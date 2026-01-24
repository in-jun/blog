---
title: "JPA 1차 캐시와 2차 캐시"
date: 2024-06-08T03:39:05+09:00
tags: ["JPA", "ORM", "캐시"]
description: "JPA의 1차 캐시와 2차 캐시의 차이와 동작 방식을 설명한다."
draft: false
---

## Hibernate 캐시 아키텍처의 역사와 개념

Hibernate는 2001년 Gavin King이 처음 개발할 때부터 성능 최적화를 위한 캐싱 메커니즘을 핵심 기능으로 설계했으며, 이후 Hibernate의 캐시 아키텍처는 1차 캐시(First-Level Cache)와 2차 캐시(Second-Level Cache)라는 두 단계의 계층 구조로 발전하여 데이터베이스 접근을 최소화하고 애플리케이션 성능을 극대화하는 방향으로 진화해왔다. 1차 캐시는 Session(현재의 EntityManager)과 함께 Hibernate 초기 버전부터 존재한 필수 기능으로, 영속성 컨텍스트 자체가 1차 캐시 역할을 하며 트랜잭션 내에서 엔티티의 동일성을 보장하고 변경 감지(Dirty Checking)의 기반이 된다.

2차 캐시는 Hibernate 2.x 버전(2003년경)에서 선택적 기능으로 처음 도입되었으며, 2009년 JPA 2.0 명세에서 공유 캐시(Shared Cache)라는 이름으로 표준화되어 모든 JPA 구현체에서 일관된 방식으로 사용할 수 있게 되었다. Hibernate는 2차 캐시 구현을 직접 제공하지 않고 SPI(Service Provider Interface)를 통해 EhCache, Infinispan, Hazelcast 같은 외부 캐시 제공자를 플러그인 방식으로 통합하는 아키텍처를 채택했는데, 이 설계 덕분에 사용자는 애플리케이션 요구사항에 맞는 최적의 캐시 솔루션을 선택할 수 있다.

캐시 계층 구조의 핵심 원리는 데이터에 가까울수록 빠르다는 메모리 계층 구조(Memory Hierarchy) 개념에서 비롯되며, 1차 캐시는 개별 트랜잭션에 가장 가까운 계층으로 트랜잭션 내 반복 조회를 최적화하고, 2차 캐시는 애플리케이션 전체에서 공유되어 트랜잭션 간 데이터 재사용을 가능하게 한다.

## 1차 캐시의 동작 원리

### 1차 캐시의 구조와 생명주기

1차 캐시는 영속성 컨텍스트 내부에 Map 구조로 구현되어 있으며, 엔티티의 식별자(@Id)를 키로, 엔티티 인스턴스를 값으로 저장하여 동일한 식별자로 조회 시 데이터베이스에 접근하지 않고 즉시 캐시된 인스턴스를 반환할 수 있게 한다. 1차 캐시의 생명주기는 영속성 컨텍스트와 동일하여 트랜잭션이 시작되면 생성되고 트랜잭션이 종료되면 함께 소멸하며, 이러한 트랜잭션 범위(Transaction-Scoped) 특성 덕분에 서로 다른 트랜잭션 간의 데이터 격리가 자연스럽게 이루어진다.

1차 캐시는 JPA 명세의 필수 기능으로 모든 JPA 구현체에서 자동으로 활성화되며, 개발자가 명시적으로 비활성화하거나 설정할 수 있는 옵션이 아니다. EntityManager.find() 메서드가 호출되면 먼저 1차 캐시를 조회하고, 캐시에 해당 엔티티가 존재하면 데이터베이스 쿼리 없이 즉시 반환하며, 캐시에 없는 경우에만 SELECT 쿼리를 실행한 후 결과를 1차 캐시에 저장한다.

```java
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();

// 첫 번째 조회: DB에서 SELECT, 1차 캐시에 저장
User user1 = em.find(User.class, 1L);

// 두 번째 조회: 1차 캐시에서 즉시 반환, DB 접근 없음
User user2 = em.find(User.class, 1L);

System.out.println(user1 == user2); // true - 동일 인스턴스

em.getTransaction().commit();
```

### 동일성 보장과 Dirty Checking

1차 캐시의 핵심 기능 중 하나는 Identity Map 패턴을 구현하여 같은 트랜잭션 내에서 동일한 식별자로 조회한 엔티티는 항상 같은 객체 인스턴스를 반환하도록 보장하는 것으로, 이 특성 덕분에 애플리케이션 수준에서 REPEATABLE READ 트랜잭션 격리 수준을 제공할 수 있다. 또한 1차 캐시는 Dirty Checking의 기반이 되는데, 엔티티가 1차 캐시에 저장될 때 해당 시점의 스냅샷도 함께 저장되어 flush 시점에 현재 상태와 스냅샷을 비교하여 변경된 엔티티에 대해 자동으로 UPDATE 쿼리를 생성한다.

### 1차 캐시의 한계와 메모리 관리

1차 캐시는 트랜잭션 단위로 생성되고 소멸하므로 서로 다른 요청이나 트랜잭션 간에는 캐시가 공유되지 않아 애플리케이션 전체의 성능을 획기적으로 향상시키지는 못하며, 1차 캐시의 진정한 가치는 성능보다는 동일성 보장과 변경 감지를 위한 기반 메커니즘에 있다. 대량의 엔티티를 처리하는 배치 작업에서는 1차 캐시에 엔티티가 계속 쌓여 메모리 사용량이 증가하므로, 일정 개수마다 flush()와 clear()를 호출하여 영속성 컨텍스트를 비워주어야 OutOfMemoryError를 방지할 수 있다.

## 2차 캐시의 동작 원리

### 2차 캐시의 범위와 공유 메커니즘

2차 캐시는 SessionFactory 또는 EntityManagerFactory 수준에서 동작하여 애플리케이션 전체에서 공유되는 캐시로, 서로 다른 트랜잭션과 사용자 요청 간에 데이터를 재사용할 수 있어 데이터베이스 접근 횟수를 크게 줄일 수 있다. 1차 캐시가 트랜잭션 종료와 함께 소멸하는 것과 달리 2차 캐시는 애플리케이션이 종료되거나 명시적으로 제거될 때까지 유지되며, 엔티티가 조회되면 먼저 1차 캐시를 확인하고, 1차 캐시에 없으면 2차 캐시를 확인하고, 2차 캐시에도 없으면 데이터베이스에서 조회하는 3단계 조회 과정을 거친다.

2차 캐시는 동시성 문제를 방지하기 위해 엔티티 인스턴스를 직접 저장하지 않고 직렬화된 형태(Disassembled State)로 저장하며, 조회 시 역직렬화하여 새로운 인스턴스를 생성함으로써 한 세션에서의 변경이 다른 세션에 영향을 주지 않도록 격리한다. 이러한 직렬화/역직렬화 과정은 약간의 오버헤드가 발생하지만, 데이터베이스 접근 비용에 비하면 무시할 수 있는 수준이다.

### 2차 캐시 활성화와 설정

2차 캐시는 선택적 기능으로 기본적으로 비활성화되어 있으며, 사용하려면 캐시 제공자를 지정하고 어떤 엔티티를 캐싱할지 명시적으로 설정해야 한다. Spring Boot에서는 `spring.jpa.properties.hibernate.cache.use_second_level_cache=true`로 활성화하고, 엔티티 클래스에 @Cacheable과 Hibernate의 @Cache 어노테이션을 추가하여 개별 엔티티의 캐싱을 활성화한다.

```java
@Entity
@Cacheable // JPA 표준 어노테이션
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE, region = "users") // Hibernate 어노테이션
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    @Cache(usage = CacheConcurrencyStrategy.READ_WRITE) // 컬렉션 캐싱
    @OneToMany(mappedBy = "user")
    private List<Order> orders = new ArrayList<>();
}
```

## 2차 캐시 제공자 비교

### EhCache

EhCache는 2003년 Greg Luck이 처음 개발한 오픈소스 캐시 라이브러리로, Hibernate와 가장 오래되고 널리 사용되는 조합이며, 간단한 설정과 뛰어난 성능, 풍부한 기능을 제공한다. EhCache 3.x 버전부터는 JSR-107(JCache) 표준을 완전히 구현하여 벤더 종속성 없이 표준 API로 캐시를 사용할 수 있으며, Terracotta와 통합하여 분산 캐시로 확장할 수 있어 클러스터 환경에서도 사용 가능하다.

### Infinispan

Infinispan은 Red Hat이 개발한 오픈소스 분산 인메모리 데이터 그리드로, 2009년 JBoss Cache 프로젝트를 계승하여 출시되었으며, 클러스터 환경에서 뛰어난 확장성과 트랜잭션 지원이 강점이다. Infinispan은 복제(Replication) 모드와 분산(Distribution) 모드를 모두 지원하여 데이터 일관성과 확장성 간의 균형을 조절할 수 있으며, Wildfly와 JBoss EAP에 기본 내장되어 있어 Red Hat 기술 스택에서 자연스럽게 통합된다.

### Hazelcast

Hazelcast는 2008년에 설립된 Hazelcast Inc.에서 개발한 인메모리 데이터 그리드로, 클라우드 네이티브 환경에 최적화된 설계와 자동 클러스터 발견(Auto-Discovery) 기능이 특징이며, 분산 Map, Queue, Topic 등 다양한 분산 데이터 구조를 제공한다. Kubernetes와 AWS, Azure, GCP 같은 클라우드 환경에서 자동으로 클러스터를 구성하는 기능이 강점이며, Spring Boot와의 통합이 매우 간편하다.

## 캐시 동시성 전략

### READ_ONLY

READ_ONLY 전략은 절대 변경되지 않는 불변 데이터에 사용하며, 락이 전혀 필요 없어 가장 높은 성능을 제공하고 동시성 문제가 발생하지 않는다. 코드 테이블, 국가 목록, 통화 코드 같은 정적 참조 데이터에 적합하며, 만약 엔티티를 수정하려고 하면 Hibernate가 예외를 발생시켜 데이터 무결성을 보호한다.

### READ_WRITE

READ_WRITE 전략은 읽기와 쓰기가 모두 발생하는 데이터에 사용하며, soft lock을 사용하여 동시성을 제어하고 엔티티가 수정될 때 캐시 항목을 무효화하여 데이터 일관성을 보장한다. 대부분의 일반적인 비즈니스 엔티티에 적합하며, EhCache, Infinispan, Hazelcast 등 주요 캐시 제공자에서 모두 지원한다.

### NONSTRICT_READ_WRITE

NONSTRICT_READ_WRITE 전략은 동시에 같은 엔티티를 수정할 가능성이 낮고 짧은 시간 동안의 stale 데이터를 허용할 수 있는 경우에 사용하며, 락을 사용하지 않아 READ_WRITE보다 성능이 좋지만 eventual consistency만 보장한다. 업데이트 빈도가 낮은 설정 데이터나 통계 정보 같은 곳에 적합하다.

### TRANSACTIONAL

TRANSACTIONAL 전략은 완전한 트랜잭션 격리를 제공하며 JTA 트랜잭션과 통합되어 2단계 커밋(Two-Phase Commit)을 지원하는 가장 강력한 일관성을 보장하는 전략이다. 성능 오버헤드가 크고 Infinispan 같은 트랜잭션을 지원하는 캐시 제공자에서만 사용 가능하며, 분산 트랜잭션이 필수인 엔터프라이즈 환경에서 사용한다.

## 쿼리 캐시

쿼리 캐시는 JPQL이나 Criteria API 쿼리의 결과를 캐싱하는 기능으로, 2차 캐시와 함께 사용해야 효과적이며 `spring.jpa.properties.hibernate.cache.use_query_cache=true`로 활성화한다. 쿼리 캐시는 쿼리 문자열과 파라미터를 키로, 결과 엔티티의 식별자 목록을 값으로 저장하며, 실제 엔티티 데이터는 2차 캐시에서 가져오므로 엔티티 캐싱과 함께 사용해야 한다.

쿼리 캐시의 주의점은 관련 테이블이 변경되면 해당 테이블을 참조하는 모든 쿼리 캐시가 무효화된다는 것으로, 자주 변경되는 테이블에 대한 쿼리를 캐싱하면 무효화가 빈번하게 발생하여 오히려 성능이 저하될 수 있다. 따라서 쿼리 캐시는 변경이 드문 데이터에 대한 자주 실행되는 쿼리에만 선택적으로 적용해야 한다.

## 분산 환경에서의 캐시 동기화

### 로컬 캐시의 한계

단일 서버 환경에서는 로컬 캐시만으로 충분하지만, 여러 서버 인스턴스가 실행되는 분산 환경에서는 한 서버에서 데이터를 수정해도 다른 서버의 캐시는 여전히 이전 데이터를 가지고 있어 캐시 불일치(Cache Inconsistency) 문제가 발생한다. 이 문제는 사용자가 서로 다른 서버에 요청할 때 일관되지 않은 데이터를 보게 되는 심각한 문제로 이어질 수 있다.

### 분산 캐시 솔루션

Infinispan이나 Hazelcast 같은 분산 캐시 제공자를 사용하면 클러스터의 모든 노드 간에 캐시를 동기화할 수 있으며, 복제(Replication) 모드는 모든 노드가 전체 캐시의 복사본을 가지고, 분산(Distribution) 모드는 캐시 항목이 여러 노드에 분산 저장된다. 복제 모드는 읽기 성능이 뛰어나지만 메모리 사용량이 크고, 분산 모드는 메모리 효율적이지만 네트워크 호출이 필요하여 상황에 맞게 선택해야 한다.

### Eventual Consistency 고려

분산 캐시에서도 네트워크 지연으로 인해 짧은 시간 동안 노드 간 데이터 불일치가 발생할 수 있으며, 이를 eventual consistency라고 한다. 강한 일관성(Strong Consistency)이 필수적인 경우 TRANSACTIONAL 전략이나 분산 락을 사용해야 하지만, 대부분의 웹 애플리케이션에서는 짧은 시간의 stale 데이터를 허용하는 eventual consistency로 충분하다.

## 캐시 모니터링과 최적화

### 캐시 통계 활용

Hibernate는 캐시 히트율, 미스율, 저장 횟수, 제거 횟수 등의 통계를 제공하며, `spring.jpa.properties.hibernate.generate_statistics=true`로 활성화하면 SessionFactory.getStatistics()를 통해 조회할 수 있다. 히트율이 낮다면 캐싱 대상 선정이 잘못되었거나 캐시 크기가 작아 조기 제거가 발생하는 것이므로 설정을 재검토해야 한다.

### 캐시 적용 대상 선정

2차 캐시는 자주 읽히지만 드물게 변경되는 데이터에만 적용해야 효과적이며, 자주 변경되는 데이터를 캐싱하면 캐시 무효화 오버헤드가 이점보다 커질 수 있다. 코드 테이블, 권한 정보, 카테고리 같은 참조 데이터가 2차 캐시의 대표적인 적용 대상이며, 주문이나 결제 같은 트랜잭션 데이터는 대부분 캐싱 대상에서 제외하는 것이 좋다.

## 결론

Hibernate의 캐시 아키텍처는 1차 캐시와 2차 캐시라는 두 단계로 구성되어 있으며, 1차 캐시는 트랜잭션 범위에서 동작하는 필수 기능으로 영속성 컨텍스트 자체가 1차 캐시 역할을 하고 동일성 보장과 변경 감지의 기반이 된다. 2차 캐시는 애플리케이션 전체에서 공유되는 선택적 기능으로 EhCache, Infinispan, Hazelcast 같은 외부 제공자를 통해 구현되며, READ_ONLY, READ_WRITE, NONSTRICT_READ_WRITE, TRANSACTIONAL 네 가지 동시성 전략 중 데이터 특성에 맞는 것을 선택해야 한다. 분산 환경에서는 캐시 동기화 문제를 고려하여 분산 캐시 제공자를 사용하고, 캐시 통계를 모니터링하여 적절한 대상에만 캐싱을 적용하는 것이 성능 최적화의 핵심이다.
