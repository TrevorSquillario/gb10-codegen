# Dockerfile.vllm
# allow passing model name and image name at build-time
ARG MODEL_NAME=gemma4
ARG BASE_IMAGE=vllm/vllm-openai
ARG BASE_IMAGE_TAG=latest
FROM vllm/vllm-openai:${BASE_IMAGE_TAG}

# expose MODEL_NAME and IMAGE_NAME to the container runtime
ENV MODEL_NAME=${MODEL_NAME}
ENV BASE_IMAGE=${BASE_IMAGE}
ENV BASE_IMAGE_TAG=${BASE_IMAGE_TAG}
#FROM vllm/vllm-openai:v0.22.0

# Upgrade transformers to a recent compatible version
RUN pip install --no-cache-dir --upgrade "transformers>=5.5.0"

# Update NCCL to latest
# https://github.com/vllm-project/vllm/issues/30682
RUN pip install -U nvidia-nccl-cu13

# Install Ray for distributed computing
RUN pip install --no-cache-dir "ray[default]"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh