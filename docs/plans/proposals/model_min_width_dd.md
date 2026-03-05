# Model Proposal: MinWidthDecisionDiagram

## Problem Definition

**Minimum Width Decision Diagram**

Given a set of constraints C over n discrete variables (defining a feasible set S ⊆ D₁ × D₂ × ... × Dₙ) and an integer w, determine whether there exists an exact MDD (Multi-valued Decision Diagram) representing S with width at most w.

The width of an MDD is the maximum number of nodes in any single layer (one layer per variable).

- **Category:** structural (decision diagram)
- **Reference:** Bergman et al. (2016). "Decision Diagrams for Optimization." Springer.
- **Complexity:** NP-hard for most interesting constraint sets
- **Problem type:** Satisfaction (Metric = bool) — does a width-w exact MDD exist?

## Why Include

1. **Core DD concept:** Width is THE key parameter controlling DD size, memory, and bound quality.
2. **Connects to Pathwidth:** The minimum width of an exact MDD equals the pathwidth of the constraint interaction graph — creating a direct bridge between DD theory and graph structural parameters.
3. **Bridges theory and practice:** Relaxed DDs (used for bounds in optimization) trade exactness for width bounds. Understanding the minimum exact width tells us when relaxation is necessary.
4. **Codebase relevance:** The existing `pathdecomposition.rs` already computes pathwidth, which IS this problem on the constraint graph.

## Variables

- **Encoding:** Variable ordering (permutation) + layer merging decisions
- The minimum width depends on the variable ordering (like BDD variable ordering)
- For a fixed ordering, the exact MDD is unique (after reduction)
- **Count:** n (permutation) — the width is determined by the ordering

## Schema

| Field | Description |
|-------|-------------|
| `constraints` | Set of constraints defining the feasible set (e.g., list of allowed tuples, or algebraic constraints) |
| `num_variables` | Number of discrete variables n |
| `domains` | Domain size for each variable |
| `target_width` | Maximum allowed MDD width w |

## Example Instance

```
Constraints: AllDifferent(x₁, x₂, x₃), domains = {0,1,2}
n = 3, target_width = 3

With ordering (x₁, x₂, x₃):
  Layer 1: 3 nodes (for x₁ ∈ {0,1,2})
  Layer 2: 6 nodes (each x₁ value × 2 remaining for x₂)  → width = 6 > 3, NO

With better ordering tricks? Still need width ≥ 3 for this constraint.
Actually AllDifferent on 3 vars needs width = max(3, 2·1) = 3 → YES

Simple example: x₁ + x₂ ≤ 2, domains = {0,1,2}
n = 2, target_width = 2
Layer 1: 3 nodes → width already 3 > 2 → NO (minimum width = 3)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| MinWidthDD ↔ Pathwidth | Equivalence | Minimum DD width on constraint graph = pathwidth of the primal graph |
| MinWidthDD → ILP | New | Encode ordering + width counting as ILP |
| BDDVariableOrdering → MinWidthDD | Specialization | BDD is binary MDD; ROBDD size relates to width via Shannon expansion |

## Connection to Existing Codebase

- **`pathdecomposition.rs`** already solves this problem implicitly — pathwidth of a graph equals the minimum DD width for constraint satisfaction on that graph
- Relaxed DDs (Bergman et al.) bound the width and merge nodes — this is the problem of determining WHEN merging is needed
- GenericTensorNetworks.jl uses DD width as a proxy for computational cost

## Difficulty: Tier 4

- Abstract constraint representation is complex to encode generically
- Relationship to pathwidth makes it partially redundant with Pathwidth model
- Most useful as a theoretical bridge rather than standalone problem
- Could be implemented as a thin wrapper over Pathwidth for graph-based constraints

## References

1. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)
   — Comprehensive monograph on DD-based optimization; covers exact, relaxed, and restricted DDs and width control.

2. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2014). "Optimization bounds from binary decision diagrams." *INFORMS Journal on Computing*, 26(2):253–268. DOI: [10.1287/ijoc.2013.0561](https://doi.org/10.1287/ijoc.2013.0561)
   — Shows how relaxed DDs with bounded width provide optimization bounds tighter than LP.

3. **Hadzic, T., Hooker, J.N. & Tiedemann, P.** (2008). "Approximate compilation of constraints into multivalued decision diagrams." *Proc. 14th International Conference on Principles and Practice of Constraint Programming (CP 2008)*, LNCS 5202, pp. 448–462. Springer. DOI: [10.1007/978-3-540-85958-1_30](https://doi.org/10.1007/978-3-540-85958-1_30)
   — Approximate MDD compilation trading exactness for bounded width.

4. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   — Proves NP-completeness of treewidth/pathwidth computation, which bounds DD width.
