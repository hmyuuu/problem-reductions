# Model Proposal: SubsetSum

## Problem Definition

**Subset Sum**

Given a set of integers A = {a₀, a₁, …, aₙ₋₁} and a target value t, determine whether there exists a subset S ⊆ A such that Σᵢ∈S aᵢ = t.

- **Karp #18** (Karp's "Knapsack" is actually SubsetSum) | **Category:** number (new)
- **Reference:** Garey & Johnson (1979), [SP13]; CLRS Ch. 34
- **Complexity:** NP-complete (weakly)
- **Problem type:** Satisfaction (Metric = bool)

## Type Parameters

None. Numbers are always `i64` (large enough for interesting instances).

## Problem Trait Implementation

```rust
struct SubsetSum {
    numbers: Vec<i64>,    // the set of integers
    target: i64,          // target sum
}
```

- **`NAME`**: `"SubsetSum"`
- **`Metric`**: `bool` (satisfaction problem)
- **`dims()`**: `vec![2; numbers.len()]` — binary: include each number or not
- **`evaluate(config)`**: compute sum of selected numbers, return `sum == target`
- **`variant()`**: `[]`
- **`num_variables()`**: `numbers.len()`

## Example Instance

```
Numbers: [3, 7, 1, 8, -2]
Target: 6
Solutions:
  {3, 1, -2} → 3 + 1 + (-2) = 2 ✗ (that's 2, not 6)
  Actually: {3, 1, -2} → 3 + 1 - 2 = 2. Wrong.
  {7, 1, -2} → 7 + 1 - 2 = 6 ✓
  {3, 1, 2}... -2 is the value, so: {-2} has index 4
  Config [1,0,1,0,1] → 3+1+(-2) = 2 ✗
  Config [0,1,1,0,1] → 7+1+(-2) = 6 ✓
  Config [1,0,0,1,1] → 3+8+(-2) = 9 ✗
  Config [0,0,0,1,1] → 8+(-2) = 6 ✓
  Two solutions: {7,1,-2} and {8,-2}
```

## Why Easy

Simplest possible model:
- Single array + target integer
- Satisfaction check = one summation + equality test
- No graphs, no sets, no matrix structures
- ILP reduction is one equality constraint
- Natural foundation for Partition and Knapsack

## Category: `number`

This introduces a new model category `src/models/number/` for numeric problems. Other number problems (Partition, Knapsack, BinPacking) will join this category.

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| SubsetSum → ILP | Standard | min 0 s.t. Σ aᵢxᵢ = t, xᵢ ∈ {0,1} |
| SubsetSum → QUBO | Lucas 2014 §5 | H = A(Σ aᵢxᵢ − t)², expand quadratic |
| Partition → SubsetSum | Trivial | Set target = sum(A)/2 |

## Implementation Notes

- Create new category `src/models/number/mod.rs`
- Use `i64` for numbers (supports negative values, large enough for tests)
- No weight type parameter needed (always integer values)
- Simple validation: non-empty numbers list

## Files to Create/Modify

1. `src/models/number/mod.rs` — new category module
2. `src/models/number/subset_sum.rs` — model
3. `src/models/mod.rs` — register number category
4. `src/unit_tests/models/number/mod.rs` — test module
5. `src/unit_tests/models/number/subset_sum.rs` — tests
6. `src/rules/subsetsum_ilp.rs` — ILP reduction
7. `src/rules/mod.rs` — register
8. `docs/paper/reductions.typ` — paper entries
