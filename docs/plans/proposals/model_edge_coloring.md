# Model Proposal: EdgeColoring

## Problem Definition

**Edge Coloring (Minimum Edge Coloring / Chromatic Index)**

Given an undirected graph G = (V, E), find a proper edge coloring using the minimum number of colors such that no two edges sharing a vertex have the same color.

- **Category:** graph
- **Reference:** Vizing's theorem (1964); Garey & Johnson (1979), [GT40]
- **Complexity:** NP-complete (to determine if chromatic index = Δ or Δ+1)
- **Problem type:** Satisfaction (Metric = bool) — given k colors, can we color?

## Why Include

- Natural complement to vertex coloring (`KColoring` already exists)
- Vizing's theorem: chromatic index is either Δ or Δ+1 (where Δ = max degree)
- Decision problem: can we edge-color with exactly Δ colors?
- Applications: scheduling, timetabling, register allocation

## Variables

- Count: |E| (one per edge)
- Per-variable domain: {0, 1, …, k-1}
- Meaning: color assigned to edge e

## Schema

| Field | Description |
|-------|-------------|
| `graph` | The graph G |
| `k` | Number of colors available |

## Example Instance

```
Graph: K₃ (triangle), V={0,1,2}, E={(0,1),(1,2),(0,2)}
k = 3 (Δ = 2, need at least 2 colors; actually need 3 for odd cycle)
Color: (0,1)→0, (1,2)→1, (0,2)→2
  Vertex 0: edges colored {0, 2} — distinct ✓
  Vertex 1: edges colored {0, 1} — distinct ✓
  Vertex 2: edges colored {1, 2} — distinct ✓
Valid with k=3. Not valid with k=2 (try and see: impossible for triangle).
```

## Reductions

| Reduction | Type | Description |
|-----------|------|-------------|
| EdgeColoring → KColoring | Standard | Construct line graph L(G); vertex-color L(G) with k colors |
| EdgeColoring → ILP | Standard | Binary x_{e,c} per edge-color pair; for each vertex v: all incident edges get distinct colors |

## Relationship to Line Graph

Edge coloring of G = Vertex coloring of the line graph L(G).
- L(G) has one vertex per edge of G
- Two vertices in L(G) are adjacent iff corresponding edges in G share a vertex
- This means EdgeColoring → KColoring via line graph construction

## Difficulty: Tier 2

- Mirror of KColoring but on edges
- Line graph construction provides natural reduction to existing KColoring
- Could be a good "easy" addition since KColoring infrastructure exists
