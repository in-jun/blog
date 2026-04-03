---
title: "Servlet Filter"
date: 2024-06-04T16:29:15+09:00
tags: ["Spring", "Java", "Servlet"]
description: "Servlet filter operation and usage."
draft: false
---

## Servlet Filter Basics and History

A servlet filter is a Java component introduced in the Servlet 2.3 specification in 2001. It intercepts HTTP requests before servlets handle them and responses before they are returned to clients, making it useful for preprocessing and postprocessing tasks. This makes it easier to implement cross-cutting concerns such as authentication, logging, character encoding, and data compression in a reusable way separate from business logic. Filters are based on the Chain of Responsibility design pattern, so multiple filters can be linked together and executed in sequence.

> **Servlet**
>
> A servlet is a Java server-side component that processes client HTTP requests and generates HTTP responses. It is a core technology of the Java EE (now Jakarta EE) standard and serves as the foundation for most Java web frameworks.

## Primary Use Cases for Filters

Servlet filters are useful when requests or responses need to be modified, or when shared processing should happen before or after request handling. Common use cases include authentication and authorization checks, request and response logging, data encryption and decryption, HTTP header manipulation, image format conversion, data compression and decompression, and custom exception handling. By implementing these concerns as filters, common functionality can be applied without duplicating code across individual servlets or controllers.

## Filter Implementation Methods

### GenericFilterBean

`GenericFilterBean` is an abstract class provided by Spring Framework that implements the `javax.servlet.Filter` interface. It integrates with Spring's configuration model, allowing bean properties to be applied during filter initialization. Developers override the `doFilter` method to implement logic that runs for each request.

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

`OncePerRequestFilter` is a class that extends `GenericFilterBean` and guarantees execution exactly once per HTTP request. Even if the same request passes through the filter chain multiple times because of a forward or include inside the servlet container, this filter runs its logic only on the first pass. This makes it suitable for tasks that should happen only once per request, such as authentication or logging.

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

When a request arrives, the servlet container executes registered filters sequentially according to the filter chain. After the request passes through all filters, the container invokes the target servlet. When servlet processing finishes, each filter runs its postprocessing logic in reverse order. This structure implements the Chain of Responsibility pattern, allowing each filter to perform its role independently while passing control to the next filter or servlet.

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

In Spring Boot, filters can be registered in two ways: by using the `@Component` annotation for automatic registration or by using `FilterRegistrationBean` for programmatic registration. `FilterRegistrationBean` provides finer control, such as applying filters only to specific URL patterns or explicitly setting execution order.

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

Servlet filters and Spring interceptors both intercept requests for processing, but they differ in where they run and when they execute. Filters operate at the servlet container level (Tomcat, Jetty, and similar servers) and run before the request reaches the `DispatcherServlet`. In contrast, interceptors run within Spring MVC after the `DispatcherServlet` identifies the handler and before or after controller execution. That gives them easier access to the Spring context and controller-level information.

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

This filter configures Cross-Origin Resource Sharing (CORS), allowing API calls from different domains under controlled rules instead of having them blocked by the browser's Same-Origin Policy. It handles preflight requests using the `OPTIONS` method.

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

When implementing filters, keep the following points in mind. First, filter order significantly affects behavior, so it should be managed explicitly using the `@Order` annotation or the `setOrder` method. Second, omitting the `filterChain.doFilter(request, response)` call prevents the request from being forwarded to the next filter or servlet. Third, exceptions raised in filters cannot be handled by Spring's `@ControllerAdvice`, so direct try-catch handling is often required inside the filter. Fourth, since filters execute for all requests, heavy operations that could impact performance should be avoided, and URL patterns or conditional checks should be used to run them only when necessary.

## Conclusion

Since its introduction in the Servlet 2.3 specification in 2001, servlet filters have remained a core mechanism for handling cross-cutting concerns in Java web applications. Operating at the servlet container level, they can apply common functionality such as authentication, logging, encoding, and CORS configuration to all HTTP requests. The Chain of Responsibility pattern enables flexible request-processing pipelines by combining multiple filters. Understanding the differences between servlet filters and Spring interceptors helps when choosing the right tool for a given web application concern.
