---
title: "Understanding the Persistence Context"
date: 2024-06-08T03:12:19+09:00
tags: ["ORM", "java"]
description: "A comprehensive guide covering persistence context necessity and role, first-level cache working principles and advantages, identity guarantee mechanism, write-behind and performance optimization, transaction-scoped vs extended persistence context, and OSIV pattern issues"
draft: false
---

## What is Persistence Context

The Persistence Context is an environment for permanently storing entities. It plays the role of storing objects retrieved from the database by the application. It exists as a virtual database between the application and the database.

### Role of Persistence Context

The persistence context stores and manages entities when they are retrieved or saved through the entity manager. It tracks state changes between entities and the database.

### Provided Features

The persistence context is managed by the entity manager and provides the following features:

- **First-level cache**: Temporarily stores entities to improve performance during repeated queries
- **Dirty checking**: Automatically tracks entity changes and generates UPDATE queries automatically
- **Write-behind**: Collects multiple queries to execute them at once for performance optimization
- **Identity guarantee**: Guarantees identity for the same entity within the same transaction
- **Lazy loading**: Loads associated entities at the point of actual use

## First-Level Cache Working Principles and Advantages

Inside the persistence context, there is a storage space for entities called the first-level cache (First Level Cache).

### Structure of First-Level Cache

The first-level cache has a Key-Value structure:

- **Key**: Entity identifier (ID)
- **Value**: Entity instance

### Query Mechanism

When querying the database through EntityManager using the find command, it operates in the following order:

1. First queries the persistence context's first-level cache
2. If the id value received during find exists in the first-level cache, it finds and returns that value
3. If the entity is not in the cache, data retrieved from the database is stored in the first-level cache

### Lifecycle

The first-level cache is only valid from when the transaction starts until it ends:

- Transaction-scoped cache
- Not an option that can be activated or deactivated
- The persistence context itself is essentially the first-level cache

### Advantages of First-Level Cache

It reduces database access counts:

- When querying the same entity again later, since the same entity exists in the first-level cache, it doesn't query the database
- Returns the entity from the first-level cache as is
- Since the same entity is in the same persistence context, it guarantees object identity

### Performance Limitations

If 10 requests come in, 10 first-level caches are created. The persistence context created for each request disappears together when the request ends and the transaction terminates.

Therefore, the first-level cache often doesn't provide significant performance improvements. The first-level cache provides greater benefits from its mechanism than from performance.

## Identity Guarantee Mechanism

JPA's persistence context guarantees entity identity through the first-level cache mechanism.

### Identity Guarantee Principle

When repeatedly calling em.find(Member.class, "member1"), the persistence context returns the same entity instance from the first-level cache.

Because the first-level cache returns the same entity instance, JPA guarantees entity identity.

### Identity Comparison Example

```java
Member a = em.find(Member.class, "member1");
Member b = em.find(Member.class, "member1");
```

The identity comparison `a == b` returns true.

### Transaction Isolation Level

Thanks to this identity guarantee, it provides REPEATABLE READ level transaction isolation at the application level:

- Provided at the application level, not at the database level
- If persistence contexts are different, entities are considered different objects, so identity is not guaranteed

## Write-Behind and Performance Optimization

The persistence context provides transactional write-behind functionality.

### Write-Behind Working Principle

The entity manager doesn't save entities to the database until just before committing the transaction:

1. Collects INSERT SQL in an internal query storage
2. When committing the transaction, sends the collected queries to the database to save them

This is called transactional write-behind.

### SQL Batch Functionality

Thanks to write-behind, SQL batch functionality can be used.

For example, you can collect 5 INSERT SQLs and send them to the database at once. INSERT queries are collected up to that size until just before commit and processed at once.

### Performance Optimization Settings

For performance optimization, hibernate.default_batch_fetch_size must be set:

- Usually set with values of 100~1000 depending on application characteristics
- Read-only optimization that doesn't flush the persistence context doesn't perform heavy logic like snapshot comparison, so performance is optimized

## Transaction-Scoped Persistence Context

Spring uses transaction-scoped persistence context strategy by default.

### How it Works

- The same persistence context is used within the same transaction
- Because OSIV is OFF, the lifecycle of the transaction and persistence context are the same
- EntityManager is created only when entering the Service Layer where the transaction starts

### Presentation Layer Constraints

In the presentation layer like controller or view, it becomes detached state:

- Attempting lazy loading throws an exception
- The persistence context is limited to the transaction scope

## OSIV Pattern and Issues

OSIV (Open Session In View) is a feature that keeps the persistence context open until the view.

### How OSIV Works

1. When a client request comes in, the persistence context is created in a servlet filter or Spring interceptor
2. The transaction doesn't start
3. When starting a transaction in the service layer, it finds the created persistence context and starts the transaction
4. When the service layer ends, it flushes the persistence context and commits the transaction
5. The transaction ends but the persistence context doesn't terminate
6. Since the persistence context is maintained until the presentation layer, lazy loading is possible

### Advantages of OSIV

If the persistence context is alive until the View, lazy loading can be used in the View as well.

### Disadvantages of OSIV

#### Database Connection Pool Exhaustion

If code in the API that is not related to the database takes a long time, the following problems occur:

- The database connection is held until the API responds
- If many such requests come in, the database connection pool is exhausted instantly
- The next request cannot be processed

#### Persistence Context Sharing Problem

It expanded from opening the persistence context per transaction to opening the persistence context per request:

- If there are multiple transactions in one request, the persistence context is shared
- Possibility of unintended data changes exists

## Conclusion

The persistence context is a virtual database that exists between the application and the database. It reduces database access counts through the first-level cache and guarantees identity.

The first-level cache operates on a transaction basis. When repeatedly querying the same entity, it doesn't query the database but returns the cached entity. It provides REPEATABLE READ level transaction isolation at the application level.

The write-behind feature collects SQL until just before transaction commit and sends it to the database at once, enabling batch processing. Performance can be optimized through hibernate.default_batch_fetch_size settings.

Spring basically uses transaction-scoped persistence context strategy. The OSIV pattern maintains the persistence context until the view to enable lazy loading, but connection pool exhaustion and persistence context sharing issues can occur, so it should be used carefully.
