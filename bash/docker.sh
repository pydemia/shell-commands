#!/bin/bash

alias docker_rm_untagged='docker rmi $(docker images | grep "^<none>" | awk "{print $3}") && docker image prune -f'
alias docker_rm_after_build='docker images -f "dangling=true" -q'
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
