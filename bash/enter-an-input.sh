#!/bin/bash

var_nm="predefined"
read -p "Enter variable name [$var_nm]: " input_nm

echo "${input_nm} / ${var_nm}"

var_nm=${input_nm:-$var_nm}

echo "${input_nm} / ${var_nm}"
