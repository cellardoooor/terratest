# Quick Start

## Быстрое развертывание за 3 этапа

### Этап 1: Инфраструктура (Terraform)
```bash
# Инициализация
bash scripts/init.sh

# Развертывание
cd envs/dev
terraform plan
terraform apply
```

### Этап 2: Получение данных кластера
```bash
# Сохраняем данные для следующего шага
CLUSTER_ID=$(terraform output -raw cluster_id)
PUBLIC_SUBNET_ID=$(terraform output -raw public_subnet_id)

echo "Cluster ID: $CLUSTER_ID"
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
```

### Этап 3: Развертывание компонентов в кластер
```bash
# Из корня проекта
bash scripts/deploy-k8s.sh "$CLUSTER_ID" monitoring zabbix "your_postgres_password" ingress-nginx "$PUBLIC_SUBNET_ID"
```

## Проверка

```bash
# Подключиться к кластеру
yc managed-kubernetes cluster get-credentials "$CLUSTER_ID" --external

# Проверить namespaces
kubectl get ns

# Проверить Kubernetes nodes
kubectl get nodes
```

## Минимальная конфигурация

Если нужны только базовые ресурсы (сеть + кластер):

```bash
bash scripts/init.sh
cd envs/dev
terraform apply
# Стоп - остальное позже!
```

## Развертывание Helm чартов

Для установки дополнительных сервисов:

```bash
# Подключиться к кластеру
yc managed-kubernetes cluster get-credentials "$CLUSTER_ID" --external

# Prometheus + Grafana
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# NGINX Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm install ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer
```

```bash
# Удалить все инфраструктуру
cd envs/dev
terraform destroy -auto-approve

# Удалить в-cluster ресурсы (оставить кластер)
kubectl delete namespace monitoring zabbix ingress-nginx
```

## Полезные команды

### Terraform
```bash
cd envs/dev

# Информация о state
terraform state list
terraform state show module.network.yandex_vpc_network.this

# Проверка конфигурации
terraform validate

# Обновление backend
terraform init -reconfigure

# Все outputs
terraform output
```

### Yandex CLI
```bash
# Список кластеров
yc managed-kubernetes cluster list

# Информация о кластере
yc managed-kubernetes cluster get <cluster-id>

# Публичные подсети
yc vpc subnet list

# Service accounts
yc iam service-account list
```

### Kubectl
```bash
# Список namespaces
kubectl get ns

# Список подов
kubectl get pods -A

# Список сервисов
kubectl get svc -A

# Список PVC
kubectl get pvc -A

# Логи пода
kubectl logs -f <pod-name> -n <namespace>

# Shell в pod
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
```

## Документация

- `README.md` - полная информация об архитектуре
- `USAGE.md` - детальная инструкция
- `modules/*/` - документация модулей
