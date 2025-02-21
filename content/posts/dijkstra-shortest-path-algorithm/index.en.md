---
title: "Dijkstra's Algorithm Explained"
date: 2024-06-17T16:52:43+09:00
tage: ["Dijkstra", "Dijkstra's", "Algorithm", "Shortest Path"]
draft: false
---

## Dijkstra's Algorithm

Dijkstra's algorithm is an algorithm for finding the shortest path from a single source vertex to all other vertices in a weighted graph. It is similar to breadth-first search (BFS) in that it explores the graph by keeping track of the shortest known distance to each vertex.

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

### Advantages

- Dijkstra's algorithm can find the shortest path from a source vertex to all other vertices in a graph.

### Disadvantages

- Dijkstra's algorithm cannot be used on graphs with negative weights.

### Time Complexity

- The time complexity of Dijkstra's algorithm is O(n log n), where n is the number of vertices.
- Without using a priority queue, the time complexity is O(n^2).
