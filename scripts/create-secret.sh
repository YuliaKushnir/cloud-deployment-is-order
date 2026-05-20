#!/bin/bash

# Скрипт для створення Kubernetes Secrets
# Запускати один раз перед першим деплоєм
#
# Використання:
#   ./create-secrets.sh
#
# Або з власними паролями:
#   POSTGRES_PASSWORD=mypass RABBITMQ_PASSWORD=mypass ./create-secrets.sh

set -e

NAMESPACE="cloud-demo"

echo "=== Creating / Updating Kubernetes Secrets ==="

# ---- REQUIRED SECRETS CHECK ----
required_vars=(
  POSTGRES_USER
  POSTGRES_PASSWORD
  RABBITMQ_USER
  RABBITMQ_PASSWORD
  MAIL_HOST
  MAIL_PORT
  MAIL_USER
  MAIL_PASS

  CLOUDINARY_CLOUD_NAME
  CLOUDINARY_API_KEY
  CLOUDINARY_API_SECRET

  KEYCLOAK_REALM
  KEYCLOAK_CLIENT_ID
  KEYCLOAK_USERNAME
  KEYCLOAK_PASSWORD
  KEYCLOAK_TARGET_CLIENT_ID
  KEYCLOAK_ADMIN
  KEYCLOAK_ADMIN_PASSWORD
)

for var in "${required_vars[@]}"; do
  if [ -z "${!var}" ]; then
    echo "Environment variable $var is NOT set"
    exit 1
  fi
done

# ---- POSTGRES ----
echo "Applying postgresql-secret..."
kubectl create secret generic postgresql-secret \
  --from-literal=username="$POSTGRES_USER" \
  --from-literal=password="$POSTGRES_PASSWORD" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# ---- RABBITMQ ----
echo "Applying rabbitmq-secret..."
kubectl create secret generic rabbitmq-secret \
  --from-literal=username="$RABBITMQ_USER" \
  --from-literal=password="$RABBITMQ_PASSWORD" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# ---- MAIL ----
echo "Applying mail-secret..."
kubectl create secret generic mail-secret \
  --from-literal=host="$MAIL_HOST" \
  --from-literal=port="$MAIL_PORT" \
  --from-literal=username="$MAIL_USER" \
  --from-literal=password="$MAIL_PASS" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# ---- CLOUDINARY ----
echo "Applying cloudinary-secret..."
kubectl create secret generic cloudinary-secret \
  --from-literal=cloud-name="$CLOUDINARY_CLOUD_NAME" \
  --from-literal=api-key="$CLOUDINARY_API_KEY" \
  --from-literal=api-secret="$CLOUDINARY_API_SECRET" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# ---- KEYCLOAK ----
echo "Applying mail-secret..."
kubectl create secret generic keycloak-secret \
  --from-literal=realm="$KEYCLOAK_REALM" \
  --from-literal=client-id="$KEYCLOAK_CLIENT_ID" \
  --from-literal=username="$KEYCLOAK_USERNAME" \
  --from-literal=password="$KEYCLOAK_PASSWORD" \
  --from-literal=target-client-id="$KEYCLOAK_TARGET_CLIENT_ID" \
  --from-literal=keycloak-admin="$KEYCLOAK_ADMIN" \
  --from-literal=keycloak-admin-password="$KEYCLOAK_ADMIN_PASSWORD" \
  -n $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

echo "All secrets created or updated successfully"