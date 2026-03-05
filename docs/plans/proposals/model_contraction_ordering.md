# Model Proposal: ContractionOrdering

## Problem Definition

**Optimal Tensor Network Contraction Ordering**

Given a tensor network represented as a hypergraph H = (V, E) where:
- Each vertex v ∈ V is a tensor with associated dimensions
- Each hyperedge e ∈ E represents a shared index with dimension dₑ

Find a contraction ordering (binary tree of pairwise contractions) that minimizes the total computational cost (sum or max of intermediate tensor sizes).

- **Category:** optimization (structural)
- **Reference:** Markov & Shi (2008). "Simulating quantum computation by contracting tensor networks."
- **Complexity:** NP-hard
- **Problem type:** Optimization (Minimize total contraction cost)

## Why Include

1. **GenericTensorNetworks.jl connection:** The companion Julia package solves NP-hard problems via tensor network contraction. The contraction ordering ITSELF is NP-hard — the solver needs to solve an NP-hard problem to efficiently solve NP-hard problems!
2. **Equivalent to Treewidth:** Optimal contraction ordering on the line graph ↔ treewidth of the original graph. This creates a deep structural connection.
3. **Practical impact:** The difference between good and bad contraction orderings is exponential — from feasible to infeasible computation.
4. **Bridges communities:** Connects quantum computing, tensor networks, graphical models, and combinatorial optimization.

## Variables

- **Encoding:** Binary contraction tree over |V| tensors
- **Count:** |V| - 1 contractions (each step merges two tensors)
- **Alternative encoding:** Vertex elimination ordering on the line graph
  - |V| variables, domain {0, ..., |V|-1}
  - Elimination order determines contraction sequence
- **Objective:** Minimize Σ (intermediate tensor sizes) or minimize max intermediate tensor size

## Schema

| Field | Description |
|-------|-------------|
| `hypergraph` | Tensor network structure (vertices = tensors, hyperedges = shared indices) |
| `dimensions` | Dimension of each hyperedge/index |
| `objective` | "total_cost" (sum of FLOPS) or "max_width" (space complexity) |

## Example Instance

```
Matrix chain: A(10×30) × B(30×5) × C(5×60)
Hypergraph: V={A,B,C}, edges: {A,B} dim 30, {B,C} dim 5, plus external indices

Ordering 1: (A×B)×C
  A×B: cost = 10×30×5 = 1500, result 10×5
  ×C: cost = 10×5×60 = 3000
  Total: 4500

Ordering 2: A×(B×C)
  B×C: cost = 30×5×60 = 9000, result 30×60
  A×: cost = 10×30×60 = 18000
  Total: 27000

Optimal: Ordering 1 (cost 4500 vs 27000)

Tensor network for a 4-vertex graph problem:
  Hypergraph with 4 tensors (one per vertex), edges from graph edges
  Contraction ordering = tree decomposition of the graph
  Optimal cost = 2^(treewidth+1) per contraction step
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| ContractionOrdering ↔ Treewidth | Structural equivalence | Optimal max-width contraction = treewidth of line graph; optimal contraction tree = tree decomposition |
| ContractionOrdering → ILP | New | Ordering variables + cost tracking; similar to scheduling ILP |
| MatrixChainMultiplication → ContractionOrdering | Special case | Matrix chain is the 1D (path) case; solvable in O(n³) by DP, but general case is NP-hard |

## Connection to Existing Codebase

- **GenericTensorNetworks.jl** is the primary consumer: it uses contraction ordering to solve MIS, MaxCut, SAT, etc. via tensor networks
- **Treewidth** (proposed) is the graph-theoretic equivalent — implementing both creates a strong connection
- The existing **pathdecomposition.rs** computes pathwidth, which bounds contraction cost for 1D layouts

## Difficulty: Tier 4

- Hypergraph data structure needed (not currently in codebase; existing `HyperGraph` is for set problems)
- Cost computation requires tracking intermediate tensor dimensions
- The "max-width" variant reduces to Treewidth (simpler)
- The "total-cost" variant is strictly harder (no clean graph parameter)
- Very specialized audience (quantum computing, tensor networks)
- Better as a theoretical connection than a standalone implementation target

## References

1. **Markov, I.L. & Shi, Y.** (2008). "Simulating quantum computation by contracting tensor networks." *SIAM Journal on Computing*, 38(3):963–981. DOI: [10.1137/050644756](https://doi.org/10.1137/050644756)
   — Foundational paper proving contraction cost is bounded by 2^(treewidth); establishes the treewidth connection.

2. **Gray, J. & Kourtis, S.** (2021). "Hyper-optimized tensor network contraction." *Quantum*, 5:410. DOI: [10.22331/q-2021-03-15-410](https://doi.org/10.22331/q-2021-03-15-410)
   — State-of-the-art randomized protocols for finding high-quality contraction paths; >10,000× speedup for Sycamore circuits.

3. **Pfeifer, R.N.C., Haegeman, J. & Verstraete, F.** (2014). "Faster identification of optimal contraction sequences for tensor networks." *Physical Review E*, 90(3):033315. DOI: [10.1103/PhysRevE.90.033315](https://doi.org/10.1103/PhysRevE.90.033315). arXiv: [1304.6112](https://arxiv.org/abs/1304.6112)
   — Modified search algorithm with enhanced pruning for exact optimal contraction sequences.

4. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   — NP-completeness of treewidth, which is equivalent to optimal contraction width.

5. **Bodlaender, H.L.** (1998). "A partial k-arboretum of graphs with bounded treewidth." *Theoretical Computer Science*, 209(1–2):1–45. DOI: [10.1016/S0304-3975(97)00228-4](https://doi.org/10.1016/S0304-3975(97)00228-4)
   — Survey of treewidth theory; relevant because contraction ordering = treewidth of line graph.
