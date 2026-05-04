# PAUL Handoff

**Date:** 2026-05-04 — tooling setup session
**Status:** paused — workspace tooling complete, no app code written

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

- Cloned `Claude-Code-Status-Clarity` statusline tool to `/Users/admin/Claude-Code-Status-Clarity` and updated `~/.claude/settings.json` statusLine path
- Created `.claude/settings.json` wiring up all four workspace tools:
  - **caveman** — SessionStart + UserPromptSubmit hooks (JS files already in `.claude/hooks/`)
  - **token-optimizer** — 10 hook events (SessionStart, UserPromptSubmit, PreToolUse, PostToolUse, PreCompact, PostCompact, Stop, StopFailure, SessionEnd, CwdChanged), using `$HOME/.claude/skills/token-optimizer/scripts/` paths
  - **lean-ctx** — already active via MCP server in `.mcp.json`
  - **rtk** — already active via CLAUDE.md instructions (use `rtk` prefix on bash commands)

---

## What's In Progress

Nothing — all tooling setup is complete. Clean slate for application code.

---

## What's Next

**Immediate:** `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

This builds:
1. `apps/competitor-scraper/package.json` — `"type": "module"` is non-negotiable
2. `npm install` — better-sqlite3 requires Xcode CLT (already present)
3. 8-table SQLite schema migration
4. DB singleton (`database.js`)
5. Seed data

**After that:** UNIFY loop for Phase 1 Plan 1, then Plan 01-02.

---

## Key Files

| File | Purpose |
|------|---------|
| `.paul/STATE.md` | Live project state |
| `.paul/phases/01-foundation/01-01-PLAN.md` | Current plan — ready for APPLY |
| `.paul/phases/01-foundation/01-01-AUDIT.md` | Enterprise audit — 7 changes applied |
| `.claude/settings.json` | Workspace tool hooks (caveman, token-optimizer) |
| `.mcp.json` | MCP servers (lean-ctx, base-mcp) |
| `.paul/handoffs/HANDOFF-INDEX.md` | Full handoff history |

---

## Critical Decisions To Remember

| Decision | Impact |
|----------|--------|
| `"type": "module"` non-negotiable in package.json | ES module syntax throughout; omission = hard SyntaxError |
| `store_id NOT NULL` on competitor_price_observation | Nullable silently bypasses UNIQUE constraint in SQLite (NULL≠NULL) |
| Working directory is `/Users/admin/Competitor-Analyzer` | Confirmed correct — no space in path |
| All APPLY targets go in `apps/competitor-scraper/` | Subdirectory only — nothing at repo root |

---

## Resume Instructions

1. Read `.paul/STATE.md` for latest position
2. Run `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`

---

*Handoff created: 2026-05-04*
