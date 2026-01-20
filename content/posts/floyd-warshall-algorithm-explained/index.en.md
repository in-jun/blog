---
title: "The Complete Guide to the Floyd-Warshall Algorithm"
date: 2024-06-17T19:29:50+09:00
tags: ["Floyd-Warshall", "algorithm", "shortest-path", "graph", "dynamic-programming"]
description: "A comprehensive guide covering the history of the Floyd-Warshall algorithm independently published by Robert Floyd and Stephen Warshall in 1962, its dynamic programming-based recurrence relation and triple loop operation, O(V³) time complexity analysis, negative weight handling and negative cycle detection methods, and real-world applications including network diameter calculation and transitive closure."
draft: false
---

The Floyd-Warshall algorithm is a dynamic programming-based algorithm that finds the shortest paths between all pairs of vertices in a graph. Independently published by Robert Floyd and Stephen Warshall in 1962, it differs from Dijkstra's and Bellman-Ford algorithms by computing shortest paths for all pairs simultaneously in a single execution. With O(V³) time complexity, it can handle edges with negative weights and detect the presence of negative cycles, making it a core component in various fields including network diameter calculation, transitive closure operations, and database query optimization.

## History of the Floyd-Warshall Algorithm

> **What is the Floyd-Warshall Algorithm?**
>
> A dynamic programming-based algorithm that simultaneously finds the shortest paths between all pairs of vertices in a weighted graph, capable of handling negative weight edges and detecting the presence of negative cycles.

The Floyd-Warshall algorithm was presented by American computer scientist Robert W. Floyd in his 1962 paper "Algorithm 97: Shortest Path" published in Communications of the ACM, applied to the shortest path problem. In the same year, Stephen Warshall independently published the same algorithm applied to the transitive closure problem in his paper "A Theorem on Boolean Matrices" in the Journal of the ACM. The algorithm was named after both researchers. Interestingly, French mathematician Bernard Roy had already described essentially the same algorithm in research published in 1959, so some European literature refers to it as the "Roy-Floyd-Warshall algorithm."

This algorithm is a classic example of dynamic programming frequently covered in computer science education and has made significant contributions to the development of graph theory and optimization theory. Robert Floyd received the Turing Award in 1978 for his contributions to programming languages and algorithms, including this algorithm. In modern computer science, the algorithm is practically utilized in various fields including network routing, reachability analysis in game theory, relational operations in databases, and connectivity analysis in social networks.

## How the Algorithm Works

The core idea of the Floyd-Warshall algorithm is the concept of "intermediate vertices," progressively computing the shortest path from i to j using only vertices from the set {1, 2, ..., k} as intermediate vertices.

### Dynamic Programming Recurrence Relation

> **Core Recurrence Relation**
>
> D[k][i][j] = min(D[k-1][i][j], D[k-1][i][k] + D[k-1][k][j])
>
> When vertices 1 through k can be used as intermediate vertices, the shortest distance from i to j is the shorter of (1) the path not passing through k and (2) the path passing through k.

In actual implementation, a 2D array is used instead of a 3D array for space optimization. This is safe because at the k-th stage, the values D[i][k] and D[k][j] are identical to the values of paths that do not use k as an intermediate vertex.

```
D[i][j] = min(D[i][j], D[i][k] + D[k][j])
```

This recurrence relation embodies the meaning "update if going through vertex k is shorter," utilizing the optimal substructure property that subpaths of shortest paths are also shortest paths.

### Meaning of the Triple Loop

The algorithm structure consists of three nested loops, and the role and order of each loop are crucial to correctness.

**Outermost loop (k)**: Sequentially selects intermediate vertices from 1 to V. At the k-th iteration, only vertices {1, 2, ..., k} are considered as intermediate vertices. As k increases, paths using more intermediate vertices are explored, progressively reaching the optimal solution.

**Middle loop (i)**: Iterates through starting vertices from 1 to V.

**Innermost loop (j)**: Iterates through destination vertices from 1 to V.

The loop order being k → i → j is essential. If k were in the innermost position, the algorithm would not work correctly. k must be outermost to ensure the progressive expansion of dynamic programming, where the k-th stage uses results from up to the (k-1)-th stage.

### Algorithm Execution Steps

**Step 1: Initialization**

Create a V × V 2D array D. Initialize adjacent vertices with edge weights, set unconnected vertices to infinity (INF), and set the distance to self D[i][i] to 0.

**Step 2: Execute Triple Loop**

Iterate intermediate vertex k from 1 to V, applying D[i][j] = min(D[i][j], D[i][k] + D[k][j]) for all (i, j) pairs.

**Step 3: Check Results**

After the algorithm terminates, D[i][j] contains the shortest distance from vertex i to vertex j. If a negative cycle exists, cases where D[i][i] < 0 occur among the diagonal elements.

### Working Example

Assume we have the following graph.

```
Vertices: 1, 2, 3, 4
Edges: 1→2(3), 1→3(8), 1→4(∞), 2→3(2), 2→4(5), 3→4(1)
```

Initial distance matrix:
```
    1    2    3    4
1 [ 0    3    8    ∞  ]
2 [ ∞    0    2    5  ]
3 [ ∞    ∞    0    1  ]
4 [ ∞    ∞    ∞    0  ]
```

After k=1 (considering vertex 1 as intermediate): No change

After k=2 (considering vertices 1, 2 as intermediate):
- D[1][3] = min(8, 3+2) = 5 (1→2→3)
- D[1][4] = min(∞, 3+5) = 8 (1→2→4)

After k=3 (considering vertices 1, 2, 3 as intermediate):
- D[1][4] = min(8, 5+1) = 6 (1→2→3→4)
- D[2][4] = min(5, 2+1) = 3 (2→3→4)

Final result:
```
    1    2    3    4
1 [ 0    3    5    6  ]
2 [ ∞    0    2    3  ]
3 [ ∞    ∞    0    1  ]
4 [ ∞    ∞    ∞    0  ]
```

## Implementation Example

Here is a C++ implementation of the Floyd-Warshall algorithm.

```cpp
#include <iostream>
#include <vector>
using namespace std;

#define INF 1e9

int main() {
    int n, m; // n: number of vertices, m: number of edges
    cin >> n >> m;

    // Initialize distance matrix
    vector<vector<long long>> dist(n + 1, vector<long long>(n + 1, INF));

    for (int i = 1; i <= n; i++) {
        dist[i][i] = 0; // Distance to self is 0
    }

    // Edge input
    for (int i = 0; i < m; i++) {
        int a, b, c;
        cin >> a >> b >> c;
        dist[a][b] = min(dist[a][b], (long long)c); // Handle duplicate edges
    }

    // Floyd-Warshall algorithm
    for (int k = 1; k <= n; k++) {
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= n; j++) {
                if (dist[i][k] != INF && dist[k][j] != INF) {
                    dist[i][j] = min(dist[i][j], dist[i][k] + dist[k][j]);
                }
            }
        }
    }

    // Negative cycle check
    bool hasNegativeCycle = false;
    for (int i = 1; i <= n; i++) {
        if (dist[i][i] < 0) {
            hasNegativeCycle = true;
            break;
        }
    }

    if (hasNegativeCycle) {
        cout << "A negative cycle exists." << '\n';
    } else {
        // Output results
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= n; j++) {
                if (dist[i][j] == INF) {
                    cout << "INF ";
                } else {
                    cout << dist[i][j] << ' ';
                }
            }
            cout << '\n';
        }
    }

    return 0;
}
```

### Code Explanation

- `dist`: A V × V 2D array where dist[i][j] stores the shortest distance from vertex i to j.
- `dist[i][i] = 0`: Distance to self must always be initialized to 0. Omitting this leads to incorrect results.
- `dist[i][k] != INF && dist[k][j] != INF` condition: Checks before performing addition with INF to prevent overflow.
- Duplicate edge handling: Multiple edges for the same (a, b) pair may be given, so the minimum value is selected.

## Negative Weights and Negative Cycles

Unlike Dijkstra's algorithm, the Floyd-Warshall algorithm can correctly handle edges with negative weights. This is because, due to the nature of dynamic programming, it systematically explores all possible paths.

### Meaning of Negative Cycles

> **What is a Negative Cycle?**
>
> A cycle where the sum of the weights of its constituent edges is negative. If a negative cycle exists, the distance can be reduced to negative infinity by repeating the cycle infinitely, so the shortest path is not defined.

For example, if the sum of weights on a path A → B → C → A is -5, the distance continues to decrease as -5, -10, -15, ... as the cycle repeats. Therefore, the shortest distance for all vertex pairs involving vertices in a negative cycle or reachable from such vertices becomes negative infinity.

### Negative Cycle Detection Method

Negative cycles can be detected in O(V) time by examining the diagonal elements after running the Floyd-Warshall algorithm. Normally, the shortest distance D[i][i] back to oneself should always be 0. However, if a negative cycle exists, vertices with D[i][i] < 0 are found. Such a vertex i is either included in a negative cycle or can reach a negative cycle.

### Real-World Applications of Negative Cycles

Negative cycles are utilized in arbitrage detection in financial trading. When modeling exchange rates between multiple currencies as a graph, transforming exchange rate r to -log(r) converts the multiplication of the exchange process to addition. The existence of a negative cycle indicates an arbitrage opportunity to gain risk-free profit by repeating exchanges.

## Time Complexity Analysis

The time complexity of the Floyd-Warshall algorithm is O(V³), where V is the number of vertices.

### Detailed O(V³) Analysis

Each loop of the triple nested loop executes V times, so a total of V × V × V = V³ comparison and update operations are performed. Each operation consists of addition, comparison, and minimum value selection, performed in constant time O(1). Space complexity is O(V²), requiring a V × V 2D array. Even with an additional next array for path reconstruction, it remains O(V²).

### Practical Limits

| Number of Vertices (V) | Number of Operations | Expected Execution Time |
|------------------------|----------------------|-------------------------|
| 100 | 10⁶ | < 0.01 seconds |
| 500 | 1.25 × 10⁸ | About 0.5 seconds |
| 1,000 | 10⁹ | About 5 seconds |
| 5,000 | 1.25 × 10¹¹ | Not practical |

On modern computers, V up to about 500 can be processed within 1 second. When V exceeds 1,000, execution time increases rapidly, and other algorithms should be considered for large-scale graphs.

## Comparison with Other Shortest Path Algorithms

| Comparison Item | Floyd-Warshall | Dijkstra (V times) | Bellman-Ford (V times) |
|-----------------|----------------|--------------------|------------------------|
| Time Complexity | O(V³) | O(VE log V) | O(V²E) |
| Sparse Graph (E ≈ V) | O(V³) | O(V² log V) | O(V³) |
| Dense Graph (E ≈ V²) | O(V³) | O(V³ log V) | O(V⁴) |
| Negative Weights | Supported | Not supported | Supported |
| Negative Cycle Detection | Supported | Not supported | Supported |
| Implementation Complexity | Very simple | Medium | Simple |

### Algorithm Selection Guide

- **All-pairs shortest paths, dense graph**: Floyd-Warshall algorithm
- **All-pairs shortest paths, sparse graph, positive weights only**: Run Dijkstra V times
- **Single-source shortest path**: Dijkstra or Bellman-Ford
- **Negative weights, negative cycle detection needed**: Floyd-Warshall or Bellman-Ford
- **Simple implementation preferred, small number of vertices**: Floyd-Warshall algorithm

## Path Reconstruction

In many cases, not only the shortest distance but also the actual path needs to be reconstructed. For this purpose, a next array is used.

```cpp
#include <iostream>
#include <vector>
using namespace std;

#define INF 1e9

void printPath(int i, int j, vector<vector<int>>& next) {
    if (next[i][j] == -1) {
        cout << "No path" << '\n';
        return;
    }

    cout << i;
    while (i != j) {
        i = next[i][j];
        cout << " -> " << i;
    }
    cout << '\n';
}

int main() {
    int n, m;
    cin >> n >> m;

    vector<vector<long long>> dist(n + 1, vector<long long>(n + 1, INF));
    vector<vector<int>> next(n + 1, vector<int>(n + 1, -1));

    for (int i = 1; i <= n; i++) {
        dist[i][i] = 0;
    }

    for (int i = 0; i < m; i++) {
        int a, b, c;
        cin >> a >> b >> c;
        if (c < dist[a][b]) {
            dist[a][b] = c;
            next[a][b] = b; // Initialize with directly connected vertex
        }
    }

    for (int k = 1; k <= n; k++) {
        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= n; j++) {
                if (dist[i][k] != INF && dist[k][j] != INF &&
                    dist[i][k] + dist[k][j] < dist[i][j]) {
                    dist[i][j] = dist[i][k] + dist[k][j];
                    next[i][j] = next[i][k]; // First vertex to visit when going from i to j
                }
            }
        }
    }

    // Print path from 1 to n
    printPath(1, n, next);

    return 0;
}
```

next[i][j] stores the vertex visited immediately after i on the shortest path from i to j. Whenever the distance is updated, next is also updated. When printing the path, follow next to sequentially list all intermediate vertices.

## Real-World Applications

The Floyd-Warshall algorithm is used as a core component in various real-world problems.

### Transitive Closure

Transitive closure is the problem of determining whether vertex j is "reachable" from vertex i in a graph, checking only connectivity while ignoring weights. The Warshall algorithm, a variant of Floyd-Warshall, solves this problem using boolean operations. It is utilized in database relationship analysis (e.g., "Is A an ancestor of B?"), control flow reachability in program analysis, and compiler optimization.

### Network Diameter Calculation

The maximum of all shortest distances between vertex pairs is the network's diameter, which is a key indicator for evaluating network efficiency and vulnerabilities. In communication networks, it represents the worst-case transmission delay. In social network analysis, it is used to calculate the distance between "the two most distant people" (e.g., Six Degrees of Separation).

### Transportation Network Optimization Between Cities

Pre-calculating shortest paths between all city pairs is utilized for logistics center placement, prioritizing transportation infrastructure investment, and optimizing emergency service deployment. In small-scale networks with limited vertex counts, Floyd-Warshall can pre-calculate all paths and respond to queries in O(1) time.

### Game AI Pathfinding

When game maps are sufficiently small (e.g., sectors in grid-based strategy games), pre-calculating all-pairs shortest paths enables fast pathfinding at runtime. This provides much faster response times than running the A* algorithm each time and is an effective optimization strategy when memory constraints permit.

## Optimization Techniques

### Space Optimization

Space can be reduced from O(V³) to O(V²) by reusing a 2D array D[i][j] instead of a 3D array D[k][i][j]. This is safe because at the k-th stage, D[i][k] and D[k][j] are identical to the (k-1)-th results.

### Parallel Processing

Updates for all (i, j) pairs at each k stage are independent of each other and can be parallelized. Using GPUs or multi-core CPUs to process the inner two loops in parallel can achieve significant speed improvements, which is an important technique for achieving practical performance in large-scale graphs.

### Early Termination

If no distances are updated at a particular k stage, no updates will occur in subsequent stages either, so the algorithm can be terminated. However, this check itself costs O(V²), so it is not always advantageous. In practice, its effectiveness varies depending on graph characteristics.

## Implementation Considerations

- **INF value selection**: Choose a value large enough but with room so that INF + INF does not overflow. For int range, 1e9 is appropriate; for long long range, around 1e18/2 is suitable.
- **Self-distance initialization**: Omitting D[i][i] = 0 leads to incorrect results, so initialization is mandatory.
- **Duplicate edge handling**: Multiple edges may be given for the same (a, b) pair, so the minimum value must be selected.
- **Undirected graphs**: Represent as bidirectional edges; both (a, b) and (b, a) must be added.
- **Path reconstruction**: If needed, maintain the next array from the start; it is difficult to add later.

## Conclusion

The Floyd-Warshall algorithm was independently published by Robert Floyd and Stephen Warshall in 1962. It calculates the shortest paths between all pairs of vertices in a graph in O(V³) time using the principles of dynamic programming. Unlike Dijkstra's and Bellman-Ford, it can obtain shortest paths for all pairs simultaneously in a single execution, handle negative weights, and detect negative cycles. Implemented with just a triple loop and one line of update logic, it is very simple yet powerful. It is used as a core component in various fields including transitive closure, network diameter calculation, transportation network optimization, and game AI. It is the most suitable choice when all-pairs shortest paths are needed in dense graphs with a few hundred or fewer vertices.
