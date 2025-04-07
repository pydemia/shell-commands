#!/bin/bash

alias docker_rm_untagged='docker rmi $(docker images | grep "^<none>" | awk "{print $3}") && docker image prune -f'
alias docker_rm_after_build='docker images -f "dangling=true" -q'
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'

#docker images | awk '$1 { print $1":"$2 }'
alias docker_ls='docker images | awk '\''$1 { print $1":"$2 }'\'''

alias docker_sort_by_size='docker images | sort -k7 -h -r'

#docker images --filter=reference="*latest*" -q

function docker_filter() {
  docker images --format "{{.ID}}\t{{.Repository}}:{{.Tag}}" | grep 'docker-[(stg)|(dev)]' | awk '$1 { print $1 t$2 }'
  docker images --format "{{.ID}}\t{{.Repository}}:{{.Tag}}" | awk -v XX='docker-[(stg)|(dev)]' '$2 ~ XX { print $1 $2 }'
}

function docker_get_images() {
  if [ -z "${1}" ]; then
    docker images | awk '$1 { print $1":"$2 }'
  else
    PATTERN="${1}"
    docker images | awk -v pattern="$PATTERN" '$1 ~ pattern { print $1":"$2 }'
  fi
}
