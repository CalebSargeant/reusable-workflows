# Copier Template Guide

This repository serves as a Copier template for setting up GitHub Actions workflows that reference the reusable workflows in this repository as a single source of truth.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [Usage](#usage)
- [Configuration Options](#configuration-options)
- [Workflow Templates](#workflow-templates)
- [GHES Support](#ghes-support)
- [Updating Templates](#updating-templates)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)

## Overview

Copier is a library for rendering project templates. This template allows you to:

1. Generate GitHub Actions workflow files that call reusable workflows from this repository
2. Maintain a single source of truth for workflow logic
3. Easily update multiple repositories when workflows change
4. Customize workflows per repository while keeping core logic centralized

## Installation

### Install Copier

Choose one of the following methods:

**Using pip:**
```bash
pip install copier
```

**Using pipx (recommended):**
```bash
pipx install copier
```

**Using uv:**
```bash
uv tool install copier
```

### Verify Installation

```bash
copier --version
```

## Usage

### Basic Usage

1. Navigate to your destination repository:
```bash
cd /path/to/your/repository
```

2. Run Copier to generate workflows from the latest version:
```bash
copier copy gh:CalebSargeant/reusable-workflows .
```

3. Answer the interactive prompts to configure your workflows.

**For the latest stable release:**
```bash
copier copy --vcs-ref=v1.0.28 gh:CalebSargeant/reusable-workflows .
```

**For the latest development version:**
```bash
copier copy --vcs-ref=main gh:CalebSargeant/reusable-workflows .
```

### Non-Interactive Usage

You can also provide answers via command-line arguments:

```bash
copier copy \
  --data github_org=myorg \
  --data github_repo=my-repo \
  --data setup_mkdocs=true \
  --data setup_terragrunt=true \
  --data include_readme=true \
  gh:CalebSargeant/reusable-workflows .
```

### Using a Specific Version

Reference a specific branch or tag:

```bash
# Use a specific tag
copier copy gh:CalebSargeant/reusable-workflows --vcs-ref=v1.0.0 .

# Use a specific branch
copier copy gh:CalebSargeant/reusable-workflows --vcs-ref=staging .
```

## Configuration Options

### Required Options

| Option | Description | Example |
|--------|-------------|---------|
| `github_org` | GitHub organization or username | `myorg` |
| `github_repo` | Repository name (without org) | `my-repo` |

### Workflow Selection

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `setup_mkdocs` | bool | `false` | Enable MkDocs documentation workflow |
| `setup_terragrunt` | bool | `false` | Enable Terragrunt infrastructure workflow |
| `setup_docker_bake` | bool | `false` | Enable Docker Bake workflow |
| `setup_semantic_release` | bool | `false` | Enable Semantic Release workflow |
| `setup_server_notifications` | bool | `false` | Enable server update notifications |

### Source Configuration

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `source_repo` | str | `CalebSargeant/reusable-workflows` | Source repository for reusable workflows |
| `source_branch` | str | `main` | Branch/tag to reference |

### MkDocs Options

Only asked when `setup_mkdocs` is `true`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `mkdocs_python_version` | str | `3.x` | Python version for MkDocs |
| `mkdocs_working_directory` | str | `.` | MkDocs working directory |

### Terragrunt Options

Only asked when `setup_terragrunt` is `true`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `terragrunt_working_dir` | str | `./terraform` | Terragrunt working directory |
| `terragrunt_aws_region` | str | `us-east-1` | AWS region |
| `terragrunt_enable_infracost` | bool | `true` | Enable Infracost cost estimation |

### Docker Options

Only asked when `setup_docker_bake` is `true`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `docker_registry` | str | `ghcr.io` | Container registry |
| `docker_image_name` | str | - | Docker image name |

### Server Notifications Options

Only asked when `setup_server_notifications` is `true`:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `slack_channel_id` | str | - | Slack channel ID for notifications |

### GHES Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `is_ghes` | bool | `false` | Deploy to GitHub Enterprise Server |
| `ghes_hostname` | str | - | GHES hostname (only if `is_ghes` is true) |

### Additional Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `include_readme` | bool | `true` | Include WORKFLOWS-README.md |

## Workflow Templates

### Generated Workflow Files

Depending on your selections, the following workflow files may be generated:

1. **`.github/workflows/mkdocs.yml`** - MkDocs documentation build and deployment
2. **`.github/workflows/terragrunt.yml`** - Terragrunt infrastructure management
3. **`.github/workflows/docker.yml`** - Docker image build and push
4. **`.github/workflows/semantic-release.yml`** - Automated versioning
5. **`.github/workflows/server-notifications.yml`** - Server update notifications

### Generated Documentation

- **`WORKFLOWS-README.md`** - Comprehensive setup guide for the generated workflows

### Configuration Tracking

- **`.copier-answers.yml`** - Stores your configuration for future updates

## GHES Support

### Using with GitHub Enterprise Server

When generating workflows for GHES:

1. Set `is_ghes` to `true`
2. Provide your GHES hostname (e.g., `github.mycompany.com`)
3. Ensure the source repository is accessible from your GHES instance

### GHES Considerations

- **Repository Access**: The reusable workflows repository must be accessible from your GHES instance
- **Marketplace Actions**: Some GitHub Marketplace actions may not be available on GHES
- **Custom References**: You may need to fork the reusable workflows to your GHES instance

### Example GHES Setup

```bash
copier copy \
  --data github_org=myorg \
  --data github_repo=my-repo \
  --data is_ghes=true \
  --data ghes_hostname=github.mycompany.com \
  --data source_repo=myorg/reusable-workflows \
  gh:CalebSargeant/reusable-workflows .
```

## Updating Templates

### Update Existing Configuration

To update workflows with the latest template changes:

```bash
cd /path/to/your/repository
copier update
```

This will:
1. Pull the latest template version
2. Re-render templates with your saved configuration
3. Show you a diff of changes
4. Allow you to review and accept/reject changes

### Reconfigure Workflows

To change your configuration:

```bash
copier update --force
```

This will:
1. Re-ask all configuration questions
2. Allow you to change your answers
3. Regenerate all workflow files

### Update to a Specific Version

```bash
copier update --vcs-ref=v2.0.0
```

## Advanced Usage

### Using with CI/CD

You can automate template updates in CI/CD:

```yaml
name: Update Workflows

on:
  schedule:
    - cron: '0 0 * * 0'  # Weekly on Sunday
  workflow_dispatch:

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Install Copier
        run: pipx install copier
      
      - name: Update template
        run: copier update --force
      
      - name: Create Pull Request
        uses: peter-evans/create-pull-request@v6
        with:
          title: 'chore: update workflow templates'
          branch: update-workflow-templates
```

### Pre-commit Hook

Add a pre-commit hook to ensure templates are up to date:

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/copier-org/copier
    rev: v9.0.0
    hooks:
      - id: copier-forbidden-files
```

### Dry Run

Preview what would be generated without actually creating files:

```bash
copier copy --force --pretend gh:CalebSargeant/reusable-workflows .
```

## Troubleshooting

### Common Issues

#### 1. Copier Command Not Found

**Problem**: `copier: command not found`

**Solution**: Install Copier using one of the installation methods above.

#### 2. Permission Denied

**Problem**: Cannot write files to the current directory

**Solution**: Ensure you have write permissions in the target directory.

#### 3. Template Version Mismatch

**Problem**: Error about incompatible Copier version

**Solution**: Update Copier:
```bash
pip install --upgrade copier
# or
pipx upgrade copier
```

#### 4. Workflows Not Working After Generation

**Problem**: Generated workflows fail

**Solution**: 
- Check that all required secrets are configured
- Verify that the source repository is accessible
- Review the WORKFLOWS-README.md for setup requirements

#### 5. GHES Repository Access

**Problem**: Cannot access reusable workflows from GHES

**Solution**:
- Fork the reusable-workflows repository to your GHES instance
- Update the `source_repo` configuration to point to your fork

### Getting Help

- **Template Issues**: Open an issue at https://github.com/CalebSargeant/reusable-workflows/issues
- **Copier Documentation**: https://copier.readthedocs.io/
- **GitHub Actions**: https://docs.github.com/en/actions

## Best Practices

1. **Version Control**: Always commit `.copier-answers.yml` to track your configuration
2. **Regular Updates**: Run `copier update` regularly to get workflow improvements
3. **Review Changes**: Always review diffs before accepting template updates
4. **Test Workflows**: Test generated workflows in a branch before merging
5. **Document Customizations**: If you manually modify generated workflows, document the changes
6. **Use Tags**: Reference specific template versions in production repositories

## Example Configurations

### Documentation Site

```bash
copier copy \
  --data github_org=myorg \
  --data github_repo=docs \
  --data setup_mkdocs=true \
  --data mkdocs_working_directory=. \
  --data include_readme=true \
  gh:CalebSargeant/reusable-workflows .
```

### Infrastructure Repository

```bash
copier copy \
  --data github_org=myorg \
  --data github_repo=infrastructure \
  --data setup_terragrunt=true \
  --data terragrunt_working_dir=./terraform \
  --data terragrunt_enable_infracost=true \
  --data include_readme=true \
  gh:CalebSargeant/reusable-workflows .
```

### Application Repository

```bash
copier copy \
  --data github_org=myorg \
  --data github_repo=my-app \
  --data setup_docker_bake=true \
  --data docker_image_name=my-app \
  --data setup_semantic_release=true \
  --data include_readme=true \
  gh:CalebSargeant/reusable-workflows .
```

### Full Stack Repository

```bash
copier copy \
  --data github_org=myorg \
  --data github_repo=fullstack-app \
  --data setup_docker_bake=true \
  --data setup_semantic_release=true \
  --data setup_mkdocs=true \
  --data docker_image_name=fullstack-app \
  --data include_readme=true \
  gh:CalebSargeant/reusable-workflows .
```

---

For more information, see the main [README.md](README.md).
