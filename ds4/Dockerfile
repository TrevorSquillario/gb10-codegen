# ==========================================
# Stage 1: Build environment (ARM64 CUDA Devel)
# ==========================================
FROM nvidia/cuda:13.0.2-devel-ubuntu24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies required for compiling ds4
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    build-essential \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# Clone antirez/ds4
RUN git clone https://github.com/antirez/ds4.git .

# Build for Blackwell & ARM. 
# We specify the compute capability for Blackwell (sm_100) 
# and enable CUDA compilation for ds4.
#ENV NVCCFLAGS="-arch=sm_100"
RUN make cuda-spark

# ==========================================
# Stage 2: Runtime environment (ARM64 CUDA Runtime)
# ==========================================
FROM nvidia/cuda:13.0.2-runtime-ubuntu24.04

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy binaries and model downloader from the builder stage
COPY --from=builder /build/ds4 /app/ds4
COPY --from=builder /build/ds4-server /app/ds4-server

EXPOSE 8080

ENTRYPOINT ["./ds4-server"]
CMD ["--help"]