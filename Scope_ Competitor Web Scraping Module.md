## Scope: Competitor Web Scraping Module

This section extracts and restructures only the parts of your spec that relate to competitor web scraping and downstream use of that data, as a Markdown guide for app development.[^1]

***

## High-level Goal

Build a controlled module that:

- Tracks public supermarket competitor egg prices over time for Auckland.
- Uses only public, browser-visible information from Woolworths and New World sites.
- Feeds competitor observations into a `CompetitorPriceObservation` table.
- Supports a basic Market Opportunities Report comparing internal prices vs competitors.[^1]

***

## Price Survey Overview

- **Purpose**: Create a database of weekly New Zealand supermarket egg prices for market evaluation.[^1]
- **Frequency**: Weekly survey runs (or manually triggered) appended to the master database.[^1]
- **Geography**:
    - Market limited to **Auckland City region** supermarkets.[^1]
- **Sources**:
    - Woolworths shopping website (online store pages).
    - New World shopping website (online store pages).[^1]
- **Store list (examples from spec)**:
    - **Woolworths**: Greenlane, Hobsonville, Northwest, Three Kings, Newmarket, Warkworth.[^1]
    - **New World**: Eastridge, Browns Bay, Albany, Devonport, Mt Roskill, Metro Auckland.[^1]
- **Product scope**:
    - Only **free range eggs**.
    - Pack ranges (examples, not exhaustive):
        - Range 1: 12-pack size 7 free range eggs or specified 12-pack FR packs.
        - Range 2: 12-pack mixed grade free range eggs or specified 12-pack mixed FR packs.
        - Range 3: 18–20 pack size 6 free range eggs or specified pack descriptions.
    - Include **Traditional Free Range** brand packs in addition to ranges above.[^1]
- **Key competitor brands to monitor** (examples):
    - Otaika, Better Eggs, New Day, Maco, Woolworths house brand, Natural, Good Farms, Pams, Coulston Hill, Frenz.[^1]

***

## System Architecture (Scraping-related)

- **Scraping / extraction stack**:
    - **Primary**: Firecrawl for structured public extraction.
    - **Fallback**: Playwright for browser tests and screenshots (and when Firecrawl cannot parse pages cleanly).[^1]
- **Data source layer (for scrapes)**:
    - Public Woolworths and New World shopping pages.
    - No logged-in pages, private APIs, or blocked paths.[^1]
- **Prototype and production data**:
    - **Prototype database**: SQLite for local MVP.
    - **Production database**: PostgreSQL for reliability, access control, and multi-user support.[^1]

***

## Core Data Model (Competitor Side)

Relevant tables for competitor scraping and mapping:[^1]

- **Competitor**
    - Purpose: List of competitors.
    - Key fields:
        - `competitor_id`
        - `name`
        - `region`
        - `website`
- **CompetitorProduct**
    - Purpose: Map competitor products to internal SKUs with confidence.
    - Key fields:
        - `competitor_product_id`
        - `competitor_id`
        - `competitor_name` (raw product name from website)
        - `mapped_sku` (internal SKU)
        - `match_confidence`
- **CompetitorPriceObservation**
    - Purpose: Dated competitor price record.
    - Key fields:
        - `observation_id`
        - `competitor_product_id`
        - `observed_at`
        - `price`
        - `member_price`
        - `unit_price`
        - `stock_status`
        - `source_url`[^1]

***

## Competitor Price Capture: What It Does

- Tracks **public competitor price observations** over time.
- Does **not** replace internal pricing decisions; it supplies inputs for analysis.[^1]
- Supports multi-competitor, multi-store tracking, with later comparison to internal prices, sales velocity, and stock.[^1]

***

## Capture Fields for Each Observation

When the scraper runs for a product in a specific store, the system should capture at least these fields:[^1]

- **Identification and mapping**
    - `competitor` (e.g., Woolworths, New World)
    - `product_name` (raw from website)
    - `brand`
    - `egg_method` (e.g., free range, barn)
    - `size` (e.g., 6, 7, 8)
    - `pack_size` (e.g., 12 pack, 18 pack, 20 pack)
- **Pricing**
    - `price` (displayed normal price)
    - `member_price` (if a public “club card” style price is shown)
    - `unit_price` (price per egg or per 100g where available)
- **Status and promotion**
    - `stock_status` (e.g., in stock / out of stock / low stock if visible)
    - `promotion_label` (e.g., “Special”, “Club Deal”)
- **Audit and provenance**
    - `source_url` (exact page URL)
    - `observed_datetime`
    - `scrape_run_id` (identifies which run produced these rows)
    - `screenshot_path` (proof if prices are disputed)
    - `raw_json_snapshot` (structured raw data for reprocessing when mapping rules change)[^1]

These fields should be persisted to the `CompetitorPriceObservation` table and linked via `competitor_product_id` to the `CompetitorProduct` row.[^1]

***

## Legal / Technical Guardrails for Scraping

The scraper must **stop or skip** a target if any of the following are required to access the data:[^1]

- Login or account-only pages.
- Private or undocumented APIs.
- Account pages or user-specific pricing views.
- Bypassed controls or robots protections.
- Blocked paths or anti-bot circumvention.

Rule: **Use public, browser-visible information only unless there is explicit legal and business approval**.[^1]

***

## Integration with Market Opportunities Report

The competitor scraping feeds into the Market Opportunities Report as one of several inputs:[^1]

- **Inputs relevant here**:
    - Internal product master: `Product` table.
    - Internal current prices: `ProductPrice`, `CustomerPriceAgreement`, `Promotion`.
    - Competitor prices: `CompetitorPriceObservation`.
    - Margin thresholds and specials rules: owner-defined planning metrics.[^1]
- **Key report sections affected by competitor data**:
    - Price gap table: internal price vs competitor average by SKU.
    - Margin risk: specials or competitor pressure that may erode margin.
    - Recommended actions: hold price, run special, raise price, investigate, or no action.
    - Confidence score: influenced by completeness of competitor observations and match confidence.[^1]

***

## App Screens Relevant to Competitor Scraping

For the MVP, competitor scraping touches mainly these screens:[^1]

- **Home dashboard**
    - Shows price alerts and competitor-related exceptions.
- **Competitor prices**
    - Displays latest public competitor observations.
    - Likely filters: store, brand, SKU, date range.
- **Reports**
    - Generates competitor-related weekly reports and the Market Opportunities Report.[^1]

***

## MVP Acceptance Criteria (Scraper-related)

The following must be true at minimum for the competitor module:[^1]

- Each competitor price observation includes:
    - `date`
    - `source_url`
    - raw snapshot (e.g., `raw_json_snapshot`)
    - match confidence via mapping to internal SKU.
- Scraper failures or mismatches are visible:
    - Use `ExceptionQueue` for wrong or uncertain matches (through `match_confidence`).[^1]
- Scraper resilience:
    - Raw snapshots, screenshots, and validation results are stored so that scraper breakage can be debugged later.[^1]

***

## Open Business Decisions (Scraper Frequency)

One decision directly relevant to scraping:[^1]

- **Competitor frequency**:
    - Start with a **manual run button** (operator-triggered).
    - Later add **daily automated runs** once stable.

***

## Scraper-related Risks and Controls

Key risks and controls for this module:[^1]

- **Scraper breaks**
    - Control: Store raw snapshots, screenshots, and validation results to allow reprocessing and debugging.
- **Wrong competitor match**
    - Control: Use `match_confidence` and send low-confidence rows to `ExceptionQueue` for human review.[^1]

***

## How This Guides App Development (Competitor Module)

Concretely for the dev team, the competitor web scraping portion of the app should:

1. **Implement scraping pipeline**
    - Use Firecrawl as the primary extractor on Woolworths and New World product-listing and product-detail pages for the specified stores, restricted to free range egg packs in the defined ranges.
    - Use Playwright when pages fail structured extraction or when screenshots are required for evidence.[^1]
2. **Normalize and map product data**
    - Map raw competitor products into `CompetitorProduct`, connecting them to internal SKUs with a `match_confidence`.
    - Send low-confidence mappings to `ExceptionQueue` for manual review.[^1]
3. **Persist observations**
    - For each run, create a `scrape_run_id` and write rows into `CompetitorPriceObservation` including all capture fields and links to `CompetitorProduct`.
    - Attach `screenshot_path` and `raw_json_snapshot` for every observation where practical.[^1]
4. **Expose data in the app**
    - Build a **Competitor prices** screen to browse and filter observations.
    - Provide basic visualisation of price gaps (this can be simple tables in MVP; deeper analytics live in the Market Opportunities Report).[^1]
5. **Respect guardrails**
    - Ensure the scraper never logs in, uses private APIs, or bypasses protections.
    - Treat all competitor data as public observational data with strong audit trails.[^1]

***

To move forward efficiently: which of these do you want the dev team to implement first—scraping pipeline, data model tables, or the Competitor prices screen UI?

<div align="center">⁂</div>

[^1]: 01_Project_Build_Specification-WIP.docx

