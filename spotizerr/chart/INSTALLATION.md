# Spotizerr Helm Chart - Quick Start Installation Guide

## Prerequisites

Before installing, ensure you have:
- Kubernetes cluster (version 1.19+) running and accessible
- `kubectl` configured to communicate with your cluster
- Helm 3.0+ installed
- Persistent Volume provisioner in your cluster (for storage)

## Quick Installation

### Step 1: Prepare Your Values File

Create a file named `my-values.yaml` with your configuration:

```yaml
# Required: Add your Spotizerr secrets
spotizerr:
  secrets:
    # Add all your environment variables from .env file here
    SPOTIFY_CLIENT_ID: "your-spotify-client-id"
    SPOTIFY_CLIENT_SECRET: "your-spotify-client-secret"
    # Add any other required environment variables
  
  # Optional: Adjust storage sizes
  persistence:
    downloads:
      size: 50Gi  # Adjust based on your needs

# Required: Set a secure Redis password
redis:
  password: "your-secure-redis-password-here"
```

### Step 2: Install the Chart

```bash
# Navigate to the chart directory
cd spotizerr-helm-chart

# Install the chart
helm install spotizerr . -f my-values.yaml -n spotizerr --create-namespace
```

### Step 3: Verify Installation

```bash
# Check if pods are running
kubectl get pods -n spotizerr

# Watch the deployment
kubectl get pods -n spotizerr -w
```

Expected output:
```
NAME                              READY   STATUS    RESTARTS   AGE
spotizerr-6d8f9b5c7d-x9k2m       1/1     Running   0          2m
spotizerr-redis-7d9f8b6c5d-h4n3k 1/1     Running   0          2m
```

### Step 4: Access Spotizerr

#### Option A: Port Forward (for testing)
```bash
kubectl port-forward -n spotizerr svc/spotizerr 7171:7171
```
Then open your browser to: http://localhost:7171

#### Option B: Using Ingress (for production)

Update `my-values.yaml` to enable Ingress:
```yaml
ingress:
  enabled: true
  className: "nginx"  # or your ingress controller
  hosts:
    - host: spotizerr.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: spotizerr-tls
      hosts:
        - spotizerr.yourdomain.com
```

Upgrade the release:
```bash
helm upgrade spotizerr . -f my-values.yaml -n spotizerr
```

## Verification Steps

### 1. Check All Resources

```bash
# Check all resources in the namespace
kubectl get all -n spotizerr

# Check persistent volume claims
kubectl get pvc -n spotizerr
```

### 2. View Logs

```bash
# Spotizerr application logs
kubectl logs -n spotizerr -l app.kubernetes.io/name=spotizerr -f

# Redis logs
kubectl logs -n spotizerr -l app.kubernetes.io/component=redis -f
```

### 3. Check Service Connectivity

```bash
# Test Redis connectivity
kubectl exec -n spotizerr deploy/spotizerr -- nc -zv spotizerr-redis 6379
```

## Common Configuration Scenarios

### Minimal Installation (for testing)

```yaml
spotizerr:
  secrets:
    SPOTIFY_CLIENT_ID: "test-id"
    SPOTIFY_CLIENT_SECRET: "test-secret"
  persistence:
    data:
      size: 500Mi
    downloads:
      size: 2Gi
    logs:
      size: 500Mi
    cache:
      size: 100Mi

redis:
  password: "test-password"
  persistence:
    size: 500Mi
```

### Production Installation

```yaml
spotizerr:
  image:
    tag: "stable"  # Use a specific tag instead of 'latest'
  
  secrets:
    SPOTIFY_CLIENT_ID: "prod-client-id"
    SPOTIFY_CLIENT_SECRET: "prod-client-secret"
  
  resources:
    limits:
      cpu: 2000m
      memory: 2Gi
    requests:
      cpu: 500m
      memory: 512Mi
  
  persistence:
    storageClassName: "fast-ssd"  # Use your fast storage class
    downloads:
      size: 500Gi

redis:
  existingSecret: "production-redis-secret"  # Use Kubernetes Secret
  persistence:
    storageClassName: "fast-ssd"
    size: 10Gi
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
    requests:
      cpu: 250m
      memory: 256Mi

ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: spotizerr.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: spotizerr-tls
      hosts:
        - spotizerr.example.com

# Node affinity for production workloads
nodeSelector:
  workload-type: applications

# Pod disruption budget consideration
podSecurityContext:
  fsGroup: 1000
  runAsNonRoot: true
```

### Using Existing PersistentVolumeClaims

If you have pre-existing PVCs (useful when migrating from docker-compose or another deployment):

```yaml
spotizerr:
  secrets:
    SPOTIFY_CLIENT_ID: "your-id"
    SPOTIFY_CLIENT_SECRET: "your-secret"
  
  persistence:
    # Use your existing PVCs
    data:
      existingClaim: "spotizerr-data-pvc"
    downloads:
      existingClaim: "spotizerr-downloads-pvc"
    logs:
      existingClaim: "spotizerr-logs-pvc"
    cache:
      existingClaim: "spotizerr-cache-pvc"

redis:
  password: "your-secure-password"
  persistence:
    existingClaim: "redis-data-pvc"
```

**Benefits of using existing PVCs:**
- Preserve data when migrating from another deployment
- Use PVCs created by external storage provisioners
- Maintain data across chart uninstall/reinstall
- Share volumes between different releases (advanced use case)

**Note:** The chart will skip creating PVCs for volumes with `existingClaim` set.

### Using External Redis

If you have an existing Redis instance:

```yaml
redis:
  enabled: false

spotizerr:
  env:
    REDIS_HOST: "external-redis.example.com"
    REDIS_PORT: "6379"
  secrets:
    REDIS_PASSWORD: "external-redis-password"
    SPOTIFY_CLIENT_ID: "your-id"
    SPOTIFY_CLIENT_SECRET: "your-secret"
```

## Upgrading

To upgrade your installation with new configuration:

```bash
# Update your my-values.yaml file with new values
# Then run:
helm upgrade spotizerr . -f my-values.yaml -n spotizerr
```

To upgrade to a new chart version:

```bash
# Pull the latest chart
helm repo update  # if using a helm repository

# Upgrade
helm upgrade spotizerr spotizerr/spotizerr -f my-values.yaml -n spotizerr
```

## Uninstallation

To remove Spotizerr:

```bash
# Uninstall the release
helm uninstall spotizerr -n spotizerr

# Optional: Delete persistent data (WARNING: This deletes all your data!)
kubectl delete pvc -n spotizerr -l app.kubernetes.io/instance=spotizerr

# Optional: Delete the namespace
kubectl delete namespace spotizerr
```

## Troubleshooting

### Pod Not Starting

```bash
# Check pod status and events
kubectl describe pod -n spotizerr -l app.kubernetes.io/name=spotizerr

# Check logs
kubectl logs -n spotizerr -l app.kubernetes.io/name=spotizerr --previous
```

### Storage Issues

```bash
# Check PVC status
kubectl get pvc -n spotizerr

# Describe PVC to see binding issues
kubectl describe pvc -n spotizerr spotizerr-downloads
```

### Redis Connection Issues

```bash
# Check Redis pod
kubectl get pod -n spotizerr -l app.kubernetes.io/component=redis

# Test Redis connectivity
kubectl exec -n spotizerr deploy/spotizerr -- redis-cli -h spotizerr-redis -a $REDIS_PASSWORD ping
```

### Check Configuration

```bash
# View current values
helm get values spotizerr -n spotizerr

# View all manifests
helm get manifest spotizerr -n spotizerr
```

## Advanced Topics

### Backup and Restore

Backup persistent volumes:
```bash
# Create a backup of data PVC
kubectl exec -n spotizerr deploy/spotizerr -- tar czf /tmp/data-backup.tar.gz /app/data

# Copy backup locally
kubectl cp spotizerr/spotizerr-xxxxx-xxxxx:/tmp/data-backup.tar.gz ./data-backup.tar.gz
```

### Monitoring

Add monitoring annotations to your values:
```yaml
podAnnotations:
  prometheus.io/scrape: "true"
  prometheus.io/port: "7171"
  prometheus.io/path: "/metrics"
```

### Security

Use Kubernetes Secrets instead of values.yaml for sensitive data:
```bash
# Create secret
kubectl create secret generic spotizerr-secrets \
  --from-literal=SPOTIFY_CLIENT_ID=xxx \
  --from-literal=SPOTIFY_CLIENT_SECRET=xxx \
  -n spotizerr

# Reference in values.yaml
spotizerr:
  useExternalSecret: true
  externalSecretName: spotizerr-secrets
```

## Support

- Documentation: https://spotizerr.rtfd.io
- Issues: https://github.com/yourusername/spotizerr-helm-chart/issues
- Chart Repository: https://your-helm-repo-url

## Next Steps

1. Configure your application through the web interface
2. Set up automated backups of persistent volumes
3. Configure monitoring and alerting
4. Review security best practices for your cluster
5. Consider setting up GitOps with ArgoCD or Flux for chart management

