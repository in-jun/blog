---
title: "Dirty Checking 알아보기"
date: 2024-06-08T02:47:28+09:00
tags: ["ORM", "java"]
draft: false
---

### Dirty Checking이란

**Dirty Checking**은 JPA(Java Persistence API)에서 엔티티의 변경 사항을 자동으로 감지하고, 이를 데이터베이스에 반영하는 방식이다. Dirty Checking을 통해 개발자는 명시적으로 데이터베이스 업데이트 쿼리를 작성할 필요 없이, 객체의 상태만 변경하면 된다.

또한 Dirty Checking은 영속성 컨텍스트(Persistence Context)가 관리하는 엔티티만 적용된다.

### Dirty Checking 동작 방식

1. 엔티티 관리:

-   EntityManager가 엔티티를 관리한다.
-   영속성 컨텍스트(Persistence Context)가 엔티티의 초기 상태를 저장한다.

2. 변경 감지:

-   트랜잭션이 커밋되기 전에, JPA는 엔티티의 현제 상태와 초기 상태를 비교한다.

3. 변경 사항 적용:

-   변경 사항이 감지되면, JPA는 자동으로 데이터베이스 업데이트 쿼리를 생성하고 실행한다.
-   트랜잭션이 커밋되면, 변경 사항이 데이터베이스에 반영된다.

### 예시

```java
// 엔티티 저장
Member member = new Member("Alice");
memberRepository.save(member);

// 엔티티 조회
Member findMember = memberRepository.findById(member.getId()).get();

// 엔티티 변경
findMember.setName("Bob");

// 변경 사항 감지
// Dirty Checking이 동작하여 자동으로 데이터베이스 업데이트 쿼리를 생성하고 실행한다.
// UPDATE member SET name = 'Bob' WHERE id = 1;
```

### 장점

-   **편의성**: 개발자가 데이터베이스 업데이트 쿼리를 작성할 필요 없이, 객체의 상태만 변경하면 된다.
-   **일관성**: 변경 사항이 자동으로 데이터베이스에 반영되므로, 데이터 일관성을 유지할 수 있다.
-   **생산성**: 개발자가 비즈니스 로직에 집중할 수 있으므로, 생산성이 향상된다.
