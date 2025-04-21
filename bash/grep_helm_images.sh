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

rm -rf images.txt

for repo in $(find . -maxdepth 1 -type d); do
    if [[ $repo != "." ]]; then
        repo_name="$(echo $repo | sed -E 's|\.\/||g')"
        echo "# $repo" >> images.txt
        # helm template $repo -f "./values_$repo_name.yaml"  2>> images.txt | grep 'image: ' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g' >> images.txt
        helm template $repo -f "./values_$repo_name.yaml" | grep 'image: ' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g' >> images.txt
    fi
done

yq -r '.defaults.global.proxy.image' ./values_istio-istiod.yaml >> images.txt

sed -r -e 's|^([^# ][^:]*):(.*)|\1:\2|' -e 's|^([^# ][^:]*)$|\1:latest|' -e 's|(^#.*)||g' images.txt | sort -u - > images_unique.txt

