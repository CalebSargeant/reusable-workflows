# 🎯 Interactive Slack Buttons Implementation Guide

This guide shows how to implement interactive Slack buttons with confirmation dialogs using our reusable GitHub Actions workflow system.

## 🌟 **What We Built**

We created a sophisticated interactive button system with:
- ✅ **Rich confirmation dialogs**
- ✅ **Multiple button types** (danger, primary, default)
- ✅ **Proper security escaping** using jq
- ✅ **Reusable workflow architecture**

## 🎨 **Button Examples**

### **Reboot Confirmation (Danger Button)**
```json
{
  "type": "button",
  "text": {
    "type": "plain_text",
    "text": "🔄 Reboot Now"
  },
  "style": "danger",
  "value": "reboot_proxmox",
  "action_id": "reboot_server",
  "confirm": {
    "title": {
      "type": "plain_text",
      "text": "Confirm Reboot"
    },
    "text": {
      "type": "mrkdwn",
      "text": "Are you sure you want to reboot *proxmox*? This will cause a brief service interruption."
    },
    "confirm": {
      "type": "plain_text",
      "text": "Yes, Reboot"
    },
    "deny": {
      "type": "plain_text",
      "text": "Cancel"
    }
  }
}
```

### **Schedule Button (Primary)**
```json
{
  "type": "button",
  "text": {
    "type": "plain_text",
    "text": "⏰ Schedule Later"
  },
  "style": "primary",
  "value": "schedule_proxmox",
  "action_id": "schedule_reboot"
}
```

### **Dismiss Button (Default)**
```json
{
  "type": "button",
  "text": {
    "type": "plain_text",
    "text": "❌ Dismiss"
  },
  "value": "dismiss_proxmox",
  "action_id": "dismiss_notification"
}
```

## 🏗️ **Implementation Architecture**

### **GitHub Actions Workflow Structure**
```yaml
name: Interactive Notifications

on:
  workflow_call:
    inputs:
      message_type:
        description: 'Type: reboot_required, deployment_ready, etc.'
        required: true
        type: string
      server_name:
        description: 'Server name for actions'
        required: true
        type: string
      enable_buttons:
        description: 'Enable interactive buttons'
        required: false
        type: boolean
        default: false
    secrets:
      SLACK_BOT_TOKEN:
        required: true
      SLACK_CHANNEL_ID:
        required: true
```

### **jq-Based JSON Generation (Security Best Practice)**
```bash
jq -n \
  --arg channel "$SLACK_CHANNEL_ID" \
  --arg server "$SERVER_NAME" \
  --arg confirm_text "Are you sure you want to reboot *$SERVER_NAME*?" \
  '{
    "channel": $channel,
    "blocks": [
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {"type": "plain_text", "text": "🔄 Reboot Now"},
            "style": "danger",
            "action_id": "reboot_server",
            "value": ("reboot_" + $server),
            "confirm": {
              "title": {"type": "plain_text", "text": "Confirm Reboot"},
              "text": {"type": "mrkdwn", "text": $confirm_text},
              "confirm": {"type": "plain_text", "text": "Yes, Reboot"},
              "deny": {"type": "plain_text", "text": "Cancel"}
            }
          }
        ]
      }
    ]
  }' > slack_payload.json
```

## 🎯 **Use Cases You Can Implement**

### **1. Server Management**
- **Reboot servers** with confirmation
- **Deploy applications** with approval
- **Scale services** up/down
- **Restart services** selectively

### **2. CI/CD Approvals**
- **Production deployments** requiring approval
- **Database migrations** with confirmation
- **Infrastructure changes** with review
- **Rollback operations** with safety checks

### **3. Alert Responses**
- **Acknowledge alerts** with user tracking
- **Escalate incidents** to on-call
- **Mute alerts** temporarily
- **Mark incidents** as resolved

### **4. Resource Management**
- **Provision cloud resources** with cost approval
- **Delete unused resources** with confirmation
- **Backup operations** with scheduling
- **Certificate renewals** with verification

## 🔧 **Implementation Steps**

### **Step 1: Create the Workflow**
```yaml
# .github/workflows/interactive-notifications.yml
name: Interactive Notifications

on:
  workflow_call:
    inputs:
      action_type:
        type: string
        required: true
      target:
        type: string  
        required: true
      enable_buttons:
        type: boolean
        default: false

jobs:
  send-notification:
    runs-on: ubuntu-latest
    steps:
    - name: Build interactive message
      env:
        SLACK_CHANNEL_ID: ${{ secrets.SLACK_CHANNEL_ID }}
        ACTION_TYPE: ${{ inputs.action_type }}
        TARGET: ${{ inputs.target }}
      run: |
        case "$ACTION_TYPE" in
          "reboot_required")
            # Build reboot confirmation message
            ;;
          "deployment_ready") 
            # Build deployment approval message
            ;;
          "resource_cleanup")
            # Build cleanup confirmation message
            ;;
        esac
```

### **Step 2: Set Up Webhook Handler**

#### **Option A: GitHub Actions Webhook**
```yaml
name: Handle Slack Interactions

on:
  repository_dispatch:
    types: [slack_interaction]

jobs:
  handle_interaction:
    runs-on: ubuntu-latest
    steps:
    - name: Process button click
      run: |
        ACTION="${{ github.event.client_payload.action_id }}"
        TARGET="${{ github.event.client_payload.value }}"
        USER="${{ github.event.client_payload.user_name }}"
        
        case "$ACTION" in
          "reboot_server")
            # Execute reboot with proper authentication
            ;;
          "approve_deployment")
            # Trigger deployment workflow
            ;;
        esac
```

#### **Option B: Serverless Function (Vercel/Netlify)**
```javascript
// api/slack-webhook.js
export default async function handler(req, res) {
  const payload = JSON.parse(req.body.payload);
  const action = payload.actions[0];
  
  // Verify Slack signature
  if (!verifySlackRequest(req)) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  
  switch (action.action_id) {
    case 'reboot_server':
      await handleReboot(action.value);
      return res.json({
        replace_original: true,
        text: `🔄 Rebooting ${action.value}...`
      });
  }
}
```

#### **Option C: Ephemeral WireGuard + GitHub Actions**
```yaml
name: Secure Server Action

jobs:
  execute_action:
    runs-on: ubuntu-latest
    steps:
    - name: Setup WireGuard
      run: |
        echo "${{ secrets.WIREGUARD_CONFIG }}" > wg0.conf
        sudo wg-quick up wg0.conf
        
    - name: Execute server command
      run: |
        ssh -o StrictHostKeyChecking=no server "reboot"
        
    - name: Cleanup WireGuard
      if: always()
      run: sudo wg-quick down wg0.conf || true
```

## 🔐 **Security Best Practices**

### **1. Request Verification**
```javascript
function verifySlackRequest(req) {
  const signature = req.headers['x-slack-signature'];
  const timestamp = req.headers['x-slack-request-timestamp'];
  const body = req.body;
  
  // Verify timestamp (prevent replay attacks)
  const fiveMinutesAgo = Math.floor(Date.now() / 1000) - (60 * 5);
  if (timestamp < fiveMinutesAgo) return false;
  
  // Verify signature
  const basestring = `v0:${timestamp}:${body}`;
  const hash = crypto
    .createHmac('sha256', process.env.SLACK_SIGNING_SECRET)
    .update(basestring)
    .digest('hex');
    
  return `v0=${hash}` === signature;
}
```

### **2. User Authorization**
```yaml
- name: Check user permissions
  run: |
    ALLOWED_USERS="${{ secrets.SLACK_ADMIN_USERS }}"
    USER_ID="${{ github.event.client_payload.user_id }}"
    
    if [[ "$ALLOWED_USERS" != *"$USER_ID"* ]]; then
      echo "::error::User $USER_ID not authorized for this action"
      exit 1
    fi
```

### **3. Action Auditing**
```yaml
- name: Audit log
  run: |
    echo "$(date): User ${{ github.event.client_payload.user_name }} executed ${{ github.event.client_payload.action_id }} on ${{ github.event.client_payload.value }}" >> audit.log
    
    # Send to logging service
    curl -X POST "${{ secrets.AUDIT_WEBHOOK }}" \
      -d "user=${{ github.event.client_payload.user_name }}&action=${{ github.event.client_payload.action_id }}&target=${{ github.event.client_payload.value }}"
```

## 🎨 **Message Templates**

### **Server Reboot Template**
```javascript
function buildRebootMessage(serverName, uptime, updates) {
  return {
    "blocks": [
      {
        "type": "header",
        "text": {
          "type": "plain_text", 
          "text": "⚠️ Server Reboot Required"
        }
      },
      {
        "type": "section",
        "fields": [
          {"type": "mrkdwn", "text": `*Server:*\n${serverName}`},
          {"type": "mrkdwn", "text": `*Current Uptime:*\n${uptime}`}
        ]
      },
      {
        "type": "section",
        "text": {
          "type": "mrkdwn",
          "text": `*Updates Applied:*\n${updates}`
        }
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {"type": "plain_text", "text": "🔄 Reboot Now"},
            "style": "danger",
            "value": `reboot_${serverName}`,
            "action_id": "reboot_server",
            "confirm": {
              "title": {"type": "plain_text", "text": "Confirm Reboot"},
              "text": {"type": "mrkdwn", "text": `Are you sure you want to reboot *${serverName}*?`},
              "confirm": {"type": "plain_text", "text": "Yes, Reboot"},
              "deny": {"type": "plain_text", "text": "Cancel"}
            }
          },
          {
            "type": "button",
            "text": {"type": "plain_text", "text": "⏰ Schedule Later"},
            "style": "primary",
            "value": `schedule_${serverName}`,
            "action_id": "schedule_reboot"
          }
        ]
      }
    ]
  };
}
```

### **Deployment Approval Template**
```javascript
function buildDeploymentMessage(environment, changes, author) {
  return {
    "blocks": [
      {
        "type": "header",
        "text": {"type": "plain_text", "text": "🚀 Deployment Approval Required"}
      },
      {
        "type": "section",
        "fields": [
          {"type": "mrkdwn", "text": `*Environment:*\n${environment}`},
          {"type": "mrkdwn", "text": `*Author:*\n${author}`}
        ]
      },
      {
        "type": "section",
        "text": {"type": "mrkdwn", "text": `*Changes:*\n${changes}`}
      },
      {
        "type": "actions",
        "elements": [
          {
            "type": "button",
            "text": {"type": "plain_text", "text": "✅ Approve Deploy"},
            "style": "primary",
            "value": `deploy_${environment}`,
            "action_id": "approve_deployment"
          },
          {
            "type": "button", 
            "text": {"type": "plain_text", "text": "❌ Reject"},
            "style": "danger",
            "value": `reject_${environment}`,
            "action_id": "reject_deployment"
          }
        ]
      }
    ]
  };
}
```

## 📊 **Advanced Features**

### **1. Dynamic Button Generation**
```bash
# Generate buttons based on server list
SERVERS=("web-01" "web-02" "db-01")
BUTTONS=""

for server in "${SERVERS[@]}"; do
  BUTTONS+="{\"type\": \"button\", \"text\": {\"type\": \"plain_text\", \"text\": \"Restart $server\"}, \"value\": \"restart_$server\", \"action_id\": \"restart_service\"},"
done

# Remove trailing comma and build message
BUTTONS=${BUTTONS%,}
```

### **2. Multi-Step Workflows**
```javascript
// Handle progressive interactions
switch (action.action_id) {
  case 'initial_action':
    return showConfirmationStep();
  case 'confirm_action':
    return showExecutionStep();  
  case 'final_action':
    return executeAndComplete();
}
```

### **3. User Context**
```yaml
- name: Get user context
  run: |
    USER_ID="${{ github.event.client_payload.user.id }}"
    USER_NAME="${{ github.event.client_payload.user.name }}"
    CHANNEL_ID="${{ github.event.client_payload.channel.id }}"
    
    # Store context for follow-up actions
    echo "user_context={\"id\":\"$USER_ID\",\"name\":\"$USER_NAME\",\"channel\":\"$CHANNEL_ID\"}" >> $GITHUB_OUTPUT
```

## 🚀 **Quick Start Template**

Want to implement interactive buttons quickly? Use this template:

```yaml
name: My Interactive Workflow

on:
  workflow_call:
    inputs:
      action_type:
        type: string
        required: true

jobs:
  interactive_notification:
    uses: calebsargeant/reusable-workflows/.github/workflows/server-update-notifications.yml@main
    with:
      server_name: ${{ inputs.target }}
      status: ${{ inputs.action_type }}
      message: ${{ inputs.message }}
      enable_reboot_button: true
    secrets:
      SLACK_BOT_TOKEN: ${{ secrets.SLACK_BOT_TOKEN }}
      SLACK_CHANNEL_ID: ${{ secrets.SLACK_CHANNEL_ID }}
```

---

This implementation gives you a production-ready foundation for interactive Slack notifications with proper security, confirmation dialogs, and extensible architecture! 🎯✨