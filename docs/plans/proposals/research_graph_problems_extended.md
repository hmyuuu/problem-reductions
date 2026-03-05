# Research: Extended Graph Problems for NP-Hard Reductions

> Generated: 2026-02-27
> Scope: Minimum Bisection, Edge Coloring, Max k-Cut, Longest Path, Minimal Maximal Matching, Multiway Cut, Graph Partitioning, Quadratic Assignment Problem
> Context: complexity theory details for `problem-reductions` codebase additions

---

## Table of Contents

1. [Minimum Bisection](#1-minimum-bisection)
2. [Edge Coloring](#2-edge-coloring)
3. [Max k-Cut](#3-max-k-cut)
4. [Longest Path](#4-longest-path)
5. [Minimal Maximal Matching (Min-Edge Dominating Set)](#5-minimal-maximal-matching-min-edge-dominating-set)
6. [Multiway Cut](#6-multiway-cut)
7. [Graph Partitioning (k-way balanced)](#7-graph-partitioning-k-way-balanced)
8. [Quadratic Assignment Problem (QAP)](#8-quadratic-assignment-problem-qap)
9. [Cross-Problem Reduction Network](#9-cross-problem-reduction-network)
10. [References](#10-references)

---

## 1. Minimum Bisection

### 1.1 Formal Definition

**Garey & Johnson reference:** [ND16]

**Input:** An undirected graph G = (V, E) with |V| = n (n even), and edge weights w: E -> R+.

**Objective (optimization):** Find a partition of V into two disjoint sets A and B with |A| = |B| = n/2 that minimizes the total weight of edges crossing the partition:

```
minimize    sum_{(u,v) in E: u in A, v in B} w(u,v)
subject to  |A| = |B| = n/2
            A union B = V, A intersect B = empty
```

**Decision version:** Given an integer k, does there exist such a partition with at most k crossing edges?

The unweighted version sets w(u,v) = 1 for all edges.

### 1.2 Complexity Classification

**NP-completeness:** Garey, Johnson, and Stockmeyer (1976) proved Minimum Bisection is NP-complete. It appears as problem [ND16] in Garey & Johnson (1979).

**Stronger hardness:** Minimum Bisection is NP-hard even on unit disk graphs (Diaz, Petit, Serna, 2017), settling a longstanding open question. The problem is also NP-hard on grid graphs and bounded-degree graphs.

**MAX SNP-hardness:** Unlike Max-Cut, the minimization variant does not belong to MAX SNP. However, the closely related Minimum Balanced Cut problem is known to lack a PTAS unless P = NP.

**Approximation hardness:** Under the Unique Games Conjecture, Minimum Bisection cannot be approximated within any constant factor (Khot and Vishnoi, 2015).

### 1.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1976 | Garey, Johnson, Stockmeyer | NP-completeness proof |
| 1988 | Leighton, Rao | O(log n) approximation via multicommodity flow |
| 1999 | Feige, Krauthgamer | O(log^{3/2} n) approximation |
| 2004 | Arora, Rao, Vazirani | O(sqrt(log n)) approximation via SDP + expander flows |
| 2009 | Arora, Rao, Vazirani | Journal version of O(sqrt(log n)) result (JACM 56(2)) |
| 2014 | Cygan, Lokshtanov, Pilipczuk, Pilipczuk, Saurabh | First FPT algorithm: O(2^{O(k^3)} n^3 log^3 n) |
| 2014 | Lucas | QUBO/Ising formulation (Frontiers in Physics) |

### 1.4 Approximation Algorithms

**Best known:** O(sqrt(log n))-approximation by Arora, Rao, and Vazirani (2004/2009), based on semidefinite programming with triangle inequality constraints. The algorithm uses the concept of "expander flows" -- embedding an expander in the graph with bounded congestion. The SDP relaxation has O(sqrt(log n)) integrality gap.

**Prior results:**
- O(n)-approximation: trivial (any bisection)
- O(sqrt(n))-approximation: spectral methods via Fiedler vector
- O(log^2 n)-approximation: Leighton and Rao (1988) via multicommodity flow
- O(log^{3/2} n)-approximation: Feige and Krauthgamer (1999)

**Dense instances:** PTAS exists for dense graphs (min degree Omega(n)) via the Arora-Karger-Karpinski framework.

**Spectral methods:**
- **Fiedler vector:** The eigenvector corresponding to the second-smallest eigenvalue (algebraic connectivity) of the Laplacian matrix provides a spectral bisection. Sort vertices by Fiedler vector coordinates; split at the median. Quality: within O(sqrt(Delta * OPT)) of optimal (Cheeger inequality).
- **Cheeger inequality:** For graph Laplacian with eigenvalue lambda_2: phi(G) / 2 <= sqrt(2 * lambda_2), where phi(G) is the edge expansion (closely related to bisection width).

### 1.5 Parameterized Complexity

**FPT by cut size k:** Cygan, Lokshtanov, Pilipczuk, Pilipczuk, and Saurabh (STOC 2014, SICOMP 2019) gave the first FPT algorithm with running time O(2^{O(k^3)} * n^3 * log^3(n)). This was a major breakthrough, resolving a long-standing open question.

The algorithm uses a novel decomposition theorem: every graph can be decomposed by small separators into parts where each part is "highly connected" in the sense that any cut of bounded size can separate only a limited number of vertices from each part.

**FPT by treewidth tw:** Solvable in O(2^{O(tw)} * n) time via dynamic programming on tree decompositions using the Cut&Count technique (Cygan et al., FOCS 2011).

**Kernelization:** A polynomial kernel parameterized by k is not known to exist.

### 1.6 Exact Algorithms and Practical Solvers

**Branch-and-bound:** Typically combined with SDP or LP relaxations for lower bounds. METIS, KaHiP, and Scotch are practical graph partitioning solvers that handle bisection.

**SDP-based branch-and-cut:** Armbruster, Fuhry, Helmberg, and Krislock (2012) describe a combined linear/semidefinite branch-and-cut framework that solves sparse instances up to several thousand vertices.

**Exact exponential:** O*(2^n) brute force over all balanced partitions. Can be improved to O*(2^{n/2}) via meet-in-the-middle.

### 1.7 Known Reductions

```
Minimum Bisection
  <-- Graph Partitioning (k=2 special case)
  --> QUBO (Lucas 2014, Section 2)
  --> ILP (standard formulation)
  <-> Max-Cut (complementary: min crossing vs max crossing)
  <-- 3-SAT (NP-completeness proof)
```

**From Max-Cut:** For an unweighted graph G = (V, E), let cut(S) = edges crossing partition (S, V\S). Then:
- Max-Cut maximizes cut(S) over all S (no balance constraint)
- Minimum Bisection minimizes cut(S) subject to |S| = n/2

These are complementary objectives on the same structure. An edge (u,v) contributes to the cut iff x_u != x_v. The balance constraint is what makes Minimum Bisection fundamentally harder to approximate.

**From Graph Partitioning:** Minimum Bisection is the special case of k-way balanced graph partitioning with k = 2.

### 1.8 QUBO/Ising and ILP Formulations

**QUBO/Ising formulation (Lucas 2014, Section 2):**

Variables: x_i in {0, 1} for each vertex i, indicating partition assignment.

Hamiltonian:
```
H = A * (sum_i x_i - n/2)^2 + B * sum_{(i,j) in E} x_i(1-x_j) + (1-x_i)x_j
```

The first term (coefficient A) enforces the balance constraint |A| = |B| = n/2.
The second term (coefficient B) counts crossing edges.

For correctness: A > B * |E| ensures balance is never violated.

In Ising form (s_i in {-1, +1}, x_i = (1 - s_i)/2):
```
H = A * (sum_i s_i)^2 - B * sum_{(i,j) in E} s_i * s_j + constant
```

Number of spins: n. Number of quadratic terms: n + |E|.

**ILP formulation:**

```
minimize    sum_{(i,j) in E} y_{ij}
subject to  y_{ij} >= x_i - x_j          for all (i,j) in E
            y_{ij} >= x_j - x_i          for all (i,j) in E
            sum_i x_i = n/2
            x_i in {0, 1}                for all i in V
            y_{ij} in {0, 1}             for all (i,j) in E
```

Variables: x_i = 1 iff vertex i in partition A; y_{ij} = 1 iff edge (i,j) is cut.
Constraints: 2|E| + 1 inequality/equality constraints, n + |E| binary variables.

### 1.9 Connections to Other Proposed Problems

- **Max-Cut (implemented):** Complementary objective (maximize vs minimize crossing edges), but Max-Cut has no balance constraint. Adding balance to Max-Cut yields Max Bisection. Conversely, relaxing balance from Min Bisection yields Min-Cut (polynomial).
- **Graph Partitioning (Section 7):** Minimum Bisection is k=2 case.
- **QUBO (implemented):** Natural Ising encoding via Lucas formulation.
- **Spin Glass (implemented):** The Ising form of bisection is a spin glass with an additional linear constraint on magnetization.

### 1.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct MinimumBisection<G, W = One> {
    graph: G,
    edge_weights: Vec<W>,
}
```

**Trait implementation:**
- `Problem::NAME = "MinimumBisection"`
- `Problem::Metric = SolutionSize<W::Sum>` -- `Valid(crossing_weight)` when partition is balanced, `Invalid` otherwise
- `Problem::dims()` -> `vec![2; n]` (binary assignment per vertex)
- `OptimizationProblem::direction()` -> `Direction::Minimize`
- `evaluate()`: Check |{i : x_i = 0}| = |{i : x_i = 1}| = n/2. If not balanced, return `Invalid`. Otherwise sum edge weights where endpoints differ.

**Variant:** `[("graph", G::NAME), ("weight", W::NAME)]`

**Size fields for overhead expressions:** `num_vertices`, `num_edges`.

**Key consideration:** Only defined for even n. The `new()` constructor should assert n is even, or generalize to ||A| - |B|| <= 1 for odd n (as in the FPT paper).

---

## 2. Edge Coloring

### 2.1 Formal Definition

**Input:** An undirected graph G = (V, E) and a positive integer k.

**Decision version (k-Edge-Coloring):** Does there exist a proper edge coloring c: E -> {1, ..., k} such that for any two incident edges e1, e2 (sharing a vertex), c(e1) != c(e2)?

**Optimization version:** Find the smallest k for which a proper edge coloring exists. This k is the **chromatic index** chi'(G).

Formally:
```
chi'(G) = min { k : there exists c: E -> {1,...,k} such that
                 for all v in V, all e1, e2 in delta(v) with e1 != e2,
                 c(e1) != c(e2) }
```

where delta(v) = set of edges incident to v.

### 2.2 Complexity Classification

**NP-completeness (Holyer 1981):** Determining whether chi'(G) = Delta(G) (i.e., whether G is Class 1) is NP-complete. Specifically, Holyer proved that deciding whether a cubic graph (Delta = 3) has chromatic index 3 or 4 is NP-complete.

**Stronger results:**
- NP-complete even for triangle-free graphs with Delta = 3 (Leven and Galil, 1983)
- NP-complete for k-regular graphs for any fixed k >= 3
- NP-complete for planar graphs with Delta = 3 (shown to be equivalent to the four-color theorem for bridgeless cubic planar graphs)

**Polynomial cases:**
- Bipartite graphs: chi'(G) = Delta(G) always (Konig's theorem, 1916). Computable in O(|E| * Delta) time.
- Planar graphs with Delta >= 7: chi'(G) = Delta(G) (Vizing 1965, extended by Sanders and Zhao 2001 for Delta = 7)
- Graphs with at most one vertex of degree Delta: polynomial
- Series-parallel graphs: polynomial

### 2.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1916 | Konig | Bipartite graphs have chi' = Delta (Konig's theorem) |
| 1949 | Shannon | chi'(G) <= floor(3*Delta/2) for multigraphs |
| 1964 | Vizing | Delta <= chi'(G) <= Delta + 1 for simple graphs |
| 1965 | Gupta | Independent discovery of Vizing's theorem |
| 1965 | Vizing | Planar graphs with Delta >= 8 are Class 1 |
| 1981 | Holyer | Deciding Class 1 vs Class 2 is NP-complete |
| 2001 | Sanders, Zhao | Planar graphs with Delta >= 7 are Class 1 |

### 2.4 Approximation Algorithms

Edge coloring has a unique approximation profile:

**Trivial (Delta+1)-approximation:** Vizing's original proof is algorithmic and runs in polynomial time. It colors any simple graph with Delta + 1 colors. Since chi'(G) >= Delta, this is a (1 + 1/Delta)-approximation -- asymptotically optimal.

**Exact for bipartite:** Konig's theorem gives an exact polynomial algorithm for bipartite graphs (chi' = Delta). The algorithm is based on augmenting path techniques in O(|E| * Delta) time.

**Shannon's bound for multigraphs:** chi'(G) <= floor(3*Delta/2). A polynomial algorithm achieving this bound exists (using Vizing fans).

**APX-hardness:** The edge coloring problem is not APX-hard in the usual sense because the gap between Delta and Delta+1 is only additive 1. However, distinguishing Class 1 from Class 2 is NP-complete.

### 2.5 Parameterized Complexity

**Parameterized by number of colors k:**
- For k = Delta: NP-complete (Holyer 1981)
- For k = Delta + 1: trivially polynomial (Vizing's algorithm)
- For k < Delta: trivially NO (lower bound)

**Parameterized by treewidth tw:**
- Edge coloring is FPT when parameterized by treewidth: solvable in O(Delta^{O(tw)} * n) time via dynamic programming on tree decompositions
- The base of the exponent depends on Delta, which may be large

**Parameterized by vertex cover number vc:**
- FPT: the number of edges is at most O(vc^2), so the problem becomes tractable

**Maximum Edge q-Coloring (variant):**
- FPT parameterized by treewidth: O(2^{O(tw * q * log(tw * q))} * n) (FSTTCS 2024)
- W[1]-hard when parameterized by gap above matching size

### 2.6 Exact Algorithms and Practical Solvers

**Exact exponential:** O*(2^{|E|}) brute force over all colorings. Can be improved using inclusion-exclusion to O*((2^Delta - 1)^{n/2}).

**Practical approaches:**
- **SAT encoding:** Each edge-color pair is a Boolean variable. Conflict clauses enforce proper coloring. Modern SAT solvers handle moderate instances efficiently.
- **Constraint programming:** MiniZinc / Google OR-Tools with edge coloring constraints
- **Heuristic:** Vizing's algorithm (polynomial, at most 1 color above optimal), followed by local search to remove the extra color if possible.

### 2.7 Known Reductions

```
Edge Coloring of G
  <-> Vertex Coloring of L(G) (line graph transformation)
  --> ILP (assignment formulation)
  <-- k-SAT (via NP-completeness)
```

**Line graph reduction:** The **critical** reduction for edge coloring. Given G, construct the line graph L(G):
- Vertices of L(G) = edges of G
- Two vertices in L(G) are adjacent iff the corresponding edges in G share an endpoint

Then: chi'(G) = chi(L(G)). A proper vertex k-coloring of L(G) is exactly a proper edge k-coloring of G. Since L(G) has |E| vertices and can be constructed in O(|E| * Delta) time, this is a polynomial reduction.

**Consequence:** Any algorithm or hardness result for vertex coloring transfers to edge coloring via line graphs. In particular, the KColoring implementation in the codebase can solve edge coloring instances after line graph transformation.

### 2.8 QUBO/Ising and ILP Formulations

**ILP formulation:**

```
minimize    k
subject to  sum_{c=1}^{k} x_{e,c} = 1              for all e in E    (each edge gets one color)
            x_{e1,c} + x_{e2,c} <= 1                for all v in V, e1,e2 in delta(v), c in {1,...,k}
                                                     (incident edges get different colors)
            x_{e,c} in {0, 1}                        for all e in E, c in {1,...,k}
```

Variables: |E| * k binary variables. Constraints: |E| + O(|E| * Delta * k) inequalities.

For the decision version (fixed k = Delta): drop the objective, just check feasibility.

**QUBO/Ising formulation:**

Via the line graph reduction, edge coloring reduces to vertex coloring of L(G), which has a known QUBO formulation (Lucas 2014, Section 6):

For k colors and |E| edges in G (= |V(L(G))| vertices in L(G)):
```
H = A * sum_{e in E} (1 - sum_{c=1}^{k} x_{e,c})^2
  + A * sum_{v in V} sum_{e1,e2 in delta(v), e1<e2} sum_{c=1}^{k} x_{e1,c} * x_{e2,c}
```

First term: each edge gets exactly one color (one-hot constraint).
Second term: incident edges get different colors.

Number of binary variables: |E| * k. For the chromatic index problem with k = Delta + 1: |E| * (Delta + 1) variables.

### 2.9 Connections to Other Proposed Problems

- **KColoring (implemented):** Edge coloring of G = vertex coloring of L(G). This is the primary reduction pathway.
- **Max k-Cut (Section 3):** Both involve partitioning graph elements into color classes; however, Max k-Cut maximizes cut edges while edge coloring minimizes colors needed.
- **Minimal Maximal Matching (Section 5):** Both operate on edges of a graph with structural constraints.
- **Maximum Matching (implemented):** Konig's theorem connects matchings and edge colorings in bipartite graphs: a perfect matching in a bipartite graph uses Delta colors, and each color class is a matching.

### 2.10 Implementation Notes for Rust Codebase

**Recommended approach:** Implement as a satisfaction problem for fixed k (k-Edge-Coloring), analogous to `KColoring`.

**Problem struct:**
```rust
pub struct KEdgeColoring<K: KValue, G> {
    graph: G,
    num_colors: usize,  // runtime k, compile-time via K type
}
```

**Trait implementation:**
- `Problem::NAME = "KEdgeColoring"`
- `Problem::Metric = bool` (satisfaction problem)
- `Problem::dims()` -> `vec![k; |E|]` (each edge gets one of k colors)
- `SatisfactionProblem` marker trait
- `evaluate()`: Check that for every vertex v, all edges incident to v have distinct colors.

**Alternative (optimization version):**
- `EdgeColoring<G>` with `Metric = SolutionSize<usize>` counting the number of distinct colors used, direction `Minimize`. Config space: `vec![Delta+1; |E|]`.

**Line graph helper:** Implement `fn line_graph(g: &G) -> SimpleGraph` utility that enables the reduction `KEdgeColoring -> KColoring`.

**Variant:** `[("graph", G::NAME)]`. No weight parameter (unweighted problem).

---

## 3. Max k-Cut

### 3.1 Formal Definition

**Input:** An undirected graph G = (V, E) with edge weights w: E -> R+, and a positive integer k >= 2.

**Objective:** Partition V into k disjoint non-empty sets S_1, S_2, ..., S_k that maximizes the total weight of edges whose endpoints belong to different parts:

```
maximize    sum_{(u,v) in E : u in S_i, v in S_j, i != j} w(u,v)
subject to  S_1 union ... union S_k = V
            S_i intersect S_j = empty for i != j
```

Equivalently, assign each vertex a label from {0, 1, ..., k-1}. An edge contributes to the cut if its endpoints have different labels.

**Special case:** k = 2 is the classic **Max-Cut** problem.

### 3.2 Complexity Classification

**NP-hardness:** Max k-Cut is NP-hard for all k >= 2 (Karp 1972 for k=2; Kann, Khanna, Lagergren, Panconesi 1997 for general k).

**APX-hardness:** The problem is APX-hard for all k >= 2. For k = 2, Hastad (2001) showed that approximating Max-Cut within 17/16 is NP-hard, assuming P != NP. Under the Unique Games Conjecture, the Goemans-Williamson ratio alpha_GW ~ 0.878 is optimal for k = 2.

**Papadimitriou and Yannakakis (1991):** Classified Max k-Cut as NP-complete.

### 3.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1972 | Karp | Max-Cut (k=2) is NP-complete |
| 1995 | Goemans, Williamson | 0.878-approximation for Max-Cut via SDP |
| 1997 | Frieze, Jerrum | SDP-based approximation for Max k-Cut with ratio > 1 - 1/k |
| 1997 | Kann et al. | NP-hardness for all k >= 2 |
| 2004 | De Klerk et al. | Improved ratios for small k (k=3: 0.836, k=4: 0.857) |

### 3.4 Approximation Algorithms

**Trivial random partition:** Assign each vertex to a random part. Expected cut value = (1 - 1/k) * W(E), giving a (1 - 1/k)-approximation in expectation. This can be derandomized.

**Frieze-Jerrum SDP-based (1997):**
- Ratio: strictly better than 1 - 1/k for all k >= 2
- For k = 2: recovers the Goemans-Williamson 0.878 ratio
- For k = 3: ratio ~0.8327
- For k = 4: ratio ~0.8503
- Method: Solve an SDP relaxation, then round using random hyperplanes in k-dimensional space
- Publication: Algorithmica 18, 67--81 (1997)

**De Klerk, Pasechnik, Warners (2004):**
- Improved ratios via the Lovasz theta function
- k = 3: 0.836008 (improved from 0.832718)
- k = 4: 0.857487 (improved from 0.850301)

**Limitation noted by Frieze-Jerrum:** The randomized rounding often produces partitions with fewer than k non-empty parts.

### 3.5 Parameterized Complexity

**Parameterized by cut size above trivial bound:**
- Max-Cut above (|E|/2) is FPT (Mahajan and Raman 1999)
- Max k-Cut above ((1-1/k)|E|) is FPT via random separation (Cai, Fellows, Juedes, Rosamond)

**Parameterized by treewidth tw:**
- FPT: solvable in O(k^{tw} * n) time via dynamic programming on tree decomposition
- The base k in the exponent is inherent since the problem involves k-colorings

**Parameterized by crossing number:**
- Max-Cut (k=2) is FPT parameterized by crossing number: O(2^k * (n+k)^{3/2} * log(n+k)) (Kobayashi et al.)

**W[1]-hardness:**
- Min-Max k-Cut (minimize the maximum part's cut) is W[1]-hard parameterized by k (Gupta, Lee, Li)

### 3.6 Exact Algorithms and Practical Solvers

**Brute force:** O(k^n) time to enumerate all k-partitions. Improved to O*((2^k - 2)^{n/k}) via inclusion-exclusion.

**SDP solvers:** SDPA, CSDP, MOSEK for the SDP relaxation, followed by rounding.

**Branch-and-bound:** Commercial solvers (CPLEX, Gurobi) on the ILP/QUBO formulation. Effective for n <= 100--200 depending on graph density.

**Biq Mac solver:** Specialized for binary quadratic programs; handles Max-Cut (k=2) instances up to ~500 vertices.

### 3.7 Known Reductions

```
Max k-Cut
  <-- Max-Cut (k=2 special case; implemented)
  --> KColoring (complement: k-Cut = k-coloring where we maximize, not satisfy)
  --> QUBO (via one-hot encoding)
  --> ILP (assignment formulation)
  <-> Graph Partitioning (max crossing vs min crossing)
```

**From Max-Cut:** Max 2-Cut = Max-Cut exactly. The generalization to k > 2 introduces k-way partitions.

**To KColoring:** A proper k-coloring of G gives a k-cut where every edge is cut (since adjacent vertices get different colors). Max k-Cut relaxes the proper-coloring requirement: some edges between same-color vertices are allowed, but we want to maximize cut edges. If G is k-colorable, the optimal k-cut equals W(E) (all edges cut).

**Connection to chromatic number:** chi(G) <= k iff the optimal Max k-Cut equals W(E). So Max k-Cut can decide k-colorability.

### 3.8 QUBO/Ising and ILP Formulations

**QUBO formulation (one-hot encoding):**

For each vertex i and color c in {0, ..., k-1}, introduce binary variable x_{i,c} = 1 iff vertex i is assigned color c.

```
H = A * sum_i (1 - sum_{c=0}^{k-1} x_{i,c})^2
  - B * sum_{(i,j) in E} w_{ij} * sum_{c=0}^{k-1} x_{i,c} * x_{j,c}
```

First term: one-hot constraint (each vertex gets exactly one color). Penalty A.
Second term: contribution to objective. An edge (i,j) is cut iff the vertices have different colors; equivalently, the edge is NOT cut iff sum_c x_{i,c} * x_{j,c} = 1. Since Max k-Cut maximizes, we negate.

Number of binary variables: n * k.
To ensure correctness: A > B * max(w) * Delta(G).

**Alternative (k-1 binary variables per vertex):** Use binary encoding with ceil(log2(k)) binary variables per vertex. This uses n * ceil(log2(k)) variables but requires auxiliary terms to handle the encoding.

**ILP formulation:**

```
maximize    sum_{(i,j) in E} w_{ij} * z_{ij}
subject to  sum_{c=0}^{k-1} x_{i,c} = 1              for all i in V
            x_{i,c} + x_{j,c} - 1 <= 1 - z_{ij}      for all (i,j) in E, c in {0,...,k-1}
            x_{i,c} in {0, 1}, z_{ij} in {0, 1}
```

Variables: n*k + |E| binary variables.
The constraint ensures z_{ij} = 0 whenever i and j share color c.

### 3.9 Connections to Other Proposed Problems

- **Max-Cut (implemented):** k = 2 special case. MaxKCut should generalize the existing MaxCut implementation.
- **KColoring (implemented):** If optimal Max k-Cut = W(E), then G is k-colorable. Max k-Cut is a "soft" version of k-Coloring.
- **Minimum Bisection (Section 1):** Both partition vertices, but Bisection minimizes crossing edges with balance constraint while Max k-Cut maximizes crossing edges with k parts.
- **Graph Partitioning (Section 7):** Complementary objective (min cut vs max cut with k parts).
- **QUBO (implemented):** One-hot encoding provides natural QUBO formulation.

### 3.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct MaxKCut<K: KValue, G, W = One> {
    graph: G,
    edge_weights: Vec<W>,
    num_parts: usize,
}
```

**Trait implementation:**
- `Problem::NAME = "MaxKCut"`
- `Problem::Metric = SolutionSize<W::Sum>`
- `Problem::dims()` -> `vec![k; n]` (each vertex assigned to one of k parts)
- `OptimizationProblem::direction()` -> `Direction::Maximize`
- `evaluate()`: Sum weights of edges where endpoints have different labels.

**Relation to MaxCut:** For k = 2, `MaxKCut<K2, G, W>` should produce identical results to `MaxCut<G, W>`. Consider whether to make MaxCut a type alias or keep separate implementations.

**Variant:** `[("graph", G::NAME), ("weight", W::NAME)]`. The k parameter is encoded via the KValue type parameter, analogous to KColoring and KSatisfiability.

---

## 4. Longest Path

### 4.1 Formal Definition

**Garey & Johnson reference:** [ND29]

**Input:** An undirected (or directed) graph G = (V, E), optionally with edge weights w: E -> R+, and optionally designated source s and target t.

**Objective:** Find a simple path (no repeated vertices) of maximum length (number of edges, or total weight for weighted graphs).

Formal optimization version:
```
maximize    |P| - 1  (number of edges in path P)
            or sum_{e in P} w(e) for weighted version
subject to  P is a simple path in G
            (optionally: P starts at s and ends at t)
```

**Decision version:** Given integer k, does G contain a simple path with at least k edges?

**Note:** The path must be **simple** (no repeated vertices). Without this constraint, the problem is trivial (infinite for graphs with cycles).

### 4.2 Complexity Classification

**NP-hardness (Garey & Johnson 1979, [ND29]):** The decision version is NP-complete.

**Reduction from Hamiltonian Path:** A graph G has a Hamiltonian path iff its longest path has length n - 1. Since Hamiltonian Path is NP-complete, Longest Path is NP-hard.

**Inapproximability:** The Longest Path problem cannot be approximated within n^{1-epsilon} for any epsilon > 0 in polynomial time, unless P = NP (Karger, Motwani, Ramkumar 1997). This makes it one of the hardest problems to approximate.

**Polynomial cases:**
- **DAGs (directed acyclic graphs):** Solvable in O(V + E) time via topological sort + dynamic programming
- **Trees:** O(n) time (the longest path = diameter, found by two BFS/DFS passes)
- **Block graphs, cacti, bipartite permutation graphs, Ptolemaic graphs:** Polynomial
- **Interval graphs:** O(n^4) time

### 4.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1979 | Garey, Johnson | Listed as NP-complete [ND29] |
| 1995 | Alon, Yuster, Zwick | Color-coding technique: O*(2^k) for k-length paths |
| 1997 | Karger, Motwani, Ramkumar | n^{1-epsilon} inapproximability |
| 2009 | Williams | Improved to O*(2^k) deterministic via algebraic techniques |
| 2011 | Cygan et al. | Cut&Count: c^{tw} * n for treewidth-parameterized algorithms |

### 4.4 Approximation Algorithms

**Inapproximability:** No polynomial-time algorithm can approximate within n^{1-epsilon} for any epsilon > 0 (Karger, Motwani, Ramkumar 1997). This is an extremely strong hardness result.

**Color-coding based (Alon, Yuster, Zwick 1995):** For paths of length exactly k:
- Randomized: O*(2^k) time (color vertices with k colors, find colorful path by DP)
- Derandomization: O*(2^k * log n) time using k-perfect hash families
- Approximation ratio for longest path: O(n / log n) -- find longest path of length k = Theta(log n) in polynomial time

**Practical heuristics:**
- DFS-based: find a path, try to extend
- Local search: swap vertices to lengthen the path
- Genetic algorithms for larger instances

### 4.5 Parameterized Complexity

**FPT by path length k:** Yes, via color-coding. Running time O*(2^k) (Alon, Yuster, Zwick 1995; improved by Williams 2009).

**FPT by treewidth tw:** Yes, solvable in c^{tw} * n time via the Cut&Count technique (Cygan et al., FOCS 2011):
- Randomized: O(4^{tw} * n) for Longest Path
- Deterministic: O(6^{tw} * n) (Bodlaender, Cygan, Kratsch, Nederlof, ICALP 2013)

The improvement from tw^{O(tw)} (naive DP) to c^{tw} was a major breakthrough. Lower bounds suggest improving the constant c below 4 (for randomized) would violate SETH.

**W[1]-hard by clique-width:** Longest Path parameterized by clique-width is W[1]-hard (Fellows et al., 2009). The polynomial-time algorithm on bounded clique-width graphs has exponent depending on the clique-width.

**Para-NP-hard by vertex cover:** The problem remains NP-hard even when parameterized by vertex cover number.

### 4.6 Exact Algorithms and Practical Solvers

**Brute force:** O*(n!) time by trying all permutations. Can be improved:
- O*(2^n) via dynamic programming (Bellman-Held-Karp style, as for Hamiltonian Path/TSP)
- Space: O*(2^n) as well

**ILP/MIP solvers:** Effective for moderate instances (n <= 100--200) using subtour elimination constraints (analogous to TSP).

**SAT-based:** Encode as Boolean satisfiability and use modern SAT solvers. Effective for sparse graphs.

### 4.7 Known Reductions

```
Longest Path
  <-- Hamiltonian Path (special case: longest path = n-1)
  --> ILP (subtour elimination formulation)
  --> QUBO (position-based encoding)
  --> TSP (via transformation: set edge weights to 1, find max-weight Hamiltonian path)
  <-> Traveling Salesman (implemented; both involve finding optimal paths/cycles)
```

**From Hamiltonian Path:** G has a Hamiltonian path iff the longest path in G has length n - 1. This is a trivial reduction.

**To TSP:** Create a complete graph K_n. For each edge (u,v) in G, set TSP weight d(u,v) = -1 (or 0 for non-edges, 1 for edges in a max-weight variant). The TSP tour minus one edge gives the longest Hamiltonian path. This only works when seeking paths of length n-1.

**Relation to Maximum Independent Set (implemented):** On the complement graph, independent sets correspond to cliques. No direct standard reduction to MIS, but both are prototypical hard problems on graphs.

### 4.8 QUBO/Ising and ILP Formulations

**QUBO formulation (Bauckhage et al. 2018, Salehi et al. 2022):**

Position-based encoding: For a path of length k, introduce binary variables x_{v,p} = 1 iff vertex v is at position p in the path (p in {0, 1, ..., k}).

```
H = A * sum_{p=0}^{k} (1 - sum_{v in V} x_{v,p})^2    (each position has exactly one vertex)
  + A * sum_{v in V} (1 - sum_{p=0}^{k} x_{v,p})^2     (each vertex used at most once -- but not all vertices are on path)
  + B * sum_{p=0}^{k-1} sum_{(v,w) not in E} x_{v,p} * x_{w,p+1}  (consecutive vertices must be adjacent)
```

Number of binary variables: n * (k + 1). Since k is unknown for optimization, one can try k = n-1 down to k = 1, or use a penalty-based approach.

**Alternative degree-based QUBO (Salehi et al. 2022):** Uses O(n * log k) variables by encoding positions in binary, reducing variable count but increasing the number of interaction terms.

**ILP formulation (subtour elimination, analogous to TSP):**

For s-t Longest Path:
```
maximize    sum_{(i,j) in E} x_{ij}
subject to  sum_{j: (i,j) in E} x_{ij} <= 1             for all i in V (out-degree at most 1)
            sum_{j: (j,i) in E} x_{ji} <= 1             for all i in V (in-degree at most 1)
            sum_{j: (s,j) in E} x_{sj} = 1              (path starts at s)
            sum_{j: (j,t) in E} x_{jt} = 1              (path ends at t)
            subtour elimination constraints              (prevents disconnected cycles)
            x_{ij} in {0, 1}
```

Subtour elimination can use Miller-Tucker-Zemlin (MTZ) constraints with O(n) auxiliary variables, or exponentially many subtour constraints added lazily via cutting planes.

### 4.9 Connections to Other Proposed Problems

- **Traveling Salesman (implemented):** TSP asks for the shortest Hamiltonian cycle; Longest Path asks for the longest simple path. Both involve finding optimal paths/cycles in graphs. A Hamiltonian path is a longest path of length n-1.
- **Max k-Cut (Section 3):** No direct reduction, but both are classic NP-hard optimization problems on graphs.
- **QAP (Section 8):** TSP is a special case of QAP, and Longest Path relates to TSP.

### 4.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct LongestPath<G, W = One> {
    graph: G,
    edge_weights: Vec<W>,
}
```

**Trait implementation:**
- `Problem::NAME = "LongestPath"`
- `Problem::Metric = SolutionSize<W::Sum>`
- `Problem::dims()` -> `vec![2; |E|]` (binary: include edge in path or not)
  - **Alternative:** vertex-based with ordering: `vec![n+1; n]` where config[v] = position of v in path (0 = not on path, 1..=n = position). This is closer to the QUBO formulation but has larger config space.
  - **Recommended:** Edge-based binary, analogous to MaximumMatching. config[e] = 1 iff edge e is in the path.
- `OptimizationProblem::direction()` -> `Direction::Maximize`
- `evaluate()`: Check selected edges form a simple path (connected, no vertex appears more than twice in the edge set, at most 2 vertices of degree 1, no vertex of degree > 2). If valid, return `Valid(total_weight)`. Otherwise `Invalid`.

**Key consideration:** Unlike matching (where any subset with no shared vertices works), a path must be connected. The `evaluate()` function must verify connectivity of selected edges, which requires O(|E|) union-find or DFS.

**Variant:** `[("graph", G::NAME), ("weight", W::NAME)]`

**Size fields:** `num_vertices`, `num_edges`.

---

## 5. Minimal Maximal Matching (Min-Edge Dominating Set)

### 5.1 Formal Definition

**Garey & Johnson references:** [GT10] (Minimum Maximal Matching), [GT2] (Edge Dominating Set)

**Input:** An undirected graph G = (V, E).

**Matching definition:** A matching M is a subset of E such that no two edges in M share a vertex. A matching is **maximal** if no edge can be added without violating the matching property.

**Objective:** Find a maximal matching of minimum cardinality:

```
minimize    |M|
subject to  M is a matching (no two edges share a vertex)
            M is maximal (no edge in E\M can be added to M)
```

**Equivalence to Minimum Edge Dominating Set:** A subset D of E is an **edge dominating set** if every edge in E\D shares a vertex with some edge in D. Yannakakis and Gavril (1980) proved:

> The minimum cardinality of a maximal matching equals the minimum cardinality of an edge dominating set.

Moreover, every maximal matching is an edge dominating set.

### 5.2 Complexity Classification

**NP-hardness (Yannakakis and Gavril, 1980):** Both Minimum Maximal Matching and Minimum Edge Dominating Set are NP-complete, even when restricted to:
- Planar graphs with max degree 3
- Bipartite graphs with max degree 3

**Publication:** Yannakakis, M., Gavril, F. (1980), "Edge dominating sets in graphs," SIAM Journal on Applied Mathematics, 38(3): 364--372.

**Extension (Demange and Ekim, 2008):** NP-hard in k-regular bipartite graphs for all fixed k >= 3.

**Approximation hardness (Chlebik and Chlebikova, 2006):** NP-hard to approximate within any factor less than 7/6. This result extends to bounded-degree graphs and everywhere-dense graphs.

### 5.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1980 | Yannakakis, Gavril | NP-completeness; equivalence to edge dominating set |
| 2006 | Chlebik, Chlebikova | 7/6 inapproximability lower bound |
| 2008 | Demange, Ekim | NP-hard on k-regular bipartite graphs for k >= 3 |
| 2014 | Lucas | QUBO/Ising formulation (Section 4.5) |

### 5.4 Approximation Algorithms

**Trivial 2-approximation:** Find any maximal matching M (greedily add non-conflicting edges). Then |M| <= 2 * OPT, since any maximal matching has size at most 2 times the minimum maximal matching.

Proof: Let M* be a minimum maximal matching, and M be any maximal matching. Each edge of M* can "dominate" at most 2 edges of M (one at each endpoint), so |M| <= 2|M*|.

**Better approximation:**
- For weighted version: 2-approximation is the best known polynomial-time guarantee
- No PTAS exists (unless P = NP), due to the 7/6 hardness of Chlebik-Chlebikova

**Relation to Maximum Matching:**
- Maximum Matching: find the largest matching (Edmonds' algorithm, polynomial)
- Minimum Maximal Matching: find the smallest matching that is still maximal (NP-hard)
- For any graph: minimum_maximal_matching(G) <= maximum_matching(G)
- But minimum_maximal_matching(G) >= maximum_matching(G) / 2 (since a maximal matching is a 2-approximation to max matching)

### 5.5 Parameterized Complexity

**FPT by solution size k:** Yes. An FPT algorithm exists using crown decomposition (3-spike crown decomposition), running in time f(k) * n^{O(1)}.

**FPT by treewidth tw:** Yes, solvable in O(c^{tw} * n) time via standard dynamic programming on tree decompositions. The matching constraint is local (no shared vertices) and the maximality constraint requires checking that all edges are dominated.

**Kernelization:** A polynomial kernel exists parameterized by solution size k.

### 5.6 Exact Algorithms and Practical Solvers

**Brute force:** O*(2^{|E|}) time to enumerate all edge subsets, checking matching and maximality conditions.

**Improved exact:** Using the structure of matchings, can enumerate all maximal matchings more efficiently. The number of maximal matchings can be exponential, but branch-and-bound with matching-based lower bounds is practical.

**ILP/MIP solvers:** Effective for moderate instances via the ILP formulation below.

### 5.7 Known Reductions

```
Minimal Maximal Matching
  <-> Minimum Edge Dominating Set (equivalence, Yannakakis-Gavril 1980)
  --> ILP (matching + maximality constraints)
  --> QUBO (Lucas 2014, Section 4.5)
  <-- Maximum Matching (implemented; same structure, different objective)
  <-- Vertex Cover (edge domination is related)
```

**Relation to Minimum Vertex Cover (implemented):** Every edge dominating set induces a vertex cover (the endpoints of the dominating edges), and vice versa, minimum vertex cover bounds minimum edge dominating set from below (roughly: MVC >= MEDS >= MVC/2). More precisely, for any graph G:
```
minimum_edge_dominating_set(G) >= minimum_vertex_cover(G) / 2
```

### 5.8 QUBO/Ising and ILP Formulations

**QUBO/Ising formulation (Lucas 2014, Section 4.5):**

Variables: x_e in {0, 1} for each edge e in E, where x_e = 1 iff edge e is in the matching M.

```
H_A = A * sum_{v in V} sum_{e1, e2 in delta(v), e1 < e2} x_{e1} * x_{e2}
    (matching constraint: at most one edge per vertex)

H_B = B * sum_{e=(u,v) in E} (1 - x_e) * prod_{f in delta(u) union delta(v), f != e} (1 - x_f)
    (maximality: if edge e is not in M, at least one neighbor must be)

H_C = C * sum_{e in E} x_e
    (objective: minimize number of selected edges)
```

Note: H_B involves higher-order terms (products of many variables). Reducing to quadratic QUBO requires auxiliary variables via the standard penalty reduction, increasing the number of variables.

Number of base variables: |E|.

**ILP formulation:**

```
minimize    sum_{e in E} x_e
subject to  sum_{e in delta(v)} x_e <= 1              for all v in V   (matching constraint)
            sum_{e in delta(v)} x_e + sum_{e' in delta(v)} x_{e'} >= 1  (edge domination -- simplified)
```

More precisely, for edge domination (every edge must be incident to a selected edge):
```
minimize    sum_{e in E} x_e
subject to  sum_{e in delta(v)} x_e <= 1                     for all v in V
            x_e + sum_{f in delta(u) union delta(v) \ {e}} x_f >= 1   for all e = (u,v) in E
            x_e in {0, 1}                                    for all e in E
```

Variables: |E| binary variables. Constraints: |V| + |E| inequalities.

### 5.9 Connections to Other Proposed Problems

- **Maximum Matching (implemented):** Same structure (subsets of edges forming a matching) but opposite objective (maximize vs minimize among maximal matchings). `MaximumMatching` already exists in the codebase.
- **Minimum Vertex Cover (implemented):** Closely related via the Gallai-Edmonds structure theorem. Edge dominating sets and vertex covers have linked sizes.
- **Edge Coloring (Section 2):** Each color class in a proper edge coloring is a matching.

### 5.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct MinimalMaximalMatching<G> {
    graph: G,
}
```

**Trait implementation:**
- `Problem::NAME = "MinimalMaximalMatching"`
- `Problem::Metric = SolutionSize<usize>` -- count of edges in the matching
- `Problem::dims()` -> `vec![2; |E|]` (binary: include each edge or not)
- `OptimizationProblem::direction()` -> `Direction::Minimize`
- `evaluate()`: Check (1) selected edges form a matching (no shared vertices), and (2) the matching is maximal (no unselected edge can be added). If both conditions hold, return `Valid(|M|)`. Otherwise `Invalid`.

**Key implementation detail:** The maximality check in `evaluate()` requires verifying that every unselected edge has at least one endpoint covered by a selected edge. This is O(|E|) per evaluation.

**Alternative name consideration:** Could be named `MinimumEdgeDominatingSet` since the problems are equivalent. The naming `MinimalMaximalMatching` follows the convention of describing the structure (maximal matching) with the optimization prefix (minimal = minimum cardinality).

**Variant:** `[("graph", G::NAME)]`. Unweighted problem (always unit weights).

**Size fields:** `num_vertices`, `num_edges`.

---

## 6. Multiway Cut

### 6.1 Formal Definition

**Input:** An undirected graph G = (V, E) with edge weights w: E -> R+, and a set of k designated terminal vertices T = {t_1, t_2, ..., t_k} where T is a subset of V.

**Objective:** Find a minimum-weight set of edges S, a subset of E, whose removal disconnects every pair of terminals from each other:

```
minimize    sum_{e in S} w(e)
subject to  In G' = (V, E \ S), no two terminals t_i, t_j are in the same connected component
```

Equivalently: find a minimum-weight edge set whose removal partitions V such that each terminal is in a different part.

### 6.2 Complexity Classification

**k = 2 (polynomial):** When there are only two terminals, Multiway Cut is the classical minimum s-t cut problem, solvable in polynomial time via max-flow min-cut (Ford-Fulkerson, Dinic, etc.).

**k >= 3 (NP-hard):** Dahlhaus, Johnson, Papadimitriou, Seymour, and Yannakakis (1992/1994) proved that Multiway Cut is NP-hard for k >= 3, even with unit edge weights.

**MAX SNP-hard / APX-hard:** The same paper shows Multiway Cut is MAX SNP-hard for k >= 3 with unit costs, implying no PTAS exists (unless P = NP). A specific inapproximability lower bound of 1.2 was established by Angelidakis, Makarychev, and Manurangsi.

**Publication:** Dahlhaus, E., Johnson, D.S., Papadimitriou, C.H., Seymour, P.D., Yannakakis, M. (1994), "The complexity of multiterminal cuts," SIAM J. Computing, 23(4): 864--894. Preliminary version at STOC 1992.

**Planar graphs:** Polynomial for any fixed k (Dahlhaus et al. 1994). NP-hard on planar graphs when k is part of the input.

### 6.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1956 | Ford, Fulkerson | Max-flow min-cut (k=2 case) |
| 1992 | Dahlhaus, Johnson, Papadimitriou, Seymour, Yannakakis | NP-hardness for k >= 3; (2-2/k)-approximation via isolating cuts |
| 1998 | Calinescu, Karloff, Rabani | (3/2 - 1/k)-approximation via geometric LP relaxation (CKR relaxation) |
| 2004 | Karger, Klein, Stein, Thorup, Young | 1.3438-approximation via improved rounding of CKR |
| 2014 | Sharma, Vondrak | 1.2965-approximation (current best) |

### 6.4 Approximation Algorithms

**Isolating cuts (Dahlhaus et al. 1992):** (2 - 2/k)-approximation.
- For each terminal t_i, compute the minimum s-t cut separating t_i from all other terminals (treat other terminals as a single sink).
- Take the union of the k - 1 cheapest of the k isolating cuts.
- Analysis: Each edge of the optimal solution appears in at most 2 isolating cuts. Discarding the most expensive isolating cut gives factor 2(1 - 1/k).
- Running time: O(k * max-flow), i.e., k applications of max-flow.

**CKR geometric relaxation (Calinescu, Karloff, Rabani 1998/2000):** (3/2 - 1/k)-approximation.
- Embed vertices into the k-simplex (each terminal maps to a vertex of the simplex).
- LP relaxation minimizes weighted "simplex distance" of edges.
- Rounding: partition the simplex into k regions; vertices in each region form a terminal-separated part.
- Achieves factor 3/2 - 1/k, improving the isolating cuts bound.

**Improved rounding (Karger, Klein, Stein, Thorup, Young 2004):** 1.3438-approximation.
- Use the CKR relaxation with an optimized rounding scheme.
- For k = 3: achieves 12/11 ~ 1.0909 (tight for the CKR relaxation).
- For general k: 1.3438 - epsilon_k, where epsilon_k -> 0 as k -> infinity.
- The rounding scheme itself is found by solving an auxiliary LP.

**Current best (Sharma and Vondrak 2014):** 1.2965-approximation, using a new rounding scheme based on "descending thresholds."

**Inapproximability:** No polynomial-time algorithm can achieve a ratio better than 1.2 (Angelidakis, Makarychev, Manurangsi 2017), based on Unique Games.

### 6.5 Parameterized Complexity

**FPT by solution size k (number of cut edges):** Yes. FPT via randomized contractions or iterative compression. Cygan et al. give O*(2^k) algorithm.

**FPT by number of terminals:** The problem is polynomial for any fixed k (via k applications of max-flow), though the polynomial depends on k.

**Parameterized by treewidth tw:** No single-exponential (2^{O(tw)} * n^{O(1)}) exact algorithm is expected. Bergougnoux et al. (IPEC 2020) showed conditional lower bounds ruling out c^{tw} * n^{O(1)} algorithms for Node Multiway Cut. However, FPT-approximation is possible: a (4 + epsilon)-approximation in 2^{O(tw)} * n time.

### 6.6 Exact Algorithms and Practical Solvers

**Brute force:** O*(2^{|E|}) by trying all edge subsets. Can be improved by only considering edges on paths between terminals.

**ILP solvers:** Very effective, since the LP relaxation (CKR) has good integrality properties. Commercial solvers (CPLEX, Gurobi) can handle instances with thousands of vertices.

**Min-cut based:** For small k, iterating over terminal pairs and computing min-cuts provides practical solutions. Gomory-Hu trees precompute all pairwise min-cuts in n-1 max-flow computations.

### 6.7 Known Reductions

```
Multiway Cut
  <-- Min s-t Cut (k=2 special case; polynomial)
  --> ILP (flow-based or CKR relaxation)
  <-- Max k-Cut (complementary: max crossing vs min separating)
  <-- Minimum Bisection (special structure)
  --> Minimum Vertex Cover (approximate reduction)
```

**To ILP:** Direct formulation with flow-conservation constraints or the CKR geometric relaxation.

**From Min s-t Cut:** When k = 2, Multiway Cut = Min s-t Cut = Max-Flow (polynomial).

**Vertex Multiway Cut variant:** Instead of removing edges, remove vertices (excluding terminals) to separate terminals. This variant is also NP-hard for k >= 3 and has been studied separately with FPT algorithms.

### 6.8 QUBO/Ising and ILP Formulations

**ILP formulation (edge-based):**

```
minimize    sum_{e in E} w_e * z_e
subject to  z_e in {0, 1}                    for all e in E (z_e = 1 iff edge e is cut)
            For all i != j in {1,...,k}: no path from t_i to t_j using edges with z_e = 0
```

The path-elimination constraints are exponential. In practice, use:
- **Flow-based formulation:** For each terminal pair (t_i, t_j), introduce flow variables and require that no flow can reach t_j from t_i through uncut edges.
- **CKR-based LP:** Assign each vertex to a region in the k-simplex; LP constraints enforce valid partitioning.

Compact ILP:
```
minimize    sum_{e=(u,v) in E} w_e * (1 - sum_{c=1}^{k} x_{u,c} * x_{v,c})
subject to  sum_{c=1}^{k} x_{v,c} = 1            for all v in V  (each vertex in one part)
            x_{t_i,i} = 1                          for all i in {1,...,k}  (terminal constraints)
            x_{v,c} in {0, 1}
```

This has n * k binary variables and is equivalent to the Multiway Cut problem.

**QUBO/Ising formulation:**

Using the ILP above, convert to QUBO with one-hot encoding:
```
H = A * sum_v (1 - sum_{c=1}^{k} x_{v,c})^2         (one-hot: each vertex in exactly one part)
  + A * sum_i (1 - x_{t_i,i})^2                       (terminal assignment)
  + B * sum_{(u,v) in E} w_{uv} * (1 - sum_{c=1}^{k} x_{u,c} * x_{v,c})  (cut weight)
```

Number of binary variables: n * k.

### 6.9 Connections to Other Proposed Problems

- **Max-Cut (implemented, k=2):** Min s-t Cut (k=2 Multiway Cut) is the dual of Max-Flow. Max-Cut maximizes cut weight; Multiway Cut (k=2) minimizes it with terminal constraints.
- **Graph Partitioning (Section 7):** Both partition vertices, but Graph Partitioning has balance constraints while Multiway Cut has terminal-separation constraints.
- **Minimum Bisection (Section 1):** Bisection is balanced 2-partition minimizing cut; Multiway Cut is terminal-separation minimizing cut. Different constraints, same optimization direction.
- **Max k-Cut (Section 3):** Complementary: Max k-Cut maximizes cut weight over k-partitions; Multiway Cut minimizes cut weight subject to terminal separation.

### 6.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct MultiwayCut<G, W = One> {
    graph: G,
    edge_weights: Vec<W>,
    terminals: Vec<usize>,  // terminal vertex indices
}
```

**Trait implementation:**
- `Problem::NAME = "MultiwayCut"`
- `Problem::Metric = SolutionSize<W::Sum>`
- `Problem::dims()` -> `vec![2; |E|]` (binary: cut each edge or not)
- `OptimizationProblem::direction()` -> `Direction::Minimize`
- `evaluate()`: Check that removing selected edges separates all terminals into different connected components (BFS/DFS from each terminal in the remaining graph). If separated, return `Valid(total_cut_weight)`. Otherwise `Invalid`.

**Alternative encoding:** Assign each vertex to a terminal partition: `dims() -> vec![k; n]` where config[v] = which terminal's partition vertex v belongs to. Terminals are fixed: config[t_i] must equal i. This encoding is smaller when |E| >> n * k, and matches the ILP/QUBO formulation. However, the terminal-fixing constraint makes some configs invalid.

**Key consideration:** The number of terminals k is an instance parameter, not a type parameter. Unlike KColoring where K is a type parameter, MultiwayCut stores terminals as runtime data.

**Variant:** `[("graph", G::NAME), ("weight", W::NAME)]`

**Size fields:** `num_vertices`, `num_edges`, `num_terminals`.

---

## 7. Graph Partitioning (k-way balanced)

### 7.1 Formal Definition

**Garey & Johnson reference:** Related to [ND14], [ND16]

**Input:** An undirected graph G = (V, E) with edge weights w: E -> R+, and a positive integer k.

**Objective:** Partition V into k disjoint sets S_1, ..., S_k of approximately equal size, minimizing the total weight of edges crossing between parts:

```
minimize    sum_{(u,v) in E : u in S_i, v in S_j, i != j} w(u,v)
subject to  S_1 union ... union S_k = V
            S_i intersect S_j = empty for i != j
            |S_i| = n/k for all i  (or ||S_i| - n/k| <= 1 for non-divisible n)
```

**Relaxed balance:** A (k, 1+epsilon)-balanced partition requires |S_i| <= (1 + epsilon) * n/k for all i.

**Special cases:**
- k = 2: Minimum Bisection
- No balance constraint: Multiway Cut (with terminals)
- Maximize instead of minimize: Max k-Cut

### 7.2 Complexity Classification

**NP-completeness:** Graph Partitioning is NP-complete (Garey and Johnson 1979). Even for k = 2 (Minimum Bisection), the problem is NP-complete.

**Inapproximability for exact balance:** The (k, 1)-balanced partitioning problem (exact equal sizes) has no polynomial-time approximation algorithm with any finite approximation factor, unless P = NP. This is because even deciding whether a balanced partition of a given size exists is NP-hard.

**APX-hardness:** For the relaxed version with epsilon > 0, the problem remains APX-hard for any fixed k >= 2.

### 7.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1979 | Garey, Johnson | NP-completeness |
| 1988 | Leighton, Rao | O(log n)-approximation for bisection via multicommodity flow |
| 2004 | Arora, Rao, Vazirani | O(sqrt(log n)) for balanced separator |
| 2006 | Andreev, Racke | Bicriteria approximation for k-way partitioning |
| 2009 | Krauthgamer, Naor, Schwartz | SDP-based bicriteria approximation for k-way |
| 2014 | Lucas | QUBO/Ising formulation (Section 2) |

### 7.4 Approximation Algorithms

**Bicriteria approximation (standard approach):** Allow parts to be slightly unbalanced to achieve a bounded approximation ratio.

**Even, Naor, Rao, Schieber (1999):** O(log n)-approximation for any k, allowing parts of size at most (1 + epsilon) * n/k. Based on recursive bisection using the Leighton-Rao framework.

**Krauthgamer, Naor, Schwartz (SODA 2009):** SDP-based bicriteria approximation using spreading metrics. The integrality gap of the SDP relaxation is Omega(log k) for large k, meaning the dependence on k in the approximation factor is inherent for this relaxation.

**Recursive bisection:** A simple practical approach:
1. Bisect the graph (using any bisection algorithm)
2. Recursively bisect each half until k parts are obtained
This gives an O(log k)-factor blowup over the bisection approximation ratio.

**Spectral methods (practical):** Compute the k smallest eigenvectors of the Laplacian, embed vertices in R^k, then cluster (e.g., k-means). Quality depends on the spectral gap. Widely used in practice (METIS, KaHiP, Scotch).

### 7.5 Parameterized Complexity

**FPT by cut size (k=2):** Yes, Minimum Bisection is FPT by cut size (Cygan et al. 2014).

**FPT by treewidth tw:** For fixed k, the balanced k-partition problem is FPT parameterized by treewidth, solvable in k^{O(tw)} * n time. The dependence on k in the base of the exponent is significant.

**W[1]-hardness:** For k as part of the input (not fixed), balanced k-partitioning parameterized by k is W[1]-hard (since it generalizes k-Coloring, which is W[1]-hard parameterized by k on general graphs... but note k-Coloring has no balance constraint, so the analogy is imprecise). The exact parameterized complexity of balanced k-partition by k alone is open for many formulations.

### 7.6 Exact Algorithms and Practical Solvers

**Practical solvers (used extensively in industry):**
- **METIS** (Karypis and Kumar): Multilevel graph partitioning. Coarsens the graph, partitions the coarsened graph, then uncoarsens with refinement. Handles millions of vertices.
- **KaHiP** (Karlsruhe High Quality Partitioning): State-of-the-art quality, uses evolutionary algorithms + multilevel schemes.
- **Scotch**: Includes both static and dynamic partitioning.
- **ParMETIS / ParHIP**: Parallel versions for distributed computing.

**Branch-and-bound with SDP bounds:** For exact solutions on small instances (n <= 100--200).

**Applications:**
- Parallel computing: distribute work evenly across processors while minimizing communication
- VLSI circuit design: partition logic blocks to minimize wire length
- Load balancing in distributed systems
- Scientific computing: mesh partitioning for finite element methods

### 7.7 Known Reductions

```
Graph Partitioning
  <-- Minimum Bisection (k=2 special case, Section 1)
  --> QUBO (Lucas 2014, Section 2)
  --> ILP (assignment + balance constraints)
  <-> Max k-Cut (complementary objective)
  <-> Multiway Cut (without balance, with terminals)
```

### 7.8 QUBO/Ising and ILP Formulations

**QUBO/Ising formulation (Lucas 2014, Section 2):**

Variables: x_{i,c} in {0, 1} for each vertex i and part c in {1, ..., k}, where x_{i,c} = 1 iff vertex i is assigned to part c.

```
H = A * sum_i (1 - sum_{c=1}^{k} x_{i,c})^2          (one-hot: each vertex in exactly one part)
  + A * sum_c (sum_i x_{i,c} - n/k)^2                  (balance: each part has n/k vertices)
  + B * sum_{(i,j) in E} w_{ij} * (1 - sum_{c=1}^{k} x_{i,c} * x_{j,c})  (cut weight to minimize)
```

First term: one-hot constraint.
Second term: balance constraint.
Third term: objective (cut weight).

Number of binary variables: n * k.
Constraint: A must be large enough to enforce one-hot and balance constraints (A > B * W_max * Delta).

**ILP formulation:**

```
minimize    sum_{(i,j) in E} w_{ij} * z_{ij}
subject to  sum_{c=1}^{k} x_{i,c} = 1                  for all i in V      (one-hot)
            sum_{i in V} x_{i,c} = n/k                  for all c in {1,...,k} (balance)
            z_{ij} >= x_{i,c} - x_{j,c}                 for all (i,j) in E, c  (linearize cut)
            z_{ij} >= x_{j,c} - x_{i,c}                 for all (i,j) in E, c
            x_{i,c} in {0, 1}, z_{ij} in {0, 1}
```

Variables: n * k + |E| binary variables. Constraints: n + k + 2|E|k inequalities.

### 7.9 Connections to Other Proposed Problems

- **Minimum Bisection (Section 1):** k = 2 special case.
- **Max k-Cut (Section 3):** Same partition structure, opposite objective (maximize vs minimize cut weight). No balance constraint in Max k-Cut.
- **Multiway Cut (Section 6):** Both minimize cut weight, but Graph Partitioning has balance constraints while Multiway Cut has terminal-separation constraints.
- **QUBO (implemented):** Natural formulation via Lucas's Ising mapping.
- **QAP (Section 8):** QAP generalizes graph partitioning when flow and distance matrices are considered.

### 7.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct GraphPartitioning<K: KValue, G, W = One> {
    graph: G,
    edge_weights: Vec<W>,
    num_parts: usize,
}
```

**Trait implementation:**
- `Problem::NAME = "GraphPartitioning"`
- `Problem::Metric = SolutionSize<W::Sum>`
- `Problem::dims()` -> `vec![k; n]` (each vertex assigned to one of k parts)
- `OptimizationProblem::direction()` -> `Direction::Minimize`
- `evaluate()`: Check balance (each part has exactly n/k vertices, or within 1 for non-divisible n). If unbalanced, return `Invalid`. Otherwise sum weights of edges crossing between parts and return `Valid(cut_weight)`.

**Relation to MinimumBisection:** For k = 2, `GraphPartitioning<K2, G, W>` is equivalent to `MinimumBisection<G, W>`. Consider whether to keep separate implementations or make MinimumBisection a type alias.

**Variant:** `[("graph", G::NAME), ("weight", W::NAME)]`. The k parameter is encoded via the KValue type parameter.

**Size fields:** `num_vertices`, `num_edges`.

---

## 8. Quadratic Assignment Problem (QAP)

### 8.1 Formal Definition

**Garey & Johnson reference:** [ND43]

**Input:** Two n x n matrices:
- F = (f_{ij}): flow matrix, where f_{ij} represents the flow between facilities i and j
- D = (d_{kl}): distance matrix, where d_{kl} represents the distance between locations k and l

**Objective:** Find a permutation pi: {1, ..., n} -> {1, ..., n} that minimizes the total cost:

```
minimize    sum_{i=1}^{n} sum_{j=1}^{n} f_{ij} * d_{pi(i), pi(j)}
subject to  pi is a permutation (bijection)
```

Equivalently, using a permutation matrix X = (x_{ik}) where x_{ik} = 1 iff facility i is assigned to location k:

```
minimize    sum_{i,j,k,l} f_{ij} * d_{kl} * x_{ik} * x_{jl}
subject to  sum_k x_{ik} = 1  for all i  (each facility to one location)
            sum_i x_{ik} = 1  for all k  (each location to one facility)
            x_{ik} in {0, 1}
```

**Koopmans-Beckmann form (1957):** The original formulation models assigning n facilities to n locations, minimizing total interaction cost weighted by distance.

### 8.2 Complexity Classification

**NP-hardness:** QAP is strongly NP-hard (Sahni and Gonzalez, 1976). It is described as "the hardest of the hard" among combinatorial optimization problems.

**Inapproximability:** Sahni and Gonzalez (1976) showed that unless P = NP, there is no polynomial-time algorithm that approximates QAP within any constant factor. Even stronger: no FPTAS exists unless P = NP.

This extreme inapproximability distinguishes QAP from most other NP-hard problems, which typically admit constant-factor or O(log n)-factor approximations.

**Practical hardness:** Instances with n > 30 are generally intractable for exact solvers. The hardest known instances (from QAPLIB) remain unsolved for n > 36.

### 8.3 History and Key Milestones

| Year | Authors | Contribution |
|------|---------|-------------|
| 1957 | Koopmans, Beckmann | Original formulation (facility location) |
| 1976 | Sahni, Gonzalez | NP-hardness, inapproximability within any constant |
| 1997 | Burkard, Karisch, Rendl | QAPLIB benchmark library |
| 1998 | Anstreicher et al. | Branch-and-bound solving instances up to n=30 |
| 2014 | Lucas | QUBO/Ising formulation (Section 8) |

### 8.4 Approximation Algorithms

**No constant-factor approximation:** The inapproximability result of Sahni and Gonzalez (1976) rules out any polynomial-time algorithm with bounded approximation ratio for general QAP, unless P = NP.

**Special structure:** For QAP instances with specific structure (e.g., tree-structured flows, grid-structured distances), better approximation is sometimes possible. But for general F and D matrices, no meaningful polynomial-time approximation guarantee exists.

**Practical heuristics:**
- **Simulated annealing:** Widely used; swaps two facility assignments per step
- **Tabu search:** Reactive tabu search is state-of-the-art for large unstructured instances
- **Genetic algorithms / memetic algorithms:** Population-based approaches with local search
- **Ant colony optimization:** Effective for structured instances
- **GRASP (Greedy Randomized Adaptive Search):** Competitive for medium-sized instances

### 8.5 Parameterized Complexity

QAP has received limited attention from the parameterized complexity community, primarily because of its extreme hardness.

**No known FPT results for natural parameters:** The problem's n^2 binary variables and quartic objective (in the linearized form) make standard parameterization difficult.

**Structural parameters:** For special flow/distance structures (e.g., bounded treewidth of the flow graph), restricted QAP variants may become tractable, but systematic FPT results are not established in the literature.

**Connection to graph isomorphism:** QAP with F = D (same matrix) asks for the permutation minimizing sum f_{ij} * f_{pi(i),pi(j)}, which is related to graph isomorphism and automorphism problems.

### 8.6 Exact Algorithms and Practical Solvers

**Branch-and-bound:** The dominant exact approach. Key ingredients:
- **Gilmore-Lawler bound:** LP relaxation of the linearized QAP
- **QAP-specific bounds:** Eigenvalue bounds (Finke, Burkard, Rendl 1987), convex hull relaxations
- **Symmetry reduction:** Exploit problem structure to prune the search tree

**Practical limits:** Exact solutions feasible for n <= 30--36 with state-of-the-art branch-and-bound on parallel hardware (requiring days to weeks of computation for the hardest instances).

**QAPLIB benchmarks (Burkard, Karisch, Rendl 1997):**
- 134 instances from real-world applications and synthetic generators
- Categories: Nugent (hospital layouts), Taillard (random), Skorin-Kapov (random structured), etc.
- Instance status: solved to optimality or with best-known bounds
- URL: https://www.opt.math.tugraz.at/qaplib/

**Phase transitions (recent research, 2024):** QAP-SAT instances based on submodularity reveal sharp phase transitions in computational difficulty, providing new benchmarks that capture the hardest regime.

### 8.7 Known Reductions

```
Quadratic Assignment Problem
  <-- Traveling Salesman (special case: F = cycle adjacency, D = distances)
  <-- Graph Partitioning (special case)
  --> QUBO (Lucas 2014, Section 8)
  --> ILP (linearization of quadratic objective)
  <-- Minimum Bisection (special case with 2-partition structure)
```

**From TSP:** The TSP is a special case of QAP where:
- F is the adjacency matrix of a Hamiltonian cycle (f_{i,i+1} = f_{n,1} = 1, all else 0)
- D is the distance matrix

The QAP objective sum_{i,j} f_{ij} * d_{pi(i),pi(j)} then equals the total tour length.

**From Graph Partitioning:** Balanced graph partitioning can be encoded as QAP:
- F = adjacency matrix of G (or complement)
- D = block-structured distance matrix where same-part locations have distance 0 and cross-part locations have distance 1

### 8.8 QUBO/Ising and ILP Formulations

**QUBO/Ising formulation (Lucas 2014, Section 8):**

Variables: x_{ik} in {0, 1} for each facility i and location k (n^2 binary variables).

```
H = A * sum_i (1 - sum_k x_{ik})^2         (each facility to exactly one location)
  + A * sum_k (1 - sum_i x_{ik})^2         (each location to exactly one facility)
  + B * sum_{i,j,k,l} f_{ij} * d_{kl} * x_{ik} * x_{jl}   (objective)
```

The objective term is already quadratic in x variables (pairs x_{ik} * x_{jl}), so it fits naturally into QUBO form.

Number of binary variables: n^2.
Number of quadratic terms in objective: O(n^4) (but only O(nnz(F) * nnz(D)) non-zero terms for sparse F and D).

Constraint: A must be large enough so that violating permutation constraints is never beneficial.

**ILP formulation (linearization):**

Introduce auxiliary variables y_{ik,jl} = x_{ik} * x_{jl}:

```
minimize    sum_{i,j,k,l} f_{ij} * d_{kl} * y_{ik,jl}
subject to  sum_k x_{ik} = 1                 for all i
            sum_i x_{ik} = 1                 for all k
            y_{ik,jl} <= x_{ik}              for all i,j,k,l
            y_{ik,jl} <= x_{jl}              for all i,j,k,l
            y_{ik,jl} >= x_{ik} + x_{jl} - 1 for all i,j,k,l
            x_{ik} in {0, 1}, y_{ik,jl} in {0, 1}
```

Variables: n^2 + n^4 binary variables (can be reduced using symmetry).
This linearization is very large; in practice, tighter formulations with fewer variables are used.

**Gilmore-Lawler bound:** An LP relaxation that provides the most commonly used lower bound for branch-and-bound algorithms.

### 8.9 Connections to Other Proposed Problems

- **Traveling Salesman (implemented):** TSP is a special case of QAP. A reduction `TSP -> QAP` would map the TSP distance matrix to D and use a cycle-adjacency matrix for F.
- **Graph Partitioning (Section 7):** Can be encoded as QAP with appropriate flow and distance matrices.
- **Minimum Bisection (Section 1):** Bisection as QAP: F = adjacency matrix, D = {{0,0},{0,0}} vs {{1,1},{1,1}} block structure.
- **QUBO (implemented):** Natural QUBO formulation with n^2 variables via Lucas.
- **ILP (implemented):** Linearization gives ILP with n^2 + n^4 variables.

### 8.10 Implementation Notes for Rust Codebase

**Problem struct:**
```rust
pub struct QuadraticAssignment<W = i32> {
    flow: Vec<Vec<W>>,      // n x n flow matrix
    distance: Vec<Vec<W>>,  // n x n distance matrix
    n: usize,               // number of facilities/locations
}
```

**Trait implementation:**
- `Problem::NAME = "QuadraticAssignment"`
- `Problem::Metric = SolutionSize<W>` where W is the cost type
- `Problem::dims()` -> `vec![n; n]` (each facility assigned to one of n locations)
- `OptimizationProblem::direction()` -> `Direction::Minimize`
- `evaluate()`: Check that config represents a valid permutation (each location used exactly once). If not, return `Invalid`. Otherwise compute sum_{i,j} f_{i,j} * d_{config[i], config[j]} and return `Valid(cost)`.

**Key considerations:**
- Config space `vec![n; n]` means each variable can take n values, but most configurations are not valid permutations. Only n! out of n^n configurations are valid.
- The `BruteForce` solver will enumerate n^n configurations, of which only n! are valid. For n > 8, this is extremely wasteful. A specialized solver or smarter enumeration (permutation-based) would be beneficial.
- Consider adding a `fn is_permutation(config: &[usize], n: usize) -> bool` utility.

**No graph type parameter:** QAP is defined by matrices, not by a graph topology. This differs from most other problems in the codebase.

**Variant:** Empty (no graph/weight type parameters) or `[("weight", W::NAME)]`.

**Size fields:** `n` (problem size).

**Category:** Likely belongs in `src/models/optimization/` rather than `src/models/graph/` since it is fundamentally a matrix-based problem, though it has graph-theoretic applications.

---

## 9. Cross-Problem Reduction Network

### 9.1 Reduction Graph

The following diagram shows the reduction relationships among the 8 proposed problems and their connections to existing problems in the codebase:

```
                    +-----------+
                    | 3-SAT     |  (implemented)
                    +-----+-----+
                          |
                    +-----v-----+
                    | Max-Cut   |  (implemented)
                    +-----+-----+
                          |
          +------+--------+--------+------+
          |      |                 |      |
    +-----v-+ +--v---+      +-----v-+ +--v--------+
    |Min     | |Max   |      |Multiway| |Graph     |
    |Bisect  | |k-Cut |      |Cut     | |Partition |
    +---+----+ +--+---+      +---+----+ +----+-----+
        |         |               |           |
        +---------+-------+-------+-----------+
                          |
                    +-----v-----+
                    |   QUBO    |  (implemented)
                    +-----------+

    +----------+     +---------+     +----------+
    | Edge     |---->|KColoring|     | Maximum  |
    | Coloring |     |(impl'd) |     | Matching |  (implemented)
    +----------+     +---------+     +----+-----+
                                          |
                                   +------v--------+
                                   | Min. Maximal  |
                                   | Matching      |
                                   +---------------+

    +---------+     +-----------+
    | TSP     |---->|   QAP     |
    |(impl'd) |     +-----------+
    +---------+

    +---------+     +-----------+
    | Ham.Path|---->|Longest    |
    |         |     |Path       |
    +---------+     +-----------+
```

### 9.2 Priority Implementation Order

Based on reduction connectivity and codebase impact:

1. **Max k-Cut** -- Direct generalization of existing MaxCut; uses KValue infrastructure from KColoring
2. **Minimum Bisection** -- Natural QUBO target; connects to existing Max-Cut via complementary objective
3. **Graph Partitioning** -- Generalizes Minimum Bisection; connects to Max k-Cut
4. **Minimal Maximal Matching** -- Uses same edge-based structure as existing MaximumMatching
5. **Edge Coloring** -- Reduces to existing KColoring via line graph
6. **Longest Path** -- Connects to existing TravelingSalesman
7. **Multiway Cut** -- Requires terminal infrastructure; builds on max-flow concepts
8. **QAP** -- Matrix-based; least graph-like; most isolated from current codebase

### 9.3 Shared Infrastructure Needs

- **KValue type system:** Already exists for KColoring and KSatisfiability. Max k-Cut and Graph Partitioning should reuse this.
- **Line graph construction:** New utility needed for Edge Coloring reduction.
- **Permutation validation:** New utility for QAP evaluation.
- **Connectivity checking:** New utility for Longest Path and Multiway Cut evaluation (BFS/DFS on subgraphs).
- **Balance checking:** New utility for Minimum Bisection and Graph Partitioning evaluation.

---

## 10. References

### Primary Sources

1. **Garey, M.R., Johnson, D.S.** (1979). *Computers and Intractability: A Guide to the Theory of NP-Completeness*. W.H. Freeman.

2. **Lucas, A.** (2014). "Ising formulations of many NP problems." *Frontiers in Physics*, 2:5. DOI: 10.3389/fphy.2014.00005. [arXiv:1302.5843](https://arxiv.org/abs/1302.5843)

3. **Arora, S., Rao, S., Vazirani, U.** (2009). "Expander flows, geometric embeddings, and graph partitioning." *Journal of the ACM*, 56(2), Article 5. [ACM](https://dl.acm.org/doi/10.1145/1502793.1502794)

4. **Vizing, V.G.** (1964). "On an estimate of the chromatic class of a p-graph." *Diskret. Analiz.*, 3:25--30.

5. **Holyer, I.** (1981). "The NP-completeness of edge-coloring." *SIAM Journal on Computing*, 10(4):718--720.

6. **Konig, D.** (1916). "Uber Graphen und ihre Anwendung auf Determinantentheorie und Mengenlehre." *Math. Annalen*, 77:453--465.

7. **Frieze, A., Jerrum, M.** (1997). "Improved approximation algorithms for MAX k-CUT and MAX BISECTION." *Algorithmica*, 18:67--81. [Springer](https://link.springer.com/article/10.1007/BF02523688)

8. **Alon, N., Yuster, R., Zwick, U.** (1995). "Color-coding." *Journal of the ACM*, 42(4):844--856.

9. **Yannakakis, M., Gavril, F.** (1980). "Edge dominating sets in graphs." *SIAM Journal on Applied Mathematics*, 38(3):364--372. [PDF](https://cgi.di.uoa.gr/~vassilis/co/dominating-sets.pdf)

10. **Dahlhaus, E., Johnson, D.S., Papadimitriou, C.H., Seymour, P.D., Yannakakis, M.** (1994). "The complexity of multiterminal cuts." *SIAM Journal on Computing*, 23(4):864--894. [Princeton](https://collaborate.princeton.edu/en/publications/the-complexity-of-multiway-cuts)

11. **Koopmans, T.C., Beckmann, M.** (1957). "Assignment problems and the location of economic activities." *Econometrica*, 25(1):53--76.

12. **Sahni, S., Gonzalez, T.** (1976). "P-complete approximation problems." *Journal of the ACM*, 23(3):555--565.

### Approximation and Parameterized Complexity

13. **Goemans, M.X., Williamson, D.P.** (1995). "Improved approximation algorithms for maximum cut and satisfiability problems using semidefinite programming." *Journal of the ACM*, 42(6):1115--1145.

14. **Cygan, M., Lokshtanov, D., Pilipczuk, M., Pilipczuk, M., Saurabh, S.** (2014/2019). "Minimum bisection is fixed parameter tractable." *SIAM Journal on Computing*, 48(2):417--450. [STOC 2014](https://dl.acm.org/doi/10.1145/2591796.2591852), [arXiv:1311.2563](https://arxiv.org/abs/1311.2563)

15. **Cygan, M., Nederlof, J., Pilipczuk, M., Pilipczuk, M., van Rooij, J., Wojtaszczyk, J.** (2011). "Solving connectivity problems parameterized by treewidth in single exponential time." *FOCS 2011*. [arXiv:1103.0534](https://arxiv.org/abs/1103.0534)

16. **Calinescu, G., Karloff, H., Rabani, Y.** (2000). "An improved approximation algorithm for multiway cut." *Journal of Computer and System Sciences*, 60(3):564--574. [ACM](https://dl.acm.org/doi/10.1145/276698.276711)

17. **Sharma, A., Vondrak, J.** (2014). "Multiway cut, pairwise realizable distributions, and descending thresholds." *STOC 2014*. [ResearchGate](https://www.researchgate.net/publication/260667787)

18. **Chlebik, M., Chlebikova, J.** (2006). "Approximation hardness of edge dominating set problems." *Journal of Combinatorial Optimization*, 11(3):279--290. [Springer](https://link.springer.com/article/10.1007/s10878-006-7908-0)

19. **De Klerk, E., Pasechnik, D.V., Warners, J.P.** (2004). "On approximate graph colouring and MAX-k-CUT algorithms based on the theta-function." *Journal of Combinatorial Optimization*, 8:267--294. [Springer](https://link.springer.com/article/10.1023/B:JOCO.0000038911.67280.3f)

20. **Krauthgamer, R., Naor, J., Schwartz, R.** (2009). "Partitioning graphs into balanced components." *SODA 2009*, pp. 942--949. [SIAM](https://epubs.siam.org/doi/10.1137/1.9781611973068.102)

21. **Burkard, R.E., Karisch, S.E., Rendl, F.** (1997). "QAPLIB -- A quadratic assignment problem library." *Journal of Global Optimization*, 10:391--403. [Springer](https://link.springer.com/article/10.1023/A:1008293323270)

22. **Angelidakis, H., Makarychev, Y., Manurangsi, P.** (2017). "An improved integrality gap for the Calinescu-Karloff-Rabani relaxation for multiway cut." [arXiv:1611.05530](https://arxiv.org/abs/1611.05530)

23. **Williams, R.** (2009). "Finding paths of length k in O*(2^k) time." *Information Processing Letters*, 109(6):315--318.

24. **Karger, D., Motwani, R., Ramkumar, G.D.S.** (1997). "On approximating the longest path in a graph." *Algorithmica*, 18(1):82--98.

25. **Salehi, O., Glos, A., Miszczak, J.A.** (2022). "QUBO formulations of the longest path problem." *Theoretical Computer Science*, 904:20--33. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S030439752100092X)

### Problem-Specific References

26. **Shannon, C.E.** (1949). "A theorem on coloring lines of a network." *J. Math. Phys.*, 28:148--151.

27. **Feige, U., Krauthgamer, R.** (2002). "A polylogarithmic approximation of the minimum bisection." *SIAM Review*, 48(1). [SIAM](https://epubs.siam.org/doi/10.1137/050640904)

28. **Bodlaender, H.L., Cygan, M., Kratsch, S., Nederlof, J.** (2015). "Deterministic single exponential time algorithms for connectivity problems parameterized by treewidth." *Information and Computation*, 243:86--111. [ScienceDirect](https://www.sciencedirect.com/science/article/pii/S0890540114001606)

29. **Demange, M., Ekim, T.** (2008). "Minimum maximal matching is NP-hard in regular bipartite graphs." *TAMC 2008*, LNCS 4978, pp. 364--375. [Springer](https://link.springer.com/chapter/10.1007/978-3-540-79228-4_32)

30. **Andreev, K., Racke, H.** (2006). "Balanced graph partitioning." *Theory of Computing Systems*, 39:929--939. [Springer](https://www.math.cmu.edu/~kandreev/kpart.pdf)
