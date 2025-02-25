---
title: "Spring Data JPA와 JPA의 차이점"
date: 2024-06-07T04:14:51+09:00
tags: ["spring", "jpa"]
draft: false
---

### JPA(Java Persistence API)

#### JPA란 무엇인가?

JPA는 자바 ORM(Object Relational Mapping) 기술에 대한 API 표준 명세이다. ORM이란 객체와 관계형 데이터베이스의 데이터를 자동으로 매핑해주는 기술이다. JPA는 이러한 ORM 기술을 사용하기 위한 인터페이스를 모아놓은 것이다. JPA를 사용하면 개발자는 객체 중심으로 개발을 할 수 있고, JPA가 이를 관계형 데이터베이스에 맞게 SQL을 대신 생성해서 실행해 준다.

#### JPA의 특징

-   **표준 명세**: JPA는 자바에서 ORM 기술을 구현하기 위한 표준 명세이다.
-   **객체 중심 개발**: JPA를 사용하면 개발자는 객체 중심으로 개발을 할 수 있다.
-   **SQL 자동 생성**: JPA는 개발자가 직접 SQL을 작성하지 않아도 SQL을 자동으로 생성해서 실행해 준다.
-   **구현체 필요**: JPA는 인터페이스이기 때문에 이를 구현한 구현체가 필요하다.

### Spring Data JPA

#### Spring Data JPA란 무엇인가?

Spring Data JPA는 스프링에서 JPA를 쉽게 사용할 수 있도록 도와주는 기술이다. JPA를 사용하기 위해서는 EntityManagerFactory, EntityManager, EntityTransaction 등 많은 설정이 필요한데, Spring Data JPA는 이러한 설정을 대신해준다. 또한 Spring Data JPA는 JPA를 사용하기 위한 다양한 기능을 제공한다.

#### Spring Data JPA의 특징

-   **간편한 설정**: Spring Data JPA는 JPA를 사용하기 위한 설정을 대신해준다.
-   **Repository 패턴**: 정해진 규칙에 따라 Repository 인터페이스에 메서드를 정의하면 메서드 이름에 따라 적합한 쿼리를 생성하는 구현체를 자동으로 생성해 준다.
-   **생산성 향상**: Spring Data JPA를 사용하면 개발자는 JPA를 쉽게 사용할 수 있고, 생산성을 향상할 수 있다.

### Spring Data JPA와 JPA의 차이점

-   **기능적 차이**: JPA는 자바 ORM 기술에 대한 API 표준 명세이고, Spring Data JPA는 스프링에서 JPA를 쉽게 사용할 수 있도록 도와주는 기술이다.
-   **설정 차이**: JPA를 사용하기 위해서는 EntityManagerFactory, EntityManager, EntityTransaction 등 많은 설정이 필요한데, Spring Data JPA는 이러한 설정을 대신해준다.
-   **개발 편의성**: Spring Data JPA를 사용하면 개발자는 JPA를 쉽게 사용할 수 있고, 생산성을 향상할 수 있다.

### 결론

JPA는 자바 ORM 기술에 대한 API 표준 명세이고, Spring Data JPA는 스프링에서 JPA를 쉽게 사용할 수 있도록 도와주는 기술이다. Spring Data JPA를 사용하면 JPA를 사용하기 위한 설정을 대신해주고, 개발자는 JPA를 쉽게 사용할 수 있고, 생산성을 향상할 수 있다.
