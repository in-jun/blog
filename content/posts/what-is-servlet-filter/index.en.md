---
title: "What Is a Servlet Filter?"
date: 2024-06-04T16:29:15+09:00
tags: ["servlet", "filter", "java"]
draft: false
---

> Servlets are Java classes which handle a client's request. Servlets are used to process HTTP requests and to generate HTTP responses.

## What is a Servlet Filter?

A Servlet filter provides a way to modify the request or response before it is handled by the servlet, or after the servlet has generated it.

Why would you want to modify the request or response? There are many reasons to modify the request or response, such as:

-   **Authentication**: Check if the user is logged in.
-   **Logging**: Log the request and response.
-   **Encryption**: Encrypt the request and response.
-   **Header Manipulation**: Add headers to the request or response.
-   **Image Manipulation**: Convert image requests to different formats.
-   **Data Compression**: Compress the request or response.
-   **Custom Exception Handling**: Handle exceptions with custom exception handlers.

Filters allow you to implement such functionality.

### GenericFilterBean

The `GenericFilterBean` is a class that implements the `Filter` interface. By extending `GenericFilterBean` you can implement a filter that runs every time a request comes in.

```java
import org.springframework.web.filter.GenericFilterBean;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import java.io.IOException;

public class CustomFilter extends GenericFilterBean {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
        // Code that runs on every request
        filterChain.doFilter(request, response);
    }
}
```

You can write code in the `doFilter` method that runs every time a request comes in.

### OncePerRequestFilter

`OncePerRequestFilter` is a class that extends `GenericFilterBean`. `OncePerRequestFilter` is a filter that runs **only once** per request.

By extending `OncePerRequestFilter` you can implement a filter that runs only once for each request that comes in.

```java
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class CustomFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // Code that runs on every request
        filterChain.doFilter(request, response);
    }
}
```

You can write code in the `doFilterInternal` method that runs every time a request comes in.

## How Filters Work

1. A client sends a request to the server.
2. The filters that are registered in the filter chain are executed in sequence.
3. The servlet processes the request.
4. The filters that are registered in the filter chain are executed in sequence.
5. The server sends the response to the client.

Filters are executed in the order in which they are registered in the filter chain. Because the filters that are registered in the filter chain are executed in sequence, it is important to define the order of the filters carefully.

You can also use the `@Order` annotation to define the order of the filters.

```java
import org.springframework.core.annotation.Order;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Order(1)
public class CustomFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // Code that runs on every request
        filterChain.doFilter(request, response);
    }
}
```

One thing to note is that when using the `@Order` annotation to define the order of the filters, the lower the number, the higher the priority.

## Registering a Filter

Here is how to register a filter:

### @Configuration

You can use the `@Configuration` annotation to register a filter.

```java
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<CustomFilter> customFilter() {
        FilterRegistrationBean<CustomFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new CustomFilter());
        registrationBean.addUrlPatterns("/*");
        return registrationBean;
    }
}
```

You can use a `FilterRegistrationBean` to register a filter. You can use the `addUrlPatterns` method to specify the URL patterns that the filter will be applied to.

## Implementing a Simple Logging Filter

Let's implement a simple logging filter:

```java
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

public class LoggingFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        long startTime = System.currentTimeMillis();
        String requestURI = request.getRequestURI();
        String method = request.getMethod();

        filterChain.doFilter(request, response);

        long endTime = System.currentTimeMillis();
        long duration = endTime - startTime;

        System.out.println("Request URI: " + requestURI + ", Method: " + method + ", Duration: " + duration + "ms");
    }
}
```

In the `doFilterInternal` method we print out the request URI, the HTTP method, and the duration of the request every time a request comes in.

```java
import org.springframework.boot.web.servlet.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class FilterConfig {

    @Bean
    public FilterRegistrationBean<LoggingFilter> loggingFilter() {
        FilterRegistrationBean<LoggingFilter> registrationBean = new FilterRegistrationBean<>();
        registrationBean.setFilter(new LoggingFilter());
        registrationBean.addUrlPatterns("/*");
        return registrationBean;
    }
}
```

In the `FilterConfig` class, we register the `LoggingFilter`.

Now when you make a request to your server, you will see the request URI, the HTTP method, and the duration of the request printed out.

```bash
Request URI: /, Method: GET, Duration: 0ms
```

Good filters don’t modify the request or response; instead, they provide additional functionality such as logging or authentication. Filters should be used to provide additional functionality, not to modify the request or response.
