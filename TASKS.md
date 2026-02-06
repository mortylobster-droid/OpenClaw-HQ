# TASKS.md

This file is the active task queue for OpenClaw HQ.

Only the **Brain OpenClaw** creates or modifies tasks in this file.

Frontend and Backend agents consume tasks from here, implement them in their respective domains, and push branches to Git for Brain review.

Felipe does not edit this file directly. Felipe communicates intent to the Brain agent (typically via Telegram).

If it is not listed here, it is not active work.

---

## Task Lifecycle

Each task follows this lifecycle:

- Proposed (created by Brain)
- In Progress (picked up by Frontend or Backend)
- In Review (PR opened, waiting for Brain)
- Completed (merged by Brain)
- Blocked (waiting on clarification or approval)

Status must always be kept up to date by the Brain agent.

---

## Task Format

Each task should follow this structure:

---

### TASK-ID: <unique-id>

**Title:** Short descriptive title

**Owner:** Frontend | Backend

**Status:** Proposed | In Progress | In Review | Completed | Blocked

**Priority:** Low | Medium | High | Critical

**Description:**  
Clear explanation of what needs to be done.

**Scope:**  
What files, folders, or systems are expected to change.

**Acceptance Criteria:**  
Bullet list of conditions that must be met for the task to be considered complete.

**Dependencies:**  
Other tasks, approvals, or external requirements (if any).

**Notes:**  
Optional implementation hints or constraints.

---

---

## Active Tasks

(Brain agent populates this section)

---

## Example Task

---

### TASK-001

**Title:** Scaffold frontend project structure

**Owner:** Frontend

**Status:** Proposed

**Priority:** Medium

**Description:**  
Create the initial frontend folder structure for project-alpha, including basic layout and placeholder components.

**Scope:**  
projects/project-alpha/frontend/

**Acceptance Criteria:**  
- Folder structure exists  
- Base layout component created  
- Placeholder homepage renders  

**Dependencies:**  
None

**Notes:**  
Follow existing shared UI conventions.

---

---

## Completed Tasks

(Brain agent moves finished tasks here for historical tracking)

---

End of file.
