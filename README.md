# Sabkhi Lab - Helm Values Repository

This repository contains Helm values and Kubernetes manifests for all applications deployed in the Sabkhi homelab cluster via ArgoCD.

## 📁 Repository Structure

```
sabkhi_lab_values/
├── infrastructure/          # Core cluster components
│   ├── argocd/             # ArgoCD configuration
│   ├── cert-manager/       # TLS certificate management
│   ├── longhorn/           # Distributed storage
│   ├── metallb/            # Load balancer
│   ├── sealed-secrets/     # Secrets encryption
│   └── storage/            # Persistent volume claims
│       ├── immich-storage/
│       ├── music-storage/
│       └── spotizerr-storage/
│
├── platform/               # Platform services & operators
│   ├── operators/          # Kubernetes operators
│   │   ├── eck-operator/   # Elastic Cloud on Kubernetes
│   │   ├── kyverno/        # Policy engine
│   │   └── vpa/            # Vertical Pod Autoscaler
│   └── observability/      # Monitoring, logging, metrics
│       ├── monitoring/     # Prometheus + Grafana
│       ├── loki/           # Log aggregation
│       ├── promtail/       # Log collection
│       ├── elasticsearch/  # Search engine
│       ├── kibana/         # Elasticsearch UI
│       ├── goldilocks/     # Resource recommendations
│       └── policy-reporter/# Kyverno reporting
│
├── security/               # Security & compliance
│   ├── falco/              # Runtime security
│   ├── kyverno-policies/   # Security policies
│   └── rbac/               # Role-based access control
│       └── readonly/       # Read-only cluster access
│
├── applications/           # User-facing applications
│   ├── media/              # Media management
│   │   ├── immich/         # Photo management
│   │   ├── navidrome/      # Music streaming
│   │   └── spotizerr/      # Spotify downloader
│   └── automation/
│       └── n8n/            # Workflow automation
│
├── tools/                  # Development & testing tools
│   ├── benchmark-operator/ # Performance testing
│   └── librespeed/         # Network speed test
│
├── _archived/              # Deprecated/testing apps
│   └── hello-world/        # Testing application
│
├── scripts/                # Helper scripts
├── renovate.json           # Renovate dependency updates
└── README.md               # This file
```

## 🎯 Purpose

This repository follows GitOps best practices by:
- ✅ Organizing apps by function (infrastructure, platform, security, applications)
- ✅ Consolidating storage manifests in one place
- ✅ Separating system components from user applications
- ✅ Making it easy to find and manage configurations
- ✅ Enabling RBAC and access control by directory
- ✅ Preserving full Git history for all changes

## 🚀 Usage

### Adding a New Application

1. Determine the category (infrastructure, platform, security, applications, tools)
2. Create a new directory under the appropriate category:
   ```bash
   mkdir -p applications/media/new-app
   ```
3. Add your Helm values or manifests:
   ```bash
   # For Helm charts
   touch applications/media/new-app/values.yaml
   
   # For raw manifests
   touch applications/media/new-app/deployment.yaml
   ```
4. Create corresponding ArgoCD Application in `sabkhi_lab_gitops`

### Updating Values

1. Edit the appropriate values file
2. Commit and push
3. ArgoCD automatically syncs within 3 minutes

### Storage Management

All PVC/storage manifests are consolidated under `infrastructure/storage/`:
```bash
infrastructure/storage/
├── immich-storage/         # Immich photo storage
├── music-storage/          # Navidrome music library
└── spotizerr-storage/      # Spotizerr download cache
```

## 🔄 Dependency Management

This repository uses [Renovate](https://docs.renovatebot.com/) to automatically:
- Monitor container image tags
- Create pull requests for updates
- Group minor/major/patch updates
- Schedule updates for weekends

See `renovate.json` for configuration.

## 📊 Categories Explained

### Infrastructure
Core cluster functionality that everything else depends on:
- Networking (MetalLB)
- Storage (Longhorn)
- Security (cert-manager, sealed-secrets)
- GitOps (ArgoCD)

### Platform
Platform services that support applications:
- **Operators**: Automate management of complex applications
- **Observability**: Monitoring, logging, and metrics

### Security
Security, compliance, and access control:
- Runtime security (Falco)
- Policy enforcement (Kyverno)
- RBAC configurations

### Applications
User-facing applications:
- **Media**: Photo/music management
- **Automation**: Workflow tools

### Tools
Development and testing utilities

## 🔗 Related Repositories

- **GitOps Repo**: [sabkhi_lab_gitops](https://github.com/rmsz005/sabkhi_lab_gitops) - ArgoCD Application manifests
- **Cluster Repo**: (Private) - Kubernetes cluster configuration

## 📖 Documentation

- [Migration Guide](../MIGRATION_GUIDE.md) - How this structure was created
- [Reorganization Plan](../REORGANIZATION_PLAN.md) - Design decisions
- [Renovate Setup](../RENOVATE_SETUP.md) - Dependency management

## 🤝 Contributing

When adding new applications:
1. Follow the directory structure
2. Use descriptive names
3. Include README in complex app directories
4. Test with `helm template` or `kubectl apply --dry-run`

## 📝 Notes

- Git history is fully preserved (all moves done with `git mv`)
- Storage manifests should go in `infrastructure/storage/`
- Helm values files should be named `values.yaml`
- Raw manifests can use any descriptive name
