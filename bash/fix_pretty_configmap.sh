#!/bin/bash

# remove leading whitespaces
sed -i -E 's/([[:space:]]|\r)+$//g' profiles.yaml
