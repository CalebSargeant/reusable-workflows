# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repository Overview

This repository contains GitHub Actions reusable workflows designed to be called from other repositories. The workflows provide standardized CI/CD functionality for:

1. **Slack Pull Request Events** - Automated Slack notifications for PR activities
2. **Terragrunt Plan/Cost/Apply** - Infrastructure deployment with cost estimation
3. **SonarQube Analysis** - Code quality and security scanning

## Architecture

### Workflow Structure
Each reusable workflow follows the GitHub Actions `workflow_call` pattern and is located in `.github/workflows/`:

- `slack-pr-events.yaml` - Handles PR notifications to Slack channels
- `terragrunt-plan-cost-apply.yaml` - Manages infrastructure deployment lifecycle
- `sonarqube.yaml` - Executes code quality analysis

### Key Patterns
- **Input Validation**: All workflows define required and optional inputs with defaults
- **Secret Management**: Sensitive data passed via GitHub secrets
- **Conditional Execution**: Logic based on event type (PR vs push) and branch
- **Multi-step Jobs**: Sequential execution with dependencies (`needs`)

## Common Development Tasks

### Testing Workflow Changes
```bash
# Validate YAML syntax
yamllint .github/workflows/*.yaml

# Check workflow structure (if actionlint is available)
actionlint .github/workflows/*.yaml
```

### Workflow Development
```bash
# Create a new workflow file
touch .github/workflows/new-workflow.yaml

# Copy template structure from existing workflow
cp .github/workflows/slack-pr-events.yaml .github/workflows/new-workflow.yaml
```

### Version Management
```bash
# Create new release tag for workflow versioning
git tag -a v1.2.0 -m "Release version 1.2.0"
git push origin v1.2.0

# Update main branch reference
git push origin main
```

## Workflow-Specific Details

### Slack PR Events Workflow
- **Dependencies**: Uses `cakarci/pull-request-workflow@v1.11.5` marketplace action
- **Triggers**: PR events (opened, review_requested, review_request_removed) and review submissions
- **Outputs**: Slack messages with PR links and reviewer mentions

### Terragrunt Workflow
- **Multi-stage pipeline**: Checks → Plan → Cost (PR only) → Apply (main branch only)
- **AWS Integration**: Uses OIDC authentication with assumable IAM roles
- **Cost Analysis**: Integrates with Infracost for infrastructure cost estimation
- **Environment Support**: Supports multiple environments through GitHub Environments
- **SOPS Integration**: Handles encrypted secrets via Age keys

### SonarQube Workflow
- **Analysis Scope**: Full repository scan with deep fetch for better analysis
- **Integration**: Works with SonarCloud and self-hosted SonarQube instances
- **Configuration**: Uses `sonar-project.properties` for project-specific settings

## Integration Guidelines

### Calling These Workflows
Reference workflows using the repository path and version:
```yaml
jobs:
  deploy:
    uses: CalebSargeant/reusable-workflows/.github/workflows/terragrunt-plan-cost-apply.yaml@main
```

### Required Secrets Setup
- **Slack**: `SLACK_BOT_TOKEN` with appropriate permissions
- **AWS**: `AWS_ROLE_TO_ASSUME` for infrastructure workflows
- **Infracost**: `INFRACOST_API_KEY` for cost estimation
- **SonarQube**: `SONAR_TOKEN` for code analysis
- **SOPS**: `SOPS_AGE_KEY` for secret decryption

### Environment Configuration
The Terragrunt workflow expects GitHub Environments to be configured with:
- Environment-specific secrets (e.g., `DEV_AWS_ROLE_ARN`, `PROD_AWS_ROLE_ARN`)
- Protection rules for production environments
- Reviewer requirements for sensitive deployments

## File Structure Context

```
.github/workflows/
├── slack-pr-events.yaml          # Slack notification workflow
├── terragrunt-plan-cost-apply.yaml  # Infrastructure deployment workflow  
└── sonarqube.yaml                # Code quality analysis workflow

sonar-project.properties          # SonarQube project configuration
README.md                         # Comprehensive usage documentation
```

## Debugging Common Issues

### Workflow Not Triggering
- Verify the calling repository has the correct workflow syntax
- Check that required secrets are properly configured
- Ensure GitHub Environments exist if specified

### Authentication Failures
- Validate AWS OIDC trust relationships include the calling repository
- Confirm Slack bot tokens have necessary scopes
- Check SonarQube token permissions and organization access

### Cost Estimation Not Working
- Verify Infracost API key is valid and has sufficient quota
- Ensure Terraform/Terragrunt code is parseable by Infracost
- Check that the workflow has PR write permissions for comments