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
- 🔄 **PR Build → Promote pattern** - Build once in PR, promote to release tag on merge (no rebuild)

## Workflow Patterns

### Standard Pattern

Build on every push/tag:

```
Push to main/tag → Build container → Push with version tag
```

### PR Build → Semantic Release → Promote Pattern

Efficient workflow that avoids rebuilding after merge:

```
PR Created/Updated
       ↓
Container built and tagged with pr-<number>
       ↓
PR Merged → semantic-release creates release tag
       ↓
Promote: retag the container with the semantic-release version
```

This pattern uses the `promote_pr_number` input to skip the build and instead retag the already-tested PR image. See [Examples](#pr-build--semantic-release--promote-pattern) for implementation details.

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
| `promote_pr_number` | Skip build and promote `pr-<number>` image to the calculated version | No | `''` |
| `force_version` | Force specific version tag (overrides automatic detection) | No | `''` |
| `registry` | Container registry URL | No | `ghcr.io` |
| `runner` | GitHub runner to use | No | `ubuntu-latest` |
| `enable_sbom` | Generate and upload SBOM | No | `false` |
| `buildx_vars` | Additional environment variables for docker/bake-action in KEY=VALUE format, one per line | No | `''` |

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
  contents: read      # Clone repository
  packages: write     # Push to GHCR
  id-token: write     # Optional: OIDC authentication
```

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

### PR Build → Semantic Release → Promote Pattern

This pattern enables an efficient workflow where:
1. **PR Created/Updated** → Container is built and tagged with `pr-<number>`
2. **PR Merged** → semantic-release creates a release tag
3. **After Release** → The PR image is promoted (retagged) to the semantic-release version

This avoids rebuilding the container after merge by reusing the already-tested PR image.

#### Step 1: Create PR Build Workflow

Create `.github/workflows/docker-pr.yaml`:

```yaml
name: Docker PR Build

on:
  pull_request:
    types: [opened, synchronize, reopened]

jobs:
  build:
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    permissions:
      contents: read
      packages: write
    with:
      image_name: my-app
      bake_target: my-app
      # PR builds are automatically tagged as pr-<number>
```

#### Step 2: Create Release + Promote Workflow

Create `.github/workflows/release.yaml`:

```yaml
name: Release

on:
  pull_request:
    types: [closed]

jobs:
  # Only run on merged PRs
  semantic-release:
    if: github.event.pull_request.merged == true
    uses: calebsargeant/reusable-workflows/.github/workflows/semantic-release.yaml@main
    permissions:
      contents: write
      id-token: write
    secrets:
      SEMANTIC_RELEASE_APP_ID: ${{ secrets.SEMANTIC_RELEASE_APP_ID }}
      SEMANTIC_RELEASE_APP_PRIVATE_KEY: ${{ secrets.SEMANTIC_RELEASE_APP_PRIVATE_KEY }}

  # Promote the PR image to the release version
  promote-container:
    needs: semantic-release
    if: needs.semantic-release.outputs.released == 'true'
    uses: calebsargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    permissions:
      contents: read
      packages: write
    with:
      image_name: my-app
      bake_target: my-app
      # This reuses the pr-<number> image and tags it with the new version
      promote_pr_number: ${{ github.event.pull_request.number }}
      force_version: ${{ needs.semantic-release.outputs.version }}
```

#### How It Works

1. When a PR is opened/updated, the `docker-pr.yaml` workflow builds and pushes the container tagged as `pr-123`
2. When the PR is merged, the `release.yaml` workflow:
   - Runs semantic-release to determine and create the new version (e.g., `v1.2.0`)
   - Promotes the `pr-123` image by retagging it to `v1.2.0` using `docker buildx imagetools create`
3. No rebuild is required - the exact same image that was tested in the PR is now tagged with the release version

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
