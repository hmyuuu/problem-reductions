# Model Proposal: Pathwidth

## Problem Definition

**Pathwidth (Path Decomposition)**

Given an undirected graph G = (V, E) and an integer k, determine whether G has pathwidth ≤ k. Equivalently, find a path decomposition of G with width ≤ k.

A path decomposition of G is a sequence of "bags" B₁, B₂, ..., Bₘ where:
- Each bag Bᵢ ⊆ V
- Every vertex v ∈ V appears in at least one bag
- For every edge (u,v) ∈ E, some bag contains both u and v
- For every vertex v, the bags containing v form a contiguous subsequence
- Width = max(|Bᵢ|) - 1

Path decomposition is a special case of tree decomposition where the underlying tree is a path.

- **Category:** graph (structural parameter)
- **Reference:** Robertson & Seymour (1983); Kinnersley (1992)
- **Complexity:** NP-complete (decision version)
- **Problem type:** Satisfaction (Metric = bool) — does pw(G) ≤ k?

## Why Include

1. **Already computed in codebase:** `src/rules/unitdiskmapping/pathdecomposition.rs` computes pathwidth — this formalizes it as an NP-hard problem model.
2. **Bounds BDD size:** BDD size for a function is bounded by 2^(pathwidth of its variable interaction graph). This is the tightest known structural bound.
3. **Bounds DD width:** Minimum exact MDD width = pathwidth + 1 of the constraint interaction graph.
4. **Relates to Treewidth:** pw(G) ≥ tw(G) always, and pw(G) ≤ tw(G) · O(log n). The two parameters form a natural pair.
5. **Equivalent to several other problems:** Pathwidth = node search number = vertex separation number = interval thickness - 1.

## Variables

Encoding as vertex elimination ordering on a path:
- Variables define a linear arrangement of vertices (permutation)
- Count: |V| (one per vertex for position in the linear order)
- Per-variable domain: {0, 1, ..., |V|-1}
- Pathwidth = max vertex separation in the ordering

Alternative: interval model
- Each vertex v gets an interval [lᵥ, rᵥ] on the real line
- Edges (u,v) require interval overlap
- Pathwidth = max clique size of the interval graph - 1

## Schema

| Field | Description |
|-------|-------------|
| `graph` | The graph G |
| `k` | Target pathwidth (for decision version) |

## Example Instance

```
Graph: Path P₄ = V={0,1,2,3}, E={(0,1),(1,2),(2,3)}
Pathwidth = 1 (same as treewidth for paths)
Path decomposition: bags {0,1}, {1,2}, {2,3}

Graph: Cycle C₆ = V={0,...,5}
Pathwidth = 2 (one more than treewidth = 2)
Path decomposition: {0,1,5}, {1,2,5}, {2,3,4}, {3,4,5} — width 2

Graph: Complete graph K₄
Pathwidth = 3 = n-1 (same as treewidth)
Only one bag needed: {0,1,2,3}

Graph: 3×3 Grid
Pathwidth = 3 (treewidth = 2)
This demonstrates pw > tw gap: grid has small treewidth but larger pathwidth
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| Pathwidth → Treewidth | Trivial | Every path decomposition is a tree decomposition; pw(G) ≥ tw(G) |
| Pathwidth → ILP | Known | Linear ordering variables + separation counting |
| Pathwidth ↔ MinWidthDD | Equivalence | Minimum DD width for graph constraints = pw + 1 |
| Pathwidth → IntervalGraphCompletion | Known | pw(G) = min interval thickness over all interval supergraphs |

## Connection to Existing Codebase

The codebase already has a working pathwidth computation:
- `src/rules/unitdiskmapping/pathdecomposition.rs` — heuristic pathwidth computation
- Used in UnitDiskGraph → GridGraph mapping pipeline
- Used to determine grid embedding quality

Formalizing Pathwidth as a problem model would:
- Expose the existing computation as a first-class NP-hard problem
- Enable reduction testing (Pathwidth → Treewidth, Pathwidth → ILP)
- Connect the UnitDiskGraph mapping infrastructure to the reduction network

## Relationship to Treewidth

| Property | Pathwidth | Treewidth |
|----------|-----------|-----------|
| Decomposition shape | Path (linear) | Tree (branching) |
| Width | Always ≥ treewidth | Always ≤ pathwidth |
| Bounds BDD size | 2^pw | — |
| Bounds MDD size | — | 2^tw |
| Bounds tensor contraction | — | 2^tw |
| For trees | = ⌊log₂ n⌋ | = 1 |
| For grids (n×n) | = n | = n |
| For planar graphs | ≤ O(√n) | ≤ O(√n) |

## Difficulty: Tier 2-3

- Pathwidth infrastructure already exists in the codebase (can wrap/reuse)
- Linear ordering formulation is simpler than tree decomposition
- The decision version is well-studied
- Connecting to existing pathdecomposition.rs provides immediate value
- Simpler than Treewidth since path decomposition structure is linear (no branching)

## References

1. **Robertson, N. & Seymour, P.D.** (1983). "Graph minors. I. Excluding a forest." *Journal of Combinatorial Theory, Series B*, 35(1):39–61. DOI: [10.1016/0095-8956(83)90079-5](https://doi.org/10.1016/0095-8956(83)90079-5)
   — Introduces pathwidth; first paper in the Graph Minors series.

2. **Kinnersley, N.G.** (1992). "The vertex separation number of a graph equals its path-width." *Information Processing Letters*, 42(6):345–350. DOI: [10.1016/0020-0190(92)90234-M](https://doi.org/10.1016/0020-0190(92)90234-M)
   — Proves the equivalence between vertex separation number and pathwidth.

3. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   — Proves NP-completeness of treewidth (and pathwidth) decision problems.

4. **Bodlaender, H.L.** (1998). "A partial k-arboretum of graphs with bounded treewidth." *Theoretical Computer Science*, 209(1–2):1–45. DOI: [10.1016/S0304-3975(97)00228-4](https://doi.org/10.1016/S0304-3975(97)00228-4)
   — Comprehensive survey of treewidth/pathwidth bounds for graph classes.

5. **Korach, E. & Solel, N.** (1993). "Tree-width, path-width, and cutwidth." *Discrete Applied Mathematics*, 43(1):97–101. DOI: [10.1016/0166-218X(93)90171-J](https://doi.org/10.1016/0166-218X(93)90171-J)
   — Establishes relationships between pathwidth, treewidth, and cutwidth.

6. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)
   — Connects pathwidth to minimum DD width for constraint interaction graphs.
