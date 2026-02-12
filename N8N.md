# N8N.md - OpenClaw HQ n8n Skills & Best Practices

**Status:** ✅ Active Implementation  
**Last Updated:** 2026-02-12  
**n8n Version:** 2.7.4 (Docker)  
**Public URL:** https://n8n.mortyautomations.com

---

## Executive Summary

This document synthesizes best practices from the n8n community (haunchen/n8n-skills, czlonkowski/n8n-skills, enescingoz/awesome-n8n-templates) tailored for OpenClaw HQ's AI-assisted workflow automation.

**Key Insight:** n8n workflows should be designed for programmatic creation and modification via API, not just manual GUI building.

---

## 1. n8n Architecture for AI Assistants

### 1.1 Our Setup

```
┌─────────────────────────────────────────────────────────────┐
│  OpenClaw HQ n8n Architecture                               │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User (Felipe)                                              │
│     ↓ Telegram/Chat                                         │
│  Brain Agent (Rick)                                         │
│     ↓ n8n API / Webhooks                                    │
│  n8n (Docker) ────────→ Localhost:5678                      │
│     ↓ HTTPS                                                │
│  Cloudflare Tunnel ───→ n8n.mortyautomations.com            │
│     ↓ Webhooks                                             │
│  External Services (Gmail, Telegram, etc.)                  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 API-First Design

**We use n8n programmatically:**
```bash
# Create workflow via API
curl -X POST http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d @workflow.json

# Trigger webhook
curl -X POST http://localhost:5678/webhook/my-trigger \
  -H "Content-Type: application/json" \
  -d '{"key": "value"}'
```

---

## 2. Core n8n Concepts

### 2.1 Node Categories

| Category | Purpose | Examples |
|----------|---------|----------|
| **Triggers** | Start workflows | Webhook, Schedule, Email, Telegram |
| **Actions** | Perform operations | HTTP Request, Gmail, Telegram |
| **Transform** | Manipulate data | Set, Code, Function, Split In Batches |
| **Logic** | Control flow | IF, Switch, Wait, Loop |
| **AI** | AI/LLM operations | AI Agent, Chat Model, Vector Store |

### 2.2 Expression Syntax (Critical)

**Correct n8n expressions use double curly braces:**
```javascript
// ✅ CORRECT - Access webhook payload
{{ $json.body.email }}
{{ $json.body.subject }}

// ✅ CORRECT - Access previous node output
{{ $node["Set"].json["userId"] }}

// ✅ CORRECT - System variables
{{ $now }}
{{ $env["API_KEY"] }}

// ❌ WRONG - Single braces (won't work)
{ $json.email }
```

**Critical Gotcha:** Webhook data is ALWAYS under `$json.body`:
```javascript
// If webhook receives: {"email": "test@example.com"}
// Access it with:
{{ $json.body.email }}  // ✅ Correct
{{ $json.email }}       // ❌ Wrong - returns undefined
```

### 2.3 Code Node Patterns

**JavaScript Code Node:**
```javascript
// Access input data
const items = $input.all();  // All items
const first = $input.first(); // First item
const item = $input.item;     // Current item

// Return format (CRITICAL)
return [{
  json: {
    processed: true,
    data: items[0].json.body
  }
}];

// HTTP requests with helpers
const response = await $helpers.httpRequest({
  url: 'https://api.example.com',
  method: 'POST',
  body: { key: 'value' }
});
```

**Top 5 Code Node Errors:**
1. Not wrapping return in `[{json: {...}}]`
2. Trying to use expressions `{{}}` inside Code node (use JS instead)
3. Not awaiting async operations
4. Accessing `$json` directly instead of `$input`
5. Wrong data structure in return

---

## 3. Essential Workflow Patterns

### 3.1 Webhook Processing Pattern

```json
{
  "nodes": [
    {
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "process-data",
        "responseMode": "responseNode"
      }
    },
    {
      "type": "n8n-nodes-base.set",
      "parameters": {
        "values": {
          "email": "={{ $json.body.email }}",
          "action": "={{ $json.body.action }}"
        }
      }
    },
    {
      "type": "n8n-nodes-base.function",
      "parameters": {
        "functionCode": "// Process data\nconst data = $input.first().json;\nreturn [{json: {processed: true, ...data}}];"
      }
    },
    {
      "type": "n8n-nodes-base.respondToWebhook",
      "parameters": {
        "respondWith": "json",
        "responseBody": "={\"status\": \"success\"}"
      }
    }
  ]
}
```

### 3.2 Gmail Automation Pattern

```json
{
  "name": "Gmail Auto-Label AI",
  "nodes": [
    {
      "type": "n8n-nodes-base.gmailTrigger",
      "parameters": {
        "event": "receive",
        "mailbox": "INBOX"
      }
    },
    {
      "type": "n8n-nodes-base.openAi",
      "parameters": {
        "resource": "completion",
        "prompt": "={{ 'Categorize this email: ' + $json.body }}"
      }
    },
    {
      "type": "n8n-nodes-base.gmail",
      "parameters": {
        "operation": "addLabel",
        "messageId": "={{ $json.id }}",
        "label": "={{ $node['OpenAI'].json.category }}"
      }
    }
  ]
}
```

### 3.3 AI Agent Pattern

```json
{
  "name": "AI Agent with Tools",
  "nodes": [
    {
      "type": "n8n-nodes-base.chatTrigger",
      "parameters": {
        "options": {}
      }
    },
    {
      "type": "@n8n/n8n-nodes-langchain.agent",
      "parameters": {
        "agentType": "conversationalAgent",
        "model": "={{ $node['Chat Model'].json }}"
      }
    },
    {
      "type": "@n8n/n8n-nodes-langchain.lmChatOpenAi",
      "parameters": {
        "model": "gpt-4",
        "apiKey": "={{ $env['OPENAI_API_KEY'] }}"
      }
    }
  ]
}
```

---

## 4. OpenClaw HQ n8n Templates

### 4.1 Gmail → OpenClaw Integration

**Purpose:** Process incoming emails and notify Brain Agent

```json
{
  "name": "Gmail to OpenClaw",
  "nodes": [
    {
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "gmail-webhook",
        "responseMode": "responseNode"
      }
    },
    {
      "type": "n8n-nodes-base.set",
      "parameters": {
        "values": {
          "summary": "={{ 'New email from: ' + $json.body.from }}",
          "priority": "={{ $json.body.subject.includes('URGENT') ? 'high' : 'normal' }}"
        }
      }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "http://localhost:18789/webhook/telegram",
        "body": {
          "message": "={{ $json.summary }}"
        }
      }
    }
  ]
}
```

### 4.2 Telegram Command Handler

**Purpose:** Execute workflows from Telegram commands

```json
{
  "name": "Telegram Bot Commands",
  "nodes": [
    {
      "type": "n8n-nodes-base.telegramTrigger",
      "parameters": {
        "botToken": "={{ $env['TELEGRAM_BOT_TOKEN'] }}",
        "updates": ["message"]
      }
    },
    {
      "type": "n8n-nodes-base.switch",
      "parameters": {
        "rules": {
          "rules": [
            {
              "value": "={{ $json.body.text }}",
              "output": 0,
              "condition": "startsWith",
              "compareValue": "/status"
            },
            {
              "value": "={{ $json.body.text }}",
              "output": 1,
              "condition": "startsWith",
              "compareValue": "/email"
            }
          ]
        }
      }
    }
  ]
}
```

### 4.3 Scheduled Health Checks

**Purpose:** Monitor services and alert on failures

```json
{
  "name": "Health Monitor",
  "nodes": [
    {
      "type": "n8n-nodes-base.scheduleTrigger",
      "parameters": {
        "rule": {
          "interval": [{
            "field": "minutes",
            "minutesInterval": 5
          }]
        }
      }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "GET",
        "url": "http://localhost:5678/health"
      }
    },
    {
      "type": "n8n-nodes-base.if",
      "parameters": {
        "conditions": {
          "options": {
            "caseSensitive": true,
            "leftValue": "={{ $json.status }}",
            "operator": {
              "type": "notEqual",
              "operation": "notEquals"
            },
            "rightValue": "ok"
          }
        }
      }
    },
    {
      "type": "n8n-nodes-base.telegram",
      "parameters": {
        "chatId": "={{ $env['TELEGRAM_CHAT_ID'] }}",
        "text": "⚠️ n8n health check failed!"
      }
    }
  ]
}
```

---

## 5. API Workflow Creation (Our Method)

### 5.1 Workflow JSON Structure

```json
{
  "name": "API-Created Workflow",
  "nodes": [
    {
      "id": "trigger-1",
      "name": "Webhook",
      "type": "n8n-nodes-base.webhook",
      "typeVersion": 1,
      "position": [250, 300],
      "parameters": {
        "httpMethod": "POST",
        "path": "my-webhook",
        "responseMode": "responseNode"
      },
      "webhookId": "my-webhook"
    }
  ],
  "connections": {},
  "settings": {
    "executionOrder": "v1"
  },
  "staticData": null
}
```

### 5.2 Creating via API (Brain Agent Method)

```bash
# 1. Create workflow
curl -X POST http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Send Email via API",
    "nodes": [{
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "httpMethod": "POST",
        "path": "send-email"
      }
    },{
      "type": "n8n-nodes-base.gmail",
      "parameters": {
        "toEmail": "={{ $json.body.to }}",
        "subject": "={{ $json.body.subject }}"
      }
    }]
  }'

# 2. Activate workflow
curl -X POST http://localhost:5678/api/v1/workflows/{id}/activate \
  -H "X-N8N-API-KEY: $N8N_API_KEY"

# 3. Trigger webhook
curl -X POST http://localhost:5678/webhook/send-email \
  -H "Content-Type: application/json" \
  -d '{"to": "user@example.com", "subject": "Test"}'
```

---

## 6. Best Practices & Anti-Patterns

### ✅ DO

- **Use expressions correctly:** `{{ $json.body.field }}`
- **Return proper format from Code nodes:** `[{json: {...}}]`
- **Use environment variables for secrets:** `{{ $env["KEY"] }}`
- **Test webhooks locally first:** `curl http://localhost:5678/webhook/...`
- **Version control workflow JSON:** Commit to GitHub
- **Use descriptive node names:** "Extract User Data" not "Set23"
- **Handle errors with IF nodes:** Don't let workflows crash silently

### ❌ DON'T

- **Don't use expressions in Code nodes:** Use JavaScript instead
- **Don't hardcode credentials:** Always use env vars
- **Don't ignore validation errors:** Fix them before activating
- **Don't use `$json` directly in webhooks:** Use `$json.body`
- **Don't create circular connections:** n8n doesn't support loops natively
- **Don't forget error handling:** Always have a fallback path

---

## 7. Debugging Guide

### 7.1 Common Errors

| Error | Cause | Fix |
|-------|-------|-----|
| `Cannot read property of undefined` | Accessing `$json.field` when data is in `$json.body` | Use `$json.body.field` |
| `Expression syntax error` | Missing closing braces or wrong syntax | Check `{{ }}` pairs |
| `Node not found` | Referencing node that doesn't exist | Check node name in expression |
| `Invalid JSON` | Code node returning wrong format | Wrap in `[{json: {...}}]` |
| `ECONNREFUSED` | Service not running | Check if localhost service is up |

### 7.2 Testing Workflows

```bash
# Test webhook locally
curl -X POST http://localhost:5678/webhook/test \
  -H "Content-Type: application/json" \
  -d @test-payload.json

# View execution logs
curl http://localhost:5678/api/v1/executions?limit=10 \
  -H "X-N8N-API-KEY: $N8N_API_KEY"

# Check specific execution
curl http://localhost:5678/api/v1/executions/{id} \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

---

## 8. Integration with OpenClaw

### 8.1 Brain Agent → n8n Communication

```javascript
// Brain Agent triggers n8n workflow
async function triggerWorkflow(data) {
  const response = await fetch('http://localhost:5678/webhook/openclaw-trigger', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      from: 'Brain Agent',
      action: data.action,
      payload: data
    })
  });
  return response.json();
}
```

### 8.2 n8n → Brain Agent Communication

```json
{
  "nodes": [
    {
      "type": "n8n-nodes-base.webhook",
      "parameters": {
        "path": "openclaw-trigger"
      }
    },
    {
      "type": "n8n-nodes-base.httpRequest",
      "parameters": {
        "method": "POST",
        "url": "http://localhost:18789/webhook/n8n-response",
        "body": "={{ $json }}"
      }
    }
  ]
}
```

---

## 9. Security in n8n

### 9.1 Credential Management

```javascript
// ✅ GOOD: Use environment variables
const apiKey = $env["OPENAI_API_KEY"];

// ❌ BAD: Hardcoded secret
const apiKey = "sk-123456...";
```

### 9.2 Webhook Security

```json
{
  "nodes": [{
    "type": "n8n-nodes-base.webhook",
    "parameters": {
      "path": "secure-webhook",
      "responseMode": "responseNode",
      "authentication": "basicAuth"
    }
  }]
}
```

### 9.3 Allowed Endpoints (per SECURITY.md)

| Service | Endpoint | Status |
|---------|----------|--------|
| Gmail API | gmail.googleapis.com | ✅ Allowed |
| Telegram | api.telegram.org | ✅ Allowed |
| OpenAI | api.openai.com | ✅ Allowed |
| GitHub | api.github.com | ✅ Allowed |
| Unknown | random-site.com | ❌ Requires approval |

---

## 10. Maintenance & Operations

### 10.1 Weekly Tasks

```bash
# Backup workflows
curl http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  > backups/workflows-$(date +%Y%m%d).json

# Check failed executions
curl "http://localhost:5678/api/v1/executions?status=error" \
  -H "X-N8N-API-KEY: $N8N_API_KEY"

# Review logs
docker logs n8n --tail 100
```

### 10.2 Monitoring

```json
{
  "name": "n8n Health Monitor",
  "schedule": "*/5 * * * *",
  "check": "http://localhost:5678/health",
  "alert": "telegram"
}
```

---

## Quick Reference

### Essential Commands

```bash
# Create workflow via API
curl -X POST http://localhost:5678/api/v1/workflows \
  -H "X-N8N-API-KEY: $N8N_API_KEY" \
  -d @workflow.json

# Activate workflow
curl -X POST http://localhost:5678/api/v1/workflows/{id}/activate \
  -H "X-N8N-API-KEY: $N8N_API_KEY"

# Trigger webhook
curl -X POST http://localhost:5678/webhook/trigger \
  -d '{"key": "value"}'

# Check executions
curl http://localhost:5678/api/v1/executions?limit=10 \
  -H "X-N8N-API-KEY: $N8N_API_KEY"
```

### Expression Cheatsheet

| What You Want | Expression |
|--------------|------------|
| Webhook body field | `{{ $json.body.field }}` |
| Previous node output | `{{ $node["NodeName"].json.field }}` |
| Current timestamp | `{{ $now }}` |
| Environment variable | `{{ $env["VAR_NAME"] }}` |
| Item count | `{{ $input.all().length }}` |

---

## Resources

- **n8n Documentation:** https://docs.n8n.io
- **API Reference:** http://localhost:5678/api/v1/docs
- **Workflow Templates:** https://n8n.io/workflows
- **Our Templates:** https://github.com/mortylobster-droid/OpenClaw-HQ/tree/main/n8n-templates

---

*Based on insights from:*
- haunchen/n8n-skills (545 nodes, 20 templates)
- czlonkowski/n8n-skills (7 Claude Code skills)
- enescingoz/awesome-n8n-templates (curated automations)

*Adapted for OpenClaw HQ's AI-first workflow automation.*
