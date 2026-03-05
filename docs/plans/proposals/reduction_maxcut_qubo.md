# Reduction Proposal: MaxCut → QUBO (Direct)

## Reduction Direction: One-way

### MaxCut → QUBO

**Algorithm:** Direct Ising-to-QUBO mapping

MaxCut already reduces via MaxCut → SpinGlass → QUBO. This proposal adds a **direct** MaxCut → QUBO reduction with tighter overhead (no intermediate SpinGlass).

Given MaxCut instance: graph G = (V, E), edge weights wₑ

**Ising formulation** (Lucas 2014 §2):
```
H = -Σ_{(i,j)∈E} wᵢⱼ · (1 - sᵢsⱼ) / 2
```
where sᵢ ∈ {+1, -1}.

**QUBO formulation** (substituting xᵢ = (1-sᵢ)/2):
```
H = -Σ_{(i,j)∈E} wᵢⱼ · (xᵢ + xⱼ - 2xᵢxⱼ)
```
Equivalently, the QUBO Q matrix:
- Qᵢᵢ = -Σ_{j:(i,j)∈E} wᵢⱼ (diagonal: negative sum of adjacent weights)
- Qᵢⱼ = 2wᵢⱼ for (i,j) ∈ E (off-diagonal: twice edge weight)

**Solution extraction:** Direct — QUBO binary variables = MaxCut partition assignment

**Overhead:**
- num_vars = |V| (same as source!)
- num_nonzeros = |V| + 2|E|
- No auxiliary variables needed

## Why Add This

- Shorter reduction path: MaxCut → QUBO instead of MaxCut → SpinGlass → QUBO
- Tighter overhead (no intermediate spin variables)
- Educational: shows direct correspondence between graph cuts and QUBO

## Notes

- MaxCut→SpinGlass and SpinGlass→QUBO already exist
- This direct path is redundant but more efficient (fewer intermediate variables)
- The QUBO matrix is exactly the negative Laplacian of the weighted graph
- Could be skipped if the team prefers the existing chain
