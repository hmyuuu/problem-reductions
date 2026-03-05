# Reduction Proposal: SubsetSum → QUBO

## Algorithm (Lucas 2014 §5)

Given SubsetSum: numbers A = {a₀, …, aₙ₋₁}, target t

**Ising Hamiltonian:**
```
H = A · (Σᵢ aᵢxᵢ − t)²
```
where xᵢ ∈ {0,1}, A > 0 is a penalty coefficient.

**Expansion to QUBO:**
```
H = A · (Σᵢ aᵢxᵢ − t)²
  = A · (Σᵢ aᵢ²xᵢ² + 2·Σᵢ<ⱼ aᵢaⱼxᵢxⱼ − 2t·Σᵢ aᵢxᵢ + t²)
  = A · (Σᵢ (aᵢ² − 2t·aᵢ)xᵢ + 2·Σᵢ<ⱼ aᵢaⱼxᵢxⱼ + t²)
```
(using xᵢ² = xᵢ for binary variables)

**QUBO Q matrix:**
- Qᵢᵢ = A · (aᵢ² − 2t·aᵢ)
- Qᵢⱼ = 2A · aᵢaⱼ for i < j
- Constant offset: A·t² (doesn't affect optimization)

**Overhead:** n variables, n² matrix entries. Dense QUBO.

**Solution extraction:** Direct — xᵢ = QUBO solution, ground state has energy 0 iff subset sums to t.
