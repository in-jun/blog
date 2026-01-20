---
title: "Complete Guide to EntityManager"
date: 2024-06-07T19:12:36+09:00
tags: ["jpa", "hibernate", "entitymanager", "orm"]
description: "EntityManager is the core JPA interface that standardized Hibernate's Session. It manages the persistence context and controls entity lifecycle through methods like persist, find, merge, and remove, executing queries via JPQL and Criteria API"
draft: false
---

## History and Concept of EntityManager

EntityManager is the core interface of Java Persistence API (JPA), first defined in the EJB 3.0 specification released as part of JSR 220 in 2006. It was designed to standardize Hibernate's Session interface and provide a vendor-independent persistence management API. The Session concept introduced by Gavin King in 2001 when developing Hibernate was an innovative approach that abstracted database connections and tracked entity object states. JPA standardized this idea, reformulated it as EntityManager, and enabled the same interface to be used across all JPA implementations (Hibernate, EclipseLink, OpenJPA).

The core problem EntityManager solves is the Object-Relational Impedance Mismatch between objects in object-oriented programming and tables in relational databases. It enables developers to perform database operations with object-centric code without writing SQL directly, automatically providing optimization features like first-level cache, dirty checking, and write-behind. EntityManager manages a logical space called the Persistence Context, which implements the Identity Map and Unit of Work patterns defined by Martin Fowler—guaranteeing identity for entities with the same identifier within the same transaction and tracking changed entities to reflect them all at once to the database when the transaction ends.

## EntityManager Lifecycle and Management Approaches

### Relationship Between EntityManagerFactory and EntityManager

EntityManager is created from EntityManagerFactory. EntityManagerFactory is a heavyweight object containing database connection information, entity metadata, and cache settings that is created once and shared across the entire application. EntityManager, on the other hand, is a lightweight object created per request that must be closed after use. Creating EntityManagerFactory is expensive as it involves parsing persistence.xml or Spring configuration and loading database metadata, so it's created only once at application startup. EntityManager is not thread-safe, cannot be shared across threads, and must have a new instance created for each request or transaction.

### Application-Managed vs Container-Managed

EntityManager management approaches are divided into Application-Managed and Container-Managed. The Application-Managed approach is primarily used in Java SE environments where developers directly create EntityManager via EntityManagerFactory.createEntityManager() and must explicitly close it by calling close() after use. The Container-Managed approach is used in container environments like Spring or Java EE, where the container manages EntityManager's lifecycle—automatically creating it when transactions start and automatically closing it when transactions end.

In Spring environments, the @PersistenceContext annotation is used to inject a Container-Managed EntityManager. What's actually injected is a proxy object called SharedEntityManagerInvocationHandler that connects the actual EntityManager for each transaction. The @PersistenceUnit annotation injects EntityManagerFactory, used when developers need to directly create and manage EntityManager for fine-grained transaction control, such as batch jobs or asynchronous processing.

```java
// Application-Managed approach
EntityManagerFactory emf = Persistence.createEntityManagerFactory("persistence-unit");
EntityManager em = emf.createEntityManager();
EntityTransaction tx = em.getTransaction();

tx.begin();
// Perform operations
tx.commit();
em.close(); // Must explicitly close

// Container-Managed approach (Spring)
@Repository
public class UserRepository {
    @PersistenceContext
    private EntityManager em; // Proxy injected, actual EM connected per transaction
}
```

## Key API Methods

### persist()

The persist() method saves a new entity to the persistence context and transitions it to managed state. It doesn't immediately execute an INSERT query when called but registers the INSERT query in the persistence context's write-behind SQL store. The query is actually sent to the database when flush is called at transaction commit time. When using IDENTITY strategy with @GeneratedValue, INSERT executes immediately at persist() call time because the database must generate the ID. SEQUENCE or TABLE strategies can pre-allocate sequence values, enabling write-behind.

### find() and getReference()

The find() method is the most basic method for querying entities by identifier. It first checks the persistence context's first-level cache and only executes a SELECT query to the database if not found in cache. The queried entity is automatically managed in persistent state. The getReference() method returns a proxy object that delays actual database lookup, operating in lazy loading fashion where the actual SELECT executes when the proxy's fields are accessed.

```java
User user1 = em.find(User.class, 1L); // SELECT executes immediately
User user2 = em.getReference(User.class, 2L); // Returns proxy, no SELECT
String name = user2.getName(); // SELECT executes at this point
```

### merge()

The merge() method makes a detached entity persistent again. It checks the persistence context using the passed entity's identifier, queries the database if not found, copies all values from the passed entity to the queried persistent entity, and returns that persistent entity. The important point is that merge()'s return value is the persistent entity while the original parameter entity remains detached. Subsequent work must use the returned persistent entity for dirty checking to work.

### remove()

The remove() method transitions a persistent entity to removed state. Like persist(), it doesn't execute a DELETE query immediately when called but registers the DELETE query in the write-behind SQL store. It actually executes at transaction commit time. remove() can only be used on persistent entities. To delete a detached entity, you must first make it persistent with find() or merge() before calling remove().

### flush() and clear()

The flush() method immediately synchronizes persistence context changes to the database. It sends all queries in the write-behind SQL store to the database but doesn't commit the transaction. It's automatically called just before JPQL query execution to ensure queries can retrieve the latest data. The clear() method completely initializes the persistence context, making all managed entities detached. When processing large amounts of data, flush() and clear() are called together at regular intervals to prevent memory exhaustion from entities accumulating in the first-level cache.

## Transactions and Persistence Context

### Transaction-Scoped Persistence Context

Spring uses transaction-scoped persistence context strategy by default. When a method with @Transactional annotation starts, the transaction and persistence context are created together. When the method ends, the persistence context terminates along with transaction commit. At transaction commit time, flush() is automatically called to perform dirty checking, comparing snapshots of persistent entities with their current state and automatically generating UPDATE queries for changed fields.

### Dirty Checking and Identity Guarantee

Dirty Checking is a feature where EntityManager stores a snapshot when making an entity persistent, compares it with the current state at flush time, finds changed fields, and automatically generates UPDATE queries. Without developers explicitly calling methods like update(), simply changing values through setters automatically reflects changes to the database. Identity Guarantee ensures that entities queried with the same identifier within the same transaction are always the same object instance. Calling em.find(User.class, 1L) multiple times always returns the identical instance, making == comparison return true.

## JPQL and Criteria API

### JPQL (Java Persistence Query Language)

JPQL is an object-oriented query language that writes queries targeting entity objects. It targets entity classes and fields rather than tables and is database-independent, so queries don't need modification when the database changes. JPQL is executed via EntityManager.createQuery(). Using TypedQuery allows specifying result types for type safety. Parameter binding supports both position-based (:1) and name-based (:name) approaches.

```java
// JPQL example
TypedQuery<User> query = em.createQuery(
    "SELECT u FROM User u WHERE u.status = :status AND u.age > :age",
    User.class
);
query.setParameter("status", UserStatus.ACTIVE);
query.setParameter("age", 18);
List<User> users = query.getResultList();
```

### Criteria API and Native Query

Criteria API writes queries in Java code using CriteriaBuilder. It compensates for JPQL's disadvantage of being string-based and unable to detect errors at compile time, enabling type-safe query writing. However, it has disadvantages of complex code and reduced readability, so it's best used selectively only when dynamic queries are needed. When native SQL is needed, the createNativeQuery() method can execute database-specific SQL directly, useful for complex statistical queries or when database-specific features are required.

## Relationship with Spring Data JPA

Spring Data JPA's Repository interfaces (JpaRepository, CrudRepository) are implemented internally using EntityManager. The SimpleJpaRepository class is the actual implementation where save() calls persist() for new entities and merge() for existing ones, findById() calls EntityManager.find(), and deleteById() calls find() followed by remove(). Spring Data JPA provides convenience features like method name-based query generation, @Query annotation, and Specification to increase development productivity. However, for complex queries, bulk operations, or fine-grained persistence context control, injecting EntityManager directly with @PersistenceContext is more appropriate.

## Practical Optimization Tips

### Large Data Processing

Processing thousands or more entities at once can cause memory exhaustion as all entities accumulate in the persistence context. You should call flush() and clear() at regular intervals (e.g., every 100 entities) to empty the persistence context. Additionally, executing multiple INSERTs or UPDATEs in one batch through JDBC batch settings (hibernate.jdbc.batch_size) can significantly improve performance.

### Solving N+1 Problem

The N+1 problem is when N parent entities are queried and then queries to retrieve child entities execute N additional times for each parent, resulting in N+1 total queries. Solutions include using JPQL fetch join to query parents and children together in one query, using @EntityGraph to explicitly load necessary relationships, or setting hibernate.default_batch_fetch_size to query child entities bundled in an IN clause.

## Conclusion

EntityManager is the core JPA interface that standardized Hibernate's Session in the EJB 3.0 specification in 2006. It provides first-level cache, dirty checking, write-behind, and identity guarantee through the persistence context. It manages entity lifecycle through methods like persist(), find(), merge(), and remove(), executes object-oriented queries via JPQL and Criteria API, and is designed to operate within transaction scope. Spring Data JPA provides an abstraction layer based on EntityManager, but for complex queries or fine-grained control, using EntityManager directly is appropriate. For large data processing, manage memory with flush() and clear(), and optimize performance with batch settings and fetch join.
