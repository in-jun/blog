---
title: "N+1 문제 알아보기"
date: 2024-06-08T02:17:46+09:00
tags: ["ORM", "java"]
draft: false
---

### N+1 문제란

**N+1 문제**는 ORM(Object-Relational Mapping)에서 자주 발생하는 성능 문제 중 하나로, 연관된 엔티티를 조회할 때, 연관된 엔티티의 수(N)만큼 추가로 쿼리가 실행되는 문제이다. 그 결과, 쿼리의 수가 N+1개가 된다. 쿼리의 수가 많아지면 데이터베이스와의 통신이 늘어나고, 성능이 저하될 수 있다.

그렇기 때문에 **N+1 문제**는 성능 최적화를 위해 주의해야 하는 문제이다.

### 동작 원리

1. 첫 번째 쿼리로 엔티티를 조회한다.

```java
List<Member> members = memberRepository.findAll();
```

2. 조회된 엔티티를 사용할 때마다 추가로 쿼리가 실행된다.

```java
for (Member member : members) {
    System.out.println(member.getTeam().getName());
}
```

3. 연관된 엔티티의 수만큼 추가로 쿼리가 실행된다.

```sql
SELECT * FROM Team WHERE team_id = 1;
SELECT * FROM Team WHERE team_id = 2;
SELECT * FROM Team WHERE team_id = 3;
...
```

### 해결 방법

> Eager Loading으로 N+1 문제를 해결하려고 하면 성능이 저하될 수 있다. 따라서 Fetch Join, Batch Fetch, EntityGraph 등을 사용하여 해결하는 것이 좋다.

**N+1 문제**를 해결하는 방법은 다음과 같다.

1. **Fetch Join 사용**: 연관된 엔티티를 함께 조회한다.

```java
@Query("SELECT m FROM Member m JOIN FETCH m.team")
List<Member> findAllWithTeam();
```

2. **Batch Fetch 사용**: 연관된 엔티티를 한꺼번에 조회한다.

```java
@Entity
public class Member {
    @ManyToOne(fetch = FetchType.LAZY)
    @BatchSize(size = 100)
    private Team team;
}
```

3. **EntityGraph 사용**: 연관된 엔티티를 함께 조회한다.

```java
// 이 방식은 JPA 2.1부터 지원된다.
@EntityGraph(attributePaths = {"team"})
@Query("SELECT m FROM Member m")
List<Member> findAllWithTeam();
```

### 결론

**N+1 문제**는 연관된 엔티티를 조회할 때 발생하는 성능 문제이다. 이 문제를 해결하기 위해서는 **Fetch Join**, **Batch Fetch**, **EntityGraph** 등을 사용하여 연관된 엔티티를 함께 조회하거나 한꺼번에 조회하는 방법을 사용할 수 있다.
