# BUDGET.md

Cost policy and spending limits for OpenClaw HQ.

This document defines how to manage AI model costs, when to use premium vs. fallback models, and how to stay within budget while maintaining quality.

The goal is simple:

- Use the right model for the job
- Avoid wasteful spending on mechanical tasks
- Stay within monthly budget limits
- Maintain quality where it matters

Felipe owns budget authority and can override any decision.

---

## Principles

1. **Premium models for creation, cheaper for analysis**
2. **OpenRouter is the primary fallback** (not Ollama)
3. **Ollama is optional** (only if disk space allows)
4. **Brain decides model escalation** for its own work
5. **Quality over cost** for critical decisions
6. **Track and review** spending monthly

Never penny-pinch on decisions that matter.  
Never waste money on tasks that don't.

---

## Monthly Budget

**Target monthly spend:** $100 USD

**Breakdown:**
- Brain (Claude Sonnet 4.5): ~$70/month (primary builder)
- OpenRouter fallback: ~$20/month (simple queries, email checks)
- Reviewer (Codex): $0/month (self-hosted or included)
- Buffer: ~$10/month (spikes, testing, experiments)

**Hard limit:** $150 USD

If approaching limit, Felipe must approve continued spending or:
- Reduce usage
- Switch to cheaper models temporarily
- Defer non-critical work

**Monitoring:** Check OpenRouter dashboard weekly.

---

## Model Selection Strategy

### Brain OpenClaw (Builder)

Brain uses a **tiered approach** based on task complexity:

#### Tier 1: Premium (Claude Sonnet 4.5) — DEFAULT

**Use for:**
- Architecture and system design
- Complex reasoning and problem-solving
- Multi-component feature implementation
- Authentication and security flows
- Ambiguous requirements that need interpretation
- Integration with external services
- Large refactors touching multiple files
- Writing production code
- Debugging complex issues
- Making decisions with long-term impact

**Cost:** ~$3 per 1M input tokens, ~$15 per 1M output tokens

**Justification:** Full context and coherent architecture justify premium pricing.

**Example tasks:**
- "Build a user authentication system with JWT"
- "Design the database schema for multi-tenant SaaS"
- "Integrate Stripe payment processing"
- "Fix race condition in WebSocket handler"
- "Refactor API to use microservices architecture"

#### Tier 2: OpenRouter Fallback (GPT-4o-mini, Gemini Flash, etc.) — PRIMARY FALLBACK

**Use for:**
- Simple queries and lookups
- Checking emails
- Status checks and monitoring
- Quick questions without full context
- Formatting assistance
- Documentation reading
- Web searches
- Non-critical administrative tasks

**Cost:** ~$0.15 per 1M input tokens, ~$0.60 per 1M output tokens (GPT-4o-mini)

**Justification:** 10-20x cheaper for tasks that don't require premium reasoning.

**Example tasks:**
- "Check if there are any new emails from GitHub"
- "What's the current status of PR #42?"
- "Format this JSON nicely"
- "What time is it in UTC?"
- "Summarize these meeting notes"
- "Look up the documentation for React.lazy"

**Available OpenRouter models:**
```
- openai/gpt-4o-mini (recommended for general fallback)
- google/gemini-flash-1.5 (fast, good for simple tasks)
- anthropic/claude-3-haiku (when staying in Claude family)
- meta-llama/llama-3.1-70b-instruct (open source option)
```

**Configuration:**
```bash
# In Brain's config
OPENROUTER_API_KEY=your_key_here
OPENROUTER_DEFAULT_MODEL=openai/gpt-4o-mini
```

#### Tier 3: Ollama Local Models — OPTIONAL

**Only install if:**
- Mac mini has ample disk space (50GB+ available)
- Frequent mechanical edits justify offline capability
- Internet unreliability is a concern
- Privacy requirements demand local processing

**Use for:**
- Typo fixes
- Variable renaming
- Code formatting
- Markdown cleanup
- Simple find-and-replace operations
- Mechanical refactors with clear patterns

**Cost:** $0 (free, but uses disk and compute)

**Disk requirements:**
- Llama 3.1 8B: ~4.7GB
- Codestral 22B: ~12GB
- Qwen 2.5 Coder 7B: ~4.4GB

**Setup (optional):**
```bash
# Only if disk space allows
brew install ollama

# Pull recommended model for code editing
ollama pull qwen2.5-coder:7b

# Verify
ollama list
```

**Example tasks:**
- "Fix typo in README.md line 42"
- "Rename variable `usr` to `user` throughout file"
- "Format this code block with proper indentation"
- "Add missing semicolons"

**Important:** Ollama is **purely optional**. If not installed, use OpenRouter fallback instead.

### Reviewer OpenClaw (Quality Gate)

**Model:** Codex (self-hosted or via API)

**Cost:** $0/month (included in setup, no per-token charges)

**Use for:**
- Code review and analysis
- Bug detection
- Security vulnerability scanning
- Architecture critique
- Performance analysis
- All quality gate tasks

**Justification:** Reviewer only analyzes, doesn't create. Codex is optimized for code understanding.

**No escalation needed** — Codex is sufficient for all review tasks.

---

## Decision Framework

When Brain is unsure which tier to use, follow this decision tree:

```
START
  │
  ├─ Is this a lookup/email/status check?
  │  └─ YES → OpenRouter fallback (Tier 2)
  │
  ├─ Is this a simple mechanical edit (typo, rename)?
  │  ├─ Ollama installed? → YES → Ollama (Tier 3)
  │  └─ Ollama not installed? → OpenRouter fallback (Tier 2)
  │
  ├─ Does this require architecture/design thinking?
  │  └─ YES → Premium (Tier 1)
  │
  ├─ Does this touch authentication/security?
  │  └─ YES → Premium (Tier 1)
  │
  ├─ Is this production code (not a throwaway script)?
  │  └─ YES → Premium (Tier 1)
  │
  ├─ Does this integrate external services?
  │  └─ YES → Premium (Tier 1)
  │
  ├─ Is the requirement ambiguous?
  │  └─ YES → Premium (Tier 1)
  │
  └─ Default → Premium (Tier 1)
     (When in doubt, use premium for quality)
```

**Golden rule:** If unsure between Tier 1 and Tier 2, choose Tier 1.  
Quality matters more than saving a few cents.

---

## What Never Uses Premium

These tasks should **always** use OpenRouter fallback or Ollama (if installed):

### Administrative Tasks
- Checking email inbox
- Reading calendar
- Checking time/date
- Looking up definitions
- Web searches

### Simple Formatting
- Adding/removing whitespace
- Fixing indentation
- JSON/YAML formatting
- Line ending conversions
- Case transformations

### Trivial Edits
- Fixing typos
- Adding missing punctuation
- Renaming variables (simple find-replace)
- Updating version numbers
- Changing string literals

### Documentation Reading
- "What does this API return?"
- "Read the React docs on useEffect"
- "What's the syntax for SQL JOIN?"

**Why:** These tasks don't require reasoning or context. Cheaper models handle them perfectly.

---

## What Always Uses Premium

These tasks should **always** use Claude Sonnet 4.5 (Tier 1):

### Architecture & Design
- System design decisions
- Database schema design
- API contract definition
- Microservices architecture
- Choosing tech stack

### Security & Authentication
- Implementing auth flows
- OAuth integration
- JWT token handling
- Security vulnerability fixes
- Rate limiting strategies

### Complex Implementation
- Multi-file refactors
- State management patterns
- Async/concurrent code
- Error handling strategies
- Performance optimization

### Ambiguous Requirements
- "Make this better"
- "Fix the UX"
- "This feels wrong"
- Feature requests without specs
- Debugging without error messages

### Integration Work
- Stripe payment processing
- Email service (SendGrid, Resend)
- Database migrations
- Third-party API integration
- Webhook handling

**Why:** These require deep reasoning, context awareness, and could have expensive consequences if done wrong.

---

## Cost Estimation Examples

### Typical Feature: User Authentication

**Tasks breakdown:**

1. **Design JWT strategy** (Premium - $0.50)
   - Architecture decision
   - Security critical
   - Long-term impact

2. **Implement auth endpoints** (Premium - $2.00)
   - Production code
   - Complex logic
   - Integration with database

3. **Write tests** (Premium - $1.00)
   - Quality critical
   - Edge cases require reasoning

4. **Update docs** (OpenRouter - $0.05)
   - Straightforward writing
   - No complex reasoning

5. **Fix typos in comments** (OpenRouter or Ollama - $0.01)
   - Mechanical edit
   - No thinking required

**Total: ~$3.56**

**Worth it?** Yes. Auth is security-critical and foundation of the app.

### Typical Task: Add Button to UI

**Tasks breakdown:**

1. **Design component API** (Premium - $0.30)
   - Reusable component design
   - Props and behavior

2. **Implement component** (Premium - $0.80)
   - React code
   - Styling with Tailwind

3. **Check if PR passed CI** (OpenRouter - $0.01)
   - Status check
   - Simple lookup

4. **Format code** (OpenRouter or Ollama - $0.01)
   - Mechanical task

**Total: ~$1.12**

**Worth it?** Yes. Component quality matters for maintainability.

### Typical Task: Fix Typo in README

**Tasks breakdown:**

1. **Find and fix typo** (OpenRouter or Ollama - $0.01)
   - Mechanical edit
   - No reasoning needed

**Total: ~$0.01**

**Worth it?** Yes. Trivial cost, quick fix.

---

## Monthly Cost Projection

Based on typical usage patterns:

### Light Month (Maintenance)
- 20 premium queries/day × 30 days = 600 queries
- Avg cost per query: ~$0.10
- **Total: ~$60/month**

### Normal Month (Active Development)
- 40 premium queries/day × 30 days = 1,200 queries
- 100 fallback queries/day × 30 days = 3,000 queries
- Premium: ~$0.10/query = $120
- Fallback: ~$0.005/query = $15
- **Total: ~$135/month**

### Heavy Month (Major Project)
- 80 premium queries/day × 30 days = 2,400 queries
- 150 fallback queries/day × 30 days = 4,500 queries
- Premium: ~$0.10/query = $240
- Fallback: ~$0.005/query = $22
- **Total: ~$262/month**

**Action if over budget:**
1. Notify Felipe immediately
2. Review usage logs
3. Identify waste (did we use premium for formatting?)
4. Defer non-critical work
5. Get Felipe approval to continue or reduce usage

---

## Cost Optimization Strategies

### 1. Batch Simple Tasks

**Bad:**
```
Query 1: "Check email" ($0.10)
Query 2: "Format this JSON" ($0.10)
Query 3: "What time is it" ($0.10)
Total: $0.30
```

**Good:**
```
Single OpenRouter query: "Check email, format this JSON, and tell me the time"
Total: $0.005
```

**Savings: 60x**

### 2. Use Context Wisely

**Bad:**
```
Load entire codebase into premium model to fix typo
Cost: $2.00
```

**Good:**
```
Use OpenRouter or Ollama for typo fix
Cost: $0.01
```

**Savings: 200x**

### 3. Cache Common Queries

**Bad:**
```
Ask "What's the React useEffect syntax?" every time
Cost per query: $0.05
10 queries: $0.50
```

**Good:**
```
Write answer to MEMORY.md after first query
Future queries: $0 (read from memory)
```

**Savings: Infinite after first query**

### 4. Right-Size the Task

**Bad:**
```
"Redesign the entire application architecture"
Single massive query: $5.00
```

**Good:**
```
"Design auth module" ($0.50)
"Design API structure" ($0.50)
"Design database schema" ($0.50)
Multiple focused queries: $1.50
```

**Savings: Better quality AND cheaper**

### 5. Use Memory to Avoid Re-Explaining

**Bad:**
```
Every session: "Here's our tech stack: React, Node, Postgres..."
Cost per session: $0.20
30 sessions: $6.00
```

**Good:**
```
Write tech stack to MEMORY.md once
Future sessions: Auto-loaded from memory
Cost: $0
```

**Savings: $6.00/month**

---

## Monitoring and Tracking

### Weekly Review

Every week, Brain should:

1. **Check OpenRouter dashboard:**
   ```
   https://openrouter.ai/usage
   ```

2. **Calculate spend to date:**
   ```
   Week 1: $X
   Week 2: $Y
   Week 3: $Z
   Projected month total: $(X+Y+Z) × 4
   ```

3. **If > 75% of budget:**
   - Alert Felipe
   - Review what's driving costs
   - Identify optimization opportunities

### Monthly Review

At month end, Felipe reviews:

1. **Total spend vs. budget**
2. **Cost per feature/task**
3. **Premium vs. fallback ratio**
4. **Any waste identified**
5. **Adjust budget or usage for next month**

### Cost Breakdown Report

Brain should be able to generate:

```markdown
## Monthly Cost Report: January 2026

**Total Spend:** $142.56 / $150 budget (95%)

**By Model:**
- Claude Sonnet 4.5: $118.20 (83%)
- OpenRouter fallback: $24.36 (17%)
- Ollama: $0 (local)

**By Task Type:**
- Feature development: $89.40 (63%)
- Bug fixes: $28.80 (20%)
- Code review responses: $15.60 (11%)
- Administrative: $8.76 (6%)

**Top Cost Drivers:**
1. User authentication system: $42.30
2. Payment integration: $31.20
3. Database migration: $18.90

**Optimization Opportunities:**
- Used premium for 12 email checks ($1.20) → Should use OpenRouter
- Loaded full context for typo fixes ($0.80) → Should use targeted edits
- Potential savings: ~$2.00/month

**Recommendation:** Within budget, quality maintained, minor optimization possible.
```

---

## OpenRouter Configuration

### Setup

```bash
# Get API key from https://openrouter.ai/keys
export OPENROUTER_API_KEY="sk-or-v1-..."

# Add to ~/.zshrc or ~/.bashrc for persistence
echo 'export OPENROUTER_API_KEY="sk-or-v1-..."' >> ~/.zshrc
```

### Recommended Models

**For simple queries (cheapest):**
```
openai/gpt-4o-mini
Cost: $0.15/1M input, $0.60/1M output
Use: 80% of fallback queries
```

**For slightly more complex tasks:**
```
google/gemini-flash-1.5
Cost: $0.075/1M input, $0.30/1M output
Use: Fast responses, good quality
```

**For staying in Claude family:**
```
anthropic/claude-3-haiku
Cost: $0.25/1M input, $1.25/1M output
Use: When consistency with Claude Sonnet matters
```

**For open source:**
```
meta-llama/llama-3.1-70b-instruct
Cost: $0.18/1M input, $0.18/1M output
Use: Privacy-conscious tasks
```

### Usage Pattern

```javascript
// Brain should route queries like this:

if (isLookupOrSimpleQuery(task)) {
  useModel('openai/gpt-4o-mini', { via: 'openrouter' })
} else if (isProductionCode(task) || needsArchitecture(task)) {
  useModel('claude-sonnet-4-20250514', { via: 'primary' })
} else {
  // Default to premium for quality
  useModel('claude-sonnet-4-20250514', { via: 'primary' })
}
```

---

## Ollama Configuration (Optional)

**Only install if disk space allows (50GB+ free recommended).**

### Installation

```bash
# macOS
brew install ollama

# Start Ollama service
ollama serve

# In another terminal, pull model
ollama pull qwen2.5-coder:7b
```

### Recommended Models

**For code editing:**
```
ollama pull qwen2.5-coder:7b
Size: ~4.4GB
Use: Mechanical code edits, formatting
```

**For general text:**
```
ollama pull llama3.1:8b
Size: ~4.7GB
Use: Documentation, simple text tasks
```

### Usage

```bash
# Test
ollama run qwen2.5-coder:7b "Fix this typo: 'teh' → 'the'"

# Use in scripts
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Rename variable usr to user in this code",
  "stream": false
}'
```

### When NOT to Install Ollama

- Disk space < 50GB free
- Rarely do mechanical edits
- Internet is reliable (OpenRouter works fine)
- Simplicity preferred over local capability

**OpenRouter fallback is sufficient for 99% of use cases.**

---

## Emergency Procedures

### If Budget Exceeded

**Immediate actions:**

1. **Stop all non-critical work**
   ```
   No new features
   Only critical bugs
   Defer optimizations
   ```

2. **Switch to OpenRouter only**
   ```
   Use GPT-4o-mini for everything
   Cost: ~90% reduction
   Quality: Acceptable for most tasks
   ```

3. **Notify Felipe**
   ```
   "Budget exceeded. Current spend: $X / $150.
   Switched to economy mode.
   Awaiting approval to continue or defer work."
   ```

4. **Review and optimize**
   ```
   Identify waste in usage logs
   Eliminate unnecessary queries
   Batch operations
   ```

### If OpenRouter Down

**Fallback chain:**

1. **Try Ollama** (if installed)
   - Handle mechanical tasks locally
   - Wait for OpenRouter to return

2. **Use premium sparingly**
   - Only for critical work
   - Document as emergency usage

3. **Defer non-critical work**
   - Wait for service restoration
   - Don't rack up premium costs

### If Costs Spike Unexpectedly

**Investigation checklist:**

1. **Check for loops or retries**
   ```
   Did we accidentally query in a loop?
   Are retries consuming tokens?
   ```

2. **Check context size**
   ```
   Are we loading unnecessary files?
   Is context window too large?
   ```

3. **Check task classification**
   ```
   Are we using premium for simple tasks?
   Should we reclassify some queries?
   ```

4. **Report to Felipe**
   ```
   Include: What happened, why, prevention plan
   ```

---

## Decision Authority

### Brain Decides

- Which tier to use for its own tasks
- When to use OpenRouter vs. Ollama (if installed)
- How to batch queries for efficiency
- What to write to memory to avoid re-explaining

### Felipe Decides

- Monthly budget limits
- Whether to continue when over budget
- Whether to install Ollama
- Policy changes to this document

### When Conflict

1. Brain explains reasoning
2. Felipe reviews cost vs. value
3. Felipe makes final call
4. Decision logged in `/FELIPE/APPROVALS.md`

---

## Cost-Quality Trade-offs

**Remember:**

- **False economy:** Using cheap model for critical code → bugs cost more than premium model
- **True economy:** Using cheap model for email checks → perfect use case
- **Waste:** Using premium for typos → completely unnecessary
- **Investment:** Using premium for architecture → pays dividends for months

**The goal is not minimum cost — it's maximum value per dollar.**

A $5 architecture decision that prevents a $50 rewrite is excellent value.  
A $5 spend on formatting is pure waste.

---

## Summary

**Model Selection:**
1. **Claude Sonnet 4.5** (Premium, Tier 1) — Default for building, architecture, production code
2. **OpenRouter** (Fallback, Tier 2) — **Primary fallback** for simple queries, lookups, email checks
3. **Ollama** (Local, Tier 3) — **Optional** for mechanical edits if disk space allows

**Budget:**
- Target: $100/month
- Hard limit: $150/month
- Brain decides tier per task
- Felipe approves budget overruns

**Philosophy:**
- Quality over cost for decisions that matter
- Never waste on mechanical tasks
- Monitor weekly, review monthly
- Optimize continuously

**Remember:**
> The most expensive model is the wrong model for the job — whether too cheap and produces bugs, or too expensive for trivial tasks.

Use the right tool for the right job.

---

End of file.
