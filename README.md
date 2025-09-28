
[![CodeQL](https://github.com/CalebSargeant/reusable-workflows/actions/workflows/github-code-scanning/codeql/badge.svg)](https://github.com/CalebSargeant/reusable-workflows/actions/workflows/github-code-scanning/codeql)
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=coverage)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Maintainability Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=sqale_rating)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Reliability Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=reliability_rating)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Technical Debt](https://sonarcloud.io/api/project_badges/measure?project=CalebSargeant_reusable-workflows&metric=sqale_index)](https://sonarcloud.io/summary/new_code?id=CalebSargeant_reusable-workflows)
[![Known Vulnerabilities](https://snyk.io/test/github/CalebSargeant/reusable-workflows/badge.svg)](https://snyk.io/test/github/CalebSargeant/reusable-workflows)

[//]: # ([![License: MIT]&#40;https://img.shields.io/badge/License-MIT-yellow.svg&#41;]&#40;LICENSE&#41;)
[//]: # ([![GitHub release]&#40;https://img.shields.io/github/v/release/CalebSargeant/reusable-workflows&#41;]&#40;https://github.com/CalebSargeant/reusable-workflows/releases&#41;)
[//]: # ([![Build]&#40;https://github.com/CalebSargeant/reusable-workflows/actions/workflows/ci.yaml/badge.svg&#41;]&#40;https://github.com/CalebSargeant/reusable-workflows/actions/workflows/ci.yml&#41;)

# GitHub Reusable Workflows

This repository contains reusable GitHub Actions workflows that can be called from other repositories.

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

### Usage

To use this workflow in your repository, create a workflow file like this:

```yaml
name: Infrastructure Deployment

on:
  push:
    branches: [main, master]
  pull_request:
    branches: [main, master]

jobs:
  deploy:
    uses: CalebSargeant/reusable-workflows/.github/workflows/terragrunt-plan-cost-apply.yaml@main
    with:
      environment: production
      working_dir: ./terraform
      terraform_version: 1.5.7
      terragrunt_version: 0.45.0
      aws_region: us-east-1
      enable_comments: true
      enable_infracost: true
      auto_approve: false
    secrets:
      AWS_ROLE_TO_ASSUME: ${{ secrets.AWS_ROLE_TO_ASSUME }}
      INFRACOST_API_KEY: ${{ secrets.INFRACOST_API_KEY }}
```

**How it works:**
- For **Pull Requests**: Runs plan, posts plan output as PR comment, and shows cost estimation via Infracost
- For **main/master pushes**: Runs plan and then applies the changes (deployment)
- Automatically detects the context and behaves appropriately

### Inputs

| Name | Description | Required | Default |
|------|-------------|----------|---------|
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
