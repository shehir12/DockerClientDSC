#!/bin/bash

# Author: Andrew Weiss | Microsoft

if [[ $(docker images | grep -c "[image]") -eq 3 ]]
then
    exit 0
else
    docker pull [image]
    exit 0
fi