# MEMORY.md - OpenClaw HQ Implementation

**Status:** ✅ Active Implementation  
**Last Updated:** 2026-02-12  
**Maintained by:** Brain Agent (Rick)

---

## Our Implementation: OpenClaw Native Memory (Option 1)

We use **Markdown files in agent workspace** with the following architecture:

```
~/.openclaw/
├── MEMORY.md                    # This file - system overview
├── memory/                      # Daily logs and system docs
│   ├── MEMORY_SYSTEM.md        # Implementation guide
│   ├── 2026-02-11.md           # Session log
│   ├── 2026-02-12.md           # Session log
│   ├── _TODAY.md → 2026-02-12.md  # Symlink to current
│   └── _WEEK-06.md             # Weekly summary (auto)
└── OpenClaw-HQ/                # Git repo
    ├── MEMORY.md               # Long-term knowledge (this file)
    ├── ARCHITECTURE.md         # System design
    ├── CONFIG.md               # Setup summary
    └── memory/                 # Synced from ~/.openclaw/memory/
```

---

## 3-Layer Memory Architecture

### Layer 1: Working Memory (Context Window)
- **Storage:** RAM / OpenClaw context window
- **Lifespan:** Single conversation
- **Purpose:** Active reasoning, immediate decisions
- **Auto-compaction:** At 50 messages or 2 hours

### Layer 2: Session Memory (Daily Logs)
- **Storage:** `memory/YYYY-MM-DD.md`
- **Lifespan:** Days to weeks
- **Auto-archive:** After 30 days → weekly summary
- **Purpose:** Short-term continuity

### Layer 3: Long-Term Memory (Persistent Knowledge)
- **Storage:** `MEMORY.md` + `OpenClaw-HQ/*.md`
- **Lifespan:** Permanent
- **Purpose:** Architecture, patterns, preferences
- **Sync:** GitHub (source of truth)

---

## Memory Types We Use

### 1. Episodic Memory → Daily Logs
**Files:** `memory/YYYY-MM-DD.md`

Captures:
- What was done in each session
- Decisions made and why
- Blockers and resolutions
- Context for next session

**Template:** See `memory/MEMORY_SYSTEM.md`

### 2. Semantic Memory → Config Files
**Files:** `CONFIG.md`, `ARCHITECTURE.md`, `AGENTS.md`

Captures:
- Technology stack decisions
- API configurations
- Integration details
- Security boundaries

### 3. Procedural Memory → SKILL.md Files
**Files:** `SKILL.md` in skill directories

Captures:
- How to use tools
- Deployment procedures
- Common debugging steps

### 4. Preferences → AGENTS.md + Daily Logs
**Files:** `AGENTS.md`, `memory/*.md`

Captures:
- User preferences (code style, communication)
- Cost constraints ($60-80/month target)
- Approval requirements

---

## Compression Strategy

### Auto-Compact Triggers
| Trigger | Threshold | Action |
|---------|-----------|--------|
| Message count | > 50 messages | Compress to summary |
| Meaningful resolution | Significant decisions made | Compress immediately |
| Token buffer | > 8000 tokens OR approaching 100% | Pre-compaction flush |
| Context switches | > 3 topics | Write decision log |
| Session duration | > 2 hours | Archive working context |
| User request | "wrap up" / "summarize" / "remember this" | Immediate compaction |

**Note on token limits:** When context hits 100% (e.g., 262k/262k tokens), older messages are truncated and lost. Proactive compression before this prevents amnesia.

### What Gets Preserved
**KEEP:**
- ✅ Final decisions and outcomes
- ✅ Configuration changes
- ✅ Error fixes and solutions
- ✅ API endpoints and URLs
- ✅ Blockers and how resolved
- ✅ User preferences revealed

**DISCARD:**
- ❌ Back-and-forth clarification
- ❌ Failed attempts (unless educational)
- ❌ Status checks
- ❌ Repeated explanations

---

## Automatic Memory Flush (Pre-Compaction)

**How it works:**
1. When conversation approaches 50 messages
2. System prompts: "Session nearing compaction. Store durable memories."
3. I write important context to daily log
4. Continue with compressed context

**What I write before compaction:**
- Decisions made in this conversation
- Configuration changes
- Important user preferences
- Blockers resolved
- Next steps agreed

---

## Weekly Summary System

### Cron Job: Every Sunday 9:00 AM
**Sends to:** Telegram (@FelipeEche27)

**Content:**
```
📊 Weekly Summary (Week 06)

🎯 Focus Areas:
- OpenClaw setup completion
- GitHub integration
- Memory system implementation

✅ Completed:
- Docker Desktop + n8n
- Gmail OAuth
- GitHub CLI auth
- CONFIG.md documentation
- Memory system with daily logs

⏳ In Progress:
- DNS propagation for n8n domain
- Weekly summary automation

💰 Cost Status:
- Target: $60-80/month
- Current week: ~$X

🔜 Next Week:
- [Pending]

📁 Full logs: https://github.com/mortylobster-droid/OpenClaw-HQ/tree/main/memory
```

### How It's Generated
1. Collect all daily logs from past week
2. Extract completed items, decisions, blockers
3. Calculate cost metrics
4. Generate summary Markdown
5. Send via Telegram bot
6. Archive daily logs to `memory/archive/2026-02/`

---

## Memory Search

### Current: Text Search (No Vector DB)
```bash
# Search all memory files
rg "gmail" ~/.openclaw/memory/

# With context
rg -B2 -A2 "oauth" ~/.openclaw/memory/

# Today's log
cat ~/.openclaw/memory/_TODAY.md

# Recent sessions
ls -lt ~/.openclaw/memory/*.md | head -10
```

### Future: Vector Search (Optional)
**If we add later:**
- Provider: Gemini embeddings (free tier: 1M req/day)
- Index: MEMORY.md + last 30 days
- Storage: SQLite or ChromaDB
- Cost: ~$0

---

## Git Sync Strategy

### Proactive Push (User Request)
**I push when significant context:**
- ✅ Architecture decisions documented
- ✅ Configuration changes
- ✅ Daily logs with important outcomes
- ✅ Weekly summaries
- ✅ Error fixes with solutions

**Don't push:**
- ❌ Routine status checks
- ❌ Temporary debugging
- ❌ Single-line updates

### Git Workflow
```bash
# Daily (automated or manual)
cd ~/.openclaw/OpenClaw-HQ
git add memory/
git commit -m "memory: Update daily logs $(date +%Y-%m-%d)"
git push origin main

# Weekly summary
git add memory/
git commit -m "memory: Week $(date +%U) summary"
git push origin main
```

---

## Session Handoff Protocol

### At Session Start (I will do this)
1. Read `memory/_TODAY.md` (today's context)
2. Read `memory/YYYY-MM-DD.md` (yesterday)
3. Check `MEMORY.md` for relevant sections
4. Summarize: "Last time we [X], next is [Y]"

### At Session End (I will do this)
1. Write/update `memory/YYYY-MM-DD.md`
2. Update `_TODAY.md` symlink
3. Push to GitHub if significant
4. Confirm: "Memory updated in [file]"

---

## Active Memories

### Architecture Decisions
| Date | Decision | Rationale | Status |
|------|----------|-----------|--------|
| 2026-02-11 | Kimi K2.5 primary | 76.8% SWE-bench, 80% cheaper | ✅ Active |
| 2026-02-11 | Brain exclusive Gmail | Security - trusted device | ✅ Enforced |
| 2026-02-11 | Reviewer read-only | Quality gate only | ✅ Policy |
| 2026-02-12 | 50-msg auto-compact | Balance detail vs efficiency | ✅ Active |
| 2026-02-12 | Proactive Git push | Keep source of truth updated | ✅ Active |

### User Preferences
- **Code style:** Functional > OOP, explicit > implicit
- **Responses:** Concise, no unnecessary explanations
- **Cost target:** $60-80/month
- **Communication:** Telegram preferred
- **Git strategy:** Proactive push on significant context
- **Memory:** Daily logs + weekly summaries

### Integration Status
All documented in `CONFIG.md`:
- Kimi K2.5 (primary model)
- Telegram bot
- Brave Search API
- Gmail OAuth
- Docker Desktop + sandbox
- n8n workflow automation
- GitHub CLI
- Cloudflare tunnel

---

## Metrics to Track

### Weekly Review
- [ ] % sessions with memory updates
- [ ] Number of architecture decisions documented
- [ ] Cost vs. budget ($60-80/month)
- [ ] Memory search hit rate
- [ ] Git sync frequency

### Monthly Review
- [ ] Archive old daily logs (>30 days)
- [ ] Compress MEMORY.md if >100KB
- [ ] Review and update preferences
- [ ] Evaluate vector search need

---

## Troubleshooting

### "Can't find previous session context"
**Check:**
1. `ls ~/.openclaw/memory/*.md` - files exist?
2. `cat ~/.openclaw/memory/_TODAY.md` - symlink valid?
3. GitHub repo synced? `git log --oneline -5`

### "Memory files too large"
**Fix:**
1. Archive logs >30 days: `mv memory/2026-01-*.md memory/archive/2026-01/`
2. Compress weekly: Create `_WEEK-NN.md` summaries
3. Remove ephemeral content from MEMORY.md

### "Search not finding results"
**Fix:**
1. Use `rg` (ripgrep) instead of `grep` - faster, better
2. Search with context: `rg -C3 "keyword"`
3. Check file paths: `~/.openclaw/memory/` not `~/memory/`

---

## Quick Reference

### Commands
```bash
# Today's log
cat ~/.openclaw/memory/_TODAY.md

# Search memory
rg "keyword" ~/.openclaw/memory/

# Recent sessions
ls -lt ~/.openclaw/memory/*.md | head -5

# Push to GitHub
cd ~/.openclaw/OpenClaw-HQ && git add memory/ && git commit -m "memory: update" && git push

# Weekly summary (manual)
openclaw memory weekly-summary
```

### File Locations
| File | Path | Purpose |
|------|------|---------|
| Today's log | `~/.openclaw/memory/_TODAY.md` | Current session |
| Daily logs | `~/.openclaw/memory/YYYY-MM-DD.md` | Session history |
| System guide | `~/.openclaw/memory/MEMORY_SYSTEM.md` | Implementation |
| Long-term | `~/.openclaw/OpenClaw-HQ/MEMORY.md` | This file |
| Config | `~/.openclaw/OpenClaw-HQ/CONFIG.md` | Setup summary |

---

## Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| Daily logs | ✅ Active | Template created, using daily |
| Auto-compact (50 msg) | ✅ Active | Trigger set |
| Git sync | ✅ Active | Proactive push on significant context |
| Weekly summaries | ⏳ Pending | Cron job to be set up |
| Vector search | ⏳ Future | Can add Gemini embeddings later |
| Episodic Memory plugin | ❌ Not used | Claude Code specific |
| Supermemory | ❌ Not used | Cloud dependency |
| Agent Memory MCP | ❌ Not used | Overkill for current needs |

---

*This is a living document. Updated as system evolves.*  
*Last significant update: 2026-02-12 - Memory system implementation*
