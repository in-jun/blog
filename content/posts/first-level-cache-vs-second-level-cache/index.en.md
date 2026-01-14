---
title: "Understanding First-Level and Second-Level Caches"
date: 2024-06-08T03:39:05+09:00
tags: ["ORM", "java"]
description: "A comprehensive guide covering Hibernate cache architecture history and evolution, first-level cache working principles and transaction scope, second-level cache sharing mechanism and concurrency control, EhCache/Infinispan/Hazelcast comparison, cache strategies (READ_ONLY, READ_WRITE, NONSTRICT_READ_WRITE, TRANSACTIONAL), and cache synchronization issues with solutions in distributed environments"
draft: false
---

## History and Evolution of Hibernate Caching

Hibernate has provided caching mechanisms for performance optimization from its inception.

### Emergence of First-Level Cache

The first-level cache has been included as a core feature of the persistence context since Hibernate's early versions. It is a mandatory feature that all JPA implementations must provide.

The first-level cache is part of the JPA specification and is automatically activated at the EntityManager or Session level. It cannot be disabled. It remains valid only within the transaction scope to ensure data consistency.

### Introduction of Second-Level Cache

The second-level cache was introduced as an optional feature starting from Hibernate 2.x. It was standardized in the JPA 2.0 specification, allowing it to be used consistently across multiple implementations.

As a cache shared across the entire application, it enables data reuse across multiple transactions and sessions. Hibernate does not provide the second-level cache implementation directly. Instead, it is designed to integrate various cache providers through a standard interface in a plugin-based manner.

Supported cache providers include:

- **EhCache**: The most widely used caching library
- **Infinispan**: Red Hat's distributed cache solution
- **Hazelcast**: In-memory data grid optimized for cloud environments

## Concept and Working Principles of First-Level Cache

The first-level cache refers to the cache that exists within the persistence context. When an entity is queried, the persistence context stores the entity in the cache.

### Structure of First-Level Cache

The first-level cache operates at the Session or EntityManager level. Each session has its own first-level cache. This cache has a Key-Value structure and uses the entity's identifier as the key to store the entity instance as the value.

### Query Mechanism

When querying an entity, Hibernate first checks the first-level cache. If the entity is in the cache, it returns the cached instance without querying the database.

This ensures that even if the same entity is queried multiple times within the same transaction, the database is accessed only once. This is a core mechanism that significantly improves performance.

### Transaction Scope and Lifecycle

The first-level cache is valid only within a transaction. When the transaction ends, the first-level cache is also terminated. This ensures consistency within the transaction scope and isolates it from changes made by other transactions.

### Mandatory Feature

The first-level cache is always active and cannot be disabled. As a core feature of JPA and Hibernate, the persistence context itself is essentially the first-level cache.

It guarantees entity identity. Within the same persistence context, entities with the same identifier always return the same instance.

## Dirty Checking and First-Level Cache Relationship

Dirty checking is a mechanism that tracks changes to entities through the first-level cache. When an entity is queried, the persistence context stores the initial state of the entity as a snapshot.

### Snapshot Storage Mechanism

When storing an entity in the first-level cache, Hibernate also stores a copy (snapshot) of that entity. When flush occurs, it compares the current entity state with the snapshot to detect changed fields.

When changes are detected, it automatically generates an UPDATE SQL and reflects it in the database. Developers don't need to explicitly call an update method.

### Automatic Synchronization

When the entity's state changes, the persistence context tracks the changes and reflects them in the database. Changes are automatically synchronized to the database at transaction commit time.

### Memory Management Considerations

The first-level cache is stored in memory, so query performance is very fast. However, memory usage can increase as the transaction lengthens.

When processing large numbers of entities, you should periodically call flush() and clear() to manage memory. This prevents OutOfMemoryError.

## Concept and Sharing Mechanism of Second-Level Cache

The second-level cache refers to a cache shared among multiple persistence contexts. The cache is maintained even after the persistence context terminates, and entities can be shared among multiple persistence contexts.

### Operating Scope and Sharing

The second-level cache operates at the SessionFactory or EntityManagerFactory level and is shared across the entire application. Data can be reused across multiple transactions and multiple user requests, significantly reducing database queries.

### Lifecycle and Application Targets

The second-level cache is valid across multiple transactions. Cached data is retained until the application restarts or is explicitly removed.

It is suitable for data that is frequently read but rarely modified:

- **Code tables**: Country codes, currency codes, etc.
- **Configuration data**: System settings, permission information, etc.
- **Reference data**: Categories, department information, etc.

### Activation Method

The second-level cache is an optional feature and is disabled by default. To use it, you must explicitly enable it and configure a cache provider.

You can use the @Cacheable and @Cache annotations to enable caching on a per-entity basis.

### Concurrency Control

The second-level cache can cause concurrency issues. Therefore, instead of providing objects directly, it should provide copies or use locks to control concurrency issues.

Hibernate serializes entities to store them in the second-level cache. When querying, it deserializes them to create new instances, ensuring that changes to cached data do not affect other sessions.

## Comparison of Second-Level Cache Providers

Hibernate supports various second-level cache providers, each with unique characteristics and use cases.

### EhCache

The most widely used combination with Hibernate, providing simple configuration and fast performance.

- **Support mode**: Supports both local and distributed caching
- **Cluster environment**: Can be used by integrating with Terracotta
- **Standards compliance**: Implements the JCache (JSR-107) standard for high portability

### Infinispan

An open-source data grid developed by Red Hat, optimized for distributed caching.

- **Scalability**: Provides excellent scalability in cluster environments
- **Transaction support**: Fully supports transactional cache strategies
- **Integration**: Included by default in Wildfly and JBoss EAP
- **Operation modes**: Supports both replication and distribution modes

### Hazelcast

An in-memory data grid that provides simple configuration and automatic cluster discovery features.

- **Data structures**: Supports various data structures like distributed Map, Queue, and Topic
- **Cloud optimization**: Excellent performance in cloud environments
- **Spring Boot integration**: Very easy integration

### Caffeine

A high-performance local cache developed as a successor to Google Guava cache.

- **Performance**: Provides the best performance in single JVM environments
- **Features**: Automatic expiration, size limits, statistics collection, etc.
- **Limitations**: Does not support distributed caching and is not suitable for cluster environments

## Cache Concurrency Strategies

Hibernate provides four cache concurrency strategies for second-level cache concurrency control. Each strategy represents a tradeoff between performance and consistency.

### READ_ONLY

Used for data that never changes and provides the highest performance.

- **Lock usage**: No locks needed, so no concurrency issues occur
- **Modification attempt**: An exception occurs if you try to modify the entity
- **Application target**: Code tables or static reference data

### READ_WRITE

Used for data where both reads and writes occur and is suitable for most common use cases.

- **Concurrency control**: Uses soft locks to control concurrency
- **Consistency guarantee**: Invalidates cache entries when entities are modified
- **Provider support**: Supported by EhCache, Infinispan, and Hazelcast

### NONSTRICT_READ_WRITE

Used when the likelihood of concurrently modifying the same entity is low. Does not use locks, so performance is better.

- **Performance**: Faster than READ_WRITE, but stale data can be read for a short period
- **Application target**: When update frequency is low and stale data can be temporarily tolerated

### TRANSACTIONAL

Provides complete transaction isolation and guarantees the strongest consistency.

- **Transaction support**: Integrates with JTA transactions and supports two-phase commit
- **Performance**: Significant performance overhead
- **Provider limitation**: Only supported by transactional cache providers like Infinispan
- **Application environment**: Enterprise environments requiring distributed transactions

## How to Use and Configure Second-Level Cache

### Basic Activation Configuration

To use the second-level cache, you must first enable it in hibernate.properties or application.properties.

```properties
spring.jpa.properties.hibernate.cache.use_second_level_cache=true
```

You must specify a cache provider.

### Enabling Entity Caching

You can use the @Cacheable annotation on entities to enable caching. You can use the @Cache annotation to set the cache's concurrency strategy and region name.

Collections and associations can also be cached using @Cache.

### Query Cache

Using query cache allows you to cache the results of JPQL or Criteria queries.

```properties
spring.jpa.properties.hibernate.cache.use_query_cache=true
```

Use it by calling setCacheable(true) on queries. Query cache stores only the identifier list of the result set, and actual entities are retrieved from the second-level cache.

### Cache Region Configuration

You can use cache regions to apply different cache settings for different entities or collections.

Items that can be configured independently per region include:

- **Expiration time**: Validity period of cached data
- **Maximum size**: Maximum number of items that can be stored in cache
- **Eviction policy**: Cache eviction algorithms like LRU, LFU

Details are configured in provider-specific configuration files such as ehcache.xml or infinispan.xml.

## Cache Behavior and Query Order

When querying an entity, Hibernate goes through a multi-level cache lookup process.

### Step 1: First-Level Cache Check

The persistence context first looks for the entity in the first-level cache. If the entity is in the first-level cache, it is returned immediately.

### Step 2: Second-Level Cache Check

If the entity is not in the first-level cache, it checks the second-level cache. If found in the second-level cache, the entity is deserialized, stored in the first-level cache, and then returned.

This is called a second-level cache hit and avoids database queries.

### Step 3: Database Query

If the entity is not in the second-level cache either, it queries the entity from the database. The queried entity is stored in both the first-level cache and the second-level cache.

The entity is serialized and stored in the second-level cache, ready for the next query.

### Behavior When Modifying Entities

When an entity is modified, the persistence context updates the entity in the first-level cache. At transaction commit time, it updates both the database and the second-level cache.

Cache entries are invalidated or updated according to the cache concurrency strategy.

### Cache Validity Period

- **First-level cache**: Valid until the transaction ends
- **Second-level cache**: Valid even after the persistence context terminates, retained until explicitly removed or expired

## Cache Synchronization Issues in Distributed Environments

In distributed environments where multiple server instances are running, second-level cache synchronization becomes an important issue. When an entity is modified on one server, the cache on other servers must be invalidated.

### Problems with Local Cache

Using only local cache can cause cache inconsistency between servers. Even if one server updates data, other servers continue to provide old cached data.

This causes data consistency issues.

### Using Distributed Cache Providers

Using distributed cache providers (Infinispan, Hazelcast) allows cache synchronization across all nodes in the cluster.

- **Replication mode**: All nodes have a copy of the entire cache
- **Distribution mode**: Cache entries are distributed and stored across multiple nodes

### Cache Invalidation Mechanism

Hibernate's cache invalidation mechanism invalidates the corresponding cache entry when an entity is modified or deleted. In distributed caches, invalidation messages are propagated to all nodes.

Query cache is more complex to manage because all related query results must be invalidated when a table is updated.

### Eventual Consistency and Strong Consistency

Cache synchronization delays can cause data inconsistencies between nodes for a short period. You should consider whether eventual consistency can be tolerated.

If strong consistency is required, you must use the TRANSACTIONAL strategy or distributed locks.

## Precautions and Best Practices for Cache Usage

### Selective Caching Application

Second-level cache should not be applied to all entities. It should only be selectively applied to entities with many reads and few writes. Caching frequently changing data can make the cache invalidation overhead greater than the benefits.

### Monitoring Cache Statistics

You should monitor cache statistics to track performance:

- **Hit rate**: Percentage of data found in cache
- **Miss rate**: Percentage of data not found in cache
- **Eviction count**: Number of times items were removed due to cache capacity

Use Hibernate Statistics API or cache provider monitoring tools. A low hit rate indicates that cache settings should be reviewed.

### Limiting Memory Usage

To limit memory usage, cache size and expiration policies should be set appropriately.

- **TTL (Time To Live)**: Maximum lifespan of cache items
- **TTI (Time To Idle)**: Maximum idle time for cache items not accessed
- **Eviction policy**: LRU (Least Recently Used) or LFU (Least Frequently Used)

### Association Caching Considerations

Association caching should be used carefully. Collection caching can use a lot of memory.

Caching lazy-loaded collections can reduce N+1 problems, but memory usage should be monitored.

### Validation and Testing

You should verify cache behavior in test and production environments.

- Check logs to see if the cache is working as expected
- Test data consistency in concurrency scenarios
- Measure cache performance improvements through load testing

## Conclusion

Hibernate provides two levels of caching mechanisms—first-level cache and second-level cache—to minimize database queries and improve performance.

The first-level cache is a mandatory feature valid only within transactions and is the core of the persistence context. It guarantees entity identity and enables dirty checking. It is automatically activated in all JPA implementations and cannot be disabled.

The second-level cache is an optional feature valid across multiple transactions and is shared across the entire application. It supports various cache providers like EhCache, Infinispan, and Hazelcast. It provides four concurrency strategies: READ_ONLY, READ_WRITE, NONSTRICT_READ_WRITE, and TRANSACTIONAL.

The second-level cache is suitable for data that is frequently read but rarely modified. In distributed environments, cache synchronization issues must be considered. Cache effectiveness should be verified through proper monitoring and testing.

By appropriately combining first-level and second-level caches and correctly selecting cache concurrency strategies, you can significantly reduce database load and improve application performance. It is important to balance memory usage and data consistency.
