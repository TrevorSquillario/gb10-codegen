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
# 16384, 32768, 49152, 65536, 81920, 98304, 114688, 131072, 147456, 163840, 180224, 196608, 212992, 229376, 245760, 262144
MAX_MODEL_LEN=${MAX_MODEL_LEN:-131072} 

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
        # State: Works A++, 50+ t/s
        # ./start_cluster.sh 192.168.10.11 qwen3.6 v0.23.0
        # uvx llama-benchy --base-url http://localhost:8090/v1 --model Qwen/Qwen3.6-35B-A3B --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 --runs 1
        MODEL="Qwen/Qwen3.6-35B-A3B"
        ARGS=(
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
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
            --load-format fastsafetensors
            --distributed-executor-backend ray
            --max-num-batched-tokens 8192
            --speculative-config '{"method": "mtp", "num_speculative_tokens": 2}'
        )
        ;;

    lukealonso/MiniMax-M2.7-NVFP4)
        # State: Doesn't work
        # --compilation-config '{"cudagraph_mode":"none","inductor_compile_config":{"combo_kernels":false,"benchmark_combo_kernel":false,"max_autotune":false,"max_autotune_gemm":false}}'
        #            --disable-custom-all-reduce
        #    --enforce-eager
        # --compilation-config '{"cudagraph_mode": "FULL_DECODE_ONLY"}'
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
        )

        export VLLM_NVFP4_GEMM_BACKEND=flashinfer-cutlass
        export VLLM_USE_FLASHINFER_MOE_FP4=0
        export SAFETENSORS_FAST_GPU=1
        export OMP_NUM_THREADS=8
        export TORCHINDUCTOR_MAX_AUTOTUNE=0
        export NCCL_PROTO=Simple
        ;;

    nvidia/MiniMax-M2.7-NVFP4)
        # State: Doesn't work
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

    cyankiwi/MiniMax-M2.7-AWQ-4bit)
        # State: Working A++
        MODEL="cyankiwi/MiniMax-M2.7-AWQ-4bit"

        ARGS=(
            --tensor-parallel-size 1
            --pipeline-parallel-size 2
            --port "$PORT"
            --host "$HOST"
            --max-model-len 131072
            --gpu-memory-utilization 0.8
            --max-num-batched-tokens 8192
            --max-num-seqs 4
            --load-format fastsafetensors
            --kv-cache-dtype fp8
            --trust-remote-code
            --enable-chunked-prefill
            --enable-prefix-caching
            --tool-call-parser minimax_m2
            --enable-auto-tool-choice 
            --reasoning-parser minimax_m2
            --distributed-executor-backend ray
            --compilation-config '{"cudagraph_mode": "PIECEWISE"}'
        )

        # Environment tweaks for DGX Spark optimized build
        #export VLLM_MARLIN_USE_ATOMIC_ADD=1
        ;;

    cyankiwi/GLM-4.7-AWQ-4bit)
        # State: Working. Slow and barely enough VRAM left
        # ./start_cluster.sh 192.168.10.11 cyankiwi/GLM-4.7-AWQ-4bit vllm/vllm-openai v0.23.0
        # uvx llama-benchy --base-url http://localhost:8090/v1 --model cyankiwi/GLM-4.7-AWQ-4bit --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 --runs 1
        MODEL="cyankiwi/GLM-4.7-AWQ-4bit"

        ARGS=(
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --port "$PORT"
            --host "$HOST"
            --max-model-len 65536
            --gpu-memory-utilization 0.9
            --max-num-batched-tokens 8192
            --max-num-seqs 4
            --kv-cache-dtype fp8
            --trust-remote-code
            --enable-chunked-prefill
            --enable-prefix-caching
            --tool-call-parser glm47
            --enable-auto-tool-choice
            --reasoning-parser glm45
            --distributed-executor-backend ray
            --compilation-config '{"cudagraph_mode": "PIECEWISE"}'
        )
        ;;

    stepfun-ai/Step-3.7-Flash-NVFP4)
        # State: Doesn't work. RuntimeError: The size of tensor a (2048) must match the size of tensor b (4096) at non-singleton dimension 1
        # ./start_cluster.sh 192.168.10.11 stepfun-ai/Step-3.7-Flash-NVFP4 stepfun37
        # ./start_cluster.sh 192.168.10.11 stepfun-ai/Step-3.7-Flash-NVFP4 v0.23.0

        # --speculative-config '{"method":"mtp","num_speculative_tokens":1}'
        MODEL="stepfun-ai/Step-3.7-Flash-NVFP4"
        ARGS=(
            --port "$PORT"
            --host "$HOST"
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --gpu-memory-utilization 0.75
            --max-num-seqs 2
            --distributed-executor-backend ray
            --trust-remote-code
            --enable-prefix-caching
            --enable-chunked-prefill
            --quantization modelopt
            --kv-cache-dtype fp8
            --max-model-len 65536
            --max-num-batched-tokens 8192
            --reasoning-parser step3p5
            --enable-auto-tool-choice
            --tool-call-parser step3p5
            --async-scheduling
            --speculative-config '{"method":"mtp","num_speculative_tokens":1}'
        )

        ;;

     cyankiwi/Step-3.7-Flash-AWQ-INT4)
        # State: Doesn't work.  RuntimeError: Some parameters like model.layers.47.mtp_block.self_attn.attn.k_zero_point are not in the checkpoint and will falsely use random initialization
        # ./start_cluster.sh 192.168.10.11 cyankiwi/Step-3.7-Flash-AWQ-INT4 v0.23.0

        # --speculative-config '{"method":"mtp","num_speculative_tokens":1}'
        MODEL="cyankiwi/Step-3.7-Flash-AWQ-INT4"
        ARGS=(
            --port "$PORT"
            --host "$HOST"
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --gpu-memory-utilization 0.75
            --max-num-seqs 2
            --distributed-executor-backend ray
            --trust-remote-code
            --enable-prefix-caching
            --enable-chunked-prefill
            --kv-cache-dtype fp8
            --max-model-len 131072
            --max-num-batched-tokens 8192
            --reasoning-parser step3p5
            --enable-auto-tool-choice
            --tool-call-parser step3p5
            --speculative-config '{"method":"mtp","num_speculative_tokens":1}'
        )

        ;;

    deepseek-ai/DeepSeek-V4-Flash)
        # ./start_cluster.sh 192.168.10.11 deepseek-ai/DeepSeek-V4-Flash aidendle94/sparkrun-vllm-ds4-gb10 production-ready
        MODEL="deepseek-ai/DeepSeek-V4-Flash"
        ARGS=(
            --served-model-name deepseek-v4-flash
            --port "$PORT"
            --host "$HOST"
            --tensor-parallel-size 2
            --pipeline-parallel-size 1
            --kv-cache-dtype fp8
            --block-size 256
            --max-model-len 131072
            --max-num-seqs 4
            --max-num-batched-tokens 8192
            --gpu-memory-utilization 0.82
            --enable-prefix-caching
            --speculative-config '{"method":"mtp","num_speculative_tokens":2}'
            --tokenizer-mode deepseek_v4
            --distributed-executor-backend ray
            --tool-call-parser deepseek_v4
            --enable-auto-tool-choice
            --reasoning-parser deepseek_v4
            --reasoning-config '{"reasoning_parser":"deepseek_v4","reasoning_start_str":"","reasoning_end_str":""}'
            --default-chat-template-kwargs.thinking=true
            --default-chat-template-kwargs.reasoning_effort=high
            --enable-flashinfer-autotune
        )

        export VLLM_ALLOW_LONG_MAX_MODEL_LEN="1"
        export VLLM_USE_B12X_MOE="1"
        export VLLM_SPARSE_INDEXER_MAX_LOGITS_MB="256"
        #export VLLM_NCCL_SO_PATH="/opt/env/lib/python3.12/.../libnccl.so.2"
        export TORCH_CUDA_ARCH_LIST="12.1a"
        export FLASHINFER_CUDA_ARCH_LIST="12.1a"
        export NCCL_IB_GID_INDEX="3"
        export NCCL_CROSS_NIC="1"
        export NCCL_CUMEM_ENABLE="0"
        export NCCL_IGNORE_CPU_AFFINITY="1"

        ;;

    *)
        echo "Unknown profile: $PROFILE"
        echo "Available profiles: gemma4, qwen3.6, minimax-m27, minimax-m27-nvfp4, nvidia/MiniMax-M2.7-NVFP4, cyankiwi/MiniMax-M2.7-AWQ-4bit, cyankiwi/GLM-4.7-Flash-AWQ-4bit, cyankiwi/Step-3.7-Flash-AWQ-INT4, deepseek-ai/DeepSeek-V4-Flash"
        exit 1
        ;;
esac

echo "Starting vllm serve for profile '$PROFILE' (model: $MODEL)"
vllm serve "$MODEL" "${ARGS[@]}" "${EXTRA_ARGS[@]}"
