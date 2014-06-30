#!/bin/bash

# Author: Andrew Weiss | Microsoft

[[ $(docker ps -a | grep -c "[containername]") -eq 1 ]] && exit 0 || exit 1