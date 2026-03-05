# Reduction Proposals: Missing Cross-Reductions Between Existing Problems

## Overview

These are reductions between **already-implemented** problems that are missing from the codebase. Adding them would make the reduction graph denser and more useful.

---

## 1. MaximumClique ↔ MaximumIndependentSet

**Status:** NOT YET IMPLEMENTED (surprisingly!)

**Algorithm:** Complement graph.
- MaxClique(G) = MaxIndependentSet(complement(G))
- This is one of the most fundamental equivalences in combinatorics

**Why missing?** Both problems exist but the direct reduction between them is not in the codebase. Currently:
- MaxClique → ILP exists
- MIS → ILP exists
- But MaxClique ↔ MIS direct is missing!

**Overhead:** O(|V|²) for complement

**Files:** `src/rules/maximumclique_maximumindependentset.rs`

---

## 2. MaximumClique → QUBO (Direct)

**Status:** NOT YET IMPLEMENTED directly

**Current path:** MaxClique → ILP → QUBO (indirect, more overhead)

**Algorithm (Lucas 2014 §3.2):**
```
H = -A·Σᵥ xᵥ + B·Σ_{(u,v)∉E} xᵤxᵥ
```
Maximize selected vertices (penalty for selecting non-adjacent pair)

**Why add:** Direct QUBO is tighter than going through ILP. O(|V|) variables.

**Files:** `src/rules/maximumclique_qubo.rs`

---

## 3. MinimumDominatingSet → QUBO (Direct)

**Status:** NOT YET IMPLEMENTED directly

**Current path:** SAT → DominatingSet exists (reverse direction), and DS → ILP exists

**Algorithm (Lucas 2014 §4.3):**
```
H = A·Σᵥ xᵥ + B·Σᵥ (1 - xᵥ - Σ_{u∈N(v)} xᵤ + xᵥ·Σ_{u∈N(v)} xᵤ + ...)
```
Minimize selected vertices (penalty if any vertex is not dominated)

Simplified QUBO: for each vertex v, at least one of {v} ∪ N(v) must be selected. This is equivalent to a set covering constraint.

**Files:** `src/rules/minimumdominatingset_qubo.rs`

---

## 4. MinimumDominatingSet → MinimumSetCovering

**Status:** NOT YET IMPLEMENTED

**Algorithm:** Classic reduction.
- Universe = V (all vertices)
- For each vertex v, create set Sᵥ = {v} ∪ N(v) (closed neighborhood)
- MinSetCover on this instance = MinDominatingSet on G

**Why add:** Natural structural connection between graph and set problems.

**Overhead:** O(|V| + |E|)

**Files:** `src/rules/minimumdominatingset_minimumsetcovering.rs`

---

## 5. HamiltonianCycle → TravelingSalesman

**Status:** NOT YET IMPLEMENTED (both problems exist!)

**Algorithm:** Classic reduction.
- Given graph G, create TSP instance where edge weight = 1 if edge exists, M (big number) if not
- Optimal TSP tour with cost = |V| ↔ Hamiltonian cycle exists

**Why add:** This is one of the most famous reductions in CS! Both problems already exist in the codebase.

**Overhead:** O(|V|²)

**Files:** `src/rules/hamiltoniancycle_travelingsalesman.rs`

---

## 6. SAT → MaxCut (via 3-SAT)

**Status:** NOT YET IMPLEMENTED directly

**Current paths exist:** SAT → MIS, SAT → KColoring, SAT → DominatingSet
But SAT → MaxCut is missing (classically important!)

**Algorithm:** Garey, Johnson, Stockmeyer (1976)
Each clause creates a gadget in the MaxCut graph.

**Complexity:** More involved reduction, may be Tier 3.

**Files:** `src/rules/satisfiability_maxcut.rs`

---

## Priority Ranking

1. **MaxClique ↔ MIS** — fundamental, trivial, should already exist (HIGH priority)
2. **HamiltonianCycle → TSP** — famous, both problems exist (HIGH priority)
3. **DominatingSet → SetCovering** — natural, connects graph↔set (MEDIUM priority)
4. **MaxClique → QUBO** — direct, tighter than ILP chain (MEDIUM priority)
5. **DominatingSet → QUBO** — direct QUBO (LOW priority)
6. **SAT → MaxCut** — complex reduction (LOW priority)
