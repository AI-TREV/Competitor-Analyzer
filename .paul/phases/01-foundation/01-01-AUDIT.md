# Enterprise Plan Audit Report

**Plan:** `.paul/phases/01-foundation/01-01-PLAN.md`
**Audited:** 2026-05-04
**Verdict:** Conditionally Acceptable — 4 must-have issues found and applied; 3 strongly-recommended improvements applied; 5 deferred items noted.

---

## 1. Executive Verdict

**Conditionally Acceptable.** The plan demonstrates solid architectural thinking — the 8-table schema is well-reasoned, the forensic review that preceded it shows genuine rigour, and the verification checklist is unusually thorough. However, four issues would cause the build to fail completely as written, and they are not edge cases. The plan was authored as if `apps/competitor-scraper/package.json` already exists (it does not), omits the `npm install` step that every downstream verification depends on, does not anchor the migration path to `__dirname` (making CWD-sensitive failures near-certain), and has a NULL-bypass in the UNIQUE constraint that silently defeats the core duplicate-prevention mechanism.

These are not architectural gaps — they are execution gaps. Applied. The plan is now safe to run.

Would I sign my name to this system after the applied fixes? Yes, for a Phase 1 foundation build.

---

## 2. What Is Solid (Do Not Change)

**8-table schema design and FK ordering.** Tables are created in correct FK-dependency order (competitor → competitor_store → internal_sku → internal_price_history → competitor_product → scrape_run → competitor_price_observation → exception_queue). The scrape_run table appearing before observations is critical and correct.

**`observed_at` has no DEFAULT.** Forcing the scraper to supply the actual HTTP response time rather than database insertion time is a deliberate and correct audit trail decision. The comment documents the intent. Do not add a DEFAULT here.

**`screenshot_path` CHECK constraint.** Enforcing relative-only paths at the database layer is the right place for this invariant. The constraint correctly rejects both Unix (`/`) and Windows (`C:\`) absolute paths. The comment documenting the resolve-at-read-time pattern is valuable.

**`exception_queue.scrape_run_id` ON DELETE SET NULL.** Correct. Preserves exception records when scrape runs are cleaned up. The FK semantics match the business intent: exceptions are evidence of what happened during a run, not dependent on the run's continued existence.

**`internal_price_history` as a separate table.** Correctly identified that storing only `current_price` in `internal_sku` would lose history when the operator updates their pricing. The dated history table enables the Phase 5 "price as-of date" gap analysis. Good architectural foresight.

**`scrape_run_id` as UUID TEXT with comment.** Documenting `crypto.randomUUID()` requirement in the SQL comment prevents sequential ID anti-patterns in Phase 2.

**Idempotent seed using `INSERT OR IGNORE`.** Correct pattern. Seed can be re-run safely. Seeding in FK-dependency order (competitors → stores → internal_sku) is correct.

**Task ordering (1 → 2 → 3).** Schema before connection, connection before seed. Task 3 imports from Task 2's output. Dependency order is correct.

**Absolute DB path resolution via `path.resolve()`.** Correctly ensures the database file lands at a deterministic path regardless of CWD at startup.

---

## 3. Enterprise Gaps Identified

### G1 — `apps/competitor-scraper/package.json` doesn't exist (MUST-HAVE)
The plan's Task 1 says "Add `better-sqlite3` to dependencies in `apps/competitor-scraper/package.json`" — implying the file exists. `ls apps/competitor-scraper/` shows only `PLANNING.md` and `README.md`. The file must be CREATED. More critically, the plan never specified `"type": "module"` in that file. `database.js` and `seed.js` both use ES module syntax (`import`, `export`). Without `"type": "module"`, Node.js treats `.js` files as CommonJS and throws `SyntaxError: Cannot use import statement in a module` on the very first line of both files. Every verification step in this plan would fail.

### G2 — `npm install` never runs (MUST-HAVE)
Task 1 writes `better-sqlite3` into the package.json but no step runs `npm install`. There is no `node_modules/` in `apps/competitor-scraper/`. Running `database.js migrate` would throw `Error [ERR_MODULE_NOT_FOUND]: Cannot find package 'better-sqlite3'` before a single line of business logic executes.

### G3 — Migration path is CWD-sensitive (MUST-HAVE)
Task 2 says "Read all `.sql` files from `migrations/` in sorted filename order" with no path resolution specified. If implemented as `fs.readdirSync('./migrations')` or `'migrations/'`, the path resolves relative to `process.cwd()`. Running `node apps/competitor-scraper/src/config/database.js migrate` from the workspace root would look for `./migrations/` in the workspace root — not `apps/competitor-scraper/migrations/`. The path must be anchored with `path.join(path.dirname(fileURLToPath(import.meta.url)), '../../migrations')`.

### G4 — NULL store_id silently bypasses UNIQUE constraint (MUST-HAVE)
`competitor_price_observation.store_id` is nullable in the plan. In SQLite, NULL values are each considered distinct in UNIQUE constraints — `NULL ≠ NULL`. This means two observation rows with `store_id = NULL`, the same `competitor_product_id`, and the same `scrape_run_id` both satisfy `UNIQUE(competitor_product_id, store_id, scrape_run_id)` and are inserted without error. The entire duplicate-prevention mechanism fails silently for any observation where store is not set. Since every observation in this system comes from scraping a specific store's page, `store_id` should be NOT NULL.

### G5 — Status fields accept arbitrary text values (STRONGLY RECOMMENDED)
`scrape_run.status`, `exception_queue.status`, and `competitor_store.last_scrape_status` are TEXT fields with no CHECK constraints. A typo — `'complete'` instead of `'completed'`, `'resolve'` instead of `'resolved'` — is silently accepted. Dashboard queries that filter on `status = 'completed'` would miss rows with `status = 'complete'`. Given Phase 6 will build a UI reading these fields, unvalidated enum values are a latent display bug.

### G6 — UNIQUE(competitor_id, competitor_name, pack_size) NULL behaviour undocumented (STRONGLY RECOMMENDED)
Same SQLite NULL uniqueness issue as G4, but on `competitor_product`. Two rows with `pack_size = NULL`, same `competitor_id`, same `competitor_name` will both be inserted without error. Phase 2/3 scraping products whose pack size cannot be parsed from the product name (e.g. "Traditional Free Range Eggs") could accumulate duplicate `competitor_product` rows across runs. The constraint behaviour must be documented so the Phase 2/3 normalizer accounts for it — either by mapping null-pack-size products to a sentinel value or by using a separate deduplication key.

---

## 4. Upgrades Applied to Plan

### Must-Have (Release-Blocking)

| # | Finding | Plan Section Modified | Change Applied |
|---|---------|----------------------|----------------|
| MH-1 | package.json doesn't exist; missing `"type": "module"` | Task 1, Action Steps 1–2 | Changed "Add to dependencies" to "CREATE package.json" with full content including `"type": "module"`, name, version, scripts, and dependency |
| MH-2 | `npm install` never runs | Task 1, Action Step 2 (new) | Added `cd apps/competitor-scraper && npm install` as explicit step; added to verification checklist |
| MH-3 | Migration path CWD-sensitive | Task 2, Action — Migration runner section | Added `MIGRATIONS_DIR = path.join(path.dirname(fileURLToPath(...)), '../../migrations')` with note that `process.cwd()` must not be used |
| MH-4 | NULL store_id bypasses UNIQUE constraint | Task 1, Table 7 (competitor_price_observation) | Changed `store_id INTEGER REFERENCES` to `store_id INTEGER NOT NULL REFERENCES`; added inline comment explaining NULL uniqueness risk; added to AC-1 and verification checklist |

### Strongly Recommended

| # | Finding | Plan Section Modified | Change Applied |
|---|---------|----------------------|----------------|
| SR-1 | No CHECK constraints on status enum fields | Task 1, Tables 2, 6, 8 | Added `CHECK(status IN (...))` to `competitor_store.last_scrape_status`, `scrape_run.status`, and `exception_queue.status`; added to verification checklist |
| SR-2 | NULL UNIQUE behaviour undocumented on competitor_product | Task 1, Table 5 | Added inline SQL comment documenting SQLite NULL uniqueness behaviour; flagged for Phase 2/3 normalizer |

### Deferred (Can Safely Defer)

| # | Finding | Rationale for Deferral |
|---|---------|----------------------|
| CSD-1 | PLANNING.md still says "6 tables" in Phase 1 description | Documentation debt only — does not affect this plan's build. Update PLANNING.md in a separate cleanup pass. |
| CSD-2 | No `.gitignore` for `apps/competitor-scraper/data/` | Local dev risk, not a correctness issue. PLANNING.md notes the files as gitignored. Add in Plan 01-02 or a cleanup task. |
| CSD-3 | `scrape_run` has no `run_trigger` column (manual vs scheduled) | Post-MVP concern. Scheduling is out of scope for MVP per PLANNING.md. |
| CSD-4 | `internal_price_history` has no `effective_to` column; Phase 5 query pattern undocumented | `MAX(effective_from) WHERE effective_from <= target_date` pattern is workable. Document the query pattern in Phase 5 plan, not here. |
| CSD-5 | AC-2 log output wording ("Seeded: 2 competitors...") doesn't match action spec ("Log row counts for each table seeded") | Minor cosmetic mismatch. Fix in seed.js implementation to match AC-2's exact phrasing. |

---

## 5. Audit & Compliance Readiness

**Audit evidence:** Every observation has `source_url NOT NULL` and `raw_json_snapshot`. Screenshot evidence is captured with path stored in DB. `scrape_run` tracks start/completion times and error counts. The `exception_queue` provides a full record of what failed and why, with `resolved_by` field for operator sign-off. This is a solid audit trail for a price intelligence system.

**Silent failure prevention:** The `observed_at NO DEFAULT` constraint forces the scraper to be explicit about when data was captured — preventing a class of silent bug where DB insertion time substitutes for actual observation time. The `screenshot_path CHECK` prevents absolute paths that would break on any machine other than the one that ran the scrape.

**Post-incident reconstruction:** `raw_json_snapshot TEXT` in `competitor_price_observation` allows re-running normalization/mapping logic against historical scrape data without re-scraping. `scrape_run` provides a complete run log. These fields are necessary and correctly specified.

**Ownership and accountability:** `exception_queue.resolved_by TEXT` provides operator attribution on exception resolution. `exception_queue.status` CHECK constraint (applied via SR-1) ensures only valid terminal states can be written.

**Gap:** After applied fixes, no remaining compliance gaps for Phase 1 scope. Phase 4 (persistence wiring) will need to enforce that every `INSERT INTO competitor_price_observation` sets `store_id` correctly — the NOT NULL constraint now enforces this at the DB layer.

---

## 6. Final Release Bar

**What must be true before this plan executes:**
- `apps/competitor-scraper/npm install` runs without errors (MH-2 — now in plan)
- `"type": "module"` is in the created package.json (MH-1 — now in plan)
- Migration path uses `__dirname`-based resolution (MH-3 — now in plan)
- `store_id NOT NULL` on `competitor_price_observation` (MH-4 — now in plan)

**Risks if shipped as-is (before audit):**
- Build would fail on first command: `SyntaxError: Cannot use import statement in a module`
- Even if syntax was fixed, `npm install` omission means `better-sqlite3` not found
- Duplicate observations silently inserted despite UNIQUE constraint (NULL bypass)
- Status field typos accepted silently — dashboard shows wrong counts

**After applied fixes:**
No remaining release-blocking risks for Phase 1 scope. The foundation schema is enterprise-defensible, idempotent, and audit-trail-complete. The normalizer's handling of null-pack-size products (CSD, SR-2) must be addressed in Phase 2/3 planning — document this as a known gap to carry forward.

**Sign-off statement:** I would approve this plan for execution with the applied fixes in place.

---

**Summary:** Applied 4 must-have + 3 strongly-recommended upgrades (7 changes to PLAN.md). Deferred 5 items.
**Plan status:** Updated and ready for APPLY.

---
*Audit performed by PAUL Enterprise Audit Workflow*
*Audit template version: 1.0*
*Auditor: Senior Principal Engineer role (Claude)*
