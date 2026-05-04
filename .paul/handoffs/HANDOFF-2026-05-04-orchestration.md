# PAUL Handoff

**Date:** 2026-05-04
**Status:** paused — workspace fully orchestrated, ready to build

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** Competitor Scraper — automated competitor egg price intelligence for Auckland NZ free range egg business
**Repo:** https://github.com/AI-TREV/Competitor-Analyzer (rename from Egg-Scraper may still be pending — check)
**Core value:** Automated, weekly competitor price intelligence with full audit trail — replacing manual store visits

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

This session was workspace orchestration — NOT coding. No application code was written.

1. **PAUL relocated** — `.paul/` moved from `apps/competitor-scraper/.paul/` to workspace root `Competitor Analyzer/.paul/`. All internal paths updated to prefix `apps/competitor-scraper/`.
2. **CARL configured** — `.carl/carl.json` created with 4 active domains:
   - `paul-workflow` (always_on) — PAUL loop governance rules + key project decisions
   - `scraping` — Firecrawl/Playwright rules, scope constraints, audit trail requirements
   - `database` — SQLite rules, foreign_keys, WAL, idempotent migrations
   - `reporting` — ExcelJS, PDF, dashboard, Phase 5 dependencies
3. **Root CLAUDE.md created** — workspace identity, framework stack, directory map, constraints
4. **settings.local.json fixed** — removed stale `carl-mcp` from `enabledMcpjsonServers` (CARL v2 is hook-based, not MCP)
5. **workspace.json updated** — skillsmith satellite registered; competitor-scraper state path updated to `.paul/STATE.md`
6. **lean-ctx MCP wired** — binary installed (was broken — tar extraction failed on Windows, fixed with PowerShell). Added to `.mcp.json` + `settings.local.json`.
7. **RTK hook fixed** — was calling `rtk` (not in PATH). Updated `~/.claude/settings.json` to use full path: `C:/Users/trevo/.claude/plugins/rtk-bin/rtk.exe hook claude`
8. **Git cleanup pending** — `apps/competitor-scraper/.paul/` deletions are unstaged. Needs commit.

---

## What's Pending

- **GitHub repo rename** — `Egg-Scraper` → `Competitor-Analyzer`. Run `gh auth login` then `gh repo rename Competitor-Analyzer --repo AI-TREV/Egg-Scraper --yes` in terminal.
- **Operator profile** — `.base/operator.json` all nulls. Run `/base:orientation` when ready.
- **Git deletions** — `apps/competitor-scraper/.paul/` deleted (moved to root). Needs commit before APPLY.

---

## What's Next

**Step 1 — Commit .paul/ deletion from competitor-scraper repo:**

```bash
cd apps/competitor-scraper
git add -A
git commit -m "chore: move .paul to workspace root

PAUL now managed from Competitor Analyzer root.
All plan file paths updated to apps/competitor-scraper/ prefix."
git push
```

**Step 2 — Restart Claude Code session** (activates RTK full-path hook + lean-ctx MCP)

**Step 3 — Execute Plan 01-01:**
```
/paul:apply .paul/phases/01-foundation/01-01-PLAN.md
```

**What apply builds (all in apps/competitor-scraper/):**
1. `better-sqlite3` installed
2. `migrations/001-initial-schema.sql` — 8 tables, 5 indexes, all constraints
3. `src/config/database.js` — connection singleton + migration runner
4. `src/config/seed.js` — 2 competitors, 12 stores, 4 internal SKU stubs
5. `db:setup` / `db:migrate` / `db:seed` scripts added to `package.json`

**After APPLY:** `/paul:unify .paul/phases/01-foundation/01-01-PLAN.md`
**After UNIFY:** `/paul:plan` → Plan 01-02 (config modules, env, taxonomy constants)

---

## Framework Status

| Tool | Was | Now |
|------|-----|-----|
| BASE MCP | Active | Active (unchanged) |
| CARL | Hook fired, no rules (no carl.json) | Active — `.carl/carl.json` 4 domains |
| PAUL | In apps/competitor-scraper/.paul/ | At workspace root `.paul/` |
| lean-ctx MCP | Binary broken, not in .mcp.json | Active — binary fixed, wired to .mcp.json |
| RTK | rtk not in PATH → hook failing | Active — full path in `~/.claude/settings.json` |
| Caveman | Active | Active (unchanged) |

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/ROADMAP.md` | All 6 phases, dashboard design, post-MVP backlog |
| `.paul/INTEGRATION.md` | 19-item tracking table — every item → phase/plan |
| `.paul/phases/01-foundation/01-01-PLAN.md` | **Execute this — 3 tasks, paths prefixed `apps/competitor-scraper/`** |
| `apps/competitor-scraper/PLANNING.md` | Full architecture spec + 8-table data model |
| `.carl/carl.json` | CARL behavioral rules (4 domains) |
| `CLAUDE.md` | Workspace identity and framework map |

---

## Resume Instructions

1. Open Claude Code — working directory: `Competitor Analyzer/` (workspace root)
2. Run `/paul:resume` — restores context from STATE.md + this handoff
3. Commit `.paul/` deletions in `apps/competitor-scraper/` if not done
4. Restart session, then run `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

---

*Handoff created: 2026-05-04*
*Session work: Full workspace orchestration — CARL/lean-ctx/RTK fixed, PAUL relocated to root, no application code written*
