# PAUL Handoff

**Date:** 2026-05-04 — CLAUDE.md audit session
**Status:** paused — CLAUDE.md audited, CLAUDE.base.md ready to adopt, no app code written

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

- Ran `/paul:resume` — confirmed loop position, consumed tooling-setup handoff context
- Ran `/performance-audit` — no application code exists yet, nothing to audit
- Ran `/base:audit-claude-md` — full strategy audit of CLAUDE.md:
  - Classified all 205 lines (KEEP / REMOVE / RESTRUCTURE / CARL_CANDIDATE)
  - Wrote `CLAUDE.base.md` (75 lines, down from 205)
  - Removed: RTK block (137 lines — already in global CLAUDE.md, dead weight here)
  - Removed: Active Projects section (volatile — lives in STATE.md)
  - Added: Why section (philosophy + separation of concerns)
  - Added: Who section (business context — Auckland NZ egg business)
  - Restructured: Where tree verified against actual filesystem
  - CARL candidates: all already in CARL domains — no migration needed
- Confirmed skillsmith installed globally (no local directory in workspace)
- Corrected Where tree: `skillsmith/` and `antigravity-plus/` removed (don't exist in workspace)

---

## What's In Progress

- `CLAUDE.base.md` written and ready — operator needs to adopt it:
  ```bash
  mv CLAUDE.base.md CLAUDE.md
  ```
  This is optional housekeeping — does NOT block APPLY.

---

## What's Next

**Immediate:** `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

Builds:
1. `apps/competitor-scraper/package.json` — `"type": "module"` is non-negotiable
2. `npm install` — better-sqlite3 requires Xcode CLT (already present)
3. 8-table SQLite schema migration
4. DB singleton (`database.js`)
5. Seed data

**Optional first:** `mv CLAUDE.base.md CLAUDE.md` — adopt audited CLAUDE.md (75 lines, clean)

**After APPLY:** `/paul:unify .paul/phases/01-foundation/01-01-PLAN.md`

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/phases/01-foundation/01-01-PLAN.md` | Current plan — ready for APPLY |
| `.paul/phases/01-foundation/01-01-AUDIT.md` | Enterprise audit — 7 changes applied |
| `CLAUDE.base.md` | Audited CLAUDE.md (75 lines) — adopt with mv |
| `.carl/carl.json` | All operational rules (paul-workflow, scraping, database, reporting) |

---

## Critical Decisions To Remember

| Decision | Impact |
|----------|--------|
| `"type": "module"` non-negotiable in package.json | ES module syntax throughout; omission = hard SyntaxError |
| `store_id NOT NULL` on competitor_price_observation | Nullable silently bypasses UNIQUE constraint in SQLite (NULL≠NULL) |
| All APPLY targets → `apps/competitor-scraper/` only | Nothing at repo root |
| CARL owns all operational rules | CLAUDE.md is constitution only — don't add operational rules there |

---

## Resume Instructions

1. Read `.paul/STATE.md` for latest position
2. Optionally: `mv CLAUDE.base.md CLAUDE.md` (CLAUDE.md audit housekeeping)
3. Run `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

---

*Handoff created: 2026-05-04*
