---
title: "What is Spring Interceptor?"
date: 2024-06-04T17:14:49+09:00
tags: ["spring", "interceptor", "java"]
draft: false
---

## Spring Interceptor

Interceptor performs similar role to Servlet Filter. Servlet filter provides functionality to intercept and process requests before and after they reach the servlet container. Spring Interceptor provides functionality to intercept and process requests before and after they reach the controller in Spring MVC.

Interceptor is implemented using `HandlerInterceptor` interface. `HandlerInterceptor` interface provides three methods:

-   `preHandle`: Method executed before the request reaches the controller
-   `postHandle`: Method executed after the request has reached the controller, before the view is rendered
-   `afterCompletion`: Method executed after the view has been rendered

### Interceptor Implementation

```java
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CustomInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // Code to execute before the request reaches the controller
        // If false is returned, request is not forwarded to the controller
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        // Code to execute after the controller is executed normally
        // Not executed if an exception is thrown
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        // Code to execute after the view has been sent to the client
        // Exception object can be used to check exception information if an exception occurred
        // Exception information can be checked and logged
    }
}
```

### Interceptor Registration

To register the interceptor, implement the `WebMvcConfigurer` interface and override the `addInterceptors` method.

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new CustomInterceptor())
                .addPathPatterns("/**")
                .excludePathPatterns("/exclude");
    }
}
```

Register the interceptor using `addInterceptor` method on `InterceptorRegistry` by overriding the `addInterceptors` method. Specify the patterns to which the interceptor should be applied using `addPathPatterns` method and specify the patterns to exclude from the interceptor using `excludePathPatterns` method.

Implement `preHandle`, `postHandle`, `afterCompletion` methods by implementing the `HandlerInterceptor` interface. Write the code to be executed before the request reaches the controller in the `preHandle` method, write the code to be executed after the controller is executed normally in the `postHandle` method and write the code to be executed after the view is sent to the client in the `afterCompletion` method.

## Logging Interceptor Example

Interceptor can be used to implement logging. Logging interceptor can be implemented to log whenever a request comes in using the `preHandle` method.

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax javax.servlet.http.HttpServletResponse;

public class LoggingInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(LoggingInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        logger.info("Request URL: {}", request.getRequestURL());
        return true;
    }
}
```

Logging can be done in the `preHandle` method whenever a request comes in. Logging can be done using the `Logger`.

```java
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Override
    public void addInterceptors(InterceptorRegistry registry) {
        registry.addInterceptor(new LoggingInterceptor())
                .addPathPatterns("/**");
    }
}
```

To register the interceptor, implement the `WebMvcConfigurer` interface and override the `addInterceptors` method.
