# Reduction Proposal: ExactCover → ILP

## Reduction Direction: One-way

### ExactCover → ILP

**Algorithm:** Binary variables with equality constraints

Given ExactCover instance: universe U = {0,...,n-1}, sets S = {S₀,...,Sₘ₋₁}

Construct ILP:
```
minimize 0  (feasibility)
subject to:
    Σ_{j: i∈Sⱼ} xⱼ = 1    for each element i ∈ U
    xⱼ ∈ {0, 1}              for each set j
```

**Correctness:** Each element must be in exactly one selected set = ExactCover definition.

**Solution extraction:** Direct — xⱼ = 1 iff set Sⱼ is selected.

**Overhead:** m variables, n constraints, Σ|Sⱼ| nonzeros

## Implementation Notes

- Check how ILP struct handles equality constraints
- If ILP only supports ≤: use two constraints per element:
  ```
  Σ xⱼ ≥ 1  (at least one)
  Σ xⱼ ≤ 1  (at most one)
  ```
  This doubles constraints but preserves correctness.
