# BRAINAGENT.md

Cost-effective model selection strategy for OpenClaw HQ Brain Agent.

**Philosophy:** Quality where it matters, efficiency everywhere else. No Opus 4.5 (out of budget). Willing to pay for Sonnet 4.5 when it's the second-best option. Not chasing absolute cheapest — chasing best value.

**Target monthly spend:** ~$100-150 (vs $200+ with Opus-heavy strategy)

---

## Core Principle

**Right model for the right job.**

We're running a 2-agent system (Brain + Reviewer):
- **Brain (Mac mini):** Full-stack builder, needs quality models
- **Reviewer (VPS):** Quality gate, uses Codex (free)

Brain needs **smart routing** across model tiers:
1. **Premium tier** (Sonnet 4.5) → Complex architecture, critical code
2. **Mid tier** (Gemini 2.5 Flash) → Most daily work
3. **Budget tier** (Gemini 2.5 Flash-Lite) → Simple queries, status checks

---

## Model Selection by Task Type

### Tier 1: Premium (Claude Sonnet 4.5)

**When to use:** Complex building, architecture, critical decisions

**Cost:** $3/M input, $15/M output

**Use for:**
- System architecture and design
- Authentication/security implementation
- Payment processing integration
- Complex multi-file refactors
- Database schema design
- API contract definitions
- Production code with edge cases
- Debugging complex issues
- Large feature implementation

**Why Sonnet 4.5 (not Opus 4.5):**
- **SWE-bench Verified:** 77.2% (vs Opus 80.9%) — only 3.7% difference
- **OSWorld (agents):** 61.4% — excellent for autonomous tasks
- **Cost:** $3/$15 (vs Opus $5/$25) — **40% cheaper**
- **Speed:** Faster than Opus for most tasks
- **Quality:** Second-best coding model globally

**Trade-off:** Lose ~4% coding accuracy vs Opus, save 40% on costs. Totally worth it.

**Monthly allocation:** ~$60-80 (for heavy building work)

---

### Tier 2: Mid-Range (Gemini 2.5 Flash)

**When to use:** Most everyday development work

**Cost:** $0.30/M input, $2.50/M output

**Use for:**
- Standard feature implementation
- Frontend components (React, Vue)
- Backend API endpoints (straightforward)
- Database queries (non-complex)
- Test writing
- Documentation writing
- Code reviews (before Reviewer sees it)
- Bug fixes (non-critical)
- Refactoring (single file)
- Configuration updates

**Why Gemini 2.5 Flash:**
- **90% cheaper than Sonnet** ($0.30 vs $3 input)
- **1M token context** (vs Sonnet 200K) — 5x larger
- **Fast:** 274 tokens/second
- **Good enough** for 70% of daily work
- **Native multimodal:** Handles images, PDFs, video
- **Google Search integration:** Built-in web search when needed

**Trade-off:** Not as good at complex reasoning as Sonnet, but handles routine work perfectly.

**Monthly allocation:** ~$30-40 (bulk of daily tasks)

---

### Tier 3: Budget (Gemini 2.5 Flash-Lite)

**When to use:** Simple queries, lookups, status checks

**Cost:** $0.10/M input, $0.40/M output

**Use for:**
- Email checks ("Any GitHub notifications?")
- Status queries ("Did CI pass?")
- Simple lookups ("What's the latest commit?")
- Documentation reading
- Environment variable updates
- Simple text formatting
- Quick Q&A
- Log analysis
- Configuration reading

**Why Gemini 2.5 Flash-Lite:**
- **97% cheaper than Sonnet** ($0.10 vs $3 input)
- **Fastest model available:** 645 tokens/second
- **1M token context**
- **Good for high-volume, simple ops**

**Trade-off:** Less capable reasoning, but perfect for mechanical tasks.

**Monthly allocation:** ~$10-20 (high-volume simple tasks)

---

## Specialized Tasks

### Web Search & Research

**Model:** Gemini 3 Flash (or Gemini 2.5 Flash)

**Cost:** ~$0.30-0.50/M input, ~$2/M output

**Use for:**
- Researching documentation
- Finding solutions to errors
- Comparing approaches
- Looking up API references
- Competitive analysis
- News/updates in tech stack

**Why Gemini:**
- **Native Google Search integration** (huge advantage)
- **Purpose-built for research tasks**
- **Multimodal:** Can analyze images from web
- **Much cheaper than Sonnet**

**Don't use:**
- ❌ Sonnet 4.5 (expensive, not optimized for search)
- ❌ DeepSeek V3 (actually weak at web search per benchmarks)

**Monthly allocation:** ~$5-10

---

### Image Understanding & Vision

**Model:** Gemini 3 Flash

**Cost:** ~$0.30-0.50/M input (images), ~$2/M output

**Use for:**
- Analyzing UI mockups
- Reading diagrams/charts
- Processing screenshots
- Extracting text from images (OCR)
- Understanding error screenshots
- Design feedback

**Why Gemini 3 Flash:**
- **Best-in-class vision:** 81% MMMU-Pro, 87.6% Video-MMMU
- **Native multimodal architecture**
- **Much cheaper than Claude models**

**Don't use:**
- ❌ Sonnet 4.5 (supports vision but not optimized, expensive)

**Monthly allocation:** ~$5-10

---

### Heavy Coding (Alternative)

**Model:** DeepSeek V3.2 (optional, for cost savings)

**Cost:** $0.21/M input, $0.32/M output

**Use for:**
- Large coding tasks when budget tight
- Algorithm implementation
- Mathematical/computational tasks
- Non-critical code generation
- Internal tools (not customer-facing)

**Why DeepSeek V3.2:**
- **95% cheaper than Sonnet**
- **Excellent coding:** 82.6% HumanEval (beats GPT-4o)
- **Strong math:** 90.2% MATH-500
- **Open source:** MIT license

**Trade-offs:**
- No vision support
- Weaker at agent workflows
- Less ecosystem maturity
- Slightly less reliable than Claude

**When to use:**
- Budget is tight
- Task is pure coding (no multimodal)
- Can afford to review output carefully

**Monthly allocation:** ~$5-15 (if used instead of some Sonnet work)

---

## Decision Framework

**START:** New task arrives

```
Is this authentication, payments, or security-critical?
├─ YES → Sonnet 4.5 (no compromise on security)
└─ NO ↓

Is this complex architecture or multi-system design?
├─ YES → Sonnet 4.5 (quality matters long-term)
└─ NO ↓

Is this a simple lookup, status check, or email?
├─ YES → Gemini 2.5 Flash-Lite (cheap & fast)
└─ NO ↓

Does this need web search or research?
├─ YES → Gemini 3 Flash (built for it)
└─ NO ↓

Does this involve images, diagrams, or UI analysis?
├─ YES → Gemini 3 Flash (best vision)
└─ NO ↓

Is this standard feature work (API, frontend, tests)?
├─ YES → Gemini 2.5 Flash (good quality, 90% cheaper)
└─ NO ↓

Is this pure algorithmic/math-heavy coding?
├─ YES → Consider DeepSeek V3.2 (excellent & cheap)
└─ NO → Default to Gemini 2.5 Flash
```

**Rule of thumb:**
- **Sonnet 4.5:** ~20% of tasks (the critical 20%)
- **Gemini 2.5 Flash:** ~60% of tasks (daily workhorse)
- **Gemini 2.5 Flash-Lite:** ~15% of tasks (simple ops)
- **Gemini 3 Flash:** ~5% of tasks (search/vision)

---

## Monthly Cost Projection

### Light Month (Maintenance Mode)

**Scenario:** Bug fixes, small updates, monitoring

| Model | Usage | Cost |
|-------|-------|------|
| Sonnet 4.5 | 5M tokens (I/O) | ~$20 |
| Gemini 2.5 Flash | 10M tokens | ~$15 |
| Gemini 2.5 Flash-Lite | 20M tokens | ~$5 |
| Gemini 3 Flash (search/vision) | 2M tokens | ~$3 |
| **Total** | | **~$43** |

**Headroom:** $57 left in $100 budget

---

### Normal Month (Active Development)

**Scenario:** Multiple features, integrations, regular pace

| Model | Usage | Cost |
|-------|-------|------|
| Sonnet 4.5 | 15M tokens (I/O) | ~$60 |
| Gemini 2.5 Flash | 25M tokens | ~$35 |
| Gemini 2.5 Flash-Lite | 40M tokens | ~$10 |
| Gemini 3 Flash (search/vision) | 5M tokens | ~$8 |
| **Total** | | **~$113** |

**Within budget:** $100-150 target range

---

### Heavy Month (Major Project)

**Scenario:** Large feature, complex integration, refactor

| Model | Usage | Cost |
|-------|-------|------|
| Sonnet 4.5 | 25M tokens (I/O) | ~$95 |
| Gemini 2.5 Flash | 35M tokens | ~$50 |
| Gemini 2.5 Flash-Lite | 50M tokens | ~$12 |
| Gemini 3 Flash (search/vision) | 8M tokens | ~$12 |
| **Total** | | **~$169** |

**Slightly over:** Can reduce Gemini usage or get Felipe approval

**With DeepSeek alternative for heavy coding:**

| Model | Usage | Cost |
|-------|-------|------|
| Sonnet 4.5 | 15M tokens | ~$60 |
| DeepSeek V3.2 | 30M tokens | ~$12 |
| Gemini 2.5 Flash | 25M tokens | ~$35 |
| Gemini 2.5 Flash-Lite | 50M tokens | ~$12 |
| Gemini 3 Flash | 8M tokens | ~$12 |
| **Total** | | **~$131** |

**Back in budget** by using DeepSeek for heavy coding

---

## Cost Comparison: Our Strategy vs Opus Strategy

### Opus-Heavy Strategy (Original Chart)

| Component | Model | Monthly Cost |
|-----------|-------|--------------|
| Brain/Architecture | Opus 4.5 | ~$120 |
| Daily coding | Opus 4.5 | ~$80 |
| Search/Research | Opus 4.5 | ~$30 |
| Vision tasks | Opus 4.5 | ~$20 |
| Simple queries | Haiku | ~$20 |
| **Total** | | **~$270** |

**Problem:** Way over budget, wastes Opus on non-optimal tasks

---

### Our Strategy (Sonnet + Gemini)

| Component | Model | Monthly Cost |
|-----------|-------|--------------|
| Critical work | Sonnet 4.5 | ~$60 |
| Daily coding | Gemini 2.5 Flash | ~$35 |
| Search/Research | Gemini 3 Flash | ~$8 |
| Vision tasks | Gemini 3 Flash | ~$5 |
| Simple queries | Gemini 2.5 Flash-Lite | ~$10 |
| **Total** | | **~$118** |

**Savings:** $152/month (56% reduction)  
**Quality:** Minimal compromise (Sonnet is second-best, Gemini excellent for its tasks)

---

## Quality vs Cost Analysis

### What We Sacrifice

**Opus 4.5 → Sonnet 4.5:**
- **Coding accuracy:** 80.9% → 77.2% (3.7% loss)
- **Cost:** $5/$25 → $3/$15 (40% savings)
- **Verdict:** Worth it. 96% of Opus quality at 60% of cost.

**Sonnet → Gemini 2.5 Flash (for routine work):**
- **General capability:** Still very strong (Google's tier-2 model)
- **Context:** Actually larger (1M vs 200K)
- **Cost:** 90% cheaper
- **Verdict:** Smart routing. Use Sonnet for hard stuff, Gemini for routine.

**Haiku → Gemini 2.5 Flash-Lite (for simple ops):**
- **Capability:** Comparable for simple tasks
- **Speed:** Actually faster (645 vs ~200 tokens/sec)
- **Cost:** 92% cheaper
- **Verdict:** No-brainer. Flash-Lite is better AND cheaper.

### What We Gain

- **Budget headroom:** Can handle spikes without stress
- **Larger contexts:** Gemini's 1M vs Claude's 200K
- **Native search:** Gemini integrates Google Search
- **Better vision:** Gemini 3 Flash beats Claude models
- **Flexibility:** Can use DeepSeek for pure coding if needed

---

## Implementation Strategy

### Phase 1: Foundation (Month 1)

**Goal:** Get basic routing working

**Setup:**
1. Configure Sonnet 4.5 via Anthropic API or OpenRouter
2. Configure Gemini 2.5 Flash, Flash-Lite, 3 Flash via Google AI Studio
3. Create routing function in Brain agent

**Routing logic:**
```python
def select_model(task_type, complexity, budget_used):
    # Security/payments always premium
    if task_type in ['auth', 'payments', 'security']:
        return 'sonnet-4.5'
    
    # Simple ops always budget
    if complexity == 'simple':
        return 'gemini-2.5-flash-lite'
    
    # Search/research always Gemini
    if task_type in ['search', 'research', 'web']:
        return 'gemini-3-flash'
    
    # Vision always Gemini
    if task_type == 'vision':
        return 'gemini-3-flash'
    
    # Complex architecture → premium
    if complexity == 'high' and task_type in ['architecture', 'design']:
        return 'sonnet-4.5'
    
    # Budget check: if >75% spent, downgrade
    if budget_used > 0.75:
        return 'gemini-2.5-flash'
    
    # Default: mid-tier for routine work
    return 'gemini-2.5-flash'
```

**Test:** Run 50 varied tasks, track costs and quality

---

### Phase 2: Optimization (Month 2-3)

**Goal:** Refine routing based on real usage

**Track:**
1. Cost per task type
2. Quality metrics (Reviewer feedback)
3. Tasks where model struggled
4. Budget burn rate

**Adjust:**
- Move more tasks to Gemini if quality acceptable
- Identify tasks that actually need Sonnet
- Find unnecessary Sonnet usage

**Target:** <$120/month average

---

### Phase 3: Advanced (Month 4+)

**Goal:** Cost optimization without quality loss

**Implement:**
1. **Prompt caching** (Anthropic feature)
   - Reuse system prompts
   - Cache frequently accessed docs
   - 50-90% savings on repeated context

2. **Batch processing**
   - Group similar tasks together
   - Send to appropriate model in batch
   - Reduce API overhead

3. **Output limiting**
   - Set max_tokens appropriately
   - Don't generate more than needed
   - Especially important for expensive models

4. **Smart context**
   - Only include relevant files
   - Don't load entire codebase for typo fix
   - Use Gemini's 1M context wisely

**Target:** <$100/month average

---

## Budget Alerts & Controls

### Weekly Review

**Every Monday, Brain checks:**

```python
weekly_spend = get_last_7_days_cost()
projected_monthly = weekly_spend * 4.3

if projected_monthly > 120:
    alert = f"Projected: ${projected_monthly}, target: $100-120"
    notify_felipe(alert)
    
    # Auto-adjust: shift more to Gemini
    increase_gemini_threshold()
```

### Daily Limits

**Prevent runaway costs:**

```python
daily_limits = {
    'sonnet-4.5': 2_000_000,  # 2M tokens/day max
    'gemini-2.5-flash': 5_000_000,  # 5M tokens/day
    'gemini-2.5-flash-lite': 10_000_000,  # 10M tokens
}

# If hit limit, downgrade to next tier
if usage['sonnet-4.5'] > daily_limits['sonnet-4.5']:
    use_model = 'gemini-2.5-flash'  # fallback
```

### Emergency Mode

**If budget hits $140 (93% of $150 hard limit):**

```python
if monthly_spend > 140:
    # EMERGENCY: Only Gemini models
    disable_premium_tier()
    use_only = ['gemini-2.5-flash', 'gemini-2.5-flash-lite']
    
    notify_felipe("Budget critical: $140/$150. Premium disabled.")
```

---

## Task Examples with Routing

### Example 1: User Authentication System

**Task:** "Implement JWT authentication with refresh tokens"

**Routing Decision:**
- **Type:** Security-critical
- **Complexity:** High
- **Model:** Sonnet 4.5

**Reasoning:** Auth is security-critical, needs best model. No compromise.

**Estimated cost:** $2-3 for full implementation

---

### Example 2: Blog Post API Endpoint

**Task:** "Create GET /api/posts endpoint with pagination"

**Routing Decision:**
- **Type:** Standard feature
- **Complexity:** Medium
- **Model:** Gemini 2.5 Flash

**Reasoning:** Routine work, well-defined, Gemini handles perfectly.

**Estimated cost:** $0.15-0.30

---

### Example 3: Email Check

**Task:** "Check if there are new GitHub notifications"

**Routing Decision:**
- **Type:** Simple query
- **Complexity:** Low
- **Model:** Gemini 2.5 Flash-Lite

**Reasoning:** Trivial task, cheapest model perfect for this.

**Estimated cost:** $0.001-0.01

---

### Example 4: Research Stripe API

**Task:** "Find documentation on Stripe webhooks and payment intents"

**Routing Decision:**
- **Type:** Web search
- **Complexity:** Medium
- **Model:** Gemini 3 Flash

**Reasoning:** Search task, Gemini has native Google integration.

**Estimated cost:** $0.05-0.10

---

### Example 5: Analyze UI Mockup

**Task:** "Look at this Figma screenshot and suggest component structure"

**Routing Decision:**
- **Type:** Vision
- **Complexity:** Medium
- **Model:** Gemini 3 Flash

**Reasoning:** Vision task, Gemini 3 Flash has best image understanding.

**Estimated cost:** $0.10-0.20

---

### Example 6: Complex Algorithm

**Task:** "Implement Dijkstra's algorithm with optimizations for sparse graphs"

**Routing Decision:**
- **Type:** Algorithmic coding
- **Complexity:** High
- **Model:** Sonnet 4.5 OR DeepSeek V3.2

**Reasoning:** 
- If budget OK → Sonnet (highest quality)
- If budget tight → DeepSeek (excellent at algorithms, 95% cheaper)

**Estimated cost:** 
- Sonnet: $0.80-1.50
- DeepSeek: $0.05-0.10

---

## Provider Configuration

### Anthropic (Sonnet 4.5)

```bash
# Direct API (no markup)
export ANTHROPIC_API_KEY="sk-ant-..."

# Model string
model: "claude-sonnet-4-20250514"
```

**Pricing:** $3/M input, $15/M output

**Set monthly limit:** $100 via Anthropic dashboard

---

### Google AI Studio (Gemini Models)

```bash
# Get API key
export GOOGLE_API_KEY="AIza..."

# Model strings
gemini-2.5-flash
gemini-2.5-flash-lite
gemini-3-flash
```

**Pricing:**
- 2.5 Flash: $0.30/M in, $2.50/M out
- 2.5 Flash-Lite: $0.10/M in, $0.40/M out
- 3 Flash: ~$0.30-0.50/M in, ~$2/M out

**Set quota:** 50M tokens/month via Google Cloud Console

---

### OpenRouter (Fallback/Alternative)

```bash
# For accessing Sonnet or other models
export OPENROUTER_API_KEY="sk-or-v1-..."

# Model strings
anthropic/claude-sonnet-4-20250514
google/gemini-2.5-flash
```

**Trade-off:** 10% markup but single API for all models

**Use when:**
- Simpler than managing multiple provider APIs
- Want unified cost tracking
- Willing to pay 10% for convenience

---

### DeepSeek (Optional, Budget Saver)

```bash
# Direct API
export DEEPSEEK_API_KEY="sk-..."

# Model string
deepseek-chat-v3.2
```

**Pricing:** $0.21/M input, $0.32/M output

**Use when:**
- Pure coding tasks
- Budget is tight
- Can afford careful review

---

## Cost Tracking

### Daily Check

```bash
# Script: check-costs.sh
#!/bin/bash

ANTHROPIC_COST=$(get_anthropic_usage)
GOOGLE_COST=$(get_google_usage)
TOTAL=$((ANTHROPIC_COST + GOOGLE_COST))

echo "Today: \$${TOTAL}"
echo "Sonnet: \$${ANTHROPIC_COST}"
echo "Gemini: \$${GOOGLE_COST}"

if [ $TOTAL -gt 5 ]; then
    echo "⚠️  High usage today (>\$5)"
fi
```

### Weekly Report

```markdown
## Week of [Date]

**Total spend:** $XX / $30 weekly target

**By model:**
- Sonnet 4.5: $XX (XX% of total)
- Gemini 2.5 Flash: $XX (XX%)
- Gemini 2.5 Flash-Lite: $XX (XX%)
- Gemini 3 Flash: $XX (XX%)

**Top tasks:**
1. [Task type]: $XX
2. [Task type]: $XX
3. [Task type]: $XX

**Projection:** On track for $XX/month
```

### Monthly Reconciliation

```markdown
## Month: [Month]

**Final spend:** $XXX / $120 target

**Variance:** +/- $XX

**By tier:**
- Premium (Sonnet): XX% of budget
- Mid (Gemini Flash): XX%
- Budget (Flash-Lite): XX%
- Specialized (3 Flash): XX%

**Insights:**
- What worked well
- What cost more than expected
- Adjustments for next month

**Next month target:** $XXX
```

---

## Success Metrics

### Quality Metrics

1. **Reviewer approval rate**
   - Target: >90% of PRs approved without major changes
   - Track by model tier

2. **Bug rate**
   - Target: <5% of deployed code has bugs
   - Track which model produced buggy code

3. **Iteration count**
   - Target: Average <2 iterations per feature
   - High iterations = wrong model tier

### Cost Metrics

1. **Cost per feature**
   - Track actual spend per completed feature
   - Compare Sonnet vs Gemini features

2. **Budget utilization**
   - Target: 80-95% of monthly budget
   - <80% = too conservative
   - >95% = too aggressive

3. **Cost per model tier**
   - Ensure routing is working correctly
   - Should be ~20% Sonnet, ~60% Gemini Flash, ~20% Flash-Lite

---

## Common Pitfalls to Avoid

### 1. Over-using Sonnet

**Symptom:** Sonnet costs >$100/month

**Problem:** Using premium model for routine work

**Fix:** Audit Sonnet usage, move routine tasks to Gemini

---

### 2. Under-using Sonnet

**Symptom:** High bug rate, many Reviewer rejections

**Problem:** Using Gemini for tasks that need Sonnet

**Fix:** Identify complex tasks, route to Sonnet

---

### 3. Ignoring Context Size

**Symptom:** Hitting token limits, truncated context

**Problem:** Loading full codebase for simple task

**Fix:** Be selective about context, use Gemini's 1M window wisely

---

### 4. Not Tracking Costs

**Symptom:** Surprise overages

**Problem:** Not monitoring daily spend

**Fix:** Implement daily checks, weekly reports

---

### 5. Analysis Paralysis

**Symptom:** Spending too long deciding which model

**Problem:** Over-optimizing model selection

**Fix:** Use decision tree, default to Gemini Flash when uncertain

---

## Quick Reference Card

Print this and keep handy:

```
┌─────────────────────────────────────────────────┐
│ BRAINAGENT MODEL SELECTION QUICK GUIDE          │
├─────────────────────────────────────────────────┤
│                                                 │
│ 🔴 SONNET 4.5 ($3/$15)                         │
│ → Auth, payments, security                     │
│ → Complex architecture                         │
│ → Critical production code                     │
│ → Multi-system integration                     │
│                                                 │
│ 🟡 GEMINI 2.5 FLASH ($0.30/$2.50)             │
│ → Standard features                            │
│ → Frontend/backend APIs                        │
│ → Tests & documentation                        │
│ → Most daily work                              │
│                                                 │
│ 🟢 GEMINI 2.5 FLASH-LITE ($0.10/$0.40)        │
│ → Email/status checks                          │
│ → Simple queries                               │
│ → Quick lookups                                │
│ → High-volume ops                              │
│                                                 │
│ 🔵 GEMINI 3 FLASH ($0.30-0.50/$2)             │
│ → Web search                                   │
│ → Image analysis                               │
│ → Vision tasks                                 │
│ → Research                                     │
│                                                 │
│ ⚪ DEEPSEEK V3.2 ($0.21/$0.32) [OPTIONAL]     │
│ → Pure coding (non-critical)                   │
│ → Algorithms/math                              │
│ → When budget tight                            │
│                                                 │
│ MONTHLY TARGET: $100-120                       │
│ HARD LIMIT: $150                               │
│                                                 │
└─────────────────────────────────────────────────┘
```

---

## Summary

**Our strategy:**
- **Premium (Sonnet 4.5):** 20% of work, 50% of budget — critical tasks only
- **Mid (Gemini 2.5 Flash):** 60% of work, 30% of budget — daily workhorse
- **Budget (Gemini 2.5 Flash-Lite):** 15% of work, 10% of budget — simple ops
- **Specialized (Gemini 3 Flash):** 5% of work, 10% of budget — search/vision

**Expected monthly spend:** $100-120 (vs $270 with Opus strategy)

**Quality sacrifice:** Minimal (Sonnet is 96% of Opus quality)

**Key insight:** Right model for right task beats "always use best model"

**Remember:**
> "The most expensive model is the wrong model for the job — whether too cheap and produces bugs, or too expensive for trivial tasks."

Use Sonnet for what matters. Use Gemini for everything else. Stay in budget. Ship quality code.

---

End of file.
