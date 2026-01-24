---
title: "Understanding the JPA N+1 Query Problem"
date: 2024-06-08T02:17:46+09:00
tags: ["JPA", "ORM", "Performance"]
description: "JPA N+1 query problem causes and solutions."
draft: false
---

### What is the N+1 Problem?

The **N+1 problem** is a common performance issue in Object-Relational Mapping (ORM) where N additional queries are executed when retrieving associated entities. As a result, the total number of queries becomes N+1. When the number of queries increases, database communication multiplies, network round-trip time grows, and there is a risk of database connection pool exhaustion, which can significantly degrade performance.

### History and Background of the N+1 Problem

The N+1 problem emerged alongside ORM frameworks and is particularly common when using Lazy Loading strategies in Hibernate and JPA. ORM frameworks adopt lazy loading as the default strategy to handle data in an object-oriented manner by deferring the loading of associated entities until needed. This approach has advantages such as preventing unnecessary data loading and improving initial loading speed. However, when developers access associated entities inside loops without recognizing the relationships, individual queries are executed for each entity, causing the N+1 problem. This has remained a critical performance issue that developers must be aware of from the early versions of Hibernate to the present.

### N+1 Problem Occurrence Scenarios

#### Occurrence in 1:N Relationships

The most common case occurs in 1:N relationships where one parent entity has multiple child entities. For example, in the relationship between Team and Member, if you retrieve a list of teams and then access each team's member list, additional queries are executed equal to the number of teams. If there are 100 teams, 1 team retrieval query and 100 member retrieval queries will be executed.

#### Occurrence in N:M Relationships

The N+1 problem can also occur in many-to-many (N:M) relationships. In cases like the relationship between Student and Course connected through an intermediate table, if you retrieve a list of students and then access the list of courses each student is taking, additional queries are executed equal to the number of students.

#### Occurrence in Nested Associations

When associations are nested in multiple levels (e.g., A -> B -> C), the N+1 problem can become more severe. For example, in the relationship Department -> Team -> Member, if you retrieve a list of departments and then access teams for each department and members for each team, queries equal to the number of departments + (departments × teams) + (departments × teams × members) can be executed.

### How it Works

1. The first query retrieves the entities.

```java
List<Member> members = memberRepository.findAll();
```

2. For each retrieved entity, additional queries are executed when used.

```java
for (Member member : members) {
    System.out.println(member.getTeam().getName());
}
```

3. Additional queries are executed equal to the number of associated entities.

```sql
SELECT * FROM Team WHERE team_id = 1;
SELECT * FROM Team WHERE team_id = 2;
SELECT * FROM Team WHERE team_id = 3;
...
```

### Performance Impact Analysis

The performance impact of the N+1 problem increases exponentially with the amount of data. For example, when retrieving 100 members and accessing each member's team information, one optimized join query takes about 10ms, but 101 individual queries take a total of 505ms even if each takes an average of 5ms, resulting in more than 50 times the performance difference. A more serious problem is that each query uses a database connection and incurs network round-trip time (RTT), which can deplete the database connection pool. In environments with many concurrent users, other requests may wait for connections or experience timeouts.

### Solution

> Attempting to solve the N+1 problem using Eager Loading can degrade performance by always loading all associations. Therefore, it is better to selectively resolve it only when needed using Fetch Join, Batch Fetch, EntityGraph, etc.

#### Fetch Join Details

Fetch Join is a feature provided by JPQL that retrieves associated entities in one query through SQL join. Regular JOIN does not actually load the associated entity and only uses it in the condition clause, but JOIN FETCH immediately loads the associated entity, stores it together in the persistence context, and allows it to be used without additional queries.

```java
@Query("SELECT m FROM Member m JOIN FETCH m.team")
List<Member> findAllWithTeam();
```

When using Fetch Join, be aware that using it with pagination can cause performance issues by processing pagination in memory. When Fetch Joining collections, duplicate data can occur due to Cartesian product, so the DISTINCT keyword should be used. Fetch Joining more than one collection can cause MultipleBagFetchException, so only Fetch Join one collection and use Batch Fetch for the rest.

#### @BatchSize Details

@BatchSize is a batch processing method that retrieves multiple associated entities at once using IN clause instead of individual queries. For example, if 100 members belong to different teams and BatchSize is set to 10, it groups 10 team IDs and retrieves them with IN clause, executing a total of 1 member retrieval query and 10 team retrieval queries.

```java
@Entity
public class Member {
    @ManyToOne(fetch = FetchType.LAZY)
    @BatchSize(size = 100)
    private Team team;
}
```

BatchSize can be applied to individual fields or globally by setting hibernate.default_batch_fetch_size in application.properties. The appropriate batch size depends on data characteristics and environment, but values between 10 and 1000 are commonly used. Mid-range sizes like 50 or 100 are popular choices. The decision should consider the maximum length limit of IN clause and memory usage.

#### @EntityGraph Details

@EntityGraph is a feature supported since JPA 2.1 that allows dynamic specification of which associations to load together in a specific query. EntityGraph uses the attributePaths property to specify attributes to load together. Multi-level associations can be expressed by separating them with dots (.). You can also define @NamedEntityGraph on the entity class for reuse.

```java
@EntityGraph(attributePaths = {"team"})
@Query("SELECT m FROM Member m")
List<Member> findAllWithTeam();
```

EntityGraph has two types: FETCH and LOAD. FETCH type loads attributes specified in attributePaths as EAGER and the rest as LAZY. LOAD type loads attributes specified in attributePaths as EAGER and follows the strategy set in the entity for the rest.

#### Direct DTO Retrieval

You can also directly retrieve only the necessary data as DTOs using the new keyword in JPQL. This method does not load the entity graph but SELECTs only the required columns and puts them in DTOs. This prevents unnecessary data loading and reduces memory usage.

```java
@Query("SELECT new com.example.dto.MemberDto(m.id, m.name, t.name) " +
       "FROM Member m JOIN m.team t")
List<MemberDto> findAllMemberDto();
```

#### Solving with QueryDSL

QueryDSL is a framework that supports type-safe query writing. You can apply Fetch Join using the fetchJoin() method. It is more convenient than JPQL when writing complex conditions and dynamic queries. It can also verify errors at compile time.

#### Using Native Query

When complex joins or database-specific features are needed, you can write SQL directly using Native Query. This method gives up ORM abstraction but allows writing optimized queries. You can utilize all database features.

#### Read-Only Transaction

Using @Transactional(readOnly = true) prevents Hibernate from creating snapshots for change detection, reducing memory usage. Depending on the database, read-only optimizations may be applied to improve performance. It is recommended to always apply this option to read-only service methods.

### Practical Tips and Monitoring

#### Activating Hibernate Statistics

Activating Hibernate Statistics allows collecting various statistical information such as the number of queries executed, connection acquisition time, and entity loading count. This helps identify whether the N+1 problem is occurring and monitor performance.

```properties
spring.jpa.properties.hibernate.generate_statistics=true
```

#### Checking Query Logs

Activating show_sql and format_sql in application.properties outputs executed SQL to the console for verification. In development environments, it is good to always activate these to monitor what queries are being executed.

```properties
spring.jpa.show-sql=true
spring.jpa.properties.hibernate.format_sql=true
spring.jpa.properties.hibernate.use_sql_comments=true
```

#### Query Monitoring with p6spy

p6spy is a library that wraps the JDBC driver to log all executed SQL and binding parameters. It can confirm the actual executed SQL with parameters bound, making it very useful for debugging. It also measures query execution time, helping with performance analysis.

#### Using Profiling Tools

In production environments, you can use APM (Application Performance Monitoring) tools or database profilers to monitor query performance in real-time. You can identify slow queries for optimization. You can quickly find points where the N+1 problem occurs.

### Conclusion

The N+1 problem is a performance issue inevitably encountered when using lazy loading and associations in ORM. If developers are not aware of this problem, performance can degrade exponentially as data increases. However, by appropriately utilizing various solutions such as Fetch Join, @BatchSize, and @EntityGraph, the problem can be effectively resolved. By continuously managing performance through query logging and monitoring tools, you can operate stable applications.
