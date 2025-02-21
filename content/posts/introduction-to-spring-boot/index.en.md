---
title: "Getting to know Spring Boot"
date: 2024-05-16T22:14:17+09:00
draft: false
tags: ["Spring", "Spring boot"]
---

![spring](image.png)

### What is Spring?

> Spring is a framework based on the Java language that provides various features for developing enterprise-grade applications.

Spring has the following characteristics:

-   **Lightweight container**: Spring is a lightweight container that manages the creation of objects, their lifecycle, and dependency management.

-   **Inversion of Control (IoC)**: Spring supports Inversion of Control, which allows the Spring container to manage the creation, lifecycle, and dependency management of objects.

-   **Dependency Injection (DI)**: Spring supports Dependency Injection, which allows the Spring container to manage the dependencies between objects.

-   **Aspect-Oriented Programming (AOP)**: Spring supports Aspect-Oriented Programming, which allows key logic to be separated from common logic for management.

-   **Transaction Management**: Spring supports transaction management, which allows database operations to be processed as transaction units.

-   **Exception Handling**: Spring supports exception handling, which allows exceptions to be processed when they occur.

-   **Testing**: Spring supports testing, which allows unit tests, integration tests, and system tests to be performed.

### What is Spring Boot?

> Spring Boot is a framework that helps facilitate the development of web applications using the Spring framework.

Spring Boot has the following characteristics:

-   **Embedded server**: Spring Boot provides an embedded server (Tomcat, Jetty, Undertow) so that web applications can be executed without having to install a separate server.

-   **Auto-configuration**: Spring Boot auto-configures Spring applications with the `@SpringBootApplication` annotation.

-   **Dependency Management**: Spring Boot uses `starters` to manage dependencies. `starters` are collections of dependencies that provide specific features.

-   **Spring Boot CLI**: The Spring Boot CLI (Command Line Interface) can be used to quickly develop Spring Boot applications.

-   **Spring Boot Actuator**: Spring Boot Actuator can be used to monitor the status of applications.

-   **Spring Boot Starters**: Spring Boot Starters are collections of dependencies that provide specific features.

### What is a Spring Bean?

> A Spring bean is an object managed by the Spring container.
> Simply put, a Spring bean is an object created by the Spring container instead of using the new operator.
> The Singleton pattern is applied to create and manage Spring beans.

For example, you can register a Spring bean with the `@Component` annotation as follows:

```java
@Component
public class HelloService {
    public String sayHello() {
        return "Hello, World!";
    }
}
```

In the code above, the `HelloService` class is registered as a Spring bean with the `@Component` annotation.
Therefore, the Spring container creates and manages an instance of the `HelloService` class.

You can also register a Spring bean with the `@Bean` annotation.

```java
@Configuration
public class AppConfig {
    @Bean
    public HelloService helloService() {
        return new HelloService();
    }
}
```

And you can inject a Spring bean with the `@Autowired` annotation.

```java
@Component
public class HelloController {
    @Autowired
    private HelloService helloService;

    public String sayHello() {
        return helloService.sayHello();
    }
}
```

In the code above, the `HelloController` class injects the `HelloService` Spring bean with the `@Autowired` annotation.
Therefore, the Spring container creates an instance of the `HelloService` class and injects it into the `helloService` field of the `HelloController` class.

### Singleton Pattern

> The Singleton pattern is a design pattern that ensures that only one instance of a class is created.

Creating objects multiple times can waste memory.
Therefore, it is recommended to apply the Singleton pattern to create an object only once and then continue to use the created instance.

Singleton pattern code example

```java
public class Singleton {
    private static Singleton instance;

    private Singleton() {
    }

    public static Singleton getInstance() {
        if (instance == null) {
            instance = new Singleton();
        }
        return instance;
    }
}
```

In the code above, the `Singleton` class applies the Singleton pattern to create an object only once and then continues to use the created instance.

> Typical use cases: `Spring Bean`, `Logger`, `Runtime`

### Spring Bean Scope

> The scope of a Spring bean refers to the range of which the Spring container creates and manages the Spring bean.

![Spring Bean Scope](image-1.png)

The scope of a Spring bean can be set as follows:

-   `singleton`: The Spring container creates the Spring bean only once and then continues to use the created instance. This is the default scope.
-   `prototype`: The Spring container creates a new instance of the Spring bean each time it is requested.
-   `request`: The Spring bean is created for each HTTP request and disposed of when the request is complete.
-   `session`: The Spring bean is created for each HTTP session and disposed of when the session is complete.
-   `application`: The Spring bean is created for each servlet context and disposed of when the context is terminated.

The scope of a Spring bean can be set as follows:

```java
@Component
@Scope("prototype")
public class HelloService {
    public HelloService() {
        System.out.println("HelloService created");
    }
}
```

In the code above, the `@Scope("prototype")` annotation is used to set the scope of the `HelloService` Spring bean to `prototype`.

### What are DI, IOC, AOP?

> -   DI (Dependency Injection): Dependency Injection refers to the management of dependency relationships between objects by the Spring container.
> -   IOC (Inversion of Control): Inversion of Control refers to the management of the creation, lifecycle, and dependency management of objects by the Spring container.
> -   AOP (Aspect-Oriented Programming): Aspect-Oriented Programming refers to the separation and management of key logic and common logic.

For example, Dependency Injection can be done with the `@Autowired` annotation as follows:

```java
@Component
public class HelloController {
    @Autowired
    private HelloService helloService;

    public String sayHello() {
        return helloService.sayHello();
    }
}
```

In the code above, the `HelloController` class injects the `HelloService` Spring bean with the `@Autowired` annotation.

AOP can also be applied with the `@Aspect` annotation.

```java
@Aspect
@Component
public class LoggingAspect {
    @Before("execution(* com.example.demo..*.*(..))")
    public void logBefore(JoinPoint joinPoint) {
        System.out.println("Before: " + joinPoint.getSignature().getName());
    }
}
```

In the code above, the `LoggingAspect` class applies AOP with the `@Aspect` annotation.
And the `Before` annotation is used to set the `logBefore` method to be executed before all methods in the` com.example.demo` package are executed.
Eventually, when the `logBefore` method is executed, `Before: method name` is printed.

In this way, Spring supports DI, IOC, and AOP for managing dependencies between objects and separating and managing common logic.
