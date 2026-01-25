# Terraform Yandex Cloud Test Project

Инфраструктура для тестирования сервисов в Yandex Cloud, развернутая с помощью Terraform.  
Основные компоненты:

- Создание VPC и подсетей
- Настройка Compute Instances (Виртуальные машины)
- Настройка Instance Group с автоскейлингом (только dev окружение)
- Настройка Network Load Balancer (Network Load Balancer)
- Security Groups для защиты сетевых ресурсов
- NAT сетей для доступа к интернету

## Структура проекта

```
ter/
├── environments/
│   ├── dev/       # Dev окружение с автоскейлингом и LB
│   └── test/      # Test окружение с 1 VM и LB
├── modules/
│   ├── compute/          # Базовые VM
│   ├── instance_group/   # Группа VM с автоскейлингом
│   ├── load_balancer/    # Целевая группа и балансировщик
│   ├── security/         # Security groups
│   └── vpc/              # Сеть и подсеть
└── terraform/    # Артефакты предыдущих запусков (игнорировать)
```

## Использование

### Dev окружение
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### Test окружение
```bash
cd environments/test
terraform init
terraform plan
terraform apply
```

## Outputs

- `vpc_network_id` - ID сети
- `vm_ip_address` - IP адрес VM
- `load_balancer_external_ip` - Публичный IP балансировщика
- `vm_security_group_id` - ID security group для VM
