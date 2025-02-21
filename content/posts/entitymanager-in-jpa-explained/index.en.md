---
title: "What is EntityManager?"
date: 2024-06-07T19:12:36+09:00
tags: ["jpa", "entitymanager"]
draft: false
---

> EntityManager manages the lifecycle of an entity and performs all operations associated with the entity.

## EntityManager

### Meaning

An entity manager manages the lifecycle of an entity and performs all operations associated with the entity. The entity manager performs operations such as storing an entity in a database or reading an entity from a database.

### Key Features

The key features of an entity manager are as follows:

1. **Persist**: Stores an entity in a database.
2. **Query**: Reads an entity from a database.
3. **Update**: Modifies an entity stored in a database.
4. **Delete**: Removes an entity from a database.

### Example

```java
@Repository
public class UserRepository {
    @PersistenceContext
    private EntityManager em;

    public void save(User user) {
        em.persist(user);
    }

    public User findById(Long id) {
        return em.find(User.class, id);
    }

    public void update(User user) {
        em.merge(user);
    }

    public void delete(User user) {
        em.remove(user);
    }
}
```

The entity manager can be injected using the `@PersistenceContext` annotation. The entity manager can be used to perform operations such as saving, querying, modifying, and deleting entities. The entity manager operates in a transaction unit, and the entity manager is automatically closed when the transaction ends.

### Explanation of Usage Examples

The example above is the `UserRepository` class that uses `EntityManager` to manage the `User` entity.

-   The `save` method uses `em.persist(user)` to store a new user entity in the database.
-   The `findById` method uses `em.find(User.class, id)` to query the user entity with the given ID.
-   The `update` method uses `em.merge(user)` to modify an existing user entity.
-   The `delete` method uses `em.remove(user)` to delete the user entity.

### Summary

-   An entity manager manages the lifecycle of an entity and performs all operations associated with the entity.
-   An entity manager operates in a transaction unit, and the entity manager is automatically closed when the transaction ends.
-   An entity manager can be injected using the `@PersistenceContext` annotation.
