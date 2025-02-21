---
title: "Entity Relationship Diagrams (ERDs)"
date: 2024-05-25T16:02:12+09:00
draft: false
tags: ["ERD", "Database"]
---

An Entity Relationship Diagram (ERD) is a graphical representation of the structure of a database. ERDs show the relationships between tables in a database, making it easier to understand the design and structure of the database.

## Components of an ERD

An ERD is made up of the following components:

1. **Entities**
2. **Attributes**
3. **Relationships**

### Entities

An entity represents an object that you want to manage in your database. For example, a student, a professor, or a course could all be entities.

### Attributes

Attributes represent characteristics of an entity. For example, attributes of a student entity could include student ID, name, and major.

### Relationships

Relationships represent the connections between entities. For example, there could be an 'enrolls in' relationship between students and professors.

## ERD Notation

There are several different notations for ERDs, but the most widely used notation is the **IE notation**. The IE notation uses the following conventions:

-   **Entities:** Represented by rectangles. The name of the entity is written at the top of the rectangle.
-   **Attributes:** Written inside the rectangle, below the entity name. The names and data types of attributes can be included. Constraints such as PK and FK can also be included.
    ![Entity](image-1.png)
-   **Relationships:**
    1. Lines and arrows
        - Solid line: Identifying relationship
            - Relationship where a PK is used as a FK:
                - The PK of the parent table is used as the FK in the child table
        - Dashed line: Non-identifying relationship
            - Relationship where a PK is not used as a FK:
                - The PK of the parent table is not used as the FK in the child table
    2. Mapping Cardinality - Meaning: Indicates the relationship between entities and how one entity relates to another entity. - Represents relationships such as 1:1, 1:N, and N:M. - In IE notation, crow's foot notation is used.
       ![erd](image-3.png)
       The diagram above shows the following relationships:
        - A USER table can have multiple TODO tables or none at all.
        - A TODO table has only one USER table.

## Crow's Foot Notation

Relationships
Crow's foot notation is a notation for representing relationships in ERDs. Crow's foot notation uses the following symbols:
![까마귀 발](image.png)

-   **one**: When an element is one
-   **many**: When there are multiple N elements
-   **only one**: When an element is the only one
-   **zero or one**: When an element is zero or one
-   **one or many**: When an element is one or more
-   **zero or many**: When an element is zero or multiple
