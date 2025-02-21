---
title: "Difference between Spring Data JPA and JPA"
date: 2024-06-07T04:14:51+09:00
tags: ["spring", "jpa"]
draft: false
---

### JPA (Java Persistence API)

#### What is JPA?

JPA, the Java Persistence API, is the standard specification for object-relational mapping (ORM) in Java. ORM allows automatic mapping between an object and a relational database. JPA is a collection of interfaces used for ORM. With JPA, developers can develop using object-oriented programming, and JPA will automatically generate the appropriate SQL for the relational database and execute it.

#### Features of JPA

-   **Standard specifications:** JPA is the standard specification for implementing ORM in Java.
-   **Object-oriented development:** With JPA, developers can write code using an object-oriented approach.
-   **Automatic SQL generation:** JPA automatically generates and executes SQL without requiring developers to write SQL statements.
-   **Implementation required:** JPA is an interface, so it requires an implementation.

## Spring Data JPA

### What is Spring Data JPA?

Spring Data JPA is a technology from Spring that makes it easier to use JPA. Using JPA requires many settings, such as `EntityManagerFactory`, `EntityManager`, and `EntityTransaction`, but Spring Data JPA handles these settings. Spring Data JPA also provides additional features to JPA.

### Features of Spring Data JPA

-   **Simplified setup:** Spring Data JPA handles the setup for JPA.
-   **Repository pattern:** By defining methods in the repository interface according to specific rules, Spring Data JPA automatically generates an implementation that generates the appropriate query based on the method name.
-   **Improved productivity:** Spring Data JPA helps developers use JPA more easily and efficiently.

### Difference between Spring Data JPA and JPA

-   **Functional difference:** JPA is a standard specification for ORM in Java, and Spring Data JPA is a technology that helps use JPA with Spring.
-   **Setup difference:** Using JPA requires many settings, such as `EntityManagerFactory`, `EntityManager`, and `EntityTransaction`, but Spring Data JPA handles these settings.
-   **Development convenience:** Spring Data JPA helps developers use JPA more easily and efficiently.

### Conclusion

JPA is a standard specification for ORM in Java, and Spring Data JPA is a technology in Spring that helps simplify the use of JPA. With Spring Data JPA, users can avoid complex setups and use JPA with increased ease and efficiency.
