# Deep Research: NP-Hard Problems Related to Decision Diagrams

## Overview

Decision diagrams (BDDs, MDDs, ZDDs) are both **tools for solving** NP-hard problems AND **sources of** NP-hard problems themselves. This analysis covers both directions.

---

## Part A: NP-Hard Problems ABOUT Decision Diagrams

These are computational problems where the decision diagram itself is the subject.

### 1. Optimal Variable Ordering for BDDs (OBDD Minimization)

**Problem:** Given a Boolean function f and a target size k, does there exist a variable ordering π such that the ROBDD for f under π has at most k nodes?

- **Complexity:** NP-complete (Bollig & Wegener 1996)
- **Even harder:** Inapproximable within constant factor unless P=NP
- **Why it matters:** The size of an OBDD can vary exponentially with ordering. Finding the best ordering is itself NP-hard.
- **Reference:** Bollig & Wegener (1996). "Improving the variable ordering of OBDDs is NP-complete."

**Potential model:**
```
struct BDDMinimization {
    truth_table: Vec<bool>,     // Boolean function as truth table (2ⁿ entries)
    num_variables: usize,       // n
    target_size: usize,         // k
}
```
- Variables: n! possible orderings → encode as permutation (like QAP)
- Metric: bool (satisfaction: can we achieve size ≤ k?)
- Reduction: relates to Optimal Linear Arrangement and Minimum Cut Width

### 2. Minimum Width Decision Diagram

**Problem:** Given a constraint set (or optimization problem), construct a decision diagram of minimum width that exactly represents the feasible set.

- **Complexity:** NP-hard for most interesting constraint sets
- **Why it matters:** Width controls both space and bound quality
- **Connection:** Width of exact DD = pathwidth of constraint interaction graph

### 3. Treewidth / Pathwidth Computation

**Problem:** Given a graph G and integer k, does G have treewidth (or pathwidth) ≤ k?

- **Complexity:** NP-complete (Arnborg et al. 1987)
- **Why deeply connected to DDs:**
  - BDD size is bounded by 2^(pathwidth)
  - MDD size is bounded by 2^(treewidth)
  - Tensor network contraction cost is bounded by 2^(treewidth)
  - The codebase already uses pathwidth in UnitDiskGraph mapping!
- **Reference:** Arnborg, Corneil, Proskurowski (1987)

**Potential model:**
```
struct Treewidth {
    graph: SimpleGraph,
    k: usize,                  // target width
}
```
- Variables: tree decomposition encoding (complex)
- Metric: bool (does treewidth ≤ k?)
- This is particularly relevant since the codebase already has `pathdecomposition.rs`!

### 4. Optimal Tensor Network Contraction Order

**Problem:** Given a tensor network (hypergraph with tensor dimensions), find the contraction ordering that minimizes total computational cost.

- **Complexity:** NP-hard
- **Connection:** Equivalent to finding minimum-width tree decomposition of the line graph
- **Why relevant:** GenericTensorNetworks.jl (companion to ProblemReductions.jl) solves NP-hard problems via tensor networks. The contraction ordering itself is NP-hard!
- **Reference:** Markov & Shi (2008)

---

## Part B: NP-Hard Problems SOLVED USING Decision Diagrams

Decision diagrams are used as solution tools for these problems (already in or proposed for codebase):

| Problem | DD Role | DD Type |
|---------|---------|---------|
| **MaximumIndependentSet** | Relaxed DD gives bounds tighter than LP | MDD |
| **MaxCut** | Relaxed DD for strong relaxation bounds | MDD |
| **TSP** | Peel-and-bound DD approach | MDD |
| **SetCovering/SetPacking** | ZDD represents all feasible set families | ZDD |
| **Satisfiability** | BDD represents solution space | BDD |
| **ExactCover** | ZDD naturally represents disjoint set families | ZDD |
| **Knapsack** | DD-based dynamic programming | MDD |
| **Graph Coloring** | DD for constraint propagation | MDD |

### ZDD-Native Problems

Zero-Suppressed Decision Diagrams (ZDDs) are particularly natural for **set family** problems:

- **ExactCover** — ZDD represents all exact covers compactly
- **SetPacking/SetCovering** — ZDD represents all feasible selections
- **HittingSet** — dual of SetCovering, ZDD on dual sets
- **3DMatching** — ZDD on triple selections

These are already proposed in our model proposals but noting the ZDD connection adds value.

---

## Part C: Recommendations for the Codebase

### High Priority: Treewidth (Tier 2-3)

**Why:** The codebase already has `src/rules/unitdiskmapping/pathdecomposition.rs` which computes pathwidth. Treewidth is the natural generalization.

- Treewidth computation is NP-hard
- Treewidth bounds DD size and tensor network contraction cost
- Directly connects to GenericTensorNetworks.jl ecosystem
- Could be modeled as: given graph G and k, is tw(G) ≤ k?

**Reductions:**
- Treewidth → ILP (known formulations exist)
- Pathwidth → Treewidth (pathwidth ≥ treewidth always)
- Treewidth relates to MinimumBisection (tw ≤ n/3 · bisection_width + O(1))

### Medium Priority: BDD Variable Ordering (Tier 3-4)

- Interesting meta-problem (optimizing the solver itself)
- Relates to Minimum Linear Arrangement, Bandwidth Minimization
- But may be too "meta" for a problem-reductions library

### Low Priority: Contraction Ordering (Tier 4)

- Very specialized to tensor network community
- Complex model (hypergraph + cost function)
- Better suited as a separate tool than a generic NP-hard problem model

---

## Summary Table

| Problem | Complexity | DD Connection | Priority | Already in Codebase? |
|---------|-----------|---------------|----------|---------------------|
| BDD Variable Ordering | NP-complete | IS a DD problem | Medium | No |
| Treewidth | NP-complete | Bounds DD size | **High** | Pathwidth exists |
| Pathwidth | NP-complete | Bounds BDD size | **High** | `pathdecomposition.rs` exists |
| Contraction Ordering | NP-hard | = Treewidth of line graph | Low | No |
| Min-Width DD | NP-hard | IS a DD problem | Low | No |

## References

1. **Bollig, B. & Wegener, I.** (1996). "Improving the variable ordering of OBDDs is NP-complete." *IEEE Transactions on Computers*, 45(9):993–1002. DOI: [10.1109/12.537122](https://doi.org/10.1109/12.537122)

2. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM J. Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)

3. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)

4. **Minato, S.** (1993). "Zero-Suppressed BDDs for Set Manipulation in Combinatorial Problems." *Proc. DAC '93*, pp. 272–277. DOI: [10.1145/157485.164890](https://doi.org/10.1145/157485.164890)

5. **Markov, I.L. & Shi, Y.** (2008). "Simulating quantum computation by contracting tensor networks." *SIAM J. Computing*, 38(3):963–981. DOI: [10.1137/050644756](https://doi.org/10.1137/050644756)

6. **Coudert, O.** (1997). "Solving graph optimization problems with ZBDDs." *Proc. European Design and Test Conference (ED&TC '97)*. DOI: [10.1109/EDTC.1997.582363](https://doi.org/10.1109/EDTC.1997.582363)

7. **Bryant, R.E.** (1986). "Graph-based algorithms for Boolean function manipulation." *IEEE Trans. Computers*, 35(8):677–691. DOI: [10.1109/TC.1986.1676819](https://doi.org/10.1109/TC.1986.1676819)

8. **Bergman, D. et al.** (2014). "Optimization bounds from binary decision diagrams." *INFORMS J. Computing*, 26(2):253–268. DOI: [10.1287/ijoc.2013.0561](https://doi.org/10.1287/ijoc.2013.0561)

9. **Gray, J. & Kourtis, S.** (2021). "Hyper-optimized tensor network contraction." *Quantum*, 5:410. DOI: [10.22331/q-2021-03-15-410](https://doi.org/10.22331/q-2021-03-15-410)

10. **Pfeifer, R.N.C., Haegeman, J. & Verstraete, F.** (2014). "Faster identification of optimal contraction sequences for tensor networks." *Phys. Rev. E*, 90(3):033315. DOI: [10.1103/PhysRevE.90.033315](https://doi.org/10.1103/PhysRevE.90.033315)
