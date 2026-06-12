#!/bin/bash
set -e

# Usage: entrypoint.sh [profile] [-- extra vllm args]
# profile: gemma4 | qwen3.6 | minimax-m27

# First argument selects which serve profile to run (default: gemma4)
PROFILE=${1:-gemma4}
NODE_RANK=${2:-0}
# Remove both PROFILE and NODE_RANK from positional params so $@ holds only extra vllm args
shift 2 || true

# Start Ray: head if NODE_RANK == 1, otherwise start as worker
if [ "$NODE_RANK" = "1" ]; then
    echo "Starting Ray on head node (NODE_RANK=1)"
    ray start --block --head --node-ip-address=192.168.10.10 --object-store-memory=2147483648 --port=6379 --dashboard-host=0.0.0.0 --dashboard-port=8265 --metrics-export-port=8080 &
else
    echo "Starting Ray on worker node (NODE_RANK=$NODE_RANK)"
    ray start --block --address=192.168.10.10:6379 --node-ip-address=192.168.10.11 --object-store-memory=2147483648
fi

sleep 5  # Wait for Ray to start

# Any additional args after the profile are passed directly to vllm
EXTRA_ARGS=("$@")

# Defaults (can be overridden via env vars)
PORT=${PORT:-8090}
HOST=${HOST:-0.0.0.0}
GPU_MEMORY_UTILIZATION=${GPU_MEMORY_UTILIZATION:-0.65}
MAX_MODEL_LEN=${MAX_MODEL_LEN:-131072} # 65536, 131072

case "$PROFILE" in
    gemma4)
        MODEL="google/gemma-4-26B-A4B-it"
        ARGS=(
            --tensor-parallel-size 1
            --pipeline-parallel-size 2
            --port "$PORT"
            --max-model-len "$MAX_MODEL_LEN"
            --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION"
            --trust-remote-code
            --enable-prefix-caching
            --kv-cache-dtype fp8
            --reasoning-parser gemma4
            --tool-call-parser gemma4
            --enable-auto-tool-choice
            --enable-chunked-prefill
            --max-num-batched-tokens 8192
            --distributed-executor-backend ray
        )
        ;;

    qwen3.6)
        MODEL="Qwen/Qwen3.6-35B-A3B"
        ARGS=(
            --tensor-parallel-size 1
            --pipeline-parallel-size 2
            --port "$PORT"
            --max-model-len "$MAX_MODEL_LEN"
            --gpu-memory-utilization "$GPU_MEMORY_UTILIZATION"
            --trust-remote-code
            --enable-prefix-caching
            --kv-cache-dtype fp8
            --reasoning-parser qwen3
            --tool-call-parser qwen3_coder
            --enable-auto-tool-choice
            --enable-chunked-prefill
            --distributed-executor-backend ray
        )
        ;;

    lukealonso/MiniMax-M2.7-NVFP4)
        # --compilation-config '{"cudagraph_mode":"none","inductor_compile_config":{"combo_kernels":false,"benchmark_combo_kernel":false,"max_autotune":false,"max_autotune_gemm":false}}'
        #            --disable-custom-all-reduce
        #    --enforce-eager
        MODEL="lukealonso/MiniMax-M2.7-NVFP4"
        ARGS=(
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --port "$PORT"
            --host "$HOST"
            --gpu-memory-utilization 0.7
            --max-model-len 131072
            --max-num-seqs 2
            --kv-cache-dtype fp8
            --distributed-executor-backend ray
            --trust-remote-code
            --attention-backend flashinfer
            --attention-config.use_trtllm_attention=0
            --enable-prefix-caching
            --enable-chunked-prefill
            --load-format fastsafetensors
            --enable-auto-tool-choice
            --max-num-batched-tokens 8192
            --tool-call-parser minimax_m2
            --reasoning-parser minimax_m2_append_think
            --disable-custom-all-reduce 
            --compilation-config '{"cudagraph_mode": "FULL_DECODE_ONLY"}'
        )

        export VLLM_NVFP4_GEMM_BACKEND=flashinfer-cutlass
        export VLLM_USE_FLASHINFER_MOE_FP4=0
        export SAFETENSORS_FAST_GPU=1
        export OMP_NUM_THREADS=8
        export TORCHINDUCTOR_MAX_AUTOTUNE=0
        export NCCL_PROTO=Simple
        ;;

    nvidia/MiniMax-M2.7-NVFP4)
        MODEL="nvidia/MiniMax-M2.7-NVFP4"
        ARGS=(
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --port "$PORT"
            --host "$HOST"
            --gpu-memory-utilization 0.7
            --max-model-len 131072
            --max-num-seqs 2
            --distributed-executor-backend ray
            --trust-remote-code 
            --kv-cache-dtype fp8 
            --compilation-config '{"mode":3,"pass_config":{"fuse_minimax_qk_norm":true}}'
            --tool-call-parser minimax_m2 
            --enable-auto-tool-choice 
            --reasoning-parser minimax_m2
            --load-format fastsafetensors
            --disable-custom-all-reduce
            --enforce-eager
        )

        export VLLM_NVFP4_GEMM_BACKEND=flashinfer-cutlass 
        export VLLM_USE_FLASHINFER_MOE_FP4=1
        export OMP_NUM_THREADS=8
        export VLLM_MEMORY_PROFILER_ESTIMATE_CUDAGRAPHS=1
        export VLLM_FLASHINFER_MOE_BACKEND=throughput
        ;;


    stepfun-ai/Step-3.7-Flash-NVFP4)
        # ./start_cluster.sh 192.168.10.11 stepfun-ai/Step-3.7-Flash-NVFP4 stepfun37

        MODEL="stepfun-ai/Step-3.7-Flash-NVFP4"
        ARGS=(
            --port "$PORT"
            --host "$HOST"
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --gpu-memory-utilization 0.70
            --max-num-seqs 2
            --distributed-executor-backend ray
            --trust-remote-code
            --enable-prefix-caching
            --enable-chunked-prefill
            --quantization modelopt
            --kv-cache-dtype fp8
            --max-model-len 131072
            --max-num-batched-tokens 8192
            --reasoning-parser step3p5
            --enable-auto-tool-choice
            --tool-call-parser step3p5
            --async-scheduling
            --speculative-config '{"method":"mtp","num_speculative_tokens":1}'
        )

        ;;

    *)
        echo "Unknown profile: $PROFILE"
        echo "Available profiles: gemma4, qwen3.6, minimax-m27, minimax-m27-nvfp4, stepfun-ai/Step-3.7-Flash-NVFP4"
        exit 1
        ;;
esac

echo "Starting vllm serve for profile '$PROFILE' (model: $MODEL)"
vllm serve "$MODEL" "${ARGS[@]}" "${EXTRA_ARGS[@]}"
