# Reduction Proposal: MinimumBisection → QUBO

## Reduction Direction: One-way

### MinimumBisection → QUBO

**Algorithm:** Ising-to-QUBO mapping (Lucas 2014 §3)

Given MinimumBisection: graph G = (V, E), |V| = 2n (even)

**Ising formulation:**
```
H = A · Σ_{(i,j)∈E} (1 - sᵢsⱼ)/2  +  B · (Σᵢ sᵢ)²
```
where sᵢ ∈ {+1, -1}, A > 0 is the cut weight, B > 0 is the penalty for unequal partition.

The first term counts crossing edges (minimize).
The second term penalizes partition imbalance (forces equal partition when B is large enough).

**QUBO substitution** (xᵢ = (1-sᵢ)/2, so sᵢ = 1-2xᵢ):

After expansion:
```
H_cut = A · Σ_{(i,j)∈E} (xᵢ + xⱼ - 2xᵢxⱼ)
H_balance = B · (n - 2·Σᵢ xᵢ)²
         = B · (n² - 4n·Σxᵢ + 4·(Σxᵢ)²)
         = B · (n² - 4n·Σxᵢ + 4·Σᵢ xᵢ² + 4·Σᵢ<ⱼ 2xᵢxⱼ)
         = B · (n² - 4n·Σxᵢ + 4·Σxᵢ + 8·Σᵢ<ⱼ xᵢxⱼ)    [since xᵢ²=xᵢ]
```

**QUBO Q matrix:**
- Qᵢᵢ = A·deg(i) + B·(4 - 4n) [diagonal]  (where deg(i) = degree of vertex i from cut term, plus balance term)
  - More precisely: Qᵢᵢ = -A·Σⱼ wᵢⱼ + B·(4-4n)
  - Wait, let me recompute. For H_cut, the xᵢ coefficient from A·Σ(xᵢ+xⱼ-2xᵢxⱼ) gives Qᵢᵢ += A·deg(i)
  - For H_balance, Qᵢᵢ += B·(4-4n)
- Qᵢⱼ = -2A·wᵢⱼ + 8B for (i,j)∈E; 8B for (i,j)∉E

**Penalty parameter:** B > A·max_cut_possible / 2 ensures equal partition is enforced.

**Solution extraction:** Direct — xᵢ = 0/1 is partition assignment

**Overhead:** |V| variables, |V|² potential interactions (dense QUBO from balance constraint)

## Notes

- The balance constraint (Σsᵢ)² makes the QUBO dense even for sparse graphs
- This is inherent — enforcing global equality constraint requires all-to-all interactions
- Penalty B must be chosen carefully: B > A·|E|/2 is sufficient but may make numerics worse
