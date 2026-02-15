# Security Scan - Reusable Workflow

Minimal, fast security scanning with dynamic language detection. Only runs the scans needed based on what files actually changed.

> **✅ Works in Private Repos:** All scanners are free and work without commercial licenses.

## Design Philosophy

- **Fast by default** - Only 2 core scans always run (~1-2 min)
- **Dynamic detection** - Language-specific scans run automatically when those files change
- **Caller-controlled** - Heavy scans (SAST, IaC) must be explicitly enabled

## What Runs

### Core Scans (Always Run)
| Scan | Tool | Time | Purpose |
|------|------|------|---------|
| Vulnerability Scan | Trivy | ~30s | CVEs in dependencies |
| Secret Detection | TruffleHog | ~30s | Leaked credentials |
| SAST | Semgrep | ~1-2 min | Security bugs in code |

### Dynamic Scans (Auto-Detected)
These run **only if** the relevant files changed:

| Scan | Tool | Triggers On | Time |
|------|------|-------------|------|
| pip-audit | PyPA | `*.py`, `requirements.txt`, `pyproject.toml` | ~20s |
| npm/yarn/pnpm audit | Node.js | `*.js`, `*.ts`, `package.json`, `*.lock` | ~20s |
| govulncheck | Go Team | `*.go`, `go.mod` | ~30s |
| Hadolint | Hadolint | `Dockerfile*`, `docker-compose*.yml` | ~10s |
| ShellCheck | ShellCheck | `*.sh`, `*.bash`, `*.zsh` | ~10s |
| Actionlint | Actionlint | `.github/workflows/**` | ~10s |
| Checkov | Bridgecrew | `*.tf`, `*.yaml`, `k8s/**`, `helm/**` | ~1 min |

### Optional Scans (Caller Must Enable)
| Scan | Tool | Input | Time |
|------|------|-------|------|
| License Check | Trivy | `enable_license_scan: true` | ~30s |

## Usage

### Basic (Minimal, Fast)

```yaml
name: Security

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
```

This runs:
- ✅ Trivy (CVEs)
- ✅ TruffleHog (secrets)
- ✅ Semgrep SAST (code security)
- ✅ Any language-specific scans based on changed files


### With IaC Scanning (Terraform/Kubernetes)

Checkov runs automatically when IaC files are detected. No configuration needed!

To skip specific checks:
```yaml
jobs:
  security:
    uses: calebsargeant/reusable-workflows/.github/workflows/security-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
      security-events: write
    with:
      checkov_skip_checks: 'CKV_DOCKER_2,CKV_K8S_21'
```

### With License Scanning

```yaml
jobs:
  security:
    uses: calebsargeant/reusable-workflows/.github/workflows/security-scan.yaml@main
    permissions:
      contents: read
      pull-requests: read
      security-events: write
    with:
      enable_license_scan: true
```

## Inputs

| Input | Description | Default |
|-------|-------------|---------|
| `runner` | GitHub runner | `ubuntu-latest` |
| `trivy_severity` | Severity levels | `CRITICAL,HIGH` |
| `trivy_exit_code` | Exit code on findings | `1` (fail) |
| `trivy_ignore_unfixed` | Ignore unfixed CVEs | `true` |
| `trivyignore_file` | Path to .trivyignore (only used if exists) | `.trivyignore` |
| `gitleaks_baseline` | Path to TruffleHog exclude file (only used if exists) | `''` |
| `semgrep_baseline` | Path to .semgrepignore (auto-detected) | `''` |
| `enable_sast` | Enable Semgrep SAST | `true` |
| `enable_license_scan` | Enable license scan | `false` |
| `semgrep_config` | Semgrep rules | `p/default p/security-audit p/secrets` |
| `checkov_skip_checks` | Checkov checks to skip | `''` |

## Ignoring Pre-Existing Vulnerabilities

If your project has existing vulnerabilities you can't fix immediately, use baseline/ignore files to prevent new vulnerabilities while tracking known ones.

> **Note:** All ignore files are **optional**. The workflow checks if each file exists before using it - missing files won't cause errors.

### Trivy (CVEs) - `.trivyignore`

Create `.trivyignore` in your repo root:

```
# Ignore specific CVEs
CVE-2023-12345
CVE-2023-67890

# Ignore by package
pkg:npm/lodash@4.17.20
pkg:pypi/requests@2.25.0

# Comments are supported
# This CVE is a false positive for our use case
CVE-2024-11111
```

### TruffleHog (Secrets) - `.trufflehogignore`

Create `.trufflehogignore` to exclude paths:

```
# Ignore test fixtures
tests/fixtures/
test_data/

# Ignore specific files with known false positives
config/example.env
docs/api-examples.md
```

Then reference it:
```yaml
with:
  gitleaks_baseline: '.trufflehogignore'
```

### Semgrep (SAST) - `.semgrepignore`

Create `.semgrepignore` in your repo root:

```
# Ignore test files
tests/
*_test.py
*.test.js

# Ignore vendored code
vendor/
third_party/

# Ignore specific files
legacy/old_code.py
```

The file follows `.gitignore` syntax.

### Checkov (IaC) - Skip Checks

Use the `checkov_skip_checks` input:

```yaml
with:
  checkov_skip_checks: 'CKV_DOCKER_2,CKV_K8S_21,CKV_AWS_123'
```

Or add inline comments in your IaC files:

```hcl
# checkov:skip=CKV_AWS_123:This is intentionally public
resource "aws_s3_bucket" "public" {
  # ...
}
```

```yaml
# Kubernetes deployment
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    checkov.io/skip: "CKV_K8S_21=Using host network intentionally"
```

### Hadolint (Dockerfile) - `.hadolint.yaml`

Create `.hadolint.yaml` in your repo root:

```yaml
ignored:
  - DL3008  # Pin versions in apt-get
  - DL3013  # Pin versions in pip
  - DL4006  # Set SHELL option

trustedRegistries:
  - docker.io
  - gcr.io
```

### ShellCheck - Inline Directives

Add directives in your shell scripts:

```bash
#!/bin/bash

# shellcheck disable=SC2034  # Variable appears unused
UNUSED_VAR="intentional"

# shellcheck disable=SC2086  # Double quote to prevent globbing
ls $FILES
```

### npm audit - `.nsprc` or `package.json`

Create `.nsprc`:
```json
{
  "exceptions": [
    "https://github.com/advisories/GHSA-xxxx-xxxx-xxxx"
  ]
}
```

Or in `package.json`:
```json
{
  "auditIgnore": {
    "advisories": [1234, 5678]
  }
}
```

### pip-audit - Inline Ignores

Currently pip-audit doesn't support ignore files, but Trivy covers Python CVEs and uses `.trivyignore`.

### govulncheck - No Ignore Support

govulncheck doesn't support ignoring vulnerabilities. Use Trivy's `.trivyignore` for Go CVEs.

## Summary of Ignore Files

| Scanner | Ignore File | Format |
|---------|-------------|--------|
| Trivy | `.trivyignore` | CVE IDs, one per line |
| TruffleHog | `.trufflehogignore` | Paths, gitignore syntax |
| Semgrep | `.semgrepignore` | Paths, gitignore syntax |
| Checkov | Input or inline | Check IDs |
| Hadolint | `.hadolint.yaml` | YAML config |
| ShellCheck | Inline | `# shellcheck disable=SCXXXX` |
| npm audit | `.nsprc` | JSON advisories |

## Dynamic Detection

The workflow automatically detects what languages/files changed and runs the appropriate scanners:

```
PR changes:
  - src/main.py          → pip-audit runs
  - Dockerfile           → Hadolint runs
  - .github/workflows/   → Actionlint runs

PR changes:
  - src/app.ts           → npm audit runs
  - package.json         → npm audit runs

PR changes:
  - cmd/server/main.go   → govulncheck runs
  - scripts/deploy.sh    → ShellCheck runs

PR changes:
  - terraform/main.tf    → Checkov runs
  - k8s/deployment.yaml  → Checkov runs

PR changes:
  - README.md            → Only core scans (Trivy + TruffleHog + Semgrep)
```

## Example Summary Output

```
## 🔍 Detected Changes

| Language/Type | Changed |
|---------------|---------|
| Python | true |
| JavaScript/TypeScript | true |
| Go | false |
| Dockerfile | true |
| Shell Scripts | false |
| GitHub Workflows | true |
| IaC (Terraform/K8s) | false |

## 🔒 Security Scan Summary

### Core Scans (always run)
| Check | Status |
|-------|--------|
| Trivy Vulnerability Scan | ✅ Completed |
| TruffleHog Secret Detection | ✅ Completed |
| Semgrep SAST | ✅ Completed |

### Dynamic Scans (based on detected files)
| Check | Status |
|-------|--------|
| pip-audit (Python) | ✅ Ran |
| npm audit (JavaScript) | ✅ Ran |
| Hadolint (Dockerfile) | ✅ Ran |
| Actionlint | ✅ Ran |

### Optional Scans (caller-enabled)
| Check | Status |
|-------|--------|
| License Scan | ⏭️ Not enabled |
```

## Performance

| Scenario | Time |
|----------|------|
| Minimal (docs only) | ~2 min |
| Python PR | ~2.5 min |
| JavaScript/Node.js PR | ~2.5 min |
| Go PR | ~3 min |
| Terraform PR | ~3 min |
| With License scan | +30s |

## Required Permissions

```yaml
permissions:
  contents: read
  pull-requests: read
  security-events: write
```

## Branch Protection

1. **Settings** → **Branches** → **Add rule**
2. Enable **Require status checks**
3. Add **Security Scan**

## Troubleshooting

### Scan Skipped
The workflow detects that no relevant files changed. This is expected for documentation-only PRs.

### Pre-Existing Vulnerabilities Blocking PRs
If you have known vulnerabilities you can't fix yet, add them to the appropriate ignore file:

1. **CVEs:** Add to `.trivyignore`
2. **Secrets:** Add paths to `.trufflehogignore` and pass via `gitleaks_baseline`
3. **Code issues:** Add paths to `.semgrepignore`
4. **IaC issues:** Use `checkov_skip_checks` input or inline comments

See "Ignoring Pre-Existing Vulnerabilities" section above.

### Checkov Too Noisy
Skip specific checks:
```yaml
with:
  checkov_skip_checks: 'CKV_DOCKER_2,CKV_K8S_21'
```

### Want to Track Known Issues
Keep a record of ignored vulnerabilities in your repo's SECURITY.md or create a `security-baseline.md` documenting why each item is ignored and when it should be reviewed.
