#!/bin/bash

# delete all jobs
kubectl -n default delete jobs `kubectl -n default get jobs -o custom-columns=:.metadata.name`

# delete failed or long-running jobs
kubectl delete jobs --field-selector status.successful=0

