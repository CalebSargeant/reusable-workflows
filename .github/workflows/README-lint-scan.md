# Lint Scan - Reusable Workflow

Code quality linting for JavaScript/TypeScript, Kubernetes manifests, Dockerfiles, shell scripts, and GitHub Actions workflows. Separate from security scanning for clear separation of concerns.

> **Note:** This workflow reports quality issues but does **not block PRs by default**. Enable blocking with `fail_on_errors: true`.

## What It Does

| Linter | File Types | Purpose |
|--------|------------|---------|
| **ESLint** | `*.js`, `*.ts`, `*.jsx`, `*.tsx` | JavaScript/TypeScript linting |
| **Kustomize** | `k8s/**`, `kustomization.yaml` | Kubernetes manifest validation |
| **Hadolint** | `Dockerfile*` | Dockerfile best practices |
| **ShellCheck** | `*.sh`, `*.bash`, `*.zsh` | Shell script quality |
| **Actionlint** | `.github/workflows/**` | GitHub Actions best practices |

## Usage

### Basic (Advisory Mode)

```yaml
name: Lint

on:
  pull_request:
    branches: [main]

jobs:
  lint:
    uses: calebsargeant/reusable-workflows/.github/workflows/lint-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
```

Issues are reported as PR annotations but don't block merging.

### Blocking Mode

```yaml
jobs:
  lint:
    uses: calebsargeant/reusable-workflows/.github/workflows/lint-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
    with:
      fail_on_errors: true
```

PR will fail if any lint errors are found.

### With Custom Options

```yaml
jobs:
  lint:
    uses: calebsargeant/reusable-workflows/.github/workflows/lint-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
    with:
      # ESLint options
      node_version: '20'
      eslint_script: 'lint:ci'

      # Kustomize options
      k8s_directory: './kubernetes'
      kubernetes_version: '1.30.0'
      skip_kubescore: true
```

### Combined with Security Scan

```yaml
name: CI

on:
  pull_request:
    branches: [main]

jobs:
  security:
    uses: calebsargeant/reusable-workflows/.github/workflows/security-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
      security-events: write

  lint:
    uses: calebsargeant/reusable-workflows/.github/workflows/lint-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
```

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `runner` | GitHub runner to use | `ubuntu-latest` |
| `fail_on_errors` | Fail workflow on lint errors | `false` |
| `node_version` | Node.js version for ESLint | `22` |
| `eslint_script` | npm script to run for linting | `lint` |
| `k8s_directory` | Directory containing Kustomize files | `./k8s` |
| `kustomize_version` | Kustomize version | `5.8.1` |
| `kubernetes_version` | K8s version for validation | `1.32.0` |
| `skip_kubeconform` | Skip kubeconform validation | `false` |
| `skip_kubescore` | Skip kube-score validation | `false` |

## Outputs

| Output | Description |
|--------|-------------|
| `lint_skipped` | Whether lint was skipped (no relevant files changed) |

## Dynamic Detection

Only runs linters for file types that changed:

```
PR changes:
  - src/app.ts           → ESLint runs
  - k8s/deployment.yaml  → Kustomize lint runs
  - Dockerfile           → Hadolint runs
  - scripts/deploy.sh    → ShellCheck runs
  - .github/workflows/   → Actionlint runs

PR changes:
  - README.md            → All linters skipped
```

## ESLint Requirements

ESLint requires:
1. A `package.json` file in your repo root
2. A `lint` script (or custom script via `eslint_script` input)

Example `package.json`:
```json
{
  "scripts": {
    "lint": "eslint ."
  },
  "devDependencies": {
    "eslint": "^9.0.0"
  }
}
```

## Kustomize Validation

When K8s files change, the workflow:
1. **yamllint** - Validates YAML syntax
2. **kustomize build** - Builds manifests
3. **kubeconform** - Validates against K8s schemas
4. **kube-score** - Checks for best practices

## Ignoring Issues

### ESLint - `.eslintrc` or `eslint.config.js`
Configure rules or use inline comments:
```javascript
// eslint-disable-next-line no-console
console.log('debug');
```

### Kustomize - `.yamllint.yaml`
```yaml
extends: default
rules:
  line-length: disable
```

### Hadolint - `.hadolint.yaml`
```yaml
ignored:
  - DL3008
  - DL3013
```

### ShellCheck - Inline Directives
```bash
# shellcheck disable=SC2034
UNUSED_VAR="intentional"
```

## Example Summary

```
## 🔍 Detected Changes

| File Type | Changed |
|-----------|---------|
| JavaScript/TypeScript | true |
| Kustomize/K8s | true |
| Dockerfile | false |
| Shell Scripts | false |
| GitHub Workflows | false |

## 🧹 Lint Scan Summary

| Check | Status |
|-------|--------|
| ESLint (JavaScript/TypeScript) | ✅ Ran |
| Kustomize/K8s Lint | ✅ Ran |
| Hadolint (Dockerfile) | ⏭️ No Dockerfiles |
| ShellCheck | ⏭️ No shell scripts |
| Actionlint | ⏭️ No workflows |

ℹ️ **Advisory mode:** Lint errors are reported but don't block
```

## Why Separate from Security?

1. **Different purposes:** Security = blocking vulnerabilities, Lint = code quality suggestions
2. **Different urgency:** Security issues must block, lint issues are advisory
3. **Clearer PR status:** See security vs. lint status separately
4. **Flexible enforcement:** Security always blocks, lint is configurable

