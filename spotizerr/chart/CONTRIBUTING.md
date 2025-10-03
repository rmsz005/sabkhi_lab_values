# Contributing to Spotizerr Helm Chart

Thank you for your interest in contributing to the Spotizerr Helm Chart!

## Development Setup

### Prerequisites

- Kubernetes cluster (local via Kind, Minikube, or k3s)
- Helm 3.0+
- kubectl

### Local Testing

1. Clone the repository:
```bash
git clone https://github.com/yourusername/spotizerr-helm-chart.git
cd spotizerr-helm-chart
```

2. Lint the chart:
```bash
helm lint .
```

3. Template the chart to verify output:
```bash
helm template test-release . --debug
```

4. Install the chart locally:
```bash
helm install spotizerr . -f ci/default-values.yaml
```

5. Test the installation:
```bash
kubectl get pods -l app.kubernetes.io/name=spotizerr
helm test spotizerr
```

## Making Changes

### Chart Structure

Follow Helm best practices:
- Use `_helpers.tpl` for reusable template definitions
- Keep templates simple and readable
- Document all values in `values.yaml` with comments
- Use semantic versioning for chart versions
- Update `Chart.yaml` version when making changes

### Testing Changes

1. Run lint checks:
```bash
helm lint .
```

2. Test template rendering:
```bash
helm template . --debug > /tmp/output.yaml
```

3. Validate Kubernetes manifests:
```bash
helm template . | kubectl apply --dry-run=client -f -
```

### Commit Guidelines

- Write clear, descriptive commit messages
- Reference issue numbers when applicable
- Keep commits focused and atomic
- Follow conventional commits format:
  - `feat:` for new features
  - `fix:` for bug fixes
  - `docs:` for documentation changes
  - `chore:` for maintenance tasks

## Pull Request Process

1. Fork the repository
2. Create a feature branch from `main`
3. Make your changes
4. Test thoroughly
5. Update documentation if needed
6. Submit a pull request

### PR Checklist

- [ ] Chart lints successfully (`helm lint`)
- [ ] Templates render correctly (`helm template`)
- [ ] Installation works on test cluster
- [ ] Documentation updated (README.md, values.yaml comments)
- [ ] Chart version bumped in Chart.yaml
- [ ] CHANGELOG updated (if applicable)

## Code Review

All submissions require review. We use GitHub pull requests for this purpose.

## Release Process

Releases are managed by maintainers:
1. Update version in `Chart.yaml`
2. Update `CHANGELOG.md`
3. Create a git tag
4. Package and publish to chart repository

## Questions?

Feel free to open an issue for any questions or concerns.

## Code of Conduct

Be respectful and constructive in all interactions.

