# Docker Bake to GHCR - Reusable Workflow

Reusable GitHub Actions workflow for building multi-platform Docker images using docker-bake and pushing to GitHub Container Registry (GHCR).

## Features

- 🐳 **Docker Bake support** - Build complex multi-image projects with docker-bake.hcl
- 🏗️ **Multi-platform builds** - Default support for linux/amd64 and linux/arm64
- 🚀 **GitHub Actions cache** - Fast builds using GitHub Actions cache
- 🏷️ **Smart versioning** - Automatic version detection from tags, releases, branches, and PRs
- 📦 **GHCR optimized** - Defaults to ghcr.io with GITHUB_TOKEN authentication
- 🔒 **Optional SBOM** - Generate Software Bill of Materials for security scanning
- 📊 **Job summaries** - Clear build output with pull commands

## Usage

### Basic Example

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']

jobs:
  build:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    permissions:
      contents: read
      packages: write
    with:
      image_name: my-app
      bake_target: my-app
    secrets:
      registry_password: ${{ secrets.GITHUB_TOKEN }}
```

### Advanced Example

```yaml
name: Docker Build

on:
  push:
    branches: [main]
    tags: ['v*']
  pull_request:
  workflow_dispatch:
    inputs:
      version:
        description: 'Version tag'
        type: string

jobs:
  build:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    permissions:
      contents: read
      packages: write
      id-token: write
    with:
      bake_file: docker-bake.hcl
      bake_target: app
      push_target: app-push
      image_name: my-app
      platforms: linux/amd64,linux/arm64,linux/arm/v7
      push: ${{ github.event_name != 'pull_request' }}
      runner: ubuntu-latest
      enable_sbom: true
    secrets:
      registry_password: ${{ secrets.GITHUB_TOKEN }}
```

## Inputs

| Input | Description | Required | Default |
|-------|-------------|----------|---------|
| `bake_file` | Path to docker-bake file | No | `docker-bake.hcl` |
| `bake_target` | Docker Bake target to build | No | `default` |
| `push_target` | Separate target for push (if different) | No | `''` |
| `image_name` | Image name without registry/org prefix | **Yes** | - |
| `platforms` | Target platforms (comma-separated) | No | `linux/amd64,linux/arm64` |
| `push` | Push images to registry | No | `true` |
| `registry` | Container registry URL | No | `ghcr.io` |
| `runner` | GitHub runner to use | No | `ubuntu-latest` |
| `enable_sbom` | Generate and upload SBOM | No | `false` |

## Secrets

| Secret | Description | Required |
|--------|-------------|----------|
| `registry_username` | Registry username (defaults to github.actor) | No |
| `registry_password` | Registry password/token | No* |

*Required for pushing, defaults to `secrets.GITHUB_TOKEN`

## Docker Bake File Requirements

Your `docker-bake.hcl` should define variables that the workflow will populate:

```hcl
variable "REGISTRY" {
  default = "ghcr.io"
}

variable "IMAGE_NAME" {
  default = "owner/image"
}

variable "VERSION" {
  default = "latest"
}

variable "PLATFORMS" {
  default = "linux/amd64,linux/arm64"
}

target "app" {
  context    = "."
  dockerfile = "Dockerfile"
  tags = [
    "${REGISTRY}/${IMAGE_NAME}:${VERSION}",
    "${REGISTRY}/${IMAGE_NAME}:latest"
  ]
  platforms = split(",", PLATFORMS)
}

target "app-push" {
  inherits = ["app"]
  output   = ["type=registry"]
}
```

## Version Detection

The workflow automatically determines the version tag:

| Event | Version |
|-------|---------|
| Push to main/master | `latest` |
| Tag push (v*) | Tag name (e.g., `v1.2.3`) |
| Release | Release tag name |
| Pull request | `pr-<number>` |
| Other branches | Branch name (/ replaced with -) |
| Manual dispatch | Input version or `latest` |

## Image Tags

The workflow generates multiple tags using docker/metadata-action:

- `latest` (on main branch)
- `<version>` (from version detection)
- `<branch>` (on branch pushes)
- `pr-<number>` (on PRs)
- `<branch>-<sha>` (git commit SHA)
- Semver variants: `1.2.3`, `1.2`, `1` (on semver tags)

## Permissions Required

```yaml
permissions:
  contents: read        # Clone repository
  packages: write       # Push to GHCR
  id-token: write       # Optional: OIDC authentication
  pull-requests: read   # Required for auto-promotion on release events
```

**Note:** When using `auto_promote_on_release: true` (the default) with release events, the workflow needs `pull-requests: read` permission to extract the PR number from the release commit history.

## Environment Variables

The workflow sets these environment variables for docker-bake:

- `VERSION` - Detected version string
- `REGISTRY` - Registry URL (e.g., ghcr.io)
- `IMAGE_NAME` - Full image name (owner/image)
- `PLATFORMS` - Platform list

## Cache Strategy

- Uses GitHub Actions cache (`type=gha`)
- Scoped per workflow for isolation
- Mode: `max` for maximum cache coverage
- Separate cache for each workflow/branch combination

## SBOM Generation

When `enable_sbom: true`:

1. Generates SPDX-format SBOM using Anchore
2. Uploads as workflow artifact
3. Retention: 90 days
4. Only runs on successful pushes (not PRs)

## Examples

### Monorepo with Multiple Images

```yaml
jobs:
  api:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    with:
      image_name: api
      bake_target: api
    secrets:
      registry_password: ${{ secrets.GITHUB_TOKEN }}

  web:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    with:
      image_name: web
      bake_target: web
    secrets:
      registry_password: ${{ secrets.GITHUB_TOKEN }}
```

### Custom Registry

```yaml
jobs:
  build:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    with:
      image_name: my-app
      registry: registry.example.com
    secrets:
      registry_username: ${{ secrets.REGISTRY_USER }}
      registry_password: ${{ secrets.REGISTRY_TOKEN }}
```

### PR Builds Without Push

```yaml
jobs:
  build:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    with:
      image_name: my-app
      push: false  # Just build, don't push
```

## Troubleshooting

### "cannot parse bake definitions" error

Ensure your docker-bake.hcl uses variables correctly:
- Use `${VARIABLE}` syntax for substitution
- Don't use GitHub Actions expressions in the bake file
- Variables are passed via environment, not inline

### Push fails with authentication error

Check that:
1. `permissions.packages: write` is set
2. `secrets.registry_password` is provided (or defaults to GITHUB_TOKEN)
3. Repository package permissions allow the workflow

### Cache not working

- Caches are scoped per workflow name
- Check if you're using custom runners with cache limitations
- Verify GitHub Actions cache quota hasn't been exceeded

## Related Workflows

- [semantic-release.yaml](./semantic-release.yaml) - Automated versioning
- [terragrunt-plan-cost-apply.yaml](./terragrunt-plan-cost-apply.yaml) - Infrastructure deployment
