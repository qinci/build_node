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
ANDROID_SDK_VERSION=23
WORKER_COUNT=8
NODE_SOURCES=`dirname  $PWD`/node

#case $ARCH in
#arm)
#  IMAGE_NAME=ndk20b_i386
#  DOCKFILE=Dockerfile_i386
#  ;;
#*)
#  IMAGE_NAME=ndk20b
#  DOCKFILE=Dockerfile
#  ;;
#esac

mkdir -p "$NODE_SOURCES"/output
mkdir -p "$NODE_SOURCES"/out/"$ARCH"/

case $COMMAND in
configure)
  docker -D build -t "$IMAGE_NAME" ./

  docker container run -it \
    --mount type=bind,source="$NODE_SOURCES",target=/node \
    --mount type=bind,source="$NODE_SOURCES"/out/"$ARCH"/,target=/node/out \
    $IMAGE_NAME /env.sh configure "$ARCH" "$ANDROID_SDK_VERSION" "$WORKER_COUNT"
  ;;
make)
  mkdir -p "$OUTPUT"
  echo building "$ARCH"
  docker container run -it \
    --mount type=bind,source="$NODE_SOURCES",target=/node \
    --mount type=bind,source="$NODE_SOURCES"/out/"$ARCH"/,target=/node/out \
    --mount type=bind,source="$OUTPUT",target=/output \
    $IMAGE_NAME /env.sh make "$ARCH" "$ANDROID_SDK_VERSION" "$WORKER_COUNT"
  ;;
*)
  echo "Unsupported command provided: $COMMAND"
  exit -1
  ;;
esac
