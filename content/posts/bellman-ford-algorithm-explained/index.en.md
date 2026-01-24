---
title: "Bellman-Ford Algorithm"
date: 2024-06-17T18:40:50+09:00
tags: ["Algorithm", "Graph", "Shortest Path"]
description: "Shortest path algorithm for graphs with negative edge weights."
draft: false
---

The Bellman-Ford algorithm is an algorithm that finds the shortest paths from a single source vertex to all other vertices in a weighted graph. Independently discovered by Richard Bellman and Lester Ford Jr. in the 1950s, it has powerful characteristics that distinguish it from Dijkstra's algorithm: it can handle edges with negative weights and detect whether negative cycles exist in the graph. Using a dynamic programming approach with O(VE) time complexity, it is used as a core component in various real-world applications including network routing protocols, arbitrage detection in financial markets, and minimum cost flow problems.

## History of the Bellman-Ford Algorithm

> **What is the Bellman-Ford Algorithm?**
>
> An algorithm that finds the shortest paths from a single source vertex to all other vertices in a weighted graph, capable of handling negative weight edges and detecting the presence of negative cycles.

The Bellman-Ford algorithm was first proposed in 1956 by American mathematician Lester Randolph Ford Jr. in his research on the maximum flow problem. In 1958, Richard Ernest Bellman independently published the same algorithm in his research on dynamic programming. The algorithm was named after both researchers. Richard Bellman, as the founder of dynamic programming, proposed the "Bellman equation" and systematized the methodology for solving optimization problems by dividing them into smaller subproblems. The Bellman-Ford algorithm is regarded as a representative example of applying these dynamic programming principles to graph shortest path problems.

Interestingly, Edward F. Moore described essentially the same algorithm in research published in 1957, so some literature refers to this algorithm as the "Bellman-Ford-Moore algorithm." This algorithm has had a profound impact on network flow theory and routing protocol development. It became the theoretical foundation for RIP (Routing Information Protocol), which was widely used as the early routing system of the Internet in the 1980s. Due to its characteristic of handling negative weights, it is also practically utilized in arbitrage detection in financial markets, currency exchange optimization, and various Operations Research problems.

## How the Algorithm Works

The core of the Bellman-Ford algorithm is repeating the edge relaxation operation V-1 times for all edges in the graph, utilizing the optimal substructure and overlapping subproblems properties of dynamic programming in this process.

### The Concept of Edge Relaxation

> **What is Edge Relaxation?**
>
> For an edge (u, v) from vertex u to vertex v with weight w, if dist[u] + w < dist[v], the operation updates dist[v] to dist[u] + w. This is the process of updating distance information when a shorter path is discovered.

Edge relaxation is an operation that updates the distance when the path to v via u is shorter than the currently known shortest distance to v. The term "relaxation" originates from the mathematical meaning of loosening distance constraints. This operation is performed in constant time O(1) and is the most fundamental component of the Bellman-Ford algorithm.

### Mathematical Basis for V-1 Iterations

A simple path (one that does not contain cycles) in a graph can contain at most V-1 edges, because a path from the starting vertex to another vertex can pass through at most V-1 vertices when it does not visit the same vertex more than once. If a path contains V or more edges, by the pigeonhole principle, it must visit the same vertex more than once, forming a cycle. In general cycles (not negative cycles), there exists a shorter path with the cycle removed, so it cannot be the shortest path.

Therefore, in the first iteration, the shortest distances of vertices reachable with at most 1 edge from the starting vertex are correctly calculated. In the second iteration, the shortest distances of vertices reachable with at most 2 edges are calculated. After the i-th iteration, the shortest paths using at most i edges are determined. This is the core principle of dynamic programming: a bottom-up approach that progressively solves larger problems (shortest paths using more edges) using the solutions of smaller subproblems (shortest paths using fewer edges).

### Algorithm Execution Steps

**Step 1: Initialization**

Create an array dist[] to store the distance from the starting vertex to each vertex. Set the starting vertex's distance to 0 and initialize all other vertex distances to infinity (INF).

**Step 2: Edge Relaxation Iteration (V-1 times)**

Perform edge relaxation for all edges, and repeat this entire process V-1 times. For each edge (u, v, w), if dist[u] + w < dist[v], update dist[v] = dist[u] + w.

**Step 3: Negative Cycle Check**

After completing V-1 iterations, attempt relaxation one more time for all edges. If any edge is updated in this V-th iteration, a negative cycle exists in the graph, and the shortest path is not defined.

### Working Example

Assume we have the following graph. Starting from vertex 1, we find the shortest distance to all vertices.

```
Vertices: 1, 2, 3, 4
Edges: 1→2 (weight 4), 1→3 (weight 3), 2→3 (weight -2), 3→4 (weight 2)
```

1. Initialization: dist = [0, INF, INF, INF]
2. 1st iteration:
   - 1→2: dist[2] = 0 + 4 = 4
   - 1→3: dist[3] = 0 + 3 = 3
   - 2→3: dist[3] = min(3, 4 + (-2)) = 2
   - 3→4: dist[4] = 2 + 2 = 4
3. 2nd iteration:
   - No changes
4. 3rd iteration:
   - No changes
5. Negative cycle check: No edges updated
6. Result: dist = [0, 4, 2, 4]

## Implementation Example

Here is a C++ implementation of the Bellman-Ford algorithm.

```cpp
#include <iostream>
#include <vector>
using namespace std;

#define INF 1e9

int main() {
    int n, m; // n: number of vertices, m: number of edges
    cin >> n >> m;

    vector<tuple<int, int, int>> edges; // (source, destination, weight)
    vector<long long> dist(n + 1, INF);

    // Edge input
    for (int i = 0; i < m; i++) {
        int u, v, w;
        cin >> u >> v >> w;
        edges.push_back({u, v, w});
    }

    int start;
    cin >> start;

    dist[start] = 0;

    // V-1 edge relaxation iterations
    for (int i = 0; i < n - 1; i++) {
        for (auto& [u, v, w] : edges) {
            if (dist[u] != INF && dist[v] > dist[u] + w) {
                dist[v] = dist[u] + w;
            }
        }
    }

    // Negative cycle check
    bool hasNegativeCycle = false;
    for (auto& [u, v, w] : edges) {
        if (dist[u] != INF && dist[v] > dist[u] + w) {
            hasNegativeCycle = true;
            break;
        }
    }

    if (hasNegativeCycle) {
        cout << "A negative cycle exists." << '\n';
    } else {
        for (int i = 1; i <= n; i++) {
            if (dist[i] == INF) {
                cout << "INF" << '\n';
            } else {
                cout << dist[i] << '\n';
            }
        }
    }

    return 0;
}
```

### Code Explanation

- `edges`: Stores all edges as (source vertex, destination vertex, weight) tuples. Using an edge list instead of an adjacency list simplifies the implementation.
- `dist`: An array storing the shortest distance from the starting vertex to each vertex. Uses long long type to prevent overflow due to negative weights.
- The outer loop iterates V-1 times, traversing all edges and performing edge relaxation. A final traversal checks for negative cycles.

## Handling Negative Weights

The most significant characteristic of the Bellman-Ford algorithm is its ability to correctly handle edges with negative weights. This is the most fundamental difference from Dijkstra's algorithm.

### Why Dijkstra Fails with Negative Weights

Dijkstra's algorithm uses a greedy approach to select the vertex with the shortest discovered distance at each step and "finalize" that vertex's shortest distance. This is based on the premise that once a vertex's shortest distance is finalized, it will not be updated again. This premise holds when all edge weights are positive, but when negative weights exist, shorter paths through already finalized vertices can be discovered later, preventing the algorithm from guaranteeing correct results.

### How Bellman-Ford Handles Negative Weights

The Bellman-Ford algorithm uses a method that updates the shortest distances of all vertices "simultaneously." Without the concept of finalizing vertices like Dijkstra, it repeatedly performs relaxation on all edges through V-1 iterations. Even if shorter paths are discovered later due to negative weights, distances can be updated in the next iteration, allowing the algorithm to find the correct shortest distances as long as no negative cycles exist.

### Real-World Applications of Negative Weights

Negative weights naturally appear in various real-world problems.

- **Currency exchange conversion**: When exchange rates are log-transformed, multiplication becomes addition, and exchange profits are expressed as negative cycles.
- **Network flow problems**: Negative cost edges in residual graphs are used to minimize costs.
- **Game theory and optimization**: Negative weights are naturally modeled to represent losses or penalties.

## Negative Cycle Detection

> **What is a Negative Cycle?**
>
> A cycle where the sum of the weights of its constituent edges is negative. If a negative cycle exists, the distance can be infinitely reduced by continuously traversing the cycle, so the shortest path is not defined.

### Impact of Negative Cycles

When a negative cycle exists, the vertices included in that cycle have their distances decrease each time the cycle is traversed. Theoretically, if the cycle is repeated infinitely, the distance can be made negative infinity (-∞). Therefore, a clear shortest distance cannot be defined. In real-world problems, this can indicate that arbitrage opportunities exist or that there are logical errors in the modeling.

### Detecting Negative Cycles via the V-th Iteration

Since all shortest paths should be determined after V-1 iterations in the Bellman-Ford algorithm, if edges are still being updated in the V-th iteration, this means paths using V or more edges are shorter. Using V or more edges necessarily involves a cycle, and a cycle that decreases the distance means it is a negative cycle. By checking all edges one more time at the end of the algorithm to see if distances are updated, the existence of negative cycles can be determined in O(E) time.

### Handling When Negative Cycles Exist

When a negative cycle is detected, the algorithm is generally terminated and reports that a negative cycle exists. If there are vertices that cannot reach the negative cycle from the starting vertex, the shortest distances for those vertices may still be valid. However, in most applications, the existence of a negative cycle itself indicates a problem situation, so separate handling is required.

## Time Complexity Analysis

The time complexity of the Bellman-Ford algorithm is O(VE), where V is the number of vertices and E is the number of edges.

### Detailed O(VE) Analysis

The algorithm performs V-1 outer iterations, and in each iteration, it attempts relaxation for all E edges, so the total number of operations is (V-1) × E. An additional E operations are needed for negative cycle checking, but this is asymptotically included in O(VE). Since each edge relaxation is performed in constant time O(1), the overall time complexity is O(VE).

### Analysis by Graph Type

| Graph Type | Number of Edges | Time Complexity | Characteristics |
|------------|-----------------|-----------------|-----------------|
| Sparse Graph | E ≈ V | O(V²) | Trees, road networks |
| General Graph | E ≈ V log V | O(V² log V) | Social networks |
| Dense Graph | E ≈ V² | O(V³) | Complete graphs |

In dense graphs, the time complexity can increase to O(V³), making it very slow. In such cases, using Dijkstra's algorithm is much more efficient if there are no negative weights.

## Comparison with Dijkstra's Algorithm

| Comparison Item | Bellman-Ford | Dijkstra |
|-----------------|--------------|----------|
| Time Complexity | O(VE) | O(E log V) |
| Negative Weights | Supported | Not supported |
| Negative Cycle Detection | Supported | Not supported |
| Approach | Dynamic Programming | Greedy Algorithm |
| Implementation Complexity | Simple (triple loop) | Complex (requires priority queue) |
| General Speed | Slow | Fast |

### Algorithm Selection Guide

- **All weights positive, speed is important**: Dijkstra's algorithm
- **Negative weights exist**: Bellman-Ford algorithm
- **Negative cycle detection needed**: Bellman-Ford algorithm
- **Simple implementation preferred, small graph**: Bellman-Ford algorithm

## Real-World Applications

The Bellman-Ford algorithm is essential in areas requiring negative weight handling or negative cycle detection.

### Network Routing Protocol (RIP)

RIP (Routing Information Protocol) is a distance vector routing protocol standardized as RFC 1058 in 1988, based on the Bellman-Ford algorithm. Each router periodically (typically every 30 seconds) exchanges its routing table with neighboring routers, and based on this information, runs a distributed version of the Bellman-Ford algorithm (Distributed Bellman-Ford) to calculate the shortest paths to all destinations in the network. RIP was widely used in the early routing systems of the Internet and is still utilized in small-scale networks today due to its simplicity.

### Arbitrage Detection

When modeling exchange rates between multiple currencies in financial markets as a graph, transforming exchange rate r to -log(r) converts the multiplication of the exchange process to addition. For example, if the product of exchange rates in the USD → EUR → JPY → USD exchange path is greater than 1, an arbitrage opportunity exists. After log transformation, this is expressed as a negative cycle. By detecting negative cycles with the Bellman-Ford algorithm, risk-free profit opportunities can be found. This is a technique actually used in high-frequency trading (HFT) systems.

### Minimum Cost Maximum Flow Problem

In network flow problems where edges have unit costs as well as capacities, several algorithms that solve the problem of sending maximum flow with minimum cost (e.g., Successive Shortest Paths, Cycle-Canceling) use Bellman-Ford internally. In residual graphs, backward edges can have negative costs, so Bellman-Ford is needed instead of Dijkstra. This is applied to logistics, transportation, communication network optimization, and more.

### System of Difference Constraints

A system of difference constraints, a special form of linear programming, consists of constraints of the form x_j - x_i ≤ c_ij. This can be modeled as a graph and solved using the Bellman-Ford algorithm. If a solution satisfying the constraints exists, the shortest distances become one solution. If a negative cycle exists, it means no solution satisfies the constraints.

## Optimization Techniques

While the basic form of the Bellman-Ford algorithm always performs V-1 complete iterations, several optimization techniques can be applied to achieve faster convergence in practice.

### Early Termination Optimization

If no edge is relaxed in a particular iteration, all shortest distances are already determined, so the remaining iterations can be skipped and the algorithm can be terminated. This optimization is very simple to implement while terminating with far fewer iterations than V-1 in many real-world graphs, significantly improving average performance.

```cpp
bool updated = false;
for (auto& [u, v, w] : edges) {
    if (dist[u] != INF && dist[v] > dist[u] + w) {
        dist[v] = dist[u] + w;
        updated = true;
    }
}
if (!updated) break; // Early termination
```

### SPFA (Shortest Path Faster Algorithm)

SPFA is an optimized variant of the Bellman-Ford algorithm, proposed by Duan Fanding of China in 1994, using a queue data structure to selectively process only vertices whose distances have been updated. Instead of checking all edges in every iteration, it only relaxes adjacent edges of vertices whose distances have changed, operating in O(E) time on average. However, in the worst case, it is still O(VE). Worst-case scenarios can occur in certain types of graphs (especially grid graphs), and recently, competitive programming has included test cases intentionally designed to slow down SPFA.

## Conclusion

The Bellman-Ford algorithm was independently discovered by Richard Bellman and Lester Ford Jr. in the 1950s and is a representative example of applying dynamic programming principles to graph shortest path problems. While generally slower than Dijkstra's algorithm with O(VE) time complexity, it has powerful characteristics: it can correctly handle edges with negative weights and detect the presence of negative cycles in graphs. It plays a core role in various real-world applications including RIP routing protocol, arbitrage detection in financial markets, minimum cost flow problems, and systems of difference constraints. In certain problem domains, it is an irreplaceable and essential algorithm.
