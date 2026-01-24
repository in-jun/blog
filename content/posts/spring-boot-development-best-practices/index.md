---
title: "Spring Boot 개발 모범 사례"
date: 2024-05-25T22:56:18+09:00
tags: ["Spring", "Java", "개발방법론"]
description: "Spring Boot 애플리케이션 개발 시 권장되는 패턴과 구조를 설명한다."
draft: false
---

## 계층형 아키텍처의 역사와 배경

계층형 아키텍처(Layered Architecture)는 1990년대 엔터프라이즈 애플리케이션 개발에서 관심사의 분리(Separation of Concerns) 원칙을 실현하기 위해 정립된 설계 패턴으로, Martin Fowler의 "Patterns of Enterprise Application Architecture"(2002)에서 체계화되었다. 전통적인 3계층 아키텍처는 프레젠테이션 계층(Presentation Layer), 비즈니스 로직 계층(Business Logic Layer), 데이터 접근 계층(Data Access Layer)으로 구성되며, Spring Framework는 이 구조를 @Controller, @Service, @Repository 어노테이션으로 자연스럽게 구현할 수 있게 하여 자바 엔터프라이즈 개발의 사실상 표준이 되었다.

Spring Boot에서 계층형 아키텍처를 적용하면 각 계층이 인접한 계층과만 통신하도록 제한하여 결합도를 낮추고, 각 계층을 독립적으로 테스트하고 교체할 수 있게 되며, 새로운 개발자가 코드베이스를 이해하기 쉬워진다. 일반적으로 Controller는 HTTP 요청을 받아 Service를 호출하고, Service는 비즈니스 로직을 수행하며 Repository를 통해 데이터에 접근하고, Repository는 데이터베이스와 통신하여 CRUD 연산을 수행한다.

## Entity 설계 원칙

### 엔티티와 테이블 매핑

Entity는 JPA에서 데이터베이스 테이블에 대응하는 영속성 객체로, @Entity 어노테이션으로 선언하고 @Table로 테이블명을 지정하며, @Id와 @GeneratedValue로 기본 키 생성 전략을 정의한다. 엔티티 클래스명은 테이블을 나타내는 명사형으로 짓고, 필드명은 자바 네이밍 컨벤션에 따라 camelCase를 사용하되 @Column의 name 속성으로 snake_case 컬럼명과 매핑할 수 있다. 엔티티는 가능한 한 불변(immutable)으로 설계하여 setter 사용을 최소화하고, 생성자나 정적 팩토리 메서드를 통해 객체를 생성하는 것이 권장된다.

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

    // 정적 팩토리 메서드
    public static Order createOrder(Member member) {
        Order order = new Order();
        order.member = member;
        order.status = OrderStatus.PENDING;
        order.orderDate = LocalDateTime.now();
        return order;
    }
}
```

### 연관관계 매핑 전략

JPA 연관관계는 기본적으로 지연 로딩(FetchType.LAZY)을 사용해야 N+1 문제를 방지할 수 있으며, 필요한 경우에만 fetch join이나 @EntityGraph로 즉시 로딩한다. 양방향 연관관계는 편의 메서드를 통해 양쪽 객체의 참조를 일관성 있게 관리해야 하고, 연관관계의 주인(owning side)은 외래 키가 있는 쪽으로 설정한다. @ManyToMany는 중간 테이블에 추가 컬럼이 필요한 경우가 많아 실무에서는 @OneToMany와 @ManyToOne으로 풀어서 사용하는 것이 권장된다.

## Repository 계층

### Spring Data JPA 활용

Repository는 데이터 접근 계층으로, Spring Data JPA의 JpaRepository를 상속받으면 기본적인 CRUD 메서드(save, findById, findAll, delete)가 자동으로 제공되고, 메서드 이름 규칙에 따라 쿼리가 자동 생성된다. findByUsername, findByEmailAndStatus, existsByEmail 같은 메서드명을 선언하면 Spring Data JPA가 메서드명을 파싱하여 적절한 JPQL을 생성하므로 간단한 쿼리에는 별도의 구현이 필요 없다.

```java
@Repository
public interface OrderRepository extends JpaRepository<Order, Long> {
    // 메서드명 기반 쿼리
    List<Order> findByMemberIdAndStatus(Long memberId, OrderStatus status);

    // JPQL 쿼리
    @Query("SELECT o FROM Order o JOIN FETCH o.member WHERE o.id = :id")
    Optional<Order> findByIdWithMember(@Param("id") Long id);

    // 페이징 쿼리
    Page<Order> findByStatus(OrderStatus status, Pageable pageable);
}
```

### 복잡한 쿼리 처리

메서드명 기반 쿼리로 표현하기 어려운 복잡한 조건이나 동적 쿼리는 @Query 어노테이션으로 JPQL을 직접 작성하거나, QueryDSL을 사용하여 타입 안전한 쿼리를 작성한다. QueryDSL은 Q타입 클래스를 기반으로 자바 코드로 쿼리를 작성하므로 컴파일 타임에 문법 오류를 검증할 수 있고, IDE의 자동 완성을 활용할 수 있으며, 조건부로 where 절을 추가하는 동적 쿼리 작성이 용이하다.

## Service 계층

### 비즈니스 로직 구현

Service는 비즈니스 로직을 담당하는 계층으로, 하나의 유스케이스나 비즈니스 트랜잭션을 표현하며, Repository를 조합하여 도메인 로직을 수행한다. Service 클래스에는 @Service 어노테이션을 붙이고, 의존성은 생성자 주입으로 받으며, 필드는 final로 선언하여 불변성을 보장한다. 비즈니스 로직은 Service에 집중하고 Controller나 Repository에 흩어지지 않도록 해야 테스트와 유지보수가 용이해진다.

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

### 트랜잭션 관리

@Transactional 어노테이션은 메서드 실행을 트랜잭션으로 묶어 모든 데이터베이스 연산이 성공하거나 모두 롤백되도록 보장하며, 클래스 레벨에 @Transactional(readOnly = true)를 붙이고 쓰기 작업이 있는 메서드에만 @Transactional을 오버라이드하는 패턴이 권장된다. readOnly = true는 JPA에게 변경 감지를 하지 않아도 됨을 알려주어 성능을 최적화하고, 일부 데이터베이스 드라이버는 읽기 전용 최적화를 적용하며, 명시적으로 해당 메서드가 데이터를 변경하지 않음을 문서화하는 효과가 있다.

## Controller 계층

### REST API 설계

Controller는 HTTP 요청을 받아 응답을 반환하는 프레젠테이션 계층으로, @RestController 어노테이션을 사용하면 모든 메서드의 반환값이 JSON으로 직렬화된다. URL은 리소스 명사형으로 설계하고(/api/orders), HTTP 메서드(GET, POST, PUT, DELETE)로 행위를 표현하며, 경로 변수(@PathVariable), 쿼리 파라미터(@RequestParam), 요청 본문(@RequestBody)을 적절히 활용한다.

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

### 입력 값 검증

@Valid 어노테이션과 Bean Validation(JSR 380)을 사용하면 요청 DTO의 필드에 @NotNull, @NotBlank, @Size, @Email 같은 검증 어노테이션을 붙여 입력 값을 선언적으로 검증할 수 있다. 검증에 실패하면 MethodArgumentNotValidException이 발생하며, @ExceptionHandler나 @ControllerAdvice에서 이를 처리하여 일관된 오류 응답을 반환할 수 있다.

## DTO 설계와 활용

### Entity와 DTO 분리

DTO(Data Transfer Object)는 계층 간 또는 클라이언트-서버 간 데이터 전송에 사용하는 객체로, Entity를 직접 API 응답으로 노출하지 않고 DTO를 사용해야 하는 이유는 Entity의 변경이 API 스펙에 영향을 주지 않도록 하고, 순환 참조 문제를 방지하며, 응답에 필요한 데이터만 선택적으로 포함할 수 있기 때문이다. 요청 DTO(Request)와 응답 DTO(Response)를 분리하면 입력 검증 어노테이션과 응답 직렬화 설정을 각각 독립적으로 관리할 수 있다.

```java
// 요청 DTO
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

// 응답 DTO
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

## 예외 처리 전략

### 전역 예외 처리

@ControllerAdvice와 @ExceptionHandler를 사용하면 애플리케이션 전역에서 발생하는 예외를 한 곳에서 처리하여 일관된 오류 응답 형식을 유지할 수 있다. 비즈니스 예외는 RuntimeException을 상속받아 커스텀 예외 클래스로 정의하고, HTTP 상태 코드와 오류 메시지를 매핑하여 클라이언트에게 의미 있는 오류 정보를 전달한다.

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

## 결론

Spring Boot 애플리케이션은 Controller-Service-Repository의 3계층 아키텍처를 기반으로 각 계층의 책임을 명확히 분리하여 테스트 용이성, 유지보수성, 확장성을 확보한다. Entity는 불변 설계와 정적 팩토리 메서드를 활용하고, 연관관계는 지연 로딩을 기본으로 설정하며, Repository는 Spring Data JPA의 메서드명 기반 쿼리와 QueryDSL을 조합하여 사용한다. Service 계층은 비즈니스 로직을 집중시키고 트랜잭션 경계를 관리하며, Controller는 REST 원칙에 따라 API를 설계하고 입력 검증을 수행한다. DTO로 Entity를 캡슐화하여 API 스펙의 안정성을 확보하고, 전역 예외 처리로 일관된 오류 응답을 제공하는 것이 견고한 Spring Boot 애플리케이션 개발의 핵심이다.
