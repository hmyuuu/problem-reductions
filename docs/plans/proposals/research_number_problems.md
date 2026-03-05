# Complexity Theory Research: Number Problems

**Date:** 2026-02-27
**Scope:** Detailed complexity-theoretic reference for SubsetSum, Partition, Knapsack (0-1), and JobSequencing in the `problem-reductions` codebase.

---

## Table of Contents

1. [Subset Sum](#1-subset-sum)
2. [Partition](#2-partition)
3. [0-1 Knapsack](#3-0-1-knapsack)
4. [Job Sequencing with Deadlines](#4-job-sequencing-with-deadlines)
5. [Cross-Problem Relationships](#5-cross-problem-relationships)
6. [References](#6-references)

---

## 1. Subset Sum

### 1.1 Problem Definition

Given a set of integers A = {a₀, …, aₙ₋₁} and a target t ∈ ℤ, decide whether ∃ S ⊆ {0,…,n-1} such that Σᵢ∈S aᵢ = t.

### 1.2 Original NP-Completeness Result

**Primary reference:**
Karp, R.M. (1972). "Reducibility Among Combinatorial Problems." In R.E. Miller & J.W. Thatcher (Eds.), *Complexity of Computer Computations*. Plenum Press, New York, pp. 85–103.
DOI: `10.1007/978-1-4684-2001-2_9`
Karp's **Problem #18** is called "KNAPSACK" but its formulation is strictly the decision version of Subset Sum (given a set and a target capacity, can you select items totaling exactly that capacity). The reduction chain in Karp's Figure 1 runs: EXACT COVER → **KNAPSACK (#18)** → JOB SEQUENCING (#19) → PARTITION (#20) → MAX-CUT (#21).

**Secondary reference (standard textbook citation):**
Garey, M.R. & Johnson, D.S. (1979). *Computers and Intractability: A Guide to the Theory of NP-Completeness*. W.H. Freeman, New York.
Problem [SP13]: "SUBSET SUM". Proved NP-complete by polynomial transformation from 3-SAT via the Garey-Johnson catalog.

**Note on naming:** Karp's paper calls the problem "KNAPSACK" but defines it as what is now universally called Subset Sum. The modern 0-1 Knapsack (with separate weights and values) is a generalization. Garey & Johnson distinguish them as [SP13] (Subset Sum) and [MP9] (0-1 Knapsack).

### 1.3 Weak vs. Strong NP-Completeness

Subset Sum is **weakly NP-complete** (Garey & Johnson 1979, Theorem 4.2):
- It is NP-complete under standard (binary) encoding.
- It becomes polynomial-time solvable when numbers are encoded in unary (because the DP runs in time polynomial in the unary input size).
- It does **not** remain NP-hard when all input numbers are polynomially bounded (it becomes pseudo-polynomial).

This is in contrast to **strongly NP-complete** problems (e.g., 3-Partition, Bin Packing) which remain NP-complete even when all numeric parameters are bounded by a polynomial in n.

**Formal criterion:** An NP-complete problem Π is weakly NP-complete if it admits a pseudo-polynomial time algorithm. An NP-complete problem Π is strongly NP-complete if it is NP-complete even when all numeric parameters are bounded by a polynomial in the encoding length.

### 1.4 Pseudo-Polynomial Algorithm

**Bellman's DP (1956/1957):**
Bellman, R.E. (1956). "Notes on the Theory of Dynamic Programming IV — Maximization over Discrete Sets." *Naval Research Logistics Quarterly*, 3(1-2):67–70.

Standard DP table: `dp[i][s] = true` iff there exists a subset of the first i elements summing to s.

- **Time:** O(n · t), where t is the target value
- **Space:** O(n · t), reducible to O(t) by processing rows sequentially
- **Why pseudo-polynomial:** t is not bounded by a polynomial in the bit-length of the input (⌈log₂ t⌉ bits). If t = 2^n, the algorithm takes O(n · 2^n) time — exponential.

**Modern improvements:** See §1.7 (Best Known Exact Algorithms).

### 1.5 FPTAS / Approximation

For the **optimization variant** (find subset sum closest to t without exceeding it):
- An **FPTAS** exists with running time O(n · min(n/ε, √t)) via scaling and rounding of DP.
- For the **decision problem**, approximation is not directly applicable (it is a yes/no question), but the closest-subset-sum optimization has FPTAS.
- Reference: Ibarra, O.H. & Kim, C.E. (1975). "Fast approximation algorithms for the knapsack and sum of subset problems." *JACM*, 22(4):463–468. DOI: `10.1145/321906.321909`

**Note:** Since Subset Sum is a satisfaction (decision) problem in the codebase, the FPTAS applies to the associated optimization version. No approximation algorithm exists for the decision version itself (it is exact-answer required).

### 1.6 Parameterized Complexity

- **Parameter n (number of items):** W[1]-hard when parameterized by solution size k (number of items chosen). The k-SUM problem (find k elements summing to 0) is not believed to be FPT.
- **Parameter max-element value w:** FPT in w via DP in O(n · w) time; this is the pseudo-polynomial algorithm.
- **Parameter target t:** FPT in t via DP; same pseudo-polynomial algorithm.
- **Bringmann's ~O(n + t) algorithm** (2017): Near-optimal for the decision version; see §1.7.

FPT connection to FPTAS (Garey & Johnson 1979, Theorem 4.3): **If an NP-hard optimization problem has an FPTAS, then it is FPT with respect to the standard parameterization 1/ε.** Conversely, strongly NP-hard problems cannot have an FPTAS unless P = NP.

### 1.7 Best Known Exact Algorithm

| Algorithm | Complexity | Type | Year |
|---|---|---|---|
| Bellman DP | O(n · t) | Deterministic, pseudo-poly | 1956 |
| Horowitz–Sahni meet-in-middle | O(2^(n/2)) | Deterministic, exponential | 1974 |
| Schroeppel–Shamir | O*(2^(n/2)), O*(2^(n/4)) space | Deterministic | 1981 |
| Bringmann | O~(n + t) | Randomized | SODA 2017 |
| Jin–Wu | O~(n + t) | Randomized, simpler | SOSA 2019 |
| Koiliaris–Xu | O~(√n · t) | Deterministic | SODA 2019 |
| Bringmann–Wellnitz | O~(n) (dense case) | Randomized | SODA 2021 |
| Polak–Rohwedder–Węgrzycki | O~(n + w^(5/3)) | — | 2021 |
| Chen–Lian–Mao–Zhang | O~(n + w^(3/2)) | — | 2023 |

**Key references:**
- Bringmann, K. (2017). "A near-linear pseudopolynomial time algorithm for subset sum." *Proc. SODA*, pp. 1073–1084. arXiv:1610.04712
- Bringmann, K. & Wellnitz, P. (2021). "On near-linear-time algorithms for dense subset sum." *Proc. SODA*, pp. 1777–1796. arXiv:2010.09096
- The O~(n + t) bound is essentially optimal under SETH (Abboud, Bringmann, Hermelin & Shabtay 2019/2022); see §1.8.

**Exact exponential:** Best known exact algorithm is O*(2^(n/2)) (meet-in-the-middle, Horowitz–Sahni 1974). The naive O*(2^n) brute force is superseded by this.

### 1.8 SETH-Based Conditional Lower Bounds

Abboud, A., Bringmann, K., Hermelin, D. & Shabtay, D. (2019/2022). "SETH-Based Lower Bounds for Subset Sum and Bicriteria Path." *ACM Transactions on Algorithms*, 18(1):1–31. arXiv:1704.04546. DOI: `10.1145/3450524`

**Main theorem:** Under SETH, Bellman's O*(t) pseudo-polynomial algorithm for Subset Sum on n numbers and target t cannot be improved to time T^(1-ε) · 2^o(n) for any ε > 0. In particular, the O~(n + t) randomized algorithms (Bringmann 2017, Jin–Wu 2019) are essentially optimal under SETH.

### 1.9 Phase Transition / Average-Case Complexity

**Density parameter:** d = n / log₂(max |aᵢ|)

- **Dense regime (d ≫ 1):** Almost all instances are satisfiable. Random instances are easy.
- **Sparse regime (d ≪ 1):** Hard cryptographic regime. Lagarias–Odlyzko algorithm solves almost all instances with d < 1/(n · polylog(n)) in polynomial time via LLL lattice reduction.
- **Phase transition near d ≈ 1:** Hardness peaks. This is the "cryptographically interesting" regime.

**Lagarias–Odlyzko result:**
Lagarias, J.C. & Odlyzko, A.M. (1985). "Solving low-density subset sum problems." *JACM*, 32(1):229–246. DOI: `10.1145/2455.2461`

The algorithm reduces low-density Subset Sum to finding a short vector in a lattice, then applies the LLL basis reduction algorithm. **Theorem:** For d < c/n (for some constant c), almost all instances are solvable in polynomial time.

**Average-case hardness (k-SUM variant):**
Worst-case to average-case reductions exist for the k-SUM problem; any sub-polynomial improvement over k-SUM in the average case would imply super-polynomial improvements for lattice problems. See: "On the Hardness of Average-case k-SUM," arXiv:2010.08821.

### 1.10 Special Cases Solvable in Polynomial Time

| Special Case | Condition | Algorithm |
|---|---|---|
| All numbers in {0,1} | Binary inputs | O(n) |
| Numbers bounded by polynomial | Values ≤ poly(n) | Pseudo-poly DP in polynomial total time |
| Low-density instances | d < c/n | LLL lattice reduction (Lagarias–Odlyzko) |
| Numbers in arithmetic progression | a_i = a₀ + i·Δ | O(n log n) via Fourier methods |
| Fixed number of distinct values | Bounded range | O(n · (distinct values)) |

### 1.11 Quantum Algorithms

- **Grover search:** Provides O(2^(n/2)) quantum time, matching classical meet-in-the-middle but with only O(n) qubits (no polynomial space requirement).
- **Best known quantum:** O~(2^(0.226n)) via quantum walk on Johnson graph using QRAQM (Quantum Random Access Memory). Without QRAQM: O(2^(0.48n)).
- **QUBO formulation:** H = A(Σᵢ aᵢxᵢ − t)² with Qᵢᵢ = A(aᵢ² − 2t·aᵢ), Qᵢⱼ = 2A·aᵢ·aⱼ. Ground state energy 0 iff solution exists. (Lucas 2014, §5)
- **D-Wave limitation:** Current quantum annealers handle ~70 QUBO variables effectively, limiting to small instances.

---

## 2. Partition

### 2.1 Problem Definition

Given a multiset of positive integers A = {a₀, …, aₙ₋₁}, decide whether A can be split into two parts with equal sum.

Equivalently: find x ∈ {0,1}ⁿ such that Σᵢ aᵢxᵢ = S/2 where S = Σᵢ aᵢ. If S is odd, immediately unsatisfiable.

### 2.2 Original NP-Completeness Result

**Primary reference:**
Karp, R.M. (1972). "Reducibility Among Combinatorial Problems." Problem **#20: PARTITION**. Proved NP-complete by reduction from JOB SEQUENCING (#19). The exact chain is: KNAPSACK (#18) → JOB SEQUENCING (#19) → **PARTITION (#20)** → MAX-CUT (#21).

**Secondary reference:**
Garey, M.R. & Johnson, D.S. (1979). *Computers and Intractability*. Problem **[SP12]**: "PARTITION". One of six fundamental NP-complete problems in the Garey–Johnson catalog.

Karp's reduction from JOB SEQUENCING to PARTITION: given a job sequencing instance with penalties below k, construct a Partition instance using the penalties as numbers.

### 2.3 Weak vs. Strong NP-Completeness

Partition is **weakly NP-complete:**
- Reduces to Subset Sum with target S/2 in O(n) time.
- Has pseudo-polynomial DP in O(n · S) time.
- Does **not** remain NP-complete when numbers are polynomially bounded.

The related **3-Partition** problem (split into triples, each summing to S/3) is **strongly NP-complete** (Garey & Johnson 1979, [SP15]). This distinction is critical:
- Partition → use pseudo-polynomial DP, FPTAS possible.
- 3-Partition → no pseudo-polynomial algorithm, no FPTAS (unless P = NP).

**Why Partition is the "easiest hard problem":**
Mertens, S. (2003). "The Easiest Hard Problem: Number Partitioning." In *Computational Complexity and Statistical Physics* (Santa Fe Institute Studies in the Sciences of Complexity). pp. 125–139. arXiv:cond-mat/0310317
"Number partitioning is one of the most intensively studied problems in combinatorial optimization... Despite being NP-complete, random instances are often solved trivially by the differencing algorithm."

### 2.4 Pseudo-Polynomial Algorithm

**Standard DP:** Reduce to SubsetSum with target t = S/2. Time O(n · S), space O(S).

**Karmarkar–Karp differencing algorithm:**
Karmarkar, N. & Karp, R.M. (1982). "The differencing method of set partitioning." UC Berkeley Technical Report UCB/CSD 82/113.

Algorithm: Sort numbers in descending order; repeatedly replace the two largest by their absolute difference. O(n log n) time. Does **not** always find the optimal partition, but works for all instances with large S (see phase transition §2.5). Also the basis of the best heuristic for practical Partition instances.

**Approximation ratios of heuristics:**

| Algorithm | Approximation | Time |
|---|---|---|
| Greedy (unsorted) | ≤ 3/2 of optimal | O(n) |
| LPT (sorted greedy) | ≤ 7/6 | O(n log n) |
| Karmarkar–Karp differencing | Empirically near-optimal | O(n log n) |
| FPTAS (via Subset Sum FPTAS) | (1+ε)-optimal | O(n²/ε) |

**FPTAS:** Exists by reduction to Subset Sum FPTAS. Sets target = S/2 and applies the FPTAS for closest-subset-sum. O(n²/ε) time.

### 2.5 Phase Transition / Average-Case Complexity

This is one of the most studied phase transitions in combinatorial optimization.

**Phase transition parameter:** κ = n / log₂(max aᵢ) (same density parameter as Subset Sum).

- **Easy regime (κ ≫ 1):** With high probability, a perfect partition exists and Karmarkar–Karp finds it. Random instances in this regime are trivial.
- **Hard regime (κ ≈ 1):** Transition between "always has perfect partition" and "almost never has perfect partition." Algorithmic difficulty is maximized near this threshold. The Karmarkar–Karp differencing method performs much worse here.
- **Sparse regime (κ ≪ 1):** With high probability, no perfect partition exists.

**Rigorous phase transition proof:**
Borgs, C., Chayes, J. & Pittel, B. (2001). "Phase transition and finite-size scaling for the integer partitioning problem." *Random Structures and Algorithms*, 19(3-4):247–288.

The transition at κ ≈ 0.96 (first identified empirically by Gent & Walsh, then by Mertens via statistical mechanics):

- Mertens, S. (1998). "Phase transition in the number partitioning problem." *Physical Review Letters*, 81(20):4281–4284. DOI: `10.1103/PhysRevLett.81.4281`

**Statistical mechanics connection:**
The partition problem maps to a 1D infinite-range antiferromagnetic Ising model. The ground state energy corresponds to the minimal partition difference. Mertens showed that the phase transition corresponds to a spin glass transition — the hardness of finding the partition corresponds to frustration in the spin glass.

**Average-case complexity:**
For random instances with n numbers drawn uniformly from [1, 2^m]:
- If m < n: exponentially many perfect partitions exist, trivially satisfiable.
- If m > n: with high probability, no perfect partition exists.
- If m ≈ n: hardest instances. Expected number of optimal solutions = O(1).

### 2.6 Polynomial Special Cases

| Special Case | Condition | Algorithm |
|---|---|---|
| Sum is odd | S mod 2 ≠ 0 | Immediately unsatisfiable |
| Two elements | {a, b} | Poly: check a = b |
| All equal elements | aᵢ = c for all i | Poly: check n even |
| Values polynomially bounded | max aᵢ ≤ poly(n) | Pseudo-poly DP in polynomial total time |
| Dense instances (κ ≫ 1) | Karmarkar–Karp almost always succeeds | O(n log n) practical |

### 2.7 Parameterized Complexity

- Partition is trivially parameterized by the **number of elements** n: brute force in O(2^n) is FPT in n.
- No meaningful FPT result known with n as parameter (W[1]-hardness expected since k-SUM is not believed FPT).
- FPT in the **maximum element value** via the pseudo-polynomial DP.

### 2.8 Quantum and QUBO Connections

**Lucas 2014, §5.1 (arXiv:1302.5843):**
Partition has an especially clean Ising formulation. Let sᵢ ∈ {+1,-1} indicate which partition each element belongs to. The Hamiltonian is:

H = A(Σᵢ aᵢsᵢ)²

Ground state energy 0 iff perfect partition exists. Converting to QUBO via xᵢ = (1-sᵢ)/2:

H = A(S - 2·Σᵢ aᵢxᵢ)²

with Qᵢᵢ = A(4aᵢ² - 4S·aᵢ), Qᵢⱼ = 8A·aᵢ·aⱼ. This is one of the simplest and cleanest NP-complete → QUBO reductions.

---

## 3. 0-1 Knapsack

### 3.1 Problem Definition

Given n items with weights wᵢ and values vᵢ (both positive integers), and capacity C, find x ∈ {0,1}ⁿ maximizing Σᵢ vᵢxᵢ subject to Σᵢ wᵢxᵢ ≤ C.

### 3.2 Original NP-Completeness Result

**Primary reference:**
Karp, R.M. (1972). The "KNAPSACK" problem in Karp's paper (#18) is the Subset Sum decision version. The full optimization Knapsack with separate weights and values is a generalization; its NP-completeness follows from Subset Sum (when weights = values, Knapsack reduces to Subset Sum).

**Standard reference:**
Garey, M.R. & Johnson, D.S. (1979). *Computers and Intractability*. Problem **[MP9]**: "KNAPSACK". Proved NP-complete. Classification: Mathematical Programming (MP category).

The decision version: "Is there a selection of items with total weight ≤ C and total value ≥ V?" This is NP-complete by reduction from Subset Sum (set vᵢ = wᵢ, V = C = t).

**Classic algorithm reference:**
Dantzig, G.B. (1957). "Discrete-variable extremum problems." *Operations Research*, 5(2):266–277.
The continuous (fractional) relaxation was solved by Dantzig; the 0-1 constraint makes it NP-hard.

### 3.3 Weak vs. Strong NP-Completeness

0-1 Knapsack is **weakly NP-complete:**
- Under binary encoding of weights and values, NP-complete.
- Under unary encoding (values and weights ≤ polynomial), solvable in polynomial time via DP.
- **Not strongly NP-complete** when weights and values are integers.
- Under rational number encoding (unbounded precision), technically strongly NP-complete — but with an FPTAS still applying.

Kellerer, H., Pferschy, U. & Pisinger, D. (2004). *Knapsack Problems*. Springer. DOI: `10.1007/978-3-540-24777-7` — comprehensive reference on all knapsack variants.

### 3.4 Pseudo-Polynomial Algorithms

**Weight-based DP:** O(n · C) time, O(C) space.

```
dp[c] = max total value using capacity exactly c
dp[c] = max over items i: dp[c - wᵢ] + vᵢ
```

**Value-based DP (Garey–Johnson [MP9]):** O(n · V*) time, where V* = optimal value. Useful when V* ≪ C.

**Space optimization:** Standard DP uses O(C) space with rolling array.

**Pisinger 1999 (linear time for bounded items):**
Pisinger, D. (1999). "Linear time algorithms for knapsack problems with bounded weights." *JACM*, 46(3):363–380.
When each wᵢ ≤ C/n (items much smaller than capacity), solvable in O(n·C) = polynomial time.

### 3.5 FPTAS

**First FPTAS:**
Ibarra, O.H. & Kim, C.E. (1975). "Fast approximation algorithms for the knapsack and sum of subset problems." *JACM*, 22(4):463–468. DOI: `10.1145/321906.321909`
Also independently: Sahni, S. (1975). "Approximate algorithms for the 0/1 knapsack problem." *JACM*, 22(1):115–124. DOI: `10.1145/321864.321873` (first PTAS; Ibarra-Kim gave the FPTAS).

**Standard FPTAS (rounding technique):**
1. Compute upper bound V_max = max vᵢ.
2. Scale values: v̂ᵢ = ⌊vᵢ · n / (ε · V_max)⌋.
3. Run DP on scaled problem in O(n³/ε) time.
4. Output achieves value ≥ (1-ε) · OPT.

**Time complexity:** O(n²/ε) for the standard FPTAS (Garey–Johnson). Improved to O(n · min(n/ε, √(nV*))) by modern methods.

**FPTAS lower bound:** Knuth et al. showed (via (min,+)-convolution) that no FPTAS runs in O((n/ε)^(2-δ)) for any δ > 0, unless (min,+)-Convolution conjecture fails.

**Improved FPTAS (2019):**
Eisenbrand, F. & Weismantel, R. (2019). "Proximity results and faster algorithms for integer programming using the Steinitz lemma." *ACM Trans. Algorithms*, 16(1):5. arXiv:1707.00481
A (1-ε)-FPTAS for Knapsack running in O(n + (1/ε)^(5/2) · log(1/ε)) time.

**Jin (2023) (1-ε)-approximation:**
Jin, C. (2023). "(1-ε)-Approximation of Knapsack in Nearly Quadratic Time." *Proc. STOC 2024*. arXiv:2308.07004
A (1-ε)-FPTAS in O~((n + 1/ε²)) time — nearly optimal.

**No FPTAS for extensions:**
- Multiple knapsack (≥2 bins): no FPTAS unless P = NP (follows from Partition hardness).
- Quadratic knapsack: no FPTAS in general.

### 3.6 Best Known Exact Algorithm

| Algorithm | Complexity | Type | Year |
|---|---|---|---|
| Bellman DP (weight) | O(n · C) | Deterministic, pseudo-poly | 1957 |
| Bellman DP (value) | O(n · V*) | Deterministic, pseudo-poly | 1957 |
| Horowitz–Sahni | O(2^(n/2)) space O(2^(n/2)) | Deterministic, exact | 1974 |
| Polak–Rohwedder–Węgrzycki | O~(n + w_max³) | — | 2021 |
| Chen–Lian–Mao–Zhang | O~(n + w_max^(12/5)) | — | 2023 |
| **Ce Jin (2023/2024)** | **O(n + w_max² log⁴ w_max)** | **Deterministic** | **STOC 2024** |

**Jin's near-quadratic result:**
Jin, C. (2023/2024). "0-1 Knapsack in Nearly Quadratic Time." *Proc. ACM STOC 2024*, pp. 271–282. arXiv:2308.04093. DOI: `10.1145/3618260.3649618`

Main theorem: The 0-1 Knapsack problem can be solved deterministically in O(n + w_max² · log⁴ w_max) time, where w_max is the maximum item weight.

**Conditional lower bound:** Under the (min,+)-convolution hypothesis (Cygan et al. 2017, Künnemann et al. 2017), no O((n + w_max)^(2-δ)) algorithm exists for any δ > 0. Jin's result essentially matches this lower bound up to polylogarithmic factors.

### 3.7 Parameterized Complexity

- **Parameter C (capacity):** FPT in C (pseudo-polynomial DP).
- **Parameter w_max:** FPT in w_max (Jin's O(n + w_max²) algorithm).
- **Parameter n:** W[1]-hard (via reduction from k-SUM).
- **Fixed-dimension ILP connection:** When item count n is fixed (constant), the associated ILP is solvable in polynomial time (Lenstra 1983).

### 3.8 Polynomial Special Cases

| Special Case | Condition | Algorithm |
|---|---|---|
| Fractional relaxation | Remove integrality | O(n log n) greedy (Dantzig's algorithm) |
| All weights equal | wᵢ = c | Sort by value, take top ⌊C/c⌋ |
| Unit weights | wᵢ = 1 | Sort by value, take top C items |
| Polynomially bounded capacity | C ≤ poly(n) | Pseudo-poly DP in polynomial total time |
| Items with values proportional to weights | vᵢ/wᵢ = const | Greedy is optimal (unit value density) |
| Unbounded knapsack | Items reusable | O(n · C) DP but different recurrence |

**Lenstra (1983) — Fixed-variable ILP:**
Lenstra, H.W. Jr. (1983). "Integer programming with a fixed number of variables." *Mathematics of Operations Research*, 8(4):538–548.
When n is constant, the ILP (hence Knapsack) is solvable in polynomial time. Used for constant-dimensional versions.

### 3.9 Quantum and QUBO Connections

**Lucas 2014, §5.2 (arXiv:1302.5843):**
Introduce ⌈log₂(C+1)⌉ binary slack variables {yⱼ} to convert the inequality constraint to equality:

Σᵢ wᵢxᵢ + Σⱼ 2ʲyⱼ = C

QUBO Hamiltonian: H = -A·Σᵢ vᵢxᵢ + B·(Σᵢ wᵢxᵢ + Σⱼ 2ʲyⱼ - C)²

Requires B > A·max(vᵢ) to enforce feasibility. Total variables: n + O(log C).

**Quantum speedup:** O~(2^(n/2)) via Grover over the 2^n feasible configurations. No known polynomial quantum algorithm.

---

## 4. Job Sequencing with Deadlines

### 4.1 Problem Definition

Karp's precise formulation (1972, pp. 97–98):

**INPUT:** "execution time vector" (T₁, …, Tₚ) ∈ ℤᵖ, "deadline vector" (D₁, …, Dₚ) ∈ ℤᵖ, "penalty vector" (P₁, …, Pₚ) ∈ ℤᵖ, and positive integer k.

**PROPERTY:** There exists a permutation π of {1, …, p} such that:

Σⱼ₌₁ᵖ [if T_{π(1)} + … + T_{π(j)} > D_{π(j)} then P_{π(j)} else 0] < k

In plain language: **can we order p jobs with variable execution times and deadlines so that the total penalty for missing deadlines is less than k?** This is a weighted scheduling problem.

**Note:** This is the Karp #19 formulation, not the simpler "unit-time greedy" variant. The unit-time variant (where all execution times Tᵢ = 1) is solvable in polynomial time via greedy. The **NP-hard** variant is the one with **variable execution times Tᵢ**.

**Codebase variant:** The current proposal uses unit-time jobs with binary selection (include/exclude). This is the simpler variant. The full Karp #19 is the weighted variable-execution-time version.

**Complexity clarification:**
- Unit-time jobs, maximize total profit: **Polynomial** via greedy (Lawler 1983 matroid argument)
- Variable-execution-time jobs, minimize total penalty: **NP-complete** (Karp 1972 #19)
- Variable jobs with weighted penalties, general deadlines: **Strongly NP-hard** (reduction from 3-Partition)
- Variable jobs with one of two deadlines: **Weakly NP-hard** (reduction from Partition)

### 4.2 Original NP-Completeness Result

**Primary reference:**
Karp, R.M. (1972). "Reducibility Among Combinatorial Problems." Problem **#19: JOB SEQUENCING (SEQUENCING)**. Proved NP-complete by reduction from KNAPSACK (#18). The reduction encodes the knapsack selection as a scheduling choice: items selected become "on-time" jobs, items not selected become "missed deadline" jobs.

**Independent confirmation:**
Ullman, J.D. (1975). "NP-complete scheduling problems." *Journal of Computer and System Sciences*, 10(3):384–393. DOI: `10.1016/S0022-0000(75)80080-0`
Proved NP-completeness for preemptive and non-preemptive variants on multiple machines.

**Garey & Johnson reference:**
Garey, M.R. & Johnson, D.S. (1979). *Computers and Intractability*. The scheduling problem "SS7" (minimize weighted tardiness) and related variants. The exact catalog number for job sequencing is in the scheduling chapter.

### 4.3 Weak vs. Strong NP-Completeness

The complexity depends critically on the structure of deadlines:

| Variant | Complexity | Reference |
|---|---|---|
| Unit-time jobs, maximize profit | **Polynomial** (greedy) | Moore–Hodgson 1968 |
| Variable jobs, arbitrary deadlines | **Strongly NP-hard** | Reduction from 3-Partition |
| Variable jobs, two distinct deadlines | **Weakly NP-hard** | Reduction from Partition |
| Variable jobs, all same deadline | Polynomial (trivial) | O(n log n) sort |
| Weighted number tardy, 1 machine | **Weakly NP-hard** | Lawler–Moore 1969 pseudo-poly |
| Weighted tardiness, precedence constraints | **Strongly NP-hard** | Reduction from 3-Partition |

**Key result:** When jobs have **arbitrary execution times and arbitrary deadlines**, the problem is **strongly NP-hard** (reduction from 3-Partition), meaning no pseudo-polynomial algorithm exists unless P = NP.

When jobs have **exactly two distinct deadlines**, the problem is **weakly NP-hard** (reduction from Partition), admitting pseudo-polynomial algorithms.

### 4.4 Pseudo-Polynomial Algorithm (Weakly NP-Hard Variant)

For the variant **1 || Σ wⱼUⱼ** (minimize weighted number of tardy jobs, no hard deadlines):

**Lawler–Moore algorithm (1969):**
Lawler, E.L. & Moore, J.M. (1969). "A functional equation and its application to resource allocation and sequencing problems." *Management Science*, 16(1):77–84.

Algorithm: DP in O(n · Σwⱼ) time. Finds an optimal schedule minimizing the weighted number of late jobs. This is pseudo-polynomial since Σwⱼ can be exponential in the encoding length.

**Moore–Hodgson algorithm (1968) — unweighted case:**
Moore, J.M. (1968). "An n job, one machine sequencing algorithm for minimizing the number of late jobs." *Management Science*, 15(1):102–109.

Solves **1 || ΣUⱼ** (minimize number of late jobs, unit weights) in **O(n log n)** time. This is the tractable case. The algorithm maintains an EDD (Earliest Due Date) schedule and drops the latest job whenever tardiness occurs.

### 4.5 FPTAS and Approximation

- **For strongly NP-hard variants** (arbitrary deadlines): No FPTAS unless P = NP (by Garey–Johnson Theorem 4.1 for strongly NP-hard problems with polynomially bounded objectives).
- **For weakly NP-hard variants** (e.g., two deadlines): FPTAS may exist; this is related to whether the pseudo-polynomial algorithm can be converted via scaling.
- **Greedy approximation for unit-time variant:** The greedy algorithm (sort by profit, assign to latest available slot ≤ deadline) is **optimal** for the unit-time maximize-profit version. This is the matroid intersection structure.

**No constant-factor approximation** for the general scheduling optimization version (Zuckerman 1996 extends Karp's result to show no constant-factor approximation for all 21 NP-complete problems unless P = NP).

### 4.6 SETH-Based Scheduling Lower Bounds

The connection between Subset Sum and scheduling complexity is deep:

Abboud, A., Bringmann, K., Hermelin, D. & Shabtay, D. (2022). "Scheduling Lower Bounds via AND Subset Sum." *Journal of Computer and System Sciences*, 127:29–40. DOI: `10.1016/j.jcss.2022.01.003`

**Main result:** Under ∀∃-SETH, scheduling problems including **1 || ΣwⱼUⱼ** and **P2 || ΣUⱼ** have no O~(n + p_max · n^(1-ε)) algorithm for any ε > 0.

This tight connection between Subset Sum hardness and scheduling hardness:
- Justifies why pseudo-polynomial DP is essentially the best possible for these scheduling variants.
- Shows that Subset Sum lower bounds directly transfer to scheduling lower bounds.

### 4.7 Polynomial Special Cases

| Special Case | Algorithm | Complexity |
|---|---|---|
| Unit-time jobs, maximize profit | Greedy (sort by profit + EDF scheduling) | O(n log n) |
| Minimize number of late jobs (unit weights) | Moore–Hodgson algorithm | O(n log n) |
| Minimize weighted completion time (no deadlines) | WSPT (Smith's rule) | O(n log n) |
| All jobs have same deadline | Sort by processing time | O(n log n) |
| Two machines, minimize makespan | Special case of Partition | Pseudo-poly |
| Series-parallel precedence constraints | DP on partial orders | O(n log n) |
| Preemptive, minimize weighted late jobs | Network flow / DP | Polynomial (Lawler 1983) |

**Matroid structure of unit-time variant:**
The feasible schedules form a graphic matroid. The greedy algorithm on a matroid is optimal (Rado–Edmonds theorem). This is why the greedy algorithm solves unit-time Job Sequencing to optimality in O(n log n).

### 4.8 Parameterized Complexity

Heeger, K. (2023). "Single Machine Scheduling with Few Deadlines." *Proc. IPEC 2023*. LIPIcs vol. 285. DOI: `10.4230/LIPIcs.IPEC.2023.24`

- **Parameter k = number of distinct deadlines:**
  - Both `1|dⱼ|ΣwⱼUⱼ` and `1|dⱼ|ΣwⱼCⱼ` are **W[1]-hard** with respect to k, even for unit processing times encoded in unary.
  - For constant k = O(1): pseudo-polynomial algorithm exists.
- **Implication:** Even with very few distinct deadlines, the problem is unlikely to be FPT in the number of deadlines (conditional on W[1] ≠ FPT).

### 4.9 Average-Case and Quantum

- **No published phase transition results** specific to Job Sequencing (unlike Partition). The inheriting hardness from Subset Sum suggests similar density-dependent behavior, but this is not formalized.
- **QUBO formulation:**
  Venturelli, D., Marchand, D.J.J. & Rojo, G. (2016). "Quantum annealing implementation of job-shop scheduling." arXiv:1506.08479
  For job-shop scheduling (generalization): assignment encoding with penalty terms for slot conflicts. For unit-time Job Sequencing: binary xⱼ (include/exclude), with time-slot conflict penalties via assignment variables.

---

## 5. Cross-Problem Relationships

### 5.1 The Karp Reduction Chain (Problems #18–#21)

```
EXACT COVER (#14)
    |
    v
KNAPSACK = SubsetSum (#18)
    |
    v
JOB SEQUENCING (#19)  ---[Karp 1972 reduction]
    |
    v
PARTITION (#20)  ---[Karp 1972 reduction]
    |
    v
MAX-CUT (#21)
```

All proved NP-complete by Karp (1972). The chain means:
- Knapsack (SubsetSum) ≤ₚ JobSequencing (Karp reduces via penalty encoding)
- JobSequencing ≤ₚ Partition (Karp reduces via scheduling to balancing)
- Partition ≤ₚ MaxCut (Karp reduces via gadget construction)

### 5.2 The Polynomial Hierarchy within the Family

```
SubsetSum (Satisfaction) --- special case when vᵢ = wᵢ
        |
        ↓ (generalization: add value array)
Knapsack (Optimization, Maximize)
        |
        ↓ (restrict: all weights = 1, add deadlines)
JobSequencing Unit-Time (POLYNOMIAL via matroid)
        |
        ↓ (generalize: variable execution times)
JobSequencing Variable-Time (NP-COMPLETE, Karp #19)
        |
        ↑ (special case: 2 groups, equal penalty)
Partition (Satisfaction)
        |
        ↑ (special case: target = S/2)
SubsetSum (circular: Partition ≤ SubsetSum and SubsetSum ≤ Partition)
```

### 5.3 Reduction Summary for Codebase

| Source | Target | Type | Reference |
|---|---|---|---|
| Partition → SubsetSum | Trivial (target = S/2) | Karp | Standard |
| SubsetSum → ILP | 1 equality constraint | Standard | Garey–Johnson |
| SubsetSum → QUBO | H = A(Σaᵢxᵢ − t)² | Lucas 2014 §5 | arXiv:1302.5843 |
| Partition → ILP | 1 equality constraint | Standard | Garey–Johnson |
| Partition → QUBO | H = A(Σaᵢsᵢ)², Ising model | Lucas 2014 §5.1 | arXiv:1302.5843 |
| Knapsack → ILP | max vᵀx, wᵀx ≤ C | Standard | Kellerer et al. 2004 |
| Knapsack → QUBO | Slack-variable encoding | Lucas 2014 §5.2 | arXiv:1302.5843 |
| JobSequencing → ILP | Cumulative flow constraints | Standard | — |
| Partition → JobSequencing | NP-hardness proof | Karp 1972 | #20 ← #19 |

### 5.4 FPTAS Existence Summary

| Problem | FPTAS? | Reason |
|---|---|---|
| SubsetSum (optimization variant) | Yes | Weakly NP-hard, pseudo-poly DP exists |
| Partition | Yes | Reduces to SubsetSum FPTAS |
| Knapsack | Yes | Ibarra–Kim 1975 FPTAS |
| JobSequencing (unit-time) | N/A (polynomial exact) | Matroid structure |
| JobSequencing (variable-time, two deadlines) | Possibly (open) | Weakly NP-hard |
| JobSequencing (variable-time, arbitrary deadlines) | No (unless P=NP) | Strongly NP-hard |

---

## 6. References

### Primary NP-Completeness References

1. **Karp, R.M. (1972).** "Reducibility Among Combinatorial Problems." In R.E. Miller & J.W. Thatcher (Eds.), *Complexity of Computer Computations*, Plenum Press, pp. 85–103. DOI: `10.1007/978-1-4684-2001-2_9`
   [Problems #18 (KNAPSACK = SubsetSum), #19 (JOB SEQUENCING), #20 (PARTITION)]

2. **Garey, M.R. & Johnson, D.S. (1979).** *Computers and Intractability: A Guide to the Theory of NP-Completeness*. W.H. Freeman.
   [SP12: Partition, SP13: Subset Sum, MP9: Knapsack]

3. **Ullman, J.D. (1975).** "NP-complete scheduling problems." *Journal of Computer and System Sciences*, 10(3):384–393. DOI: `10.1016/S0022-0000(75)80080-0`

### Pseudo-Polynomial Algorithms

4. **Bellman, R.E. (1956).** "Notes on the Theory of Dynamic Programming IV — Maximization over Discrete Sets." *Naval Research Logistics Quarterly*, 3(1-2):67–70.

5. **Moore, J.M. (1968).** "An n job, one machine sequencing algorithm for minimizing the number of late jobs." *Management Science*, 15(1):102–109.

6. **Lawler, E.L. & Moore, J.M. (1969).** "A functional equation and its application to resource allocation and sequencing problems." *Management Science*, 16(1):77–84.

### FPTAS / Approximation

7. **Sahni, S. (1975).** "Approximate algorithms for the 0/1 knapsack problem." *JACM*, 22(1):115–124. DOI: `10.1145/321864.321873`
   [First PTAS for Knapsack]

8. **Ibarra, O.H. & Kim, C.E. (1975).** "Fast approximation algorithms for the knapsack and sum of subset problems." *JACM*, 22(4):463–468. DOI: `10.1145/321906.321909`
   [First FPTAS for Knapsack/SubsetSum]

9. **Karmarkar, N. & Karp, R.M. (1982).** "The differencing method of set partitioning." UC Berkeley Technical Report UCB/CSD 82/113.
   [Karmarkar–Karp O(n log n) heuristic for Partition]

### Exact Algorithms / Fine-Grained Complexity

10. **Horowitz, E. & Sahni, S. (1974).** "Computing partitions with applications to the knapsack problem." *JACM*, 21(2):277–292.
    [O(2^(n/2)) meet-in-middle for Subset Sum and Knapsack]

11. **Bringmann, K. (2017).** "A near-linear pseudopolynomial time algorithm for subset sum." *Proc. SODA*, pp. 1073–1084. arXiv:1610.04712

12. **Bringmann, K. & Wellnitz, P. (2021).** "On near-linear-time algorithms for dense subset sum." *Proc. SODA*, pp. 1777–1796. arXiv:2010.09096

13. **Jin, C. (2023/2024).** "0-1 Knapsack in Nearly Quadratic Time." *Proc. ACM STOC 2024*, pp. 271–282. arXiv:2308.04093. DOI: `10.1145/3618260.3649618`

### SETH Lower Bounds

14. **Abboud, A., Bringmann, K., Hermelin, D. & Shabtay, D. (2019/2022).** "SETH-Based Lower Bounds for Subset Sum and Bicriteria Path." *ACM Transactions on Algorithms*, 18(1):1–31. arXiv:1704.04546. DOI: `10.1145/3450524`

15. **Abboud, A., Bringmann, K., Hermelin, D. & Shabtay, D. (2022).** "Scheduling Lower Bounds via AND Subset Sum." *Journal of Computer and System Sciences*, 127:29–40. DOI: `10.1016/j.jcss.2022.01.003`

16. **Cygan, M., Mucha, M., Węgrzycki, K. & Włodarczyk, M. (2017).** "On problems equivalent to (min,+)-convolution." *Proc. ICALP 2017*, LIPIcs vol. 80.

17. **Künnemann, M., Paturi, R. & Schneider, S. (2017).** "On the fine-grained complexity of one-dimensional dynamic programming." *Proc. ICALP 2017*, LIPIcs vol. 80.

### Phase Transitions

18. **Mertens, S. (1998).** "Phase transition in the number partitioning problem." *Physical Review Letters*, 81(20):4281–4284. DOI: `10.1103/PhysRevLett.81.4281`

19. **Mertens, S. (2003).** "The Easiest Hard Problem: Number Partitioning." In *Computational Complexity and Statistical Physics*, Santa Fe Institute Studies, pp. 125–139. arXiv:cond-mat/0310317

20. **Borgs, C., Chayes, J. & Pittel, B. (2001).** "Phase transition and finite-size scaling for the integer partitioning problem." *Random Structures and Algorithms*, 19(3-4):247–288.

21. **Lagarias, J.C. & Odlyzko, A.M. (1985).** "Solving low-density subset sum problems." *JACM*, 32(1):229–246. DOI: `10.1145/2455.2461`

### Parameterized Complexity

22. **Heeger, K. (2023).** "Single Machine Scheduling with Few Deadlines." *Proc. IPEC 2023*, LIPIcs vol. 285. DOI: `10.4230/LIPIcs.IPEC.2023.24`

23. **Cygan, M. et al. (2015).** *Parameterized Algorithms*. Springer. DOI: `10.1007/978-3-319-21275-3`

### QUBO / Quantum

24. **Lucas, A. (2014).** "Ising formulations of many NP problems." *Frontiers in Physics*, 2:5. arXiv:1302.5843. DOI: `10.3389/fphy.2014.00005`
    [§5 = SubsetSum, §5.1 = Partition, §5.2 = Knapsack]

25. **Venturelli, D., Marchand, D.J.J. & Rojo, G. (2016).** "Quantum annealing implementation of job-shop scheduling." arXiv:1506.08479

26. **Jin, C. (2023).** "(1-ε)-Approximation of Knapsack in Nearly Quadratic Time." *Proc. ACM STOC 2024*. arXiv:2308.07004. DOI: `10.1145/3618260.3649677`

### Comprehensive Surveys

27. **Kellerer, H., Pferschy, U. & Pisinger, D. (2004).** *Knapsack Problems*. Springer. DOI: `10.1007/978-3-540-24777-7`
    [Comprehensive reference on all Knapsack variants, complexity, and algorithms]

28. **Lenstra, H.W. Jr. (1983).** "Integer programming with a fixed number of variables." *Mathematics of Operations Research*, 8(4):538–548.
    [Polynomial-time ILP for fixed dimension; special-case polynomial for Knapsack with fixed n]

29. **Lenstra, A.K., Lenstra, H.W. Jr. & Lovász, L. (1982).** "Factoring polynomials with rational coefficients." *Mathematische Annalen*, 261:515–534.
    [LLL algorithm, foundational for Lagarias–Odlyzko low-density Subset Sum]

---

## Appendix: Key Complexity Facts Summary Table

| Property | SubsetSum | Partition | Knapsack | JobSeq (variable) |
|---|---|---|---|---|
| Karp # | #18 | #20 | #18 (gen.) | #19 |
| G&J catalog | [SP13] | [SP12] | [MP9] | (scheduling chapter) |
| Complexity class | NP-c | NP-c | NP-c | NP-c |
| Weakly NP-c? | **Yes** | **Yes** | **Yes** | Variant-dependent |
| Strongly NP-c? | No | No | No | Yes (arbitrary deadlines) |
| Pseudo-poly time | O(n·t) | O(n·S) | O(n·C) | O(n·Σpⱼ) (2 deadlines) |
| FPTAS exists? | Yes (optimization) | Yes | **Yes (Ibarra–Kim 1975)** | No (strongly NP-h case) |
| Best exact alg. | O~(n+t) [Bringmann 17] | O~(n+S) via SubsetSum | O(n + w²log⁴w) [Jin 2024] | NP-hard, exp. exact |
| SETH lower bound | Yes (Abboud+ 2019) | via SubsetSum | (min,+)-conv. lb. | via AND-SubsetSum 2022 |
| Phase transition? | Yes (density d≈1) | **Yes (κ≈0.96, Mertens 1998)** | Inherits from SubsetSum | Not characterized |
| Quantum alg. | O~(2^0.226n) [w/ QRAQM] | Same via SubsetSum | Grover O(2^n/2) | QAOA (approx.) |
| QUBO reference | Lucas §5 | Lucas §5.1 | Lucas §5.2 | Venturelli 2016 |
| Poly special cases | Low density, small nums | S odd (unsat), κ≫1 | Unit weights, frac. relax | Unit-time (greedy) |
