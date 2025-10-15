#!/bin/bash
# Plane Sealed Secrets Creation Template
# Run this to create production-ready sealed secrets for Plane

set -e

NAMESPACE="plane"
CONTROLLER_NAME="sealed-secrets"
CONTROLLER_NAMESPACE="kube-system"

echo "=== Plane Sealed Secrets Generator ==="
echo ""
echo "This script will help create sealed secrets for Plane deployment."
echo "Default values will be used if you press Enter without input."
echo ""

# PostgreSQL Credentials
echo "--- PostgreSQL Credentials ---"
read -p "PostgreSQL Username [plane]: " PG_USER
PG_USER=${PG_USER:-plane}

read -sp "PostgreSQL Password (will be hidden): " PG_PASS
echo ""
if [ -z "$PG_PASS" ]; then
    PG_PASS=$(openssl rand -base64 32)
    echo "Generated random password for PostgreSQL"
fi

# RabbitMQ Credentials
echo ""
echo "--- RabbitMQ Credentials ---"
read -p "RabbitMQ Username [plane]: " RABBITMQ_USER
RABBITMQ_USER=${RABBITMQ_USER:-plane}

read -sp "RabbitMQ Password (will be hidden): " RABBITMQ_PASS
echo ""
if [ -z "$RABBITMQ_PASS" ]; then
    RABBITMQ_PASS=$(openssl rand -base64 32)
    echo "Generated random password for RabbitMQ"
fi

# MinIO Credentials
echo ""
echo "--- MinIO Credentials ---"
read -p "MinIO Root User [plane-admin]: " MINIO_USER
MINIO_USER=${MINIO_USER:-plane-admin}

read -sp "MinIO Root Password (will be hidden): " MINIO_PASS
echo ""
if [ -z "$MINIO_PASS" ]; then
    MINIO_PASS=$(openssl rand -base64 32)
    echo "Generated random password for MinIO"
fi

# Django Secret Keys
echo ""
echo "--- Django Application Secrets ---"
SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
LIVE_SECRET_KEY=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
echo "Generated Django secret keys"

# Create temporary files
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo ""
echo "Creating sealed secrets..."

# 1. PostgreSQL Secret
cat > "$TEMP_DIR/pgdb-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: plane-pgdb-secret
  namespace: $NAMESPACE
type: Opaque
stringData:
  username: "$PG_USER"
  password: "$PG_PASS"
EOF

kubeseal --controller-name=$CONTROLLER_NAME \
  --controller-namespace=$CONTROLLER_NAMESPACE \
  --format=yaml < "$TEMP_DIR/pgdb-secret.yaml" > plane-pgdb-sealed-secret.yaml

echo "✓ Created plane-pgdb-sealed-secret.yaml"

# 2. RabbitMQ Secret
cat > "$TEMP_DIR/rabbitmq-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: plane-rabbitmq-secret
  namespace: $NAMESPACE
type: Opaque
stringData:
  username: "$RABBITMQ_USER"
  password: "$RABBITMQ_PASS"
  url: "amqp://${RABBITMQ_USER}:${RABBITMQ_PASS}@plane-ce-rabbitmq.${NAMESPACE}.svc.cluster.local:5672/"
EOF

kubeseal --controller-name=$CONTROLLER_NAME \
  --controller-namespace=$CONTROLLER_NAMESPACE \
  --format=yaml < "$TEMP_DIR/rabbitmq-secret.yaml" > plane-rabbitmq-sealed-secret.yaml

echo "✓ Created plane-rabbitmq-sealed-secret.yaml"

# 3. MinIO/DocStore Secret
cat > "$TEMP_DIR/docstore-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: plane-docstore-secret
  namespace: $NAMESPACE
type: Opaque
stringData:
  aws_access_key: "$MINIO_USER"
  aws_secret_access_key: "$MINIO_PASS"
EOF

kubeseal --controller-name=$CONTROLLER_NAME \
  --controller-namespace=$CONTROLLER_NAMESPACE \
  --format=yaml < "$TEMP_DIR/docstore-secret.yaml" > plane-docstore-sealed-secret.yaml

echo "✓ Created plane-docstore-sealed-secret.yaml"

# 4. Application Environment Secret
cat > "$TEMP_DIR/app-env-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: plane-app-env-secret
  namespace: $NAMESPACE
type: Opaque
stringData:
  secret_key: "$SECRET_KEY"
EOF

kubeseal --controller-name=$CONTROLLER_NAME \
  --controller-namespace=$CONTROLLER_NAMESPACE \
  --format=yaml < "$TEMP_DIR/app-env-secret.yaml" > plane-app-env-sealed-secret.yaml

echo "✓ Created plane-app-env-sealed-secret.yaml"

# 5. Live Server Secret
cat > "$TEMP_DIR/live-env-secret.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: plane-live-env-secret
  namespace: $NAMESPACE
type: Opaque
stringData:
  live_server_secret_key: "$LIVE_SECRET_KEY"
EOF

kubeseal --controller-name=$CONTROLLER_NAME \
  --controller-namespace=$CONTROLLER_NAMESPACE \
  --format=yaml < "$TEMP_DIR/live-env-secret.yaml" > plane-live-env-sealed-secret.yaml

echo "✓ Created plane-live-env-sealed-secret.yaml"

echo ""
echo "=== Sealed Secrets Created Successfully ==="
echo ""
echo "Files created in current directory:"
echo "  - plane-pgdb-sealed-secret.yaml"
echo "  - plane-rabbitmq-sealed-secret.yaml"
echo "  - plane-docstore-sealed-secret.yaml"
echo "  - plane-app-env-sealed-secret.yaml"
echo "  - plane-live-env-sealed-secret.yaml"
echo ""
echo "Next steps:"
echo "1. Move sealed secrets to sabkhi_lab_secrets/ directory"
echo "2. Apply sealed secrets manually:"
echo "   kubectl apply -f sabkhi_lab_secrets/plane-*-sealed-secret.yaml"
echo ""
echo "3. Update values.yaml to use these secrets:"
echo "   external_secrets:"
echo "     pgdb_existingSecret: 'plane-pgdb-secret'"
echo "     rabbitmq_existingSecret: 'plane-rabbitmq-secret'"
echo "     doc_store_existingSecret: 'plane-docstore-secret'"
echo "     app_env_existingSecret: 'plane-app-env-secret'"
echo "     live_env_existingSecret: 'plane-live-env-secret'"
echo ""
echo "4. Remove plaintext passwords from values.yaml"
echo ""

