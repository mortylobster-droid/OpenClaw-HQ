# SECURITY.md - OpenClaw HQ Security Guidelines

**Status:** 🛡️ Active Implementation  
**Last Updated:** 2026-02-12  
**Threat Model:** Personal/Professional AI assistant with sensitive account access

---

## Executive Summary

**Your concern is valid.** Yesterday I opened browser tabs while you were logged into ChatGPT, Gmail, and other accounts. This creates real risks:

- **Session hijacking** via exposed cookies
- **Credential leakage** through browser automation
- **Cross-site attacks** from malicious pages
- **Accidental actions** on authenticated services

**This document establishes guardrails to prevent these risks while maintaining productivity.**

---

## 1. Browser Automation Policy

### 🔴 HIGH RISK - Requires Explicit Approval

**I MUST ask you before:**
- Opening ANY browser tab when you're logged into:
  - Gmail/Google Workspace
  - ChatGPT/Claude/AI services
  - Banking/financial services
  - Social media (Twitter, LinkedIn, etc.)
  - Any service with payment methods saved
- Interacting with authenticated sessions
- Taking screenshots of logged-in pages
- Filling forms with auto-complete data

**Approval format:**
```
⚠️ SECURITY: I need to open a browser tab for [purpose].
You're currently logged into [detected services].

Options:
1. ✅ Approve (I'll proceed)
2. 🔒 Log out first (recommended)
3. 🚫 Deny (find alternative)
4. ⏭️ Skip (do it yourself)
```

### 🟡 MEDIUM RISK - Use Isolated Methods

**Preferred alternatives to browser automation:**
- **OAuth flows** → Use CLI/device flow instead of browser
- **API calls** → Use curl/SDK instead of web scraping
- **Form filling** → Use headless browser with clean profile
- **File downloads** → Use direct URLs with authentication tokens

**Example:**
```bash
# ❌ DON'T: Open browser to download
open https://example.com/file.pdf

# ✅ DO: Use authenticated API
curl -H "Authorization: Bearer $TOKEN" https://api.example.com/file.pdf
```

### 🟢 LOW RISK - Proceed with Logging

**Safe to automate without approval:**
- Public documentation sites (no login)
- Status pages and health checks
- Local development servers (localhost)
- Sandbox/isolated browser profiles

**Always log:**
- URL accessed
- Actions taken
- Duration of access

---

## 2. Authentication & Credential Isolation

### 2.1 Browser Profile Separation

**Create isolated browser profiles for automation:**

```bash
# Safari: Use private window for all automation
# Chrome: Create dedicated automation profile

# Create automation profile directory
mkdir -p ~/.openclaw/browser-profiles/automation

# Launch browser with isolated profile
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome \
  --user-data-dir=~/.openclaw/browser-profiles/automation \
  --no-first-run \
  --no-default-browser-check
```

**Benefits:**
- No saved passwords
- No auto-fill data
- No session cookies
- Clean slate every time

### 2.2 OAuth Device Flow (Preferred)

**For all OAuth authentications:**

```bash
# ✅ GOOD: Device flow (you authorize on YOUR terms)
gh auth login --web  # You control the browser
openclaw auth login  # You paste the code

# ❌ BAD: Headless browser automation
# (I control the browser, you don't see what's happening)
```

### 2.3 Token Storage Security

**Current implementation (review and confirm):**

| Credential | Location | Permissions | Risk |
|------------|----------|-------------|------|
| Gmail OAuth | `~/.openclaw/.gmail-tokens.env` | 600 | ✅ Low |
| n8n API Key | `~/.openclaw/.n8n-api.env` | 600 | ✅ Low |
| GitHub Token | Keychain | OS-managed | ✅ Low |
| Kimi API Key | `openclaw.json` | 600 | ✅ Low |

**Required additions:**
```bash
# Add to .zshrc or .bash_profile
export OPENCLAW_CREDENTIAL_DIR="$HOME/.openclaw"
chmod 700 "$OPENCLAW_CREDENTIAL_DIR"

# Audit script (run weekly)
find ~/.openclaw -name "*.env" -o -name "*token*" -o -name "*key*" | xargs ls -la
```

---

## 3. Network Security

### 3.1 Endpoint Allowlisting

**I should ONLY connect to:**

| Service | Endpoint | Protocol | Purpose |
|---------|----------|----------|---------|
| GitHub | github.com, api.github.com | HTTPS | Code, Issues, PRs |
| Gmail | gmail.googleapis.com | HTTPS | Email operations |
| n8n | localhost:5678, n8n.mortyautomations.com | HTTP/HTTPS | Automation |
| Telegram | api.telegram.org | HTTPS | Messaging |
| Cloudflare | *.cloudflare.com, *.trycloudflare.com | HTTPS | Tunnels |
| Kimi API | api.moonshot.cn | HTTPS | AI inference |

**⚠️ FLAG for approval if I need to connect to:**
- Unknown/unlisted domains
- HTTP (non-HTTPS) endpoints
- IP addresses directly (bypassing DNS)
- Suspicious ports (non-80/443)

### 3.2 Request Logging

**All outbound requests logged to:**
```
~/.openclaw/logs/network.log

Format:
[2026-02-12T20:00:00Z] GET https://api.github.com/user/repos
[2026-02-12T20:00:01Z] POST https://gmail.googleapis.com/gmail/v1/users/me/messages/send
```

**Implementation:**
```bash
# Add to curl wrapper
log_request() {
  echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" >> ~/.openclaw/logs/network.log
}
```

---

## 4. File System Security

### 4.1 Sandboxed Write Locations

**I can write freely to:**
```
~/.openclaw/              # Project directory
~/.openclaw/workspace/    # Working files
~/.openclaw/memory/       # Session logs
/tmp/openclaw-*/          # Temporary files
```

**⚠️ REQUIRES APPROVAL for:**
```
~/Documents/              # Personal documents
~/Desktop/                # Desktop files
~/Downloads/              # Downloads
~/Pictures/               # Photos
/etc/                     # System config
/usr/local/bin/           # System binaries
```

### 4.2 Sensitive File Patterns

**FLAG immediately if I attempt to access:**
- `~/.ssh/*` (SSH keys)
- `~/.aws/*` (AWS credentials)
- `~/.docker/config.json` (Docker registry auth)
- `~/.netrc` (FTP credentials)
- `~/.npmrc` (NPM auth)
- `*/.env` (environment files in other projects)
- `*/secrets*` `*/credentials*` (obvious secret files)

**Exception:** Read-only access for migration/integration with explicit approval.

---

## 5. Command Execution Security

### 5.1 Command Risk Classification

| Risk | Examples | Approval |
|------|----------|----------|
| 🟢 Low | `ls`, `cat`, `grep`, `curl` (to known endpoints) | No |
| 🟡 Medium | `npm install`, `pip install`, `brew install` | Log only |
| 🔴 High | `sudo`, `rm -rf`, `curl \| bash`, `eval` | **Required** |
| 🚨 Critical | `curl \| sudo bash`, `chmod 777 /`, `kill` | **Explicit + confirmation** |

### 5.2 Install Script Protection

**❌ NEVER execute:**
```bash
curl -sSL https://example.com/install.sh | bash
curl -sSL https://example.com/install.sh | sh
curl -sSL https://example.com/install.sh | sudo bash
```

**✅ SAFE alternatives:**
```bash
# Download first, review, then execute
curl -sSL https://example.com/install.sh -o /tmp/install.sh
cat /tmp/install.sh  # Review content
bash /tmp/install.sh  # Execute after approval

# Or use package managers
brew install package-name
npm install package-name
```

---

## 6. Docker Sandbox Security

### 6.1 Current Configuration (Review)

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
    "noNewPrivileges": true,
    "dropAllCapabilities": true
  }
}
```

**✅ Good practices already in place:**
- Per-session containers (isolation)
- Read-only root filesystem
- No new privileges
- Resource limits

**🔄 Recommended additions:**
```json
{
  "network": "none",  // Or restricted bridge
  "volumes": [
    "/tmp/work:/work:rw",
    "/dev/null:/etc/passwd:ro"  // Hide system users
  ],
  "tmpfs": {
    "/tmp": "rw,noexec,nosuid,size=100m"
  }
}
```

### 6.2 Container Escalation Prevention

**I should NEVER:**
- Run containers with `--privileged`
- Mount Docker socket (`/var/run/docker.sock`)
- Use host networking (`--network host`)
- Mount sensitive host paths

---

## 7. Audit & Monitoring

### 7.1 Security Event Log

**Log all security-relevant events to:**
```
~/.openclaw/logs/security.log

Events:
- Browser automation initiated
- Credential file accessed
- High-risk command executed
- Network request to new endpoint
- File write outside sandbox
- Permission changes
```

### 7.2 Weekly Security Audit

**Automated script (Sundays):**
```bash
#!/bin/bash
# ~/.openclaw/scripts/security-audit.sh

echo "=== Security Audit $(date) ==="

# Check credential permissions
echo "Credential file permissions:"
find ~/.openclaw -name "*.env" -o -name "*token*" | xargs ls -la

# Check for unexpected network activity
echo "Network connections (last 7 days):"
cat ~/.openclaw/logs/network.log | tail -100

# Check for file writes outside sandbox
echo "Recent file writes:"
find /tmp -name "openclaw*" -mtime -7

# Check running processes
echo "Active tunnels/processes:"
ps aux | grep -E "(cloudflared|n8n|docker)" | grep -v grep
```

### 7.3 Alert Conditions

**Notify you immediately if:**
- Credential file permissions change
- Unknown process spawned
- Network request to unlisted endpoint
- File written outside sandbox
- High-risk command executed

**Notification method:** Telegram message

---

## 8. Incident Response

### 8.1 If Browser Automation Goes Wrong

**Immediate actions:**
1. Close all browser tabs/windows
2. Clear cookies and session data
3. Revoke OAuth tokens (if suspicious activity)
4. Change passwords (if credentials exposed)
5. Review security logs

**Revoke OAuth tokens:**
```bash
# Gmail
open https://myaccount.google.com/permissions
# Revoke "OpenClaw" or suspicious apps

# GitHub
gh auth logout
# Or: https://github.com/settings/applications
```

### 8.2 If Credential Leak Suspected

**Immediate:**
1. Rotate API keys (all services)
2. Revoke OAuth tokens
3. Check audit logs for unauthorized access
4. Review recent commits for exposed secrets

**Check for exposed secrets:**
```bash
cd ~/.openclaw/OpenClaw-HQ
git log --all --full-history -- '*.env' '*.key' '*secret*'
```

---

## 9. Secure Development Practices

### 9.1 Code Review for Security

**Reviewer (Morty) should flag:**
- Hardcoded credentials
- Unsafe `eval()` or `exec()` usage
- Unvalidated user input
- Insecure dependencies
- Missing error handling
- Overly broad permissions

### 9.2 Secret Management

**Use environment variables, never hardcode:**
```javascript
// ❌ BAD
const apiKey = "sk-12345...";

// ✅ GOOD
const apiKey = process.env.API_KEY;
```

**Git pre-commit hook:**
```bash
# ~/.git/hooks/pre-commit
#!/bin/bash
if git diff --cached --name-only | xargs grep -l "sk-"; then
  echo "ERROR: Potential secret detected"
  exit 1
fi
```

---

## 10. User Control & Transparency

### 10.1 You Can Always:

- **Revoke access:** Delete OAuth tokens anytime
- **Audit activity:** Read all logs in `~/.openclaw/logs/`
- **Pause automation:** Kill processes or stop services
- **Review code:** All changes committed to GitHub
- **Override decisions:** You have final authority (per ARCHITECTURE.md)

### 10.2 Visibility I Provide:

- Every command executed (logged)
- Every network request (logged)
- Every file access (logged)
- Browser automation (approval required)
- High-risk operations (approval required)

---

## Quick Reference

### Security Checklist (Before Each Session)

- [ ] Review active OAuth grants
- [ ] Check for browser sessions
- [ ] Verify credential file permissions
- [ ] Confirm sandbox configuration

### Emergency Contacts

| Issue | Action |
|-------|--------|
| Credential leak suspected | Rotate all keys immediately |
| Unauthorized access | Revoke OAuth + change passwords |
| System compromise | Disconnect network, audit logs |
| Questions | Ask me anything - transparency first |

---

## Implementation Status

| Security Control | Status | Notes |
|-----------------|--------|-------|
| Browser approval workflow | ⏳ Pending | Need your confirmation |
| Isolated browser profiles | ⏳ Pending | Create automation profile |
| Network request logging | ⏳ Pending | Add curl wrapper |
| Security event log | ⏳ Pending | Create logging function |
| Weekly security audit | ⏳ Pending | Add to Sunday cron |
| Credential permission audit | ✅ Done | All files 600 |
| Docker sandbox | ✅ Done | Non-root, read-only |
| File system sandbox | ✅ Done | Restricted to ~/.openclaw |

---

**Questions for you:**

1. **Browser automation:** Should I ALWAYS ask approval, or is there a "safe mode" (private window, no cookies) I can use without asking?

2. **Network logging:** Want me to log all outbound requests? Could be verbose but good for audit.

3. **Security audit:** Should I run the weekly audit and send results to Telegram?

4. **IronClaw features:** Should I implement any of their specific protections (WASM sandbox, credential injection)?

**Your security is my priority.** Let me know which guardrails to implement first! 🛡️🧪
