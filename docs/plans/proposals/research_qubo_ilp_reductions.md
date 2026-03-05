# Research: QUBO and ILP Reduction Formulations

> Compiled: 2026-02-27 | Reference: Lucas (2014) arXiv:1302.5843

This document consolidates the mathematical details for all proposed QUBO and ILP reductions.
It cross-references the existing proposal documents in this directory, the Lucas (2014) paper,
and the actual Rust implementations in `src/rules/` where they exist.

---

## Notation and Conventions

**QUBO (Quadratic Unconstrained Binary Optimization):**
The codebase minimizes `f(x) = x^T Q x = Σᵢ Σⱼ Qᵢⱼ xᵢ xⱼ` over binary `xᵢ ∈ {0, 1}`.
The Q matrix is stored upper-triangular. Ground state energy = 0 indicates a feasible solution
for penalty-based encodings.

**ILP in this codebase:**
`ILP` is a flexible struct with `VarBounds`, `LinearConstraint` (supporting `Le`, `Ge`, `Eq`),
sparse objective coefficients, and `ObjectiveSense` (Maximize/Minimize). All existing
problem-to-ILP reductions use `VarBounds::binary()` for the core variables.

**Penalty coefficient convention:**
For QUBO reductions, the penalty `P` must dominate the objective so that infeasible
configurations always have higher energy than the optimal feasible one. A common choice is
`P = 1 + Σᵢ wᵢ` (sum of weights plus one). For unweighted problems, `P = 1 + n` suffices.

---

## Part I: QUBO Reductions

### 1. SubsetSum → QUBO (Lucas 2014 §5)

**Reference:** `docs/plans/proposals/reduction_subsetsum_qubo.md`

**Problem:** Given numbers A = {a₀, …, aₙ₋₁} ⊆ ℤ and target t ∈ ℤ,
decide whether Σᵢ aᵢxᵢ = t has a binary solution.

**Hamiltonian:**
```
H = A · (Σᵢ aᵢxᵢ − t)²
```
where A > 0. Ground state H = 0 iff a valid subset exists.

**Expansion to QUBO** (using xᵢ² = xᵢ):
```
H = A · (Σᵢ aᵢ²xᵢ² + 2·Σᵢ<ⱼ aᵢaⱼxᵢxⱼ − 2t·Σᵢ aᵢxᵢ + t²)
  = A · (Σᵢ (aᵢ² − 2t·aᵢ)xᵢ + 2·Σᵢ<ⱼ aᵢaⱼxᵢxⱼ) + A·t²
```

**Q matrix entries:**
- `Qᵢᵢ = A · aᵢ · (aᵢ − 2t)`
- `Qᵢⱼ = 2A · aᵢaⱼ`  for i < j
- Constant offset: `A·t²` (irrelevant to optimization)

**Sign correctness note:**
The diagonal term `aᵢ(aᵢ − 2t)` is negative when `aᵢ < 2t` (which is common for small elements
relative to target), meaning those variables are incentivized to be selected. This is correct:
selecting `xᵢ = 1` with small `aᵢ` is energetically favorable when trying to build up to t.
The off-diagonal `2aᵢaⱼ > 0` penalizes co-selection, reflecting that the squared sum grows
when both are included simultaneously beyond the target.

**Penalty coefficient:**
`A = 1` works for the feasibility version (minimum energy 0 = exact subset sum).
No penalty tuning needed — the ground state is exactly zero.

**Overhead:**
- Variables: n (one per element)
- Q matrix entries: n² (dense; all pairs interact)
- No auxiliary variables required

**Solution extraction:** Direct. The QUBO solution xᵢ is the SubsetSum selection.

**Tightness:** Exact. The ground state energy is 0 if and only if the selected
subset sums to t. Energy = A·(sum − t)² for any assignment.

---

### 2. Partition → QUBO (Lucas 2014 §5.1)

**Reference:** `docs/plans/proposals/reduction_partition_qubo.md`

**Problem:** Given numbers A = {a₀, …, aₙ₋₁}, decide whether they can be split
into two equal-sum subsets.

**Ising Hamiltonian** (spin variables sᵢ ∈ {+1, −1}):
```
H = A · (Σᵢ aᵢsᵢ)²
```
where sᵢ = +1 means "partition A₁" and sᵢ = −1 means "partition A₂".
Ground state H = 0 iff Σ aᵢsᵢ = 0, i.e., the two groups have equal sum.

**QUBO substitution** (xᵢ = (1 − sᵢ)/2, so sᵢ = 1 − 2xᵢ):
```
Σᵢ aᵢsᵢ = Σᵢ aᵢ(1 − 2xᵢ) = S − 2·Σᵢ aᵢxᵢ
```
where S = Σᵢ aᵢ.

```
H = A · (S − 2·Σᵢ aᵢxᵢ)²
  = A · (S² − 4S·Σᵢ aᵢxᵢ + 4·(Σᵢ aᵢxᵢ)²)
```

**Q matrix entries** (after expanding and using xᵢ² = xᵢ):
- `Qᵢᵢ = A · 4aᵢ · (aᵢ − S)` = `A · (4aᵢ² − 4S·aᵢ)`
- `Qᵢⱼ = A · 8aᵢaⱼ`  for i < j
- Constant: `A·S²`

**Comparison with SubsetSum → QUBO:**
Partition → QUBO is SubsetSum → QUBO with implicit target t = S/2, scaled by 4.
Specifically, substituting t = S/2 into the SubsetSum formula:
- SubsetSum Qᵢᵢ = A(aᵢ² − 2·(S/2)·aᵢ) = A(aᵢ² − S·aᵢ)
- Partition Qᵢᵢ = A(4aᵢ² − 4S·aᵢ) = 4·SubsetSum Qᵢᵢ (with same A)

The factor-4 scaling comes from the sᵢ = 1 − 2xᵢ substitution. Both are correct.

**Overhead:**
- Variables: n
- Q matrix entries: n² (dense)
- No auxiliaries

**Solution extraction:** Direct. xᵢ = 0 → partition A₁, xᵢ = 1 → partition A₂.

---

### 3. Knapsack → QUBO (Lucas 2014 §5.2)

**Reference:** `docs/plans/proposals/reduction_knapsack_qubo.md`

**Problem:** Given n items with weights wᵢ, values vᵢ, and capacity C,
maximize Σ vᵢxᵢ subject to Σ wᵢxᵢ ≤ C.

**Key challenge:** The inequality constraint Σ wᵢxᵢ ≤ C must be encoded.

**Step 1: Slack variable introduction**

Introduce binary slack variables y₀, y₁, …, y_{s-1} where s = ⌈log₂(C+1)⌉,
encoding the slack value Δ = C − Σ wᵢxᵢ ∈ {0, …, C} in binary:
```
Σᵢ wᵢxᵢ + Σⱼ 2ʲyⱼ = C
```

Number of slack variables: `s = ⌈log₂(C + 1)⌉`.

**Step 2: QUBO Hamiltonian**
```
H = −A·Σᵢ vᵢxᵢ + B·(Σᵢ wᵢxᵢ + Σⱼ 2ʲyⱼ − C)²
```
where:
- First term: objective (maximize value = minimize negative value)
- Second term: penalty for violating the capacity constraint

**Penalty coefficient condition:** `B > A·max(vᵢ)` ensures that the optimizer
prefers any feasible solution over any infeasible one. More precisely:
- The objective term can contribute at most A·Σvᵢ in benefit
- The penalty term contributes at least B·1 = B for any infeasible assignment
- So `B > A·Σvᵢ` is sufficient (though `B > A·max(vᵢ)` is the tighter sufficient condition)

**Q matrix entries:**

Let the full variable vector be z = (x₀, …, xₙ₋₁, y₀, …, y_{s-1}).
Define coefficients: cᵢ = wᵢ for item variables, cₙ₊ⱼ = 2ʲ for slack variables.

- Objective contribution (item variables only): `Qᵢᵢ -= A·vᵢ`
- Penalty diagonal: `Qₖₖ += B·(cₖ² − 2C·cₖ)` = `B·cₖ·(cₖ − 2C)`
- Penalty off-diagonal: `Qₖₗ += 2B·cₖcₗ`  for k < l

**Total variables:** n + ⌈log₂(C+1)⌉

**Overhead summary:**
- n item variables + O(log C) slack variables
- Dense (n + log C)² QUBO matrix
- Penalty tuning: B > A·max(vᵢ)

**Solution extraction:**
Read x₀, …, xₙ₋₁ from the QUBO solution (discard slack variables y).
Verify feasibility: check Σ wᵢxᵢ ≤ C.

**Tightness:** The formulation is tight — every binary assignment satisfying
the equality is a feasible knapsack assignment, and vice versa.

**Important implementation note:** The slack variable encoding assumes
C is integer (which it is for Knapsack). The encoding `Σⱼ 2ʲyⱼ` can represent
any value in {0, …, 2^s − 1}. If 2^s − 1 > C, some slack values overshoot;
this is handled by the fact that any such assignment would also violate the equality,
increasing the penalty.

---

### 4. MaxSAT → QUBO

**Reference:** `docs/plans/proposals/reduction_maxsat_qubo.md`

**Problem:** Given Boolean variables x₁, …, xₙ and weighted clauses (Cⱼ, wⱼ),
maximize total weight of satisfied clauses.

**Key insight:** Each clause Cⱼ = (l₁ ∨ l₂ ∨ … ∨ lₖ) is unsatisfied iff all
literals are false. The "unsatisfied indicator" is:
```
P(Cⱼ) = Πᵢ (1 − lᵢ*)
```
where lᵢ* = xᵢ if literal is positive, lᵢ* = 1 − xᵢ if negated.

**QUBO Hamiltonian:** `H = Σⱼ wⱼ · P(Cⱼ)`  (minimize = maximize satisfied weight)

**Case 1: MAX-2-SAT (k = 2 literals per clause)**

The product P(C) = (1 − l₁*)(1 − l₂*) is at most quadratic → direct QUBO.
The four cases based on literal signs:
- `(xᵢ ∨ xⱼ)`:  penalty `(1−xᵢ)(1−xⱼ) = 1 − xᵢ − xⱼ + xᵢxⱼ`
  → Qᵢᵢ −= w, Qⱼⱼ −= w, Qᵢⱼ += w, constant += w
- `(¬xᵢ ∨ xⱼ)`:  penalty `xᵢ(1−xⱼ) = xᵢ − xᵢxⱼ`
  → Qᵢᵢ += w, Qᵢⱼ −= w
- `(xᵢ ∨ ¬xⱼ)`:  penalty `(1−xᵢ)xⱼ = xⱼ − xᵢxⱼ`
  → Qⱼⱼ += w, Qᵢⱼ −= w
- `(¬xᵢ ∨ ¬xⱼ)`:  penalty `xᵢxⱼ`
  → Qᵢⱼ += w

**Overhead:** n variables, no auxiliaries, n² matrix (sparse for sparse clauses).
This matches the existing `KSatisfiability<K2> → QUBO` in `src/rules/ksatisfiability_qubo.rs`,
extended with per-clause weights instead of unit weights.

**Case 2: MAX-3-SAT (k = 3 literals per clause)**

P(C) = y₁y₂y₃ where yᵢ = 1 − lᵢ* is cubic — not directly QUBO.

**Rosenberg quadratization:** Introduce auxiliary `a = y₁y₂` via:
```
H_clause = a·y₃ + M·(y₁y₂ − 2y₁a − 2y₂a + 3a)
```
where M = 2 suffices (any M ≥ 2 enforces a = y₁y₂ at the ground state).

The term `M·(y₁y₂ − 2y₁a − 2y₂a + 3a)` is the Rosenberg polynomial for the
constraint `a = y₁y₂`:
- If y₁y₂ = 0 and a = 0: penalty = 0 ✓
- If y₁y₂ = 1 and a = 1: penalty = 1 − 2 − 2 + 3 = 0 ✓
- If y₁y₂ = 0 and a = 1: penalty = −2 − 2 + 3 = −1 < 0, so add M to make it positive
  With M = 2: M·(0 − 0 − 2·1 + 3·1) = M·1 = 2 > 0 ✓

**Overhead for MAX-3-SAT:**
- n original variables + m auxiliary variables (one per clause)
- Total: n + m variables
- Matrix size: (n + m)² entries

**General k-clause:**
Each clause of k literals requires k − 2 auxiliary variables (Rosenberg chain).
Total auxiliaries: Σⱼ (kⱼ − 2).

For MAX-k-SAT with uniform clause size:
- n + m·(k−2) total variables
- Dense (n + m(k−2))² QUBO

**Weighted clause handling:**
Multiply all QUBO contributions of clause j by its weight wⱼ.
The penalty coefficient M must also scale: `M·wⱼ` for each clause.

**Solution extraction:**
Read x₀, …, xₙ₋₁ (discard the auxiliary variables at indices n, n+1, …, n+m−1).
The total satisfied weight = (Σⱼ wⱼ) − H(x*) where H(x*) is the ground state energy.

---

### 5. MinimumBisection → QUBO (Lucas 2014 §3)

**Reference:** `docs/plans/proposals/reduction_minimumbisection_qubo.md`

**Problem:** Given graph G = (V, E) with |V| = 2n, partition V into two equal
sets minimizing the number of crossing edges.

**Ising Hamiltonian:**
```
H = A·Σ_{(i,j)∈E} (1 − sᵢsⱼ)/2  +  B·(Σᵢ sᵢ)²
```
- First term: counts cut edges (0 for same partition, 1 for different partitions)
- Second term: penalizes partition imbalance; equals 0 iff |partition+| = |partition−| = n

**QUBO substitution** (xᵢ = (1 − sᵢ)/2, sᵢ = 1 − 2xᵢ):

First term H_cut:
```
(1 − sᵢsⱼ)/2 = (1 − (1−2xᵢ)(1−2xⱼ))/2
             = (1 − 1 + 2xᵢ + 2xⱼ − 4xᵢxⱼ)/2
             = xᵢ + xⱼ − 2xᵢxⱼ
```
So `H_cut = A·Σ_{(i,j)∈E} (xᵢ + xⱼ − 2xᵢxⱼ)`.

Second term H_balance:
```
Σᵢ sᵢ = Σᵢ (1 − 2xᵢ) = 2n − 2·Σxᵢ
(Σᵢ sᵢ)² = 4·(n − Σxᵢ)² = 4·(n² − 2n·Σxᵢ + (Σxᵢ)²)
```
Expanding (Σxᵢ)² = Σxᵢ² + 2Σᵢ<ⱼ xᵢxⱼ = Σxᵢ + 2Σᵢ<ⱼ xᵢxⱼ (using xᵢ² = xᵢ):
```
H_balance = B·4·(n² − 2n·Σxᵢ + Σxᵢ + 2·Σᵢ<ⱼ xᵢxⱼ)
```

**Full Q matrix entries:**

Diagonal (`Qᵢᵢ`):
- From H_cut: `+A·deg(i)` (degree of vertex i; from the xᵢ + xⱼ expansion)
- From H_balance: `+4B·(1 − 2n)` = `4B − 8Bn`
- Total: `Qᵢᵢ = A·deg(i) + 4B·(1 − 2n)`

Off-diagonal (`Qᵢⱼ`, i < j):
- From H_cut (only for edges): `−2A·wᵢⱼ` (where wᵢⱼ = edge weight, 1 for unweighted)
- From H_balance (for ALL pairs): `+8B`
- Total for edges: `Qᵢⱼ = −2A + 8B`
- Total for non-edges: `Qᵢⱼ = 8B`

**Penalty condition:** `B > A·|E| / (4n²)` is a conservative bound; in practice
`B > A·n/2` ensures the balance term dominates any cut objective gain.
A common choice: `B = A · (|E| + 1)`.

**Overhead:**
- Variables: |V| = 2n
- Q matrix: |V|² entries (dense, even for sparse graphs — due to balance constraint)
- No auxiliary variables

**Solution extraction:**
xᵢ = 0 → partition A, xᵢ = 1 → partition B.
Check |{i : xᵢ = 0}| = |{i : xᵢ = 1}| = n; invalid otherwise.

**Tightness note:**
The formulation is dense because the balance constraint `(Σsᵢ)²` couples all pairs.
This is inherent: enforcing global equality requires all-to-all interactions.
The ILP formulation (linear balance constraint) avoids this, but requires more variables.

---

### 6. MaximumClique → QUBO (Lucas 2014 §3.2)

**Reference:** `docs/plans/proposals/reduction_missing_cross_reductions.md`

**Problem:** Find the maximum weight clique in graph G = (V, E).

**Hamiltonian (Lucas §3.2, eq. for clique):**
```
H = −A·Σᵥ xᵥ + B·Σ_{(u,v)∉E} xᵤxᵥ
```
- First term: reward for selecting more vertices (maximize clique size)
- Second term: penalty for selecting a non-adjacent pair (violates clique constraint)

**Q matrix entries:**
- `Qᵥᵥ = −A` (diagonal: reward for each selected vertex)
- `Qᵤᵥ = +B` for each non-edge (u,v) ∉ E (quadratic penalty)
- `Qᵤᵥ = 0` for edges (u,v) ∈ E (no penalty for adjacent pairs)

**Weighted generalization:**
Replace `−A` with `−A·wᵥ` (vertex weight). The penalty coefficient
`B > A·Σwᵥ` ensures any non-clique assignment is penalized beyond the maximum
possible clique objective.

**Comparison with MaximumIndependentSet → QUBO:**
MaxClique on G = MaxIS on complement G̅. Indeed, the MaxClique QUBO formula
is identical to the MaxIS formula on the complement graph (where non-edges become edges).
The existing `MaximumIndependentSet → QUBO` uses:
```
H_MIS = −A·Σwᵢxᵢ + P·Σ_{(i,j)∈E} xᵢxⱼ
```
MaxClique → QUBO replaces the edge set E with the complement edge set Ē:
```
H_Clique = −A·Σwᵢxᵢ + P·Σ_{(i,j)∉E} xᵢxⱼ
```

**Overhead:**
- Variables: |V|
- Entries: |V|² in the worst case (complete bipartite complement = sparse original graph)
- For dense graphs (few non-edges): sparse QUBO
- No auxiliary variables

**Solution extraction:** Direct. xᵥ = 1 iff vertex v is in the clique.

**Non-edge enumeration:** Computing all non-edges takes O(|V|²) time.
This is unavoidable when the original graph is sparse (most pairs are non-edges).

---

### 7. MinimumDominatingSet → QUBO (Lucas 2014 §4.3)

**Reference:** `docs/plans/proposals/reduction_missing_cross_reductions.md`

**Problem:** Find minimum weight dominating set: a set S ⊆ V such that every
vertex v ∈ V is either in S or has a neighbor in S.

**Domination constraint:** For each vertex v, at least one of {v} ∪ N(v) must be selected.
Let N_closed(v) = {v} ∪ N(v) (closed neighborhood).

**QUBO Hamiltonian:**
```
H = A·Σᵥ wᵥ·xᵥ  +  B·Σᵥ f(xᵥ, {xᵤ : u ∈ N(v)})
```
where `f(...)` = 1 if v is not dominated = 0 if v ∈ S or some neighbor of v ∈ S.

The domination indicator (v not dominated) is:
```
f_v = (1 − xᵥ) · Πᵤ∈N(v) (1 − xᵤ)
```
This is a product of (1 + deg(v)) binary terms — a high-degree polynomial.

**Quadratization of the domination penalty:**

The product must be reduced to degree ≤ 2 for QUBO.
For vertex v with neighbors N(v) = {u₁, …, u_d}:

Let y = 1 − xᵥ. The constraint is: `y · Πᵢ (1 − xᵤᵢ) = 0`.

For each vertex v, the minimum-degree quadratization requires O(deg(v)) auxiliary variables.
However, Lucas (2014) §4.3 uses a different approach: introduce a binary variable `aᵥ`
representing "v is covered" (= at least one of N_closed(v) is selected).

**Lucas' auxiliary variable approach:**

For each vertex v, introduce `aᵥ ∈ {0, 1}` where `aᵥ = 1 − ΠᵤΝ_closed(v) (1 − xᵤ)`.

Penalty for `aᵥ` being inconsistent (not matching coverage status) uses a Rosenberg-like term.

In practice, the direct Lucas formulation is dense:
- `Qᵥᵥ = Awᵥ − B·(1 + deg(v))·(sum of neighborhood terms)`
- Cross-terms for all pairs within each closed neighborhood

**Simplified observation (equivalent to covering ILP):**

The QUBO can be thought of as a penalty-form set cover:
each vertex v defines a "constraint set" N_closed(v), and we need at least one element
selected from each constraint set.

This matches the structure of `MinimumSetCovering → QUBO`, which could be implemented as:
```
H = A·Σᵥ wᵥxᵥ + B·Σᵥ (covering_gap(v))²
```
where `covering_gap(v)` = 1 if v is not dominated.

**Overhead:**
- Variables: |V| + O(|V|) auxiliary variables (one per vertex constraint)
- Q matrix: O((|V| + max_degree)²) entries
- Penalty coefficient: B > A·Σwᵥ

**Tightness:** Exact when penalty B is large enough relative to the objective weights.

**Implementation recommendation:**
Direct QUBO via auxiliary variables. The DominatingSet → ILP formulation
(`src/rules/minimumdominatingset_ilp.rs`) is cleaner; the QUBO formulation is
best derived via the neighborhood expansion with quadratization auxiliaries.

---

## Part II: ILP Reductions

### 8. SubsetSum → ILP

**Reference:** `docs/plans/proposals/reduction_subsetsum_ilp.md`

**ILP formulation:**
```
minimize  0        (feasibility)
subject to:
    Σᵢ aᵢ·xᵢ = t
    xᵢ ∈ {0, 1}
```

**Overhead:**
- Variables: n (binary)
- Constraints: 1 equality constraint
- Nonzeros: n (fully dense constraint row)
- Objective: zero (feasibility)

The ILP struct supports `Comparison::Eq` directly, so a single equality constraint suffices.

**Solution extraction:** Direct. xᵢ = ILP solution.

**Tightness:** Exact. The ILP feasibility ↔ SubsetSum satisfiability.

---

### 9. Partition → ILP

**Reference:** `docs/plans/proposals/reduction_partition_ilp.md`

**ILP formulation:**
```
minimize  0        (feasibility)
subject to:
    Σᵢ aᵢ·xᵢ = S/2    where S = Σᵢ aᵢ
    xᵢ ∈ {0, 1}
```

If S is odd → no integer solution (infeasible by construction).

**Overhead:** n variables, 1 constraint.

**Alternative via SubsetSum:** Partition → SubsetSum → ILP (with target = S/2).
The direct ILP is marginally simpler (avoids the intermediate SubsetSum model).

---

### 10. ExactCover → ILP

**Reference:** `docs/plans/proposals/reduction_exactcover_ilp.md`

**Problem:** Given universe U = {0, …, n−1} and sets S₀, …, Sₘ₋₁, find a
collection of sets that covers every element exactly once.

**ILP formulation:**
```
minimize  0        (feasibility)
subject to:
    Σ_{j: i∈Sⱼ} xⱼ = 1    for each i ∈ U  (exactly-once coverage)
    xⱼ ∈ {0, 1}
```

**Overhead:**
- Variables: m (one per set)
- Constraints: n (one per element)
- Nonzeros: Σⱼ |Sⱼ| (total set membership count)
- Supports `Comparison::Eq` directly

**Solution extraction:** Direct. xⱼ = 1 iff set Sⱼ is selected.

**Comparison with MinimumSetCovering → ILP:**
ExactCover replaces `≥ 1` with `= 1`. This is a strictly harder constraint.
The existing `MinimumSetCovering → ILP` uses `Comparison::Ge`; ExactCover uses `Comparison::Eq`.

---

### 11. HittingSet → ILP

**Reference:** `docs/plans/proposals/reduction_hittingset_ilp.md`

**Problem:** Given universe U and sets S₀, …, Sₘ₋₁ with element weights w,
find minimum weight H ⊆ U such that H ∩ Sⱼ ≠ ∅ for all j.

**ILP formulation:**
```
minimize  Σᵢ wᵢ·xᵢ
subject to:
    Σ_{i∈Sⱼ} xᵢ ≥ 1    for each set j
    xᵢ ∈ {0, 1}
```

**Overhead:**
- Variables: n = |U| (element variables)
- Constraints: m (one per set)
- Nonzeros: Σⱼ |Sⱼ|

**Relationship to MinimumSetCovering:**
HittingSet is the LP dual of SetCovering. The roles of elements and sets are transposed:
- SetCovering: variable per set, constraint per element
- HittingSet: variable per element, constraint per set

This near-identical structure allows straightforward implementation by analogy to
`src/rules/minimumsetcovering_ilp.rs`.

---

### 12. FeedbackVertexSet → ILP (Ordering-based)

**Reference:** `docs/plans/proposals/reduction_feedbackvertexset_ilp.md`

**Problem:** Given directed graph G = (V, A) with vertex weights w,
find minimum weight F ⊆ V such that G[V \ F] is acyclic.

**ILP formulation (ordering-based, polynomial constraint count):**

Variables:
- `xᵥ ∈ {0, 1}`: 1 iff vertex v is removed
- `yᵥ ∈ {0, 1, …, n−1}`: topological position of vertex v in the remaining DAG

Constraints:
```
For each arc (u, v) ∈ A:
    yᵤ − yᵥ + 1 ≤ n·(xᵤ + xᵥ)
```
Interpretation: if both u and v are kept (xᵤ = xᵥ = 0), then yᵤ < yᵥ (u appears before v
in topological order). If either is removed, the constraint is vacuous (RHS ≥ n > n−1).

Objective: `minimize Σᵥ wᵥ·xᵥ`

**Overhead:**
- Variables: n binary (xᵥ) + n integer (yᵥ ∈ {0, …, n−1})
- Constraints: |A| (one per arc)
- Nonzeros: 3·|A| (two variables per constraint)

**Integer variable support:** The `VarBounds::bounded(0, n-1)` form is available in the
ILP struct. However, the BruteForce solver treats each `yᵥ` as a domain of size n,
making brute-force exponential in n². For solving, an external ILP solver is required.

For binary-only ILP, encode `yᵥ` in ⌈log₂ n⌉ bits per vertex, replacing integer variables
with O(n log n) binary variables and O(|A| log n) constraints. This is practical for
small n but inflates the formulation.

**Alternative cycle-based formulation (exponential constraints, lazy generation):**
```
For each directed cycle C in G:
    Σᵥ∈C xᵥ ≥ 1
```
Exponentially many constraints but can be added lazily. Not suitable for static ILP encoding.

**Solution extraction:**
Read xᵥ values; set of removed vertices = {v : xᵥ = 1}.

---

### 13. FeedbackArcSet → ILP (Ordering-based)

**Reference:** `docs/plans/proposals/reduction_feedbackarcset_ilp.md`

**Problem:** Given directed graph G = (V, A) with arc weights w,
find minimum weight F ⊆ A such that G[A \ F] is acyclic.

**ILP formulation:**

Variables:
- `xₑ ∈ {0, 1}`: 1 iff arc e = (u, v) is removed
- `yᵥ ∈ {0, 1, …, n−1}`: topological position

Constraints:
```
For each arc e = (u, v) ∈ A:
    yᵤ − yᵥ + 1 ≤ n · xₑ
```
Interpretation: if arc e is kept (xₑ = 0), then yᵤ < yᵥ (topological order respected).
If arc is removed (xₑ = 1), the constraint is vacuous (RHS = n).

Objective: `minimize Σₑ wₑ·xₑ`

**Overhead:**
- Variables: |A| binary (xₑ) + |V| integer (yᵥ)
- Constraints: |A| (one per arc)
- Nonzeros: 3·|A|

**Comparison with FVS → ILP:**
FAS is slightly simpler — each constraint involves only one binary variable xₑ
(arc decision), versus FVS where each constraint involves xᵤ + xᵥ (both endpoints).
The ordering constraint structure is identical.

**Solution extraction:**
Set of removed arcs = {e : xₑ = 1}.

---

### 14. SteinerTree → ILP (Flow-based)

**Reference:** `docs/plans/proposals/reduction_steinertree_ilp.md`

**Problem:** Given graph G = (V, E) with edge weights w and terminal set R ⊆ V,
find minimum weight connected subgraph (tree) spanning all terminals.

**ILP formulation (flow-based connectivity):**

Variables:
- `xᵥ ∈ {0, 1}`: 1 iff non-terminal vertex v is included as Steiner vertex
  (terminal vertices are always included: xᵥ = 1 for v ∈ R)
- `yₑ ∈ {0, 1}`: 1 iff edge e is included in the tree
- `fₑᵗ ∈ [0, 1]`: flow for terminal t on edge e (one set per non-root terminal)

Objective: `minimize Σₑ wₑ·yₑ`

Constraints:

1. **Endpoint inclusion:** For each edge e = (u, v):
   ```
   yₑ ≤ xᵤ or yₑ ≤ 1    (if u is terminal, xᵤ = 1 is fixed)
   yₑ ≤ xᵥ or yₑ ≤ 1
   ```

2. **Tree structure:** (optional; often handled by flow alone)
   ```
   Σₑ yₑ = Σᵥ xᵥ + |R| − 1
   ```

3. **Flow conservation** (pick root r ∈ R; for each t ∈ R \ {r}):
   ```
   For each vertex v ≠ r, t:
       Σ fₑᵗ (incoming) − Σ fₑᵗ (outgoing) = 0    (flow conservation)
   For root r:
       Σ fₑʳ (outgoing) − Σ fₑʳ (incoming) = |R| − 1
   For terminal t:
       Σ fₑᵗ (incoming) − Σ fₑᵗ (outgoing) = 1
   ```

4. **Flow bounded by edge selection:**
   ```
   fₑᵗ ≤ yₑ    for all e, t
   ```

**Overhead:**
- Variables: O(|V| + |E| + |R|·|E|) = O(|R|·|E|) for flow variables
- Constraints: O(|R|·|V|) for flow conservation
- Nonzeros: O(|R|·|E|) for flow bounds

This is the most complex ILP in the proposed batch. The O(|R|·|E|) scaling
means it is polynomial but can be large for dense graphs with many terminals.

**Alternative: Cut-based formulation**
For each S ⊆ V with r ∈ S, t ∉ S for some terminal t, require at least one edge
crossing the cut. This has exponentially many constraints but can be added lazily
(using a separation oracle based on min-cut).

**Solution extraction:**
Read yₑ values → selected edges. The set of selected Steiner vertices is
{v ∉ R : xᵥ = 1}. The tree is the subgraph induced by selected edges.

---

### 15. Treewidth → ILP (Elimination Ordering)

**Reference:** `docs/plans/proposals/reduction_treewidth_ilp.md`

**Problem:** Given graph G = (V, E) and k, decide if tw(G) ≤ k.

**ILP formulation:**

Variables:
- `πᵢⱼ ∈ {0, 1}` for all i ≠ j: πᵢⱼ = 1 iff vertex i is eliminated before j
- `fᵢⱼ ∈ {0, 1}` for all i ≠ j: fᵢⱼ = 1 iff j is in the "higher neighborhood" of i
  (i.e., j is adjacent to i in the elimination graph when i is eliminated)

Constraints:

1. **Ordering is total:** `πᵢⱼ + πⱼᵢ = 1`  for all i ≠ j
   → n(n−1)/2 constraints

2. **Transitivity:** `πᵢⱼ + πⱼₖ − 1 ≤ πᵢₖ`  for all distinct i, j, k
   → O(n³) constraints (can be reduced by transitivity closure)

3. **Original edges create fill:**
   For each (i, j) ∈ E: `fᵢⱼ ≥ πᵢⱼ` and `fⱼᵢ ≥ πⱼᵢ`
   → 2|E| constraints

4. **Fill propagation:**
   For all distinct i, j, k:
   ```
   fᵢⱼ + fᵢₖ + πⱼₖ − 2 ≤ fⱼₖ
   fᵢⱼ + fᵢₖ + πₖⱼ − 2 ≤ fₖⱼ
   ```
   If j, k are both higher neighbors of i, and j is before k, then k is a higher neighbor of j.
   → O(n³) constraints

5. **Width bound:** `Σⱼ fᵢⱼ ≤ k`  for all i ∈ V
   → n constraints

**Overhead:**
- Variables: 2n(n−1) = O(n²) binary variables (π + f)
- Constraints: O(n³) total
- Nonzeros: O(n³)

**Solution extraction:**
1. Read πᵢⱼ → construct elimination ordering σ
2. Simulate elimination: for each vertex in σ order, add fill edges connecting all higher neighbors
3. Each eliminated vertex i forms a bag {i} ∪ {j : fᵢⱼ = 1}
4. Tree edges connect bag of i to bag of the earliest-eliminated higher neighbor of i

**Tightness:** Exact. The ILP feasibility ↔ tw(G) ≤ k.

**Practical note:** The O(n³) constraint count makes this ILP extremely large for
graphs with more than ~15 vertices. This is inherent to the elimination ordering
formulation. The formulation is primarily of theoretical interest; practical treewidth
algorithms (Bodlaender 1996) are FPT and significantly faster.

---

## Part III: Cross-Reference Summary

### QUBO Reductions Summary

| Problem → QUBO | Variables | Matrix | Auxiliaries | Penalty B condition | Reference |
|----------------|-----------|--------|-------------|---------------------|-----------|
| SubsetSum → QUBO | n | n×n dense | 0 | A=1 (exact) | Lucas §5 |
| Partition → QUBO | n | n×n dense | 0 | A=1 (exact) | Lucas §5.1 |
| Knapsack → QUBO | n + ⌈log₂(C+1)⌉ | (n+s)×(n+s) | ⌈log₂(C+1)⌉ slack | B > A·max(vᵢ) | Lucas §5.2 |
| MaxSAT(k=2) → QUBO | n | n×n | 0 | — (exact) | per-clause |
| MaxSAT(k=3) → QUBO | n + m | (n+m)×(n+m) | m (1 per clause) | M = 2 per clause | Rosenberg |
| MaxSAT(k>3) → QUBO | n + Σ(kⱼ−2) | larger | k−2 per clause | M = 2 per clause | Rosenberg chain |
| MinimumBisection → QUBO | |V| | |V|×|V| dense | 0 | B > A·|E|+1 | Lucas §3 |
| MaximumClique → QUBO | |V| | |V|×|V| | 0 | B > A·Σwᵥ | Lucas §3.2 |
| MinDominatingSet → QUBO | |V| + O(|V|) | O((|V|+d)²) | O(|V|) | B > A·Σwᵥ | Lucas §4.3 |

### ILP Reductions Summary

| Problem → ILP | Variables | Constraints | Nonzeros | Variable types | Difficulty |
|---------------|-----------|-------------|----------|----------------|------------|
| SubsetSum → ILP | n | 1 | n | binary | Trivial |
| Partition → ILP | n | 1 | n | binary | Trivial |
| ExactCover → ILP | m sets | n elements | Σ|Sⱼ| | binary | Easy |
| HittingSet → ILP | n elements | m sets | Σ|Sⱼ| | binary | Easy |
| Knapsack → ILP | n | 1 | n | binary | Easy |
| FeedbackArcSet → ILP | |A| + |V| | |A| | 3|A| | binary + integer | Moderate |
| FeedbackVertexSet → ILP | |V| + |V| | |A| | 3|A| | binary + integer | Moderate |
| SteinerTree → ILP | O(|R|·|E|) | O(|R|·|V|) | O(|R|·|E|) | binary + cont. | Hard |
| Treewidth → ILP | O(n²) | O(n³) | O(n³) | binary | Very Hard |

---

## Part IV: Implementation Notes for This Codebase

### Existing Infrastructure

The following QUBO and ILP reductions are **already implemented**:
- `MaximumIndependentSet → QUBO`: `src/rules/maximumindependentset_qubo.rs`
- `MinimumVertexCover → QUBO`: `src/rules/minimumvertexcover_qubo.rs`
- `KSatisfiability<K2> → QUBO`: `src/rules/ksatisfiability_qubo.rs`
- `KSatisfiability<K3> → QUBO`: `src/rules/ksatisfiability_qubo.rs` (Rosenberg quadratization)
- `MaximumSetPacking → QUBO`: `src/rules/maximumsetpacking_qubo.rs`
- `ILP → QUBO`: `src/rules/ilp_qubo.rs`
- `MaximumIndependentSet → ILP`: `src/rules/maximumindependentset_ilp.rs`
- `MaximumClique → ILP`: `src/rules/maximumclique_ilp.rs`
- `MinimumVertexCover → ILP`: `src/rules/minimumvertexcover_ilp.rs`
- `MinimumDominatingSet → ILP`: `src/rules/minimumdominatingset_ilp.rs`
- `MinimumSetCovering → ILP`: `src/rules/minimumsetcovering_ilp.rs`
- `MaximumSetPacking → ILP`: `src/rules/maximumsetpacking_ilp.rs`
- `MaximumMatching → ILP`: `src/rules/maximummatching_ilp.rs`
- `TravelingSalesman → ILP`: `src/rules/travelingsalesman_ilp.rs`
- `KColoring → ILP`: `src/rules/coloring_ilp.rs`

### Pending New Problem Models Needed

Before the proposed reductions can be implemented, these models must be created:

| Model | Category | Blocks |
|-------|----------|--------|
| `SubsetSum` | `models/number/` | SubsetSum→ILP, SubsetSum→QUBO |
| `Partition` | `models/number/` | Partition→ILP, Partition→QUBO |
| `Knapsack` | `models/number/` | Knapsack→ILP, Knapsack→QUBO |
| `MaxSAT` | `models/satisfiability/` | MaxSAT→QUBO |
| `MinimumBisection` | `models/graph/` | MinimumBisection→QUBO, MinimumBisection→ILP |
| `ExactCover` | `models/set/` | ExactCover→ILP |
| `HittingSet` | `models/set/` | HittingSet→ILP |
| `MinimumFeedbackVertexSet` | `models/graph/` | FVS→ILP |
| `MinimumFeedbackArcSet` | `models/graph/` | FAS→ILP |
| `SteinerTree` | `models/graph/` | SteinerTree→ILP |
| `Treewidth` | `models/graph/` | Treewidth→ILP |

### Key Design Decisions

**1. SubsetSum → QUBO sign convention**

The Q diagonal entry `Qᵢᵢ = A·aᵢ·(aᵢ − 2t)` can be negative when `aᵢ < 2t`,
correctly incentivizing selection of small elements toward the target. The formula
is identical to what is written in Lucas (2014) §5 and the proposal document.
No sign correction is needed; the penalty is already a squared sum.

**2. Partition → QUBO vs SubsetSum → QUBO**

Partition → QUBO has a factor-4 scale compared to SubsetSum → QUBO with target = S/2.
Both are correct. The factor-4 comes from the Ising spin substitution (1 − 2xᵢ).
Either can be used; a common normalization is to divide by 4 to match the SubsetSum
coefficients (optional).

**3. Knapsack slack variable count**

The exact count is `⌈log₂(C + 1)⌉` bits to represent values 0 through C.
The ILP→QUBO reduction in `src/rules/ilp_qubo.rs` already implements this correctly:
```rust
slack_sizes[k] = (slack_range + 1.0).log2().ceil() as usize;
```
The same logic applies to direct Knapsack→QUBO. Note: if Σwᵢ < C, the effective
slack range is smaller (= Σwᵢ), potentially reducing the number of slack variables.

**4. MaxSAT vs KSatisfiability**

MaxSAT is the weighted, optimization version of KSatisfiability. The unweighted KSat → QUBO
already uses Rosenberg quadratization for k=3. MaxSAT → QUBO would be an extension where:
- Each clause's QUBO contribution is scaled by its weight wⱼ
- The Rosenberg penalty M must also scale: `M · wⱼ` (or use a global M > max(wⱼ))

**5. FVS/FAS require integer (non-binary) variables**

The ordering variables `yᵥ ∈ {0, …, n−1}` have domain size n. The `VarBounds::bounded(0, n-1)`
form is supported by the ILP struct. However, the BruteForce solver's `dims()` function
will return n for each yᵥ, making brute-force O(n^n) — infeasible for n > 6.
These reductions are meant for use with an external ILP solver, not BruteForce.
Testing requires small instances (n ≤ 4) to keep brute-force tractable.

**6. SteinerTree flow variables**

The flow variables `fₑᵗ` are continuous (0 to 1) in the relaxed formulation, but for integer
instances of the Steiner tree (undirected, integer weights), an optimal integral solution always
exists. Using `VarBounds { lower: Some(0), upper: Some(1) }` is appropriate.

**7. Treewidth ILP — O(n³) constraints**

The transitivity and fill-propagation constraints are both O(n³). For a graph with n=10,
this yields ~2000 constraints and ~200 binary variables — borderline for BruteForce.
For n=15, the ILP becomes too large for BruteForce; an external solver is needed.
Tests should use n ≤ 5 (e.g., P₄ path, C₄ cycle, K₄ complete graph).

---

## References

1. **Lucas, A.** (2014). "Ising formulations of many NP problems." *Frontiers in Physics*, 2:5.
   arXiv:1302.5843. DOI: [10.3389/fphy.2014.00005](https://doi.org/10.3389/fphy.2014.00005)

2. **Glover, F., Kochenberger, G. & Du, Y.** (2019). "A tutorial on formulating and using QUBO models."
   arXiv:1811.11538.

3. **Rosenberg, I.G.** (1975). "Reduction of bivalent maximization to the quadratic case."
   *Cahiers du Centre d'Études de Recherche Opérationnelle*, 17:71–74.

4. **Karp, R.M.** (1972). "Reducibility Among Combinatorial Problems."
   In *Complexity of Computer Computations*, pp. 85–103.

5. **Garey, M.R. & Johnson, D.S.** (1979). *Computers and Intractability: A Guide to the Theory
   of NP-Completeness*. W. H. Freeman.

6. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings
   in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284.
