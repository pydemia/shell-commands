#!/bin/bash

line='----------------------------------------'
PROC_NAME='abc'
printf "%s %s [UP]\n" $PROC_NAME "${line:${#PROC_NAME}}"
PROC_NAME='abcdef'
printf "%s %s [UP]\n" $PROC_NAME "${line:${#PROC_NAME}}"
