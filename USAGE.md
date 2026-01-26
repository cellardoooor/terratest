# Инструкция по развертыванию платформы

## 1. Подготовка аккаунта Yandex Cloud

### 1.1 Создайте Service Account
```bash
yc iam service-account create --name terraform-sa
```

### 1.2 Получите credentials
```bash
# Создайте ключ
yc iam key create --service-account-name terraform-sa --output key.json

# Получите данные
yc config profile get
```

### 1.3 Проверьте доступы
Service Account должен иметь роли:
- `admin` или `editor` (минимум)
- `k8s.admin` (для кластера)
- `storage.uploader` (для дисков)

## 2. Подготовка SSH ключа
```bash
# Сгенерируйте ключ, если его нет
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_platform -C "platform-engineering"

# Публичный ключ для node group
cat ~/.ssh/id_platform.pub
```

## 3. Настройка Terraform

### 3.1 Установите зависимости
```bash
# Terraform >= 1.4.0
# Yandex CLI (опционально)
```

### 3.2 Обновите переменные
Редактируйте `envs/dev/terraform.tfvars`:
```hcl
# Yandex Cloud credentials
cloud_id          = "YOUR_CLOUD_ID"
folder_id         = "YOUR_FOLDER_ID"
sa_key_path       = "/path/to/key.json"
service_account_id = "YOUR_SA_ID"

# SSH
ssh_public_key_path = "/path/to/id_platform.pub"

# Passwords (ИЗМЕНИТЕ В PRODUCTION!)
postgres_password = "StrongPassword123"
```

## 4. Развертывание Infrastructure (Фаза 1)

### 4.1 Инициализация
```bash
cd envs/dev
terraform init
```

### 4.2 Проверка плана
```bash
terraform plan
```

### 4.3 Применение
```bash
terraform apply
```

После выполнения вы получите:
- `lb_ip` - IP Load Balancer
- `cluster_endpoint` - Endpoint кластера (sensitive)
- `cluster_ca_certificate` - CA сертификат (sensitive)
- `public_subnet_id` - ID публичной подсети

## 5. Настройка kubectl (для Yandex Managed K8s)

### 5.1 Получите данные кластера
```bash
terraform output cluster_endpoint
terraform output cluster_ca_certificate
```

### 5.2 Настройте кластер в Yandex Cloud Console
Или используйте Yandex CLI:
```bash
yc managed-kubernetes cluster get-credentials <cluster-id> \
  --external \
  --folder-id <folder-id>
```

## 6. Развертывание Kubernetes Resources (Фаза 2)

### 6.1 Получение данных кластера
После terraform apply вы получите outputs:
```bash
# Сохраните переменные для второго apply
export PUBLIC_SUBNET_ID=$(terraform output -raw public_subnet_id)
export CLUSTER_ENDPOINT=$(terraform output -raw cluster_endpoint)
export CLUSTER_CA=$(terraform output -raw cluster_ca_certificate)

# Получите токен (если нужно)
# Для Yandex Managed K8s используйте:
# yc managed-kubernetes cluster get-credentials <cluster-id>
```

### 6.2 Подготовка переменных для k8s-resources.tf
Создайте файл `k8s.tfvars` или используйте переменные окружения:
```hcl
public_subnet_id   = "subnet-..."
k8s_endpoint       = "https://..."
k8s_ca_certificate = "..."
k8s_token          = "..." # или используйте yc config
```

### 6.3 Применение Kubernetes ресурсов
```bash
terraform apply \
  -var="public_subnet_id=$PUBLIC_SUBNET_ID" \
  -var="k8s_endpoint=$CLUSTER_ENDPOINT" \
  -var="k8s_ca_certificate=$CLUSTER_CA" \
  -var-file="k8s.tfvars" \
  k8s-resources.tf
```

Это создаст:
- Namespace `ingress-nginx`
- Service для Ingress Controller (LoadBalancer)
- StorageClass `yandex-network-ssd`
- Namespace `monitoring` и `zabbix`
- PVC для Prometheus, Loki, Grafana, PostgreSQL
- ConfigMaps и Secrets

## 7. Развертывание Services (Helm)

После Terraform нужно развернуть Kubernetes сервисы через Helm:

### 7.1 Подключитесь к кластеру
```bash
kubectl get nodes
```

### 7.2 Установите NGINX Ingress Controller
```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --create-namespace \
  --set controller.service.type=LoadBalancer \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/yandex-load-balancer-external-subnet-id"="<public_subnet_id>"
```

### 7.3 Установите Prometheus + Grafana
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace
```

### 7.4 Установите Loki
```bash
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install loki grafana/loki-stack \
  --namespace monitoring
```

### 7.5 Установите PostgreSQL (для Zabbix)
```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install postgresql bitnami/postgresql \
  --namespace zabbix \
  --create-namespace \
  --set auth.username=zabbix \
  --set auth.password=zabbix123 \
  --set auth.database=zabbix
```

### 7.6 Установите Zabbix
```bash
helm install zabbix zabbix/zabbix-server-omni \
  --namespace zabbix \
  --set db.postgresql.enabled=false \
  --set db.postgresql.host=postgresql.zabbix.svc.cluster.local \
  --set db.postgresql.user=zabbix \
  --set db.postgresql.password=zabbix123 \
  --set db.postgresql.database=zabbix
```

## 8. Настройка Ingress Rules

Создайте Ingress для доступа к сервисам:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: platform-ingress
  namespace: monitoring
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: grafana.example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: grafana
            port:
              number: 80
  - host: prometheus.example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: prometheus-server
            port:
              number: 80
  - host: loki.example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: loki
            port:
              number: 3100
  - host: zabbix.example.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: zabbix-web
            port:
              number: 80
```

## 9. Проверка работы

### 9.1 Проверьте сервисы
```bash
kubectl get pods -n monitoring
kubectl get pods -n zabbix
kubectl get pods -n ingress-nginx
```

### 9.2 Проверьте Load Balancer
```bash
terraform output lb_ip
```

### 9.3 Добавьте DNS записи
Добавьте в `/etc/hosts` или DNS:
```
<lb_ip> grafana.example.local
<lb_ip> prometheus.example.local
<lb_ip> loki.example.local
<lb_ip> zabbix.example.local
```

## 10. Работа с проектом

### 10.1 Обновление конфигурации
```bash
terraform plan
terraform apply
```

### 10.2 Удаление
```bash
terraform destroy
```

## 11. Security Best Practices

### 11.1 Пароли
- **Всегда** меняйте пароли в production
- Используйте Vault или секреты менеджеров
- Никогда не коммитьте реальные пароли

### 11.2 SSH
- Ключ используется только для node group
- В production рассмотрите отказ от SSH (используйте Cloud Config)

### 11.3 Network Policies
Настройте Network Policies в Kubernetes:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: restrict-internal
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: monitoring
    - podSelector:
        matchLabels:
          app: grafana
```

## 12. Troubleshooting

### 12.1 Terraform Error
```
Error: Provider configuration incomplete
```
**Решение**: Настройте kubernetes provider после создания кластера

### 12.2 Node Group не создается
**Решение**: Проверьте квоты Yandex Cloud для Disk и IP

### 12.3 Load Balancer не доступен
**Решение**: Проверьте Security Groups и subnet IDs

### 12.4 PVC не binding
**Решение**: Проверьте StorageClass и наличие дисков

## 13. CI/CD Integration

Для GitOps можно использовать:
- ArgoCD
- Flux
- Jenkins + Terraform

Пример pipeline:
```yaml
stages:
  - terraform-init
  - terraform-plan
  - terraform-apply (опционально)
  - helm-deploy
```

## 14. Ссылки

- [Yandex Cloud Documentation](https://cloud.yandex.ru/docs/)
- [Yandex Managed Kubernetes](https://cloud.yandex.ru/docs/managed-kubernetes/)
- [Terraform Yandex Provider](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs)
- [Helm Charts](https://artifacthub.io/)
