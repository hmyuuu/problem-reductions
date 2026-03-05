# Model Proposal: FeedbackVertexSet

## Problem Definition

**Feedback Vertex Set (Minimum Feedback Vertex Set)**

Given a directed graph G = (V, A), find a minimum-size subset F ⊆ V such that removing F from G makes it acyclic (a DAG).

- **Karp #7** | **Category:** graph
- **Reference:** Garey & Johnson (1979), [GT7]; Karp (1972)
- **Complexity:** NP-complete (both directed and undirected)
- **Problem type:** Optimization (Minimize)

## Type Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `W` | weight | `One` | Vertex weight type |

## Problem Trait Implementation

```rust
struct FeedbackVertexSet<W: WeightElement = One> {
    num_vertices: usize,
    arcs: Vec<(usize, usize)>,    // directed edges (u → v)
    weights: Option<Vec<W>>,       // vertex weights
}
```

- **`NAME`**: `"MinimumFeedbackVertexSet"` (follows Min prefix convention)
- **`Metric`**: `SolutionSize<W::Sum>`
- **`dims()`**: `vec![2; num_vertices]` — binary: remove vertex or keep
- **`evaluate(config)`**:
  1. Remove selected vertices (config[v] = 1 → remove v)
  2. Check if remaining graph is acyclic (topological sort / DFS cycle detection)
  3. If acyclic → `Valid(sum of weights of removed vertices)`, else `Invalid`
- **`direction()`**: `Minimize`
- **`variant()`**: `[("weight", W::type_name())]`

## Example Instance

```
Vertices: {0, 1, 2, 3}
Arcs: 0→1, 1→2, 2→0, 2→3, 3→1
Cycles: 0→1→2→0, 1→2→3→1

Config [0,0,1,0] → remove vertex 2
  Remaining: {0,1,3}, arcs: 3→1
  No cycle → acyclic ✓ → Valid(1)

Config [0,1,0,0] → remove vertex 1
  Remaining: {0,2,3}, arcs: 2→0, 2→3
  No cycle → acyclic ✓ → Valid(1)

Optimal: remove one vertex (size 1)
```

## Why Moderate (Tier 3)

- Requires **directed graph** support — need to check if the codebase has directed graphs
  - SimpleGraph may be undirected only → may need a new DirectedGraph type or use adjacency list directly
- Needs **cycle detection** algorithm (DFS with back-edge detection or Kahn's algorithm for topological sort)
- These are well-known algorithms but add infrastructure

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| FeedbackVertexSet → ILP | Standard | Binary xᵥ per vertex; for each cycle C: Σᵥ∈C xᵥ ≥ 1. Exponential constraints → lazy generation |
| FeedbackVertexSet → ILP (alt) | Ordering-based | Introduce ordering variables: yᵤ for topological position; for each arc (u,v): yᵤ < yᵥ OR xᵤ = 1 OR xᵥ = 1 |
| SAT → FeedbackVertexSet | Karp chain | Known reduction (via VertexCover) |

## Open Questions

- Does the codebase support directed graphs? Check SimpleGraph.
  - If not, options: (a) add DirectedGraph type, (b) store arcs as adjacency list in the struct itself
  - Option (b) is simpler and self-contained
- The ILP formulation with exponential cycle constraints is impractical → use ordering-based formulation
- Could also do undirected FVS as a simpler variant first

## Files to Create/Modify

1. `src/models/graph/minimum_feedback_vertex_set.rs` — model (self-contained directed graph)
2. `src/models/graph/mod.rs` — register
3. `src/unit_tests/models/graph/minimum_feedback_vertex_set.rs` — tests
4. `src/rules/minimumfeedbackvertexset_ilp.rs` — ILP reduction
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
