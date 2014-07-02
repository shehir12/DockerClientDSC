#!/bin/bash

# Author: Andrew Weiss | Microsoft

if [[ $(sudo dpkg-query -W -f='${Status}' lxc-docker 2>/dev/null | grep -c "ok installed") -eq 0 || $(sudo dpkg-query -W -f='${Status}' apt-transport-https 2>/dev/null | grep -c "ok installed") -eq 0 ]]
then
    exit 1
fi