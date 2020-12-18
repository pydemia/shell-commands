#!/bin/bash

declare -a arr=("var1" "var2" "var3")
for i in "${arr[@]}"; do
    echo $i
done
