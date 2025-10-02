# Excalidraw Complete Deployment

Complete Excalidraw setup with collaboration features for sabkhi_lab cluster.

## Components

- **Excalidraw Frontend**: Main drawing UI
- **Excalidraw Room**: WebSocket server for real-time collaboration
- **Excalidraw Backend**: REST API for persistent storage
- **Nginx**: Reverse proxy for routing
- **PostgreSQL**: Database for storing drawings

## Files

- `helm-chart/`: Complete Helm chart for excalidraw stack
- `values.yaml`: Configuration values
- `postgresql.yaml`: PostgreSQL deployment manifest

## Deployment

The deployment is managed by ArgoCD with two applications:

1. **excalidraw-storage**: Deploys PostgreSQL
2. **excalidraw**: Deploys the complete excalidraw stack

### Prerequisites

- Existing nginx ingress controller ✓
- cert-manager for TLS ✓
- Storage class `longhorn-ssd-replicated` ✓

### Install

The applications are already configured in the gitops repo and will auto-deploy when you push:

```bash
# Push both repos
cd /Users/ramzy.sabkhi/personal/sabkhi_lab/sabkhi_lab_values
git add excalidraw/
git commit -m "Add excalidraw complete setup"
git push

cd /Users/ramzy.sabkhi/personal/sabkhi_lab/sabkhi_lab_gitops
git add apps/excalidraw*.yaml
git commit -m "Add excalidraw ArgoCD applications"
git push
```

### Verify

```bash
# Check ArgoCD apps
kubectl get application -n argocd | grep excalidraw

# Check pods
kubectl get pods -n excalidraw

# Check ingress
kubectl get ingress -n excalidraw
```

### Access

URL: https://excalidraw.internal.rmsz005.com

## Configuration

### Database Connection

Currently using dedicated PostgreSQL deployed via `postgresql.yaml`:
- Host: `excalidraw-postgresql`
- Database: `excalidraw`
- User: `excalidraw`
- Storage: 5Gi on longhorn-ssd-replicated

### Resource Allocation

- Frontend: 256Mi-512Mi RAM, 100m-500m CPU, 2 replicas
- Room: 128Mi-256Mi RAM, 50m-200m CPU, 2 replicas
- Backend: 128Mi-256Mi RAM, 50m-200m CPU, 2 replicas
- Nginx: 64Mi-128Mi RAM, 50m-200m CPU, 1 replica
- PostgreSQL: 256Mi-512Mi RAM, 100m-500m CPU, 1 replica

Total: ~1.5Gi RAM minimum

## Customization

Edit `values.yaml` to customize:

- Domain name and URLs
- Replica counts
- Resource limits
- External PostgreSQL (if not using bundled)

## Security

**TODO**: Move PostgreSQL password to sealed secret

```bash
# Create sealed secret (example)
kubectl create secret generic excalidraw-postgresql-secret \
  --from-literal=password='your-secure-password' \
  --namespace=excalidraw \
  --dry-run=client -o yaml | \
  kubeseal --format=yaml > excalidraw-postgresql-secret.yaml
```

Then update `postgresql.yaml` to use the secret.

## Troubleshooting

### Backend can't connect to database

```bash
# Check PostgreSQL
kubectl get pod -n excalidraw -l app=excalidraw-postgresql
kubectl logs -n excalidraw -l app=excalidraw-postgresql

# Check backend logs
kubectl logs -n excalidraw -l app.kubernetes.io/component=backend
```

### Collaboration not working

```bash
# Check room server
kubectl logs -n excalidraw -l app.kubernetes.io/component=room

# Check nginx routing
kubectl logs -n excalidraw -l app.kubernetes.io/component=nginx
```

### Storage issues

```bash
# Check PVC
kubectl get pvc -n excalidraw

# Check Longhorn
kubectl get volumeattachment
```

