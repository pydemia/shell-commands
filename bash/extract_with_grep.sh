#!/bin/bash

# See merge request aaa/bbb!1234 -> 1234

echo $ENVVAR | grep -Eo 'See merge request .*!\d+' | grep -Eo '!\d+' | grep -Eo '\d+'
