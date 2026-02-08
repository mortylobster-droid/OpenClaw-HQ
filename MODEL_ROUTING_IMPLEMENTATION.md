# Model Routing Implementation Summary

**Created:** 2026-02-08  
**Author:** Rick Sanchez (Brain Agent)  
**Goal:** Reduce monthly AI costs from $270 to $100-150 while maintaining quality

---

## What I Built

### 1. Multi-Model Configuration

Added 5 models to OpenClaw config:

```json
{
  "openrouter/anthropic/claude-sonnet-4.5": "Premium - $3/$15 per M tokens",
  "openrouter/google/gemini-flash-1.5": "Mid-tier - $0.075/$0.30 (95% cheaper)",
  "openrouter/google/gemini-2.0-flash-exp:free": "Free tier (experimental)",
  "openrouter/openai/gpt-4o-mini": "Budget - $0.15/$0.60 (98% cheaper)",
  "openrouter/deepseek/deepseek-chat": "Coding specialist - $0.27/$1.10"
}
```

**Status:** ✅ Configured and active (gateway restarted)

### 2. Model Router Skill

**Location:** `/skills/model-router/SKILL.md`

**Purpose:** Decision tree for automatic model selection

**Classification:**
- 🔴 **Premium (Sonnet 4.5):** Auth, security, payments, architecture, critical code
- 🟡 **Mid-tier (Gemini Flash):** Standard features, APIs, frontends, tests, research (DEFAULT)
- 🟢 **Budget (GPT-4o-mini):** Email checks, status queries, formatting, lookups
- ⚪ **Specialist (DeepSeek):** Pure algorithmic coding, math-heavy tasks

**Status:** ✅ Created and documented

### 3. Workspace Reminders

**Location:** `~/.openclaw/workspace/MODEL_ROUTING.md`

**Purpose:** Always-visible reminder to classify tasks before execution

**Contains:**
- Decision triggers for each tier
- Example tasks per tier
- Weekly cost monitoring rules
- Manual override commands

**Status:** ✅ Created (will be auto-loaded in context)

### 4. Updated SOUL.md

**Changes:**
- Added mandatory cost awareness
- Requires reading `MODEL_ROUTING.md` at session start
- Philosophy: "Right model for right job"

**Status:** ✅ Updated

---

## Current Limitations

### ⚠️ NOT Fully Automatic (Yet)

OpenClaw doesn't have native "task complexity → model selection" routing built-in.

**What this means:**
- Brain agent (me) must manually classify each task
- I read the MODEL_ROUTING.md rules and decide
- I announce model choice before executing
- Not a transparent middleware

**This is more like a trained habit than automatic enforcement.**

---

## How It Works in Practice

### Example 1: Premium Task

**User:** "Build JWT authentication for the API"

**My Response:**
```
*burp* Alright, authentication is security-critical.

Using Sonnet 4.5 (premium model) for this — no compromise on auth.

[proceeds with implementation]
```

**Model Used:** `openrouter/anthropic/claude-sonnet-4.5`  
**Cost:** ~$2-3 for full implementation

---

### Example 2: Mid-Tier Task

**User:** "Create a React component for the user dashboard"

**My Response:**
```
Standard frontend work. Using Gemini Flash (mid-tier) for this.

[proceeds with implementation]
```

**Model Used:** `openrouter/google/gemini-flash-1.5`  
**Cost:** ~$0.10-0.20 for full component

---

### Example 3: Budget Task

**User:** "Check if there are any new GitHub notifications"

**My Response:**
```
Simple lookup. Using GPT-4o-mini (budget model).

[checks and reports]
```

**Model Used:** `openrouter/openai/gpt-4o-mini`  
**Cost:** ~$0.001-0.01 for the check

---

## Cost Projections

### Before (Sonnet-Only Strategy)

| Task Type | Monthly Tasks | Cost/Task | Total |
|-----------|--------------|-----------|-------|
| Complex features | 10 | $5 | $50 |
| Standard features | 40 | $2 | $80 |
| Bug fixes | 20 | $1 | $20 |
| Status checks | 100 | $0.10 | $10 |
| Email checks | 200 | $0.10 | $20 |
| Research | 30 | $2 | $60 |
| **Total** | | | **$240** |

---

### After (Tiered Strategy)

| Task Type | Model | Monthly Tasks | Cost/Task | Total |
|-----------|-------|--------------|-----------|-------|
| Complex features | Sonnet | 10 | $5 | $50 |
| Standard features | Gemini | 40 | $0.20 | $8 |
| Bug fixes | Gemini | 20 | $0.10 | $2 |
| Status checks | GPT-4o-mini | 100 | $0.01 | $1 |
| Email checks | GPT-4o-mini | 200 | $0.005 | $1 |
| Research | Gemini | 30 | $0.10 | $3 |
| **Total** | | | | **$65** |

**Savings:** $175/month (73% reduction)

**With buffer for spikes:** ~$100-120/month typical usage

---

## What You Need To Do

### Option A: Accept Semi-Automatic (Current State)

**How it works:**
- I (Brain) classify tasks manually using MODEL_ROUTING.md
- I announce model choice before execution
- You trust me to follow the rules

**Pros:**
- Works immediately
- No additional code needed
- Flexible (I can override when needed)

**Cons:**
- Relies on me remembering
- Not enforced by code
- Could forget under high load

**Recommendation:** Start here, track costs for 1 week

---

### Option B: Build True Automation (Future Enhancement)

**What we'd build:**

1. **Pre-processor middleware** (Node.js service)
   - Intercepts Telegram → OpenClaw messages
   - Classifies task using regex + keywords
   - Routes to appropriate OpenRouter model
   - Transparent to user

2. **Cost tracking dashboard**
   - Real-time spend by model tier
   - Weekly/monthly projections
   - Alerts when approaching budget limits

3. **Sub-agent architecture** (more complex)
   - `brain-premium` session (Sonnet 4.5)
   - `brain-standard` session (Gemini Flash)
   - `brain-budget` session (GPT-4o-mini)
   - Dispatcher routes tasks to appropriate sub-agent

**Effort:** 4-8 hours to build and test  
**Complexity:** Medium  
**Reliability:** High (truly automatic)

**Recommendation:** Build this if semi-automatic approach shows cost drift

---

## Monitoring & Adjustment

### Weekly Review (Every Monday)

1. **Check OpenRouter dashboard:**
   ```
   https://openrouter.ai/usage
   ```

2. **Calculate weekly spend:**
   ```
   Week 1: $X
   Projected monthly: $X × 4.3
   ```

3. **If > $30/week ($130/month projected):**
   - Review what's driving costs
   - Shift more tasks to Gemini
   - Reduce Sonnet usage for non-critical work

4. **Report to Felipe:**
   ```
   "Week 1 spend: $25. Projected: $107/month. On track."
   ```

---

### Budget Alerts

**Thresholds:**

- **$75 monthly spend:** ✅ Healthy, continue
- **$100 monthly spend:** ⚠️  At target, monitor closely
- **$130 monthly spend:** 🔶 Over target, increase Gemini usage
- **$140 monthly spend:** 🔴 Critical, alert Felipe + switch to budget mode

**Budget mode:**
- Disable Sonnet except for explicit auth/security tasks
- All routine work → Gemini Flash
- All lookups → GPT-4o-mini
- Continue until month resets or Felipe approves overage

---

## Manual Override Commands

### For You (Atlas)

You can always force a specific model:

```
"Use premium model for this"
"Use cheap model for this"
"Use default model"
```

I'll respect your override.

---

### For Me (Brain)

When uncertain about classification:

**Default to mid-tier** (Gemini Flash) and mention:
```
"Classified as standard work, using Gemini Flash. 
Let me know if you want premium (Sonnet) instead."
```

Never waste premium on obvious budget tasks.  
Never cheap out on security/auth/payments.

---

## Next Steps

### Immediate (This Week)

1. **I start self-policing** using MODEL_ROUTING.md
2. **Track actual costs** for 7 days
3. **You monitor** OpenRouter dashboard
4. **We review** Friday: Did it work? Any surprises?

### Short-Term (Next 2 Weeks)

5. **Adjust routing rules** based on actual usage
6. **Identify tasks** that were mis-classified
7. **Refine decision tree** in MODEL_ROUTING.md

### Long-Term (If Needed)

8. **Build middleware** for true automation
9. **Create cost dashboard** for real-time tracking
10. **Consider sub-agent architecture** if scaling up

---

## Success Metrics

**Quality:**
- Reviewer approval rate stays >90%
- Bug rate stays <5%
- No degradation on critical features

**Cost:**
- Monthly spend: $100-120 typical, <$150 hard limit
- Premium tier: ~20% of tasks, ~60% of budget
- Mid-tier: ~60% of tasks, ~30% of budget
- Budget tier: ~20% of tasks, ~10% of budget

**Efficiency:**
- Average cost per feature: <$5 (vs $10+ before)
- Simple queries: <$0.05 each
- Research tasks: <$0.20 each

---

## Summary

✅ **Configured:** 5 models in OpenClaw (Sonnet, Gemini, GPT-4o-mini, DeepSeek)  
✅ **Documented:** Model Router skill with decision tree  
✅ **Created:** MODEL_ROUTING.md for session-start reminders  
✅ **Updated:** SOUL.md with mandatory cost awareness  
✅ **Committed:** All changes pushed to GitHub

⚠️ **Current state:** Semi-automatic (relies on me following rules)  
🚀 **Future enhancement:** Build middleware for full automation if needed

**Expected savings:** $175/month (73% reduction) from Sonnet-only approach

**Target monthly spend:** $100-120  
**Hard limit:** $150

**Philosophy:**  
> "The most expensive model is the wrong model for the job."

Use premium where it matters. Use budget where it doesn't. Stay smart. Stay in budget.

*burp*

---

**Ready to test this approach?**

Let's run for a week and see actual costs. Then we can decide if we need the full automation build or if this semi-automatic approach is good enough.

What do you think, Atlas?
