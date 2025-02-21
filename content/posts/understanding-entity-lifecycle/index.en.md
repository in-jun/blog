---
title: "Understanding Entity Lifecycle"
date: 2024-06-08T01:18:57+09:00
tags: ["jpa", "java"]
draft: false
---

## Entity Lifecycle

In JPA (Java Persistence API), the entity lifecycle refers to the process from when an entity is created until it is destroyed.

### 4 States of Entity Lifecycle

1. New/Transient:

    - A new entity is created, but it is not yet managed by an EntityManager.
    - It is not stored in the database and is not managed by the persistence context.
    - Entities created with the `new` keyword are in the transient state.

2. Managed:

    - The state in which an entity is managed by an EntityManager, and is stored in the persistence context.
    - The entity is synchronized with the database and is managed by the persistence context.
    - You can make an entity managed by using the `persist()` method.

3. Detached:

    - The state in which an entity is not managed by a persistence context.
    - It is separated from the managed state and is not managed by the persistence context.
    - You can make an entity detached by using the `detach()` method.

4. Removed:

    - The state in which an entity is marked as deleted in the persistence context, but not yet deleted in the database.
    - It will be deleted from the database when the next transaction is committed.
    - You can make an entity removed by using the `remove()` method.

## Conclusion

The entity lifecycle consists of four states: new/transient, managed, detached, and removed. Depending on the state of the entity, actions such as storing in the persistence context or deleting are performed.
