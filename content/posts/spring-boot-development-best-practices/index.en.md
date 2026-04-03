---
title: "Spring Boot Development Best Practices"
date: 2024-05-25T22:56:18+09:00
tags: ["Spring", "Java", "Best Practices"]
description: "Recommended patterns and structure for Spring Boot applications."
draft: false
---

## History and Background of Layered Architecture

Layered architecture is a design pattern that emerged in 1990s enterprise application development to support the principle of separation of concerns. It was later systematized in Martin Fowler's "Patterns of Enterprise Application Architecture" (2002). The traditional three-layer architecture consists of the presentation layer, business logic layer, and data access layer. Spring Framework made this structure easy to implement through @Controller, @Service, and @Repository annotations, and it became the de facto standard for Java enterprise development.

In a Spring Boot application, layered architecture limits communication to adjacent layers, which helps reduce coupling. It also allows each layer to be tested or replaced independently, making the codebase easier for new developers to understand. Typically, a controller receives HTTP requests and calls a service, a service performs business logic and accesses data through a repository, and a repository communicates with the database to perform CRUD operations.

## Entity Design Principles

### Entity and Table Mapping

An entity is a persistence object that corresponds to a database table in JPA. It is declared with the @Entity annotation, table names are specified with @Table, and primary key generation strategies are defined with @Id and @GeneratedValue. Entity class names should be nouns that represent tables. Field names use camelCase following Java naming conventions, which can be mapped to snake_case column names through @Column's name attribute. Entities should be designed to be as immutable as possible, minimizing setter usage and creating objects through constructors or static factory methods.

```java
@Entity
@Table(name = "orders")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class Order {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false)
    private Member member;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @Column(nullable = false)
    private LocalDateTime orderDate;

    // Static factory method
    public static Order createOrder(Member member) {
        Order order = new Order();
        order.member = member;
        order.status = OrderStatus.PENDING;
        order.orderDate = LocalDateTime.now();
        return order;
    }
}
```

### Association Mapping Strategy

JPA associations should use lazy loading (FetchType.LAZY) by default to prevent N+1 problems, using fetch join or @EntityGraph for eager loading only when necessary. Bidirectional associations should manage references on both objects consistently through convenience methods, and the owning side should be set to the side with the foreign key. @ManyToMany often requires additional columns in the intermediate table, so it is recommended to decompose it into @OneToMany and @ManyToOne in practice.

## Repository Layer

### Using Spring Data JPA

A repository is the data access layer. Extending Spring Data JPA's JpaRepository automatically provides basic CRUD methods (save, findById, findAll, delete), and queries are generated according to method naming rules. Declaring method names like findByUsername, findByEmailAndStatus, or existsByEmail causes Spring Data JPA to parse the method name and generate the appropriate JPQL, so simple queries require no separate implementation.

```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    // Method name-based query
    List<Order> findByMemberIdAndStatus(Long memberId, OrderStatus status);

    // JPQL query
    @Query("SELECT o FROM Order o JOIN FETCH o.member WHERE o.id = :id")
    Optional<Order> findByIdWithMember(@Param("id") Long id);

    // Pagination query
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);
}
```

### Handling Complex Queries

Complex conditions or dynamic queries that are difficult to express with method name-based queries can be written directly in JPQL with the @Query annotation or implemented with QueryDSL for type-safe queries. QueryDSL expresses queries in Java code based on Q-type classes, which allows compile-time checking, benefits from IDE auto-completion, and makes it easier to build dynamic queries with conditional where clauses.

## Service Layer

### Implementing Business Logic

A service is the layer responsible for business logic. It usually represents a use case or business transaction and performs domain logic by coordinating repositories. Service classes are annotated with @Service, dependencies are received through constructor injection, and fields are declared final to ensure immutability. Business logic should be concentrated in the service layer rather than scattered across a controller or repository for easier testing and maintenance.

```java
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class OrderService {
    private final OrderRepository orderRepository;
    private final MemberRepository memberRepository;
    private final PaymentService paymentService;

    @Transactional
    public OrderResponse createOrder(Long memberId, OrderCreateRequest request) {
        Member member = memberRepository.findById(memberId)
            .orElseThrow(() -> new MemberNotFoundException(memberId));

        Order order = Order.createOrder(member);
        order = orderRepository.save(order);

        paymentService.processPayment(order, request.getPaymentInfo());

        return OrderResponse.from(order);
    }
}
```

### Transaction Management

The @Transactional annotation wraps method execution in a transaction, ensuring all database operations either succeed together or all roll back. The recommended pattern is to apply @Transactional(readOnly = true) at the class level and override with @Transactional only on methods with write operations. readOnly = true tells JPA that change detection is not needed, optimizing performance. Some database drivers apply read-only optimizations, and it serves as documentation that the method does not modify data.

## Controller Layer

### REST API Design

A controller is the presentation layer that receives HTTP requests and returns responses. Using the @RestController annotation causes all method return values to be serialized to JSON. URLs should be designed around resource nouns (/api/orders), with actions expressed through HTTP methods (GET, POST, PUT, DELETE), and should use path variables (@PathVariable), query parameters (@RequestParam), and the request body (@RequestBody) appropriately.

```java
@RestController
@RequestMapping("/api/orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<OrderResponse> createOrder(
            @AuthenticationPrincipal Long memberId,
            @Valid @RequestBody OrderCreateRequest request) {
        OrderResponse response = orderService.createOrder(memberId, request);
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    }

    @GetMapping("/{orderId}")
    public ResponseEntity<OrderResponse> getOrder(@PathVariable Long orderId) {
        OrderResponse response = orderService.getOrder(orderId);
        return ResponseEntity.ok(response);
    }
}
```

### Input Validation

Using @Valid annotation with Bean Validation (JSR 380) allows declarative validation of input values by adding validation annotations like @NotNull, @NotBlank, @Size, and @Email to request DTO fields. When validation fails, MethodArgumentNotValidException is thrown, which can be handled in @ExceptionHandler or @ControllerAdvice to return consistent error responses.

## DTO Design and Usage

### Separating Entity and DTO

A DTO (Data Transfer Object) is an object used to transfer data between layers or between the client and server. Using DTOs instead of directly exposing entities in API responses helps prevent entity changes from affecting the API specification, avoids circular reference problems, and allows responses to include only the necessary data. Separating request DTOs and response DTOs also allows input validation annotations and response serialization settings to be managed independently.

```java
// Request DTO
@Getter
@NoArgsConstructor
public class OrderCreateRequest {
    @NotNull
    private Long productId;

    @Min(1)
    private int quantity;

    @Valid
    @NotNull
    private PaymentInfo paymentInfo;
}

// Response DTO
@Getter
@Builder
public class OrderResponse {
    private Long orderId;
    private String status;
    private LocalDateTime orderDate;

    public static OrderResponse from(Order order) {
        return OrderResponse.builder()
            .orderId(order.getId())
            .status(order.getStatus().name())
            .orderDate(order.getOrderDate())
            .build();
    }
}
```

## Exception Handling Strategy

### Global Exception Handling

Using @ControllerAdvice and @ExceptionHandler makes it possible to handle application-wide exceptions in one place and keep error response formats consistent. Business exceptions are defined as custom exception classes that extend RuntimeException, mapping HTTP status codes and error messages to provide meaningful error information to clients.

```java
@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(EntityNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleEntityNotFound(EntityNotFoundException e) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(new ErrorResponse("NOT_FOUND", e.getMessage()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ErrorResponse> handleValidation(MethodArgumentNotValidException e) {
        String message = e.getBindingResult().getFieldErrors().stream()
            .map(error -> error.getField() + ": " + error.getDefaultMessage())
            .collect(Collectors.joining(", "));
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
            .body(new ErrorResponse("VALIDATION_ERROR", message));
    }
}
```

## Conclusion

Spring Boot applications commonly use a controller-service-repository three-layer architecture to separate responsibilities and improve testability, maintainability, and scalability. Entities favor immutable design and static factory methods, associations default to lazy loading, and repositories combine Spring Data JPA's method name-based queries with QueryDSL. The service layer concentrates business logic and manages transaction boundaries, while controllers design APIs around REST principles and handle input validation. Using DTOs helps keep the API specification stable, and global exception handling helps maintain consistent error responses across the application.
