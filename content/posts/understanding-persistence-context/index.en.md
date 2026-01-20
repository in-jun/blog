---
title: "Complete Guide to Persistence Context"
date: 2024-06-08T03:12:19+09:00
tags: ["jpa", "hibernate", "orm", "java"]
description: "The persistence context is a core JPA concept providing first-level cache, identity guarantee, write-behind, and dirty checking features. It operates within transaction scope, while the OSIV pattern maintains persistence until the view but risks connection pool exhaustion"
draft: false
---

## Concept and History of Persistence Context

The Persistence Context is an environment for permanently storing entities. It's a core JPA concept that manages entity lifecycles between the application and database while providing various optimization features. This concept was first introduced under the name "Session" when Gavin King developed Hibernate in 2001. Hibernate's Session abstracted database connections, tracked entity object states, and provided a consistent data view within transactions. When JPA 1.0 standardized Hibernate in 2006, this concept was reformulated as Persistence Context and EntityManager.

The core problem the persistence context solves is hiding the complexity of database operations in object-oriented applications, allowing developers to focus on business logic in an object-centric manner. Instead of directly querying the database each time, an intermediate layer called the persistence context handles optimizations like caching, change tracking, and delayed writing automatically. The persistence context implements the Unit of Work and Identity Map patterns defined by Martin Fowler—it tracks objects changed during a business transaction to reflect them all at once to the database when the transaction ends, and always returns the same object instance for entities with the same identifier to ensure consistency.

## Key Features of Persistence Context

### First-Level Cache

Inside the persistence context, there's a Map-structured storage called the first-level cache. It stores entity identifiers (@Id) as keys and entity instances as values, enabling immediate cache returns without database access when the same entity is queried repeatedly within the same transaction. When find() is called, it first queries the first-level cache and only executes a database query if not found in cache, then stores the result in the first-level cache. This approach significantly reduces database load when querying the same data multiple times within the same transaction.

The first-level cache operates within transaction scope—it's created when a transaction starts and destroyed when it ends. Different transactions have their own first-level caches, naturally achieving data isolation between transactions. However, since a new first-level cache is created for each request, it doesn't dramatically improve overall application performance. The cache's true value lies not in performance but in serving as the foundation mechanism for identity guarantee and dirty checking.

### Identity Guarantee

The persistence context guarantees that entities queried with the same identifier within the same transaction always return the same object instance. This is an implementation of the Identity Map pattern—calling `em.find(User.class, 1L)` multiple times doesn't create new objects each time but returns the same instance stored in the first-level cache. Therefore, `a == b` comparison returns true, and this characteristic enables providing REPEATABLE READ transaction isolation at the application level.

```java
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();

User user1 = em.find(User.class, 1L); // DB query, stored in first-level cache
User user2 = em.find(User.class, 1L); // Returned from first-level cache

System.out.println(user1 == user2); // true - same instance
```

### Write-Behind

Write-behind is a feature where the entity manager collects INSERT, UPDATE, and DELETE queries in a write-behind SQL store until just before committing the transaction, then sends them all to the database at flush time. This approach improves performance by reducing network round-trips compared to sending multiple queries individually. When persist() is called, the INSERT query doesn't execute immediately but is registered in the write-behind SQL store, and actual queries are sent at transaction commit or explicit flush() call time.

Write-behind becomes even more effective when combined with JDBC batch processing. Setting `hibernate.jdbc.batch_size` allows collecting queries of the same type up to the specified count and sending them as a single batch, greatly improving performance during bulk data processing.

### Dirty Checking

Dirty checking is a feature that automatically detects changes and generates UPDATE queries at flush time when a managed entity is modified, without developers explicitly calling UPDATE statements. It compares the snapshot stored when the entity was persisted with the current state to find changed fields. Thanks to this feature, developers only need to change object field values and are freed from the burden of tracking which fields changed or writing UPDATE queries.

```java
em.getTransaction().begin();

User user = em.find(User.class, 1L); // Managed state, snapshot stored
user.setName("ChangedName"); // Only memory change occurs

em.getTransaction().commit(); // flush → snapshot comparison → UPDATE auto-generated
```

## Persistence Context Lifecycle and Scope

### Transaction-Scoped Persistence Context

Spring Framework uses transaction-scoped persistence context strategy by default, meaning the persistence context is created when a transaction starts and terminated when the transaction ends. When entering a method with @Transactional annotation, the transaction and persistence context start together, and when the method ends, the persistence context also terminates along with commit or rollback, making all entities inside it detached.

Within the same transaction, the same persistence context is shared even across multiple repositories or services, so identity is guaranteed and dirty checking works consistently regardless of where entities are queried. However, attempting lazy loading in controllers or views after the transaction ends throws LazyInitializationException because the persistence context has already terminated.

### Extended Persistence Context and OSIV

OSIV (Open Session In View) is a pattern that keeps the persistence context open until view rendering completes. It originated from Hibernate's Open Session In View and is also called Open EntityManager In View in JPA. In Spring Boot, the `spring.jpa.open-in-view` property defaults to true, enabling OSIV. In this case, when an HTTP request comes in, the persistence context is created in a servlet filter or interceptor and maintained until the response completes.

OSIV's operation creates the persistence context at request start without starting a transaction. When entering a method with @Transactional in the service layer, it starts a transaction using the existing persistence context. When the service layer ends, the transaction commits but the persistence context doesn't terminate, enabling lazy loading in controllers and views.

## OSIV Pros, Cons, and Alternatives

### Advantages of OSIV

When OSIV is enabled, lazy loading is possible in the presentation layer, so even if entities are returned directly without converting to DTOs in the service layer, associated entities can be accessed in views, making development convenient. Since the persistence context is maintained after transaction ends, associated data can be queried at needed times without worrying about LazyInitializationException.

### Disadvantages of OSIV

OSIV's biggest problem is holding database connections for the entire request duration. If API responses or view rendering take a long time, connections aren't returned during that time, potentially exhausting the connection pool. For example, if requests involving external API calls or complex view rendering increase, the connection pool can be depleted, making it impossible to process other requests.

Another problem is that since the persistence context is shared across the entire request, if multiple transactions execute within one request, changes to entities modified in previous transactions can affect subsequent transactions, creating the possibility of unintended data changes.

### Alternatives When Disabling OSIV

Setting `spring.jpa.open-in-view=false` to disable OSIV means the persistence context terminates when the transaction ends, so all necessary data must be pre-loaded in the service layer. Methods for this include: using JPQL fetch join to query associated entities at once, using @EntityGraph to eagerly load specific associations, or converting to DTOs in the service layer to pass only necessary data to the presentation layer.

```java
// Pre-load associated entities with fetch join
@Query("SELECT u FROM User u JOIN FETCH u.orders WHERE u.id = :id")
User findWithOrders(@Param("id") Long id);

// Using @EntityGraph
@EntityGraph(attributePaths = {"orders", "profile"})
Optional<User> findById(Long id);
```

## Conclusion

The persistence context is a core JPA concept that originated from Hibernate's Session. It provides caching through first-level cache, identity guarantee through the Identity Map pattern, batch optimization through write-behind, and dirty checking through snapshot comparison. Spring uses transaction-scoped persistence context strategy by default, matching transaction and persistence context lifecycles. The OSIV pattern maintains the persistence context until the view to enable lazy loading, but due to connection pool exhaustion risks, disabling it and using fetch join or DTO conversion approaches is recommended for API servers.
