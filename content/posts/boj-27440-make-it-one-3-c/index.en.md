---
title: "Baekjoon 27440: Make it One 3 (C++)"
date: 2024-05-29T19:58:08+09:00
tags: ["Baekjoon", "Algorithm"]
draft: false
---

This is a solution to Baekjoon 27440: Make it One 3 problem in C++.

## Problem Statement

There are three operations that can be applied to an integer X:

1. If X is divisible by 3, divide it by 3.
2. If X is even, divide it by 2.
3. Subtract 1 from X.

Given an integer N, you want to make it 1 using the three operations above. Find the minimum number of operations required.

## Input

The first line contains an integer N, which is greater than or equal to 1 and less than or equal to 10^18.

## Output

Print the minimum number of operations required on the first line.

## Code

```cpp
#include <iostream>
#include <map>
using std::cin;
using std::cout;
using std::map;
using std::min;

map<int, int> mem;

int min_ops(unsigned long long n)
{
    if (mem.find(n) != mem.end())
    {
        return mem[n];
    }

    mem[n] = min(min_ops(n / 2) + (n % 2), min_ops(n / 3) + (n % 3)) + 1;

    return mem[n];
}

int main()
{
    unsigned long long n;
    cin >> n;

    mem[1] = 0; // base case
    mem[2] = 1;

    cout << min_ops(n);
    return 0;
}
```

## Explanation

This problem is challenging to solve with a naive approach because the input range is too large. Checking all cases from 1 to n would have a time complexity of O(N), which would take 10^18 operations for an input of 10^18. This is highly inefficient. Therefore, we need to solve the problem using a recurrence relation.

```cpp
min_ops(n) = min(min_ops(n / 2) + (n % 2), min_ops(n / 3) + (n % 3)) + 1
```

min_ops is a function that returns the minimum number of operations to make the given integer N equal to 1. The number of operations to get to n / 2 is min_ops(n / 2), and the remainder when n is divided by 2 is n % 2. Adding the remainder and subtracting 1 gives us the number of operations to get to n / 2 + (n % 2) - 1. We can do the same for n / 3. Finally, we add 1 to account for the operation we used to get to min_ops(n).

Using the recurrence relation above, we can solve the problem to find the minimum number of operations required to make the given integer N equal to 1. We use memoization to avoid redundant operations.

## Time Complexity

Since we divide n by either 2 or 3 at each recursive call, the number of operations is O(log n).
