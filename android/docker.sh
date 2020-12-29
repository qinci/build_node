#!/usr/bin/env bash

set -e
set -x

# supported arch:
# - arm
# - arm64
# - x86
# - x86_64

if [ $# -lt 4 ]; then
  echo "$0 should have at least 4 parameters: command, target_arch, node_source_path, output_directory"
  exit 1
fi
set -e
set -x

COMMAND=$1
ARCH=$2
NODE_SOURCE=$3
OUTPUT=$4

IMAGE_NAME=ndk20b

mkdir -p "$NODE_SOURCE"/output
mkdir -p "$NODE_SOURCE"/out/"$ARCH"/

case $COMMAND in
configure)
  # --platform linux/386
  # buildx
  docker -D build -t "$IMAGE_NAME" -f "Dockerfile" .

  docker container run -it \
    --mount type=bind,source="$NODE_SOURCE",target=/node \
    --mount type=bind,source="$NODE_SOURCE"/out/"$ARCH"/,target=/node/out \
    $IMAGE_NAME /build.sh configure "$ARCH" /node /output
  ;;
make)
  mkdir -p "$OUTPUT"
  echo building "$ARCH"
  docker container run -it \
    --mount type=bind,source="$NODE_SOURCE",target=/node \
    --mount type=bind,source="$NODE_SOURCE"/out/"$ARCH"/,target=/node/out \
    --mount type=bind,source="$OUTPUT",target=/output \
    $IMAGE_NAME /build.sh make "$ARCH" /node /output
  ;;
*)
  echo "Unsupported command provided: $COMMAND"
  exit -1
  ;;
esac
