---
title: "Dijkstra's Algorithm Explained"
date: 2024-06-17T16:52:43+09:00
tags: ["Dijkstra", "Dijkstra's", "Algorithm", "Shortest Path"]
description: "Dijkstra's algorithm, invented by Dutch computer scientist Edsger W. Dijkstra in 1956, is a fundamental algorithm for finding the shortest paths from a starting vertex to all other vertices in a graph. It uses a greedy algorithm approach and achieves O(E log V) time complexity through a priority queue implementation with a Min Heap structure. While it cannot handle negative edge weights and requires the Bellman-Ford algorithm for such cases, it is widely applied in real-world scenarios including network routing protocols (OSPF), GPS navigation systems, social network path finding, and game AI pathfinding."
draft: false
---

## Dijkstra's Algorithm

Dijkstra's algorithm is one of the most important algorithms for finding the shortest paths in a graph. It finds the shortest path from a starting vertex to all other vertices in a weighted graph. The algorithm is similar to breadth-first search (BFS) as it explores the graph while keeping track of the shortest known distance to each vertex.

## History of Dijkstra's Algorithm

Edsger W. Dijkstra, a Dutch computer scientist, invented Dijkstra's algorithm in 1956. It is one of the most famous and widely used algorithms in graph theory. Dijkstra reportedly designed the algorithm entirely in his head without using pen and paper. The algorithm plays a crucial role in numerous real-world applications. These include network routing, GPS navigation, and social network analysis. The OSPF (Open Shortest Path First) routing protocol, a cornerstone of modern internet routing, is based on Dijkstra's algorithm. The shortest path finding features in map applications we use daily also utilize variations of this algorithm.

## How the Algorithm Works

Dijkstra's algorithm uses a greedy algorithm approach. At each step, it selects the vertex with the shortest distance from the starting vertex among the currently discovered vertices. It then updates the paths to other vertices through this selected vertex. The key principle is that once a vertex's shortest distance is determined, it never changes. This property is mathematically proven under the assumption that all edge weights are non-negative. The algorithm progressively expands from the starting vertex, confirming the shortest path to each vertex. This method efficiently finds the shortest paths to all vertices.

### Steps

1. Initialize an array to store the distance from the source vertex to each vertex.

2. Mark the source vertex as visited.

3. Add the source vertex to a queue.

4. Repeat the following until the queue is empty:

    1. Remove a vertex from the queue.

    2. Explore the neighbors of the vertex.

    3. If the distance from the source vertex to the neighbor is greater than the distance from the source vertex to the current vertex plus the distance from the current vertex to the neighbor, then update the distance from the source vertex to the neighbor.

    4. Mark the neighbor as visited and add it to the queue.

When updating the distance from the source vertex to a neighbor, use a priority queue to explore the vertex with the smallest distance first.

## Role of the Priority Queue

The priority queue plays a crucial role in Dijkstra's algorithm. The reason for using a priority queue instead of a regular queue is directly related to the algorithm's efficiency. If a regular queue is used, finding the vertex with the shortest distance requires iterating through all vertices, which takes O(V) time. However, with a priority queue using a Min Heap structure, the minimum value can be extracted in O(log V) time.

### Min Heap Structure

A priority queue is internally implemented as a Min Heap data structure. This is a complete binary tree where the parent node always has a smaller value than its child nodes. This structure allows both insertion (push) and minimum value extraction (pop) operations to be performed in O(log V) time complexity. Since the smallest value is always at the root of the heap, checking the minimum value is possible in O(1) time.

### Comparison with and without Priority Queue

Without a priority queue, each step requires a linear search through all unvisited vertices to find the one with the minimum distance, resulting in an overall time complexity of O(V^2). In contrast, using a priority queue requires extracting each vertex from the queue once (O(V log V)) and updating distances for each edge once (O(E log V)). This improves the overall time complexity to O((V + E) log V). In typical graphs where the number of edges is sufficiently larger than the number of vertices, this can be expressed as O(E log V).

### Example Code

> Using a priority queue allows us to quickly find the vertex with the smallest distance from the source vertex when updating the distance from the source vertex to a neighbor.

```cpp
#include <iostream>
#include <limits.h>
#include <vector>
#include <queue>
using std::cin;
using std::cout;
using std::greater;
using std::pair;
using std::priority_queue;
using std::vector;

#define INF 1000000000

int main()
{
    int n, m;
    cin >> n >> m;

    vector<vector<pair<int, int>>> graph(n + 1);
    vector<int> dist(n + 1, INF);
    priority_queue<pair<int, int>, vector<pair<int, int>>, greater<pair<int, int>>> pq;

    for (int i = 0; i < m; i++)
    {
        int a, b, c;
        cin >> a >> b >> c;
        graph[a].push_back({b, c});
    }

    int start, end;
    cin >> start >> end;

    dist[start] = 0;
    pq.push({0, start});

    while (!pq.empty())
    {
        int cost = pq.top().first;
        int cur = pq.top().second;
        pq.pop();

        if (dist[cur] < cost)
        {
            continue;
        }

        for(vector<pair<int,int>> next : graph[cur])
        {
            int nextNode = next.first;
            int nextCost = next.second;

            if (dist[nextNode] > cost + nextCost)
            {
                dist[nextNode] = cost + nextCost;
                pq.push({dist[nextNode], nextNode});
            }
        }
    }

    cout << dist[end] << '
';

    return 0;
}
```

## Time Complexity Analysis

The time complexity of Dijkstra's algorithm varies depending on the implementation method. The optimal implementation approach differs based on the characteristics of the graph.

### With Priority Queue: O((V + E) log V) or O(E log V)

In the priority queue implementation, each vertex is extracted from the queue at most once, taking O(V log V) time. Each edge undergoes distance update and queue insertion operations at most once, taking O(E log V) time. Therefore, the overall time complexity is O((V + E) log V). In a connected graph, since E ≥ V - 1, this is generally expressed as O(E log V). Here, V represents the number of vertices and E represents the number of edges.

### Without Priority Queue: O(V^2)

When implementing with arrays instead of a priority queue, finding the vertex with minimum distance at each step takes O(V) time. For V vertices, this results in a total time complexity of O(V^2). This approach is simpler to implement but is generally slower than using a priority queue. However, it can be efficient for very dense graphs.

### Performance in Dense vs Sparse Graphs

A dense graph has approximately E ≈ V^2 edges. In this case, the priority queue version has a time complexity of O(V^2 log V), which can be slower than the array version's O(V^2). In contrast, a sparse graph has approximately E ≈ V edges. For sparse graphs, the priority queue version achieves O(V log V), which is much faster than the array version's O(V^2). Since sparse graphs are more common in real-world applications, the priority queue implementation is generally preferred.

## Negative Weight Problem

Dijkstra's algorithm has an important constraint: all edge weights must be non-negative. It cannot guarantee correct results for graphs with negative weights.

### Why It Fails with Negative Weights

The core principle of Dijkstra's algorithm is that once a vertex's shortest distance is determined, it never changes. When negative weights exist, a path through a vertex that was already finalized might later be discovered to be shorter, breaking this assumption. For example, if the distance from vertex A to B is finalized as 5, a later discovered path through C might be shorter: A→C (distance 10) + C→B (distance -8) = 2. Since the algorithm already finalized B, it won't consider this path, producing an incorrect result.

### Counterexample

Consider a simple graph. Suppose we want to find the shortest path from vertex 1 to vertex 3. The edges are: 1→2 (weight 5), 1→3 (weight 2), and 2→3 (weight -4). Dijkstra's algorithm first finalizes vertex 3 with distance 2, then finalizes vertex 2 with distance 5. However, the actual shortest path is 1→2→3 with distance 1. The algorithm misses this path because it finalized vertex 3 too early.

### Handling Negative Weights

For graphs with negative weights, the Bellman-Ford algorithm must be used. This algorithm has a time complexity of O(VE), which is slower than Dijkstra's. However, it correctly handles negative weights and can detect the presence of negative cycles. The Bellman-Ford algorithm should only be used when there are no negative cycles. If a negative cycle exists, the shortest path is undefined.

## Real-World Applications

Dijkstra's algorithm has not only theoretical value but is also widely used in the real world. It is a core technology in many services we use daily.

### Network Routing Protocol (OSPF)

OSPF (Open Shortest Path First), one of the internet's routing protocols, uses Dijkstra's algorithm to calculate the optimal path for data packet transmission across a network. Each router calculates the shortest paths from itself to all other routers based on network topology information. Link costs (bandwidth, delay time, etc.) are used as weights to select the most efficient path.

### GPS Navigation Systems

Automotive navigation systems use Dijkstra's algorithm or its variants (such as the A* algorithm) to calculate the shortest path from origin to destination. The road network is modeled as a graph, with intersections as vertices and roads as edges. Edge weights are set considering various factors such as distance, estimated travel time, and tolls. The system can dynamically recalculate routes by reflecting real-time traffic information.

### Social Network Path Finding

Features in social networking services that verify the "six degrees of separation" theory or find connection paths between two users utilize Dijkstra's algorithm. Users are modeled as vertices and friendship relationships as edges. If all edge weights are set equally, the shortest path represents the minimum number of connection steps. LinkedIn's "How you're connected" feature and Facebook's friend recommendation system use this principle.

### Game AI Pathfinding

When NPCs (Non-Player Characters) or enemy characters in games track players or move to target locations, they primarily use the A* algorithm, a variant of Dijkstra's algorithm. The map is represented as a grid or graph, with each cell or node as a vertex and possible movement paths as edges. The A* algorithm improves performance by adding a heuristic function to Dijkstra's, prioritizing exploration toward the goal. It is an essential technology in real-time strategy (RTS) games and role-playing games (RPGs).

## Comparison with Other Algorithms

Besides Dijkstra's, several other algorithms solve the shortest path problem. Each has different characteristics and applicable situations.

### Bellman-Ford Algorithm

The Bellman-Ford algorithm allows negative weights and has a time complexity of O(VE). It has the advantage of being able to detect negative cycles. It is slower than Dijkstra's algorithm but more versatile. It performs V-1 relaxation operations on all edges to find shortest paths. It is suitable for problems where negative weights naturally occur, such as currency arbitrage or network flow problems.

### Floyd-Warshall Algorithm

The Floyd-Warshall algorithm calculates shortest paths between all vertex pairs at once. It has a time complexity of O(V^3). It uses dynamic programming, making implementation simple. It is used when shortest paths between all pairs are needed, not just from a single source. It is efficient for small graphs or when all path information is needed. It can also handle negative weights but cannot handle negative cycles.

### A* Algorithm

The A* algorithm is a variant of Dijkstra's algorithm that adds a heuristic function. It considers the estimated distance to the goal, making the search more goal-oriented. With an appropriate heuristic, it can find the shortest path much faster than Dijkstra's. If the heuristic doesn't overestimate the actual distance (is admissible), it guarantees an optimal solution. It is the most widely used pathfinding algorithm in game development, robotics, and navigation systems.

### Advantages

- Dijkstra's algorithm can find the shortest path from a source vertex to all other vertices in a graph.
- Using a priority queue achieves efficient time complexity of O(E log V).
- It always guarantees an optimal solution for graphs without negative weights.

### Disadvantages

- Dijkstra's algorithm cannot be used on graphs with negative weights.
- It only works from a single source, so finding all-pairs shortest paths requires running it V times.
- Priority queue implementation requires additional memory.
