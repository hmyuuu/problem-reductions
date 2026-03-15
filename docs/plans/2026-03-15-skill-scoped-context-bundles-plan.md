# Skill-Scoped Context Bundles Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Reduce the remaining skill orchestration noise by giving `review-pipeline` and `final-review` one top-level mechanical context bundle each.

**Architecture:** Keep the existing stage-level helpers in `pipeline_board.py`, `pipeline_pr.py`, `pipeline_worktree.py`, and `pipeline_checks.py` unchanged as reusable building blocks. Add a new orchestration layer, `scripts/pipeline_skill_context.py`, whose subcommands are named after skills and return one consumer-ready JSON payload per skill entrypoint. Skills should stop composing multiple low-level commands in their happy path and instead branch off a single bundle object.

**Bundle contract rule:** Keep top-level fields minimal and stable. Top level should only carry workflow-stage objects such as `selection`, `prep`, `pr`, `review_context`, plus `skill`, `status`, and choice metadata (`options`, `recommendation`, `warnings`) when needed. Keep PR-derived details nested under `pr`; keep deterministic review/check data nested under `review_context`.

**Tech Stack:** Python 3, `gh` CLI, `git`, `unittest`, repo-local `SKILL.md` docs, Makefile shell helpers

---

## Chunk 1: Shared Skill-Context Aggregator

### Task 1: Add `scripts/pipeline_skill_context.py` skeleton and tests

**Files:**
- Create: `scripts/pipeline_skill_context.py`
- Create: `scripts/test_pipeline_skill_context.py`

- [x] **Step 1: Write the failing parser and helper tests**

Add tests for:
- CLI subcommands `review-pipeline` and `final-review`
- common JSON printer behavior
- shared helper to normalize “no work available” and “manual disambiguation required” states

The tests should assert a stable top-level contract like:

```python
{
    "skill": "review-pipeline",
    "status": "ready",
    "selection": {...},
    "prep": {...},
    "pr": {...},
}
```

and:

```python
{
    "skill": "review-pipeline",
    "status": "needs-user-choice",
    "options": [...],
    "recommendation": 173,
}
```

- [x] **Step 2: Run the focused tests to verify failure**

Run: `python3 scripts/test_pipeline_skill_context.py`
Expected: FAIL because the new script does not exist yet.

- [x] **Step 3: Implement the minimal script skeleton**

In `scripts/pipeline_skill_context.py`:
- add `emit_result()`
- add argument parsing for:
  - `review-pipeline`
  - `final-review`
- add placeholder builders that raise `NotImplementedError` until later chunks

- [x] **Step 4: Run the focused tests to verify the skeleton passes**

Run: `python3 scripts/test_pipeline_skill_context.py`
Expected: PASS for parser/shape tests only.

- [x] **Step 5: Commit**

```bash
git add scripts/pipeline_skill_context.py scripts/test_pipeline_skill_context.py
git commit -m "refactor(pipeline): scaffold skill context bundles"
```

## Chunk 2: Review-Pipeline Context Bundle

### Task 2: Add `pipeline_skill_context.py review-pipeline`

**Files:**
- Modify: `scripts/pipeline_skill_context.py`
- Modify: `scripts/test_pipeline_skill_context.py`

- [x] **Step 1: Write the failing tests for `review-pipeline` bundle**

Cover three paths:
- no eligible review item -> `status == "empty"`
- ambiguous linked PR card -> `status == "needs-user-choice"` with `options` and `recommendation`
- explicit `--pr` matching one of an ambiguous card's linked PRs -> deterministic disambiguation and `status == "ready"`
- eligible PR -> `status == "ready"` with:
  - claimed board item metadata
  - prepared review worktree payload
  - bundled PR context payload

The success payload should include:

```python
{
    "skill": "review-pipeline",
    "status": "ready",
    "selection": {...},
    "pr": {...},
    "prep": {...},
}
```

Use mocks around:
- board candidate listing / claiming
- worktree prep
- PR context loading

Do not let tests call live GitHub or mutate the project board.

- [x] **Step 2: Run the focused tests to verify failure**

Run: `python3 scripts/test_pipeline_skill_context.py`
Expected: FAIL because `review-pipeline` bundle logic is not implemented yet.

- [x] **Step 3: Implement the minimal bundle**

In `scripts/pipeline_skill_context.py`:
- add a pure `build_review_pipeline_context(...)` helper
- add CLI:

```bash
python3 scripts/pipeline_skill_context.py review-pipeline --repo <repo> [--pr <n>] [--state-file <path>] --format json
```

Behavior:
- if `--pr` is provided, validate against `pipeline_board.review_candidates`
- if `--pr` matches one of an ambiguous card's linked PR options, treat that as deterministic disambiguation, claim the item through the manual single-item path, and continue with `status == "ready"`
- if the target card is ambiguous and no `--pr` was provided, return `needs-user-choice` instead of mutating anything
- otherwise claim through `pipeline_board.claim_next_entry(...)`
- prepare the worktree through `pipeline_worktree.prepare_review(...)`
- gather bundled PR context through `pipeline_pr.build_pr_context(...)`

- [x] **Step 4: Run the focused tests to verify they pass**

Run: `python3 scripts/test_pipeline_skill_context.py`
Expected: PASS

- [x] **Step 5: Re-run local verification**

Run:
- `python3 scripts/test_pipeline_skill_context.py`
- `python3 scripts/pipeline_skill_context.py review-pipeline --help`

- [x] **Step 6: Commit**

```bash
git add scripts/pipeline_skill_context.py scripts/test_pipeline_skill_context.py
git commit -m "refactor(pipeline): bundle review-pipeline context"
```

## Chunk 3: Rewrite Review-Pipeline to Consume One Bundle

### Task 3: Simplify `review-pipeline` and helper entrypoints

**Files:**
- Modify: `.claude/skills/review-pipeline/SKILL.md`
- Modify: `scripts/make_helpers.sh`
- Modify: `scripts/test_make_helpers.py`
- Modify: `Makefile`

- [x] **Step 1: Write the failing helper tests**

Add tests that expect new helper wrappers such as:

```sh
review_pipeline_context <repo> [pr] [state_file]
```

and a Make dry-run target or helper path that emits:

```sh
scripts/pipeline_skill_context.py review-pipeline ...
```

- [x] **Step 2: Run the focused helper tests to verify failure**

Run: `python3 scripts/test_make_helpers.py`
Expected: FAIL because the helper wrappers do not exist yet.

- [x] **Step 3: Implement the helper wrapper**

In `scripts/make_helpers.sh`:
- add `review_pipeline_context()`

In `Makefile`:
- optionally add a thin `review-context-skill` target if it improves dry-run ergonomics
- keep existing `run-review` behavior intact

- [x] **Step 4: Rewrite the skill happy path**

In `.claude/skills/review-pipeline/SKILL.md`:
- replace the current sequence:
  - list review candidates
  - claim-next
  - prepare-review
  - separate comments fetch
- with one entrypoint:

```bash
CTX=$(python3 scripts/pipeline_skill_context.py review-pipeline --repo "$REPO" --format json)
```

Then branch on:
- `CTX["status"] == "empty"` -> stop
- `CTX["status"] == "needs-user-choice"` -> ask user with recommendation
- `CTX["status"] == "ready"` -> proceed using:
  - `CTX["selection"]`
  - `CTX["prep"]`
  - `CTX["pr"]`

Keep only judgment-heavy or write-side actions outside the bundle:
- deciding whether comments are actually addressed
- fixing code
- moving back to `Review pool` on complex conflicts
- moving to `Final review`

- [x] **Step 5: Re-run local verification**

Run:
- `python3 scripts/test_make_helpers.py`
- `make -n run-review`

- [x] **Step 6: Commit**

```bash
git add .claude/skills/review-pipeline/SKILL.md scripts/make_helpers.sh scripts/test_make_helpers.py Makefile
git commit -m "refactor(pipeline): simplify review-pipeline skill entry"
```

## Chunk 4: Final-Review Context Bundle

### Task 4: Add `pipeline_skill_context.py final-review`

**Files:**
- Modify: `scripts/pipeline_skill_context.py`
- Modify: `scripts/test_pipeline_skill_context.py`

- [x] **Step 1: Write the failing tests for `final-review` bundle**

Cover:
- no final-review item -> `status == "empty"`
- selected PR with clean prep -> `status == "ready"` with:
  - selected board item metadata
  - bundled PR context
  - prepared review worktree result
  - deterministic review context / checks
- selected PR with conflicted prep -> `status == "ready"` and still includes deterministic `review_context` derived from the PR diff range
- selected PR with prep failure -> `status == "ready-with-warnings"` and includes `prep` plus `warnings`; `review_context` may be `null`

The success payload should include:

```python
{
    "skill": "final-review",
    "status": "ready",
    "selection": {...},
    "pr": {...},
    "prep": {...},
    "review_context": {...},
}
```

Mock:
- board selection
- worktree prep
- PR context load
- deterministic review checks

- [x] **Step 2: Run the focused tests to verify failure**

Run: `python3 scripts/test_pipeline_skill_context.py`
Expected: FAIL because `final-review` bundle logic is not implemented yet.

- [x] **Step 3: Implement the minimal bundle**

In `scripts/pipeline_skill_context.py`:
- add `build_final_review_context(...)`
- add CLI:

```bash
python3 scripts/pipeline_skill_context.py final-review --repo <repo> [--pr <n>] [--state-file <path>] --format json
```

Behavior:
- resolve the PR through `pipeline_board.select_next_entry(...)`
- load bundled PR context through `pipeline_pr.build_pr_context(...)`
- always prepare a review worktree through `pipeline_worktree.prepare_review(...)`
- derive deterministic review context from the PR diff range using the prepared checkout metadata (`base_sha`, `head_sha`) whenever checkout succeeds, even if the merge step is conflicted
- return `status == "ready-with-warnings"` only when prep fails badly enough that deterministic review context cannot be produced

The common path must therefore include both `prep` and `review_context`. A `null` `review_context` is only acceptable in the explicit prep-failure path, which must be covered by tests.

- [x] **Step 4: Run the focused tests to verify they pass**

Run: `python3 scripts/test_pipeline_skill_context.py`
Expected: PASS

- [x] **Step 5: Re-run local verification**

Run:
- `python3 scripts/test_pipeline_skill_context.py`
- `python3 scripts/pipeline_skill_context.py final-review --help`

- [x] **Step 6: Commit**

```bash
git add scripts/pipeline_skill_context.py scripts/test_pipeline_skill_context.py
git commit -m "refactor(pipeline): bundle final-review context"
```

## Chunk 5: Rewrite Final-Review to Consume One Bundle

### Task 5: Simplify `final-review` skill entry

**Files:**
- Modify: `.claude/skills/final-review/SKILL.md`

- [x] **Step 1: Write down the exact fields the skill will consume**

Before editing, explicitly map the final-review happy path to:
- `CTX["selection"]`
- `CTX["pr"]`
- `CTX["prep"]`
- `CTX["review_context"]`

This is a prose-only preparation step to keep the skill rewrite narrow.

- [x] **Step 2: Rewrite the skill to use one mechanical bundle**

Replace the current early-stage sequence:
- board selection
- `pipeline_pr.py context`
- optional `prepare-review`
- separate whitelist/completeness setup

with:

```bash
CTX=$(python3 scripts/pipeline_skill_context.py final-review --repo "$REPO" --format json)
```

Then keep only judgment-heavy work in the skill:
- usefulness assessment
- safety assessment
- comment disposition judgment
- merge / hold / quick-fix decisions

Use `CTX["review_context"]` directly for deterministic whitelist/completeness in the common path. If `CTX["status"] == "ready-with-warnings"`, document the rare fallback clearly and keep it narrow.

- [x] **Step 3: Re-run local verification**

Run:
- `python3 scripts/test_pipeline_skill_context.py`
- `python3 scripts/test_pipeline_pr.py`
- `python3 scripts/test_pipeline_worktree.py`

- [x] **Step 4: Commit**

```bash
git add .claude/skills/final-review/SKILL.md
git commit -m "refactor(pipeline): simplify final-review skill entry"
```

## Chunk 6: Final Verification and Push

### Task 6: Verify the skill-scoped layer end to end

**Files:**
- Modify: `docs/plans/2026-03-15-skill-scoped-context-bundles-plan.md`

- [x] **Step 1: Run the full helper verification set**

Run:
- `python3 scripts/test_pipeline_skill_context.py`
- `python3 scripts/test_pipeline_pr.py`
- `python3 scripts/test_pipeline_checks.py`
- `python3 scripts/test_pipeline_worktree.py`
- `python3 scripts/test_pipeline_board.py`
- `python3 scripts/test_make_helpers.py`

- [x] **Step 2: Run dry-run command verification**

Run:
- `python3 scripts/pipeline_skill_context.py review-pipeline --help`
- `python3 scripts/pipeline_skill_context.py final-review --help`
- `make -n run-review`

- [x] **Step 3: Mark the plan checklist complete**

Update this plan file so each completed step is checked.

- [x] **Step 4: Commit**

```bash
git add docs/plans/2026-03-15-skill-scoped-context-bundles-plan.md
git commit -m "docs(pipeline): record skill-scoped context bundle plan progress"
```
