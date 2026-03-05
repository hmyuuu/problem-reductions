// Complexity Research Notes: Proposed Problems & Reductions
// Reference document for the problem-reductions codebase expansion
// Generated: 2026-02-27

#set page(paper: "a4", margin: (x: 2cm, y: 2cm))
#set text(font: "New Computer Modern", size: 10pt)
#set par(justify: true)
#set heading(numbering: "1.1")
#show link: set text(blue)

#align(center)[
  #text(size: 16pt, weight: "bold")[Complexity Research Notes]
  #linebreak()
  #text(size: 12pt)[Proposed Problems & Reductions for `problem-reductions`]
  #linebreak()
  #text(size: 10pt, fill: gray)[Research compilation --- February 2026]
]

#outline(indent: 2em, depth: 3)

= Introduction

This document compiles complexity-theoretic research for all proposed additions to the `problem-reductions` codebase. Each problem is described with its formal definition, complexity classification, key references, known reductions, and implementation notes specific to this codebase.

*Current state:* 22 problems, 47 reduction edges. \
*Target:* ~43 problems, ~91 reduction edges, completing all 21 of Karp's NP-complete problems.

== Notation

- $n = |V|$ (vertices), $m = |E|$ (edges) for graph problems
- $cal(U)$ = universe, $cal(S)$ = collection of subsets
- $x_i in {0,1}$ = binary decision variable
- $s_i in {+1,-1}$ = Ising spin variable; related by $x_i = (1-s_i)/2$
- NP-c = NP-complete, NP-h = NP-hard

#pagebreak()

// ============================================================
= Number Problems (New Category)
// ============================================================

These problems introduce the `number/` model category. They involve numeric arrays with summation constraints and are *weakly NP-complete* (pseudo-polynomial algorithms exist).

== Subset Sum <subsec:subsetsum>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#18* $dot.c$ Category: `number` $dot.c$ Complexity: NP-complete (weakly) $dot.c$ Type: Satisfaction
]

=== Definition

Given a set of integers $A = {a_0, a_1, dots, a_(n-1)}$ and a target $t in ZZ$, determine whether $exists S subset.eq A$ such that $sum_(i in S) a_i = t$.

=== Variables

$n$ binary variables: $x_i = 1$ iff $a_i$ is selected. Configuration space: ${0,1}^n$.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[SP13\]
- *Weakly NP-complete:* admits $O(n t)$ pseudo-polynomial DP algorithm
- *Strong NP-completeness:* only if numbers are exponentially large
- *Approximation:* FPTAS exists via DP rounding (Ibarra & Kim 1975)
- *Average case:* density $d = n / log_2(max |a_i|)$; for $d > 1$, almost all instances have solutions (Lagarias & Odlyzko 1985)

=== Reductions

/ SubsetSum $arrow.r$ ILP: Feasibility ILP: $min 0$ s.t. $sum_i a_i x_i = t$, $x_i in {0,1}$. *Overhead:* $n$ variables, 1 constraint.

/ SubsetSum $arrow.r$ QUBO: (Lucas 2014 §5) Hamiltonian $H = A (sum_i a_i x_i - t)^2$. Expanding:
  $ Q_(i i) = A(a_i^2 - 2t a_i), quad Q_(i j) = 2A a_i a_j #h(1em) (i < j) $
  *Overhead:* $n$ variables, dense $n times n$ matrix. Ground state energy 0 iff solution exists.

/ Partition $arrow.r$ SubsetSum: Set target $t = sum a_i \/ 2$. If total sum is odd, immediately infeasible.

=== Key References

+ Karp, R.M. (1972). "Reducibility Among Combinatorial Problems." _Complexity of Computer Computations_, pp. 85--103.
+ Garey, M.R. & Johnson, D.S. (1979). _Computers and Intractability_. Problem \[SP13\].
+ Lucas, A. (2014). "Ising formulations of many NP problems." §5. arXiv:1302.5843.
+ Lagarias, J.C. & Odlyzko, A.M. (1985). "Solving low-density subset sum problems." _JACM_, 32(1):229--246.

#v(0.5em)

== Partition <subsec:partition>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#20* $dot.c$ Category: `number` $dot.c$ Complexity: NP-complete (weakly) $dot.c$ Type: Satisfaction
]

=== Definition

Given a multiset of positive integers $A = {a_0, dots, a_(n-1)}$, determine whether $A$ can be partitioned into $A_1, A_2$ with $sum_(i in A_1) a_i = sum_(i in A_2) a_i$.

Equivalently: find $x in {0,1}^n$ such that $sum_i a_i x_i = S\/2$ where $S = sum a_i$. If $S$ is odd, immediately unsatisfiable.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[SP12\]
- *Weakly NP-complete:* $O(n S)$ pseudo-polynomial DP
- *Karmarkar-Karp heuristic:* $O(n log n)$ differencing algorithm, often finds solutions for random instances
- *Phase transition:* instances with $S \/ (2^n) approx 1$ are hardest

=== Reductions

/ Partition $arrow.r$ SubsetSum: Trivial. Target $= S\/2$.
/ Partition $arrow.r$ ILP: $sum a_i x_i = S\/2$, $x_i in {0,1}$.
/ Partition $arrow.r$ QUBO: (Lucas 2014 §5.1) Ising: $H = A(sum_i a_i s_i)^2$ with $s_i in {plus.minus 1}$. QUBO via $s_i = 1 - 2x_i$:
  $ H = A(S - 2 sum_i a_i x_i)^2 $
  $Q_(i i) = A(4a_i^2 - 4S a_i)$, $Q_(i j) = 8A a_i a_j$. *Overhead:* $n$ variables, dense.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[SP12\].
+ Karmarkar, N. & Karp, R.M. (1982). "The differencing method of set partitioning." Report UCB/CSD 82/113.
+ Mertens, S. (2006). "The Easiest Hard Problem: Number Partitioning." _Computational Complexity and Statistical Physics_, pp. 125--139.

#v(0.5em)

== Knapsack (0-1) <subsec:knapsack>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#18 generalization* $dot.c$ Category: `number` $dot.c$ Complexity: NP-complete (weakly) $dot.c$ Type: Optimization (Maximize)
]

=== Definition

Given $n$ items with weights $w_i$ and values $v_i$, and capacity $C$, find $x in {0,1}^n$ maximizing $sum_i v_i x_i$ subject to $sum_i w_i x_i lt.eq C$.

=== Complexity Analysis

- *Decision:* NP-complete (Garey & Johnson 1979) \[MP9\]
- *Weakly NP-complete:* $O(n C)$ pseudo-polynomial DP
- *FPTAS:* $(1-epsilon)$-approximation in $O(n^2 / epsilon)$ time (Ibarra & Kim 1975)
- *Relation to SubsetSum:* When $v_i = w_i$ for all $i$, Knapsack $equiv$ SubsetSum

=== Reductions

/ Knapsack $arrow.r$ ILP: $max v^T x$ s.t. $w^T x lt.eq C$, $x in {0,1}^n$. *Overhead:* $n$ vars, 1 constraint.
/ Knapsack $arrow.r$ QUBO: (Lucas 2014 §5.2) Introduce $ceil(log_2(C+1))$ binary slack variables ${y_j}$ to convert inequality to equality:
  $ sum_i w_i x_i + sum_j 2^j y_j = C $
  Then $H = -A sum_i v_i x_i + B(sum_i w_i x_i + sum_j 2^j y_j - C)^2$.
  Need $B > A dot max(v_i)$ to enforce feasibility. *Overhead:* $n + O(log C)$ variables.

=== Key References

+ Garey & Johnson (1979) \[MP9\].
+ Kellerer, H., Pferschy, U. & Pisinger, D. (2004). _Knapsack Problems_. Springer.
+ Lucas (2014). §5.2.

#v(0.5em)

== Job Sequencing <subsec:jobsequencing>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#19* $dot.c$ Category: `number` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Maximize)
]

=== Definition

Given $n$ unit-time jobs with deadlines $d_j$ and profits $p_j$, find a schedule maximizing total profit. A job is included only if completed by its deadline; at most one job per time slot.

=== Complexity Analysis

- *Decision:* NP-complete (Garey & Johnson 1979)
- *Greedy optimality:* Greedy (sort by profit, assign to latest available slot) is optimal for the *feasibility* subproblem but the selection problem is NP-hard in the weighted case
- *Special cases:* Unit profits $arrow.r$ matroid intersection (polynomial); arbitrary profits $arrow.r$ NP-hard

=== Reductions

/ JobSequencing $arrow.r$ ILP: Binary $x_j$ per job. Cumulative constraint: for each time $t$, $sum_(j: d_j gt.eq t) x_j lt.eq t$. Maximize $sum p_j x_j$.
/ Partition $arrow.r$ JobSequencing: Reduces NP-completeness proof through Partition.

=== Key References

+ Garey & Johnson (1979). Karp (1972).
+ Venturelli, D. et al. (2016). "Job-shop scheduling solver based on quantum annealing." §3.

#pagebreak()

// ============================================================
= Set Problems (Extended)
// ============================================================

These extend the existing `set/` category with dual, exact, and structured variants.

== Hitting Set <subsec:hittingset>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#15* $dot.c$ Category: `set` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given universe $cal(U) = {0, dots, n-1}$, collection $cal(S) = {S_0, dots, S_(m-1)}$ of subsets of $cal(U)$, and element weights $w: cal(U) arrow.r RR^+$, find minimum-weight $H subset.eq cal(U)$ such that $H inter S_j eq.not emptyset$ for all $j$.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[SP8\]
- *Exact dual of Set Cover:* transpose incidence matrix $A$ (rows $arrow.l.r$ columns)
  - Set Cover: select columns (sets) to cover all rows (elements)
  - Hitting Set: select rows (elements) to hit all columns (sets)
- *Approximation:* $O(log m)$-approximation via greedy (same as Set Cover)
- *Parameterized:* FPT in solution size $k$: $O(m^k dot n)$ brute force, better: $O(2.076^k + m n)$

=== Reductions

/ HittingSet $arrow.l.r$ MinimumSetCovering: Transpose incidence matrix. Both directions.
/ HittingSet $arrow.r$ ILP: $min sum w_i x_i$ s.t. $sum_(i in S_j) x_i gt.eq 1$ for all $j$, $x_i in {0,1}$.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[SP8\].
+ Hochbaum, D.S. (1982). "Approximation algorithms for the set covering and vertex cover problems." _SIAM J. Computing_, 11(3):555--556.

#v(0.5em)

== Exact Cover <subsec:exactcover>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#14* $dot.c$ Category: `set` $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given universe $cal(U) = {0, dots, n-1}$ and collection $cal(S) = {S_0, dots, S_(m-1)}$, find $cal(S)^* subset.eq cal(S)$ such that every element of $cal(U)$ belongs to *exactly one* set in $cal(S)^*$.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[SP2\]
- *Relation to Set Cover:* Set Cover requires $gt.eq 1$ coverage; Exact Cover requires $= 1$.
- *Knuth's Algorithm X:* Efficient backtracking with "dancing links" (DLX) for exact cover
- *Applications:* Sudoku solving, pentomino tiling, polyomino packing
- *ZDD connection:* ZDD naturally represents all exact covers of a set system

=== Reductions

/ ExactCover $arrow.r$ MinimumSetCovering: Relaxation. Change $= 1$ to $gt.eq 1$. Post-check exactness.
/ ExactCover $arrow.r$ ILP: $sum_(j: i in S_j) x_j = 1$ for all $i in cal(U)$, $x_j in {0,1}$. Pure feasibility.
/ ExactCover $arrow.r$ SAT: Encode "exactly one" per element as CNF. For element $i$: at-least-one clause + pairwise at-most-one clauses.
/ 3DMatching $arrow.r$ ExactCover: Each triple becomes a 3-element set in universe $X union Y union Z$ of size $3n$.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[SP2\].
+ Knuth, D.E. (2000). "Dancing links." _Millennial Perspectives in Computer Science_, pp. 187--214.

#v(0.5em)

== 3-Dimensional Matching <subsec:3dmatching>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#17* $dot.c$ Category: `set` $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given three disjoint sets $X, Y, Z$ each of size $n$ and a set of triples $T subset.eq X times Y times Z$, find $M subset.eq T$ with $|M| = n$ such that every element in $X union Y union Z$ appears in exactly one triple of $M$.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[SP1\]
- *Special case of Exact Cover:* each triple is a 3-element set from universe of size $3n$
- *Relation to bipartite matching:* 2-dimensional matching (bipartite) is polynomial; 3D matching is NP-complete
- *Applications:* scheduling with three resource types, assignment problems
- *Parameterized:* FPT in solution size

=== Reductions

/ 3DMatching $arrow.r$ ExactCover: Each triple $(x,y,z)$ becomes set ${x, n+y, 2n+z}$ in universe of size $3n$.
/ 3DMatching $arrow.r$ MaximumSetPacking: Each triple as a 3-element set. Find $n$ disjoint sets.
/ 3SAT $arrow.r$ 3DMatching: Classic Karp chain reduction.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[SP1\].
+ Kann, V. (1991). "Maximum bounded 3-dimensional matching is MAX SNP-complete." _IPL_, 37(1):27--35.

#pagebreak()

// ============================================================
= Graph Problems (Extended)
// ============================================================

== Clique Cover <subsec:cliquecover>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#13* $dot.c$ Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given undirected graph $G = (V,E)$ and integer $k$, partition $V$ into at most $k$ cliques (complete subgraphs).

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[GT17\]
- *Equivalence:* Clique Cover on $G$ $equiv$ $k$-Coloring on $overline(G)$ (complement graph)
- *For perfect graphs:* polynomial via Lovász theta function
- *Minimum clique cover number* $= $ chromatic number of complement $= chi(overline(G))$

=== Reductions

/ CliqueCover $arrow.l.r$ KColoring: $k$-color $overline(G)$. Color classes in $overline(G)$ are independent sets in $overline(G)$ = cliques in $G$.
/ CliqueCover $arrow.r$ ILP: Binary $x_(v,c)$ per vertex-clique pair. Assignment: $sum_c x_(v,c) = 1$. Clique validity: for non-adjacent $u,v$: $x_(u,c) + x_(v,c) lt.eq 1$.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[GT17\].

#v(0.5em)

== Minimum Bisection <subsec:minbiinterion>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given undirected graph $G = (V,E)$ with $|V|$ even, partition $V$ into two equal sets $V_1, V_2$ ($|V_1| = |V_2| = n\/2$) minimizing the number of crossing edges.

=== Complexity Analysis

- *Decision:* NP-complete (Garey & Johnson 1979) \[ND16\]
- *Relation to Max-Cut:* MaxCut *maximizes* crossing edges (no balance constraint); Bisection *minimizes* with equal partition constraint
- *Approximation:* $O(sqrt(log n))$-approximation (Arora, Rao, Vazirani 2009)
- *Spectral methods:* Fiedler vector gives $O(sqrt(n))$-approximation for bounded-degree graphs

=== Reductions

/ MinimumBisection $arrow.r$ QUBO: (Lucas 2014 §3) Ising: $H = A sum_((i,j) in E) (1-s_i s_j)/2 + B(sum_i s_i)^2$. The $(sum s_i)^2$ term enforces equal partition. QUBO via $x_i = (1-s_i)/2$.
/ MinimumBisection $arrow.r$ ILP: Binary $x_v$. Balance: $sum x_v = n/2$. Crossing: $y_e gt.eq x_u - x_v$, $y_e gt.eq x_v - x_u$. Minimize $sum w_e y_e$.

=== Key References

+ Garey & Johnson (1979) \[ND16\].
+ Lucas (2014). §3.
+ Arora, S., Rao, S. & Vazirani, U. (2009). "Expander flows, geometric embeddings, and graph partitioning." _JACM_, 56(2):1--37.

#v(0.5em)

== Edge Coloring <subsec:edgecoloring>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given undirected graph $G = (V,E)$ and integer $k$, find a proper edge coloring $c: E arrow.r {0, dots, k-1}$ such that no two edges sharing a vertex have the same color.

=== Complexity Analysis

- *Decision:* NP-complete for $k = Delta$ (Holyer 1981) where $Delta$ = max degree
- *Vizing's theorem (1964):* chromatic index $chi'(G) in {Delta, Delta + 1}$ for simple graphs
  - Class 1: $chi'(G) = Delta$ (most graphs)
  - Class 2: $chi'(G) = Delta + 1$ (e.g., odd cycles, Petersen graph)
- *König's theorem:* For bipartite graphs, $chi'(G) = Delta$ always (polynomial)
- *Shannon's theorem:* $chi'(G) lt.eq floor(3 Delta \/ 2)$ for multigraphs

=== Reductions

/ EdgeColoring $arrow.r$ KColoring: Via *line graph* $L(G)$. Edge coloring of $G$ = vertex coloring of $L(G)$.
  $L(G)$: one vertex per edge of $G$; two vertices adjacent iff corresponding edges share an endpoint.
/ EdgeColoring $arrow.r$ ILP: Binary $x_(e,c)$ per edge-color pair. Per vertex: all incident edges get distinct colors.

=== Key References

+ Vizing, V.G. (1964). "On an estimate of the chromatic class of a $p$-graph." _Diskret. Analiz._, 3:25--30.
+ Holyer, I. (1981). "The NP-completeness of edge-colouring." _SIAM J. Computing_, 10(4):718--720.

#v(0.5em)

== Max $k$-Cut <subsec:maxkcut>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-hard for all $k gt.eq 2$ $dot.c$ Type: Optimization (Maximize)
]

=== Definition

Given undirected weighted graph $G = (V,E)$ and integer $k gt.eq 2$, partition $V$ into $k$ groups to maximize total weight of edges between different groups.

=== Complexity Analysis

- *NP-hard for all $k gt.eq 2$* (Kann et al. 1997)
- *$k=2$:* This is Max-Cut (already implemented)
- *Approximation:* SDP-based $(1 - 1/k)$-approximation (Frieze & Jerrum 1997)
- *Relation to coloring:* If optimal Max $k$-Cut = total edge weight, a proper $k$-coloring exists
- *No equal-size constraint* (unlike Graph Partitioning / Bisection)

=== Reductions

/ Max $k$-Cut $arrow.r$ QUBO: One-hot encoding: $k-1$ binary variables per vertex. Penalty for same-partition adjacency.
/ MaxCut $arrow.r$ Max $k$-Cut: Set $k = 2$. Trivial embedding.

=== Key References

+ Kann, V. et al. (1997). "Hardness of approximating Max $k$-Cut." _Algorithmica_, 18(4):462--476.
+ Frieze, A. & Jerrum, M. (1997). "Improved approximation algorithms for MAX $k$-CUT." _Algorithmica_, 18(1):67--81.

#v(0.5em)

== Longest Path <subsec:longestpath>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-hard $dot.c$ Type: Optimization (Maximize)
]

=== Definition

Given undirected weighted graph $G = (V,E)$ and vertices $s, t in V$, find the longest *simple* (no repeated vertices) path from $s$ to $t$.

=== Complexity Analysis

- *NP-hard* (Garey & Johnson 1979) \[ND29\], even for unweighted graphs
- *Contrast with shortest path:* Shortest path is polynomial (Dijkstra, Bellman-Ford); longest path is NP-hard --- optimization direction changes complexity class
- *For DAGs:* Polynomial via topological sort + DP
- *Relation to Hamiltonian path:* Hamiltonian path exists iff longest path has length $|V| - 1$

=== Reductions

/ HamiltonianCycle $arrow.r$ LongestPath: Hamiltonian path from $s$ to $t$ exists iff longest simple path has length $n-1$.
/ LongestPath $arrow.r$ ILP: Flow-based formulation with path connectivity constraints.

=== Key References

+ Garey & Johnson (1979) \[ND29\].

#v(0.5em)

== Minimal Maximal Matching <subsec:minimalmatch>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-hard $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given undirected graph $G = (V,E)$, find a *maximal* matching $M$ (cannot add any edge without violating the matching property) of *minimum* cardinality.

=== Complexity Analysis

- *NP-hard* (Yannakakis & Gavril 1980)
- *2-approximation:* Any maximal matching has size $gt.eq |M^*| / 2$ where $M^*$ = maximum matching. So max matching / 2 $lt.eq$ min maximal matching $lt.eq$ max matching.
- *Relation to Maximum Matching:* Maximum Matching (already implemented) *maximizes*; this *minimizes among maximal* matchings
- *Relation to MaximalIS:* Follows the `MaximalIS` pattern in the codebase (maximality + optimization)

=== Reductions

/ MinimalMaximalMatching $arrow.r$ QUBO: (Lucas 2014 §4.5) Edge variables with matching + maximality penalties.
/ MinimalMaximalMatching $arrow.r$ ILP: Binary $y_e$. Matching: $sum_(e in.rev v) y_e lt.eq 1$. Maximality: for each edge $(u,v)$: $y_e + sum_(e' in.rev u) y_(e') + sum_(e' in.rev v) y_(e') gt.eq 1$. Minimize $sum y_e$.

=== Key References

+ Yannakakis, M. & Gavril, F. (1980). "Edge dominating sets in graphs." _SIAM J. Applied Mathematics_, 38(3):364--372.
+ Lucas (2014). §4.5.

#v(0.5em)

== Feedback Vertex Set <subsec:fvs>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#7* $dot.c$ Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given a *directed* graph $G = (V,A)$, find minimum-size $F subset.eq V$ such that $G - F$ is acyclic (a DAG).

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[GT7\], both directed and undirected
- *Parameterized:* FPT in solution size $k$: $O(3.618^k dot n^(O(1)))$ (Chen et al. 2008)
- *Approximation:* $O(log n log log n)$-approximation for directed; 2-approximation for undirected (Bafna et al. 1999)
- *For tournaments:* Polynomial (FVS in tournaments has $O(n^2)$ algorithm)
- *Infrastructure:* Requires directed graph support (not yet in codebase); needs cycle detection via DFS/Kahn's algorithm

=== Reductions

/ FeedbackVertexSet $arrow.r$ ILP: Ordering-based: introduce ordering $y_v$ per vertex. For each arc $(u,v)$: $y_u < y_v + M dot (x_u + x_v)$. Minimize $sum x_v$.
  Alternative: cycle-based: for each cycle $C$: $sum_(v in C) x_v gt.eq 1$ (exponential constraints, use lazy generation).

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[GT7\].
+ Chen, J. et al. (2008). "A fixed-parameter algorithm for the directed feedback vertex set problem." _JACM_, 55(5):21.

#v(0.5em)

== Feedback Arc Set <subsec:fas>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#8* $dot.c$ Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given a directed graph $G = (V,A)$, find minimum-weight $F subset.eq A$ such that $G - F$ is acyclic.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[GT8\]
- *Complement:* Maximum Acyclic Subgraph = total weight $-$ FAS (not a separate problem)
- *For tournaments:* $exists$ PTAS (Kenyon-Mathieu & Schudy 2007)
- *Approximation:* $O(log n log log n)$-approximation (Even et al. 2000)
- *Applications:* deadlock resolution, ranking, scheduling

=== Reductions

/ FeedbackArcSet $arrow.r$ ILP: Ordering-based: for each vertex $v$, ordering position $y_v$. For each arc $(u,v)$: $y_u < y_v + M dot x_e$ where $x_e = 1$ means arc removed. Minimize $sum w_e x_e$.
/ FeedbackArcSet $arrow.l.r$ FeedbackVertexSet: Known structural transformations exist between vertex and arc versions.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[GT8\].
+ Even, G. et al. (2000). "Approximating minimum feedback sets in directed graphs." _Algorithmica_, 26:439--448.

#v(0.5em)

== Steiner Tree <subsec:steinertree>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  *Karp \#16* $dot.c$ Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given undirected weighted graph $G = (V,E)$ with edge weights $w: E arrow.r RR^+$ and terminal set $R subset.eq V$, find a minimum-weight tree spanning all terminals. The tree may use non-terminal (Steiner) vertices.

=== Complexity Analysis

- *Decision:* NP-complete (Karp 1972; Garey & Johnson 1979) \[ND7\], even for unit weights
- *For $|R| = 2$:* Shortest path (polynomial)
- *For $|R| = |V|$:* Minimum spanning tree (polynomial)
- *Approximation:* $(ln 4 + epsilon)$-approximation (Byrka et al. 2013), best known $approx 1.39$
- *Steiner ratio:* optimal Steiner tree weight $gt.eq$ MST weight on terminals $slash 2$

=== Reductions

/ SteinerTree $arrow.r$ ILP: Flow-based. Binary edge variables $x_e$. For each terminal pair $(r_i, r_j)$: flow conservation ensuring connectivity. Minimize $sum w_e x_e$. *Overhead:* $O(|R| dot |E|)$ variables.
/ VertexCover $arrow.r$ SteinerTree: Known Karp chain reduction.

=== Key References

+ Karp (1972), Garey & Johnson (1979) \[ND7\].
+ Byrka, J. et al. (2013). "Steiner Tree Approximation via Iterative Randomized Rounding." _JACM_, 60(1):6.

#v(0.5em)

== Multiway Cut <subsec:multiwaycut>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-hard for $k gt.eq 3$ $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given undirected weighted graph $G = (V,E)$ and terminals $T = {t_1, dots, t_k}$, find minimum-weight edge set whose removal disconnects every pair of terminals.

=== Complexity Analysis

- *$k = 2$:* Minimum cut (polynomial, Ford-Fulkerson)
- *$k gt.eq 3$:* NP-hard (Dahlhaus et al. 1992)
- *Approximation:* $(2 - 2/k)$-approximation via isolating cuts; $1.3438$-approximation (Cǎlinescu et al. 2000) via LP relaxation + randomized rounding

=== Reductions

/ MultiwayCut $arrow.r$ ILP: Binary $x_e$ per edge. For each terminal pair: at least one edge on every path must be cut. Flow-based constraints.

=== Key References

+ Dahlhaus, E. et al. (1992). "The complexity of multiway cuts." _Proc. STOC_, pp. 241--251.
+ Cǎlinescu, G. et al. (2000). "A new approach to multiway cuts." _JCSS_, 60(3):564--574.

#v(0.5em)

== Graph Partitioning ($k$-way) <subsec:graphpartitioning>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` $dot.c$ Complexity: NP-complete $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given undirected weighted graph $G = (V,E)$ and integer $k$, partition $V$ into $k$ *equal-size* groups minimizing total crossing edge weight.

=== Complexity Analysis

- *$k=2$:* Minimum Bisection (proposed separately)
- *General $k$:* NP-complete (Garey & Johnson 1979)
- *Approximation:* $O(sqrt(log n log k))$ via SDP (Krauthgamer & Naor 2006)
- *Applications:* parallel computing, VLSI, load balancing

=== Reductions

/ GraphPartitioning $arrow.r$ QUBO: (Lucas 2014 §2) One-hot vertex-to-partition assignment. Balance penalty: $(sum_v x_(v,p) - n/k)^2$ per partition.
/ MinimumBisection $arrow.r$ GraphPartitioning: Set $k = 2$.

=== Key References

+ Garey & Johnson (1979). Lucas (2014) §2.

#v(0.5em)

== Quadratic Assignment Problem <subsec:qap>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `optimization` $dot.c$ Complexity: NP-hard $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given $n$ facilities and $n$ locations, flow matrix $F_(i j)$ and distance matrix $D_(i j)$, find permutation $pi$ minimizing $sum_(i,j) F_(i j) dot D_(pi(i),pi(j))$.

=== Complexity Analysis

- *NP-hard* (Garey & Johnson 1979) \[ND43\], even to approximate within any constant factor (Sahni & Gonzalez 1976)
- *One of the hardest optimization problems:* no polynomial-time approximation scheme unless P=NP
- *Generalizes TSP:* Set $F$ = adjacency matrix of a cycle, $D$ = distance matrix $arrow.r$ TSP
- *$n^2$ binary variables* (permutation matrix encoding)

=== Reductions

/ QAP $arrow.r$ QUBO: (Lucas 2014 §8) $n^2$ binary variables $x_(i j) = 1$ iff facility $i$ at location $j$. Permutation penalty: $B sum_i (sum_j x_(i j) - 1)^2 + B sum_j (sum_i x_(i j) - 1)^2$.
/ TSP $arrow.r$ QAP: TSP is QAP where $F$ = cycle adjacency matrix.

=== Key References

+ Koopmans, T.C. & Beckmann, M. (1957). "Assignment problems and the location of economic activities." _Econometrica_, 25(1):53--76.
+ Sahni, S. & Gonzalez, T. (1976). "P-complete approximation problems." _JACM_, 23(3):555--565.

#pagebreak()

// ============================================================
= Satisfiability Problems (Extended)
// ============================================================

== Maximum Satisfiability (MaxSAT) <subsec:maxsat>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `satisfiability` $dot.c$ Complexity: NP-hard $dot.c$ Type: Optimization (Maximize)
]

=== Definition

Given CNF formula $phi$ with clauses $C_1, dots, C_m$ and weights $w_j$, find truth assignment maximizing $sum_(j: C_j "satisfied") w_j$.

=== Complexity Analysis

- *NP-hard* (optimization version of SAT)
- *When satisfiable:* optimal = total weight (reduces to SAT)
- *MAX-2-SAT:* NP-hard; SDP gives 0.9401-approximation (Lewin et al. 2002)
- *MAX-3-SAT:* NP-hard; 7/8-approximation is optimal unless P=NP (Håstad 2001)
- *Annual competition:* MaxSAT Evaluation (practical solvers highly optimized)

=== Reductions

/ MaxSAT $arrow.r$ QUBO: Each clause $C_j = (l_1 or dots or l_k)$: penalty $P(C_j) = product_("pos") (1-x_i) dot product_("neg") x_i$.
  - MAX-2-SAT: direct QUBO (no auxiliary variables)
  - MAX-3-SAT: one auxiliary variable per clause
  - General $k$: $k-2$ auxiliary variables per clause

/ MaxSAT $arrow.r$ ILP: Binary $x_i$ per variable, $y_j$ indicator per clause. Maximize $sum w_j y_j$.
/ Satisfiability $arrow.r$ MaxSAT: All weights = 1. Satisfiable iff optimal = $m$.

=== Key References

+ Håstad, J. (2001). "Some optimal inapproximability results." _JACM_, 48(4):798--859.
+ Lewin, M. et al. (2002). "A tighter 0.9401 semidefinite bound for MAX-2-SAT." unpublished.
+ Annual MaxSAT Evaluation: https://maxsat-evaluations.github.io/

#pagebreak()

// ============================================================
= Structural / Decision Diagram Problems
// ============================================================

These problems concern *structural graph parameters* that bound the complexity of solving other NP-hard problems.

== Treewidth <subsec:treewidth>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` (structural) $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given undirected graph $G = (V,E)$ and integer $k$, determine whether $G$ has treewidth $lt.eq k$. A *tree decomposition* is a tree $T$ with bags $B_i subset.eq V$ satisfying:
+ Every $v in V$ appears in some bag
+ For every $(u,v) in E$, some bag contains both $u$ and $v$
+ For every $v$, the bags containing $v$ form a connected subtree
Width $= max_i |B_i| - 1$.

=== Complexity Analysis

- *Decision:* NP-complete (Arnborg et al. 1987)
- *Fixed-parameter tractable:* $O(2^(O(k^3)) dot n)$ algorithm (Bodlaender 1996) for fixed $k$
- *Exact:* $O^*(2^n)$ (Fomin et al. 2006)
- *Bounds:*
  - $"tw"(G) lt.eq "pw"(G)$ always
  - $"tw"(G) lt.eq "pw"(G) lt.eq "tw"(G) dot O(log n)$
  - Trees: $"tw" = 1$, $"pw" = floor(log_2 n)$
  - Grids $n times n$: $"tw" = "pw" = n$
  - Planar: $"tw" lt.eq O(sqrt(n))$
- *BDD/tensor connection:* MDD size $lt.eq 2^("tw")$, tensor contraction cost $lt.eq 2^("tw"+1)$

=== Reductions

/ Treewidth $arrow.r$ ILP: Elimination ordering: binary $x_(i j)$ for "vertex $i$ before $j$". Minimize maximum fill-in degree. $O(n^3)$ constraints.
/ Pathwidth $arrow.r$ Treewidth: Every path decomposition is a tree decomposition. $"pw"(G) gt.eq "tw"(G)$.

=== Key References

+ Robertson, N. & Seymour, P.D. (1986). "Graph minors. II." _J. Algorithms_, 7(3):309--322.
+ Arnborg, S. et al. (1987). "Complexity of finding embeddings in a k-tree." _SIAM J. Algebraic Discrete Methods_, 8(2):277--284.
+ Bodlaender, H.L. (1996). "A linear-time algorithm for finding tree-decompositions of small treewidth." _SIAM J. Computing_, 25(6):1305--1317.

#v(0.5em)

== Pathwidth <subsec:pathwidth>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `graph` (structural) $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given graph $G$ and integer $k$, determine whether $G$ has pathwidth $lt.eq k$. Same as treewidth but the decomposition tree must be a *path* (bags form a linear sequence).

=== Complexity Analysis

- *Decision:* NP-complete (Arnborg et al. 1987)
- *Equivalences:* pathwidth = vertex separation number = node search number = interval thickness $- 1$
- *Already in codebase:* `pathdecomposition.rs` computes pathwidth heuristically
- *BDD connection:* BDD size $lt.eq 2^("pw")$ for functions on the variable interaction graph

=== Key References

+ Robertson & Seymour (1983). Kinnersley (1992). Arnborg et al. (1987).

#v(0.5em)

== BDD Variable Ordering <subsec:bddordering>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `structural` (DD) $dot.c$ Complexity: NP-complete $dot.c$ Type: Satisfaction
]

=== Definition

Given Boolean function $f$ (truth table over $n$ variables) and integer $k$, does there exist a variable ordering $pi$ such that the ROBDD for $f$ under $pi$ has $lt.eq k$ nodes?

=== Complexity Analysis

- *NP-complete* (Bollig & Wegener 1996)
- *Inapproximable* within any constant factor unless P=NP
- *ROBDD size* can vary *exponentially* between orderings: multiplication function needs $Theta(2^(n\/2))$ with bad ordering, $O(n^3)$ with good ordering
- *Heuristics:* sifting (Rudell 1993), window permutation, genetic algorithms
- *Meta-problem:* optimizing the problem-solving tool itself is NP-hard

=== Key References

+ Bollig, B. & Wegener, I. (1996). "Improving the variable ordering of OBDDs is NP-complete." _IEEE Trans. Computers_, 45(9):993--1002.
+ Bryant, R.E. (1986). "Graph-based algorithms for Boolean function manipulation." _IEEE Trans. Computers_, 35(8):677--691.
+ Friedman, S.J. & Supowit, K.J. (1990). "Finding the optimal variable ordering for BDDs." _IEEE Trans. Computers_, 39(5):710--713.

#v(0.5em)

== Optimal Contraction Ordering <subsec:contraction>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `structural` (tensor) $dot.c$ Complexity: NP-hard $dot.c$ Type: Optimization (Minimize)
]

=== Definition

Given tensor network as hypergraph $H = (V, E)$ with tensor dimensions, find contraction ordering minimizing total cost (sum or max of intermediate tensor sizes).

=== Complexity Analysis

- *NP-hard* (via reduction from treewidth)
- *Equivalence:* Optimal max-width contraction = treewidth of the line graph
- *Exponential impact:* Good vs bad ordering = feasible vs infeasible computation
- *Special case:* Matrix chain multiplication (path hypergraph) is polynomial via $O(n^3)$ DP
- *State of the art:* Hyper-optimized tensor contraction (Gray & Kourtis 2021) achieves $>10000 times$ speedup

=== Key References

+ Markov, I.L. & Shi, Y. (2008). "Simulating quantum computation by contracting tensor networks." _SIAM J. Computing_, 38(3):963--981.
+ Gray, J. & Kourtis, S. (2021). "Hyper-optimized tensor network contraction." _Quantum_, 5:410.

#v(0.5em)

== Minimum Width Decision Diagram <subsec:minwidthdd>

#block(stroke: 0.5pt + gray, inset: 8pt, radius: 3pt)[
  Category: `structural` (DD) $dot.c$ Complexity: NP-hard $dot.c$ Type: Satisfaction
]

=== Definition

Given constraints over $n$ discrete variables and target width $w$, does an exact MDD with width $lt.eq w$ exist?

=== Complexity Analysis

- *NP-hard* for most constraint sets
- *Equivalence:* Minimum exact MDD width = pathwidth of constraint interaction graph $+ 1$
- *Practical impact:* Controls when relaxed DDs (with merging) are needed

=== Key References

+ Bergman et al. (2016). _Decision Diagrams for Optimization_. Springer.

#pagebreak()

// ============================================================
= Missing Cross-Reductions (Existing Problems)
// ============================================================

These are reductions between *already-implemented* problems that should be added to densify the reduction graph.

== MaxClique $arrow.l.r$ MIS (Complement Graph) <subsec:clique-mis>

*Fundamental equivalence.* $"MaxClique"(G) = "MIS"(overline(G))$. Both problems exist in codebase but the direct reduction is missing. Requires complement graph utility. *Overhead:* $O(n^2)$.

== HamiltonianCycle $arrow.r$ TSP <subsec:hamcycle-tsp>

*Most famous CS reduction.* Set edge weight = 1 if edge exists, $M$ (big number) otherwise. TSP tour cost $= n$ iff Hamiltonian cycle exists. Both problems exist. *Overhead:* $O(n^2)$.

== DominatingSet $arrow.r$ SetCovering <subsec:ds-sc>

*Natural graph$arrow.r$set bridge.* Universe = $V$. For each $v$, set $S_v = {v} union N(v)$ (closed neighborhood). Both exist. *Overhead:* $O(n + m)$.

== MaxClique $arrow.r$ QUBO (Direct) <subsec:clique-qubo>

(Lucas 2014 §3.2) $H = -A sum_v x_v + B sum_((u,v) in.not E) x_u x_v$. Direct QUBO avoids ILP intermediate. *Overhead:* $n$ variables.

== DominatingSet $arrow.r$ QUBO (Direct) <subsec:ds-qubo>

(Lucas 2014 §4.3) Penalty for non-dominated vertices. Complex neighborhood encoding.

== SAT $arrow.r$ MaxCut <subsec:sat-maxcut>

Garey-Johnson-Stockmeyer (1976) gadget construction. Each clause $arrow.r$ gadget in MaxCut graph. *Difficulty:* Tier 3.

== SpinGlass $arrow.r$ MaxSAT <subsec:sg-maxsat>

Exists in Julia `spinglass_sat.jl` but not in Rust. Would close the cycle SAT $arrow.r$ MIS $arrow.r$ QUBO $arrow.r$ SpinGlass $arrow.r$ SAT. More natural as SpinGlass $arrow.r$ MaxSAT.

#pagebreak()

// ============================================================
= Summary Tables
// ============================================================

== Problem Complexity Classification

#table(
  columns: (auto, auto, auto, auto, auto),
  align: (left, center, center, center, left),
  stroke: 0.5pt,
  [*Problem*], [*Karp \#*], [*Complexity*], [*Type*], [*Category*],
  [Subset Sum], [\#18], [NP-c (weak)], [Satisfaction], [`number`],
  [Partition], [\#20], [NP-c (weak)], [Satisfaction], [`number`],
  [Knapsack], [\#18+], [NP-c (weak)], [Optimization], [`number`],
  [Job Sequencing], [\#19], [NP-c], [Optimization], [`number`],
  [Hitting Set], [\#15], [NP-c], [Optimization], [`set`],
  [Exact Cover], [\#14], [NP-c], [Satisfaction], [`set`],
  [3D Matching], [\#17], [NP-c], [Satisfaction], [`set`],
  [Clique Cover], [\#13], [NP-c], [Satisfaction], [`graph`],
  [Minimum Bisection], [---], [NP-c], [Optimization], [`graph`],
  [Edge Coloring], [---], [NP-c], [Satisfaction], [`graph`],
  [Max $k$-Cut], [---], [NP-h], [Optimization], [`graph`],
  [Longest Path], [---], [NP-h], [Optimization], [`graph`],
  [Min. Maximal Matching], [---], [NP-h], [Optimization], [`graph`],
  [Feedback Vertex Set], [\#7], [NP-c], [Optimization], [`graph`],
  [Feedback Arc Set], [\#8], [NP-c], [Optimization], [`graph`],
  [Steiner Tree], [\#16], [NP-c], [Optimization], [`graph`],
  [Multiway Cut], [---], [NP-h ($k gt.eq 3$)], [Optimization], [`graph`],
  [Graph Partitioning], [---], [NP-c], [Optimization], [`graph`],
  [QAP], [---], [NP-h], [Optimization], [`optimization`],
  [MaxSAT], [---], [NP-h], [Optimization], [`satisfiability`],
  [Treewidth], [---], [NP-c], [Satisfaction], [`graph`],
  [Pathwidth], [---], [NP-c], [Satisfaction], [`graph`],
  [BDD Variable Ordering], [---], [NP-c], [Satisfaction], [`structural`],
  [Contraction Ordering], [---], [NP-h], [Optimization], [`structural`],
  [Min-Width DD], [---], [NP-h], [Satisfaction], [`structural`],
)

== Karp's 21 Completion Status

After implementing all proposals:

#table(
  columns: (auto, auto, auto),
  align: (left, center, left),
  stroke: 0.5pt,
  [*Karp Problem*], [*Status*], [*Codebase Name*],
  [\#1 SAT], [Implemented], [`Satisfiability`],
  [\#2 0-1 IP], [Implemented], [`ILP`],
  [\#3 Clique], [Implemented], [`MaximumClique`],
  [\#4 Set Packing], [Implemented], [`MaximumSetPacking`],
  [\#5 Vertex Cover], [Implemented], [`MinimumVertexCover`],
  [\#6 Set Covering], [Implemented], [`MinimumSetCovering`],
  [\#7 Feedback Node Set], [*Proposed*], [`MinimumFeedbackVertexSet`],
  [\#8 Feedback Arc Set], [*Proposed*], [`MinimumFeedbackArcSet`],
  [\#9 Directed Ham. Circuit], [Implemented], [`HamiltonianCycle`],
  [\#10 Undir. Ham. Circuit], [Implemented], [`HamiltonianCycle`],
  [\#11 3-SAT], [Implemented], [`KSatisfiability<K3>`],
  [\#12 Chromatic Number], [Implemented], [`KColoring`],
  [\#13 Clique Cover], [*Proposed*], [`CliqueCover`],
  [\#14 Exact Cover], [*Proposed*], [`ExactCover`],
  [\#15 Hitting Set], [*Proposed*], [`MinimumHittingSet`],
  [\#16 Steiner Tree], [*Proposed*], [`SteinerTree`],
  [\#17 3D Matching], [*Proposed*], [`ThreeDimensionalMatching`],
  [\#18 Knapsack/SubsetSum], [*Proposed*], [`SubsetSum` + `Knapsack`],
  [\#19 Job Sequencing], [*Proposed*], [`JobSequencing`],
  [\#20 Partition], [*Proposed*], [`Partition`],
  [\#21 Max Cut], [Implemented], [`MaxCut`],
)

== Infrastructure Requirements

#table(
  columns: (auto, auto, auto),
  stroke: 0.5pt,
  [*Gap*], [*Impact*], [*Blocks*],
  [`number/` category], [New directory + `mod.rs`], [SubsetSum, Partition, Knapsack, JobSequencing],
  [Directed graph support], [No `DiGraph`; workaround with `Vec<(usize,usize)>`], [FVS, FAS],
  [Complement graph utility], [`complement()` on `SimpleGraph` (~15 LOC)], [MaxClique↔MIS, CliqueCover↔KColoring],
  [Line graph construction], [$L(G)$ transformation], [EdgeColoring → KColoring],
  [Non-binary domains], [`dims = vec![k; n]` untested at scale], [Pathwidth, Treewidth, BDDVarOrder],
)

// ============================================================
// Bibliography
// ============================================================

#pagebreak()

= References

#set par(hanging-indent: 1.5em)

Arnborg, S., Corneil, D.G. & Proskurowski, A. (1987). "Complexity of finding embeddings in a k-tree." _SIAM J. Algebraic Discrete Methods_, 8(2):277--284.

Bergman, D. et al. (2016). _Decision Diagrams for Optimization_. Springer.

Bodlaender, H.L. (1996). "A linear-time algorithm for finding tree-decompositions of small treewidth." _SIAM J. Computing_, 25(6):1305--1317.

Bollig, B. & Wegener, I. (1996). "Improving the variable ordering of OBDDs is NP-complete." _IEEE Trans. Computers_, 45(9):993--1002.

Bryant, R.E. (1986). "Graph-based algorithms for Boolean function manipulation." _IEEE Trans. Computers_, 35(8):677--691.

Byrka, J. et al. (2013). "Steiner Tree Approximation via Iterative Randomized Rounding." _JACM_, 60(1):6.

Dahlhaus, E. et al. (1992). "The complexity of multiway cuts." _Proc. STOC_, pp. 241--251.

Garey, M.R. & Johnson, D.S. (1979). _Computers and Intractability: A Guide to the Theory of NP-Completeness_. Freeman.

Gray, J. & Kourtis, S. (2021). "Hyper-optimized tensor network contraction." _Quantum_, 5:410.

Holyer, I. (1981). "The NP-completeness of edge-colouring." _SIAM J. Computing_, 10(4):718--720.

Håstad, J. (2001). "Some optimal inapproximability results." _JACM_, 48(4):798--859.

Kann, V. et al. (1997). "Hardness of approximating Max $k$-Cut." _Algorithmica_, 18(4):462--476.

Karp, R.M. (1972). "Reducibility Among Combinatorial Problems." _Complexity of Computer Computations_, pp. 85--103.

Koopmans, T.C. & Beckmann, M. (1957). "Assignment problems and the location of economic activities." _Econometrica_, 25(1):53--76.

Lucas, A. (2014). "Ising formulations of many NP problems." _Frontiers in Physics_, 2:5. arXiv:1302.5843.

Markov, I.L. & Shi, Y. (2008). "Simulating quantum computation by contracting tensor networks." _SIAM J. Computing_, 38(3):963--981.

Robertson, N. & Seymour, P.D. (1986). "Graph minors. II." _J. Algorithms_, 7(3):309--322.

Vizing, V.G. (1964). "On an estimate of the chromatic class of a $p$-graph." _Diskret. Analiz._, 3:25--30.

Yannakakis, M. & Gavril, F. (1980). "Edge dominating sets in graphs." _SIAM J. Applied Mathematics_, 38(3):364--372.
