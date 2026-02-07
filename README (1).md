# OpenClaw HQ

Welcome to **OpenClaw HQ** — a personal, distributed, 2-agent engineering system with human-in-the-loop control.

This repository is the **single source of truth** for all projects, code, decisions, and memory.  
It is designed around two specialized OpenClaw sessions, cost-aware inference, and Felipe's strategic oversight.

Think of this repo as a **small AI-powered engineering organization** coordinated by Felipe, where one agent builds and another reviews.

---

## High-Level Philosophy

This system is built on a few core principles:

- **Simplicity over complexity** — Two agents (builder + reviewer) avoid coordination overhead
- **Quality through review** — Two independent intelligences check every change
- **Cheap inference first** — Local models when possible, paid only when necessary
- **Human control** — Felipe retains final authority on all merges and sensitive actions
- **Git is truth** — If it's not committed, it doesn't exist
- **Memory matters** — Agents remember context across weeks and months

Instead of one monolithic agent or complex multi-agent coordination, we run **two OpenClaw sessions** with clear separation of concerns.

---

## The Two OpenClaw Sessions

### 🧠 Brain OpenClaw (Mac mini — Claude Sonnet 4.5)

**Role:** Full-stack builder, architect, and implementer

**Responsibilities:**

- Receives objectives from Felipe via Telegram
- Architecture and system design
- Full-stack implementation:
  - Frontend UI/UX
  - Backend APIs and services
  - Automation workflows (n8n, Playwright)
  - Infrastructure and integrations
- Pushes feature branches to GitHub
- Opens pull requests with clear descriptions
- Responds to Reviewer feedback
- Fixes issues identified in review
- **Never merges to main** (only Felipe merges)

**Special privileges:**

- Only Brain can log into Gmail and send/read email
- Only Brain can execute identity-sensitive operations (OAuth, logins)
- Only Brain decides OpenRouter escalation when costs are ambiguous
- Hosts n8n automation instance (HTTPS + custom domain)

**This agent is the builder** — it has full context and builds coherent systems end-to-end.

---

### 🔍 Reviewer OpenClaw (Linux VPS — Codex)

**Role:** Independent quality gate and security checker

**Responsibilities:**

- Monitors GitHub for new PRs from Brain
- Reviews code for:
  - Bugs and edge cases
  - Security vulnerabilities
  - Architecture problems
  - Code quality and maintainability
  - Performance issues
  - Missing error handling
- Leaves detailed, actionable comments on PRs
- Approves PRs when quality is acceptable
- Requests changes when issues are found
- **Never writes code, never merges, never builds**

**Restrictions:**

- No code writing or implementation
- No branch pushing
- No Gmail or external service authentication
- No merging to main
- Review only — acts as second set of eyes

**This agent is the quality gate** — it catches what Brain misses.

---

## Felipe (Human Orchestrator)

Felipe sits above all agents and has final authority.

**Felipe:**

- Defines strategic goals and roadmap (in `/FELIPE`)
- Messages Brain with objectives via Telegram
- Reviews and approves pull requests
- **Merges all changes to main** (no agent ever merges)
- Approves sensitive actions (logins, payments, messaging humans)
- Resolves conflicts between Brain and Reviewer
- Owns budget and cost decisions
- Can override any agent decision

**The hierarchy:**
1. Felipe makes final decisions
2. Reviewer flags concerns
3. Brain decides technical approach
4. `AGENTS.md` policies override all

Agents propose.  
Felipe disposes.

---

## Why This Architecture Works

### Simplicity
- **Linear workflow:** build → review → merge
- No task queues, no race conditions, no coordination overhead
- Easy to understand and debug
- One builder = coherent design

### Quality
- Two independent intelligences check every change
- Brain has full context for end-to-end implementation
- Reviewer catches bugs, security issues, and edge cases
- Human approval required for all merges

### Cost Efficiency
- Premium model (Claude Sonnet 4.5) only for building
- Cheaper model (Codex) for analysis and review
- Local models (Ollama) for simple edits when available
- OpenRouter as fallback for easy queries (checking emails, simple lookups)
- No wasted tokens on coordination between agents

### Reliability
- Predictable, testable workflow
- Clear responsibilities and boundaries
- Human control at every merge point
- All state in Git = easy recovery

---

## Source of Truth

**GitHub is the canonical system state.**

Everything meaningful lives in Git:

- Code and automation definitions
- Architecture documents (`ARCHITECTURE.md`, `AGENTS.md`, `SKILLS.md`)
- Memory files (`workspace/MEMORY.md`, `workspace/REVIEW_MEMORY.md`)
- Goals and roadmap (`/FELIPE/`)
- Tasks and decisions
- Pull requests and reviews
- n8n workflow definitions

**Chat systems (Telegram/Discord) are for coordination only.**

If it's not committed to Git, it doesn't exist.

---

## Locked Human Folder

The `/FELIPE` directory is **human-owned and locked**.

**Contains:**
- `GOALS.md` — strategic objectives
- `ROADMAP.md` — priorities and timeline
- `APPROVALS.md` — log of sensitive actions
- `NOTES.md` / `IDEAS.md` — brainstorming

**Access:**
- Agents may read if permitted
- Agents **never modify** `/FELIPE`

This keeps **strategic vision separated from execution**.

Felipe doesn't create tasks by editing `/FELIPE` for agents to consume. Instead:

1. Felipe messages Brain with an objective
2. Brain builds it end-to-end
3. Reviewer checks quality
4. Felipe approves and merges

---

## Shared Gmail Account (Critical Security Rule)

All agents share a **single dedicated Gmail account** for system communication.

**However:**

👉 **ONLY the Brain OpenClaw (Mac mini) is allowed to:**
- Log into Gmail
- Read emails
- Send emails
- Perform OAuth flows
- Access Gmail API

👉 **Reviewer OpenClaw must NEVER:**
- Authenticate to Gmail
- Attempt OAuth
- Read or send email
- Access any email functionality

**Why this rule exists:**

- Mac mini (Brain's device) is the **trusted device**
- Dramatically reduces account blocks, CAPTCHA loops, and security flags
- Single point of authentication = easier to secure
- Prevents accidental credential leaks

**If email interaction is needed:**

1. Reviewer prepares data or context
2. Brain performs the actual email action

**This rule is strict and non-negotiable.**

---

## Cost Policy (Cheap-First Inference)

All agents follow a shared cost philosophy:

**For Brain (Builder):**

- **Use premium models** (Claude Sonnet 4.5) by default for building
  - Full context justifies the cost
  - Coherent architecture requires quality reasoning
  
- **Use local models** (Ollama) when available for:
  - Simple edits (typo fixes, formatting)
  - Renaming variables
  - Markdown cleanup
  - Small, mechanical changes

- **Use OpenRouter as fallback** for simple queries:
  - Checking emails
  - Quick lookups
  - Status checks
  - Non-critical questions

- **Always use premium for:**
  - Architecture decisions
  - Complex reasoning
  - Multi-system integration
  - Authentication flows
  - Ambiguous requirements
  - Large refactors

**For Reviewer (Quality Gate):**

- Uses **Codex** (self-hosted or via API)
- No additional costs
- Analysis only, no creation

**Decision authority:**

- Brain decides its own model usage based on task complexity
- Felipe can override if costs spike
- Budget details in `BUDGET.md`

---

## Typical Workflow (Step-by-Step)

### Phase 1: Objective Definition

1. **Felipe messages Brain** via Telegram: "Build a dashboard that shows n8n workflow stats"
2. **Brain acknowledges** and clarifies requirements if needed

### Phase 2: Building

3. **Brain architects the solution** and builds everything:
   - Frontend components
   - Backend API
   - Database queries
   - Tests and documentation
4. **Brain pushes feature branch** to GitHub: `feature/n8n-dashboard`
5. **Brain opens pull request** with clear description

### Phase 3: Review

6. **Reviewer scans GitHub** for new PRs
7. **Reviewer reviews code** for bugs, security, quality
8. **Reviewer leaves comments** (approval or requests changes)

### Phase 4: Iteration (if needed)

9. **Brain reads feedback** and addresses issues
10. **Brain pushes fixes** to same branch
11. **Reviewer re-reviews** if changes were significant

### Phase 5: Merge

12. **Felipe reviews the PR** (Brain's description + Reviewer's comments)
13. **Felipe checks for sensitive actions** (credentials, external messages, payments)
14. **Felipe merges to main** (only Felipe has merge authority)

**No agent bypasses this loop.**

---

## Memory System

OpenClaw HQ uses a **hybrid memory system** to maintain context across sessions:

### Short-term Memory
- Current conversation context (RAM)
- Session-specific decisions

### Medium-term Memory
- Daily logs: `workspace/memory/YYYY-MM-DD.md`
- Recent project context (last 7-30 days)

### Long-term Memory
- Persistent knowledge: `workspace/MEMORY.md`
- Architecture decisions with reasoning
- Patterns and lessons learned
- User preferences and constraints
- Committed to Git for permanence

### Optional: Episodic Memory
- Semantic search of all past conversations
- Preserves "why" decisions were made
- See `MEMORY.md` for setup instructions

**Memory is critical** — it transforms agents from stateless tools into collaborative partners who remember your journey together.

---

## Automation Infrastructure

**Brain hosts the n8n automation engine** (HTTPS + custom domain).

**n8n is used for:**
- Scheduled jobs (scraping, report generation)
- Webhook integrations
- Notification workflows
- Monitoring and health checks

**All workflows:**
- Defined in code (stored in Git)
- Exported as JSON to `/automations/n8n/workflows/`
- Reviewed by Reviewer during PR process

This keeps automation under version control and review.

---

## File Structure

```
openclaw-hq/
├── README.md                    (this file)
├── ARCHITECTURE.md              (2-agent system design)
├── AGENTS.md                    (agent roles and rules)
├── SKILLS.md                    (best practices across domains)
├── MEMORY.md                    (memory system documentation)
├── BACKUP.md                    (backup and recovery strategy)
├── BUDGET.md                    (cost policy and limits)
│
├── FELIPE/                      (human-owned, locked)
│   ├── GOALS.md
│   ├── ROADMAP.md
│   ├── APPROVALS.md
│   └── NOTES.md
│
├── workspace/
│   ├── MEMORY.md                (long-term knowledge)
│   ├── REVIEW_MEMORY.md         (review findings)
│   └── memory/
│       ├── 2025-02-01.md
│       ├── 2025-02-07.md        (today)
│       └── ...
│
├── automations/
│   └── n8n/
│       └── workflows/
│           ├── email-automation.json
│           ├── github-webhook.json
│           └── ...
│
├── src/                         (application code)
├── docs/                        (documentation)
└── .github/                     (GitHub Actions, PR templates)
```

---

## Key Documents

### Core Architecture
- **`ARCHITECTURE.md`** — Full system design and 2-agent workflow
- **`AGENTS.md`** — Global agent rules and responsibilities
- **`SKILLS.md`** — Best practices for frontend, backend, marketing, SEO, security

### Operations
- **`MEMORY.md`** — Memory system setup and best practices
- **`BACKUP.md`** — Backup strategy and recovery procedures
- **`BUDGET.md`** — Cost policy and spending limits

### Human Intent
- **`/FELIPE/GOALS.md`** — Strategic objectives
- **`/FELIPE/ROADMAP.md`** — Priorities and timeline

### Agent Memory
- **`workspace/MEMORY.md`** — Brain's long-term knowledge
- **`workspace/REVIEW_MEMORY.md`** — Reviewer's findings
- **`workspace/memory/*.md`** — Daily session logs

---

## What This Repository Represents

This is not just a codebase.

**It is:**

- A coordination layer for AI agents
- A memory system that preserves context
- A decision log with reasoning
- A multi-agent runtime with human oversight
- A personal engineering platform
- A knowledge base that grows over time

**You are effectively running a small distributed AI team** where:
- Brain builds with full context
- Reviewer ensures quality
- Felipe maintains strategic direction
- Memory prevents context loss
- Git preserves everything

---

## Getting Started

### Prerequisites

**For Brain (Mac mini):**
- macOS with Claude Sonnet 4.5 access
- Git installed
- Telegram for Felipe ↔ Brain communication
- Optional: Ollama for local models
- Optional: episodic-memory for conversation search

**For Reviewer (Linux VPS):**
- Ubuntu/Debian server
- Git installed
- Codex access (self-hosted or via API)
- GitHub access for monitoring PRs

**For Felipe:**
- GitHub account with merge permissions
- Telegram account
- Password manager (1Password, Bitwarden)
- Access to both Brain and Reviewer agents

### Initial Setup

1. **Create GitHub repository:**
   ```bash
   # On your local machine
   git clone https://github.com/YOUR_ORG/openclaw-hq.git
   cd openclaw-hq
   ```

2. **Set up folder structure:**
   ```bash
   mkdir -p FELIPE workspace/memory automations/n8n/workflows
   ```

3. **Create core documents:**
   - Copy `ARCHITECTURE.md`, `AGENTS.md`, `SKILLS.md`, `MEMORY.md`, `BACKUP.md` into repo
   - Create `/FELIPE/GOALS.md` with your strategic objectives
   - Create `/FELIPE/ROADMAP.md` with priorities

4. **Configure Brain (Mac mini):**
   - Install OpenClaw
   - Set up Gmail authentication
   - Configure Telegram bot
   - Optional: Install episodic-memory

5. **Configure Reviewer (Linux VPS):**
   - Install OpenClaw with Codex
   - Clone repository
   - Set up GitHub PR monitoring

6. **Create backup mirror:**
   ```bash
   # Add GitLab as backup
   git remote add backup https://gitlab.com/YOUR_USERNAME/openclaw-hq-backup.git
   git push backup main
   ```

7. **First task:**
   - Felipe messages Brain: "Build a simple health check endpoint"
   - Brain builds, tests, pushes PR
   - Reviewer reviews, approves
   - Felipe merges
   - System validated ✅

---

## Common Commands

### For Brain

```bash
# Start new feature
git checkout -b feature/new-feature
# ... build ...
git add .
git commit -m "feat: implement new feature"
git push origin feature/new-feature
# Open PR on GitHub

# Respond to review
git add .
git commit -m "fix: address review comments"
git push origin feature/new-feature
```

### For Reviewer

```bash
# Pull latest
git pull origin main

# Review PR (done via GitHub UI or CLI)
gh pr review 123 --comment --body "LGTM, approve"
gh pr review 123 --request-changes --body "Security issue in auth.js:42"
```

### For Felipe

```bash
# Review and merge PR
gh pr view 123
gh pr review 123 --approve
gh pr merge 123 --squash

# Push to backup
git push backup main
```

---

## Troubleshooting

### "Brain forgot previous context"

**Solution:** Check if memory files exist and are being loaded.

```bash
# Verify memory files
ls -lh workspace/MEMORY.md
ls -lh workspace/memory/

# If using episodic-memory
episodic-memory stats
```

See `MEMORY.md` for detailed troubleshooting.

### "Reviewer isn't catching issues"

**Solution:** Verify Reviewer has latest code and can access PRs.

```bash
# On VPS
cd ~/openclaw-hq
git pull
gh pr list --state open
```

### "GitHub sync failing"

**Solution:** Check credentials and network.

```bash
git remote -v
git fetch origin
git status
```

### "Costs spiking"

**Solution:** Review model usage and adjust in `BUDGET.md`.

Check OpenRouter dashboard for actual usage.
Consider using Ollama for more tasks.

---

## Security Notes

**Secrets Management:**
- Never commit API keys, passwords, or tokens to Git
- Use `.env` files (add to `.gitignore`)
- Store secrets in password manager
- Commit `.env.example` templates only

**Access Control:**
- Only Felipe has merge permissions
- Only Brain can access Gmail
- Reviewer is read-only on external services
- VPS is disposable infrastructure

**Backup Strategy:**
- Triple redundancy: GitHub + GitLab + Mac mini
- Daily automated backups
- Quarterly disaster recovery tests
- See `BACKUP.md` for details

---

## Contributing

This is a personal system, but if you're building something similar:

1. **Fork this repository** as a template
2. **Adapt to your needs** (different agents, models, structure)
3. **Keep the core principles:**
   - Simplicity over complexity
   - Human in the loop
   - Git as source of truth
   - Memory preservation
   - Cost awareness

**Share your learnings!** If you find improvements or patterns, consider contributing back or sharing publicly.

---

## License

This repository is private and proprietary.

The architecture and patterns described here are provided as-is for personal use.

---

## Support

**For Felipe:**
- Primary: Telegram bot for Brain agent
- Backup: Direct messages to agents
- Emergency: Manual Git operations

**For issues:**
- Open GitHub issue for bugs
- Message Brain for feature requests
- Update `/FELIPE/ROADMAP.md` for priorities

---

## Acknowledgments

This system builds on ideas and tools from:

- **OpenClaw** — Multi-platform AI messaging gateway
- **Anthropic** — Claude models and agent skills
- **Vercel** — React/Next.js best practices
- **Supabase** — Postgres best practices
- **obra/episodic-memory** — Conversation memory system
- **Supermemory** — Cloud memory API
- **Community contributors** — Agent skills and patterns

Special thanks to the open-source community for agent skills, memory systems, and best practices that made this possible.

---

## What's Next?

**Immediate priorities:**

1. Set up episodic memory for Brain
2. Configure automated backups to GitLab
3. Create first real project with build → review → merge workflow
4. Test disaster recovery procedures
5. Refine memory-writing habits

**Long-term vision:**

- Continuously improve agent skills and best practices
- Build library of reusable patterns and templates
- Expand memory system for better context preservation
- Optimize costs through better local model usage
- Scale to more complex projects

**The system evolves with you.**

As you use OpenClaw HQ, you'll discover new patterns, refine workflows, and build institutional knowledge in memory files. This isn't a static system — it's a living, learning engineering organization.

---

## Final Note

**Remember the core insight:**

> Code comments explain **what**, documentation explains **how**, but memory preserves **why** — and that makes agents far more effective collaborators across sessions.

This system is designed to:
- Preserve context across weeks and months
- Learn from mistakes and remember decisions
- Build quality through independent review
- Keep humans in control of critical actions
- Scale your personal productivity with AI

**Welcome to OpenClaw HQ.**

Let's build something great.

---

End of README.
