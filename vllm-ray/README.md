

```
./hf_download.sh -c 192.168.1.11 lukealonso/MiniMax-M2.7-NVFP4
./start_cluster.sh 192.168.1.11 lukealonso/MiniMax-M2.7-NVFP4

./hf_download.sh -c 192.168.1.11 stepfun-ai/Step-3.7-Flash-NVFP4
./start_cluster.sh 192.168.1.11 stepfun-ai/Step-3.7-Flash-NVFP4 stepfun37

./hf_download.sh -c 192.168.20.11 cyankiwi/MiniMax-M2.7-AWQ-4bit
./start_cluster.sh 192.168.20.11 cyankiwi/MiniMax-M2.7-AWQ-4bit v0.23.0
```

### Ensure IB connectivity between nodes

Look for in vLLM startup. If it says NET/Socket it's using Ethernet
```
NET/IB : Using [0]rocep1s0f1:1/RoCE [1]roceP2p1s0f1:1/RoCE [RO]; OOB enp1s0f0np0:192.168.1.10<0>
```