# Model Proposal: LongestPath

## Problem Definition

**Longest Path**

Given an undirected weighted graph G = (V, E) and two vertices s, t ∈ V, find the longest simple (no repeated vertices) path from s to t.

- **Category:** graph
- **Reference:** Garey & Johnson (1979), [ND29]
- **Complexity:** NP-hard (even for unweighted graphs)
- **Problem type:** Optimization (Maximize)

## Why Include

- Dual of shortest path (polynomial) — shows how optimization direction changes complexity
- Related to HamiltonianCycle (Hamiltonian path = longest path of length |V|-1)
- Has natural ILP formulation
- Good educational example

## Variables

- Count: |V| (one per vertex)
- Per-variable domain: binary {0, 1}
- Meaning: xᵥ = 1 if vertex v is on the path

## Schema

| Field | Description |
|-------|-------------|
| `graph` | The graph G |
| `source` | Start vertex s |
| `target` | End vertex t |
| `edge_weights` | Weight per edge (default: unit) |

## Example Instance

```
Graph: V={0,1,2,3}, E={(0,1),(1,2),(2,3),(0,3),(1,3)}
Source: 0, Target: 3
Paths:
  0→3: length 1
  0→1→3: length 2
  0→1→2→3: length 3 (longest simple path)
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| LongestPath → ILP | Standard | Flow-based: maximize path length, flow conservation at each vertex |
| HamiltonianCycle → LongestPath | Trivial | Hamiltonian path exists iff longest path has length |V|-1 |

## Difficulty: Tier 2-3

- Path validity check (connected, simple) in evaluate() needs BFS/DFS
- Similar complexity to SteinerTree and TSP
- But simpler than TSP (no need for Hamiltonian constraint)
