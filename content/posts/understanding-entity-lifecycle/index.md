---
title: "엔티티 생명주기 알아보기"
date: 2024-06-08T01:18:57+09:00
tags: ["jpa", "java", "hibernate", "persistence"]
description: "JPA 엔티티의 4가지 생명주기 상태(비영속, 영속, 준영속, 삭제)와 상태 전이 과정, EntityManager 메서드, 영속성 컨텍스트의 flush와 clear 동작을 정리한다"
draft: false
---

## 엔티티 생명주기란

JPA(Java Persistence API)에서 엔티티의 생명주기는 엔티티 객체가 생성되고 소멸할 때까지 거치는 일련의 상태 변화를 의미한다. 엔티티가 영속성 컨텍스트(Persistence Context)에 의해 관리되는지 여부와 데이터베이스와의 동기화 상태에 따라 구분된다.

엔티티의 상태를 올바르게 이해하는 것은 JPA를 효과적으로 사용하고 데이터 일관성을 유지하며 성능을 최적화하는 데 필수적이다. 각 상태에서 EntityManager가 엔티티를 어떻게 처리하는지 파악하면 예기치 않은 동작을 방지하고 트랜잭션을 안전하게 관리할 수 있다.

## 엔티티 생명주기의 4가지 상태

### 비영속 (New/Transient)

비영속 상태는 엔티티 객체가 생성되었지만 아직 영속성 컨텍스트에 저장되지 않은 상태이다. EntityManager와 아무런 관계가 없는 순수한 자바 객체이며, 데이터베이스와도 연결되지 않아 데이터베이스에 저장되지 않은 상태를 의미한다.

#### 특징

- `new` 키워드로 생성한 엔티티 객체는 기본적으로 비영속 상태
- JPA가 관리하지 않으므로 변경 감지(Dirty Checking)나 1차 캐시 같은 영속성 컨텍스트의 기능을 사용할 수 없음
- 트랜잭션이 커밋되어도 데이터베이스에 반영되지 않음

```java
// 비영속 상태 - EntityManager와 무관한 순수 객체
User user = new User();
user.setName("홍길동");
user.setEmail("hong@example.com");
// 아직 영속성 컨텍스트에 관리되지 않음
```

### 영속 (Managed/Persistent)

영속 상태는 엔티티가 영속성 컨텍스트에 저장되어 EntityManager에 의해 관리되는 상태이다. 영속성 컨텍스트가 해당 엔티티의 변경 사항을 추적하고 트랜잭션 커밋 시 데이터베이스와 자동으로 동기화한다.

#### 영속 상태로의 전환

- `persist()` 메서드를 호출
- `find()`, `JPQL` 등으로 데이터베이스에서 조회

#### 영속 상태의 장점

- 1차 캐시에 보관
- 변경 감지가 활성화
- 지연 로딩이 가능
- 쓰기 지연을 통해 성능 최적화

영속 상태에서는 엔티티의 필드를 변경하기만 해도 트랜잭션 커밋 시 자동으로 UPDATE 쿼리가 실행된다. 개발자가 명시적으로 저장 메서드를 호출할 필요가 없다.

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

// 비영속 상태
User user = new User();
user.setName("홍길동");

// 영속 상태로 전환 - persist() 호출
em.persist(user);
// 이제 영속성 컨텍스트가 user를 관리하며, 커밋 시 INSERT 쿼리 실행

// 영속 상태 엔티티 조회
User foundUser = em.find(User.class, 1L);
// find()로 조회한 엔티티도 영속 상태

// 영속 상태에서 값 변경 - 자동으로 UPDATE 쿼리 생성
foundUser.setName("김철수");
// 별도의 update() 호출 없이 커밋 시 자동 반영

tx.commit(); // 이 시점에 실제 SQL 실행
```

### 준영속 (Detached)

준영속 상태는 이전에 영속 상태였던 엔티티가 영속성 컨텍스트에서 분리되어 더 이상 EntityManager의 관리를 받지 않는 상태이다.

#### 특징

- 데이터베이스 식별자(ID)는 가지고 있음
- 영속성 컨텍스트의 관리 대상이 아니므로 변경 감지나 지연 로딩 같은 기능이 동작하지 않음

#### 준영속 상태로의 전환

- `detach()` 메서드로 특정 엔티티를 준영속 상태로 만듦
- `clear()`로 영속성 컨텍스트를 초기화
- `close()`로 영속성 컨텍스트를 종료

준영속 상태의 엔티티를 다시 영속 상태로 만들려면 `merge()` 메서드를 사용해야 한다.

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user = em.find(User.class, 1L); // 영속 상태

// 준영속 상태로 전환 - detach() 호출
em.detach(user);
// 이제 user는 영속성 컨텍스트에서 분리됨

user.setName("이영희"); // 변경해도 DB에 반영되지 않음

tx.commit(); // 준영속 상태의 변경사항은 무시됨

// 준영속 엔티티를 다시 영속 상태로 - merge() 사용
tx.begin();
User mergedUser = em.merge(user);
// mergedUser는 영속 상태, user는 여전히 준영속 상태
tx.commit(); // 이제 변경사항이 DB에 반영됨
```

### 삭제 (Removed)

삭제 상태는 엔티티가 영속성 컨텍스트와 데이터베이스에서 삭제되도록 예약된 상태이다.

#### 특징

- `remove()` 메서드를 호출하면 엔티티가 삭제 상태로 전환
- 트랜잭션이 커밋될 때 실제 데이터베이스에서 DELETE 쿼리가 실행
- 삭제 상태의 엔티티는 영속성 컨텍스트에서 관리되지만 데이터베이스에서 제거될 예정이라는 표시가 되어 있음
- 커밋 전까지는 실제로 데이터베이스에서 삭제되지 않고 롤백하면 삭제가 취소될 수 있음

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user = em.find(User.class, 1L); // 영속 상태

// 삭제 상태로 전환 - remove() 호출
em.remove(user);
// user는 삭제 상태, 아직 DB에서는 삭제되지 않음

tx.commit(); // 이 시점에 실제 DELETE 쿼리 실행
// 커밋 후 user는 삭제됨
```

## 영속성 컨텍스트와 상태 전이

영속성 컨텍스트는 엔티티를 영구 저장하는 환경으로 엔티티 매니저를 통해 엔티티를 조회하거나 저장할 때 엔티티를 보관하고 관리하는 논리적 공간이다. 애플리케이션과 데이터베이스 사이에서 객체를 보관하는 가상의 저장소 역할을 한다.

### 영속성 컨텍스트의 기능

- **1차 캐시**: 같은 트랜잭션 내에서 동일한 엔티티를 반복 조회할 때 데이터베이스 접근 없이 캐시에서 반환
- **변경 감지(Dirty Checking)**: 엔티티의 변경사항을 자동으로 추적
- **쓰기 지연(Transactional Write-Behind)**: 여러 쿼리를 모아서 한 번에 실행하여 성능을 최적화

### Flush 동작

flush는 영속성 컨텍스트에 있는 변경 내용을 데이터베이스에 반영하는 작업이다.

#### Flush의 특징

- 영속성 컨텍스트의 변경사항을 데이터베이스와 동기화
- 영속성 컨텍스트를 비우는 것이 아니며 관리되는 엔티티는 여전히 영속 상태를 유지

#### Flush 발생 시점

- `em.flush()`를 직접 호출
- 트랜잭션 커밋 시 자동으로 호출
- JPQL 쿼리 실행 전에 자동으로 호출

#### Flush 과정

1. 변경 감지가 작동하여 수정된 엔티티를 찾음
2. 수정 쿼리를 생성해서 쓰기 지연 SQL 저장소에 등록
3. 쓰기 지연 SQL 저장소의 쿼리를 데이터베이스에 전송

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user = new User();
user.setName("박민수");
em.persist(user); // 영속 상태

// 명시적 flush - 즉시 DB에 반영
em.flush();
// 이 시점에 INSERT 쿼리가 실행됨

// flush 후에도 user는 여전히 영속 상태
user.setName("최지훈"); // 변경 가능

tx.commit(); // 커밋 시 다시 flush 발생하여 UPDATE 쿼리 실행
```

### Clear 동작

clear는 영속성 컨텍스트를 완전히 초기화하여 관리 중인 모든 엔티티를 준영속 상태로 전환하는 작업이다.

#### Clear의 특징

- `em.clear()`를 호출하면 1차 캐시를 포함한 영속성 컨텍스트의 모든 내용이 삭제
- 관리되던 엔티티들이 모두 준영속 상태가 됨

#### Clear 사용 시점

- 영속성 컨텍스트에 많은 엔티티가 쌓여 메모리 사용량이 증가했을 때
- 테스트 코드에서 각 테스트 간 격리를 보장하기 위해

#### Clear 후 주의사항

- 이전에 조회했던 엔티티를 다시 사용하려면 재조회해야 함
- 기존 엔티티 객체에 대한 변경사항은 데이터베이스에 반영되지 않음

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user1 = em.find(User.class, 1L); // 영속 상태
User user2 = em.find(User.class, 2L); // 영속 상태

// 영속성 컨텍스트 초기화
em.clear();
// user1, user2 모두 준영속 상태로 전환

user1.setName("변경"); // 변경해도 DB에 반영되지 않음

// 다시 조회하면 새로운 영속 상태 엔티티 반환
User user3 = em.find(User.class, 1L); // 새로운 영속 상태

tx.commit();
```

## 상태 전이 메서드

### persist() - 비영속에서 영속으로

`persist()` 메서드는 비영속 상태의 새로운 엔티티를 영속성 컨텍스트에 저장하여 영속 상태로 만든다.

#### 동작 방식

- 엔티티가 영속 상태가 되면 1차 캐시에 저장됨
- 트랜잭션 커밋 시 INSERT 쿼리가 실행됨

#### 사용 시 주의사항

- 새로운 엔티티에만 사용해야 함
- 이미 데이터베이스에 존재하는 엔티티(ID가 할당된 엔티티)에 호출하면 예외가 발생할 수 있음
- 준영속 상태의 엔티티를 다시 영속 상태로 만들려면 `persist()` 대신 `merge()`를 사용해야 함

### merge() - 준영속에서 영속으로

`merge()` 메서드는 준영속 상태의 엔티티를 영속 상태로 만드는 메서드이다.

#### 동작 방식

1. 준영속 엔티티의 식별자로 영속성 컨텍스트에서 엔티티를 조회
2. 조회된 영속 엔티티에 준영속 엔티티의 값을 병합
3. 병합된 영속 엔티티를 반환

#### 중요한 특징

- `merge()`는 준영속 엔티티를 영속 상태로 변환하는 것이 아님
- 준영속 엔티티의 값을 가진 새로운 영속 엔티티를 반환
- `merge()` 호출 후에는 반환된 엔티티를 사용해야 함
- 원본 준영속 엔티티는 여전히 준영속 상태로 남아있음

### detach() - 영속에서 준영속으로

`detach()` 메서드는 특정 엔티티를 영속성 컨텍스트에서 분리하여 준영속 상태로 만든다.

#### 영향

- 분리된 엔티티는 더 이상 영속성 컨텍스트의 관리를 받지 않음
- 변경 감지가 작동하지 않음
- 지연 로딩도 불가능

#### 사용 사례

- 영속성 컨텍스트에 관리되는 엔티티가 너무 많을 때 일부만 분리
- 특정 엔티티의 변경사항을 데이터베이스에 반영하고 싶지 않을 때

### remove() - 영속에서 삭제로

`remove()` 메서드는 영속 상태의 엔티티를 삭제 상태로 전환하여 트랜잭션 커밋 시 데이터베이스에서 삭제되도록 예약한다.

#### 동작 방식

- 삭제 상태의 엔티티는 영속성 컨텍스트에서 제거 예정으로 표시
- 커밋 시 DELETE 쿼리가 실행

#### 주의사항

- 삭제된 엔티티를 다시 사용하려고 하면 예외가 발생할 수 있음
- `remove()` 호출 후에는 해당 엔티티를 더 이상 사용하지 않는 것이 좋음

## 결론

JPA 엔티티의 생명주기는 비영속, 영속, 준영속, 삭제의 4가지 상태로 구분된다. 각 상태는 EntityManager의 메서드를 통해 전환되고 영속성 컨텍스트의 관리 여부와 데이터베이스 동기화 상태에 따라 결정된다.

엔티티 상태를 정확히 이해하면 다음과 같은 이점을 얻을 수 있다.

- 변경 감지와 1차 캐시 같은 영속성 컨텍스트의 기능을 효과적으로 활용
- flush와 clear의 동작 시점을 파악하여 성능을 최적화
- 준영속 상태로 인한 LazyInitializationException 같은 예외를 방지
- 트랜잭션 범위 내에서 엔티티를 안전하게 관리
