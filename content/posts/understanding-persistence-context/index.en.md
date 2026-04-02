---
title: "Understanding JPA Persistence Context"
date: 2024-06-08T03:12:19+09:00
tags: ["JPA", "ORM", "Java"]
description: "JPA persistence context role and first-level cache operation."
draft: false
---

## Concept and History of Persistence Context

The Persistence Context is the environment in which JPA manages entity instances. It is a core JPA concept that handles entity lifecycles between the application and the database while also providing several optimization features. This idea first appeared under the name `Session` when Gavin King developed Hibernate in 2001. Hibernate's Session abstracted database access, tracked entity state, and maintained a consistent view of data within a transaction. When JPA 1.0 was introduced in 2006, this concept was standardized as the Persistence Context and EntityManager.

The persistence context helps hide the complexity of database operations in object-oriented applications, allowing developers to focus on business logic in a more object-centric way. Instead of querying the database directly every time, the persistence context acts as an intermediate layer that automatically handles caching, change tracking, and delayed writes. It implements Martin Fowler's Unit of Work and Identity Map patterns: it tracks changed objects during a business transaction and flushes those changes to the database when needed, while always returning the same object instance for entities with the same identifier.

## Key Features of Persistence Context

### First-Level Cache

Inside the persistence context, there's a Map-structured storage called the first-level cache. It stores entity identifiers (@Id) as keys and entity instances as values, enabling immediate cache returns without database access when the same entity is queried repeatedly within the same transaction. When find() is called, it first queries the first-level cache and only executes a database query if not found in cache, then stores the result in the first-level cache. This approach significantly reduces database load when querying the same data multiple times within the same transaction.

The first-level cache operates within a transaction scope: it is created when a transaction starts and destroyed when it ends. Different transactions have their own first-level caches, which naturally creates isolation between them. Because the cache is recreated for each transaction, it does not dramatically improve overall application performance. Its real value lies in supporting identity guarantees and dirty checking.

### Identity Guarantee

The persistence context guarantees that entities queried with the same identifier within the same transaction always return the same object instance. This is an implementation of the Identity Map pattern. Calling `em.find(User.class, 1L)` multiple times does not create new objects each time; it returns the same instance stored in the first-level cache. As a result, `a == b` returns `true`, and this behavior provides a REPEATABLE READ-like guarantee at the application level.

```java
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();

User user1 = em.find(User.class, 1L); // DB query, stored in first-level cache
User user2 = em.find(User.class, 1L); // Returned from first-level cache

System.out.println(user1 == user2); // true - same instance
```

### Write-Behind

Write-behind is a feature in which the entity manager collects INSERT, UPDATE, and DELETE queries in an internal SQL queue and sends them to the database during flush. This reduces network round-trips compared with sending each query immediately. When `persist()` is called, the INSERT query does not execute right away. Instead, it is queued and later sent when the transaction commits or when `flush()` is called explicitly.

Write-behind becomes even more effective when combined with JDBC batch processing. Setting `hibernate.jdbc.batch_size` allows collecting queries of the same type up to the specified count and sending them as a single batch, greatly improving performance during bulk data processing.

### Dirty Checking

Dirty checking is a feature that automatically detects changes in managed entities and generates UPDATE queries during flush without requiring developers to write those SQL statements directly. It compares the snapshot captured when the entity became managed with the current state to determine which fields changed. Because of this, developers can simply modify object fields instead of manually tracking changes or writing update queries.

```java
em.getTransaction().begin();

User user = em.find(User.class, 1L); // Managed state, snapshot stored
user.setName("ChangedName"); // Only memory change occurs

em.getTransaction().commit(); // flush → snapshot comparison → UPDATE auto-generated
```

## Persistence Context Lifecycle and Scope

### Transaction-Scoped Persistence Context

Spring Framework uses a transaction-scoped persistence context by default, which means the persistence context is created when a transaction starts and closed when the transaction ends. When a method annotated with `@Transactional` begins, the transaction and persistence context start together. When the method ends, the persistence context is closed along with the commit or rollback, and all managed entities become detached.

Within the same transaction, the same persistence context is shared even across multiple repositories or services, so identity is guaranteed and dirty checking works consistently regardless of where entities are queried. However, attempting lazy loading in controllers or views after the transaction ends throws LazyInitializationException because the persistence context has already terminated.

### Extended Persistence Context and OSIV

OSIV (Open Session In View) is a pattern that keeps the persistence context open until view rendering is complete. It originated from Hibernate's Open Session In View pattern and is also called Open EntityManager In View in JPA. In Spring Boot, the `spring.jpa.open-in-view` property defaults to `true`, which enables OSIV. In that case, when an HTTP request comes in, the persistence context is created in a servlet filter or interceptor and kept alive until the response is sent.

OSIV's operation creates the persistence context at request start without starting a transaction. When entering a method with @Transactional in the service layer, it starts a transaction using the existing persistence context. When the service layer ends, the transaction commits but the persistence context doesn't terminate, enabling lazy loading in controllers and views.

## OSIV Pros, Cons, and Alternatives

### Advantages of OSIV

When OSIV is enabled, lazy loading remains possible in the presentation layer. That means associated entities can still be accessed in views even if the service layer returns entities directly instead of converting them to DTOs. Because the persistence context stays alive after the transaction ends, related data can still be loaded without triggering `LazyInitializationException`.

### Disadvantages of OSIV

OSIV's biggest problem is that it can hold database connections for the full duration of a request. If API responses or view rendering take a long time, those connections may not be returned to the pool quickly enough. For example, if requests that involve external API calls or complex view rendering become common, the connection pool can be exhausted and other requests may be blocked.

Another problem is that the persistence context is shared across the entire request. If multiple transactions run within that request, changes made to entities in one transaction can affect later transactions, which increases the risk of unintended data changes.

### Alternatives When Disabling OSIV

Setting `spring.jpa.open-in-view=false` disables OSIV, which means the persistence context ends when the transaction ends. In that case, all required data must be loaded in the service layer ahead of time. Common approaches include querying related entities with JPQL fetch joins, using `@EntityGraph` to eagerly load specific associations, or converting entities to DTOs in the service layer so only the necessary data reaches the presentation layer.

```java
// Pre-load associated entities with fetch join
@Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id = :id")
User findWithOrders(@Param("id") Long id);

// Using @EntityGraph
@EntityGraph(attributePaths = {"orders", "profile"})
Optional<User> findById(Long id);
```

## Conclusion

The persistence context is a core JPA concept that evolved from Hibernate's Session model. It provides caching through the first-level cache, identity guarantees through the Identity Map pattern, batch-friendly writes through write-behind, and dirty checking through snapshot comparison. By default, Spring uses a transaction-scoped persistence context, so the persistence context lifecycle follows the transaction lifecycle. OSIV extends that lifetime to keep lazy loading available during view rendering, but for API servers it is usually safer to disable OSIV and rely on fetch joins or DTO conversion instead.
