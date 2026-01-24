---
title: "JPA First-Level and Second-Level Cache"
date: 2024-06-08T03:39:05+09:00
tags: ["JPA", "ORM", "Cache"]
description: "Differences between JPA first-level and second-level caching."
draft: false
---

## History and Concepts of Hibernate Cache Architecture

Hibernate was designed with caching mechanisms as a core feature for performance optimization from when Gavin King first developed it in 2001. Since then, Hibernate's cache architecture has evolved into a two-level hierarchical structure called first-level cache and second-level cache, minimizing database access and maximizing application performance. The first-level cache is a mandatory feature that has existed since Hibernate's early versions along with Session (now EntityManager). The persistence context itself serves as the first-level cache, guaranteeing entity identity within transactions and serving as the foundation for Dirty Checking.

The second-level cache was first introduced as an optional feature in Hibernate 2.x (around 2003) and was standardized as "Shared Cache" in the JPA 2.0 specification in 2009, enabling consistent usage across all JPA implementations. Hibernate adopted an architecture that doesn't provide second-level cache implementation directly but integrates external cache providers like EhCache, Infinispan, and Hazelcast in a plugin-based manner through SPI (Service Provider Interface). This design allows users to select the optimal cache solution for their application requirements.

The core principle of the cache hierarchy structure comes from the Memory Hierarchy concept that data closer to the processor is faster. The first-level cache is the layer closest to individual transactions, optimizing repeated queries within transactions, while the second-level cache is shared across the entire application, enabling data reuse between transactions.

## How First-Level Cache Works

### First-Level Cache Structure and Lifecycle

The first-level cache is implemented as a Map structure inside the persistence context. It stores entity identifiers (@Id) as keys and entity instances as values, enabling immediate cached instance returns without database access when querying with the same identifier. The first-level cache lifecycle is identical to the persistence context—it's created when a transaction starts and destroyed when it ends. This transaction-scoped characteristic naturally achieves data isolation between different transactions.

The first-level cache is a mandatory feature in the JPA specification and is automatically activated in all JPA implementations. It's not an option that developers can explicitly disable or configure. When EntityManager.find() is called, it first queries the first-level cache. If the entity exists in cache, it returns immediately without a database query. Only when not in cache does it execute a SELECT query and store the result in the first-level cache.

```java
EntityManager em = emf.createEntityManager();
em.getTransaction().begin();

// First query: SELECT from DB, stored in first-level cache
User user1 = em.find(User.class, 1L);

// Second query: Immediate return from first-level cache, no DB access
User user2 = em.find(User.class, 1L);

System.out.println(user1 == user2); // true - same instance

em.getTransaction().commit();
```

### Identity Guarantee and Dirty Checking

One of the first-level cache's core functions is implementing the Identity Map pattern, guaranteeing that entities queried with the same identifier within the same transaction always return the same object instance. This characteristic enables providing REPEATABLE READ transaction isolation at the application level. Additionally, the first-level cache serves as the foundation for Dirty Checking—when an entity is stored in the first-level cache, a snapshot of that moment is also stored. At flush time, it compares the current state with the snapshot and automatically generates UPDATE queries for changed entities.

### First-Level Cache Limitations and Memory Management

The first-level cache is created and destroyed per transaction, so caches aren't shared between different requests or transactions. It doesn't dramatically improve overall application performance. The first-level cache's true value lies not in performance but in serving as the foundation mechanism for identity guarantee and dirty checking. In batch operations processing large numbers of entities, entities keep accumulating in the first-level cache, increasing memory usage. You should call flush() and clear() at regular intervals to empty the persistence context and prevent OutOfMemoryError.

## How Second-Level Cache Works

### Second-Level Cache Scope and Sharing Mechanism

The second-level cache operates at the SessionFactory or EntityManagerFactory level. As a cache shared across the entire application, it can reuse data between different transactions and user requests, significantly reducing database access. Unlike the first-level cache which is destroyed when transactions end, the second-level cache is maintained until the application terminates or is explicitly removed. When an entity is queried, it first checks the first-level cache, then the second-level cache if not found, and finally queries the database if not in the second-level cache either—a three-step query process.

To prevent concurrency issues, the second-level cache doesn't store entity instances directly but in serialized form (Disassembled State). When queried, it deserializes to create new instances, isolating changes in one session from affecting other sessions. This serialization/deserialization process incurs some overhead, but it's negligible compared to database access costs.

### Second-Level Cache Activation and Configuration

The second-level cache is an optional feature that's disabled by default. To use it, you must specify a cache provider and explicitly configure which entities to cache. In Spring Boot, activate it with `spring.jpa.properties.hibernate.cache.use_second_level_cache=true`, then add @Cacheable and Hibernate's @Cache annotations to entity classes to enable caching for individual entities.

```java
@Entity
@Cacheable // JPA standard annotation
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE, region = "users") // Hibernate annotation
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;

    @Cache(usage = CacheConcurrencyStrategy.READ_WRITE) // Collection caching
    @OneToMany(mappedBy = "user")
    private List<Order> orders = new ArrayList<>();
}
```

## Comparing Second-Level Cache Providers

### EhCache

EhCache is an open-source cache library first developed by Greg Luck in 2003. It's the oldest and most widely used combination with Hibernate, providing simple configuration, excellent performance, and rich features. Starting with EhCache 3.x, it fully implements the JSR-107 (JCache) standard, allowing cache usage with standard APIs without vendor lock-in. It can be extended to distributed cache by integrating with Terracotta, making it usable in cluster environments.

### Infinispan

Infinispan is an open-source distributed in-memory data grid developed by Red Hat, released in 2009 succeeding the JBoss Cache project. Its strengths are excellent scalability and transaction support in cluster environments. Infinispan supports both replication and distribution modes, allowing balance adjustment between data consistency and scalability. It's built into Wildfly and JBoss EAP by default, integrating naturally in the Red Hat technology stack.

### Hazelcast

Hazelcast is an in-memory data grid developed by Hazelcast Inc., founded in 2008. It features cloud-native optimized design and auto-discovery functionality, providing various distributed data structures like distributed Map, Queue, and Topic. Its strength is automatic cluster configuration in Kubernetes and cloud environments like AWS, Azure, and GCP, with very easy Spring Boot integration.

## Cache Concurrency Strategies

### READ_ONLY

The READ_ONLY strategy is used for immutable data that never changes. It provides the highest performance as no locks are needed and no concurrency issues occur. It's suitable for static reference data like code tables, country lists, and currency codes. If you attempt to modify an entity, Hibernate throws an exception to protect data integrity.

### READ_WRITE

The READ_WRITE strategy is used for data where both reads and writes occur. It uses soft locks to control concurrency and invalidates cache entries when entities are modified, ensuring data consistency. It's suitable for most common business entities and is supported by major cache providers including EhCache, Infinispan, and Hazelcast.

### NONSTRICT_READ_WRITE

The NONSTRICT_READ_WRITE strategy is used when the likelihood of concurrently modifying the same entity is low and short-term stale data can be tolerated. It doesn't use locks so performance is better than READ_WRITE, but only guarantees eventual consistency. It's suitable for configuration data or statistics information with low update frequency.

### TRANSACTIONAL

The TRANSACTIONAL strategy provides complete transaction isolation and integrates with JTA transactions to support two-phase commit, guaranteeing the strongest consistency. It has significant performance overhead and is only available with transactional cache providers like Infinispan. It's used in enterprise environments where distributed transactions are essential.

## Query Cache

Query cache is a feature that caches JPQL or Criteria API query results. It should be used with second-level cache to be effective and is activated with `spring.jpa.properties.hibernate.cache.use_query_cache=true`. Query cache stores query strings and parameters as keys and result entity identifier lists as values. Since actual entity data is retrieved from the second-level cache, it should be used together with entity caching.

The caution with query cache is that when related tables change, all query caches referencing those tables are invalidated. Caching queries on frequently changing tables causes frequent invalidation, potentially degrading performance. Therefore, query cache should be selectively applied only to frequently executed queries on rarely changing data.

## Cache Synchronization in Distributed Environments

### Local Cache Limitations

Local cache alone is sufficient in single server environments. However, in distributed environments with multiple server instances, even if one server modifies data, caches on other servers still have previous data, causing cache inconsistency. This problem can lead to serious issues where users see inconsistent data when requesting from different servers.

### Distributed Cache Solutions

Using distributed cache providers like Infinispan or Hazelcast allows cache synchronization across all nodes in the cluster. Replication mode has all nodes holding copies of the entire cache, while distribution mode stores cache entries distributed across multiple nodes. Replication mode has excellent read performance but high memory usage, while distribution mode is memory efficient but requires network calls—choose based on your situation.

### Eventual Consistency Considerations

Even in distributed caches, network delays can cause data inconsistencies between nodes for short periods—this is called eventual consistency. If strong consistency is essential, you must use the TRANSACTIONAL strategy or distributed locks. However, eventual consistency allowing short-term stale data is sufficient for most web applications.

## Cache Monitoring and Optimization

### Utilizing Cache Statistics

Hibernate provides statistics like cache hit rate, miss rate, store count, and eviction count. Enable with `spring.jpa.properties.hibernate.generate_statistics=true` and query through SessionFactory.getStatistics(). A low hit rate indicates either wrong caching target selection or early eviction due to small cache size—review your settings.

### Selecting Cache Application Targets

Second-level cache is effective only when applied to data that's frequently read but rarely modified. Caching frequently changing data can make cache invalidation overhead greater than benefits. Reference data like code tables, permission information, and categories are typical second-level cache targets. Transaction data like orders or payments should generally be excluded from caching.

## Conclusion

Hibernate's cache architecture consists of two levels: first-level cache and second-level cache. The first-level cache is a mandatory feature operating at transaction scope, where the persistence context itself serves as the first-level cache, forming the foundation for identity guarantee and dirty checking. The second-level cache is an optional feature shared across the entire application, implemented through external providers like EhCache, Infinispan, and Hazelcast. You should choose from four concurrency strategies—READ_ONLY, READ_WRITE, NONSTRICT_READ_WRITE, and TRANSACTIONAL—based on data characteristics. In distributed environments, use distributed cache providers considering cache synchronization issues, and the key to performance optimization is monitoring cache statistics and applying caching only to appropriate targets.
