---
name: model-router
description: Automatically select the most cost-effective model based on task complexity. Use this to route between premium (Sonnet 4.5), mid-tier (Gemini Flash), and budget (GPT-4o-mini) models based on task type.
---

# Model Router Skill

Implements intelligent model selection based on task complexity to optimize cost vs. quality.

## Decision Tree

```
Is this auth/payments/security-critical?
├─ YES → Sonnet 4.5 (no compromise)
└─ NO ↓

Is this a simple lookup/status/email check?
├─ YES → GPT-4o-mini (cheapest)
└─ NO ↓

Does this need web search or research?
├─ YES → Gemini Flash (built-in search)
└─ NO ↓

Is this standard feature work (API/frontend)?
├─ YES → Gemini Flash (90% cheaper, good quality)
└─ NO ↓

Is this complex architecture or critical production code?
├─ YES → Sonnet 4.5 (premium quality)
└─ NO → Gemini Flash (default mid-tier)
```

## Usage

Before processing any user request, evaluate task type:

### Tier 1: Premium (Claude Sonnet 4.5)
**Model:** `openrouter/anthropic/claude-sonnet-4.5`  
**Cost:** $3/M input, $15/M output

**Use for:**
- Authentication/security/payments
- Complex architecture decisions
- Multi-system integration
- Critical production code
- Ambiguous requirements needing interpretation
- Large refactors (multi-file)

**Example tasks:**
- "Build JWT authentication"
- "Design microservices architecture"
- "Integrate Stripe payments"
- "Fix race condition in WebSocket"

### Tier 2: Mid-Range (Gemini Flash)
**Model:** `openrouter/google/gemini-flash-1.5`  
**Cost:** $0.075/M input, $0.30/M output (95% cheaper)

**Use for:**
- Standard feature implementation
- Frontend components
- Backend API endpoints
- Test writing
- Documentation
- Web search tasks
- Most daily work (60-70%)

**Example tasks:**
- "Create GET /api/posts endpoint"
- "Build React dashboard component"
- "Research Stripe webhook documentation"
- "Write tests for user service"

### Tier 3: Budget (GPT-4o-mini)
**Model:** `openrouter/openai/gpt-4o-mini`  
**Cost:** $0.15/M input, $0.60/M output (98% cheaper than Sonnet)

**Use for:**
- Email/status checks
- Simple queries
- Formatting
- Quick lookups
- Non-critical admin tasks

**Example tasks:**
- "Check if there are new GitHub notifications"
- "What time is it in UTC?"
- "Format this JSON"
- "What's the status of PR #42?"

### Tier 4: Coding Specialist (DeepSeek - Optional)
**Model:** `openrouter/deepseek/deepseek-chat`  
**Cost:** $0.27/M input, $1.10/M output

**Use for:**
- Pure algorithmic coding
- Math-heavy computation
- Non-critical code generation
- When budget is tight

**Example tasks:**
- "Implement Dijkstra's algorithm"
- "Solve this dynamic programming problem"
- "Generate test data for API"

## Implementation

When you receive a task, classify it first:

```javascript
function selectModel(taskDescription) {
  const task = taskDescription.toLowerCase();
  
  // Security/payments always premium
  if (task.includes('auth') || task.includes('payment') || 
      task.includes('security') || task.includes('oauth')) {
    return 'openrouter/anthropic/claude-sonnet-4.5';
  }
  
  // Simple ops always budget
  if (task.includes('check email') || task.includes('status') ||
      task.includes('what time') || task.includes('format')) {
    return 'openrouter/openai/gpt-4o-mini';
  }
  
  // Research/search → Gemini
  if (task.includes('research') || task.includes('search') ||
      task.includes('documentation') || task.includes('find')) {
    return 'openrouter/google/gemini-flash-1.5';
  }
  
  // Architecture/design → premium
  if (task.includes('architecture') || task.includes('design') ||
      task.includes('integrate') || task.includes('refactor')) {
    return 'openrouter/anthropic/claude-sonnet-4.5';
  }
  
  // Default: mid-tier for routine work
  return 'openrouter/google/gemini-flash-1.5';
}
```

## Manual Override

User can always override with:
- `/model openrouter/anthropic/claude-sonnet-4.5` (premium)
- `/model openrouter/google/gemini-flash-1.5` (mid)
- `/model openrouter/openai/gpt-4o-mini` (budget)

## Cost Tracking

**Monthly target:** $100-150  
**Hard limit:** $150

**Expected breakdown:**
- Sonnet 4.5: ~20% of tasks, ~60% of budget ($60-80)
- Gemini Flash: ~60% of tasks, ~30% of budget ($30-40)
- GPT-4o-mini: ~20% of tasks, ~10% of budget ($10-20)

## Notes

- When in doubt between tiers, use mid-tier (Gemini Flash)
- Never penny-pinch on security/auth (always Sonnet)
- Track weekly spend via OpenRouter dashboard
- Adjust routing if costs spike

**Quality over cost** for decisions that matter.  
**Efficiency over waste** for mechanical tasks.
