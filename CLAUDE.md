# CLAUDE.md

## What

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## Why

Build context for NZ egg market intelligence automation. Execution state lives in PAUL, behavioural rules live in CARL, workspace health lives in BASE. This file is the constitution — identity and routing only. Operational detail lives in the systems that own it.

---

## Who

**Competitor Analyzer** — automated price intelligence for an Auckland NZ free range egg business.

Primary product: scraper tracking Woolworths NZ + New World NZ, normalising products to internal SKUs, generating weekly Market Opportunities Reports.

---

## Where

```
Competitor-Analyzer/
├── .base/                    BASE infrastructure (MCP + hooks + data surfaces)
├── .carl/                    CARL behavioural rules (carl.json)
├── .claude/                  Claude Code settings (hooks, permissions)
├── .firecrawl/               Firecrawl config
├── .paul/                    PAUL project state — never edit manually
├── .mcp.json                 MCP server config
├── apps/
│   └── competitor-scraper/   Active build — Node.js scraper (Phases 1–6)
├── projects/                 Planning artefacts and reference docs
├── tests/                    Workspace-level test scripts
├── agent-browser.json        Headless browser config
└── package.json              Shared workspace dependencies
```

---

## How

### Systems

| System | Purpose | Location |
|--------|---------|----------|
| BASE | Workspace memory, health, MCP | `.base/` |
| PAUL | Project execution loop (PLAN → APPLY → UNIFY) | `.paul/` |
| CARL | Behavioural governance, domain rules | `.carl/carl.json` |
| lean-ctx | Token-efficient context tools | MCP (`.mcp.json`) |
| RTK | Bash token optimiser | Global hook |
| Caveman | Compressed response mode | Global hook |

### Git Strategy

| Path | Approach |
|------|----------|
| `chrome/` | Never tracked — Playwright binary, too large |
| `.paul/` | Tracked — PAUL manages, never edit manually |
| `apps/competitor-scraper/` | Tracked — all application code |

### Rules

NEVER commit `chrome/` — Playwright binary exceeds git limits  
NEVER edit `.paul/` files manually — PAUL manages all state  
NEVER add operational rules here — they belong in CARL domains

### Quick Reference

**Resume PAUL work?** → `/paul:resume`  
**Apply a plan?** → `/paul:apply .paul/phases/{phase}/{plan}-PLAN.md`  
**Check project status?** → `/paul:status`  
**Check CARL rules?** → `/base:carl-hygiene`
