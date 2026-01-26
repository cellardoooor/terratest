# Quick Start

## Быстрое развертывание за 5 шагов

### Шаг 1: Подготовка
```bash
# Клонируем
cd ~/projects
git clone <repo> platform-engineering
cd platform-engineering

# Настраиваем переменные
cp envs/dev/terraform.tfvars.example envs/dev/terraform.tfvars
# Редактируем terraform.tfvars
```

### Шаг 2: Infrastructure
```bash
cd envs/dev
terraform init
terraform plan
terraform apply -auto-approve
```

### Шаг 3: Получаем данные
```bash
# Сохраняем переменные
LB_IP=$(terraform output -raw lb_ip)
ENDPOINT=$(terraform output -raw cluster_endpoint)
CA_CERT=$(terraform output -raw cluster_ca_certificate)

# Экспортируем для следующего шага
export TF_VAR_k8s_endpoint="$ENDPOINT"
export TF_VAR_k8s_ca_certificate="$CA_CERT"
```

### Шаг 4: Kubernetes Resources
```bash
# Применяем k8s-resources
terraform apply -var="k8s_endpoint=$ENDPOINT" -var="k8s_ca_certificate=$CA_CERT" k8s-resources.tf -auto-approve
```

### Шаг 5: Deploy Services (Helm)
```bash
# Подключаемся к кластеру
yc managed-kubernetes cluster get-credentials <cluster-id> --external

# Устанавливаем базовые сервисы
helm repo add grafana https://grafana.github.io/helm-charts
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# Простая проверка
kubectl get nodes
```

## Минимальная конфигурация

### Если нужны только базовые ресурсы (сеть + кластер)

```bash
terraform apply -auto-approve  # Только infrastructure
# Остановитесь на этом, если нужно развернуть сервисы вручную
```

### Если нужны все ресурсы

Установите через Helm основные сервисы:
```bash
# Prometheus + Grafana
helm install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace

# Loki (logs)
helm install loki grafana/loki-stack \
  --namespace monitoring

# Ingress NGINX
helm install ingress ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.type=LoadBalancer
```

## Проверка

```bash
# Проверить сеть
terraform output vpc_id
terraform output lb_ip

# Проверить кластер
terraform output cluster_endpoint
kubectl get nodes

# Проверить ресурсы
terraform state list
terraform state show module.network.yandex_vpc_network.this
```

## Удаление

```bash
# Удалить все
terraform destroy -auto-approve

# Удалить только k8s ресурсы (если нужно сохранить кластер)
terraform destroy -auto-approve -var="k8s_endpoint=$ENDPOINT" k8s-resources.tf
```

## Полезные команды Yandex CLI

```bash
# Список кластеров
yc managed-kubernetes cluster list

# Информация о кластере
yc managed-kubernetes cluster get <cluster-id>

# Публичные подсети
yc vpc subnet list

# Service accounts
yc iam service-account list

# Диски
yc compute disk list
```

## Полезные команды kubectl

```bash
# Список namespace
kubectl get ns

# Список подов
kubectl get pods -A

# Список сервисов
kubectl get svc -A

# Список PVC
kubectl get pvc -A

# Информация о поде
kubectl describe pod <pod-name> -n <namespace>

# Логи пода
kubectl logs -f <pod-name> -n <namespace>

# Shell в под
kubectl exec -it <pod-name> -n <namespace> -- /bin/bash
```

## Полезные команды Terraform

```bash
# Информация о state
terraform state list
terraform state show <resource>

# Модуль вывода
terraform output -json

# Проверка конфигурации
terraform validate

# Обновление backend (если изменился)
terraform init -reconfigure
```

## Частые проблемы

### Проблема: "Service account has no permission"
**Решение**: Добавьте роли service account в Yandex Cloud

### Проблема: "Quota exceeded"
**Решение**: Увеличьте квоты или уменьшите размеры дисков/нод

### Проблема: "Cluster not ready"
**Решение**: Подождите 5-10 минут, кластер создается не мгновенно

### Проблема: "Kubernetes provider not configured"
**Решение**: Вы используете k8s-resources.tf без данных кластера

## Окружение

```bash
# Для разработки
export TF_VAR_sa_key_path="$HOME/.secrets/yandex/key.json"
export TF_VAR_ssh_public_key_path="$HOME/.ssh/id_platform.pub"

# Для CI/CD
# Используйте vault или github secrets
```

## Документация

См. также:
- `USAGE.md` - полная инструкция
- `README.md` - общая документация
- `modules/*/README.md` - документация модулей (если создана)
