---
title: "What is ORM (Object-Relational Mapping)?"
date: 2024-05-15T16:40:07+09:00
tags: ["ORM", "Database", "Programming", "Software Development", "Backend Development"]
draft: false
---

Developers dealing with databases will definitely have heard of ORM at least once. But many are unsure about what it is exactly and why it is used. This will help you learn about everything from ORM concepts to real-world applications.

## Table of Contents

1. ORM concepts and definitions
2. How ORM works
3. Major ORM frameworks
4. Advantages and Disadvantages of ORM
5. Real-world use cases of ORM
6. Frequently Asked Questions (FAQ)

## 1. ORM concepts and definitions

ORM (Object-Relational Mapping) is a technology that bridges object-oriented programming and relational databases. Simply put, it is a tool that automatically maps objects used in programming languages to database tables.

### Existing SQL vs ORM comparison

```sql
-- Existing SQL method
SELECT * FROM users WHERE id = 1;

-- ORM method (Python/Django example)
user = User.objects.get(id=1)
```

## 2. How ORM works

ORM works in the following way:

1. **Object mapping**: Maps classes to tables
2. **Attribute mapping**: Maps object attributes to table columns
3. **Relationship mapping**: Maps relationships between objects to relationships between tables

Example code (Java/Hibernate):

```java
@Entity
@Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private Long id;

    @Column(name = "username")
    private String username;

    @Column(name = "email")
    private String email;
}
```

## 3. Major ORM frameworks

### Java camp

-   **Hibernate**: Most widely used JPA implementation
-   **EclipseLink**: Lightweight JPA implementation
-   **MyBatis**: SQL mapping framework

### Python camp

-   **SQLAlchemy**: Representative ORM of Python
-   **Django ORM**: Basic ORM of the Django framework

### Node.js camp

-   **Sequelize**: Promise-based ORM for Node.js
-   **TypeORM**: ORM for TypeScript and JavaScript

## 4. Advantages and Disadvantages of ORM

### Advantages

1. **Increased productivity**

    - Reduces SQL writing time
    - Automates CRUD query generation

2. **Improved maintainability**

    - Allows for object-oriented code writing
    - Concentrates on business logic

3. **Database independence**
    - Minimizing code changes when changing databases

### Disadvantages

1. **Performance issues**

    - Performance degradation when executing complex queries
    - May produce unnecessary queries

2. **Learning curve**
    - Requires learning about ORM itself
    - Understanding of internal mechanisms

## 5. Real-world use cases of ORM

### Simple CRUD example (Python/SQLAlchemy)

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from models import User

# Database connection
engine = create_engine('postgresql://user:password@localhost:5432/dbname')
Session = sessionmaker(bind=engine)
session = Session()

# Create
new_user = User(name='John Doe', email='john@example.com')
session.add(new_user)
session.commit()

# Read
user = session.query(User).filter_by(name='John Doe').first()

# Update
user.email = 'john.doe@example.com'
session.commit()

# Delete
session.delete(user)
session.commit()
```

## 6. Frequently Asked Questions (FAQ)

Q: Should I always use ORM?
A: It is recommended to use it selectively depending on the size and requirements of the project.

Q: How do I solve performance issues?
A: Consider using appropriate indexing, caching, and native queries when necessary.

## Conclusion

ORM has become an essential tool in modern web development. If you properly understand its advantages and disadvantages and use it appropriately according to the project's requirements, you can significantly improve development productivity and code quality.

### Recommended resources

-   [Hibernate official documentation](https://hibernate.org/orm/documentation/5.4/)
-   [SQLAlchemy tutorial](https://docs.sqlalchemy.org/en/14/tutorial/)
-   [TypeORM guide](https://typeorm.io/#/)
