FROM ubuntu:18.04
#FROM i386/ubuntu:18.04

ENV ANDROID_NDK_HOME /opt/android-ndk
ENV ANDROID_NDK_VERSION r20b


# Set China source mirror
RUN echo "deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic main restricted universe multiverse\n\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-updates main restricted universe multiverse\n\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-backports main restricted universe multiverse\n\
deb http://mirrors.tuna.tsinghua.edu.cn/ubuntu/ bionic-security main restricted universe multiverse" > /etc/apt/sources.list

# Install required tools
RUN apt-get update -qq \
  && apt-get clean \
  && apt-get install git wget unzip python g++ gcc make gcc-multilib g++-multilib zlib1g -y

# zlib1g:i386

# Download NDK
RUN mkdir /opt/android-ndk-tmp && \
    wget -P /opt/android-ndk-tmp https://dl.google.com/android/repository/android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip 
    
# Uncompress NDK
RUN cd /opt/android-ndk-tmp && \
    unzip -q android-ndk-${ANDROID_NDK_VERSION}-linux-x86_64.zip && \
    # Move to its final location
    mv ./android-ndk-${ANDROID_NDK_VERSION} ${ANDROID_NDK_HOME} && \
    # Remove temporary dir
    rm -rf /opt/android-ndk-tmp

ADD ./env.sh /env.sh
RUN mkdir -p /output

# Add NDK to PATH
ENV PATH ${PATH}:${ANDROID_NDK_HOME}