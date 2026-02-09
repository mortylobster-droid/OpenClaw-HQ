# BRAINAGENT.md

Simplified model selection strategy for OpenClaw HQ Brain Agent.

**Philosophy:** Keep it simple. Kimi K2.5 for everything by default. Sonnet 4.5 only when Kimi struggles.

**Target monthly spend:** ~$60-80/month

---

## The Strategy (Ultra-Simplified)

**DEFAULT:** Kimi K2.5 for everything

**EXCEPTIONS:**
- **Heartbeat** (simple ops) → Gemini 2.5 Flash-Lite  
- **Web Search** → DeepSeek V3

**FALLBACK:** Sonnet 4.5 when Kimi fails

**That's it. Three models + one fallback. Simple.**

---

## The Four Models

### 1. Kimi K2.5 — DEFAULT (90% of work)

**Released:** January 27, 2026  
**Pricing:** $0.60/M input, $2.50/M output  
**Context:** 256K tokens  
**Provider:** Fireworks AI (recommended), OpenRouter, Together.ai

**Performance:**
- **SWE-bench Verified:** 76.8% (only 4% behind Opus 4.5)
- **AIME 2025:** 96.1% (olympiad-level math)
- **MMMU Pro:** 78.5% (strong vision)
- **Video-MMMU:** 86.6% (video understanding)
- **BrowseComp:** 78.4% (with Agent Swarm)

**Strengths:**
- Excellent coding (76.8% SWE-bench)
- Native multimodal (handles images/video)
- Agent Swarm (100 parallel sub-agents)
- Open source (MIT license)
- **80% cheaper than Sonnet on input**
- **83% cheaper than Sonnet on output**

**Weaknesses:**
- Slower than Gemini (~50-80 tokens/sec)
- More verbose (uses more output tokens)
- Newer model (less battle-tested)

**Use Kimi for:**
- ✅ All architecture and design
- ✅ All coding (frontend, backend, full-stack)
- ✅ All features and bug fixes
- ✅ Database work, APIs, integration
- ✅ Tests and documentation
- ✅ Image/vision tasks
- ✅ Authentication (try first, escalate if fails)
- ✅ **Everything by default**

**Escalate to Sonnet when:**
- ❌ Kimi fails 2+ times on same task
- ❌ Reviewer rejects 2+ times
- ❌ Payment processing (too critical)
- ❌ Genuinely too complex for Kimi

**Monthly allocation:** ~$40-50

---

### 2. Claude Sonnet 4.5 — FALLBACK (5% of work)

**Pricing:** $3/M input, $15/M output  
**Context:** 200K tokens

**Performance:**
- **SWE-bench Verified:** 77.2%
- **OSWorld:** 61.4%
- Second-best coding model globally

**When to use:**
- ⚠️ **ONLY when Kimi fails or struggles**
- Payment processing (no compromise)
- Kimi failed 2+ times on task
- Reviewer rejected Kimi's code 2+ times
- Security-critical code that needs highest quality
- Extremely complex architecture Kimi couldn't solve

**When NOT to use:**
- ❌ First attempt at ANY task (always try Kimi first)
- ❌ Tasks Kimi handles fine (most coding)
- ❌ Standard features or CRUD operations
- ❌ When budget is tight

**Monthly allocation:** ~$10-20 (emergency only)

---

### 3. Gemini 2.5 Flash-Lite — HEARTBEAT (5% of work)

**Pricing:** $0.10/M input, $0.40/M output  
**Context:** 1M tokens  
**Speed:** 645 tokens/second (fastest)

**Use for:**
- Email checks ("Check GitHub notifications")
- Status queries ("Did CI pass?")
- Simple lookups ("Latest commit hash?")
- Configuration reading
- Log scanning
- Quick documentation lookups

**Don't use for:**
- ❌ Code generation
- ❌ Architecture decisions
- ❌ Anything requiring reasoning

**Monthly allocation:** ~$5-10

---

### 4. DeepSeek V3 — WEB SEARCH (<5% of work)

**Pricing:** $0.27/M input, $1.10/M output  
**Context:** 128K tokens

**Use for:**
- Web research and documentation lookup
- Finding error solutions
- API reference searches
- Technology comparisons
- Stack Overflow searches

**Why DeepSeek:**
- Cheap ($0.27 vs Gemini's $0.30-0.50)
- Per your testing and preference
- Good at focused research

**Don't use for:**
- ❌ Code generation (use Kimi)
- ❌ Complex reasoning (use Kimi or Sonnet)

**Monthly allocation:** ~$5-10

---

## Decision Framework

**Simple 3-question routing:**

```
Is this a heartbeat operation?
(email check, status query, simple lookup)
├─ YES → Gemini 2.5 Flash-Lite
└─ NO ↓

Is this web search or research?
├─ YES → DeepSeek V3
└─ NO ↓

Use Kimi K2.5

Did Kimi fail or struggle (2+ attempts)?
├─ YES → Escalate to Sonnet 4.5
└─ NO → Ship it
```

**That's it. Three questions.**

---

## Escalation Rules

### Automatic Escalation to Sonnet

1. **Payment processing** — Always start with Sonnet (too critical)
2. **Kimi failed 2+ times** — Stop burning tokens, use Sonnet
3. **Reviewer rejected 2+ times** — Quality issue, escalate

### Manual Escalation (Your Judgment)

4. **Task seems beyond Kimi** — Complex multi-system architecture
5. **Mission-critical security** — When you don't trust Kimi

### Never Escalate

- Standard features → Kimi handles fine
- Bug fixes → Kimi handles fine
- Tests/docs → Kimi handles fine
- Simple refactors → Kimi handles fine

**Remember:** Kimi scores 76.8% on SWE-bench. It handles 90%+ of real work.

---

## Monthly Cost Projections

### Light Month (Maintenance)

| Model | Usage | Cost |
|-------|-------|------|
| Kimi K2.5 | 15M tokens | $25 |
| Gemini Flash-Lite | 30M tokens | $8 |
| DeepSeek V3 | 5M tokens | $4 |
| Sonnet 4.5 | 2M tokens | $8 |
| **Total** | | **$45** |

### Normal Month (Active Dev)

| Model | Usage | Cost |
|-------|-------|------|
| Kimi K2.5 | 25M tokens | $45 |
| Gemini Flash-Lite | 50M tokens | $12 |
| DeepSeek V3 | 10M tokens | $8 |
| Sonnet 4.5 | 3M tokens | $12 |
| **Total** | | **$77** |

### Heavy Month (Major Project)

| Model | Usage | Cost |
|-------|-------|------|
| Kimi K2.5 | 40M tokens | $72 |
| Gemini Flash-Lite | 80M tokens | $20 |
| DeepSeek V3 | 15M tokens | $12 |
| Sonnet 4.5 | 5M tokens | $22 |
| **Total** | | **$126** |

**Even heavy months are <$150 hard limit**

---

## Cost Comparison

### Old Strategy (Opus-Heavy)

| What | Model | Cost |
|------|-------|------|
| Everything | Opus 4.5 | ~$200 |
| Heartbeat | Haiku | ~$20 |
| **Total** | | **~$220** |

### New Strategy (Kimi-First)

| What | Model | Cost |
|------|-------|------|
| Everything | Kimi K2.5 | ~$45 |
| Heartbeat | Gemini Flash-Lite | ~$12 |
| Web Search | DeepSeek V3 | ~$8 |
| Fallback | Sonnet 4.5 | ~$12 |
| **Total** | | **~$77** |

**Savings: $143/month (65% reduction)**

---

## Implementation

### 1. Set Up API Keys

```bash
# Kimi K2.5 (via Fireworks - recommended)
export FIREWORKS_API_KEY="fw_..."

# OR via OpenRouter (easier - all models in one place)
export OPENROUTER_API_KEY="sk-or-v1-..."

# Claude Sonnet 4.5 (fallback)
export ANTHROPIC_API_KEY="sk-ant-..."

# Gemini Flash-Lite (heartbeat)
export GOOGLE_API_KEY="AIza..."

# DeepSeek V3 (web search)
export DEEPSEEK_API_KEY="sk-..."
```

### 2. Simple Routing Logic

```python
def select_model(task):
    # Heartbeat: simple operations
    if is_heartbeat(task):
        return 'gemini-2.5-flash-lite'
    
    # Web search
    if is_search(task):
        return 'deepseek-v3'
    
    # Everything else: Kimi by default
    return 'kimi-k2.5'

def handle_failure(task, attempts):
    # Escalate to Sonnet after 2 failures
    if attempts >= 2:
        logger.info(f"Kimi failed {attempts} times, escalating to Sonnet")
        return 'sonnet-4.5'
    
    return 'kimi-k2.5'
```

**That's it. No complex decision trees.**

### 3. Provider Setup

**For Kimi K2.5, choose ONE:**

**Option A: Fireworks AI** (Fastest - recommended)
- Speed: 213 tokens/sec
- Latency: 0.40s
- Sign up: https://fireworks.ai
- Model string: `accounts/fireworks/models/kimi-k2.5`

**Option B: OpenRouter** (Easiest - one API for all)
- Unified API for Kimi, Sonnet, DeepSeek
- Pricing: +10% markup
- Sign up: https://openrouter.ai
- Model string: `moonshotai/kimi-k2.5`

**Option C: Together.ai** (Good middle ground)
- Speed: 83 tokens/sec
- Sign up: https://together.ai
- Model string: `moonshotai/kimi-k2.5`

**Recommendation:** Start with **Fireworks** (fastest) or **OpenRouter** (simplest)

---

## Budget Controls

### Weekly Check

```bash
#!/bin/bash
# check-spend.sh

WEEK_SPEND=$(get_total_spend_last_7_days)
PROJECTED=$((WEEK_SPEND * 4))

echo "This week: \$${WEEK_SPEND}"
echo "Projected month: \$${PROJECTED}"

if [ $PROJECTED -gt 100 ]; then
    echo "⚠️  High burn rate - projected \$${PROJECTED}/month"
fi
```

### Spending Alerts

- **<$60/month:** Under budget (great)
- **$60-80/month:** On target (perfect)
- **$80-100/month:** Getting expensive (review usage)
- **$100-120/month:** Warning zone (reduce Kimi, increase Sonnet threshold)
- **>$120/month:** Emergency (freeze Sonnet, Kimi only)

### Daily Limits (Optional)

```python
daily_limits = {
    'kimi-k2.5': 3_000_000,  # 3M tokens/day (~$4.50)
    'sonnet-4.5': 500_000,   # 500K tokens/day max (~$4)
}

if usage['sonnet-4.5'] > daily_limits['sonnet-4.5']:
    notify_felipe("Sonnet usage high today")
```

---

## Task Examples

### Example 1: Build REST API

**Task:** "Create /api/users endpoint with CRUD operations"

**Routing:**
- Type: Standard feature
- Use: **Kimi K2.5**
- Cost: ~$0.30-0.50

**Why:** Routine work, Kimi handles perfectly

---

### Example 2: Email Check

**Task:** "Check if there are GitHub notifications"

**Routing:**
- Type: Heartbeat
- Use: **Gemini 2.5 Flash-Lite**
- Cost: ~$0.001

**Why:** Simple lookup, use cheapest model

---

### Example 3: Research Docs

**Task:** "Find documentation on React Server Components"

**Routing:**
- Type: Web search
- Use: **DeepSeek V3**
- Cost: ~$0.05

**Why:** Research task, DeepSeek good at this

---

### Example 4: Payment Integration

**Task:** "Integrate Stripe payment processing"

**Routing:**
- Type: Payment (critical)
- Use: **Sonnet 4.5** (skip Kimi entirely)
- Cost: ~$2-3

**Why:** Too critical, use best model directly

---

### Example 5: Complex Bug (Escalation)

**Task:** "Fix race condition in WebSocket handler"

**First attempt:** Kimi K2.5 → Failed  
**Second attempt:** Kimi K2.5 → Still buggy  
**Third attempt:** **Sonnet 4.5** → Success

**Cost:** ~$1.50 (Kimi tries) + $2 (Sonnet fix) = $3.50

**Why:** Auto-escalation after 2 failures

---

## Quality vs Cost

### What We Sacrifice

**Opus 4.5 → Kimi K2.5:**
- Coding: 80.9% → 76.8% (4.1% lower)
- Cost: $5/$25 → $0.60/$2.50 (88% cheaper input, 90% cheaper output)
- **Verdict:** 95% of Opus quality at <15% of cost

**Safety net:** Sonnet 4.5 available when needed

### What We Gain

- **Massive savings:** $77/month vs $220+
- **Simplicity:** One default model (Kimi)
- **Clear escalation:** Use Sonnet when Kimi fails
- **Native multimodal:** Kimi handles vision
- **Agent Swarm:** 4.5x faster on complex tasks
- **Open source:** Can self-host if needed

---

## Common Mistakes to Avoid

### ❌ Don't: Use Sonnet for simple tasks

```python
# BAD
if task == "create_api_endpoint":
    use_model("sonnet-4.5")  # Wasteful!
```

```python
# GOOD
if task == "create_api_endpoint":
    use_model("kimi-k2.5")  # Kimi handles this fine
```

### ❌ Don't: Keep trying Kimi forever

```python
# BAD
while not success:
    try_kimi_again()  # Infinite money pit!
```

```python
# GOOD
if attempts >= 2:
    escalate_to_sonnet()  # Stop wasting tokens
```

### ❌ Don't: Forget about specialized models

```python
# BAD
if task == "check_email":
    use_model("kimi-k2.5")  # Overkill
```

```python
# GOOD
if task == "check_email":
    use_model("gemini-2.5-flash-lite")  # 90% cheaper
```

---

## Quick Reference Card

**Print this:**

```
┌──────────────────────────────────────────┐
│ BRAINAGENT MODEL SELECTION               │
├──────────────────────────────────────────┤
│                                          │
│ 🟢 DEFAULT: Kimi K2.5 ($0.60/$2.50)     │
│    → All coding, architecture, features │
│    → 90% of your work                   │
│                                          │
│ 🔵 HEARTBEAT: Gemini Flash-Lite         │
│    → Email, status, lookups             │
│    → Simple ops only                    │
│                                          │
│ 🟣 WEB SEARCH: DeepSeek V3               │
│    → Research, documentation            │
│    → Finding solutions                  │
│                                          │
│ 🔴 FALLBACK: Sonnet 4.5 ($3/$15)        │
│    → When Kimi fails 2+ times           │
│    → Payments (no compromise)           │
│    → 5% of work, last resort            │
│                                          │
│ TARGET: $60-80/month                    │
│ LIMIT: $120/month                       │
│                                          │
└──────────────────────────────────────────┘
```

---

## Summary

**The strategy in 3 sentences:**

1. **Use Kimi K2.5 for everything by default** — it's 76.8% SWE-bench and handles 90% of real work
2. **Use specialized models for heartbeat and search** — Gemini Flash-Lite and DeepSeek V3 are cheaper
3. **Escalate to Sonnet 4.5 only when Kimi fails** — after 2 attempts or for payments

**Expected cost:** ~$77/month (vs $220 with Opus strategy)

**Quality trade-off:** Minimal (Kimi is 95% of Opus, Sonnet available as safety net)

**Complexity:** Ultra-low (one default model, clear escalation path)

**The rule:**

> Default to Kimi. Use specialists for heartbeat/search. Escalate to Sonnet when necessary.

---

End of file.
