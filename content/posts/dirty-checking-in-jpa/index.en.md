---
title: "Dirty Checking in JPA"
date: 2024-06-08T02:47:28+09:00
tags: ["JPA", "ORM", "Java"]
description: "Change detection mechanism in JPA."
draft: false
---

## Concept and History of Dirty Checking

Dirty Checking is one of Hibernate's core features. It automatically detects changes to entities managed by the persistence context and reflects those changes in the database. Gavin King introduced this mechanism when he first developed Hibernate in 2001 as part of the framework's Transparent Persistence model. The goal was simple: let developers update the database by changing an object's state, without writing explicit UPDATE statements.

The term "Dirty" is a traditional database expression for modified data that has not been saved yet, meaning the data in memory no longer matches the data on disk. Hibernate applied this idea to object-relational mapping by checking whether an entity object's current state differs from the state it had when it was first loaded. When JPA 1.0 was standardized in 2006, this behavior became part of the persistence context model and has since been a required feature of JPA implementations.

The core problem Dirty Checking solves is eliminating the burden on developers to track which fields have changed and manually write corresponding UPDATE queries. In object-oriented programming, values are simply changed through setter methods, but in relational databases, UPDATE statements must be written—this paradigm mismatch is resolved through automation.

## Snapshot-Based Change Detection Mechanism

### Snapshot Creation Mechanism

Hibernate's Dirty Checking works through snapshot comparison. When an entity is first registered in the persistence context, all of its field values are copied and stored as a separate snapshot. This snapshot represents the entity's "Clean" state, meaning the initial state that matches the database. Internally, the persistence context stores the snapshot in a Map-like structure keyed by the entity identifier, typically as an Object array that holds each field value in order.

Snapshots are mainly created in two situations: when an entity is loaded from the database through EntityManager.find() or JPQL, and when a new entity is made persistent with EntityManager.persist(). With merge(), Hibernate first copies the detached entity's values into a managed entity and then creates a snapshot for that managed instance. The returned object is the new managed entity, while the original object remains detached.

### Field Comparison Process

When flush is called, Hibernate iterates through all entities in the persistence context and compares the current state with the snapshot field by field. This comparison doesn't use Java's equals() method but uses Hibernate's internal type-specific comparison logic—primitive types use the == operator, while object types use equals() after null checking. Entities with detected changes have a "dirty" flag set, and UPDATE queries for those entities are registered in the write-behind SQL store.

```java
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();

User user = em.find(User.class, 1L); // Snapshot created: {id=1, name="Hong Gil-dong", email="hong@example.com"}
user.setName("Kim Chul-soo"); // Only memory state changes, not yet reflected in DB

// At flush: Compare current state {name="Kim Chul-soo"} with snapshot {name="Hong Gil-dong"}
// name field change detected → UPDATE query generated
em.getTransaction().commit(); // Automatic flush → UPDATE user SET name='Kim Chul-soo' WHERE id=1
```

## Relationship Between Flush and Dirty Checking

### How Flush Works

Flush is the operation of synchronizing persistence context changes to the database. When flush is called, Dirty Checking is performed first to find changed entities, then INSERT, UPDATE, and DELETE queries registered in the write-behind SQL store are sent to the database. The important point is that flush doesn't empty the persistence context—it only sends changes to the database, and the actual commit happens when the transaction ends.

### When Flush Occurs

There are three common situations in which flush occurs. First, it runs right before transaction commit, because changes must be written to the database before the transaction finishes. Second, it runs right before JPQL or Criteria API query execution so the query can read the latest data. Third, it runs when EntityManager.flush() is explicitly called. FlushModeType.AUTO is the default. When it is set to COMMIT, flush happens only at commit time, and the automatic flush before JPQL execution is skipped.

```java
em.getTransaction().begin();

User user = em.find(User.class, 1L);
user.setName("Changed");

// Automatic flush before JPQL execution
List<User> users = em.createQuery("SELECT u FROM User u", User.class).getResultList();
// The query results include user's changes

em.getTransaction().commit();
```

## Default UPDATE Strategy and @DynamicUpdate

### Full Field Update Strategy

JPA's default UPDATE strategy generates UPDATE queries that include all entity fields. For example, even if only 1 of 10 fields is changed, a query that SETs all 10 fields is executed. While this seems inefficient, it has several important benefits. First, since the UPDATE query form is always identical, PreparedStatements can be pre-generated and cached at application startup. Second, databases can also reuse execution plans for identical queries, reducing parsing overhead.

### @DynamicUpdate Annotation

@DynamicUpdate is a Hibernate-specific annotation that, when applied to an entity class, dynamically generates UPDATE queries containing only changed fields. It compares the current state with the snapshot each time to identify the changed columns and build the query. This approach loses the benefit of PreparedStatement caching because the query string changes each time, and it also adds runtime cost for detecting changed fields and generating SQL dynamically.

Cases where @DynamicUpdate is effective include: when an entity has dozens or more columns and only some frequently change; when a table has large columns like TEXT or BLOB and you want to avoid unnecessary transmission; when the database uses column-level locking and you want to reduce lock contention on unchanged columns.

```java
@Entity
@DynamicUpdate // UPDATE only changed fields
public class Article {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String title;

    @Lob
    private String content; // Large field

    private LocalDateTime updatedAt;
}

// When only title changes: UPDATE article SET title=?, updated_at=? WHERE id=?
// content is excluded from UPDATE
```

## When Dirty Checking Doesn't Work

### Detached State

Dirty Checking only works for entities in the managed state within the persistence context. An entity becomes detached and is no longer part of change detection when detach() is called, when the persistence context is cleared with clear(), or when the EntityManager is closed with close(). To make a detached entity managed again, you must use merge()—merge() copies the detached entity's values to a new managed entity and returns that managed entity.

### Transient State

Entities created with the new keyword but not persisted with persist() are in transient state and have no relation to the persistence context whatsoever, so they are naturally not targets for Dirty Checking. No matter how much you change fields of such entities, they won't be reflected in the database.

```java
User user = em.find(User.class, 1L); // Managed state
em.detach(user); // Transitions to detached state

user.setName("Changed"); // Dirty Checking doesn't work, not reflected in DB

User merged = em.merge(user); // Returns new managed entity
merged.setName("Changed again"); // Now Dirty Checking works
```

## Bulk Data Processing Optimization

### Limitations of Dirty Checking

When modifying large numbers of entities, Dirty Checking generates individual UPDATE queries for each entity. If you modify 10,000 entities, 10,000 UPDATE queries execute, causing dramatic performance degradation. Also, when many entities accumulate in the persistence context, snapshot comparison costs at flush time increase along with memory usage.

### JDBC Batch Settings

Activating Hibernate's JDBC batch feature allows collecting multiple UPDATE queries and sending them in a single network round-trip. Setting `hibernate.jdbc.batch_size` and `hibernate.order_updates` to true maximizes batch efficiency by executing identical UPDATE statements consecutively. In optimistic locking environments using @Version, you must set `hibernate.jdbc.batch_versioned_data` to true for batch processing to work correctly.

### Utilizing Bulk Operations

The most effective method is using bulk operations with JPQL or Criteria API. A single UPDATE statement can modify all records matching conditions at once, handling tens of thousands of records with a single query. However, bulk operations modify the database directly without going through the persistence context, so entities in the persistence context become unsynchronized with the database after execution. After bulk operations, you must either clear the persistence context with clear() or query the data again.

```java
// Bulk UPDATE - bypasses persistence context, processes large amounts with single query
@Modifying
@Query("UPDATE User u SET u.status = :status WHERE u.lastLoginAt < :date")
int bulkUpdateStatus(@Param("status") UserStatus status, @Param("date") LocalDateTime date);

// Usage
em.getTransaction().begin();
int count = userRepository.bulkUpdateStatus(UserStatus.INACTIVE, LocalDateTime.now().minusYears(1));
em.clear(); // Must clear persistence context
em.getTransaction().commit();
```

## Conclusion

Dirty Checking is a core feature of Transparent Persistence introduced by Hibernate in 2001. The persistence context stores entity snapshots and compares them with the current state at flush time to automatically generate UPDATE queries for changed entities. By default, all fields are updated, but @DynamicUpdate can be configured to update only changed fields. For bulk data processing, performance should be optimized using JDBC batch settings or bulk operations. Since Dirty Checking only works on entities in managed state, changes in detached or transient state are not reflected in the database—understanding this is essential for proper entity state management.
