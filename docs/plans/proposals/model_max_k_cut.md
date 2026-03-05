# Model Proposal: Max k-Cut

## Problem Definition

**Maximum k-Cut**

Given an undirected weighted graph G = (V, E) and integer k ≥ 2, partition V into k groups to maximize the total weight of edges between different groups.

- **Category:** graph
- **Reference:** Kann et al. (1997); Frieze & Jerrum (1997)
- **Complexity:** NP-hard for all k ≥ 2
- **Problem type:** Optimization (Maximize)

## Why Include

- Natural generalization of existing `MaxCut` (k=2)
- Codebase already has `MaxCut` — this extends it to k partitions
- Has direct QUBO/Ising formulation
- Complementary to `KColoring` (MaxkCut maximizes inter-partition edges; KColoring minimizes them... actually KColoring forbids them)
- Relationship: MaxkCut optimal with 0 intra-partition edges ↔ proper k-coloring exists

## Relationship to Existing Problems

- `MaxCut` = Max 2-Cut (k=2 special case, already implemented)
- `KColoring` = asks if we can k-partition with NO intra-partition edges
- `GraphPartitioning` = minimizes inter-partition edges with EQUAL partition sizes
- Max k-Cut has NO equal-size constraint (unlike GraphPartitioning/MinBisection)

## Variables

- Count: |V|
- Per-variable domain: {0, 1, …, k-1}
- Meaning: partition assignment for each vertex

## Example Instance

```
Graph: V={0,1,2,3}, E={(0,1,w=3),(1,2,w=2),(2,3,w=4),(0,3,w=1),(0,2,w=5)}
k = 3

Assignment [0,1,2,0]:
  (0,1): different partitions → +3
  (1,2): different → +2
  (2,3): 2≠0 → +4
  (0,3): same (both 0) → +0
  (0,2): 0≠2 → +5
  Total: 14

Assignment [0,1,2,1]:
  (0,1): +3, (1,2): +2, (2,3): +4, (0,3): +1, (0,2): +5
  Total: 15 (all edges cut!)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| MaxkCut → QUBO | Known | k-1 binary variables per vertex (one-hot encoding); penalty for same-partition adjacency |
| MaxkCut → ILP | Standard | Binary x_{v,p}; maximize Σ wₑ·(1 - Σp x_{u,p}·x_{v,p}) |
| MaxCut → MaxkCut | Trivial | Set k=2 |
| MaxkCut → KColoring | Related | If MaxkCut optimal = total edge weight, then k-coloring exists |

## Difficulty: Tier 2

- Very similar to MaxCut but with k partitions instead of 2
- Can reuse MaxCut infrastructure
- QUBO encoding needs one-hot per vertex (k-1 binary variables each)
