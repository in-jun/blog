---
title: "벨만-포드(Bellman-Ford) 알고리즘 알아보기"
date: 2024-06-17T18:40:50+09:00
tage: ["벨만-포드", "Bellman-Ford", "알고리즘", "최단 경로"]
draft: false
---

## 벨만-포드 알고리즘

최단 경로를 찾는 알고리즘 중 하나이다. 벨만-포드 알고리즘은 시작 정점에서 다른 모든 정점까지의 최단 경로를 찾는 알고리즘이다. 다익스트라 알고리즘과 유사하지만, 음수 가중치가 있는 그래프에서도 사용할 수 있다.

### 순서

1. 시작 정점에서 각 정점까지의 거리를 저장하는 배열을 초기화한다.

2. 시작 정점을 방문 처리한다.

3. 시작 정점에서 다른 정점까지의 거리를 갱신한다.

4. 위 과정을 정점의 개수 - 1번 반복한다.

5. 음수 사이클이 있는지 확인한다.

### 예제 코드

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
                cout << "음수 사이클이 존재합니다.\n";
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

### 장점

벨만-포드 알고리즘은 음수 가중치가 있는 그래프에서도 사용할 수 있다.

### 단점

음수 사이클이 있는 경우, 최단 경로를 찾을 수 없다.
속도가 다익스트라 알고리즘보다 느리다.

### 시간 복잡도

벨만-포드 알고리즘의 시간 복잡도는 O(VE)이다. 여기서 V는 정점의 개수, E는 간선의 개수이다.
