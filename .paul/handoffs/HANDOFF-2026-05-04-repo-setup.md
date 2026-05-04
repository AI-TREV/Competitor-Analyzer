# PAUL Handoff

**Date:** 2026-05-04
**Status:** paused — repo fully structured, ready to build

---

## READ THIS FIRST

You have no prior context. This document tells you everything.

**Project:** Competitor Scraper — NZ Egg Market Intelligence
**Repo:** https://github.com/AI-TREV/Competitor-Analyzer
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

This session was repo restructuring — NOT coding. No application code was written.

1. **Project renamed** — "egg price intelligence" → "NZ Egg Market Intelligence" across STATE.md, CLAUDE.md, README.md
2. **Monorepo created** — git initialized at workspace root `Competitor Analyzer/`. Nested `apps/competitor-scraper/.git` removed. 53 files committed and force-pushed to `AI-TREV/Competitor-Analyzer`
3. **Framework skills committed** — `.claude/commands/` (base, paul), `.claude/skills/` (firecrawl x13, base), `.claude/paul-framework/`, `.claude/base-framework/`, `.claude/hooks/` (carl, caveman). 196 files, 30k+ lines
4. **Machine-agnostic setup** — `.mcp.template.json` + `.claude/settings.local.template.json` created. `.mcp.json` and `.claude/settings.local.json` added to `.gitignore`
5. **Excluded from repo** — `Egg-Scraper/`, `antigravity-plus/`, `skillsmith/`, `chrome/` (nested git repos + browser binary)

---

## What's Next

**Immediate:**
```
/paul:apply .paul/phases/01-foundation/01-01-PLAN.md
```

**What apply builds (all in `apps/competitor-scraper/`):**
1. `better-sqlite3` installed
2. `migrations/001-initial-schema.sql` — 8 tables, 5 indexes, all constraints
3. `src/config/database.js` — connection singleton + migration runner
4. `src/config/seed.js` — 2 competitors, 12 stores, 4 internal SKU stubs
5. `db:setup` / `db:migrate` / `db:seed` scripts in `package.json`

**After APPLY:** `/paul:unify .paul/phases/01-foundation/01-01-PLAN.md`
**After UNIFY:** `/paul:plan` → Plan 01-02 (config modules, env, taxonomy constants)

---

## Collaborator Setup (Mac)

Second contributor has PAUL/CARL/RTK/lean-ctx already installed. To join:

```bash
git clone https://github.com/AI-TREV/Competitor-Analyzer.git "Competitor Analyzer"
cd "Competitor Analyzer"
npm install
cp .mcp.template.json .mcp.json           # edit lean-ctx path for Mac
cp .claude/settings.local.template.json .claude/settings.local.json  # edit PYTHON_PATH + WORKSPACE_PATH
```

Git workflow: `git pull origin main` before starting, push to `main` directly (both admins).

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/ROADMAP.md` | All 6 phases, dashboard design, post-MVP backlog |
| `.paul/INTEGRATION.md` | 19-item tracking table — every item → phase/plan |
| `.paul/phases/01-foundation/01-01-PLAN.md` | **Execute this next — 3 tasks** |
| `apps/competitor-scraper/PLANNING.md` | Full architecture spec + 8-table data model |
| `.mcp.template.json` | Template for machine-specific MCP config |
| `.claude/settings.local.template.json` | Template for machine-specific hooks config |

---

## Resume Instructions

1. Open Claude Code — working directory: `Competitor Analyzer/` (workspace root)
2. Run `/paul:resume` — restores context from STATE.md + this handoff
3. Run `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

---

*Handoff created: 2026-05-04*
*Session work: Repo restructured as monorepo, all framework skills committed, machine-agnostic setup created. No application code written.*
