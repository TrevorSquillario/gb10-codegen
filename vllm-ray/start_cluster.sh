#!/bin/bash

# Parse options
FORCE=false
while getopts "f" opt; do
    case $opt in
        f) FORCE=true ;;
        *) echo "Usage: $0 [-f] <remote-ip> <model-name> <base-image>"; exit 1 ;;
    esac
done
shift $((OPTIND-1))

if [ $# -lt 3 ]; then
        echo "Usage: $0 [-f] <remote-ip> <model-name> <base-image>"
        exit 1
fi

REMOTE_IP="$1"
MODEL_NAME="$2"
BASE_IMAGE_TAG="$3"
BASE_IMAGE="vllm/vllm-openai:${BASE_IMAGE_TAG:-latest}"

# Start remote workers
echo "Starting remote workers on $REMOTE_IP..."

# Ensure remote has compose files (but do NOT build there)
echo "Copying vllm-ray to remote host..."
rsync -av --delete ../vllm-ray/ "$REMOTE_IP":~/vllm-ray/
echo "Dropping caches on remote host..."
ssh "$REMOTE_IP" "sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'"

echo "Building worker image locally with MODEL_NAME=$MODEL_NAME and BASE_IMAGE_TAG=$BASE_IMAGE_TAG..."
# Build the worker image locally and tag it explicitly so we can save/load
docker compose --profile worker build --build-arg MODEL_NAME="$MODEL_NAME" --build-arg BASE_IMAGE_TAG="$BASE_IMAGE_TAG"

IMAGE_NAME="vllm-ray-vllm-worker:latest"

echo "Checking if $IMAGE_NAME exists on remote host $REMOTE_IP..."
skip_transfer=false
if ssh "$REMOTE_IP" "docker image inspect '$IMAGE_NAME' > /dev/null 2>&1"; then
    if [ "$FORCE" = true ]; then
        echo "Remote already has $IMAGE_NAME but -f specified; will overwrite."
    else
        echo "Remote already has $IMAGE_NAME. Skipping save/copy/load and starting remote worker services."
        ssh "$REMOTE_IP" "cd ~/vllm-ray && docker compose --profile worker up -d --no-build"
        skip_transfer=true
    fi
fi

if [ "$skip_transfer" = false ]; then
    echo "Saving worker image $IMAGE_NAME to tar..."
    docker save -o worker_image.tar "$IMAGE_NAME"

    echo "Copying worker image tar to remote host..."
    scp worker_image.tar "$REMOTE_IP":~/vllm-ray/worker_image.tar

    echo "Loading worker image on remote host and starting services..."
    ssh "$REMOTE_IP" "cd ~/vllm-ray && sudo docker load -i worker_image.tar && rm -f worker_image.tar && docker compose --profile worker up -d --no-build"

    echo "Cleaning up local image tar..."
    rm -f worker_image.tar
fi

# Start local head
echo "Starting local head with model: $MODEL_NAME..."
export MODEL_NAME="$MODEL_NAME"
echo "Dropping caches on local host..."
sudo sh -c 'echo 3 > /proc/sys/vm/drop_caches'
docker compose --profile head build --build-arg MODEL_NAME="$MODEL_NAME" --build-arg BASE_IMAGE_TAG="$BASE_IMAGE_TAG"
docker compose --profile head up

