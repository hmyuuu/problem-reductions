# Research Tasks: New Problems & Reductions

> Generated: 2026-02-16 | Status: ✅ RESEARCH COMPLETE (Iterations 1-4)
> Network note: All work logged locally. Do NOT push.
>
> **Summary:** 19 models + 20 reductions + 2 analyses + 1 SUMMARY in `docs/plans/proposals/` (42 files)
> Iteration 1: Karp's 21 gap analysis → 12 models, 15 reductions
> Iteration 2: Lucas 2014, missing cross-reductions → +3 models, +1 analysis
> Iteration 3: Julia alignment, MaxSAT, EdgeColoring, MultiwayCut, LongestPath → +4 models, +2 reductions
> Iteration 4: QUBO reductions (SubsetSum, Partition, Knapsack, MaxSAT) + SUMMARY → +4 reductions, +1 summary

## Karp's 21 NP-Complete Problems — Gap Analysis

| # | Karp Problem | Codebase Status | Proposed? | Notes |
|---|-------------|----------------|-----------|-------|
| 1 | Satisfiability (SAT) | ✅ `Satisfiability` | — | Done |
| 2 | 0-1 Integer Programming | ✅ `ILP` | — | Done |
| 3 | Clique | ✅ `MaximumClique` | — | Done |
| 4 | Set Packing | ✅ `MaximumSetPacking` | — | Done |
| 5 | Vertex Cover | ✅ `MinimumVertexCover` | — | Done |
| 6 | Set Covering | ✅ `MinimumSetCovering` | — | Done |
| 7 | Feedback Node Set | ❌ Missing | ⚠️ Tier 3 | Needs directed graph / cycle detection |
| 8 | Feedback Arc Set | ❌ Missing | 🆕 NEW | Dual of Feedback Node Set on arcs |
| 9 | Directed Hamiltonian Circuit | ✅ `HamiltonianCycle` | — | Done (#47/#57) |
| 10 | Undirected Hamiltonian Circuit | ✅ `HamiltonianCycle` | — | Same model |
| 11 | 3-SAT | ✅ `KSatisfiability<K3>` | — | Done |
| 12 | Chromatic Number (Coloring) | ✅ `KColoring` | — | Done |
| 13 | Clique Cover | ❌ Missing | ✅ Tier 2 | KColoring on complement |
| 14 | Exact Cover | ❌ Missing | ✅ Tier 1 | Satisfaction variant of SetCovering |
| 15 | Hitting Set | ❌ Missing | ✅ Tier 1 | Dual of SetCovering |
| 16 | Steiner Tree | ❌ Missing | 🆕 NEW | Graph + terminals, ILP formulation |
| 17 | 3-Dimensional Matching | ❌ Missing | 🆕 NEW | Special case of set packing |
| 18 | Knapsack / Subset Sum | ❌ Missing | ✅ Tier 1-2 | SubsetSum + Knapsack |
| 19 | Job Sequencing | ❌ Missing | 🆕 NEW | Scheduling, QUBO available |
| 20 | Partition | ❌ Missing | ✅ Tier 1 | SubsetSum with target=sum/2 |
| 21 | Max Cut | ✅ `MaxCut` | — | Done |

**Summary: 10 of 21 implemented, 11 missing. 6 already proposed, 5 newly identified.**

---

## Task List

### Tier 1: Very Easy (from existing proposal — confirmed good)
- [ ] `[T1-1]` HittingSet model → `docs/plans/proposals/model_hitting_set.md`
- [ ] `[T1-2]` ExactCover model → `docs/plans/proposals/model_exact_cover.md`
- [ ] `[T1-3]` SubsetSum model → `docs/plans/proposals/model_subset_sum.md`
- [ ] `[T1-4]` Partition model → `docs/plans/proposals/model_partition.md`
- [ ] `[T1-5]` HittingSet ↔ MinimumSetCovering reduction → `docs/plans/proposals/reduction_hittingset_setcovering.md`
- [ ] `[T1-6]` ExactCover → MinimumSetCovering reduction → `docs/plans/proposals/reduction_exactcover_setcovering.md`
- [ ] `[T1-7]` ExactCover → ILP reduction → `docs/plans/proposals/reduction_exactcover_ilp.md`
- [ ] `[T1-8]` SubsetSum → ILP reduction → `docs/plans/proposals/reduction_subsetsum_ilp.md`
- [ ] `[T1-9]` Partition → SubsetSum reduction → `docs/plans/proposals/reduction_partition_subsetsum.md`
- [ ] `[T1-10]` HittingSet → ILP reduction → `docs/plans/proposals/reduction_hittingset_ilp.md`
- [ ] `[T1-11]` Partition → ILP reduction → `docs/plans/proposals/reduction_partition_ilp.md`

### Tier 2: Easy (from existing proposal — confirmed good)
- [ ] `[T2-1]` Knapsack model → `docs/plans/proposals/model_knapsack.md`
- [ ] `[T2-2]` CliqueCover model → `docs/plans/proposals/model_clique_cover.md`
- [ ] `[T2-3]` Knapsack → ILP reduction → `docs/plans/proposals/reduction_knapsack_ilp.md`
- [ ] `[T2-4]` CliqueCover ↔ KColoring reduction → `docs/plans/proposals/reduction_cliquecover_kcoloring.md`

### Tier 3: Moderate (new research — additional Karp problems)
- [ ] `[T3-1]` 3DMatching model → `docs/plans/proposals/model_3d_matching.md`
- [ ] `[T3-2]` SteinerTree model → `docs/plans/proposals/model_steiner_tree.md`
- [ ] `[T3-3]` FeedbackVertexSet model → `docs/plans/proposals/model_feedback_vertex_set.md`
- [ ] `[T3-4]` FeedbackArcSet model → `docs/plans/proposals/model_feedback_arc_set.md`
- [ ] `[T3-5]` JobSequencing model → `docs/plans/proposals/model_job_sequencing.md`
- [ ] `[T3-6]` 3DMatching → MaximumSetPacking reduction → `docs/plans/proposals/reduction_3dmatching_setpacking.md`
- [ ] `[T3-7]` SteinerTree → ILP reduction → `docs/plans/proposals/reduction_steinertree_ilp.md`
- [ ] `[T3-8]` FeedbackVertexSet → ILP reduction → `docs/plans/proposals/reduction_feedbackvertexset_ilp.md`
- [ ] `[T3-9]` FeedbackArcSet → ILP reduction → `docs/plans/proposals/reduction_feedbackarcset_ilp.md`

### Tier 4: Bonus (from Lucas 2014 / QUBO research)
- [ ] `[T4-1]` MinimumBisection model → `docs/plans/proposals/model_minimum_bisection.md`
- [ ] `[T4-2]` MinimumBisection → QUBO reduction → `docs/plans/proposals/reduction_minimumbisection_qubo.md`
- [ ] `[T4-3]` MaxCut → QUBO direct reduction → `docs/plans/proposals/reduction_maxcut_qubo.md`
- [ ] `[T4-4]` HamiltonianCycle → ILP (already filed as #52) → skip

### Cross-cutting Reductions (connect new problems to graph)
- [ ] `[X-1]` ExactCover → SAT reduction
- [ ] `[X-2]` 3DMatching → ExactCover reduction
- [ ] `[X-3]` SubsetSum → QUBO reduction (from Lucas 2014)
- [ ] `[X-4]` Partition → QUBO reduction (from Lucas 2014)
- [ ] `[X-5]` Knapsack → QUBO reduction (from Lucas 2014)

### Tier 5: New from Iteration 2 — Lucas 2014 & Cross-Reductions
- [ ] `[T5-1]` MinimalMaximalMatching model → `docs/plans/proposals/model_minimal_maximal_matching.md`
- [ ] `[T5-2]` GraphPartitioning (k-way) model → `docs/plans/proposals/model_graph_partitioning.md`
- [ ] `[T5-3]` GraphIsomorphism → SKIP (NP-intermediate, not NP-complete)

### Tier 6: New from Iteration 3 — Extended Research
- [ ] `[T6-1]` MaxSAT model → `docs/plans/proposals/model_max_sat.md`
- [ ] `[T6-2]` MultiwayCut model → `docs/plans/proposals/model_multiway_cut.md`
- [ ] `[T6-3]` EdgeColoring model → `docs/plans/proposals/model_edge_coloring.md`
- [ ] `[T6-4]` LongestPath model → `docs/plans/proposals/model_longest_path.md`
- [ ] `[T6-5]` SpinGlass → SAT/MaxSAT reduction → `docs/plans/proposals/reduction_spinglass_sat.md`
- [ ] `[T6-6]` MaxSAT → QUBO reduction (direct encoding)
- [ ] `[T6-7]` EdgeColoring → KColoring reduction (via line graph)

### Missing Cross-Reductions (between EXISTING problems!)
- [ ] `[M-1]` MaximumClique ↔ MaximumIndependentSet (complement graph — FUNDAMENTAL, missing!)
- [ ] `[M-2]` HamiltonianCycle → TravelingSalesman (classic, both problems exist!)
- [ ] `[M-3]` MinimumDominatingSet → MinimumSetCovering (closed neighborhood → covering)
- [ ] `[M-4]` MaximumClique → QUBO (direct, bypasses ILP)
- [ ] `[M-5]` MinimumDominatingSet → QUBO (direct)
- [ ] `[M-6]` SAT → MaxCut (Garey-Johnson-Stockmeyer 1976)
- [ ] `[M-7]` SpinGlass → SAT (exists in Julia ProblemReductions.jl but NOT in Rust!)

---

## Proposal File Status

| File | Status |
|------|--------|
| `model_hitting_set.md` | ✅ DONE |
| `model_exact_cover.md` | ✅ DONE |
| `model_subset_sum.md` | ✅ DONE |
| `model_partition.md` | ✅ DONE |
| `model_knapsack.md` | ✅ DONE |
| `model_clique_cover.md` | ✅ DONE |
| `model_3d_matching.md` | ✅ DONE |
| `model_steiner_tree.md` | ✅ DONE |
| `model_feedback_vertex_set.md` | ✅ DONE |
| `model_feedback_arc_set.md` | ✅ DONE |
| `model_job_sequencing.md` | ✅ DONE |
| `model_minimum_bisection.md` | ✅ DONE |
| `reduction_hittingset_setcovering.md` | ✅ DONE |
| `reduction_exactcover_setcovering.md` | ✅ DONE |
| `reduction_exactcover_ilp.md` | ✅ DONE |
| `reduction_subsetsum_ilp.md` | ✅ DONE |
| `reduction_partition_subsetsum.md` | ✅ DONE |
| `reduction_hittingset_ilp.md` | ✅ DONE |
| `reduction_partition_ilp.md` | ✅ DONE |
| `reduction_knapsack_ilp.md` | ✅ DONE |
| `reduction_cliquecover_kcoloring.md` | ✅ DONE |
| `reduction_3dmatching_setpacking.md` | ✅ DONE |
| `reduction_steinertree_ilp.md` | ✅ DONE |
| `reduction_feedbackvertexset_ilp.md` | ✅ DONE |
| `reduction_feedbackarcset_ilp.md` | ✅ DONE |
| `reduction_minimumbisection_qubo.md` | ✅ DONE |
| `reduction_maxcut_qubo.md` | ✅ DONE |
| `model_minimal_maximal_matching.md` | ✅ DONE (iter 2) |
| `model_graph_partitioning.md` | ✅ DONE (iter 2) |
| `model_graph_isomorphism_SKIP.md` | ✅ DONE (iter 2, SKIP — NPI) |
| `reduction_missing_cross_reductions.md` | ✅ DONE (iter 2) |
| `analysis_julia_alignment.md` | ✅ DONE (iter 3) |
| `model_max_sat.md` | ✅ DONE (iter 3) |
| `model_multiway_cut.md` | ✅ DONE (iter 3) |
| `model_edge_coloring.md` | ✅ DONE (iter 3) |
| `model_longest_path.md` | ✅ DONE (iter 3) |
| `reduction_spinglass_sat.md` | ✅ DONE (iter 3) |

---

## References
- Karp, R.M. (1972). "Reducibility Among Combinatorial Problems"
- Garey, M.R. & Johnson, D.S. (1979). "Computers and Intractability"
- Lucas, A. (2014). "Ising formulations of many NP problems" (arXiv:1302.5843)
- Glover, F. & Kochenberger, G. (2019). "A Tutorial on Formulating and Using QUBO Models"
