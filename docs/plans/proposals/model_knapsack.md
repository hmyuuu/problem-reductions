# Model Proposal: Knapsack

## Problem Definition

**0-1 Knapsack**

Given n items, each with weight wᵢ and value vᵢ, and a capacity C, find a subset of items that maximizes total value while keeping total weight ≤ C.

- **Karp #18 (generalization)** | **Category:** number
- **Reference:** Garey & Johnson (1979), [MP9]; Karp (1972)
- **Complexity:** NP-complete (weakly)
- **Problem type:** Optimization (Maximize)

## Problem Trait Implementation

```rust
struct Knapsack {
    weights: Vec<i64>,    // weight per item
    values: Vec<i64>,     // value per item
    capacity: i64,        // max weight capacity
}
```

- **`NAME`**: `"Knapsack"`
- **`Metric`**: `SolutionSize<i64>` (optimization)
- **`dims()`**: `vec![2; weights.len()]`
- **`evaluate(config)`**: total_weight = Σ wᵢ·xᵢ, total_value = Σ vᵢ·xᵢ. If total_weight ≤ capacity → `Valid(total_value)`, else `Invalid`
- **`direction()`**: `Maximize`
- **`variant()`**: `[]`

## Example Instance

```
Weights:  [2, 3, 4, 5]
Values:   [3, 4, 5, 6]
Capacity: 5
Config [1,1,0,0] → weight=5, value=7 ✓ (optimal)
Config [1,0,1,0] → weight=6 > 5 → Invalid
Config [0,1,0,0] → weight=3, value=4 ✓
Config [0,0,1,0] → weight=4, value=5 ✓
Best: {0,1} → weight 5, value 7
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| Knapsack → ILP | Standard | max vᵀx s.t. wᵀx ≤ C, x ∈ {0,1}ⁿ |
| Knapsack → QUBO | Lucas 2014 §5.2 | Penalty method: H = -A·Σvᵢxᵢ + B·(Σwᵢxᵢ - C)² with slack variables for inequality |
| Knapsack → SubsetSum | Special case | When values = weights, it becomes SubsetSum |

## Implementation Notes

- Natural extension of SubsetSum (add value array + capacity constraint)
- First optimization problem in the `number` category
- Validation: weights.len() == values.len(), all weights > 0, capacity > 0

## Files to Create/Modify

1. `src/models/number/knapsack.rs` — model
2. `src/models/number/mod.rs` — register
3. `src/unit_tests/models/number/knapsack.rs` — tests
4. `src/rules/knapsack_ilp.rs` — ILP reduction
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
