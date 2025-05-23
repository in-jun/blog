---
title: "서블릿 filter란 무엇인가?"
date: 2024-06-04T16:29:15+09:00
tags: ["서블릿", "filter", "java"]
draft: false
---

> 서블릿은 클라이언트의 요청을 처리하는 자바 클래스이다. 서블릿은 HTTP 요청을 처리하고, HTTP 응답을 생성하는 데 사용된다.

## 서블릿 필터란?

서블릿 필터는 서블릿 컨테이너에서 서블릿이 요청을 처리하기 전이나 응답을 보내기 전에 요청이나 응답을 수정할 수 있는 기능을 제공한다.

요청이나 응답을 수정하는 이유가 무엇일까? 다음과 같은 이유로 요청이나 응답을 수정한다.

-   **인증**: 사용자가 로그인했는지 확인
-   **로깅**: 요청과 응답을 로깅
-   **암호화**: 요청과 응답을 암호화
-   **헤더 추가**: 요청이나 응답에 헤더 추가
-   **이미지 변환**: 이미지 요청을 다른 형식으로 변환
-   **데이터 압축**: 요청이나 응답을 압축
-   **사용자 정의 인셉션 처리**: 예외 발생 시 사용자 정의 인셉션 처리

이러한 기능을 필터로 사용하여 구현할 수 있다.

### GenericFilterBean

`GenericFilterBean`은 `Filter` 인터페이스를 구현한 클래스이다. `GenericFilterBean`을 상속받아 필터를 구현하면, 요청이 들어올 때마다 실행되는 필터를 구현할 수 있다.

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
        // 요청이 들어올 때마다 실행되는 코드
        filterChain.doFilter(request, response);
    }
}
```

`doFilter` 메소드에 요청이 들어올 때마다 실행되는 코드를 작성하면 된다.

### OncePerRequestFilter

`OncePerRequestFilter`는 `GenericFilterBean`을 상속받아 구현된 클래스이다. `OncePerRequestFilter`는 요청이 들어올 때마다 **한 번만** 실행되는 필터이다.

`OncePerRequestFilter`를 상속받아 필터를 구현하면, 요청이 들어올 때마다 한 번만 실행되는 필터를 구현할 수 있다.

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
        // 요청이 들어올 때마다 실행되는 코드
        filterChain.doFilter(request, response);
    }
}
```

`doFilterInternal` 메소드에 요청이 들어올 때마다 실행되는 코드를 작성하면 된다.

## 필터 작동 순서

1. 클라이언트가 서버에 요청을 보낸다.
2. 필터 체인에 등록된 필터들이 순서대로 실행된다.
3. 서블릿이 요청을 처리한다.
4. 필터 체인에 등록된 필터들이 순서대로 실행된다.
5. 서버가 클라이언트에 응답을 보낸다.

필터는 필터 체인에 등록된 순서대로 실행된다. 필터 체인에 등록된 필터들이 순서대로 실행되기 때문에, 필터의 순서를 잘 정의해야 한다.

또한 `@Order` 어노테이션을 사용하여 필터의 순서를 정의할 수 있다.

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
        // 요청이 들어올 때마다 실행되는 코드
        filterChain.doFilter(request, response);
    }
}
```

주의할 점은 `@Order` 어노테이션을 사용하여 필터의 순서를 정의할 때, 숫자가 작을수록 우선순위가 높다.

## 필터 등록

필터를 등록하는 방법은 다음과 같다.

### @Configuration

`@Configuration` 어노테이션을 사용하여 필터를 등록할 수 있다.

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

`FilterRegistrationBean`을 사용하여 필터를 등록할 수 있다. `addUrlPatterns` 메소드를 사용하여 필터를 적용할 URL 패턴을 지정할 수 있다.

## 간단한 로깅 필터 구현

간단한 로깅 필터를 구현해 보자.

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

`doFilterInternal` 메소드에서 요청이 들어올 때마다 요청 URI, HTTP 메소드, 처리 시간을 출력한다.

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

`FilterConfig` 클래스에서 `LoggingFilter`를 등록한다.

이제 서버에 요청을 보내면, 요청 URI, HTTP 메소드, 처리 시간이 출력된다.

```bash
Request URI: /, Method: GET, Duration: 0ms
```

좋은 필터는 요청이나 응답을 수정하는 것이 아니라, 로깅이나 인증과 같은 부가적인 기능을 제공하는 것이다. 필터는 요청이나 응답을 수정하는 것이 아니라, 부가적인 기능을 제공하는 것이 좋다.
