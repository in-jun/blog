---
title: "Lazy Loading VS Eager Loading"
date: 2024-06-08T01:45:34+09:00
tags: ["jpa", "java"]
draft: false
---

## Lazy Loading

### What is Lazy Loading

**Lazy Loading** loads the associated entity when you actually use it, also called a delayed loading.

### Features

- It fetches associated data when it is actually being used, not immediately.
- It is used to optimize performance and to reduce memory usage.
- It reduces the initial loading time when there are many associated entities.

### Example

```java
@OneToMany(fetch = FetchType.LAZY)
private List<Order> orders;
```

### Advantages

- Reduces initial loading time.
- Can reduce memory usage when there are many associated entities.

### Disadvantages

- May cause performance degradation as it fires queries every time a part of the associated entity is used.

## Eager Loading

### What is Eager Loading

**Eager Loading** is a way to load the associated entity together when the entity is fetched, it is also called an immediate loading.

### Features

- It fetches associated data all at once when the entity is fetched.
- There is no need to execute additional queries when using the associated entities.
- It does not cause the N+1 problem.

### Example

```java
@OneToMany(fetch = FetchType.EAGER)
private List<Order> orders;
```

### Advantages

- No need to execute additional queries when using the associated entities.

### Disadvantages

- May increase the initial loading time.
- Can increase memory usage when there are many associated entities.

## Summary

- **Lazy Loading** is a way of loading associated entities when they are actually used.
- **Eager Loading** is a way of loading associated entities together when the entity is fetched.
- **Lazy Loading** can reduce the initial loading time and memory usage, while **Eager Loading** eliminates the need for additional queries when using associated entities.
