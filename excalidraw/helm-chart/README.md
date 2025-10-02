# Excalidraw Complete Helm Chart

A complete Helm chart for deploying Excalidraw with collaboration room server and storage backend on Kubernetes.

## Components

This chart deploys the following components:

1. **Excalidraw Frontend** - The main Excalidraw UI
2. **Excalidraw Room** - WebSocket collaboration server for real-time drawing
3. **Excalidraw Backend** - Storage backend for saving/loading drawings
4. **Nginx** - Reverse proxy to route traffic to the appropriate services
5. **PostgreSQL** - Database for storing drawings (optional, can use external)

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- cert-manager (if using TLS with Let's Encrypt)
- Ingress controller (nginx recommended)

## Installation

### 1. Add PostgreSQL dependency

First, update the Helm dependencies:

```bash
cd /Users/ramzy.sabkhi/personal/tmp/excalidraw-demo/helm-chart
helm dependency update
```

### 2. Customize values

Edit `values.yaml` and update:

- `excalidraw.env.domain` - Your domain name
- `excalidraw.env.httpStorageBackendUrl` - Update with your domain
- `excalidraw.env.backendV2GetUrl` - Update with your domain
- `excalidraw.env.backendV2PostUrl` - Update with your domain
- `excalidraw.env.wsServerUrl` - Update with your domain
- `ingress.hosts` - Your domain configuration
- `ingress.tls` - Your TLS configuration

### 3. Install the chart

```bash
# Create namespace
kubectl create namespace excalidraw

# Install the chart
helm install excalidraw . -n excalidraw
```

Or with custom values:

```bash
helm install excalidraw . -n excalidraw -f custom-values.yaml
```

### 4. Using ArgoCD

If you're using ArgoCD (as shown in your setup), create an Application manifest:

```yaml
---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: excalidraw-complete
  namespace: argocd
spec:
  project: default
  sources:
  - repoURL: <YOUR_GIT_REPO>  # Push this chart to your git repo
    targetRevision: main
    path: helm-chart
    helm:
      releaseName: excalidraw
      valueFiles:
      - $values/excalidraw/values.yaml
  - repoURL: https://github.com/rmsz005/sabkhi_lab_values.git
    targetRevision: main
    ref: values
  destination:
    server: https://kubernetes.default.svc
    namespace: excalidraw
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Configuration

### Key Configuration Options

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of frontend replicas | `2` |
| `excalidraw.image.repository` | Frontend image repository | `excalidraw/excalidraw` |
| `excalidrawRoom.replicaCount` | Number of room server replicas | `2` |
| `excalidrawBackend.replicaCount` | Number of backend replicas | `2` |
| `postgresql.enabled` | Enable built-in PostgreSQL | `true` |
| `postgresql.auth.username` | PostgreSQL username | `excalidraw` |
| `postgresql.auth.password` | PostgreSQL password | `excalidraw` |
| `postgresql.auth.database` | PostgreSQL database name | `excalidraw` |
| `ingress.enabled` | Enable ingress | `true` |
| `ingress.className` | Ingress class name | `nginx` |

### Using External PostgreSQL

To use an external PostgreSQL instance:

```yaml
postgresql:
  enabled: false

externalDatabase:
  host: your-postgres-host
  port: 5432
  user: excalidraw
  password: your-password
  database: excalidraw
```

## Upgrading

To upgrade the chart:

```bash
helm upgrade excalidraw . -n excalidraw
```

## Uninstalling

To remove the chart:

```bash
helm uninstall excalidraw -n excalidraw
```

## Architecture

```
                                    ┌─────────────┐
                                    │   Ingress   │
                                    │   (nginx)   │
                                    └──────┬──────┘
                                           │
                                    ┌──────▼──────┐
                                    │    Nginx    │
                                    │   Proxy     │
                                    └──────┬──────┘
                                           │
                    ┌──────────────────────┼──────────────────────┐
                    │                      │                      │
             ┌──────▼──────┐        ┌─────▼──────┐        ┌─────▼──────┐
             │  Excalidraw │        │ Excalidraw │        │ Excalidraw │
             │   Frontend  │        │    Room    │        │   Backend  │
             └─────────────┘        │(WebSocket) │        └─────┬──────┘
                                    └────────────┘              │
                                                          ┌─────▼──────┐
                                                          │ PostgreSQL │
                                                          └────────────┘
```

## Troubleshooting

### Check pod status

```bash
kubectl get pods -n excalidraw
```

### View logs

```bash
# Frontend logs
kubectl logs -n excalidraw -l app.kubernetes.io/component=frontend

# Room server logs
kubectl logs -n excalidraw -l app.kubernetes.io/component=room

# Backend logs
kubectl logs -n excalidraw -l app.kubernetes.io/component=backend

# Nginx logs
kubectl logs -n excalidraw -l app.kubernetes.io/component=nginx
```

### Common Issues

1. **Cannot save drawings**: Check backend and PostgreSQL connectivity
   ```bash
   kubectl logs -n excalidraw -l app.kubernetes.io/component=backend
   kubectl get pods -n excalidraw | grep postgres
   ```

2. **Collaboration not working**: Check room server and websocket configuration
   ```bash
   kubectl logs -n excalidraw -l app.kubernetes.io/component=room
   ```

3. **Ingress not working**: Verify ingress controller and cert-manager
   ```bash
   kubectl get ingress -n excalidraw
   kubectl describe ingress -n excalidraw excalidraw-complete
   ```

## Development

To build custom excalidraw image (optional):

1. Clone the excalidraw repo inside the images directory
2. Build using the Dockerfile:
   ```bash
   docker build -t my/excalidraw:latest -f images/Dockerfile.excalidraw images/
   ```

## License

This Helm chart is open source. Excalidraw itself is licensed under MIT.

