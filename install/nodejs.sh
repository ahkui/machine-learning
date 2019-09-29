#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

export DEBIAN_FRONTEND="noninteractive"

NODEJS_VERSION=${NODEJS_VERSION:-10}

cd /tmp

if [[ -z `which curl` ]]
then
    apt update
    apt install -y --no-install-recommends curl
fi

curl -sL https://deb.nodesource.com/setup_$NODEJS_VERSION.x | bash -

apt-get update
apt-get install -y --no-install-recommends \
    nodejs
