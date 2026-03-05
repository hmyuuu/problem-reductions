# Reduction Proposal: Pathwidth → Treewidth

## Overview

| Property | Value |
|----------|-------|
| Source | Pathwidth |
| Target | Treewidth |
| Type | One-way (trivial embedding) |
| Difficulty | Easy |

## Reduction Description

Every path decomposition is a tree decomposition where the underlying tree is a simple path. Therefore, any instance of the Pathwidth decision problem (pw(G) ≤ k?) can be directly answered by the Treewidth decision problem (tw(G) ≤ k?), since pw(G) ≥ tw(G) always holds.

### Forward Direction (Problem Reduction)

Given a Pathwidth instance (G, k):
- Create a Treewidth instance (G, k) — same graph, same target width
- If tw(G) ≤ k, this does NOT imply pw(G) ≤ k (treewidth can be strictly smaller)
- But: if we solve Treewidth and get tw(G) > k, then certainly pw(G) > k too

**Note:** This is a one-way reduction. The Pathwidth problem is at least as hard as Treewidth. A YES answer to Treewidth is necessary but not sufficient for Pathwidth.

### Solution Extraction

Given a tree decomposition T of width ≤ k:
- If T happens to be a path → it is also a valid path decomposition of width ≤ k
- In general, a tree decomposition of width w can be converted to a path decomposition of width ≤ w · O(log n) (Robertson & Seymour)
- For the exact pathwidth, additional work is needed — the tree decomposition provides a lower bound

### Key Inequality

```
tw(G) ≤ pw(G) ≤ tw(G) · (1 + log₂ n)
```

This means:
- Pathwidth is always at least treewidth (path is restricted tree)
- Pathwidth is at most O(log n) times treewidth
- For many graph classes (trees, outerplanar, series-parallel), the gap is tight

## Example

```
Graph: Binary tree T₇ with 7 vertices (depth 2)
        0
       / \
      1   2
     / \ / \
    3  4 5  6

Treewidth = 1 (all trees have treewidth 1)
Tree decomposition: bags {0,1}, {0,2}, {1,3}, {1,4}, {2,5}, {2,6}
  with tree edges matching the original tree structure

Pathwidth = 2 (need to "linearize" the branching)
Path decomposition: {3,1,0}, {1,0,4}, {0,2,5}, {2,5,6} — width 2
Note: pw > tw because the tree structure is lost in a path

Reduction: Pathwidth instance (T₇, k=2)
  → Treewidth instance (T₇, k=2)
  tw(T₇) = 1 ≤ 2 → YES → consistent (but we cannot conclude pw ≤ 2 from this alone)
  In fact pw(T₇) = 2 ≤ 2, so the answer is also YES

Reduction: Pathwidth instance (T₇, k=1)
  → Treewidth instance (T₇, k=1)
  tw(T₇) = 1 ≤ 1 → YES, but pw(T₇) = 2 > 1 → the actual answer is NO
  This demonstrates the one-way nature: Treewidth YES does not imply Pathwidth YES
```

## Formal Properties

| Property | Value |
|----------|-------|
| Variables change | None — same graph G |
| Constraint change | Relaxation — tree decomposition is less restricted than path decomposition |
| Overhead | O(1) — trivial identity mapping |
| Tightness | Sound but not complete — tw ≤ k is necessary but not sufficient for pw ≤ k |
| Gap | pw(G) ≤ tw(G) · O(log n), can be Θ(log n) for binary trees |

## Graph Classes Where pw = tw

For these graph classes, the reduction is exact (pw = tw):
- Complete graphs: pw = tw = n-1
- Cycles: pw = tw = 2
- Paths: pw = tw = 1
- Outerplanar graphs: pw = tw (for many subclasses)

## Implementation Notes

```rust
impl ReduceTo<Treewidth> for Pathwidth {
    fn reduce(&self) -> ReductionResult<Treewidth> {
        // Trivial: same graph, same k
        ReductionResult::new(
            Treewidth { graph: self.graph.clone(), k: self.k },
            // extract_solution: check if tree decomposition is also a path decomposition
        )
    }
}
```

## References

1. **Robertson, N. & Seymour, P.D.** (1983). "Graph minors. I. Excluding a forest." *Journal of Combinatorial Theory, Series B*, 35(1):39–61. DOI: [10.1016/0095-8956(83)90079-5](https://doi.org/10.1016/0095-8956(83)90079-5)
   — Introduces pathwidth; proves pw(G) ≤ tw(G) · O(log n) relationship.

2. **Bodlaender, H.L.** (1998). "A partial k-arboretum of graphs with bounded treewidth." *Theoretical Computer Science*, 209(1–2):1–45. DOI: [10.1016/S0304-3975(97)00228-4](https://doi.org/10.1016/S0304-3975(97)00228-4)
   — Survey of treewidth/pathwidth bounds; catalogs graph classes where pw = tw.

3. **Kinnersley, N.G.** (1992). "The vertex separation number of a graph equals its path-width." *Information Processing Letters*, 42(6):345–350. DOI: [10.1016/0020-0190(92)90234-M](https://doi.org/10.1016/0020-0190(92)90234-M)
   — Equivalence of vertex separation and pathwidth; pathwidth characterization via linear layouts.

4. **Korach, E. & Solel, N.** (1993). "Tree-width, path-width, and cutwidth." *Discrete Applied Mathematics*, 43(1):97–101. DOI: [10.1016/0166-218X(93)90171-J](https://doi.org/10.1016/0166-218X(93)90171-J)
   — Relates pathwidth, treewidth, and cutwidth; proves cutwidth ≥ pathwidth ≥ treewidth.

5. **Arnborg, S., Corneil, D.G. & Proskurowski, A.** (1987). "Complexity of finding embeddings in a k-tree." *SIAM Journal on Algebraic Discrete Methods*, 8(2):277–284. DOI: [10.1137/0608024](https://doi.org/10.1137/0608024)
   — NP-completeness of both treewidth and pathwidth decision problems.
