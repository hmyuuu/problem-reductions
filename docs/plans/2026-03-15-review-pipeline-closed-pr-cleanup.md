# Review Pipeline Closed-PR Cleanup Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Remove stale closed-PR links that confuse board selection, make review selection skip closed or mixed-status cards, and clean up the leftover local review worktree.

**Architecture:** Keep the operational cleanup separate from repository behavior changes. The durable fix lives in the review poller and the repo-local `review-pipeline` skill so both the forever poller and manual review runs reject stale or ambiguous Review pool cards.

**Tech Stack:** GitHub CLI, Python, unittest, repo-local skill docs

---

### Task 1: Add failing review-poller tests

**Files:**
- Modify: `scripts/test_project_board_poll.py`

- [ ] Add a test showing a Review pool PR card with a closed PR is skipped.
- [ ] Add a test showing a Review pool issue card with mixed linked PR states is skipped.
- [ ] Run the targeted test file and confirm the new assertions fail before implementation.

### Task 2: Implement minimal poller fix

**Files:**
- Modify: `scripts/project_board_poll.py`

- [ ] Add minimal PR-state inspection helpers needed by review mode.
- [ ] Reject closed PR cards in review mode.
- [ ] Reject issue cards whose linked repo PRs are mixed-status or otherwise ambiguous.
- [ ] Re-run the targeted poller tests and confirm they pass.

### Task 3: Update manual review-pipeline instructions

**Files:**
- Modify: `.claude/skills/review-pipeline/SKILL.md`

- [ ] Update candidate-discovery guidance to require open PRs only.
- [ ] Add an explicit rule to skip mixed-status cards and cards with multiple linked repo PRs unless the selection is unambiguous.
- [ ] Document the stale-link cleanup expectation so manual review runs match the automated poller.

### Task 4: Perform operational cleanup

**Files:**
- None (GitHub/project operations)

- [ ] Remove stale issue-closing references from closed PRs that should no longer be attached to active board cards.
- [ ] Remove the leftover local worktree from the aborted `review-pipeline` run.
- [ ] Refresh the project board state and confirm the affected card no longer presents the same stale closed-PR selection problem.

### Task 5: Verify

**Files:**
- None

- [ ] Run the targeted poller test file.
- [ ] Re-check the affected PR/card state on GitHub.
- [ ] Summarize what changed and any remaining board ambiguities.
