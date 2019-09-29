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
    libatlas-base-dev \
    libboost-all-dev \
    libgoogle-glog-dev \
    libhdf5-dev \
    libopencv-dev \
    libprotobuf-dev \
    protobuf-compiler \
    python-dev \
    python3-dev

if [ ${ENABLE_GPU} = true ]
then
    apt install -y --no-install-recommends libcaffe-cuda-dev
else
    apt install -y --no-install-recommends libcaffe-cpu-dev
fi

cd /opt

curl -L https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-Linux-x86_64.tar.gz -o cmake-3.14.2-Linux-x86_64.tar.gz
tar xzf cmake-3.14.2-Linux-x86_64.tar.gz -C /opt
rm cmake-3.14.2-Linux-x86_64.tar.gz

export PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"
export PYTHONPATH=/usr/local/python:$PYTHONPATH

sed -i '/export PYTHONPATH=\/usr\/local\/python:$PYTHONPATH/d' /etc/bash.bashrc
echo 'export PYTHONPATH=/usr/local/python:$PYTHONPATH' >> /etc/bash.bashrc

if [[ -z "${BASH}" ]]
then
    sed -i '/export PATH="\/opt\/cmake-3.14.2-Linux-x86_64\/bin:${PATH}"/d' ~/.bashrc
    echo 'export PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"' >> ~/.bashrc

    sed -i '/export PYTHONPATH=\/usr\/local\/python:$PYTHONPATH/d' ~/.bashrc
    echo 'export PYTHONPATH=/usr/local/python:$PYTHONPATH' >> ~/.bashrc

    source ~/.bashrc
elif [[ -z "${ZSH_NAME}" ]]
then
    sed -i '/export PATH="\/opt\/cmake-3.14.2-Linux-x86_64\/bin:${PATH}"/d' ~/.zshrc
    echo 'export PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"' >> ~/.zshrc

    sed -i '/export PYTHONPATH=\/usr\/local\/python:$PYTHONPATH/d' ~/.zshrc
    echo 'export PYTHONPATH=/usr/local/python:$PYTHONPATH' >> ~/.zshrc

    source ~/.zshrc
else
    echo "Please set this environment variable 'PYTHONPATH=/usr/local/python:\$PYTHONPATH'"
fi

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
          -D CMAKE_BUILD_TYPE=RELEASE
else
    cmake -D BUILD_PYTHON=ON -D GPU_MODE=CPU_ONLY -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE .. || true
    sed -i "362i }" ../3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp
    sed -i "358i {" ../3rdparty/caffe/src/caffe/layers/mkldnn_inner_product_layer.cpp
    cmake -D BUILD_PYTHON=ON -D GPU_MODE=CPU_ONLY -D BUILD_EXAMPLES=OFF -D CMAKE_BUILD_TYPE=RELEASE ..
fi

make -j`nproc`
make install
