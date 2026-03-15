#!/usr/bin/env python3
import tempfile
import unittest
from pathlib import Path

from pipeline_board import (
    STATUS_DONE,
    STATUS_FINAL_REVIEW,
    STATUS_READY,
    STATUS_REVIEW_POOL,
    ack_item,
    build_recovery_plan,
    process_snapshot,
)


def make_issue_item(
    item_id: str,
    number: int,
    *,
    status: str = "Ready",
    title: str | None = None,
    linked_prs: list[int] | None = None,
) -> dict:
    item = {
        "id": item_id,
        "status": status,
        "content": {
            "type": "Issue",
            "number": number,
            "title": title or f"[Model] Issue {number}",
        },
        "title": title or f"[Model] Issue {number}",
    }
    if linked_prs is not None:
        item["linked pull requests"] = [
            f"https://github.com/CodingThrust/problem-reductions/pull/{pr_number}"
            for pr_number in linked_prs
        ]
    return item


def make_pr_item(item_id: str, number: int, status: str = "Review pool") -> dict:
    return {
        "id": item_id,
        "status": status,
        "content": {"type": "PullRequest", "number": number},
    }


def make_issue(number: int, *, state: str = "OPEN", labels: list[str] | None = None) -> dict:
    return {
        "number": number,
        "state": state,
        "title": f"[Model] Issue {number}",
        "labels": [{"name": label} for label in (labels or [])],
    }


def make_pr(
    number: int,
    *,
    state: str = "OPEN",
    merged: bool = False,
    checks: list[dict] | None = None,
) -> dict:
    return {
        "number": number,
        "state": state,
        "mergedAt": "2026-03-15T00:00:00Z" if merged else None,
        "statusCheckRollup": checks or [],
    }


def success_check(name: str = "ci") -> dict:
    return {
        "__typename": "CheckRun",
        "name": name,
        "status": "COMPLETED",
        "conclusion": "SUCCESS",
    }


class PipelineBoardPollTests(unittest.TestCase):
    def test_ready_queue_retries_same_item_until_ack(self) -> None:
        with tempfile.TemporaryDirectory() as tmpdir:
            state_file = Path(tmpdir) / "ready-state.json"
            snapshot = {
                "items": [
                    make_issue_item("PVTI_1", 101),
                    make_issue_item("PVTI_2", 102),
                ]
            }

            item_id, number = process_snapshot("ready", snapshot, state_file)
            self.assertEqual((item_id, number), ("PVTI_1", 101))

            item_id, number = process_snapshot("ready", snapshot, state_file)
            self.assertEqual((item_id, number), ("PVTI_1", 101))

            ack_item(state_file, "PVTI_1")
            item_id, number = process_snapshot("ready", snapshot, state_file)
            self.assertEqual((item_id, number), ("PVTI_2", 102))

    def test_review_queue_resolves_issue_cards_to_prs(self) -> None:
        def fake_pr_resolver(repo: str, issue_number: int) -> int | None:
            self.assertEqual(repo, "CodingThrust/problem-reductions")
            return 570 if issue_number == 117 else None

        def fake_review_fetcher(repo: str, pr_number: int) -> list[dict]:
            self.assertEqual(repo, "CodingThrust/problem-reductions")
            if pr_number == 570:
                return [{"user": {"login": "copilot-pull-request-reviewer[bot]"}}]
            return []

        def fake_pr_state_fetcher(repo: str, pr_number: int) -> str:
            self.assertEqual(repo, "CodingThrust/problem-reductions")
            self.assertEqual(pr_number, 570)
            return "OPEN"

        with tempfile.TemporaryDirectory() as tmpdir:
            state_file = Path(tmpdir) / "review-state.json"
            item_id, number = process_snapshot(
                "review",
                {"items": [make_issue_item("PVTI_10", 117, status="Review pool")]},
                state_file,
                repo="CodingThrust/problem-reductions",
                review_fetcher=fake_review_fetcher,
                pr_resolver=fake_pr_resolver,
                pr_state_fetcher=fake_pr_state_fetcher,
            )
            self.assertEqual((item_id, number), ("PVTI_10", 570))

    def test_review_queue_skips_closed_pr_cards(self) -> None:
        def fake_review_fetcher(repo: str, pr_number: int) -> list[dict]:
            return [{"user": {"login": "copilot-pull-request-reviewer[bot]"}}]

        def fake_pr_state_fetcher(repo: str, pr_number: int) -> str:
            self.assertEqual(repo, "CodingThrust/problem-reductions")
            self.assertEqual(pr_number, 570)
            return "CLOSED"

        with tempfile.TemporaryDirectory() as tmpdir:
            state_file = Path(tmpdir) / "review-state.json"
            no_item = process_snapshot(
                "review",
                {"items": [make_pr_item("PVTI_10", 570)]},
                state_file,
                repo="CodingThrust/problem-reductions",
                review_fetcher=fake_review_fetcher,
                pr_state_fetcher=fake_pr_state_fetcher,
            )
            self.assertIsNone(no_item)


class PipelineBoardRecoveryTests(unittest.TestCase):
    def test_recovery_plan_marks_merged_pr_items_done(self) -> None:
        board_data = {
            "items": [
                make_issue_item(
                    "PVTI_1",
                    101,
                    status="Review pool",
                    title="[Model] MinimumFeedbackVertexSet",
                    linked_prs=[615],
                )
            ]
        }
        issues = [make_issue(101, labels=["Good"])]
        prs = [make_pr(615, state="MERGED", merged=True)]

        plan = build_recovery_plan(board_data, issues, prs, pr_reviews={})

        self.assertEqual(len(plan), 1)
        self.assertEqual(plan[0]["proposed_status"], STATUS_DONE)

    def test_recovery_plan_marks_green_copilot_reviewed_prs_final_review(self) -> None:
        board_data = {
            "items": [
                make_issue_item(
                    "PVTI_1",
                    101,
                    status="Review pool",
                    title="[Model] HamiltonianPath",
                    linked_prs=[621],
                )
            ]
        }
        issues = [make_issue(101, labels=["Good"])]
        prs = [make_pr(621, checks=[success_check()])]
        pr_reviews = {621: [{"user": {"login": "copilot-pull-request-reviewer[bot]"}}]}

        plan = build_recovery_plan(board_data, issues, prs, pr_reviews=pr_reviews)

        self.assertEqual(plan[0]["proposed_status"], STATUS_FINAL_REVIEW)

    def test_recovery_plan_marks_open_pr_without_copilot_review_review_pool(self) -> None:
        board_data = {
            "items": [
                make_issue_item(
                    "PVTI_1",
                    101,
                    status="In progress",
                    title="[Model] SteinerTree",
                    linked_prs=[192],
                )
            ]
        }
        issues = [make_issue(101, labels=["Good"])]
        prs = [make_pr(192, checks=[success_check()])]

        plan = build_recovery_plan(board_data, issues, prs, pr_reviews={192: []})

        self.assertEqual(plan[0]["proposed_status"], STATUS_REVIEW_POOL)

    def test_recovery_plan_marks_good_issue_without_pr_ready(self) -> None:
        board_data = {
            "items": [
                make_issue_item(
                    "PVTI_1",
                    101,
                    status="Backlog",
                    title="[Model] ExactCoverBy3Sets",
                )
            ]
        }
        issues = [make_issue(101, labels=["Good"])]

        plan = build_recovery_plan(board_data, issues, prs=[], pr_reviews={})

        self.assertEqual(plan[0]["proposed_status"], STATUS_READY)


if __name__ == "__main__":
    unittest.main()
