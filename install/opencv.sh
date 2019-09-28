#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

OPENCV_VERSION=${OPENCV_VERSION:-4.1.0}

apt-get purge *libopencv* -y
apt update
apt install -y \
    build-essential \
    cmake \
    curl \
    git \
    libavcodec-dev \
    libavformat-dev \
    libdc1394-22-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer1.0-dev \
    libgtk2.0-dev \
    libjasper-dev \
    libjpeg-dev \
    libpng-dev \
    libswscale-dev \
    libtbb-dev \
    libtbb2 \
    libtiff-dev \
    libv4l-dev \
    pkg-config \
    python-dev \
    python-numpy \
    python3-dev \
    python3-numpy \
    qv4l2 \
    v4l-utils \
    v4l2ucp

mkdir -p /opt/opencv_build

curl -L https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip -o opencv-$OPENCV_VERSION.zip
curl -L https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip -o opencv_contrib-$OPENCV_VERSION.zip

unzip opencv-$OPENCV_VERSION.zip
unzip opencv_contrib-$OPENCV_VERSION.zip
cd opencv-$OPENCV_VERSION/

mkdir release
cd release/

cmake -D WITH_CUDA=ON \
      -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib-$OPENCV_VERSION/modules \
      -D WITH_GSTREAMER=ON \
      -D WITH_LIBV4L=ON \
      -D BUILD_opencv_python2=ON \
      -D BUILD_opencv_python3=ON \
      -D BUILD_TESTS=OFF \
      -D BUILD_PERF_TESTS=OFF \
      -D BUILD_EXAMPLES=OFF \
      -D CMAKE_BUILD_TYPE=RELEASE \
      -D CMAKE_INSTALL_PREFIX=/usr/local ..

make -j`nproc`
make install

apt install -y \
    python-opencv \
    python3-opencv

rm -rf /opt/opencv_build
