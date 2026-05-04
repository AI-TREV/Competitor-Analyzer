# Competitor Analyzer — Workspace

## What This Is

Workspace for building automated NZ Egg Market Intelligence for an Auckland NZ free range egg business. Primary product: competitor price scraper that tracks Woolworths NZ and New World NZ, normalizes products to internal SKUs, and generates Market Opportunities Reports.

## Framework Stack

| Tool | Role | Status |
|------|------|--------|
| BASE | Workspace memory, health, MCP server | Active |
| PAUL | Project execution loop (PLAN → APPLY → UNIFY) | Active — Phase 1 ready |
| CARL | Behavioral governance, domain rules | Active — `.carl/carl.json` |
| SKILLSMITH | Skill creation meta-framework | Complete (v0.1) |
| Caveman | Token-compressed responses | Active (global) |
| RTK | Bash token optimizer | Active (global hook) |
| Agent-browser | Headless browser test runner | Configured |

## Active Projects

**`apps/competitor-scraper/`** — PRIMARY BUILD (PAUL-managed, Phase 1 of 6)
- Plan 01-01 approved and ready to execute: `/paul:apply .paul/phases/01-foundation/01-01-PLAN.md`
- Loop position: PLAN ✓ → APPLY ○ → UNIFY ○
- 6 phases: Foundation → Scraping Pipeline → Normalization → Persistence → Reporting → UI

**`skillsmith/`** — Complete (v0.1). Meta-framework for creating Claude Code skills.

**`antigravity-plus/`** — VS Code extension. Satellite in BASE workspace.

## PAUL Convention

`.paul/` lives at workspace root. All APPLY file operations target `apps/competitor-scraper/` unless otherwise specified. State file: `.paul/STATE.md`.

## Key Technical Constraints

- Scraping: public data only, no auth bypass, Auckland region, free range eggs only
- Database: SQLite (MVP), WAL mode, foreign_keys ON, absolute path at startup
- Firecrawl primary, Playwright fallback + screenshots
- All observations need source_url + raw_json_snapshot
- screenshot_path: relative only (`{run_id}/{filename}.png`)

## Directory Map

```
Competitor Analyzer/
├── .base/          BASE infrastructure (MCP + hooks + data surfaces)
├── .carl/          CARL behavioral rules (carl.json)
├── .claude/        Claude Code project settings
├── .paul/          PAUL project state (workspace root)
├── .mcp.json       MCP server config (base-mcp)
├── CLAUDE.md       This file
├── apps/
│   └── competitor-scraper/   Active build — Node.js scraper
├── skillsmith/               Skill creation framework
├── antigravity-plus/         VS Code extension
├── chrome/                   Playwright browser binary (never commit)
├── agent-browser.json        Headless browser config
└── package.json              Shared workspace dependencies
```

## Do Not

- Commit `chrome/` — browser binary, too large
- Modify `.paul/` files manually — PAUL manages them
- Expand scraping scope beyond Woolworths NZ + New World NZ without user confirmation
- Write code outside `/paul:apply` unless explicitly debugging
