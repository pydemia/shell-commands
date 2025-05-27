#!/bin/bash

#alias docker_rm_untagged='docker rmi $(docker images | grep "^<none>" | awk "{print $3}") && docker image prune -f'
alias docker_rm_after_build='docker images -f "dangling=true" -q'
alias docker_rm_untagged='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_images='docker rmi $(docker images -a --filter=dangling=true -q)'
alias docker_clean_ps='docker rm $(docker ps --filter=status=exited --filter=status=created -q)'
alias docker_clean_build_cache='docker builder prune -a'
#alias docker_clean_system_all='docker system prune -a --volumes'

#docker images | awk '$1 { print $1":"$2 }'
alias docker_ls='docker images | awk '\''$1 { print $1":"$2 }'\'''

alias docker_sort_by_size='docker images | sort -k7 -h -r'

#docker images --filter=reference="*latest*" -q

function docker_filter() {
  docker images --format "{{.ID}}\t{{.Repository}}:{{.Tag}}" | grep 'docker-[(stg)|(dev)]' | awk '$1 { print $1 t$2 }'
  docker images --format "{{.ID}}\t{{.Repository}}:{{.Tag}}" | awk -v XX='docker-[(stg)|(dev)]' '$2 ~ XX { print $1 $2 }'
}

function docker_get_images() {
  # docker_get_images -n busybox -t latest -u
  local pattern tag uniqueid=false
  while [[ ${1} ]]; do
      case "${1}" in
          --name | -n)
              name=${2}
              shift
              ;;
          --tag | -t)
              tag=${2}
              shift
              ;;
          --unique | -u)
              uniqueid=true
              ;;
          *)
              echo "Unknown parameter: ${1}" >&2
              return 1
      esac
      shift

      # if ! shift; then
      #     echo 'Missing parameter argument.' >&2
      #     return 1
      # fi
  done
  if [ -z "${name}" ]; then
    if [ -z "${tag}" ]; then
      if [[ "${uniqueid}" == "true" ]]; then
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk '{ print $1 }' | sort -u
      else
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk '{ print $1"\t"$2":"$3 }'
      fi
    else
      if [[ "${uniqueid}" == "true" ]]; then
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk -v tag_pattern="$tag" '$3 ~ tag_pattern { print $1 }' | sort -u
      else
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk -v tag_pattern="$tag" '$3 ~ tag_pattern { print $1"\t"$2":"$3 }'
      fi
    fi
  else
    if [ -z "${tag}" ]; then
      if [[ "${uniqueid}" == "true" ]]; then
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk -v name_pattern="$name" '$2 ~ name_pattern { print $1 }' | sort -u
      else
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk -v name_pattern="$name" '$2 ~ name_pattern { print $1"\t"$2":"$3 }'
      fi
    else
      if [ "${uniqueid}" == "true" ]; then
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk -v name_pattern="$name" -v tag_pattern="$tag" '$2 ~ name_pattern && $3 ~ tag_pattern { print $1 }' | sort -u
      else
        docker images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}" | awk -v name_pattern="$name" -v tag_pattern="$tag" '$2 ~ name_pattern && $3 ~ tag_pattern { print $1"\t"$2":"$3 }'
      fi
    fi
  fi
}

function docker_check_image_exists() {
    local image="$1"
    local arch
    arch="$(docker image inspect --format '{{.Os}}/{{.Architecture}}') $image"
    
    # docker image inspect --format '{{.Os}}/{{.Architecture}}' busybox
}
# docker image inspect --format '{{.Os}}/{{.Architecture}}' busybox

function imagetag_to_filename() {
    local image="$1"
    # Replace '/' with '--' and ':' with '-'
    echo "$image" | sed -E 's|/|--|g; s|:|__|g'
}


function filename_to_imagetag() {
    local filename="$1"
    # Replace '--' with '/' and '__' with ':'
    echo "$filename" | sed -E 's|--|/|g; s|__|:|g'
}
