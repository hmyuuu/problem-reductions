# Model Proposal: SpinGlass → SAT Reduction

## Missing Reduction (exists in Julia, not in Rust)

**SpinGlass → Satisfiability**

The Julia ProblemReductions.jl has `spinglass_sat.jl` implementing this direction.
Currently Rust has CircuitSAT → SpinGlass but NOT SpinGlass → SAT.

## Why Include

- Closes a reduction cycle: SAT → MIS → QUBO → SpinGlass → SAT
- Exists in the Julia reference implementation
- Establishes SpinGlass/Ising model as a universal representation

## Algorithm Sketch

Given SpinGlass instance on graph G with couplings Jᵢⱼ and fields hᵢ:

The ground state of H = Σᵢⱼ Jᵢⱼsᵢsⱼ + Σᵢ hᵢsᵢ can be encoded as a SAT problem.

**Approach:** Encode the optimization as a sequence of decision problems.
For each possible energy level E, ask: is there a configuration with energy ≤ E?
Binary search on E to find ground state.

**Alternative (direct):** Encode each Ising interaction as clauses.
For coupling Jᵢⱼ between spins sᵢ, sⱼ:
- If Jᵢⱼ < 0 (ferromagnetic): prefer sᵢ = sⱼ → add clauses favoring agreement
- If Jᵢⱼ > 0 (antiferromagnetic): prefer sᵢ ≠ sⱼ → add clauses favoring disagreement

This is actually more naturally a MAX-SAT formulation (maximize satisfied weighted clauses).

## Difficulty: Tier 3

- Need to understand the Julia implementation to match semantics
- Natural formulation is MAX-SAT rather than plain SAT
- May want to add MaxSAT first, then do SpinGlass → MaxSAT

## Recommendation

Add as: SpinGlass → MaxSAT (more natural) rather than SpinGlass → SAT
