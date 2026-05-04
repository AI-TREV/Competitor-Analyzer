# Competitor Scraper — NZ Egg Market Intelligence

Automated NZ Egg Market Intelligence for Auckland, New Zealand. Tracks public supermarket pricing from Woolworths and New World, normalizes and maps products to internal SKUs, and generates Market Opportunities Reports.

## Quick Start

```bash
# Install dependencies
npm install

# Set up environment
cp .env.example .env
# Edit .env with your FIRECRAWL_API_KEY

# Initialize database
npm run db:setup

# Run a scrape
npm run scrape

# Generate report
npm run report

# Start dashboard
npm run dev
```

## Architecture

```
Firecrawl / Playwright  →  Normalizer  →  SQLite  →  Reports
     (scrape)              (map SKUs)     (persist)   (analyze)
```

- **Firecrawl** (primary) — Structured extraction from public product pages
- **Playwright** (fallback) — Browser rendering + screenshot evidence
- **SQLite** (MVP) — Zero-config local database
- **Vite** — Lightweight web dashboard

## Scope

- **Geography:** Auckland City region
- **Chains:** Woolworths NZ, New World NZ
- **Products:** Free range eggs only (all pack sizes)
- **Frequency:** Manual trigger (automated scheduling post-MVP)

## Project Management

This project uses PAUL for structured builds. See `.paul/` for project state and roadmap.

---

*Generated from SEED — graduated from ideation to build*
