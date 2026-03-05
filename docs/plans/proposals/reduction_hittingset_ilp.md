# Reduction Proposal: HittingSet → ILP

## Reduction Direction: One-way

### MinimumHittingSet → ILP

**Algorithm:** Standard covering ILP

Given HittingSet: universe U = {0,...,n-1}, sets S = {S₀,...,Sₘ₋₁}, weights w

Construct ILP:
```
minimize Σᵢ wᵢ · xᵢ
subject to:
    Σ_{i∈Sⱼ} xᵢ ≥ 1    for each set j ∈ {0,...,m-1}
    xᵢ ∈ {0, 1}          for each element i
```

**Correctness:** Each set must have at least one selected element = hitting definition.

**Solution extraction:** Direct — xᵢ = 1 iff element i is in hitting set.

**Overhead:** n variables, m constraints, Σ|Sⱼ| nonzeros

## Notes

- Mirrors MinimumSetCovering→ILP with roles of elements and sets swapped
- Nearly identical code structure
