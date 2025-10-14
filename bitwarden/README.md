# Bitwarden Self-Hosted Deployment

Bitwarden password manager deployed via Helm and ArgoCD.

## Architecture

- **Chart**: Official Bitwarden Helm chart (v2025.9.2)
- **Values**: `values.yaml` - Production configuration
- **ArgoCD**: Two applications:
  - `bitwarden-storage` - PostgreSQL and PVCs
  - `bitwarden` - Main Bitwarden application
- **Namespace**: `bitwarden`

## Access

Once deployed:
- **URL**: https://bitwarden.internal.rmsz005.com
- **Admin Email**: ramzy.sabkhi@gmail.com
- **Registration**: Disabled (admin-only)

## Storage

### Database (PostgreSQL 16)
- **PVC**: `bitwarden-postgresql-pvc`
- **Size**: 10Gi
- **Storage Class**: `longhorn-ssd-replicated`
- **Access Mode**: ReadWriteOnce

### Attachments
- **PVC**: `bitwarden-attachments-pvc`
- **Size**: 10Gi
- **Storage Class**: `longhorn-hd-replicated`
- **Access Mode**: ReadWriteMany

## Configuration

### Email (SMTP)
- **Provider**: Brevo (smtp-relay.brevo.com)
- **Port**: 587 (STARTTLS)
- **From Address**: bitwarden@rmsz005.com

### Security
- **Registration**: Admin-only (disabled for public)
- **TLS**: Let's Encrypt via cert-manager
- **Secrets**: Managed via Sealed Secrets

## Setup Instructions

### 1. Generate Sealed Secrets

Run the secret generator script:

```bash
cd /Users/ramzy.sabkhi/personal/sabkhi_lab/sabkhi_lab_values/bitwarden
./SECRET_TEMPLATE.sh
```

This will:
- Generate PostgreSQL credentials
- Create sealed secrets
- Output files to `/tmp/`

**IMPORTANT**: Save the PostgreSQL password shown in the output!

### 2. Copy Secrets to Secrets Repo

```bash
# Copy sealed secrets
cp /tmp/bitwarden-sealed-secrets.yaml ~/personal/sabkhi_lab/sabkhi_lab_secrets/
cp /tmp/bitwarden-postgresql-sealed-secret.yaml ~/personal/sabkhi_lab/sabkhi_lab_secrets/

# Commit and push
cd ~/personal/sabkhi_lab/sabkhi_lab_secrets
git add bitwarden-sealed-secrets.yaml bitwarden-postgresql-sealed-secret.yaml
git commit -m "Add Bitwarden sealed secrets"
git push
```

### 3. Deploy via GitOps

```bash
# Commit configuration files
cd ~/personal/sabkhi_lab/sabkhi_lab_values
git add bitwarden/ bitwarden_storage/
git commit -m "Add Bitwarden configuration"
git push

# Commit ArgoCD applications
cd ~/personal/sabkhi_lab/sabkhi_lab_gitops
git add apps/bitwarden-storage-application.yaml apps/bitwarden-application.yaml
git commit -m "Add Bitwarden ArgoCD applications"
git push
```

### 4. Monitor Deployment

```bash
# Watch ArgoCD sync
kubectl get applications -n argocd | grep bitwarden

# Watch pods
kubectl get pods -n bitwarden -w

# Check logs if issues
kubectl logs -n bitwarden -l app.kubernetes.io/component=web
```

### 5. First Login

1. Visit https://bitwarden.internal.rmsz005.com
2. Click "Create Account"
3. Use admin email: `ramzy.sabkhi@gmail.com`
4. Set your master password (SAVE THIS SECURELY!)
5. Verify email (check your Gmail)

## Backup Strategy

- **Database**: Longhorn snapshots + external backup
- **Attachments**: Longhorn snapshots
- **Recommendation**: Configure Longhorn backup to external drive

## Troubleshooting

### Database Connection Issues

```bash
# Check PostgreSQL pod
kubectl get pods -n bitwarden -l app=bitwarden-postgresql

# Check logs
kubectl logs -n bitwarden -l app=bitwarden-postgresql

# Test connection
kubectl exec -n bitwarden -it deployment/bitwarden-postgresql -- psql -U bitwarden -d vault
```

### Email Not Working

```bash
# Check API pod logs
kubectl logs -n bitwarden -l app.kubernetes.io/component=api | grep -i mail

# Test SMTP manually
kubectl run -n bitwarden curl-test --rm -it --image=curlimages/curl -- sh
```

### Ingress Issues

```bash
# Check ingress
kubectl get ingress -n bitwarden

# Check certificate
kubectl get certificate -n bitwarden

# Check cert-manager logs
kubectl logs -n cert-manager -l app=cert-manager
```

## Security Notes

- ✅ Registration disabled for public
- ✅ Admin-only account creation
- ✅ TLS encryption (Let's Encrypt)
- ✅ Secrets stored as Sealed Secrets
- ✅ Database credentials auto-generated
- ⚠️  No cloud sync (self-hosted only)
- ⚠️  Backup responsibility is yours

## Maintenance

### Update Bitwarden

ArgoCD will auto-update when you bump chart version in application manifest:

```yaml
# bitwarden-application.yaml
targetRevision: 2025.X.X  # Update this
```

### Database Maintenance

```bash
# Backup database manually
kubectl exec -n bitwarden deployment/bitwarden-postgresql -- \
  pg_dump -U bitwarden vault > bitwarden-backup-$(date +%Y%m%d).sql

# Restore database
kubectl exec -i -n bitwarden deployment/bitwarden-postgresql -- \
  psql -U bitwarden vault < bitwarden-backup-20250114.sql
```

## Resources

- [Bitwarden Helm Chart](https://github.com/bitwarden/helm-charts)
- [Bitwarden Help Center](https://bitwarden.com/help/)
- [Self-Hosting Guide](https://bitwarden.com/help/self-host-with-helm/)

