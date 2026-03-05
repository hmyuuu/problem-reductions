# Reduction Proposal: Treewidth → ILP

## Overview

| Property | Value |
|----------|-------|
| Source | Treewidth |
| Target | ILP (Integer Linear Programming) |
| Type | One-way |
| Difficulty | Moderate |

## Reduction Description

Encode the decision problem "tw(G) ≤ k?" as an ILP using the elimination ordering formulation. The key insight: treewidth equals the minimum, over all elimination orderings, of the maximum clique size in the elimination graph minus 1.

### Elimination Ordering Formulation

**Variables:**
- `πᵢⱼ ∈ {0,1}` for all i,j ∈ V, i ≠ j: πᵢⱼ = 1 iff vertex i is eliminated before vertex j
- `fᵢⱼ ∈ {0,1}` for all i,j ∈ V, i ≠ j: fᵢⱼ = 1 iff j is a "fill neighbor" of i when i is eliminated (i.e., j is in the higher neighborhood of i)
- `w ∈ ℤ`: objective variable (width)

**Constraints:**

1. **Ordering is total:** πᵢⱼ + πⱼᵢ = 1 for all i ≠ j

2. **Transitivity:** πᵢⱼ + πⱼₖ - 1 ≤ πᵢₖ for all distinct i,j,k
   (if i before j and j before k, then i before k)

3. **Original edges create fill:** For each edge (i,j) ∈ E:
   - fᵢⱼ ≥ πᵢⱼ (if i eliminated first, j is in its higher neighborhood)
   - fⱼᵢ ≥ πⱼᵢ (if j eliminated first, i is in its higher neighborhood)

4. **Fill propagation:** For all distinct i,j,k:
   - fᵢⱼ + fᵢₖ + πⱼₖ - 2 ≤ fⱼₖ
   - fᵢⱼ + fᵢₖ + πₖⱼ - 2 ≤ fₖⱼ
   (if j,k are both higher neighbors of i and j is before k, then k is a higher neighbor of j)

5. **Width constraint:** Σⱼ fᵢⱼ ≤ k for all i ∈ V
   (at most k higher neighbors when eliminated — this is the treewidth bound)

**Objective:** Satisfy all constraints (feasibility ILP), or minimize max_i Σⱼ fᵢⱼ for optimization version.

### Variable Count

- Ordering variables: n(n-1) binary variables (πᵢⱼ)
- Fill variables: n(n-1) binary variables (fᵢⱼ)
- **Total:** 2n(n-1) = O(n²) binary variables

### Constraint Count

- Ordering total: n(n-1)/2
- Transitivity: n(n-1)(n-2) (can reduce)
- Original edges: 2|E|
- Fill propagation: O(n³)
- Width bound: n
- **Total:** O(n³) constraints

## Example

```
Graph: C₄ = V={0,1,2,3}, E={(0,1),(1,2),(2,3),(3,0)}
Target: k = 2

Elimination ordering: 0, 1, 2, 3
- Eliminate 0: neighbors {1,3} both higher → fill edge (1,3), degree = 2 ✓
- Eliminate 1: neighbors {2,3} both higher → fill edge (2,3) (already exists), degree = 2 ✓
- Eliminate 2: neighbor {3} higher → degree = 1 ✓
- Eliminate 3: no higher neighbors → degree = 0 ✓
Max degree = 2 = k → YES, tw(C₄) ≤ 2

ILP encoding:
π₀₁ = π₀₂ = π₀₃ = π₁₂ = π₁₃ = π₂₃ = 1 (order 0<1<2<3)
f₀₁ = f₀₃ = 1 (neighbors of 0 that are higher)
f₁₂ = f₁₃ = 1 (neighbors of 1 that are higher, including fill)
f₂₃ = 1
Width = max(2, 2, 1, 0) = 2 ≤ k ✓
```

## Solution Extraction

Given a feasible ILP solution:
1. Read πᵢⱼ values → construct elimination ordering σ
2. Build elimination graph: start with G, process vertices in σ order, connecting all higher neighbors of each eliminated vertex
3. Tree decomposition: each eliminated vertex i forms a bag {i} ∪ {j : fᵢⱼ = 1}
4. Tree edges: bag of i connects to bag of the earliest-eliminated higher neighbor of i

**Verification:** Check that resulting tree decomposition has width ≤ k and satisfies all three tree decomposition properties.

## Complexity Analysis

| Metric | Value |
|--------|-------|
| Variables | O(n²) |
| Constraints | O(n³) |
| Overhead | Polynomial (cubic) |
| Tightness | Exact — ILP feasibility ↔ tw(G) ≤ k |

## References

1. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   — NP-completeness proof for treewidth decision problem.

2. **Bodlaender, H.L.** (1998). "A partial k-arboretum of graphs with bounded treewidth." *Theoretical Computer Science*, 209(1–2):1–45. DOI: [10.1016/S0304-3975(97)00228-4](https://doi.org/10.1016/S0304-3975(97)00228-4)
   — Comprehensive survey including elimination ordering characterization of treewidth.

3. **Gavril, F.** (1974). "The intersection graphs of subtrees in trees are exactly the chordal graphs." *Journal of Combinatorial Theory, Series B*, 16(1):47–56. DOI: [10.1016/0095-8956(74)90094-X](https://doi.org/10.1016/0095-8956(74)90094-X)
   — Establishes that chordal graphs = intersection graphs of subtrees; chordal completion ↔ treewidth.

4. **Rose, D.J.** (1970). "Triangulated graphs and the elimination process." *Journal of Mathematical Analysis and Applications*, 32(3):597–609. DOI: [10.1016/0022-247X(70)90282-9](https://doi.org/10.1016/0022-247X(70)90282-9)
   — Foundational work connecting vertex elimination orderings to triangulated (chordal) graphs.

5. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)
   — ILP formulations for treewidth-related optimization in DD context.
