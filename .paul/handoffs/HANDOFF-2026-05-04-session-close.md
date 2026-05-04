# PAUL Handoff

**Date:** 2026-05-04 — session close
**Status:** paused — all housekeeping complete, repo pushed to GitHub, ready for APPLY

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** Competitor Scraper — NZ Egg Market Intelligence  
**Core value:** Automated weekly competitor price intelligence with full audit trail, replacing manual store visits.

---

## Current State

**Version:** 0.0.0  
**Phase:** 1 of 6 — Foundation (Data Model & Configuration)  
**Plan:** 01-01 — audited + approved, ready for APPLY

**Loop Position:**
```
PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ○        ○
```

---

## What Was Done

- CLAUDE.md audit complete — CLAUDE.base.md written (75 lines, from 205)
- Adopted CLAUDE.base.md as CLAUDE.md (`mv CLAUDE.base.md CLAUDE.md`)
- Fixed GitHub push auth — Clarity-EngineAI added as collaborator to AI-TREV/Competitor-Analyzer
- Pushed all 5 commits to origin/main — repo fully synced
- skillsmith confirmed installed globally (available in all Claude Code sessions)

---

## What's In Progress

Nothing — clean slate for application code.

---

## What's Next

**Immediate:** `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

Builds in order:
1. `apps/competitor-scraper/package.json` — `"type": "module"` is non-negotiable
2. `npm install` — better-sqlite3 requires Xcode CLT (already present on this Mac)
3. 8-table SQLite schema migration
4. DB singleton (`src/database.js`)
5. Seed data (`src/seed.js`)

**After APPLY:** `/paul:unify .paul/phases/01-foundation/01-01-PLAN.md`

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/phases/01-foundation/01-01-PLAN.md` | Current plan — ready for APPLY |
| `.paul/phases/01-foundation/01-01-AUDIT.md` | Enterprise audit — 7 changes applied |
| `.carl/carl.json` | All operational rules (paul-workflow, scraping, database, reporting) |
| `CLAUDE.md` | Audited, 75-line workspace constitution |

---

## Critical Decisions To Remember

| Decision | Impact |
|----------|--------|
| `"type": "module"` non-negotiable in package.json | ES module syntax throughout; omission = hard SyntaxError |
| `store_id NOT NULL` on competitor_price_observation | Nullable silently bypasses UNIQUE constraint in SQLite (NULL≠NULL) |
| All APPLY targets → `apps/competitor-scraper/` only | Nothing at repo root |
| GitHub push: Clarity-EngineAI needs collaborator access | Already granted — push works |

---

## Resume Instructions

1. Read `.paul/STATE.md` for latest position
2. Run `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

---

*Handoff created: 2026-05-04*
