#!/bin/bash

var_nm1="predefined1"
var_nm2="predefined2"
var_nm3=""

for i in "$@"; do
  case $i in
    -v=*|--pyversion=*)
    PY_VER="${i#*=}"
    shift # past argument=value
    ;;
    -n=*|--env_name=*)
    CONDA_ENV_NM="${i#*=}"
    shift # past argument=value
    ;;
    -d=*|--display_name=*)
    CONDA_DISP_NM="${i#*=}"
    shift # past argument=value
    ;;
    -e=*|--conda_yaml=*)
    BASE_ENVFILE="${i#*=}"
    shift # past argument=value
    ;;
    -r=*|--pip_req=*)
    PIP_PKG_REQ="${i#*=}"
    shift # past argument=value
    ;;
  esac
done
