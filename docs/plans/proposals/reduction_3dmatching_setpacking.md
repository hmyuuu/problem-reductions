# Reduction Proposal: 3DMatching → MaximumSetPacking

## Reduction Direction: One-way

### ThreeDimensionalMatching → MaximumSetPacking

**Algorithm:** Interpret triples as 3-element sets

Given 3DMatching instance: sets X, Y, Z of size n, triples T:
1. Create universe U = X ∪ Y ∪ Z of size 3n
   - Map: X elements → {0, ..., n-1}
   - Map: Y elements → {n, ..., 2n-1}
   - Map: Z elements → {2n, ..., 3n-1}
2. For each triple (x, y, z) ∈ T, create set {x, y+n, z+2n}
3. Create MaximumSetPacking instance with these sets and universe size 3n

**Correctness:**
- A perfect 3D matching (n disjoint triples covering all elements) ↔ a set packing of size n where all 3n elements are covered
- 3DM asks: is there a matching of size n? → SetPacking optimal ≥ n?

**Solution extraction:** Direct — selected sets = selected triples

**Overhead:** O(|T|) time and space

## Notes

- This shows 3DM as a special case of SetPacking
- Each set has exactly 3 elements (3-uniform)
- The universe has a 3-partite structure
- This is a classic Karp reduction
