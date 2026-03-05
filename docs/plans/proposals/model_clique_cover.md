# Model Proposal: CliqueCover

## Problem Definition

**Clique Cover (Minimum Clique Cover)**

Given an undirected graph G = (V, E) and an integer k, partition the vertices into at most k cliques (complete subgraphs).

- **Karp #13** | **Category:** graph
- **Reference:** Garey & Johnson (1979), [GT17]; Karp (1972)
- **Complexity:** NP-complete
- **Problem type:** Satisfaction (Metric = bool)

## Type Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `G` | graph | `SimpleGraph` | Graph type |

## Problem Trait Implementation

```rust
struct CliqueCover<G: GraphInterface = SimpleGraph> {
    graph: G,
    k: usize,            // number of allowed cliques
}
```

- **`NAME`**: `"CliqueCover"`
- **`Metric`**: `bool` (satisfaction — can we partition into ≤ k cliques?)
- **`dims()`**: `vec![k; graph.num_vertices()]` — assign each vertex a clique label 0..k-1
- **`evaluate(config)`**: for each clique label c, collect all vertices assigned to c; check that they form a complete subgraph (all pairs have edges). Return `true` iff all groups are cliques.
- **`variant()`**: `[("graph", G::type_name())]`

## Example Instance

```
Graph: V={0,1,2,3}, E={(0,1),(1,2),(2,3),(0,2)}
k = 2
Config [0,0,0,1] → Clique₀={0,1,2}, Clique₁={3}
  {0,1,2}: edges (0,1)✓, (1,2)✓, (0,2)✓ → clique ✓
  {3}: singleton → clique ✓
  All cliques valid → true ✓
```

## Why Easy

This is **KColoring on the complement graph**:
- If you can k-color complement(G), those color classes are cliques in G
- `KColoring` struct already exists, `complement()` graph method already exists
- The reduction is a one-liner transformation

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| CliqueCover → KColoring | Trivial | Apply k-coloring to complement(G) |
| KColoring → CliqueCover | Trivial | Apply clique cover to complement(G) |
| CliqueCover → ILP | Standard | Binary xᵥc per vertex-clique pair; assignment + adjacency constraints |

## Implementation Notes

- Mirror `KColoring` structure but check cliques instead of proper coloring
- `complement()` method on graph types needs verification that it exists
- Consider: should `k` be a const generic like KColoring's K? Check KColoring impl.
  - KColoring uses `K: KValue` (K1..K5, KN) — probably overkill for CliqueCover
  - Simpler: just use runtime `k: usize`

## Files to Create/Modify

1. `src/models/graph/clique_cover.rs` — model
2. `src/models/graph/mod.rs` — register
3. `src/unit_tests/models/graph/clique_cover.rs` — tests
4. `src/rules/cliquecover_kcoloring.rs` — bidirectional reduction
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
