# Reduction Proposal: FeedbackVertexSet → ILP

## Reduction Direction: One-way

### MinimumFeedbackVertexSet → ILP

**Algorithm:** Ordering-based ILP (avoids exponential cycle constraints)

Given FVS: directed graph G = (V, A), vertex weights w

**Approach 1: Topological ordering** (polynomial constraints)

Introduce variables:
- xᵥ ∈ {0, 1} for each vertex (1 = remove)
- yᵥ ∈ {0, 1, ..., n-1} for each vertex (topological order position)

```
minimize Σᵥ wᵥ · xᵥ
subject to:
    For each arc (u,v) ∈ A:
        yᵤ - yᵥ + 1 ≤ n · (xᵤ + xᵥ)
    // If both u,v are kept (xᵤ=xᵥ=0), then yᵤ < yᵥ (topological order)
    // If either is removed, constraint is vacuous

    yᵥ ∈ {0, ..., n-1}
    xᵥ ∈ {0, 1}
```

**Overhead:** n binary + n integer variables, |A| constraints

**Approach 2: Cycle-based** (exponential but lazy)

```
minimize Σᵥ wᵥ · xᵥ
subject to:
    For each directed cycle C in G:
        Σᵥ∈C xᵥ ≥ 1
```

This has exponentially many constraints → need lazy constraint generation.

**Recommendation:** Use Approach 1 (ordering-based) for implementation.

## Notes

- The ordering approach requires integer (not just binary) variables → check if ILP struct supports general integer variables
- If only binary variables available, encode yᵥ in binary: need ⌈log₂ n⌉ bits per vertex → more variables but still polynomial
- Alternative: use big-M formulation with binary indicator
