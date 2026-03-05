# Reduction Proposal: SubsetSum → ILP

## Reduction Direction: One-way

### SubsetSum → ILP

**Algorithm:** Single equality constraint

Given SubsetSum instance: numbers A = {a₀, ..., aₙ₋₁}, target t

Construct ILP instance:
- Variables: x₀, ..., xₙ₋₁ ∈ {0, 1}
- Constraints: Σᵢ aᵢ·xᵢ = t (single equality constraint)
- Objective: none (feasibility problem) → minimize 0

**Formal ILP:**
```
minimize 0
subject to:
    a₀·x₀ + a₁·x₁ + ... + aₙ₋₁·xₙ₋₁ = t
    xᵢ ∈ {0, 1} for all i
```

**Solution extraction:** Direct — ILP solution xᵢ = SubsetSum selection

**Overhead:** O(n) variables, 1 constraint, O(n) nonzeros

## Notes

- This is the simplest possible ILP formulation in the entire codebase
- Single equality constraint
- Pattern matches MinimumSetCovering→ILP but even simpler
- Need to check how ILP handles equality constraints (vs ≤ or ≥)
  - If ILP only supports ≤: encode a₀x₀+...+aₙxₙ ≤ t AND a₀x₀+...+aₙxₙ ≥ t (two constraints)
