# Competitor Web Scraping Module

## What This Is

A controlled scraping module that tracks public supermarket competitor egg prices across Auckland, New Zealand. It extracts pricing from Woolworths and New World shopping websites, normalizes and maps competitor products to internal SKUs, persists observations with full audit trails, and feeds into a Market Opportunities Report comparing internal vs competitor pricing.

**Domain:** Egg pricing intelligence — free range eggs only, Auckland City region.

**Users:** Business owner/operator who sets pricing strategy based on competitor observations.

## Core Value

Automated, weekly competitor price intelligence with full audit trail — replacing manual store visits or ad hoc price checks with a structured, repeatable pipeline that feeds directly into pricing decisions.

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────┐
│                    Scrape Orchestrator                    │
│              (creates scrape_run_id, manages flow)        │
├──────────────────────┬──────────────────────────────────┤
│   Firecrawl Client   │    Playwright Fallback            │
│   (primary extract)  │    (screenshots + fallback)       │
└──────────┬───────────┴──────────────┬───────────────────┘
           │                          │
           ▼                          ▼
┌─────────────────────────────────────────────────────────┐
│              Product Normalizer + SKU Matcher             │
│         (brand, size, pack → internal SKU mapping)       │
│         (match_confidence → ExceptionQueue if low)       │
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                     SQLite Database                       │
│  Competitor │ CompetitorProduct │ CompetitorPriceObs     │
│             │                   │ (+ raw_json, screenshots)│
└──────────────────────────┬──────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                   Reporting Layer                         │
│  Price Gap Table │ Market Opportunities │ PDF/Excel       │
└─────────────────────────────────────────────────────────┘
```

### Key Architecture Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Primary scraper | Firecrawl API | Structured extraction from public pages, handles JS-rendered content, returns clean JSON |
| Fallback scraper | Playwright | For pages Firecrawl can't parse cleanly + screenshot evidence capture |
| MVP database | SQLite | Zero-config, single-file, sufficient for single-operator weekly runs |
| Production database | PostgreSQL | Multi-user, access control, reliability for production use |
| Runtime | Node.js (ES modules) | Matches existing `package.json` setup, Firecrawl SDK is JS |
| Schema validation | Zod | Already installed, validates scrape output before DB write |
| Report export | ExcelJS + @react-pdf/renderer | Already installed, Excel for data analysis, PDF for presentation |
| Email delivery | Resend | Already installed, for automated report distribution |
| Config management | dotenv | Already installed, keeps API keys out of source |
| App UI framework | Vite + vanilla JS | Lightweight, fast dev server, no heavy framework needed for 3 screens |
| App styling | Vanilla CSS (dark mode) | Per workspace conventions, premium aesthetic |

---

## Tech Stack

| Layer | Technology | Version/Notes |
|-------|------------|---------------|
| Runtime | Node.js | ES modules (`"type": "module"` in package.json) |
| Scraping (primary) | `@mendable/firecrawl-js` | ^4.21.0 — already installed |
| Scraping (fallback) | Playwright | Via `agent-browser` — already configured |
| Database (MVP) | better-sqlite3 | Synchronous, fast, zero-config |
| Database (prod) | PostgreSQL + pg | Migration path from SQLite |
| Validation | Zod | ^4.4.2 — already installed |
| Reports (Excel) | ExcelJS | ^3.10.0 — already installed |
| Reports (PDF) | @react-pdf/renderer | ^4.5.1 — already installed |
| Email | Resend | ^6.12.2 — already installed |
| Date handling | date-fns | ^4.1.0 — already installed |
| Environment | dotenv | ^17.4.2 — already installed |
| App UI | Vite | Dev server + build |
| Testing | Node test runner | Built-in, no extra deps |

### Dependencies to Add

```json
{
  "better-sqlite3": "^11.0.0",
  "playwright": "^1.49.0"
}
```

---

## Data Model

### Competitor

```sql
CREATE TABLE competitor (
  competitor_id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  region TEXT NOT NULL DEFAULT 'Auckland',
  website TEXT NOT NULL,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### CompetitorStore

```sql
CREATE TABLE competitor_store (
  store_id INTEGER PRIMARY KEY AUTOINCREMENT,
  competitor_id INTEGER NOT NULL REFERENCES competitor(competitor_id),
  store_name TEXT NOT NULL,
  store_url TEXT,
  region TEXT NOT NULL DEFAULT 'Auckland',
  active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### CompetitorProduct

```sql
CREATE TABLE competitor_product (
  competitor_product_id INTEGER PRIMARY KEY AUTOINCREMENT,
  competitor_id INTEGER NOT NULL REFERENCES competitor(competitor_id),
  competitor_name TEXT NOT NULL,
  brand TEXT,
  egg_method TEXT DEFAULT 'free-range',
  size TEXT,
  pack_size INTEGER,
  mapped_sku TEXT,
  match_confidence REAL DEFAULT 0.0,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### CompetitorPriceObservation

```sql
CREATE TABLE competitor_price_observation (
  observation_id INTEGER PRIMARY KEY AUTOINCREMENT,
  competitor_product_id INTEGER NOT NULL REFERENCES competitor_product(competitor_product_id),
  store_id INTEGER REFERENCES competitor_store(store_id),
  scrape_run_id TEXT NOT NULL,
  observed_at TEXT NOT NULL DEFAULT (datetime('now')),
  price REAL,
  member_price REAL,
  unit_price REAL,
  stock_status TEXT DEFAULT 'unknown',
  promotion_label TEXT,
  source_url TEXT NOT NULL,
  screenshot_path TEXT,
  raw_json_snapshot TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

### ScrapeRun

```sql
CREATE TABLE scrape_run (
  scrape_run_id TEXT PRIMARY KEY,
  started_at TEXT NOT NULL DEFAULT (datetime('now')),
  completed_at TEXT,
  status TEXT NOT NULL DEFAULT 'running',
  total_observations INTEGER DEFAULT 0,
  errors INTEGER DEFAULT 0,
  notes TEXT
);
```

### ExceptionQueue

```sql
CREATE TABLE exception_queue (
  exception_id INTEGER PRIMARY KEY AUTOINCREMENT,
  competitor_product_id INTEGER REFERENCES competitor_product(competitor_product_id),
  scrape_run_id TEXT REFERENCES scrape_run(scrape_run_id),
  exception_type TEXT NOT NULL,
  description TEXT,
  raw_data TEXT,
  status TEXT NOT NULL DEFAULT 'pending',
  resolved_at TEXT,
  resolved_by TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

---

## Scope

### In Scope (MVP)

- Woolworths NZ online store scraping (Auckland stores)
- New World NZ online store scraping (Auckland stores)
- Free range eggs only (all pack sizes)
- Product normalization (brand, size, pack_size extraction from raw names)
- SKU matching with confidence scoring
- Exception queue for low-confidence matches
- Full observation persistence with audit trail (screenshots, raw JSON)
- Manual trigger (operator-initiated scrape runs)
- Price gap report (internal vs competitor by SKU)
- Market Opportunities Report (price gaps, margin risk, recommended actions)
- Export to Excel and PDF
- Lightweight web dashboard (3 screens)

### Out of Scope (MVP)

- Automated daily scheduling (post-MVP once stable)
- Non-Auckland regions
- Non-egg products
- Cage or barn eggs (free range only)
- Internal pricing engine modifications
- Customer-facing price displays
- Login-required or private API data
- Mobile app

### Stores

**Woolworths:** Greenlane, Hobsonville, Northwest, Three Kings, Newmarket, Warkworth

**New World:** Eastridge, Browns Bay, Albany, Devonport, Mt Roskill, Metro Auckland

### Product Ranges

| Range | Description |
|-------|-------------|
| Range 1 | 12-pack size 7 free range eggs |
| Range 2 | 12-pack mixed grade free range eggs |
| Range 3 | 18–20 pack size 6 free range eggs |
| Traditional | Traditional Free Range brand packs |

### Brands to Monitor

Otaika, Better Eggs, New Day, Maco, Woolworths (house brand), Natural, Good Farms, Pams, Coulston Hill, Frenz

---

## Legal & Technical Guardrails

**Hard rules — scraper MUST stop or skip if any of these are encountered:**

1. Login or account-only pages required
2. Private or undocumented APIs accessed
3. Account-specific pricing views
4. Bypassed anti-bot controls
5. Blocked paths or robots.txt violations

**Implementation:** Every scrape request checks guardrails before executing. Violations are logged and the target is skipped — never circumvented.

---

## Directory Structure

```
competitor-scraper/
├── src/
│   ├── config/
│   │   ├── database.js          Database connection + migrations
│   │   ├── stores.js            Auckland store definitions
│   │   ├── product-ranges.js    Product scope + brand list
│   │   └── guardrails.js        Legal/technical guardrail checks
│   ├── scraper/
│   │   ├── firecrawl-client.js  Firecrawl API wrapper
│   │   ├── woolworths.js        Woolworths-specific extraction
│   │   ├── newworld.js          New World-specific extraction
│   │   ├── playwright-fallback.js  Fallback scraper + screenshots
│   │   └── orchestrator.js      Run manager (scrape_run_id, flow control)
│   ├── mapper/
│   │   ├── normalizer.js        Raw product name → structured fields
│   │   ├── sku-matcher.js       Competitor product → internal SKU mapping
│   │   └── exception-queue.js   Low-confidence routing + management
│   ├── reports/
│   │   ├── price-gap.js         Internal vs competitor price table
│   │   ├── market-opportunities.js  Full market analysis report
│   │   └── export.js            Excel + PDF export utilities
│   ├── ui/
│   │   ├── index.html           App shell
│   │   ├── index.css            Design system (dark mode, premium)
│   │   ├── app.js               Router + state management
│   │   ├── pages/
│   │   │   ├── dashboard.js     Home — alerts + exceptions
│   │   │   ├── competitor-prices.js  Browse/filter observations
│   │   │   └── reports.js       Generate + view reports
│   │   └── components/
│   │       ├── price-table.js   Reusable price comparison table
│   │       ├── alert-card.js    Price alert display
│   │       └── filters.js       Store/brand/date filter controls
│   └── index.js                 CLI entry point (manual trigger)
├── data/
│   ├── competitor-scraper.db    SQLite database (gitignored)
│   └── screenshots/             Scrape evidence (gitignored)
├── migrations/
│   └── 001-initial-schema.sql   All table definitions
├── tests/
│   ├── scraper.test.js          Scraper unit tests
│   ├── normalizer.test.js       Normalizer tests
│   └── sku-matcher.test.js      Matcher tests
├── .env.example                 Environment template
├── package.json
└── README.md
```

---

## Phase Breakdown

### Phase 1: Foundation — Data Model & Configuration
**Goal:** Database schema, seed data, and all configuration in place.
**Build:** SQLite schema (all 6 tables), migration runner, store definitions, product range config, guardrails module, `.env` setup.
**Test:** Run migrations, verify table creation, insert seed competitors and stores.
**Outcome:** `npm run db:setup` creates a working database with Woolworths + New World competitors and all Auckland stores.

### Phase 2: Scraping Pipeline
**Goal:** Working Firecrawl + Playwright scrapers for both supermarket chains.
**Build:** Firecrawl client wrapper, Woolworths scraper, New World scraper, Playwright fallback with screenshot capture, scrape orchestrator.
**Test:** Run against live Woolworths and New World egg category pages, verify structured data extraction, capture screenshots.
**Outcome:** `npm run scrape` executes a full scrape run and returns structured product/price data.

### Phase 3: Normalization & Mapping
**Goal:** Raw scrape data transformed into structured observations with SKU matching.
**Build:** Product normalizer (parse brand, size, pack from raw names), SKU matcher with confidence scoring, exception queue for low-confidence.
**Test:** Feed real scrape output through normalizer, verify field extraction accuracy, test edge cases.
**Outcome:** Every scraped product is normalized and either matched to an internal SKU (with confidence) or routed to the exception queue.

### Phase 4: Observation Persistence
**Goal:** Full end-to-end pipeline from scrape trigger to database write.
**Build:** Wire orchestrator to create `scrape_run_id`, run scrapers, normalize, match, persist to `CompetitorPriceObservation`, attach screenshots + raw JSON.
**Test:** Run full pipeline, verify observations in database, check audit trail completeness.
**Outcome:** `npm run scrape` is the single command that does everything — scrape, normalize, match, persist, log.

### Phase 5: Reporting
**Goal:** Price gap analysis and Market Opportunities Report generation.
**Build:** Price gap table (internal vs competitor average by SKU), margin risk assessment, recommended actions engine, Excel + PDF export, email distribution.
**Test:** Generate report from real observation data, verify calculations, test export formats.
**Outcome:** `npm run report` generates the full Market Opportunities Report as Excel and PDF.

### Phase 6: App UI (MVP)
**Goal:** Lightweight web dashboard for browsing observations, managing exceptions, and viewing reports.
**Build:** Vite dev server, dark-mode design system, dashboard (alerts + exceptions), competitor prices screen (browse/filter), reports screen (generate/view).
**Test:** Manual testing of all screens, filter interactions, report generation from UI.
**Outcome:** `npm run dev` starts the web dashboard. Operator can browse prices, review exceptions, and generate reports.

---

## Success Metrics

| Metric | Target |
|--------|--------|
| Scrapers extract egg prices from both chains | ≥ 90% of listed free-range egg products captured |
| Product normalization accuracy | ≥ 85% correctly parsed brand + size + pack |
| SKU match confidence | ≥ 70% of products matched with confidence > 0.7 |
| Audit trail completeness | 100% of observations have source_url + raw_json |
| Screenshots captured | ≥ 95% of observations have screenshot evidence |
| Report generation | Market Opportunities Report renders correctly |
| End-to-end scrape time | < 10 minutes for full Auckland run |

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Supermarket website structure changes | Scraper breaks | Store raw snapshots + screenshots for reprocessing; modular scraper design |
| Firecrawl can't parse JS-heavy pages | Missing data | Playwright fallback with full browser rendering |
| Wrong competitor product match | Incorrect analysis | `match_confidence` scoring + ExceptionQueue for human review |
| Rate limiting / blocking | Scrape failures | Respectful request pacing, user-agent identification, skip on block |
| Internal SKU data unavailable | Can't compare | Standalone competitor tracking works without internal data; comparison is additive |

---

## Environment Variables

```env
# Firecrawl
FIRECRAWL_API_KEY=fc-your-key-here

# Database
DATABASE_PATH=./data/competitor-scraper.db

# Screenshots
SCREENSHOT_DIR=./data/screenshots

# Email (optional, for report distribution)
RESEND_API_KEY=re-your-key-here
REPORT_EMAIL_TO=operator@example.com

# Scraper behavior
SCRAPE_DELAY_MS=2000
MAX_RETRIES=3
```

---

*Generated by SEED (application type, standard rigor)*
*Ready for `/seed graduate` or `/seed launch`*
