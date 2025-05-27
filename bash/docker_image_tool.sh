#!/bin/bash

handle_interrupt() {
    echo "Interrupt received. Cleaning up..."
    # Add cleanup actions here, e.g., deleting temp files, closing connections
    exit 1 # Exit with an error code to indicate interruption
}
# Set the trap for SIGINT (Ctrl+C)
trap handle_interrupt SIGINT

function grep_images() {
    
    echo 'Get a list of all images in helm [images.txt]...'
    rm -rf images.txt

    local REPO_NAME="aiplatform"
    local VALUES_FILE="./values.yaml"
    if [ -f "$VALUES_FILE" ]; then
        echo "Using values file: $VALUES_FILE"
        helm template --include-crds $REPO_NAME -f "./values.yaml" | grep 'image: ' | sed -E 's|[[:space:]]*[^[:space:]]*(-[[:space:]]*)*(image: )"?([^"]*)"?|\3|g' | sort -u >> images.txt
    else
        echo "Values file not found: $VALUES_FILE. using default values.yaml"
        helm template --include-crds $REPO_NAME | grep 'image: ' | sed -E 's|[[:space:]]*[^[:space:]]*(-[[:space:]]*)*(image: )"?([^"]*)"?|\3|g' | sort -u  >> images.txt
    fi

    echo 'Processing images list [images_unique.txt]...'
    sed -r \
        -e 's|^([^# ][^:]*):(.*)|\1:\2|' \
        images.txt \
    | sort -u | sort -h > images_unique.txt


    sed -r \
        -e 's|^([^# ][^:]*):(.*)|\1:\2|' \
        -e 's|^([^# ][^:]*)$|\1:latest|' \
        -e 's|(^#.*)||g' \
        -e 's|[[:space:]]*$||' \
        -e 's|^[[:space:]]+(#.*)||g' \
        -e 's|(^#.*)||g' \
        -e 's|(-[[:space:]]+)(.*)|\2|g' \
        -e '/^$/d' \
        images.txt \
    | sort -u | sort -h > images_unique.txt
    # -e 's|^\{(.*)||g' \
    # -e 's|^\{<(.*)||g' \

    # cat -n images.txt | sort --key=2.1 -b -u | sort -n | cut -c8- 
    mv images_unique.txt images.txt
    echo 'all done! '

}


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


# echo '1. Save images...'
# line='-----------------------------------------------------------------------------------------------'
# images=($(cat images.txt | grep -v '^#' | grep -v '^$' | sort -u))
# length=${#images[@]}
# for i in ${!images[@]}; do
#     image=${images[i]}
#     if [[ $image != "." ]]; then
#         echo "$(echo $image | sed -E 's|/|--|g')"
#         echo "Pulling image: $image"
#         # printf "%s %s [%+2s/%+2s]\n" "$image" "${line:${#image}}" "$((i+1))" $length
#         # printf "%-${linewidth}s |\n" "a = $a and b = $b"
#     fi
# done

# # with docker
# docker images --format '{{.ID}} {{.Repository}} {{.Tag}}'| while read id repo tag; do echo $id $repo:$tag `docker image inspect $id --format {{.Os}}'/'{{.Architecture}}`; done

# image_arch="linux/amd64"

# ✅⚠️❗❌💡❌❔⌛

function docker_check_image_exists() {
    local image="$1"
    local target_arch="${2:-linux/amd64}"
    local arch
    arch="$(docker image inspect $image --format '{{.Os}}/{{.Architecture}}' || '')"
    if [[ $arch == *"$target_arch"* ]]; then
        echo "✅ Image $image exists for architecture [$target_arch]"
        return 0
    else
        echo "⚠️ Image Not Found: Image $image does not exist for architecture [$target_arch]"
        return 1
    fi
}

# docker_check_image_exists busybox:latest linux/amd64


function pull_with_docker() {
    local image="$1"
    local docker_platform_opt="${2:---platform=linux/amd64}"
    echo "⌛ Pulling image: $image"
    docker pull $docker_platform_opt "$image"
}

function save_with_docker() {
    local image="$1"
    local docker_platform_opt="${2:---platform=linux/amd64}"
    if [[ -z "$image" ]]; then
        echo "❗ No image specified to save."
        exit 1
    fi
    local filename=$(imagetag_to_filename "$image").tar.gz
    echo "⌛ Saving image: $image -> $filename"
    docker save "$image" | gzip > "$filename"
    filesize="$(ls -lh aip-harbor.sktai.io--sktai--agent--agents_backend__v1.0.0.tar.gz | awk '{print $5}')"
    echo "✅ Image saved to $filename (size: $filesize)"
}

function save_image() {
    local image="$1"
    if docker_check_image_exists "$image"; then
        save_with_docker "$image"
    else
        echo "❗ Image $image does not exist, pulling it first."
        pull_with_docker "$image"
        save_with_docker "$image"
    fi
}

function save_images() {
    local images_file="${1:-images.txt}"
    local target_dir="${2:-./images}"
    mkdir -p "$target_dir"
    echo "⌛ Saving images to directory: $target_dir"
    line='---------------------------------------------------------------------------------------------------------------------------------------------'
    images=($(cat images.txt | grep -v '^#' | grep -v '^$' | sort -u))
    length=${#images[@]}
    for i in ${!images[@]}; do
        image=${images[i]}
        printf "🐳 %s %s [%+2s/%+2s]\n" "$image" "${line:${#image}}" "$((i+1))" $length
        save_image "$image"
    echo "✅ All images saved to $target_dir"
    done
}

function load_with_docker() {
    local image="$1"
    local docker_platform_opt="${2:---platform=linux/amd64}"
    if [[ -z "$image" ]]; then
        echo "❗ No image specified to load."
        exit 1
    fi
    local filename="$(imagetag_to_filename "$image").tar.gz"
    if [[ -f "$filename" ]]; then
        echo "⌛ Loading image: $image from $filename"
        docker load < "$filename"
    else
        echo "❗ File not found: $filename"
        exit 1
    fi
}

function push_with_docker() {
    local image="$1"
    local docker_platform_opt="${2:---platform=linux/amd64}"
    if [[ -z "$image" ]]; then
        echo "❗ No image specified to push."
        exit 1
    fi
    echo "⌛ Pushing image: $image"
    docker push $docker_platform_opt "$image"
}

function load_image() {
    local image="$1"
    load_with_docker "$image"
    push_with_docker "$image"
}

function load_images() {
    local images_file="${1:-images.txt}"
    local target_dir="${2:-./images}"
    if [[ ! -d "$target_dir" ]]; then
        echo "❗ Target directory does not exist: $target_dir"
        exit 1
    fi
    echo "⌛ Loading images from directory: $target_dir"
    line='---------------------------------------------------------------------------------------------------------------------------------------------'
    images=($(cat images.txt | grep -v '^#' | grep -v '^$' | sort -u))
    length=${#images[@]}
    for i in ${!images[@]}; do
        image=${images[i]}
        printf "🐳 %s %s [%+2s/%+2s]\n" "$image" "${line:${#image}}" "$((i+1))" $length
        if [[ $image != "." ]]; then
            load_image "$image"
        fi
    done
    echo "✅ All images loaded from $target_dir"
}

# for image in "${images[@]}"; do
#     if [[ $image != "." ]]; then
#         save_with_docker "$image" ||
#         pull_with_docker "$image"
#     fi
# done

# # with containerd
# for image in "${images[@]}"; do
#     if [[ $image != "." ]]; then
#         echo "Pulling image: $image"
#         ctr -n k8s.io images pull "$image"
#     fi
# done

# # with podman
# for image in "${images[@]}"; do
#     if [[ $image != "." ]]; then
#         echo "Pulling image: $image"
#         podman pull "$image"
#     fi
# done

"$@"
