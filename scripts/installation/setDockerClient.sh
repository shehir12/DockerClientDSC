#!/bin/bash

# Author: Andrew Weiss | Microsoft

if [[ $(dpkg-query -W -f='${Status}' docker.io 2>/dev/null | grep -c "ok installed") -eq 0 ]]
then
    apt-get install -y docker.io
    ln -sf /usr/bin/docker.io /usr/local/bin/docker
    sed -i '$acomplete -F _docker docker' /etc/bash_completion.d/docker.io
    exit 0
fi

if [[ ! -L /usr/local/bin/docker ]]
then
    ln -sf /usr/bin/docker.io /usr/local/bin/docker
    exit 0
fi