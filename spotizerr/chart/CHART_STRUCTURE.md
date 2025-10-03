# Spotizerr Helm Chart - Architecture & Best Practices

## Overview

This document describes the architecture, structure, and best practices implemented in the Spotizerr Helm chart.

## Directory Structure

```
spotizerr-helm-chart/
├── Chart.yaml                  # Chart metadata and version information
├── values.yaml                 # Default configuration values
├── README.md                   # User-facing documentation
├── INSTALLATION.md             # Detailed installation guide
├── CONTRIBUTING.md             # Contribution guidelines
├── LICENSE                     # MIT License
├── .helmignore                 # Files to exclude from packaging
├── templates/                  # Kubernetes manifest templates
│   ├── _helpers.tpl           # Template helper functions
│   ├── deployment.yaml        # Spotizerr application deployment
│   ├── service.yaml           # Spotizerr service
│   ├── serviceaccount.yaml    # Service account
│   ├── secret.yaml            # Application secrets
│   ├── pvc.yaml               # Persistent volume claims (data, downloads, logs, cache)
│   ├── ingress.yaml           # Ingress configuration (optional)
│   ├── redis-deployment.yaml  # Redis deployment
│   ├── redis-service.yaml     # Redis service
│   ├── redis-secret.yaml      # Redis password secret
│   ├── redis-pvc.yaml         # Redis persistent storage
│   └── NOTES.txt              # Post-installation instructions
├── ci/                        # CI/CD configurations
│   └── default-values.yaml    # Values for automated testing
└── .github/                   # GitHub Actions workflows
    └── workflows/
        └── lint-test.yaml     # Chart linting and testing workflow
```

## Helm Best Practices Implemented

### 1. Chart Metadata (Chart.yaml)

**Best Practices Applied:**
- ✅ Uses `apiVersion: v2` (Helm 3 format)
- ✅ Includes descriptive metadata (description, keywords, home)
- ✅ Specifies chart type as `application`
- ✅ Includes maintainer information
- ✅ Uses semantic versioning (1.0.0)
- ✅ Separate appVersion for the application itself

**Why:** Proper metadata makes the chart discoverable and maintainable.

### 2. Values Configuration (values.yaml)

**Best Practices Applied:**
- ✅ Extensive inline documentation via comments
- ✅ Sensible defaults for all configurations
- ✅ Organized hierarchically by component
- ✅ Security-conscious defaults (runAsUser, fsGroup)
- ✅ Resource limits and requests defined
- ✅ Persistent storage enabled by default
- ✅ Health probes configured

**Why:** Well-documented defaults make the chart easy to customize while maintaining security and reliability.

### 3. Template Helpers (_helpers.tpl)

**Best Practices Applied:**
- ✅ Reusable naming functions (fullname, name, chart)
- ✅ Consistent label generation functions
- ✅ Separate helper functions for each component (Redis, Spotizerr)
- ✅ Service account name helper
- ✅ Secret name helpers

**Why:** Template helpers promote DRY (Don't Repeat Yourself) principles and ensure consistency across all resources.

### 4. Labels and Selectors

**Best Practices Applied:**
- ✅ Uses recommended Kubernetes labels:
  - `app.kubernetes.io/name`
  - `app.kubernetes.io/instance`
  - `app.kubernetes.io/version`
  - `app.kubernetes.io/managed-by`
  - `app.kubernetes.io/component` (for multi-component apps)
  - `helm.sh/chart`
- ✅ Consistent selector labels across deployments and services
- ✅ Support for custom labels via `commonLabels`

**Why:** Standard labels enable better operational practices, monitoring, and resource management.

### 5. Security

**Best Practices Applied:**
- ✅ Runs as non-root user (1000:1000)
- ✅ SecurityContext defined at pod and container level
- ✅ fsGroup set for volume permissions
- ✅ Secrets stored in Kubernetes Secret resources
- ✅ Support for existing secrets (Redis)
- ✅ Service accounts created per application

**Why:** Security is paramount in production Kubernetes deployments.

### 6. Resource Management

**Best Practices Applied:**
- ✅ CPU and memory limits defined
- ✅ CPU and memory requests defined
- ✅ Separate resource configurations for each component
- ✅ Conservative defaults that can be scaled up

**Why:** Proper resource management prevents resource contention and enables effective cluster capacity planning.

### 7. Storage

**Best Practices Applied:**
- ✅ Persistent storage enabled by default
- ✅ Separate PVCs for different data types:
  - Data (config, credentials, watch lists, history)
  - Downloads (downloaded files)
  - Logs (application logs)
  - Cache (temporary cache files)
- ✅ Redis persistence enabled by default
- ✅ Configurable storage classes
- ✅ Configurable access modes
- ✅ Appropriate size defaults for each volume

**Why:** Proper storage separation enables better backup strategies, storage class optimization, and data lifecycle management.

### 8. Health Checks

**Best Practices Applied:**
- ✅ Liveness probes configured (HTTP for Spotizerr, TCP for Redis)
- ✅ Readiness probes configured (HTTP for Spotizerr, exec for Redis)
- ✅ Appropriate initial delays and intervals
- ✅ Can be disabled if needed

**Why:** Health checks ensure reliable service availability and automatic recovery from failures.

### 9. Configuration Management

**Best Practices Applied:**
- ✅ Environment variables separated into `env` and `secrets`
- ✅ Secrets base64 encoded automatically
- ✅ ConfigMap pattern available through env vars
- ✅ Redis configuration passed as environment variables
- ✅ Checksum annotations for secrets (triggers rolling update on secret change)

**Why:** Proper configuration management enables secure, auditable deployments.

### 10. Service Exposure

**Best Practices Applied:**
- ✅ ClusterIP as default service type (most secure)
- ✅ Support for NodePort and LoadBalancer
- ✅ Optional Ingress configuration
- ✅ Ingress supports TLS
- ✅ Ingress supports annotations for various controllers
- ✅ Named ports in services

**Why:** Flexible service exposure options support different deployment scenarios.

### 11. Dependency Management

**Best Practices Applied:**
- ✅ Redis as embedded dependency (can be disabled)
- ✅ Redis deployment fully configurable
- ✅ Support for external Redis instances
- ✅ Dependency service discovery via DNS

**Why:** Flexible dependency management supports both simple and complex deployment scenarios.

### 12. Upgradability

**Best Practices Applied:**
- ✅ Rolling update strategy (default)
- ✅ Secret checksums trigger rolling updates
- ✅ Single replica for stateful app (prevents data conflicts)
- ✅ Version pinning support

**Why:** Safe upgrade paths are critical for production stability.

### 13. Observability

**Best Practices Applied:**
- ✅ Support for pod annotations (Prometheus, etc.)
- ✅ Logs accessible via kubectl
- ✅ Standard Kubernetes events
- ✅ Post-install NOTES.txt with helpful commands

**Why:** Observability is essential for production operations.

### 14. Documentation

**Best Practices Applied:**
- ✅ Comprehensive README.md
- ✅ Detailed INSTALLATION.md guide
- ✅ CONTRIBUTING.md for contributors
- ✅ Inline comments in values.yaml
- ✅ Post-install NOTES.txt
- ✅ Examples for common scenarios

**Why:** Good documentation reduces support burden and improves user experience.

### 15. Testing and CI/CD

**Best Practices Applied:**
- ✅ GitHub Actions workflow for automated testing
- ✅ Chart linting in CI
- ✅ Test values for CI environment
- ✅ Minimal resource requirements for testing

**Why:** Automated testing ensures chart quality and prevents regressions.

### 16. Flexibility and Configurability

**Best Practices Applied:**
- ✅ Almost everything is configurable
- ✅ Sane defaults for production use
- ✅ Support for node selectors
- ✅ Support for tolerations
- ✅ Support for affinity rules
- ✅ Configurable probe parameters
- ✅ Image pull secrets support

**Why:** Production environments have diverse requirements that must be accommodated.

## Architecture Decisions

### Why ClusterIP Service Type by Default?

ClusterIP is the most secure option. Users who need external access can:
1. Use port-forwarding for development
2. Enable Ingress for production
3. Change to LoadBalancer if needed

### Why Separate PVCs?

Separate PVCs enable:
- Different storage classes per data type (e.g., fast SSD for data, cheaper storage for logs)
- Independent backup schedules
- Different retention policies
- Better cost optimization

### Why Include Redis?

Redis is a required dependency for Spotizerr. Including it as an embedded deployment:
- Simplifies initial setup
- Provides a working default configuration
- Can be disabled for production if external Redis is preferred

### Why RunAsUser 1000?

Matches the docker-compose configuration, ensuring:
- File permissions work correctly
- No breaking changes for users migrating from Docker
- Non-root user for security

## Template Patterns Used

### 1. Conditional Resource Creation

```yaml
{{- if .Values.redis.enabled }}
# Redis resources only created if enabled
{{- end }}
```

### 2. Loop for Multiple PVCs

```yaml
{{- if .Values.spotizerr.persistence.data.enabled }}
# Create PVC
{{- end }}
```

### 3. Checksum Annotations

```yaml
annotations:
  checksum/secret: {{ include (print $.Template.BasePath "/secret.yaml") . | sha256sum }}
```

Triggers pod restart when secrets change.

### 4. Using Existing Secrets

```yaml
{{- if .Values.redis.existingSecret }}
  # Use existing secret
{{- else }}
  # Create new secret
{{- end }}
```

### 5. Dynamic Environment Variables

```yaml
{{- range $key, $value := .Values.spotizerr.env }}
- name: {{ $key }}
  value: {{ $value | quote }}
{{- end }}
```

## Validation and Testing

### Lint the Chart

```bash
helm lint spotizerr-helm-chart
```

### Template Validation

```bash
helm template spotizerr spotizerr-helm-chart --debug
```

### Dry Run Installation

```bash
helm install spotizerr spotizerr-helm-chart --dry-run --debug
```

### Full Installation Test

```bash
helm install spotizerr spotizerr-helm-chart -f test-values.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=spotizerr --timeout=300s
```

## Maintenance

### Versioning Strategy

- **Chart Version**: Semantic versioning (major.minor.patch)
  - Major: Breaking changes
  - Minor: New features, backward compatible
  - Patch: Bug fixes
- **App Version**: Tracks the Spotizerr application version

### Regular Maintenance Tasks

1. Update appVersion when new Spotizerr releases are available
2. Test with new Kubernetes versions
3. Review and update dependencies
4. Security audits of default configurations
5. Update documentation

## Future Enhancements

Potential improvements for future versions:

1. **StatefulSet Option**: For multi-replica deployments
2. **Horizontal Pod Autoscaler**: For automatic scaling
3. **Pod Disruption Budget**: For high availability
4. **Network Policies**: For enhanced security
5. **Service Mesh Integration**: Istio/Linkerd support
6. **Backup CronJob**: Automated backup solution
7. **Monitoring Dashboard**: Grafana dashboard template
8. **Values Schema**: JSON Schema validation
9. **Sub-charts**: Package Redis as a sub-chart
10. **Helm Tests**: Automated test jobs

## Compliance and Standards

This chart adheres to:
- ✅ Helm Best Practices Guide
- ✅ Kubernetes Resource Best Practices
- ✅ CNCF Security Best Practices
- ✅ 12-Factor App Methodology
- ✅ GitOps-friendly patterns

## References

- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Best Practices](https://kubernetes.io/docs/concepts/configuration/overview/)
- [Artifact Hub Chart Requirements](https://artifacthub.io/docs/topics/repositories/)
- [Spotizerr Documentation](https://spotizerr.rtfd.io)

