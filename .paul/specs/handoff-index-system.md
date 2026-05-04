# Spec: Handoff Index System

**Created:** 2026-05-04
**Status:** Ready to implement
**Target workspace:** Mac (implement in other Claude Code window, pull from AI-TREV/Competitor-Analyzer)

---

## Problem

`.paul/handoffs/` accumulates files with no index. Resume workflow scans by mtime and picks latest — no visibility into what each handoff contains, whether decisions were promoted, or which are stale. No command to inspect handoff state.

---

## Solution: Three Components

### 1. `HANDOFF-INDEX.md`

Auto-maintained file at `.paul/handoffs/HANDOFF-INDEX.md`.

**Format:**
```markdown
# Handoff Index

_Updated automatically by /paul:pause and /paul:resume_

## Active

| Date | File | Summary | Decisions Promoted |
|------|------|---------|-------------------|
| 2026-05-04 | HANDOFF-2026-05-04-repo-setup.md | Monorepo restructured, framework committed, no app code | None |

## Archived

| Date | File | Archived | Summary |
|------|------|---------|---------|
| 2026-05-04 | HANDOFF-2026-05-04-forensic-planning.md | 2026-05-04 | Pre-execution forensic review complete |
```

**Rules:**
- New row added to Active on every `/paul:pause`
- Row moved from Active → Archived on `/paul:resume` (when handoff consumed)
- `Decisions Promoted` column: comma-separated list of decisions added to STATE.md, or "None"
- Index never deleted — only rows move sections

---

### 2. Updated `pause-work.md` — Two New Steps

#### New Step: `extract_decisions` (after `create_handoff`, before `update_state`)

```
After writing HANDOFF file:
1. Scan handoff content for decisions (look for "Decision:", "Decided:", "Chose:", key choices in What Was Done)
2. List found decisions to user
3. Ask: "Promote any of these to STATE.md Decisions table? (yes/no/list numbers)"
4. If yes: append rows to STATE.md ## Accumulated Context > ### Decisions table
5. Record promoted decisions in HANDOFF-INDEX.md row (comma-separated short labels)
```

**Promotion format for STATE.md Decisions table:**
```markdown
| [Short label] | [Phase] | [Impact — one sentence] |
```

#### New Step: `update_handoff_index` (after `extract_decisions`)

```
1. Read .paul/handoffs/HANDOFF-INDEX.md (create if missing)
2. Build new row:
   - Date: current date
   - File: HANDOFF-{context}.md filename only (not path)
   - Summary: one-line from handoff "Status:" line + first bullet of What Was Done
   - Decisions Promoted: from extract_decisions step (or "None")
3. Append row to ## Active section
4. Write updated index
```

**Index creation (if missing):**
```markdown
# Handoff Index

_Updated automatically by /paul:pause and /paul:resume_

## Active

| Date | File | Summary | Decisions Promoted |
|------|------|---------|-------------------|

## Archived

| Date | File | Archived | Summary |
|------|------|---------|---------|
```

---

### 3. New Command: `/paul:handoffs`

**File location:** `.claude/commands/paul/handoffs.md`

**Arguments:** `[list|view <file>|archive <file>]` (default: `list`)

**Behavior:**

#### `list` (default)
- Read `.paul/handoffs/HANDOFF-INDEX.md`
- Display Active section as formatted table
- Show count of archived
- Output:
```
════════════════════════════════════════
PAUL HANDOFFS
════════════════════════════════════════

Active (2):
  2026-05-04  HANDOFF-2026-05-04-repo-setup.md
              Monorepo restructured, framework committed
              Decisions: None

  2026-05-04  HANDOFF-2026-05-04-framework-spec.md
              Token pause — handoff index spec written
              Decisions: Handoff index system

Archived: 2 files  (run /paul:handoffs archive to view)

▶ Resume uses most recent active handoff.
════════════════════════════════════════
```

#### `view <filename>`
- Read `.paul/handoffs/<filename>`
- Display full content
- Note active/archived status from index

#### `archive <filename>`
- Move row from Active → Archived in HANDOFF-INDEX.md (add Archived date)
- Do NOT move the file itself (keep in `.paul/handoffs/` flat)
- Confirm: "Archived HANDOFF-2026-05-04-repo-setup.md in index."

---

### 4. Updated `resume-project.md` — Consume Step Enhancement

After user confirms next action (currently: "archive handoff"):

**Replace current handoff_lifecycle step with:**

```
1. Move handoff row from Active → Archived in HANDOFF-INDEX.md
   - Add current date to Archived column
2. Do NOT move or delete the file (keep for reference)
3. Update STATE.md: clear Resume file field, set to "none"
4. Note which handoff was consumed in STATE.md Last activity line
```

---

## Implementation Order

1. Create `/paul:handoffs` command file (`.claude/commands/paul/handoffs.md`)
2. Create workflow stub at `~/.claude/paul-framework/workflows/handoffs.md`
3. Update `pause-work.md` — add `extract_decisions` step + `update_handoff_index` step
4. Update `resume-project.md` — replace `handoff_lifecycle` step
5. Create `.paul/handoffs/HANDOFF-INDEX.md` with current handoffs backfilled
6. Test: `/paul:pause` → verify index updated → `/paul:handoffs list` → verify display → `/paul:resume` → verify archived

---

## File Map

| File | Action |
|------|--------|
| `.claude/commands/paul/handoffs.md` | CREATE |
| `~/.claude/paul-framework/workflows/handoffs.md` | CREATE |
| `~/.claude/paul-framework/workflows/pause-work.md` | EDIT — add 2 steps |
| `~/.claude/paul-framework/workflows/resume-project.md` | EDIT — replace handoff_lifecycle step |
| `.paul/handoffs/HANDOFF-INDEX.md` | CREATE + backfill |

---

## Backfill for Existing Handoffs

On creation of `HANDOFF-INDEX.md`, add these rows to Active:

| Date | File | Summary | Decisions Promoted |
|------|------|---------|-------------------|
| 2026-05-04 | HANDOFF-2026-05-04-orchestration.md | Pre-build orchestration setup | None |
| 2026-05-04 | HANDOFF-2026-05-04-forensic-planning.md | Forensic review, 8-table schema finalized | 8-table schema, ExceptionQueue taxonomy, Phase 5 metrics, Post-MVP backlog |
| 2026-05-04 | HANDOFF-2026-05-04-repo-setup.md | Monorepo restructured, framework committed, no app code | None |
| 2026-05-04 | HANDOFF-2026-05-04-framework-spec.md | Token pause — handoff index spec written | Handoff index system |

---

## Notes

- HANDOFF files never deleted — index is the control surface
- `/paul:resume` picks most recent Active row (not mtime) after this lands
- Decision promotion is optional — user can skip, always "None" if declined
- Keep implementation tight: no extra features beyond spec above
