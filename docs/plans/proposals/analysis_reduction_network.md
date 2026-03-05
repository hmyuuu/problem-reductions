# Proposed Reduction Network — Full Graph

> Shows ALL reduction edges: existing (✅) + proposed (🆕)
> Arrows show reduction direction: Source → Target

## Visualization (ASCII)

```
                         ┌──────────────┐
                         │  CircuitSAT  │
                         └──────┬───────┘
                        ✅ ↓         ↑ ✅
                    ┌────────────┐   │
        ✅ ←────── │ SpinGlass  │ ──┘
        │          └─┬────┬─────┘  Factoring
   ┌────▼────┐   ✅↕ ↓  ✅↕ ↓
   │ MaxCut  │←──── │    ├────→ QUBO ←── 🆕 MinBisection
   └─────────┘      │    │       ↑  ↑
     🆕↓ QUBO       │    │    ✅ │  │ 🆕 SubsetSum
                     │    │  ┌───┘  │ 🆕 Partition
                     │    │  │      │ 🆕 Knapsack
                     │    │  │      │ 🆕 MaxSAT
                     │    │  ✅ ILP ←─── many problems
                     │    │         ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
                     │    │         │ │ │ │ │ │ │ │ └─ 🆕 FeedbackArcSet
                     │    │         │ │ │ │ │ │ │ └─── 🆕 FeedbackVertexSet
                     │    │         │ │ │ │ │ │ └───── 🆕 SteinerTree
                     │    │         │ │ │ │ │ └─────── 🆕 Knapsack
                     │    │         │ │ │ │ └───────── 🆕 ExactCover
                     │    │         │ │ │ └─────────── 🆕 HittingSet
                     │    │         │ │ └───────────── 🆕 SubsetSum/Partition
                     │    │         │ └─────────────── ✅ TSP, Clique, etc.
                     │    │         └─────────────────── ✅ MIS, VC, DS, etc.
                     │    │
            ┌────────┘    └──── 🆕 SpinGlass → MaxSAT
            │
     ┌──────▼──────┐
     │Satisfiability│
     └──┬──┬──┬────┘
     ✅ │  │  │
     ↕  │  │  └──→ ✅ KColoring ←──→ 🆕 CliqueCover
   KSat │  └─────→ ✅ DominatingSet ──→ 🆕 SetCovering
        │               ↑              ✅ ↕
        └───→ ✅ MIS ←──┘         SetCovering ←→ 🆕 HittingSet
              ↕  ✅ ↕                    ↑
         VertexCover  SetPacking    🆕 ExactCover
          ✅ ↕           ↑
         SetCovering  🆕 3DMatching
              ↑
         🆕 HittingSet

     🆕 Clique ←→ MIS  (complement — MISSING!)
     🆕 HamCycle → TSP  (MISSING!)

     Number family:
     🆕 Partition → SubsetSum → ILP/QUBO
     🆕 Knapsack → ILP/QUBO

     New graph problems:
     🆕 EdgeColoring → KColoring (line graph)
     🆕 LongestPath → ILP
     🆕 MinimalMaximalMatching → QUBO
     🆕 MultiwayCut → ILP
     🆕 QAP → QUBO/ILP
```

## Structural Analysis

### Hub Problems (most connections)
1. **ILP** — target of ~15 reductions (universal sink for → ILP)
2. **QUBO** — target of ~10 reductions (universal for quantum)
3. **SAT/MIS** — source of many Karp reductions
4. **SpinGlass** — bidirectional bridge between QUBO and MaxCut

### Isolated Clusters (need more connections)
- **Number family** (SubsetSum, Partition, Knapsack) — only connect to ILP/QUBO, not to graph/SAT problems
  - Could add: SubsetSum → SAT (encode equality as clauses)
- **Feedback problems** (FVS, FAS) — only connect to ILP
  - Could add: VertexCover → FVS (known reduction)
- **New graph problems** (EdgeColoring, LongestPath, MultiwayCut) — sparsely connected

### Missing "Famous" Reductions (priority to add)
1. VertexCover → HamiltonianCycle (Karp chain, not yet in codebase)
2. 3SAT → 3DMatching (Karp chain)
3. ExactCover → 3DMatching (reverse of 3DM → EC)

## Edge Count Summary

| Type | Count |
|------|-------|
| Existing reduction edges | 47 |
| Proposed new reduction edges | ~35 |
| Missing cross-reductions (existing problems) | 7 |
| **Total after implementation** | **~89** |
