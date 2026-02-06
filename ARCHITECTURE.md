# ARCHITECTURE.md

This document describes the architecture for **OpenClaw HQ**: a distributed, multi-agent engineering system coordinated through GitHub, with human-in-the-loop control and cost-aware model usage.

It is designed around three concrete OpenClaw sessions:

1. Brain OpenClaw (Mac mini — Claude Sonnet 4.5)
2. Frontend OpenClaw (Mac OS VM — Gemini / Kimi)
3. Backend OpenClaw (Linux VPS — Codex)

Felipe remains the orchestrator.  
GitHub remains the source of truth.

---

## 1) Mental Model (Concise)

You are running a small engineering organization:

- Felipe = human orchestrator and final authority
- Brain = architect, task dispatcher, final reviewer, integrator
- Frontend = UI engineer
- Backend = systems + automation engineer

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
          ┌──────────────────────────┼──────────────────────────┐
          │                          │                          │
          ▼                          ▼                          ▼

   Brain OpenClaw              Frontend OpenClaw           Backend OpenClaw
 (Mac mini – Claude)        (Mac VM – Gemini/Kimi)        (VPS – Codex)
 ──────────────────         ─────────────────────         ─────────────────
 - Reads /FELIPE/*           - Pulls tasks from TASKS.md   - Pulls tasks from TASKS.md
 - Writes TASKS.md           - Builds UI / UX              - Builds APIs / automations
 - Architecture              - Pushes branches             - Pushes branches
 - Final review              - Never merges                - Never merges
 - Integration
 - Merges to main

            ▲                     ▲                         ▲
            └────────────── Pull / Push via Git ────────────┘

Shared policies:
- AGENTS.md (roles, constraints)
- BUDGET.md (cost rules)
```
---

## 3) Components

### 3.1 GitHub Repository (Source of Truth)

GitHub contains the canonical state for:

- Architecture and decisions
- Tasks and work queue
- Code and automation definitions
- Reviews and integration notes
- Shared prompts and contracts

Chat systems (Telegram/Discord) are coordination surfaces only.  
If it is not committed, it does not exist.

---

### 3.2 Felipe Folder (Locked)

`/FELIPE` is human-owned and locked.

It contains:

- GOALS.md
- ROADMAP.md
- APPROVALS.md
- NOTES.md / IDEAS.md

Agents may read if permitted, but agents never modify `/FELIPE`.

This keeps strategic intent separate from execution.

---

### 3.3 Three OpenClaw Sessions

#### Brain OpenClaw (Mac mini — Claude Sonnet 4.5)

Responsibilities:

- Architecture and system design
- Task decomposition and routing
- Maintaining TASKS.md
- Cross-agent coordination
- Final review (has full context)
- Integration and merge to main
- Cost escalation authority when ambiguous

Brain is the “tech lead” and final reviewer.

#### Frontend OpenClaw (Mac OS VM — Gemini / Kimi)

Responsibilities:

- UI components
- UX flows
- Client-side logic
- Styling and design coherence

Rules:

- Only executes Brain-issued tasks
- Pushes branches to Git
- Never merges
- Does not change architecture

#### Backend OpenClaw (Linux VPS — Codex)

Responsibilities:

- APIs and services
- Automations and workers
- Playwright jobs
- Infrastructure integration
- System reliability

Rules:

- Only executes Brain-issued tasks
- Pushes branches to Git
- Never merges
- Does not change architecture

Additional note:

- Backend session hosts the self-managed **n8n** instance (HTTPS + custom domain) and serves as the primary automation engine.

---

## 4) Task Dispatch and Review Loop

Only Brain creates tasks.

Default flow:

1. Felipe updates /FELIPE/GOALS.md and /FELIPE/ROADMAP.md
2. Brain translates intent into TASKS.md
3. Frontend and Backend pull tasks and implement
4. They push branches / PRs
5. Brain reviews both outputs (final review)
6. Brain integrates and finalizes
7. Felipe approves if sensitive actions are involved
8. Brain merges to main

Frontend and Backend never self-assign work.

---

## 5) Gmail Authority Rule (Strict)

All agents share a single dedicated Gmail account for system communication.

However:

- ONLY the Brain OpenClaw (Mac mini) may log into Gmail, read email, or send email.
- Frontend and Backend must never authenticate to Gmail or attempt OAuth flows.
- If email interaction is required, Backend/Frontend prepare the payload and Brain executes the email action.

Reason:

- Brain runs on the trusted device (Mac mini)
- This dramatically reduces account blocks, CAPTCHA, and security flags

This rule is strict and non-negotiable.

---

## 6) Cost Policy (Local Models + OpenRouter)

Cost rules are defined in `BUDGET.md`.

Summary:

- If local models are installed (e.g., Ollama), use them for simple, low-risk queries (syntax, small refactors, lightweight lookups).
- Use paid models (via OpenRouter) for architecture, complex reasoning, integration, auth flows, and final quality gates.
- Avoid spending on mechanical edits.

Brain resolves ambiguity and approves escalation when unclear.

---

## 7) Communication Layer

Telegram/Discord are used for:

- Status updates
- Coordination
- Notifications
- Approval prompts

They are not sources of truth.

All durable state lives in GitHub.

---

## 8) Security and Boundaries

Hard boundaries:

- `/FELIPE` is human-owned
- Only Brain merges
- Only Brain uses Gmail
- Backend hosts automation runtime (n8n + workers)
- Frontend focuses on UI and client logic
- Paid model usage is controlled by BUDGET.md

If there is conflict:

1. AGENTS.md overrides
2. Brain decides technical direction
3. Felipe makes the final decision

---

## 9) Summary

You operate three OpenClaw sessions:

- Brain OpenClaw (Mac mini — Claude Sonnet 4.5) for architecture + task routing + final review + integration
- Frontend OpenClaw (Mac OS VM — Gemini/Kimi) for UI/UX + client implementation
- Backend OpenClaw (Linux VPS — Codex) for APIs + automation + infrastructure, including the n8n automation engine

With:

- GitHub as source of truth
- `/FELIPE` locked for goals and roadmap
- Gmail authority restricted to Brain (trusted device)
- Cost policy via local models when available and OpenRouter escalation when needed

This forms a durable, scalable multi-agent engineering system under human control.

---

End of file.
