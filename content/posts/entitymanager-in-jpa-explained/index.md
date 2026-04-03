---
title: "JPA EntityManager"
date: 2024-06-07T19:12:36+09:00
tags: ["JPA", "ORM", "Java"]
description: "JPA EntityManager의 역할과 영속성 컨텍스트 관리 방법을 설명한다."
draft: false
---

## EntityManager의 역사와 개념

EntityManager는 Java Persistence API(JPA)의 핵심 인터페이스다. 2006년 JSR 220의 일부로 발표된 EJB 3.0 명세에서 처음 정의되었고, Hibernate의 `Session` 인터페이스를 표준화해 벤더 독립적인 영속성 관리 API를 제공하도록 설계되었다. Gavin King이 2001년에 도입한 `Session` 개념은 데이터베이스 연결을 추상화하고 엔티티 객체의 상태를 추적하는 방식으로 주목받았는데, JPA는 이를 표준화해 `EntityManager`라는 이름으로 재정립했다. 덕분에 Hibernate, EclipseLink, OpenJPA 같은 구현체에서도 동일한 인터페이스를 사용할 수 있다.

EntityManager가 다루는 핵심 문제는 객체지향 프로그래밍의 객체와 관계형 데이터베이스의 테이블 사이에 존재하는 패러다임 불일치(Object-Relational Impedance Mismatch)다. 개발자는 SQL을 직접 다루지 않고도 객체 중심의 코드로 데이터베이스 작업을 수행할 수 있고, EntityManager는 1차 캐시, 변경 감지, 쓰기 지연 같은 최적화 기능을 자동으로 제공한다. 또한 영속성 컨텍스트(Persistence Context)라는 논리적 공간을 관리한다. 이 공간은 Martin Fowler가 정리한 Identity Map 패턴과 Unit of Work 패턴을 구현해, 동일 트랜잭션 안에서 같은 식별자를 가진 엔티티의 동일성을 보장하고 변경된 엔티티를 추적해 트랜잭션 종료 시점에 일괄 반영한다.

## EntityManager의 생명주기와 관리 방식

### EntityManagerFactory와 EntityManager의 관계

EntityManager는 `EntityManagerFactory`로부터 생성된다. `EntityManagerFactory`는 데이터베이스 연결 정보, 엔티티 메타데이터, 캐시 설정 등을 담는 무거운 객체다. `persistence.xml`이나 Spring 설정을 파싱하고 데이터베이스 메타데이터를 로딩하는 과정이 포함되므로, 보통 애플리케이션 전체에서 하나만 만들어 공유한다. 반면 `EntityManager`는 요청이나 트랜잭션마다 생성해서 사용하는 경량 객체다. 또한 스레드 세이프하지 않으므로 여러 스레드에서 공유하면 안 되며, 사용이 끝나면 반드시 종료해야 한다.

### Application-Managed vs Container-Managed

EntityManager의 관리 방식은 크게 Application-Managed와 Container-Managed로 나뉜다. Application-Managed 방식은 Java SE 환경에서 주로 사용한다. 개발자가 `EntityManagerFactory.createEntityManager()`로 직접 EntityManager를 만들고, 사용이 끝나면 `close()`를 호출해 명시적으로 종료해야 한다.

Container-Managed 방식은 Spring이나 Java EE 같은 컨테이너 환경에서 사용한다. 이 경우 컨테이너가 EntityManager의 생명주기를 관리하며, 보통 트랜잭션 시작 시 생성하고 종료 시 함께 정리한다.

Spring에서는 `@PersistenceContext`로 Container-Managed EntityManager를 주입받는다. 이때 실제로 주입되는 것은 `SharedEntityManagerInvocationHandler` 기반의 프록시 객체이며, 각 트랜잭션에 맞는 실제 EntityManager를 연결해준다. 반면 `@PersistenceUnit`은 `EntityManagerFactory`를 주입받는 방식이다. 배치 작업이나 비동기 처리처럼 트랜잭션 범위를 더 세밀하게 제어해야 할 때 유용하다.

```java
// Application-Managed 방식
EntityManagerFactory emf = Persistence.createEntityManagerFactory("persistence-unit");
EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();

tx.begin();
// 작업 수행
tx.commit();
em.close(); // 반드시 명시적으로 종료

// Container-Managed 방식 (Spring)
@Repository
public class UserRepository {
    @PersistenceContext
    private EntityManager em; // 프록시 객체 주입, 트랜잭션마다 실제 EM 연결
}
```

## 주요 API 메서드

### persist()

`persist()`는 새로운 엔티티를 영속성 컨텍스트에 저장해 영속 상태(Managed State)로 전환하는 메서드다. 일반적으로 호출 즉시 `INSERT` 쿼리가 실행되지는 않는다. 대신 영속성 컨텍스트의 쓰기 지연 SQL 저장소에 `INSERT`가 등록되고, 트랜잭션 커밋 시점에 `flush()`가 일어나면서 실제 데이터베이스로 전송된다. 다만 `@GeneratedValue`에서 `IDENTITY` 전략을 쓰면 데이터베이스가 ID를 만들어야 하므로 `persist()` 시점에 즉시 `INSERT`가 실행된다. `SEQUENCE`나 `TABLE` 전략은 시퀀스 값을 미리 확보할 수 있어 쓰기 지연이 가능하다.

### find()와 getReference()

`find()`는 식별자로 엔티티를 조회하는 가장 기본적인 메서드다. 먼저 영속성 컨텍스트의 1차 캐시를 확인하고, 캐시에 없을 때만 데이터베이스에 `SELECT`를 실행한다. 조회된 엔티티는 자동으로 영속 상태로 관리된다. `getReference()`는 실제 조회를 지연시키는 프록시 객체를 반환한다. 따라서 프록시의 필드에 접근하는 시점에 `SELECT`가 실행되는 지연 로딩(Lazy Loading) 방식으로 동작한다.

```java
User user1 = em.find(User.class, 1L); // 즉시 SELECT 실행
User user2 = em.getReference(User.class, 2L); // 프록시 반환, SELECT 없음
String name = user2.getName(); // 이 시점에 SELECT 실행
```

### merge()

`merge()`는 준영속 상태(Detached State)의 엔티티를 다시 영속성 컨텍스트와 연결할 때 사용하는 메서드다. 전달된 엔티티의 식별자를 기준으로 먼저 영속성 컨텍스트를 확인하고, 없으면 데이터베이스를 조회한다. 그다음 조회된 영속 엔티티에 전달된 엔티티의 값을 복사한 뒤, 그 영속 엔티티를 반환한다.

여기서 중요한 점은 반환값만 영속 상태라는 것이다. 파라미터로 넘긴 원본 엔티티는 여전히 준영속 상태로 남기 때문에, 이후 변경 감지를 기대한다면 반환된 엔티티를 기준으로 작업해야 한다.

### remove()

`remove()`는 영속 상태의 엔티티를 삭제 예정 상태(Removed State)로 바꾸는 메서드다. `persist()`와 마찬가지로 호출 즉시 `DELETE`가 실행되지는 않고, 쓰기 지연 SQL 저장소에 `DELETE`가 등록된 뒤 트랜잭션 커밋 시점에 실제로 실행된다. `remove()`는 영속 상태의 엔티티에만 적용할 수 있으므로, 준영속 엔티티를 삭제하려면 먼저 `find()`나 `merge()`로 영속 상태로 만든 다음 호출해야 한다.

### flush()와 clear()

`flush()`는 영속성 컨텍스트의 변경 내용을 데이터베이스에 즉시 동기화하는 메서드다. 쓰기 지연 SQL 저장소에 쌓인 쿼리를 데이터베이스로 전송하지만, 트랜잭션 자체를 커밋하지는 않는다. 또한 JPQL 실행 직전에 자동 호출되어 쿼리가 최신 상태를 기준으로 동작하게 한다.

`clear()`는 영속성 컨텍스트를 완전히 초기화해 관리 중인 모든 엔티티를 준영속 상태로 만든다. 대량 데이터를 처리할 때는 1차 캐시에 엔티티가 계속 쌓여 메모리 사용량이 커질 수 있으므로, 일정 주기마다 `flush()`와 `clear()`를 함께 호출해 관리하는 것이 일반적이다.

## 트랜잭션과 영속성 컨텍스트

### 트랜잭션 범위 영속성 컨텍스트

Spring은 기본적으로 트랜잭션 범위 영속성 컨텍스트 전략을 사용한다. `@Transactional`이 붙은 메서드가 시작되면 트랜잭션과 영속성 컨텍스트가 함께 생성되고, 메서드가 끝나면 트랜잭션 커밋과 함께 영속성 컨텍스트도 종료된다. 커밋 시점에는 자동으로 `flush()`가 호출되고, 이 과정에서 변경 감지(Dirty Checking)가 수행된다. 영속 엔티티의 스냅샷과 현재 상태를 비교해 변경된 필드에 대한 `UPDATE` 쿼리가 자동으로 만들어진다.

### 변경 감지와 동일성 보장

변경 감지(Dirty Checking)는 EntityManager가 엔티티를 영속 상태로 만들 때 해당 시점의 스냅샷을 저장해두고, `flush()` 시점에 현재 상태와 비교해 변경된 필드를 찾아내는 방식이다. 그래서 개발자가 별도의 `update()` 메서드를 호출하지 않아도, setter로 값을 바꾸기만 하면 변경 내용이 데이터베이스에 반영된다.

동일성 보장(Identity Guarantee)은 같은 트랜잭션 안에서 같은 식별자로 조회한 엔티티가 항상 같은 객체 인스턴스임을 보장하는 성질이다. 예를 들어 `em.find(User.class, 1L)`을 여러 번 호출해도 항상 동일한 인스턴스가 반환되므로 `==` 비교 결과가 `true`가 된다.

## JPQL과 Criteria API

### JPQL (Java Persistence Query Language)

JPQL은 엔티티 객체를 대상으로 쿼리를 작성하는 객체 지향 쿼리 언어다. 테이블이 아니라 엔티티 클래스와 필드를 기준으로 작성하므로 데이터베이스에 덜 종속적이며, 데이터베이스가 바뀌어도 쿼리를 그대로 유지하기 쉽다. `EntityManager.createQuery()`로 실행하며, `TypedQuery`를 사용하면 결과 타입을 지정해 타입 안전성을 높일 수 있다. 파라미터 바인딩은 위치 기반(`?1`)과 이름 기반(`:name`) 두 방식을 지원한다.

```java
// JPQL 예시
TypedQuery<User> query = em.createQuery(
    "SELECT u FROM User u WHERE u.status = :status AND u.age > :age",
    User.class
);
query.setParameter("status", UserStatus.ACTIVE);
query.setParameter("age", 18);
List<User> users = query.getResultList();
```

### Criteria API와 Native Query

Criteria API는 `CriteriaBuilder`를 사용해 자바 코드로 쿼리를 작성하는 방식이다. 문자열 기반인 JPQL과 달리 컴파일 시점에 더 많은 오류를 잡을 수 있어, 동적 쿼리가 많을 때 타입 세이프하게 작성하기 좋다. 다만 코드가 복잡해지고 가독성이 떨어지기 쉬워서, 보통은 동적 쿼리가 꼭 필요한 경우에 선택적으로 사용한다. 네이티브 SQL이 필요할 때는 `createNativeQuery()`를 사용해 데이터베이스 고유의 SQL을 직접 실행할 수 있다. 복잡한 통계 쿼리나 데이터베이스별 기능을 써야 할 때 유용하다.

## Spring Data JPA와의 관계

Spring Data JPA의 Repository 인터페이스(`JpaRepository`, `CrudRepository`)는 내부적으로 EntityManager를 기반으로 동작한다. 실제 구현체인 `SimpleJpaRepository`는 새 엔티티에는 `persist()`를, 기존 엔티티에는 `merge()`를 호출하는 방식으로 `save()`를 처리한다. `findById()`는 `EntityManager.find()`를, `deleteById()`는 `find()` 후 `remove()`를 호출한다. Spring Data JPA는 메서드 이름 기반 쿼리 생성, `@Query` 어노테이션, `Specification` 같은 편의 기능을 제공해 생산성을 높여준다. 다만 복잡한 쿼리, 벌크 연산, 세밀한 영속성 컨텍스트 제어가 필요하다면 `@PersistenceContext`로 EntityManager를 직접 주입받아 쓰는 편이 적합하다.

## 실전 최적화 팁

### 대량 데이터 처리

수천 개 이상의 엔티티를 한 번에 처리하면 영속성 컨텍스트에 객체가 계속 쌓여 메모리 부족이 발생할 수 있다. 이런 경우 일정 개수마다 `flush()`와 `clear()`를 호출해 영속성 컨텍스트를 비워주는 것이 좋다. 예를 들어 100건 단위로 끊어 처리하면 메모리를 더 안정적으로 관리할 수 있다. 여기에 JDBC 배치 설정(`hibernate.jdbc.batch_size`)까지 적용하면 여러 `INSERT`나 `UPDATE`를 한 번의 배치로 묶어 성능을 높일 수 있다.

### N+1 문제 해결

N+1 문제는 부모 엔티티 N개를 조회한 뒤, 각 부모마다 자식 엔티티를 조회하는 쿼리가 추가로 실행되어 총 N+1번의 쿼리가 발생하는 현상이다. 가장 대표적인 해결 방법은 JPQL의 fetch join으로 한 번에 함께 조회하는 것이다. 또는 `@EntityGraph`로 필요한 연관 관계를 명시적으로 로딩할 수도 있다. `hibernate.default_batch_fetch_size`를 설정해 자식 엔티티를 `IN` 절로 묶어 조회하는 방식도 자주 사용된다.

## 결론

EntityManager는 JPA에서 영속성 컨텍스트를 다루는 핵심 인터페이스다. 이 객체를 통해 1차 캐시, 변경 감지, 쓰기 지연, 동일성 보장 같은 기능이 동작한다. `persist()`, `find()`, `merge()`, `remove()` 같은 메서드는 엔티티의 생명주기를 관리하는 기본 수단이며, JPQL과 Criteria API는 객체 중심으로 데이터를 조회하고 조작하는 방법을 제공한다.

실무에서는 Spring Data JPA가 이 역할을 상당 부분 추상화해주지만, 동작 원리를 이해하고 있어야 복잡한 쿼리나 성능 문제를 제대로 다룰 수 있다. 특히 대량 처리에서는 `flush()`와 `clear()`로 메모리를 관리하고, 조회 성능 문제는 fetch join이나 배치 설정으로 조정하는 식의 판단이 중요하다.
