# BACKUP.md

Backup and recovery strategy for OpenClaw HQ.

This document defines how to keep redundant copies of the repository, memory systems, and critical configurations so that no single machine or service failure can destroy your system.

The goal is simple:

- Always have at least two independent copies of critical data
- Make restoration trivial
- Avoid manual heroics during incidents
- Preserve both code AND memory

This applies to Brain (Mac mini), Reviewer (Linux VPS), and all cloud mirrors.

Felipe owns backup policy and has final authority on recovery procedures.

---

## Principles

1. **GitHub is the primary source of truth** for code and documentation
2. **At least one secondary cloud mirror** must exist
3. **Brain (Mac mini) must always keep a local clone** with full memory
4. **Reviewer (VPS) keeps a working clone** but is considered disposable infrastructure
5. **Memory systems must be backed up separately** (not all memory lives in Git)
6. **Recovery must be possible from any single surviving copy**

Never rely on only one machine or one provider.

---

## What Needs Backup

### Critical (Must Never Lose)

1. **Git Repository:**
   - All code
   - Architecture documents
   - AGENTS.md, SKILLS.md, MEMORY.md (documentation)
   - /FELIPE folder (strategic planning)
   - Automation definitions (n8n workflows)

2. **Memory Systems:**
   - `workspace/MEMORY.md` (long-term knowledge)
   - `workspace/REVIEW_MEMORY.md` (review findings)
   - `workspace/memory/*.md` (session logs, at least last 30 days)
   - Episodic memory database (if using obra/episodic-memory)
   - Memory indexes and embeddings

3. **Configuration:**
   - OpenClaw config files
   - n8n workflow exports
   - Environment variable templates (NOT the values, those go in password manager)

### Important (Should Backup)

4. **Credentials & Secrets:**
   - Store in password manager (1Password, Bitwarden, etc.)
   - Never commit to Git
   - Keep encrypted backup of password manager vault

5. **n8n Data:**
   - Workflow JSONs (committed to Git)
   - Execution history (optional, keep last 30 days)
   - Credentials vault (encrypted export)

### Nice to Have

6. **Conversation Archives:**
   - Full conversation history (if using episodic-memory)
   - Chat logs from Telegram/Discord
   - PR review history (already in GitHub)

---

## Backup Architecture

```
                    ┌─────────────────────┐
                    │   GitHub (Primary)  │
                    │   Source of Truth   │
                    └──────────┬──────────┘
                               │
          ┌────────────────────┼────────────────────┐
          │                    │                    │
          ▼                    ▼                    ▼
          
  ┌───────────────┐    ┌──────────────┐    ┌──────────────┐
  │  Mac mini     │    │  Linux VPS   │    │  GitLab      │
  │  (Brain)      │    │  (Reviewer)  │    │  (Mirror)    │
  │               │    │              │    │              │
  │  • Full clone │    │  • Working   │    │  • Full      │
  │  • Memory DB  │    │    clone     │    │    mirror    │
  │  • Local Time │    │  • Disposable│    │  • Automated │
  │    Machine    │    │              │    │    push      │
  └───────────────┘    └──────────────┘    └──────────────┘
          │                                        │
          │                                        │
          └────────────────┬───────────────────────┘
                           │
                           ▼
                  ┌─────────────────┐
                  │  Password Mgr   │
                  │  (1Password)    │
                  │                 │
                  │  • API keys     │
                  │  • Credentials  │
                  │  • Secrets      │
                  └─────────────────┘

Recovery possible from ANY surviving copy
```

---

## Primary Repository (GitHub)

The main GitHub repository is the canonical system state.

**Contains:**
- All code and automation
- Architecture documents
- Memory documentation (MEMORY.md)
- Committed memory files (workspace/MEMORY.md, workspace/REVIEW_MEMORY.md)
- /FELIPE folder
- n8n workflow definitions

**Location:** `https://github.com/YOUR_ORG/openclaw-hq`

**Access:** Brain and Reviewer both push here

**Critical rule:** If GitHub is reachable, this is always the first recovery point.

### What Gets Committed

**✅ Always commit:**
- Code and documentation
- `workspace/MEMORY.md` (long-term knowledge)
- `workspace/REVIEW_MEMORY.md` (review findings)
- Memory docs older than 7 days (for historical record)
- n8n workflow JSONs
- Configuration templates (`.env.example`)

**⚠️ Commit selectively:**
- Daily memory logs (`workspace/memory/YYYY-MM-DD.md`) - commit weekly, not daily

**❌ Never commit:**
- Credentials or API keys
- `.env` files with real secrets
- Password database files
- Episodic memory SQLite database (too large, not Git-friendly)
- n8n credentials vault (contains secrets)

---

## Secondary Cloud Mirror (Required)

Create a second private repository on a different provider or GitHub org.

**Purpose:**
- Protection against GitHub outages
- Protection against account compromise
- True redundancy

**Options:**
1. GitLab private repo (recommended - different company)
2. Bitbucket private repo
3. Second GitHub org/account (less ideal - same provider)

**This mirror is backup-only** - not used for day-to-day development.

### Setup

On Brain (Mac mini):

```bash
# Add backup remote
cd ~/openclaw-hq
git remote add backup https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git

# Initial push
git push backup main

# Verify
git remote -v
```

### Maintenance

**Manual (minimum):**
```bash
# Push to backup after major changes
git push backup main
```

**Automated (recommended):**

Create daily backup script on Mac mini:

```bash
# ~/scripts/backup-repo.sh
#!/bin/bash
cd ~/openclaw-hq
git push backup main --all
git push backup main --tags

echo "$(date): Backup pushed to GitLab" >> ~/logs/backup.log
```

Make executable:
```bash
chmod +x ~/scripts/backup-repo.sh
```

Schedule with launchd (macOS) or add to cron:

```bash
# Run daily at 2 AM
0 2 * * * ~/scripts/backup-repo.sh
```

---

## Brain (Mac mini) - Critical Backup

The Mac mini is the **most important backup** because it stores:
- Full Git repository
- Complete memory database (episodic-memory)
- All conversation history
- OpenClaw workspace with session data

### Setup

**1. Full Git Clone:**
```bash
cd ~
git clone https://github.com/YOUR_ORG/openclaw-hq.git
cd openclaw-hq
git remote add backup https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git
```

**2. Memory System Backup:**

If using **episodic-memory**:
```bash
# Memory DB location
~/.config/superpowers/conversations-archive/

# Backup strategy
# Option A: Time Machine (includes this directory)
# Option B: Manual sync to external drive weekly
rsync -av ~/.config/superpowers/ /Volumes/Backup/episodic-memory/

# Option C: Cloud sync (if not sensitive)
# Use rclone or similar to sync to encrypted cloud storage
```

If using **OpenClaw native memory**:
```bash
# Memory location
~/.openclaw/workspace/

# Already in Git if committed regularly
# Additional safety: Time Machine backup
```

**3. macOS Time Machine (Recommended):**

Enable Time Machine to back up entire Mac mini including:
- Git repositories
- Memory databases
- OpenClaw workspace
- Configuration files

Connect external drive and enable Time Machine:
```
System Settings → General → Time Machine → Add Backup Disk
```

This gives you **Git backup + disk backup + cloud mirror** = triple redundancy.

### Daily Maintenance

Brain should automatically sync on session start. Verify manually:

```bash
cd ~/openclaw-hq
git status  # Should be clean or ahead
git pull    # Get latest from team (if applicable)
git push    # Push local changes

# Push to backup mirror (automated or manual)
git push backup main
```

---

## Reviewer (Linux VPS) - Working Clone

The VPS is **disposable infrastructure** - if lost, it can be recreated from Git.

### Setup

```bash
# Clone repository
cd ~
git clone https://github.com/YOUR_ORG/openclaw-hq.git
cd openclaw-hq

# Verify connection
git remote -v
```

### Maintenance

Reviewer pulls before each review session:

```bash
cd ~/openclaw-hq
git pull
```

**No backup responsibility** - VPS is rebuilt from Git if lost.

### Optional: Automated Backup Push

If you want VPS to push to backup mirror (redundant but harmless):

```bash
# Add backup remote
git remote add backup https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git

# Cron job (daily at 3 AM)
0 3 * * * cd ~/openclaw-hq && git push backup main 2>&1 | logger -t git-backup
```

---

## Memory System Backups

Memory requires special handling because not all of it lives in Git.

### Episodic Memory (obra/episodic-memory)

**Location:** `~/.config/superpowers/conversations-archive/`

**Contents:**
- SQLite database with vector embeddings
- Indexed conversation history
- Semantic search index

**Backup strategy:**

**Option 1: Time Machine (macOS)**
```bash
# Automatic - Time Machine includes ~/.config/
# No action needed if Time Machine enabled
```

**Option 2: Manual Sync to External Drive**
```bash
# Weekly backup script
#!/bin/bash
rsync -av --delete \
  ~/.config/superpowers/conversations-archive/ \
  /Volumes/Backup/episodic-memory/

echo "$(date): Episodic memory backed up" >> ~/logs/memory-backup.log
```

**Option 3: Encrypted Cloud Sync**
```bash
# Using rclone to encrypted remote
rclone sync ~/.config/superpowers/conversations-archive/ \
  encrypted-remote:episodic-memory/
```

**Recovery:**
```bash
# Restore from backup
rsync -av /Volumes/Backup/episodic-memory/ \
  ~/.config/superpowers/conversations-archive/

# Re-index if needed
episodic-memory index --force
```

### OpenClaw Native Memory

**Location:** `~/.openclaw/workspace/`

**Contents:**
- MEMORY.md (committed to Git)
- memory/*.md (daily logs, selectively committed)

**Backup strategy:**

**Git is primary backup:**
```bash
# Memory files already in repo
workspace/MEMORY.md
workspace/REVIEW_MEMORY.md
workspace/memory/YYYY-MM-DD.md
```

**Commit policy:**
- Commit MEMORY.md on every significant update
- Commit daily logs weekly (not every day - too noisy)
- Commit REVIEW_MEMORY.md after each review cycle

**Recovery:**
```bash
# Restore from Git
git pull
# Memory files restored automatically
```

### Supermemory (Cloud-based)

**Location:** Supermemory cloud servers

**Backup strategy:**

**Export API:**
```bash
# Export all memories (if API supports)
curl -H "Authorization: Bearer $SUPERMEMORY_API_KEY" \
  https://api.supermemory.ai/v1/export > memories-backup.json

# Store in Git (if not too large)
git add backups/memories-$(date +%Y-%m-%d).json
git commit -m "backup: export Supermemory data"
```

**No local backup needed** - cloud provider handles redundancy.

**Risk mitigation:** Export monthly and commit to Git.

---

## n8n Workflow Backups

n8n workflows must be backed up separately from execution data.

### Workflow Definitions (Critical)

**Backup strategy:**

1. **Export workflows as JSON:**
```bash
# From n8n UI: Settings → Export
# Save to: automations/n8n/workflows/

automations/n8n/workflows/
├── email-automation.json
├── github-webhook.json
├── daily-report.json
└── ...
```

2. **Commit to Git:**
```bash
git add automations/n8n/workflows/*.json
git commit -m "backup: export n8n workflows"
git push
git push backup main
```

**Frequency:** After every workflow change

### Credentials Vault (Sensitive)

n8n stores credentials in encrypted database.

**Backup strategy:**

**Option 1: Encrypted Export**
```bash
# Export credentials (encrypted)
# From n8n UI: Settings → Credentials → Export
# Save outside Git in password manager as attachment
```

**Option 2: Document in Password Manager**
```
1Password vault entry: "n8n Credentials"
- GitHub API Key: ghp_...
- Gmail OAuth: ...
- Supabase Key: ...
```

**Never commit credentials to Git!**

### Execution History (Optional)

Execution logs can be large - keep only recent data.

**Retention policy:**
- Keep last 30 days in n8n database
- Export critical executions manually if needed
- Don't back up routine execution logs

---

## Credentials & Secrets Backup

**Never store in Git.** Use password manager.

### Recommended: 1Password (or Bitwarden)

**Store:**
- All API keys (OpenRouter, Gemini, Brave Search, etc.)
- Database credentials
- OAuth tokens
- n8n credentials export (as secure attachment)
- Gmail password / app-specific password
- GitHub personal access tokens

**Backup:**
- 1Password handles cloud sync automatically
- Export emergency kit (encrypted backup)
- Store emergency kit in physical safe or separate location

### Environment Variables Template

Commit template to Git, actual values in password manager:

**`.env.example` (committed):**
```bash
# OpenRouter
OPENROUTER_API_KEY=your_key_here

# Gemini
GEMINI_API_KEY=your_key_here

# Database
DATABASE_URL=postgresql://user:password@host:5432/dbname

# n8n
N8N_ENCRYPTION_KEY=your_key_here
```

**`.env` (gitignored, never committed):**
```bash
# Real values from password manager
OPENROUTER_API_KEY=sk_or_actual_key_123abc
GEMINI_API_KEY=AIza...
DATABASE_URL=postgresql://real_user:real_pass@...
```

---

## Recovery Procedures

### Scenario 1: GitHub Down or Compromised

**Impact:** Primary repo unavailable

**Recovery:**

1. **Work from Mac mini local clone:**
   ```bash
   cd ~/openclaw-hq
   # Continue working locally
   git commit -am "work: continued during GitHub outage"
   ```

2. **Push to backup mirror:**
   ```bash
   git push backup main
   ```

3. **When GitHub returns:**
   ```bash
   git push origin main
   ```

**Downtime:** Zero (local work continues)

---

### Scenario 2: Mac Mini Lost or Damaged

**Impact:** Brain agent offline, local memory lost

**Recovery:**

1. **Clone from GitHub to new machine:**
   ```bash
   # On new Mac
   git clone https://github.com/YOUR_ORG/openclaw-hq.git
   cd openclaw-hq
   git remote add backup https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git
   ```

2. **Restore memory from Time Machine (if available):**
   ```bash
   # Connect Time Machine backup drive
   # Restore ~/.config/superpowers/ (episodic-memory)
   # Restore ~/.openclaw/workspace/ (native memory)
   ```

3. **If no Time Machine, restore from Git:**
   ```bash
   # Memory files already in repo
   # workspace/MEMORY.md restored automatically
   # Recent session logs available
   ```

4. **Restore credentials:**
   ```bash
   # Get from password manager
   # Create .env file with real values
   ```

5. **Resume work:**
   ```bash
   # OpenClaw should work with restored files
   # Memory intact (from Git or Time Machine)
   ```

**Downtime:** 1-2 hours (setup new machine)

**Data loss:** None if Time Machine backup exists, minimal if not (only very recent session data)

---

### Scenario 3: VPS Lost or Destroyed

**Impact:** Reviewer agent offline, automation stopped

**Recovery:**

1. **Create new VPS:**
   ```bash
   # Ubuntu/Debian
   apt update && apt upgrade -y
   apt install -y git nodejs npm
   ```

2. **Clone repository:**
   ```bash
   cd ~
   git clone https://github.com/YOUR_ORG/openclaw-hq.git
   cd openclaw-hq
   ```

3. **Install dependencies:**
   ```bash
   npm install
   ```

4. **Restore environment variables:**
   ```bash
   # Get from password manager
   nano .env
   # Paste real values
   ```

5. **Restart services:**
   ```bash
   # n8n, automation workers, etc.
   npm start
   ```

**Downtime:** 30-60 minutes (recreate VPS)

**Data loss:** None (VPS is stateless, everything in Git)

---

### Scenario 4: Complete Disaster (All Systems Lost)

**Impact:** GitHub compromised, Mac mini destroyed, VPS gone

**Recovery:**

**Prerequisites:**
- GitLab backup mirror exists
- Password manager vault accessible
- Time Machine backup (optional but helps)

**Steps:**

1. **Restore from GitLab mirror:**
   ```bash
   # On any new machine
   git clone https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git openclaw-hq
   cd openclaw-hq
   
   # Re-create GitHub repo (if compromised)
   # Add as remote
   git remote add origin https://github.com/YOUR_ORG/openclaw-hq-new.git
   git push origin main
   ```

2. **Restore credentials from password manager**

3. **Restore memory from Time Machine (if available)**

4. **Rebuild infrastructure:**
   - New Mac mini for Brain
   - New VPS for Reviewer
   - Redeploy n8n

**Downtime:** Several hours to 1 day

**Data loss:** Minimal (GitLab has all code + committed memory, only very recent uncommitted work lost)

---

## Backup Verification

Don't assume backups work - test them!

### Weekly Checks

```bash
# 1. Verify GitHub is up to date
cd ~/openclaw-hq
git status  # Should be clean or only uncommitted local work

# 2. Verify backup mirror in sync
git fetch backup
git log backup/main  # Should match origin/main

# 3. Check memory files exist
ls -lh workspace/MEMORY.md
ls -lh workspace/memory/

# 4. If using episodic-memory, verify index
episodic-memory stats
```

### Monthly Tests

```bash
# 1. Test clone from backup mirror
cd /tmp
git clone https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git test-restore
cd test-restore
# Verify files present

# 2. Test memory restore
cp -r workspace/MEMORY.md /tmp/memory-test.md
# Verify readable

# 3. Clean up
rm -rf /tmp/test-restore /tmp/memory-test.md
```

### Quarterly Full Recovery Test

Once per quarter, simulate complete disaster:

1. **Create fresh VM or directory**
2. **Clone from backup mirror** (don't use primary GitHub)
3. **Restore credentials** from password manager
4. **Restore memory** from Time Machine or Git
5. **Verify OpenClaw runs**
6. **Verify memory search works**
7. **Document any issues**

This ensures your recovery procedures actually work.

---

## Backup Checklist

### Daily (Automated)

- [ ] Brain pulls latest from GitHub
- [ ] Brain pushes commits to GitHub
- [ ] Automated backup push to GitLab mirror (cron)
- [ ] VPS pulls latest (before review sessions)

### Weekly

- [ ] Commit `workspace/MEMORY.md` if updated
- [ ] Commit recent daily logs to Git
- [ ] Verify backup mirror in sync
- [ ] Export n8n workflows (if changed)

### Monthly

- [ ] Test clone from backup mirror
- [ ] Test memory restore
- [ ] Export Supermemory data (if using)
- [ ] Verify Time Machine backups running
- [ ] Review password manager vault

### Quarterly

- [ ] Full disaster recovery drill
- [ ] Update backup procedures documentation
- [ ] Review what's excluded from backup (should anything be added?)
- [ ] Audit credentials in password manager

---

## Automation Scripts

### Daily Backup Script (Mac mini)

```bash
#!/bin/bash
# ~/scripts/daily-backup.sh

REPO_PATH="$HOME/openclaw-hq"
LOG_FILE="$HOME/logs/backup.log"

echo "$(date): Starting daily backup" >> "$LOG_FILE"

cd "$REPO_PATH" || exit 1

# Pull latest
git pull origin main >> "$LOG_FILE" 2>&1

# Push to backup
git push backup main --all >> "$LOG_FILE" 2>&1
git push backup main --tags >> "$LOG_FILE" 2>&1

# Backup episodic memory (if using)
if [ -d "$HOME/.config/superpowers/conversations-archive" ]; then
  rsync -av --delete \
    "$HOME/.config/superpowers/conversations-archive/" \
    "/Volumes/Backup/episodic-memory/" >> "$LOG_FILE" 2>&1
  echo "$(date): Episodic memory backed up" >> "$LOG_FILE"
fi

echo "$(date): Daily backup complete" >> "$LOG_FILE"
```

### Weekly Memory Commit Script

```bash
#!/bin/bash
# ~/scripts/weekly-memory-commit.sh

REPO_PATH="$HOME/openclaw-hq"
WEEK_AGO=$(date -v-7d +%Y-%m-%d)

cd "$REPO_PATH" || exit 1

# Commit memory files older than 7 days
git add workspace/MEMORY.md
git add workspace/REVIEW_MEMORY.md
git add workspace/memory/*[0-9].md

git commit -m "backup: weekly memory commit ($WEEK_AGO)"
git push origin main
git push backup main

echo "$(date): Weekly memory committed"
```

### Schedule with launchd (macOS)

Create `~/Library/LaunchAgents/com.openclaw.backup.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.openclaw.backup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/YOUR_USERNAME/scripts/daily-backup.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>2</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
</dict>
</plist>
```

Load:
```bash
launchctl load ~/Library/LaunchAgents/com.openclaw.backup.plist
```

---

## Summary

**You maintain:**

1. **GitHub primary repo** (canonical source of truth)
2. **GitLab backup mirror** (secondary cloud redundancy)
3. **Mac mini local clone** (with full memory and Time Machine)
4. **VPS working clone** (disposable, rebuilt from Git)
5. **Password manager vault** (all credentials and secrets)

**Recovery is possible from:**
- GitHub alone
- GitLab mirror alone
- Mac mini Time Machine alone
- Any combination of the above

**This gives you true redundancy with minimal complexity.**

**The golden rule:** If it's not in at least two places, it doesn't exist.

---

End of file.
