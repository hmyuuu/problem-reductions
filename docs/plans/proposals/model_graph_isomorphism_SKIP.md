# Model Proposal: GraphIsomorphism

## ⚠️ NOT RECOMMENDED — NP-Intermediate, not NP-Complete

Graph Isomorphism is **not known to be NP-complete** and is widely believed to be in NP-intermediate (NPI). Babai (2015) gave a quasipolynomial-time algorithm. While it has QUBO/Ising formulations (Lucas 2014 §9), it doesn't fit the project's NP-hard focus.

**Skip this problem** unless the project scope explicitly expands to NP-intermediate problems.

## For Reference Only

Lucas 2014 §9 provides an Ising formulation using n² binary variables (permutation matrix):
- Variables: P_{uv} ∈ {0,1} for mapping vertex u in G₁ to vertex v in G₂
- Constraints: P is a permutation matrix (doubly stochastic + binary)
- Objective: H = A·Σ constraints + B·Σ edge mismatches
