# Model Proposal: 3-Dimensional Matching (3DM)

## Problem Definition

**3-Dimensional Matching**

Given three disjoint sets X, Y, Z of equal size n, and a set T of triples (x, y, z) where x ∈ X, y ∈ Y, z ∈ Z, determine whether there exists a subset M ⊆ T of size n such that every element in X ∪ Y ∪ Z appears in exactly one triple of M.

- **Karp #17** | **Category:** set
- **Reference:** Garey & Johnson (1979), [SP1]; Karp (1972)
- **Complexity:** NP-complete
- **Problem type:** Satisfaction (Metric = bool)

## Problem Trait Implementation

```rust
struct ThreeDimensionalMatching {
    n: usize,                        // size of each set X, Y, Z
    triples: Vec<(usize, usize, usize)>,  // available triples (x,y,z)
}
```

- **`NAME`**: `"ThreeDimensionalMatching"`
- **`Metric`**: `bool`
- **`dims()`**: `vec![2; triples.len()]` — binary: select each triple or not
- **`evaluate(config)`**: collect selected triples. Check:
  1. Each x ∈ {0..n-1} appears exactly once across selected triples
  2. Each y ∈ {0..n-1} appears exactly once
  3. Each z ∈ {0..n-1} appears exactly once
  Return `true` iff all three conditions hold.
- **`variant()`**: `[]`

## Example Instance

```
n = 2 (X={0,1}, Y={0,1}, Z={0,1})
Triples: T₀=(0,0,0), T₁=(0,1,1), T₂=(1,0,1), T₃=(1,1,0)
Config [1,0,0,1] → {T₀, T₃} = {(0,0,0), (1,1,0)}
  X: {0,1} ✓  Y: {0,1} ✓  Z: {0,0} ✗ (element 0 appears twice)
Config [0,1,1,0] → {T₁, T₂} = {(0,1,1), (1,0,1)}
  X: {0,1} ✓  Y: {1,0} ✓  Z: {1,1} ✗ (element 1 twice)

Better example:
n = 2, Triples: T₀=(0,0,1), T₁=(1,1,0), T₂=(0,1,0), T₃=(1,0,1)
Config [1,1,0,0] → {T₀, T₁} = {(0,0,1), (1,1,0)}
  X: {0,1} ✓  Y: {0,1} ✓  Z: {1,0} ✓ → Matching found!
```

## Why Moderate (Tier 3)

- New data structure (triples), not directly reusing existing set/graph infrastructure
- But the evaluation logic is straightforward (counting)
- Special case of ExactCover (each triple is a "set" of 3 elements from X∪Y∪Z)

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| 3DMatching → ExactCover | Trivial | Each triple = a set of 3 elements from universe X∪Y∪Z (size 3n) |
| 3DMatching → MaximumSetPacking | Karp | Each triple as a 3-element set; find n disjoint sets |
| 3DMatching → SAT | Standard | Encode "exactly one" constraints per element as clauses |
| 3DMatching → ILP | Standard | Binary xₜ per triple; Σₜ:x∈t xₜ = 1 for each element |

## Implementation Notes

- Validation: all triple indices within bounds, non-empty triples list
- Canonically a special case of ExactCover → implement 3DM→ExactCover as primary reduction
- The 3-partite structure distinguishes it from general ExactCover
- Could also relate to HyperGraph matching (3-uniform hypergraph)

## Files to Create/Modify

1. `src/models/set/three_dimensional_matching.rs` — model
2. `src/models/set/mod.rs` — register
3. `src/unit_tests/models/set/three_dimensional_matching.rs` — tests
4. `src/rules/threedimensionalmatching_exactcover.rs` — reduction
5. `src/rules/threedimensionalmatching_maximumsetpacking.rs` — reduction
6. `src/rules/mod.rs` — register
7. `docs/paper/reductions.typ` — paper entries
