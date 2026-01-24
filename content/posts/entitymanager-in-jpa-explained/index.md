---
title: "JPA EntityManager"
date: 2024-06-07T19:12:36+09:00
tags: ["JPA", "ORM", "Java"]
description: "JPA EntityManager의 역할과 영속성 컨텍스트 관리 방법을 설명한다."
draft: false
---

## EntityManager의 역사와 개념

EntityManager는 Java Persistence API(JPA)의 핵심 인터페이스로, 2006년 JSR 220의 일부로 발표된 EJB 3.0 명세에서 처음 정의되었으며, Hibernate의 Session 인터페이스를 표준화하여 벤더 독립적인 영속성 관리 API를 제공하기 위해 설계되었다. Hibernate를 개발한 Gavin King이 2001년에 도입한 Session 개념은 데이터베이스 연결을 추상화하고 엔티티 객체의 상태를 추적하는 혁신적인 접근 방식이었는데, JPA는 이 아이디어를 표준화하여 EntityManager라는 이름으로 재정립하고 모든 JPA 구현체(Hibernate, EclipseLink, OpenJPA)에서 동일한 인터페이스를 사용할 수 있게 했다.

EntityManager가 해결하는 핵심 문제는 객체지향 프로그래밍의 객체와 관계형 데이터베이스의 테이블 간의 패러다임 불일치(Object-Relational Impedance Mismatch)로, 개발자가 SQL을 직접 작성하지 않고도 객체 중심의 코드로 데이터베이스 작업을 수행할 수 있게 하며, 1차 캐시, 변경 감지, 쓰기 지연 같은 최적화 기능을 자동으로 제공한다. EntityManager는 영속성 컨텍스트(Persistence Context)라는 논리적 공간을 관리하는데, 이 공간은 Martin Fowler가 정의한 Identity Map 패턴과 Unit of Work 패턴을 구현하여 동일 트랜잭션 내에서 같은 식별자를 가진 엔티티의 동일성을 보장하고, 변경된 엔티티를 추적하여 트랜잭션 종료 시 일괄적으로 데이터베이스에 반영한다.

## EntityManager의 생명주기와 관리 방식

### EntityManagerFactory와 EntityManager의 관계

EntityManager는 EntityManagerFactory로부터 생성되며, EntityManagerFactory는 데이터베이스 연결 정보, 엔티티 메타데이터, 캐시 설정 등을 포함하는 무거운 객체로 애플리케이션 전체에서 하나만 생성되어 공유되는 반면, EntityManager는 요청마다 생성되고 사용 후 반드시 종료되어야 하는 경량 객체이다. EntityManagerFactory의 생성은 persistence.xml이나 Spring 설정을 파싱하고 데이터베이스 메타데이터를 로딩하는 등 비용이 크기 때문에 애플리케이션 시작 시점에 한 번만 생성하며, EntityManager는 스레드 세이프하지 않으므로 여러 스레드에서 공유할 수 없고 각 요청이나 트랜잭션마다 새로운 인스턴스를 생성해야 한다.

### Application-Managed vs Container-Managed

EntityManager의 관리 방식은 Application-Managed와 Container-Managed 두 가지로 구분되는데, Application-Managed 방식은 Java SE 환경에서 주로 사용되며 개발자가 EntityManagerFactory.createEntityManager()로 직접 EntityManager를 생성하고 사용 후 close()를 호출하여 명시적으로 종료해야 한다. Container-Managed 방식은 Spring이나 Java EE 같은 컨테이너 환경에서 사용되며, 컨테이너가 EntityManager의 생명주기를 관리하여 트랜잭션 시작 시 자동으로 생성하고 트랜잭션 종료 시 자동으로 종료한다.

Spring 환경에서는 @PersistenceContext 어노테이션을 사용하여 Container-Managed EntityManager를 주입받는데, 실제로 주입되는 것은 SharedEntityManagerInvocationHandler라는 프록시 객체로서 각 트랜잭션마다 실제 EntityManager를 연결해주는 역할을 한다. @PersistenceUnit 어노테이션은 EntityManagerFactory를 주입받는 방식으로, 배치 작업이나 비동기 처리처럼 트랜잭션 범위를 세밀하게 제어해야 하는 경우에 개발자가 직접 EntityManager를 생성하고 관리할 때 사용한다.

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

persist() 메서드는 새로운 엔티티를 영속성 컨텍스트에 저장하여 영속 상태(Managed State)로 전환하는 메서드로, 호출 시점에 즉시 INSERT 쿼리가 실행되는 것이 아니라 영속성 컨텍스트의 쓰기 지연 SQL 저장소에 INSERT 쿼리가 등록되고, 트랜잭션 커밋 시점에 flush가 호출될 때 실제로 데이터베이스에 전송된다. @GeneratedValue로 IDENTITY 전략을 사용하는 경우에는 데이터베이스에서 ID를 생성해야 하므로 persist() 호출 시점에 즉시 INSERT가 실행되며, SEQUENCE나 TABLE 전략은 미리 시퀀스 값을 할당받아 쓰기 지연이 가능하다.

### find()와 getReference()

find() 메서드는 식별자를 통해 엔티티를 조회하는 가장 기본적인 메서드로, 먼저 영속성 컨텍스트의 1차 캐시를 확인하고 캐시에 없는 경우에만 데이터베이스에 SELECT 쿼리를 실행하며, 조회된 엔티티는 자동으로 영속 상태로 관리된다. getReference() 메서드는 실제 데이터베이스 조회를 지연시키는 프록시 객체를 반환하며, 프록시의 필드에 접근하는 시점에 실제 SELECT가 실행되는 지연 로딩(Lazy Loading) 방식으로 동작한다.

```java
User user1 = em.find(User.class, 1L); // 즉시 SELECT 실행
User user2 = em.getReference(User.class, 2L); // 프록시 반환, SELECT 없음
String name = user2.getName(); // 이 시점에 SELECT 실행
```

### merge()

merge() 메서드는 준영속 상태(Detached State)의 엔티티를 다시 영속 상태로 만드는 메서드로, 전달된 엔티티의 식별자로 영속성 컨텍스트를 확인하고 없으면 데이터베이스를 조회한 후, 조회된 영속 엔티티에 전달된 엔티티의 모든 값을 복사하고 그 영속 엔티티를 반환한다. 중요한 점은 merge()의 반환 값이 영속 상태의 엔티티이며 파라미터로 전달한 원본 엔티티는 여전히 준영속 상태로 남아있다는 것으로, 이후 작업은 반환된 영속 엔티티를 사용해야 변경 감지가 작동한다.

### remove()

remove() 메서드는 영속 상태의 엔티티를 삭제 예정 상태(Removed State)로 전환하는 메서드로, persist()와 마찬가지로 호출 즉시 DELETE 쿼리가 실행되지 않고 쓰기 지연 SQL 저장소에 DELETE 쿼리가 등록되며 트랜잭션 커밋 시점에 실제로 실행된다. remove()는 영속 상태의 엔티티에만 사용할 수 있으므로, 준영속 상태의 엔티티를 삭제하려면 먼저 find()나 merge()로 영속 상태로 만든 후 remove()를 호출해야 한다.

### flush()와 clear()

flush() 메서드는 영속성 컨텍스트의 변경 내용을 데이터베이스에 즉시 동기화하는 메서드로, 쓰기 지연 SQL 저장소에 있는 모든 쿼리를 데이터베이스로 전송하지만 트랜잭션을 커밋하지는 않으며, JPQL 쿼리 실행 직전에 자동으로 호출되어 쿼리가 최신 데이터를 조회할 수 있도록 보장한다. clear() 메서드는 영속성 컨텍스트를 완전히 초기화하여 관리 중인 모든 엔티티를 준영속 상태로 만드는 메서드로, 대량 데이터를 처리할 때 1차 캐시에 엔티티가 쌓여 메모리 부족이 발생하는 것을 방지하기 위해 일정 주기로 flush()와 clear()를 함께 호출한다.

## 트랜잭션과 영속성 컨텍스트

### 트랜잭션 범위 영속성 컨텍스트

Spring에서는 기본적으로 트랜잭션 범위 영속성 컨텍스트 전략을 사용하며, @Transactional 어노테이션이 붙은 메서드가 시작될 때 트랜잭션과 영속성 컨텍스트가 함께 생성되고, 메서드가 종료될 때 트랜잭션 커밋과 함께 영속성 컨텍스트가 종료된다. 트랜잭션 커밋 시점에 자동으로 flush()가 호출되어 변경 감지(Dirty Checking)가 수행되고, 영속 상태 엔티티의 스냅샷과 현재 상태를 비교하여 변경된 필드에 대해 UPDATE 쿼리가 자동으로 생성된다.

### 변경 감지와 동일성 보장

변경 감지(Dirty Checking)는 EntityManager가 엔티티를 영속 상태로 만들 때 해당 시점의 스냅샷을 저장하고, flush 시점에 현재 상태와 비교하여 변경된 필드를 찾아 UPDATE 쿼리를 자동 생성하는 기능으로, 개발자가 명시적으로 update() 같은 메서드를 호출하지 않아도 setter로 값만 변경하면 자동으로 데이터베이스에 반영된다. 동일성 보장(Identity Guarantee)은 같은 트랜잭션 내에서 같은 식별자로 조회한 엔티티는 항상 같은 객체 인스턴스임을 보장하는 기능으로, em.find(User.class, 1L)을 여러 번 호출해도 항상 동일한 인스턴스가 반환되어 == 비교가 true를 반환한다.

## JPQL과 Criteria API

### JPQL (Java Persistence Query Language)

JPQL은 엔티티 객체를 대상으로 쿼리를 작성하는 객체 지향 쿼리 언어로, 테이블이 아닌 엔티티 클래스와 필드를 대상으로 하며 데이터베이스에 독립적이어서 데이터베이스가 변경되어도 쿼리를 수정할 필요가 없다. EntityManager.createQuery() 메서드로 JPQL을 실행하며, TypedQuery를 사용하면 결과 타입을 지정하여 타입 안전성을 확보할 수 있고, 파라미터 바인딩은 위치 기반(:1)과 이름 기반(:name) 두 가지 방식을 지원한다.

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

Criteria API는 CriteriaBuilder를 사용하여 자바 코드로 쿼리를 작성하는 방식으로, JPQL이 문자열 기반이라 컴파일 타임에 오류를 발견할 수 없는 단점을 보완하여 타입 세이프한 쿼리 작성이 가능하지만, 코드가 복잡하고 가독성이 떨어지는 단점이 있어 동적 쿼리가 필요한 경우에만 선택적으로 사용하는 것이 좋다. 네이티브 SQL이 필요한 경우에는 createNativeQuery() 메서드를 사용하여 데이터베이스 고유의 SQL을 직접 실행할 수 있으며, 복잡한 통계 쿼리나 데이터베이스 특정 기능을 사용해야 할 때 유용하다.

## Spring Data JPA와의 관계

Spring Data JPA의 Repository 인터페이스(JpaRepository, CrudRepository)는 내부적으로 EntityManager를 사용하여 구현되어 있으며, SimpleJpaRepository 클래스가 실제 구현체로서 save()는 새 엔티티면 persist()를, 기존 엔티티면 merge()를 호출하고, findById()는 EntityManager.find()를, deleteById()는 find() 후 remove()를 호출하는 방식으로 동작한다. Spring Data JPA는 메서드 이름 기반 쿼리 생성, @Query 어노테이션, Specification 등의 편의 기능을 제공하여 개발 생산성을 높이지만, 복잡한 쿼리나 벌크 연산, 세밀한 영속성 컨텍스트 제어가 필요한 경우에는 @PersistenceContext로 EntityManager를 직접 주입받아 사용하는 것이 적합하다.

## 실전 최적화 팁

### 대량 데이터 처리

수천 개 이상의 엔티티를 한 번에 처리하면 영속성 컨텍스트에 모든 엔티티가 쌓여 메모리 부족이 발생할 수 있으므로, 일정 개수(예: 100개)마다 flush()와 clear()를 호출하여 영속성 컨텍스트를 비워주어야 하며, JDBC 배치 설정(hibernate.jdbc.batch_size)을 통해 여러 INSERT나 UPDATE를 하나의 배치로 묶어 실행하면 성능을 크게 향상시킬 수 있다.

### N+1 문제 해결

N+1 문제는 부모 엔티티 N개를 조회한 후 각 부모마다 자식 엔티티를 조회하는 쿼리가 추가로 N번 실행되어 총 N+1번의 쿼리가 발생하는 현상으로, JPQL의 fetch join을 사용하여 한 번의 쿼리로 부모와 자식을 함께 조회하거나, @EntityGraph를 사용하여 필요한 연관 관계를 명시적으로 로딩하거나, hibernate.default_batch_fetch_size를 설정하여 자식 엔티티를 IN 절로 묶어서 조회하는 방법으로 해결한다.

## 결론

EntityManager는 JPA의 핵심 인터페이스로 2006년 EJB 3.0 명세에서 Hibernate의 Session을 표준화한 것이며, 영속성 컨텍스트를 통해 1차 캐시, 변경 감지, 쓰기 지연, 동일성 보장 기능을 제공한다. persist(), find(), merge(), remove() 등의 메서드로 엔티티의 생명주기를 관리하고, JPQL과 Criteria API로 객체 지향 쿼리를 실행하며, 트랜잭션 범위 내에서 동작하도록 설계되어 있다. Spring Data JPA는 EntityManager를 기반으로 추상화 계층을 제공하지만, 복잡한 쿼리나 세밀한 제어가 필요한 경우에는 EntityManager를 직접 사용하는 것이 적합하며, 대량 데이터 처리 시에는 flush()와 clear()로 메모리를 관리하고 배치 설정과 fetch join으로 성능을 최적화해야 한다.
