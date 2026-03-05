# Model Proposal: MaximumAcyclicSubgraph

## Problem Definition

**Maximum Acyclic Subgraph (Maximum DAG)**

Given a directed graph G = (V, A), find a maximum-weight subset of arcs A' ⊆ A such that the subgraph (V, A') is acyclic (a DAG).

- **Category:** graph
- **Reference:** Garey & Johnson (1979), [GT8] (complement of FeedbackArcSet)
- **Complexity:** NP-hard
- **Problem type:** Optimization (Maximize)

## Why Include

- **Exact complement of FeedbackArcSet**: MaxAcyclicSubgraph = total weight − MinFeedbackArcSet
- If we implement FAS, we get MAS for free (and vice versa)
- More natural in some applications (ranking, tournament ordering)
- Reduces complexity of implementing both problems

## Relationship

```
MaxAcyclicSubgraph(G) = TotalWeight(G) − MinFeedbackArcSet(G)
```

The optimal MAS arc set is the complement of the optimal FAS.

## Recommendation

**Do NOT implement as a separate problem.** Instead, note in `model_feedback_arc_set.md` that MAS is the complement. Users can derive MAS solutions from FAS solutions.

If the team wants it as a separate problem for pedagogical reasons, it's trivial:
- Same struct as FeedbackArcSet
- `evaluate()`: keep selected arcs (not remove), check acyclicity, return weight of kept arcs
- `direction()`: Maximize (instead of Minimize)
