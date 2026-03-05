# Proposal: Easy-to-Add Problems & Reductions from Roadmap

> Based on deep analysis of the codebase (22 problems, 44 reduction edges) and the [Roadmap (Issue #1)](https://github.com/CodingThrust/problem-reductions/issues/1).

## Current State Summary

| Category | Problems | Count |
|----------|----------|-------|
| Graph | MIS, MaximalIS, VertexCover, DominatingSet, KColoring, MaxCut, Matching, Clique, TSP | 9 |
| Satisfiability | SAT, KSatisfiability, CircuitSAT | 3 |
| Set | SetCovering, SetPacking | 2 |
| Optimization | SpinGlass, QUBO, ILP | 3 |
| Specialized | Factoring, BicliqueCover, BMF, PaintShop | 4 |

**Already filed:** HamiltonianCycle ([#47](https://github.com/CodingThrust/problem-reductions/issues/47)), HamiltonianCycle→ILP ([#52](https://github.com/CodingThrust/problem-reductions/issues/52))

---

## Workflow Reference: Adding a Problem

1. **Model** → `src/models/<category>/<name>.rs` — struct + `Problem` trait + `OptimizationProblem` (if applicable)
2. **Register** → `src/models/<category>/mod.rs`
3. **Tests** → `src/unit_tests/models/<category>/<name>.rs` linked via `#[path]`
4. **Paper** → `docs/paper/reductions.typ` — `display-name` entry + `#problem-def`
5. **Verify** → `make test clippy && make coverage`

## Workflow Reference: Adding a Reduction

1. **Rule** → `src/rules/<source>_<target>.rs` — `ReductionResult` struct + `ReduceTo` impl with `#[reduction]` macro
2. **Register** → `src/rules/mod.rs`
3. **Tests** → `src/unit_tests/rules/<source>_<target>.rs` — closed-loop pattern
4. **Example** → `examples/reduction_<source>_to_<target>.rs` — `pub fn run()` + `fn main()`
5. **Example test** → `tests/suites/examples.rs`
6. **Paper** → `docs/paper/reductions.typ` — `#reduction-rule` entry
7. **Graph** → `cargo run --example export_graph`
8. **Verify** → `make test clippy && make coverage`

---

## Proposed Additions (Ranked by Ease)

### Tier 1: Very Easy — Heavy Reuse of Existing Code

---

#### 1. [Model] HittingSet

**Definition:**
Given a universe U = {1, …, n} and a collection S = {S₁, S₂, …, Sₘ} of subsets of U with weights w: U → ℝ, find a minimum-weight subset H ⊆ U such that H ∩ Sⱼ ≠ ∅ for every j.

- **Category:** set
- **Reference:** Garey & Johnson (1979), Problem [SP8]; Karp (1972) — dual of Set Cover
- **Complexity:** NP-complete

**Variables:**
- Count: n = |U|
- Per-variable domain: binary {0, 1}
- Meaning: xᵢ = 1 if element i is included in the hitting set

**Schema:**

| Field | Description |
|-------|-------------|
| `universe_size` | Size of the universe U |
| `sets` | Collection of subsets S₁, …, Sₘ (each a Vec of element indices) |
| `weights` | Weight w(i) for each element i ∈ U |

**Why easy:** This is the **exact dual** of `MinimumSetCovering` — transpose the incidence matrix (rows ↔ columns). The struct, evaluate logic, and ILP reduction are near-identical. ~90% code reuse.

**Example Instance:**

```
Universe: {0, 1, 2, 3, 4}
Sets: S₀={0,1,2}, S₁={2,3}, S₂={3,4}, S₃={0,4}
Weights: [1, 1, 1, 1, 1]
Optimal: H = {2, 3, 0} or {2, 4} — hit every set
```

**Reductions to add:**
- HittingSet ↔ MinimumSetCovering (transpose incidence matrix — both directions)
- HittingSet → ILP (copy MinimumSetCovering→ILP pattern)

---

#### 2. [Model] ExactCover

**Definition:**
Given a universe U = {1, …, n} and a collection S = {S₁, S₂, …, Sₘ} of subsets of U, find a sub-collection S* ⊆ S such that every element of U belongs to exactly one set in S*.

- **Category:** set
- **Reference:** Garey & Johnson (1979), Problem [SP2]; Karp (1972)
- **Complexity:** NP-complete

**Variables:**
- Count: m = |S|
- Per-variable domain: binary {0, 1}
- Meaning: xⱼ = 1 if set Sⱼ is selected

**Schema:**

| Field | Description |
|-------|-------------|
| `universe_size` | Size of the universe U |
| `sets` | Collection of subsets S₁, …, Sₘ |

**Why easy:** Special case of `MinimumSetCovering` where each element must be covered **exactly once** (equality constraint instead of ≥1). The satisfaction check changes from `count ≥ 1` to `count == 1`. This is a satisfaction problem (Metric = bool).

**Example Instance:**

```
Universe: {0, 1, 2, 3, 4, 5, 6}
Sets: S₀={0,3,6}, S₁={2,3,4}, S₂={1,2,5}, S₃={0,3}, S₄={4,5,6}, S₅={1,6}
Solution: {S₀, S₂, S₄} — covers each element exactly once
```

**Reductions to add:**
- ExactCover → MinimumSetCovering (trivial relaxation)
- ExactCover → ILP (equality constraints)

---

#### 3. [Model] SubsetSum

**Definition:**
Given a set of integers A = {a₁, a₂, …, aₙ} and a target value t, determine whether there exists a subset S ⊆ A such that Σᵢ∈S aᵢ = t.

- **Category:** optimization (new subcategory: `number`)
- **Reference:** Garey & Johnson (1979), Problem [SP13]; CLRS Chapter 34
- **Complexity:** NP-complete (weakly)

**Variables:**
- Count: n = |A|
- Per-variable domain: binary {0, 1}
- Meaning: xᵢ = 1 if aᵢ is selected

**Schema:**

| Field | Description |
|-------|-------------|
| `numbers` | The set of integers A = {a₁, …, aₙ} |
| `target` | The target sum t |

**Why easy:** Simplest possible model — single array + target, satisfaction check is just `sum == target`. No graphs needed. Pure numeric. ILP reduction is one equality constraint.

**Example Instance:**

```
Numbers: [3, 7, 1, 8, -2]
Target: 6
Solution: {3, 1, -2} → 3 + 1 + (-2) = 6 ✓
Alternative: {7, 1, -2} → 7 + 1 + (-2) = 6 ✓
```

**Reductions to add:**
- SubsetSum → ILP (single equality constraint: Σ aᵢxᵢ = t)

---

#### 4. [Model] Partition

**Definition:**
Given a multiset of integers A = {a₁, a₂, …, aₙ}, determine whether A can be partitioned into two subsets A₁ and A₂ such that Σᵢ∈A₁ aᵢ = Σᵢ∈A₂ aᵢ.

- **Category:** number
- **Reference:** Garey & Johnson (1979), Problem [SP12]; Karp (1972)
- **Complexity:** NP-complete (weakly)

**Variables:**
- Count: n = |A|
- Per-variable domain: binary {0, 1}
- Meaning: xᵢ = 1 if aᵢ is in partition A₁ (else in A₂)

**Schema:**

| Field | Description |
|-------|-------------|
| `numbers` | The multiset of integers A = {a₁, …, aₙ} |

**Why easy:** This is SubsetSum with target = sum(A)/2. Special case where we don't even need a target field. Model is ~25 lines.

**Example Instance:**

```
Numbers: [1, 5, 11, 5]
Sum = 22, Target = 11
Solution: A₁ = {1, 5, 5}, A₂ = {11} → both sum to 11 ✓
```

**Reductions to add:**
- Partition → SubsetSum (set target = sum/2)
- Partition → ILP (single equality constraint)

---

### Tier 2: Easy — Moderate New Code

---

#### 5. [Model] Knapsack

**Definition:**
Given a set of n items, each with weight wᵢ and value vᵢ, and a capacity C, find a subset that maximizes total value while keeping total weight ≤ C.

- **Category:** number
- **Reference:** Garey & Johnson (1979), Problem [MP9]; Karp (1972)
- **Complexity:** NP-complete (weakly)

**Variables:**
- Count: n (one per item)
- Per-variable domain: binary {0, 1}
- Meaning: xᵢ = 1 if item i is selected

**Schema:**

| Field | Description |
|-------|-------------|
| `weights` | Weight wᵢ per item |
| `values` | Value vᵢ per item |
| `capacity` | Maximum weight capacity C |

**Why easy:** Natural extension of SubsetSum (add values + capacity). Optimization problem (Maximize). ILP formulation is textbook-standard.

**Example Instance:**

```
Weights: [2, 3, 4, 5]
Values:  [3, 4, 5, 6]
Capacity: 5
Optimal: items {0, 1} → weight 5, value 7
```

**Reductions to add:**
- Knapsack → ILP (maximize cᵀx subject to wᵀx ≤ C)
- Knapsack → SubsetSum (special case when values = weights)

---

#### 6. [Model] CliqueCover

**Definition:**
Given an undirected graph G = (V, E) and an integer k, partition the vertices into at most k cliques (complete subgraphs).

- **Category:** graph
- **Reference:** Garey & Johnson (1979), Problem [GT17]; Karp (1972)
- **Complexity:** NP-complete

**Variables:**
- Count: n = |V|
- Per-variable domain: {0, 1, …, k-1}
- Meaning: xᵥ = color/clique assignment of vertex v

**Schema:**

| Field | Description |
|-------|-------------|
| `graph` | The graph G = (V, E) |
| `k` | Number of cliques (partitions) |

**Why easy:** This is **KColoring on the complement graph**. If you can color complement(G) with k colors, those color classes are cliques in G. The `KColoring` struct and `complement()` graph method already exist.

**Example Instance:**

```
Graph: V = {0,1,2,3,4}, E = {(0,1),(1,2),(2,3),(3,4),(0,4),(0,2),(1,3)}
k = 2
Solution: Clique₀ = {0, 1, 2}, Clique₁ = {3, 4}
  — {0,1,2} is a clique (all 3 edges present)
  — {3,4} is a clique (edge present)
```

**Reductions to add:**
- CliqueCover ↔ KColoring (complement graph — both directions)
- CliqueCover → ILP (assignment + adjacency constraints)

---

#### 7. [Rule] Max2SAT → QUBO

**Definition:**
Max 2-SAT is already representable as `KSatisfiability<Two>`. This rule provides a **direct** QUBO encoding (not through the generic SAT→KSat→QUBO chain) with tighter overhead.

- **Source:** KSatisfiability (K=2) — already exists
- **Target:** QUBO — already exists
- **Reference:** Glover & Kochenberger (2019), QUBO Tutorial; Lucas (2014) §4.4

**Why easy:** KSatisfiability<Two> already exists and `ksatisfiability_qubo.rs` handles the generic case. This would be an optimized specialization that produces smaller QUBO instances.

**Note:** This could also be filed as a separate optimization issue since the generic KSat→QUBO already covers K=2. Skip if out of scope.

---

### Tier 3: Moderate — New Infrastructure Needed

---

#### 8. [Model] BinPacking

- **Category:** number
- **Reference:** Garey & Johnson (1979), [SR1]
- Items with sizes, bins with capacity, minimize bins used
- **Why moderate:** Multi-dimensional configuration (item → bin assignment), needs careful `dims()` implementation

#### 9. [Model] FeedbackVertexSet

- **Category:** graph
- **Reference:** Garey & Johnson (1979), [GT7]; Karp (1972)
- Remove minimum vertices to make graph acyclic
- **Why moderate:** Needs cycle detection (topological sort) in `evaluate()`, requires directed graph support

---

## Recommended Implementation Order

```
Batch 1 (Models — 1 week):        Batch 2 (Rules — 1 week):
  1. SubsetSum                       5. SubsetSum → ILP
  2. Partition                       6. Partition → SubsetSum
  3. HittingSet                      7. HittingSet ↔ SetCovering
  4. ExactCover                      8. ExactCover → ILP
                                     9. HittingSet → ILP
                                    10. Partition → ILP

Batch 3 (Expand — 1 week):
 11. Knapsack (model + → ILP)
 12. CliqueCover (model + ↔ KColoring)
```

**Expected impact:**
- +6 problems → 28 total (completing 18/21 Karp's problems)
- +10-14 reduction edges → 54-58 total
- Establishes **number problem** infrastructure (SubsetSum/Partition/Knapsack family)
- Completes **set problem** family (HittingSet + ExactCover join SetCovering/SetPacking)
- Fills in the "easy wins" from Karp's original 21

---

## Issue Templates (Ready to File)

Each of the 6 proposed models and their reductions can be filed as individual `[Model]` and `[Rule]` issues following the format of [#47](https://github.com/CodingThrust/problem-reductions/issues/47) and [#52](https://github.com/CodingThrust/problem-reductions/issues/52). The definitions, schemas, examples, and reduction algorithms above provide the content needed for each issue.
