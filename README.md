# OpenClaw-HQ
Welcome to **OpenClaw HQ** — a personal, distributed, multi-agent engineering system.

This repository is the **single source of truth** for all projects, agents, automations, and decisions.  
It is designed around three specialized OpenClaw sessions, human-in-the-loop control, and cost-aware inference.

Think of this repo as a **small AI-powered engineering organization**, coordinated by Felipe.

---

## High-Level Philosophy

This system is built on a few core ideas:

- Specialization beats generalization  
- Cheap inference first, paid inference only when needed  
- Humans stay in control of sensitive actions  
- Git is the source of truth  
- Agents build, the Brain reviews, Felipe approves  

Instead of one monolithic agent, we run **three OpenClaw sessions**, each optimized for a specific role.

---

## The Three OpenClaw Sessions

### 🧠 Brain OpenClaw (Mac mini – Claude Sonnet 4.5)

Role: **Architecture, orchestration, integration, and final review**

Responsibilities:

- System design and planning  
- Task decomposition  
- Cross-agent coordination  
- Reviewing Frontend and Backend output  
- Final integration and merging  
- Cost escalation authority (Ollama → OpenRouter)  
- Logistics and reasoning  

This agent is the **technical lead**.

Only the Brain agent:

- Merges to main  
- Performs final reviews  
- Decides when paid models are justified  
- Has authority over shared email (see below)

---

### 🎨 Frontend OpenClaw (Mac OS VM – Gemini / Kimi)

Role: **UI / UX / client-side implementation**

Responsibilities:

- Frontend components  
- UX flows  
- Styling  
- Client logic  

Rules:

- Never self-assigns work  
- Only executes Brain-issued tasks  
- Pushes branches to Git  
- Never merges  

---

### 🧰 Backend OpenClaw (Linux VPS – Codex)

Role: **Backend systems, automations, and infrastructure**

Responsibilities:

- APIs and services  
- Playwright automation  
- Workers and bots  
- Integrations  
- Infrastructure  

Rules:

- Never self-assigns work  
- Only executes Brain-issued tasks  
- Pushes branches to Git  
- Never merges  

---

## Felipe (Human Orchestrator)

Felipe sits above all agents.

Felipe:

- Defines goals and roadmap (inside `/FELIPE`)  
- Approves sensitive actions  
- Resolves conflicts  
- Owns budget decisions  
- Provides final human oversight  

Agents propose.  
Felipe disposes.

---

## Source of Truth

GitHub is the canonical system state.

All of the following live in Git:

- Architecture  
- Tasks  
- Code  
- Reviews  
- Decisions  
- Automation definitions  

Chat systems (Telegram / Discord) are for coordination and visibility only.

If it’s not in Git, it doesn’t exist.

---

## Locked Human Folder

The `/FELIPE` directory is **human-owned and locked**.

It contains:

- Goals  
- Roadmap  
- Notes  
- Ideas  
- Approvals  

Agents may read (if allowed), but never modify this folder.

This keeps **vision separated from execution**.

---

## Shared Gmail Account (Important)

All agents share a **single dedicated Gmail account** for system communication.

However:

👉 **Only the Brain OpenClaw (Mac mini) is allowed to log in, read, or send email.**

Frontend and Backend agents:

- Must never authenticate to Gmail  
- Must never attempt OAuth flows  
- Must never send or read email directly  

If email interaction is required:

1. Backend or Frontend prepares the data  
2. Brain agent performs the actual email action  

Reason:

- The Mac mini is the trusted device  
- This dramatically reduces account blocks, CAPTCHA loops, and security flags  

This rule is strict and non-negotiable.

---

## Cheap-First Model Policy

All agents follow a shared cost philosophy:

- Ollama (local) is always attempted first  
- OpenRouter (paid models) is used only when necessary  

Paid models are reserved for:

- Architecture decisions  
- Complex reasoning  
- Multi-system integration  
- Ambiguous requirements  

Never use paid models for:

- Formatting  
- Simple edits  
- Renaming variables  
- Markdown cleanup  

The Brain agent resolves ambiguity.

Details live in `BUDGET.md`.

---

## Typical Workflow

1. Felipe updates goals or roadmap (in `/FELIPE`)  
2. Brain converts goals into tasks (`TASKS.md`)  
3. Frontend and Backend pull tasks  
4. They implement and push branches  
5. Brain reviews both outputs  
6. Brain integrates and finalizes  
7. Felipe approves if sensitive  
8. Brain merges  

No agent bypasses this loop.

---

## What This Repository Represents

This is not just a codebase.

It is:

- A coordination layer  
- A memory system  
- A decision log  
- A multi-agent runtime  
- A personal engineering platform  

You are effectively running a small distributed AI team.

---

## Next Files to Review

- `AGENTS.md` – global agent rules  
- `BUDGET.md` – cost policy  
- `ARCHITECTURE.md` – full system design  
- `TASKS.md` – current work  
- `/FELIPE/GOALS.md` – human intent  

---

End of README.
