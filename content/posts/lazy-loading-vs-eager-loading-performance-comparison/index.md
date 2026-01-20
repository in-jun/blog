---
title: "Lazy Loading VS Eager Loading"
date: 2024-06-08T01:45:34+09:00
tags: ["jpa", "java", "hibernate", "performance"]
description: "Lazy Loading은 프록시 기반 지연 로딩으로 연관 엔티티를 실제 사용 시점에 조회하고, Eager Loading은 즉시 조인하여 함께 로딩한다. N+1 문제는 fetch join, @EntityGraph, @BatchSize로 해결하며, 실무에서는 LAZY 기본 설정을 권장한다"
draft: false
---

## 로딩 전략의 역사와 필요성

ORM(Object-Relational Mapping) 프레임워크는 객체지향 프로그래밍과 관계형 데이터베이스 사이의 불일치를 해결하기 위해 등장했으며, 이 과정에서 연관관계를 가진 엔티티들을 어떻게 효율적으로 로딩할 것인가라는 문제가 중요한 과제로 대두되었다. 초기 ORM 구현체들은 모든 연관 엔티티를 즉시 로딩하는 방식을 사용했으나, 이는 불필요한 데이터까지 메모리에 적재하여 성능 저하를 일으켰고, Hibernate는 이를 해결하기 위해 프록시 기반의 지연 로딩 메커니즘을 도입했다.

Hibernate는 2001년 처음 공개된 이후 로딩 전략을 지속적으로 개선해왔으며, 초기 버전에서는 단순한 지연 로딩만 지원했지만, 이후 버전에서는 fetch join, batch fetching, subselect fetching 등 다양한 최적화 기법을 추가했다. 이러한 기능들은 JPA(Java Persistence API) 1.0 표준이 2006년에 공개되면서 표준 스펙에 포함되었고, JPA 2.0(2009년)과 JPA 2.1(2013년)을 거치면서 @EntityGraph와 같은 선언적 페치 전략이 추가되어 더욱 세련된 방식으로 연관 엔티티 로딩을 제어할 수 있게 되었으며, 현재는 JPA 표준과 Hibernate 구현체가 함께 발전하며 개발자에게 다양한 선택지를 제공하고 있다.

## Lazy Loading

### Lazy Loading이란

**Lazy Loading**(지연 로딩)은 연관된 엔티티를 실제로 사용하는 시점에 데이터베이스에서 조회하는 방식으로, 엔티티를 처음 로드할 때는 연관 엔티티 대신 프록시 객체를 주입하고, 해당 프록시 객체의 메서드를 호출할 때 실제 데이터베이스 쿼리를 실행하여 데이터를 가져온다.

### 프록시 객체의 동작 원리

Lazy Loading은 프록시 객체를 통해 구현되며, 프록시 객체는 실제 엔티티 클래스를 상속받아 Hibernate가 런타임에 동적으로 생성하는 가짜 객체로, 실제 엔티티와 동일한 인터페이스를 제공하면서도 내부적으로는 데이터베이스 쿼리 실행을 지연시키는 역할을 한다.

프록시 객체는 내부에 실제 엔티티 객체를 참조하는 target 필드를 가지고 있으며, 초기에는 이 target이 null 상태로 유지되다가, 프록시 객체의 메서드(getId() 제외)가 호출되면 그때 비로소 데이터베이스 쿼리를 실행하여 실제 엔티티를 조회하고 target 필드에 할당하는 초기화(initialization) 과정을 거친다. 이러한 프록시 초기화는 영속성 컨텍스트가 활성화된 상태에서만 가능하며, 트랜잭션이 종료되어 영속성 컨텍스트가 닫힌 후에 프록시를 초기화하려고 하면 LazyInitializationException이 발생한다.

실제 엔티티와 프록시 객체는 겉보기에는 동일해 보이지만, instanceof 연산이나 getClass() 메서드를 사용할 때 차이가 드러나므로, 엔티티 비교 시에는 반드시 equals() 메서드를 사용해야 하며, 프록시 여부를 확인하려면 Hibernate.isInitialized() 메서드나 PersistenceUnitUtil.isLoaded() 메서드를 활용할 수 있다.

### 특징

-   연관된 데이터를 바로 가져오지 않고, 실제로 사용할 때 가져온다.
-   성능 최적화와 메모리 사용량을 줄이기 위해 사용된다.
-   연관된 엔티티가 많은 경우 초기 로딩 시간이 단축된다.
-   영속성 컨텍스트가 활성화된 상태에서만 프록시 초기화가 가능하다.

### 예시

```java
@Entity
public class Member {
    @Id @GeneratedValue
    private Long id;

    @OneToMany(fetch = FetchType.LAZY, mappedBy = "member")
    private List<Order> orders;
}
```

### 장점

-   초기 로딩 시간이 단축된다.
-   연관된 엔티티가 많은 경우 메모리 사용량을 줄일 수 있다.
-   필요한 데이터만 선택적으로 로딩하여 네트워크 트래픽을 줄인다.

### 단점

-   연관된 엔티티를 사용할 때마다 쿼리가 실행되어 N+1 문제가 발생할 수 있다.
-   트랜잭션 범위 밖에서 프록시를 사용하면 LazyInitializationException이 발생한다.

## Eager Loading

### Eager Loading이란

**Eager Loading**(즉시 로딩)은 엔티티를 조회할 때 연관된 엔티티를 함께 조인하여 한 번의 쿼리로 모든 데이터를 로딩하는 방식으로, 프록시를 사용하지 않고 실제 엔티티 객체를 즉시 초기화하여 영속성 컨텍스트에 저장한다.

### 특징

-   연관된 데이터를 한꺼번에 가져온다.
-   연관된 엔티티를 사용할 때 추가로 쿼리를 실행하지 않아도 된다.
-   프록시가 아닌 실제 엔티티 객체가 즉시 로딩된다.

### 예시

```java
@Entity
public class Member {
    @Id @GeneratedValue
    private Long id;

    @OneToMany(fetch = FetchType.EAGER, mappedBy = "member")
    private List<Order> orders;
}
```

### 장점

-   연관된 엔티티를 사용할 때 추가로 쿼리를 실행하지 않아도 된다.
-   LazyInitializationException이 발생하지 않는다.

### 단점

-   초기 로딩 시간이 길어질 수 있다.
-   연관된 엔티티가 많은 경우 메모리 사용량이 증가할 수 있다.
-   사용하지 않는 데이터까지 로딩하여 성능 낭비가 발생할 수 있다.
-   JPQL을 사용할 경우 Eager Loading도 N+1 문제가 발생할 수 있다.

## N+1 문제 상세 설명

### N+1 문제란

N+1 문제는 연관 엔티티를 조회할 때 최초 쿼리 1번과 연관된 엔티티를 조회하는 쿼리 N번이 추가로 실행되어 총 N+1번의 쿼리가 발생하는 성능 문제로, 예를 들어 10개의 회원을 조회하고 각 회원의 주문 목록을 조회하면 회원 조회 쿼리 1번과 각 회원별 주문 조회 쿼리 10번이 실행되어 총 11번의 쿼리가 발생한다.

### Lazy Loading에서 N+1 문제가 발생하는 이유

Lazy Loading은 연관 엔티티를 프록시로 가져오기 때문에 초기 조회 시에는 1번의 쿼리만 실행되지만, 반복문 등에서 각 엔티티의 연관 엔티티에 접근할 때마다 프록시 초기화를 위한 쿼리가 개별적으로 실행되어 결과적으로 N+1 문제가 발생한다.

```java
List<Member> members = em.createQuery("select m from Member m", Member.class)
    .getResultList();  // 쿼리 1번 실행

for (Member member : members) {
    List<Order> orders = member.getOrders();
    orders.size();  // 각 회원마다 쿼리 1번씩 추가 실행 (N번)
}
```

### Eager Loading에서도 N+1 문제가 발생하는 경우

Eager Loading을 사용하면 EntityManager.find() 메서드로 단건 조회할 때는 조인을 사용하여 한 번에 가져오지만, JPQL이나 Criteria API를 사용하여 여러 엔티티를 조회할 때는 먼저 JPQL 쿼리를 그대로 실행하고, 그 결과에서 Eager Loading으로 설정된 연관 엔티티를 발견하면 각각에 대해 추가 쿼리를 실행하여 N+1 문제가 발생한다.

### 실제 쿼리 로그 예제

```sql
-- 초기 회원 조회 쿼리 (1번)
SELECT * FROM member;

-- 각 회원별 주문 조회 쿼리 (N번)
SELECT * FROM orders WHERE member_id = 1;
SELECT * FROM orders WHERE member_id = 2;
SELECT * FROM orders WHERE member_id = 3;
...
```

## N+1 문제 해결 방법

### Fetch Join

JPQL의 join fetch 키워드를 사용하면 연관된 엔티티를 SQL 조인을 통해 한 번에 조회할 수 있으며, 이는 가장 일반적이고 효과적인 N+1 문제 해결 방법이다.

```java
List<Member> members = em.createQuery(
    "select m from Member m join fetch m.orders", Member.class)
    .getResultList();
```

fetch join은 SQL의 INNER JOIN이나 LEFT OUTER JOIN을 사용하여 연관 엔티티를 함께 조회하므로 쿼리가 1번만 실행되지만, 컬렉션 페치 조인 시 중복 결과가 발생할 수 있어 distinct 키워드를 함께 사용해야 하며, 페이징 API(setFirstResult, setMaxResults)와 함께 사용하면 경고 로그가 출력되고 메모리에서 페이징 처리가 되므로 주의해야 한다.

### @EntityGraph

@EntityGraph는 JPA 2.1에서 추가된 기능으로, 엔티티 조회 시점에 함께 로딩할 연관 엔티티를 선언적으로 지정할 수 있으며, JPQL 없이도 fetch join과 유사한 효과를 얻을 수 있다.

```java
public interface MemberRepository extends JpaRepository<Member, Long> {
    @EntityGraph(attributePaths = {"orders"})
    List<Member> findAll();

    @EntityGraph(attributePaths = {"orders", "orders.items"})
    @Query("select m from Member m")
    List<Member> findAllWithOrders();
}
```

@EntityGraph는 LEFT OUTER JOIN을 사용하여 연관 엔티티를 로딩하고, attributePaths에 여러 연관 엔티티를 지정할 수 있으며, @NamedEntityGraph와 조합하여 재사용 가능한 그래프를 정의할 수도 있지만, 복잡한 조건이나 동적 쿼리에는 fetch join이 더 적합하다.

### @BatchSize

@BatchSize는 지연 로딩 시 N+1 문제를 완화하기 위해 여러 프록시를 한 번에 초기화하는 배치 크기를 설정하는 방법으로, 개별 쿼리 대신 IN 절을 사용하여 여러 엔티티를 한 번에 조회한다.

```java
@Entity
public class Member {
    @Id @GeneratedValue
    private Long id;

    @BatchSize(size = 100)
    @OneToMany(mappedBy = "member")
    private List<Order> orders;
}
```

@BatchSize를 사용하면 프록시 초기화 시 지정된 크기만큼의 엔티티를 WHERE IN 절로 한 번에 조회하므로, 예를 들어 1000개의 회원이 있고 배치 크기가 100이면 회원 조회 1번 + 주문 조회 10번으로 총 11번의 쿼리가 실행되어 N+1 문제를 크게 완화할 수 있으며, 글로벌 설정으로 hibernate.default_batch_fetch_size를 사용하면 모든 엔티티에 일괄 적용할 수 있다.

### @Fetch(FetchMode.SUBSELECT)

Hibernate의 @Fetch 어노테이션에 FetchMode.SUBSELECT를 지정하면 연관 엔티티를 조회할 때 서브쿼리를 사용하여 한 번에 가져올 수 있으며, 이는 첫 번째 쿼리의 결과를 서브쿼리로 사용하여 연관 엔티티를 조회하는 방식이다.

```java
@Entity
public class Member {
    @Id @GeneratedValue
    private Long id;

    @OneToMany(mappedBy = "member")
    @Fetch(FetchMode.SUBSELECT)
    private List<Order> orders;
}
```

SUBSELECT 방식은 전체 결과 집합에 대해 한 번의 추가 쿼리만 실행하므로 N+1 문제를 해결할 수 있지만, 서브쿼리 성능이 좋지 않은 데이터베이스에서는 오히려 성능이 저하될 수 있고, 단건 조회에서는 효과가 없으며 여러 건을 조회할 때만 유용하다.

## FetchType 기본값

JPA는 연관관계 종류에 따라 다른 FetchType 기본값을 가지며, 이는 각 연관관계의 특성을 고려한 설계이다.

-   **@OneToOne**: EAGER (기본값) - 일대일 관계는 대부분 함께 사용되므로 즉시 로딩
-   **@ManyToOne**: EAGER (기본값) - 다대일 관계의 '일' 쪽은 단일 엔티티이므로 즉시 로딩
-   **@OneToMany**: LAZY (기본값) - 일대다 관계의 '다' 쪽은 컬렉션이므로 지연 로딩
-   **@ManyToMany**: LAZY (기본값) - 다대다 관계는 컬렉션이므로 지연 로딩

이러한 기본값 설계는 단일 엔티티(ToOne)는 조인 비용이 적고 함께 사용될 가능성이 높으므로 즉시 로딩하고, 컬렉션(ToMany)은 데이터 양이 많고 사용되지 않을 수 있으므로 지연 로딩하는 것이 합리적이라는 판단에 기반하지만, 실무에서는 모든 연관관계를 LAZY로 설정하고 필요한 경우에만 fetch join을 사용하는 것이 권장된다.

## 실전 권장사항

실무에서는 모든 연관관계에 FetchType.LAZY를 기본으로 사용하고, 특정 화면이나 API에서 연관 엔티티가 필요한 경우에만 fetch join이나 @EntityGraph를 사용하여 선택적으로 즉시 로딩하는 전략이 가장 효과적이며, EAGER는 예측하기 어려운 쿼리를 발생시키고 JPQL에서 N+1 문제를 일으키므로 가급적 사용하지 않는 것이 좋다.

Open Session In View(OSIV) 패턴은 영속성 컨텍스트를 뷰 레이어까지 열어두어 지연 로딩을 편리하게 사용할 수 있게 하지만, 데이터베이스 커넥션을 오랫동안 점유하여 실시간 트래픽이 많은 애플리케이션에서는 커넥션 부족 문제를 일으킬 수 있으므로, Spring Boot의 spring.jpa.open-in-view 옵션을 false로 설정하고 트랜잭션 내에서 필요한 데이터를 모두 로딩하는 방식을 권장한다.

트랜잭션 범위 밖에서 지연 로딩을 시도하면 LazyInitializationException이 발생하므로, 서비스 계층에서 트랜잭션 내에 fetch join이나 프록시 초기화를 통해 필요한 데이터를 미리 로딩하거나, DTO로 변환하여 뷰에 전달하는 방식으로 문제를 방지할 수 있으며, 이는 영속성 컨텍스트와 프레젠테이션 계층의 분리라는 관점에서도 바람직하다.

## 요약

-   **Lazy Loading**은 프록시를 사용하여 연관된 엔티티를 실제로 사용할 때 로딩하는 방식이다.
-   **Eager Loading**은 엔티티를 조회할 때 연관된 엔티티를 조인하여 함께 로딩하는 방식이다.
-   **N+1 문제**는 양쪽 모두에서 발생할 수 있으며, fetch join, @EntityGraph, @BatchSize 등으로 해결할 수 있다.
-   실무에서는 기본적으로 LAZY를 사용하고 필요한 경우에만 fetch join을 적용하는 것이 권장된다.
