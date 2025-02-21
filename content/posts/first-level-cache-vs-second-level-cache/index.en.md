---
title: "Understanding First-Level and Second-Level Caches"
date: 2024-06-08T03:39:05+09:00
tags: ["ORM", "java"]
draft: false
---

### First-Level Cache

**First-level cache (L1 cache)** is a cache that exists within the persistence context. When an entity is retrieved, the persistence context stores the entity in the cache. If the same entity is retrieved later on, the persistence context finds the entity in the cache and returns it.

Hence, it is only valid within a transaction, and when the transaction ends, the first-level cache is also terminated.

#### Dirty Checking

**Dirty checking** is a way of tracking changes to entities using the first-level cache. When an entity is retrieved, the persistence context stores the initial state of the entity. If the state of the entity changes later on, the persistence context tracks the changes and reflects them in the database.

### Second-Level Cache

**Second-level cache (L2 cache)** is a cache that is shared among multiple persistence contexts. The cache persists even after the persistence context is terminated, and it enables sharing of entities among multiple persistence contexts.

Hence, the second-level cache is valid across multiple transactions.

> The second-level cache can cause concurrency issues. Therefore, it is necessary to control concurrency issues by providing a copy of the object instead of the object itself, or by using locks.

#### How to Use

To use the second-level cache, you can use the `@Cacheable` annotation to cache entities. You can also use the `@Cache` annotation to change the settings of the cache.

```java
@Entity
@Cacheable
@Cache(usage = CacheConcurrencyStrategy.READ_WRITE)
public class Member {
    ...
}
```

### Cache Behavior

1. **Cache Lookup on Retrieval**:

    - When an entity is retrieved, the persistence context looks for the entity in the first-level cache.
    - If the entity is not found in the first-level cache, it looks for the entity in the second-level cache.
    - If the entity is not found in the second-level cache, it retrieves the entity from the database and stores it in both the first-level cache and the second-level cache.

2. **Cache Storage**:

    - When an entity is retrieved, the persistence context stores the entity in the first-level cache.
    - The entity stored in the first-level cache is valid until the end of the transaction.
    - The entity stored in the second-level cache is valid even after the persistence context is terminated.

3. **Cache Update**:

    - When an entity is modified, the persistence context updates the entity in both the first-level cache and the second-level cache.
    - The entities stored in the first-level cache and the second-level cache are automatically updated with the changes.

### Conclusion

To minimize database lookups and improve performance, it is important to appropriately utilize the first-level and second-level caches. The first-level cache is only valid within a transaction, while the second-level cache is valid across multiple transactions. Therefore, you can optimize performance by appropriately combining the first-level cache and the second-level cache.
