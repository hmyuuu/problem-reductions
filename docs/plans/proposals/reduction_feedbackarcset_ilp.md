# Reduction Proposal: FeedbackArcSet → ILP

## Reduction Direction: One-way

### MinimumFeedbackArcSet → ILP

**Algorithm:** Ordering-based ILP

Given FAS: directed graph G = (V, A), arc weights w

Introduce variables:
- xₑ ∈ {0, 1} for each arc e (1 = remove)
- yᵥ ∈ {0, ..., n-1} for each vertex (topological order position)

```
minimize Σₑ wₑ · xₑ
subject to:
    For each arc e = (u,v) ∈ A:
        yᵤ - yᵥ + 1 ≤ n · xₑ
    // If arc is kept (xₑ=0), then yᵤ < yᵥ (topological order respected)
    // If arc is removed (xₑ=1), constraint is vacuous

    yᵥ ∈ {0, ..., n-1}
    xₑ ∈ {0, 1}
```

**Solution extraction:** xₑ = 1 → arc is in feedback set

**Overhead:** |A| binary + |V| integer variables, |A| constraints

## Notes

- Simpler than FVS→ILP because each constraint involves only one decision variable xₑ
- Same ordering trick eliminates exponential cycle enumeration
- Same integer variable concern as FVS→ILP
