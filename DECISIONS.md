# DECISIONS.md

Architecture Decision Log for OpenClaw HQ.

This file records important technical, architectural, and operational decisions over time.

Purpose:

- Preserve reasoning behind choices
- Avoid repeating past debates
- Provide context to agents
- Enable future revisions with clarity

Only the **Brain OpenClaw** writes to this file.

Felipe approves major decisions.

If it’s not recorded here, it’s not an official decision.

---

## How to Use This File

Each decision is appended chronologically.

Do not rewrite history.  
If something changes, add a new entry that references the old one.

Every decision should answer:

- What was decided?
- Why?
- What alternatives were considered?
- What are the consequences?

---

## Decision Template

Copy this template for each new entry:

---

### DECISION-YYYY-MM-DD-XXX

**Title:** Short descriptive name

**Status:** Proposed | Accepted | Superseded | Deprecated

**Context:**  
What problem or situation triggered this decision.

**Decision:**  
What was chosen.

**Alternatives Considered:**  
- Option A  
- Option B  
- Option C  

**Rationale:**  
Why this option was selected over the others.

**Consequences:**  
Expected impacts, tradeoffs, or limitations.

**Approved By:**  
Felipe

**Implemented By:**  
Brain OpenClaw

---

---

## Recorded Decisions

(Brain agent appends entries here)

---

## Example

---

### DECISION-2026-02-06-001

**Title:** Adopt three-agent OpenClaw architecture

**Status:** Accepted

**Context:**  
Single-agent workflows were becoming complex and error-prone. Clear separation of frontend, backend, and reasoning was needed.

**Decision:**  
Adopt three OpenClaw sessions:
- Brain (Claude)
- Frontend (Gemini/Kimi)
- Backend (Codex)

With Brain acting as dispatcher and final reviewer.

**Alternatives Considered:**  
- Single agent  
- Dual agent (builder/reviewer)  

**Rationale:**  
Three specialized agents allow parallel development, deeper domain focus, and cleaner review boundaries.

**Consequences:**  
Increased coordination complexity, but higher quality output and scalability.

**Approved By:**  
Felipe

**Implemented By:**  
Brain OpenClaw

---

---

## Guidelines

- Keep entries concise but complete
- Prefer clarity over brevity
- Reference related commits or PRs when helpful
- Mark decisions as Superseded instead of deleting

---

End of file.
