# Research: Structural and Decision Diagram Problems for NP-Hard Problem Reductions

> Generated: 2026-02-27
> Scope: Treewidth, Pathwidth, MaxSAT, BDD Variable Ordering, Optimal Contraction Ordering, Minimum Width DD
> Context: Complexity theory research for `problem-reductions` Rust codebase — structural graph parameters and decision diagram problems forming a chain of equivalences

---

## Table of Contents

1. [Treewidth](#1-treewidth)
2. [Pathwidth](#2-pathwidth)
3. [Maximum Satisfiability (MaxSAT)](#3-maximum-satisfiability-maxsat)
4. [BDD Variable Ordering](#4-bdd-variable-ordering)
5. [Optimal Contraction Ordering (Tensor Networks)](#5-optimal-contraction-ordering-tensor-networks)
6. [Minimum Width Decision Diagram](#6-minimum-width-decision-diagram)
7. [The Treewidth-Pathwidth-BDD-Contraction Chain](#7-the-treewidth-pathwidth-bdd-contraction-chain)
8. [Implementation Strategy for problem-reductions](#8-implementation-strategy-for-problem-reductions)
9. [Master Reference List](#9-master-reference-list)

---

## 1. Treewidth

### 1.1 Formal Mathematical Definition

**Tree Decomposition.** Given an undirected graph G = (V, E), a *tree decomposition* of G is a pair (T, {B_t}_{t in V(T)}) where T is a tree and each node t of T is associated with a bag B_t subset V, satisfying:

1. **Vertex coverage:** For every vertex v in V, there exists at least one bag B_t containing v.
2. **Edge coverage:** For every edge {u, v} in E, there exists at least one bag B_t containing both u and v.
3. **Running intersection property (coherence):** For every vertex v in V, the set of nodes {t in V(T) : v in B_t} forms a connected subtree of T.

The **width** of a tree decomposition is max_{t in V(T)} |B_t| - 1.

The **treewidth** tw(G) of a graph G is the minimum width over all possible tree decompositions of G.

**Decision problem (TREEWIDTH).** Given an undirected graph G and an integer k, decide whether tw(G) <= k.

**Optimization problem.** Given G, find tw(G) and a corresponding optimal tree decomposition.

**Equivalent characterizations:**
- tw(G) = min_{H : H supergraph of G, H chordal} (omega(H) - 1), where omega denotes the clique number. This is the *minimum chordal completion* characterization (Gavril 1974, Rose 1970).
- tw(G) = min over all elimination orderings sigma of the maximum degree in the fill-in graph produced by the elimination game under sigma.
- tw(G) = min over all chordal supergraphs H of G of (omega(H) - 1).

### 1.2 Complexity Classification

**NP-completeness.** The decision problem "is tw(G) <= k?" is NP-complete (Arnborg, Corneil & Proskurowski 1987). Their paper "Complexity of finding embeddings in a k-tree" in *SIAM Journal on Algebraic Discrete Methods*, 8(2):277--284, established this via reduction from graph coloring. The original proof works for general graphs and also establishes NP-completeness on co-bipartite graphs.

**Refined hardness results:**
- NP-complete on graphs with maximum degree at most 9 (Bodlaender & Thilikos 1997).
- NP-complete on cubic graphs (maximum degree 3) (Bodlaender, Bonnet, Jaffke & Tiwary 2023, IPEC 2023 / Electronic Journal of Combinatorics 2025). This is the current tightest degree restriction known.
- NP-complete on bipartite graphs (follows by subdivision invariance of treewidth).
- **Open:** Whether Treewidth is NP-complete on planar graphs remains unresolved as of 2026.

**Membership in NP.** A tree decomposition of width k can be verified in polynomial time by checking the three properties above, and its width computed by inspecting bag sizes. Thus the decision problem is in NP.

### 1.3 History and Key Milestones

| Year | Milestone | Reference |
|------|-----------|-----------|
| 1970 | Rose introduces elimination orderings for chordal graphs | Rose 1970 |
| 1974 | Gavril characterizes chordal graphs as subtree intersection graphs | Gavril 1974 |
| 1976 | Halin introduces S-functions, an early form of tree decomposition | Halin 1976 |
| 1983 | Robertson & Seymour begin the Graph Minors series | Robertson & Seymour 1983 |
| 1986 | Robertson & Seymour (Graph Minors II) formally define treewidth and tree decomposition; prove algorithmic applications | Robertson & Seymour 1986 |
| 1987 | Arnborg et al. prove NP-completeness; give O(n^{k+2}) exact algorithm | Arnborg et al. 1987 |
| 1990 | Courcelle's theorem: every MSO2-definable property is decidable in linear time on bounded-treewidth graphs | Courcelle 1990 |
| 1993 | Bodlaender & Kloks give constructive O(2^{O(k^3)} * n) algorithm | Bodlaender & Kloks 1993 |
| 1996 | Bodlaender achieves FPT linear time: O(2^{O(k^3)} * n) | Bodlaender 1996 |
| 1997 | Bodlaender & Thilikos: NP-complete for degree <= 9 | Bodlaender & Thilikos 1997 |
| 2004 | Robertson & Seymour complete Graph Minors series (Theorem XX) | Robertson & Seymour 2004 |
| 2013 | Bodlaender et al.: 5-approximation in 2^{O(k)} * n time | Bodlaender et al. 2016 (SICOMP) |
| 2016 | PACE Challenge uses Treewidth as competition problem | PACE 2016 |
| 2017 | PACE 2017: Tamaki wins exact track with positive-instance-driven DP | Tamaki 2017 |
| 2022 | Korhonen: improved FPT to 2^{O(k^2)} * n^{O(1)} | Korhonen 2022 |
| 2023 | Bodlaender et al.: NP-complete on cubic graphs | Bodlaender et al. 2023 |

### 1.4 Approximation Algorithms

| Algorithm | Ratio | Time Complexity | Reference |
|-----------|-------|-----------------|-----------|
| Arnborg et al. exact | 1 (exact) | O(n^{k+2}) | Arnborg et al. 1987 |
| Robertson & Seymour | 4 | O(3^{3k} * n^2) | Robertson & Seymour 1995 |
| Lagergren | 8 | 2^{O(k log k)} * n log^2 n | Lagergren 1996 |
| Reed | 4-5 | 2^{O(k log k)} * n log n | Reed 1992 |
| Bodlaender et al. | 5 (ratio 5k+4) | 2^{O(k)} * n | Bodlaender et al. 2016 |
| Korhonen | 1+epsilon | k^{O(k/epsilon)} * n^{O(1)} | Korhonen 2022 |

**Inapproximability.** It is unknown whether a polynomial-time approximation scheme (PTAS) for treewidth exists. The problem is not known to be APX-hard.

### 1.5 Parameterized Complexity (FPT, W-Hierarchy)

**Fixed-parameter tractability.** Treewidth is **FPT** parameterized by k = tw(G):

- **Bodlaender 1996:** O(2^{O(k^3)} * n) deterministic linear-time algorithm for fixed k. The constant hidden in the O(k^3) is enormous, making this primarily of theoretical interest.
- **Korhonen 2022:** Improved to 2^{O(k^2)} * n^{O(1)}, the first improvement on the dependence on k since 1991.
- **5-approximation:** Bodlaender et al. 2016 give a 5-approximation in 2^{O(k)} * n time with single-exponential dependence on k.

**W-hierarchy.** Computing treewidth exactly is believed not to be in W[1] when parameterized by the treewidth itself (it is FPT), but the related problem of *tree-partition-width* is XALP-complete, which implies W[t]-hardness for all t. This illustrates that even slight variations on width parameters can jump dramatically in the parameterized hierarchy.

**Kernelization.** Treewidth has polynomial kernels when parameterized by treewidth: a graph of treewidth k has at most O(k * n) edges (any tree decomposition witnesses this), and the kernel size is O(k^3) vertices (Bodlaender et al. 2009).

### 1.6 Exact Algorithms and Practical Solvers

**Exact algorithms:**
- **Arnborg et al. 1987:** O(n^{k+2}) time, polynomial for fixed k but not FPT.
- **Bodlaender 1996:** O(2^{O(k^3)} * n) time. Theoretically linear in n, but the constant makes it impractical for k > 5.
- **Bouchitte & Todinca 2001:** O*(1.7549^n) using minimal separators and potential maximal cliques (PMCs). This is the basis of Tamaki's PACE-winning solver.
- **Tamaki 2017:** Positive-instance-driven dynamic programming, won the PACE 2017 exact treewidth track solving 199/200 instances. Won ESA 2017 Best Paper Award.

**Heuristic solvers:**
- **MinDegree / MinFillIn:** Greedy elimination ordering heuristics. MinDegree eliminates the minimum-degree vertex at each step; MinFillIn eliminates the vertex causing the fewest fill-in edges.
- **FlowCutter (Strasser 2017):** Uses nested dissection via balanced cuts found by maximum flow. Competitive heuristic in PACE 2017.
- **Jdrasil (Bannach, Berndt & Ehlers 2017):** Modular Java library incorporating SAT-based and DP-based methods for exact treewidth.

**PACE Challenge implementations** (available at https://github.com/PACE-challenge/Treewidth):
- The 2016 and 2017 PACE challenges produced a rich ecosystem of exact and heuristic treewidth solvers.
- Notable teams: Tamaki (Meiji University), Bodlaender & Van der Zanden (Utrecht), Strasser (KIT), Bannach/Berndt/Ehlers (Lubeck).

### 1.7 Known Reductions

| Source | Target | Type | Description |
|--------|--------|------|-------------|
| TREEWIDTH | Chordal Graph Completion | Equivalence | tw(G) = min omega(H) - 1 over chordal supergraphs H of G |
| TREEWIDTH | Bramble Order | Duality | tw(G) + 1 = maximum order of a bramble in G (Seymour & Thomas 1993) |
| Graph k-Coloring | TREEWIDTH | Reduction source | NP-completeness of treewidth proved via coloring (Arnborg et al. 1987) |
| TREEWIDTH | ILP | Reduction | Elimination ordering formulation: binary variables x_{ij} = 1 iff vertex i precedes j; O(n^3) constraints for transitivity + fill-in. Minimize the max clique in fill-in graph. |
| PATHWIDTH | TREEWIDTH | Relaxation | pw(G) >= tw(G); every path decomposition is a tree decomposition |
| Contraction Ordering | TREEWIDTH | Equivalence | Optimal max-width tensor contraction = treewidth of line graph (Markov & Shi 2008) |
| MINIMUM BISECTION | TREEWIDTH | Structural | tw(G) <= O(bisection_width(G) * log n) |
| Cutwidth | TREEWIDTH | Reduction source | NP-completeness of treewidth on cubic graphs proved via cutwidth (Bodlaender et al. 2023) |

### 1.8 QUBO/Ising and ILP Formulations

**ILP formulation (elimination ordering).**

Variables:
- Binary x_{ij} in {0, 1} for all i != j, i,j in V: x_{ij} = 1 iff vertex i is eliminated before vertex j.
- Binary f_{ij} in {0, 1} for pairs (i,j) not in E: f_{ij} = 1 iff the edge {i,j} becomes fill-in.
- Integer w >= 0: the treewidth.

Constraints:
- **Transitivity:** x_{ij} + x_{jk} - 1 <= x_{ik} for all distinct i, j, k (O(n^3) constraints).
- **Antisymmetry:** x_{ij} + x_{ji} = 1 for all i < j.
- **Fill-in:** If x_{ij} = 1, x_{ik} = 1, and {j,k} in E or f_{jk} = 1, then f_{jk} = 1 (this requires careful linearization).
- **Width bound:** For each vertex i, the number of neighbors in the fill-in graph that are eliminated after i is at most w.

Objective: minimize w.

This formulation has O(n^2) binary variables and O(n^3) constraints. In practice, the PEO-based ILP formulations have known structural limitations for producing tight LP relaxation lower bounds (as shown in recent work on PEO-based ILP weaknesses).

**QUBO formulation.** No standard QUBO formulation for treewidth exists in the literature. The permutation structure (like QAP) would require O(n^2) qubits with the standard assignment encoding x_{i,p} = 1 iff vertex i is at position p. The fill-in constraint introduces higher-order interactions that would need auxiliary variables for quadratization. This makes a direct QUBO encoding prohibitively large.

### 1.9 Structural Bounds

| Graph Class | Treewidth | Notes |
|-------------|-----------|-------|
| Trees | 1 | Minimum possible for connected graphs |
| Series-parallel graphs | <= 2 | K_4-minor-free |
| Outerplanar graphs | <= 2 | |
| Halin graphs | <= 3 | |
| n x n grid | n | Exact value |
| Planar graphs | O(sqrt(n)) | Planar separator theorem |
| Graphs of genus g | O(sqrt(g * n)) | |
| K_n (complete graph) | n - 1 | Maximum possible |
| Bounded-degree graphs | O(n / log n) | By separator theorem |

**Key inequalities:**
- tw(G) <= pw(G) for all G.
- tw(G) <= pw(G) <= tw(G) * O(log n) (Korach & Solel 1993).
- tw(G) <= cw(G) (cutwidth) for all G.
- tw(G) = 1 iff G is a forest.

### 1.10 BDD/Tensor Connection

This is a critical connection for the problem-reductions codebase:

- **MDD size bound:** The exact MDD representing a constraint set over a graph G has width at most 2^{tw(G)} when using AND/OR decomposition structures (Mateescu & Dechter 2007, Bergman et al. 2016).
- **Tensor contraction cost:** The computational cost of contracting a tensor network is bounded by O(T * 2^{tw+1}), where T is the number of gates/tensors and tw is the treewidth of the underlying graph (Markov & Shi 2008).
- **Dynamic programming:** Any MSO2-expressible problem on a graph of treewidth k can be solved in f(k) * n time by dynamic programming on a tree decomposition (Courcelle 1990).

### 1.11 Implementation Notes for problem-reductions

**Current codebase state:**
- `src/rules/unitdiskmapping/pathdecomposition.rs` already computes pathwidth using branch-and-bound (exact for n <= 30) and greedy heuristics.
- The `Layout` struct tracks vertex separation (equivalent to pathwidth).
- UnitDiskGraph -> GridGraph reduction uses pathwidth to determine grid height.

**Proposed model structure:**
```rust
struct Treewidth<G: GraphTrait> {
    graph: G,
    k: usize,  // target treewidth for decision version
}
// Problem: Satisfaction (does tw(G) <= k?)
// Metric: bool
// Variables: elimination ordering (permutation of |V| vertices)
// dims(): vec![|V|; |V|] — each position in ordering can be any vertex
```

**Reductions to implement:**
- `Treewidth -> ILP`: elimination ordering formulation
- `Pathwidth -> Treewidth`: trivial embedding (path decomposition is tree decomposition)

---

## 2. Pathwidth

### 2.1 Formal Mathematical Definition

**Path Decomposition.** Given an undirected graph G = (V, E), a *path decomposition* of G is a sequence (B_1, B_2, ..., B_m) of bags B_i subset V satisfying:

1. **Vertex coverage:** Every vertex v in V appears in at least one bag B_i.
2. **Edge coverage:** For every edge {u, v} in E, some bag B_i contains both u and v.
3. **Contiguity (running intersection on a path):** For every vertex v in V, the set of indices {i : v in B_i} forms a contiguous interval [l_v, r_v].

The **width** of a path decomposition is max_i |B_i| - 1.

The **pathwidth** pw(G) of a graph G is the minimum width over all possible path decompositions of G.

**Equivalently,** a path decomposition is a tree decomposition where the underlying tree T is a path.

**Decision problem (PATHWIDTH).** Given an undirected graph G and an integer k, decide whether pw(G) <= k.

### 2.2 Equivalent Formulations

Pathwidth is equivalent to several independently studied graph parameters. The precise quantitative relationship is:

**vs(G) = pw(G) = it(G) - 1 = sn(G) - 1 = gml(G)**

where:

1. **Vertex Separation Number (vs).** Given a linear ordering L = (v_1, v_2, ..., v_n) of V, the vertex separation at position i is:

   vs_L(i) = |{v_j : j <= i and there exists v_k with k > i such that {v_j, v_k} in E}|

   That is, vs_L(i) counts the number of vertices at or before position i that have at least one neighbor after position i. Then vs_L = max_i vs_L(i), and vs(G) = min_L vs_L. This was defined by Ellis, Sudborough & Turner (1983). Kinnersley (1992) proved vs(G) = pw(G).

2. **Node Search Number (sn).** The minimum number of searchers needed to clear all edges of G using the node-searching model (place searcher on vertex, remove searcher from vertex). Established equivalent by Kirousis & Papadimitriou (1985, 1986): sn(G) = pw(G) + 1.

3. **Interval Thickness (it).** The minimum clique number omega(H) over all interval supergraphs H of G. Equivalently, the minimum number of colors in an interval coloring extending G. Kirousis & Papadimitriou (1985) showed it(G) = pw(G) + 1.

4. **Gate Matrix Layout (gml).** The minimum number of columns in a gate matrix layout of G. Kinnersley & Langston (1994) showed gml(G) = pw(G).

These equivalences were unified by Fellows & Langston (1994), Kinnersley (1992), and Kirousis & Papadimitriou (1986).

### 2.3 Complexity Classification

**NP-completeness.** The decision problem "is pw(G) <= k?" is NP-complete. This was originally established through the vertex separation number formulation:

- **General graphs:** Lengauer (1981), via reduction from NP-complete layout problems.
- **Planar graphs of max degree 3:** Monien & Sudborough (1988).
- **Chordal graphs:** Gustedt (1993).
- **Bipartite graphs:** Goldberg et al. (1995).
- **Grid graphs and unit disk graphs:** Diaz et al. (2001).

Since pathwidth is NP-complete already for cubic (3-regular) graphs (via Monien & Sudborough), and treewidth on cubic graphs was only shown NP-complete in 2023, pathwidth has a longer history of strong hardness results on restricted graph classes.

### 2.4 History and Key Milestones

| Year | Milestone | Reference |
|------|-----------|-----------|
| 1981 | Lengauer proves vertex separation is NP-complete | Lengauer 1981 |
| 1983 | Robertson & Seymour introduce pathwidth (Graph Minors I) | Robertson & Seymour 1983 |
| 1983 | Ellis, Sudborough & Turner define vertex separation number | Ellis et al. 1983 |
| 1985 | Kirousis & Papadimitriou: node search number = interval thickness | Kirousis & Papadimitriou 1985 |
| 1988 | Monien & Sudborough: NP-complete for planar degree-3 graphs | Monien & Sudborough 1988 |
| 1992 | Kinnersley proves vs(G) = pw(G) | Kinnersley 1992 |
| 1993 | Korach & Solel: pw <= tw * O(log n) | Korach & Solel 1993 |
| 1994 | Fellows & Langston: unified equivalence of all formulations | Fellows & Langston 1994 |
| 2014 | Coudert, Mazauric & Nisse: practical branch-and-bound for pathwidth | Coudert et al. 2014 |

### 2.5 Approximation Algorithms

| Algorithm | Ratio | Time | Reference |
|-----------|-------|------|-----------|
| Greedy (MinDegree on path) | O(log n) | O(n^2) | folklore |
| Bodlaender via treewidth | O(log n) (via pw <= tw * O(log n)) | 2^{O(tw)} * n | indirect |
| Exact DP on vertex orderings | 1 (exact) | O*(2^n) | various |

**Exact algorithms:**
- Best known exact algorithm: O*(2^n) using dynamic programming over subsets of vertices (Bodlaender & Kloks 1996, Coudert et al. 2014).
- The codebase's existing branch-and-bound (`MinhThiTrick` in `pathdecomposition.rs`) is based on Coudert et al. (2014), which uses upper/lower bound pruning to achieve practical performance on graphs with up to ~30 vertices.

### 2.6 Parameterized Complexity

**FPT.** Pathwidth is FPT parameterized by k = pw(G):
- Bodlaender's 1996 algorithm also handles pathwidth (as a special case of treewidth) in O(2^{O(k^3)} * n) time.
- For pathwidth specifically, Ellis et al. (1983) gave an O(n^{k+1}) algorithm.
- The FPT algorithms for treewidth apply since pw(G) >= tw(G), and a tree decomposition of width k gives a path decomposition of width at most O(k * log n).

**Obstruction sets.** By the Graph Minor Theorem (Robertson & Seymour), for each fixed k, the set of minor-minimal graphs of pathwidth > k is finite. These form the forbidden minor characterization. However, the obstruction sets are only known explicitly for small k:
- pw(G) <= 1 iff G is a forest of caterpillars (forbidden minor: K_3 with pendant edge).
- pw(G) <= 2: 110 forbidden minors.

### 2.7 Known Reductions

| Source | Target | Type | Description |
|--------|--------|------|-------------|
| PATHWIDTH | TREEWIDTH | Relaxation | pw(G) >= tw(G); path decomposition is tree decomposition |
| PATHWIDTH | Interval Graph Completion | Equivalence | pw(G) = min omega(H) - 1 over interval supergraphs H of G |
| PATHWIDTH | Vertex Separation | Equivalence | vs(G) = pw(G) (Kinnersley 1992) |
| PATHWIDTH | Node Search Number | Equivalence | sn(G) = pw(G) + 1 (Kirousis & Papadimitriou 1986) |
| PATHWIDTH | Min Width DD | Equivalence | Min exact MDD width = pw(G) + 1 for constraint graph G |
| PATHWIDTH | BDD Variable Ordering | Structural | BDD size <= 2^{pw} for variable interaction graph of pw |
| PATHWIDTH | ILP | Reduction | Linear ordering variables x_{ij} + separation counting constraints |

### 2.8 Structural Bounds

| Graph Class | Pathwidth | Treewidth for Comparison |
|-------------|-----------|--------------------------|
| Paths P_n | 1 | 1 |
| Cycles C_n | 2 | 2 |
| Binary trees (n nodes) | floor(log_2 n) | 1 |
| Caterpillars | 1 | 1 |
| n x n grids | n | n |
| Planar graphs | O(sqrt(n)) | O(sqrt(n)) |
| K_n | n - 1 | n - 1 |
| Outerplanar | O(log n) | <= 2 |

**The key gap:** For balanced binary trees, tw = 1 but pw = Theta(log n). This is the canonical example demonstrating that pathwidth can be logarithmically larger than treewidth, and this gap is tight: pw(G) <= tw(G) * O(log n) in general.

### 2.9 BDD Connection

The connection between pathwidth and BDD size is one of the deepest structural results in the theory of decision diagrams:

**Theorem (BDD Size Bound).** Let f be a Boolean function whose variable interaction graph (primal graph) has pathwidth pw. Then for any variable ordering consistent with a minimum-width path decomposition, the ROBDD for f has at most O(n * 2^{pw}) nodes. Conversely, any ROBDD for f requires at least 2^{Omega(pw)} nodes for some functions.

More precisely (Amarilli et al.):
- A circuit of pathwidth <= k can be converted to an OBDD of width <= 2^{(k+2) * 2^{k+2}}.
- For monotone CNF/DNF, the minimum OBDD width is Theta(2^{pw}).

This establishes that OBDD width and pathwidth are in a **tight singly-exponential relationship** for structured Boolean functions.

### 2.10 ILP Formulation

**Linear ordering ILP for pathwidth/vertex separation:**

Variables:
- Binary x_{ij} in {0, 1} for all i != j: x_{ij} = 1 iff vertex i precedes vertex j in the linear ordering.
- Integer s >= 0: the maximum vertex separation (= pathwidth).

Constraints:
- **Transitivity:** x_{ij} + x_{jk} - 1 <= x_{ik} for all distinct i, j, k.
- **Antisymmetry:** x_{ij} + x_{ji} = 1 for all i < j.
- **Separation bound:** For each vertex i and each neighbor j of i: if x_{ij} = 1 (i before j), then vertex i contributes to the separation at position pi(i). The constraint is:
  For each vertex v: sum over neighbors u of v where x_{vu} = 1 (v before u, u still active) is counted as 1 toward the separation. Formally, for each vertex v: sum_{u : {v,u} in E} z_{vu} <= s, where z_{vu} in {0,1} and z_{vu} >= x_{vu} - sum_{w : {u,w} in E, w != v} x_{uw} (an indicator that u is still "active" when v is placed).

A cleaner formulation from the GRAFO group (linear ordering-based MIP):
- For each vertex v, define sep(v) = |{u : u is placed before v, and u has a neighbor placed at or after v}|.
- Constraint: sep(v) <= s for all v.
- This yields O(n^2) binary variables and O(n^3) constraints, similar to the treewidth ILP but with simpler structure.

### 2.11 Implementation Notes for problem-reductions

**Current codebase state:**
- `src/rules/unitdiskmapping/pathdecomposition.rs` — fully functional pathwidth computation.
- Three methods: `Auto` (exact for n <= 30, greedy otherwise), `Greedy` (random restarts), `MinhThiTrick` (branch-and-bound).
- The `Layout` struct directly implements the vertex separation formulation.
- Used in the UnitDiskGraph -> GridGraph reduction pipeline.

**Formalizing as a Problem model** would expose this existing infrastructure as a first-class NP-hard problem in the reduction network, enabling:
- `Pathwidth -> Treewidth` reduction
- `Pathwidth -> ILP` reduction
- Connection to BDD Variable Ordering and MinWidthDD

---

## 3. Maximum Satisfiability (MaxSAT)

### 3.1 Formal Mathematical Definition

**MAX-SAT.** Given a Boolean formula phi in conjunctive normal form (CNF) with variables x_1, ..., x_n and clauses C_1, ..., C_m, find a truth assignment tau: {x_1, ..., x_n} -> {0, 1} that maximizes the number of satisfied clauses.

**Weighted MAX-SAT.** Each clause C_j has an associated positive weight w_j. The objective is to maximize sum_{j : C_j satisfied by tau} w_j.

**Partial MAX-SAT.** Clauses are partitioned into *hard* clauses (must be satisfied; w_j = infinity) and *soft* clauses (maximize total weight of satisfied soft clauses subject to all hard clauses being satisfied).

**MAX-k-SAT.** Each clause has at most k literals.

**Decision version.** Given a CNF formula phi, weights w_j, and a target W, is there an assignment satisfying clauses of total weight >= W?

### 3.2 Complexity Classification

**NP-hardness.** MAX-SAT is NP-hard since SAT reduces to it: a formula is satisfiable iff the optimal MAX-SAT value equals m (all clauses satisfied).

**APX-completeness.** MAX-SAT is APX-complete — it admits a constant-factor approximation but no PTAS unless P = NP (Papadimitriou & Yannakakis 1991).

**Inapproximability results (Hastad 2001):**
- **MAX-3-SAT:** For every k >= 3, it is NP-hard to approximate MAX-Ek-SAT within a factor better than 1 - 1/2^k. For MAX-3-SAT specifically, the random assignment achieves a 7/8-approximation, and Hastad proved this is **optimal** — no polynomial-time algorithm can achieve ratio better than 7/8 unless P = NP.
- **MAX-2-SAT:** NP-hard to approximate within 22/21 (approximately 1.047).

These results are proved via Probabilistically Checkable Proofs (PCPs) and the PCP Theorem.

### 3.3 History and Key Milestones

| Year | Milestone | Reference |
|------|-----------|-----------|
| 1974 | Johnson: greedy 2/3-approximation for MAX-SAT | Johnson 1974 |
| 1976 | Johnson: randomized 3/4-approximation for MAX-SAT | Johnson 1974 |
| 1994 | Goemans & Williamson: SDP-based 0.878 for MAX-CUT | Goemans & Williamson 1994 |
| 1995 | Goemans & Williamson: 0.931-approximation for MAX-2-SAT | Goemans & Williamson 1995 |
| 2001 | Hastad: 7/8 is optimal for MAX-3-SAT (PCP-based proof) | Hastad 2001 |
| 2002 | Lewin, Livnat & Zwick: 0.9401-approximation for MAX-2-SAT | Lewin et al. 2002 |
| 2006 | First annual MaxSAT Evaluation (ongoing since then) | MaxSAT Evaluations |
| 2007 | Austrin: 0.9401 is optimal for MAX-2-SAT under UGC | Austrin 2007 |

### 3.4 Approximation Algorithms

| Problem | Best Ratio | Method | Reference |
|---------|-----------|--------|-----------|
| MAX-SAT | 3/4 | Randomized rounding | Johnson 1974 |
| MAX-SAT | 3/4 | LP relaxation + rounding | Goemans & Williamson 1994 |
| MAX-2-SAT | 0.9401 | SDP + skewed hyperplane rounding | Lewin, Livnat & Zwick 2002 |
| MAX-3-SAT | 7/8 | Random assignment (optimal!) | Hastad 2001 |
| MAX-E3-SAT | 7/8 | Derandomized via conditional expectations | Hastad 2001 |
| Weighted MAX-SAT | 3/4 | Combining LP rounding + random | Poloczek & Schnitger 2011 |

**The 3/4 barrier.** For general MAX-SAT, the best known polynomial-time algorithm achieves ratio 3/4. This is obtained by taking the better of: (1) randomized rounding of the LP relaxation, and (2) random assignment. The ratio 3/4 is conjectured to be optimal for general MAX-SAT.

**SDP approach for MAX-2-SAT.** Lewin, Livnat & Zwick (2002) achieve ratio beta_LLZ = 0.9401656724... by:
1. Solving an SDP relaxation.
2. Applying a rotation to the SDP solution vectors (following Feige-Goemans).
3. Rounding using random hyperplanes drawn from a skewed distribution.

Under the Unique Games Conjecture, this ratio is optimal (Austrin 2007).

### 3.5 Parameterized Complexity

- **Above-guarantee parameterization:** MAX-SAT parameterized by the number of clauses satisfied above m/2 (the random assignment guarantee) is FPT (Mahajan & Raman 1999).
- **Below-optimum:** Parameterized by the number of unsatisfied clauses is W[1]-hard for MAX-3-SAT.
- **On bounded-treewidth formulas:** MAX-SAT on formulas whose incidence graph has treewidth k can be solved in O(2^k * m) time by dynamic programming on a tree decomposition.

### 3.6 Exact Algorithms and Practical Solvers

**Exact algorithms:**
- **Branch-and-bound:** MaxSolver (Xing & Zhang 2005) uses unit propagation, failed literal detection, and inference rules.
- **SAT-based approaches:** Convert MAX-SAT to a sequence of SAT calls using binary search or iterative SAT-UNSAT.
- **Core-guided:** RC2, Open-WBO extract unsatisfiable cores and use them to derive new soft clauses.

**Annual MaxSAT Evaluation.** Running since 2006, this competition benchmarks MaxSAT solvers on:
- Unweighted / Weighted
- Partial / Full (with/without hard clauses)
- Complete / Incomplete (exact vs. heuristic)

Leading solvers as of 2025: MaxHS (Davies & Bacchus), RC2 (Ignatiev et al.), CASHWMaxSAT, Pacose.

### 3.7 Known Reductions

| Source | Target | Type | Description |
|--------|--------|------|-------------|
| SAT | MAX-SAT | Embedding | Set all weights = 1; satisfiable iff optimal = m |
| MAX-SAT | SAT | Decision version | Is there assignment satisfying weight >= W? Encode as SAT with auxiliary variables |
| MAX-SAT | QUBO | Direct | Each clause contributes a penalty; auxiliary variables for k >= 3 |
| MAX-SAT | ILP | Standard | Binary x_i per variable; y_j indicator per clause; maximize sum w_j * y_j |
| MAX-2-SAT | MAX-CUT | Known | Gadget reduction preserving approximation ratios |
| MAX-CUT | MAX-2-SAT | Known | Each edge becomes a 2-clause |
| Satisfiability (existing) | MAX-SAT | Trivial | All weights 1 |
| MAX-SAT | SpinGlass | Known | Via QUBO/Ising connection |

### 3.8 QUBO Formulation

The MAX-SAT to QUBO reduction is a cornerstone of quantum annealing approaches.

**For MAX-2-SAT (clauses with <= 2 literals):**

Each 2-clause can be directly encoded as a quadratic penalty. For a clause (x_i OR x_j):
- Penalty: (1 - x_i)(1 - x_j) = 1 - x_i - x_j + x_i * x_j
- This equals 1 iff x_i = x_j = 0 (clause unsatisfied), and 0 otherwise.

For a clause (x_i OR NOT x_j):
- Penalty: (1 - x_i) * x_j = x_j - x_i * x_j

The QUBO objective is: minimize sum_j w_j * penalty(C_j), where each penalty is quadratic in the binary variables.

**For MAX-3-SAT (clauses with 3 literals):**

A 3-literal clause like (x_i OR x_j OR x_k) has penalty (1 - x_i)(1 - x_j)(1 - x_k), which is **cubic**. Quadratization requires an auxiliary variable y per clause:

Replace (1 - x_i)(1 - x_j)(1 - x_k) with a quadratic expression using y:
- Introduce y_{ijk} and add penalty P * (x_i * x_j - 2 * x_i * y_{ijk} - 2 * x_j * y_{ijk} + 3 * y_{ijk})
where P is a sufficiently large penalty weight ensuring y_{ijk} = x_i * x_j at optimum.

**Size:** For a MAX-SAT instance with n variables and m clauses:
- MAX-2-SAT: n QUBO variables, O(m) quadratic terms.
- MAX-3-SAT: n + m_3 QUBO variables (one auxiliary per 3-clause), O(m) quadratic terms.
- General MAX-k-SAT: requires O(m * k) auxiliary variables via recursive quadratization.

### 3.9 ILP Formulation

Variables:
- x_i in {0, 1} for i = 1, ..., n: truth assignment of variable i.
- y_j in {0, 1} for j = 1, ..., m: indicator that clause C_j is satisfied.

Constraints:
- For each clause C_j = (l_1 OR l_2 OR ... OR l_r), where each literal l_i is either x_i or (1 - x_i):
  - sum_{i in S_j^+} x_i + sum_{i in S_j^-} (1 - x_i) >= y_j
  where S_j^+ is the set of variables appearing positively in C_j and S_j^- is the set appearing negated.

Objective: maximize sum_{j=1}^{m} w_j * y_j.

This formulation has n + m binary variables and m constraints (plus variable bounds). The LP relaxation gives a 3/4-approximation via randomized rounding.

### 3.10 Implementation Notes for problem-reductions

**Connection to existing codebase:**
- The codebase already has `Satisfiability` and `KSatisfiability` models with clause infrastructure.
- MaxSAT reuses the CNF clause representation, adding weights.
- The existing `Satisfiability -> QUBO` reduction path can be extended.

**Proposed model:**
```rust
struct MaxSAT<W: WeightElement> {
    num_variables: usize,
    clauses: Vec<Vec<i32>>,  // signed literals, like existing SAT
    weights: Vec<W>,          // weight per clause
}
// Problem: Optimization (Maximize)
// Metric: SolutionSize<W::Sum>
// dims(): vec![2; num_variables]
```

**Reductions to implement:**
- `Satisfiability -> MaxSAT` (all weights 1)
- `MaxSAT -> QUBO` (penalty per unsatisfied clause)
- `MaxSAT -> ILP` (clause indicator variables)

---

## 4. BDD Variable Ordering

### 4.1 Formal Mathematical Definition

**Reduced Ordered Binary Decision Diagram (ROBDD).** Given a Boolean function f: {0,1}^n -> {0,1} and a variable ordering pi: {x_1, ..., x_n} -> {1, ..., n} (a permutation), the ROBDD(f, pi) is a directed acyclic graph where:
- There are two terminal nodes (labeled 0 and 1).
- Each non-terminal node is labeled with a variable x_i and has two children (low and high).
- Variables appear in order consistent with pi along every root-to-terminal path.
- No two distinct nodes represent the same Boolean function (maximally reduced).

**Canonicity theorem (Bryant 1986).** For any Boolean function f and variable ordering pi, the ROBDD(f, pi) is unique up to isomorphism and is the smallest OBDD for f under ordering pi.

**BDD Variable Ordering Problem (OBDD-MINIMIZATION).** Given a Boolean function f (represented as a truth table, circuit, or BDD) and an integer k, does there exist a variable ordering pi such that |ROBDD(f, pi)| <= k nodes?

**Optimization version.** Find the ordering pi minimizing |ROBDD(f, pi)|.

### 4.2 Complexity Classification

**NP-completeness.** Bollig & Wegener (1996), "Improving the variable ordering of OBDDs is NP-complete," *IEEE Transactions on Computers*, 45(9):993--1002. The proof reduces from 3-SAT.

More precisely, given an OBDD G representing f and a size bound s, deciding whether there exists an OBDD G* (under any variable ordering) for f with at most s nodes is NP-complete.

**Inapproximability.** For any constant c > 1, it is NP-hard to compute a variable ordering resulting in an OBDD with size at most c times the optimal size (Sieling 2002). This means OBDD-MINIMIZATION has **no polynomial-time constant-factor approximation** unless P = NP.

**Hardness for shared BDDs.** The complexity of the optimal variable ordering problem for shared BDDs (multiple functions sharing the same ordering) is also NP-complete (Tani, Hamaguchi & Yajima 1993).

### 4.3 History and Key Milestones

| Year | Milestone | Reference |
|------|-----------|-----------|
| 1959 | Lee introduces binary decision programs | Lee 1959 |
| 1978 | Akers: BDD representation for Boolean functions | Akers 1978 |
| 1986 | Bryant: ROBDD canonical form, ITE algorithm | Bryant 1986 |
| 1987 | Friedman & Supowit: first exact algorithm O(n^2 * 3^n) | Friedman & Supowit 1987/1990 |
| 1993 | Rudell: sifting algorithm for dynamic variable reordering | Rudell 1993 |
| 1993 | Minato: Zero-Suppressed BDDs (ZDDs) | Minato 1993 |
| 1993 | Tani et al.: shared BDD ordering is NP-complete | Tani et al. 1993 |
| 1996 | Bollig & Wegener: OBDD minimization is NP-complete | Bollig & Wegener 1996 |
| 2002 | Sieling: no constant-factor approximation unless P=NP | Sieling 2002 |

### 4.4 The Exponential Ordering Sensitivity

**Classic example (Bryant 1986).** The function f(x_1, ..., x_{2n}) = x_1 x_2 + x_3 x_4 + ... + x_{2n-1} x_{2n} (sum of products of adjacent variable pairs):
- Ordering (x_1, x_2, x_3, x_4, ..., x_{2n-1}, x_{2n}): ROBDD has O(n) nodes (linear).
- Ordering (x_1, x_3, x_5, ..., x_{2n-1}, x_2, x_4, ..., x_{2n}): ROBDD has 2^n nodes (exponential).

**General worst case.** The integer multiplication function requires exponential ROBDD size under **any** variable ordering (Bryant 1991). This is fundamentally different from the ordering-sensitive case above.

**Symmetric functions.** Symmetric Boolean functions (those depending only on the Hamming weight of the input) have ROBDD size O(n^2) under **any** variable ordering. Thus the ordering problem is trivial for symmetric functions.

### 4.5 Approximation Algorithms (Heuristics)

Since the problem is NP-hard and inapproximable within any constant, practical approaches rely on heuristics:

**Static ordering heuristics (applied once before BDD construction):**
- **DFS/BFS ordering:** Traverse the circuit graph and order variables by visit time.
- **FANIN ordering:** Order by reverse topological sort of the circuit.
- **Weighted ordering:** Use heuristic scores based on variable interactions.

**Dynamic ordering heuristics (applied during BDD operations):**
- **Sifting (Rudell 1993):** The most widely used algorithm. For each variable, try all positions by adjacent swaps, keeping the best. Key properties:
  - Each variable sweep takes O(n * |BDD|) time (since each adjacent swap affects only one BDD layer).
  - Typically reduces BDD size by 2-10x.
  - Can be triggered automatically when BDD size exceeds a threshold.
  - Rudell's original heuristic: process variables in order of decreasing number of nodes.
- **Window permutation:** Try all permutations within a sliding window of w consecutive variables. Exact within the window, O(w! * n/w) swaps.
- **Group sifting:** Sift groups of related variables together.
- **Simulated annealing:** Random swaps accepted with Boltzmann probability.
- **Genetic algorithms:** Population of orderings evolved with crossover and mutation.

**Exact algorithms:**
- **Friedman & Supowit (1987/1990):** O(n^2 * 3^n) dynamic programming. For n variables, enumerate all subsets S of variables; for each S, record the minimum BDD size when the variables in S are placed first. The recurrence builds up from smaller subsets. This remains the basis for most exact methods.
- **Ishiura et al. improvement:** Avoids explicit table construction, reducing practical memory usage.
- **Quantum algorithm (2019):** O*(2.77^n) time and space, improving the classical 3^n bound using quantum walks.

### 4.6 Parameterized Complexity

- The problem parameterized by the target BDD size k is unlikely to be FPT, as BDD size can vary exponentially.
- Parameterized by the number of variables n, exact computation takes O*(3^n) time (Friedman & Supowit).
- For BDDs of bounded width w, the ordering problem can be solved more efficiently, but the width itself depends on the ordering.

### 4.7 Known Reductions

| Source | Target | Type | Description |
|--------|--------|------|-------------|
| 3-SAT | BDD Variable Ordering | NP-completeness proof | Bollig & Wegener 1996 |
| BDD Variable Ordering | Minimum Linear Arrangement | Related | Both involve optimal vertex ordering on interaction graph |
| BDD Variable Ordering | Minimum Bandwidth | Related | BDD width relates to bandwidth of interaction graph |
| BDD Variable Ordering | Pathwidth | Structural | BDD size <= 2^{pw} of variable interaction graph |
| BDD Variable Ordering | MinWidthDD | Specialization | BDD is binary case of MDD; ROBDD size relates to MDD width |
| BDD Variable Ordering | ILP | Reduction | Permutation matrix encoding (like QAP) |

### 4.8 Connection to Pathwidth

This is the critical theoretical link:

**Variable Interaction Graph.** Given a Boolean function f over variables x_1, ..., x_n, the variable interaction graph G_f has vertex set {x_1, ..., x_n} and edge {x_i, x_j} iff there exist assignments differing only in x_i and x_j that change the function value.

For a CNF formula, the variable interaction graph (also called the primal graph) has an edge between x_i and x_j iff they appear together in some clause.

**Theorem.** For any Boolean function f with variable interaction graph G_f:
- min_pi |ROBDD(f, pi)| <= n * 2^{pw(G_f)}
where pw(G_f) is the pathwidth of G_f.

**Intuition.** The pathwidth of G_f controls the maximum "active set" of variables at any layer of the BDD — variables that have been seen but whose influence has not yet been fully resolved. The BDD width at any layer is at most 2^{active set size}, and the pathwidth is the minimum over all orderings of the maximum active set size.

This means:
- Finding the optimal BDD variable ordering is at least as hard as computing pathwidth (since pathwidth gives a lower bound on BDD size).
- Conversely, a good path decomposition yields a good BDD variable ordering.
- The meta-problem "optimize the problem-solving tool (BDD)" reduces structurally to the NP-hard problem of computing pathwidth.

### 4.9 Implementation Notes for problem-reductions

**Proposed model:**
```rust
struct BDDVariableOrdering {
    truth_table: Vec<bool>,   // 2^n entries
    num_variables: usize,
    target_size: usize,       // k
}
// Problem: Satisfaction (does ordering with <= k nodes exist?)
// Metric: bool
// Variables: permutation of n variables
// dims(): vec![n; n]
```

**Key challenge:** The evaluate() function must build an ROBDD from the truth table under a given ordering — this requires implementing Bryant's reduction algorithm. The truth table representation limits practical instance sizes to n <= ~20.

---

## 5. Optimal Contraction Ordering (Tensor Networks)

### 5.1 Formal Mathematical Definition

**Tensor Network.** A tensor network is a collection of tensors T_1, T_2, ..., T_m with shared indices. It is represented as a hypergraph H = (V, E) where:
- Each vertex v in V corresponds to a tensor T_v.
- Each hyperedge e in E corresponds to a shared index (bond) with dimension d_e.
- The value of the tensor network is obtained by summing over all shared indices (contraction).

**Contraction Ordering Problem.** A contraction ordering is a binary tree (contraction tree) whose leaves are the individual tensors and each internal node represents a pairwise contraction. The cost of a contraction at node t is the product of the dimensions of all indices incident to the two subtensors being contracted.

**Two objectives:**
1. **Total cost (FLOP count):** Minimize the sum of costs over all contractions. This determines the total computation time.
2. **Maximum intermediate size (space complexity):** Minimize the maximum size of any intermediate tensor. This determines the peak memory requirement.

**Decision problem.** Given a tensor network H with dimension labels and an integer C, does there exist a contraction ordering with total cost (or max intermediate size) at most C?

### 5.2 Complexity Classification

**NP-hardness.** The contraction ordering problem is NP-hard for both the total cost and maximum intermediate size objectives. This follows from the connection to treewidth:

**Theorem (Markov & Shi 2008).** The minimum max-intermediate-size contraction of a tensor network corresponds to the treewidth of the line graph of the tensor network's hypergraph. Specifically, the optimal contraction width (log_2 of the maximum intermediate tensor size) equals the treewidth of the line graph.

Since treewidth is NP-complete (Arnborg et al. 1987), optimal contraction ordering (for the max-width objective) is NP-hard.

**Special case: Matrix Chain Multiplication.** When the tensor network forms a path (chain), the contraction ordering problem reduces to the classical matrix chain multiplication problem, solvable in O(n^3) time by dynamic programming (Godbole 1973). The NP-hardness arises from the general structure (arbitrary hypergraphs), not from the chain case.

### 5.3 History and Key Milestones

| Year | Milestone | Reference |
|------|-----------|-----------|
| 1973 | Godbole: O(n^3) DP for matrix chain multiplication | Godbole 1973 |
| 1992 | White: density matrix renormalization group (DMRG) for 1D tensor networks | White 1992 |
| 2005 | Markov & Shi: tensor contraction for quantum circuit simulation, treewidth connection | Markov & Shi 2005/2008 |
| 2014 | Pfeifer et al.: enhanced pruning for exact contraction sequences | Pfeifer et al. 2014 |
| 2018 | Google Sycamore: contraction ordering critical for quantum supremacy claims | Arute et al. 2019 |
| 2021 | Gray & Kourtis: hyper-optimized contraction with cotengra, >10000x speedup | Gray & Kourtis 2021 |
| 2024 | Staudt: improved cut strategies for contraction via hypergraph partitioning | Staudt 2024 |

### 5.4 Approximation Algorithms

Since optimal contraction ordering is NP-hard, practical approaches use heuristics:

| Method | Description | Quality | Reference |
|--------|-------------|---------|-----------|
| Greedy | Contract cheapest pair first | Often poor (arbitrarily bad) | folklore |
| Community detection | Partition into communities, contract within | Good for clustered networks | Gray & Kourtis 2021 |
| KaHyPar partitioning | Recursive balanced hypergraph partitioning | Near-optimal for many cases | Gray & Kourtis 2021 |
| Simulated annealing | Random tree modifications with cooling | Very good but slow | Gray & Kourtis 2021 |
| Random greedy + hyper-optimization | Random trials with Bayesian hyperparameter tuning | State of the art | Gray & Kourtis 2021 |

**cotengra (Gray & Kourtis 2021).** The state-of-the-art software package for finding contraction orderings. Key features:
- Hyper-optimization: tunes both the method and its parameters using random, Nevergrad, or Optuna optimizers.
- Hypergraph partitioning via KaHyPar.
- Greedy algorithms with random restarts.
- Achieved >10,000x speedup over established methods for Google Sycamore circuits.
- Open source: https://github.com/jcmgray/cotengra

### 5.5 Parameterized Complexity

- **Max-width objective:** Since this equals treewidth of the line graph, it inherits all FPT results for treewidth. The problem is FPT parameterized by the contraction width k, solvable in O(2^{O(k^3)} * m) time.
- **Total cost objective:** Strictly harder than max-width. Not known to be FPT under standard parameterizations.
- **Path-like contractions:** When restricted to left-to-right (caterpillar) contraction trees, the problem becomes equivalent to pathwidth of the line graph.

### 5.6 Exact Algorithms

- **Brute-force:** Enumerate all (2m-3)!! = (2m-3)(2m-5)...3*1 binary trees on m tensors. Prohibitive for m > ~15.
- **Dynamic programming over subsets:** O*(3^m) time, analogous to Friedman-Supowit for BDDs (enumerate subsets, build optimal subtrees).
- **Branch-and-bound:** Pfeifer et al. (2014) use enhanced pruning with lower bounds to solve instances with up to ~40 tensors exactly.
- **Treewidth solvers:** For the max-width objective, any exact treewidth solver (e.g., Tamaki's PACE solver) applied to the line graph gives the optimal contraction width.

### 5.7 Known Reductions

| Source | Target | Type | Description |
|--------|--------|------|-------------|
| TREEWIDTH (line graph) | Contraction Ordering (max-width) | Equivalence | tw(L(H)) = optimal contraction width (Markov & Shi 2008) |
| Contraction Ordering | TREEWIDTH | Equivalence (reverse) | Any tensor network defines a line graph whose treewidth = contraction width |
| Matrix Chain Multiplication | Contraction Ordering | Special case | Path hypergraph; polynomial (Godbole 1973) |
| Contraction Ordering | ILP | Reduction | Ordering variables + cost tracking constraints |
| Contraction Ordering | Pathwidth (line graph) | Relaxation | Path-like (caterpillar) contractions have cost = 2^{pw(L(H))} |
| #SAT | Contraction Ordering | Application | Counting satisfying assignments reduces to tensor network contraction |

### 5.8 Applications

1. **Quantum circuit simulation.** Classical simulation of quantum circuits with T gates on a graph of treewidth d runs in O(T^{O(1)} * 2^{O(d)}) time (Markov & Shi 2008). This is polynomial in T when d = O(log T).

2. **#SAT (counting satisfying assignments).** Any SAT formula can be encoded as a tensor network whose contraction gives the count of satisfying assignments. The contraction cost depends on the treewidth of the formula's incidence graph.

3. **Bayesian inference.** Exact inference in Bayesian networks by variable elimination has cost exponential in the treewidth of the moral graph — identical to tensor contraction.

4. **Statistical mechanics.** Partition function computation for Ising/Potts models is equivalent to tensor network contraction.

### 5.9 QUBO/ILP Formulations

**ILP formulation.** The contraction ordering problem can be formulated as an ILP by encoding the elimination ordering on the line graph (for the max-width objective), identical to the treewidth ILP. For the total cost objective, additional constraints track the cost of each contraction step.

**QUBO formulation.** As with treewidth, the permutation structure makes a direct QUBO encoding impractical. One would need O(m^2) qubits for the ordering plus auxiliary variables for cost computation.

### 5.10 Implementation Notes for problem-reductions

**Codebase connections:**
- GenericTensorNetworks.jl (companion Julia package) uses contraction ordering as its core subroutine.
- The existing `HyperGraph` in the codebase is for set problems, not tensor networks — a new `TensorNetwork` structure would be needed.
- For the max-width objective, implementation reduces to treewidth on the line graph.

**Proposed model:**
```rust
struct ContractionOrdering {
    hypergraph: HyperGraph,          // tensor network structure
    dimensions: Vec<usize>,          // dimension of each hyperedge
    objective: ContractionObjective, // TotalCost or MaxWidth
}
enum ContractionObjective { TotalCost, MaxWidth }
// Problem: Optimization (Minimize)
// Metric: SolutionSize<usize>
```

---

## 6. Minimum Width Decision Diagram

### 6.1 Formal Mathematical Definition

**Multi-valued Decision Diagram (MDD).** Given n discrete variables x_1, ..., x_n with domains D_1, ..., D_n and a feasible set S subset D_1 x D_2 x ... x D_n, an MDD for S under variable ordering pi is a layered directed acyclic graph where:
- Layer 0 has a single root node r.
- Layer i corresponds to variable x_{pi(i)}, 1 <= i <= n.
- Layer n+1 has a single terminal node t.
- Each node at layer i has at most |D_{pi(i)}| outgoing arcs, one for each domain value.
- A path from r to t represents a feasible assignment in S.
- An **exact MDD** represents S exactly: the set of r-t paths is in bijection with S.
- A **reduced MDD** merges equivalent nodes (same reachable terminal paths), analogous to ROBDD reduction.

The **width** of an MDD is max_{0 <= i <= n+1} |{nodes at layer i}|.

**Minimum Width Decision Diagram Problem.** Given a constraint set C defining a feasible set S over n variables and an integer w, does there exist a variable ordering pi such that the reduced exact MDD for S under pi has width at most w?

### 6.2 Complexity Classification

**NP-hardness.** Finding the minimum-width exact MDD is NP-hard for most interesting constraint sets. This follows directly from the equivalence to pathwidth:

**Theorem.** For a constraint satisfaction problem with constraint (primal/interaction) graph G, the minimum width of an exact MDD over all variable orderings equals pw(G) + 1, where pw(G) is the pathwidth of G.

**Proof sketch.** The width at layer i in an exact MDD counts the number of distinguishable states after fixing the first i variables. The maximum such count over all layers, minimized over all orderings, equals the maximum number of "active" constraints — those involving both assigned and unassigned variables. This is precisely the vertex separation number of the constraint graph, which equals the pathwidth.

Since pathwidth computation is NP-complete (Arnborg et al. 1987, Lengauer 1981), minimum width MDD computation is NP-hard.

### 6.3 History and Key Milestones

| Year | Milestone | Reference |
|------|-----------|-----------|
| 1986 | Bryant: ROBDD as canonical form, width = 2^n worst case | Bryant 1986 |
| 2007 | Andersen et al.: MDD propagation for constraint programming | Andersen et al. 2007 |
| 2008 | Hadzic et al.: approximate MDD compilation with bounded width | Hadzic et al. 2008 |
| 2011 | Bergman et al.: relaxed MDDs for optimization bounds | Bergman et al. 2011 |
| 2014 | Bergman et al.: optimization bounds from binary DDs | Bergman et al. 2014 |
| 2016 | Bergman, Cire, van Hoeve & Hooker: comprehensive monograph on DD-based optimization | Bergman et al. 2016 |
| 2021 | Gillard et al.: branch-and-bound with DDs in Rust | Gillard et al. 2021 |

### 6.4 Approximation — Relaxed and Restricted DDs

Since finding the exact minimum-width MDD is NP-hard, practical DD-based optimization uses width-bounded approximations:

**Relaxed DDs (upper/lower bounds):**
- Fix a maximum width W.
- Build the MDD top-down. When a layer exceeds width W, merge nodes.
- The resulting diagram is a *relaxation*: it contains all feasible solutions plus some infeasible ones.
- Optimizing over the relaxed DD gives a bound (upper bound for minimization, lower bound for maximization).
- These bounds can be tighter than LP relaxation bounds (Bergman et al. 2014).

**Restricted DDs (feasible solutions):**
- Fix a maximum width W.
- Build the MDD top-down. When a layer exceeds width W, delete nodes.
- The resulting diagram represents a *subset* of feasible solutions.
- Any path gives a feasible solution (heuristic/incumbent).

**Branch-and-bound with DDs.**
Bergman et al. (2016) describe a complete framework:
1. Build relaxed DD at root node — obtain bound.
2. Build restricted DD — obtain incumbent.
3. If gap remains, branch by fixing a variable and recurse.
4. This yields an exact solver using only DDs (no LP/MIP needed).

### 6.5 Parameterized Complexity

Since minimum width MDD is equivalent to pathwidth:
- FPT parameterized by the target width w, inheriting all FPT results for pathwidth/treewidth.
- For fixed w, decidable in O(2^{O(w^3)} * n) time (via Bodlaender's algorithm for treewidth, since pw >= tw).

### 6.6 Known Reductions

| Source | Target | Type | Description |
|--------|--------|------|-------------|
| MinWidthDD | Pathwidth | Equivalence | Min DD width = pw(constraint graph) + 1 |
| Pathwidth | MinWidthDD | Equivalence (reverse) | pw(G) = min DD width - 1 for constraints on G |
| BDD Variable Ordering | MinWidthDD | Specialization | BDD is binary-domain MDD; ROBDD minimization is the binary case |
| MinWidthDD | ILP | Reduction | Encode ordering + width counting |
| MinWidthDD | Treewidth | Relaxation | min DD width = pw + 1 >= tw + 1; AND/OR DDs achieve 2^{tw} |

### 6.7 Connection to AND/OR Decision Diagrams

A key insight from the constraint programming community (Mateescu & Dechter 2007):

**OR-based DDs (standard MDDs):**
- Width bounded by 2^{pw(G)} where pw(G) is the pathwidth of the constraint graph.
- Correspond to path decompositions / linear orderings.

**AND/OR MDDs (AOMDDs):**
- Width bounded by 2^{tw(G)} where tw(G) is the treewidth of the constraint graph.
- Correspond to tree decompositions / pseudo-trees.
- Can be exponentially smaller than OR-based MDDs for graphs where tw << pw (e.g., balanced trees: tw = 1 vs pw = log n).

This creates a hierarchy:
```
AND/OR MDD size <= 2^{tw(G)}  <=  OR MDD size <= 2^{pw(G)}
```

The gap between tw and pw (up to a log n factor) translates directly into an exponential gap in DD sizes.

### 6.8 Practical Impact

The minimum DD width determines:
1. **Whether relaxation is needed:** If the exact MDD width is small (e.g., polynomial in n), no relaxation is necessary and exact optimization is efficient.
2. **Quality of relaxation bounds:** Wider exact MDDs require more aggressive merging in relaxed DDs, producing weaker bounds.
3. **Variable ordering quality:** The variable ordering that minimizes DD width corresponds to the optimal path decomposition of the constraint graph.

### 6.9 Implementation Notes for problem-reductions

**Codebase connection:**
- `pathdecomposition.rs` already solves this problem implicitly — computing pathwidth of a graph gives the minimum DD width minus 1.
- The MinWidthDD model could be a thin wrapper exposing pathwidth as a DD problem.

**Proposed model:**
```rust
struct MinWidthDD {
    constraints: Vec<Constraint>,  // or reference a constraint graph
    num_variables: usize,
    domains: Vec<usize>,           // domain size per variable
    target_width: usize,           // w
}
// Problem: Satisfaction (does width-w exact MDD exist?)
// Metric: bool
```

---

## 7. The Treewidth-Pathwidth-BDD-Contraction Chain

This section synthesizes the deep connections between all six problems, forming a coherent chain of reductions and equivalences.

### 7.1 The Central Chain

```
                    [Structural Graph Parameters]
                              |
                    Treewidth (tw) <= Pathwidth (pw)
                        |                    |
                        |                    |
              [AND/OR DD Size]       [OR DD / BDD Size]
              bounded by 2^tw        bounded by 2^pw
                        |                    |
                        |                    |
            Contraction Ordering     BDD Variable Ordering
            = tw(line graph)         related to pw(interaction graph)
                        |                    |
                        |                    |
               Tensor Networks        Decision Diagrams
                        \                  /
                         \                /
                    [Minimum Width DD]
                    = pw(constraint graph) + 1
```

### 7.2 Precise Equivalences and Inequalities

**Width parameter chain:**

For any graph G:
1. tw(G) <= pw(G) <= tw(G) * O(log n)
2. BDD width for constraints on G is in Theta(2^{pw(G)})
3. AND/OR MDD width for constraints on G is in Theta(2^{tw(G)})
4. Tensor contraction cost for network on G is Theta(2^{tw(L(G))}) where L(G) is the line graph
5. Min exact MDD width = pw(G) + 1

**Problem difficulty chain:**

All six problems are NP-hard. Their computational relationships:
- Treewidth computation: NP-complete, FPT in O(2^{O(k^2)} * n^{O(1)})
- Pathwidth computation: NP-complete, FPT (via treewidth algorithms)
- BDD Variable Ordering: NP-complete, inapproximable within any constant
- Contraction Ordering (max-width): NP-hard, equivalent to treewidth of line graph
- MinWidthDD: NP-hard, equivalent to pathwidth of constraint graph
- MaxSAT: NP-hard, APX-complete (admits constant-factor approximation unlike BDD ordering)

### 7.3 The Meta-Recursive Structure

A fascinating self-referential structure emerges:

1. **Problem**: Solve MaxSAT instance phi.
2. **Approach 1**: Encode phi as a tensor network; contract it.
3. **Sub-problem**: Find optimal contraction ordering (NP-hard! equivalent to treewidth).
4. **Approach 2**: Build a BDD for phi; evaluate it.
5. **Sub-problem**: Find optimal BDD variable ordering (NP-hard! related to pathwidth).
6. **Approach 3**: Build an MDD for the constraints of phi.
7. **Sub-problem**: Find minimum-width MDD (NP-hard! equivalent to pathwidth).

In each case, the **tool used to solve the NP-hard problem introduces its own NP-hard optimization problem**. The difficulty of the sub-problem is controlled by the structural graph parameter (treewidth or pathwidth) of the original problem instance.

### 7.4 Reduction Graph for problem-reductions

```
MaxSAT ---------> QUBO (penalty per clause)
  |                  |
  |                  v
  |              SpinGlass / Ising
  v
  ILP <----------- Treewidth (elimination ordering ILP)
  ^                  ^
  |                  |
  |            Pathwidth -> Treewidth (trivial relaxation)
  |                  |
  |            MinWidthDD = Pathwidth (equivalence)
  |                  |
  |            BDD Variable Ordering ---> Pathwidth (structural bound)
  |
  +<----------- Contraction Ordering (= treewidth of line graph)
```

### 7.5 Implications for the Codebase

The chain of connections means that adding these six problems creates a rich, deeply interconnected subgraph in the reduction network:

1. **Pathwidth** is the linchpin — it connects to BDD ordering, MinWidthDD, and Treewidth.
2. **Treewidth** connects to Contraction Ordering and provides the foundation for all width-based bounds.
3. **MaxSAT** connects the structural problems to the existing SAT/QUBO/ILP infrastructure.
4. **BDD Variable Ordering** and **MinWidthDD** are the "meta-problems" — NP-hard problems about the tools used to solve NP-hard problems.
5. **Contraction Ordering** bridges the tensor network (GenericTensorNetworks.jl) and graph theory worlds.

---

## 8. Implementation Strategy for problem-reductions

### 8.1 Priority Ordering

| Priority | Problem | Rationale |
|----------|---------|-----------|
| 1 (Tier 2) | MaxSAT | Reuses existing SAT infrastructure; direct QUBO/ILP reductions |
| 2 (Tier 2) | Pathwidth | Already implemented in codebase; formalize as Problem model |
| 3 (Tier 3) | Treewidth | Generalizes pathwidth; central structural parameter |
| 4 (Tier 3) | BDD Variable Ordering | Meta-problem with strong pathwidth connection |
| 5 (Tier 4) | MinWidthDD | Thin wrapper over Pathwidth; theoretical bridge |
| 6 (Tier 4) | Contraction Ordering | Specialized; needs tensor network infrastructure |

### 8.2 Shared Infrastructure

**Pathwidth computation** (`pathdecomposition.rs`): Already exists. Needs to be exposed as a standalone Problem model rather than buried in the UnitDiskGraph mapping pipeline.

**Elimination ordering encoding:** Shared between Treewidth, Pathwidth, and Contraction Ordering ILP formulations. Factor out a common `EliminationOrdering` helper.

**CNF clause handling:** Shared between MaxSAT and existing Satisfiability/KSatisfiability. Extend with weight support.

### 8.3 Key Reductions to Implement

| Reduction | Difficulty | Notes |
|-----------|-----------|-------|
| Satisfiability -> MaxSAT | Trivial | All weights = 1 |
| MaxSAT -> QUBO | Moderate | 2-clause is direct; 3-clause needs auxiliary variables |
| MaxSAT -> ILP | Easy | Clause indicator variables |
| Pathwidth -> Treewidth | Trivial | Path decomposition is tree decomposition |
| Treewidth -> ILP | Moderate | Elimination ordering formulation |
| Contraction Ordering -> Treewidth | Moderate | Compute line graph, then find treewidth |

---

## 9. Master Reference List

### Foundational Papers

1. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277--284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   -- NP-completeness of treewidth and pathwidth decision problems.

2. **Robertson, N. & Seymour, P.D.** (1986). "Graph minors. II. Algorithmic aspects of tree-width." *Journal of Algorithms*, 7(3):309--322. DOI: [10.1016/0196-6774(86)90023-4](https://doi.org/10.1016/0196-6774(86)90023-4)
   -- Formal definition of tree decomposition and treewidth; algorithmic foundations.

3. **Robertson, N. & Seymour, P.D.** (1983). "Graph minors. I. Excluding a forest." *Journal of Combinatorial Theory, Series B*, 35(1):39--61. DOI: [10.1016/0095-8956(83)90079-5](https://doi.org/10.1016/0095-8956(83)90079-5)
   -- Introduces pathwidth; first paper in the Graph Minors series.

4. **Bodlaender, H.L.** (1996). "A linear-time algorithm for finding tree-decompositions of small treewidth." *SIAM Journal on Computing*, 25(6):1305--1317. DOI: [10.1137/S0097539793251219](https://doi.org/10.1137/S0097539793251219)
   -- FPT algorithm: O(2^{O(k^3)} * n) for treewidth.

5. **Bryant, R.E.** (1986). "Graph-based algorithms for Boolean function manipulation." *IEEE Transactions on Computers*, 35(8):677--691. DOI: [10.1109/TC.1986.1676819](https://doi.org/10.1109/TC.1986.1676819)
   -- Foundational paper on ROBDDs: canonical form, ITE algorithm, ordering sensitivity.

6. **Bollig, B. & Wegener, I.** (1996). "Improving the variable ordering of OBDDs is NP-complete." *IEEE Transactions on Computers*, 45(9):993--1002. DOI: [10.1109/12.537122](https://doi.org/10.1109/12.537122)
   -- NP-completeness of BDD variable ordering; reduction from 3-SAT.

7. **Markov, I.L. & Shi, Y.** (2008). "Simulating quantum computation by contracting tensor networks." *SIAM Journal on Computing*, 38(3):963--981. DOI: [10.1137/050644756](https://doi.org/10.1137/050644756)
   -- Contraction cost bounded by 2^{treewidth}; treewidth of line graph = contraction width.

8. **Hastad, J.** (2001). "Some optimal inapproximability results." *Journal of the ACM*, 48(4):798--859. DOI: [10.1145/502090.502098](https://doi.org/10.1145/502090.502098)
   -- 7/8 optimal for MAX-3-SAT; inapproximability via PCPs.

### Equivalence and Structural Results

9. **Kinnersley, N.G.** (1992). "The vertex separation number of a graph equals its path-width." *Information Processing Letters*, 42(6):345--350. DOI: [10.1016/0020-0190(92)90234-M](https://doi.org/10.1016/0020-0190(92)90234-M)
   -- Proves vs(G) = pw(G).

10. **Kirousis, L.M. & Papadimitriou, C.H.** (1985). "Interval graphs and searching." *Discrete Mathematics*, 55(2):181--184. DOI: [10.1016/0012-365X(85)90046-9](https://doi.org/10.1016/0012-365X(85)90046-9)
    -- Node search number = interval thickness.

11. **Kirousis, L.M. & Papadimitriou, C.H.** (1986). "Searching and pebbling." *Theoretical Computer Science*, 47:205--218. DOI: [10.1016/0304-3975(86)90146-5](https://doi.org/10.1016/0304-3975(86)90146-5)
    -- Node search number equivalences.

12. **Korach, E. & Solel, N.** (1993). "Tree-width, path-width, and cutwidth." *Discrete Applied Mathematics*, 43(1):97--101. DOI: [10.1016/0166-218X(93)90171-J](https://doi.org/10.1016/0166-218X(93)90171-J)
    -- pw(G) <= tw(G) * O(log n).

13. **Fellows, M.R. & Langston, M.A.** (1994). "On search, decision, and the efficiency of polynomial-time algorithms." *Journal of Computer and System Sciences*, 49(3):769--779. DOI: [10.1016/S0022-0000(05)80079-0](https://doi.org/10.1016/S0022-0000(05)80079-0)
    -- Unified equivalence of pathwidth, vertex separation, node search, gate matrix layout.

### Algorithms and Approximation

14. **Bodlaender, H.L., Drange, P.G., Dregi, M.S., Fomin, F.V., Lokshtanov, D. & Pilipczuk, M.** (2016). "A c^k n 5-approximation algorithm for treewidth." *SIAM Journal on Computing*, 45(2):317--378. DOI: [10.1137/130947374](https://doi.org/10.1137/130947374)
    -- 5-approximation in 2^{O(k)} * n time.

15. **Korhonen, T.** (2022). "An improved parameterized algorithm for treewidth." *SIAM Journal on Computing* (2024 publication). arXiv: [2211.07154](https://arxiv.org/abs/2211.07154)
    -- Improved FPT to 2^{O(k^2)} * n^{O(1)}; (1+epsilon)-approximation in k^{O(k/epsilon)} * n^{O(1)}.

16. **Lewin, M., Livnat, D. & Zwick, U.** (2002). "Improved rounding techniques for the MAX 2-SAT and MAX DI-CUT problems." *IPCO 2002*, LNCS 2337. DOI: [10.1007/3-540-47867-1_6](https://doi.org/10.1007/3-540-47867-1_6)
    -- 0.9401-approximation for MAX-2-SAT via SDP + skewed rounding.

17. **Friedman, S.J. & Supowit, K.J.** (1990). "Finding the optimal variable ordering for binary decision diagrams." *IEEE Transactions on Computers*, 39(5):710--713. DOI: [10.1109/12.53586](https://doi.org/10.1109/12.53586)
    -- First exact algorithm: O(n^2 * 3^n) dynamic programming.

18. **Rudell, R.** (1993). "Dynamic variable ordering for ordered binary decision diagrams." *Proc. ICCAD '93*, pp. 42--47.
    -- Sifting algorithm for dynamic BDD variable reordering.

19. **Gray, J. & Kourtis, S.** (2021). "Hyper-optimized tensor network contraction." *Quantum*, 5:410. DOI: [10.22331/q-2021-03-15-410](https://doi.org/10.22331/q-2021-03-15-410)
    -- State-of-the-art contraction path finding; cotengra library; >10000x speedup.

### Decision Diagram Optimization

20. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2016). *Decision Diagrams for Optimization*. Springer. DOI: [10.1007/978-3-319-42849-9](https://doi.org/10.1007/978-3-319-42849-9)
    -- Comprehensive monograph: exact, relaxed, restricted DDs; width control; MDD-based branch-and-bound.

21. **Bergman, D., Cire, A.A., van Hoeve, W.-J. & Hooker, J.N.** (2014). "Optimization bounds from binary decision diagrams." *INFORMS Journal on Computing*, 26(2):253--268. DOI: [10.1287/ijoc.2013.0561](https://doi.org/10.1287/ijoc.2013.0561)
    -- Relaxed DDs yield bounds tighter than LP for MIS, MaxCut, MAX-2-SAT.

22. **Hadzic, T., Hooker, J.N. & Tiedemann, P.** (2008). "Approximate compilation of constraints into multivalued decision diagrams." *CP 2008*, LNCS 5202, pp. 448--462. DOI: [10.1007/978-3-540-85958-1_30](https://doi.org/10.1007/978-3-540-85958-1_30)
    -- Approximate MDD compilation with bounded width.

### NP-Completeness Refinements

23. **Bodlaender, H.L., Bonnet, E., Jaffke, L. & Tiwary, H.R.** (2023). "Treewidth is NP-complete on cubic graphs." *Proc. IPEC 2023*, LIPIcs 285, Article 7. DOI: [10.4230/LIPIcs.IPEC.2023.7](https://doi.org/10.4230/LIPIcs.IPEC.2023.7). Also: *Electronic Journal of Combinatorics* 32(3):P36, 2025.
    -- Improves degree bound for treewidth NP-completeness from 9 to 3.

24. **Bodlaender, H.L. & Thilikos, D.M.** (1997). "Treewidth for graphs with small chordality." *Discrete Applied Mathematics*, 79(1--3):45--61.
    -- NP-completeness for max-degree-9 graphs.

25. **Monien, B. & Sudborough, I.H.** (1988). "Min cut is NP-complete for edge weighted trees." *Theoretical Computer Science*, 58(1--3):209--229.
    -- Pathwidth NP-complete for planar degree-3 graphs (via vertex separation).

### Surveys and Background

26. **Bodlaender, H.L.** (1998). "A partial k-arboretum of graphs with bounded treewidth." *Theoretical Computer Science*, 209(1--2):1--45. DOI: [10.1016/S0304-3975(97)00228-4](https://doi.org/10.1016/S0304-3975(97)00228-4)
    -- Comprehensive survey of treewidth bounds for 100+ graph classes.

27. **Courcelle, B.** (1990). "The monadic second-order logic of graphs. I. Recognizable sets of finite graphs." *Information and Computation*, 85(1):12--75.
    -- Courcelle's theorem: MSO2 properties decidable in linear time on bounded-treewidth graphs.

28. **Rose, D.J.** (1970). "Triangulated graphs and the elimination process." *Journal of Mathematical Analysis and Applications*, 32(3):597--609.
    -- Elimination orderings characterize chordal graphs; treewidth via elimination.

29. **Gavril, F.** (1974). "The intersection graphs of subtrees in trees are exactly the chordal graphs." *Journal of Combinatorial Theory, Series B*, 16(1):47--56.
    -- Chordal graphs as subtree intersection graphs; tree decomposition via chordal completion.

30. **Coudert, D., Mazauric, D. & Nisse, N.** (2014). "Experimental evaluation of a branch and bound algorithm for computing pathwidth." *SEA 2014*, LNCS 8504, pp. 46--58. DOI: [10.1007/978-3-319-07959-2_5](https://doi.org/10.1007/978-3-319-07959-2_5)
    -- Branch-and-bound for exact pathwidth; basis of the codebase's `MinhThiTrick` algorithm.

### PACE Challenge

31. **Tamaki, H.** (2017). "Positive-instance driven dynamic programming for treewidth." *Proc. ESA 2017*, LIPIcs 87, Article 68. DOI: [10.4230/LIPIcs.ESA.2017.68](https://doi.org/10.4230/LIPIcs.ESA.2017.68)
    -- Won PACE 2017 exact treewidth track and ESA 2017 Best Paper Award.

32. **Bannach, M., Berndt, S. & Ehlers, T.** (2017). "Jdrasil: A modular library for computing tree decompositions." *Proc. SEA 2017*.
    -- Modular Java framework for treewidth; PACE 2017 submission.

### MaxSAT and QUBO

33. **Ansotegui, C. & Gabas, J.** (2013). "Solving (weighted) partial MaxSAT with ILP." *Proc. CPAIOR 2013*, LNCS 7874, pp. 403--409.
    -- ILP encoding for weighted partial MaxSAT using clause indicator variables.

34. **Austrin, P.** (2007). "Balanced MAX 2-SAT might not be the hardest." *Proc. STOC 2007*, pp. 189--197.
    -- Optimality of 0.9401 for MAX-2-SAT under the Unique Games Conjecture.

35. **Minato, S.** (1993). "Zero-Suppressed BDDs for Set Manipulation in Combinatorial Problems." *Proc. DAC '93*, pp. 272--277. DOI: [10.1145/157485.164890](https://doi.org/10.1145/157485.164890)
    -- ZDDs: variable ordering equally critical for ZDD size.

36. **Mateescu, R. & Dechter, R.** (2007). "AND/OR multi-valued decision diagrams (AOMDDs) for graphical models." *Journal of Artificial Intelligence Research*, 33:465--519.
    -- AND/OR DDs achieve width 2^{tw} vs. standard DDs at 2^{pw}.

### Tensor Network Contraction

37. **Pfeifer, R.N.C., Haegeman, J. & Verstraete, F.** (2014). "Faster identification of optimal contraction sequences for tensor networks." *Physical Review E*, 90(3):033315. DOI: [10.1103/PhysRevE.90.033315](https://doi.org/10.1103/PhysRevE.90.033315)
    -- Enhanced pruning for exact optimal contraction sequences.

38. **Staudt, C.** (2024). "Improved cut strategy for tensor network contraction orders." *Proc. SEA 2024*, LIPIcs 301, Article 27. DOI: [10.4230/LIPIcs.SEA.2024.27](https://doi.org/10.4230/LIPIcs.SEA.2024.27)
    -- Recent improvement on hypergraph partitioning for contraction ordering.
