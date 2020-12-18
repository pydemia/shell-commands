#!/bin/bash

# string="Paris;France;Europe";
string="Paris; France; Europe";
# delimeter=";"

# readarray -td "" arr < <(awk '{ gsub(/'$delimeter' */,"\0"); print; }' <<<"${string}${delimeter} "); unset 'arr[-1]'; # declare -p arr;
# # readarray -td "" arr < <(awk 'BEGIN {d="$delimeter "} { gsub(d,"\0"); print; }' <<<"${string}${delimeter} "); unset 'arr[-1]'; # declare -p arr;
# declare -p arr;
# for i in "${arr[@]}"; do
#   echo $i
# done


split() {
  string=$1
  delimeter=$2
  
  readarray -td "" arr < <(awk '{ gsub(/'$delimeter' */,"\0"); print; }' <<<"${string}${delimeter} "); unset 'arr[-1]'; # declare -p arr;
  declare -p arr;
}

res=$(split "$string" ";")
echo $res
