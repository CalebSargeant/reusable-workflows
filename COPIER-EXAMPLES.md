# Copier Template Examples

This file shows examples of what gets generated when using the Copier template with different configurations.

## Example 1: Documentation Repository

**Configuration:**
```bash
copier copy gh:CalebSargeant/reusable-workflows . \
  --data github_org=myorg \
  --data github_repo=docs \
  --data setup_mkdocs=true \
  --data setup_terragrunt=false \
  --data setup_docker_bake=false \
  --data setup_semantic_release=false \
  --data setup_server_notifications=false
```

**Generated files:**
```
.
├── .copier-answers.yml
├── .github/
│   └── workflows/
│       ├── mkdocs.yml              ✅ Configured
│       ├── terragrunt.yml          ❌ Not configured (can delete)
│       ├── docker.yml              ❌ Not configured (can delete)
│       ├── semantic-release.yml    ❌ Not configured (can delete)
│       └── server-notifications.yml ❌ Not configured (can delete)
├── README.md                        (Setup guide)
└── WORKFLOWS-README.md             (Documentation)
```

## Example 2: Infrastructure Repository

**Configuration:**
```bash
copier copy gh:CalebSargeant/reusable-workflows . \
  --data github_org=myorg \
  --data github_repo=infrastructure \
  --data setup_mkdocs=false \
  --data setup_terragrunt=true \
  --data terragrunt_working_dir=./terraform \
  --data terragrunt_aws_region=us-east-1 \
  --data terragrunt_enable_infracost=true \
  --data setup_docker_bake=false \
  --data setup_semantic_release=false \
  --data setup_server_notifications=false
```

**Generated Terragrunt workflow:**
```yaml
name: Deploy Infrastructure

on:
  push:
    branches:
      - main
    paths:
      - 'terraform/**'
      - '.github/workflows/**'
  pull_request:
    branches:
      - main
    paths:
      - 'terraform/**'

permissions:
  id-token: write
  contents: read
  issues: write
  pull-requests: write

jobs:
  deploy:
    uses: CalebSargeant/reusable-workflows/.github/workflows/terragrunt-plan-cost-apply.yaml@main
    with:
      environment: 'production'
      working_dir: './terraform'
      aws_region: 'us-east-1'
      enable_comments: true
      enable_infracost: true
      auto_approve: ${{ github.event_name == 'push' && github.ref == 'refs/heads/main' }}
    secrets:
      AWS_ROLE_TO_ASSUME: ${{ secrets.AWS_ROLE_ARN }}
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
      SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
```

## Example 3: Application Repository (Docker + Semantic Release)

**Configuration:**
```bash
copier copy gh:CalebSargeant/reusable-workflows . \
  --data github_org=myorg \
  --data github_repo=my-app \
  --data setup_mkdocs=false \
  --data setup_terragrunt=false \
  --data setup_docker_bake=true \
  --data docker_registry=ghcr.io \
  --data docker_image_name=my-app \
  --data setup_semantic_release=true \
  --data setup_server_notifications=false
```

**Generated Docker workflow:**
```yaml
name: Docker Build and Push

on:
  push:
    branches:
      - main
    tags:
      - 'v*'
  pull_request:
    branches:
      - main

permissions:
  contents: read
  packages: write

jobs:
  docker:
    uses: CalebSargeant/reusable-workflows/.github/workflows/docker-bake-ghcr.yaml@main
    with:
      registry: ghcr.io
      image_name: my-app
    secrets:
      REGISTRY_USERNAME: ${{ github.actor }}
      REGISTRY_PASSWORD: ${{ secrets.GITHUB_TOKEN }}
```

**Generated Semantic Release workflow:**
```yaml
name: Semantic Release

on:
  push:
    branches:
      - main
      - staging

permissions:
  contents: write
  issues: write
  pull-requests: write

jobs:
  release:
    uses: CalebSargeant/reusable-workflows/.github/workflows/semantic-release.yaml@main
    secrets:
      GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## Example 4: Full Stack Application (All Workflows)

**Configuration:**
```bash
copier copy gh:CalebSargeant/reusable-workflows . \
  --data github_org=myorg \
  --data github_repo=fullstack-app \
  --data setup_mkdocs=true \
  --data mkdocs_working_directory=./docs \
  --data setup_terragrunt=true \
  --data terragrunt_working_dir=./infrastructure \
  --data setup_docker_bake=true \
  --data docker_image_name=fullstack-app \
  --data setup_semantic_release=true \
  --data setup_server_notifications=true \
  --data slack_channel_id=C1234567890
```

**Generated README.md excerpt:**
```markdown
# Workflows Setup Complete!

The following workflow files have been generated:

✅ **mkdocs.yml** - MkDocs documentation workflow (CONFIGURED)
✅ **terragrunt.yml** - Terragrunt infrastructure workflow (CONFIGURED)
✅ **docker.yml** - Docker build and push workflow (CONFIGURED)
✅ **semantic-release.yml** - Semantic release workflow (CONFIGURED)
✅ **server-notifications.yml** - Server update notifications workflow (CONFIGURED)

## Next Steps

1. Review the generated workflow files in `.github/workflows/`
2. Delete any workflow files that are marked as "NOT CONFIGURED" if you don't need them
3. Read `WORKFLOWS-README.md` for detailed setup instructions
4. Configure required secrets in your repository settings
5. Test the workflows by triggering them manually or via commits
```

## Example 5: GHES Deployment

**Configuration:**
```bash
copier copy gh:CalebSargeant/reusable-workflows . \
  --data github_org=enterprise-org \
  --data github_repo=infrastructure \
  --data setup_terragrunt=true \
  --data terragrunt_working_dir=./terraform/aws \
  --data terragrunt_aws_region=us-west-2 \
  --data source_repo=enterprise-org/reusable-workflows \
  --data source_branch=main \
  --data is_ghes=true \
  --data ghes_hostname=github.company.com
```

**Generated .copier-answers.yml:**
```yaml
# Copier answers file
# This file tracks the configuration used to generate this repository
# Run `copier update` to update the generated files
_src_path: https://github.com/enterprise-org/reusable-workflows
_commit: main

github_org: enterprise-org
github_repo: infrastructure
source_repo: enterprise-org/reusable-workflows
source_branch: main
is_ghes: True
ghes_hostname: github.company.com
setup_terragrunt: True
terragrunt_working_dir: ./terraform/aws
terragrunt_aws_region: us-west-2
```

**WORKFLOWS-README.md will include GHES notes:**
```markdown
## GHES Considerations

This repository is configured for GitHub Enterprise Server at `github.company.com`.

**Important notes:**
- Ensure the reusable workflows repository is accessible from your GHES instance
- Update workflow references if the source repository is hosted on a different GHES instance
- Some GitHub Marketplace actions may not be available on GHES - verify availability
```

## Updating Existing Templates

After initial generation, you can update to get the latest template changes:

```bash
cd /path/to/your/repo
copier update
```

This will:
1. Pull the latest template version
2. Re-render templates with your saved configuration from `.copier-answers.yml`
3. Show you a diff of changes
4. Allow you to review and accept/reject changes

## Interactive Mode

Run without `--data` flags for interactive mode:

```bash
copier copy gh:CalebSargeant/reusable-workflows .
```

You'll be prompted with questions like:
```
GitHub organization or username where destination repo is located
  myorg
Destination repository name (without org/user)
  my-repo
Source repository for reusable workflows (org/repo format)
  CalebSargeant/reusable-workflows
Branch/tag to reference in the source repository
  main
Set up MkDocs GitHub Pages workflow?
  No
Set up Terragrunt infrastructure workflow?
  Yes
...
```

All answers are saved to `.copier-answers.yml` for future updates.
