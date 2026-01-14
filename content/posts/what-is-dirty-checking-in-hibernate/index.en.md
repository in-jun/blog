---
title: "Understanding Dirty Checking"
date: 2024-06-08T02:47:28+09:00
tags: ["ORM", "java"]
description: "A comprehensive guide covering JPA Dirty Checking's snapshot comparison mechanism, relationship with flush timing, @DynamicUpdate's role and performance impact, non-working cases in detached state, and bulk update performance optimization methods"
draft: false
---

## What is Dirty Checking

Dirty Checking is a mechanism in JPA that automatically detects changes to entities and reflects them in the database.

### Automatic Change Detection

Developers only need to change the object's state without explicitly writing database UPDATE queries. The UPDATE queries are automatically generated and executed.

### Target Entities

Dirty Checking only applies to entities managed by the persistence context:

- Entities in detached or transient state are not targets for change detection

## How Change Detection Works

### Snapshot Creation

Whenever an entity is loaded, Hibernate creates a snapshot, which is a copy containing all entity attribute values.

### Comparison and Update

When flush occurs, it compares the entity with the snapshot to check for changes and updates accordingly.

#### Specific Operation Process

1. When EntityManager manages an entity, the persistence context stores the entity's initial state
2. Hibernate stores a copy of the retrieved entity during entity retrieval
3. It then uses equals to compare each field for change detection

### Flush Timing Operation

When transaction.commit() is called, flush() occurs and goes through the following process:

1. Compares the entity and snapshot field by field
2. If there are changes, creates UPDATE queries and puts them in the write-behind SQL store
3. Reflects them in the database and commits

### Target Entities

State change checking only applies to entities managed by the persistence context:

- Detached or transient states are not targets for Dirty Checking

## Flush Timing and Dirty Checking

### Role of Flush

When flush occurs, JPA detects changes and registers modified entities in the write-behind SQL store:

1. Sends queries from the write-behind SQL store to the database
2. Flush occurring doesn't mean commit happens
3. The actual commit happens after flush

### When Flush Occurs

Flush occurs at the following times:

- **Transaction Commit**: When committing a transaction, flush is first called internally in the entity manager
- **EntityManager Flush**: Explicitly calling the flush() method
- **JPQL Usage**: When executing JPQL queries

### Necessity of Flush

The reason flush() is automatically called during transaction commit is because nothing would happen if COMMIT is performed without writing SQL.

Since synchronization only needs to happen right before the transaction commits after it starts, the flush mechanism can operate in between.

## Role and Performance Impact of @DynamicUpdate

### JPA's Default Behavior

JPA basically updates all fields so that modification queries are always created identically.

#### Advantages

- UPDATE queries can be created in advance at boot time for reuse
- Previously parsed queries can also be reused in the database

### Using @DynamicUpdate

When the @DynamicUpdate annotation is applied to an entity class, Hibernate generates SQL UPDATE statements that include only the columns whose values have been modified.

#### How it Works

It compares current and modified states to find only the changed columns.

#### Performance Impact

When using @DynamicUpdate, Hibernate doesn't use cached SQL statements but generates new SQL statements each time:

- Runtime costs for change tracking and query generation occur

### Recommended Use Cases

For entities with dozens of fields, @DynamicUpdate has the following benefits:

- Prevents waste of network, CPU, and other resources on serialization, transmission, and deserialization of unmodified entity columns
- On databases using column-level locking, it has significant effects even for entities with few fields

#### Special Cases

- Entities containing JSON properties
- When using column-level versioning in MVCC databases

## When Dirty Checking Doesn't Work

### Persistence Context Management Target

Dirty Checking only works on entities managed by the persistence context.

Entities in detached or transient state are excluded from change detection targets.

### Detached State

Detached state means separated from the persistence context:

- Detached state after calling detach
- Transient state like entities not yet reflected in the database
- Dirty Checking is not performed and value changes are not reflected in the database

### Necessity of Persistence Context

To use persistence context features like Dirty Checking and UPDATE query generation, entities must be managed by the persistence context.

In JPA, when retrieving an entity, it takes a snapshot of that entity. It compares this snapshot at transaction end and requests UPDATE queries to the database if there are changes.

## Performance Optimization for Bulk Updates

### JDBC Batch Settings

To activate JDBC batching, the following settings are needed:

- Set `spring.jpa.properties.hibernate.jdbc.batch_size`
- Set `spring.jpa.properties.hibernate.order_updates` to true

Ordering statements ensures Hibernate executes all identical UPDATE statements that only differ in provided bind parameter values sequentially.

### When Using Optimistic Locking

When using optimistic locking with @Version annotation, set the `hibernate.jdbc.batch_versioned_data` property to true.

You can compare the returned count with the changed entity count after batch update execution.

### Custom Modification Queries

If you can define an UPDATE statement that performs all required changes, the following method is better:

- Define a custom modifying query in your Repository using @Query and @Modifying annotations

#### Optimization Strategy

Grouping data by status criteria and updating via IDs requires a maximum of only 2 database communications per chunk. Network I/O can be significantly reduced.

### Batch Application Optimization

For batch applications with large-scale processing, the following are recommended:

- Returning Projection objects instead of Entity objects is recommended
- For very large data volumes, using Spring Data JDBC's batchUpdate() is recommended
- Can be used alongside Spring Data JPA

## Conclusion

Dirty Checking is a mechanism where the persistence context stores entity snapshots and automatically detects changes by comparing at flush time.

Flush occurs at Transaction Commit, EntityManager Flush, and when using JPQL. Dirty Checking is performed at that time.

By default, all fields are updated, but using @DynamicUpdate allows updating only changed fields. Performance improvements can be expected for entities with many fields or when using column-level locking.

Entities in detached or transient state are excluded from Dirty Checking targets. They must be managed by the persistence context.

For bulk updates, performance can be optimized through:

- JDBC batch settings
- Custom modifying queries
- Utilizing Projections
