---
title: "What Is a Servlet Filter?"
date: 2024-06-04T16:29:15+09:00
tags: ["spring", "servlet", "filter", "java"]
description: "Servlet Filter is an HTTP request/response preprocessing and postprocessing component introduced in Servlet 2.3 specification (2001), operating at the servlet container level to handle cross-cutting concerns such as authentication, logging, and encoding configuration"
draft: false
---

## Concept and History of Servlet Filter

Servlet Filter is a Java component first introduced in the Servlet 2.3 specification released in 2001. It intercepts HTTP requests before servlets process them and responses before they are sent to clients, enabling preprocessing and postprocessing operations. The introduction of this feature enabled developers to implement cross-cutting concerns such as authentication, logging, character encoding, and data compression in a reusable manner, separate from business logic. Filters are based on the Chain of Responsibility design pattern, allowing multiple filters to be connected in a chain and executed sequentially.

> **Servlet**
>
> A servlet is a Java server-side component that processes client HTTP requests and generates HTTP responses. It is a core technology of the Java EE (now Jakarta EE) standard and serves as the foundation for most Java web frameworks.

## Primary Use Cases for Filters

Servlet filters are utilized in various situations where requests or responses need to be modified or specific processing needs to be performed. Representative use cases include user authentication and authorization verification, request and response logging, data encryption and decryption, HTTP header manipulation, image format conversion, data compression and decompression, and custom exception handling. By implementing these functionalities as filters, common features can be applied without duplicating code across individual servlets or controllers.

## Filter Implementation Methods

### GenericFilterBean

`GenericFilterBean` is an abstract class provided by Spring Framework that implements the `javax.servlet.Filter` interface. It integrates with Spring's environment configuration, automatically setting Spring Bean properties during filter initialization. Developers override the `doFilter` method to implement logic that executes for each request.

```java
public class CustomFilter extends GenericFilterBean {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
        // Preprocessing logic
        filterChain.doFilter(request, response);
        // Postprocessing logic
    }
}
```

### OncePerRequestFilter

`OncePerRequestFilter` is a class that extends `GenericFilterBean` and guarantees execution exactly once per HTTP request. Even when the same request passes through the filter chain multiple times due to internal forwards or includes in the servlet container, this filter ensures the logic executes only on the initial pass. This makes it suitable for tasks that should be performed only once per request, such as authentication filters or logging filters.

```java
public class CustomFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // Preprocessing logic
        filterChain.doFilter(request, response);
        // Postprocessing logic
    }
}
```

## Filter Chain and Execution Order

When a request arrives, the servlet container executes registered filters sequentially according to the filter chain. After passing through all filters, it invokes the target servlet, and upon completion of servlet processing, each filter's postprocessing logic executes in reverse order. This structure is an implementation of the Chain of Responsibility pattern, allowing each filter to independently perform its role while passing control to the next filter or servlet.

Filter execution order can be specified using the `@Order` annotation or the `setOrder` method of `FilterRegistrationBean`. Lower numbers indicate higher priority and earlier execution.

```java
@Order(1)
public class FirstFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // First filter to execute
        filterChain.doFilter(request, response);
    }
}
```

## Filter Registration Methods

In Spring Boot, filters can be registered in two ways: automatic registration using the `@Component` annotation, or programmatic registration through `FilterRegistrationBean`. Using `FilterRegistrationBean` enables fine-grained control, such as applying filters only to specific URL patterns or explicitly specifying execution order.

```java
@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<LoggingFilter> loggingFilter() {
        FilterRegistrationBean<LoggingFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new LoggingFilter());
        registrationBean.addUrlPatterns("/*");
        registrationBean.setOrder(1);
        return registrationBean;
    }
}
```

## Filter vs Spring Interceptor Comparison

Servlet Filters and Spring Interceptors both intercept requests for processing, but they have fundamental differences in the layer and timing of execution. Filters operate at the servlet container level (Tomcat, Jetty, etc.) and execute before reaching the DispatcherServlet. In contrast, Interceptors execute within Spring MVC's DispatcherServlet before and after calling the Handler (controller), providing easier access to the Spring Context and enabling exception handling through @ExceptionHandler.

| Characteristic | Servlet Filter | Spring Interceptor |
|----------------|---------------|-------------------|
| Execution Layer | Servlet container level (before DispatcherServlet) | Spring MVC level (after DispatcherServlet) |
| Scope | All HTTP requests | Only requests going to Spring MVC controllers |
| Spring Context Access | Limited (DI possible but requires configuration) | Easy (automatic Spring Bean injection) |
| Exception Handling | ServletException, IOException | Can use Spring @ExceptionHandler |
| Typical Use Cases | Character encoding, CORS, security, logging | Authentication/authorization, API versioning, logging |

### Request Processing Flow

```
Client Request
    ↓
Filter 1 (preprocessing)
    ↓
Filter 2 (preprocessing)
    ↓
DispatcherServlet
    ↓
Interceptor 1 (preHandle)
    ↓
Interceptor 2 (preHandle)
    ↓
Controller
    ↓
Interceptor 2 (postHandle)
    ↓
Interceptor 1 (postHandle)
    ↓
View Rendering
    ↓
Interceptor 2 (afterCompletion)
    ↓
Interceptor 1 (afterCompletion)
    ↓
Filter 2 (postprocessing)
    ↓
Filter 1 (postprocessing)
    ↓
Client Response
```

## Practical Examples

### CORS Filter

This filter configures Cross-Origin Resource Sharing (CORS), allowing API calls from different domains by bypassing the browser's Same-Origin Policy. It handles preflight requests using the OPTIONS method.

```java
@Component
@Order(Ordered.HIGHEST_PRECEDENCE)
public class CorsFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        response.setHeader("Access-Control-Allow-Origin", "*");
        response.setHeader("Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS");
        response.setHeader("Access-Control-Allow-Headers", "Authorization, Content-Type");

        if ("OPTIONS".equalsIgnoreCase(request.getMethod())) {
            response.setStatus(HttpServletResponse.SC_OK);
            return;
        }

        filterChain.doFilter(request, response);
    }
}
```

### JWT Authentication Filter

This filter validates JSON Web Tokens and sets authentication information in Spring Security's SecurityContext. It extracts the Bearer token from the Authorization header and verifies its validity.

```java
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        String token = request.getHeader("Authorization");

        if (token != null && token.startsWith("Bearer ")) {
            token = token.substring(7);
            if (jwtUtil.validateToken(token)) {
                String username = jwtUtil.getUsernameFromToken(token);
                UsernamePasswordAuthenticationToken authentication =
                    new UsernamePasswordAuthenticationToken(username, null, Collections.emptyList());
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }

        filterChain.doFilter(request, response);
    }
}
```

## Precautions When Implementing Filters

Several important considerations must be taken into account when implementing filters. First, filter order significantly affects behavior, so it should be explicitly managed using the @Order annotation or setOrder method. Second, omitting the `filterChain.doFilter(request, response)` call prevents requests from being forwarded to the next filter or servlet. Third, exceptions occurring in filters cannot be handled by Spring's @ControllerAdvice, requiring direct try-catch handling within the filter. Fourth, since filters execute for all requests, heavy operations that could impact performance should be avoided, and filtering through URL patterns or conditional statements should be used to execute only when necessary.

## Conclusion

Since its introduction in the Servlet 2.3 specification in 2001, Servlet Filter has established itself as a core mechanism for handling cross-cutting concerns in Java web applications. Operating at the servlet container level, it can apply common functionality such as authentication, logging, encoding, and CORS configuration to all HTTP requests. The Chain of Responsibility pattern enables flexible request processing pipelines by combining multiple filters. Understanding the differences between Servlet Filters and Spring Interceptors and selecting the appropriate technology for each situation is key to effective web application development.
