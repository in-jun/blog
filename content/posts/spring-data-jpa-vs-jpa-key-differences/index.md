---
title: "Spring Data JPA와 JPA 주요 차이점"
date: 2024-06-07T04:14:51+09:00
tags: ["Spring", "JPA", "ORM"]
description: "JPA와 Spring Data JPA의 차이점을 설명한다."
draft: false
---

## JPA의 탄생 배경과 역사

JPA(Java Persistence API)는 2006년 5월 11일 자바 커뮤니티 프로세스 JSR 220을 통해 EJB 3.0 스펙의 일부로 처음 발표되었으며, 기존 EJB 2.x의 엔티티 빈(Entity Bean)이 가진 복잡성과 무거운 구조, 컨테이너 의존성 등의 문제를 해결하기 위해 Hibernate의 핵심 개념들을 표준화한 것이다. EJB 2.x의 엔티티 빈은 홈 인터페이스(Home Interface), 원격 인터페이스(Remote Interface), 빈 클래스(Bean Class)를 모두 작성해야 하고 복잡한 XML 디스크립터를 관리해야 했으며, 이로 인해 개발 생산성이 크게 떨어지고 테스트가 어려웠다.

2001년 Gavin King이 개발한 Hibernate는 POJO(Plain Old Java Object) 기반의 가볍고 실용적인 ORM 프레임워크로, 객체와 테이블 간의 매핑을 어노테이션이나 XML로 간단히 정의하고 SQL 생성을 자동화하며 영속성 컨텍스트를 통해 객체의 상태를 추적하는 기능을 제공했다. Hibernate의 성공으로 자바 진영은 이를 표준화하기로 결정했고, JPA 1.0(2006년), JPA 2.0(2009년, Criteria API 추가), JPA 2.1(2013년, 저장 프로시저 지원), JPA 2.2(2017년, 스트리밍 결과, LocalDate 지원)를 거쳐 발전해왔으며, 2019년 Java EE가 Eclipse Foundation으로 이관되면서 Jakarta Persistence라는 이름으로 변경되었다.

JPA는 EJB 3.0 스펙의 일부로 정의되었지만 EJB 컨테이너에 의존하지 않도록 설계되어 Java SE 환경, 웹 애플리케이션, 마이크로서비스 등 어디서든 사용할 수 있으며, 이러한 독립성은 Spring Framework와의 통합을 가능하게 했고 Spring Data JPA의 탄생 배경이 되었다.

## JPA의 핵심 개념

JPA는 자바에서 ORM(Object-Relational Mapping) 기술을 사용하기 위한 API 표준 명세로, 객체 지향 프로그래밍의 클래스와 관계형 데이터베이스의 테이블 사이의 불일치(Object-Relational Impedance Mismatch)를 해결하기 위해 설계되었다. 개발자는 SQL을 직접 작성하지 않고 객체 중심으로 개발할 수 있으며, JPA가 런타임에 엔티티의 상태 변화를 감지하여 적절한 SQL을 자동으로 생성하고 실행한다.

### JPA 구현체 비교

JPA는 인터페이스의 집합이므로 실제 동작을 위해서는 구현체가 필요하며, 대표적인 구현체들은 각각의 특성과 장단점을 가지고 있다.

Hibernate는 Red Hat에서 개발하고 유지보수하는 가장 널리 사용되는 JPA 구현체로, JPA 표준 외에도 다양한 추가 기능을 제공하며 방대한 커뮤니티와 풍부한 문서화로 문제 해결이 용이하고, @Where, @Formula, @BatchSize 같은 Hibernate 전용 어노테이션을 통해 JPA만으로는 어려운 기능을 구현할 수 있다. EclipseLink는 Eclipse Foundation에서 개발한 구현체로 Jakarta Persistence의 공식 참조 구현체(Reference Implementation)이며, 복잡한 관계형 데이터나 중첩된 연관관계를 Hibernate보다 더 잘 지원하고 JAXB, JSON-B 같은 다른 Java EE 표준과의 통합이 뛰어나다. Apache OpenJPA는 Apache 재단에서 관리하는 오픈소스 구현체로 Apache 생태계와의 통합에 강점이 있지만 Hibernate나 EclipseLink에 비해 사용률이 낮다.

### 영속성 컨텍스트와 EntityManager

JPA의 핵심은 영속성 컨텍스트(Persistence Context)와 이를 관리하는 EntityManager로, 영속성 컨텍스트는 엔티티를 영구 저장하는 논리적 공간이며 1차 캐시, 변경 감지(Dirty Checking), 지연 로딩(Lazy Loading), 쓰기 지연(Write-Behind) 등의 기능을 제공한다. EntityManager는 영속성 컨텍스트에 접근하기 위한 인터페이스로, persist(), find(), merge(), remove() 같은 메서드를 통해 엔티티의 생명주기를 관리하며, 트랜잭션 범위 내에서 동작하여 데이터 일관성을 보장한다.

```java
EntityManagerFactory emf = Persistence.createEntityManagerFactory("persistence-unit");
EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();

tx.begin();
User user = new User("홍길동", "hong@example.com");
em.persist(user); // 영속 상태로 전환
User found = em.find(User.class, user.getId()); // 1차 캐시에서 반환
found.setName("김철수"); // 변경 감지 - 자동 UPDATE
tx.commit(); // SQL 실행
```

## Spring Data JPA의 등장

Spring Data JPA는 2011년 Spring Data 프로젝트의 일부로 처음 발표되었으며, JPA를 사용할 때 필요한 EntityManagerFactory와 EntityManager 생성, 트랜잭션 관리, 반복적인 CRUD 코드 작성 등의 보일러플레이트를 제거하여 개발 생산성을 크게 향상시켰다. Spring Data 프로젝트는 JPA뿐만 아니라 MongoDB, Redis, Elasticsearch, Neo4j 등 다양한 데이터 저장소에 대해 일관된 프로그래밍 모델을 제공하며, Spring Data JPA는 그중에서도 관계형 데이터베이스와 JPA에 특화된 모듈이다.

### Repository 패턴의 구현

Spring Data JPA의 핵심은 Repository 패턴으로, 개발자가 인터페이스만 정의하면 Spring이 런타임에 프록시 기반의 구현체를 자동으로 생성하며, 이 구현체는 내부적으로 EntityManager를 사용하여 데이터베이스와 상호작용한다. CrudRepository는 save(), findById(), findAll(), deleteById() 같은 기본적인 CRUD 메서드를 제공하고, JpaRepository는 CrudRepository를 확장하여 flush(), saveAndFlush(), 배치 삭제, 페이징과 정렬 기능을 추가로 제공한다.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // 기본 CRUD 메서드는 자동 제공
    // save(), findById(), findAll(), delete() 등
}

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;

    public User createUser(String name, String email) {
        User user = new User(name, email);
        return userRepository.save(user); // EntityManager.persist() 위임
    }
}
```

## 쿼리 작성 방식 비교

### 쿼리 메서드 (Query Methods)

쿼리 메서드는 Spring Data JPA의 가장 강력한 기능 중 하나로, 메서드 이름의 규칙에 따라 자동으로 JPQL 쿼리를 생성하며, findBy, countBy, existsBy, deleteBy 같은 접두사와 엔티티의 필드명, And/Or 같은 논리 연산자, Between/LessThan/GreaterThan/Like/In/OrderBy 같은 키워드를 조합하여 다양한 쿼리를 표현할 수 있다. 컴파일 타임에 메서드 이름의 유효성을 검증하므로 오타나 잘못된 필드명 사용 시 즉시 오류를 발견할 수 있고, IDE의 자동완성 기능을 활용할 수 있어 개발 생산성이 높다.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // SELECT * FROM user WHERE name = ?
    List<User> findByName(String name);

    // SELECT * FROM user WHERE email = ? AND status = ?
    Optional<User> findByEmailAndStatus(String email, UserStatus status);

    // SELECT * FROM user WHERE created_at BETWEEN ? AND ? ORDER BY name ASC
    List<User> findByCreatedAtBetweenOrderByNameAsc(LocalDateTime start, LocalDateTime end);

    // SELECT COUNT(*) FROM user WHERE status = ?
    long countByStatus(UserStatus status);

    // SELECT EXISTS(SELECT 1 FROM user WHERE email = ?)
    boolean existsByEmail(String email);
}
```

### @Query 어노테이션

@Query 어노테이션은 메서드 이름으로 표현하기 어렵거나 복잡한 쿼리를 JPQL 또는 네이티브 SQL로 직접 작성할 수 있게 해주며, 특히 JOIN, 서브쿼리, 집계 함수, CASE 문 등이 필요한 경우에 유용하다. nativeQuery = true 옵션을 사용하면 데이터베이스에 특화된 SQL 문법을 사용할 수 있지만, 이 경우 데이터베이스 이식성이 떨어지므로 가급적 JPQL을 사용하는 것이 권장된다.

```java
public interface UserRepository extends JpaRepository<User, Long> {
    // JPQL 사용
    @Query("SELECT u FROM User u WHERE u.status = :status AND u.createdAt > :date")
    List<User> findActiveUsersAfter(@Param("status") UserStatus status,
                                    @Param("date") LocalDateTime date);

    // 집계 쿼리
    @Query("SELECT u.department, COUNT(u) FROM User u GROUP BY u.department")
    List<Object[]> countByDepartment();

    // 네이티브 SQL
    @Query(value = "SELECT * FROM users WHERE MATCH(name, bio) AGAINST(?1)",
           nativeQuery = true)
    List<User> fullTextSearch(String keyword);
}
```

### QueryDSL을 활용한 동적 쿼리

QueryDSL은 2008년 Timo Westkämper가 개발한 타입 세이프 쿼리 빌더 라이브러리로, JPA Criteria API의 복잡하고 가독성이 떨어지는 문제를 해결하기 위해 만들어졌으며, 컴파일 타임에 쿼리 문법을 검증하고 IDE 자동완성을 지원하여 런타임 오류를 크게 줄인다. QueryDSL은 APT(Annotation Processing Tool)를 사용하여 엔티티 클래스로부터 Q클래스를 자동 생성하며, 이 Q클래스를 사용하여 마치 SQL을 작성하듯이 자연스럽고 가독성 높은 쿼리를 작성할 수 있다.

동적 쿼리가 필요한 검색 기능에서 QueryDSL은 특히 강력한데, BooleanBuilder나 BooleanExpression을 사용하여 조건을 동적으로 조합할 수 있고, 조건이 null인 경우 해당 조건을 자동으로 무시하도록 구현할 수 있어 복잡한 if-else 분기 없이 깔끔한 코드를 작성할 수 있다.

```java
@Repository
@RequiredArgsConstructor
public class UserQueryRepository {
    private final JPAQueryFactory queryFactory;

    public List<User> searchUsers(UserSearchCondition condition) {
        return queryFactory
            .selectFrom(user)
            .where(
                nameContains(condition.getName()),
                statusEq(condition.getStatus()),
                createdAtBetween(condition.getStartDate(), condition.getEndDate())
            )
            .orderBy(user.createdAt.desc())
            .fetch();
    }

    private BooleanExpression nameContains(String name) {
        return StringUtils.hasText(name) ? user.name.contains(name) : null;
    }

    private BooleanExpression statusEq(UserStatus status) {
        return status != null ? user.status.eq(status) : null;
    }

    private BooleanExpression createdAtBetween(LocalDateTime start, LocalDateTime end) {
        if (start == null && end == null) return null;
        if (start == null) return user.createdAt.loe(end);
        if (end == null) return user.createdAt.goe(start);
        return user.createdAt.between(start, end);
    }
}
```

## EntityManager vs Repository 성능 비교

모든 Spring Data JPA Repository 호출은 최종적으로 EntityManager에게 위임되므로, Repository 사용으로 인한 고유한 성능 오버헤드는 사실상 없으며 두 방식 모두 동일한 JPA 구현체(대부분 Hibernate)를 사용하여 동일한 SQL을 생성한다. 성능 차이가 발생하는 경우는 대부분 사용 패턴의 차이에서 비롯되며, 특히 배치 처리, N+1 문제 해결, 프로젝션(Projection) 최적화 등에서 차이가 나타날 수 있다.

배치 업데이트의 경우 Repository의 기본 saveAll() 메서드는 각 엔티티마다 개별 INSERT/UPDATE 쿼리를 실행하므로 대량 데이터 처리에 비효율적이며, 이런 경우 @Modifying과 @Query를 사용한 벌크 연산이나 EntityManager를 직접 사용한 JDBC 배치 처리가 더 적합하다. 복잡한 쿼리나 데이터베이스 특화 기능이 필요한 경우에도 EntityManager와 네이티브 쿼리를 사용하는 것이 더 적절할 수 있으며, 이는 성능 차이가 아닌 기능적 요구사항의 문제이다.

## 선택 가이드

Spring Data JPA의 Repository와 쿼리 메서드는 단순한 CRUD 작업과 메서드 이름으로 표현 가능한 쿼리에 최적화되어 있으며, 대부분의 비즈니스 애플리케이션에서 80% 이상의 데이터 접근 로직을 처리할 수 있다. @Query 어노테이션은 JOIN, 집계, 서브쿼리 등 복잡한 쿼리가 필요하지만 동적 조건이 없는 경우에 적합하며, JPQL을 사용하면 데이터베이스 이식성을 유지할 수 있다.

QueryDSL은 검색 조건이 동적으로 변하는 복잡한 쿼리에 최적의 선택으로, 조건의 유무에 따라 쿼리가 달라져야 하거나 정렬 기준이 동적으로 변경되어야 하는 경우에 가독성과 유지보수성을 크게 향상시킨다. 실무에서는 이 세 가지 방식을 상황에 맞게 조합하여 사용하는 것이 가장 효율적이며, 간단한 조회는 쿼리 메서드로, 복잡한 정적 쿼리는 @Query로, 동적 쿼리는 QueryDSL로 처리하는 것이 권장된다.

## 결론

JPA는 2006년 Hibernate를 기반으로 탄생한 자바 ORM 표준으로, 객체 중심 개발과 SQL 자동 생성을 가능하게 하여 개발자가 비즈니스 로직에 집중할 수 있게 해주며, Spring Data JPA는 JPA 위에 Repository 패턴을 적용하여 보일러플레이트 코드를 제거하고 선언적인 데이터 접근을 가능하게 한다. 쿼리 메서드, @Query, QueryDSL은 각각의 강점이 있으므로 상황에 맞게 조합하여 사용해야 하며, 성능보다는 코드의 가독성과 유지보수성을 기준으로 적절한 방식을 선택하는 것이 중요하다.
