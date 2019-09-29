#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

cd /tmp

if [[ -z `which wget` ]]
then
    apt update
    apt install -y --no-install-recommends wget
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

wget https://bootstrap.pypa.io/get-pip.py

python2 get-pip.py || true
python3 get-pip.py || true

rm get-pip.py
