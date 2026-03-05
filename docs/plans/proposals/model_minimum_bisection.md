# Model Proposal: MinimumBisection

## Problem Definition

**Minimum Bisection (Graph Bisection)**

Given an undirected graph G = (V, E) with |V| even, partition V into two equal-size sets V₁, V₂ (|V₁| = |V₂| = |V|/2) such that the number of edges between V₁ and V₂ is minimized.

- **Category:** graph
- **Reference:** Garey & Johnson (1979), [ND16]; Lucas (2014) §3
- **Complexity:** NP-complete
- **Problem type:** Optimization (Minimize)

## Why Include

- Appears in Lucas (2014) with explicit QUBO/Ising formulation
- Natural complement to MaxCut (MaxCut maximizes cut edges; Bisection minimizes with equal partition constraint)
- Important in parallel computing, VLSI design, network partitioning
- Has a direct Ising formulation: H = A·Σᵢⱼ∈E (1-sᵢsⱼ)/2 + B·(Σᵢ sᵢ)²

## Type Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `G` | graph | `SimpleGraph` | Graph type |
| `W` | weight | `One` | Edge weight type |

## Problem Trait Implementation

```rust
struct MinimumBisection<G: GraphInterface = SimpleGraph, W: WeightElement = One> {
    graph: G,
    weights: Option<Vec<W>>,  // edge weights
}
```

- **`NAME`**: `"MinimumBisection"`
- **`Metric`**: `SolutionSize<W::Sum>`
- **`dims()`**: `vec![2; graph.num_vertices()]` — assign each vertex to partition 0 or 1
- **`evaluate(config)`**:
  1. Check |partition 0| = |partition 1| = n/2. If not → `Invalid`
  2. Count weighted edges crossing the partition
  3. Return `Valid(crossing_weight)`
- **`direction()`**: `Minimize`
- **`variant()`**: `[("graph", G::type_name()), ("weight", W::type_name())]`

## Example Instance

```
Graph: V={0,1,2,3}, E={(0,1),(1,2),(2,3),(0,3),(0,2)}
Config [0,0,1,1] → V₁={0,1}, V₂={2,3}
  Crossing edges: (1,2), (2,3)... wait: (0,2) and (0,3) also cross?
  0∈V₁, 2∈V₂ → (0,2) crosses ✓
  0∈V₁, 3∈V₂ → (0,3) crosses ✓
  1∈V₁, 2∈V₂ → (1,2) crosses ✓
  Total: 3 crossing edges

Config [0,1,1,0] → V₁={0,3}, V₂={1,2}
  (0,1) crosses ✓, (0,3) no, (1,2) no, (2,3) crosses ✓, (0,2) crosses ✓
  Total: 3 crossing edges

Config [0,1,0,1] → V₁={0,2}, V₂={1,3}
  (0,1) crosses ✓, (1,2) crosses ✓, (2,3) crosses ✓, (0,3) crosses ✓, (0,2) no
  Total: 4 crossing edges

Optimal: 3 (multiple configs achieve this)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| MinimumBisection → QUBO | Lucas 2014 §3 | H = A·Σ edges Jᵢⱼ(1-sᵢsⱼ)/2 + B·(Σsᵢ)²; binary: xᵢ = (1+sᵢ)/2 |
| MinimumBisection → ILP | Standard | Binary xᵥ; Σxᵥ = n/2; for each edge (u,v): yₑ ≥ xᵤ-xᵥ, yₑ ≥ xᵥ-xᵤ; min Σ wₑyₑ |
| MinimumBisection → MaxCut | Related | Not a direct reduction but closely related (opposite optimization with partition constraint) |

## Implementation Notes

- Very similar to MaxCut: both count crossing edges
- MaxCut maximizes, Bisection minimizes with equal partition constraint
- The equal partition constraint (|V| must be even) is the key difference
- If |V| is odd, problem is infeasible

## Files to Create/Modify

1. `src/models/graph/minimum_bisection.rs` — model
2. `src/models/graph/mod.rs` — register
3. `src/unit_tests/models/graph/minimum_bisection.rs` — tests
4. `src/rules/minimumbisection_qubo.rs` — QUBO reduction
5. `src/rules/minimumbisection_ilp.rs` — ILP reduction
6. `src/rules/mod.rs` — register
7. `docs/paper/reductions.typ` — paper entries
