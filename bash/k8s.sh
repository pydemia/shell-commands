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

function kns () { kubectl config set-context --current --namespace="$1" }

# "kubectl -n istio-system get gw ingress-prd -o jsonpath='{.metadata.annotations.kubectl\.kubernetes\.io/last-applied-configuration}' | yq -y"
function kexec () {
  NAMESPACE="$1"
  # SELECTOR="model=skh-bch-003"
  SELECTOR="$2"
  CMD="${3:-/bin/bash}"
  kubectl -n ${NAMESPACE} exec --stdin --tty "$(kubectl -n ${NAMESPACE} get pods -l ${SELECTOR} -o jsonpath="{.items[0].metadata.name}")" -- ${CMD}
}

function kdb () {
  NAMESPACE="${1:-default}"
  kubectl -n ${NAMESPACE} run --rm -it debug --image=pydemia/debug --restart=Never
}

# ==============================================================================================================
# ==============================================================================================================
# ==============================================================================================================
