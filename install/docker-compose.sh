#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

if [[ -z `which curl` ]]
then
    apt update
    apt install -y --no-install-recommends curl
fi

if [[ -z `which docker` ]]
then
    curl -L https://kui.im/install-docker -o install-docker
    chmod +x install-docker
    ./install-docker
    rm install-docker
fi

SYSTEM_ARCH=`uname -m`
if [ $SYSTEM_ARCH == "aarch64" ]
then
    if [[ -z `which pip3` ]]
    then
        curl -L https://kui.im/install-python-pip -o install-python-pip
        chmod +x install-python-pip
        ./install-python-pip
        rm install-python-pip
    fi

    apt install -y --no-install-recommends \
        build-essential \
        libssl-dev \
        libffi-dev \
        python-dev \
        python3-dev

    pip3 install docker-compose
else
    curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
fi
