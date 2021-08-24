# kubectl settings

# ==============================================================================================================
# Kubernetes Settings ==========================================================================================
# ==============================================================================================================

# Proxy Certificate Setting
alias k-certdata="kubectl config set "clusters.$(kubectl config current-context).certificate-authority-data" "$(cat $HOME/.ssl/my.crt|base64 -i -)""

# Unused: See this message:
# error: certificate-authority-data and certificate-authority are both specified for $CLUSTER_NAME. certificate-authority-data will override.
#alias k-cert="kubectl config set "clusters.$(kubectl config current-context).certificate-authority" $HOME/.ssl/my.crt"
alias kc="k-certdata"
kc

alias kv="kubectl --insecure-skip-tls-verify"

alias clean-dns="sudo killall -HUP mDNSResponder"

export PATH=$PATH:$HOME/.istioctl/bin

#alias k9v="k9s --insecure-skip-tls-verify"
#complete -F __start_kubectl k
source <(kubectl completion zsh)

alias k="kubectl"
#alias kk="kubectl --insecure-skip-tls-verify"
#alias k9k="k9s --insecure-skip-tls-verify"

alias kme="kubectl config current-context;kubectl cluster-info"

function kns () {
  NAMESPACE="${1:-default}"
  kubectl config set-context --current --namespace="${NAMESPACE}"
}

# "kubectl -n istio-system get gw ingress-prd -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' | yq -y"
function kexec () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  SELECTOR="$2"
  CMD="${3:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty "$(kubectl -n ${NAMESPACE} get pods -l ${SELECTOR} -o jsonpath="{.items[0].metadata.name}")" -- ${CMD}
}

# "kubectl -n istio-system get gw ingress-prd -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' | yq -y"
function kx () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  SELECTOR="$2"
  CMD="${3:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty "$(kubectl -n ${NAMESPACE} get pods -l ${SELECTOR} -o jsonpath="{.items[0].metadata.name}")" -- ${CMD}
}

function kxc () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  SELECTOR="$2"
  CONTAINER="$3"
  CMD="${4:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty "$(kubectl -n ${NAMESPACE} get pods -l ${SELECTOR} -o jsonpath='{.items[0].metadata.name}')" -c ${CONTAINER} -- ${CMD}
}

function kxp () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  PODNAME="$2"
  CONTAINER="$3"
  CMD="${4:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty ${PODNAME} -c ${CONTAINER} -- ${CMD}
}

function kdb () {
  NAMESPACE="${1:-default}"
  SA="${2:-default}"
  kubectl -n ${NAMESPACE} run --rm -it debug --image=pydemia/debug --restart=Never --serviceaccount=${SA}
}

function kdbs () {
  NAMESPACE="${1:-default}"
  SA="${2:-default}"
  kubectl -n ${NAMESPACE} run --rm -it debug --image=pydemia/debug-slim --restart=Never --serviceaccount=${SA}
}



"kubectl get svc -n airuntime -o jsonpath='{range .items[*]}{.metadata.name}{"\t\t"}{.spec.ports}{"\n"}{end}'"


# ===========================================
function isvclog () {
  NAMESPACE="${1:-default}"
  ISVC_NM="$2"
  COMPONENT="${3:-predictor}"
  DEPLOY_TYPE="${4:-default}"
  CONTAINER_NM="${5:-kfserving-container}"

  if [[ -z $ISVC_NM ]]; then
    echo "inferenceservice '-i' is not given."
    exit 1
  else
    echo "$ISVC_NM in $NAMESPACE"
    kubectl -n ${NAMESPACE} logs "$(kubectl -n ${NAMESPACE} get pods -l=serving.kubeflow.org/inferenceservice=${ISVC_NM},component=${COMPONENT},service.istio.io/canonical-name=${ISVC_NM}-${COMPONENT}-${DEPLOY_TYPE} -o=jsonpath='{.items[0].metadata.name}')" -c ${CONTAINER_NM}
  fi

}
# ===========================================

# ==============================================================================================================
# ==============================================================================================================
# ==============================================================================================================
