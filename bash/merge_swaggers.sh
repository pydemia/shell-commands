#!/usr/bin/env bash

set -e
set -x

# >>> npx openapi-merge-cli

# # `auth` not included.
# APP_URL__ARRAY=("agent" "data" "model" "serving" "model_gateway" "agent_gateway" "management/resource" "management/safety_filter" "management/history" "model-benchmark" "finetuning" )


# PATH_PREFIX="/api/v1/"

# for APP_URL in ${APP_URL__ARRAY[@]}; do
#   SEP="--"
#   FILENAME="${APP_URL/\//$SEP}.swagger.json"
#   PATH="${PATH_PREFIX}${APP_URL}"

#   echo $APP_URL
#   echo $FILENAME
#   echo $PATH
# done

cat << EOF > ./openapi-merge.json
{
  "inputs": [
    {
      "inputFile": "./agent.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/agent",
        "prepend": "/api/v1/agent"
      }
    },
    {
      "inputFile": "./data.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/data",
        "prepend": "/api/v1/data"
      }
    },
    {
      "inputFile": "./knowledge.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/knowledge",
        "prepend": "/api/v1/knowledge"
      }
    },
    {
      "inputFile": "./model.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/model",
        "prepend": "/api/v1/model"
      }
    },
    {
      "inputFile": "./serving.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/serving",
        "prepend": "/api/v1/serving"
      }
    },
    {
      "inputFile": "./model_gateway.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/model_gateway",
        "prepend": "/api/v1/model_gateway"
      }
    },
    {
      "inputFile": "./agent_gateway.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/agent_gateway",
        "prepend": "/api/v1/agent_gateway"
      }
    },
    {
      "inputFile": "./management--resource.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/management/resource",
        "prepend": "/api/v1/management/resource"
      }
    },
    {
      "inputFile": "./management--safety_filter.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/management/safety_filter",
        "prepend": "/api/v1/management/safety_filter"
      }
    },
    {
      "inputFile": "./management--history.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/management/history",
        "prepend": "/api/v1/management/history"
      }
    },
    {
      "inputFile": "./model-benchmark.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/model-benchmark",
        "prepend": "/api/v1/model-benchmark"
      }
    },
    {
      "inputFile": "./finetuning.swagger.json",
      "pathModification": {
        "stripStart": "/api/v1/finetuning",
        "prepend": "/api/v1/finetuning"
      }
    }
  ],
  "output": "./merged.swagger.json"
}
EOF


function merge_swaggers() {
  DOMAIN="${1:-https://aip.sktai.io}"
  PATH_PREFIX="/api/v1/"

  # `auth` not included.
  APP_URL__ARRAY=("agent" "data" "knowledge" "model" "serving" "model_gateway" "agent_gateway" "management/resource" "management/safety_filter" "management/history" "model-benchmark" "finetuning" )

  for APP_URL in ${APP_URL__ARRAY[@]}; do
    SEP="--"
    FILENAME="${APP_URL/\//$SEP}.swagger.json"
    URL_PATH="${PATH_PREFIX}${APP_URL}"
    OPENAPI_JSON_URL="${DOMAIN}${URL_PATH}/openapi.json"

    curl -fsSL "${OPENAPI_JSON_URL}" -o "${FILENAME}"
  done

  npx openapi-merge-cli

  ls ./merged.swagger.json
}

merge_swaggers "$@"
