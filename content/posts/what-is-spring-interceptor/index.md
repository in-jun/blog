---
title: "스프링 인터셉터란 무엇인가?"
date: 2024-06-04T17:14:49+09:00
tags: ["스프링", "인터셉터", "java"]
draft: false
---

## 스프링 인터셉터

인터셉터는 서블릿 필터와 비슷한 역할을 한다. 서블릿 필터는 서블릿 컨테이너에서 요청이 들어오기 전, 후에 요청을 가로채어 처리할 수 있는 기능을 제공한다. 스프링 인터셉터는 스프링 MVC에서 컨트롤러에 요청이 들어가기 전, 후에 요청을 가로채어 처리할 수 있는 기능을 제공한다.

인터셉터는 `HandlerInterceptor` 인터페이스를 구현하여 사용한다. `HandlerInterceptor` 인터페이스는 세 가지 메소드를 제공한다.

-   `preHandle` : 컨트롤러에 요청이 들어가기 전에 실행되는 메소드
-   `postHandle` : 컨트롤러에 요청이 들어간 후, 뷰가 렌더링 되기 전에 실행되는 메소드
-   `afterCompletion` : 뷰가 렌더링 된 후에 실행되는 메소드

### 인터셉터 구현

```java
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class CustomInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 컨트롤러에 요청이 들어가기 전에 실행되는 코드
        // 만약 false를 반환하면 컨트롤러에 요청이 들어가지 않음
        return true;
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        // 컨트롤러가 정상적으로 실행된 이후에 실행되는 코드
        // 예외가 발생하면 실행되지 않음
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        // 뷰가 클라이언트에 응답을 보낸 후에 실행되는 코드
        // 예외가 발생한다면 Exception 객체를 통해 예외 정보를 확인할 수 있음
        // 예외 정보를 확인해서 로깅할 수 있음
    }
}
```

### 인터셉터 등록

인터셉터를 등록하기 위해서는 `WebMvcConfigurer` 인터페이스를 구현하여 `addInterceptors` 메소드를 오버라이딩한다.

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

`addInterceptors` 메소드를 오버라이딩하여 `InterceptorRegistry`에 `addInterceptor` 메소드를 사용하여 인터셉터를 등록한다. `addPathPatterns` 메소드를 사용하여 인터셉터를 적용할 패턴을 지정하고, `excludePathPatterns` 메소드를 사용하여 인터셉터를 제외할 패턴을 지정한다.

`HandlerInterceptor` 인터페이스를 구현하여 `preHandle`, `postHandle`, `afterCompletion` 메소드를 오버라이딩한다. `preHandle` 메소드는 컨트롤러에 요청이 들어가기 전에 실행되는 코드를 작성하면 되고, `postHandle` 메소드는 컨트롤러가 정상적으로 실행된 이후에 실행되는 코드를 작성하면 된다. `afterCompletion` 메소드는 뷰가 클라이언트에 응답을 보낸 후에 실행되는 코드를 작성하면 된다.

## 로깅 인터셉터 예제

인터셉터를 사용하여 로깅을 구현할 수 있다. 로깅 인터셉터는 `preHandle` 메소드를 사용하여 요청이 들어올 때마다 로깅을 할 수 있다.

```java
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class LoggingInterceptor implements HandlerInterceptor {

    private static final Logger logger = LoggerFactory.getLogger(LoggingInterceptor.class);

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        logger.info("Request URL: {}", request.getRequestURL());
        return true;
    }
}
```

`preHandle` 메소드를 사용하여 요청이 들어올 때마다 로깅을 할 수 있다. `Logger`를 사용하여 로깅을 하면 된다.

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

인터셉터 등록을 위해 `WebMvcConfigurer` 인터페이스를 구현하여 `addInterceptors` 메소드를 오버라이딩한다.
