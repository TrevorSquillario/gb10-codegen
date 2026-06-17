
DeepSeek 4
https://github.com/canada-quant/dsv4-flash-w4a16-fp8/blob/main/findings/QUICKSTART_DUAL_SPARK.md

```
# Get our DSV4-specific Dockerfile + the two patches the Dockerfile expects in the build context.
# All three are required — the Dockerfile fails with "kylesayrs-deepseek-ct.patch: not found"
# at the COPY step if you skip the patch curl.
curl -O https://raw.githubusercontent.com/canada-quant/dsv4-flash-w4a16-fp8/main/scripts/Dockerfile.dsv4-spark
curl -O https://raw.githubusercontent.com/canada-quant/dsv4-flash-w4a16-fp8/main/scripts/kylesayrs-deepseek-ct.patch
curl -O https://raw.githubusercontent.com/canada-quant/dsv4-flash-w4a16-fp8/main/scripts/patch_v4_packed_mapping.py
mv Dockerfile.dsv4-spark Dockerfile

./build-and-copy.sh \
  -t vllm-w4a16-dsv4:exp \
  --vllm-ref ds4-sm120-experimental \
  --rebuild-vllm \
  -c 192.168.10.11 \
  --full-log
```