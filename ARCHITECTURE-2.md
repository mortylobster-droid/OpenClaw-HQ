# ARCHITECTURE.md

This document describes the architecture for **OpenClaw HQ**: a 2-agent engineering system coordinated through GitHub, with human-in-the-loop control and cost-aware model usage.

It is designed around two concrete OpenClaw sessions:

1. **Brain OpenClaw** (Mac mini — Kimi K2.5 with Sonnet 4.5 fallback) — Builder
2. **Reviewer OpenClaw** (Linux VPS — Codex) — Quality Gate

Felipe remains the orchestrator and final authority.  
GitHub remains the source of truth.

---

## 1) Mental Model (Concise)

You are running a small engineering organization with a clean separation:

- **Felipe** = human orchestrator and final authority
- **Brain** = builder, architect, full-stack engineer
- **Reviewer** = independent quality gate, catches bugs and design issues

Brain builds everything end-to-end.  
Reviewer only activates after Brain is done.  
No parallel work = no coordination complexity.

Everything meaningful flows through Git.

---

## 2) System Diagram

```
                          ┌──────────────────────┐
                          │        Felipe        │
                          │ (Human Orchestrator)  │
                          └──────────┬───────────┘
                                     │
                                     ▼
                               GitHub Repo
                           (Single Source of Truth)
                                     │
                    ┌────────────────┴────────────────┐
                    │                                 │
                    ▼                                 ▼
                                          
            Brain OpenClaw                    Reviewer OpenClaw
          (Mac mini – Kimi K2.5)             (Linux VPS – Codex)
          ───────────────────                ───────────────────
          
          - Receives objectives              - Scans GitHub after Brain is done
          - Full-stack builder               - Reviews PRs for:
          - Architecture + code                • Bugs and edge cases
          - UI + backend + automation          • Security issues
          - Pushes branches                    • Architecture problems
          - Opens PRs                          • Code quality
          - Never merges                     - Comments on PRs
                                            - Never merges
                                            - Never builds

                    │                                 │
                    └────────────────┬────────────────┘
                                     │
                                     ▼
                                  Felipe
                            (Approves & Merges)

Workflow:
1. Felipe → Brain: "Build X"
2. Brain → GitHub: Builds, pushes branch, opens PR
3. Reviewer → GitHub: Reviews PR, comments
4. Brain → GitHub: Fixes issues (if any)
5. Felipe → GitHub: Approves & merges to main
```

---

## 3) Components

### 3.1 GitHub Repository (Source of Truth)

GitHub contains the canonical state for:

- Architecture and decisions
- Code and automation definitions
- Pull requests and reviews
- Integration history
- Shared policies and contracts

Chat systems (Telegram/Discord) are coordination surfaces only.  
**If it is not committed, it does not exist.**

---

### 3.2 Felipe Folder (Locked)

`/FELIPE` is human-owned and locked.

It contains:

- `GOALS.md` — strategic objectives
- `ROADMAP.md` — priorities and timeline
- `APPROVALS.md` — sensitive actions log
- `NOTES.md` / `IDEAS.md` — brainstorming

Agents may read if permitted, but agents **never modify** `/FELIPE`.

This keeps strategic intent separate from execution.

---

### 3.3 Two OpenClaw Sessions

#### Brain OpenClaw (Mac mini — Kimi K2.5 with Sonnet 4.5 fallback)

**Role:** Full-stack builder

**Responsibilities:**

- Receives objectives from Felipe via Telegram
- Architects the solution
- Builds everything:
  - Frontend UI/UX
  - Backend APIs and services
  - Automation workflows (n8n, Playwright)
  - Infrastructure and integrations
- Pushes feature branches to GitHub
- Opens pull requests with clear descriptions
- Responds to Reviewer feedback
- **Never merges to main**

**Model Strategy:**

- **Primary:** Kimi K2.5 ($0.60 input / $2.50 output per 1M tokens)
  - Used for 90%+ of building work
  - Excellent coding (76.8% SWE-bench)
  - Native multimodal (handles images/diagrams)
  - Agent Swarm capability for complex tasks
  
- **Fallback:** Claude Sonnet 4.5 ($3 input / $15 output per 1M tokens)
  - Used only when Kimi fails after 2 attempts
  - Used for payment processing (too critical)
  - Used when Reviewer rejects Kimi's code 2+ times
  
- **Specialized models:**
  - Gemini 2.5 Flash-Lite: Heartbeat operations (email checks, status queries)
  - DeepSeek V3: Web search and research tasks

**Escalation logic:**
1. Try Kimi K2.5 first (default)
2. If Kimi fails or produces buggy code → retry once
3. If still failing after 2 attempts → escalate to Sonnet 4.5
4. Log escalation for cost tracking

**Cost policy:** See `BRAINAGENT.md` for detailed model selection rules. Target monthly spend: $60-80.

---

#### Reviewer OpenClaw (Linux VPS — Codex)

**Role:** Independent quality gate

**Responsibilities:**

- Monitors GitHub for new PRs from Brain
- Reviews code for:
  - Bugs and edge cases
  - Security vulnerabilities
  - Architecture problems
  - Code quality and maintainability
  - Performance issues
  - Missing error handling
- Leaves detailed comments on PRs via structured review file
- Does NOT build, code, or push
- Does NOT merge
- Acts as second set of eyes only

**Model:** Codex (self-hosted or via API)

**Cost policy:** Codex usage does not incur additional costs for this setup.

**Activation:** Only activates after Brain opens a PR. Does not proactively build or modify code.

---

### Reviewer's Detailed Workflow

When a new PR is detected, Reviewer follows this structured process:

#### Step 1: Initial Scan

```bash
# Reviewer detects new PR
gh pr list --state open --author brain-agent

# Clone/pull latest
git fetch origin
git checkout pr-branch-name
```

#### Step 2: Code Analysis

Reviewer analyzes:
- All changed files in the PR
- Diffs compared to main branch
- Architecture decisions
- Security implications
- Edge cases and error handling

#### Step 3: Generate Review Document

**Reviewer creates a structured review file:**

```markdown
# File: REVIEW-{PR_NUMBER}.md
# Location: /reviews/REVIEW-{PR_NUMBER}.md

## Review Summary
**PR:** #{PR_NUMBER} - {PR_Title}  
**Reviewed by:** Reviewer OpenClaw  
**Date:** {ISO_DATE}  
**Overall Status:** ✅ APPROVED | ⚠️ CHANGES_REQUESTED | ❌ BLOCKED

---

## Critical Issues (Must Fix)

### Issue 1: SQL Injection Vulnerability
**File:** `api/users.js`  
**Lines:** 42-45  
**Severity:** CRITICAL

**Current code:**
```javascript
const query = `SELECT * FROM users WHERE id = ${userId}`;
db.query(query);
```

**Problem:** Direct string interpolation allows SQL injection attacks.

**Suggested fix:**
```javascript
const query = 'SELECT * FROM users WHERE id = $1';
db.query(query, [userId]);
```

**Action required:** Use parameterized queries

---

### Issue 2: Missing Error Handling
**File:** `api/payment.js`  
**Lines:** 78-82  
**Severity:** HIGH

**Current code:**
```javascript
const charge = await stripe.charges.create({
  amount: amount,
  currency: 'usd'
});
return charge;
```

**Problem:** No try-catch, will crash on Stripe API errors.

**Suggested fix:**
```javascript
try {
  const charge = await stripe.charges.create({
    amount: amount,
    currency: 'usd'
  });
  return charge;
} catch (error) {
  logger.error('Stripe charge failed:', error);
  throw new PaymentError('Charge failed', { cause: error });
}
```

**Action required:** Add proper error handling

---

## Moderate Issues (Should Fix)

### Issue 3: Inefficient Database Query
**File:** `api/reports.js`  
**Lines:** 120-125  
**Severity:** MEDIUM

**Current code:**
```javascript
const users = await db.query('SELECT * FROM users');
const filtered = users.filter(u => u.active === true);
```

**Problem:** Fetches all users then filters in memory. Inefficient for large datasets.

**Suggested fix:**
```javascript
const users = await db.query('SELECT * FROM users WHERE active = true');
```

**Action required:** Filter in database query

---

## Minor Issues (Nice to Have)

### Issue 4: Inconsistent Naming
**File:** `utils/helpers.js`  
**Lines:** 15, 23, 34  
**Severity:** LOW

**Problem:** Mix of camelCase and snake_case in function names.

**Suggested change:** Use consistent camelCase throughout.

---

## Architecture Observations

### Positive
- ✅ Good separation of concerns
- ✅ Proper use of async/await
- ✅ Clear file structure

### Concerns
- ⚠️ Consider adding rate limiting to API endpoints
- ⚠️ No database migration strategy mentioned
- ℹ️ Could benefit from input validation layer

---

## Security Checklist
- ❌ SQL injection vulnerability (Issue #1)
- ✅ Authentication properly implemented
- ✅ HTTPS enforced
- ⚠️ No rate limiting on public endpoints
- ✅ Environment variables used for secrets

---

## Performance Notes
- Query optimization needed (Issue #3)
- Consider adding caching for frequently accessed data
- Database indexes appear correct

---

## Testing Coverage
- ✅ Unit tests present
- ⚠️ No integration tests for payment flow
- ❌ Missing edge case tests for error scenarios

---

## Action Items for Brain

**Must fix before merge (CRITICAL/HIGH):**
1. Fix SQL injection in `api/users.js` (Issue #1)
2. Add error handling to `api/payment.js` (Issue #2)

**Should fix (MEDIUM):**
3. Optimize database query in `api/reports.js` (Issue #3)

**Optional (LOW):**
4. Standardize naming convention

**Recommendations:**
- Add rate limiting middleware
- Write integration tests for payment flow
- Document database schema changes

---

## Reviewer Decision

**Status:** ⚠️ CHANGES_REQUESTED

**Reason:** Critical security issue must be addressed before merge.

**Next steps:**
1. Brain addresses critical issues (#1, #2)
2. Brain pushes fixes to same branch
3. Brain responds to this review with summary of changes
4. Reviewer re-reviews if changes are substantial

---

**Estimated time to fix:** 30-60 minutes  
**Complexity:** Medium
```

#### Step 4: Commit Review to Repository

```bash
# Reviewer creates review file
git checkout pr-branch-name
mkdir -p reviews
cat > reviews/REVIEW-{PR_NUMBER}.md < review_content

# Commit review to PR branch
git add reviews/REVIEW-{PR_NUMBER}.md
git commit -m "Review: PR #{PR_NUMBER} - Changes requested"
git push origin pr-branch-name

# Also post summary as PR comment
gh pr comment {PR_NUMBER} --body "
## Review Complete

I've created a detailed review document: \`reviews/REVIEW-{PR_NUMBER}.md\`

**Status:** ⚠️ CHANGES_REQUESTED

**Critical issues found:** 2  
**Must fix before merge:**
1. SQL injection vulnerability in \`api/users.js\`
2. Missing error handling in \`api/payment.js\`

Please address these issues and push updates to this branch.
"
```

#### Step 5: Brain's Response Workflow

When Brain sees the review:

```bash
# Brain pulls latest (includes review file)
git pull origin pr-branch-name

# Brain reads review
cat reviews/REVIEW-{PR_NUMBER}.md

# Brain addresses each issue
# ... makes code changes ...

# Brain documents fixes
cat > reviews/REVIEW-{PR_NUMBER}-RESPONSE.md <<'EOF'
# Response to Review #{PR_NUMBER}

## Issues Addressed

### Issue #1: SQL Injection (CRITICAL) ✅ FIXED
**File:** `api/users.js`  
**Action taken:** Implemented parameterized queries as suggested.  
**Commit:** abc123f

**Changes:**
```javascript
// Before
const query = `SELECT * FROM users WHERE id = ${userId}`;

// After  
const query = 'SELECT * FROM users WHERE id = $1';
db.query(query, [userId]);
```

### Issue #2: Missing Error Handling (HIGH) ✅ FIXED
**File:** `api/payment.js`  
**Action taken:** Added try-catch with proper error logging.  
**Commit:** def456a

### Issue #3: Database Query (MEDIUM) ✅ FIXED
**File:** `api/reports.js`  
**Action taken:** Moved filter to SQL query.  
**Commit:** ghi789b

### Issue #4: Naming Convention (LOW) ⏭️ SKIPPED
**Reason:** Will address in separate PR to avoid scope creep.  
**Tracking:** Created issue #123 for future cleanup.

## Additional Changes

- Added rate limiting middleware as recommended
- Created integration tests for payment flow
- Updated documentation

## Ready for Re-Review

All CRITICAL and HIGH severity issues have been addressed.  
Ready for Reviewer to re-check.
EOF

# Brain commits everything
git add .
git commit -m "Fix: Address review issues #1, #2, #3

- Fix SQL injection with parameterized queries
- Add error handling to payment flow  
- Optimize database query
- Add rate limiting (bonus)
- Add integration tests (bonus)"

git push origin pr-branch-name

# Brain posts response as PR comment
gh pr comment {PR_NUMBER} --body "
## Fixes Pushed

I've addressed all critical and high-severity issues from the review.

**Fixed:**
- ✅ Issue #1: SQL injection (parameterized queries)
- ✅ Issue #2: Error handling (try-catch added)
- ✅ Issue #3: Query optimization (filter in SQL)

**Bonus improvements:**
- Added rate limiting middleware
- Created integration tests for payment flow

See \`reviews/REVIEW-{PR_NUMBER}-RESPONSE.md\` for detailed changes.

@reviewer-agent Ready for re-review.
"
```

#### Step 6: Reviewer Re-Review (if needed)

```bash
# Reviewer pulls latest
git pull origin pr-branch-name

# Reviewer checks if fixes are adequate
# Reads RESPONSE.md
# Verifies code changes

# If satisfied:
gh pr review {PR_NUMBER} --approve --body "
## Re-Review Complete ✅

All critical issues have been properly addressed.

**Verified fixes:**
- ✅ SQL injection fixed with parameterized queries
- ✅ Error handling properly implemented
- ✅ Database query optimized

**Bonus improvements noted:**
- Rate limiting added (excellent)
- Integration tests added (great)

**Recommendation:** APPROVE - Ready for Felipe to merge.
"

# Reviewer updates review file
echo "
---

## Re-Review Update

**Date:** {ISO_DATE}  
**Status:** ✅ APPROVED

All critical issues resolved. Code quality is good. Ready for production.
" >> reviews/REVIEW-{PR_NUMBER}.md

git add reviews/REVIEW-{PR_NUMBER}.md
git commit -m "Review: PR #{PR_NUMBER} - Approved after fixes"
git push origin pr-branch-name
```

#### Step 7: Felipe's Final Check

Felipe sees:
1. Original PR from Brain
2. Review file with issues found
3. Brain's response with fixes
4. Reviewer's approval

Felipe can quickly assess:
- What was built
- What issues were found
- How Brain fixed them
- Whether Reviewer is satisfied

Then Felipe merges with confidence.

---

### Review File Naming Convention

```
/reviews/
  ├── REVIEW-0001.md              # Initial review of PR #1
  ├── REVIEW-0001-RESPONSE.md     # Brain's response
  ├── REVIEW-0002.md              # Initial review of PR #2
  ├── REVIEW-0002-RESPONSE.md     # Brain's response
  └── README.md                   # Explains review process
```

### Benefits of This Approach

**Structured communication:**
- Clear, documented review process
- Easy to track what was found and fixed
- Historical record in Git

**Async-friendly:**
- Brain and Reviewer don't need real-time coordination
- Felipe can review at any time
- All context preserved in files

**Audit trail:**
- Every review is versioned in Git
- Can see how code quality improved over time
- Learn from past issues

**Scalability:**
- Template can be reused for every PR
- Easy to add more reviewers (security specialist, performance specialist)
- Clear handoff points

---

## 4) Workflow (Step-by-Step)

This is the complete lifecycle from idea to production:

### Phase 1: Objective Definition

1. **Felipe messages Brain** via Telegram with an objective
   - Example: "Build a dashboard that shows our n8n workflow stats"
   - Example: "Add authentication to the API"
   - Example: "Create a Playwright job to scrape competitor pricing"

2. **Brain acknowledges** and clarifies if needed
   - May ask questions about requirements
   - Confirms understanding before building

### Phase 2: Building

3. **Brain architects the solution**
   - Decides on tech stack, file structure, approach
   - Considers existing codebase and patterns

4. **Brain builds everything**
   - Writes all code: frontend, backend, automation, config
   - Tests locally when possible
   - Maintains coherent design across all components
   - Full context = no integration issues

5. **Brain pushes feature branch**
   - Branch name: `feature/descriptive-name`
   - Example: `feature/n8n-dashboard`

6. **Brain opens PR**
   - Clear title and description
   - Lists what was built
   - Notes any assumptions or decisions
   - Tags any areas needing extra review

### Phase 3: Review (Structured via Review Files)

7. **Reviewer scans GitHub** (manual trigger or automated notification)
   - Sees new PR from Brain
   - Pulls PR branch locally
   - Reads all changed files and PR description

8. **Reviewer performs quality check and creates review document**
   - Analyzes code for bugs, security, architecture, edge cases
   - Creates structured review file: `/reviews/REVIEW-{PR_NUMBER}.md`
   - Documents all issues with:
     - Severity levels (CRITICAL, HIGH, MEDIUM, LOW)
     - Specific file locations and line numbers
     - Current problematic code
     - Suggested fixes with code examples
     - Clear action items
   - Commits review file to PR branch
   - Posts summary comment on PR with status (APPROVED, CHANGES_REQUESTED, BLOCKED)

**Review file structure:**
```
/reviews/
  ├── REVIEW-0001.md              # Reviewer's initial review
  ├── REVIEW-0001-RESPONSE.md     # Brain's response with fixes
  ├── REVIEW-0002.md              # Next PR's review
  └── README.md                   # Review process documentation
```

### Phase 4: Iteration (via Response Files)

9. **Brain reads Reviewer feedback**
   - Pulls latest from PR branch (includes review file)
   - Reads `/reviews/REVIEW-{PR_NUMBER}.md` thoroughly
   - Addresses each issue by priority (CRITICAL → HIGH → MEDIUM → LOW)

10. **Brain fixes issues and documents response**
    - Makes code changes to fix each issue
    - Creates response file: `/reviews/REVIEW-{PR_NUMBER}-RESPONSE.md`
    - Documents for each issue:
      - ✅ Issue fixed: what was changed, which commit
      - ⏭️ Issue skipped: reason and tracking (e.g., "will address in separate PR")
      - ℹ️ Issue disputed: Brain's reasoning if disagrees
    - Lists any bonus improvements made
    - Commits all fixes and response file
    - Posts PR comment: "Fixes pushed, see REVIEW-{PR_NUMBER}-RESPONSE.md"

11. **Reviewer re-reviews** (if changes were significant)
    - Pulls latest changes
    - Reads Brain's response file
    - Verifies fixes are adequate
    - Updates original review file with re-review section
    - Or approves PR via GitHub if satisfied

### Phase 5: Merge

12. **Felipe reviews the PR**
    - Reads Brain's PR description
    - Reviews `/reviews/REVIEW-{PR_NUMBER}.md` to see what issues were found
    - Reviews `/reviews/REVIEW-{PR_NUMBER}-RESPONSE.md` to see how Brain fixed them
    - Reads Reviewer's final approval/comments
    - Checks if sensitive actions are involved (credentials, payments, external messages)
    - Makes final decision with full context

13. **Felipe merges to main**
    - Only Felipe has merge authority
    - Ensures human oversight on all production changes
    - Review files remain in Git as permanent audit trail

---

## 4.1) Why Review Files Work

The structured review file approach provides several advantages over traditional PR comments:

**Comprehensive documentation:**
- All issues in one organized document
- Easy to see full picture of code quality
- Searchable history of review patterns

**Async-friendly:**
- Brain and Reviewer don't need real-time coordination
- Felipe can review thoroughly at any time
- All context preserved in versioned files

**Audit trail:**
- Every review permanently in Git history
- Can track improvement over time
- Learn from past mistakes
- Compliance and quality metrics

**Structured communication:**
- Clear severity levels (CRITICAL → HIGH → MEDIUM → LOW)
- Explicit action items with code examples
- Documented responses showing what was fixed

**Scalability:**
- Template can be reused for every PR
- Easy to add specialized reviewers (security, performance)
- Clear handoff points between agents

**Cost tracking:**
- Review files show when Kimi struggled (led to escalation)
- Pattern analysis: which types of tasks cause failures
- Optimize model routing based on historical data

---

## 5) Gmail Authority Rule (Strict)

All agents share a single dedicated Gmail account for system communication.

However:

- **ONLY the Brain OpenClaw (Mac mini) may log into Gmail, read email, or send email.**
- Reviewer must never authenticate to Gmail or attempt OAuth flows.
- If email needs review, Brain includes relevant context in PR description.

**Reason:**

- Brain runs on the trusted device (Mac mini)
- This dramatically reduces account blocks, CAPTCHA, and security flags
- Single point of authentication = easier to secure

This rule is **strict and non-negotiable**.

---

## 6) Cost Policy (Kimi K2.5 + Fallbacks)

Cost rules are defined in `BUDGET.md` and `BRAINAGENT.md`.

**Summary:**

**Brain (Builder):**
- **Primary model:** Kimi K2.5 ($0.60 input / $2.50 output per 1M tokens)
  - Used for 90%+ of all building work
  - Excellent coding performance (76.8% SWE-bench)
  - Native multimodal capabilities
  - Cost-effective at ~80-90% cheaper than Sonnet
  
- **Fallback model:** Claude Sonnet 4.5 ($3 input / $15 output per 1M tokens)
  - Used only when Kimi fails after 2 attempts
  - Used for payment processing (too critical to risk)
  - Used when Reviewer rejects Kimi's code 2+ times
  - Provides quality safety net
  
- **Specialized models:**
  - Gemini 2.5 Flash-Lite: Heartbeat operations (email checks, status queries)
  - DeepSeek V3: Web search and research tasks

**Escalation policy:**
1. Try Kimi K2.5 first (default for all tasks)
2. If Kimi produces bugs or fails → retry once with Kimi
3. If still failing after 2 attempts → escalate to Sonnet 4.5
4. Log all escalations for cost tracking and pattern analysis

**Monthly budget target:** $60-80/month
- Light month: ~$45
- Normal month: ~$77
- Heavy month: ~$126 (acceptable spike)

**Reviewer (Quality Gate):**
- Uses Codex (self-hosted or via API)
- Codex usage does not incur additional costs
- Does not need creation capabilities, just analysis

**Decision authority:**
- Brain decides its own model usage based on task complexity and failure count
- Automatic escalation triggers (see `BRAINAGENT.md`)
- Felipe can override if costs spike or quality suffers

---

## 7) Communication Layer

**Telegram/Discord** are used for:

- Felipe → Brain: objectives and instructions
- Brain → Felipe: status updates and questions
- Automated notifications (PR opened, review complete)
- Approval prompts for sensitive actions

**They are not sources of truth.**

All durable state lives in GitHub.

Conversation history in chat is ephemeral and may be lost.  
Documentation and decisions must be committed to the repo.

---

## 8) Security and Boundaries

**Hard boundaries:**

- `/FELIPE` is human-owned, agents read-only (if permitted)
- Only Felipe merges to main
- Only Brain uses Gmail and external credentials
- Only Brain builds and pushes code
- Reviewer only analyzes and comments
- Sensitive actions (logins, payments, messaging humans) require Felipe approval

**If there is conflict:**

1. `AGENTS.md` policies override
2. Brain decides technical approach
3. Reviewer flags concerns
4. **Felipe makes the final decision**

---

## 9) Automation Infrastructure

**Brain OpenClaw hosts the self-managed n8n instance** (HTTPS + custom domain).

**n8n is used for:**

- Scheduled jobs (data scraping, report generation)
- Webhook integrations
- Notification workflows
- Monitoring and health checks

**Architecture:**

- n8n runs on Brain's Mac mini (or dedicated VPS if needed)
- Brain builds and deploys workflows
- Workflows commit their definitions to `/automations/` in Git
- Reviewer checks workflow logic during PR review

This keeps automation definitions in version control and under review.

---

## 10) Why This Architecture Works

**Simplicity:**
- Linear workflow: build → review → merge
- No task queues, no coordination, no race conditions
- Easy to understand and debug

**Quality:**
- Two independent intelligences check every change
- Brain has full context for coherent design
- Reviewer catches what Brain misses

**Cost efficiency:**
- Premium model (Brain) only for building, with OpenRouter as fallback for simple tasks
- Codex (Reviewer) for analysis without additional costs
- No wasted tokens on coordination overhead

**Human control:**
- Felipe retains final authority on all merges
- Clear approval gates for sensitive actions
- Can override or redirect at any time

**Scalability:**
- Works for solo projects and small teams
- Can add more Reviewer instances if needed (security specialist, performance specialist)
- Brain remains single builder = no integration complexity

---

## 11) Failure Modes and Recovery

**What if Brain builds something broken?**
- Reviewer catches it before merge
- Brain fixes in same PR
- If merged anyway, Felipe can revert

**What if Reviewer misses a bug?**
- Not catastrophic: Felipe is final check
- Real-world testing will catch it
- Brain can fix in follow-up PR

**What if Brain and Reviewer disagree?**
- Brain explains reasoning in PR comments
- Reviewer explains concerns
- Felipe makes final call

**What if Brain goes offline mid-build?**
- Work is in Git (feature branch)
- Felipe can redirect to different session
- Or wait for Brain to come back online

**What if costs spike?**
- `BUDGET.md` and `BRAINAGENT.md` define spending limits
- Weekly budget checks alert if trending over $80/month
- Can reduce Kimi usage and increase Sonnet escalation threshold
- Can use DeepSeek V3 more for pure coding tasks
- Felipe monitors spending via provider dashboards (Fireworks, Anthropic, Google AI)

---

## 12) Getting Started

**Initial setup:**

1. Create GitHub repo
2. Set up `/FELIPE` folder with `GOALS.md` and `ROADMAP.md`
3. Create `AGENTS.md` (roles and constraints)
4. Create `BUDGET.md` (spending limits and model policies)
5. Configure Brain OpenClaw on Mac mini
6. Configure Reviewer OpenClaw on Linux VPS with Codex
7. Set up Telegram bot for Felipe ↔ Brain communication
8. Configure GitHub webhooks (optional) to notify Reviewer of new PRs

**First project:**

1. Felipe messages Brain: "Build a simple health check endpoint"
2. Brain builds, tests, pushes PR
3. Reviewer reviews, approves
4. Felipe merges
5. System is validated and ready for real work

---

## 13) Summary

You operate two OpenClaw sessions:

- **Brain OpenClaw** (Mac mini — Kimi K2.5 with Sonnet 4.5 fallback) for architecture + full-stack building
- **Reviewer OpenClaw** (Linux VPS — Codex) for independent quality review

With:

- GitHub as single source of truth
- `/FELIPE` locked for human-only strategic planning
- Gmail authority restricted to Brain (trusted device)
- Cost policy: Kimi K2.5 primary (90%+ of work), Sonnet 4.5 fallback (failures/critical), specialized models for heartbeat/search
- Review workflow: Structured MD files in `/reviews/` directory with detailed issue documentation
- Linear workflow: build → review (via review file) → fix → re-review → approve → merge
- No coordination complexity, no race conditions, no merge conflicts

This forms a **simple, robust, cost-effective engineering system under human control.**

**Key innovations:**
- Cost optimization: $77/month average (vs $220+ with premium-only strategy)
- Quality assurance: Two-agent review with structured documentation
- Human oversight: Felipe retains final merge authority
- Transparent iteration: All review feedback and responses versioned in Git

---

End of file.
