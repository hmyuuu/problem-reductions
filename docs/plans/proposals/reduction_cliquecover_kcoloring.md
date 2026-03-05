# Reduction Proposal: CliqueCover ↔ KColoring

## Reduction Direction: Bidirectional

### CliqueCover → KColoring (Forward)

**Algorithm:** k-color the complement graph.

Given CliqueCover instance (G, k):
1. Compute complement graph Ḡ = complement(G)
2. Create KColoring instance (Ḡ, k)

**Correctness:**
- A partition of V into cliques in G ↔ a proper coloring of Ḡ
- Vertices in the same clique in G are all adjacent → in Ḡ they are all non-adjacent → can share a color
- Vertices sharing a color in Ḡ are non-adjacent in Ḡ → adjacent in G → form a clique

**Solution extraction:** Direct — clique assignment = color assignment

### KColoring → CliqueCover (Reverse)

**Algorithm:** Apply clique cover to complement.

Given KColoring instance (G, k):
1. Compute complement graph Ḡ = complement(G)
2. Create CliqueCover instance (Ḡ, k)

**Solution extraction:** Direct — same mapping

**Overhead:** O(|V|²) for complement computation

## Key Dependencies

Need to verify:
- `complement()` method exists on SimpleGraph → check `src/topology/graph.rs`
- KColoring's `k` parameter type (uses KValue enum) vs CliqueCover's `k: usize`
  - May need to handle KValue ↔ usize conversion

## Test Pattern

Closed-loop: create graph, reduce CliqueCover→KColoring, solve, extract, verify.
Also test: KColoring→CliqueCover→back = identity (up to isomorphism).
