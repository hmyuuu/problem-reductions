# Reduction Proposal: Partition → QUBO

## Algorithm (Lucas 2014 §5.1)

Given Partition: numbers A = {a₀, …, aₙ₋₁}

**Ising Hamiltonian (simplest form):**
```
H = A · (Σᵢ aᵢsᵢ)²
```
where sᵢ ∈ {+1, -1}. Ground state at H=0 iff equal partition exists.

**QUBO substitution** (xᵢ = (1-sᵢ)/2, so sᵢ = 1-2xᵢ):
```
Σᵢ aᵢsᵢ = Σᵢ aᵢ(1 - 2xᵢ) = S - 2·Σᵢ aᵢxᵢ
```
where S = Σᵢ aᵢ.

```
H = A · (S - 2·Σᵢ aᵢxᵢ)²
  = A · (S² - 4S·Σᵢ aᵢxᵢ + 4·(Σᵢ aᵢxᵢ)²)
```

**QUBO Q matrix:**
- Qᵢᵢ = A · (4aᵢ² - 4S·aᵢ)
- Qᵢⱼ = A · 8aᵢaⱼ for i < j
- Constant: A·S²

**Overhead:** n variables, dense n×n QUBO.

**Note:** This is even simpler than SubsetSum→QUBO since there's no target parameter — it's implicit (S/2).
