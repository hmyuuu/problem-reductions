# Reduction Proposal: SteinerTree → ILP

## Reduction Direction: One-way

### SteinerTree → ILP

**Algorithm:** Flow-based or cut-based ILP

Given SteinerTree: graph G = (V, E), terminals R ⊆ V, edge weights w

**Approach: Vertex-based with connectivity**

Variables:
- xᵥ ∈ {0, 1} for each non-terminal vertex (1 = include as Steiner vertex)
  - Terminal vertices are always included (xᵥ = 1 fixed)
- yₑ ∈ {0, 1} for each edge (1 = include in tree)

```
minimize Σₑ wₑ · yₑ
subject to:
    // Edge can only be used if both endpoints are included
    For each edge e = (u,v):
        yₑ ≤ xᵤ  (or 1 if u is terminal)
        yₑ ≤ xᵥ  (or 1 if v is terminal)

    // Tree has exactly k-1 edges (k = number of selected vertices)
    Σₑ yₑ = (Σᵥ xᵥ + |R|) - 1  // total vertices - 1

    // Connectivity: flow-based constraints
    // Pick a root terminal r ∈ R
    // For each other terminal t ∈ R\{r}:
    //   There must be a path from r to t using selected edges
    //   Encode via network flow: fₑᵗ ∈ [0,1] flow for terminal t on edge e
    For each terminal t ∈ R\{r}:
        Flow conservation at each vertex v:
        Σ fₑᵗ(incoming) - Σ fₑᵗ(outgoing) = { 1 if v=t, -1 if v=r, 0 otherwise }
        Flow only on selected edges: fₑᵗ ≤ yₑ
```

**Overhead:** O(|V| + |E| + |R|·|E|) variables, O(|R|·|V|) constraints

## Notes

- Most complex ILP reduction in the batch
- Flow-based connectivity encoding is standard but verbose
- Alternative: use cut-based constraints (exponentially many, lazily generated)
- Could simplify by using subtour elimination (like TSP→ILP does)
- Check how TravelingSalesman→ILP handles connectivity — may reuse pattern
