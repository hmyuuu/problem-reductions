# Model Proposal: FeedbackArcSet

## Problem Definition

**Feedback Arc Set (Minimum Feedback Arc Set)**

Given a directed graph G = (V, A), find a minimum-size (or minimum-weight) subset F ⊆ A of arcs such that removing F from G makes it acyclic.

- **Karp #8** | **Category:** graph
- **Reference:** Garey & Johnson (1979), [GT8]; Karp (1972)
- **Complexity:** NP-complete
- **Problem type:** Optimization (Minimize)

## Type Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `W` | weight | `One` | Arc weight type |

## Problem Trait Implementation

```rust
struct FeedbackArcSet<W: WeightElement = One> {
    num_vertices: usize,
    arcs: Vec<(usize, usize)>,    // directed edges
    weights: Option<Vec<W>>,       // arc weights (one per arc)
}
```

- **`NAME`**: `"MinimumFeedbackArcSet"`
- **`Metric`**: `SolutionSize<W::Sum>`
- **`dims()`**: `vec![2; arcs.len()]` — binary: remove arc or keep
- **`evaluate(config)`**:
  1. Collect remaining arcs (those with config[i] = 0)
  2. Check acyclicity (topological sort on remaining arcs)
  3. If acyclic → `Valid(sum of weights of removed arcs)`, else `Invalid`
- **`direction()`**: `Minimize`
- **`variant()`**: `[("weight", W::type_name())]`

## Example Instance

```
Vertices: {0, 1, 2}
Arcs: a₀=(0→1), a₁=(1→2), a₂=(2→0)
Cycle: 0→1→2→0

Config [0,0,1] → remove arc 2→0
  Remaining: 0→1, 1→2 → DAG ✓ → Valid(1)

Any single arc removal breaks the only cycle → optimal size = 1
```

## Why Moderate (Tier 3)

- Same directed graph infrastructure as FeedbackVertexSet
- Variables are arcs (edges) instead of vertices — similar to SteinerTree
- Acyclicity check is the same algorithm
- Can share code/infrastructure with FeedbackVertexSet

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| FeedbackArcSet → ILP | Ordering-based | Introduce ordering yᵥ per vertex. For each arc (u,v): yᵤ < yᵥ + M·xₑ. Minimize Σ wₑxₑ |
| FeedbackArcSet → FeedbackVertexSet | Known | Replace each vertex v with two vertices v_in, v_out + arc v_in→v_out; each original arc (u,v) becomes (u_out, v_in). FVS on transformed graph gives FAS. |
| FeedbackVertexSet → FeedbackArcSet | Known | For each vertex v, add v to FAS iff all incoming arcs of v are in FAS |

## Implementation Notes

- Shares directed graph infrastructure with FeedbackVertexSet
- Could implement both problems in same batch
- Topological sort utility function can be shared
- Applications: deadlock resolution, scheduling, ranking

## Files to Create/Modify

1. `src/models/graph/minimum_feedback_arc_set.rs` — model
2. `src/models/graph/mod.rs` — register
3. `src/unit_tests/models/graph/minimum_feedback_arc_set.rs` — tests
4. `src/rules/minimumfeedbackarcset_ilp.rs` — ILP reduction
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
