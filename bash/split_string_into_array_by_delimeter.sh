#!/bin/bash

string="Paris,France,Europe"; string="Paris, France, Europe";
delimeter=","
readarray -td "" arr < <(awk '{ gsub(/, /,"\0"); print; }' <<<"${string}${delimeter} "); unset 'arr[-1]'; # declare -p arr;
for i in "${arr[@]}"; do
  echo $i
done
