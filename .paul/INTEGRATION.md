# Integration Plan: Forensic Fixes + Improvements + Innovations

**Created:** 2026-05-04
**Status:** Pre-execution — all items mapped, Plan 01-01 updated and ready to execute

This document is the canonical reference for all items surfaced during pre-execution forensic review. Every item is assigned a source, phase, and plan. Nothing is lost.

---

## Quick Reference: All Items by Status

| ID | Item | Type | Phase | Plan | Status |
|----|------|------|-------|------|--------|
| F1 | Remove `observed_at` DEFAULT | Forensic Fix | 1 | 01-01 | ✓ Baked in |
| F2 | UNIQUE on competitor_price_observation | Forensic Fix | 1 | 01-01 | ✓ Baked in |
| F3 | SKU FK error → ExceptionQueue | Forensic Fix | 3 | 03-02 | Pending |
| F4 | JSON.parse validation before write | Forensic Fix | 2 | 02-03 | Pending |
| F5 | CHECK constraint on screenshot_path | Forensic Fix | 1 | 01-01 | ✓ Baked in |
| I1 | internal_price_history table | Improvement | 1 | 01-01 | ✓ Baked in |
| I2 | UNIQUE on competitor_product | Improvement | 1 | 01-01 | ✓ Baked in |
| I3 | last_scraped_at + last_scrape_status | Improvement | 1 | 01-01 | ✓ Baked in |
| I4 | ExceptionQueue taxonomy constants | Improvement | 1 | 01-02 | Pending |
| I5 | Pre-write price anomaly check | Improvement | 2 | 02-03 | Pending |
| HO1 | SCREENSHOT_DIR absolute resolution | Handoff | 1 | 01-02 | Pending |
| HO2 | Phase 4 transaction wrapping | Handoff | 4 | 04-01 | Pending |
| HO3 | Email allowlist + dry-run flag | Handoff | 5 | 05-02 | Pending |
| M1 | OOS Rate metric | New Metric | 5 | 05-01 | Pending |
| M2 | Loyalty Price Dependency Score | New Metric | 5 | 05-01 | Pending |
| M3 | Competitive Price Band Width | New Metric | 5 | 05-01 | Pending |
| M4 | Promotion Frequency Index | New Metric | 5 | 05-01 | Pending |
| M5 | New SKU Detection Alert | New Metric | 2+5 | 02-03, 05-01 | Pending |
| IN1 | Promotional Calendar | Innovation | Post-MVP | — | Backlog |
| IN2 | Brand Availability Heatmap | Innovation | Post-MVP | — | Backlog |
| IN3 | Shelf Presence Score | Innovation | Post-MVP | — | Backlog |
| IN4 | Price Velocity Alerting | Innovation | Post-MVP | — | Backlog |
| IN5 | Normalizer Rule Table | Innovation | Post-MVP | — | Backlog |

---

## Forensic Fixes (F-series)

### F1 — Remove `observed_at` DEFAULT
**Problem:** `observed_at DEFAULT (datetime('now'))` captures DB write time, not scrape time. Batch processing can lag minutes. Firecrawl cached responses could record wrong date.
**Fix:** Column is `observed_at TEXT NOT NULL` with no default. Scraper stamps value at HTTP response time.
**Assigned to:** Plan 01-01 (schema) ✓ + Plan 02-03 (scraper stamps value)
**Dashboard relevance:** Price timeline accuracy on Competitor Prices page depends on this.

### F2 — UNIQUE constraint on competitor_price_observation
**Problem:** No duplicate guard. Re-running a failed scrape doubles observation rows. Report averages include duplicates.
**Fix:** `UNIQUE(competitor_product_id, store_id, scrape_run_id)` — idempotent re-runs safe via `INSERT OR IGNORE`.
**Assigned to:** Plan 01-01 ✓
**Dashboard relevance:** Row counts and price averages on dashboard are accurate.

### F3 — SKU mapping FK error → ExceptionQueue
**Problem:** Phase 3 normalizer sets `mapped_sku` via UPDATE. If sku_id doesn't exist in `internal_sku`, FK violation silently leaves mapped_sku null with no operator notification.
**Fix:** Wrap all `mapped_sku` UPDATEs in try-catch. FK violation → ExceptionQueue(`SKU_REF_ERROR`).
**Assigned to:** Plan 03-02
**Dashboard relevance:** Exception triage panel captures these for operator resolution.

### F4 — JSON.parse validation before raw_json_snapshot write
**Problem:** SQLite accepts any TEXT. Truncated/broken Firecrawl responses silently corrupt the audit trail — the main purpose of raw_json_snapshot is reprocessing, which requires valid JSON.
**Fix:** `JSON.parse(raw_json_snapshot)` before every INSERT. On failure: write `null` to field, create ExceptionQueue(`JSON_INVALID`) with raw string.
**Assigned to:** Plan 02-03 (orchestrator, before persistence)
**Dashboard relevance:** Operator can see JSON failures in exception triage without data appearing silently broken.

### F5 — CHECK constraint on screenshot_path
**Problem:** SQL comment documents relative path requirement, but nothing enforces it. Absolute path (Windows `C:\...`, Linux `/...`) causes cross-platform resolution failures in Phase 6 UI.
**Fix:** `screenshot_path TEXT CHECK(screenshot_path IS NULL OR (screenshot_path NOT LIKE '/%' AND screenshot_path NOT LIKE '_:\%'))`
**Assigned to:** Plan 01-01 ✓
**Dashboard relevance:** Phase 6 screenshot display resolves `SCREENSHOT_DIR + path` — absolute paths in DB would double-resolve or fail.

---

## Improvements (I-series)

### I1 — internal_price_history table
**Problem:** `internal_sku.current_price` is a single value. When operator updates their price, historical gap analysis loses what the gap was last week/month. Reports become inaccurate retrospectively.
**Fix:** New `internal_price_history (history_id, sku_id, price, effective_from, notes)` table. Phase 5 report joins to price WHERE `effective_from <= observation_date ORDER BY effective_from DESC LIMIT 1`.
**Assigned to:** Plan 01-01 (table creation) ✓ + Plan 05-01 (query)
**Dashboard relevance:** Price trend sparklines in Reports page use this history.

### I2 — UNIQUE constraint on competitor_product
**Problem:** Two scrape runs seeing the same product create duplicate `competitor_product` rows. Mapper creates ambiguous duplicate SKU matches. Report joins return doubled rows.
**Fix:** `UNIQUE(competitor_id, competitor_name, pack_size)` — normalizer uses `INSERT OR IGNORE`, Phase 3 mapper operates on the canonical row.
**Assigned to:** Plan 01-01 ✓
**Dashboard relevance:** No duplicate products appearing in Competitor Prices page.

### I3 — last_scraped_at + last_scrape_status on competitor_store
**Problem:** No way to know when each of the 12 stores was last scraped. A silently failing store (Albany New World fails 3 weeks running) generates no alert.
**Fix:** Add `last_scraped_at TEXT` and `last_scrape_status TEXT DEFAULT 'never'` to competitor_store. Orchestrator updates both after each store attempt.
**Assigned to:** Plan 01-01 (columns) ✓ + Plan 02-03 (orchestrator updates)
**Dashboard relevance:** Store freshness grid on dashboard (12 tiles, colour-coded: green/amber/red by age and status).

### I4 — ExceptionQueue taxonomy constants
**Problem:** `exception_type TEXT NOT NULL` accepts any string. Operators can't filter, UI can't build type-specific triage, and automation can't auto-resolve by category.
**Fix:** Export named constants from Plan 01-02 config:
```js
export const ExceptionType = {
  MATCH_CONFIDENCE_LOW: 'MATCH_CONFIDENCE_LOW',
  PARSE_FAILED: 'PARSE_FAILED',
  PRICE_ANOMALY: 'PRICE_ANOMALY',
  JSON_INVALID: 'JSON_INVALID',
  SITE_BLOCKED: 'SITE_BLOCKED',
  SKU_REF_ERROR: 'SKU_REF_ERROR'
};
```
All code uses these constants, never raw strings.
**Assigned to:** Plan 01-02
**Dashboard relevance:** Exception triage panel in Phase 6 uses these exact values for filter tabs.

### I5 — Pre-write price anomaly validation
**Problem:** Firecrawl parse failures produce `price = 0.0`, `price = 999.99`, or `price = null`. These silently enter DB and corrupt report averages.
**Fix:** Before every `competitor_price_observation` INSERT: validate `price > PRICE_MIN_NZD (0.01)` AND `price < PRICE_MAX_NZD (50.00)`. On failure → ExceptionQueue(`PRICE_ANOMALY`), do NOT write observation.
**Assigned to:** Plan 01-02 (thresholds config) + Plan 02-03 (validation at persistence point)
**Dashboard relevance:** Price anomaly count visible in exception summary on dashboard.

---

## Handoff Items (HO-series)

### HO1 — SCREENSHOT_DIR absolute resolution
**From handoff:** "SCREENSHOT_DIR absolute resolution → Plan 01-02"
**Implementation:** In stores/config init, resolve `process.env.SCREENSHOT_DIR` to absolute at startup via `path.resolve()`. Fail fast if env var missing (not a silent undefined). Pass resolved path through to orchestrator.
**Assigned to:** Plan 01-02

### HO2 — Phase 4 transaction wrapping
**From handoff:** "Phase 4 transaction wrapping → Plan 04-01"
**Implementation:** Full scrape pipeline (scrape → normalize → match → persist) wrapped in a single better-sqlite3 transaction. On any failure: transaction rolls back, `scrape_run.status = 'failed'`, exception logged. No partial run rows in DB.
**Assigned to:** Plan 04-01

### HO3 — Email allowlist + dry-run flag
**From handoff:** "Email allowlist/dry-run → Plan 05-02"
**Implementation:**
- `REPORT_EMAIL_ALLOWLIST` env var: comma-separated list. Resend `to:` field only draws from this list.
- `REPORT_EMAIL_DRY_RUN=true`: logs full email payload to console, does not call Resend API.
**Assigned to:** Plan 05-02

---

## New Intelligence Metrics (M-series)

All metrics derived from data already captured — no extra scraping required.

### M1 — OOS Rate (Out-of-Stock Frequency)
**Query:** `COUNT(stock_status = 'out_of_stock') / COUNT(*) WHERE product = X AND observed_at > 28 days ago`
**Business use:** High OOS at competitor = unmet demand. Opportunity to position your supply directly against that gap.
**Phase 5 placement:** Market Opportunities Report — "Demand Gap" section.
**Dashboard:** OOS heatmap overlay on Competitor Prices page.

### M2 — Loyalty Price Dependency Score
**Query:** `(price - member_price) / price * 100 WHERE member_price IS NOT NULL`
**Business use:** Competitor showing >15% loyalty gap means non-loyalty customers overpay. Your single transparent price can appear fairer. Positioning asset.
**Phase 5 placement:** Market Opportunities Report — per-product loyalty gap column.
**Dashboard:** Loyalty gap % badge in Competitor Prices table.

### M3 — Competitive Price Band Width
**Query:** `MAX(price) - MIN(price)` across all competitors + stores for same product range, same week
**Business use:** Wide band (>$3) = price-insensitive segment → you have pricing headroom. Narrow band (<$1) = commodity → compete on availability/quality.
**Phase 5 placement:** Price Gap Report — "Range Analysis" section.
**Dashboard:** Band width indicator in Reports page metric cards.

### M4 — Promotion Frequency Index
**Query:** `COUNT(promotion_label IS NOT NULL) / COUNT(*) * 100` per product per competitor, rolling 12 weeks
**Business use:** >30% promo frequency = product effectively always discounted. Competitor's "special" IS their real price. You can match their "special" price as your regular price without margin damage.
**Phase 5 placement:** Market Opportunities Report — "Permanent Markdown Detection" column.
**Dashboard:** "Permanent markdown" badge on products in Competitor Prices page.

### M5 — New SKU Detection Alert
**Query:** `competitor_product rows WHERE created_at > last_week_run_start`
**Business use:** New brand/product appearing for first time = competitor expanding range, new NZ supplier, or private label launch. 1–2 week head start to respond.
**Phase assignment:** Flagged in Phase 2 (orchestrator detects new rows), surfaced in Phase 5 report + Phase 6 dashboard.
**Dashboard:** "N new competitor products this week" alert card on home dashboard.

---

## Post-MVP Innovation Backlog (IN-series)

All require no new scraping infrastructure — computed from existing MVP data.

### IN1 — Promotional Calendar Reconstruction
**What:** Aggregate promotion_label frequency by product by week-of-year over 3+ months. Reconstruct competitor special cycle (weekly? fortnightly? seasonal?). Predict next discount window.
**Strategic use:** Pre-empt competitor's next special with your own promotion timed 3–5 days earlier.
**Needs:** 3+ months of scrape history.

### IN2 — Brand Availability Heatmap
**What:** For each brand, show which chains carry it: Woolworths-only | New World-only | Both. Update weekly from competitor_product data.
**Strategic use:** Exclusive brands have pricing power (no cross-shop comparison). Shared brands race to the bottom. Tells you which brands to undercut vs which to position as alternatives.
**Needs:** 1 scrape run minimum.

### IN3 — Shelf Presence Score
**What:** `COUNT(competitor_product) WHERE brand = X AND scrape_run_id = Y` over time. Alert when brand drops >20% SKU count over 4 weeks.
**Strategic use:** Brand reducing shelf presence = exiting category. Fill the gap before competitor does.
**Needs:** 4+ weeks of scrape history.

### IN4 — Price Velocity Alerting
**What:** Week-over-week: `(this_week_avg - last_week_avg) / last_week_avg * 100` per product. Auto-alert: competitor rising >5% = hold/raise your price; falling >5% = competitive pressure.
**Strategic use:** Turns raw price history into decision triggers. No manual scanning needed.
**Needs:** 2+ weeks of scrape history.

### IN5 — Normalizer Rule Table
**What:** DB-backed mapping rules `(pattern, field, value)`. When operator resolves ExceptionQueue item, extract the resolution as a new rule. Next run, same pattern resolves automatically.
**Strategic use:** Exception queue shrinks over time without code changes. System learns from operator corrections.
**Needs:** ExceptionQueue taxonomy from Plan 01-02 + operator resolution workflow from Phase 6.

---

## Schema Summary (Post-Forensic)

**8 tables (was 6 in original spec, 7 in initial plan):**
1. `competitor`
2. `competitor_store` — added: last_scraped_at, last_scrape_status
3. `internal_sku`
4. `internal_price_history` — NEW
5. `competitor_product` — added: UNIQUE(competitor_id, competitor_name, pack_size)
6. `scrape_run`
7. `competitor_price_observation` — changed: observed_at no DEFAULT, added UNIQUE, screenshot_path CHECK
8. `exception_queue` — added: taxonomy values documented in comment

**5 indexes (was 4):**
- idx_obs_scrape_run, idx_obs_product, idx_obs_observed_at (original 3)
- idx_exc_scrape_run (original 4)
- idx_price_history_sku (NEW)

---

## .paul Directory Note

PAUL is initialized at `apps/competitor-scraper/` (the project root for this app), not the workspace root. The workspace root (`Competitor Analyzer/`) is a monorepo container. Run PAUL commands from within `apps/competitor-scraper/` or use paths relative to it. This is correct PAUL framework behaviour — PAUL tracks one project per `.paul/` directory.

---

*Integration plan compiled: 2026-05-04*
*Sources: Pre-execution forensic review × 2 sessions, HANDOFF-2026-05-04.md*
