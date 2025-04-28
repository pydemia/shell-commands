#!/bin/bash


command_list='kubectl yq'
for cmd in ${command_list}; do
    if ! command -v $cmd 2>&1 > /dev/null; then
        echo "${cmd} not found";
        exit 1;
    fi
done


function rename_kubeconfig() {
    local FILEPATH FILENAME_NO_EXT CLUSTER_NAME CLUSTER_USER CONTEXT_NAME
    FILEPATH=${1}
    if [ ! -f $FILEPATH ]; then
        printf "\nKubeconfig file '%s' does not exist!" $FILEPATH;
        exit 1;
    fi
    FILENAME=$(basename "${FILEPATH}")
    FILENAME_NO_EXT=$(basename "${FILENAME%.*}")
    
    TEMP_YAML=new_kubeconfig.yaml
    rm -rf $TEMP_YAML
    cp $FILEPATH $TEMP_YAML
    DEFAULT_CLUSTER_NAME="$(yq -r ".clusters[0].name" $TEMP_YAML)"
    KUBE_SERVER_URL="$(yq -r ".clusters[0].cluster.server" $TEMP_YAML)"
    CLUSTER_NAME="${FILENAME_NO_EXT:-$(DEFAULT_CLUSTER_NAME)}"
    CLUSTER_USER="${CLUSTER_NAME}-$(yq ".users[0].name" $TEMP_YAML)"

    yq -i ".clusters[0].name=\"${CLUSTER_NAME}\"" $TEMP_YAML
    yq -i ".users[0].name=\"${CLUSTER_USER}\"" $TEMP_YAML
    yq -i ".contexts[0].name=\"${CLUSTER_NAME}\"" $TEMP_YAML
    yq -i ".contexts[0].context.user=\"${CLUSTER_USER}\"" $TEMP_YAML
    yq -i ".contexts[0].context.cluster=\"${CLUSTER_NAME}\"" $TEMP_YAML
    # printf "\rKubeconfig file '%s' is done!" $FILEPATH
    echo "$TEMP_YAML"
}

function merge_kubeconfig() {
    KUBECONFIG="${KUBECONFIG:-${HOME}/.kube/config}"
    # local KUBECONFIG MERGED_FILEPATH
    KUBECONFIG="${KUBECONFIG}"

    MERGED_FILEPATH="merged_kubeconfig"
    rm -rf $MERGED_FILEPATH

    for config_file in "$@"; do
        if [ ! -f $config_file ]; then
            printf "\nKubeconfig file '%s' does not exist!" "$config_file";
            exit 1;
        else
            # printf "\nKubeconfig file '%s' is processing..." "$config_file";
            line='---------------------------------------------------------------------------------------------'
            printf "\n%s %s\n" "$config_file" "${line:${#config_file}}"
        fi

        KUBE_SERVER_URL="$(yq -r ".clusters[0].cluster.server" $config_file)"
        FILEPATH=$(rename_kubeconfig $config_file)
        printf ">>> '%s'\n" "$FILEPATH";
        if [[ "$KUBE_SERVER_URL" =~ "localhost" ]]; then
            printf "!!! [WARN] '%s' contains 'localhost' !!!\n  server: %s\n" "$config_file" "$KUBE_SERVER_URL" 
        fi

        KUBECONFIG="${KUBECONFIG}:${FILEPATH}"

        # printf "\nKubeconfig file '%s' is merging..." "$FILEPATH"
        KUBECONFIG=$KUBECONFIG kubectl config view --flatten > $MERGED_FILEPATH
        printf "\nKubeconfig file '%s' has been merged to '%s'\n" "$config_file" "$MERGED_FILEPATH"
        printf "%s\n" "-${line}"
        rm -rf $FILEPATH
    done
    printf "\nAll Kubeconfig has been merged: '%s'\n" "$(find . -type f -name $MERGED_FILEPATH)";
}


while [[ ${1} ]]; do
    case "${1}" in
        --help | -h)
            printf "[Usage]\n"
            printf "./concat_kubeconfig.sh merge_kubeconfig <kubeconfig1> <kubeconfig2>\n\n"
            printf "The name of new cluster will be replace with filename, ignoring ext if exists."
            printf "[Example]\n"
            printf "$ ./concat_kubeconfig.sh merge_kubeconfig ~/.kube/config_new\n"
            printf "...\n"
            printf "  cluster: config_new\n"
            printf "  user: config_new-user\n"
            printf "  context: config_new\n"
            printf "...\n"
            shift
            ;;
        merge_kubeconfig)
            merge_kubeconfig "${@:2}"
            shift
            ;;
        *)
            shift
    esac
    shift

    # if ! shift; then
    #     echo 'Missing parameter argument.' >&2
    #     return 1
    # fi
done


"$@"


