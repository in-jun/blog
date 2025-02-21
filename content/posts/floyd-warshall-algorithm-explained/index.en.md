---
title: "Understanding the Floyd-Warshall Algorithm"
date: 2024-06-17T19:29:50+09:00
tags: ["Floyd-Warshall", "shortest path", "algorithm"]
draft: false
---

## Floyd-Warshall Algorithm

The Floyd-Warshall algorithm is an algorithm that finds the shortest paths between all pairs of vertices in a graph. It can be used on graphs with negative weights.
It can also be used on graphs with negative cycles. It is implemented using dynamic programming.

### Recurrence Relation

```
D_{ij} = min(D_{ij}, D_{ik} + D_{kj})
```

### Procedure

1. Initialize a 2D array.
2. Iterate through all the vertices using three nested loops.
3. Update the shortest paths using the recurrence relation.

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
        cout << '
';
    }

    return 0;
}
```

### Advantages

- It can be used to find the shortest paths between all pairs of vertices.
- It can be used on graphs with negative weights.

### Disadvantages

- It is slower than Dijkstra's algorithm for finding the shortest path from one vertex to another.
- It cannot find the shortest paths if the graph contains a negative cycle.

### Time Complexity

- The Floyd-Warshall algorithm has a time complexity of `O(n^3)` where n is the number of vertices.
