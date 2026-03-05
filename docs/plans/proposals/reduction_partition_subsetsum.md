# Reduction Proposal: Partition → SubsetSum

## Reduction Direction: One-way

### Partition → SubsetSum

**Algorithm:** Set target = sum(numbers) / 2

Given Partition instance with numbers A = {a₀, ..., aₙ₋₁}:
1. Compute S = Σ aᵢ
2. If S is odd → problem is trivially unsatisfiable (no reduction needed, but we still reduce and it will be unsatisfiable in SubsetSum too since target would not be integer)
3. Create SubsetSum instance: numbers = A, target = S / 2

**Correctness:**
- A partition exists ↔ there's a subset summing to S/2
- If subset sums to S/2, remaining elements also sum to S - S/2 = S/2

**Solution extraction:** Direct — config is identical (same binary variables)

**Overhead:** O(n) time for sum computation, O(1) extra space

## Implementation Pattern

```rust
struct PartitionToSubsetSumResult {
    target_problem: SubsetSum,
    // No solution transformation needed — identity mapping
}

impl ReduceTo<SubsetSum> for Partition {
    fn reduce(&self) -> PartitionToSubsetSumResult {
        let total: i64 = self.numbers.iter().sum();
        let target = total / 2;  // integer division; if odd, no solution exists
        PartitionToSubsetSumResult {
            target_problem: SubsetSum {
                numbers: self.numbers.clone(),
                target,
            }
        }
    }
}
```

## Notes

- This is one of the simplest reductions in the codebase
- Identity solution extraction (same variables, same meaning)
- Partition depends on SubsetSum being implemented first
