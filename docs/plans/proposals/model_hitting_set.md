# Model Proposal: HittingSet

## Problem Definition

**Hitting Set (Minimum Hitting Set)**

Given a universe U = {0, 1, …, n−1} and a collection S = {S₀, S₁, …, Sₘ₋₁} of subsets of U with weights w: U → ℝ, find a minimum-weight subset H ⊆ U such that H ∩ Sⱼ ≠ ∅ for every j.

- **Karp #15** | **Category:** set
- **Reference:** Garey & Johnson (1979), [SP8]; Karp (1972)
- **Complexity:** NP-complete

## Type Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `W` | weight | `One` | Weight type for universe elements |

## Problem Trait Implementation

```rust
struct HittingSet<W: WeightElement = One> {
    universe_size: usize,         // |U|
    sets: Vec<Vec<usize>>,        // collection of subsets
    weights: Option<Vec<W>>,      // element weights (None = unit weight)
}
```

- **`NAME`**: `"HittingSet"` (no prefix — convention matches existing `MinimumSetCovering`)
  - Wait — should it be `MinimumHittingSet`? Check: SetCovering uses `MinimumSetCovering`. For consistency → `MinimumHittingSet`.
- **`Metric`**: `SolutionSize<W::Sum>` (optimization: minimize)
- **`dims()`**: `vec![2; universe_size]` — binary choice per element
- **`evaluate(config)`**: check that every set Sⱼ has at least one selected element; if yes, return `Valid(sum of weights of selected elements)`, else `Invalid`
- **`variant()`**: `[("weight", W::type_name())]`
- **`direction()`**: `Minimize`

## Example Instance

```
Universe: {0, 1, 2, 3, 4}
Sets: S₀={0,1,2}, S₁={2,3}, S₂={3,4}, S₃={0,4}
Weights: [1, 1, 1, 1, 1]
Optimal: H = {2, 4} (weight 2) — hits all 4 sets
  S₀∩H={2}✓  S₁∩H={}... wait, S₁={2,3}, H={2,4}, S₁∩H={2}✓
  S₂∩H={4}✓  S₃∩H={4}✓ → all hit ✓
```

## Why Easy

This is the **exact dual** of `MinimumSetCovering`:
- SetCovering: select SETS to cover all ELEMENTS
- HittingSet: select ELEMENTS to hit all SETS
- Transpose the incidence matrix (rows ↔ columns)

~90% code reuse from `MinimumSetCovering`.

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| HittingSet → MinimumSetCovering | Trivial | Transpose incidence matrix |
| MinimumSetCovering → HittingSet | Trivial | Transpose back |
| HittingSet → ILP | Standard | min Σ wᵢxᵢ s.t. Σᵢ∈Sⱼ xᵢ ≥ 1 ∀j |

## Implementation Notes

- Struct mirrors `MinimumSetCovering` with roles of sets/elements swapped
- Validation: each set index < universe_size, non-empty sets
- Serialization: same JSON schema pattern as SetCovering/SetPacking
- Test: use the example above as primary test case

## Files to Create/Modify

1. `src/models/set/minimum_hitting_set.rs` — model
2. `src/models/set/mod.rs` — register module
3. `src/unit_tests/models/set/minimum_hitting_set.rs` — tests
4. `src/rules/minimumhittingset_minimumsetcovering.rs` — bidirectional reduction
5. `src/rules/minimumhittingset_ilp.rs` — ILP reduction
6. `src/rules/mod.rs` — register reductions
7. `docs/paper/reductions.typ` — problem-def + display-name + reduction-rules
