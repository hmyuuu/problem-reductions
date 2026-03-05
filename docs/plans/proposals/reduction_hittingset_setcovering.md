# Reduction Proposal: HittingSet ↔ MinimumSetCovering

## Reduction Direction: Bidirectional

### HittingSet → MinimumSetCovering (Forward)

**Algorithm:** Transpose the incidence matrix.

Given HittingSet instance:
- Universe U = {0, ..., n-1}, Sets S = {S₀, ..., Sₘ₋₁}, Weights w

Construct SetCovering instance:
- Universe U' = {0, ..., m-1} (one element per original set)
- For each element i ∈ U, create set S'ᵢ = {j : i ∈ Sⱼ} (all original sets containing i)
- Weights w' = w (same as original element weights)

**Correctness:** H hits all sets ↔ {S'ᵢ : i ∈ H} covers all elements of U'

**Solution extraction:** Direct — selected elements in HittingSet = selected sets in SetCovering

### MinimumSetCovering → HittingSet (Reverse)

**Algorithm:** Same transpose, opposite direction.

Given SetCovering instance:
- Universe U = {0, ..., n-1}, Sets S = {S₀, ..., Sₘ₋₁}, Weights w

Construct HittingSet instance:
- Universe U' = {0, ..., m-1} (one element per original set)
  Wait — that's the same as forward. Let me think again.

Actually: the dual is more precisely:
- HittingSet universe = SetCovering sets (the "collections")
- HittingSet sets = SetCovering elements (each element defines which sets contain it)

So:
- HittingSet(universe=n, sets, weights) → SetCovering(universe=m, sets=transpose, weights)
- SetCovering(universe=n, sets, weights) → HittingSet(universe=m, sets=transpose, weights)

**Overhead:** O(n·m) time and space (building transpose)

## Implementation Pattern

```rust
// In minimumhittingset_minimumsetcovering.rs

struct HittingSetToSetCoveringResult { /* ... */ }

impl ReduceTo<MinimumSetCovering<W>> for MinimumHittingSet<W> {
    fn reduce(&self) -> HittingSetToSetCoveringResult { /* transpose */ }
}

struct SetCoveringToHittingSetResult { /* ... */ }

impl ReduceTo<MinimumHittingSet<W>> for MinimumSetCovering<W> {
    fn reduce(&self) -> SetCoveringToHittingSetResult { /* transpose back */ }
}
```

## Test Pattern

Closed-loop test:
1. Create HittingSet instance
2. Reduce to SetCovering
3. Solve SetCovering with brute force
4. Extract solution back
5. Verify it's optimal for original HittingSet
