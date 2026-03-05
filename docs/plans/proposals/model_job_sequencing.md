# Model Proposal: JobSequencing

## Problem Definition

**Job Sequencing with Deadlines**

Given n jobs, each with a deadline dⱼ and profit pⱼ, where each job takes unit time, find a schedule that maximizes total profit. A job can only be included if it is completed by its deadline. At most one job can be scheduled per time slot.

- **Karp #19** | **Category:** number (scheduling)
- **Reference:** Garey & Johnson (1979); Karp (1972)
- **Complexity:** NP-complete (general weighted case)
- **Problem type:** Optimization (Maximize)

## Problem Trait Implementation

```rust
struct JobSequencing {
    deadlines: Vec<usize>,   // deadline per job (1-indexed time slots)
    profits: Vec<i64>,       // profit per job
}
```

- **`NAME`**: `"JobSequencing"`
- **`Metric`**: `SolutionSize<i64>`
- **`dims()`**: `vec![2; deadlines.len()]` — binary: schedule job or skip
- **`evaluate(config)`**:
  1. Collect selected jobs, sort by deadline
  2. Greedily assign to earliest available time slot ≤ deadline
  3. If all selected jobs can be scheduled → `Valid(total_profit)`, else `Invalid`

  Alternative (simpler, but more variables): use assignment encoding
  - dims = `vec![max_deadline + 1; n]` — assign each job to a time slot (or 0 = skip)
  - Check: no two jobs in same slot, each job before its deadline
- **`direction()`**: `Maximize`
- **`variant()`**: `[]`

## Example Instance

```
Jobs: [(deadline=2, profit=100), (deadline=1, profit=19), (deadline=2, profit=27), (deadline=1, profit=25), (deadline=3, profit=15)]
Config [1,0,1,0,1] → select jobs {0,2,4}
  Job 0 (d=2, p=100): slot 1 ✓
  Job 2 (d=2, p=27): slot 2 ✓
  Job 4 (d=3, p=15): slot 3 ✓
  Total profit: 142 ✓
```

## Why Moderate (Tier 3)

- Scheduling feasibility check is more complex than simple sum
- The greedy assignment in `evaluate()` needs careful implementation
- QUBO formulation exists (Venturelli et al. 2016) but requires assignment variables
- However, the binary selection version is simple enough

## Design Decision: Binary Selection vs Assignment

**Option A: Binary selection** (simpler)
- `dims = [2; n]`, select which jobs to include
- Feasibility: check if selected jobs can be scheduled (greedy)
- Pro: fewer variables, simple
- Con: feasibility check is non-trivial

**Option B: Assignment encoding** (more explicit)
- `dims = [max_deadline + 1; n]` (0 = don't schedule, 1..D = time slot)
- Feasibility: no conflicts, respect deadlines
- Pro: evaluate is simpler (direct checking)
- Con: more variables

**Recommendation: Option A** (binary selection) — matches other problems' style, fewer variables for brute force.

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| JobSequencing → ILP | Standard | Binary xⱼ per job; for each time slot t: Σⱼ:dⱼ≥t xⱼ ≤ t (cumulative constraint). Max Σ pⱼxⱼ |
| JobSequencing → QUBO | Venturelli 2016 | Assignment encoding with penalty terms for conflicts |
| Partition → JobSequencing | Known | Reduction from Partition proves NP-completeness |

## Files to Create/Modify

1. `src/models/number/job_sequencing.rs` — model
2. `src/models/number/mod.rs` — register
3. `src/unit_tests/models/number/job_sequencing.rs` — tests
4. `src/rules/jobsequencing_ilp.rs` — ILP reduction
5. `src/rules/mod.rs` — register
6. `docs/paper/reductions.typ` — paper entries
