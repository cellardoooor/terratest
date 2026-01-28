# Этот файл содержит ресурсы Kubernetes, которые требуют существующего кластера
# Запускается после terraform apply основного конфига

// In-cluster resources (namespaces, storageclass, monitoring, ingress, etc.)
// are applied outside of Terraform using the script `scripts/deploy-k8s.sh`.
//
// Workflow:
// 1) terraform apply (creates Yandex managed k8s cluster)
// 2) Run from repo root (in WSL where `yc`, `kubectl`, `helm` are available):
//    ./scripts/deploy-k8s.sh <cluster_id> <monitoring_ns> <zabbix_ns> <postgres_password> <ingress_ns> <public_subnet_id>
// Example:
//    ./scripts/deploy-k8s.sh $(terraform -chdir=envs/dev output -raw cluster_id) monitoring zabbix "${POSTGRES_PASS}" ingress <public_subnet_id>

// This approach avoids the need for the Terraform `kubernetes` and `helm` providers
// by delegating in-cluster work to standard CLIs.
