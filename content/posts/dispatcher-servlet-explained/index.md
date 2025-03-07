---
title: "디스패처 서블릿(Dispatcher Servlet) 알아보기"
date: 2024-06-05T08:14:35+09:00
tags: ["스프링", "디스패처 서블릿", "java"]
draft: false
---

## 디스패처 서블릿이란?

디스패처 서블릿은 스프링 MVC의 핵심이다. 클라이언트의 요청을 전달받아 적절한 컨트롤러로 요청을 전달하고, 컨트롤러가 반환한 결과를 View로 전달하는 역할을 한다. 디스패처 서블릿은 웹 애플리케이션에서 하나만 존재하며, 클라이언트의 모든 요청을 처리한다.

### 디스패처 서블릿의 동작 과정

1. 클라이언트의 요청을 전달받는다.
2. Handler Mapping을 통해 클라이언트의 요청을 처리할 컨트롤러를 찾는다.
3. Handler Adapter를 통해 컨트롤러를 실행한다.
4. 컨트롤러가 반환한 결과를 View Resolver를 통해 View로 변환한다.
5. View를 클라이언트에게 전달한다.

> RestController를 사용할 경우 View Resolver를 사용하지 않는다. 대신에 객체를 JSON 형태로 변환하여 클라이언트에게 전달한다.

### 디스패처 서블릿 장점

4. web.xml에 서블릿 매핑을 설정하지 않아도 된다.
1. 클라이언트의 요청을 적절한 컨트롤러로 전달해 주기 때문에 개발자는 컨트롤러에만 집중할 수 있다.
1. 컨트롤러가 반환한 결과를 View로 전달해 주기 때문에 개발자는 View에 대한 처리를 신경 쓰지 않아도 된다.
1. 디스패처 서블릿을 통해 요청과 응답을 처리하기 때문에 개발자는 서블릿 API를 사용하지 않아도 된다.

### 디스패처 서블릿의 추가 기능

디스패처 서블릿은 기본적인 요청 처리 외에도 다양한 추가 기능을 제공한다.

#### 인터셉터(Interceptor) 지원

디스패처 서블릿은 인터셉터를 통해 요청 전후에 특정 로직을 수행할 수 있도록 지원한다. 이를 통해 공통적인 기능(예: 인증, 로깅)을 중앙 집중식으로 처리할 수 있다.

#### 예외 처리 기능

디스패처 서블릿은 예외 처리 기능을 내장하고 있어, 애플리케이션 전반에 걸친 일관된 예외 처리를 할 수 있다. `@ControllerAdvice`와 `@ExceptionHandler`를 통해 특정 예외에 대한 처리 로직을 정의할 수 있다.

#### 커스텀 핸들러 매핑

기본 핸들러 매핑 외에도 커스텀 핸들러 매핑을 구현하여 복잡한 요청 매핑 로직을 적용할 수 있다. 이를 통해 더욱 유연한 요청 처리를 할 수 있다.

### 디스패처 서블릿 설정

디스패처 서블릿은 Spring Boot를 사용할 경우, 기본적으로 자동 설정된다. 하지만, 필요에 따라 수동으로 설정할 수도 있다. `@Configuration` 클래스에서 `DispatcherServlet`을 빈으로 등록하여 설정할 수 있다.

```java
@Configuration
public class WebConfig {
    @Bean
    public DispatcherServlet dispatcherServlet() {
        DispatcherServlet dispatcherServlet = new DispatcherServlet();
        dispatcherServlet.setThrowExceptionIfNoHandlerFound(true);
        return dispatcherServlet;
    }
}
```

이와 같이 설정하면, 핸들러를 찾지 못할 경우 예외를 던지도록 설정할 수 있다.

### 결론

디스패처 서블릿은 스프링 MVC의 핵심 컴포넌트로서, 클라이언트의 요청을 처리하고 적절한 컨트롤러로 전달하는 역할을 한다. 다양한 추가 기능과 설정을 통해 유연하고 강력한 웹 애플리케이션을 개발할 수 있게 해 준다.
