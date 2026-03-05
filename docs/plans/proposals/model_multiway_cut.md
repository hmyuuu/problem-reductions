# Model Proposal: MultiwaCut

## Problem Definition

**Multiway Cut (Minimum Multiway Cut)**

Given an undirected weighted graph G = (V, E) and a set of terminal vertices T = {t₁, …, tₖ} ⊆ V, find a minimum-weight set of edges whose removal disconnects every pair of terminals.

- **Category:** graph
- **Reference:** Dahlhaus et al. (1992); Garey & Johnson related problems
- **Complexity:** NP-hard for k ≥ 3 (polynomial for k = 2 via min-cut)
- **Problem type:** Optimization (Minimize)

## Why Include

- Generalizes MinCut (k=2 is polynomial, k≥3 is NP-hard)
- Complementary to MaxCut (MaxCut maximizes cut of 2 partitions; MultiwayCut minimizes cut separating k terminals)
- Important in network design, VLSI, image segmentation
- Has clean ILP formulation

## Variables

- Count: |E| (one per edge)
- Per-variable domain: binary {0, 1}
- Meaning: xₑ = 1 if edge e is cut (removed)

## Schema

| Field | Description |
|-------|-------------|
| `graph` | The graph G |
| `terminals` | List of terminal vertex indices |
| `edge_weights` | Weight per edge |

## Example Instance

```
Graph: V={0,1,2,3,4}, terminals={0,2,4}
Edges: (0,1,w=2), (1,2,w=3), (2,3,w=1), (3,4,w=2), (0,4,w=4), (1,3,w=5)

Need to disconnect 0 from 2, 0 from 4, and 2 from 4.
Cut {(0,1), (2,3)}: weight 2+1=3
  0 disconnected from {1,2,3,4}? Check: 0-4 via direct edge (0,4). Not disconnected!
Cut {(0,1), (0,4), (2,3)}: weight 2+4+1=7
  0 isolated. 2 connected to 3,4 via (3,4). So 2 and 4 still connected. Need more.
Cut {(0,1), (0,4), (3,4)}: weight 2+4+2=8
  0 isolated. 4 isolated. 2 connected to 1,3. All terminals separated. ✓
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| MultiwayCut → ILP | Standard | Binary xₑ per edge; for each terminal pair (tᵢ,tⱼ): at least one edge on every path between them must be cut |
| MultiwayCut → MaxCut | Related | k=2 case with specific structure |

## Difficulty: Tier 3

- Need connectivity checks between terminals
- ILP formulation requires path/flow constraints (similar to SteinerTree)
- k=2 case is polynomial (reduces to standard min-cut)
