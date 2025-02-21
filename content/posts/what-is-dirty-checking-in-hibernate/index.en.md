---
title: "Understanding Dirty Checking"
date: 2024-06-08T02:47:28+09:00
tags: ["ORM", "java"]
draft: false
---

### What is Dirty Checking?

**Dirty Checking** is a mechanism in JPA (Java Persistence API) that automatically detects changes made to an entity and propagates those changes to the database. With Dirty Checking, developers can modify the state of an object without having to explicitly write database update queries.

It's important to note that Dirty Checking only applies to entities managed by the Persistence Context.

### How Dirty Checking Works

1. Entity Management:

-   Entities are managed by an EntityManager.
-   The Persistence Context stores the initial state of the entities.

2. Change Detection:

-   Before a transaction is committed, JPA compares the current state of an entity with its initial state.

3. Applying Changes:

-   If any changes are detected, JPA automatically generates and executes database update queries.
-   When the transaction is committed, the changes are propagated to the database.

### Example

```java
// Saving the entity
Member member = new Member("Alice");
memberRepository.save(member);

// Retrieving the entity
Member findMember = memberRepository.findById(member.getId()).get();

// Modifying the entity
findMember.setName("Bob");

// Change detection
// Dirty Checking kicks in and automatically generates and executes a database update query.
// UPDATE member SET name = 'Bob' WHERE id = 1;
```

### Advantages

-   **Convenience**: Developers only need to modify the state of the object, without having to write database update queries.
-   **Consistency**: Data consistency is maintained as changes are automatically propagated to the database.
-   **Productivity**: It improves productivity as developers can focus on business logic.
