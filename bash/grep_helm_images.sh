#!/bin/bash

# find -type f -exec sed -i -e 's|\n\w+image:||g' {} +

# helm template . \
#     | yq '..|.image? | select(.)' \
#     | sort -u

# helm template istio-base | grep 'image:'

# helm list-images ./istio-base -f ./values_istio-base.yaml
# helm list-images ./istio-cni -f ./values_istio-cni.yaml
# helm list-images ./istio-istiod -f ./values_istio-istiod.yaml
# helm list-images ./istio-gateway -f ./values_istio-gateway.yaml
# helm list-images ./fluent-bit -f ./values_fluent-bit.yaml
# helm list-images ./argo-cd -f ./values_argo-cd.yaml


# helm template .

# helm list-images ./fluent-bit --yaml
# helm template ./fluent-bit | grep 'image:'
# helm template ./fluent-bit | grep 'image:' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g'
# helm template ./kserve-crd | grep 'image: ' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g'


#!/bin/bash

# 1. Get a list of all images in helm
echo '1. Get a list of all images in helm [images.txt]...'
rm -rf images.txt
# for repo in $(find . -maxdepth 1 -type d); do
#     if [[ $repo != "." ]]; then
#         repo_name="$(echo $repo | sed -E 's|\.\/||g')"
#         echo "# $repo" >> images.txt
#         helm template $repo -f "./values_$repo_name.yaml" | grep 'image: ' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g' >> images.txt
#     fi
# done

line='----------------------------------------'
repos=($(find . -maxdepth 1 -type d | sort -h))
length=${#repos[@]}
for i in ${!repos[@]}; do
    repo=${repos[i]}
    if [[ $repo != "." ]]; then
        repo_name="$(echo $repo | sed -E 's|\.\/||g')"
        printf "%s %s [%+2s/%+2s]\n" "$repo" "${line:${#repo}}" $i $length
        # printf "%-${linewidth}s |\n" "a = $a and b = $b"
        printf "%s %s [%+2s/%+2s]\n" "# $repo" "${line:${#repo}}" $i $length >> images.txt
        helm template --include-crds $repo -f "./values_$repo_name.yaml" | grep 'image: ' | sed -E 's|[[:space:]]*[^[:space:]]*(image: )"?([^"]*)"?|\2|g' | sort -u >> images.txt
        printf "# %s\n\n" $line >> images.txt
    fi
done

# 2. Add an image manually: istio proxy
echo '2. Add an image manually: istio proxy...'
echo "istio/$(yq -r '.defaults.global.proxy.image' ./values_istio-istiod.yaml)" >> images.txt
echo "istio/$(yq -r '.defaults.global.proxy_init.image' ./values_istio-istiod.yaml)" >> images.txt

# 3. Add a "latest" tag to untagged image
# & Get unique images list
# & Remove comments
# & Remove invalid lines
# & Remove trailing whitespaces
#Remove invalid lines
# ex.)
# {{ .ProxyImage }}:latest
# {{ annotation .ObjectMeta `sidecar.istio.io/proxyImage` .Values.global.proxy.image }}:latest
# {{ annotation .ObjectMeta `sidecar.istio.io/proxyImage` .Values.global.proxy_init.image }}:latest
echo '3. Processing images list [images_unique.txt]...'
sed -r \
    -e 's|^([^# ][^:]*):(.*)|\1:\2|' \
    -e 's|^([^# ][^:]*)$|\1:latest|' \
    -e 's|(^#.*)||g' \
    -e 's|[[:space:]]*$||' \
    -e 's|^\{(.*)||g' \
    -e '/^$/d' \
    images.txt \
| sort -u > images_unique.txt

echo 'all done! '
