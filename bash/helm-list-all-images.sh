#!/bin/bash

# See: https://artifacthub.io/packages/helm-plugin/helm-list-images/list-images

helm plugin install https://github.com/d2iq-labs/helm-list-images

helm list-images [RELEASE] [CHART] [flags]


helm template ./kserve-crd | grep 'image: ' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g'

rm -rf images.txt

for repo in $(find . -maxdepth 1 -type d); do
    if [[ $repo != "." ]]; then
        echo "# $repo" >> images.txt
        helm template $repo | grep 'image: ' | sed -E 's|^[ \t]*(image: )"?([^"]*)"?|\2|g' >> images.txt 2>&1
    fi
done
