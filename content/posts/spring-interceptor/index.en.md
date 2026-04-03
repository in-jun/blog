---
title: "Spring Interceptor"
date: 2024-06-04T17:14:49+09:00
tags: ["Spring", "Java", "Interceptor"]
description: "Spring interceptor role and differences from filters."
draft: false
---

## Spring Interceptor Basics and History

Spring Interceptor is a feature first introduced in Spring Framework 2.0 in 2006. It is a mechanism that intervenes at key points—before and after controller execution and after view rendering completion—in the MVC architecture to perform common functions. Through the three methods of the `HandlerInterceptor` interface (`preHandle`, `postHandle`, and `afterCompletion`), it handles request preprocessing and postprocessing. The design separates cross-cutting concerns such as authentication, logging, execution time measurement, and common data setup from business logic.

The key difference that distinguishes Spring Interceptor from Servlet Filter lies in the layer where they operate. While Servlet Filters execute at the servlet container level (Tomcat, Jetty, etc.) before reaching the DispatcherServlet, Interceptors execute within the Spring context after the DispatcherServlet finds the appropriate controller through handler mapping but before actually calling the controller. This provides the advantage of fully utilizing Spring features such as dependency injection, bean management, and exception handling.

## Detailed Comparison: Filter vs Interceptor

Servlet Filters and Spring Interceptors are similar in that they both intercept requests to perform preprocessing and postprocessing. However, they have clear differences in their operating location, accessible information, and scope of utilization. The most important difference is in execution timing. Filters execute before reaching the DispatcherServlet, making them suitable for processing independent of the Spring context. In contrast, Interceptors execute within the Spring context, allowing access to controller information and ModelAndView, and enabling consistent exception handling through @ControllerAdvice.

| Aspect | Servlet Filter | Spring Interceptor |
|--------|----------------|-------------------|
| Operating Level | Servlet Container Level (before DispatcherServlet) | Spring Context Level (after DispatcherServlet) |
| Configuration Method | web.xml or @WebFilter | WebMvcConfigurer |
| Spring Bean Injection | Limited (requires separate configuration) | Easy (automatic DI support) |
| Accessible Information | ServletRequest/Response | HttpServletRequest/Response, Handler, ModelAndView |
| Exception Handling | @ControllerAdvice Not Applicable | @ControllerAdvice Applicable |
| Typical Use Cases | Encoding, CORS, compression, security | Authentication/authorization, logging, API versioning |

## HandlerInterceptor Methods in Detail

### preHandle Method

The `preHandle` method is called before the controller executes and returns a boolean value that determines whether request processing should continue. If it returns `true`, the request is forwarded to the next interceptor or controller. If it returns `false`, request processing is immediately stopped and the controller is not executed. This makes it suitable for gatekeeper roles such as authentication status verification, permission validation, API call rate limiting, request logging, and request start time recording.

### postHandle Method

The `postHandle` method is called after the controller completes execution normally, before the view is rendered. It receives the ModelAndView object as a parameter, allowing addition or modification of model data to be passed to the view. This is useful for uniformly adding data commonly needed across all views (user information, site configuration, menu structure, etc.). However, this method is not executed if an exception occurs in the controller. Its utility is also limited in REST API environments using `@RestController` since there is no view rendering.

### afterCompletion Method

The `afterCompletion` method always executes after view rendering is complete and the response has been sent to the client. It executes even if an exception occurred in the controller, making it suitable for post-processing tasks such as resource cleanup, log recording, and execution time calculation. Through the fourth parameter, the `Exception` object, you can check whether an exception occurred—`null` if no exception occurred, or the actual exception object if one did, enabling implementation of additional logging or notifications.

### Execution Order with Multiple Interceptors

When multiple interceptors are registered, the execution order works like a stack structure. `preHandle` executes in registration order (A → B → C), while `postHandle` and `afterCompletion` execute in reverse registration order (C → B → A). If any interceptor's `preHandle` returns `false`, only the `afterCompletion` methods of already-executed interceptors run in reverse order, and `postHandle` is not executed.

## Interceptor Implementation and Registration

To create an interceptor, implement the `HandlerInterceptor` interface. To register it, override the `addInterceptors` method in a configuration class that implements `WebMvcConfigurer`, then add the interceptor to the `InterceptorRegistry`. You can specify URL patterns to include with `addPathPatterns`, patterns to exclude with `excludePathPatterns`, and execution order with `order`.

```java
public class CustomInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Logic before controller execution
        return true; // Returning false stops request processing
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        // Logic after normal controller execution, before view rendering
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        // Logic after view rendering completion (executes even if exception occurred)
    }
}
```

```java
@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new CustomInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/static/**", "/error")
                .order(1);
    }
}
```

Path patterns use Ant-style pattern matching. `**` means all sub-paths, `*` means a single path segment, and `?` means a single character. For example, `/api/**` applies to all paths starting with `/api`, and `/user/*/profile` matches patterns like `/user/123/profile`.

## Practical Use Cases

### Authentication Interceptor

The most representative use case for interceptors is authentication and authorization verification. In `preHandle`, check the user's login status and access permissions for specific resources. If conditions are not met, return `false` to block the request and set an appropriate error response (401 Unauthorized, 403 Forbidden, etc.).

```java
@Component
public class AuthInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        String token = request.getHeader("Authorization");

        if (token == null || !tokenService.isValid(token)) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.getWriter().write("{\"error\": \"Unauthorized\"}");
            return false;
        }

        return true;
    }
}
```

### Execution Time Measurement Interceptor

This interceptor measures execution time for each request as part of API performance monitoring. In `preHandle`, it stores the start time in a `HttpServletRequest` attribute. In `afterCompletion`, it calculates the elapsed time and records it in the log. Using request attributes instead of `ThreadLocal` makes it easier to keep request-specific timing data separate.

```java
@Component
public class ExecutionTimeInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(ExecutionTimeInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        request.setAttribute("startTime", System.currentTimeMillis());
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        long startTime = (Long) request.getAttribute("startTime");
        long duration = System.currentTimeMillis() - startTime;
        logger.info("Request {} {} completed in {}ms", request.getMethod(), request.getRequestURI(), duration);
    }
}
```

## Precautions and Best Practices

When implementing interceptors, keep a few points in mind. First, if you want to use Spring beans inside an interceptor, the interceptor itself must be registered with `@Component` or as a bean in a `@Configuration` class. Creating it directly with `new` means the Spring container does not manage it, so dependency injection will not work. Second, because interceptors execute for every request, heavy operations like database queries or external API calls should be avoided when possible, and caching should be used where appropriate. Third, in REST API environments, `postHandle` is often less useful, so `preHandle` and `afterCompletion` usually carry more of the work. Fourth, in cases like authentication failure, returning `false` and setting an appropriate response is often clearer than throwing an exception.

## Conclusion

Since its introduction in Spring Framework 2.0 in 2006, the Spring interceptor has remained a core mechanism for handling cross-cutting concerns in MVC applications. Unlike servlet filters, it operates within the Spring context, which makes it easier to use features such as dependency injection, exception handling through `@ControllerAdvice`, and access to `Handler` and `ModelAndView`. Through `preHandle`, `postHandle`, and `afterCompletion`, it gives developers fine-grained control before controller execution, after controller execution, and after view rendering. That makes it well suited to tasks such as authentication, logging, execution time measurement, and common data setup. Understanding how it differs from servlet filters helps when choosing the right tool for each situation.
