# BUDGET.md

Cost management rules for the OpenClaw multi-agent system.

This file defines how models and tools should be used to minimize spend while preserving quality for important decisions.

It applies to:

- Brain OpenClaw (Mac mini – Claude)
- Frontend OpenClaw (Mac OS VM – Gemini / Kimi)
- Backend OpenClaw (Linux VPS – Codex)

Felipe is the final authority on budget decisions.

---

## Purpose

The goal is simple:

- Keep routine work cheap
- Spend money only when it materially improves outcomes

Local models and lightweight tools handle everyday tasks.  
Cloud models are reserved for reasoning, architecture, and high-impact work.

---

## Local Models (when installed)

If Ollama (or any local model runtime) is installed on an agent, it should be used for **simple, low-risk queries**, such as:

- Syntax checks
- Small refactors
- Variable renaming
- Formatting
- Markdown cleanup
- Quick explanations
- Basic research summaries
- Simple utility questions (for example: weather, definitions, commands)

These tasks do not require premium reasoning and should not consume paid tokens.

Local models are optional, but when available they are preferred for this category of work.

---

## Paid Models (via OpenRouter)

Paid models (Claude, Gemini, Codex, etc.) are reserved for:

- Architecture and system design
- Complex reasoning
- Multi-file or multi-service refactors
- Authentication or identity-sensitive logic
- Automation design
- Integration across systems
- Ambiguous or underspecified requirements
- Final reviews and quality gates

In short:

Use paid models when correctness, depth, or safety matter.

---

## Things That Must NOT Use Paid Models

Never use paid models for:

- Formatting
- Renaming variables
- Trivial edits
- Markdown cleanup
- Simple linting
- Cosmetic changes
- Mechanical transformations

If a task is mostly mechanical, it should stay local.

---

## Escalation Authority

- Each agent may suggest escalation to paid models.
- The Brain agent has technical authority to approve escalation.
- Felipe retains final authority over overall spending.

If there is uncertainty, defer to the Brain agent.

---

## Practical Heuristics

Escalation is usually justified when:

- Many files are involved
- Multiple services must align
- Security or authentication is present
- Architecture decisions are required
- The agent explicitly signals uncertainty
- The change affects production workflows

Everything else should remain inexpensive.

---

## Visibility

Agents should be transparent when they escalate to paid models.

When meaningful cost is incurred, it should be reflected in Git (commit messages, notes, or DECISIONS.md if appropriate).

---

## Summary

- Use local models for simple work when available.
- Use paid models for reasoning, architecture, integration, and final review.
- Avoid spending on mechanical tasks.
- Brain approves technical escalation.
- Felipe owns the budget.

This keeps the system sustainable, scalable, and intentional.

---

End of file.
