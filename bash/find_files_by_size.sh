#!/bin/bash

# example: size more than 100MB

target_size="+100M"

find ./ -type f -size "${target_size}" -exec ls -lh {} \;
