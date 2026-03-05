# Model Proposal: Partition

## Problem Definition

**Number Partition**

Given a multiset of positive integers A = {a₀, a₁, …, aₙ₋₁}, determine whether A can be partitioned into two subsets A₁ and A₂ such that Σᵢ∈A₁ aᵢ = Σᵢ∈A₂ aᵢ.

- **Karp #20** | **Category:** number
- **Reference:** Garey & Johnson (1979), [SP12]; Karp (1972)
- **Complexity:** NP-complete (weakly)
- **Problem type:** Satisfaction (Metric = bool)

## Type Parameters

None.

## Problem Trait Implementation

```rust
struct Partition {
    numbers: Vec<i64>,    // the multiset of integers
}
```

- **`NAME`**: `"Partition"`
- **`Metric`**: `bool` (satisfaction problem)
- **`dims()`**: `vec![2; numbers.len()]` — binary: assign each to partition 0 or 1
- **`evaluate(config)`**: compute sum of each partition, return `sum₀ == sum₁` (equivalently, `sum_selected == total_sum / 2`)
- **`variant()`**: `[]`

## Example Instance

```
Numbers: [1, 5, 11, 5]
Total sum = 22, Target = 11
Config [1,1,0,1] → A₁ = {1,5,5} = 11, A₂ = {11} = 11 ✓
Config [0,0,1,0] → A₁ = {11} = 11, A₂ = {1,5,5} = 11 ✓
```

## Why Easy

This is **SubsetSum with target = sum(A)/2**:
- If total sum is odd → immediately unsatisfiable
- Otherwise, find subset summing to total/2
- Model is ~25 lines

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| Partition → SubsetSum | Trivial | Set target = sum(numbers)/2 |
| Partition → ILP | Standard | Σ aᵢxᵢ = S/2, xᵢ ∈ {0,1} |
| Partition → QUBO | Lucas 2014 §5.1 | H = A(Σ aᵢsᵢ)² where sᵢ ∈ {±1}. Even simpler than SubsetSum→QUBO |

## Implementation Notes

- Depends on SubsetSum being available (for Partition→SubsetSum reduction)
- Immediate infeasibility check: if sum is odd, no valid config exists
- All numbers should be positive for classic definition (negatives make it trivially easier)

## Files to Create/Modify

1. `src/models/number/partition.rs` — model
2. `src/models/number/mod.rs` — register (already created for SubsetSum)
3. `src/unit_tests/models/number/partition.rs` — tests
4. `src/rules/partition_subsetsum.rs` — reduction to SubsetSum
5. `src/rules/partition_ilp.rs` — ILP reduction
6. `src/rules/mod.rs` — register
7. `docs/paper/reductions.typ` — paper entries
