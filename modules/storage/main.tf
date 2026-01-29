# Note: Storage resources (StorageClass, ConfigMaps) are created via deploy-k8s.sh script
# using kubectl and Kubernetes manifests to avoid dependency on kubernetes provider.
# 
# This allows the storage configuration to be applied directly to the cluster
# without requiring Terraform's kubernetes provider to be configured.
#
# StorageClass manifest (applied via deploy-k8s.sh):
# 
# apiVersion: storage.k8s.io/v1
# kind: StorageClass
# metadata:
#   name: yandex-network-ssd
#   annotations:
#     storageclass.kubernetes.io/is-default-class: "true"
# provisioner: yandex.csi.flant.com
# parameters:
#   type: network-ssd
#   fsType: ext4
#   zone: ru-central1-a
# allowVolumeExpansion: true
# reclaimPolicy: Retain
# volumeBindingMode: WaitForFirstConsumer
# mountOptions:
#   - discard
