---
title: "Spring Interceptor"
date: 2024-06-04T17:14:49+09:00
tags: ["Spring", "Java", "인터셉터"]
description: "Spring Interceptor의 역할과 Filter와의 차이를 설명한다."
draft: false
---

## 스프링 인터셉터의 개념과 역사

스프링 인터셉터(Spring Interceptor)는 2006년 Spring Framework 2.0에서 처음 도입된 기능으로, MVC 아키텍처에서 컨트롤러가 요청을 처리하기 전, 후, 그리고 뷰 렌더링 완료 후의 시점에 개입하여 공통 기능을 수행하는 메커니즘이며, `HandlerInterceptor` 인터페이스의 `preHandle`, `postHandle`, `afterCompletion` 세 가지 메서드를 통해 요청의 전처리와 후처리를 수행하고, 인증, 로깅, 실행 시간 측정, 공통 데이터 설정 같은 횡단 관심사(cross-cutting concerns)를 비즈니스 로직과 분리하여 처리할 수 있도록 설계되었다.

스프링 인터셉터가 서블릿 필터와 구분되는 핵심적인 차이점은 동작하는 계층에 있는데, 서블릿 필터가 서블릿 컨테이너(Tomcat, Jetty 등) 레벨에서 DispatcherServlet에 도달하기 전에 실행되는 반면, 인터셉터는 스프링 컨텍스트 내부에서 DispatcherServlet이 핸들러 매핑을 통해 컨트롤러를 찾은 후 실제 컨트롤러를 호출하기 전후에 실행되므로, 스프링이 제공하는 의존성 주입, 빈 관리, 예외 처리 등의 기능을 완전히 활용할 수 있다는 장점이 있다.

## Filter와 Interceptor 상세 비교

서블릿 필터와 스프링 인터셉터는 모두 요청을 가로채어 전처리와 후처리를 수행한다는 점에서 유사하지만, 동작 위치와 접근 가능한 정보, 활용 범위에서 명확한 차이가 있으며, 실행 시점의 차이가 가장 중요한데 필터는 DispatcherServlet에 도달하기 전에 실행되어 스프링 컨텍스트와 무관한 처리에 적합한 반면, 인터셉터는 스프링 컨텍스트 내에서 실행되어 컨트롤러 정보나 ModelAndView에 접근할 수 있고 @ControllerAdvice를 통한 일관된 예외 처리가 가능하다.

| 구분 | Servlet Filter | Spring Interceptor |
|------|----------------|-------------------|
| 동작 위치 | 서블릿 컨테이너 레벨 (DispatcherServlet 이전) | 스프링 컨텍스트 레벨 (DispatcherServlet 이후) |
| 설정 방법 | web.xml 또는 @WebFilter | WebMvcConfigurer |
| 스프링 빈 주입 | 제한적 (별도 설정 필요) | 자유로움 (자동 DI 지원) |
| 접근 가능 정보 | ServletRequest/Response | HttpServletRequest/Response, Handler, ModelAndView |
| 예외 처리 | @ControllerAdvice 적용 불가 | @ControllerAdvice 적용 가능 |
| 대표적 사용 사례 | 인코딩, CORS, 압축, 보안 | 인증/인가, 로깅, API 버전 관리 |

## HandlerInterceptor 메서드 상세

### preHandle 메서드

`preHandle` 메서드는 컨트롤러가 실행되기 전에 호출되며, boolean 값을 반환하여 요청 처리의 계속 여부를 결정하는데, `true`를 반환하면 다음 인터셉터나 컨트롤러로 요청이 전달되고, `false`를 반환하면 요청 처리가 즉시 중단되어 컨트롤러가 실행되지 않으므로, 인증 상태 확인, 권한 검증, API 호출 횟수 제한, 요청 로깅, 요청 시작 시간 기록 같은 게이트키퍼 역할을 수행하는 데 적합하다.

### postHandle 메서드

`postHandle` 메서드는 컨트롤러가 정상적으로 실행을 완료한 후, 뷰가 렌더링되기 전에 호출되며, ModelAndView 객체를 파라미터로 받아 뷰에 전달될 모델 데이터를 추가하거나 수정할 수 있으므로 모든 뷰에 공통으로 필요한 데이터(사용자 정보, 사이트 설정, 메뉴 구조 등)를 일괄적으로 추가하는 데 유용하지만, 컨트롤러에서 예외가 발생하면 이 메서드가 실행되지 않으며, `@RestController`를 사용하는 REST API 환경에서는 뷰 렌더링이 없어 활용도가 제한적이다.

### afterCompletion 메서드

`afterCompletion` 메서드는 뷰 렌더링이 완료되고 클라이언트에 응답이 전송된 후 항상 실행되는 메서드로, 컨트롤러에서 예외가 발생한 경우에도 반드시 실행되므로 리소스 정리, 로그 기록, 실행 시간 계산 같은 후처리 작업에 적합하며, 네 번째 파라미터인 `Exception` 객체를 통해 예외 발생 여부를 확인할 수 있어 예외가 발생하지 않았다면 `null`이고 예외가 발생했다면 해당 예외 객체를 받아 추가 로깅이나 알림을 구현할 수 있다.

### 다중 인터셉터의 실행 순서

여러 인터셉터를 등록한 경우 실행 순서는 스택 구조와 유사하게 동작하는데, `preHandle`은 등록 순서대로(A → B → C) 실행되고, `postHandle`과 `afterCompletion`은 등록 역순으로(C → B → A) 실행되며, 어떤 인터셉터의 `preHandle`이 `false`를 반환하면 이미 실행된 인터셉터들의 `afterCompletion`만 역순으로 실행되고 `postHandle`은 실행되지 않는다.

## 인터셉터 구현과 등록

인터셉터를 구현하려면 `HandlerInterceptor` 인터페이스를 구현하고, 등록하려면 `WebMvcConfigurer` 인터페이스를 구현한 설정 클래스에서 `addInterceptors` 메서드를 오버라이드하여 `InterceptorRegistry`에 인터셉터를 추가하며, `addPathPatterns`로 적용할 URL 패턴을, `excludePathPatterns`로 제외할 URL 패턴을, `order`로 실행 순서를 지정할 수 있다.

```java
public class CustomInterceptor implements HandlerInterceptor {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        // 컨트롤러 실행 전 로직
        return true; // false 반환 시 요청 처리 중단
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception {
        // 컨트롤러 정상 실행 후, 뷰 렌더링 전 로직
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        // 뷰 렌더링 완료 후 로직 (예외 발생 시에도 실행)
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

경로 패턴은 Ant 스타일 패턴 매칭을 사용하며, `**`는 모든 하위 경로를, `*`는 단일 경로 세그먼트를, `?`는 단일 문자를 의미하므로 `/api/**`는 `/api`로 시작하는 모든 경로에 적용되고 `/user/*/profile`은 `/user/123/profile` 같은 패턴에 매칭된다.

## 실무 활용 사례

### 인증 인터셉터

인터셉터의 가장 대표적인 사용 사례는 인증과 권한 검증으로, `preHandle`에서 사용자의 로그인 상태와 특정 리소스에 대한 접근 권한을 확인하고, 조건을 만족하지 않으면 `false`를 반환하여 요청을 차단하고 적절한 에러 응답(401 Unauthorized, 403 Forbidden 등)을 설정한다.

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

### 실행 시간 측정 인터셉터

API 성능 모니터링을 위해 각 요청의 실행 시간을 측정하는 인터셉터로, `preHandle`에서 시작 시간을 `HttpServletRequest`의 attribute에 저장하고 `afterCompletion`에서 종료 시간과의 차이를 계산하여 로그에 기록하며, ThreadLocal 대신 request attribute를 사용하면 요청별로 독립적인 시간 정보를 안전하게 관리할 수 있다.

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

## 주의사항과 모범 사례

인터셉터를 구현할 때는 몇 가지 중요한 사항을 고려해야 하는데, 첫째로 인터셉터에서 스프링 빈을 사용하려면 인터셉터 자체를 `@Component`로 등록하거나 `@Configuration` 클래스에서 빈으로 등록한 후 의존성 주입을 통해 `WebMvcConfigurer`에서 사용해야 하며 `new` 키워드로 직접 생성하면 스프링 컨테이너가 관리하지 않아 의존성 주입이 작동하지 않고, 둘째로 모든 요청에 대해 실행되므로 데이터베이스 조회나 외부 API 호출 같은 무거운 작업은 피하고 캐싱을 활용하여 성능을 최적화해야 하며, 셋째로 REST API 환경에서는 `postHandle`의 활용도가 제한적이므로 주로 `preHandle`로 요청 전처리를, `afterCompletion`으로 요청 후처리를 수행하고, 넷째로 인증 실패 등의 경우에는 예외를 던지기보다 `false`를 반환하고 적절한 응답을 설정하는 방식이 더 명확하다.

## 결론

스프링 인터셉터는 2006년 Spring Framework 2.0에서 도입된 이래로 MVC 아키텍처에서 횡단 관심사를 처리하는 핵심 메커니즘으로 자리 잡았으며, 서블릿 필터와 달리 스프링 컨텍스트 내에서 동작하여 의존성 주입, @ControllerAdvice를 통한 예외 처리, Handler 및 ModelAndView 접근 같은 스프링의 다양한 기능을 활용할 수 있고, `preHandle`, `postHandle`, `afterCompletion` 세 가지 메서드를 통해 컨트롤러 실행 전후와 뷰 렌더링 후의 시점을 세밀하게 제어할 수 있어 인증, 로깅, 실행 시간 측정, 공통 데이터 설정 같은 작업을 효과적으로 구현할 수 있으며, 서블릿 필터와의 차이점을 이해하고 각 상황에 맞는 적절한 기술을 선택하는 것이 효과적인 스프링 웹 애플리케이션 개발의 핵심이다.
