# Model Proposal: SteinerTree

## Problem Definition

**Steiner Tree in Graphs**

Given an undirected weighted graph G = (V, E) with edge weights w: E → ℝ⁺ and a set of terminal vertices R ⊆ V, find a minimum-weight tree T that spans all terminals in R. The tree may use non-terminal (Steiner) vertices.

- **Karp #16** | **Category:** graph
- **Reference:** Garey & Johnson (1979), [ND7]; Karp (1972)
- **Complexity:** NP-complete (even for unit weights)
- **Problem type:** Optimization (Minimize)

## Type Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `G` | graph | `SimpleGraph` | Graph type |
| `W` | weight | `i32` | Edge weight type |

## Problem Trait Implementation

```rust
struct SteinerTree<G: GraphInterface = SimpleGraph, W: WeightElement = i32> {
    graph: G,
    terminals: Vec<usize>,       // terminal vertex indices
    edge_weights: Vec<W>,        // weight per edge
}
```

- **`NAME`**: `"SteinerTree"`
- **`Metric`**: `SolutionSize<W::Sum>` (optimization)
- **`dims()`**: `vec![2; graph.num_edges()]` — binary: include each edge or not
- **`evaluate(config)`**:
  1. Collect selected edges → form subgraph
  2. Check subgraph is connected and spans all terminals
  3. Check subgraph is a tree (|selected edges| = |reachable vertices| - 1)
  4. If valid → `Valid(sum of edge weights)`, else `Invalid`
- **`direction()`**: `Minimize`
- **`variant()`**: `[("graph", G::type_name()), ("weight", W::type_name())]`

## Example Instance

```
Graph: V={0,1,2,3,4}
Edges: (0,1,w=2), (1,2,w=1), (2,3,w=3), (0,3,w=4), (1,4,w=5), (3,4,w=1)
Terminals: {0, 2, 4}

Possible trees:
  {(0,1), (1,2), (3,4), (2,3)} → weight = 2+1+3+1 = 7, spans {0,1,2,3,4}
  {(0,1), (1,2), (1,4)} → weight = 2+1+5 = 8, spans {0,1,2,4} (terminals covered!)
  Optimal: {(0,1), (1,2), (3,4), (2,3)} → weight 7 (uses Steiner vertex 1,3)
    Actually check: can we do better?
  {(0,1), (1,2), (1,4)} = weight 8
  Need to span 0,2,4. Steiner vertices 1,3 may help.
  {(0,1), (1,2), (3,4), (2,3)} = 2+1+3+1 = 7
```

## Why Moderate (Tier 3)

- Needs edge-based variables (vs vertex-based for most problems)
- Connectivity check in `evaluate()` requires BFS/DFS
- Tree validation adds complexity
- But ILP formulation is well-known (flow-based or cut-based)

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| SteinerTree → ILP | Standard (flow-based) | Binary edge variables + flow conservation constraints for connectivity |
| VertexCover → SteinerTree | Karp chain | Known NP-completeness proof |

## Implementation Notes

- Variables are **edges** not vertices — different from most existing problems
- Could alternatively formulate with vertex variables (include Steiner vertex or not) + connectivity check
  - Vertex formulation: dims = [2; |V|], select vertices, then use minimum spanning tree on induced subgraph
  - Edge formulation is more natural for ILP
- Connectivity check: BFS/DFS from any terminal, verify all terminals reachable
- Consider: does the existing graph infrastructure support edge-based problems well?

## Open Questions

- Edge-based vs vertex-based variable encoding? Check how TravelingSalesman handles this.
- Does SimpleGraph expose edge iteration easily?

## Files to Create/Modify

1. `src/models/graph/steiner_tree.rs` — model
2. `src/models/graph/mod.rs` — register
3. `src/unit_tests/models/graph/steiner_tree.rs` — tests
4. `src/rules/steinertree_ilp.rs` — ILP reduction
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
