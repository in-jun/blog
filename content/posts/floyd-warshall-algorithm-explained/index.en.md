---
title: "Understanding the Floyd-Warshall Algorithm"
date: 2024-06-17T19:29:50+09:00
tags: ["Floyd-Warshall", "shortest path", "algorithm"]
draft: false
description: "The Floyd-Warshall algorithm is a dynamic programming-based algorithm that finds shortest paths between all pairs of vertices. It can handle negative weights with O(V^3) time complexity and is also used for transitive closure computation."
---

## Floyd-Warshall Algorithm

The Floyd-Warshall algorithm finds the shortest paths between all pairs of vertices in a graph. It uses a dynamic programming approach and has a time complexity of O(V^3). It can handle edges with negative weights and detect negative cycles. Unlike Dijkstra's or Bellman-Ford algorithms, it computes shortest paths for all pairs at once.

### History of the Algorithm

The Floyd-Warshall algorithm was independently published by Robert Floyd and Stephen Warshall in 1962. Floyd applied it to the shortest path problem. Warshall applied it to the transitive closure problem. Interestingly, Bernard Roy had already published a similar algorithm in 1959. However, it was not widely known.

This algorithm is a classic example of dynamic programming. It has made significant contributions to graph theory and optimization theory. In modern computer science, it is used in various fields. These include network routing, game theory, and database query optimization.

### Algorithm Principle

The Floyd-Warshall algorithm solves the All-Pairs Shortest Path problem. The key idea is to consider paths that go through intermediate vertices sequentially. When using vertex k as an intermediate vertex, there are two cases for the path from i to j.

The first is a direct path without going through k. The second is a path that goes through k. The algorithm selects the shorter of these two paths. By repeating this process for all vertices, we can finally obtain the shortest paths for all pairs.

### Recurrence Relation

The core of the algorithm is expressed by the following recurrence relation.

```
D[i][j] = min(D[i][j], D[i][k] + D[k][j])
```

Here, D[i][j] represents the shortest distance from vertex i to vertex j. D[i][k] + D[k][j] is the distance from vertex i to j via k. This recurrence relation embodies the meaning "update if going through k is shorter." This utilizes the optimal substructure property. The property states that subpaths of the shortest path are also shortest paths.

We iterate k from 1 to n. For each k, we perform this comparison for all i and j pairs. As k increases, more intermediate vertices are considered. We progressively reach the optimal solution. When k=1, only vertex 1 is considered as an intermediate vertex. When k=2, vertices 1 and 2 are considered, and so on.

The correctness of this recurrence relation can be proven by induction. If correct results are obtained up to step k-1, correct results are obtained at step k as well. The base case is when k=0. This is the initial state considering only the weights of directly connected edges.

### Dynamic Programming Approach

The Floyd-Warshall algorithm has all three core elements of dynamic programming.

First, it has Optimal Substructure. The shortest path from i to j consists of the shortest path from i to k and the shortest path from k to j. Second, Overlapping Subproblems exist. Multiple paths share the same intermediate vertices. The same calculations are repeated. Third, it stores and reuses the results of subproblems.

The meaning of the triple loop is clear. The outermost loop selects the intermediate vertex k. The middle loop selects the starting vertex i. The innermost loop selects the destination vertex j. This order is important. At the kth step, only vertices from 1 to k are considered as intermediate vertices.

### Procedure

The algorithm proceeds in the following steps.

1. Initialize the 2D array D. Set the weight of edges between adjacent vertices. Set infinity between unconnected vertices. Set the distance to oneself as 0.

2. Use triple nested loops to explore all vertices. The outer loop iterates the intermediate vertex k from 1 to n.

3. For each k, examine all i, j pairs. Apply the recurrence relation to update the shortest paths.

4. When all iterations are complete, D[i][j] contains the shortest distance from i to j.

### Example Code

```cpp
#include <iostream>
#include <vector>
using std::cin;
using std::cout;
using std::min;
using std::vector;

#define INF 1000000000

int main()
{
    int n, m;
    cin >> n >> m;

    vector<vector<int>> graph(n + 1, vector<int>(n + 1, INF));

    for (int i = 1; i <= n; i++)
    {
        graph[i][i] = 0;
    }

    for (int i = 0; i < m; i++)
    {
        int a, b, c;
        cin >> a >> b >> c;
        graph[a][b] = c;
    }

    for (int k = 1; k <= n; k++)
    {
        for (int i = 1; i <= n; i++)
        {
            for (int j = 1; j <= n; j++)
            {
                graph[i][j] = min(graph[i][j], graph[i][k] + graph[k][j]);
            }
        }
    }

    for (int i = 1; i <= n; i++)
    {
        for (int j = 1; j <= n; j++)
        {
            if (graph[i][j] == INF)
            {
                cout << "INF ";
            }
            else
            {
                cout << graph[i][j] << ' ';
            }
        }
        cout << '\n';
    }

    return 0;
}
```

### Negative Weights and Negative Cycles

An important feature of the Floyd-Warshall algorithm is its ability to handle edges with negative weights. Dijkstra's algorithm cannot handle negative weights. Floyd-Warshall computes them accurately. This is because it systematically explores all possible paths due to the nature of dynamic programming.

However, caution is needed when negative cycles exist. A negative cycle is a cycle where the sum of the weights is negative. If such a cycle exists, the distance becomes shorter as you keep cycling. The shortest path is not defined. For example, if the sum of weights on a path A → B → C → A is -5, the distance continues to decrease. It goes to -5, -10, -15 as the cycle repeats.

Negative cycles can be detected by examining the diagonal elements after running the algorithm. If there is a case where D[i][i] < 0, it means there is a negative cycle involving i. Normally, the shortest distance back to oneself should always be 0. Using this property, the existence of negative cycles can be determined in O(1) time.

In a graph with negative cycles, the shortest distances for all vertex pairs connected to vertices in the cycle become negative infinity. Practically, when a negative cycle is detected, this information should be communicated to the user. Special handling should be performed. In financial arbitrage detection or currency exchange graph analysis, negative cycles can represent profit opportunities.

### Time Complexity Analysis

The time complexity of the Floyd-Warshall algorithm is O(V^3). Here V is the number of vertices. Each loop of the triple nested loop runs V times. A total of V * V * V = V^3 operations are performed. Each operation consists of comparison, addition, and minimum value selection. All of which are performed in constant time.

The space complexity is O(V^2). A two-dimensional array of size V x V is required. To reconstruct paths, an additional V x V array is needed. But it is still O(V^2). This has the characteristic of depending only on the number of vertices. It is regardless of the number of edges.

This complexity is efficient when the number of vertices is small. It is practical enough for V of a few hundred or less. However, as V increases to thousands or tens of thousands, computation time increases rapidly. For example, V=100 requires 1 million operations. V=1000 requires 1 billion operations. V=10000 requires 1 trillion operations. On modern computers, up to about V=500 can be processed within 1 second.

Therefore, for large-scale graphs, other algorithms should be considered. If only single-source shortest paths are needed, Dijkstra's or Bellman-Ford is more efficient. In sparse graphs, the number of edges E is much smaller than V^2. Algorithms that utilize E are advantageous. Conversely, if all pairs of shortest paths are needed in dense graphs, Floyd-Warshall is most suitable.

### Comparison with Other Algorithms

Shortest path algorithms each have advantages and disadvantages. They should be chosen according to the situation.

Running Dijkstra's algorithm V times can find shortest paths for all pairs. Using a priority queue takes O(E log V) per run. The total is O(V * E log V). In dense graphs, E is close to V^2. This results in O(V^3 log V), which is slower than Floyd-Warshall. However, in sparse graphs, E is much smaller. Dijkstra is faster. For example, in a graph where E = O(V), it becomes O(V^2 log V). This is much faster than Floyd-Warshall's O(V^3).

Running Bellman-Ford algorithm V times results in O(V^2 * E). In dense graphs, it becomes O(V^4), which is very slow. Even in sparse graphs, O(V^2 * E) is usually larger than O(V^3). The advantage of Bellman-Ford is that it handles negative weights and clearly detects negative cycles. However, since Floyd-Warshall can also handle negative weights, there is rarely a reason to run Bellman-Ford multiple times.

Floyd-Warshall should be used in the following cases. First, when the number of vertices is small and shortest paths for all pairs are needed. Second, when shortest paths for all pairs are needed in dense graphs. Third, when implementation should be simple and easy to understand. Fourth, when negative weights need to be handled.

### Practical Applications

The Floyd-Warshall algorithm is applied to various real-world problems.

Transitive Closure is the most direct application. It is the problem of determining whether vertex j is reachable from vertex i in a graph. You only need to check connectivity, ignoring weights. This is used in database relationship analysis and network connectivity analysis.

Calculating the Network Diameter is also an important application. The maximum of the shortest distances among all pairs is the network diameter. This is used as an indicator to evaluate network efficiency. It is used in communication network and social network analysis.

Path reconstruction is a practical requirement. Often, not only the shortest distance but also the actual path needs to be known. For this, a separate array is maintained to record intermediate vertices. Path reconstruction is essential in navigation and network routing.

It is also used in designing transportation networks between cities. By calculating the shortest paths between all city pairs, transportation infrastructure can be optimized. It is similarly used in logistics center placement and communication network design.

In game development, it is used for pathfinding for AI characters. If the game map is small, calculating all pairs of shortest paths in advance allows for fast pathfinding at runtime.

### Path Reconstruction Example

In many cases, not only the shortest distance but also the actual path needs to be known. For this purpose, a next array is used.

```cpp
#include <iostream>
#include <vector>
using std::cin;
using std::cout;
using std::min;
using std::vector;

#define INF 1000000000

void printPath(int i, int j, vector<vector<int>>& next)
{
    if (next[i][j] == -1)
    {
        cout << "No path\n";
        return;
    }

    cout << i;
    while (i != j)
    {
        i = next[i][j];
        cout << " -> " << i;
    }
    cout << '\n';
}

int main()
{
    int n, m;
    cin >> n >> m;

    vector<vector<int>> graph(n + 1, vector<int>(n + 1, INF));
    vector<vector<int>> next(n + 1, vector<int>(n + 1, -1));

    for (int i = 1; i <= n; i++)
    {
        graph[i][i] = 0;
    }

    for (int i = 0; i < m; i++)
    {
        int a, b, c;
        cin >> a >> b >> c;
        graph[a][b] = c;
        next[a][b] = b;
    }

    for (int k = 1; k <= n; k++)
    {
        for (int i = 1; i <= n; i++)
        {
            for (int j = 1; j <= n; j++)
            {
                if (graph[i][k] + graph[k][j] < graph[i][j])
                {
                    graph[i][j] = graph[i][k] + graph[k][j];
                    next[i][j] = next[i][k];
                }
            }
        }
    }

    // Example path output
    printPath(1, n, next);

    return 0;
}
```

next[i][j] stores the next vertex to visit after i on the shortest path from i to j. Whenever the distance is updated, next is also updated. When printing the path, follow next to list all intermediate vertices.

### Optimization Techniques

There are several techniques to make the Floyd-Warshall algorithm more efficient.

Space optimization is important in memory-constrained environments. Space can be saved by reusing a 2D array instead of a 3D array. This overwrites the k-1th result in the kth step. This can be done safely due to the nature of the recurrence relation.

Parallel processing is an opportunity for performance improvement. The i and j loops are independent of each other. They can be parallelized. At each k step, all i, j pairs can be calculated simultaneously. Utilizing GPUs or multi-core CPUs can achieve significant speed improvements.

Early termination optimization is also possible. If no distance is updated at a certain step, there is no further improvement. The algorithm can be terminated. However, since this check itself has a cost, it is not always advantageous.

### Practical Tips

There are several important points to be careful about when implementing.

Initialization must be accurate. Set INF for unconnected vertices. Always set the distance to oneself as 0. Forgetting this leads to incorrect results. Also, when the same edge is given multiple times, the smallest weight should be selected.

Choosing the INF value is also important. Using too large a value can cause overflow during addition. A safe method is to choose a value large enough that INF + INF does not overflow. It should have about half the margin. For example, around 1e9 is appropriate for the int range.

Negative cycle detection is performed by examining the diagonal after running the algorithm. If there is any case where D[i][i] < 0, a negative cycle exists. In this case, the user should be warned. Special handling should be performed.

Directed and undirected graphs should be distinguished. Undirected graphs are represented as bidirectional edges. The edge must be added twice. Directed graphs add edges only in the given direction.

If path reconstruction is needed, the next array must be maintained from the beginning. It is difficult to add later. The next array is initially set to directly connected vertices. It is updated together with distance updates.

### Advantages

The Floyd-Warshall algorithm has several strengths.

-   It computes shortest paths between all vertex pairs at once. It is efficient as precomputation when multiple queries are expected.
-   It can accurately handle edges with negative weights. It solves problems that are impossible with Dijkstra.
-   Implementation is very simple and easy to understand. It is implemented with just triple loops and one line of update logic.
-   It can detect negative cycles. This is an important feature in many real-world problems.
-   It is easy to extend to other problems such as transitive closure. The structure of the algorithm is clear, making modifications easy.

### Disadvantages

The limitations of the algorithm are also clear.

-   Due to O(V^3) time complexity, it is impractical for large-scale graphs. When vertices exceed thousands, computation time increases rapidly.
-   When only single-source shortest paths are needed, it performs excessive computation. Running Dijkstra once is more efficient.
-   O(V^2) space complexity results in high memory usage. Memory shortage problems can occur with many vertices.
-   If negative cycles exist, shortest paths cannot be calculated. Only cycle detection is possible, and correct distances cannot be obtained.
-   It is less efficient than algorithms that utilize the number of edges in sparse graphs. This is because it examines all edges, including those that do not exist.

### Time Complexity

-   The Floyd-Warshall algorithm has a time complexity of O(V^3). Here V is the number of vertices.
-   The space complexity is O(V^2). Even with additional arrays for path reconstruction, it is still O(V^2).
-   It is practical when the number of vertices is a few hundred or less. For larger graphs, other algorithms should be considered.
