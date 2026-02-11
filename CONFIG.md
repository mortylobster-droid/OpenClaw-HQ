# OpenClaw Configuration Summary

**Generated:** 2026-02-12  
**Brain Agent:** Rick Sanchez (Mac mini)  
**User:** Atlas (Felipe)

---

## 1. Model Routing

### Primary Model: Kimi K2.5 (Kimi Code API)
- **Provider:** Kimi Code API (direct integration)
- **Model ID:** `kimi-coding/k2p5`
- **Status:** ✅ Active and working
- **Configuration:** `~/.openclaw/openclaw.json`

### Routing History
- **Before:** OpenRouter with messy fallback chain
- **After:** Direct Kimi Code API (cleaner, more reliable)
- **Fallback:** `moonshot/kimi-k2.5` configured but unused

### Model Selection Strategy (per BRAINAGENT.md)
| Task Type | Model | Cost (per 1M tokens) |
|-----------|-------|---------------------|
| Default (90% of work) | Kimi K2.5 | $0.60 input / $2.50 output |
| Heartbeat ops | Gemini 2.5 Flash-Lite | $0.10 input / $0.40 output |
| Web search | DeepSeek V3 | $0.27 input / $1.10 output |
| Fallback (failures) | Sonnet 4.5 | $3 input / $15 output |

**Target monthly spend:** $60-80

---

## 2. Telegram Integration

- **Bot Username:** @
- **Bot ID:** 602....
- **Status:** ✅ Configured and working
- **Purpose:** Primary communication channel between Atlas and Brain Agent
- **Configuration:** `~/.openclaw/openclaw.json`

---

## 3. Brave Search API

- **Status:** ✅ Active
- **Purpose:** Web search and research tasks
- **Use case:** Finding documentation, solutions, technology comparisons
- **Configuration:** `~/.openclaw/openclaw.json`

---

## 4. Gmail OAuth Integration

### Account Details
- **Email:** mortylob....
- **Status:** ✅ Fully authorized
- **Scopes:** `gmail.readonly`, `gmail.modify`, `gmail.send`

### Capabilities
- ✅ Read emails
- ✅ Send emails
- ✅ Create/modify labels and filters
- ✅ Check for new messages

### Access Restrictions
- **Brain Agent ONLY** (Mac mini - trusted device)
- Reviewer Agent (Morty) has NO Gmail access
- This prevents account blocks and CAPTCHA issues

### Credential Storage
- **Client credentials:** `~/.openclaw/.gmail-credentials.env`
- **OAuth tokens:** `~/.openclaw/.gmail-tokens.env`
- **Permissions:** 600 (owner read/write only)

---

## 5. Docker Setup

### Docker Desktop
- **Version:** 29.2.0
- **Install method:** Homebrew (`brew install --cask docker`)
- **Status:** ✅ Running

### OpenClaw Sandbox Configuration
```json
{
  "mode": "non-main",
  "perSession": true,
  "image": "node:20-alpine",
  "resources": {
    "memory": "1GB",
    "cpus": 1
  },
  "security": {
    "readOnlyRoot": true,
    "noNewPrivileges": true
  }
}
```

### Purpose
- Main agent runs on host (speed)
- Sub-agents/spawned tasks run in isolated containers
- Per-session containers for security

---

## 6. n8n Workflow Automation

### Instance Details
- **Version:** 2.7.4
- **Deployment:** Docker container
- **Local URL:** http://localhost:...
- **Public URL:** https://n8n.ricksanchezautomations.com (DNS propagating)
- **Temporary URL:** https://sign-discounted-arabic-fo.....

### Authentication
- **Basic Auth User:** atlas
- **Basic Auth Password:** [stored securely]
- **API Key:** [stored in `~/.openclaw/.n8n-api.env`]

### n8n Configuration
```bash
N8N_PROTOCOL=http
N8N_BASIC_AUTH_ACTIVE=true
```

### Connected Services
- ✅ Gmail OAuth (via n8n credential)
- ✅ OpenClaw webhook triggers

### Sample Workflow Created
- **Name:** "OpenClaw Integration Demo"
- **ID:** 3SFcwT3umowGuAUh
- **Trigger:** Webhook (POST /webhook/openclaw-trigger)
- **Action:** Send Gmail via n8n
- **Status:** ✅ Active and tested

### API Capabilities
- Create/modify workflows programmatically
- Trigger executions via API
- Manage credentials
- Access all n8n data

---

## 7. GitHub Integration

### GitHub CLI (gh)
- **Status:** ✅ Authenticated
- **Account:** mortylobster-droid
- **Token scopes:** `gist`, `read:org`, `repo`, `workflow`
- **Install location:** `/opt/homebrew/bin/gh`

### Repository: OpenClaw-HQ
- **URL:** https://github.com/mortylobster-droid/OpenClaw-HQ
- **Local path:** `~/.openclaw/OpenClaw-HQ`
- **Purpose:** Source of truth for 2-agent architecture

### Key Files
- `ARCHITECTURE-2.md` - System design and workflow
- `BRAINAGENT.md` - Model selection strategy
- `AGENTS.md` - Role definitions and boundaries
- `README.md` - Project overview

---

## 8. Cloudflare Tunnel

### Tunnel Details
- **Name:** n8n-atlas
- **ID:** f7cf7648-bb4f-42ad-b92e-12d545e....
- **Domain:** n8n.ricksanchezautomations.com
- **Local service:** http://localhost:...

### DNS Status
- **CNAME record:** Created and configured
- **Propagation:** In progress (can take 10-30 minutes to 24 hours)
- **Temporary access:** Available via `trycloudflare.com` URLs

### Configuration Files
- **Config:** `~/.cloudflared/config.yml`
- **Certificate:** `~/.cloudflared/cert.pem`
- **Credentials:** `~/.cloudflared/{tunnel-id}.json`

---

## 9. Security & Access Control

### Credential Storage
All sensitive files stored in `~/.openclaw/` with 600 permissions:

| File | Contents | Permissions |
|------|----------|-------------|
| `.gmail-credentials.env` | Gmail Client ID/Secret | 600 |
| `.gmail-tokens.env` | Gmail OAuth tokens | 600 |
| `.n8n-api.env` | n8n API key | 600 |
| `openclaw.json` | All API keys (Telegram, Brave, Kimi) | 600 |
| `.cloudflared/cert.pem` | Cloudflare tunnel cert | 600 |

### Access Boundaries (per ARCHITECTURE.md)
- **Brain Agent (Mac mini):** Gmail access, building, pushing PRs
- **Reviewer Agent (Linux VPS):** NO Gmail access, read-only reviews
- **Felipe:** Final merge authority, strategic decisions

### Hard Rules
- ❌ Agents never modify `/FELIPE` folder
- ❌ Only Felipe merges to main
- ❌ Reviewer never builds or pushes code
- ❌ Brain never merges (opens PRs only)

---

## 10. Architecture Overview

```
                    ┌──────────────────────┐
                    │       Felipe         │
                    │  (Human Orchestrator) │
                    └──────────┬───────────┘
                               │
                               ▼
                        GitHub Repository
                    (Single Source of Truth)
                               │
            ┌──────────────────┴──────────────────┐
            │                                     │
            ▼                                     ▼
    Brain OpenClaw                      Reviewer OpenClaw
  (Mac mini – Kimi K2.5)              (Linux VPS – Codex)
  ─────────────────────               ───────────────────
  
  • Receives objectives               • Monitors GitHub PRs
  • Full-stack builder                • Code review only
  • Gmail access (exclusive)          • NO Gmail/build access
  • Pushes branches                   • Creates review files
  • Opens PRs                         • Comments on issues
  • Never merges                      • Never merges
            │                                     │
            └──────────────────┬──────────────────┘
                               │
                               ▼
                            Felipe
                      (Approves & Merges)
```

### External Services
```
Internet → Cloudflare Tunnel → n8n (Docker) → OpenClaw
                                     ↓
                              Gmail API (OAuth)
                                     ↓
                              Telegram Bot API
```

---

## 11. Cost Tracking

### Current Monthly Projection
| Service | Model | Est. Usage | Est. Cost |
|---------|-------|------------|-----------|
| Kimi K2.5 | Brain default | 25M tokens | ~$45 |
| Gemini Flash-Lite | Heartbeat | 50M tokens | ~$12 |
| DeepSeek V3 | Web search | 10M tokens | ~$8 |
| Sonnet 4.5 | Fallback | 3M tokens | ~$12 |
| **Total** | | | **~$77/month** |

### Budget Alerts
- **<$60:** Under budget ✅
- **$60-80:** On target ✅
- **$80-100:** Review usage ⚠️
- **>$120:** Emergency freeze 🚨

---

## 12. Quick Reference

### Local URLs
| Service | URL | Notes |
|---------|-----|-------|
| OpenClaw | http://localhost: | Gateway |
| n8n | http://localhost:| HTTP mode |
| Docker | unix:///var/run/docker.sock | Local socket |

### GitHub Commands
```bash
# Check PR status
gh pr list --repo mortylobster-droid/OpenClaw-HQ

# View workflow runs
gh run list --repo mortylobster-droid/OpenClaw-HQ --limit 10

# Review PR
gh pr view <number> --repo mortylobster-droid/OpenClaw-HQ
```

### n8n Commands
```bash
# View logs
docker logs n8n --tail 50

# Restart n8n
docker restart n8n

# Check tunnel status
cloudflared tunnel info n8n-atlas
```

---

## 13. Troubleshooting

### n8n not accessible
1. Check Docker: `docker ps | grep n8n`
2. Check logs: `docker logs n8n --tail 20`
3. Restart: `docker restart n8n`

### Gmail OAuth expired
1. Token auto-refreshes via refresh token
2. If fails, re-run OAuth flow
3. Check `~/.openclaw/.gmail-tokens.env`

### Cloudflare tunnel down
1. Check status: `cloudflared tunnel info n8n-atlas`
2. Restart: `cloudflared tunnel run n8n-atlas`
3. Check DNS: `host n8n.ricksanchezautomations.com`

### Model routing issues
1. Check config: `cat ~/.openclaw/openclaw.json | grep -A5 models`
2. Verify Kimi Code API key is present
3. Fallback to Sonnet if Kimi fails 2+ times

---

## 14. Next Steps / TODO

### Immediate
- [ ] Wait for DNS propagation (ricksanchezautomations.com)
- [ ] Test public n8n URL
- [ ] Verify Gmail credential in n8n UI is persistent

### Short Term
- [ ] Set up GitHub webhooks for Reviewer notifications
- [ ] Create first real workflow in n8n
- [ ] Document review file templates

### Long Term
- [ ] Migrate Reviewer to Linux VPS (if not already done)
- [ ] Set up monitoring/alerting for costs
- [ ] Create automated backup strategy

---

**Last Updated:** 2026-02-12  
**Maintained by:** Brain Agent (Rick)  
**Reviewed by:** Human (Felipe)
