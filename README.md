# gb10-coder
Local LLM server setup for coding

https://onyx.app/self-hosted-llm-leaderboard
# 2x GB10
- MiniMax M2.7
    https://forums.developer.nvidia.com/t/minimax-m2-7-nfvp4-recipe-benchmarks/366324/4
    https://huggingface.co/nvidia/MiniMax-M2.7-NVFP4
- DeepSeek-V4-Flash
    https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4-Flash
    https://huggingface.co/deepseek-ai/DeepSeek-V4-Flash


# Benchmark
```
# google/gemma-4-26B-A4B-it 
uvx llama-benchy --base-url http://localhost:8090/v1 --model google/gemma-4-26B-A4B-it --enable-prefix-caching --latency-mode generation --depth 32768 65536 131072

# bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4
docker compose --profile gemma4-nvfp4 up

| model                                       |                 test |    t/s (total) |        t/s (req) |      peak t/s |   peak t/s (req) |                                                                                                                                                       ttfr (ms) |        est_ppt (ms) |       e2e_ttft (ms) |
|:--------------------------------------------|---------------------:|---------------:|-----------------:|--------------:|-----------------:|-----                                                                                                                                            ---------------:|--------------------:|--------------------:|
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | ctx_pp @ d32768 (c1) | 2420.42 ± 0.00 |   2420.42 ± 0.00 |               |                  |                                                                                                                                                 14817.33 ± 0.00 |     14761.08 ± 0.00 |     14820.59 ± 0.00 |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | ctx_tg @ d32768 (c1) |   48.86 ± 0.00 |     48.86 ± 0.00 |  50.45 ± 0.00 |     50.45 ± 0.00 |                                                                                                                                                                 |                     |                     |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | pp2048 @ d32768 (c1) | 1354.86 ± 0.00 |   1354.86 ± 0.00 |               |                  |                                                                                                                                                  1567.85 ± 0.00 |      1511.60 ± 0.00 |      1571.59 ± 0.00 |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 |   tg32 @ d32768 (c1) |   48.56 ± 0.00 |     48.56 ± 0.00 |  50.13 ± 0.00 |     50.13 ± 0.00 |                                                                                                                                                                 |                     |                     |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | ctx_pp @ d32768 (c2) | 2415.03 ± 0.00 | 1797.56 ± 586.42 |               |                  |  223                                                                                                                                            11.48 ± 7279.82 |  22255.23 ± 7279.82 |  22314.79 ± 7279.92 |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | ctx_tg @ d32768 (c2) |    4.07 ± 0.00 |    23.48 ± 21.41 |  50.00 ± 0.00 |    32.17 ± 14.17 |                                                                                                                                                                 |                     |                     |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | pp2048 @ d32768 (c2) | 1295.91 ± 0.00 |  975.52 ± 315.02 |               |                  |    2                                                                                                                                            400.07 ± 756.89 |    2343.82 ± 756.89 |    2403.80 ± 756.90 |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 |   tg32 @ d32768 (c2) |   27.77 ± 0.00 |    28.56 ± 14.54 |  63.00 ± 0.00 |     37.75 ± 6.75 |                                                                                                                                                                 |                     |                     |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | ctx_pp @ d32768 (c4) | 2416.38 ± 0.00 | 1248.67 ± 686.99 |               |                  | 3694                                                                                                                                            5.93 ± 16355.92 | 36889.69 ± 16355.92 | 36945.93 ± 16355.92 |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | ctx_tg @ d32768 (c4) |    2.78 ± 0.00 |    11.86 ± 18.18 |  54.00 ± 0.00 |    17.44 ± 16.84 |                                                                                                                                                                 |                     |                     |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 | pp2048 @ d32768 (c4) | 1322.32 ± 0.00 |  577.45 ± 287.73 |               |                  |   43                                                                                                                                            86.89 ± 1639.54 |   4330.64 ± 1639.54 |   4387.29 ± 1639.83 |
| bg-digitalservices/Gemma-4-26B-A4B-it-NVFP4 |   tg32 @ d32768 (c4) |   23.94 ± 0.00 |     16.65 ± 9.99 | 122.00 ± 0.00 |     30.66 ± 1.34 |                                                                                                                                                                 |                     |                     |



# lukealonso/MiniMax-M2.7-NVFP4
./start_cluster.sh 192.168.10.11 lukealonso/MiniMax-M2.7-NVFP4 v0.23.0
uvx llama-benchy --base-url http://localhost:8090/v1 --model lukealonso/MiniMax-M2.7-NVFP4 --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2

| model                         |                 test |     t/s (total) |        t/s (req) |     peak t/s |   peak t/s (req) |          ttfr (ms) |       est_ppt (ms) |      e2e_ttft (ms) |
|:------------------------------|---------------------:|----------------:|-----------------:|-------------:|-----------------:|-------------------:|-------------------:|-------------------:|
| lukealonso/MiniMax-M2.7-NVFP4 | ctx_pp @ d32768 (c1) | 2061.07 ± 27.87 |  2061.07 ± 27.87 |              |                  |  16014.75 ± 217.07 |  15901.47 ± 217.07 |  16014.75 ± 217.07 |
| lukealonso/MiniMax-M2.7-NVFP4 | ctx_tg @ d32768 (c1) |    20.26 ± 0.51 |     20.26 ± 0.51 | 21.00 ± 0.82 |     21.00 ± 0.82 |                    |                    |                    |
| lukealonso/MiniMax-M2.7-NVFP4 | pp2048 @ d32768 (c1) | 1217.30 ± 21.39 |  1217.30 ± 21.39 |              |                  |    1796.22 ± 29.85 |    1682.94 ± 29.85 |    1796.81 ± 29.62 |
| lukealonso/MiniMax-M2.7-NVFP4 |   tg32 @ d32768 (c1) |    19.84 ± 0.07 |     19.84 ± 0.07 | 20.33 ± 0.47 |     20.33 ± 0.47 |                    |                    |                    |
| lukealonso/MiniMax-M2.7-NVFP4 | ctx_pp @ d32768 (c2) | 2009.16 ± 21.54 | 1518.94 ± 511.09 |              |                  | 24439.78 ± 8185.22 | 24326.50 ± 8185.22 | 24441.78 ± 8185.31 |
| lukealonso/MiniMax-M2.7-NVFP4 | ctx_tg @ d32768 (c2) |     3.40 ± 0.03 |      9.15 ± 7.43 | 34.00 ± 0.00 |     17.00 ± 0.00 |                    |                    |                    |
| lukealonso/MiniMax-M2.7-NVFP4 | pp2048 @ d32768 (c2) | 1255.13 ± 18.21 |    651.10 ± 9.59 |              |                  |    3259.40 ± 46.64 |    3146.12 ± 46.64 |    3262.47 ± 47.15 |
| lukealonso/MiniMax-M2.7-NVFP4 |   tg32 @ d32768 (c2) |    31.85 ± 0.64 |     15.94 ± 0.33 | 34.00 ± 0.00 |     17.00 ± 0.00 |                    |                    |                    |

# cyankiwi/MiniMax-M2.7-AWQ-4bit
./start_cluster.sh 192.168.10.11 cyankiwi/MiniMax-M2.7-AWQ-4bit v0.23.0

uvx llama-benchy --base-url http://localhost:8090/v1 --model cyankiwi/MiniMax-M2.7-AWQ-4bit --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 --runs 1

| model                          |                 test |    t/s (total) |        t/s (req) |     peak t/s |   peak t/s (req) |           ttfr (ms) |        est_ppt (ms) |       e2e_ttft (ms) |
|:-------------------------------|---------------------:|---------------:|-----------------:|-------------:|-----------------:|--------------------:|--------------------:|--------------------:|
| cyankiwi/MiniMax-M2.7-AWQ-4bit | ctx_pp @ d32768 (c1) | 2042.79 ± 0.00 |   2042.79 ± 0.00 |              |                  |     16179.66 ± 0.00 |     16040.79 ± 0.00 |     16180.79 ± 0.00 |
| cyankiwi/MiniMax-M2.7-AWQ-4bit | ctx_tg @ d32768 (c1) |   19.69 ± 0.00 |     19.69 ± 0.00 | 20.00 ± 0.00 |     20.00 ± 0.00 |                     |                     |                     |
| cyankiwi/MiniMax-M2.7-AWQ-4bit | pp2048 @ d32768 (c1) |  766.96 ± 0.00 |    766.96 ± 0.00 |              |                  |      2809.16 ± 0.00 |      2670.29 ± 0.00 |      2811.54 ± 0.00 |
| cyankiwi/MiniMax-M2.7-AWQ-4bit |   tg32 @ d32768 (c1) |   19.42 ± 0.00 |     19.42 ± 0.00 | 20.00 ± 0.00 |     20.00 ± 0.00 |                     |                     |                     |
| cyankiwi/MiniMax-M2.7-AWQ-4bit | ctx_pp @ d32768 (c2) | 1607.00 ± 0.00 | 1416.62 ± 610.34 |              |                  | 28542.43 ± 12237.47 | 28403.56 ± 12237.47 | 28543.69 ± 12237.44 |
| cyankiwi/MiniMax-M2.7-AWQ-4bit | ctx_tg @ d32768 (c2) |    2.31 ± 0.00 |      7.28 ± 6.11 | 26.00 ± 0.00 |     14.00 ± 1.00 |                     |                     |                     |
| cyankiwi/MiniMax-M2.7-AWQ-4bit | pp2048 @ d32768 (c2) |  804.72 ± 0.00 |    413.98 ± 0.08 |              |                  |      5085.92 ± 1.00 |      4947.05 ± 1.00 |      5089.65 ± 0.01 |
| cyankiwi/MiniMax-M2.7-AWQ-4bit |   tg32 @ d32768 (c2) |   24.83 ± 0.00 |     12.41 ± 0.00 | 28.00 ± 0.00 |     14.00 ± 0.00 |                     |                     |                     |

# stepfun-ai/Step-3.7-Flash-NVFP4
./start_cluster.sh 192.168.10.11 stepfun-ai/Step-3.7-Flash-NVFP4 v0.23.0

uvx llama-benchy --base-url http://localhost:8090/v1 --model stepfun-ai/Step-3.7-Flash-NVFP4 --enable-prefix-caching --latency-mode generation ---adapt-prompt --depth 32768 --concurrency 1 2 4 --runs 1


| model                           |                 test |    t/s (total) |        t/s (req) |     peak t/s |   peak t/s (req) |           ttfr (ms) |        est_ppt (ms) |       e2e_ttft (ms) |
|:--------------------------------|---------------------:|---------------:|-----------------:|-------------:|-----------------:|--------------------:|--------------------:|--------------------:|
| stepfun-ai/Step-3.7-Flash-NVFP4 | ctx_pp @ d32768 (c1) | 2942.00 ± 0.00 |   2942.00 ± 0.00 |              |                  |     11256.91 ± 0.00 |     11138.69 ± 0.00 |     11258.84 ± 0.00 |
| stepfun-ai/Step-3.7-Flash-NVFP4 | ctx_tg @ d32768 (c1) |   30.78 ± 0.00 |     30.78 ± 0.00 | 31.00 ± 0.00 |     31.00 ± 0.00 |                     |                     |                     |
| stepfun-ai/Step-3.7-Flash-NVFP4 | pp2048 @ d32768 (c1) | 1985.55 ± 0.00 |   1985.55 ± 0.00 |              |                  |      1149.66 ± 0.00 |      1031.45 ± 0.00 |      1152.87 ± 0.00 |
| stepfun-ai/Step-3.7-Flash-NVFP4 |   tg32 @ d32768 (c1) |   28.89 ± 0.00 |     28.89 ± 0.00 | 30.00 ± 0.00 |     30.00 ± 0.00 |                     |                     |                     |
| stepfun-ai/Step-3.7-Flash-NVFP4 | ctx_pp @ d32768 (c2) | 3005.56 ± 0.00 | 2027.35 ± 516.45 |              |                  |  17406.25 ± 4402.98 |  17288.04 ± 4402.98 |  17406.91 ± 4402.31 |
| stepfun-ai/Step-3.7-Flash-NVFP4 | ctx_tg @ d32768 (c2) |    6.05 ± 0.00 |     12.36 ± 9.22 | 47.00 ± 0.00 |     23.50 ± 0.50 |                     |                     |                     |
| stepfun-ai/Step-3.7-Flash-NVFP4 | pp2048 @ d32768 (c2) | 2319.58 ± 0.00 |   1247.56 ± 1.19 |              |                  |      1759.82 ± 1.57 |      1641.60 ± 1.57 |      1763.61 ± 2.23 |
| stepfun-ai/Step-3.7-Flash-NVFP4 |   tg32 @ d32768 (c2) |   48.84 ± 0.00 |     25.16 ± 0.74 | 57.00 ± 0.00 |     28.50 ± 0.50 |                     |                     |                     |
| stepfun-ai/Step-3.7-Flash-NVFP4 | ctx_pp @ d32768 (c4) | 2951.52 ± 0.00 | 1444.56 ± 684.57 |              |                  | 28111.80 ± 11861.29 | 27993.58 ± 11861.29 | 28112.91 ± 11860.43 |
| stepfun-ai/Step-3.7-Flash-NVFP4 | ctx_tg @ d32768 (c4) |    3.82 ± 0.00 |     8.67 ± 10.08 | 50.00 ± 0.00 |     24.75 ± 1.48 |                     |                     |                     |
| stepfun-ai/Step-3.7-Flash-NVFP4 | pp2048 @ d32768 (c4) | 1617.32 ± 0.00 | 1058.10 ± 711.70 |              |                  |   3055.51 ± 1614.74 |   2937.30 ± 1614.74 |   3057.38 ± 1614.70 |
| stepfun-ai/Step-3.7-Flash-NVFP4 |   tg32 @ d32768 (c4) |   22.76 ± 0.00 |     18.89 ± 4.55 | 52.00 ± 0.00 |     24.50 ± 1.50 |                     |                     |                     |

# cyankiwi/Step-3.7-Flash-AWQ-INT4
./start_cluster.sh 192.168.10.11 cyankiwi/Step-3.7-Flash-AWQ-INT4

uvx llama-benchy --base-url http://localhost:8090/v1 --model cyankiwi/Step-3.7-Flash-AWQ-INT4 --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 4 --runs 1
# Errors out with "(APIServer pid=516) AttributeError: '_IncludedRouter' object has no attribute 'path'"

# Qwen/Qwen3.6-27B
uvx llama-benchy --base-url http://localhost:8090/v1 --model Qwen/Qwen3.6-27B --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2


| model            |                 test |    t/s (total) |      t/s (req) |     peak t/s |   peak t/s (req) |          ttfr (ms) |       est_ppt (ms) |      e2e_ttft (ms) |
|:-----------------|---------------------:|---------------:|---------------:|-------------:|-----------------:|-------------------:|-------------------:|-------------------:|
| Qwen/Qwen3.6-27B | ctx_pp @ d32768 (c1) | 1146.70 ± 0.00 | 1146.70 ± 0.00 |              |                  |    28910.13 ± 0.00 |    28576.90 ± 0.00 |    28910.13 ± 0.00 |
| Qwen/Qwen3.6-27B | ctx_tg @ d32768 (c1) |   11.69 ± 0.00 |   11.69 ± 0.00 | 14.00 ± 0.00 |     14.00 ± 0.00 |                    |                    |                    |
| Qwen/Qwen3.6-27B | pp2048 @ d32768 (c1) |  419.59 ± 0.00 |  419.59 ± 0.00 |              |                  |     5214.21 ± 0.00 |     4880.98 ± 0.00 |     5214.21 ± 0.00 |
| Qwen/Qwen3.6-27B |   tg32 @ d32768 (c1) |   11.52 ± 0.00 |   11.52 ± 0.00 | 14.00 ± 0.00 |     14.00 ± 0.00 |                    |                    |                    |
| Qwen/Qwen3.6-27B | ctx_pp @ d32768 (c2) | 1149.49 ± 0.00 | 594.22 ± 16.09 |              |                  | 55520.03 ± 1494.66 | 55186.80 ± 1494.66 | 55520.03 ± 1494.66 |
| Qwen/Qwen3.6-27B | ctx_tg @ d32768 (c2) |   10.67 ± 0.00 |    8.40 ± 2.59 | 27.00 ± 0.00 |     14.00 ± 0.00 |                    |                    |                    |
| Qwen/Qwen3.6-27B | pp2048 @ d32768 (c2) |  422.68 ± 0.00 |  222.51 ± 3.63 |              |                  |   9539.65 ± 150.27 |   9206.42 ± 150.27 |   9540.54 ± 149.38 |
| Qwen/Qwen3.6-27B |   tg32 @ d32768 (c2) |   23.39 ± 0.00 |   13.16 ± 0.02 | 28.00 ± 0.00 |     14.00 ± 0.00 |                    |                    |                    |

# Qwen/Qwen3.6-35B-A3B
uvx llama-benchy --base-url http://localhost:8090/v1 --model Qwen/Qwen3.6-35B-A3B --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 --runs 1

| model                |                 test |    t/s (total) |         t/s (req) |     peak t/s |   peak t/s (req) |         ttfr (ms) |      est_ppt (ms) |     e2e_ttft (ms) |
|:---------------------|---------------------:|---------------:|------------------:|-------------:|-----------------:|------------------:|------------------:|------------------:|
| Qwen/Qwen3.6-35B-A3B | ctx_pp @ d32768 (c1) | 5734.82 ± 0.00 |    5734.82 ± 0.00 |              |                  |    5816.79 ± 0.00 |    5714.04 ± 0.00 |    5818.68 ± 0.00 |
| Qwen/Qwen3.6-35B-A3B | ctx_tg @ d32768 (c1) |   56.85 ± 0.00 |      56.85 ± 0.00 | 58.69 ± 0.00 |     58.69 ± 0.00 |                   |                   |                   |
| Qwen/Qwen3.6-35B-A3B | pp2048 @ d32768 (c1) | 1785.47 ± 0.00 |    1785.47 ± 0.00 |              |                  |    1249.78 ± 0.00 |    1147.03 ± 0.00 |    1251.65 ± 0.00 |
| Qwen/Qwen3.6-35B-A3B |   tg32 @ d32768 (c1) |   56.02 ± 0.00 |      56.02 ± 0.00 | 57.83 ± 0.00 |     57.83 ± 0.00 |                   |                   |                   |
| Qwen/Qwen3.6-35B-A3B | ctx_pp @ d32768 (c2) | 5697.92 ± 0.00 | 3913.77 ± 1038.39 |              |                  | 9109.50 ± 2389.64 | 9006.75 ± 2389.64 | 9111.67 ± 2390.11 |
| Qwen/Qwen3.6-35B-A3B | ctx_tg @ d32768 (c2) |   11.30 ± 0.00 |     24.92 ± 19.00 | 50.00 ± 0.00 |    32.17 ± 13.17 |                   |                   |                   |
| Qwen/Qwen3.6-35B-A3B | pp2048 @ d32768 (c2) | 1653.29 ± 0.00 |  1277.45 ± 414.05 |              |                  |  1894.14 ± 580.63 |  1791.39 ± 580.63 |  1896.86 ± 580.62 |
| Qwen/Qwen3.6-35B-A3B |   tg32 @ d32768 (c2) |   33.35 ± 0.00 |     31.24 ± 13.15 | 59.00 ± 0.00 |     36.41 ± 9.41 |                   |                   |                   |


# Intel/Qwen3.5-122B-A10B-int4-AutoRound
uvx llama-benchy --base-url http://localhost:8090/v1 --model Intel/Qwen3.5-122B-A10B-int4-AutoRound --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 4 --runs 1

| model                                  |                 test |    t/s (total) |       t/s (req) |      peak t/s |   peak t/s (req) |           ttfr (ms) |        est_ppt (ms) |       e2e_ttft (ms) |
|:---------------------------------------|---------------------:|---------------:|----------------:|--------------:|-----------------:|--------------------:|--------------------:|--------------------:|
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | ctx_pp @ d32768 (c1) | 1791.69 ± 0.00 |  1791.69 ± 0.00 |               |                  |     18428.70 ± 0.00 |     18289.42 ± 0.00 |     18428.70 ± 0.00 |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | ctx_tg @ d32768 (c1) |   42.15 ± 0.00 |    42.15 ± 0.00 |  43.52 ± 0.00 |     43.52 ± 0.00 |                     |                     |                     |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | pp2048 @ d32768 (c1) |  312.37 ± 0.00 |   312.37 ± 0.00 |               |                  |      6695.66 ± 0.00 |      6556.38 ± 0.00 |      6695.66 ± 0.00 |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound |   tg32 @ d32768 (c1) |   42.36 ± 0.00 |    42.36 ± 0.00 |  43.73 ± 0.00 |     43.73 ± 0.00 |                     |                     |                     |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | ctx_pp @ d32768 (c2) | 1721.11 ± 0.00 | 984.32 ± 120.61 |               |                  |  33937.69 ± 4141.27 |  33798.41 ± 4141.27 |  33939.12 ± 4139.85 |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | ctx_tg @ d32768 (c2) |    6.66 ± 0.00 |   16.88 ± 13.39 |  51.00 ± 0.00 |     27.50 ± 3.50 |                     |                     |                     |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | pp2048 @ d32768 (c2) |  306.06 ± 0.00 |   155.20 ± 0.55 |               |                  |    13335.57 ± 46.73 |    13196.28 ± 46.73 |    13337.39 ± 44.90 |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound |   tg32 @ d32768 (c2) |   71.15 ± 0.00 |    40.07 ± 0.38 |  73.45 ± 0.00 |     41.36 ± 0.39 |                     |                     |                     |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | ctx_pp @ d32768 (c4) | 1676.64 ± 0.00 | 646.27 ± 274.36 |               |                  | 58673.31 ± 18946.61 | 58534.02 ± 18946.61 | 58673.90 ± 18945.70 |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | ctx_tg @ d32768 (c4) |    2.51 ± 0.00 |    9.02 ± 11.80 |  80.00 ± 0.00 |     21.50 ± 7.53 |                     |                     |                     |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound | pp2048 @ d32768 (c4) |  301.64 ± 0.00 |    79.36 ± 5.88 |               |                  |  26076.73 ± 1770.60 |  25937.45 ± 1770.60 |  26078.84 ± 1769.81 |
| Intel/Qwen3.5-122B-A10B-int4-AutoRound |   tg32 @ d32768 (c4) |   23.49 ± 0.00 |    22.67 ± 9.85 | 113.00 ± 0.00 |     28.38 ± 2.69 |                     |                     |                     |

# deepseek-ai/DeepSeek-V4-Flash
./run-recipe.sh deepseek-v4-flash --force-build
uvx llama-benchy --base-url http://localhost:8000/v1 --model deepseek-v4-flash --enable-prefix-caching --latency-mode generation --depth 32768 --concurrency 1 2 4 --runs 1

| model             |                 test |    t/s (total) |       t/s (req) |     peak t/s |   peak t/s (req) |           ttfr (ms) |        est_ppt (ms) |       e2e_ttft (ms) |
|:------------------|---------------------:|---------------:|----------------:|-------------:|-----------------:|--------------------:|--------------------:|--------------------:|
| deepseek-v4-flash | ctx_pp @ d32768 (c1) | 1183.96 ± 0.00 |  1183.96 ± 0.00 |              |                  |     24840.22 ± 0.00 |     24613.11 ± 0.00 |     24842.96 ± 0.00 |
| deepseek-v4-flash | ctx_tg @ d32768 (c1) |   40.94 ± 0.00 |    40.94 ± 0.00 | 42.26 ± 0.00 |     42.26 ± 0.00 |                     |                     |                     |
| deepseek-v4-flash | pp2048 @ d32768 (c1) | 1120.38 ± 0.00 |  1120.38 ± 0.00 |              |                  |      2055.06 ± 0.00 |      1827.95 ± 0.00 |      2057.75 ± 0.00 |
| deepseek-v4-flash |   tg32 @ d32768 (c1) |   34.04 ± 0.00 |    34.04 ± 0.00 | 35.13 ± 0.00 |     35.13 ± 0.00 |                     |                     |                     |
| deepseek-v4-flash | ctx_pp @ d32768 (c2) | 1282.23 ± 0.00 | 821.90 ± 182.70 |              |                  |  37937.54 ± 8096.64 |  37710.43 ± 8096.64 |  37940.29 ± 8096.65 |
| deepseek-v4-flash | ctx_tg @ d32768 (c2) |    3.66 ± 0.00 |    39.67 ± 1.77 | 32.00 ± 0.00 |     40.95 ± 1.82 |                     |                     |                     |
| deepseek-v4-flash | pp2048 @ d32768 (c2) |  826.29 ± 0.00 | 792.64 ± 359.61 |              |                  |   3480.52 ± 1476.01 |   3253.40 ± 1476.01 |   3481.67 ± 1474.86 |
| deepseek-v4-flash |   tg32 @ d32768 (c2) |   15.97 ± 0.00 |    33.13 ± 0.12 | 32.00 ± 0.00 |     34.20 ± 0.13 |                     |                     |                     |
| deepseek-v4-flash | ctx_pp @ d32768 (c4) | 1198.68 ± 0.00 | 591.48 ± 327.14 |              |                  | 63716.91 ± 27272.22 | 63489.79 ± 27272.22 | 63718.78 ± 27272.04 |
| deepseek-v4-flash | ctx_tg @ d32768 (c4) |    1.71 ± 0.00 |    37.70 ± 4.75 | 32.00 ± 0.00 |     38.67 ± 5.29 |                     |                     |                     |
| deepseek-v4-flash | pp2048 @ d32768 (c4) |  828.84 ± 0.00 | 486.52 ± 475.09 |              |                  |   7855.68 ± 3501.34 |   7628.56 ± 3501.34 |   7860.06 ± 3502.32 |
| deepseek-v4-flash |   tg32 @ d32768 (c4) |   13.14 ± 0.00 |    25.77 ± 2.48 | 77.00 ± 0.00 |     27.00 ± 2.74 |                     |                     |                     |
