#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

export DEBIAN_FRONTEND="noninteractive"

cd /tmp

if [[ -z `which curl` ]]
then
    apt update
    apt install -y --no-install-recommends curl
fi

if [[ -z `which python2` ]]
then
    apt update
    apt install -y --no-install-recommends python
fi

if [[ -z `which python3` ]]
then
    apt update
    apt install -y --no-install-recommends python3
fi

curl -L https://bootstrap.pypa.io/get-pip.py -o get-pip.py

python2 get-pip.py || true
python3 get-pip.py || true

rm get-pip.py
