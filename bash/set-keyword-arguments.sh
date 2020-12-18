#!/bin/bash

var_nm1="predefined1"
var_nm2="predefined2"
var_nm3=""

echo "${var_nm1} / ${var_nm2} / ${var_nm3}"

# "v,var_nm1" "a,var_nm2", "r,var_nm3"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -v|--var_nm1)
    var_nm1="$2"
    shift 2 # past argument value
    ;;
    -v*|-v=*|--var_nm1=*)
    var_nm1="${1#*=}"
    shift 1 # past argument=value
    ;;

    -a|--var_nm2)
    var_nm2="$2"
    shift 2 # past argument value
    ;;
    -a*|-a=*|--var_nm2=*)
    var_nm2="${1#*=}"
    shift 1 # past argument=value
    ;;

    -r|--var_nm3)
    var_nm3="$2"
    shift 2 # past argument value
    ;;
    -r*|-r=*|--var_nm3=*)
    var_nm3="${1#*=}"
    shift 1 # past argument=value
    ;;

    -h|--help)
    echo "Description: "
    echo "Usage:"
    echo "  -v|--var_nm1"
    echo "                : var_nm1 description"
    echo ""
    echo "  -a|--var_nm2"
    echo "                : var_nm2 description"
    echo ""
    echo "  -r|--var_nm3"
    echo "                : var_nm3 description"
    echo ""
    exit 0;;

    -*) echo "unknown option: $1" >&2; exit 1;;
    *) echo "Error: missing argument(s)"; break;;

  esac
done

echo "${var_nm1} / ${var_nm2} / ${var_nm3}"
