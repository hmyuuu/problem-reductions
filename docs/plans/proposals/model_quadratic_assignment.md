# Model Proposal: QuadraticAssignment (QAP)

## Problem Definition

**Quadratic Assignment Problem**

Given n facilities and n locations, a flow matrix F (flow between facilities) and a distance matrix D (distance between locations), find an assignment of facilities to locations that minimizes total cost = Σᵢⱼ Fᵢⱼ · D_{π(i)π(j)}, where π is a permutation.

- **Category:** optimization
- **Reference:** Koopmans & Beckmann (1957); Garey & Johnson (1979), [ND43]
- **Complexity:** NP-hard (even to approximate)
- **Problem type:** Optimization (Minimize)

## Why Include

- One of the hardest NP-hard problems in practice (no good approximation algorithms)
- Generalizes TSP (set F = adjacency, D = distances)
- Has clean QUBO formulation (Lucas 2014 §8)
- Important applications: facility layout, keyboard design, VLSI
- Connects to TSP (TSP is a special case of QAP)

## Variables

- Count: n² (assignment matrix)
- Per-variable domain: binary {0, 1}
- Meaning: xᵢⱼ = 1 if facility i assigned to location j
- Constraint: X is a permutation matrix (each row and column sums to 1)

## Schema

| Field | Description |
|-------|-------------|
| `n` | Number of facilities/locations |
| `flow` | n×n flow matrix F |
| `distance` | n×n distance matrix D |

## Example Instance

```
n = 3
Flow: [[0,5,2],[5,0,3],[2,3,0]]
Distance: [[0,8,4],[8,0,6],[4,6,0]]

Assignment π = (0→0, 1→1, 2→2) (identity):
Cost = F₀₁·D₀₁ + F₀₂·D₀₂ + F₁₀·D₁₀ + F₁₂·D₁₂ + F₂₀·D₂₀ + F₂₁·D₂₁
     = 5·8 + 2·4 + 5·8 + 3·6 + 2·4 + 3·6
     = 40 + 8 + 40 + 18 + 8 + 18 = 132

Assignment π = (0→1, 1→0, 2→2):
Cost = F₀₁·D₁₀ + F₀₂·D₁₂ + F₁₀·D₀₁ + F₁₂·D₀₂ + F₂₀·D₂₁ + F₂₁·D₂₀
     = 5·8 + 2·6 + 5·8 + 3·4 + 2·6 + 3·4
     = 40 + 12 + 40 + 12 + 12 + 12 = 128 (better!)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| QAP → QUBO | Lucas 2014 §8 | n² variables xᵢⱼ + permutation penalty terms |
| QAP → ILP | Standard | Binary xᵢⱼ; permutation + linearization of quadratic objective |
| TSP → QAP | Known | TSP is QAP where F = cycle adjacency matrix |

## Difficulty: Tier 3

- n² variables (quadratic in problem size)
- Permutation constraint handling
- Quadratic objective needs linearization for ILP
- But QUBO formulation is direct (already quadratic in binary variables)
