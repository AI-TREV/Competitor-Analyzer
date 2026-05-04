# PAUL Handoff

**Date:** 2026-05-04
**Status:** paused — full pre-execution planning complete, repo pushed to GitHub, ready to build

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** Egg-Scraper — tracks public supermarket egg prices (Woolworths + New World, Auckland NZ)
**Repo:** https://github.com/AI-TREV/Egg-Scraper.git
**Core value:** Automated weekly competitor price intelligence with full audit trail, replacing manual store visits

---

## Current State

**Version:** 0.0.0
**Phase:** 1 of 6 — Foundation (Data Model & Configuration)
**Plan:** 01-01 finalized and ready to execute — no code written yet

**Loop Position:**
```
PLAN ──▶ APPLY ──▶ UNIFY
  ✓        ○        ○     [Plan approved, ready for APPLY]
```

---

## What Was Done This Session

- Ran full pre-execution forensic review — found 5 data integrity risks in original planning doc
- Updated Plan 01-01 to incorporate all forensic fixes (8 tables, 5 indexes, new constraints)
- Rewrote ROADMAP.md — all 6 phases now have full scope, dashboard design threading, and post-MVP backlog
- Created `.paul/INTEGRATION.md` — master 19-item tracking table (source → phase → plan → status)
- Updated `PLANNING.md` — data model section reflects 8-table schema with all constraints
- Updated `STATE.md` — all key decisions documented
- Committed all planning files and pushed to GitHub

---

## Key Schema Changes (Plan 01-01 — what it will build)

**8 tables** (original spec had 6, first plan had 7):
1. `competitor`
2. `competitor_store` — added: `last_scraped_at`, `last_scrape_status` (store freshness for dashboard)
3. `internal_sku`
4. `internal_price_history` — NEW (historical gap analysis in Phase 5 reporting)
5. `competitor_product` — added: `UNIQUE(competitor_id, competitor_name, pack_size)`
6. `scrape_run`
7. `competitor_price_observation` — changed: `observed_at` no DEFAULT, added `UNIQUE(product, store, run)`, `screenshot_path CHECK` enforces relative paths
8. `exception_queue` — taxonomy documented: `MATCH_CONFIDENCE_LOW | PARSE_FAILED | PRICE_ANOMALY | JSON_INVALID | SITE_BLOCKED | SKU_REF_ERROR`

**5 indexes** (was 4 — added `idx_price_history_sku`)

---

## What's In Progress

Nothing. All planning complete. No code exists yet. Plan 01-01 is the first execution step.

---

## What's Next

**Immediate:** Clone repo on new machine, then execute Plan 01-01:

```bash
git clone https://github.com/AI-TREV/Egg-Scraper.git
cd Egg-Scraper
npm install
```

Then in Claude Code:
```
/paul:apply .paul/phases/01-foundation/01-01-PLAN.md
```

**What apply will build:**
1. Install `better-sqlite3`
2. Create `migrations/001-initial-schema.sql` (8 tables, 5 indexes, all constraints)
3. Create `src/config/database.js` (connection singleton + migration runner, absolute path)
4. Create `src/config/seed.js` (2 competitors, 12 stores, 4 internal SKU stubs)
5. Add `db:setup`, `db:migrate`, `db:seed` scripts to `package.json`
6. Verify with `npm run db:setup`

**After APPLY:** Run `/paul:unify .paul/phases/01-foundation/01-01-PLAN.md`
**After UNIFY:** Run `/paul:plan` for Plan 01-02 (config modules: stores, product ranges, guardrails, env, taxonomy constants)

---

## Items Deferred to Later Phases

| Item | Phase | Plan |
|------|-------|------|
| SCREENSHOT_DIR absolute resolution | 1 | 01-02 |
| ExceptionQueue taxonomy constants module | 1 | 01-02 |
| Price anomaly thresholds config | 1 | 01-02 |
| JSON.parse validation before DB write | 2 | 02-03 |
| Pre-write price anomaly check | 2 | 02-03 |
| New SKU detection flag | 2 | 02-03 |
| SKU mapping FK error → ExceptionQueue | 3 | 03-02 |
| Phase 4 transaction wrapping | 4 | 04-01 |
| Email allowlist + dry-run flag | 5 | 05-02 |
| 5 new intelligence metrics | 5 | 05-01 |

See `.paul/INTEGRATION.md` for complete 19-item tracking table.

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/ROADMAP.md` | All 6 phases with full scope + dashboard notes + post-MVP backlog |
| `.paul/INTEGRATION.md` | Master reference: every forensic/improvement/innovation item mapped to phase |
| `.paul/phases/01-foundation/01-01-PLAN.md` | **The plan to execute — 3 tasks, 8 tables** |
| `PLANNING.md` | Full architecture spec + updated 8-table data model |
| `.paul/PROJECT.md` | Project summary + constraints |

---

## Resume Instructions

1. Clone: `git clone https://github.com/AI-TREV/Egg-Scraper.git`
2. Open in Claude Code with working directory: `Egg-Scraper/`
3. Run `/paul:resume` — restores context from STATE.md + this handoff
4. Approve Plan 01-01 (already approved — just execute it)
5. Run `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

---

*Handoff created: 2026-05-04*
*Session work: Full forensic review + integration plan — no code written, all planning locked and pushed*
