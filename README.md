# Platform Engineering Infrastructure (Yandex Cloud)

Учебная platform-engineering платформа для развертывания Kubernetes инфраструктуры в Yandex Cloud.

## Архитектура

```
Internet
   |
[Public Subnet - 10.0.1.0/24]
   |
[Load Balancer (HTTP/HTTPS)]
   |
[Kubernetes Ingress Controller]
   |
-----------------------------------------------
| Kubernetes Cluster                           |
|                                              |
|  PostgreSQL  <- Zabbix                       |
|  Prometheus  <- Alertmanager                 |
|  Grafana     <- Prometheus + Loki            |
|  Loki        -> PVC                          |
|  Zabbix      -> PVC                          |
|  Prometheus  -> PVC                          |
|  Grafana     -> PVC                          |
-----------------------------------------------
   |
[Private Subnet - 10.0.2.0/24]
```

## Структура проекта

```
├── modules/             # Terraform модули
│   ├── network/         # VPC, NAT Gateway, Public/Private subnets
│   ├── security_groups/ # Security Groups (LB, K8s master/nodes)
│   ├── kubernetes_cluster/ # Managed K8s cluster + node group
│   └── ingress/         # Load Balancer для Ingress Controller
│
├── envs/
│   └── dev/             # Dev окружение
│       ├── versions.tf  # Версии Terraform и провайдеров
│       ├── providers.tf # Конфигурация провайдера Yandex
│       ├── main.tf      # Основной конфиг
│       ├── variables.tf # Переменные
│       ├── outputs.tf   # Выводы
│       └── terraform.tfvars # Значения переменных
│
├── scripts/
│   ├── init.sh          # Инициализация проекта
│   ├── deploy-k8s.sh    # Развертывание компонентов в кластер
│   └── set-creds.sh     # Установка credentials
│
├── .gitignore.example   # Пример .gitignore
├── README.md            # Общая информация
├── QUICKSTART.md        # Быстрый старт
└── USAGE.md             # Полная инструкция
```

## Компоненты

### Модуль Network
- **VPC**: 1 сеть
- **Public Subnet**: 10.0.1.0/24 (Load Balancer)
- **Private Subnet**: 10.0.2.0/24 (K8s nodes, внутренние сервисы)

### Модуль Security Groups
- **Load Balancer SG**:
  - Входящие: TCP 80, 443 (0.0.0.0/0)
  - Исходящие: TCP 30000-32767 (NodePorts → private subnet)
- **K8s Nodes SG**:
  - Входящие: TCP 6443 (API), 10250 (Kubelet), 30000-32767 (NodePorts)
  - Входящие: UDP 8472 (VXLAN overlay)
  - Исходящие: ANY (для образов, обновлений)

### Модуль Kubernetes Cluster
- **Тип**: Managed Kubernetes (Yandex Managed Service for Kubernetes)
- **Master Nodes**: 
  - Не имеют public IP (`public_ip = false`)
  - Доступ к API только изнутри VPC или через Yandex Cloud Console
- **Node Group**: `worker-nodes`
  - 3 ноды
  - 4 CPU, 16 GB RAM
  - Network SSD 64 GB
  - Private subnet (без публичного IP)
  - SSH по ключу

### Модуль Ingress
- **Load Balancer**: Network Load Balancer (HTTP/HTTPS)
- **Target Group**: для Ingress Controller (заполняется динамически)
- Поддерживает интеграцию с NGINX Ingress Controller через Helm

## In-Cluster Services

⚠️ **Важно**: In-cluster сервисы НЕ создаются Terraform автоматически. Они разворачиваются отдельно через скрипт `scripts/deploy-k8s.sh` или вручную через Helm.

Сервисы для развертывания:
- **NGINX Ingress Controller** (ingress-nginx) - автоматически через deploy-k8s.sh
- **PostgreSQL** (для Zabbix) - вручную или через deploy-k8s.sh
- **Zabbix** (server + web + proxy) - вручную или через deploy-k8s.sh
- **Prometheus** (server + alertmanager) - вручную или через Helm
- **Grafana** (with datasource provisioning) - вручную или через Helm
- **Loki** (log aggregation) - вручную или через Helm
- **StorageClass** (yandex-network-ssd) - автоматически через deploy-k8s.sh

## Как развернуть

### 1. Подготовка
```bash
# Клонировать репозиторий
git clone <repo>
cd <repo-name>

# Настроить переменные в envs/dev/terraform.tfvars
# Важные переменные:
# - sa_key_path: путь к JSON ключу Service Account
# - cloud_id, folder_id: ID вашего облака и папки
# - ssh_public_key_path: путь к публичному SSH ключу
# - service_account_id: ID Service Account для кластера
```

### 2. Инициализация проекта
```bash
bash scripts/init.sh
# Скрипт создаст terraform.tfvars и выполнит terraform init
```

### 3. Развертывание инфраструктуры
```bash
cd envs/dev
terraform plan
terraform apply
```

### 4. Получение данных кластера
```bash
# Сохраняем ID кластера для следующего шага
CLUSTER_ID=$(terraform output -raw cluster_id)
echo "Cluster ID: $CLUSTER_ID"
```

### 5. Развертывание компонентов в кластер
```bash
# Из корня репозитория
bash scripts/deploy-k8s.sh "$CLUSTER_ID" monitoring zabbix "your_postgres_password" ingress-nginx "<public_subnet_id>"
```

### 6. Проверка
```bash
# Получить данные для подключения к кластеру
yc managed-kubernetes cluster get-credentials "$CLUSTER_ID" --external

# Проверить namespaces
kubectl get ns

# Установить мониторинг (Prometheus + Grafana) если требуется
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring --create-namespace

# Проверить что Ingress Controller уже установлен (через deploy-k8s.sh)
kubectl get pods -n ingress-nginx
```

## Outputs (после terraform apply)

```bash
cd envs/dev

# Основные параметры
terraform output -raw cluster_id          # ID кластера
terraform output -raw lb_ip               # IP Load Balancer
terraform output -raw cluster_endpoint    # Endpoint кластера API
terraform output -raw cluster_ca_certificate # CA сертификат

# Все outputs
terraform output
```

## Безопасность

### Passwords
Файл `envs/dev/terraform.tfvars` содержит пароли по умолчанию.
**В production обязательно измените:**
- `postgres_password`
- Пароли в Kubernetes секретах

### SSH
Минимальное использование SSH:
- Только для нод Kubernetes (node group)
- Ключ указан в переменной `ssh_public_key_path`
- Используется только для node group template

### Без SSH
Для внутренних сервисов (PostgreSQL, Zabbix, Prometheus, Grafana, Loki) SSH не требуется.

## Список требований

1. **Yandex Cloud** аккаунт с:
   - Service Account с ролью `admin` или `k8s.admin`
   - API ключ (service account key)
   - Существующие cloud_id, folder_id

2. **Terraform** >= 1.4.0

3. **Yandex CLI** (опционально для управления)

4. **Kubectl** и **Helm** (для развертывания сервисов)

## Решение проблем

### Cloud Credential Errors
Убедитесь, что:
- Путь к sa_key_path корректен
- Service account имеет необходимые права
- Cloud ID и Folder ID верны

### State Locking
Используется S3 backend. Убедитесь, что bucket существует и доступен.

### Resource Quotas
Проверьте квоты в Yandex Cloud (особенно для Disk и IP).

## License

MIT
