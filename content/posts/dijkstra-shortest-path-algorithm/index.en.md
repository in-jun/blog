---
title: "Dijkstra's Shortest Path Algorithm"
date: 2024-06-17T16:52:43+09:00
tags: ["Algorithm", "Graph", "Shortest Path"]
description: "Shortest path algorithm using priority queues and greedy approach."
draft: false
---

Dijkstra's algorithm is the quintessential algorithm for finding the shortest paths from a starting vertex to all other vertices in a weighted graph, invented by Dutch computer scientist Edsger Wybe Dijkstra in 1956 and still serving as a core component in numerous fields including network routing, GPS navigation, and game AI. The algorithm uses a greedy algorithm approach to make optimal choices at each step, and achieves an efficient time complexity of O(E log V) through priority queue implementation, making it practical for large-scale graphs.

## History of Dijkstra's Algorithm

> **What is Dijkstra's Algorithm?**
>
> An algorithm that finds the shortest paths from a single starting vertex to all other vertices in a weighted graph, with the constraint that all edge weights must be non-negative.

Dijkstra's algorithm was born in Amsterdam, Netherlands in 1956, when 26-year-old Edsger W. Dijkstra reportedly conceived the algorithm in approximately 20 minutes while taking a break at an Amsterdam cafe with his fiancée. At the time, Dijkstra was working as a programmer for the ARMAC, an early computer at the Mathematical Centre (Mathematisch Centrum), and while searching for a problem that non-expert audiences could understand for a demonstration of the new computer, he chose the problem of finding the shortest route between two cities.

Interestingly, Dijkstra later revealed in an interview that he designed this algorithm entirely in his head without using pen and paper, explaining that "one of the advantages of not using pen and paper is that you are almost forced to avoid unnecessary complexity." The algorithm was published in 1959 in the journal Numerische Mathematik under the title "A Note on Two Problems in Connexion with Graphs," and although this paper was only 3 pages long, it is regarded as one of the most influential papers in computer science history.

Dijkstra went on to make pioneering contributions in various areas of computer science including structured programming, the THE operating system, and the semaphore concept. He received the Turing Award in 1972 for "fundamental contributions to programming languages" and continued to make tremendous contributions to the advancement of computer science until his passing in 2002.

## How the Algorithm Works

Dijkstra's algorithm uses a greedy algorithm approach, repeatedly selecting the vertex with the shortest distance from the starting vertex among currently discovered vertices and updating the paths to other vertices through this selected vertex.

### Core Principle: Optimal Substructure

The correctness of Dijkstra's algorithm is based on the optimal substructure property of the shortest path problem, which states that "if the shortest path from A to C passes through B, then the sub-path from A to B must also be the shortest path from A to B." Additionally, under the premise that all edge weights are non-negative, it is mathematically proven that once a vertex's shortest distance is finalized, it never changes. This property justifies the algorithm's greedy approach.

### Algorithm Execution Steps

**Step 1: Initialization**

Create an array to store the distance from the starting vertex to each vertex and initialize all values to infinity (INF), set only the starting vertex's distance to 0, and insert the starting vertex into the priority queue as a (distance 0, starting vertex) pair.

**Step 2: Select Minimum Distance Vertex**

Extract the vertex with the shortest distance from the priority queue. If this vertex has already been processed (the distance extracted from the queue is greater than the currently recorded distance), ignore it and select the next vertex.

**Step 3: Update Adjacent Vertex Distances (Relaxation)**

For all adjacent vertices connected to the selected vertex, calculate the distance of the "starting vertex → current vertex → adjacent vertex" path. If this value is smaller than the previously recorded distance to the adjacent vertex, update the distance and insert that vertex into the priority queue.

**Step 4: Repeat**

Repeat Steps 2 and 3 until the priority queue is empty. When all vertices have been processed, the shortest distance from the starting vertex to each vertex is stored in the array.

### Working Example

Assume we have the following graph. Starting from vertex 1, we find the shortest distance to all vertices.

```
Vertices: 1, 2, 3, 4
Edges: 1→2 (weight 4), 1→3 (weight 1), 2→3 (weight 2), 2→4 (weight 5), 3→4 (weight 8)
```

1. Initialization: dist = [0, INF, INF, INF], queue = [(0, 1)]
2. Select vertex 1: Update dist[2] = 4, dist[3] = 1, queue = [(1, 3), (4, 2)]
3. Select vertex 3 (distance 1): Update dist[4] = 1+8=9, queue = [(4, 2), (9, 4)]
4. Select vertex 2 (distance 4): dist[4] = min(9, 4+5=9) = 9 (no change)
5. Select vertex 4 (distance 9): No adjacent vertices
6. Result: dist = [0, 4, 1, 9]

## Priority Queue and Time Complexity

The efficiency of Dijkstra's algorithm largely depends on whether a priority queue is used. Using a priority queue allows finding the minimum distance vertex in O(log V) each time, greatly improving the overall time complexity.

### Min Heap-Based Priority Queue

A priority queue is internally implemented as a Min Heap data structure, which is a complete binary tree where parent nodes always have smaller values than their child nodes. Since the smallest value is always at the root of the heap, checking the minimum value is possible in O(1), while insertion (push) and minimum value extraction (pop) operations are performed in O(log V), which is the height of the tree.

### Time Complexity Analysis

**With Priority Queue: O((V + E) log V) or O(E log V)**

Each vertex is extracted from the priority queue at most once, taking O(V log V) time. Distance update and queue insertion operations are performed at most once for each edge, taking O(E log V) time. Therefore, the overall time complexity is O((V + E) log V). In connected graphs where E ≥ V - 1, this is generally expressed as O(E log V).

**Without Priority Queue: O(V²)**

When implementing with arrays, a linear search taking O(V) time is required at each step to find the minimum distance vertex, resulting in a total time complexity of O(V²) for V vertices. While this has the advantage of simpler implementation, it is slower than the priority queue version in most cases.

**Sparse Graphs vs Dense Graphs**

In sparse graphs (E ≈ V), the priority queue version achieves O(V log V), which is much faster than the array version's O(V²). In dense graphs (E ≈ V²), the priority queue version becomes O(V² log V), which can be slower than the array version's O(V²). Since sparse graphs are more common in real-world applications, the priority queue implementation is generally preferred.

## Implementation Example

Here is a C++ implementation of Dijkstra's algorithm using a priority queue.

```cpp
#include <iostream>
#include <vector>
#include <queue>
using namespace std;

#define INF 1e9

int main() {
    int n, m; // n: number of vertices, m: number of edges
    cin >> n >> m;

    vector<vector<pair<int, int>>> graph(n + 1); // adjacency list
    vector<int> dist(n + 1, INF); // shortest distance array

    // Graph input
    for (int i = 0; i < m; i++) {
        int a, b, c; // edge from a to b with weight c
        cin >> a >> b >> c;
        graph[a].push_back({b, c});
    }

    int start, end;
    cin >> start >> end;

    // Priority queue: (distance, vertex) - min heap based on distance
    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;

    dist[start] = 0;
    pq.push({0, start});

    while (!pq.empty()) {
        int cost = pq.top().first;
        int cur = pq.top().second;
        pq.pop();

        // Skip if already processed
        if (dist[cur] < cost) continue;

        // Explore adjacent vertices and update distances
        for (auto& edge : graph[cur]) {
            int next = edge.first;
            int nextCost = edge.second;

            if (dist[next] > cost + nextCost) {
                dist[next] = cost + nextCost;
                pq.push({dist[next], next});
            }
        }
    }

    if (dist[end] == INF) {
        cout << "No path" << '\n';
    } else {
        cout << dist[end] << '\n';
    }

    return 0;
}
```

### Code Explanation

- `graph`: Stores the graph in adjacency list format, where `graph[a]` stores (destination vertex, weight) pairs for edges starting from vertex a.
- `dist`: An array storing the shortest distance from the starting vertex to each vertex, initialized to infinity.
- `pq`: A priority queue implemented as a min heap that stores (distance, vertex) pairs with smaller distances extracted first.
- `if (dist[cur] < cost) continue`: An optimization condition that skips vertices already processed via a shorter path.

## The Negative Weight Problem

Dijkstra's algorithm has an important constraint that all edge weights must be non-negative, and it cannot guarantee correct results for graphs with negative weights.

### Why It Fails with Negative Weights

The core assumption of Dijkstra's algorithm is that "once a vertex's shortest distance is finalized, it never changes." When negative weights exist, a path through an already finalized vertex might later be discovered to be shorter, breaking this assumption.

**Counterexample**

```
Vertices: 1, 2, 3
Edges: 1→2 (weight 5), 1→3 (weight 2), 2→3 (weight -4)
Start vertex: 1, Target vertex: 3
```

Dijkstra's algorithm execution:
1. Start from vertex 1, dist = [0, INF, INF]
2. Finalize vertex 3 with distance 2 (1→3 path)
3. Finalize vertex 2 with distance 5 (1→2 path)
4. Result: shortest distance to vertex 3 = 2

Actual shortest path:
- 1→2→3 path: 5 + (-4) = 1
- Correct answer: 1

Dijkstra's algorithm produces an incorrect result because it finalized vertex 3 too early and failed to consider the 1→2→3 path.

### Handling Negative Weights

For graphs with negative weights, the Bellman-Ford algorithm must be used. This algorithm has a time complexity of O(VE), which is slower than Dijkstra's, but it correctly handles negative weights and can also detect the presence of negative cycles.

## Real-World Applications

Dijkstra's algorithm has not only theoretical value but is also widely used in the real world. It is a core technology behind many services we use daily.

### Network Routing Protocol (OSPF)

OSPF (Open Shortest Path First), one of the internet's representative internal routing protocols, uses Dijkstra's algorithm to calculate the optimal path for data packet transmission across a network. First standardized as RFC 1131 in 1989, it has been a core component in large enterprise networks and Internet Service Provider (ISP) networks ever since. Each router collects network topology information through Link State Advertisements (LSAs) and runs Dijkstra's algorithm to calculate the shortest paths from itself to all other routers.

### GPS Navigation Systems

Automotive navigation and map applications like Google Maps and Kakao Maps use Dijkstra's algorithm or its variants (such as the A* algorithm) to calculate the shortest path from origin to destination, modeling the road network as a graph with intersections as vertices and roads as edges. Edge weights are set considering not just simple distance but various factors including estimated travel time, tolls, and road classifications. The feature that dynamically recalculates routes reflecting real-time traffic information is also based on this algorithm.

### Game AI Pathfinding

When NPCs (Non-Player Characters) or enemy characters in games track players or move to target locations, they primarily use the A* algorithm, a variant of Dijkstra's. A* guides the search direction toward the goal by additionally considering the estimated distance to the target (heuristic), allowing it to find paths faster than Dijkstra's. Optimized versions of this algorithm are used even in real-time strategy (RTS) games like StarCraft and Age of Empires when hundreds of units move simultaneously.

### Social Network Analysis

LinkedIn's "How you're connected" feature and Facebook's friend recommendation system use Dijkstra's algorithm to find the shortest connection path between two users. By modeling users as vertices and friendship relationships as edges, with all edge weights set to 1, the shortest path represents the minimum number of connection steps.

## Comparison with Other Shortest Path Algorithms

Besides Dijkstra's, several other algorithms solve the shortest path problem, each with different characteristics and applicable situations.

| Algorithm | Time Complexity | Negative Weights | Negative Cycle Detection | Characteristics |
|-----------|-----------------|------------------|--------------------------|-----------------|
| Dijkstra | O(E log V) | Not supported | Not supported | Single source, fastest |
| Bellman-Ford | O(VE) | Supported | Supported | Single source, handles negative weights |
| Floyd-Warshall | O(V³) | Supported | Detection only | All-pairs shortest paths |
| A* | O(E log V)* | Not supported | Not supported | Goal-oriented search, requires heuristic |

*The time complexity of A* varies depending on heuristic quality and can be much faster than Dijkstra's with an ideal heuristic.

### Algorithm Selection Guide

- **Non-negative weights, single source**: Dijkstra's algorithm
- **Negative weights present, single source**: Bellman-Ford algorithm
- **All-pairs shortest paths needed**: Floyd-Warshall algorithm
- **Clear target location with usable heuristic**: A* algorithm

## Conclusion

Dijkstra's algorithm was conceived by Edsger W. Dijkstra in just 20 minutes at an Amsterdam cafe in 1956. It efficiently finds the shortest paths from a starting vertex to all other vertices in a weighted graph using a greedy algorithm approach. Using a priority queue (Min Heap) achieves a time complexity of O(E log V), making it particularly efficient for sparse graphs. While it has the constraint that all edge weights must be non-negative, requiring the Bellman-Ford algorithm for negative weights, most real-world applications involve only non-negative weights, making Dijkstra's algorithm well-suited. It is used as a core component in numerous fields of modern computing including the OSPF routing protocol, GPS navigation, game AI pathfinding, and social network analysis, and is regarded as one of the most influential algorithms in computer science history.
