
# Run DeepSeek-V4-Flash on a single GB10 using antirez ds4 project

```
git clone https://github.com/antirez/ds4.git
cd ds4
./download_model.sh q2-imatrix
./download_model.sh mtp
make cuda-spark
./ds4 -m ./gguf/DeepSeek-V4-Flash-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8-chat-v2-imatrix.gguf

# Start OpenAI Compatible server at :8000
./ds4-server --host 0.0.0.0 -m ./gguf/DeepSeek-V4-Flash-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8-chat-v2-imatrix.gguf -c 131072

# With MTP (experimental and does not provide a t/s boost at this time)
./ds4-server --host 0.0.0.0 -m ./gguf/DeepSeek-V4-Flash-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8-chat-v2-imatrix.gguf -c 131072 --mtp ./gguf/DeepSeek-V4-Flash-MTP-Q4K-Q8_0-F32.gguf --mtp-draft 2
```

# Benchmark
```
./ds4-bench \
  -m ./gguf/DeepSeek-V4-Flash-IQ2XXS-w2Q2K-AProjQ8-SExpQ8-OutQ8-chat-v2-imatrix.gguf \
  --prompt-file speed-bench/promessi_sposi.txt \
  --ctx-start 2048 \
  --ctx-max 65536 \
  --step-incr 2048 \
  --gen-tokens 128

uvx llama-benchy --base-url http://localhost:8000/v1 --model deepseek-ai/DeepSeek-V4-Flash --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 --runs 1

*DS4 doesn't do proper parallel concurrency for multiple requests at this time

| model                         |                 test |   t/s (total) |     t/s (req) |     peak t/s |   peak t/s (req) |       ttfr (ms) |    est_ppt (ms) |    e2e_ttft (ms) |
|:------------------------------|---------------------:|--------------:|--------------:|-------------:|-----------------:|----------------:|----------------:|-----------------:|
| deepseek-ai/DeepSeek-V4-Flash | ctx_pp @ d32768 (c1) | 364.45 ± 0.00 | 364.45 ± 0.00 |              |                  | 93281.68 ± 0.00 | 93125.40 ± 0.00 |  93442.65 ± 0.00 |
| deepseek-ai/DeepSeek-V4-Flash | ctx_tg @ d32768 (c1) |  26.01 ± 0.00 |  26.01 ± 0.00 | 28.00 ± 0.00 |     28.00 ± 0.00 |                 |                 |                  |
| deepseek-ai/DeepSeek-V4-Flash | pp2048 @ d32768 (c1) |  20.54 ± 0.00 |  20.54 ± 0.00 |              |                  | 99860.26 ± 0.00 | 99703.98 ± 0.00 | 100021.58 ± 0.00 |
| deepseek-ai/DeepSeek-V4-Flash |   tg32 @ d32768 (c1) |  25.48 ± 0.00 |  25.48 ± 0.00 | 28.00 ± 0.00 |     28.00 ± 0.00 |                 |                 |                  |

```