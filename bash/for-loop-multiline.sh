#!/bin/bash

FILENAME='test.txt'
while read line; do
  echo "$line"
done < $FILENAME
