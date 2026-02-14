# Kustomize Linting Workflow

A reusable GitHub Actions workflow for linting and validating Kubernetes Kustomize configurations with automatic change detection.

## Features

- **Smart Change Detection**: Only runs linting when files in the k8s directory change
- **Automatic Pass on No Changes**: CI check succeeds without running linting if no changes detected
- **Configurable k8s Directory**: Specify custom path to your Kubernetes/Kustomize files
- **Multiple Validation Tools**:
  - YAML linting with `yamllint`
  - Kustomize build validation
  - Kubernetes schema validation with `kubeconform`
  - Best practices validation with `kube-score`
- **Flexible Configuration**: Enable/disable specific validation steps
- **Version Control**: Specify Kustomize and Kubernetes versions

## Usage

### Basic Setup

Create a workflow file in your repository (e.g., `.github/workflows/kustomize-ci.yml`):

```yaml
name: Kustomize CI

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  lint:
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
```

### Custom Configuration

```yaml
name: Kustomize CI

on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]

jobs:
  lint:
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      k8s_directory: './kubernetes/manifests'
      kustomize_version: 'v5.0.0'
      kubernetes_version: '1.28.0'
      strict_validation: true
      skip_kubescore: false
```

### Advanced Multi-Environment Setup

For projects with multiple environments (dev, staging, prod):

```yaml
name: Kustomize CI

on:
  pull_request:
  push:
    branches: [main, develop, staging]

jobs:
  lint-dev:
    if: github.ref == 'refs/heads/develop' || github.base_ref == 'develop'
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      k8s_directory: './k8s/overlays/dev'
      kubernetes_version: '1.28.0'

  lint-staging:
    if: github.ref == 'refs/heads/staging' || github.base_ref == 'staging'
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      k8s_directory: './k8s/overlays/staging'
      kubernetes_version: '1.30.0'

  lint-prod:
    if: github.ref == 'refs/heads/main' || github.base_ref == 'main'
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      k8s_directory: './k8s/overlays/prod'
      kubernetes_version: '1.32.0'
      strict_validation: true
```

## Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `runner` | The GitHub runner to use | No | `ubuntu-latest` |
| `k8s_directory` | Directory containing Kustomize files | No | `./k8s` |
| `kustomize_version` | Kustomize version to use | No | `latest` |
| `kubernetes_version` | Kubernetes version for validation | No | `1.32.0` |
| `skip_kubeconform` | Skip kubeconform validation | No | `false` |
| `skip_kubescore` | Skip kube-score validation | No | `false` |
| `strict_validation` | Enable strict validation in kubeconform | No | `true` |

## How It Works

### 1. Change Detection

The workflow uses [`dorny/paths-filter`](https://github.com/dorny/paths-filter) to detect if any files in the configured `k8s_directory` have changed:

- **For Pull Requests**: Compares changes against the PR base branch
- **For Pushes**: Compares to the previous commit
- **Result**: If no changes detected, the workflow passes without running linting

### 2. Linting Steps

When changes are detected, the workflow runs the following steps:

1. **YAML Linting**: Validates YAML syntax using `yamllint`
2. **Kustomize Build**: Builds all Kustomize manifests to ensure they compile correctly
3. **Schema Validation**: Validates Kubernetes resources against OpenAPI schemas using `kubeconform`
4. **Best Practices**: Checks for Kubernetes best practices using `kube-score`

### 3. Success Check

A final job aggregates the results:
- **Passes** if no changes were detected
- **Passes** if all linting steps succeeded
- **Fails** if linting steps failed

## Validation Tools

### yamllint

Checks YAML files for:
- Syntax errors
- Indentation issues
- Line length violations
- Trailing spaces

### kubeconform

Validates Kubernetes manifests against:
- Kubernetes OpenAPI schemas
- Custom Resource Definitions (CRDs)
- Ensures resources are valid for the target Kubernetes version

### kube-score

Analyzes manifests for best practices:
- Resource limits and requests
- Security contexts
- Health checks (liveness/readiness probes)
- Pod disruption budgets
- Label and annotation conventions

## Repository Structure

Your repository should have a structure like:

```
your-repo/
├── k8s/                    # Default directory (configurable)
│   ├── base/
│   │   ├── kustomization.yaml
│   │   ├── deployment.yaml
│   │   └── service.yaml
│   └── overlays/
│       ├── dev/
│       │   └── kustomization.yaml
│       ├── staging/
│       │   └── kustomization.yaml
│       └── prod/
│           └── kustomization.yaml
└── .github/
    └── workflows/
        └── kustomize-ci.yml
```

## Common Use Cases

### Skip Specific Validations

If you want to skip certain validation steps:

```yaml
jobs:
  lint:
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      skip_kubescore: true  # Skip best practices check
      skip_kubeconform: false  # Still run schema validation
```

### Disable Strict Validation

For development or migration scenarios:

```yaml
jobs:
  lint:
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      strict_validation: false  # Allow some schema violations
```

### Pin Specific Versions

For reproducible builds:

```yaml
jobs:
  lint:
    uses: CalebSargeant/reusable-workflows/.github/workflows/kustomize-lint.yaml@main
    with:
      kustomize_version: 'v5.3.0'
      kubernetes_version: '1.28.0'
```

## Troubleshooting

### No kustomization.yaml found

**Error**: "No Kustomize manifests were built"

**Solution**: Ensure your k8s directory contains at least one `kustomization.yaml` or `kustomization.yml` file.

### Schema validation failures

**Error**: Kubeconform reports schema validation errors

**Solutions**:
- Check that your `kubernetes_version` matches your target cluster version
- Set `strict_validation: false` to allow minor schema violations
- Set `skip_kubeconform: true` to skip schema validation entirely

### YAML linting issues

**Issue**: yamllint reports formatting issues

**Solution**: 
- Fix the YAML formatting issues
- The workflow continues even with yamllint warnings

### kube-score warnings

**Issue**: kube-score reports missing best practices

**Solution**:
- Address the best practice recommendations
- Set `skip_kubescore: true` if you want to skip these checks

## Requirements

- Repository must have a valid Kustomize structure
- `kustomization.yaml` (or `.yml`) files must exist in the configured directory
- GitHub Actions must be enabled in your repository

## Permissions

The workflow requires the following permissions:
- `contents: read` - To checkout the repository
- `pull-requests: read` - To detect changes in pull requests

## Examples

See the repository workflows for examples:
- [Basic Example](../../../examples/kustomize-basic.yml)
- [Multi-Environment Example](../../../examples/kustomize-multi-env.yml)

## Related Workflows

- [Terragrunt Plan/Apply](./terragrunt-plan-cost-apply.yaml) - Infrastructure as Code workflow
- [Docker Bake to GHCR](./docker-bake-ghcr.yaml) - Container image building
- [MkDocs Pages](./mkdocs-pages.yml) - Documentation deployment

## References

- [Kustomize Documentation](https://kustomize.io/)
- [kubeconform](https://github.com/yannh/kubeconform)
- [kube-score](https://github.com/zegl/kube-score)
- [dorny/paths-filter](https://github.com/dorny/paths-filter)
