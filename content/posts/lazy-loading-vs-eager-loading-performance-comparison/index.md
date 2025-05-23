---
title: "Lazy Loading VS Eager Loading"
date: 2024-06-08T01:45:34+09:00
tags: ["jpa", "java"]
draft: false
---

## Lazy Loading

### Lazy Loading이란

**Lazy Loading**은 지연 로딩이라고도 하며, 연관된 엔티티를 실제로 사용할 때 로딩하는 방식이다.

### 특징

-   연관된 데이터를 바로 가져오지 않고, 실제로 사용할 때 가져온다.
-   성능 최적화와 메로리 사용량을 줄이기 위해 사용된다.
-   연관된 엔티티가 많은 경우 초기 로딩 시간이 단축된다.

### 예시

```java
@OneToMany(fetch = FetchType.LAZY)
private List<Order> orders;
```

### 장점

-   초기 로딩 시간이 단축된다.
-   연관된 엔티티가 많은 경우 메모리 사용량을 줄일 수 있다.

### 단점

-   연관된 엔티티를 사용할 때마다 쿼리가 실행되어 성능 저하가 발생할 수 있다.

## Eager Loading

### Eager Loading이란

**Eager Loading**은 즉시 로딩이라고도 하며, 엔티티를 조회할 때 연관된 엔티티를 함께 로딩하는 방식이다.

### 특징

-   연관된 데이터를 한꺼번에 가져온다.
-   연관된 엔티티를 사용할 때 추가로 쿼리를 실행하지 않아도 된다.
-   N+1 문제가 발생하지 않는다.

### 예시

```java
@OneToMany(fetch = FetchType.EAGER)
private List<Order> orders;
```

### 장점

-   연관된 엔티티를 사용할 때 추가로 쿼리를 실행하지 않아도 된다.

### 단점

-   초기 로딩 시간이 길어질 수 있다.
-   연관된 엔티티가 많은 경우 메모리 사용량이 증가할 수 있다.

## 요약

-   **Lazy Loading**은 연관된 엔티티를 실제로 사용할 때 로딩하는 방식이다.
-   **Eager Loading**은 엔티티를 조회할 때 연관된 엔티티를 함께 로딩하는 방식이다.
-   **Lazy Loading**은 초기 로딩 시간이 단축되고 메모리 사용량을 줄일 수 있으며, **Eager Loading**은 연관된 엔티티를 사용할 때 추가로 쿼리를 실행하지 않아도 된다.
