# Memory System Implementation Guide

**For:** Brain Agent (Rick) + Reviewer Agent (Morty)  
**Purpose:** Maximum context retention with efficient compression

---

## Quick Start: Memory Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│  LAYER 3: LONG-TERM MEMORY (Permanent)                      │
│  ─────────────────────────────────────                      │
│  File: MEMORY.md                                            │
│  Content: Architecture, decisions, patterns, preferences    │
│  Update: When durable facts change                          │
│  Frequency: Weekly or after major milestones                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 2: SESSION MEMORY (Daily Logs)                       │
│  ─────────────────────────────────────                      │
│  File: memory/YYYY-MM-DD.md                                 │
│  Content: Daily progress, decisions, blockers, next steps   │
│  Update: End of each session or when context switches       │
│  Frequency: Daily                                           │
│  Auto-archive: After 30 days → compress to weekly summary   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  LAYER 1: WORKING MEMORY (Active Context)                   │
│  ─────────────────────────────────────                      │
│  File: memory/_TODAY.md (symlink to current day)            │
│  Content: Current task, active decisions, temp notes        │
│  Update: Real-time during conversation                      │
│  Lifespan: Current session only                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Daily Log Template (memory/YYYY-MM-DD.md)

```markdown
# 2026-02-12 - Session Summary

## Session Overview
**Started:** 00:15  
**Ended:** 02:30  
**Focus:** GitHub setup, CONFIG.md creation  
**Location:** Mac mini (Brain Agent)

---

## What We Did

### ✅ Completed
1. GitHub CLI authentication
   - Device flow: 2ACA-E6DF
   - Account: mortylobster-droid
   - Scopes: repo, workflow, gist, read:org

2. Cloned OpenClaw-HQ repository
   - Local path: ~/.openclaw/OpenClaw-HQ
   - Reviewed ARCHITECTURE-2.md and BRAINAGENT.md

3. Created CONFIG.md
   - Documented all 7 integrations
   - Pushed to GitHub: main branch
   - Commit: 0a41b20

### 🔄 In Progress
- Understanding 2-agent architecture

### ⏸️ Blocked/Paused
- n8n public URL (DNS propagating)

---

## Key Decisions

| Decision | Rationale | Status |
|----------|-----------|--------|
| Kimi K2.5 as primary | 76.8% SWE-bench, 80% cheaper than Sonnet | ✅ Confirmed |
| Brain on Mac mini only | Gmail auth restricted to trusted device | ✅ Enforced |
| Reviewer read-only | No build/push access | ✅ Policy set |

---

## Context for Next Session

### Active Task
Implement robust memory system per user request

### Background Needed
- Current MEMORY.md is comprehensive but theoretical
- Need practical daily log implementation
- User wants conversation compression strategy

### Open Questions
1. How often should I compress conversations?
2. What triggers a memory write vs. relying on compaction?
3. Should I proactively summarize at session end?

### Relevant Files
- ~/.openclaw/OpenClaw-HQ/MEMORY.md (architecture)
- ~/.openclaw/memory/2026-02-11.md (yesterday)
- ~/.openclaw/memory/2026-02-12.md (today - this file)

---

## Code/Config Changes

```
NEW: ~/.openclaw/OpenClaw-HQ/CONFIG.md
NEW: ~/.openclaw/memory/MEMORY_SYSTEM.md (this guide)
```

---

## Notes & Observations

- User prefers detailed documentation
- Cost-conscious but prioritizes quality
- Clear separation of concerns (Brain vs Reviewer vs Felipe)
- GitHub as source of truth is working well

---

## Next Session Priorities

1. [ ] Set up automated memory compression
2. [ ] Create memory search index
3. [ ] Test cross-session context retention
4. [ ] Document compression triggers

---

*Written by: Brain Agent (Rick)*  
*Reviewed by: N/A (daily log)*
```

---

## When to Write Memory

### ✅ ALWAYS Write
- **Major decisions** (architecture, tech stack, rejection of alternatives)
- **Integration setups** (API keys, OAuth, connections)
- **Security configurations** (credentials, permissions, boundaries)
- **Cost/policy changes** (model routing, budget alerts)
- **Debugging solutions** (fixes for recurring issues)

### 🔄 OFTEN Write (Daily Log)
- **Session summaries** (what was done, blockers, next steps)
- **Context switches** (when topic changes significantly)
- **Error resolutions** (how a problem was fixed)
- **User preferences revealed** ("I prefer X over Y")

### ⏭️ COMPACT Automatically
- **Routine operations** (checking status, simple queries)
- **Temporary debugging** (one-off investigations)
- **Clarification questions** (asking for more details)

---

## Conversation Compression Strategy

### Trigger Conditions for Compaction

```
COMPACT WHEN:
├── Conversation length > 50 messages
├── Session duration > 2 hours
├── Context switches > 3 times
├── User says "wrap up", "summarize", "let's continue tomorrow"
└── Memory buffer > 8000 tokens (OpenClaw internal limit)
```

### What to Preserve in Compaction

**KEEP (High Value):**
- ✅ Final decisions and outcomes
- ✅ Configuration changes
- ✅ Error fixes and solutions
- ✅ API keys/credentials (locations, not values)
- ✅ URLs and access methods
- ✅ Blockers and resolutions

**DISCARD (Low Value):**
- ❌ Back-and-forth clarification
- ❌ Failed attempts (unless educational)
- ❌ Status checks ("is it working?")
- ❌ Repeated explanations

### Compaction Format

```markdown
## Compacted: 2026-02-11 Session

**Original:** 47 messages, 3.5 hours  
**Summary:** Set up Docker, n8n, Gmail OAuth, GitHub auth  
**Key Outcomes:**
- Docker Desktop 29.2.0 installed
- n8n running at http://localhost:5678
- Gmail OAuth working (mortylobster@gmail.com)
- GitHub CLI authenticated (mortylobster-droid)
- CONFIG.md created and pushed

**Decisions Made:**
- Use HTTP mode for n8n (OAuth compatibility)
- Kimi K2.5 as primary model (confirmed)

**Blockers Resolved:**
- n8n Gmail OAuth → Added HTTP redirect URI
- GitHub auth → Device flow successful

**Next:** Implement memory system robustness

**Full log:** memory/2026-02-11.md
```

---

## Memory Search Strategy

### Without Vector Search (Current)

**Use grep/ripgrep for keyword search:**
```bash
# Search all memory files
rg "gmail" ~/.openclaw/memory/ ~/.openclaw/OpenClaw-HQ/

# Search with context
rg -B2 -A2 "oauth" ~/.openclaw/memory/

# Find recent daily logs
ls -lt ~/.openclaw/memory/ | head -10
```

**Use file structure for navigation:**
```
memory/
├── 2026-02-11.md          # Yesterday
├── 2026-02-12.md          # Today
├── _TODAY.md → 2026-02-12.md  # Symlink for quick access
├── _WEEK-06.md            # Weekly summary (auto-generated)
├── archive/               # Compressed old logs
│   ├── 2026-01/           # Monthly archive
│   └── 2025-12/
└── index.md               # Quick reference index
```

### With Vector Search (Future Enhancement)

**If we add embeddings later:**
- Use Gemini embeddings (free tier: 1M requests/day)
- Index: MEMORY.md + last 30 days of logs
- Query: Natural language semantic search
- Storage: SQLite or ChromaDB

**Cost:** ~$0 (Gemini embeddings free tier)  
**Setup:** One-time script to index files

---

## Session Handoff Protocol

### At Session End (I Will Do This)

```markdown
1. Write/update memory/YYYY-MM-DD.md
2. Update _TODAY.md symlink
3. Push changes to GitHub (if significant)
4. Summarize for user: "Memory updated in [file]"

Optional:
- Compact conversation if >50 messages
- Create weekly summary if Sunday
- Archive old logs (>30 days)
```

### At Session Start (I Will Do This)

```markdown
1. Read memory/YYYY-MM-DD.md (today's log)
2. Read memory/YYYY-MM-DD.md (yesterday's log)
3. Check MEMORY.md for relevant sections
4. Summarize context: "Last time we [X], next is [Y]"

Optional:
- Search for specific topics if user references them
- Load compressed session summaries if needed
```

---

## Proactive Memory Maintenance

### Weekly (Sundays)

```bash
# 1. Compress daily logs into weekly summary
# 2. Move old daily logs to archive/
# 3. Update MEMORY.md with any new patterns
# 4. Push all changes to GitHub
```

### Monthly (1st of month)

```bash
# 1. Create monthly summary from weekly summaries
# 2. Archive weekly summaries
# 3. Review MEMORY.md for outdated info
# 4. Update project roadmap if needed
```

---

## Implementation Checklist

- [x] Create memory/ directory structure
- [x] Create daily log template
- [x] Document compression strategy
- [x] Define write triggers
- [x] Set up session handoff protocol
- [ ] Create _TODAY.md symlink (auto-update)
- [ ] Set up weekly compression (cron)
- [ ] Add memory search aliases (optional)
- [ ] Consider vector search (future)

---

## Quick Commands

```bash
# View today's log
cat ~/.openclaw/memory/_TODAY.md

# Search all memory
rg "keyword" ~/.openclaw/memory/

# List recent sessions
ls -lt ~/.openclaw/memory/*.md | head -10

# Push memory to GitHub
cd ~/.openclaw/OpenClaw-HQ && git add memory/ && git commit -m "Update memory logs" && git push

# Compress old logs (weekly)
# (Script to be created)
```

---

**This system ensures:**
- ✅ No context loss between sessions
- ✅ Efficient storage (compressed old logs)
- ✅ Fast retrieval (structured + searchable)
- ✅ Human-readable (Markdown)
- ✅ Version controlled (Git)

**Questions for you:**
1. Should I auto-compact conversations >50 messages?
2. Should I proactively push memory to GitHub daily?
3. Want me to set up weekly summaries (cron)?
