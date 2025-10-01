<!-- Quality & Security Overview -->
[![CodeQL](https://github.com/CalebSargeant/reusable-workflows/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/CalebSargeant/reusable-workflows/actions/workflows/github-code-scanning/codeql)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=alert_status&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=security_rating&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Known Vulnerabilities](https://snyk.io/test/github/calebsargeant/reusable-workflows/badge.svg)](https://snyk.io/test/github/calebsargeant/reusable-workflows)

<!-- Code Quality & Maintainability -->
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=sqale_rating&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=reliability_rating&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=sqale_index&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)

<!-- Code Metrics -->
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=coverage&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=bugs&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=vulnerabilities&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=code_smells&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)

<!-- Project Stats -->
[![Lines of Code](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=ncloc&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=duplicated_lines_density&token=ebfb6b12c8469925ada2be9a1af34b9679e55d40)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)

# GitHub Reusable Workflows

This repository contains reusable GitHub Actions workflows that can be called from other repositories.

## 🚀 Auto-Update System with Slack Notifications

A one-liner installer for server auto-updates with centralized Slack notifications, inspired by Pi-hole and k3s installers.

### ✨ Features

- 🎯 **One-liner installation** like Pi-hole/k3s
- 📱 **Rich Slack notifications** with interactive buttons
- 🔄 **Reboot confirmation buttons** (optional)
- 🏗️ **Reusable GitHub Actions workflows**
- 🔐 **Multi-OS support** (Debian/Ubuntu, RHEL/CentOS/Fedora, Arch)
- ⚡ **Smart load checking** (skips updates during high load)
- 🛡️ **Systemd security hardening**
- 📊 **Comprehensive logging**

### 🚀 Quick Start

#### Basic Installation
```bash
curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | sudo bash -s -- \
  --slack-token xoxb-your-slack-bot-token \
  --slack-channel C1234567890
```

#### Full Customization
```bash
curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | sudo bash -s -- \
  --slack-token xoxb-your-slack-bot-token \
  --slack-channel C1234567890 \
  --github-repo myorg/myrepo \
  --server-name my-production-server \
  --enable-reboot-button \
  --schedule-time "02:30:00" \
  --randomized-delay 1800
```

#### Dry Run (See what would happen)
```bash
curl -sSL https://raw.githubusercontent.com/calebsargeant/reusable-workflows/main/install-auto-update.sh | bash -s -- \
  --slack-token xoxb-test \
  --slack-channel C-test \
  --dry-run
```

### 📋 Installation Options

| Option | Description | Required | Default |
|--------|-------------|----------|---------|
| `--slack-token` | Slack bot token (starts with `xoxb-`) | ✅ | - |
| `--slack-channel` | Slack channel ID (starts with `C`) | ✅ | - |
| `--github-repo` | GitHub repository for notifications | ❌ | `calebsargeant/infra` |
| `--server-name` | Server name for notifications | ❌ | `$(hostname)` |
| `--enable-reboot-button` | Enable interactive reboot buttons | ❌ | `false` |
| `--schedule-time` | Update time in HH:MM:SS format | ❌ | `03:00:00` |
| `--randomized-delay` | Random delay in seconds | ❌ | `3600` |
| `--force` | Force installation over existing | ❌ | `false` |
| `--dry-run` | Show what would be done | ❌ | `false` |

### 🏗️ Using the Reusable Workflow

Create `.github/workflows/server-notifications.yml` in your repository:

```yaml
name: Server Update Notifications

on:
  repository_dispatch:
    types: [server-update]

jobs:
  send-notification:
    uses: calebsargeant/reusable-workflows/.github/workflows/server-update-notifications.yml@main
    with:
      server_name: ${{ github.event.client_payload.server_name }}
      status: ${{ github.event.client_payload.status }}
      message: ${{ github.event.client_payload.message }}
      enable_reboot_button: true
    secrets:
      SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
      SLACK_CHANNEL_ID: ${{ secrets.SLACK_CHANNEL_ID }}
```

## Slack Pull Request Events Workflow

A reusable workflow for sending Slack notifications on pull request events including opened PRs, reviewer mentions, and approval/decline reactions.

### Features

- Notifications when PRs are opened with link to the PR
- Automatic @mentions for requested reviewers in Slack
- ✅ emoji reaction when PRs are approved
- ❌ emoji reaction when PRs are declined/rejected
- Configurable Slack channel
- Simple setup using marketplace actions

### Usage

To use this workflow in your repository, create a workflow file like this:

```yaml
name: Slack PR Notifications

on:
  pull_request:
    types: [opened, review_requested]
  pull_request_review:
    types: [submitted]

jobs:
  notify_slack:
    uses: CalebSargeant/reusable-workflows/.github/workflows/slack-pr-events.yaml@main
    with:
      slack_channel_id: "C1234567890"  # Your Slack channel ID
    secrets:
      SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
```

### Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `slack_channel_id` | The Slack channel ID to post notifications to | Yes | - |

### Secrets

| Name | Description | Required |
|------|-------------|----------|
| `SLACK_BOT_TOKEN` | Slack Bot token for authentication | Yes |

### Slack Setup

To use this workflow, you need to create a Slack bot:

1. Go to [api.slack.com](https://api.slack.com/apps) and create a new app
2. Navigate to "OAuth & Permissions" and add the following scopes:
   - `chat:write` (to post messages)
   - `reactions:write` (to add emoji reactions)
   - `channels:read` (to access channel information)
3. Install the app to your workspace
4. Copy the Bot User OAuth Token and store it as `SLACK_BOT_TOKEN` secret in your GitHub repository
5. Find your channel ID by right-clicking on the channel in Slack and selecting "Copy link" - the ID is the last part of the URL

## Terragrunt Plan/Apply Workflow

A reusable workflow for running Terragrunt plan and apply operations with AWS authentication.

### Features

- AWS authentication using OpenID Connect (OIDC)
- Configurable Terraform and Terragrunt versions
- Automatic PR comments with plan output
- Infracost integration for cloud cost estimation
- Conditional apply based on branch and approval
- Environment variable handling for Terraform variables
- Simplified setup and execution
- Support for both single and multi-environment deployments

### Usage

This workflow can be used in two primary configurations:
1. **Multi-Environment Approach** - For managing dev/staging/prod environments with branch-based deployments
2. **Single-Environment Approach** - For simpler setups with a single target environment

#### Multi-Environment Approach (Dev/Staging/Prod)

This approach uses a matrix strategy to define multiple environments with intelligent path filtering to only run deployments when relevant files change.

##### Basic Multi-Environment Setup

For simpler setups where you want all environments to run when any terraform changes occur:

```yaml
name: Deploy Infrastructure - Multi Environment (Basic)

on:
  push:
    branches:
      - main
      - develop
      - staging
    paths:
      - 'terraform/**'
      - '.github/workflows/**'
  pull_request:
    branches:
      - main
      - develop
      - staging
    paths:
      - 'terraform/**'

permissions:
  id-token: write
  contents: read
  issues: write
  pull-requests: write

jobs:
  deploy:
    strategy:
      matrix:
        include:
          # Development environment
          - environment: dev
            environment_secret: DEV_AWS_ROLE_ARN
            branch: develop
            working_dir: './terraform/environments/dev'
            aws_region: 'us-west-2'
            enable_comments: true
            enable_infracost: true
            auto_approve: false
            
          # Staging environment
          - environment: staging
            environment_secret: STAGING_AWS_ROLE_ARN
            branch: staging
            working_dir: './terraform/environments/staging'
            aws_region: 'us-west-2'
            enable_comments: true
            enable_infracost: true
            auto_approve: false
            
          # Production environment
          - environment: prod
            environment_secret: PROD_AWS_ROLE_ARN
            branch: main
            working_dir: './terraform/environments/prod'
            aws_region: 'us-east-1'
            enable_comments: false
            enable_infracost: true
            auto_approve: true
            
    # Only run for the matching branch or PRs targeting that branch
    if: |
      (github.ref == format('refs/heads/{0}', matrix.branch)) ||
      (github.event_name == 'pull_request' && github.base_ref == matrix.branch)
    
    uses: CalebSargeant/reusable-workflows/.github/workflows/terragrunt-plan-cost-apply.yaml@main
    with:
      environment: ${{ matrix.environment }}
      working_dir: ${{ matrix.working_dir }}
      aws_region: ${{ matrix.aws_region }}
      enable_comments: ${{ matrix.enable_comments }}
      enable_infracost: ${{ matrix.enable_infracost }}
      auto_approve: ${{ matrix.auto_approve }}
    secrets:
      AWS_ROLE_TO_ASSUME: ${{ secrets[matrix.environment_secret] }}
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
      SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
```

##### Advanced Multi-Environment with Path Filtering

For more efficient deployments that only run when specific environment directories or shared modules change:

```yaml
name: Deploy Infrastructure - Multi Environment (Path Filtered)

on:
  push:
    branches:
      - main
      - develop
      - staging
  pull_request:
    branches:
      - main
      - develop
      - staging

permissions:
  id-token: write
  contents: read
  issues: write
  pull-requests: write

jobs:
  # Detect which environments have changes
  changes:
    runs-on: ubuntu-latest
    outputs:
      dev: ${{ steps.filter.outputs.dev }}
      staging: ${{ steps.filter.outputs.staging }}
      prod: ${{ steps.filter.outputs.prod }}
      shared: ${{ steps.filter.outputs.shared }}
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Check for changes
        uses: dorny/paths-filter@v3
        id: filter
        with:
          filters: |
            dev:
              - 'terraform/environments/dev/**'
              - 'terraform/_modules/**'
              - 'terraform/aws/_modules/**'
            staging:
              - 'terraform/environments/staging/**'
              - 'terraform/_modules/**'
              - 'terraform/aws/_modules/**'
            prod:
              - 'terraform/environments/prod/**'
              - 'terraform/_modules/**'
              - 'terraform/aws/_modules/**'
            shared:
              - 'terraform/_modules/**'
              - 'terraform/aws/_modules/**'
              - '.github/workflows/terragrunt-infrastructure.yaml'

  deploy:
    needs: changes
    strategy:
      matrix:
        include:
          # Development environment
          - environment: dev
            environment_secret: DEV_AWS_ROLE_ARN
            branch: develop
            working_dir: './terraform/environments/dev'
            aws_region: 'us-west-2'
            enable_comments: true
            enable_infracost: true
            auto_approve: false
            
          # Staging environment
          - environment: staging
            environment_secret: STAGING_AWS_ROLE_ARN
            branch: staging
            working_dir: './terraform/environments/staging'
            aws_region: 'us-west-2'
            enable_comments: true
            enable_infracost: true
            auto_approve: false
            
          # Production environment
          - environment: prod
            environment_secret: PROD_AWS_ROLE_ARN
            branch: main
            working_dir: './terraform/environments/prod'
            aws_region: 'us-east-1'
            enable_comments: false
            enable_infracost: true
            auto_approve: true
            
    # Only run for the matching branch/PR AND if there are relevant changes
    if: |
      (
        (matrix.environment == 'dev' && needs.changes.outputs.dev == 'true') ||
        (matrix.environment == 'staging' && needs.changes.outputs.staging == 'true') ||
        (matrix.environment == 'prod' && needs.changes.outputs.prod == 'true')
      ) && (
        (github.ref == format('refs/heads/{0}', matrix.branch)) ||
        (github.event_name == 'pull_request' && github.base_ref == matrix.branch)
      )
    
    uses: CalebSargeant/reusable-workflows/.github/workflows/terragrunt-plan-cost-apply.yaml@main
    with:
      environment: ${{ matrix.environment }}
      working_dir: ${{ matrix.working_dir }}
      aws_region: ${{ matrix.aws_region }}
      enable_comments: ${{ matrix.enable_comments }}
      enable_infracost: ${{ matrix.enable_infracost }}
      auto_approve: ${{ matrix.auto_approve }}
    secrets:
      AWS_ROLE_TO_ASSUME: ${{ secrets[matrix.environment_secret] }}
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
      SOPS_AGE_KEY: ${{ secrets.SOPS_AGE_KEY }}
```

**Multi-Environment Setup Notes:**
- **Basic Setup**: All environments run when any terraform files change - simpler but less efficient
- **Path Filtered Setup**: Only runs environments when their specific directories or shared modules change - more efficient for large projects
- Each environment is defined in the matrix with a specific branch trigger
- Environment-specific secrets are referenced using the `environment_secret` matrix parameter (e.g., `DEV_AWS_ROLE_ARN`, `STAGING_AWS_ROLE_ARN`, `PROD_AWS_ROLE_ARN`)
- The conditional `if` statement ensures workflows only run for the appropriate branch
- This approach requires creating GitHub Environment for each deployment target (dev, staging, prod)
- **Required Permissions**: The caller workflow must include the permissions block to grant access for OIDC authentication, PR comments, and issue updates

**Path Filtering Benefits:**
- **Efficiency**: Only deploys environments that actually have changes
- **Cost Savings**: Reduces unnecessary workflow runs and AWS API calls
- **Faster Feedback**: Shorter CI/CD times when only specific environments need updates
- **Clarity**: PR comments and logs only show relevant environment changes

**Path Filter Configuration:**
- Each environment filter includes its specific directory (`terraform/environments/{env}/**`)
- Shared module changes (`terraform/_modules/**`, `terraform/aws/_modules/**`) trigger all environments
- Workflow file changes trigger a "shared" output for maintenance purposes
- Customize the path patterns based on your repository structure

**Required Permissions Explained:**
- `id-token: write` - Required for OIDC authentication with AWS (allows GitHub to assume AWS IAM roles)
- `contents: read` - Required to check out the repository code
- `issues: write` - Required for posting issue comments (used by some Terraform actions)
- `pull-requests: write` - Required for posting plan output as PR comments and Infracost cost estimates

#### Single-Environment Approach

For simpler projects or when you're just getting started, you can use a single environment approach:

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

**Single-Environment Setup Notes:**
- Much simpler configuration with no matrix or conditionals
- Only triggers on main branch changes
- Auto-approve is determined by a simple expression checking if this is a push to the main branch
- Only requires a single GitHub Environment setup

### How It Works

- For **Pull Requests**: Runs plan, posts plan output as PR comment, and shows cost estimation via Infracost
- For **main/master pushes**: Runs plan and then applies the changes (deployment)
- Automatically detects the context and behaves appropriately

### Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
| `runner` | The runner to use for the job | No | `ubuntu-latest` |
| `environment` | GitHub Environment to deploy to (for AWS credentials) | Yes | - |
| `working_dir` | Directory where Terragrunt commands will be executed | No | `./terraform` |
| `terraform_version` | Terraform version to use | No | `latest` |
| `terragrunt_version` | Terragrunt version to use | No | `latest` |
| `aws_region` | AWS region to use | No | `us-east-1` |
| `enable_comments` | Enable PR comments for plan output | No | `true` |
| `enable_infracost` | Enable Infracost cost estimation | No | `true` |
| `auto_approve` | Auto approve apply (only for main/master branch) | No | `false` |

### Secrets

| Name | Description | Required |
|------|-------------|----------|
| `AWS_ROLE_TO_ASSUME` | AWS IAM role ARN to assume | Yes |
| `INFRACOST_API_KEY` | API key for Infracost cost estimation | No |
| `SOPS_AGE_KEY` | SOPS Age key for decrypting secrets | No |

### AWS Setup

To use this workflow with AWS, you need to set up OIDC authentication:

1. Create an IAM role with the necessary permissions for your Terraform/Terragrunt operations
2. Configure the trust relationship to allow GitHub Actions to assume the role:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_ORG/YOUR_REPO:*"
        }
      }
    }
  ]
}
```

3. Store the role ARN as a secret in your GitHub repository

### Infracost Setup

To use the Infracost integration for cloud cost estimation:

1. Sign up for a free Infracost account at [infracost.io](https://www.infracost.io/)
2. Get your API key from the Infracost dashboard
3. Store the API key as the `INFRACOST_API_KEY` secret in your GitHub repository
4. Enable Infracost in your workflow by setting `enable_infracost: true`

When enabled, Infracost will analyze your Terragrunt/Terraform code and provide cost estimates as comments on your pull requests.

### SOPS Setup (Optional)

If your Terraform/Terragrunt configuration uses SOPS for managing encrypted secrets:

1. Generate an Age key pair:
   ```bash
   age-keygen -o key.txt
   ```
2. Store the private key as the `SOPS_AGE_KEY` secret in your GitHub repository
3. The workflow will automatically set up the SOPS environment variables and Age key file during execution

The workflow sets these environment variables when `SOPS_AGE_KEY` is provided:
- `SOPS_AGE_KEY_FILE` - Path to the Age key file
- `TF_VAR_sops_age_key_file` - Terraform variable for the Age key file path
