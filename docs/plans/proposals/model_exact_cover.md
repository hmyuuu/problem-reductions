# Model Proposal: ExactCover

## Problem Definition

**Exact Cover**

Given a universe U = {0, 1, …, n−1} and a collection S = {S₀, S₁, …, Sₘ₋₁} of subsets of U, find a sub-collection S* ⊆ S such that every element of U belongs to **exactly one** set in S*.

- **Karp #14** | **Category:** set
- **Reference:** Garey & Johnson (1979), [SP2]; Karp (1972)
- **Complexity:** NP-complete
- **Problem type:** Satisfaction (Metric = bool)

## Type Parameters

None — ExactCover is unweighted (either a valid partition exists or not).

## Problem Trait Implementation

```rust
struct ExactCover {
    universe_size: usize,         // |U|
    sets: Vec<Vec<usize>>,        // collection of subsets
}
```

- **`NAME`**: `"ExactCover"`
- **`Metric`**: `bool` (satisfaction problem)
- **`dims()`**: `vec![2; sets.len()]` — binary choice per set (select or not)
- **`evaluate(config)`**: for each element in U, count how many selected sets contain it. Return `true` iff every element is covered exactly once.
- **`variant()`**: `[]` (no parameters)
- **`num_variables()`**: `sets.len()`

## Example Instance

```
Universe: {0, 1, 2, 3, 4, 5, 6}
Sets: S₀={0,3,6}, S₁={2,3,4}, S₂={1,2,5}, S₃={0,3}, S₄={4,5,6}, S₅={1,6}
Solution: {S₀, S₂, S₄} = {0,3,6} ∪ {1,2,5} ∪ {4,5,6}
  Wait — element 6 appears in both S₀ and S₄. That's not exact cover.
  Corrected: S₄={4,5}. Then {S₀, S₂, S₄} = {0,3,6} ∪ {1,2,5} ∪ {4,5}
  Still: element 5 in both S₂ and S₄.
  Better example:
  S₀={0,3,6}, S₁={2,3,4}, S₂={1,2,5}, S₃={0,3}, S₄={4,5,6}, S₅={1}
  Solution: S₃={0,3}, S₅={1}, S₁={2,3,4}... element 3 in S₃ and S₁.

  Clean example:
  Universe: {0, 1, 2, 3, 4}
  Sets: S₀={0,1}, S₁={2,3}, S₂={3,4}, S₃={0,2,4}, S₄={1,3}
  Solution: S₀={0,1}, S₁={2,3}, S₂={3,4} → element 3 appears twice. No.
  Solution: S₀={0,1}, S₃... S₃ has {0,2,4}, element 0 twice.

  Final clean example:
  Universe: {0, 1, 2, 3}
  Sets: S₀={0,1}, S₁={0,2}, S₂={2,3}, S₃={1,3}, S₄={0,1,2,3}
  Solutions:
    {S₀, S₂} = {0,1} ∪ {2,3} = {0,1,2,3} ✓ each exactly once
    {S₁, S₃} = {0,2} ∪ {1,3} = {0,1,2,3} ✓ each exactly once
    {S₄} = {0,1,2,3} ✓ trivially
```

## Why Easy

Special case of `MinimumSetCovering` where each element must be covered **exactly once** (equality constraint instead of ≥1). The satisfaction check changes from `count ≥ 1` to `count == 1`. This is a satisfaction problem (`Metric = bool`), NOT optimization.

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| ExactCover → MinimumSetCovering | Trivial relaxation | Relax "exactly once" to "at least once"; if covering uses k sets, check each element covered exactly once post-hoc |
| ExactCover → ILP | Standard | Binary xⱼ per set; constraints: Σⱼ:i∈Sⱼ xⱼ = 1 ∀i; feasibility problem |
| ExactCover → SAT | Standard | Encode "exactly one" per element as CNF clauses |
| 3DMatching → ExactCover | Karp chain | 3DM is a special case of ExactCover |

## Implementation Notes

- Very similar struct to SetCovering but without weights and with `==1` check instead of `>=1`
- Since this is a satisfaction problem, use `Solver::find_satisfying()` not `find_best()`
- Test with both satisfiable and unsatisfiable instances

## Files to Create/Modify

1. `src/models/set/exact_cover.rs` — model
2. `src/models/set/mod.rs` — register
3. `src/unit_tests/models/set/exact_cover.rs` — tests
4. `src/rules/exactcover_minimumsetcovering.rs` — reduction
5. `src/rules/exactcover_ilp.rs` — ILP reduction
6. `src/rules/mod.rs` — register
7. `docs/paper/reductions.typ` — paper entries
