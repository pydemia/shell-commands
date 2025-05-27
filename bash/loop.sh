#!/bin/bash

declare -a arr=("var1" "var2" "var3")
for i in "${arr[@]}"; do
    echo $i
done



line='-----------------------------------------------------------------------------------------------'
images=($(cat images.txt | grep -v '^#' | grep -v '^$' | sort -u))
length=${#images[@]}
for i in ${!images[@]}; do
    image=${images[i]}
    if [[ $image != "." ]]; then
        printf "%s %s [%+2s/%+2s]\n" "$image" "${line:${#image}}" "$((i+1))" $length
        # printf "%-${linewidth}s |\n" "a = $a and b = $b"
    fi
done
