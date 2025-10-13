# Spotizerr Deployment

Spotizerr is a Spotify download automation tool deployed via Helm chart and ArgoCD.

## Architecture

- **Chart Location**: This directory contains the Helm chart
- **Values**: `spotizerr-values.yaml` - Production configuration for sabkhi_lab
- **ArgoCD**: Application manifest in `sabkhi_lab_gitops/apps/spotizerr-application.yaml`
- **Namespace**: `spotizerr`

## Access

Once deployed, Spotizerr will be available at:
- **URL**: https://spotizerr.internal.rmsz005.com
- **Internal**: http://spotizerr.spotizerr.svc.cluster.local:7171

## Storage

Spotizerr uses 5 persistent volumes:
1. **Data** (1Gi) - Config, credentials, watch lists, history
2. **Downloads** (50Gi) - Downloaded music files
3. **Logs** (2Gi) - Application logs
4. **Cache** (500Mi) - Temporary cache
5. **Redis Data** (2Gi) - Redis persistence

All volumes use `longhorn-ssd-replicated` storage class.

## Configuration

### Environment Variables

Key settings in `spotizerr-values.yaml`:
- `LOG_LEVEL`: INFO
- `EXPLICIT_FILTER`: false (allows explicit content)
- `ENABLE_AUTH`: false (single-user mode by default)
- `SSO_ENABLED`: false

### Authentication (Optional)

To enable multi-user mode:
1. Set `ENABLE_AUTH: "true"` in `spotizerr-values.yaml`
2. Create a sealed-secret with:
   - `JWT_SECRET`: Long random string for token signing
   - `DEFAULT_ADMIN_PASSWORD`: Admin password (username is 'admin')
3. Push changes and let ArgoCD sync

### Secrets Management

Secrets are managed via Bitnami Sealed Secrets. To create secrets:

```bash
# Create a secret file
kubectl create secret generic spotizerr-secrets \
  --from-literal=JWT_SECRET='your-long-random-secret' \
  --from-literal=DEFAULT_ADMIN_PASSWORD='your-admin-password' \
  --from-literal=REDIS_PASSWORD='your-redis-password' \
  --namespace spotizerr \
  --dry-run=client -o yaml > spotizerr-secret.yaml

# Seal the secret
kubeseal --format=yaml < spotizerr-secret.yaml > spotizerr-sealed-secret.yaml

# Add to sabkhi_lab_secrets repo and commit
```

### Redis Configuration

Redis is deployed as a sidecar with:
- Persistence enabled
- Password protected (set via sealed-secret)
- AOF (Append-Only File) enabled for durability

## Monitoring

Health checks:
- **Liveness**: HTTP GET / every 10s (starts after 60s)
- **Readiness**: HTTP GET / every 5s (starts after 30s)

## Resource Allocation

**Spotizerr**:
- Requests: 500m CPU, 512Mi RAM
- Limits: 2000m CPU, 2Gi RAM

**Redis**:
- Requests: 250m CPU, 256Mi RAM
- Limits: 1000m CPU, 1Gi RAM

## Troubleshooting

### Check Pod Status
```bash
kubectl get pods -n spotizerr
```

### View Logs
```bash
# Spotizerr logs
kubectl logs -n spotizerr -l app.kubernetes.io/name=spotizerr -f

# Redis logs
kubectl logs -n spotizerr -l app.kubernetes.io/component=redis -f
```

### Access Shell
```bash
kubectl exec -it -n spotizerr deploy/spotizerr -- /bin/sh
```

### Check Persistence
```bash
kubectl get pvc -n spotizerr
```

### Check Ingress
```bash
kubectl get ingress -n spotizerr
```

### Force Sync
```bash
argocd app sync spotizerr
```

## Updating

The deployment uses `Always` image pull policy for the `latest` tag. To update:

1. **Manual Update**: Delete the pod to pull latest image
   ```bash
   kubectl delete pod -n spotizerr -l app.kubernetes.io/name=spotizerr
   ```

2. **Configuration Changes**: Update `spotizerr-values.yaml` and commit
   - ArgoCD will auto-sync within minutes

3. **Chart Changes**: Update chart files and commit
   - ArgoCD will auto-sync within minutes

## Data Migration from Docker Compose

If migrating from docker-compose:

1. Copy data to PVCs:
```bash
# Get pod name
POD=$(kubectl get pod -n spotizerr -l app.kubernetes.io/name=spotizerr -o jsonpath='{.items[0].metadata.name}')

# Copy data
kubectl cp ./data $POD:/app/data -n spotizerr
kubectl cp ./downloads $POD:/app/downloads -n spotizerr
```

2. Or use existing PVCs:
```yaml
spotizerr:
  persistence:
    data:
      existingClaim: "spotizerr-data-pvc"
    downloads:
      existingClaim: "spotizerr-downloads-pvc"
```

## Links

- **Documentation**: https://spotizerr.rtfd.io
- **Docker Hub**: https://hub.docker.com/r/cooldockerizer93/spotizerr
- **Chart Source**: This directory
