# Model Proposal: Treewidth

## Problem Definition

**Treewidth (Tree Decomposition)**

Given an undirected graph G = (V, E) and an integer k, determine whether G has treewidth ≤ k. Equivalently, find a tree decomposition of G with width ≤ k.

A tree decomposition of G is a tree T where:
- Each node of T is a "bag" Bᵢ ⊆ V
- Every vertex v ∈ V appears in at least one bag
- For every edge (u,v) ∈ E, some bag contains both u and v
- For every vertex v, the bags containing v form a connected subtree of T
- Width = max(|Bᵢ|) - 1

- **Category:** graph (structural parameter)
- **Reference:** Robertson & Seymour (1986); Arnborg et al. (1987)
- **Complexity:** NP-complete (decision version)
- **Problem type:** Satisfaction (Metric = bool) — does tw(G) ≤ k?

## Why Include

1. **Already partially in codebase:** `src/rules/unitdiskmapping/pathdecomposition.rs` computes pathwidth
2. **Bounds DD/tensor network performance:** BDD size ~ 2^pathwidth, tensor contraction ~ 2^treewidth
3. **Connects to GenericTensorNetworks.jl:** companion Julia package uses treewidth for contraction
4. **Structural parameter:** unlike most problems, treewidth describes graph structure itself
5. **FPT algorithm:** solvable in O(f(k)·n) time for fixed k — demonstrates fixed-parameter tractability

## Variables

Encoding as optimization problem (minimize width):
- Variables define a vertex elimination ordering
- Count: |V| (one per vertex for elimination position)
- Per-variable domain: {0, 1, …, |V|-1} (position in ordering)
- Treewidth = max clique size in elimination graph - 1

Alternative: satisfaction formulation
- Given k, does a tree decomposition of width ≤ k exist?

## Schema

| Field | Description |
|-------|-------------|
| `graph` | The graph G |
| `k` | Target treewidth (for decision version) |

## Example Instance

```
Graph: Path P₄ = V={0,1,2,3}, E={(0,1),(1,2),(2,3)}
Treewidth = 1 (all trees have treewidth 1)
Tree decomposition: bags {0,1}, {1,2}, {2,3} with tree edges between them

Graph: Cycle C₄ = V={0,1,2,3}, E={(0,1),(1,2),(2,3),(3,0)}
Treewidth = 2
Tree decomposition: bags {0,1,3}, {1,2,3}

Graph: K₄ (complete graph on 4 vertices)
Treewidth = 3 (complete graphs have treewidth n-1)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| Treewidth → ILP | Known | Elimination ordering formulation; binary xᵢⱼ for "i before j"; minimize max fill-in degree |
| Pathwidth → Treewidth | Trivial | pw(G) ≥ tw(G) always; path decomposition is special tree decomposition |
| Treewidth relates to MinimumBisection | Structural | tw(G) ≤ bisection_width(G) · O(log n) |

## Connection to Existing Codebase

The codebase already has:
- `src/rules/unitdiskmapping/pathdecomposition.rs` — computes pathwidth
- `src/rules/unitdiskmapping/grid.rs` — grid-based mappings use pathwidth
- UnitDiskGraph → GridGraph reduction uses path decomposition

Adding Treewidth would:
- Generalize the existing pathwidth infrastructure
- Connect structural graph parameters to the reduction network
- Enable treewidth-bounded algorithms for other problems

## Difficulty: Tier 3

- Pathwidth infrastructure already exists (can extend)
- Tree decomposition validation is more complex than path decomposition
- Elimination ordering formulation is well-studied
- FPT algorithms (Bodlaender's) are complex but not needed for basic model

## References

1. **Robertson, N. & Seymour, P.D.** (1986). "Graph minors. II. Algorithmic aspects of tree-width." *Journal of Algorithms*, 7(3):309–322. DOI: [10.1016/0196-6774(86)90023-4](https://doi.org/10.1016/0196-6774(86)90023-4)
   — Introduces tree decomposition and treewidth; proves the Graph Minor Theorem for bounded treewidth.

2. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   — Proves NP-completeness of the treewidth decision problem ("is tw(G) ≤ k?").

3. **Bodlaender, H.L.** (1998). "A partial k-arboretum of graphs with bounded treewidth." *Theoretical Computer Science*, 209(1–2):1–45. DOI: [10.1016/S0304-3975(97)00228-4](https://doi.org/10.1016/S0304-3975(97)00228-4)
   — Comprehensive survey of treewidth bounds for over 100 graph classes.

4. **Gavril, F.** (1974). "The intersection graphs of subtrees in trees are exactly the chordal graphs." *Journal of Combinatorial Theory, Series B*, 16(1):47–56. DOI: [10.1016/0095-8956(74)90094-X](https://doi.org/10.1016/0095-8956(74)90094-X)
   — Chordal graphs ↔ subtree intersection graphs; chordal completion is equivalent to finding tree decompositions.

5. **Rose, D.J.** (1970). "Triangulated graphs and the elimination process." *Journal of Mathematical Analysis and Applications*, 32(3):597–609. DOI: [10.1016/0022-247X(70)90282-9](https://doi.org/10.1016/0022-247X(70)90282-9)
   — Vertex elimination orderings characterize chordal graphs; treewidth = min max-clique in elimination graph − 1.

6. **Markov, I.L. & Shi, Y.** (2008). "Simulating quantum computation by contracting tensor networks." *SIAM Journal on Computing*, 38(3):963–981. DOI: [10.1137/050644756](https://doi.org/10.1137/050644756)
   — Proves tensor network contraction cost is bounded by 2^(treewidth); connects treewidth to quantum simulation.

7. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)
   — MDD size bounded by 2^(treewidth); connects structural graph parameters to DD performance.
