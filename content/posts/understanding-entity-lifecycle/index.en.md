---
title: "Understanding Entity Lifecycle"
date: 2024-06-08T01:18:57+09:00
tags: ["jpa", "java", "hibernate", "persistence"]
description: "A comprehensive guide to JPA entity lifecycle covering the 4 states (transient, managed, detached, removed), state transitions, EntityManager methods, and flush/clear operations in persistence context"
draft: false
---

## What is Entity Lifecycle

In JPA (Java Persistence API), the entity lifecycle refers to the series of state changes an entity object goes through from creation to destruction. These states are determined by whether the entity is managed by the persistence context and its synchronization status with the database.

Understanding entity states correctly is essential for effectively using JPA, maintaining data consistency, and optimizing performance. By grasping how EntityManager handles entities in each state, you can prevent unexpected behaviors and manage transactions safely.

## The Four States of Entity Lifecycle

### Transient (New)

The transient state is when an entity object has been created but has not yet been saved to the persistence context. It is a pure Java object with no relationship to EntityManager and is not connected to the database.

#### Characteristics

- Entity objects created with the `new` keyword are in the transient state by default
- Entities in this state are not managed by JPA, so they cannot use persistence context features like dirty checking or first-level cache
- Even when transactions commit, they are not reflected in the database

```java
// Transient state - pure object unrelated to EntityManager
User user = new User();
user.setName("Hong Gil-dong");
user.setEmail("hong@example.com");
// Not yet managed by persistence context
```

### Managed (Persistent)

The managed state is when an entity is saved to the persistence context and managed by EntityManager. The persistence context tracks changes to the entity and automatically synchronizes with the database when transactions commit.

#### Transitioning to Managed State

- Call the `persist()` method
- Retrieve from the database using `find()` or JPQL

#### Advantages of Managed State

- Stored in first-level cache
- Dirty checking is enabled
- Lazy loading is possible
- Performance optimization through write-behind

In the managed state, simply changing entity fields automatically generates UPDATE queries when transactions commit. Developers don't need to explicitly call save methods.

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

// Transient state
User user = new User();
user.setName("Hong Gil-dong");

// Transition to managed state - persist() call
em.persist(user);
// Now persistence context manages user, INSERT query executes on commit

// Retrieve managed entity
User foundUser = em.find(User.class, 1L);
// Entities retrieved via find() are also managed

// Change values in managed state - automatically generates UPDATE query
foundUser.setName("Kim Chul-soo");
// No need to call update(), automatically reflected on commit

tx.commit(); // Actual SQL execution at this point
```

### Detached

The detached state is when an entity that was previously managed is separated from the persistence context and no longer managed by EntityManager.

#### Characteristics

- Retains database identifier (ID)
- Not managed by the persistence context, so features like dirty checking and lazy loading do not work

#### Transitioning to Detached State

- Call the `detach()` method on a specific entity to make it detached
- Call `clear()` to initialize the persistence context
- Call `close()` to terminate the persistence context

To make a detached entity managed again, you must use the `merge()` method.

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user = em.find(User.class, 1L); // Managed state

// Transition to detached state - detach() call
em.detach(user);
// Now user is separated from persistence context

user.setName("Lee Young-hee"); // Changes won't be reflected in DB

tx.commit(); // Changes to detached state are ignored

// Make detached entity managed again - use merge()
tx.begin();
User mergedUser = em.merge(user);
// mergedUser is managed, user is still detached
tx.commit(); // Now changes are reflected in DB
```

### Removed

The removed state is when an entity is scheduled to be deleted from the persistence context and database.

#### Characteristics

- Calling the `remove()` method transitions an entity to the removed state
- The actual DELETE query executes in the database when the transaction commits
- Removed entities are managed by the persistence context but marked for removal from the database
- They are not actually deleted from the database until commit. Deletion can be canceled with a rollback

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user = em.find(User.class, 1L); // Managed state

// Transition to removed state - remove() call
em.remove(user);
// user is in removed state, not yet deleted from DB

tx.commit(); // Actual DELETE query execution at this point
// After commit, user is deleted
```

## Persistence Context and State Transitions

The persistence context is an environment for permanently storing entities. It is a logical space that stores and manages entities when retrieved or saved through EntityManager. It acts as a virtual repository for objects between the application and database.

### Functions of Persistence Context

- **First-level cache**: Returns cached entities without database access when repeatedly querying the same entity within a transaction
- **Dirty checking**: Automatically tracks entity changes
- **Write-behind**: Collects multiple queries to execute them at once, optimizing performance

### Flush Operation

Flush is the operation of reflecting changes in the persistence context to the database.

#### Characteristics of Flush

- Synchronizes persistence context changes with the database
- Does not empty the persistence context. Managed entities remain in the managed state

#### When Flush Occurs

- Explicitly calling `em.flush()`
- Automatically when transactions commit
- Automatically before JPQL query execution

#### Flush Process

1. Dirty checking activates to find modified entities
2. Generates modification queries and registers them in the write-behind SQL store
3. Transmits queries from the write-behind SQL store to the database

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user = new User();
user.setName("Park Min-soo");
em.persist(user); // Managed state

// Explicit flush - immediately reflect to DB
em.flush();
// INSERT query executes at this point

// user remains managed after flush
user.setName("Choi Ji-hoon"); // Can still modify

tx.commit(); // Flush occurs again on commit, UPDATE query executes
```

### Clear Operation

Clear is the operation that completely initializes the persistence context, transitioning all managed entities to the detached state.

#### Characteristics of Clear

- Calling `em.clear()` deletes all contents of the persistence context including first-level cache
- All managed entities become detached

#### When to Use Clear

- When many entities accumulate in the persistence context increasing memory usage
- To ensure isolation between tests in test code

#### Precautions After Clear

- You must re-query to use previously retrieved entities
- Changes to existing entity objects are not reflected in the database

```java
EntityManager em = entityManagerFactory.createEntityManager();
EntityTransaction tx = em.getTransaction();
tx.begin();

User user1 = em.find(User.class, 1L); // Managed state
User user2 = em.find(User.class, 2L); // Managed state

// Initialize persistence context
em.clear();
// Both user1 and user2 transition to detached state

user1.setName("Modified"); // Changes won't be reflected in DB

// Querying again returns new managed entity
User user3 = em.find(User.class, 1L); // New managed state

tx.commit();
```

## State Transition Methods

### persist() - Transient to Managed

The `persist()` method saves a transient state new entity to the persistence context, making it managed.

#### How it Works

- When an entity becomes managed, it is stored in the first-level cache
- An INSERT query executes when the transaction commits

#### Precautions When Using

- Should only be used for new entities
- Calling it on entities that already exist in the database (entities with assigned IDs) may throw exceptions
- To make detached entities managed again, use `merge()` instead of `persist()`

### merge() - Detached to Managed

The `merge()` method makes detached entities managed.

#### How it Works

1. Queries the persistence context for an entity using the detached entity's identifier
2. Merges the detached entity's values into the retrieved managed entity
3. Returns the merged managed entity

#### Important Characteristics

- `merge()` does not convert the detached entity to managed state
- It returns a new managed entity with the detached entity's values
- After calling `merge()`, you must use the returned entity
- The original detached entity remains detached

### detach() - Managed to Detached

The `detach()` method separates a specific entity from the persistence context, making it detached.

#### Effects

- Detached entities are no longer managed by the persistence context
- Dirty checking does not work
- Lazy loading is impossible

#### Use Cases

- When too many entities are managed in the persistence context and you want to separate only some
- When you don't want to reflect changes to specific entities in the database

### remove() - Managed to Removed

The `remove()` method transitions a managed entity to the removed state, scheduling it for deletion from the database when the transaction commits.

#### How it Works

- Removed entities are marked for removal in the persistence context
- A DELETE query executes on commit

#### Precautions

- Attempting to use deleted entities may throw exceptions
- It is best not to use the entity after calling `remove()`

## Conclusion

The JPA entity lifecycle is divided into four states: transient, managed, detached, and removed. Each state is transitioned through EntityManager methods and determined by whether it is managed by the persistence context and its database synchronization status.

Accurately understanding entity states provides the following benefits:

- Effectively utilize persistence context features like dirty checking and first-level cache
- Optimize performance by understanding when flush and clear operations occur
- Prevent exceptions like LazyInitializationException caused by detached states
- Safely manage entities within transaction boundaries
