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
ter/
├── versions.tf          # Версии Terraform и провайдеров
├── providers.tf         # Конфигурация провайдера Yandex
├── backend.tf           # Конфигурация state storage (S3)
├── modules/             # Terraform модули
│   ├── network/         # VPC, Public/Private subnets
│   ├── security_groups/ # Security Groups (LB, K8s nodes)
│   ├── kubernetes_cluster/ # Managed K8s cluster + node group
│   ├── storage/         # StorageClass для Persistent Volumes
│   ├── ingress/         # Load Balancer + Ingress Controller
│   └── monitoring/      # Namespace, PVC, ConfigMaps
│
├── envs/
│   └── dev/             # Dev окружение
│       ├── main.tf      # Основной конфиг
│       ├── variables.tf # Переменные
│       ├── outputs.tf   # Выводы
│       └── terraform.tfvars # Значения переменных
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
- **Node Group**: `worker-nodes`
  - 3 ноды
  - 4 CPU, 16 GB RAM
  - Network SSD 64 GB
  - Private subnet (без публичного IP)
  - SSH по ключу

### Модуль Storage
- **StorageClass**: `yandex-network-ssd`
  - Provisioner: `yandex.csi.flant.com`
  - Type: `network-ssd`
  - Allow volume expansion: true
  - Reclaim policy: Retain

### Модуль Ingress
- **Load Balancer**: Network Load Balancer (HTTP/HTTPS)
- **Ingress Controller**: NGINX (через Helm - в будущем)
- **Namespace**: `ingress-nginx`

### Модуль Monitoring
- **Namespace**: `monitoring`
- **Namespace**: `zabbix`
- **PVC**:
  - Prometheus: 20Gi
  - Loki: 10Gi
  - Grafana: 5Gi
  - PostgreSQL: 10Gi
  - Zabbix: 5Gi
- **ConfigMaps**:
  - Prometheus config
  - Loki config
  - Grafana datasources/dashboards
  - PostgreSQL config
- **Secrets**:
  - PostgreSQL password
  - Zabbix admin credentials

## Services (Kubernetes manifests)

Через Helm charts (не включены в этот репозиторий):
- **PostgreSQL** (для Zabbix)
- **Zabbix** (server + web + proxy)
- **Prometheus** (server + alertmanager)
- **Grafana** (with datasource provisioning)
- **Loki** (log aggregation)
- **NGINX Ingress Controller** (через Helm)
- **Node Exporter** (опционально)

## Как развернуть

### 1. Подготовка
```bash
# Клонировать репозиторий
git clone <repo>
cd ter

# Настроить переменные в envs/dev/terraform.tfvars
# Особое внимание: postgres_password, service_account_id, ssh keys
```

### 2. Инициализация Terraform
```bash
cd envs/dev
terraform init
```

### 3. Планирование
```bash
terraform plan
```

### 4. Применение
```bash
terraform apply
```

### 5. Настройка kubectl (после развертывания)
```bash
# Получить данные кластера
terraform output -raw cluster_endpoint
terraform output -raw cluster_ca_certificate

# Настроить kubectl через Yandex CLI или через полученные данные
# (специфично для Yandex Managed K8s)
```

### 6. Развертывание Helm-чартов
```bash
# Подключиться к кластеру
# Установить helm-чарты для:
# - ingress-nginx
# - prometheus-stack
# - loki-stack
# - postgresql (для zabbix)
# - zabbix
```

## Outputs (после terraform apply)

```bash
# Основные параметры
terraform output lb_ip                    # IP Load Balancer
terraform output cluster_endpoint         # Endpoint кластера
terraform output storage_class_name       # Имя StorageClass

# Покажет все outputs
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
