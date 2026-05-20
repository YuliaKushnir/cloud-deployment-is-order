#!/bin/bash

# Скрипт для деплою всього застосунку в Kubernetes
#
# Використання:
#   ./deploy.sh              # Деплой з поточними версіями
#   ./deploy.sh --dry-run    # Показати що буде застосовано (без змін)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KUSTOMIZE_DIR="$PROJECT_ROOT/kustomize"

echo "=== Деплой Cloud Demo Application ==="
echo ""

# Перевірка наявності kubectl
if ! command -v kubectl &> /dev/null; then
    echo "ПОМИЛКА: kubectl не знайдено. Встановіть kubectl."
    exit 1
fi

# Перевірка підключення до кластеру
if ! kubectl cluster-info &> /dev/null; then
    echo "ПОМИЛКА: Немає підключення до Kubernetes кластеру."
    exit 1
fi

# Dry run режим
if [ "$1" == "--dry-run" ]; then
    echo "=== DRY RUN MODE ==="
    echo "Наступні ресурси будуть створені/оновлені:"
    echo ""
    kubectl kustomize "$KUSTOMIZE_DIR"
    exit 0
fi

# Створення секретів (якщо ще не існують)
echo "Перевірка секретів..."
if ! kubectl get secret postgresql-secret -n cloud-demo &> /dev/null; then
    echo "Postgresql секрети не знайдено. Створюю..."
    "$SCRIPT_DIR/create-secrets.sh"
fi
if ! kubectl get secret rabbitmq-secret -n cloud-demo &> /dev/null; then
    echo "RabbitMQ секрет не знайдено. Створюю..."
    "$SCRIPT_DIR/create-secrets.sh"
fi
if ! kubectl get secret mail-secret -n cloud-demo &> /dev/null; then
    echo "Mail секрет не знайдено. Створюю..."
    "$SCRIPT_DIR/create-secrets.sh"
fi
if ! kubectl get secret cloudinary-secret -n cloud-demo &> /dev/null; then
    echo "Cloudinary секрет не знайдено. Створюю..."
    "$SCRIPT_DIR/create-secrets.sh"
fi
if ! kubectl get secret keycloak-secret -n cloud-demo &> /dev/null; then
    echo "Keycloak секрет не знайдено. Створюю..."
    "$SCRIPT_DIR/create-secrets.sh"
fi

# Застосування конфігурації
echo ""
echo "Застосовую Kustomize конфігурацію..."
kubectl apply -k "$KUSTOMIZE_DIR"

echo ""
echo "=== Деплой завершено ==="
echo ""
echo "Перевірка статусу:"
echo "  kubectl get pods -n cloud-demo"
echo "  kubectl get services -n cloud-demo"
echo ""
echo "Логи :"
echo "  kubectl logs -f deployment/gateway-service -n cloud-demo"
echo "  kubectl logs -f deployment/product-service -n cloud-demo"
echo "  kubectl logs -f deployment/order-service -n cloud-demo"
echo "  kubectl logs -f deployment/print-service -n cloud-demo"
echo "  kubectl logs -f deployment/user-service -n cloud-demo"
echo "  kubectl logs -f deployment/notification-service -n cloud-demo"
