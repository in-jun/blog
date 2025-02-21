---
title: "Exploring Bellman-Ford Algorithm"
date: 2024-06-17T18:40:50+09:00
tage: ["Bellman-Ford", "Bellman-Ford", "Algorithm", "Shortest Path"]
draft: false
---

## Bellman-Ford Algorithm

It is one of the algorithms that find the shortest path. Bellman-Ford algorithm is an algorithm to find the shortest path from the start vertex to all other vertices. It is similar to Dijkstra's algorithm but can be used even on graphs with negative weights.

### Order

1. Initialize an array to store the distances from the start vertex to each vertex.

2. Visit the start vertex.

3. Update the distances from the start vertex to other vertices.

4. Repeat the above process for the number of vertices - 1 times.

5. Check if there is a negative cycle.

### Sample Code

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
                cout << "There is a negative cycle.
";
                return 0;
            }
        }
    }

    for (int i = 1; i <= n; i++)
    {
        if (dist[i] == INF)
        {
            cout << "INF
";
        }
        else
        {
            cout << dist[i] << '
';
        }
    }

    return 0;
}
```

### Advantages

Bellman-Ford algorithm can be used even in graphs with negative weights.

### Disadvantages

When there is a negative cycle, the shortest path cannot be found.
It is slower than Dijkstra's algorithm.

### Time Complexity

The time complexity of the Bellman-Ford algorithm is O(VE). Here, V is the number of vertices and E is the number of edges.
