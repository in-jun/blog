---
title: "플로이드-워셜(Floyd-Warshall) 알고리즘 알아보기"
date: 2024-06-17T19:29:50+09:00
tags: ["플로이드-워셜", "Floyd-Warshall", "알고리즘", "최단 경로"]
draft: false
---

## 플로이드-워셜 알고리즘

모든 정점에서 모든 정점까지의 최단 경로를 찾는 알고리즘이다. 플로이드-워셜 알고리즘은 음수 가중치가 있는 그래프에서도 사용할 수 있다.
음의 사이클이 있는 경우에도 사용할 수 있다. 다이나믹 프로그래밍을 이용하여 구현한다.

### 점화식

```
D_{ij} = \min(D_{ij}, D_{ik} + D_{kj})
```

### 순서

1. 2차원 배열을 초기화한다.

2. 3중 반복문을 사용하여 모든 정점을 탐색한다.

3. 점화식을 사용하여 최단 경로를 갱신한다.

### 예제 코드

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

### 장점

-   모든 정점에서 모든 정점까지의 최단 경로를 구할 수 있다.
-   음수 가중치가 있는 그래프에서도 사용할 수 있다.

### 단점

-   한 정점에서 다른 정점으로 가는 최단 경로를 구할 때는 다익스트라 알고리즘이 더 빠르다.
-   음수 사이클이 있는 경우에는 최단 경로를 구할 수 없다.

### 시간 복잡도

-   플로이드-워셜 알고리즘의 시간 복잡도는 `O(n^3)`이다. 이때 n은 정점의 개수이다.
