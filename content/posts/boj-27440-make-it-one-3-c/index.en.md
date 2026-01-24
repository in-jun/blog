---
title: "Baekjoon 27440 Make it One 3 Solution"
date: 2024-05-29T19:58:08+09:00
tags: ["Algorithm", "Dynamic Programming"]
description: "Dynamic programming solution for Baekjoon problem 27440."
draft: false
---

Baekjoon 27440 "Make it One 3" is a problem that asks for the minimum number of operations needed to reduce a very large integer up to 10^18 to 1 using three operations (divide by 3, divide by 2, subtract 1). Since the input range reaches 10^18, the standard dynamic programming approach (O(N) time, O(N) space) is infeasible. The problem must be solved efficiently using a recursive recurrence relation and hash map-based memoization, achieving O(log² n) time complexity.

## Problem Description

> **Baekjoon 27440 - Make it One 3**
>
> Given an integer N, find the minimum number of operations needed to reduce it to 1 using three available operations.

### Available Operations

The following three operations can be applied to an integer X:

1. If X is divisible by 3, divide it by 3.
2. If X is divisible by 2, divide it by 2.
3. Subtract 1 from X.

### Input

The first line contains an integer N where 1 ≤ N ≤ 10^18.

### Output

Print the minimum number of operations required on the first line.

### Examples

| Input | Output | Explanation |
|-------|--------|-------------|
| 2 | 1 | 2 → 1 (divide by 2) |
| 10 | 4 | 10 → 9 → 3 → 1 (subtract → divide by 3 → divide by 3 → divide by 3) |

## Problem Analysis

### Limitations of Basic Dynamic Programming

The basic version of the "Make it One" problem (Baekjoon 1463) has N up to 10^6, which can be solved with O(N) dynamic programming that calculates the minimum operations for all values from 1 to N.

```cpp
// Basic DP: O(N) time, O(N) space
dp[1] = 0;
for (int i = 2; i <= n; i++) {
    dp[i] = dp[i - 1] + 1;
    if (i % 2 == 0) dp[i] = min(dp[i], dp[i / 2] + 1);
    if (i % 3 == 0) dp[i] = min(dp[i], dp[i / 3] + 1);
}
```

However, since N can be up to 10^18 in this problem, this approach is infeasible in both memory (approximately 8 exabytes required) and time (approximately 30,000 years needed).

### Key Observations

The key observations for solving this problem efficiently are as follows.

**Observation 1: Division by 2 or 3 is more efficient than subtraction**

To reduce n to 1, we ultimately need to reduce n to a sufficiently small number. Division reduces n to half or one-third in one step, while subtraction only reduces it by 1. Therefore, choosing division whenever possible is advantageous.

**Observation 2: Subtraction is used to enable division**

If n is not divisible by 2 or 3, we must subtract to make it divisible. This requires n % 2 or n % 3 subtraction operations.

**Observation 3: Compare the nearest multiples of 2 and 3 from n**

To reach n/2 from n, we subtract n % 2 times and divide by 2. To reach n/3, we subtract n % 3 times and divide by 3. We choose the path that requires fewer total operations to reach 1.

## Algorithm Design

### Deriving the Recurrence Relation

Based on the above observations, we can derive the following recurrence relation.

> **Core Recurrence Relation**
>
> f(n) = min(f(n/2) + n%2, f(n/3) + n%3) + 1
>
> The minimum number of operations to reduce n to 1 is the minimum of (1) the path through n/2 and (2) the path through n/3, plus 1.

The meaning of each term is as follows:

- `f(n/2) + n%2`: Subtraction operations needed to go from n to n/2 (n%2 times) + minimum operations from n/2 to 1 + one division by 2
- `f(n/3) + n%3`: Subtraction operations needed to go from n to n/3 (n%3 times) + minimum operations from n/3 to 1 + one division by 3
- `+ 1`: The final division operation

### Need for Memoization

Since this recurrence relation recursively calls n/2 and n/3, duplicate calculations can occur for the same value. For example, when calculating f(12), f(6) and f(4) are called. Then f(6) calls f(3) and f(2), while f(4) calls f(2) and f(1), resulting in duplicate calculation of f(2).

Using memoization with a hash map (C++ `std::map` or `std::unordered_map`) to store already computed values prevents duplicate calculations and greatly improves efficiency.

## Implementation

```cpp
#include <iostream>
#include <map>
using namespace std;

map<long long, long long> memo;

long long solve(long long n) {
    if (n == 1) return 0;
    if (memo.count(n)) return memo[n];

    long long via2 = solve(n / 2) + (n % 2) + 1;
    long long via3 = solve(n / 3) + (n % 3) + 1;

    return memo[n] = min(via2, via3);
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    long long n;
    cin >> n;
    cout << solve(n) << '\n';

    return 0;
}
```

### Code Explanation

- `memo`: A hash map that stores already computed results. The key is the integer n, and the value is the minimum number of operations to reduce n to 1.
- `solve(n)`: A recursive function that returns the minimum number of operations to reduce n to 1. It returns 0 if n is 1, returns the cached value if already computed, and otherwise applies the recurrence relation to calculate.
- `via2`: Total operations needed for the n/2 path (n%2 subtractions + reducing n/2 to 1 + division by 2)
- `via3`: Total operations needed for the n/3 path (n%3 subtractions + reducing n/3 to 1 + division by 3)

### Optimized Implementation

Using `std::unordered_map` can improve performance with average O(1) lookup/insertion time.

```cpp
#include <iostream>
#include <unordered_map>
using namespace std;

unordered_map<long long, long long> memo;

long long solve(long long n) {
    if (n == 1) return 0;

    auto it = memo.find(n);
    if (it != memo.end()) return it->second;

    return memo[n] = min(
        solve(n / 2) + (n % 2),
        solve(n / 3) + (n % 3)
    ) + 1;
}

int main() {
    ios_base::sync_with_stdio(false);
    cin.tie(nullptr);

    long long n;
    cin >> n;
    cout << solve(n) << '\n';

    return 0;
}
```

## Time Complexity Analysis

### Recursion Depth

Since n decreases by at least half in each recursive call (n/2 or n/3), the recursion depth is O(log n).

### Number of Unique States

Each recursive call generates two subproblems (n/2 and n/3). With depth O(log n), it might seem that up to 2^(log n) = n states are possible. However, far fewer unique states are actually generated because many paths converge to the same values. The actual number of unique states is approximately O(log² n).

### Overall Time Complexity

When using `std::map`, each lookup/insertion takes O(log(number of states)) = O(log log n) time, resulting in overall time complexity of O(log² n × log log n). Using `std::unordered_map` achieves average time complexity of O(log² n).

| Data Structure | Lookup/Insert | Overall Time Complexity |
|----------------|---------------|-------------------------|
| std::map | O(log log n) | O(log² n × log log n) |
| std::unordered_map | O(1) average | O(log² n) average |

### Space Complexity

Since the hash map size for memoization is proportional to the number of unique states, space complexity is O(log² n). When N = 10^18, log₂(10^18) ≈ 60, so we only need to store at most about 3600 states, resulting in very low memory usage.

## Algorithm Correctness

### Optimal Substructure

This problem has the optimal substructure property. The optimal solution for reducing n to 1 must include the optimal solution for reducing n/2, n/3 (when divisible), or n-1 to 1. Therefore, we can construct the overall optimal solution by combining optimal solutions of subproblems.

### Correctness of the Recurrence Relation

The recurrence relation `f(n) = min(f(n/2) + n%2, f(n/3) + n%3) + 1` is correct for the following reasons:

1. **n/2 path**: The nearest number divisible by 2 from n is n - (n%2). Dividing this by 2 gives n/2. Therefore, n%2 subtractions + 1 division = n%2 + 1 operations are needed.

2. **n/3 path**: Similarly, the nearest number divisible by 3 from n is n - (n%3). This requires n%3 subtractions + 1 division = n%3 + 1 operations.

3. Choosing the path that requires fewer operations yields the optimal solution.

## Related Problems and Extensions

### Make it One Series

Baekjoon has several versions of the "Make it One" problem, each requiring different approaches.

| Problem Number | N Range | Recommended Approach |
|----------------|---------|----------------------|
| 1463 | ≤ 10^6 | Standard DP |
| 12852 | ≤ 10^6 | DP + Path Tracking |
| 27440 | ≤ 10^18 | Recursion + Memoization |

### Variations

The idea of this algorithm can be applied to other similar problems:

- Different sets of operations (e.g., adding division by 5)
- Different costs for operations (e.g., division by 3 costs 2)
- Target value other than 1

## Conclusion

Baekjoon 27440 "Make it One 3" cannot be solved with standard O(N) dynamic programming because it must handle numbers up to 10^18. Instead, it requires a recursive recurrence relation and hash map-based memoization to solve in O(log² n) time. The key idea is to compare the two paths to n/2 and n/3, choosing the more efficient one, while memoization prevents duplicate calculations. This problem is an excellent example of extending the basic idea of dynamic programming to handle very large input ranges.
