# Model Proposal: MaxSAT (Maximum Satisfiability)

## Problem Definition

**Weighted Maximum Satisfiability (Weighted MAX-SAT)**

Given a Boolean formula φ in CNF with clauses C₁, …, Cₘ, each with weight wⱼ, find a truth assignment that maximizes the total weight of satisfied clauses.

- **Category:** satisfiability
- **Reference:** Garey & Johnson (1979); widely studied in AI/SAT community
- **Complexity:** NP-hard (optimization version of SAT)
- **Problem type:** Optimization (Maximize)

## Why Include

- Natural optimization extension of existing `Satisfiability` (which is satisfaction only)
- Bridges SAT and QUBO worlds — MaxSAT has direct QUBO formulation
- Extremely well-studied in practice (annual MaxSAT competition)
- When all weights = 1, becomes unweighted MAX-SAT
- When formula is satisfiable, optimal = total weight (reduces to SAT)

## Variables

- Count: n (number of Boolean variables)
- Per-variable domain: binary {0, 1} (false, true)
- Meaning: xᵢ = truth assignment of variable i

## Schema

| Field | Description |
|-------|-------------|
| `num_variables` | Number of Boolean variables |
| `clauses` | List of clauses, each a list of signed literals |
| `weights` | Weight per clause (default: all 1) |

## Example Instance

```
Variables: x₀, x₁, x₂
Clauses (weighted):
  C₀ = (x₀ ∨ x₁)       weight 3
  C₁ = (¬x₀ ∨ x₂)      weight 2
  C₂ = (¬x₁ ∨ ¬x₂)     weight 1
  C₃ = (x₀ ∨ ¬x₁ ∨ x₂) weight 4

Assignment x₀=T, x₁=F, x₂=T:
  C₀ satisfied ✓ (3), C₁ satisfied ✓ (2), C₂ satisfied ✓ (1), C₃ satisfied ✓ (4)
  Total: 10 (all satisfied)

Assignment x₀=F, x₁=T, x₂=F:
  C₀ satisfied ✓ (3), C₁ not ✗, C₂ satisfied ✓ (1), C₃ not ✗
  Total: 4
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| MaxSAT → QUBO | Direct | Each clause contributes a penalty term; well-known encoding |
| MaxSAT → ILP | Standard | Binary xᵢ per variable; yⱼ indicator per clause; maximize Σwⱼyⱼ |
| Satisfiability → MaxSAT | Trivial | Set all weights = 1; satisfiable iff optimal = m |
| MaxSAT → Satisfiability | Partial | Decision version: is there assignment satisfying weight ≥ k? |

## Difficulty: Tier 2

- Reuses SAT clause infrastructure
- Similar to KSatisfiability but with weights and optimization instead of satisfaction
- QUBO reduction is well-documented
