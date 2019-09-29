#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

ENABLE_GPU=${ENABLE_GPU:-false}
OPENPOSE_MODELS_PROVIDER=${OPENPOSE_MODELS_PROVIDER:-http://posefs1.perception.cs.cmu.edu/OpenPose/models/}

apt update
apt install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    wget \
    libprotobuf-dev \
    protobuf-compiler \
    libopencv-dev \
    libgoogle-glog-dev \
    libboost-all-dev \
    libhdf5-dev \
    libatlas-base-dev \
    python-dev \
    python3-dev

if [ ${ENABLE_GPU} = true ]
then
    apt install -y --no-install-recommends libcaffe-cuda-dev
else
    apt install -y --no-install-recommends libcaffe-cpu-dev
fi



cd /opt

wget https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-Linux-x86_64.tar.gz
tar xzf cmake-3.14.2-Linux-x86_64.tar.gz -C /opt
rm cmake-3.14.2-Linux-x86_64.tar.gz

export PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"

git clone --depth=1 https://github.com/CMU-Perceptual-Computing-Lab/openpose.git
cd openpose
git submodule update --init --recursive
cd models
sed -i "s,http://posefs1.perception.cs.cmu.edu/OpenPose/models/,$OPENPOSE_MODELS_PROVIDER,g" getModels.sh
./getModels.sh
cd ..
mkdir release

cd /opt/openpose/release

if [ ${ENABLE_GPU} = true ]
then
    cmake -D USE_OPENCV=ON \
          -D USE_NCCL=ON \
          -D BUILD_PYTHON=ON .. \
          -D BUILD_EXAMPLES=OFF \
          -D BUILD_TESTS=OFF \
          -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_BUILD_SHARED_LIBS=1
else
    cmake -D BUILD_PYTHON=ON -D GPU_MODE=CPU_ONLY -D BUILD_EXAMPLES=OFF -D BUILD_TESTS=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_BUILD_SHARED_LIBS=1 .. || true
    sed -i "362i }" ../3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp
    sed -i "358i {" ../3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp
    cmake -D BUILD_PYTHON=ON -D GPU_MODE=CPU_ONLY -D BUILD_EXAMPLES=OFF -D BUILD_TESTS=OFF -D CMAKE_BUILD_TYPE=RELEASE -D CMAKE_BUILD_SHARED_LIBS=1 ..
fi

make -j`nproc`
make install

rm -rf /opt/openpose
