# Roadmap: Competitor Scraper

## Overview

Build a competitor egg price scraping pipeline from database schema through a working web dashboard. Foundation first (data model + config), then scraping pipeline, normalization/mapping, full persistence, reporting, and finally the MVP UI.

**Design principle:** Dashboard UI is threaded through every phase. Each phase produces data structures and API contracts that the Phase 6 dashboard directly consumes. No retrofitting.

## Current Milestone

**v0.1 MVP** (v0.1.0)
Status: In Progress
Phases: 0 of 6 complete

---

## Phases

| Phase | Name | Plans | Status | Completed |
|-------|------|-------|--------|-----------|
| 1 | Foundation — Data Model & Configuration | 0/2 | Planning | — |
| 2 | Scraping Pipeline | 0/3 | Not Started | — |
| 3 | Normalization & Mapping | 0/2 | Not Started | — |
| 4 | Observation Persistence | 0/1 | Not Started | — |
| 5 | Reporting | 0/2 | Not Started | — |
| 6 | App UI (MVP) | 0/3 | Not Started | — |

---

## Phase Details

### Phase 1: Foundation — Data Model & Configuration

**Goal:** Database schema, seed data, and all configuration in place.
**Depends on:** Nothing (first phase)
**Research:** May need to confirm Woolworths/New World URL patterns in Phase 2

**Scope — Plan 01-01:**
- SQLite schema: **8 tables** (competitor, competitor_store, competitor_product, internal_sku, **internal_price_history**, scrape_run, competitor_price_observation, exception_queue)
- **5 indexes** (obs by scrape_run, product, observed_at; exc by scrape_run; price_history by sku+date)
- Migration runner (absolute DATABASE_PATH resolution)
- Seed: 2 competitors, 12 stores, 4 internal SKU stubs

**Forensic fixes baked in:**
- `observed_at` has no DEFAULT — scraper must supply HTTP response time
- `UNIQUE(competitor_product_id, store_id, scrape_run_id)` on competitor_price_observation
- `screenshot_path CHECK(...)` — rejects absolute paths at DB level
- `UNIQUE(competitor_id, competitor_name, pack_size)` on competitor_product
- `competitor_store.last_scraped_at` + `last_scrape_status` — store freshness tracking
- `internal_price_history` — dated price history for accurate Phase 5 gap analysis

**Scope — Plan 01-02:**
- Config modules: stores.js, product-ranges.js, guardrails.js
- `.env.example` + dotenv setup
- `SCREENSHOT_DIR` resolved to absolute at startup (not cwd-relative at call time)
- ExceptionQueue taxonomy constants exported (used by Phases 2–3):
  `MATCH_CONFIDENCE_LOW | PARSE_FAILED | PRICE_ANOMALY | JSON_INVALID | SITE_BLOCKED | SKU_REF_ERROR`
- Price anomaly thresholds config: `PRICE_MIN_NZD = 0.01`, `PRICE_MAX_NZD = 50.00`

**Dashboard impact (Phase 6 consumers):**
- `competitor_store.last_scraped_at` → store freshness widget
- `competitor_store.last_scrape_status` → store health status badges
- `internal_price_history` → price trend sparklines in reports
- `exception_queue.exception_type` taxonomy → filterable exception triage panel

**Plans:**
- [ ] 01-01: Database schema + migrations + seed data ← **READY TO EXECUTE (Plan written)**
- [ ] 01-02: Configuration modules (stores, product ranges, guardrails, env, taxonomy constants)

---

### Phase 2: Scraping Pipeline

**Goal:** Working Firecrawl + Playwright scrapers for both supermarket chains.
**Depends on:** Phase 1 (needs store config + guardrails + taxonomy constants)
**Research:** Required — inspect actual Woolworths/New World page structures before building

**Scope:**
- Firecrawl client wrapper (API key, error handling, rate limiting, `SCRAPE_DELAY_MS` pacing)
- Woolworths scraper (egg category page extraction)
- New World scraper (egg category page extraction)
- Playwright fallback with screenshot capture
- Scrape orchestrator (`scrape_run_id` = `crypto.randomUUID()` always)
- `competitor_store.last_scraped_at` + `last_scrape_status` updated after each store run

**Data integrity requirements:**
- `observed_at` stamped from HTTP response time, not DB write time
- `raw_json_snapshot`: validate with `JSON.parse()` before DB write — on failure, write `null` + route to ExceptionQueue(`JSON_INVALID`)
- Price anomaly check before every observation INSERT: price must be numeric, > `PRICE_MIN_NZD`, < `PRICE_MAX_NZD` — on failure, route to ExceptionQueue(`PRICE_ANOMALY`)
- `screenshot_path` written as relative path: `{run_id}/{filename}.png` — never absolute

**New intelligence:**
- New SKU detection: flag new `competitor_product` rows created this run (first appearance of brand/product) → tag for dashboard alert

**Plans:**
- [ ] 02-01: Firecrawl client + Woolworths scraper
- [ ] 02-02: New World scraper + Playwright fallback
- [ ] 02-03: Scrape orchestrator + screenshot capture + store status updates

**Dashboard impact (Phase 6 consumers):**
- `scrape_run` status column → live run progress display
- `competitor_store.last_scrape_status` → store health panel
- New SKU flag → "New products detected this week" alert card on dashboard

---

### Phase 3: Normalization & Mapping

**Goal:** Raw scrape data transformed into structured observations with SKU matching.
**Depends on:** Phase 2 (needs real scrape output to test against)
**Research:** Unlikely — product naming patterns visible from Phase 2 output

**Scope:**
- Product normalizer (parse brand, egg_method, size, pack_size from raw competitor names)
- SKU matcher with confidence scoring
- Exception queue routing (low-confidence → ExceptionQueue)

**Data integrity requirements:**
- SKU mapping via UPDATE — wrap in try-catch:
  - FK violation (invalid sku_id) → ExceptionQueue(`SKU_REF_ERROR`) with raw data
  - Low confidence (< 0.7) → ExceptionQueue(`MATCH_CONFIDENCE_LOW`) — do NOT silently leave mapped_sku null
- Use taxonomy constants from Plan 01-02 for all `exception_type` values (no raw strings)
- `INSERT OR IGNORE` on competitor_product writes — UNIQUE constraint prevents duplicates, use ignore semantics intentionally

**Plans:**
- [ ] 03-01: Product normalizer + SKU matcher
- [ ] 03-02: Exception queue management + confidence routing

**Dashboard impact (Phase 6 consumers):**
- `match_confidence` → confidence indicator in competitor prices table
- Exception taxonomy → type-filtered triage panel in dashboard
- Resolution flow → "resolved_at / resolved_by" audit display

---

### Phase 4: Observation Persistence

**Goal:** Full end-to-end pipeline from scrape trigger to database write.
**Depends on:** Phase 3 (needs normalizer + matcher)
**Research:** Unlikely

**Scope:**
- Wire orchestrator end-to-end: create run → scrape → normalize → match → persist → close run
- Attach screenshots + raw JSON to every observation where practical
- `npm run scrape` as single-command entry point
- Zod schemas validating ALL DB writes (not just observations — also scrape_run, competitor_product)

**Data integrity requirements (from handoff):**
- Full pipeline wrapped in transaction: if persistence fails mid-run, entire run rolls back
- `scrape_run.status` transitions: `running` → `completed` or `failed` (never left as 'running' after crash)
- `scrape_run.completed_at` stamped on finish, `errors` count accurate
- On exception: write to exception_queue WITHIN the same transaction as the failed observation

**Plans:**
- [ ] 04-01: End-to-end pipeline wiring + transaction wrapping + Zod validation

**Dashboard impact (Phase 6 consumers):**
- `scrape_run` completion data → run history table
- `scrape_run.errors` count → health badge on dashboard
- Transaction integrity → row counts in dashboard are always accurate (no partial runs)

---

### Phase 5: Reporting

**Goal:** Price gap analysis, Market Opportunities Report, and 5 new intelligence metrics.
**Depends on:** Phase 4 (needs real observation data)
**Research:** May need internal price data format; operator must have seeded internal_sku current_price

**Scope — Plan 05-01: Report logic**
- Price gap table: `internal_price_history` join (price as-of observation date, not current_price only)
- Margin risk assessment
- Recommended actions engine (hold / run special / raise / investigate / no action)
- Confidence scoring (observation completeness + match confidence)
- **5 new intelligence metrics:**

  **Metric 1 — OOS Rate**
  ```
  oos_rate = COUNT(stock_status = 'out_of_stock') / COUNT(*)
             WHERE product = X AND observed_at > 28 days ago
  ```
  *Use: high OOS at competitor = unmet demand = your sales opportunity.*

  **Metric 2 — Loyalty Price Dependency Score**
  ```
  loyalty_gap_pct = (price - member_price) / price * 100
                    WHERE member_price IS NOT NULL
  ```
  *Use: competitors with >15% loyalty gap appear more expensive to non-loyalty shoppers.*

  **Metric 3 — Competitive Price Band Width**
  ```
  band_width = MAX(price) - MIN(price)
               across all competitors + stores for same product range, same week
  ```
  *Use: wide band = price headroom; narrow band = commodity, compete on availability.*

  **Metric 4 — Promotion Frequency Index**
  ```
  promo_freq_pct = COUNT(promotion_label IS NOT NULL) / COUNT(*) * 100
                   per product per competitor, rolling 12 weeks
  ```
  *Use: >30% promo freq = product is effectively always discounted, their "special" is their real price.*

  **Metric 5 — New SKU Detection**
  ```
  new_skus = competitor_product rows WHERE created_at > last_week_run_start
  ```
  *Use: new competitor products = early warning of brand entry, range expansion, or private label launch.*

**Scope — Plan 05-02: Export + email**
- Excel export (ExcelJS) — tabbed: Price Gap, Market Opportunities, OOS Heatmap, New SKUs
- PDF export (@react-pdf/renderer) — executive summary view
- Email distribution (Resend):
  - `REPORT_EMAIL_ALLOWLIST` env var — comma-separated approved recipients (no open distribution)
  - `REPORT_EMAIL_DRY_RUN=true` env var — logs email content without sending (safe testing)
  - Send only when `REPORT_EMAIL_DRY_RUN` is absent or false

**Plans:**
- [ ] 05-01: Price gap + market opportunities report logic + 5 new metrics
- [ ] 05-02: Excel + PDF export + email distribution with allowlist + dry-run flag

**Dashboard impact (Phase 6 consumers):**
- OOS Rate → heatmap overlay on competitor prices page
- Loyalty gap → inline indicator in price table
- Band width → range pricing context in report page
- Promo frequency → "permanent markdown" badge on products
- New SKU alert → dashboard card "N new competitor products this week"

---

### Phase 6: App UI (MVP)

**Goal:** Lightweight web dashboard that surfaces all intelligence from Phases 1–5.
**Depends on:** Phase 5 (reports + metrics must exist to display)
**Research:** Unlikely

**Scope — Plan 06-01: Vite setup + design system + dashboard**
- Vite dev server setup (vanilla JS, ES modules)
- Dark-mode premium design system (CSS custom properties, typography, spacing scale)
- Dashboard page:
  - Scrape run status card (last run time, status, observation count, error count)
  - Store freshness grid (12 stores, last_scraped_at, status badge: fresh/stale/never)
  - New SKU alert card ("N new competitor products detected this week")
  - Exception queue summary (count by exception_type, link to triage)
  - Price alerts (biggest price movements since last run)

**Scope — Plan 06-02: Competitor Prices page**
- Browse all competitor_price_observation rows
- Filters: store, brand, product range, date range, stock status
- Inline indicators:
  - Match confidence badge (green ≥0.7, amber 0.4–0.7, red <0.4)
  - Loyalty gap % (if member_price captured)
  - Promotion label badge
  - OOS badge
- Column: unit_price (per-egg comparison across pack sizes)

**Scope — Plan 06-03: Reports page + Exception triage**
- Reports page:
  - Generate Market Opportunities Report (triggers npm run report equivalent via API)
  - Display last generated report summary inline
  - Download links: Excel, PDF
  - Metric cards: OOS Rate, Band Width, Promo Frequency, Loyalty Gap by range
- Exception triage panel:
  - Filter by exception_type (uses taxonomy from Plan 01-02)
  - Quick-resolve: mark resolved + set resolved_by
  - Raw data preview for debugging

**Plans:**
- [ ] 06-01: Vite setup + design system + dashboard
- [ ] 06-02: Competitor Prices page + filters + inline indicators
- [ ] 06-03: Reports page + exception triage

---

## Post-MVP Backlog (Innovations — data already captured, compute is additive)

These require no additional scraping. All inputs already exist in the MVP schema.

| Innovation | What It Does | Input Data | Priority |
|------------|-------------|------------|----------|
| Promotional Calendar | Predict when competitors will next discount by reconstructing weekly/fortnightly special patterns | promotion_label × observed_at history | High |
| Brand Availability Heatmap | Show which brands are Woolworths-exclusive vs New World-exclusive vs shared (pricing power signal) | competitor_product × competitor_id | High |
| Shelf Presence Score | Track brand SKU count per scrape run over time — declining count = brand exiting market | competitor_product COUNT × scrape_run_id | Medium |
| Price Velocity Alerting | Week-over-week price change per product, auto-alert when competitor moves > 5% | competitor_price_observation weekly rollup | High |
| Normalizer Rule Table | DB-backed mapping rules that self-learn from resolved ExceptionQueue items | exception_queue resolutions | Medium |

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
| OOS Rate accuracy | Matches manual spot-check of competitor sites |
| Exception queue resolution | < 48h average time to resolve low-confidence matches |

---

*Roadmap updated: 2026-05-04*
*Incorporates: forensic review fixes, 5 improvements, 5 innovations backlog, 5 new intelligence metrics, dashboard threading*
