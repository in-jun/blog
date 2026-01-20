---
title: "What is ORM (Object-Relational Mapping)?"
date: 2024-05-15T16:40:07+09:00
tags: ["orm", "jpa", "hibernate", "database"]
description: "ORM is a technology that solves paradigm mismatch between objects and relational databases, evolving from TopLink in the 1990s to JPA standard in 2006. It provides automatic mapping and persistence management but requires attention to performance issues like N+1 problem"
draft: false
---

## History and Background of ORM

ORM (Object-Relational Mapping) is a technology that automatically maps objects in object-oriented programming languages to tables in relational databases. It emerged in the early 1990s when object-oriented programming became mainstream, designed to solve the Object-Relational Impedance Mismatch between objects and tables. The first commercial ORM tool was TOPLink (now Oracle TopLink) in 1994, originally developed for Smalltalk environments before Java. It was later ported to Java in 1996, contributing to the spread of ORM concepts in the enterprise Java ecosystem.

Hibernate, developed by Gavin King in 2001, was an open-source ORM framework created to address the complexity and performance issues of EJB 2.x Entity Beans. Through declarative mapping and HQL (Hibernate Query Language), it significantly improved developer productivity and became the foundation for the JPA (Java Persistence API) standard. When JPA 1.0 was announced in 2006 as part of JSR 220, ORM became standardized. Various implementations like Hibernate, EclipseLink, and OpenJPA began providing the same interface, enabling vendor-independent persistence programming.

## Paradigm Mismatch Problem

Object-oriented programming and relational databases have fundamentally different perspectives on data, a difference called Object-Relational Impedance Mismatch. Object-orientation models the real world through inheritance, polymorphism, and encapsulation, expressing relationships through references between objects. In contrast, relational databases store data in tables and rows, express relationships through foreign keys and joins, and minimize data duplication through normalization.

### Inheritance Mismatch

Objects can naturally express inheritance hierarchies, but relational databases have no concept of inheritance. Inheritance must be simulated using strategies such as Single Table, Joined Table, or Table per Class. Each strategy has its pros and cons, requiring selection based on the situation.

### Association Mismatch

In objects, expressing bidirectional relationships through references requires both objects to reference each other. However, in databases, bidirectional joins are possible with a single foreign key, creating a fundamental difference. Additionally, objects traverse graphs using the dot operator, while SQL must specify which tables to join from the beginning, conflicting with objects' free traversal.

### Identity Mismatch

In Java, identity is determined by the == operator and equality by the equals() method, while database rows determine identity by primary key. When the same database row is queried twice, they become different instances from the object perspective, causing == comparison to return false. ORM solves this problem by ensuring that entities queried with the same identifier within the same transaction are always the same instance through the first-level cache of the persistence context.

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

The Persistence Context is a logical space for permanent entity storage, implementing the Identity Map pattern and Unit of Work pattern defined by Martin Fowler. The persistence context returns cached instances when querying the same entity within the same transaction through first-level cache. It automatically reflects changed entities to the database at transaction commit time through Dirty Checking. It optimizes database access by collecting and executing SQL at once through Write-behind.

### Association Mapping

ORM automatically converts references between objects into foreign key relationships in the database. Relationship types are specified with @ManyToOne, @OneToMany, @OneToOne, and @ManyToMany annotations. The owning side is set to determine which side manages the foreign key. In bidirectional relationships, the mappedBy attribute sets up the inverse reference. Lazy Loading and Eager Loading strategies can be selected when traversing the object graph.

## Major ORM Frameworks

### Java Ecosystem

**Hibernate** has been the most widely used JPA implementation since its 2001 release, providing rich features like HQL, Criteria API, second-level cache, and batch processing. Most JPA standard features were first implemented in Hibernate before being included in the standard. **EclipseLink** is a JPA reference implementation based on TopLink donated by Oracle, with strengths in lightweight design and extensibility, serving as the default JPA implementation for Jakarta EE. **MyBatis** is technically a SQL Mapper rather than an ORM, where developers write SQL directly and map results to objects, suitable when complete control over SQL is needed.

### Python Ecosystem

**SQLAlchemy** is Python's representative ORM released in 2005, consisting of two layers: Core (SQL Expression Language) and ORM, providing both low-level SQL control and high-level ORM abstraction. **Django ORM** is the ORM included in the Django web framework, following the Active Record pattern and tightly integrated with Django's Admin, Forms, and other components.

### JavaScript/TypeScript Ecosystem

**TypeORM** is an ORM supporting TypeScript and JavaScript, supporting both decorator-based entity definitions and Active Record and Data Mapper patterns, designed under Hibernate's influence. **Prisma** is a next-generation ORM released in 2019 that automatically generates type-safe clients based on schema files, providing migration tools and a GUI data browser.

## Advantages of ORM

### Productivity Improvement

ORM automates repetitive data access code such as SQL writing, result mapping, and connection management, allowing developers to focus on business logic and reducing CRUD code volume by over 80%. Additionally, data can be handled in an object-oriented manner, maintaining consistency between the domain model and data access layer.

### Database Independence

ORM abstracts database-specific SQL dialects, so application code doesn't need modification when changing databases from MySQL to PostgreSQL or Oracle to H2. By only changing the dialect in configuration files, ORM automatically generates SQL appropriate for the target database.

### Maintainability

When table structures change, only the entity class mappings need modification, making the scope of changes clearer than finding and modifying SQL individually. Using IDE refactoring features to rename entity fields automatically updates all referencing code.

## Disadvantages and Considerations of ORM

### N+1 Problem

The N+1 problem is the most common performance issue in ORM, occurring when N additional queries are executed when accessing associated entities after querying N entities with 1 query. For example, querying 100 members and accessing each member's team information can result in 101 total queries: 1 member query and 100 team queries. This can be solved with Fetch Join, @EntityGraph, @BatchSize, and similar techniques.

### Limitations with Complex Queries

SQL generated by ORM has difficulty expressing complex statistical queries, window functions, and database-specific features. In such cases, Native Query should be used or SQL Mappers like MyBatis should be employed alongside ORM. JPQL and Criteria API don't support all SQL features, making them unsuitable for complex analytical queries.

### Learning Curve

To effectively use ORM, developers must understand various concepts including persistence context, entity lifecycle, lazy loading, proxies, and transaction propagation. Using ORM without understanding its internal workings can lead to unexpected query generation or performance issues. ORM is not a replacement for SQL but an abstraction layer that operates on top of SQL, so understanding SQL is a prerequisite.

### Bulk Data Processing

ORM operates on an object-by-object basis, which can cause memory shortage or performance degradation when processing hundreds of thousands of records or more. During batch processing, flush() and clear() should be called periodically to empty the persistence context. For bulk INSERT or UPDATE operations, using JDBC batch or Native Query is more efficient.

## Conclusion

ORM is a technology that started with TopLink in the 1990s, evolved through Hibernate in 2001, and was standardized as JPA in 2006, solving paradigm mismatch between objects and relational databases while significantly improving development productivity. It provides features like first-level cache, dirty checking, and write-behind through the persistence context, enhancing database independence and maintainability. However, considerations such as N+1 problems, limitations with complex queries, and bulk data processing require understanding the internal workings and appropriate utilization based on the situation. Monitoring and optimizing queries generated by ORM based on SQL understanding is essential.
