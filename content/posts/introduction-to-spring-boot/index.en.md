---
title: "Getting Started with Spring Boot"
date: 2024-05-16T22:14:17+09:00
tags: ["Spring", "Java", "Framework"]
description: "Spring Boot fundamentals and project setup."
draft: false
---

## History and Background of Spring Framework

Spring Framework is a Java-based enterprise application framework first released in 2003, based on ideas Rod Johnson presented in his 2002 book "Expert One-on-One J2EE Design and Development." It emerged as an alternative to the complex and heavyweight EJB (Enterprise JavaBeans) 2.x at the time, proposing a lightweight development approach based on POJOs (Plain Old Java Objects). EJB 2.x was tightly coupled to containers, making unit testing difficult, required extensive XML configuration, and had low development productivity. Spring addressed these issues by making IoC (Inversion of Control) and DI (Dependency Injection) its core concepts, reducing coupling between objects and improving testability.

Spring Framework has continuously evolved since the official 1.0 release in 2004. Spring 2.0 in 2006 added XML namespaces and annotation support. Spring 3.0 in 2009 strengthened Java 5-based annotation configuration (@Configuration, @Bean) and REST support. Spring 4.0 in 2013 began supporting Java 8 lambdas and WebSocket. The current Spring 6.0 (2022) uses Java 17 as default, adopts Jakarta EE 9+ namespaces (using jakarta.* instead of javax.*), and strengthens GraalVM native image support for optimization in cloud-native environments.

## Birth and Philosophy of Spring Boot

Spring Boot is a framework released by Pivotal (now VMware) in 2014 to automate complex configuration for Spring Framework-based applications and enable rapid prototyping. Following the "Convention over Configuration" philosophy, it allows developers to focus on business logic. Before Spring Boot, creating a Spring MVC web application required dozens to hundreds of lines of XML configuration in files like web.xml, applicationContext.xml, and dispatcher-servlet.xml. Developers also had to separately install external servlet containers like Tomcat or Jetty and deploy WAR files.

Spring Boot's core features are Auto-configuration, Embedded Server, Starter Dependencies, and Actuator. Auto-configuration detects libraries on the classpath and automatically registers beans needed for those technologies. Embedded servers include Tomcat, Jetty, or Undertow within the JAR file, enabling application execution with the java -jar command. Starter dependencies bundle related libraries into single dependencies, solving version compatibility issues. Actuator provides application status, metrics, and health check endpoints for easy monitoring in production environments.

## Spring IoC Container and Dependency Injection

### Inversion of Control (IoC)

Inversion of Control is a design principle where the framework, not the developer, manages the program's control flow. In traditional programming, developers directly create objects and call methods. In IoC, the framework manages object creation and lifecycle, calling the developer's code at appropriate times. Spring's IoC container (ApplicationContext) reads bean definitions to create objects, inject dependencies, and manage bean initialization and destruction. This reduces coupling between objects and facilitates testing and maintenance.

### Dependency Injection (DI)

Dependency Injection is a pattern where objects receive their dependencies from external sources. Since the container injects dependencies rather than objects creating or finding them directly, loose coupling is achieved. Spring supports three injection methods: Constructor Injection, Setter Injection, and Field Injection. Since Spring 4.3, @Autowired can be omitted for single constructors. Constructor injection is currently recommended for immutability and testability.

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;

    // Constructor injection - @Autowired can be omitted (single constructor)
    public OrderService(OrderRepository orderRepository, PaymentService paymentService) {
        this.orderRepository = orderRepository;
        this.paymentService = paymentService;
    }
}
```

## Spring Beans and Bean Scopes

### Concept of Spring Beans

A Spring Bean is a Java object managed by the Spring IoC container. The container manages the entire lifecycle including creation, dependency injection, initialization, and destruction. Beans can be auto-scanned using stereotype annotations like @Component, @Service, @Repository, and @Controller, or explicitly registered through @Bean methods in @Configuration classes. Spring Boot's @ComponentScan (included in @SpringBootApplication) automatically scans all components in the base package and subpackages.

### Bean Scopes

Bean Scope defines the range in which bean instances exist. In the default Singleton scope, only one instance is created per Spring container and shared across all requests. Prototype scope creates a new instance each time a bean is requested. In web environments, Request, Session, and Application scopes are additionally provided, sharing lifecycles with HTTP requests, HTTP sessions, and servlet contexts respectively.

| Scope | Description | Lifecycle |
|-------|-------------|-----------|
| singleton | One instance per container (default) | Container start ~ shutdown |
| prototype | New instance per request | Not managed after creation |
| request | Created per HTTP request | Request start ~ end |
| session | Created per HTTP session | Session creation ~ expiration |
| application | Created per servlet context | Context start ~ shutdown |

## AOP (Aspect-Oriented Programming)

### Concepts and Terminology of AOP

AOP (Aspect-Oriented Programming) is a programming paradigm that modularizes cross-cutting concerns. It separates code that repeats across multiple modules—like logging, transaction management, security, and caching—from core business logic. Key AOP terms include Aspect (a class that modularizes cross-cutting concerns), Join Point (a point where advice can be applied), Pointcut (an expression that selects join points), Advice (code executed at specific join points), and Weaving (the process of applying aspects to target objects). Spring AOP performs weaving by generating proxies at runtime.

### Types of Advice

Spring AOP provides five Advice types. @Before executes before the target method, @AfterReturning after normal return, @AfterThrowing when an exception occurs, @After executes regardless of normal or exceptional completion, and @Around can control both before and after target method execution. @Around is the most powerful, able to control everything including whether to execute the method, manipulate return values, and handle exceptions. However, for simple tasks, using purpose-appropriate advice improves code readability.

```java
@Aspect
@Component
public class PerformanceAspect {

    @Around("execution(* com.example.service.*.*(..))")
    public Object measureExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        Object result = joinPoint.proceed();
        long executionTime = System.currentTimeMillis() - start;
        System.out.println(joinPoint.getSignature() + " execution time: " + executionTime + "ms");
        return result;
    }
}
```

## Spring Boot Auto-Configuration

### How Auto-Configuration Works

Spring Boot's Auto-configuration is activated by the @EnableAutoConfiguration annotation (included in @SpringBootApplication). It conditionally loads configuration classes defined in the META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports file of the spring-boot-autoconfigure module. Each auto-configuration class uses conditional annotations like @ConditionalOnClass, @ConditionalOnMissingBean, and @ConditionalOnProperty to activate only when specific classes exist on the classpath, specific beans don't exist, or specific properties are set. If developers have explicitly configured beans, auto-configuration backs off and developer settings take precedence.

### Starter Dependencies

Starter Dependencies bundle all libraries needed for specific functionality into a single dependency. spring-boot-starter-web includes dependencies needed for web development like Spring MVC, embedded Tomcat, and Jackson JSON. spring-boot-starter-data-jpa includes JPA-related dependencies like Spring Data JPA, Hibernate, and HikariCP. Using starters eliminates the need to manage individual library versions, as compatible versions managed by the spring-boot-dependencies BOM (Bill of Materials) are automatically applied, preventing version conflict issues.

## Conclusion

Spring Framework emerged in 2003 as an alternative to EJB's complexity, changing the paradigm of Java enterprise development through IoC and DI. Spring Boot, released in 2014, dramatically reduced configuration complexity through auto-configuration and embedded servers, providing an optimized environment for microservices and cloud-native development. Spring's core is dependency injection through the IoC container, reducing coupling between objects and improving testability. Bean scopes and AOP enable declarative management of object lifecycles and cross-cutting concerns. Spring Boot starters and auto-configuration allow developers to focus on business logic, while Actuator facilitates monitoring and management in production environments, making Spring the de facto standard for modern Java backend development.
