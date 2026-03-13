# Plan: Add MinimumTardinessSequencing Model

**Issue:** #220
**Type:** [Model]
**Skill:** add-model

## Summary

Add `MinimumTardinessSequencing` -- a classical NP-complete single-machine scheduling problem (SS2 from Garey & Johnson) where unit-length tasks with precedence constraints and deadlines must be scheduled to minimize the number of tardy tasks. Corresponds to scheduling notation `1|prec, pj=1|sum Uj`.

## Information Checklist

| # | Item | Value |
|---|------|-------|
| 1 | Problem name | `MinimumTardinessSequencing` |
| 2 | Mathematical definition | Given tasks T with unit length, deadlines d(t), and partial order on T, find bijective schedule sigma minimizing tardy count |
| 3 | Problem type | Optimization (Minimize) |
| 4 | Type parameters | None |
| 5 | Struct fields | `num_tasks: usize`, `deadlines: Vec<usize>`, `precedences: Vec<(usize, usize)>` |
| 6 | Configuration space | `vec![num_tasks; num_tasks]` -- each task assigned a position 0..num_tasks |
| 7 | Feasibility check | Config must be a valid permutation AND respect precedence constraints |
| 8 | Objective function | Count of tardy tasks: |{t : sigma(t)+1 > d(t)}| |
| 9 | Best known exact algorithm | O(2^n * n) subset DP (Lawler et al. 1993) |
| 10 | Solving strategy | BruteForce (enumerate all configs, check validity) |
| 11 | Category | `misc` |

## Implementation Steps

### Batch 1 (parallel -- independent tasks)

#### Step 1: Create model file `src/models/misc/minimum_tardiness_sequencing.rs`

- Struct: `MinimumTardinessSequencing` with fields `num_tasks`, `deadlines`, `precedences`
- Constructor: `new(num_tasks, deadlines, precedences)` with validation
- Getters: `num_tasks()`, `num_precedences()`, `deadlines()`, `precedences()`
- `inventory::submit!` for `ProblemSchemaEntry`
- `Problem` impl: NAME = "MinimumTardinessSequencing", Metric = SolutionSize<usize>, dims = vec![num_tasks; num_tasks]
- `evaluate()`: check config length, check valid permutation (bijective), check precedence constraints, count tardy tasks
- `OptimizationProblem` impl: Value = usize, direction = Minimize
- `variant_params![]` (no type params)
- `declare_variants!`: `MinimumTardinessSequencing => "2^num_tasks"`
- `#[cfg(test)] #[path = "..."] mod tests;`

#### Step 2: Create unit test file `src/unit_tests/models/misc/minimum_tardiness_sequencing.rs`

- `test_minimum_tardiness_sequencing_basic`: construct instance, verify dims, direction, NAME, variant
- `test_minimum_tardiness_sequencing_evaluate_optimal`: verify the example from the issue (5 tasks, 1 tardy)
- `test_minimum_tardiness_sequencing_evaluate_invalid_permutation`: non-bijective config returns Invalid
- `test_minimum_tardiness_sequencing_evaluate_precedence_violation`: violating precedence returns Invalid
- `test_minimum_tardiness_sequencing_evaluate_all_on_time`: schedule where no tasks are tardy
- `test_minimum_tardiness_sequencing_brute_force`: verify BruteForce finds optimal
- `test_minimum_tardiness_sequencing_serialization`: round-trip serde
- `test_minimum_tardiness_sequencing_empty`: empty instance
- `test_minimum_tardiness_sequencing_no_precedences`: instance without precedences

### Batch 2 (parallel -- registration tasks, depend on Batch 1)

#### Step 3: Register model in module system

- `src/models/misc/mod.rs`: add `mod minimum_tardiness_sequencing;` and `pub use`
- `src/models/mod.rs`: add to `misc` re-export line

#### Step 4: Register in CLI dispatch

- `problemreductions-cli/src/dispatch.rs`: add `use` import, add match arms in `load_problem()` and `serialize_any_problem()`
- `problemreductions-cli/src/problem_name.rs`: add `"minimumtardinesssequencing"` alias in `resolve_alias()`

#### Step 5: Add CLI creation support

- `problemreductions-cli/src/cli.rs`: add `--deadlines` and `--precedence-pairs` flags to `CreateArgs`, update `all_data_flags_empty()`, add to "Flags by problem type" help table
- `problemreductions-cli/src/commands/create.rs`: add match arm for `"MinimumTardinessSequencing"`

### Batch 3 (sequential -- verification)

#### Step 6: Verify

- `make fmt`
- `make clippy`
- `make test`
