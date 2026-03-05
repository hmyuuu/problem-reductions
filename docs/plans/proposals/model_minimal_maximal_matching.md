# Model Proposal: MinimalMaximalMatching

## Problem Definition

**Minimal Maximal Matching (Minimum Maximal Matching)**

Given an undirected graph G = (V, E), find a maximal matching M (no edge can be added without breaking the matching property) of minimum cardinality.

- **Category:** graph
- **Reference:** Lucas (2014) §4.5; Yannakakis & Gavril (1980)
- **Complexity:** NP-hard
- **Problem type:** Optimization (Minimize)

## Why Include

- Appears in Lucas 2014 §4.5 with explicit Ising/QUBO formulation
- The codebase already has `MaximumMatching` — this is its "opposite" (minimize among all maximal matchings)
- Connects the matching family: MaximumMatching (maximize) ↔ MinimalMaximalMatching (minimize maximal)
- Has natural reduction to QUBO

## Relationship to Existing MaximumMatching

- `MaximumMatching`: find a matching with the most edges
- `MinimalMaximalMatching`: find a maximal matching with the fewest edges
- A maximal matching cannot be extended (every edge shares a vertex with some matching edge)
- The minimum maximal matching is at least half the size of maximum matching (2-approx)

## Problem Trait Implementation

```rust
struct MinimalMaximalMatching<G: GraphInterface = SimpleGraph> {
    graph: G,
}
```

- **`NAME`**: `"MinimalMaximalMatching"`
- **`Metric`**: `SolutionSize<i32>`
- **`dims()`**: `vec![2; graph.num_edges()]` — binary: include edge or not
- **`evaluate(config)`**:
  1. Collect selected edges
  2. Check selected edges form a matching (no two share a vertex)
  3. Check matching is maximal (every unselected edge shares a vertex with a selected edge)
  4. If valid → `Valid(num_selected_edges)`, else `Invalid`
- **`direction()`**: `Minimize`
- **`variant()`**: `[("graph", G::type_name())]`

## Example Instance

```
Graph: V={0,1,2,3}, E={(0,1),(1,2),(2,3),(0,3)}
All maximal matchings:
  {(0,1),(2,3)} — size 2, maximal (all edges covered) ✓
  {(1,2),(0,3)} — size 2, maximal ✓
Minimum maximal matching: size 2 (this graph: any maximal matching has size 2)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| MinimalMaximalMatching → QUBO | Lucas 2014 §4.5 | Edge variables with matching + maximality penalty terms |
| MinimalMaximalMatching → ILP | Standard | Binary yₑ per edge; matching: Σ_{e∋v} yₑ ≤ 1 ∀v; maximality: for each edge (u,v): yₑ + Σ_{e'∋u} yₑ' + Σ_{e'∋v} yₑ' ≥ 1; minimize Σ yₑ |

## Difficulty Assessment: Tier 2

- Reuses graph infrastructure from MaximumMatching
- Evaluation needs both matching check (easy) AND maximality check (moderate)
- QUBO formulation available from Lucas 2014

## Files to Create/Modify

1. `src/models/graph/minimal_maximal_matching.rs` — model
2. `src/models/graph/mod.rs` — register
3. `src/unit_tests/models/graph/minimal_maximal_matching.rs` — tests
4. `src/rules/minimalmaximalmatching_qubo.rs` — QUBO reduction (Lucas 2014)
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
