# Reduction Proposal: MaxSAT → QUBO

## Algorithm

Given MaxSAT: variables x₁…xₙ, weighted clauses (Cⱼ, wⱼ)

**Key insight:** Each clause Cⱼ can be written as a polynomial in binary variables.

For a clause Cⱼ = (l₁ ∨ l₂ ∨ … ∨ lₖ) where lᵢ is xᵢ or ¬xᵢ:
- Clause is unsatisfied iff all literals are false
- Probability of being unsatisfied = Πᵢ (1-lᵢ) where lᵢ ∈ {0,1}

**Penalty for unsatisfied clause:**
```
P(Cⱼ) = Πᵢ∈pos(1 - xᵢ) · Πᵢ∈neg xᵢ
```
(product of complemented positive literals and uncomplemented negative literals)

**QUBO Hamiltonian:**
```
H = Σⱼ wⱼ · P(Cⱼ)
```
Minimize H = maximize satisfied clause weight.

**For 2-clauses (MAX-2-SAT):** P is at most quadratic → direct QUBO.
**For 3-clauses (MAX-3-SAT):** P is cubic → need auxiliary variable to reduce to quadratic (standard QUBO reduction technique).

**For general k-clauses:** Need k-2 auxiliary variables per clause.

**Overhead:**
- MAX-2-SAT: n variables, no auxiliaries
- MAX-3-SAT: n + m auxiliary variables (one per clause)
- General: n + Σⱼ(kⱼ-2) auxiliaries

**This matches the existing KSatisfiability → QUBO pattern** in the codebase but adds clause weights.
