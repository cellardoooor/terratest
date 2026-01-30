#!/bin/bash

# Установка переменных окружения для Yandex Cloud
# Использование: source scripts/set-creds.sh

echo "🔐 Установка Yandex Cloud credentials..."

# Запросите у пользователя данные
read -p "Введите Yandex Cloud ID: " CLOUD_ID
read -p "Введите Yandex Folder ID: " FOLDER_ID
read -p "Введите путь к SA key JSON: " SA_KEY_PATH
read -p "Введите путь к SSH public key: " SSH_KEY_PATH

# Экспорт переменных
export TF_VAR_cloud_id="$CLOUD_ID"
export TF_VAR_folder_id="$FOLDER_ID"
export TF_VAR_sa_key_path="$SA_KEY_PATH"
export TF_VAR_ssh_public_key_path="$SSH_KEY_PATH"

echo ""
echo "✅ Переменные установлены:"
echo "  - cloud_id: $CLOUD_ID"
echo "  - folder_id: $FOLDER_ID"
echo "  - sa_key_path: $SA_KEY_PATH"
echo "  - ssh_public_key_path: $SSH_KEY_PATH"
echo ""
echo "Для проверки: echo \$TF_VAR_cloud_id"
