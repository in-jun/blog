---
title: "다익스트라(Dijkstra) 알고리즘 알아보기"
date: 2024-06-17T16:52:43+09:00
tage: ["다익스트라", "Dijkstra", "알고리즘", "최단 경로"]
draft: false
---

## 다익스트라 알고리즘

최단 경로를 찾는 알고리즘 중 하나이다. 다익스트라 알고리즘은 시작 정점에서 다른 모든 정점까지의 최단 경로를 찾는 알고리즘이다. 너비 우선 탐색(BFS)와 유사하다. 각 정점까지의 최단 거리를 저장하면서 탐색한다.

### 순서

1. 시작 정점에서 각 정점까지의 거리를 저장하는 배열을 초기화한다.

2. 시작 정점을 방문 처리한다.

3. 큐에 시작 정점을 넣는다.

4. 큐가 빌 때까지 다음을 반복한다.

    1. 큐에서 정점을 꺼낸다.

    2. 해당 정점과 연결된 정점들을 탐색한다.

    3. 시작 정점에서 해당 정점까지의 거리가 시작 정점에서 현재 정점까지의 거리 + 현재 정점에서 해당 정점까지의 거리보다 크다면, 시작 정점에서 해당 정점까지의 거리를 갱신한다.

    4. 해당 정점을 방문 처리하고 큐에 넣는다.

    이때 시작 정점에서 해당 정점까지의 거리를 갱신할 때, 우선순위 큐를 사용하여 거리가 가장 짧은 정점을 먼저 탐색하도록 한다.

### 예제 코드

> 우선순위 큐를 사용하는 이유는 시작 정점에서 해당 정점까지의 거리를 갱신할 때, 거리가 가장 짧은 정점을 빠르게 구하기 위함이다.

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

    cout << dist[end] << '\n';

    return 0;
}
```

### 장점

-   다익스트라 알고리즘은 시작 정점에서 다른 모든 정점까지의 최단 경로를 찾을 수 있다.

### 단점

-   다익스트라 알고리즘은 음의 가중치가 있는 그래프에서 사용할 수 없다.

### 시간 복잡도

-   다익스트라 알고리즘의 시간 복잡도는 O(n log n)이다. 여기서 n은 정점의 개수이다.
-   우선순위 큐를 사용하지 않는 경우 시간 복잡도는 O(n^2)이다.
