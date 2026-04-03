---
title: "Getting Started with Spring Boot"
date: 2024-05-16T22:14:17+09:00
tags: ["Spring", "Java", "Framework"]
description: "Spring Boot fundamentals and project setup."
draft: false
---

## History and Background of Spring Framework

Spring Framework is a Java-based enterprise application framework that first appeared in 2003. Its core ideas were introduced earlier by Rod Johnson in his 2002 book "Expert One-on-One J2EE Design and Development." Spring emerged as an alternative to the complex and heavyweight EJB (Enterprise JavaBeans) 2.x model of the time, promoting a lighter approach built on POJOs (Plain Old Java Objects). EJB 2.x was tightly coupled to application containers, made unit testing difficult, and relied heavily on XML configuration. Spring addressed those problems by making IoC (Inversion of Control) and DI (Dependency Injection) its central concepts, which reduced coupling and improved testability.

Spring Framework has continued to evolve since the official 1.0 release in 2004. Spring 2.0 in 2006 added XML namespaces and annotation support. Spring 3.0 in 2009 expanded Java 5-based annotation configuration (@Configuration, @Bean) and REST support. Spring 4.0 in 2013 added support for Java 8 lambdas and WebSocket. The current Spring 6.0 (2022) uses Java 17 by default, adopts Jakarta EE 9+ namespaces (using jakarta.* instead of javax.*), and expands GraalVM native image support for cloud-native optimization.

## Birth and Philosophy of Spring Boot

Spring Boot is a framework released by Pivotal (now VMware) in 2014 to automate complex configuration in Spring Framework-based applications and support rapid prototyping. Built around the "Convention over Configuration" philosophy, it lets developers focus more on business logic. Before Spring Boot, creating a Spring MVC web application often required dozens or even hundreds of lines of XML in files such as web.xml, applicationContext.xml, and dispatcher-servlet.xml. Developers also had to install external servlet containers like Tomcat or Jetty separately and deploy WAR files.

Spring Boot's core features are auto-configuration, embedded servers, starter dependencies, and Actuator. Auto-configuration detects libraries on the classpath and automatically registers the beans required for those technologies. Embedded servers such as Tomcat, Jetty, and Undertow are packaged with the application, so it can run with the java -jar command. Starter dependencies bundle related libraries into single dependencies, which helps avoid version compatibility issues. Actuator provides application status, metrics, and health check endpoints for easier monitoring in production environments.

## Spring IoC Container and Dependency Injection

### Inversion of Control (IoC)

Inversion of Control is a design principle in which the framework, rather than the developer, manages the program's control flow. In a more traditional style, developers create objects directly and wire them together by hand. With IoC, the framework takes responsibility for object creation and lifecycle management, calling application code at the appropriate time. Spring's IoC container (ApplicationContext) reads bean definitions to create objects, inject dependencies, and manage bean initialization and destruction. This reduces coupling between objects and makes testing and maintenance easier.

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

A Spring Bean is a Java object managed by the Spring IoC container. The container manages the entire lifecycle, including creation, dependency injection, initialization, and destruction. Beans can be detected through component scanning with stereotype annotations like @Component, @Service, @Repository, and @Controller, or explicitly registered through @Bean methods in @Configuration classes. Spring Boot's @ComponentScan (included in @SpringBootApplication) automatically scans all components in the base package and its subpackages.

### Bean Scopes

Bean scope defines how long a bean instance lives and where it is shared. In the default singleton scope, only one instance is created per Spring container and shared across all requests. Prototype scope creates a new instance each time a bean is requested. In web environments, request, session, and application scopes are also available, and their lifecycles are tied to HTTP requests, HTTP sessions, and servlet contexts respectively.

| Scope | Description | Lifecycle |
|-------|-------------|-----------|
| singleton | One instance per container (default) | Container start ~ shutdown |
| prototype | New instance per request | Not managed after creation |
| request | Created per HTTP request | Request start ~ end |
| session | Created per HTTP session | Session creation ~ expiration |
| application | Created per servlet context | Context start ~ shutdown |

## AOP (Aspect-Oriented Programming)

### Concepts and Terminology of AOP

AOP (Aspect-Oriented Programming) is a programming paradigm that modularizes cross-cutting concerns. It separates code shared across multiple modules, such as logging, transaction management, security, and caching, from core business logic. Key AOP terms include Aspect (a class that modularizes cross-cutting concerns), Join Point (a point where advice can be applied), Pointcut (an expression that selects join points), Advice (code executed at specific join points), and Weaving (the process of applying aspects to target objects). Spring AOP performs weaving by generating proxies at runtime.

### Types of Advice

Spring AOP provides five advice types. @Before executes before the target method, @AfterReturning executes after a normal return, @AfterThrowing executes when an exception occurs, and @After executes regardless of whether the method completes normally or exceptionally. @Around can control both before and after target method execution. It is the most powerful form of advice because it can decide whether to execute the method, manipulate return values, and handle exceptions. However, for simple tasks, using the most appropriate advice usually improves readability.

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

Spring Boot's auto-configuration is activated by the @EnableAutoConfiguration annotation (included in @SpringBootApplication). It conditionally loads configuration classes defined in the META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports file of the spring-boot-autoconfigure module. Each auto-configuration class uses conditional annotations such as @ConditionalOnClass, @ConditionalOnMissingBean, and @ConditionalOnProperty. These conditions activate configuration only when the required classes are on the classpath, specific beans are missing, or certain properties are set. If developers have already configured those beans explicitly, auto-configuration backs off and developer settings take precedence.

### Starter Dependencies

Starter dependencies bundle the libraries needed for specific functionality into a single dependency. spring-boot-starter-web includes the dependencies needed for web development, such as Spring MVC, embedded Tomcat, and Jackson JSON. spring-boot-starter-data-jpa includes JPA-related dependencies such as Spring Data JPA, Hibernate, and HikariCP. Using starters removes the need to manage individual library versions manually. Compatible versions are supplied through the spring-boot-dependencies BOM (Bill of Materials), which helps prevent version conflicts.

## Conclusion

Spring Framework emerged in 2003 as an alternative to the complexity of EJB, reshaping Java enterprise development through IoC and DI. Spring Boot, released in 2014, greatly reduced configuration overhead through auto-configuration and embedded servers, creating a better environment for microservices and cloud-native development. At the core of Spring is dependency injection through the IoC container, which reduces coupling between objects and improves testability. Bean scopes and AOP support declarative management of object lifecycles and cross-cutting concerns. Spring Boot starters and auto-configuration let developers focus on business logic, while Actuator supports monitoring and management in production environments.
