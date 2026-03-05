# Model Proposal: BDDVariableOrdering

## Problem Definition

**BDD Optimal Variable Ordering (OBDD Minimization)**

Given a Boolean function f (represented as a truth table over n variables) and an integer k, determine whether there exists a variable ordering π such that the Reduced Ordered Binary Decision Diagram (ROBDD) for f under π has at most k nodes.

- **Category:** structural (decision diagram)
- **Reference:** Bollig & Wegener (1996). "Improving the variable ordering of OBDDs is NP-complete." IEEE Trans. Computers.
- **Complexity:** NP-complete (decision version); inapproximable within constant factor unless P=NP
- **Problem type:** Satisfaction (Metric = bool) — does an ordering with ≤ k nodes exist?

## Why Include

1. **Meta-problem about problem-solving tools:** BDDs are used to solve other NP-hard problems (SAT, MIS, SetCovering). Optimizing the BDD itself is NP-hard — a fascinating self-referential connection.
2. **Practical relevance:** VLSI/EDA tools spend significant time on BDD variable ordering heuristics.
3. **Connects to existing codebase:** The codebase solves problems using decision-diagram-like structures. This problem reasons about the tool itself.
4. **Relates to graph problems:** Optimal variable ordering is closely related to Minimum Linear Arrangement, Minimum Bandwidth, and Minimum Cut Width — all NP-hard graph layout problems.

## Variables

- **Encoding:** Permutation of n variables
- **Count:** n variables, each assigned a position in {0, 1, ..., n-1}
- **Per-variable domain:** {0, 1, ..., n-1} (position in ordering), with all-different constraint
- **Alternative binary encoding:** n² binary variables xᵢⱼ ∈ {0,1} where xᵢⱼ = 1 means variable i is at position j (permutation matrix, like QAP)

## Schema

| Field | Description |
|-------|-------------|
| `truth_table` | Boolean function f as truth table (2ⁿ entries) |
| `num_variables` | Number of Boolean variables n |
| `target_size` | Maximum allowed ROBDD nodes k |

## Example Instance

```
Function: f(x₁, x₂, x₃) = (x₁ ∧ x₂) ∨ (x₂ ∧ x₃)
Truth table: [0, 0, 0, 1, 0, 0, 1, 1]  (indices: x₁x₂x₃ = 000..111)
n = 3, k = 4

Ordering π = (x₂, x₁, x₃): ROBDD has 4 nodes → YES
Ordering π = (x₁, x₃, x₂): ROBDD has 5 nodes → exceeds k

Function: f(x₁, x₂) = x₁ ⊕ x₂ (XOR)
Truth table: [0, 1, 1, 0]
n = 2, k = 3
Any ordering gives 3 nodes → YES (XOR is ordering-insensitive for 2 vars)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| BDDVariableOrdering → ILP | New | Permutation matrix encoding: min Σ wₗ s.t. ordering constraints + BDD construction constraints |
| MinimumLinearArrangement → BDDVariableOrdering | Known (indirect) | Both involve optimal vertex ordering; related through cutwidth |
| BDDVariableOrdering relates to MinimumBandwidth | Structural | Variable ordering affects "bandwidth" of the BDD transition graph |

## Connection to Existing Codebase

- **GenericTensorNetworks.jl** uses BDDs/ZDDs; variable ordering is a key performance factor
- The problem is a permutation optimization like **QuadraticAssignment** (QAP) — same n² binary encoding
- Could connect to **KColoring** (graph coloring of the variable interaction graph gives ordering heuristics)

## Difficulty: Tier 3-4

- Truth table representation limits practical instance sizes (2ⁿ entries)
- ROBDD construction algorithm (Bryant's reduce+apply) needed in `evaluate()`
- Permutation encoding is well-understood (reuse QAP patterns)
- The "meta" nature makes it unusual but intellectually compelling

## References

1. **Bollig, B. & Wegener, I.** (1996). "Improving the variable ordering of OBDDs is NP-complete." *IEEE Transactions on Computers*, 45(9):993–1002. DOI: [10.1109/12.537122](https://doi.org/10.1109/12.537122)
   — Proves the NP-completeness of finding an optimal variable ordering for OBDDs.

2. **Bryant, R.E.** (1986). "Graph-based algorithms for Boolean function manipulation." *IEEE Transactions on Computers*, 35(8):677–691. DOI: [10.1109/TC.1986.1676819](https://doi.org/10.1109/TC.1986.1676819)
   — Foundational paper introducing Reduced Ordered Binary Decision Diagrams (ROBDDs).

3. **Friedman, S.J. & Supowit, K.J.** (1990). "Finding the optimal variable ordering for binary decision diagrams." *IEEE Transactions on Computers*, 39(5):710–713. DOI: [10.1109/12.53586](https://doi.org/10.1109/12.53586)
   — First exact algorithm for computing optimum variable orderings; O(n² · 3ⁿ) complexity.

4. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)
   — Comprehensive treatment of DD-based optimization including width and variable ordering.

5. **Minato, S.** (1993). "Zero-Suppressed BDDs for Set Manipulation in Combinatorial Problems." *Proc. 30th Design Automation Conference (DAC '93)*, pp. 272–277. DOI: [10.1145/157485.164890](https://doi.org/10.1145/157485.164890)
   — Introduces ZDDs; variable ordering is equally critical for ZDD size.
