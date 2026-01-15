---
title: "N+1 문제 알아보기"
date: 2024-06-08T02:17:46+09:00
tags: ["ORM", "java"]
draft: false
---

### N+1 문제란

**N+1 문제**는 ORM(Object-Relational Mapping)에서 자주 발생하는 성능 문제 중 하나로, 연관된 엔티티를 조회할 때 연관된 엔티티의 수(N)만큼 추가로 쿼리가 실행되어 결과적으로 쿼리의 수가 N+1개가 되는 문제이다. 이러한 쿼리의 수가 많아지면 데이터베이스와의 통신이 늘어나고 네트워크 왕복 시간이 증가하며 데이터베이스 커넥션 풀이 고갈될 위험이 있어 성능이 크게 저하될 수 있다.

### N+1 문제의 역사와 배경

N+1 문제는 ORM 프레임워크가 등장하면서 함께 나타난 고질적인 문제로, 특히 Hibernate와 JPA에서 지연 로딩(Lazy Loading) 전략을 사용할 때 자주 발생한다. ORM은 객체 지향적으로 데이터를 다루기 위해 연관된 엔티티를 필요할 때까지 로딩을 미루는 지연 로딩을 기본 전략으로 채택하고 있으며, 이는 불필요한 데이터 로딩을 방지하고 초기 로딩 속도를 개선하는 장점이 있다. 하지만 개발자가 연관 관계를 인지하지 못한 채 반복문 안에서 연관 엔티티에 접근하면 각 엔티티마다 개별 쿼리가 실행되어 N+1 문제가 발생하게 되고, 이는 Hibernate 초기 버전부터 현재까지 개발자들이 주의해야 할 핵심 성능 이슈로 남아있다.

### N+1 문제 발생 시나리오

#### 1:N 관계에서의 발생

가장 일반적인 경우로, 하나의 부모 엔티티가 여러 자식 엔티티를 가지는 1:N 관계에서 발생한다. 예를 들어 팀(Team)과 회원(Member)의 관계에서 팀 목록을 조회한 후 각 팀의 회원 목록에 접근하면 팀의 수만큼 추가 쿼리가 실행되며, 100개의 팀이 있다면 1개의 팀 조회 쿼리와 100개의 회원 조회 쿼리가 실행된다.

#### N:M 관계에서의 발생

다대다(N:M) 관계에서도 N+1 문제가 발생할 수 있으며, 학생(Student)과 수업(Course)의 관계처럼 중간 테이블을 통해 연결된 경우 학생 목록을 조회한 후 각 학생이 수강하는 수업 목록에 접근하면 학생의 수만큼 추가 쿼리가 실행된다.

#### 중첩된 연관관계에서의 발생

연관 관계가 여러 단계로 중첩된 경우(예: A -> B -> C) N+1 문제가 더욱 심각해질 수 있고, 예를 들어 부서(Department) -> 팀(Team) -> 회원(Member)의 관계에서 부서 목록을 조회한 후 각 부서의 팀과 각 팀의 회원에 접근하면 부서 수 + (부서 수 × 팀 수) + (부서 수 × 팀 수 × 회원 수)만큼의 쿼리가 실행될 수 있다.

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

### 성능 영향 분석

N+1 문제가 성능에 미치는 영향은 데이터의 양에 따라 기하급수적으로 증가한다. 예를 들어 100개의 회원을 조회하고 각 회원의 팀 정보에 접근하는 경우, 하나의 최적화된 조인 쿼리는 약 10ms가 걸리지만 101개의 개별 쿼리는 평균 5ms씩 걸려도 총 505ms가 소요되어 50배 이상의 성능 차이가 발생한다. 더욱 심각한 문제는 각 쿼리마다 데이터베이스 커넥션을 사용하고 네트워크 왕복 시간(RTT)이 발생하여 데이터베이스 커넥션 풀이 고갈될 수 있으며, 동시 사용자가 많은 환경에서는 다른 요청들이 커넥션을 획득하지 못해 대기하거나 타임아웃이 발생할 수 있다.

### 해결 방법

> Eager Loading으로 N+1 문제를 해결하려고 하면 모든 연관 관계를 항상 로딩하여 오히려 성능이 저하될 수 있다. 따라서 Fetch Join, Batch Fetch, EntityGraph 등을 사용하여 필요한 경우에만 선택적으로 해결하는 것이 좋다.

#### Fetch Join 상세

Fetch Join은 JPQL에서 제공하는 기능으로, 연관된 엔티티를 SQL 조인을 통해 한 번에 조회하는 방법이다. 일반 JOIN은 연관 엔티티를 실제로 로딩하지 않고 조건절에만 사용하지만, JOIN FETCH는 연관 엔티티를 즉시 로딩하여 영속성 컨텍스트에 함께 저장하며 추가 쿼리 없이 사용할 수 있다.

```java
@Query("SELECT m FROM Member m JOIN FETCH m.team")
List<Member> findAllWithTeam();
```

Fetch Join을 사용할 때 주의해야 할 점은 페이징과 함께 사용하면 메모리에서 페이징을 처리하여 성능 문제가 발생할 수 있고, 컬렉션을 Fetch Join할 때는 카테시안 곱으로 인해 중복 데이터가 발생할 수 있어 DISTINCT 키워드를 사용해야 하며, 둘 이상의 컬렉션을 Fetch Join하면 MultipleBagFetchException이 발생할 수 있어 하나의 컬렉션만 Fetch Join하고 나머지는 Batch Fetch를 사용해야 한다.

#### @BatchSize 상세

@BatchSize는 연관된 엔티티를 개별 쿼리로 조회하는 대신 IN 절을 사용하여 여러 개를 한 번에 조회하는 배치 처리 방식이다. 예를 들어 100개의 회원이 각각 다른 팀에 속해있고 BatchSize가 10으로 설정되어 있다면, 10개의 팀 ID를 묶어서 IN 절로 조회하여 총 1개의 회원 조회 쿼리와 10개의 팀 조회 쿼리가 실행된다.

```java
@Entity
public class Member {
    @ManyToOne(fetch = FetchType.LAZY)
    @BatchSize(size = 100)
    private Team team;
}
```

BatchSize는 개별 필드에 적용할 수도 있고, application.properties에서 hibernate.default_batch_fetch_size를 설정하여 전역적으로 적용할 수도 있다. 적절한 배치 크기는 데이터의 특성과 환경에 따라 다르지만, 일반적으로 10에서 1000 사이의 값을 사용하고 중간 크기인 50이나 100이 많이 사용되며, IN 절의 최대 길이 제한과 메모리 사용량을 고려하여 결정해야 한다.

#### @EntityGraph 상세

@EntityGraph는 JPA 2.1부터 지원되는 기능으로, 특정 쿼리에서 어떤 연관 관계를 함께 로딩할지 동적으로 지정할 수 있다. EntityGraph는 attributePaths 속성으로 함께 로딩할 속성을 지정하며, 여러 단계의 연관 관계는 점(.)으로 구분하여 표현할 수 있고, @NamedEntityGraph를 엔티티 클래스에 정의하여 재사용할 수도 있다.

```java
@EntityGraph(attributePaths = {"team"})
@Query("SELECT m FROM Member m")
List<Member> findAllWithTeam();
```

EntityGraph의 타입은 FETCH와 LOAD 두 가지가 있으며, FETCH 타입은 attributePaths에 명시한 속성은 EAGER로 로딩하고 나머지는 LAZY로 로딩하는 반면, LOAD 타입은 attributePaths에 명시한 속성은 EAGER로 로딩하고 나머지는 엔티티에 설정된 전략을 따른다.

#### DTO 직접 조회

JPQL의 new 키워드를 사용하여 필요한 데이터만 DTO로 직접 조회하는 방법도 있으며, 이 방법은 엔티티 그래프를 로딩하는 것이 아니라 필요한 컬럼만 SELECT하여 DTO에 담기 때문에 불필요한 데이터 로딩을 방지하고 메모리 사용량을 줄일 수 있다.

```java
@Query("SELECT new com.example.dto.MemberDto(m.id, m.name, t.name) " +
       "FROM Member m JOIN m.team t")
List<MemberDto> findAllMemberDto();
```

#### QueryDSL을 이용한 해결

QueryDSL은 타입 세이프한 쿼리 작성을 지원하는 프레임워크로, fetchJoin() 메서드를 사용하여 Fetch Join을 적용할 수 있고 복잡한 조건과 동적 쿼리를 작성할 때 JPQL보다 편리하며 컴파일 타임에 오류를 검증할 수 있다.

#### Native Query 사용

복잡한 조인이나 데이터베이스 특화 기능이 필요한 경우 Native Query를 사용하여 직접 SQL을 작성할 수 있으며, 이 방법은 ORM의 추상화를 포기하는 대신 최적화된 쿼리를 작성할 수 있고 데이터베이스의 모든 기능을 활용할 수 있다.

#### 읽기 전용 트랜잭션

@Transactional(readOnly = true)를 사용하면 Hibernate가 변경 감지를 위한 스냅샷을 생성하지 않아 메모리 사용량이 줄어들고, 데이터베이스에 따라 읽기 전용 최적화가 적용되어 성능이 향상될 수 있으며, 조회 전용 서비스 메서드에는 항상 이 옵션을 적용하는 것이 좋다.

### 실전 팁과 모니터링

#### Hibernate Statistics 활성화

Hibernate Statistics를 활성화하면 실행된 쿼리의 수, 커넥션 획득 시간, 엔티티 로딩 횟수 등 다양한 통계 정보를 수집할 수 있고, 이를 통해 N+1 문제가 발생하는지 파악하고 성능을 모니터링할 수 있다.

```properties
spring.jpa.properties.hibernate.generate_statistics=true
```

#### 쿼리 로그 확인

application.properties에서 show_sql과 format_sql을 활성화하면 실행되는 SQL을 콘솔에 출력하여 확인할 수 있고, 개발 환경에서는 항상 활성화하여 어떤 쿼리가 실행되는지 모니터링하는 것이 좋다.

```properties
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.use_sql_comments=true
```

#### p6spy를 이용한 쿼리 모니터링

p6spy는 JDBC 드라이버를 래핑하여 실행되는 모든 SQL과 바인딩 파라미터를 로깅하는 라이브러리로, 실제 실행되는 SQL을 파라미터가 바인딩된 상태로 확인할 수 있어 디버깅에 매우 유용하며, 쿼리 실행 시간도 함께 측정하여 성능 분석에 도움이 된다.

#### 프로파일링 도구 사용

운영 환경에서는 APM(Application Performance Monitoring) 도구나 데이터베이스 프로파일러를 사용하여 실시간으로 쿼리 성능을 모니터링하고, 느린 쿼리를 식별하여 최적화할 수 있으며, N+1 문제가 발생하는 지점을 빠르게 찾아낼 수 있다.

### 결론

N+1 문제는 ORM에서 지연 로딩과 연관 관계를 사용할 때 필연적으로 마주치는 성능 문제이며, 개발자가 이 문제를 인지하지 못하면 데이터가 증가함에 따라 성능이 기하급수적으로 저하될 수 있다. 하지만 Fetch Join, @BatchSize, @EntityGraph 등 다양한 해결 방법을 적절히 활용하면 효과적으로 문제를 해결할 수 있고, 쿼리 로깅과 모니터링 도구를 통해 지속적으로 성능을 관리하면 안정적인 애플리케이션을 운영할 수 있다.
