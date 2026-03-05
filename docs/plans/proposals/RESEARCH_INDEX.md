# Research Index: All Proposals & Complexity Notes

> Generated: 2026-02-27 | Based on 54 proposal files from 2026-02-16 research

## Overview

This index links all proposal files, the Typst complexity research notes, and the deep-dive research files produced by parallel research agents.

## Master Typst Document

**`complexity_research_notes.typ`** — Comprehensive Typst document covering all 25 proposed problems with:
- Formal definitions
- Complexity classifications (NP-c/NP-h, strong/weak, approximation)
- QUBO and ILP reduction formulations
- Key references with citations
- Summary tables (Karp's 21 completion, infrastructure gaps)

## Deep-Dive Research Files (from parallel agents)

| File | Scope | Lines | Status |
|------|-------|-------|--------|
| `research_number_problems.md` | SubsetSum, Partition, Knapsack, JobSequencing | 681 | ✅ Complete |
| `research_set_problems.md` | HittingSet, ExactCover, 3DMatching | 808 | ✅ Complete |
| `research_graph_problems_karp.md` | CliqueCover, FVS, FAS, SteinerTree | 870 | ✅ Complete |
| `research_graph_problems_extended.md` | Bisection, EdgeColoring, MaxkCut, LongestPath, MinMaxMatching, MultiwayCut, GraphPartitioning, QAP | 1495 | ✅ Complete |
| `research_structural_problems.md` | Treewidth, Pathwidth, BDDVarOrder, ContractionOrdering, MinWidthDD, MaxSAT | 1166 | ✅ Complete |
| `research_qubo_ilp_reductions.md` | All QUBO and ILP reduction formulations | 907 | ✅ Complete |

## Proposal Files by Category

### Number Problems (`number/` — NEW category)
| Problem | Model File | Reductions | Karp # | Tier |
|---------|-----------|------------|--------|------|
| SubsetSum | `model_subset_sum.md` | → ILP, → QUBO | #18 | 1 |
| Partition | `model_partition.md` | → SubsetSum, → ILP, → QUBO | #20 | 1 |
| Knapsack | `model_knapsack.md` | → ILP, → QUBO | #18+ | 2 |
| JobSequencing | `model_job_sequencing.md` | → ILP | #19 | 3 |

### Set Problems (`set/` — extensions)
| Problem | Model File | Reductions | Karp # | Tier |
|---------|-----------|------------|--------|------|
| HittingSet | `model_hitting_set.md` | ↔ SetCovering, → ILP | #15 | 1 |
| ExactCover | `model_exact_cover.md` | → SetCovering, → ILP, → SAT | #14 | 1 |
| 3DMatching | `model_3d_matching.md` | → ExactCover, → SetPacking | #17 | 3 |

### Graph Problems (`graph/`)
| Problem | Model File | Reductions | Karp # | Tier |
|---------|-----------|------------|--------|------|
| CliqueCover | `model_clique_cover.md` | ↔ KColoring | #13 | 2 |
| MinimumBisection | `model_minimum_bisection.md` | → QUBO, → ILP | — | 2 |
| EdgeColoring | `model_edge_coloring.md` | → KColoring (line graph) | — | 2 |
| MaxkCut | `model_max_k_cut.md` | → QUBO, → ILP | — | 2 |
| LongestPath | `model_longest_path.md` | → ILP | — | 2-3 |
| MinMaxMatching | `model_minimal_maximal_matching.md` | → QUBO, → ILP | — | 2 |
| FeedbackVertexSet | `model_feedback_vertex_set.md` | → ILP | #7 | 3 |
| FeedbackArcSet | `model_feedback_arc_set.md` | → ILP | #8 | 3 |
| SteinerTree | `model_steiner_tree.md` | → ILP | #16 | 3 |
| MultiwayCut | `model_multiway_cut.md` | → ILP | — | 3 |
| GraphPartitioning | `model_graph_partitioning.md` | → QUBO, → ILP | — | 3 |

### Optimization Problems
| Problem | Model File | Reductions | Tier |
|---------|-----------|------------|------|
| QAP | `model_quadratic_assignment.md` | → QUBO, → ILP | 3 |

### Satisfiability Problems
| Problem | Model File | Reductions | Tier |
|---------|-----------|------------|------|
| MaxSAT | `model_max_sat.md` | → QUBO, → ILP | 2 |

### Structural / DD Problems
| Problem | Model File | Reductions | Tier |
|---------|-----------|------------|------|
| Treewidth | `model_treewidth.md` | → ILP | 3 |
| Pathwidth | `model_pathwidth.md` | → Treewidth | 3 |
| BDDVarOrdering | `model_bdd_variable_ordering.md` | → ILP | 4 |
| ContractionOrdering | `model_contraction_ordering.md` | ↔ Treewidth | 4 |
| MinWidthDD | `model_min_width_dd.md` | ↔ Pathwidth | 4 |

### SKIP
| Problem | File | Reason |
|---------|------|--------|
| GraphIsomorphism | `model_graph_isomorphism_SKIP.md` | NP-intermediate (Babai 2015) |
| MaxAcyclicSubgraph | `model_maximum_acyclic_subgraph.md` | Complement of FAS, not separate |

### Cross-Reductions (existing problems)
| Reduction | File | Priority |
|-----------|------|----------|
| MaxClique ↔ MIS | `reduction_missing_cross_reductions.md` | HIGH |
| HamiltonianCycle → TSP | same | HIGH |
| DominatingSet → SetCovering | same | MEDIUM |
| MaxClique → QUBO | same | MEDIUM |
| DominatingSet → QUBO | same | LOW |
| SAT → MaxCut | same | LOW |
| SpinGlass → MaxSAT | `reduction_spinglass_sat.md` | MEDIUM |

### Analysis Files
| File | Content |
|------|---------|
| `analysis_julia_alignment.md` | ProblemReductions.jl parity comparison |
| `analysis_reduction_network.md` | Full proposed reduction graph visualization |
| `analysis_decision_diagrams.md` | DD-related NP-hard problems deep dive |
| `SUMMARY.md` | Final research summary with priority guide |
| `rank.md` | 59-item difficulty ranking |

## Difficulty Distribution

| Tier | Count | Examples |
|------|-------|---------|
| Trivial (1-2/10) | 8 | Partition→SubsetSum, MaxClique↔MIS |
| Easy (3-4/10) | 21 | SubsetSum, ExactCover, most ILP reductions |
| Moderate (5-6/10) | 20 | CliqueCover, MaxSAT, FVS/FAS |
| Hard (7-8/10) | 6 | Treewidth, SAT→MaxCut |
| Very Hard (9-10/10) | 4 | BDDVarOrdering, Treewidth→ILP, ContractionOrdering |

## Implementation Impact

| Metric | Current | After P0-P1 | After P0-P2 | After All |
|--------|---------|-------------|-------------|-----------|
| Problems | 22 | 26 | 31 | 47 |
| Karp's 21 | 10/21 | 14/21 | 16/21 | 21/21 |
| Reduction edges | 47 | ~60 | ~72 | ~91 |
| Estimated effort | — | 5-8 days | 15-20 days | 55-80 days |
