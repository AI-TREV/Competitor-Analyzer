# PAUL Handoff

**Date:** 2026-05-04
**Status:** paused — token limit approaching, spec written for Mac session

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** NZ Egg Market Intelligence — Competitor Scraper
**Repo:** https://github.com/AI-TREV/Competitor-Analyzer
**Core value:** Automated weekly competitor price intelligence replacing manual store visits

---

## Current State

**Version:** 0.0.0
**Phase:** 1 of 6 — Foundation (Data Model & Configuration)
**Plan:** 01-01 — finalized, no code written yet

**Loop Position:**
```
PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ○        ○     [Plan approved, awaiting APPLY]
```

---

## What Was Done This Session

1. Ran `/paul:resume` — confirmed loop position and handoff context
2. Identified framework enhancement work queued from prior session: Handoff Index System
3. Wrote spec: `.paul/specs/handoff-index-system.md` — full implementation plan for HANDOFF-INDEX.md, updated pause/resume workflows, and `/paul:handoffs` command
4. Created this handoff for Mac session continuity

No application code written. No APPLY executed yet.

---

## Two Tracks — Do Framework First

**Track A (Mac — do first):** Implement Handoff Index System per spec
- File: `.paul/specs/handoff-index-system.md`
- 5 files to create/edit (see spec File Map)
- Test with `/paul:pause` → `/paul:handoffs list` → `/paul:resume`

**Track B (after Track A):** `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`
- Builds: better-sqlite3, 8-table schema migration, DB singleton, seed data
- All output goes into `apps/competitor-scraper/`

---

## What's Next (Mac Session)

**Step 1 — Clone:**
```bash
git clone https://github.com/AI-TREV/Competitor-Analyzer.git "Competitor Analyzer"
cd "Competitor Analyzer"
npm install
cp .mcp.template.json .mcp.json           # edit lean-ctx path for Mac
cp .claude/settings.local.template.json .claude/settings.local.json  # edit PYTHON_PATH + WORKSPACE_PATH
```

**Step 2 — Open Claude Code in workspace root `Competitor Analyzer/`**

**Step 3 — Run:**
```
/paul:resume
```
(This handoff will be detected. Say "A" to do framework work first.)

**Step 4 — Implement spec:**
Read `.paul/specs/handoff-index-system.md` — it has exact files, steps, and backfill data.

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/specs/handoff-index-system.md` | **The spec to implement on Mac** |
| `.paul/phases/01-foundation/01-01-PLAN.md` | APPLY this after framework work |
| `.paul/ROADMAP.md` | All 6 phases |
| `apps/competitor-scraper/PLANNING.md` | Full architecture + 8-table data model |

---

## Decisions Made This Session

| Decision | Rationale |
|----------|-----------|
| Handoff index system spec written before APPLY | PAUL framework hygiene needed before app build begins |
| HANDOFF files never deleted — index is control surface | Preserves full audit trail; index manages visibility |
| Decision promotion is optional in pause workflow | Avoid blocking pause flow on trivial sessions |

---

## Context for Fresh Claude

- Monorepo root is `Competitor Analyzer/` — all claude commands run from here
- App code lives in `apps/competitor-scraper/` — nothing there yet
- PAUL framework files live in `~/.claude/paul-framework/` (machine-local, not in repo)
- `.mcp.json` and `.claude/settings.local.json` are gitignored — each machine needs own copy from templates
- Co-author on all commits: `Clarity Engine <brad@clarityengine.co>`

---

*Handoff created: 2026-05-04*
*Session work: Spec for handoff index system written to .paul/specs/. No app code written.*
