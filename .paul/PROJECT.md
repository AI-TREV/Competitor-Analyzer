# Project: Competitor Scraper

## What This Is

A controlled scraping module that tracks public supermarket competitor egg prices across Auckland, New Zealand. Extracts pricing from Woolworths and New World shopping websites, normalizes and maps competitor products to internal SKUs, persists observations with full audit trails, and feeds into a Market Opportunities Report.

## Core Value

Automated, weekly competitor price intelligence with full audit trail — replacing manual store visits or ad hoc price checks with a structured, repeatable pipeline that feeds directly into pricing decisions.

## Current State

| Attribute | Value |
|-----------|-------|
| Version | 0.0.0 |
| Status | Planning Complete |
| Last Updated | 2026-05-04 |

## Requirements

### Must Have
- Firecrawl + Playwright scraping pipeline for Woolworths and New World
- Product normalization (raw name → brand, size, pack_size)
- SKU matching with confidence scoring
- SQLite persistence with full audit trail (screenshots, raw JSON, source URLs)
- Exception queue for low-confidence matches
- Manual trigger (operator-initiated scrape runs)
- Price gap report (internal vs competitor)
- Market Opportunities Report (PDF + Excel)

### Should Have
- Lightweight web dashboard (3 screens: dashboard, competitor prices, reports)
- Email distribution of reports via Resend
- Guardrail validation before every scrape request

### Nice to Have
- Automated daily scheduling
- PostgreSQL migration for production
- Historical price trend charts

### Out of Scope
- Non-Auckland regions
- Non-egg products
- Cage or barn eggs
- Internal pricing engine modifications
- Mobile app

## Target Users

**Primary:** Business owner/operator who sets egg pricing strategy based on competitor observations.

## Context

**Business Context:**
- Free range egg market in Auckland
- Competitors: Woolworths NZ, New World NZ
- Brands monitored: Otaika, Better Eggs, New Day, Macro, Woolworths house brand, Natural, Good Farms, Pams, Coulston Hill, Frenz

**Technical Context:**
- Node.js (ES modules), Firecrawl JS SDK, Playwright
- SQLite (MVP) → PostgreSQL (production)
- Zod validation, ExcelJS + @react-pdf/renderer for export
- Part of larger Competitor Analyzer workspace with BASE infrastructure

## Constraints

### Technical Constraints
- Public data only — no logins, no private APIs, no anti-bot circumvention
- Respectful scraping — paced requests, proper user-agent
- Must store raw snapshots for reprocessing

### Business Constraints
- Auckland region only for MVP
- Free range eggs only
- Manual trigger initially (no automated scheduling)

## Key Decisions

| Decision | Rationale | Date | Status |
|----------|-----------|------|--------|
| Firecrawl as primary scraper | Structured extraction, handles JS rendering, returns clean JSON | 2026-05-04 | Active |
| Playwright as fallback | For pages Firecrawl can't parse + screenshot evidence | 2026-05-04 | Active |
| SQLite for MVP | Zero-config, single-file, sufficient for weekly operator runs | 2026-05-04 | Active |
| Zod for scrape validation | Already installed, validates output before DB write | 2026-05-04 | Active |
| Vite + vanilla JS for UI | Lightweight, no heavy framework for 3 screens | 2026-05-04 | Active |
| Manual trigger first | Automated scheduling deferred until pipeline is stable | 2026-05-04 | Active |

## Success Metrics

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| Scraper extraction rate | ≥ 90% of listed products | — | Not started |
| Normalization accuracy | ≥ 85% correct parsing | — | Not started |
| SKU match confidence | ≥ 70% matched > 0.7 confidence | — | Not started |
| Audit trail completeness | 100% have source_url + raw_json | — | Not started |
| Screenshot coverage | ≥ 95% have screenshot evidence | — | Not started |
| End-to-end scrape time | < 10 minutes | — | Not started |

## Tech Stack

| Layer | Technology | Notes |
|-------|------------|-------|
| Runtime | Node.js | ES modules |
| Scraping (primary) | @mendable/firecrawl-js | ^4.21.0 |
| Scraping (fallback) | Playwright | Browser rendering + screenshots |
| Database (MVP) | better-sqlite3 | Zero-config |
| Validation | Zod | ^4.4.2 |
| Reports (Excel) | ExcelJS | ^3.10.0 |
| Reports (PDF) | @react-pdf/renderer | ^4.5.1 |
| Email | Resend | ^6.12.2 |
| Dates | date-fns | ^4.1.0 |
| Environment | dotenv | ^17.4.2 |
| UI | Vite + vanilla JS | Lightweight dashboard |

## Links

| Resource | URL |
|----------|-----|
| Planning Doc | apps/competitor-scraper/PLANNING.md |
| Scope Document | Scope_ Competitor Web Scraping Module.md |

---
*Created: 2026-05-04*
*Derived from PLANNING.md via PAUL headless init*
