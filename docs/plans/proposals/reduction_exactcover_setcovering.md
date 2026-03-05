# Reduction Proposal: ExactCover → MinimumSetCovering

## Reduction Direction: One-way

### ExactCover → MinimumSetCovering

**Algorithm:** Relaxation with equality check

Given ExactCover instance: universe U of size n, sets S = {S₀, ..., Sₘ₋₁}

Construct MinimumSetCovering instance:
- Same universe U, same sets S
- Weights: all unit weights (w = [1, 1, ..., 1])

**Correctness (partial):**
- ExactCover requires each element covered **exactly once**
- SetCovering requires each element covered **at least once**
- A minimum SetCovering solution that uses k sets, where each element is covered exactly once, is also an ExactCover solution
- But a SetCovering optimal may cover some elements multiple times → not valid ExactCover

**Solution extraction:**
1. Get SetCovering solution
2. Check if each element is covered exactly once
3. If yes → valid ExactCover solution; if no → ExactCover is infeasible

**Note:** This is a one-way relaxation, not an equivalence. The reduction is useful for finding candidates but doesn't guarantee ExactCover feasibility.

## Alternative: ExactCover → ILP (better reduction)

The ILP reduction is more faithful:
- Binary xⱼ per set
- Constraints: Σⱼ:i∈Sⱼ xⱼ = 1 for all i (equality, not inequality!)
- Objective: feasibility (or minimize Σxⱼ)

This exactly captures the ExactCover semantics.
