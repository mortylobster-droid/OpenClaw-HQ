# BACKUP.md

Backup and recovery strategy for OpenClaw HQ.

This document defines how to keep redundant copies of the repository so that no single machine or service failure can destroy your system.

The goal is simple:

- Always have at least two independent copies of the repo
- Make restoration trivial
- Avoid manual heroics during incidents

This applies to the Brain (Mac mini), Backend (VPS), and any cloud mirrors.

Felipe owns backup policy.

---

## Principles

1. GitHub is the primary source of truth
2. At least one secondary cloud mirror must exist
3. The Mac mini must always keep a local clone
4. VPS keeps a working clone
5. Recovery must be possible from any single surviving copy

Never rely on only one machine or one provider.

---

## Primary Repository

The main GitHub repository is the canonical system state.

It contains:

- Architecture
- Tasks
- Code
- Automations
- Decisions
- Agent instructions

All agents push here.

If GitHub is reachable, this is always the first recovery point.

---

## Secondary Cloud Mirror (Recommended)

Create a second private repository on another provider (or another GitHub account / organization).

Examples:

- GitHub mirror in a separate org
- GitLab private repo
- Bitbucket private repo

This mirror exists only for backup.

It is not used for day-to-day development.

### Setup

On any machine with repo access:

```bash
git remote add backup <backup-repo-url>
```

Push regularly:

```bash
git push backup main
```

Recommended cadence:

- At least once per day
- Immediately after major architectural changes

Optional: automate via cron on the VPS.

---

## Mac Mini Local Clone (Critical)

The Mac mini (Brain OpenClaw) must always keep a full local clone.

Purpose:

- Offline access
- Fast recovery
- Human inspection
- Emergency restore

Initial setup:

```bash
git clone <main-repo-url>
```

Daily maintenance:

```bash
git pull
```

Optional safety:

Enable Time Machine or equivalent system backup on the Mac mini so the local repo is also backed up at OS level.

This gives you:

Git backup + disk backup.

---

## VPS Working Clone

The Backend OpenClaw (VPS) keeps a working clone for automation.

This is NOT considered a primary backup, but acts as an additional copy.

Setup:

```bash
git clone <main-repo-url>
```

Regularly:

```bash
git pull
```

Do not rely on VPS alone. VPS is disposable infrastructure.

---

## Optional: Automated Mirror from VPS

You may configure a daily cron job on the VPS:

```bash
0 2 * * * cd /path/to/repo && git push backup main
```

This creates a hands-off cloud mirror.

---

## Recovery Scenarios

### GitHub Down

- Use Mac mini local clone
- Push to backup mirror
- Restore GitHub from mirror when available

---

### VPS Lost

- Recreate VPS
- Clone from GitHub or backup mirror
- Resume automation

No data loss if GitHub or Mac mini exists.

---

### Mac Mini Lost

- Use GitHub or backup mirror
- Clone onto new machine
- Resume Brain OpenClaw

---

### Worst Case (GitHub Compromised)

- Restore from secondary cloud mirror
- Restore from Mac mini clone

This is why the mirror exists.

---

## What Must Always Be Backed Up

At minimum:

- Entire Git repository
- Agent instruction files
- Architecture documents
- TASKS.md
- /FELIPE folder (except PRIVATE.md if gitignored)

Credentials and API keys must be stored separately in a password manager.

Never store secrets directly in Git.

---

## Checklist

Daily (automated or manual):

- GitHub up to date
- Mac mini repo pulls clean
- VPS repo pulls clean

Weekly:

- Push to backup mirror
- Verify mirror integrity

Monthly:

- Test restore on a fresh folder or VM

---

## Summary

You maintain:

- GitHub primary repo
- Secondary cloud mirror
- Mac mini local clone
- VPS working clone

Any one of these can restore the system.

This gives you true redundancy with minimal complexity.

---

End of file.
