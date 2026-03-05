# Reduction Proposal: Knapsack → ILP

## Reduction Direction: One-way

### Knapsack → ILP

**Algorithm:** Standard Knapsack ILP formulation

Given Knapsack: weights w, values v, capacity C

Construct ILP:
```
maximize Σᵢ vᵢ · xᵢ
subject to:
    Σᵢ wᵢ · xᵢ ≤ C
    xᵢ ∈ {0, 1}
```

**Solution extraction:** Direct — xᵢ = 1 iff item i is selected

**Overhead:** n variables, 1 constraint, n nonzeros

## Notes

- Textbook ILP formulation — possibly the most well-known example
- Single inequality constraint (vs equality for SubsetSum)
- Maximization (vs minimization for most other ILP reductions)
