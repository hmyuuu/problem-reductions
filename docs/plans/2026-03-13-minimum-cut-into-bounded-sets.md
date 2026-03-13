# Plan: Add MinimumCutIntoBoundedSets Model (#228)

## Overview
Add the MinimumCutIntoBoundedSets satisfaction problem from Garey & Johnson ND17. This is a graph partitioning problem that asks whether vertices can be partitioned into two bounded-size sets (containing designated source and sink vertices) with total cut weight at most K.

## Information Checklist
1. **Problem name:** `MinimumCutIntoBoundedSets`
2. **Definition:** Given graph G=(V,E) with edge weights, source s, sink t, size bound B, cut bound K: partition V into V1 (containing s) and V2 (containing t) with |V1|<=B, |V2|<=B, and cut weight <= K.
3. **Problem type:** Satisfaction (Metric = bool)
4. **Type parameters:** `G: Graph`, `W: WeightElement`
5. **Struct fields:** `graph: G`, `edge_weights: Vec<W>`, `source: usize`, `sink: usize`, `size_bound: usize`, `cut_bound: W::Sum`
6. **Configuration space:** `vec![2; num_vertices]` (binary: 0=V1, 1=V2)
7. **Feasibility:** x_s=0, x_t=1, |V1|<=B, |V2|<=B, cut weight <= K
8. **Objective:** bool — all constraints satisfied
9. **Complexity:** `2^num_vertices` (brute force)
10. **Solving:** BruteForce (enumerate partitions)
11. **Category:** `graph`

## Steps

### Step 1: Create model file
**File:** `src/models/graph/minimum_cut_into_bounded_sets.rs`

- `inventory::submit!` for ProblemSchemaEntry with fields: graph, edge_weights, source, sink, size_bound, cut_bound
- Struct `MinimumCutIntoBoundedSets<G, W>` with fields: graph, edge_weights, source, sink, size_bound, cut_bound (where cut_bound is `W::Sum`)
- Constructor `new(graph, edge_weights, source, sink, size_bound, cut_bound)` with assertions
- Accessor methods: `graph()`, `source()`, `sink()`, `size_bound()`, `cut_bound()`, `edge_weights()`
- Size getters: `num_vertices()`, `num_edges()`
- `Problem` impl: NAME="MinimumCutIntoBoundedSets", Metric=bool, dims=vec![2; n], evaluate checks all constraints
- `SatisfactionProblem` impl (marker trait)
- `declare_variants!` with `MinimumCutIntoBoundedSets<SimpleGraph, i32> => "2^num_vertices"`
- Test link: `#[cfg(test)] #[path = "../../unit_tests/models/graph/minimum_cut_into_bounded_sets.rs"] mod tests;`

The `evaluate()` function must:
1. Check config length == num_vertices
2. Check config[source] == 0 (s in V1)
3. Check config[sink] == 1 (t in V2)
4. Count |V1| = vertices with config=0, |V2| = vertices with config=1
5. Check |V1| <= size_bound and |V2| <= size_bound
6. Compute cut weight (sum of edge weights where endpoints differ)
7. Return cut_weight <= cut_bound

### Step 2: Register the model
- `src/models/graph/mod.rs`: add `pub(crate) mod minimum_cut_into_bounded_sets;` and `pub use minimum_cut_into_bounded_sets::MinimumCutIntoBoundedSets;`
- `src/models/mod.rs`: add `MinimumCutIntoBoundedSets` to the graph re-export line

### Step 3: Register in CLI
- `problemreductions-cli/src/dispatch.rs`: add `deser_sat::<MinimumCutIntoBoundedSets<SimpleGraph, i32>>` in load_problem, `try_ser` in serialize_any_problem
- `problemreductions-cli/src/problem_name.rs`: add `"minimumcutintoboundedsets" => "MinimumCutIntoBoundedSets"`

### Step 4: Add CLI creation support
- `problemreductions-cli/src/commands/create.rs`: add creation handler that parses --graph, --edge-weights, --source, --sink, --size-bound, --cut-bound flags
- `problemreductions-cli/src/cli.rs`: add any needed flags (--source, --sink, --size-bound, --cut-bound) and update help table

### Step 5: Write unit tests
**File:** `src/unit_tests/models/graph/minimum_cut_into_bounded_sets.rs`

Tests:
- `test_minimumcutintoboundedsets_basic`: construct instance from issue example (8 vertices, 12 edges), verify dims
- `test_minimumcutintoboundedsets_evaluation`: test YES instance (V1={0,1,2,3}, K=6) returns true, NO instance (K=5 with same partition) returns false, invalid source/sink placement returns false
- `test_minimumcutintoboundedsets_serialization`: round-trip serde test
- `test_minimumcutintoboundedsets_solver`: BruteForce::find_satisfying finds a solution for K=6, returns None for K=5

Register test file in `src/unit_tests/models/graph/mod.rs`.

### Step 6: Document in paper
Add problem-def entry in `docs/paper/reductions.typ`:
- Add to `display-name` dict: `"MinimumCutIntoBoundedSets": [Minimum Cut Into Bounded Sets]`
- Add `#problem-def("MinimumCutIntoBoundedSets")[...][...]` with formal definition and background

### Step 7: Verify
```bash
make check  # fmt + clippy + test
```
