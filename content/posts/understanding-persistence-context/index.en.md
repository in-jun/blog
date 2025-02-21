---
title: "Understanding the Persistence Context"
date: 2024-06-08T03:12:19+09:00
tags: ["ORM", "java"]
draft: false
---

### What is a Persistence Context

The **Persistence Context** in Java Persistence API (JPA) refers to an environment that manages entities. It keeps track of entities and their state changes in relation to the database. The Persistence Context is handled by an Entity Manager.

### Key Functions of a Persistence Context

1. **Entity Management**:

    - An EntityManager manages entities.
    - The Persistence Context stores the initial state of an entity.

2. **Transaction Association**:

    - The Persistence Context’s lifecycle is tied to a transaction.
    - When a transaction is committed, changes made to entities managed by the Persistence Context are reflected in the database.

3. **Dirty Checking**:

    - The Persistence Context tracks changes made to entities.
    - Before a transaction is committed, JPA compares an entity’s current state with its initial state.
    - If changes are detected, JPA automatically generates and executes a database update query.

### How the Persistence Context Works

1. **Entity Management**:

    - When an entity is inserted into the Persistence Context, it becomes persistent.
    - A persistent entity’s changes are automatically propagated to the database.

2. **Entity Retrieval**:

    - When an entity is retrieved, the Persistence Context first checks its cache for the entity.
    - If the entity is not in the cache, it is fetched from the database and added to the cache.

3. **Entity Modification**:

    - If the state of an entity is modified, the Persistence Context tracks the change.
    - When a change is detected, JPA automatically generates and executes a database update query.
    - This process is called **Dirty Checking**.

### Advantages of a Persistence Context

-   **Performance**: Provides caching, so subsequent retrievals of the same entity are served from the cache instead of hitting the database again.
-   **Consistency**: Ensures data consistency as changes are automatically reflected in the database.
-   **Convenience**: Developers don’t have to write database update queries; just modify the object’s state.
