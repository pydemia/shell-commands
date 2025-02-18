#!/bin/bash

find . -name "data[0-4]*" | xargs sed -n p > merged.txt

# cat $(find . -name "0*"); echo >> merged.txt

# $ find . -name "MPA0000*" | wc -m
#     1296

# $ find . -name "MPA0000[0-4]*" | wc -m
#     768

# $ find . -name "MPA0000[5-9]*" | wc -m
#     640

# $ find . -name "0*" | xargs cat | xargs echo -n >> merged.txt

# $ cat $(find . -name "0*"); echo >> merged.txt

# $ find . -name "0*" | xargs sed -n p > merged.txt
