#!/bin/bash

# Author: Andrew Weiss | Microsoft

[[ $(docker run -d --name="[containername]" [image] '[command]') ]] && exit 0 || exit 1