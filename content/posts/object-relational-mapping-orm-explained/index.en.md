---
title: "Object-Relational Mapping (ORM)"
date: 2024-05-15T16:40:07+09:00
tags: ["ORM", "Database", "JPA"]
description: "Object-relational mapping concepts and ORM framework principles."
draft: false
---

## History and Background of ORM

ORM (Object-Relational Mapping) is a technology that automatically maps objects in object-oriented programming languages to tables in relational databases. It emerged in the early 1990s as object-oriented programming became mainstream and was designed to address the Object-Relational Impedance Mismatch between objects and tables. The first commercial ORM tool was TOPLink (now Oracle TopLink), released in 1994 for Smalltalk environments and later ported to Java in 1996. That helped spread ORM concepts throughout the enterprise Java ecosystem.

Hibernate, developed by Gavin King in 2001, was an open-source ORM framework created to address the complexity and performance issues of EJB 2.x Entity Beans. Through declarative mapping and HQL (Hibernate Query Language), it significantly improved developer productivity and became the foundation for the JPA (Java Persistence API) standard. When JPA 1.0 was announced in 2006 as part of JSR 220, ORM became standardized. Implementations such as Hibernate, EclipseLink, and OpenJPA then provided a common interface, enabling vendor-independent persistence programming.

## Paradigm Mismatch Problem

Object-oriented programming and relational databases view data in fundamentally different ways. This gap is called the Object-Relational Impedance Mismatch. Object-oriented systems model the real world through inheritance, polymorphism, and encapsulation, expressing relationships through references between objects. In contrast, relational databases store data in tables and rows, express relationships through foreign keys and joins, and minimize data duplication through normalization.

### Inheritance Mismatch

Objects can naturally express inheritance hierarchies, but relational databases have no concept of inheritance. Inheritance must be simulated using strategies such as Single Table, Joined Table, or Table per Class. Each strategy has trade-offs and should be chosen based on the use case.

### Association Mismatch

In objects, bidirectional relationships require both objects to hold references to each other. In databases, however, a single foreign key is enough to support joins in both directions, creating a fundamental difference. Objects also traverse graphs with the dot operator, whereas SQL must define joins up front, which conflicts with the flexible way objects move through associations.

### Identity Mismatch

In Java, identity is determined by the == operator and equality by the equals() method, while database rows determine identity by primary key. If the same database row is queried twice, it can become two different instances from the object's perspective, causing == to return false. ORM solves this problem by ensuring that entities queried with the same identifier within the same transaction are always represented by the same instance through the first-level cache of the persistence context.

## Core Concepts of ORM

### Entity and Mapping

An Entity is a persistence object that corresponds to a database table, declared with the @Entity annotation. Table names, column names, and primary key generation strategies can be configured through annotations or XML. ORM reads this mapping metadata to automatically generate SQL at runtime, allowing developers to perform database operations without writing SQL directly.

```java
@Entity
@Table(name = "members")
public class Member {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "username", nullable = false, length = 50)
    private String username;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "team_id")
    private Team team;
}
```

### Persistence Context

The Persistence Context is a logical space for storing managed entities, implementing the Identity Map and Unit of Work patterns defined by Martin Fowler. Within the same transaction, repeated queries for the same entity return the cached instance from the first-level cache. At transaction commit time, Dirty Checking detects changed entities and synchronizes them with the database. It also improves efficiency with Write-behind, which collects SQL statements and executes them together.

### Association Mapping

ORM automatically converts references between objects into foreign key relationships in the database. Relationship types are specified with @ManyToOne, @OneToMany, @OneToOne, and @ManyToMany annotations. The owning side determines which side manages the foreign key. In bidirectional relationships, the mappedBy attribute sets up the inverse reference. Lazy Loading and Eager Loading strategies can be selected when traversing the object graph.

## Major ORM Frameworks

### Java Ecosystem

**Hibernate** has been the most widely used JPA implementation since its 2001 release, providing rich features like HQL, Criteria API, second-level cache, and batch processing. Most JPA standard features were first implemented in Hibernate before being included in the standard. **EclipseLink** is a JPA reference implementation based on TopLink donated by Oracle, with strengths in lightweight design and extensibility, serving as the default JPA implementation for Jakarta EE. **MyBatis** is technically a SQL Mapper rather than an ORM, where developers write SQL directly and map results to objects, suitable when complete control over SQL is needed.

### Python Ecosystem

**SQLAlchemy** is Python's representative ORM, released in 2005. It consists of two layers, Core (SQL Expression Language) and ORM, providing both low-level SQL control and high-level ORM abstraction. **Django ORM** is the ORM included in the Django web framework, following the Active Record pattern and tightly integrated with Django's Admin, Forms, and other components.

### JavaScript/TypeScript Ecosystem

**TypeORM** is an ORM for TypeScript and JavaScript that supports decorator-based entity definitions as well as both the Active Record and Data Mapper patterns. It was heavily influenced by Hibernate. **Prisma** is a next-generation ORM released in 2019 that automatically generates type-safe clients based on schema files, providing migration tools and a GUI data browser.

## Advantages of ORM

### Productivity Improvement

ORM automates repetitive data access code such as SQL writing, result mapping, and connection management, allowing developers to focus on business logic and reducing CRUD code volume by over 80%. It also lets data be handled in an object-oriented way, helping maintain consistency between the domain model and the data access layer.

### Database Independence

ORM abstracts database-specific SQL dialects, so application code does not need modification when changing databases from MySQL to PostgreSQL or Oracle to H2. By changing only the dialect setting in the configuration, ORM automatically generates SQL appropriate for the target database.

### Maintainability

When table structures change, only the entity class mappings usually need to be updated, so the affected code is easier to identify than when tracking down individual SQL statements. Using IDE refactoring features to rename entity fields also updates the referencing code automatically.

## Disadvantages and Considerations of ORM

### N+1 Problem

The N+1 problem is the most common performance issue in ORM, occurring when N additional queries are executed when accessing associated entities after querying N entities with 1 query. For example, querying 100 members and accessing each member's team information can result in 101 total queries: 1 member query and 100 team queries. This can be solved with Fetch Join, @EntityGraph, @BatchSize, and similar techniques.

### Limitations with Complex Queries

SQL generated by ORM has difficulty expressing complex statistical queries, window functions, and database-specific features. In such cases, using Native Query or combining ORM with SQL Mappers like MyBatis is often more practical. JPQL and Criteria API do not support all SQL features, making them unsuitable for complex analytical queries.

### Learning Curve

To use ORM effectively, developers must understand concepts such as persistence context, entity lifecycle, lazy loading, proxies, and transaction propagation. Using ORM without understanding its internal workings can lead to unexpected query generation or performance issues. ORM is not a replacement for SQL but an abstraction layer that operates on top of it, so understanding SQL is a prerequisite.

### Bulk Data Processing

ORM operates on an object-by-object basis, which can cause high memory usage or performance degradation when processing hundreds of thousands of records or more. During batch processing, flush() and clear() should be called periodically to empty the persistence context. For bulk INSERT or UPDATE operations, using JDBC batch or Native Query is more efficient.

## Conclusion

ORM began with TopLink in the 1990s, advanced through Hibernate in 2001, and became standardized with JPA in 2006. It addresses the mismatch between objects and relational databases while improving productivity through features such as the first-level cache, dirty checking, and write-behind. At the same time, issues like N+1 queries, limitations with complex SQL, and bulk data processing mean it works best when developers understand both ORM internals and the SQL underneath. Monitoring generated queries and optimizing them accordingly remains essential.
