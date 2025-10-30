# Homarr DB Encryption Secret

## Required Secret

Homarr requires a `db-encryption` secret with a random encryption key.

## Steps to Create

### 1. Generate a random encryption key (32+ characters)

```bash
# Generate a secure random key
openssl rand -base64 32
```

### 2. Create the plain secret

```bash
cat > /tmp/homarr-db-encryption.yaml << EOF
apiVersion: v1
kind: Secret
metadata:
  name: db-encryption
  namespace: homarr
type: Opaque
stringData:
  db-encryption-key: "YOUR_GENERATED_KEY_HERE"
EOF
```

### 3. Seal the secret

```bash
kubeseal --controller-name=sealed-secrets \
  --controller-namespace=kube-system \
  --format=yaml \
  < /tmp/homarr-db-encryption.yaml \
  > ~/personal/sabkhi_lab_secrets/homarr-db-encryption-sealed.yaml
```

### 4. Apply the sealed secret

```bash
kubectl apply -f ~/personal/sabkhi_lab_secrets/homarr-db-encryption-sealed.yaml
```

### 5. Verify the secret was unsealed

```bash
kubectl get secret db-encryption -n homarr
```

### 6. Clean up temporary file

```bash
rm /tmp/homarr-db-encryption.yaml
```

## After Creating Secret

Once the secret is created, you can deploy Homarr via ArgoCD:

```bash
# Commit and push the manifests
cd ~/personal/sabkhi_lab/sabkhi_lab_values
git add homarr/
git commit -m "Add Homarr configuration"
git push

cd ~/personal/sabkhi_lab/sabkhi_lab_gitops
git add apps/homarr-application.yaml
git commit -m "Add Homarr ArgoCD application"
git push
```

## Backup the Encryption Key

**CRITICAL:** Store the encryption key securely! Without it, you cannot decrypt your Homarr database.

Add it to your password manager or secure backup location.

