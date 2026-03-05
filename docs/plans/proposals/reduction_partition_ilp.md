# Reduction Proposal: Partition → ILP

## Reduction Direction: One-way

### Partition → ILP

**Algorithm:** Single equality constraint

Given Partition: numbers A = {a₀,...,aₙ₋₁}, total S = Σaᵢ

Construct ILP:
```
minimize 0  (feasibility)
subject to:
    Σᵢ aᵢ · xᵢ = S/2
    xᵢ ∈ {0, 1}
```

If S is odd → ILP is infeasible (no integer solution).

**Solution extraction:** Direct — xᵢ = 1 → element in partition A₁

**Overhead:** n variables, 1 constraint (or 2 if equality encoded as ≤ + ≥)

## Notes

- Almost identical to SubsetSum→ILP with target = S/2
- Could just compose Partition→SubsetSum→ILP, but direct ILP is trivial
