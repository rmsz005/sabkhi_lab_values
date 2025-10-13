# Spotizerr Helm Chart

A Helm chart for deploying [Spotizerr](https://spotizerr.rtfd.io) on Kubernetes.

## Overview

Spotizerr is a Spotify download automation tool. This Helm chart provides a production-ready deployment on Kubernetes, including:

- Spotizerr application deployment
- Redis for caching and session management
- Persistent storage for data, downloads, logs, and cache
- Configurable resource limits
- Optional Ingress support
- Health checks and probes

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- PersistentVolume provisioner support in the underlying infrastructure

## Installation

### Add the Helm Repository (if published)

```bash
helm repo add spotizerr https://your-helm-repo-url
helm repo update
```

### Install from Local Chart

```bash
helm install spotizerr ./spotizerr-helm-chart
```

### Install with Custom Values

1. Copy the default values file:
```bash
cp values.yaml my-values.yaml
```

2. Edit `my-values.yaml` with your configuration:
```yaml
spotizerr:
  secrets:
    SPOTIFY_CLIENT_ID: "your-client-id"
    SPOTIFY_CLIENT_SECRET: "your-client-secret"
    # Add other environment variables from your .env file

redis:
  password: "your-secure-password"
```

3. Install the chart:
```bash
helm install spotizerr ./spotizerr-helm-chart -f my-values.yaml
```

## Configuration

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `spotizerr.image.repository` | Spotizerr image repository | `cooldockerizer93/spotizerr` |
| `spotizerr.image.tag` | Spotizerr image tag | `latest` |
| `spotizerr.service.type` | Kubernetes service type | `ClusterIP` |
| `spotizerr.service.port` | Service port | `7171` |
| `spotizerr.persistence.enabled` | Enable persistent storage | `true` |
| `spotizerr.persistence.data.size` | Data volume size | `1Gi` |
| `spotizerr.persistence.data.existingClaim` | Use existing PVC for data | `""` |
| `spotizerr.persistence.downloads.size` | Downloads volume size | `10Gi` |
| `spotizerr.persistence.downloads.existingClaim` | Use existing PVC for downloads | `""` |
| `spotizerr.persistence.logs.size` | Logs volume size | `1Gi` |
| `spotizerr.persistence.logs.existingClaim` | Use existing PVC for logs | `""` |
| `spotizerr.persistence.cache.size` | Cache volume size | `100Mi` |
| `spotizerr.persistence.cache.existingClaim` | Use existing PVC for cache | `""` |
| `spotizerr.resources.limits.cpu` | CPU limit | `1000m` |
| `spotizerr.resources.limits.memory` | Memory limit | `1Gi` |
| `redis.enabled` | Enable Redis deployment | `true` |
| `redis.password` | Redis password | `changeme` |
| `redis.persistence.enabled` | Enable Redis persistence | `true` |
| `redis.persistence.size` | Redis volume size | `1Gi` |
| `redis.persistence.existingClaim` | Use existing PVC for Redis | `""` |
| `ingress.enabled` | Enable Ingress | `false` |

### Environment Variables

Add your application environment variables under `spotizerr.secrets`:

```yaml
spotizerr:
  secrets:
    SPOTIFY_CLIENT_ID: "your-client-id"
    SPOTIFY_CLIENT_SECRET: "your-client-secret"
    # Add all variables from your .env file
```

For non-sensitive variables, use `spotizerr.env`:

```yaml
spotizerr:
  env:
    LOG_LEVEL: "info"
```

### Storage Configuration

The chart creates four persistent volumes:

1. **Data** (`/app/data`): Configuration, credentials, watch lists, history
2. **Downloads** (`/app/downloads`): Downloaded files
3. **Logs** (`/app/logs`): Application logs
4. **Cache** (`/app/.cache`): Cache files

To customize storage:

```yaml
spotizerr:
  persistence:
    storageClassName: "fast-ssd"  # Use your storage class
    data:
      size: 5Gi
    downloads:
      size: 100Gi
```

#### Using Existing PersistentVolumeClaims

If you have pre-existing PVCs, you can use them instead of creating new ones:

```yaml
spotizerr:
  persistence:
    data:
      existingClaim: "my-existing-data-pvc"
    downloads:
      existingClaim: "my-existing-downloads-pvc"
    logs:
      existingClaim: "my-existing-logs-pvc"
    cache:
      existingClaim: "my-existing-cache-pvc"

redis:
  persistence:
    existingClaim: "my-existing-redis-pvc"
```

**Note:** When using `existingClaim`, the chart will not create a new PVC, and the `size`, `accessMode`, and `storageClassName` settings for that volume will be ignored.

### Ingress Configuration

To expose Spotizerr externally:

```yaml
ingress:
  enabled: true
  className: "nginx"
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  hosts:
    - host: spotizerr.example.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: spotizerr-tls
      hosts:
        - spotizerr.example.com
```

### Redis Configuration

#### Using Built-in Redis

```yaml
redis:
  enabled: true
  password: "secure-password"
  persistence:
    enabled: true
    size: 2Gi
```

#### Using External Redis

```yaml
redis:
  enabled: false

spotizerr:
  env:
    REDIS_HOST: "external-redis.example.com"
    REDIS_PORT: "6379"
  secrets:
    REDIS_PASSWORD: "external-redis-password"
```

## Upgrading

```bash
helm upgrade spotizerr ./spotizerr-helm-chart -f my-values.yaml
```

## Uninstalling

```bash
helm uninstall spotizerr
```

**Note:** This will not delete the PersistentVolumeClaims. To delete them:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=spotizerr
```

## Security Considerations

1. **Change default Redis password** in production
2. Store sensitive values in Kubernetes Secrets:
   ```bash
   kubectl create secret generic spotizerr-secrets \
     --from-literal=SPOTIFY_CLIENT_ID=xxx \
     --from-literal=SPOTIFY_CLIENT_SECRET=xxx
   ```

3. Use `existingSecret` for Redis:
   ```yaml
   redis:
     existingSecret: "my-redis-secret"
     existingSecretPasswordKey: "password"
   ```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=spotizerr
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/name=spotizerr -f
```

### Check Persistent Volumes

```bash
kubectl get pvc -l app.kubernetes.io/instance=spotizerr
```

### Access Application

```bash
kubectl port-forward svc/spotizerr 7171:7171
```

Then visit: http://localhost:7171

## Values Reference

For a complete list of configuration options, see [values.yaml](values.yaml).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This Helm chart is open source and available under the [MIT License](LICENSE).

## Links

- [Spotizerr Documentation](https://spotizerr.rtfd.io)
- [Docker Image](https://hub.docker.com/r/cooldockerizer93/spotizerr)
- [Issue Tracker](https://github.com/yourusername/spotizerr-helm-chart/issues)

