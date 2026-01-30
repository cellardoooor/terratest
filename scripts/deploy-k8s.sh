#!/usr/bin/env bash
set -euo pipefail

# deploy-k8s.sh <cluster_id> <monitoring_ns> <zabbix_ns> <postgres_password> <ingress_ns> <public_subnet_id>
CLUSTER_ID=${1:?}
MON_NS=${2:?}
ZBX_NS=${3:?}
PG_PASS=${4:?}
ING_NS=${5:?}
PUBLIC_SUBNET_ID=${6:?}

# Ensure required CLIs are available
command -v yc >/dev/null 2>&1 || { echo "yc CLI not found; install it and authenticate" >&2; exit 2; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found; install it" >&2; exit 2; }
command -v helm >/dev/null 2>&1 || { echo "helm not found; install it" >&2; exit 2; }

echo "Fetching kubeconfig for cluster ${CLUSTER_ID}"
yc managed-kubernetes cluster get-credentials "${CLUSTER_ID}" --external

KUBECONFIG_PATH="${HOME}/.kube/config"
if [ ! -f "${KUBECONFIG_PATH}" ]; then
  echo "Kubeconfig not found at ${KUBECONFIG_PATH}" >&2
  exit 3
fi

echo "Applying namespaces"
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Namespace
metadata:
  name: ${MON_NS}
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${ZBX_NS}
---
apiVersion: v1
kind: Namespace
metadata:
  name: ${ING_NS}
EOF

# Create StorageClass for Yandex CSI (example)
cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: yandex-network-ssd
provisioner: yandex.csi.flant.com
parameters:
  type: network-ssd
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
EOF

# Example: install nginx ingress controller via helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx || true
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ${ING_NS} --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations.service\.beta\.kubernetes\.io/yandex-load-balancer-external-subnet-id=${PUBLIC_SUBNET_ID}

# Example: deploy Zabbix/Postgres via helm/chart (placeholder)
# You can add more helm installs here, using ${PG_PASS} for postgres password where needed.

echo "K8s deploy script finished"
