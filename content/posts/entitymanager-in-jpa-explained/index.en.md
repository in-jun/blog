---
title: "What is EntityManager?"
date: 2024-06-07T19:12:36+09:00
tags: ["jpa", "entitymanager"]
description: "A comprehensive guide to EntityManager covering its role and lifecycle, key API methods (persist, find, merge, remove, etc.), transaction management, JPQL and Criteria API, persistence context management (first-level cache, write-behind, dirty checking), relationship with Spring Data JPA, and practical tips for handling large datasets and solving N+1 problems."
draft: false
---

> EntityManager is the core interface of JPA that manages the lifecycle of entities and handles all interactions between entities and the database through the persistence context.

## Role and Importance of EntityManager

EntityManager is an interface positioned at the center of the Java Persistence API (JPA) specification. It handles the mapping between entities in object-oriented programming and relational databases, enabling developers to perform database operations without writing SQL directly. JPA is a Java standard ORM (Object-Relational Mapping) technology that was first introduced as part of the EJB 3.0 specification in 2006. Since then, various implementations such as Hibernate, EclipseLink, and OpenJPA have emerged, establishing JPA as the de facto standard for data access layers in Java-based applications.

EntityManager manages a logical space called the persistence context, which is a kind of first-level cache that stores entity objects in a persistent state. It tracks entity states and detects changes between the application and the database. Through the persistence context, EntityManager provides powerful features such as guaranteeing identity for entities with the same identifier within the same transaction, minimizing database access, and automatically generating UPDATE queries through change detection.

EntityManager is necessary because it resolves the paradigm mismatch between domain models and relational databases, abstracts repetitive CRUD code, and automatically provides performance optimization features such as first-level cache and write-behind. Additionally, it allows writing queries in an object-oriented manner through JPQL and Criteria API, and enables vendor-independent code that minimizes application code changes when the database is switched.

## EntityManager Lifecycle

EntityManager is created from EntityManagerFactory. While EntityManagerFactory is created once and shared across the entire application, EntityManager is a lightweight object that is created per request and must be closed after use. EntityManagerFactory contains the database connection pool and metadata information and is very expensive to create, so it is created only once at application startup. EntityManager cannot be shared between threads, so a new instance must be created for each request.

The creation and management of EntityManager is divided into two approaches: Application-Managed and Container-Managed. The Application-Managed approach is where developers directly create and close EntityManager from EntityManagerFactory, primarily used in Java SE environments. The Container-Managed approach is where the container (Spring, Java EE) manages the lifecycle of EntityManager, commonly used in web applications.

In Spring environments, the `@PersistenceContext` annotation is used to inject a Container-Managed EntityManager. This is actually a proxy object that uses the actual EntityManager within the transaction scope and automatically calls close() when the transaction ends. On the other hand, the `@PersistenceUnit` annotation injects EntityManagerFactory, used when developers need to directly create and manage EntityManager. This is useful in situations requiring fine-grained transaction control, such as batch jobs or asynchronous processing.

## Detailed API Methods

### persist()

The `persist()` method saves a new entity to the persistence context and transitions it to a persistent state. When called, it does not immediately execute an INSERT query but registers the entity in the persistence context. The actual INSERT query is executed at transaction commit time. This is the write-behind (Transactional Write-Behind) feature that minimizes database access and improves performance when saving multiple entities at once.

### find()

The `find()` method is the most basic method for querying entities by their identifier. It first looks for the entity in the first-level cache of the persistence context and only executes a SELECT query to the database if not found. Due to first-level cache utilization, even if the same entity is queried multiple times within the same transaction, actual database access occurs only once. The queried entity is automatically managed in a persistent state.

### getReference()

The `getReference()` method returns a proxy object that delays database access. It operates in a lazy loading manner where the database query is executed when the actual entity's properties are accessed. This is used to prevent unnecessary database access when querying entities with relationships and to optimize performance by loading data only when needed.

### merge()

The `merge()` method converts a detached entity to a persistent state. It queries the database using the identifier of the passed entity, merges the values of the passed entity into the queried persistent entity, and returns the merged persistent entity. Note that the return value of merge() is a persistent entity, while the parameter entity remains in a detached state. It is more efficient to use the change detection feature, so when possible, it is recommended to find() and then modify rather than using merge().

### remove()

The `remove()` method deletes a persistent entity. It does not delete immediately upon call but marks the entity for deletion in the persistence context, and the DELETE query is executed at transaction commit time. The entity to be deleted must be in a persistent state. To delete a detached entity, you must first make it persistent with merge() or query it again with find() before calling remove().

### flush()

The `flush()` method immediately synchronizes changes in the persistence context to the database. It sends queries in the write-behind SQL store to the database at the current point without waiting for transaction commit. Calling flush() does not commit the transaction nor empty the persistence context. It is automatically called just before JPQL query execution to ensure data consistency. When processing large amounts of data, calling flush() and clear() together at regular intervals can control memory usage.

### clear()

The `clear()` method completely initializes the persistence context, making all managed entities detached. It is used to prevent memory shortage caused by too many entities accumulating in the first-level cache when processing large amounts of data. After calling clear(), previously queried entities are no longer managed by the persistence context, so their changes are not reflected in the database.

### detach()

The `detach()` method detaches only a specific entity from the persistence context, making it detached. Unlike clear() which detaches all entities, it can selectively detach a single entity. The detached entity is no longer subject to change detection, so modifying values does not reflect in the database. To make it persistent again, you must use merge().

## Transaction Management

EntityManager is designed to operate within transaction scope. All data modification operations must be performed within a transaction. Query operations are possible without transactions, but performing them within transactions is recommended to utilize the benefits of the persistence context. In Java SE environments, transactions are controlled directly through the EntityTransaction interface using begin(), commit(), and rollback() methods. In Spring environments, declarative transaction management is performed using the `@Transactional` annotation, automatically starting, committing, or rolling back transactions through AOP.

Transaction scope and EntityManager scope generally match. In Spring, when a method declared with `@Transactional` starts, the transaction and EntityManager are created. When the method ends, the transaction commits and EntityManager closes. At transaction commit time, flush() is automatically called to reflect changes in the persistence context to the database. The change detection (Dirty Checking) mechanism compares snapshots of persistent entities with their current state and automatically generates and executes UPDATE queries for changed fields.

## JPQL and Criteria API

EntityManager can execute JPQL (Java Persistence Query Language) through the `createQuery()` method. JPQL is an object-oriented query language that writes queries targeting entity objects. It is similar to SQL but targets entity classes and fields rather than tables. JPQL is database-independent, so queries do not need to be modified when the database changes. It can express joins concisely using entity relationships and can easily implement features such as paging and sorting.

```java
TypedQuery<User> query = em.createQuery(
    "SELECT u FROM User u WHERE u.age > :age", User.class);
query.setParameter("age", 20);
List<User> users = query.getResultList();
```

When native SQL is needed, the `createNativeQuery()` method can be used to directly execute database-specific SQL. This is useful when complex statistical queries or database-specific features are required. Criteria API is a type-safe query writing method using CriteriaBuilder. Unlike JPQL, which writes queries as strings, it writes queries in Java code, allowing error verification at compile time. It has the advantage of flexibly assembling queries according to conditions when writing dynamic queries, but it also has the disadvantage of complex code and reduced readability.

## Persistence Context Management

The first-level cache of the persistence context has a Map structure that uses the entity's identifier as the key and stores entity instances as values. When the same entity is queried multiple times with find() within the same transaction, the database is accessed only once initially, and subsequent queries retrieve from the first-level cache. The first-level cache is created when a transaction starts and disappears when the transaction ends. Unlike the second-level cache shared across the entire application, it has a very short lifecycle and does not cause concurrency issues.

Write-behind (Transactional Write-Behind) is a mechanism where data modification methods such as persist() or remove() do not immediately execute SQL when called but collect queries in the write-behind SQL store. At transaction commit time, flush() is called to send all queries to the database at once. This improves performance by reducing database communication frequency and can execute multiple INSERT queries in one batch using JDBC batch functionality.

Change detection (Dirty Checking) is a feature that automatically detects changes in persistent entities and generates UPDATE queries. Without developers explicitly calling methods like update(), simply changing values through setters automatically reflects the changes to the database at transaction commit time. EntityManager stores a snapshot of the initial state when storing entities in the persistence context. At flush() time, it compares the snapshot with the current entity and automatically generates UPDATE queries if there are changed fields.

Identity guarantee is a feature that ensures entities queried with the same identifier within the same transaction are always the same instance. Even if find() is called multiple times, == comparison returns true. This provides Repeatable Read level isolation at the application level, ensuring data consistency.

## Relationship with Spring Data JPA

Spring Data JPA's Repository interface is implemented internally using EntityManager. The SimpleJpaRepository class is the actual implementation where all CRUD methods operate through EntityManager. The save() method internally calls persist() if the entity is new and merge() if it already exists. findById() calls EntityManager's find(), and deleteById() calls find() followed by remove().

Cases requiring direct implementation of `@Repository` using EntityManager include when complex queries, bulk operations, or dynamic queries that are difficult to implement with Spring Data JPA's basic features are needed. In this case, EntityManager is injected with `@PersistenceContext` to write queries directly using JPQL or Criteria API. Spring Data JPA greatly improves development productivity by providing convenience features such as method name-based query generation, paging and sorting, and Auditing. However, using pure EntityManager allows more fine-grained control and deeper understanding of JPA's operating principles. Mixing both approaches according to the situation is common in practice.

## Practical Tips

When processing large amounts of data, handling thousands or more entities at once can cause memory shortage as all entities accumulate in the persistence context. It is essential to call flush() and clear() at regular intervals (e.g., every 100 entities) to empty the persistence context. Additionally, for batch processing, setting JDBC batch configuration (hibernate.jdbc.batch_size) to execute multiple INSERTs or UPDATEs in one batch can significantly improve performance.

The N+1 problem is a typical performance issue that occurs when querying entities with relationships. After querying N parent entities, queries to retrieve child entities are executed N additional times for each parent, resulting in a total of N+1 queries. To solve this, use JPQL's fetch join to query parents and children together in one query, use `@EntityGraph` to explicitly load necessary relationships, or set batch size (hibernate.default_batch_fetch_size) to query child entities bundled in an IN clause.

Proxy objects are fake objects for implementing lazy loading. They are used when lazy loading is configured with getReference() or `@ManyToOne(fetch = FetchType.LAZY)`. Since proxy objects are classes that inherit from the actual entity, instanceof should be used instead of == for type comparison. LazyInitializationException occurs when trying to initialize a proxy object after the persistence context has closed. It occurs when accessing lazily loaded relationships outside the transaction scope. To solve this, pre-initialize necessary data within the transaction, use fetch join, or utilize the Open Session In View pattern.
