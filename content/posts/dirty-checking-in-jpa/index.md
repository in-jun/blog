---
title: "JPA Dirty Checking 변경 감지"
date: 2024-06-08T02:47:28+09:00
tags: ["JPA", "ORM", "Java"]
description: "JPA의 변경 감지 메커니즘인 Dirty Checking을 설명한다."
draft: false
---

## Dirty Checking의 개념과 역사

Dirty Checking은 Hibernate의 핵심 기능 중 하나로, 영속성 컨텍스트가 관리하는 엔티티의 변경 사항을 자동으로 감지해 데이터베이스에 반영하는 메커니즘이다. 이 개념은 2001년 Gavin King이 Hibernate를 처음 개발할 때 도입한 투명한 영속성(Transparent Persistence)의 핵심 구현체이기도 하다. 개발자는 명시적인 UPDATE 문을 작성하지 않아도 객체의 상태만 바꾸면 데이터베이스를 자동으로 갱신할 수 있다.

"Dirty"라는 용어는 데이터베이스 시스템에서 수정되었지만 아직 저장되지 않은 데이터를 가리키는 전통적인 표현이다. 즉, 메모리의 데이터가 디스크의 데이터와 일치하지 않는 상태를 뜻한다. Hibernate는 이 개념을 객체-관계 매핑에 적용해 엔티티 객체의 최초 로딩 상태와 현재 상태가 다른지를 감지한다. 이 기능은 2006년 JPA 1.0이 Hibernate의 개념을 표준화하면서 영속성 컨텍스트 명세의 일부로 포함되었고, 이후 모든 JPA 구현체가 지원해야 하는 기능이 되었다.

Dirty Checking이 해결하는 핵심 문제는 어떤 필드가 변경되었는지 개발자가 직접 추적하고, 그에 맞는 UPDATE 쿼리를 수동으로 작성해야 하는 부담을 없애는 데 있다. 객체지향 프로그래밍에서는 setter 메서드로 값을 바꾸면 되지만, 관계형 데이터베이스에서는 UPDATE 문이 필요하다. Dirty Checking은 이 패러다임 차이를 자동화로 메운다.

## 스냅샷 기반 변경 감지 원리

### 스냅샷 생성 메커니즘

Hibernate의 Dirty Checking은 스냅샷 비교 방식으로 동작한다. 엔티티가 영속성 컨텍스트에 처음 등록되면 해당 엔티티의 모든 필드 값을 복사해 별도의 스냅샷으로 저장한다. 이 스냅샷은 엔티티의 "깨끗한(Clean)" 상태, 즉 데이터베이스와 일치하는 최초 상태를 나타낸다. 스냅샷은 영속성 컨텍스트 내부의 Map 구조에 엔티티 식별자를 키로 저장되며, 실제로는 Object 배열 형태로 각 필드 값을 순서대로 보관한다.

스냅샷은 보통 두 시점에 생성된다. 첫째는 EntityManager.find()나 JPQL로 데이터베이스에서 엔티티를 조회할 때다. 둘째는 EntityManager.persist()로 새로운 엔티티를 영속화할 때다. merge()는 조금 다르게 동작한다. 준영속 엔티티의 값을 영속 엔티티에 복사한 뒤 새로운 스냅샷을 만들며, 이때 반환되는 객체는 새로 생성된 영속 상태의 엔티티다. 원본 준영속 엔티티는 그대로 준영속 상태를 유지한다.

### 필드 비교 과정

flush가 호출되면 Hibernate는 먼저 영속성 컨텍스트에 있는 모든 엔티티를 순회한다. 그리고 각 엔티티의 현재 상태와 스냅샷을 필드 단위로 비교한다. 이 비교에는 Java의 equals() 메서드를 그대로 쓰는 것이 아니라 Hibernate 내부의 타입별 비교 로직이 사용된다. 기본 타입은 == 연산자로, 객체 타입은 null 체크 후 equals()로 비교한다. 변경이 감지된 엔티티에는 "dirty" 플래그가 설정되고, 해당 엔티티에 대한 UPDATE 쿼리가 쓰기 지연 SQL 저장소에 등록된다.

```java
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();

User user = em.find(User.class, 1L); // 스냅샷 생성: {id=1, name="홍길동", email="hong@example.com"}
user.setName("김철수"); // 메모리 상태만 변경, 아직 DB 반영 안됨

// flush 시점: 현재 상태 {name="김철수"}와 스냅샷 {name="홍길동"} 비교
// name 필드 변경 감지 → UPDATE 쿼리 생성
em.getTransaction().commit(); // flush 자동 호출 → UPDATE user SET name='김철수' WHERE id=1
```

## Flush와 Dirty Checking의 관계

### Flush의 동작 원리

flush는 영속성 컨텍스트의 변경 내용을 데이터베이스에 동기화하는 작업이다. flush가 호출되면 먼저 Dirty Checking이 수행되어 변경된 엔티티를 찾는다. 그다음 쓰기 지연 SQL 저장소에 등록된 INSERT, UPDATE, DELETE 쿼리들이 데이터베이스로 전송된다. 중요한 점은 flush가 영속성 컨텍스트를 비우는 작업이 아니라는 것이다. flush는 변경 사항을 데이터베이스에 전송할 뿐이며, 실제 커밋은 트랜잭션이 종료될 때 이루어진다.

### Flush 발생 시점

flush가 자동으로 발생하는 시점은 세 가지다. 첫째는 트랜잭션 커밋 직전이다. 커밋 전에 변경 사항이 데이터베이스에 반영되어야 하기 때문이다. 둘째는 JPQL이나 Criteria API 쿼리 실행 직전이다. 쿼리가 최신 데이터를 조회하도록 보장하기 위해서다. 셋째는 EntityManager.flush()를 명시적으로 호출할 때다. 기본 FlushModeType은 AUTO이며, COMMIT으로 설정하면 커밋 시점에만 flush가 발생하고 JPQL 실행 전 자동 flush는 생략된다.

```java
em.getTransaction().begin();

User user = em.find(User.class, 1L);
user.setName("변경됨");

// JPQL 실행 전 자동 flush 발생
List<User> users = em.createQuery("SELECT u FROM User u", User.class).getResultList();
// 위 쿼리 결과에 user의 변경사항이 반영됨

em.getTransaction().commit();
```

## 기본 UPDATE 전략과 @DynamicUpdate

### 전체 필드 업데이트 전략

JPA의 기본 UPDATE 전략은 엔티티의 모든 필드를 포함하는 UPDATE 쿼리를 생성하는 방식이다. 예를 들어 10개 필드 중 1개만 변경되어도 10개 필드 전체를 SET하는 쿼리가 실행된다. 얼핏 비효율적으로 보일 수 있지만 이 방식에는 중요한 이점이 있다. UPDATE 쿼리의 형태가 항상 같으므로 애플리케이션은 PreparedStatement를 미리 생성해 캐싱할 수 있다. 데이터베이스도 동일한 쿼리에 대해 실행 계획을 재사용할 수 있어 파싱 오버헤드가 줄어든다.

### @DynamicUpdate 어노테이션

@DynamicUpdate는 Hibernate 전용 어노테이션이다. 엔티티 클래스에 적용하면 변경된 필드만 포함하는 UPDATE 쿼리를 동적으로 생성한다. 이를 위해 현재 상태와 스냅샷을 매번 비교해 변경된 컬럼만 찾아 쿼리를 구성한다. 다만 이 방식은 쿼리 문자열이 매번 달라지므로 PreparedStatement 캐싱의 이점을 잃고, 변경 필드 탐지와 쿼리 동적 생성에 따른 런타임 비용도 발생한다.

@DynamicUpdate는 엔티티에 수십 개 이상의 컬럼이 있고 그중 일부만 자주 변경될 때 효과적이다. 테이블에 TEXT나 BLOB 같은 대용량 컬럼이 있어 불필요한 전송을 피하고 싶을 때도 유용하다. 데이터베이스가 컬럼 수준 잠금(Column-level Locking)을 사용해 변경되지 않은 컬럼의 잠금 경합을 줄이고 싶을 때도 고려할 수 있다.

```java
@Entity
@DynamicUpdate // 변경된 필드만 UPDATE
public class Article {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @Lob
    private String content; // 대용량 필드

    private LocalDateTime updatedAt;
}

// title만 변경 시: UPDATE article SET title=?, updated_at=? WHERE id=?
// content는 UPDATE 대상에서 제외
```

## Dirty Checking이 작동하지 않는 경우

### 준영속 상태

Dirty Checking은 영속성 컨텍스트가 관리하는 영속 상태(Managed State)의 엔티티에만 작동한다. detach()로 분리되었거나, clear()로 영속성 컨텍스트가 초기화되었거나, close()로 EntityManager가 종료된 뒤의 엔티티는 준영속 상태가 되어 변경 감지 대상에서 제외된다. 준영속 엔티티를 다시 영속화하려면 merge()를 사용해야 한다. merge()는 준영속 엔티티의 값을 새로운 영속 엔티티에 복사하고, 그 영속 엔티티를 반환한다.

### 비영속 상태

new 키워드로 생성만 하고 persist()하지 않은 엔티티는 비영속 상태(Transient State)다. 이 상태의 엔티티는 영속성 컨텍스트와 전혀 관련이 없으므로 Dirty Checking 대상이 아니다. 따라서 이런 엔티티의 필드를 변경해도 데이터베이스에는 반영되지 않는다.

```java
User user = em.find(User.class, 1L); // 영속 상태
em.detach(user); // 준영속 상태로 전환

user.setName("변경"); // Dirty Checking 작동 안함, DB 반영 안됨

User merged = em.merge(user); // 새로운 영속 엔티티 반환
merged.setName("또 변경"); // 이제 Dirty Checking 작동
```

## 대량 데이터 처리 최적화

### Dirty Checking의 한계

대량의 엔티티를 수정해야 할 때 Dirty Checking은 각 엔티티마다 개별 UPDATE 쿼리를 생성한다. 만 건의 엔티티를 수정하면 만 개의 UPDATE 쿼리가 실행되므로 성능이 급격히 저하될 수 있다. 또한 영속성 컨텍스트에 많은 엔티티가 쌓이면 flush 시점의 스냅샷 비교 비용이 커지고 메모리 사용량도 늘어난다.

### JDBC 배치 설정

Hibernate의 JDBC 배치 기능을 활성화하면 여러 UPDATE 쿼리를 모아 한 번의 네트워크 왕복으로 전송할 수 있다. `hibernate.jdbc.batch_size`를 설정하고 `hibernate.order_updates`를 true로 두면 동일한 UPDATE 문을 연속 실행해 배치 효율을 높일 수 있다. @Version을 사용한 낙관적 잠금 환경에서는 `hibernate.jdbc.batch_versioned_data`를 true로 설정해야 배치 처리가 정상 동작한다.

### 벌크 연산 활용

가장 효과적인 방법은 JPQL이나 Criteria API의 벌크 연산을 사용하는 것이다. 단일 UPDATE 문으로 조건에 맞는 모든 레코드를 한 번에 수정할 수 있어 수만 건의 데이터도 하나의 쿼리로 처리할 수 있다. 다만 벌크 연산은 영속성 컨텍스트를 거치지 않고 직접 데이터베이스를 수정한다. 그래서 실행 후에는 영속성 컨텍스트의 엔티티 상태와 데이터베이스 상태가 어긋날 수 있다. 벌크 연산 뒤에는 clear()로 영속성 컨텍스트를 초기화하거나 필요한 엔티티를 다시 조회해야 한다.

```java
// 벌크 UPDATE - 영속성 컨텍스트 우회, 단일 쿼리로 대량 처리
@Modifying
@Query("UPDATE User u SET u.status = :status WHERE u.lastLoginAt < :date")
int bulkUpdateStatus(@Param("status") UserStatus status, @Param("date") LocalDateTime date);

// 사용 시
em.getTransaction().begin();
int count = userRepository.bulkUpdateStatus(UserStatus.INACTIVE, LocalDateTime.now().minusYears(1));
em.clear(); // 영속성 컨텍스트 초기화 필수
em.getTransaction().commit();
```

## 결론

Dirty Checking의 핵심은 개발자가 SQL을 직접 관리하지 않아도 엔티티 상태 변화만으로 데이터베이스 반영이 가능하다는 점이다. 이 기능은 영속성 컨텍스트의 스냅샷과 현재 상태를 비교해 flush 시점에 필요한 UPDATE 쿼리를 만든다. 기본적으로는 모든 필드를 업데이트하지만, 상황에 따라 @DynamicUpdate를 선택할 수 있다. 다만 대량 데이터 처리에서는 개별 UPDATE의 비용이 커지므로 JDBC 배치나 벌크 연산 같은 별도 최적화 전략을 함께 고려해야 한다. 무엇보다 Dirty Checking은 영속 상태의 엔티티에만 작동하므로, 엔티티 상태를 정확히 이해하는 것이 JPA를 안정적으로 사용하는 출발점이다.
