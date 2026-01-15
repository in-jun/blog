---
title: "Understanding the Bellman-Ford Algorithm"
date: 2024-06-17T18:40:50+09:00
tags: ["Bellman-Ford", "Algorithm", "Shortest Path"]
description: "The Bellman-Ford algorithm is a single-source shortest path algorithm independently discovered by Richard Bellman (1958) and Lester Ford (1956). Unlike Dijkstra's algorithm, it can handle edges with negative weights and uses a dynamic programming approach with O(VE) time complexity to find shortest paths. It can also detect the presence of negative cycles, making it essential for various real-world applications including network routing, currency exchange rate conversion, and arbitrage detection."
draft: false
---

## Bellman-Ford Algorithm

The Bellman-Ford algorithm is an algorithm that finds the shortest paths from a single source vertex to all other vertices in a weighted graph. It is similar to Dijkstra's algorithm but can correctly handle graphs with negative weight edges. Additionally, it provides the powerful capability to detect whether a negative cycle exists in the graph.

### History of the Bellman-Ford Algorithm

The Bellman-Ford algorithm was independently discovered in research published by Richard Bellman in 1958 and Lester Ford in 1956. It was named after both researchers. This algorithm has significant importance because it uses a dynamic programming approach to solve the shortest path problem.

Richard Bellman, the founder of dynamic programming, presented a methodology for solving optimization problems by dividing them into smaller subproblems. The Bellman-Ford algorithm is a representative example of applying these dynamic programming principles to graph shortest path problems.

The algorithm has had a major impact on network flow theory and routing protocol development. It became the theoretical foundation for distance vector routing protocols such as RIP (Routing Information Protocol). It also played an important role in designing the early routing mechanisms of the Internet. Furthermore, due to its characteristic of handling negative weights, it has been practically utilized in various domains including arbitrage detection in financial markets, currency exchange conversion problems, and diverse optimization problems.

### Algorithm Operating Principle

The core operating principle of the Bellman-Ford algorithm is to repeat edge relaxation for all edges V-1 times. Here, V represents the number of vertices in the graph. Edge relaxation refers to the process of updating distance information when a shorter path than the currently known shortest distance is discovered.

#### Edge Relaxation Concept

Edge relaxation is the process where, for an edge (u, v) from vertex u to vertex v with weight w, if dist[u] + w < dist[v], then dist[v] is updated to dist[u] + w. This means that the path to v via u is shorter than the currently known shortest path to v. Therefore, it updates to the better path.

#### Why Repeat V-1 Times

The shortest path in a graph can contain at most V-1 edges. This is because when the path from the starting vertex to another vertex is a simple path (not containing cycles), it can consist of at most V-1 edges. If a path contains V or more edges, it must visit the same vertex more than once, creating a cycle. In general cases without negative cycles, there exists a shorter path with the cycle removed, so it cannot be the shortest path.

Therefore, in the first iteration, the shortest distances of vertices reachable with one edge from the starting vertex are determined. In the second iteration, the shortest distances of vertices reachable with two edges are determined. By repeating this process V-1 times, all shortest paths containing at most V-1 edges are determined. This is the core principle of dynamic programming: using the solutions of smaller subproblems (shortest paths using fewer edges) to solve larger problems (shortest paths using more edges).

### Algorithm Execution Steps

1. Initialize an array storing distances from the starting vertex to each vertex. Set the distance of the starting vertex to 0. Initialize the distances of all other vertices to infinity (INF).

2. Perform edge relaxation for all edges. Repeat this process V-1 times (the number of vertices minus 1).

3. For each edge (u, v), if dist[u] + weight(u, v) < dist[v], update dist[v] to dist[u] + weight(u, v).

4. After V-1 iterations are complete, attempt relaxation one more time for all edges to check for the existence of negative cycles.

5. If any edge is updated in the V-th iteration, a negative cycle exists in the graph. In this case, the shortest path is not defined.

### Example Code

```cpp
#include <iostream>
#include <vector>
using std::cin;
using std::cout;
using std::pair;
using std::vector;

#define INF 1000000000

int main()
{
    int n, m;
    cin >> n >> m;

    vector<vector<pair<int, int>>> graph(n + 1);
    vector<int> dist(n + 1, INF);

    for (int i = 0; i < m; i++)
    {
        int u, v, w;
        cin >> u >> v >> w;
        graph[u].push_back({v, w});
    }

    int start;
    cin >> start;

    dist[start] = 0;

    for (int i = 0; i < n - 1; i++)
    {
        for (int u = 1; u <= n; u++)
        {
            for (auto p : graph[u])
            {
                int v = p.first;
                int w = p.second;

                if (dist[u] != INF && dist[v] > dist[u] + w)
                {
                    dist[v] = dist[u] + w;
                }
            }
        }
    }

    for (int u = 1; u <= n; u++)
    {
        for (auto p : graph[u])
        {
            int v = p.first;
            int w = p.second;

            if (dist[u] != INF && dist[v] > dist[u] + w)
            {
                cout << "A negative cycle exists.\n";
                return 0;
            }
        }
    }

    for (int i = 1; i <= n; i++)
    {
        if (dist[i] == INF)
        {
            cout << "INF\n";
        }
        else
        {
            cout << dist[i] << '\n';
        }
    }

    return 0;
}
```

### Handling Negative Weights

The biggest characteristic of the Bellman-Ford algorithm is its ability to correctly handle edges with negative weights. This is the most significant difference from Dijkstra's algorithm.

#### Limitations of Dijkstra's Algorithm

Dijkstra's algorithm uses a greedy approach to select the vertex with the shortest discovered distance at each step and confirms that vertex's shortest distance. This is based on the premise that once a vertex's shortest distance is confirmed, it will not be updated again. This premise holds when all edge weights are positive. However, if there are negative weights, shorter paths passing through already confirmed vertices can be discovered later, causing the algorithm to fail.

#### Bellman-Ford's Negative Weight Handling Principle

The Bellman-Ford algorithm uses a method that simultaneously updates the shortest distances of all vertices. Without the concept of confirming vertices, it repeatedly performs relaxation on all edges through V-1 iterations. Therefore, even if shorter paths are discovered later due to negative weights, distances can be updated in the next iteration, allowing the correct shortest distances to be found. Thanks to this characteristic, as long as no negative cycles exist, correct shortest paths can be calculated even when edge weights are negative.

#### Real-World Applications of Negative Weights

Negative weights appear in various real-world problems. In currency exchange rate conversion problems, when exchange rates are log-transformed, multiplication becomes addition and exchange rate profits are expressed as negative cycles. In network flow problems, edges with negative costs can be used to minimize costs. In game theory and optimization problems, negative weights are naturally modeled to represent losses.

### Negative Cycle Detection

A negative cycle is a cycle where the sum of the weights of the edges constituting the cycle is negative. If a negative cycle exists, you can continuously traverse the cycle to infinitely reduce the distance. Therefore, the shortest path is not defined.

#### Meaning of Negative Cycles

When a negative cycle exists, the vertices included in that cycle have their distances decrease each time the cycle is traversed. Theoretically, if the cycle is repeated infinitely, the distance can be made negative infinity. Therefore, a clear shortest distance cannot be defined. In real-world problems, this can mean that arbitrage opportunities exist or that there are errors in the modeling.

#### Detecting Negative Cycles with the V-th Iteration

Since all shortest paths should be determined after V-1 iterations in the Bellman-Ford algorithm, if edges are still being updated in the V-th iteration, this means that paths using V or more edges are shorter. This is evidence that a negative cycle exists that includes a cycle and decreases the distance. Therefore, by checking all edges one more time at the end of the algorithm to see if distances are updated, the existence of negative cycles can be determined.

#### Handling When Negative Cycles Exist

When a negative cycle is detected, the shortest path is not defined, so the algorithm is generally terminated and reports that a negative cycle exists. If there are vertices that cannot reach the negative cycle, the shortest distances for those vertices may be valid. However, in most applications, the existence of the negative cycle itself indicates a problem situation, so separate handling is required.

### Time Complexity Analysis

The time complexity of the Bellman-Ford algorithm is expressed as O(VE). Here, V is the number of vertices and E is the number of edges.

#### Detailed O(VE) Analysis

The algorithm performs V-1 external iterations. In each iteration, it attempts relaxation for all E edges, so the total number of operations is (V-1) × E. An additional E operations are needed for negative cycle checking. However, this is asymptotically included in the O(VE) time complexity. Since each edge relaxation is performed in constant time O(1), the overall algorithm's time complexity becomes O(VE).

#### Worst Case Analysis

In the case of a dense graph, the number of edges E can be O(V²). In this case, the time complexity of the Bellman-Ford algorithm becomes O(V × V²) = O(V³), making it very slow. On the other hand, in sparse graphs, E = O(V), so the time complexity improves to O(V²). In practice, with early termination optimization, it can operate faster on average.

#### Time Complexity Comparison with Dijkstra

Dijkstra's algorithm has a time complexity of O((V+E) log V) when implemented using a priority queue. In dense graphs, it becomes O(V² log V), and in sparse graphs, it becomes O(E log V), generally much faster than Bellman-Ford. However, since Dijkstra cannot handle negative weights, when there are no negative weights and speed is important, Dijkstra should be used. When there are negative weights or negative cycle detection is needed, Bellman-Ford must be used.

### Comparison with Dijkstra's Algorithm

Both Bellman-Ford and Dijkstra solve the single-source shortest path problem, but they differ in approach and applicable situations.

#### Speed Difference

Dijkstra's algorithm with O((V+E) log V) is generally much faster than Bellman-Ford's O(VE). The performance difference is especially large in large-scale graphs. This is because Dijkstra processes each vertex only once with a greedy approach, while Bellman-Ford repeatedly checks all edges V-1 times.

#### Negative Weight Handling

Dijkstra requires all edge weights to be 0 or greater, but Bellman-Ford can handle negative weights. This is the most important difference. If the problem has negative weights, Bellman-Ford must be used.

#### Implementation Complexity

Bellman-Ford can be implemented with just triple nested loops, making the code simple and easy to understand. Dijkstra requires using a priority queue or heap data structure, making the implementation relatively complex. For educational purposes or simple applications, Bellman-Ford may be more suitable.

#### Usage Scenarios

Dijkstra is used in most real-world applications such as road networks, GPS navigation, and network packet routing. Bellman-Ford is used in special cases requiring currency exchange rates, arbitrage detection, negative cost flow problems, and negative cycle detection.

### Real-World Applications

The Bellman-Ford algorithm plays a key role in various real-world problems, especially in areas requiring negative weight handling or negative cycle detection.

#### Network Routing Protocols

RIP (Routing Information Protocol) is a distance vector routing protocol based on the Bellman-Ford algorithm. Each router periodically exchanges its routing table with neighboring routers to calculate shortest paths. It was widely used in the early routing systems of the Internet and is still utilized in small-scale networks today.

#### Arbitrage Detection

When modeling exchange rates between multiple currencies in financial markets as a graph, if the log values of exchange rates are used as edge weights, the exchange process is expressed as addition. If a negative cycle exists, it means there is an arbitrage opportunity. Therefore, negative cycles can be detected using the Bellman-Ford algorithm to find risk-free profit opportunities.

#### Currency Exchange Rate Conversion

When finding the optimal currency exchange path between multiple currencies, the Bellman-Ford algorithm can be used. The optimal path can be calculated even when each exchange has fees and exchange rates change over time. Negative weights can also be used to model promotions or rebates.

#### Minimum Cost Flow Problems

In network flow problems where edges have costs as well as capacities, algorithms that solve the problem of sending maximum flow with minimum cost internally use Bellman-Ford. This is applied to logistics, transportation, communication network optimization, and more.

### Optimization Techniques

While the basic form of the Bellman-Ford algorithm always performs V-1 complete iterations, several optimization techniques can be applied to achieve faster convergence in practice.

#### Early Termination Optimization

If no edge is relaxed in a particular iteration, all shortest distances are already determined. Therefore, the remaining iterations can be skipped and the algorithm can be terminated. In many cases, this allows finding shortest paths with far fewer iterations than V-1, significantly improving average performance.

#### SPFA (Shortest Path Faster Algorithm)

SPFA is an optimized variant of the Bellman-Ford algorithm that uses a queue data structure to selectively process only vertices whose distances have been updated. Instead of repeatedly checking all edges, it only relaxes adjacent edges of vertices whose distances have changed. It operates in O(E) time on average and does not exceed O(VE) in the worst case, making it practically widely used.

#### Queue-Based Improvement

The queue is initialized with the starting vertex. Vertices are removed from the queue one by one, and edges departing from those vertices are relaxed. Vertices whose distances are updated through edge relaxation are added back to the queue. Duplicate additions of vertices already in the queue are prevented to increase efficiency. This method often shows performance similar to Dijkstra in many cases while being able to handle negative weights.

### Summary

The Bellman-Ford algorithm is differentiated from Dijkstra's algorithm by its ability to handle negative weights and detect negative cycles. Although it has O(VE) time complexity and is generally slower than Dijkstra in typical cases, it is an indispensable important algorithm in certain problem domains. As a representative example of applying dynamic programming principles to graph problems, it allows learning important concepts in algorithm design. It plays a key role in various real-world application areas such as network routing, financial engineering, and optimization problems.
