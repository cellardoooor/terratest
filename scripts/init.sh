#!/bin/bash

# Инициализация Terraform проекта
# Запускать из корня проекта: bash scripts/init.sh

set -e

echo "🔄 Инициализация Terraform проекта..."

# Проверка зависимости
if ! command -v terraform &> /dev/null; then
    echo "❌ Terraform не установлен. Установите terraform >= 1.4.0"
    exit 1
fi

if ! command -v yc &> /dev/null; then
    echo "⚠️  Yandex CLI не установлен (опционально)"
    echo "Установите: curl -sSL https://storage.yandexcloud.net/yandexcloud-yc/install.sh | bash"
fi

echo "✅ Зависимости проверены"

# Создание директорий если их нет
mkdir -p envs/dev

# Копирование .gitignore если нет
if [ ! -f .gitignore ]; then
    echo "📝 Создание .gitignore..."
    cp .gitignore.example .gitignore
fi

# Копирование terraform.tfvars если нет
if [ ! -f envs/dev/terraform.tfvars ]; then
    echo "📝 Создание terraform.tfvars (шаблон)..."
    cp envs/dev/terraform.tfvars.example envs/dev/terraform.tfvars
    echo "⚠️  Отредактируйте envs/dev/terraform.tfvars перед запуском terraform!"
fi

# Инициализация Terraform
echo "🔄 Инициализация Terraform..."
cd envs/dev
terraform init

echo ""
echo "✅ Готово!"
echo ""
echo "Следующие шаги:"
echo "1. Отредактируйте envs/dev/terraform.tfvars"
echo "2. Запустите: terraform plan"
echo "3. Примените: terraform apply"
echo ""
echo "Документация:"
echo "- QUICKSTART.md - Быстрый старт"
echo "- USAGE.md - Полная инструкция"
echo "- README.md - Общая информация"
