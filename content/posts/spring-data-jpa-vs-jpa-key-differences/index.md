---
title: "Spring Data JPA와 JPA의 차이점"
date: 2024-06-07T04:14:51+09:00
tags: ["spring", "jpa"]
description: "JPA의 역사와 탄생 배경부터 Spring Data JPA의 Repository 패턴, 쿼리 메서드, QueryDSL 비교까지 정리"
draft: false
---

## JPA의 탄생 배경

JPA는 2006년 5월 11일 자바 커뮤니티 프로세스 JSR220을 통해 EJB 3.0 스펙의 일부로 처음 배포되었다. 기존 EJB의 엔티티 빈(Entity Bean)을 대체하기 위해 만들어진 기술이다.

### EJB의 한계와 Hibernate의 등장

EJB 2.x까지의 엔티티 빈은 복잡하고 무겁고 실용성이 떨어졌다. 2001년 Gavin King이 개발한 Hibernate 오픈소스 ORM이 등장하면서 엔티티 빈의 낮은 기술 수준을 대체할 수 있는 가볍고 실용적인 대안이 생겼다.

결국 자바 진영은 Hibernate를 기반으로 새로운 자바 ORM 기술 표준을 만들었고, 이것이 바로 JPA이다.

### JPA의 독립성

JPA는 EJB 3.0 스펙의 일부로 정의되었지만 EJB 컨테이너에 의존하지 않는다. EJB 환경뿐만 아니라 웹 모듈과 Java SE 클라이언트 어디서든 사용할 수 있다.

## JPA란 무엇인가

JPA(Java Persistence API)는 자바에서 ORM 기술을 사용하기 위한 API 표준 명세이다. 객체와 관계형 데이터베이스 간의 매핑을 자동으로 처리하는 인터페이스의 모음이다.

### JPA 구현체

JPA는 그 자체로는 인터페이스 집합일 뿐이고 실제 구현체가 필요하다.

대표적인 구현체는 다음과 같다.

- **Hibernate**: Red Hat에서 개발한 가장 널리 사용되는 JPA 구현체. JPA 표준 외에도 다양한 추가 기능을 제공하며 설정이 비교적 간단하고 커뮤니티가 활발하다.
- **EclipseLink**: Eclipse Foundation에서 개발한 구현체로 Jakarta Persistence의 공식 참조 구현체. 복잡한 관계형 데이터나 중첩된 일대다 및 다대다 연관관계를 더 잘 지원하고 JAXB 같은 다른 영속성 표준도 지원한다.
- **OpenJPA**: Apache 재단에서 관리하는 오픈소스 구현체.

JPA를 사용하면 개발자는 SQL을 직접 작성하지 않아도 객체 중심으로 개발할 수 있다. JPA가 자동으로 SQL을 생성하고 실행해 준다.

## Spring Data JPA란 무엇인가

Spring Data JPA는 Spring에서 JPA를 더 쉽게 사용할 수 있도록 도와주는 기술이다. JPA 위에 또 하나의 추상화 계층을 제공하여 개발자가 데이터베이스와 상호작용하는 방식을 더 선언적이고 보일러플레이트가 적은 방식으로 만들어 준다.

### Repository 패턴

JPA를 사용하려면 EntityManagerFactory, EntityManager, EntityTransaction 등 많은 설정과 반복적인 코드가 필요하다. Spring Data JPA는 이런 설정과 반복 코드를 대신 처리해준다.

Spring Data JPA의 핵심은 Repository 패턴이다.

- 개발자가 인터페이스만 정의하면 Spring이 런타임에 자동으로 구현체를 생성
- CrudRepository와 JpaRepository 같은 인터페이스는 기본적인 CRUD 메서드, 페이징, 정렬 기능을 제공

## Spring Data JPA의 쿼리 작성 방식

Spring Data JPA는 세 가지 주요 쿼리 작성 방식을 제공한다.

### 쿼리 메서드 (Query Methods)

메서드 이름 규칙에 따라 자동으로 쿼리를 생성하는 방식이다.

장점은 다음과 같다.

- findByName, findByEmailAndStatus 같은 메서드 이름만으로 SELECT 쿼리를 생성
- IDE의 자동완성을 활용할 수 있음
- 컴파일 타임에 오류를 발견할 수 있음

### @Query 어노테이션

복잡한 쿼리나 메서드 이름으로 표현하기 어려운 조건을 JPQL 또는 네이티브 SQL로 직접 작성할 수 있다.

- bno > 0 같은 표현을 메서드 이름으로 만들기 어려울 때 유용
- JOIN이나 집계 함수가 필요한 경우 적합

### Specifications와 QueryDSL

동적 쿼리 작성에 사용된다.

#### Specifications

- JPA Criteria API 기반으로 술어(Predicate)를 조합하여 동적 쿼리를 만들 수 있음
- 코드 가독성이 떨어지고 작성에 많은 노력이 필요함

#### QueryDSL

- 타입 세이프한 방식으로 동적 쿼리를 작성할 수 있음
- BooleanExpression을 재사용할 수 있음
- IDE 자동완성을 지원하며 컴파일 타임에 쿼리를 검증하여 런타임 오류를 줄일 수 있음
- 복잡한 쿼리를 작성할 때 가독성과 유지보수성이 뛰어남

## EntityManager vs Repository

모든 Repository 호출은 결국 내부적으로 EntityManager에게 위임된다. Spring Data JPA Repository는 EntityManager 위에 구축된 고수준 추상화 계층이며 Repository 사용으로 인한 고유한 성능 저하는 없다.

### 내부 동작 메커니즘

Spring Data JPA는 JPA의 또 다른 추상화 계층이다. Hibernate 같은 구현체는 내부적으로 여전히 JDBC를 사용하지만 JPA와 EntityManager를 통해 동작한다.

### 성능 차이의 원인

성능 차이는 본질적인 오버헤드가 아니라 사용 패턴에서 발생한다.

- **배치 업데이트**: 기본 Repository 메서드로는 최적화 없이 매우 느림
- **1차 캐시**: 하나의 스레드에서 같은 데이터를 여러 번 조회, 수정, 삭제할 때만 유효
- **복잡한 쿼리**: 메서드 이름으로 표현하기 어렵기 때문에 직접 EntityManager를 사용하는 것이 더 적절할 수 있음

두 방식 모두 동일한 JPA 구현체를 사용하므로 성능은 일반적으로 비슷하다. 선택은 원시 성능 차이보다는 사용 사례의 복잡도와 코드 유지보수성에 따라 결정된다.

## 언제 무엇을 사용해야 하는가

### Spring Data JPA 사용

Spring Data JPA는 기본 CRUD 작업과 간단한 쿼리에 탁월하다. Repository 패턴을 통해 반복적인 코드를 제거하고 생산성을 크게 향상시킨다.

적합한 경우는 다음과 같다.

- 단순한 엔티티 저장, 조회, 삭제 작업
- 메서드 이름으로 표현 가능한 쿼리

### QueryDSL 사용

복잡한 JOIN, 필터링, 동적 조건이 포함된 고급 쿼리는 JPQL이나 Criteria API로 관리하기 어려워진다. 이때 QueryDSL을 사용하면 타입 세이프하고 가독성 높으며 유지보수 가능한 방식으로 쿼리를 작성할 수 있다.

적합한 경우는 다음과 같다.

- 페이징이 필요한 복잡한 쿼리
- 동적 조건이 많은 쿼리
- 인터페이스 스타일 쿼리 메서드로는 가독성이 떨어지는 복잡한 쿼리

### 조합 사용

Spring Data JPA에서 기본 CRUD 작업만 가져오고 모든 복잡한 쿼리는 QueryDSL을 사용하는 방식으로 조합할 수 있다. 같은 프로젝트에서 두 방식을 결합하여 사용하는 것이 가장 효율적이다.

## 결론

JPA는 2006년 EJB 3.0의 일부로 탄생한 자바 ORM 기술의 표준 명세이다. Hibernate를 기반으로 만들어져 객체 중심 개발과 SQL 자동 생성을 가능하게 한다.

Spring Data JPA는 JPA 위에 추가된 추상화 계층으로, Repository 패턴을 통해 설정과 반복 코드를 제거한다. 쿼리 메서드, @Query, Specifications, QueryDSL 등 다양한 쿼리 작성 방식을 제공하여 개발 생산성을 크게 향상시킨다.

간단한 작업에는 Spring Data JPA의 기본 기능을, 복잡한 동적 쿼리에는 QueryDSL을 조합하여 사용하는 것이 가장 효율적이다. EntityManager와 Repository는 동일한 JPA 구현체를 사용하므로 성능보다는 코드 유지보수성과 사용 사례 복잡도에 따라 선택하면 된다.
