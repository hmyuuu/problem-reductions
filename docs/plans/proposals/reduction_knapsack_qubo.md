# Reduction Proposal: Knapsack → QUBO

## Algorithm (Lucas 2014 §5.2)

Given Knapsack: item weights w, values v, capacity C

**Challenge:** Inequality constraint wᵀx ≤ C requires slack variables.

**Step 1:** Introduce slack variables to convert inequality to equality:
```
Σᵢ wᵢxᵢ + Σⱼ 2ʲyⱼ = C
```
where yⱼ are binary slack variables encoding the gap (0 to C) in binary.
Need ⌈log₂(C+1)⌉ slack variables.

**Step 2:** QUBO Hamiltonian:
```
H = -A·Σᵢ vᵢxᵢ + B·(Σᵢ wᵢxᵢ + Σⱼ 2ʲyⱼ - C)²
```
where A > 0 weights the objective, B > 0 penalizes constraint violation.
B must be large enough: B > A·max(vᵢ) ensures feasibility is enforced.

**QUBO variables:** n + ⌈log₂(C+1)⌉ binary variables total.

**QUBO Q matrix:**
- Diagonal from objective: Qᵢᵢ -= A·vᵢ (for item variables)
- Diagonal + off-diagonal from penalty: expand (Σwᵢxᵢ + Σ2ʲyⱼ - C)²

**Overhead:** n + O(log C) variables.

**Note:** The binary encoding of slack variables is a general technique used whenever QUBO needs to handle inequality constraints. Same pattern applies to any problem with capacity/budget constraints.
