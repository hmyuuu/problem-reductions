# Model Proposal: GraphPartitioning (k-way)

## Problem Definition

**Graph Partitioning (k-way Graph Partitioning / Minimum k-Cut)**

Given an undirected graph G = (V, E) with edge weights and an integer k, partition V into k equal-size groups that minimizes the total weight of edges between groups.

- **Category:** graph
- **Reference:** Lucas (2014) §2; Garey & Johnson (1979)
- **Complexity:** NP-complete
- **Problem type:** Optimization (Minimize)

## Relationship to Existing Problems

- **MinimumBisection** = GraphPartitioning with k=2 (already proposed in iteration 1)
- **MaxCut** = maximize (not minimize) cut edges with k=2 (already implemented)
- **KColoring** = assign k colors without adjacent conflicts (already implemented)
- GraphPartitioning generalizes MinimumBisection to k>2 groups

## Problem Trait Implementation

```rust
struct GraphPartitioning<G: GraphInterface = SimpleGraph, W: WeightElement = One> {
    graph: G,
    k: usize,                    // number of partitions
    weights: Option<Vec<W>>,     // edge weights
}
```

- **`NAME`**: `"GraphPartitioning"`
- **`Metric`**: `SolutionSize<W::Sum>`
- **`dims()`**: `vec![k; graph.num_vertices()]` — assign each vertex to partition 0..k-1
- **`evaluate(config)`**:
  1. Check each partition has exactly |V|/k vertices (equal size)
  2. Count weighted edges between different partitions
  3. If valid → `Valid(crossing_weight)`, else `Invalid`
- **`direction()`**: `Minimize`

## Why This is Worth Adding

- Generalizes MinimumBisection (k=2) to arbitrary k
- Very important in practice: parallel computing, VLSI, load balancing
- Has direct Ising formulation (Lucas 2014 §2)
- BUT: it adds complexity with the k parameter and equal-size constraint

## Difficulty Assessment: Tier 3

- Equal-size partition constraint makes evaluation and QUBO encoding complex
- k-way requires k·|V| binary variables in QUBO (one-hot encoding per vertex)
- Consider: implement MinimumBisection first (k=2, simpler), then generalize

## Recommendation

**Implement MinimumBisection (already proposed) as the simpler k=2 case.**
Consider GraphPartitioning (k>2) as a future extension.

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| GraphPartitioning → QUBO | Lucas 2014 §2 | One-hot vertex-to-partition assignment + equality penalties |
| GraphPartitioning → ILP | Standard | Binary x_{v,p}; assignment + balance + cut objective |
| MinimumBisection → GraphPartitioning | Trivial | Set k=2 |

## Files to Create/Modify

1. `src/models/graph/graph_partitioning.rs` — model
2. Same set as MinimumBisection + generalization
