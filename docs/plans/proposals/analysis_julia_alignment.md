# Julia ProblemReductions.jl Alignment Analysis

## Julia Package Problems (17 models)
BMF, BicliqueCover, Circuit(SAT), Coloring, DominatingSet, Factoring,
IndependentSet, Matching, MaxCut, MaximalIS, Paintshop, QUBO,
Satisfiability, SetCovering, SetPacking, SpinGlass, VertexCovering

## Julia Package Rules (14 reduction files)
1. circuit_sat.jl (CircuitSAT ↔ SpinGlass)
2. factoring_sat.jl (Factoring → CircuitSAT)
3. independentset_setpacking.jl (MIS ↔ SetPacking)
4. matching_setpacking.jl (Matching → SetPacking)
5. sat_3sat.jl (SAT ↔ 3SAT)
6. sat_coloring.jl (SAT → Coloring)
7. sat_dominatingset.jl (SAT → DominatingSet)
8. sat_independentset.jl (SAT → IndependentSet)
9. spinglass_maxcut.jl (SpinGlass ↔ MaxCut)
10. spinglass_qubo.jl (SpinGlass ↔ QUBO)
11. spinglass_sat.jl (SpinGlass → SAT?)
12. vertexcovering_independentset.jl (VC ↔ MIS)
13. vertexcovering_setcovering.jl (VC → SetCovering)
14. rules.jl (registry)

## Rust Codebase Has But Julia Doesn't
- ILP (and all →ILP reductions)
- TravelingSalesman
- HamiltonianCycle
- MaximumClique (separate from MIS)
- KSatisfiability → QUBO
- KColoring → QUBO
- MinimumVertexCover → QUBO
- MaximumIndependentSet → QUBO
- MaximumSetPacking → QUBO
- UnitDiskGraph mapping infrastructure

## Julia Has But Rust Doesn't
- spinglass_sat.jl — SpinGlass → SAT (reverse direction!) — **worth investigating**

## Parity Status
The Rust codebase is a **superset** of the Julia package.
All Julia problems and reductions have Rust equivalents.
Rust additionally has ILP, TSP, HamiltonianCycle, Clique, and many QUBO reductions.

## Notable Finding: SpinGlass → SAT
Julia has `spinglass_sat.jl` which is NOT in the Rust codebase.
This would close a loop: SAT → MIS → QUBO → SpinGlass → SAT
Could be useful but may be complex. Worth filing as a potential addition.
