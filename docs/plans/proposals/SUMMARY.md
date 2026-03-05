# Final Research Summary & Priority Guide

> Generated: 2026-02-16 | Iterations: 1-9 (Ralph Loop)

## Overview

This research identified **27 new problem models** (+ 2 SKIP/not-separate) and **~37 new reductions** to add to the `problem-reductions` codebase, which currently has 18 problems and 47 reduction edges. Full implementation would yield **~43 problems** and **~91 reduction edges**, completing all of Karp's 21 NP-complete problems plus DD-related structural problems.

## Priority-Ranked Implementation Roadmap

### 🟢 P0: Quick Wins (< 1 day each, high value)

These missing cross-reductions between **EXISTING** problems should be added first:

| # | Reduction | Why |
|---|-----------|-----|
| M-1 | **MaxClique ↔ MIS** | Most fundamental equivalence in combinatorics. Both exist. Complement graph. |
| M-2 | **HamiltonianCycle → TSP** | Most famous reduction in CS. Both exist. Trivial. |
| M-3 | **DominatingSet → SetCovering** | Natural graph↔set connection. Both exist. |

### 🟡 P1: Tier 1 — Easy Models (1-2 days each)

| # | Problem | Category | Karp # | Key Reduction |
|---|---------|----------|--------|---------------|
| 1 | **SubsetSum** | number (NEW) | #18 | → ILP, → QUBO |
| 2 | **Partition** | number | #20 | → SubsetSum, → QUBO |
| 3 | **HittingSet** | set | #15 | ↔ SetCovering, → ILP |
| 4 | **ExactCover** | set | #14 | → SetCovering, → ILP |

### 🟠 P2: Tier 2 — Easy-Moderate (2-3 days each)

| # | Problem | Category | Karp # | Key Reduction |
|---|---------|----------|--------|---------------|
| 5 | **Knapsack** | number | #18+ | → ILP, → QUBO |
| 6 | **CliqueCover** | graph | #13 | ↔ KColoring (complement) |
| 7 | **MaxSAT** | satisfiability | — | → QUBO, ← SAT |
| 8 | **EdgeColoring** | graph | — | → KColoring (line graph) |
| 9 | **Max k-Cut** | graph | — | Generalizes MaxCut to k partitions, → QUBO |

### 🔴 P3: Tier 3 — Moderate (3-5 days each)

| # | Problem | Category | Karp # | Challenge |
|---|---------|----------|--------|-----------|
| 10 | **3DMatching** | set | #17 | New data structure (triples) |
| 11 | **SteinerTree** | graph | #16 | Edge-based vars, connectivity check |
| 12 | **LongestPath** | graph | — | Path validity, BFS/DFS |
| 13 | **MinimumBisection** | graph | — | Equal partition constraint → QUBO |
| 14 | **MinimalMaximalMatching** | graph | — | Maximality check in evaluate() |
| 15 | **Treewidth** | graph (structural) | — | Extends existing pathdecomposition.rs; bounds DD/tensor perf |
| 16 | **Pathwidth** | graph (structural) | — | Already computed in codebase; formalizes as NP-hard problem |
| 17 | **BDDVariableOrdering** | structural (DD) | — | Meta-problem: optimizing BDD size is NP-complete |

### ⚫ P4: Tier 4 — Hard (5+ days, new infrastructure)

| # | Problem | Category | Karp # | Challenge |
|---|---------|----------|--------|-----------|
| 18 | **FeedbackVertexSet** | graph | #7 | Directed graph + cycle detection |
| 19 | **FeedbackArcSet** | graph | #8 | Directed graph + cycle detection |
| 20 | **JobSequencing** | number | #19 | Scheduling feasibility check |
| 21 | **MultiwayCut** | graph | — | k-terminal connectivity |
| 22 | **GraphPartitioning** | graph | — | k-way equal partition |
| 23 | **QuadraticAssignment** | optimization | — | n² variables, permutation constraints, QUBO direct |
| 24 | **MinWidthDecisionDiagram** | structural (DD) | — | NP-hard; equivalent to Pathwidth on constraint graph |
| 25 | **ContractionOrdering** | structural (tensor) | — | NP-hard; equivalent to Treewidth of line graph |

### ❌ SKIP / Not Separate

| Problem | Reason |
|---------|--------|
| GraphIsomorphism | NP-intermediate, not NP-complete (Babai 2015) |
| MaxAcyclicSubgraph | Complement of FeedbackArcSet (not a separate problem) |

---

## Impact Summary

| Metric | Current | After P0-P1 | After P0-P2 | After All |
|--------|---------|-------------|-------------|-----------|
| Problems | 18 | 22 | 27 | 43 |
| Karp's 21 | 10/21 | 14/21 | 16/21 | 21/21 |
| Reduction edges | 47 | ~60 | ~72 | ~91 |

---

## Difficulty Assessment (Deep Research)

> Synthesized from 5 parallel agent analyses: codebase calibration, P1-P2 model evaluation, P3 model evaluation, P4 model evaluation, and reduction evaluation.

### 1. Calibration Baseline

In this codebase, **"Easy"** means ~150-200 lines for a model or ~60-110 lines for a reduction, reusing existing graph/set types with simple `evaluate()` logic and identity/complement solution extraction (e.g., MIS, MIS<->VC). **"Hard"** means ~280-400 lines for a model or ~200-450 lines for a reduction, requiring custom data structures, complex mathematical encoding (quadratization, McCormick linearization), and careful auxiliary variable tracking (e.g., ILP at 371 lines, CircuitSAT->SpinGlass at 446 lines). The extreme outlier is UnitDiskMapping at ~9,700 lines across 14 files.

### 2. Master Difficulty Ranking Table

| Rank | Item | Type | Difficulty | Est. Days | Key Risk |
|------|------|------|-----------|-----------|----------|
| | **--- TRIVIAL (1-2/10) ---** | | | | |
| 1 | Partition -> SubsetSum | reduction | 1/10 | 0.25 | Requires both models first |
| 2 | Pathwidth -> Treewidth | reduction | 1.5/10 | 0.25 | Both models must exist; one-way relaxation only |
| 3 | HittingSet (model) | model | 2/10 | 0.5-1 | Exact dual of MinimumSetCovering; naming convention |
| 4 | Partition (model) | model | 2/10 | 0.5-1 | Depends on SubsetSum; trivially derived |
| 5 | MaxClique <-> MIS | cross | 2/10 | 0.5-1 | Need complement graph utility (not yet in codebase) |
| 6 | 3DMatching -> SetPacking | reduction | 2/10 | 0.5 | Index offset mapping (off-by-one risk) |
| 7 | HamiltonianCycle -> TSP | cross | 2.5/10 | 0.5-1 | HamiltonianCycle model does not exist yet |
| 8 | DominatingSet -> SetCovering | cross | 2.5/10 | 0.5-1 | None; both models exist |
| | **--- EASY (3-4/10) ---** | | | | |
| 9 | SubsetSum (model) | model | 3/10 | 1-2 | First `number/` category; new directory scaffolding |
| 10 | ExactCover (model) | model | 3/10 | 1 | SatisfactionProblem marker; test construction |
| 11 | MinimumBisection (model) | model | 3/10 | 1 | Nearly identical to MaxCut + partition balance |
| 12 | HittingSet <-> SetCovering | reduction | 3/10 | 0.5 | Incidence matrix transpose indexing |
| 13 | SubsetSum -> ILP | reduction | 3/10 | 0.5 | Feasibility ILP handling |
| 14 | Partition -> ILP | reduction | 3/10 | 0.5 | Same as SubsetSum -> ILP |
| 15 | ExactCover -> ILP | reduction | 3/10 | 0.5 | Equality constraints |
| 16 | HittingSet -> ILP | reduction | 3/10 | 0.5 | Mirrors SetCovering -> ILP |
| 17 | Knapsack -> ILP | reduction | 3/10 | 0.5 | ObjectiveSense::Maximize validation |
| 18 | MaxClique -> QUBO | cross | 3/10 | 1 | Non-edge enumeration |
| 19 | 3DMatching (model) | model | 3.5/10 | 1-1.5 | New triple-based data structure |
| 20 | MinimalMaximalMatching (model) | model | 3.5/10 | 1-1.5 | Maximality check for edges (follows MaximalIS pattern) |
| 21 | ExactCover -> SetCovering | reduction | 3.5/10 | 0.75 | Relaxation only; must verify exactness in extraction |
| 22 | MaxCut -> QUBO | reduction | 3.5/10 | 0.5 | None; shortcut for existing path |
| 23 | DominatingSet -> SetCovering | cross | 3.5/10 | 0.5 | None; both exist |
| 24 | Knapsack (model) | model | 4/10 | 2 | First optimization in `number/`; QUBO slack vars |
| 25 | JobSequencing (model) | model | 4/10 | 1.5-2 | New `number/` directory; scheduling feasibility |
| 26 | HamiltonianCycle -> TSP | cross | 4/10 | 0.75 | HamCycle model needed; big-M weight choice |
| 27 | FeedbackArcSet -> ILP | reduction | 4/10 | 1 | Directed graph; requires FAS model |
| 28 | FeedbackArcSet (model) | model | 4.5/10 | 1.5-2 | Directed graph (no infra); shares cycle detection w/ FVS |
| 29 | DominatingSet -> QUBO | cross | 4.5/10 | 1.5-2 | Complex neighborhood penalty encoding |
| | **--- MODERATE (5-6/10) ---** | | | | |
| 30 | CliqueCover (model) | model | 5/10 | 2-3 | No complement graph fn; KValue vs usize mismatch |
| 31 | MaxSAT (model) | model | 5/10 | 2-3 | QUBO reduction for general k-clause is complex |
| 32 | Max k-Cut (model) | model | 5/10 | 2-3 | One-hot QUBO encoding; k parameter design |
| 33 | LongestPath (model) | model | 5/10 | 2-3 | Path validity encoding; BFS/DFS connectivity |
| 34 | FeedbackVertexSet (model) | model | 5/10 | 2-3 | No directed graph type; cycle detection needed |
| 35 | FeedbackVertexSet -> ILP | reduction | 5/10 | 1-2 | Two decision vars per constraint; big-M issues |
| 36 | SubsetSum -> QUBO | reduction | 5/10 | 1 | Quadratic expansion sign correctness |
| 37 | Partition -> QUBO | reduction | 5/10 | 1 | Ising-to-QUBO spin substitution |
| 38 | CliqueCover <-> KColoring | reduction | 5/10 | 1 | Complement graph + KValue type mismatch |
| 39 | MaxClique -> QUBO | reduction | 5/10 | 1 | Non-edge enumeration for penalty |
| 40 | SteinerTree (model) | model | 5.5/10 | 3-4 | BFS connectivity check; edge-based vars |
| 41 | GraphPartitioning (model) | model | 5.5/10 | 2-3 | Equal partition constraint; |V| % k != 0 |
| 42 | FeedbackArcSet -> ILP | reduction | 5.5/10 | 1.5 | Ordering-based ILP; directed arcs |
| 43 | EdgeColoring (model) | model | 6/10 | 3-4 | Line graph (new infra); edge-centric variables |
| 44 | Pathwidth (model) | model | 6/10 | 3-4 | Non-binary domains; permutation encoding |
| 45 | DominatingSet -> QUBO | cross | 6/10 | 1.5 | Dense neighborhood penalty expansion |
| 46 | MaxSAT -> QUBO | reduction | 6/10 | 1.5 | Weighted Rosenberg quadratization |
| 47 | SpinGlass -> SAT/MaxSAT | reduction | 6/10 | 1.5 | Ising-to-boolean sign complexity |
| 48 | MultiwayCut (model) | model | 6/10 | 3-4 | Multi-terminal connectivity; ILP flow constraints |
| 49 | QuadraticAssignment (model) | model | 6.5/10 | 3-4 | Permutation matrix; n^2 variables |
| | **--- HARD (7-8/10) ---** | | | | |
| 50 | Treewidth (model) | model | 7/10 | 4-5 | Fill-in graph computation; O(n^3) ILP |
| 51 | Knapsack -> QUBO | reduction | 7/10 | 3 | Binary slack vars; penalty tuning |
| 52 | MinimumBisection -> QUBO | reduction | 7/10 | 2.5 | Dense QUBO from global balance constraint |
| 53 | FeedbackVertexSet -> ILP | reduction | 7/10 | 3 | Two-variable big-M ordering constraints |
| 54 | SAT -> MaxCut | cross | 7.5/10 | 3-4 | Garey-Johnson-Stockmeyer gadget construction |
| 55 | MinWidthDecisionDiagram (model) | model | 8/10 | 7-10 | Needs full MDD construction; abstract constraint repr |
| | **--- VERY HARD (9-10/10) ---** | | | | |
| 56 | BDDVariableOrdering (model) | model | 8.5/10 | 7-10 | Requires full BDD library; novel ILP formulation |
| 57 | SteinerTree -> ILP | reduction | 8.5/10 | 5 | Flow-based connectivity; O(|R|*|E|) variables |
| 58 | Treewidth -> ILP | reduction | 9/10 | 7+ | O(n^3) constraints; fill-propagation; complex extraction |
| 59 | ContractionOrdering (model) | model | 9/10 | 10-15 | Hypergraph extension; tensor contraction tree |

### 3. Infrastructure Gaps

| Gap | Impact | Blocks |
|-----|--------|--------|
| Directed graphs | No `DiGraph` type; `Graph` trait assumes undirected. Can workaround with inline `Vec<(usize, usize)>` arcs | FVS, FAS models |
| Complement graph utility | No `complement()` fn on `SimpleGraph`. ~15 lines to implement | MaxClique<->MIS, CliqueCover<->KColoring |
| Line graph construction | L(G) transformation does not exist | EdgeColoring -> KColoring reduction |
| `number/` model category | No `src/models/number/` directory or `mod.rs` | SubsetSum, Partition, Knapsack, JobSequencing |
| Non-binary BruteForce domains | `dims = vec![n; n]` (permutations) untested at scale | Pathwidth, Treewidth, BDDVariableOrdering |
| BDD/ROBDD library | No Boolean decision diagram infrastructure | BDDVariableOrdering |
| Flow-based ILP pattern | No existing flow-conservation encoding in any ILP reduction | SteinerTree -> ILP |
| Tensor network types | HyperGraph lacks dimension metadata on edges | ContractionOrdering |
| Graph algorithms (BFS/DFS/SCC) | Not exposed beyond petgraph internals | LongestPath, SteinerTree, FVS/FAS cycle detection |

### 4. Recommended Implementation Order

Total estimated effort: **55-80 person-days** for all items.

1. **P0 cross-reductions between existing models** (3 days): MaxClique<->MIS, DominatingSet->SetCovering, MaxCut->QUBO. Implement complement graph utility here.
2. **P1 number category + models** (3-4 days): Create `number/` directory, then SubsetSum, Partition (in that order). Add their trivial ILP reductions.
3. **P1 set models** (2 days): HittingSet, ExactCover + their ILP and SetCovering reductions.
4. **P1 easy graph models** (2 days): MinimumBisection, 3DMatching, MinimalMaximalMatching.
5. **P2 models** (8-12 days): Knapsack (+ ILP reduction), CliqueCover, MaxSAT, Max k-Cut, EdgeColoring.
6. **P2 QUBO reductions batch** (5-7 days): SubsetSum->QUBO, Partition->QUBO, Knapsack->QUBO, MaxSAT->QUBO, MinBisection->QUBO.
7. **Directed graph batch** (5-7 days): FeedbackVertexSet + FeedbackArcSet models (share cycle detection), then both ILP reductions.
8. **P3 moderate models** (8-12 days): LongestPath, SteinerTree (+ILP), Pathwidth, GraphPartitioning, MultiwayCut.
9. **P3 hard models** (8-12 days): Treewidth (+ILP), QuadraticAssignment, JobSequencing.
10. **P4 hard cross-reductions** (4-5 days): SAT->MaxCut, DominatingSet->QUBO, HamiltonianCycle->TSP, SpinGlass->MaxSAT.
11. **P4 very hard models** (20-30 days, consider deferring): BDDVariableOrdering, MinWidthDD, ContractionOrdering.

---

## Complete File Index (54 files)

All files in `docs/plans/proposals/`:

### Models (26 files: 25 proposals + 1 SKIP)
```
model_3d_matching.md               model_longest_path.md
model_bdd_variable_ordering.md     model_max_k_cut.md
model_clique_cover.md              model_max_sat.md
model_contraction_ordering.md      model_maximum_acyclic_subgraph.md
model_edge_coloring.md             model_min_width_dd.md
model_exact_cover.md               model_minimal_maximal_matching.md
model_feedback_arc_set.md          model_minimum_bisection.md
model_feedback_vertex_set.md       model_multiway_cut.md
model_graph_isomorphism_SKIP.md    model_partition.md
model_graph_partitioning.md        model_pathwidth.md
model_hitting_set.md               model_quadratic_assignment.md
model_job_sequencing.md            model_steiner_tree.md
model_knapsack.md                  model_subset_sum.md
model_treewidth.md
```

### Reductions (23 files)
```
reduction_3dmatching_setpacking.md       reduction_maxcut_qubo.md
reduction_cliquecover_kcoloring.md       reduction_maxsat_qubo.md
reduction_exactcover_ilp.md              reduction_minimumbisection_qubo.md
reduction_exactcover_setcovering.md      reduction_missing_cross_reductions.md
reduction_feedbackarcset_ilp.md          reduction_partition_ilp.md
reduction_feedbackvertexset_ilp.md       reduction_partition_qubo.md
reduction_hittingset_ilp.md              reduction_partition_subsetsum.md
reduction_hittingset_setcovering.md      reduction_pathwidth_treewidth.md
reduction_knapsack_ilp.md                reduction_spinglass_sat.md
reduction_knapsack_qubo.md               reduction_steinertree_ilp.md
reduction_subsetsum_ilp.md               reduction_subsetsum_qubo.md
reduction_treewidth_ilp.md
```

### Analyses & Summary (5 files)
```
analysis_decision_diagrams.md      — DD-related NP-hard problems deep dive
analysis_julia_alignment.md        — ProblemReductions.jl comparison
analysis_reduction_network.md      — full proposed reduction graph
SUMMARY.md                         — this file
```

### Tracking (outside proposals/)
```
docs/plans/tasks.md                — master task list with checkboxes
.claude/worklog-2026-02-16.md      — session work log
```

---

## Research Sources

### Primary
- Karp, R.M. (1972). "Reducibility Among Combinatorial Problems"
- Garey, M.R. & Johnson, D.S. (1979). "Computers and Intractability"
- Lucas, A. (2014). "Ising formulations of many NP problems" [arXiv:1302.5843]

### Secondary
- Glover & Kochenberger (2019). QUBO Tutorial
- Bollig & Wegener (1996). BDD variable ordering NP-completeness
- Arnborg, Corneil, Proskurowski (1987). Treewidth NP-completeness
- Bergman et al. (2016). "Decision Diagrams for Optimization"
- Babai, L. (2015). Graph isomorphism in quasipolynomial time
- Minato (1993). Zero-Suppressed BDDs
- ProblemReductions.jl — Julia reference implementation
