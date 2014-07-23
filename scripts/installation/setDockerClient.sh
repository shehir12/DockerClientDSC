#!/bin/bash

# Author: Andrew Weiss | Microsoft

if [[ $(dpkg-query -W -f='${Status}' lxc-docker 2>/dev/null | grep -c "ok installed") -eq 0 ]]
then
		[ -e /usr/lib/apt/methods/https ] || {
        apt-get update
        apt-get install apt-transport-https
		}

		apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
    sh -c "echo deb https://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
    apt-get update
    apt-get install -y lxc-docker
    exit 0
fi
