---
title: "서블릿 Filter란 무엇인가"
date: 2024-06-04T16:29:15+09:00
tags: ["spring", "servlet", "filter", "java"]
description: "서블릿 필터는 Servlet 2.3 명세(2001년)에서 도입된 HTTP 요청/응답 전처리 및 후처리 컴포넌트로, 서블릿 컨테이너 레벨에서 동작하며 인증, 로깅, 인코딩 설정 등 횡단 관심사를 처리한다"
draft: false
---

## 서블릿 필터의 개념과 역사

서블릿 필터(Servlet Filter)는 2001년 발표된 Servlet 2.3 명세에서 처음 도입된 기능으로, 서블릿이 HTTP 요청을 처리하기 전과 응답을 클라이언트에게 보내기 전에 요청과 응답을 가로채어 전처리(preprocessing)와 후처리(postprocessing)를 수행하는 자바 컴포넌트이며, 이 기능의 도입으로 인증, 로깅, 문자 인코딩, 데이터 압축 같은 횡단 관심사(cross-cutting concerns)를 비즈니스 로직과 분리하여 재사용 가능한 형태로 구현할 수 있게 되었고, Chain of Responsibility 디자인 패턴을 기반으로 여러 필터를 체인 형태로 연결하여 순차적으로 실행할 수 있는 구조를 제공한다.

> **서블릿(Servlet)**
>
> 서블릿은 클라이언트의 HTTP 요청을 처리하고 HTTP 응답을 생성하는 자바 서버 측 컴포넌트로, Java EE(현 Jakarta EE) 표준의 핵심 기술이며 대부분의 자바 웹 프레임워크의 기반이 된다.

## 필터의 주요 활용 사례

서블릿 필터는 요청이나 응답을 수정하거나 특정 처리를 수행해야 하는 다양한 상황에서 활용되며, 대표적인 사용 사례로는 사용자 인증 및 인가 검증, 요청과 응답에 대한 로깅, 요청/응답 데이터의 암호화, HTTP 헤더 조작, 이미지 포맷 변환, 데이터 압축 및 해제, 그리고 예외 발생 시 사용자 정의 처리 등이 있으며, 이러한 기능들을 필터로 구현하면 각 서블릿이나 컨트롤러에서 중복 코드 없이 공통 기능을 적용할 수 있다.

## 필터 구현 방식

### GenericFilterBean

Spring Framework에서 제공하는 `GenericFilterBean`은 `javax.servlet.Filter` 인터페이스를 구현한 추상 클래스로, Spring의 환경 설정과 통합되어 필터 초기화 시 Spring Bean의 프로퍼티를 자동으로 설정할 수 있으며, `doFilter` 메서드를 오버라이드하여 요청마다 실행되는 로직을 구현한다.

```java
public class CustomFilter extends GenericFilterBean {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain) throws IOException, ServletException {
        // 전처리 로직
        filterChain.doFilter(request, response);
        // 후처리 로직
    }
}
```

### OncePerRequestFilter

`OncePerRequestFilter`는 `GenericFilterBean`을 상속받아 구현된 클래스로, 하나의 HTTP 요청당 정확히 한 번만 실행되는 것을 보장하는 필터이며, 서블릿 컨테이너에서 내부적으로 forward나 include가 발생하여 같은 요청이 여러 번 필터 체인을 통과하는 경우에도 최초 한 번만 필터 로직이 실행되도록 설계되어 있어 인증 필터나 로깅 필터처럼 요청당 한 번만 수행되어야 하는 작업에 적합하다.

```java
public class CustomFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // 전처리 로직
        filterChain.doFilter(request, response);
        // 후처리 로직
    }
}
```

## 필터 체인과 실행 순서

서블릿 컨테이너는 요청이 들어오면 등록된 필터들을 필터 체인(Filter Chain)에 따라 순차적으로 실행하고, 모든 필터를 통과한 후 대상 서블릿을 호출하며, 서블릿의 처리가 완료되면 역순으로 각 필터의 후처리 로직이 실행되는데, 이러한 구조는 Chain of Responsibility 패턴의 구현으로 각 필터가 독립적으로 자신의 역할을 수행하면서도 다음 필터나 서블릿으로 제어를 넘길 수 있게 한다.

필터의 실행 순서는 `@Order` 어노테이션이나 `FilterRegistrationBean`의 `setOrder` 메서드로 지정할 수 있으며, 숫자가 낮을수록 우선순위가 높아 먼저 실행된다.

```java
@Order(1)
public class FirstFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain) throws ServletException, IOException {
        // 가장 먼저 실행되는 필터
        filterChain.doFilter(request, response);
    }
}
```

## 필터 등록 방법

Spring Boot에서 필터를 등록하는 방법은 `@Component` 어노테이션을 사용하여 자동 등록하거나, `FilterRegistrationBean`을 통해 프로그래밍 방식으로 등록하는 두 가지가 있으며, `FilterRegistrationBean`을 사용하면 특정 URL 패턴에만 필터를 적용하거나 실행 순서를 명시적으로 지정하는 등 세밀한 제어가 가능하다.

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

## Filter와 Spring Interceptor 비교

서블릿 필터와 Spring Interceptor는 모두 요청을 가로채어 처리하는 역할을 하지만 실행되는 계층과 시점에서 근본적인 차이가 있으며, 필터는 서블릿 컨테이너(Tomcat, Jetty 등) 레벨에서 DispatcherServlet에 도달하기 전에 실행되는 반면, Interceptor는 Spring MVC의 DispatcherServlet 내부에서 Handler(컨트롤러)를 호출하기 전후에 실행되어 Spring Context에 더 쉽게 접근할 수 있고 @ExceptionHandler를 통한 예외 처리가 가능하다.

| 특성 | Servlet Filter | Spring Interceptor |
|------|---------------|-------------------|
| 실행 계층 | 서블릿 컨테이너 레벨 (DispatcherServlet 이전) | Spring MVC 레벨 (DispatcherServlet 이후) |
| 적용 범위 | 모든 HTTP 요청 | Spring MVC 컨트롤러로 향하는 요청만 |
| Spring Context 접근 | 제한적 (DI 가능하지만 설정 필요) | 용이 (Spring Bean 자동 주입) |
| 예외 처리 | ServletException, IOException | Spring @ExceptionHandler 활용 가능 |
| 대표적 사용 사례 | 문자 인코딩, CORS, 보안, 로깅 | 인증/인가, API 버전 관리, 로깅 |

### 요청 처리 흐름

```
클라이언트 요청
    ↓
Filter 1 (전처리)
    ↓
Filter 2 (전처리)
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
View 렌더링
    ↓
Interceptor 2 (afterCompletion)
    ↓
Interceptor 1 (afterCompletion)
    ↓
Filter 2 (후처리)
    ↓
Filter 1 (후처리)
    ↓
클라이언트 응답
```

## 실무 활용 예시

### CORS 필터

Cross-Origin Resource Sharing(CORS) 설정을 위한 필터로, 브라우저의 동일 출처 정책(Same-Origin Policy)을 우회하여 다른 도메인에서의 API 호출을 허용하며, preflight 요청인 OPTIONS 메서드를 처리한다.

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

### JWT 인증 필터

JSON Web Token을 검증하여 인증 정보를 Spring Security의 SecurityContext에 설정하는 필터로, Authorization 헤더에서 Bearer 토큰을 추출하여 유효성을 검증한다.

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

## 필터 구현 시 주의사항

필터를 구현할 때는 몇 가지 중요한 사항을 고려해야 하는데, 첫째로 필터 순서가 동작에 큰 영향을 미치므로 @Order 어노테이션이나 setOrder 메서드로 명시적으로 관리해야 하고, 둘째로 `filterChain.doFilter(request, response)` 호출이 누락되면 다음 필터나 서블릿으로 요청이 전달되지 않으며, 셋째로 필터에서 발생한 예외는 Spring의 @ControllerAdvice로 처리할 수 없으므로 필터 내부에서 직접 try-catch로 처리해야 하고, 넷째로 모든 요청에 대해 실행되므로 성능에 영향을 줄 수 있는 무거운 작업은 피하고 필요한 경우에만 실행되도록 URL 패턴이나 조건문을 통해 필터링해야 한다.

## 결론

서블릿 필터는 2001년 Servlet 2.3 명세에서 도입된 이래로 자바 웹 애플리케이션에서 횡단 관심사를 처리하는 핵심 메커니즘으로 자리 잡았으며, 서블릿 컨테이너 레벨에서 동작하여 모든 HTTP 요청에 대해 인증, 로깅, 인코딩, CORS 설정 등의 공통 기능을 적용할 수 있고, Chain of Responsibility 패턴을 통해 여러 필터를 조합하여 유연한 요청 처리 파이프라인을 구성할 수 있으며, Spring Interceptor와의 차이점을 이해하고 각 상황에 맞는 적절한 기술을 선택하는 것이 효과적인 웹 애플리케이션 개발의 핵심이다.
