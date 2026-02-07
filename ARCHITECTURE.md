# ARCHITECTURE.md

This document describes the architecture for **OpenClaw HQ**: a 2-agent engineering system coordinated through GitHub, with human-in-the-loop control and cost-aware model usage.

It is designed around two concrete OpenClaw sessions:

1. **Brain OpenClaw** (Mac mini — Claude Sonnet 4.5) — Builder
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
          (Mac mini – Claude)                (Linux VPS – Codex)
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

#### Brain OpenClaw (Mac mini — Claude Sonnet 4.5)

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

**Model:** Claude Sonnet 4.5 via OpenRouter (or local Claude if available)

**Cost policy:** Premium model justified because Brain has full context and builds coherent systems.

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
- Leaves detailed comments on PRs
- Does NOT build, code, or push
- Does NOT merge
- Acts as second set of eyes only

**Model:** Codex (self-hosted or via API)

**Cost policy:** Codex usage does not incur additional costs for this setup.

**Activation:** Only activates after Brain opens a PR. Does not proactively build or modify code.

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

### Phase 3: Review

7. **Reviewer scans GitHub** (manual trigger or automated notification)
   - Sees new PR from Brain
   - Reads code and description

8. **Reviewer performs quality check**
   - Reviews for bugs, security, architecture
   - Leaves specific, actionable comments
   - Approves if good, requests changes if issues found

### Phase 4: Iteration (if needed)

9. **Brain reads Reviewer feedback**
   - Addresses each comment
   - Pushes fixes to same branch
   - Replies to comments explaining changes

10. **Reviewer re-reviews** (if changes were significant)

### Phase 5: Merge

11. **Felipe reviews the PR**
    - Reads Brain's description and Reviewer's comments
    - Checks if sensitive actions are involved (credentials, payments, external messages)
    - Makes final decision

12. **Felipe merges to main**
    - Only Felipe has merge authority
    - Ensures human oversight on all production changes

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

## 6) Cost Policy (Local Models + OpenRouter)

Cost rules are defined in `BUDGET.md`.

**Summary:**

**Brain (Builder):**
- Use premium models (Claude Sonnet 4.5) by default
- Full context and coherent architecture justify the cost
- May use local models (Ollama) for simple, low-risk edits (typo fixes, formatting)
- OpenRouter is used as fallback for easy queries like checking emails or simple tasks
- Always use premium for: authentication, integrations, complex logic, architecture

**Reviewer (Quality Gate):**
- Uses Codex (self-hosted or via API)
- Codex usage does not incur additional costs
- Does not need creation capabilities, just analysis

**Decision authority:**
- Brain decides its own model usage based on task complexity
- Felipe can override if costs spike

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
- `BUDGET.md` defines spending limits
- Felipe monitors via OpenRouter dashboard
- Can pause work or switch to local models

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

- **Brain OpenClaw** (Mac mini — Claude Sonnet 4.5) for architecture + full-stack building
- **Reviewer OpenClaw** (Linux VPS — Codex) for independent quality review

With:

- GitHub as single source of truth
- `/FELIPE` locked for human-only strategic planning
- Gmail authority restricted to Brain (trusted device)
- Cost policy: premium for Brain (with OpenRouter fallback for simple tasks), Codex for Reviewer (no additional cost)
- Linear workflow: build → review → approve → merge
- No coordination complexity, no race conditions, no merge conflicts

This forms a **simple, robust, scalable engineering system under human control.**

---

End of file.
