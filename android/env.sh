#!/bin/bash

# In order to cross-compile node for Android using NDK, run:
#   source android-configure <path_to_ndk> [arch]
#
# By running android-configure with source, will allow environment variables to
# be persistent in current session. This is useful for installing native node
# modules with npm. Also, don't forget to set the arch in npm config using
# 'npm config set arch=<arch>'

if [ $# -lt 4 ]; then
  echo "$0 should have at least 4 parameters: target_arch, sdk_version, worker_count, command"
  exit 1
fi
set -e

COMMAND=$1
ARCH=$2
ANDROID_SDK_VERSION=$3
WORKER_COUNT=$4
WORKDIR=/node

cd $WORKDIR

if [ $ANDROID_SDK_VERSION -lt 23 ]; then
  echo "$ANDROID_SDK_VERSION should equal or later than 23(Android 6.0)"
fi

CC_VER="4.9"

case $ARCH in
arm)
  DEST_CPU="arm"
  TOOLCHAIN_NAME="armv7a-linux-androideabi"
  ABI="armeabi-v7a"
  ;;
arm64 | aarch64)
  DEST_CPU="arm64"
  TOOLCHAIN_NAME="aarch64-linux-android"
  ARCH="arm64"
  ABI="arm64-v8a"
  ;;
x86)
  DEST_CPU="ia32"
  TOOLCHAIN_NAME="i686-linux-android"
  ABI="x86"
  ;;
x86_64)
  DEST_CPU="x64"
  TOOLCHAIN_NAME="x86_64-linux-android"
  ARCH="x64"
  ABI="x86_64"
  ;;
*)
  echo "Unsupported architecture provided: $ARCH"
  exit 1
  ;;
esac

PREFIX="${WORKDIR}/out/prefix"

echo ARCH=${ARCH}
echo ANDROID_SDK_VERSION=${ANDROID_SDK_VERSION}
echo WORKER_COUNT=${WORKER_COUNT}
echo PREFIX=${PREFIX}
echo 'ls -la /output '
ls -la /output

HOST_OS="linux"
HOST_ARCH="x86_64"
export CC_host=$(which gcc)
export CXX_host=$(which g++)

host_gcc_version=$($CC_host --version | grep gcc | awk '{print $NF}')
major=$(echo $host_gcc_version | awk -F . '{print $1}')
minor=$(echo $host_gcc_version | awk -F . '{print $2}')
if [ -z $major ] || [ -z $minor ] || [ $major -lt 6 ] || [ $major -eq 6 -a $minor -lt 3 ]; then
  echo "host gcc $host_gcc_version is too old, need gcc 6.3.0"
  exit 1
fi

SUFFIX="$TOOLCHAIN_NAME$ANDROID_SDK_VERSION"
TOOLCHAIN=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_OS-$HOST_ARCH

export PATH=$TOOLCHAIN/bin:$PATH
export CC=$TOOLCHAIN/bin/$SUFFIX-clang
export CXX=$TOOLCHAIN/bin/$SUFFIX-clang++

GYP_DEFINES="target_arch=$ARCH"
GYP_DEFINES+=" v8_target_arch=$ARCH"
GYP_DEFINES+=" android_target_arch=$ARCH"
GYP_DEFINES+=" host_os=$HOST_OS OS=android"
export GYP_DEFINES
# rm -rf ${WORKDIR}/out
case $COMMAND in
configure)
  make clean
  ./configure \
    --dest-cpu=$DEST_CPU \
    --dest-os=android \
    --openssl-no-asm \
    --cross-compiling \
    --prefix=$PREFIX \
    --debug-lib \
    --without-node-snapshot \
    --without-node-code-cache \
    --without-npm \
    --without-report \
    --without-etw \
    --without-dtrace \
    --with-intl=full-icu \
    --shared \
    --release-urlbase=https://github.com/dorajs/build_node
  # --without-intl \
  # --verbose \
  # --build-v8-with-gn \
  # --without-inspector \
  ;;
make)
  OUTPUT="/output/${ABI}"
  mkdir -p $OUTPUT
  echo OUTPUT=${OUTPUT}

  make -j${WORKER_COUNT}
  make install

  cp -r "$PREFIX/lib/libnode.so" "$OUTPUT"
  cp -r "$PREFIX/include" "$OUTPUT"
  ;;
*)
  echo "Unsupported command provided: $COMMAND"
  exit 1
  ;;
esac