#!/usr/bin/env bash

set -e
set -x

# supported arch:
# - arm
# - arm64
# - x86
# - x86_64

COMMAND=$1
ARCH=$2
OUTPUT=$PWD/$3

IMAGE_NAME=ndk20b
NODE_SOURCES=`dirname  $PWD`/node

mkdir -p "$NODE_SOURCES"/output
mkdir -p "$NODE_SOURCES"/out/"$ARCH"/

case $COMMAND in
configure)
  # --platform linux/386
  # buildx
  docker -D build -t "$IMAGE_NAME" -f "Dockerfile" .

  docker container run -it \
    --mount type=bind,source="$NODE_SOURCES",target=/node \
    --mount type=bind,source="$NODE_SOURCES"/out/"$ARCH"/,target=/node/out \
    $IMAGE_NAME /env.sh configure "$ARCH" /node /output
  ;;
make)
  mkdir -p "$OUTPUT"
  echo building "$ARCH"
  docker container run -it \
    --mount type=bind,source="$NODE_SOURCES",target=/node \
    --mount type=bind,source="$NODE_SOURCES"/out/"$ARCH"/,target=/node/out \
    --mount type=bind,source="$OUTPUT",target=/output \
    $IMAGE_NAME /env.sh make "$ARCH" /node /output
  ;;
*)
  echo "Unsupported command provided: $COMMAND"
  exit -1
  ;;
esac
