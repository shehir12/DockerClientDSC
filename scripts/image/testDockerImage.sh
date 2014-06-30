#!/bin/bash

# Author: Andrew Weiss | Microsoft

[[ $(docker images | grep -c "[image]") -eq 3 ]] && exit 0 || exit 1