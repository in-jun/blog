---
title: "EntityManager란 무엇인가?"
date: 2024-06-07T19:12:36+09:00
tags: ["jpa", "entitymanager"]
draft: false
---

> EntityManager는 엔티티의 생명주기를 관리하고 엔티티와 관련된 모든 작업을 수행한다.

## EntityManager

### 뜻

엔티티 매니저는 엔티티의 생명주기를 관리하고 엔티티와 관련된 모든 작업을 수행한다. 엔티티 매니저는 엔티티를 데이터베이스에 저장하거나 데이터베이스에서 엔티티를 읽어오는 등의 작업을 수행한다.

### 주요 기능

엔티티 매니저의 주요 기능은 다음과 같다:

1. **저장**: 엔티티를 데이터베이스에 저장한다.
2. **조회**: 데이터베이스에서 엔티티를 읽어온다.
3. **수정**: 데이터베이스에 저장된 엔티티를 수정한다.
4. **삭제**: 데이터베이스에서 엔티티를 삭제한다.

### 예제

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

`@PersistenceContext` 어노테이션을 사용하여 엔티티 매니저를 주입받을 수 있다. 엔티티 매니저를 사용하여 엔티티를 저장하거나 조회, 수정, 삭제하는 등의 작업을 수행할 수 있다. 엔티티 매니저는 트랜잭션 단위로 동작하며, 트랜잭션이 종료되면 엔티티 매니저가 자동으로 종료된다.

### 사용 예시 설명

위의 예제는 `UserRepository` 클래스에서 `EntityManager`를 주입받아 `User` 엔티티를 관리하는 코드이다.

-   `save` 메서드는 `em.persist(user)`를 사용하여 새로운 유저 엔티티를 데이터베이스에 저장한다.
-   `findById` 메서드는 `em.find(User.class, id)`를 통해 주어진 ID로 유저 엔티티를 조회한다.
-   `update` 메서드는 `em.merge(user)`를 사용하여 기존 유저 엔티티를 수정한다.
-   `delete` 메서드는 `em.remove(user)`를 통해 유저 엔티티를 삭제한다.

### 정리

-   엔티티 매니저는 엔티티의 생명주기를 관리하고 엔티티와 관련된 모든 작업을 수행한다.
-   엔티티 매니저는 트랜잭션 단위로 동작하며, 트랜잭션이 종료되면 엔티티 매니저가 자동으로 종료된다.
-   엔티티 매니저는 `@PersistenceContext` 어노테이션을 사용하여 주입받을 수 있다.
