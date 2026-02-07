# MEMORY.md

Memory systems and guidelines for OpenClaw HQ agents to maintain perfect recall, build contextual understanding, and preserve project knowledge across sessions.

This document synthesizes best practices from leading agent memory systems to ensure Brain and Reviewer agents never lose critical context.

---

## Table of Contents

1. [Why Memory Matters](#why-memory-matters)
2. [Memory Architecture](#memory-architecture)
3. [Memory Types](#memory-types)
4. [Implementation Options](#implementation-options)
5. [Memory Best Practices](#memory-best-practices)
6. [When to Write Memory](#when-to-write-memory)
7. [Memory Search & Retrieval](#memory-search--retrieval)
8. [Setup Instructions](#setup-instructions)

---

## Why Memory Matters

Traditional LLM interactions are stateless - each conversation starts from zero. This creates major problems for long-running projects:

**Without memory:**
- ❌ Agents forget previous decisions and their reasoning
- ❌ Developers waste time re-explaining context
- ❌ Solutions get repeated or contradicted
- ❌ Trade-offs and rejected alternatives are lost
- ❌ Project evolution and patterns become invisible

**With memory:**
- ✅ Agents remember "why" decisions were made, not just "what"
- ✅ Context persists across days, weeks, months
- ✅ Solutions build on previous work instead of starting over
- ✅ Agents avoid suggesting things already tried and rejected
- ✅ Continuity transforms agents from tools into true collaborators

**The Core Insight:**

> Code comments explain **what**, documentation explains **how**, but episodic memory preserves **why** - and that makes me a far more effective collaborator across sessions.
>
> _— Claude Sonnet 4.5, on episodic-memory_

Memory is the difference between a stateless tool and a collaborative partner who remembers your journey together.

---

## Memory Architecture

OpenClaw HQ uses a **hybrid memory system** with three layers:

### Layer 1: Working Memory (Context Window)

**What:** Current conversation and immediate task context

**Storage:** RAM / context window

**Lifespan:** Single session only

**Purpose:** Active reasoning and immediate decisions

**Example:** "The user just asked me to add authentication - I need these details right now"

### Layer 2: Session Memory (Daily Logs)

**What:** Day-to-day notes, running context, ephemeral decisions

**Storage:** `memory/YYYY-MM-DD.md` (Markdown files)

**Lifespan:** Days to weeks (auto-compacted)

**Purpose:** Short-term continuity across sessions on same day/week

**Example:** "Today we worked on the login flow - here's what we tried"

### Layer 3: Long-Term Memory (Persistent Knowledge)

**What:** Durable facts, architecture decisions, patterns, preferences

**Storage:** `MEMORY.md` + vector database for semantic search

**Lifespan:** Permanent (until explicitly deleted)

**Purpose:** Project-wide knowledge that survives months/years

**Example:** "We rejected OAuth because of compliance requirements - here's why"

---

## Memory Types

Following cognitive architecture principles, agents should organize memory into four types:

### 1. Episodic Memory

**Definition:** Specific events, conversations, and "episodes" from past interactions

**Stores:**
- What was discussed
- When it happened
- Why decisions were made
- What alternatives were considered

**Example:**
```markdown
## 2025-02-01: Authentication Implementation

**Decision:** Use JWT with 15-minute access tokens + 7-day refresh tokens

**Reasoning:**
- Considered session-based auth, but statelessness required for multiple servers
- 15-min expiry balances security vs. UX (not too frequent re-auth)
- Refresh tokens stored in httpOnly cookies to prevent XSS

**Rejected alternatives:**
- Longer access tokens (security risk)
- Session-based auth (doesn't scale horizontally)
- OAuth 2.0 flow (too complex for MVP)
```

### 2. Semantic Memory

**Definition:** Structured repository of facts, concepts, and general knowledge

**Stores:**
- Project requirements and constraints
- Technology stack decisions
- API endpoints and their contracts
- Database schema and relationships
- Environment variables and configuration

**Example:**
```markdown
## Tech Stack

- **Frontend:** React 18 + Next.js 14 (App Router)
- **Backend:** Node.js + Express + PostgreSQL (Supabase)
- **Auth:** JWT with refresh token rotation
- **Deployment:** Vercel (frontend) + Railway (backend)
- **CI/CD:** GitHub Actions

## Database Schema

### Users Table
- `id` (uuid, PK)
- `email` (text, unique, indexed)
- `created_at` (timestamptz)
- **Note:** Never store plaintext passwords (use bcrypt with cost 12)
```

### 3. Procedural Memory

**Definition:** How-to knowledge - procedures, workflows, and patterns

**Stores:**
- Deployment procedures
- Testing workflows
- Common debugging steps
- Code patterns and templates

**Example:**
```markdown
## Deployment Procedure

1. Run tests: `npm run test`
2. Build: `npm run build`
3. Tag release: `git tag v1.2.3`
4. Push to main: `git push origin main --tags`
5. Vercel auto-deploys from main
6. Monitor: Check /health endpoint after 2 minutes

## Common Debugging Pattern: "API returns 500"

1. Check logs in Railway dashboard
2. Verify environment variables are set
3. Test database connection: `psql $DATABASE_URL`
4. Check recent migrations: `npm run db:migrate:status`
```

### 4. Preferences & Context

**Definition:** User preferences, constraints, and working patterns

**Stores:**
- Preferred coding style
- Communication preferences
- Constraints (budget, timeline, compliance)
- Team structure and roles

**Example:**
```markdown
## Felipe's Preferences

- **Code style:** Functional > OOP, explicit > implicit
- **Responses:** Concise, no unnecessary explanations
- **Budget:** Prioritize local models (Ollama) over OpenRouter when possible
- **Approval required for:**
  - Messaging external parties
  - Payment actions
  - Production deployments

## Project Constraints

- **Compliance:** GDPR compliant (EU users)
- **Budget:** $100/month API costs max
- **Timeline:** MVP by March 15, 2026
- **Performance:** Page load < 2s (mobile 3G)
```

---

## Implementation Options

OpenClaw HQ can use one or more of these memory systems:

### Option 1: OpenClaw Native Memory (Built-in)

**What:** Plain Markdown files in agent workspace

**Setup:** Zero configuration, works out of the box

**Storage:**
- `~/.openclaw/workspace/MEMORY.md` (long-term)
- `~/.openclaw/workspace/memory/YYYY-MM-DD.md` (daily logs)

**Search:** Vector search with Gemini embeddings or local embeddings

**Cost:** Free (if using local embeddings)

**Pros:**
- ✅ No external dependencies
- ✅ Human-readable Markdown
- ✅ Version controlled with Git
- ✅ Works offline

**Cons:**
- ❌ Manual memory writes required
- ❌ Limited to single agent workspace
- ❌ No cross-agent memory sharing by default

**Best for:** Single-agent setups, local development

### Option 2: Episodic Memory (obra/episodic-memory)

**What:** Semantic search for Claude Code conversations with automatic archiving

**Setup:** Requires Node.js, SQLite, installation as plugin

**Storage:**
- Archives: `~/.config/superpowers/conversations-archive`
- Index: SQLite database with vector search

**Search:** Semantic search via MCP tools

**Cost:** Free (local)

**Pros:**
- ✅ Automatic conversation archiving
- ✅ Semantic search of all past conversations
- ✅ Preserves full context (what, when, why)
- ✅ Works offline after indexing
- ✅ HTML viewer for reading sessions

**Cons:**
- ❌ Claude Code specific
- ❌ Requires setup and maintenance
- ❌ Not designed for multi-agent systems

**Best for:** Brain agent running on Claude Code, preserving conversation history

**Installation:**
```bash
# Install episodic-memory plugin
npm install -g @obra/episodic-memory

# Configure Claude Code settings
# Edit ~/.claude/settings.json:
{
  "cleanupPeriodDays": 99999  # Never delete conversations
}

# Install as plugin
/plugin marketplace add obra/superpowers-marketplace
/plugin install obra/episodic-memory

# Index existing conversations
episodic-memory sync
episodic-memory index
```

**Usage:**
```bash
# Search conversations
episodic-memory search "authentication implementation"

# Multi-concept AND search
episodic-memory search "jwt" "refresh token" "security"

# View conversation
episodic-memory show conversation.jsonl

# Export as HTML
episodic-memory show --format html conversation.jsonl > output.html
```

### Option 3: Supermemory (Cloud-based)

**What:** Cloud memory API with automatic capture and recall

**Setup:** Requires Supermemory Pro plan and API key

**Storage:** Cloud (Supermemory servers)

**Search:** Semantic search via API

**Cost:** Requires paid plan

**Pros:**
- ✅ Automatic memory capture (zero-config after setup)
- ✅ Automatic recall before every turn
- ✅ Cross-platform (works across all messaging channels)
- ✅ User profile building
- ✅ No local infrastructure

**Cons:**
- ❌ Requires paid plan
- ❌ Data stored in cloud (not local)
- ❌ API dependency (requires internet)
- ❌ Vendor lock-in

**Best for:** Production deployments, multi-channel bots, cloud-first setups

**Installation:**
```bash
# Set API key
export SUPERMEMORY_OPENCLAW_API_KEY="sm_..."

# Install plugin
openclaw plugins install @supermemory/openclaw-supermemory

# Restart OpenClaw
```

**Configuration:**
```json
{
  "plugins": {
    "entries": {
      "openclaw-supermemory": {
        "enabled": true,
        "config": {
          "apiKey": "${SUPERMEMORY_OPENCLAW_API_KEY}",
          "namespace": "openclaw-hq",
          "autoRecall": true,
          "autoCapture": true,
          "maxMemoriesPerTurn": 5,
          "injectProfileInterval": 10
        }
      }
    }
  }
}
```

**CLI Commands:**
```bash
# Search memories
openclaw supermemory search "authentication patterns"

# View user profile
openclaw supermemory profile

# Wipe all memories (destructive)
openclaw supermemory wipe
```

### Option 4: Agent Memory MCP (Hybrid System)

**What:** Persistent, searchable memory bank via MCP server

**Setup:** Requires Node.js, MCP server installation

**Storage:** SQLite + vector embeddings (local)

**Search:** Semantic + keyword search

**Cost:** Free (local)

**Pros:**
- ✅ Persistent across sessions
- ✅ Semantic search
- ✅ Type-based organization (decision, pattern, fact)
- ✅ Tag-based filtering
- ✅ Analytics dashboard
- ✅ Syncs with project documentation

**Cons:**
- ❌ Requires MCP server setup
- ❌ Manual memory writes via tools
- ❌ Per-project isolation (no cross-project memory by default)

**Best for:** Brain agent with structured memory needs, documentation-heavy projects

**Installation:**
```bash
# Clone repository
git clone https://github.com/webzler/agentMemory.git .agent/skills/agent-memory

# Install dependencies
cd .agent/skills/agent-memory
npm install
npm run compile

# Start MCP server
npm run start-server my-project $(pwd)
```

**MCP Tools:**

1. **memory_search**
   ```javascript
   memory_search({
     query: "authentication patterns",
     type: "pattern",
     tags: ["security", "auth"]
   })
   ```

2. **memory_write**
   ```javascript
   memory_write({
     key: "auth-jwt-v1",
     type: "decision",
     content: "Use JWT with 15-min access tokens...",
     tags: ["auth", "security"]
   })
   ```

3. **memory_read**
   ```javascript
   memory_read({ key: "auth-jwt-v1" })
   ```

4. **memory_stats**
   ```javascript
   memory_stats({})
   ```

---

## Memory Best Practices

### When Brain Should Write Memory

Brain agent should write to long-term memory when:

1. **Making architecture decisions**
   - What was decided
   - Why it was chosen
   - What alternatives were considered and rejected
   - What constraints influenced the decision

2. **Discovering important facts**
   - API keys and credentials (store securely)
   - Environment requirements
   - External dependencies
   - Breaking changes or gotchas

3. **Identifying patterns**
   - Common bugs and their fixes
   - Performance optimizations that worked
   - Code patterns to follow/avoid
   - Integration quirks

4. **Recording preferences**
   - User preferences for code style, communication
   - Project constraints (budget, timeline, compliance)
   - Team structure and roles

5. **Learning from mistakes**
   - What didn't work and why
   - Failed approaches to avoid repeating
   - Lessons learned

### When Reviewer Should Write Memory

Reviewer agent should write to memory when:

1. **Finding recurring issues**
   - Common bugs across PRs
   - Patterns of mistakes
   - Security anti-patterns

2. **Identifying improvements**
   - Code quality patterns to reinforce
   - Testing gaps to address
   - Performance improvements to prioritize

3. **Documenting review decisions**
   - Why certain code was approved/rejected
   - Standards clarifications
   - Precedents for future reviews

### Memory Writing Format

**Good memory entries:**

```markdown
## [Date]: [Topic/Decision]

**Context:** What was happening when this decision was made

**Decision/Finding:** What was decided or discovered

**Reasoning:** Why this approach was chosen

**Alternatives considered:**
- Option A: Rejected because X
- Option B: Rejected because Y

**Impact:** How this affects the project

**Related:** Links to code, PRs, documentation

**Tags:** #architecture #auth #security
```

**Example:**

```markdown
## 2025-02-07: Database Migration Strategy

**Context:** Needed to add user roles without downtime in production

**Decision:** Use online schema migration with backward-compatible changes

**Reasoning:**
- Zero-downtime requirement (24/7 service)
- Supabase doesn't support complex migrations natively
- Team has no DBA expertise

**Alternatives considered:**
- Blue-green deployment: Rejected (too complex for current scale)
- Maintenance window: Rejected (breaks 24/7 requirement)
- Manual migration: Rejected (error-prone)

**Implementation:**
1. Add nullable `role` column
2. Backfill data in background
3. Make non-null after backfill complete
4. Update application code to use new column

**Impact:** Can safely evolve schema without downtime

**Related:** PR #123, docs/migrations.md

**Tags:** #database #migrations #postgres #architecture
```

---

## When to Write Memory

### Automatic Memory Flush (Pre-Compaction)

OpenClaw automatically triggers memory writes when approaching context limits:

**How it works:**
1. When session tokens approach `contextWindow - reserveTokensFloor - softThresholdTokens`
2. OpenClaw injects silent system prompt: "Session nearing compaction. Store durable memories now."
3. Agent writes important context to memory files
4. Agent responds with `NO_REPLY` (user doesn't see this)
5. Session continues with freed context

**Configuration:**
```json
{
  "agents": {
    "defaults": {
      "compaction": {
        "reserveTokensFloor": 20000,
        "memoryFlush": {
          "enabled": true,
          "softThresholdTokens": 4000,
          "systemPrompt": "Session nearing compaction. Store durable memories now.",
          "prompt": "Write any lasting notes to memory/YYYY-MM-DD.md; reply with NO_REPLY if nothing to store."
        }
      }
    }
  }
}
```

### Manual Memory Triggers

Users and agents should explicitly write memory when:

**User says:**
- "Remember this"
- "Don't forget that..."
- "Save this for later"
- "Write this down"
- "Keep this in mind"

**Agent recognizes:**
- Important architectural decision was made
- Critical bug was discovered and fixed
- User stated a preference or constraint
- Pattern emerged across multiple sessions
- Something would be valuable to recall weeks/months later

**Agent should ask:**
- "Should I save this to long-term memory?"
- "This seems important - shall I write it down?"
- "Do you want me to remember this for future sessions?"

---

## Memory Search & Retrieval

### Semantic Search (Vector-based)

**Use when:**
- Looking for concepts, not exact words
- Finding related decisions across time
- Discovering patterns and themes
- User asks "what did we do with X" (vague query)

**Examples:**

```bash
# Find authentication-related decisions
memory_search("authentication patterns")

# Returns conversations about:
# - JWT implementation
# - OAuth consideration
# - Session management
# - Password hashing
# (even if "authentication patterns" wasn't the exact phrase used)
```

**Multi-concept AND search:**

```bash
# Must match ALL concepts
episodic-memory search "database" "performance" "optimization"

# Returns only conversations that involve all three concepts
```

### Text Search (Keyword-based)

**Use when:**
- Looking for exact terms, names, or identifiers
- Finding specific error messages
- Locating particular file names or variables
- User asks precise question with specific terms

**Examples:**

```bash
# Find exact error message
memory_search("TypeError: Cannot read property 'map' of undefined", mode="text")

# Find specific function
memory_search("getUserByEmail", mode="text")
```

### Hybrid Search (Best of Both)

**Use when:**
- Uncertain whether semantic or keyword is better
- Want comprehensive results
- Looking for related AND exact matches

**How it works:**
1. Runs both vector and keyword search
2. Merges results using RRF (Reciprocal Rank Fusion)
3. Returns top-ranked combined results

**Default mode in most systems**

---

## Setup Instructions

### Recommended Setup for OpenClaw HQ

**For Brain Agent (Mac mini):**

**Option 1: Episodic Memory (Recommended)**

Best for preserving conversation history and semantic search of past sessions.

```bash
# 1. Install Node.js (if not installed)
brew install node

# 2. Extend conversation retention
# Edit ~/.claude/settings.json:
{
  "cleanupPeriodDays": 99999
}

# 3. Install episodic-memory
npm install -g @obra/episodic-memory

# 4. Initial sync and index
episodic-memory sync
episodic-memory index

# 5. Set up auto-sync hook
# Add to ~/.claude/settings.json:
{
  "hooks": {
    "SessionStart": {
      "command": "episodic-memory",
      "args": ["sync"]
    }
  }
}
```

**Option 2: Native OpenClaw Memory (Simpler)**

Best for simple setups without external dependencies.

```bash
# No installation needed - works out of the box

# Configure memory search (optional)
# Edit openclaw config to enable vector search with Gemini:
{
  "memorySearch": {
    "enabled": true,
    "provider": "google"
  },
  "models": {
    "providers": {
      "google": {
        "apiKey": "${GEMINI_API_KEY}"
      }
    }
  }
}

# Memory files location:
# ~/.openclaw/workspace/MEMORY.md (long-term)
# ~/.openclaw/workspace/memory/YYYY-MM-DD.md (daily)
```

**For Reviewer Agent (Linux VPS):**

Reviewer should have read-only access to memory but write minimal entries.

```bash
# Sync Brain's memory files via Git
# Memory files should be committed to repo:
git add workspace/MEMORY.md
git add workspace/memory/*.md
git commit -m "docs: update memory"
git push

# Reviewer pulls to get latest context
git pull

# Reviewer writes review findings to REVIEW_MEMORY.md (separate file)
```

### Memory File Structure in Git

```
/
├── FELIPE/
│   ├── GOALS.md
│   └── ROADMAP.md
├── ARCHITECTURE.md
├── AGENTS.md
├── SKILLS.md
├── MEMORY.md  (this file - documentation)
├── workspace/
│   ├── MEMORY.md  (Brain's long-term memory)
│   ├── REVIEW_MEMORY.md  (Reviewer's findings)
│   └── memory/
│       ├── 2025-02-01.md
│       ├── 2025-02-02.md
│       ├── 2025-02-07.md  (today)
│       └── ...
└── automations/
    └── n8n/
```

**Git tracking:**
- ✅ Commit `workspace/MEMORY.md` (long-term knowledge)
- ✅ Commit `workspace/REVIEW_MEMORY.md` (review findings)
- ⚠️ Optional: Commit daily logs older than 7 days
- ❌ Don't commit today's log (too frequent, creates noise)

---

## Integration with OpenClaw HQ Architecture

### Brain Agent Memory Workflow

1. **Session Start:**
   - Load `MEMORY.md` (long-term knowledge)
   - Load today's `memory/YYYY-MM-DD.md` (session context)
   - Load yesterday's log (continuity)

2. **During Work:**
   - Keep working memory in context window
   - Write important decisions to `memory/YYYY-MM-DD.md`
   - Flag critical items for `MEMORY.md`

3. **Before Context Limit:**
   - Auto-flush triggered by OpenClaw
   - Write durable facts to `MEMORY.md`
   - Write session summary to `memory/YYYY-MM-DD.md`
   - Reply `NO_REPLY` to continue session

4. **After PR Merged:**
   - Write architecture decisions to `MEMORY.md`
   - Tag with relevant categories
   - Commit memory files to Git

### Reviewer Agent Memory Workflow

1. **Before Review:**
   - Pull latest `MEMORY.md` from Git
   - Search for related past decisions
   - Load project patterns and constraints

2. **During Review:**
   - Note recurring issues
   - Compare against past decisions
   - Check if changes violate known constraints

3. **After Review:**
   - Write findings to `REVIEW_MEMORY.md`
   - Flag patterns for Brain to address
   - Update review standards if needed

### Felipe's Memory Access

Felipe can:
- Read all memory files directly
- Search memory via CLI tools
- Override or edit memory manually
- Request agents to remember/forget specific things

**Commands Felipe can use:**

```bash
# Search Brain's memory
episodic-memory search "authentication decisions"

# View specific memory file
cat workspace/MEMORY.md

# Export session as HTML
episodic-memory show --format html ~/.claude/projects/openclaw-hq/conversation.jsonl > session.html

# Check memory statistics
episodic-memory stats
```

---

## Metrics and Monitoring

Track memory system health:

**Key Metrics:**

1. **Memory recall accuracy:**
   - % of questions answered using memory vs. re-explained
   - Memory hit rate on semantic searches

2. **Memory coverage:**
   - Number of architecture decisions documented
   - Number of patterns cataloged
   - Number of preferences captured

3. **Memory freshness:**
   - Days since last memory write
   - % of recent sessions with memory updates

4. **Memory quality:**
   - Are memories specific and actionable?
   - Do they include "why" not just "what"?
   - Are they properly tagged and searchable?

**Monitoring Commands:**

```bash
# Check memory stats
episodic-memory stats

# Or for Agent Memory MCP
memory_stats({})

# Review recent memories
tail -100 workspace/MEMORY.md
```

---

## Troubleshooting

### "Agent doesn't remember previous conversations"

**Causes:**
- Memory not written to disk
- Memory files not loaded at session start
- Wrong memory file path
- Memory search not configured

**Fixes:**
1. Check if memory files exist: `ls workspace/memory/`
2. Verify memory search enabled: `episodic-memory stats`
3. Manually trigger memory write: "Write this to long-term memory"
4. Check OpenClaw config for memory paths

### "Semantic search returns irrelevant results"

**Causes:**
- Embedding model mismatch
- Query too vague
- Memory not properly tagged
- Vector index stale

**Fixes:**
1. Use more specific queries
2. Combine with keyword search (hybrid mode)
3. Re-index: `episodic-memory index --force`
4. Add explicit tags to memory entries

### "Memory files too large / slow to load"

**Causes:**
- Daily logs accumulating without compaction
- Too much ephemeral content in long-term memory
- No pruning of old sessions

**Fixes:**
1. Archive old daily logs (move to `memory/archive/`)
2. Compact `MEMORY.md` by removing ephemeral content
3. Enable auto-compaction in OpenClaw config
4. Separate long-term facts from session notes

---

## Best Practices Summary

### DO:

✅ Write memory immediately after important decisions
✅ Include "why" not just "what"
✅ Tag memories for easier search
✅ Commit memory files to Git
✅ Use semantic search for concepts
✅ Separate long-term facts from session notes
✅ Write before context limits hit
✅ Review and prune old memories periodically

### DON'T:

❌ Keep important context only in conversation
❌ Write vague memories without reasoning
❌ Forget to tag or categorize
❌ Let daily logs grow indefinitely
❌ Store secrets in plaintext (use environment variables)
❌ Duplicate information across files
❌ Assume memory persists without writing

### Golden Rule:

**"If you want something to stick, write it down."**

Memory is not automatic - it requires intentional writes. When in doubt, write it to memory. The cost of writing is low; the cost of forgetting is high.

---

## References

This document synthesizes memory system best practices from:

- **obra/episodic-memory**: Semantic search for Claude Code conversations
- **sickn33/antigravity-awesome-skills**: Agent memory systems and patterns
- **supermemoryai/openclaw-supermemory**: Cloud-based memory API
- **OpenClaw Memory Documentation**: Native memory system architecture

For detailed implementation guides, see:
- [Episodic Memory GitHub](https://github.com/obra/episodic-memory)
- [Agent Memory MCP](https://github.com/webzler/agentMemory)
- [Supermemory Docs](https://supermemory.ai/docs)
- [OpenClaw Memory Docs](https://docs.openclaw.ai/concepts/memory)

---

## API Keys Required

Depending on which memory system you choose:

**Episodic Memory (obra):**
- None (local only)
- Optional: Embedding provider API key for semantic search

**Supermemory:**
- ✅ Required: Supermemory API key (`SUPERMEMORY_OPENCLAW_API_KEY`)
- Get from: https://console.supermemory.ai
- Requires: Supermemory Pro plan or above

**OpenClaw Native Memory:**
- Optional: Gemini API key for vector search (`GEMINI_API_KEY`)
- Alternative: Use local embeddings (no key needed, requires setup)

**Agent Memory MCP:**
- None (local only)
- Uses local embeddings via node-llama-cpp

---

End of file.
