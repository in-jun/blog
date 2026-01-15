---
title: "디스패처 서블릿(Dispatcher Servlet) 알아보기"
date: 2024-06-05T08:14:35+09:00
tags: ["스프링", "디스패처 서블릿", "java"]
description: "스프링 MVC의 핵심 컴포넌트인 DispatcherServlet의 역사, Front Controller 패턴, 상세한 요청 처리 흐름, HandlerMapping/HandlerAdapter/ViewResolver 등 주요 컴포넌트, 초기화 과정, Spring Boot 자동 설정, @Controller와 @RestController의 동작 차이를 다루며, Interceptor와 Filter의 차이, 비동기 요청 처리 등 실전 팁까지 포괄적으로 설명한다."
draft: false
---

## 디스패처 서블릿이란?

디스패처 서블릿은 스프링 MVC의 핵심 컴포넌트로, 클라이언트의 모든 HTTP 요청을 단일 진입점에서 받아 적절한 컨트롤러로 전달하고, 컨트롤러가 반환한 결과를 View로 렌더링하여 응답하는 Front Controller 패턴의 구현체다. 이는 웹 애플리케이션에서 하나만 존재하며, 모든 요청을 중앙에서 처리함으로써 공통 로직을 효율적으로 관리하고 개발자가 비즈니스 로직에 집중할 수 있도록 한다.

## DispatcherServlet의 역사와 발전

스프링 MVC는 2004년 Spring Framework 1.0과 함께 등장했으며, 당시 J2EE의 복잡한 서블릿 개발 방식에 대한 대안으로 Front Controller 패턴을 구현한 DispatcherServlet을 핵심으로 하는 웹 프레임워크로 자리 잡았다. 초기에는 XML 기반 설정을 통해 서블릿을 등록하고 매핑했으나, Servlet 3.0 이상부터는 `WebApplicationInitializer`를 통한 자바 설정이 가능해졌으며, Spring Boot의 등장으로 인해 자동 설정(Auto Configuration)이 도입되어 개발자가 별도의 설정 없이도 즉시 사용할 수 있게 되었다.

## Front Controller 패턴

Front Controller 패턴은 엔터프라이즈 애플리케이션 설계에서 자주 사용되는 디자인 패턴으로, 모든 클라이언트 요청을 단일 진입점에서 처리하여 공통 로직(인증, 로깅, 예외 처리)을 중앙화하고 각 요청을 적절한 핸들러로 위임하는 방식이다. 전통적인 서블릿 방식에서는 각 URL마다 개별 서블릿을 생성하고 web.xml에 매핑해야 했으며 이는 중복 코드와 관리의 복잡성을 초래했지만, Front Controller 패턴을 사용하면 하나의 서블릿이 모든 요청을 받아 처리하므로 코드 중복을 제거하고 유지보수성을 향상시킬 수 있다.

## DispatcherServlet의 상세한 요청 처리 흐름

DispatcherServlet은 클라이언트 요청을 받아 응답을 생성하기까지 다음과 같은 7단계의 처리 과정을 거친다.

### 1단계: HTTP 요청 수신

클라이언트가 HTTP 요청을 보내면 서블릿 컨테이너(Tomcat, Jetty 등)가 이를 받아 DispatcherServlet의 `doService()` 메서드를 호출하며, 이때 요청 정보(URL, HTTP 메서드, 헤더, 파라미터)가 `HttpServletRequest` 객체에 담겨 전달되고 DispatcherServlet은 이 요청을 처리하기 위한 준비 작업을 수행한다.

### 2단계: HandlerMapping을 통한 핸들러 검색

DispatcherServlet은 등록된 여러 HandlerMapping 구현체를 순회하며 요청 URL과 HTTP 메서드에 매핑되는 핸들러(컨트롤러 메서드)를 검색하고, 가장 일반적으로 사용되는 `RequestMappingHandlerMapping`은 `@RequestMapping`, `@GetMapping`, `@PostMapping` 등의 어노테이션을 기반으로 매핑 정보를 찾으며, 매핑이 발견되면 해당 핸들러와 인터셉터 체인을 포함한 `HandlerExecutionChain` 객체를 반환한다.

### 3단계: HandlerAdapter를 통한 핸들러 실행

찾아진 핸들러의 타입에 맞는 HandlerAdapter를 선택하여 실제 핸들러 메서드를 호출하는데, `RequestMappingHandlerAdapter`는 `@Controller` 어노테이션이 붙은 클래스의 메서드를 처리하며 메서드 파라미터 바인딩, 검증, 타입 변환 등의 작업을 수행하고, 이 과정에서 `HttpMessageConverter`가 요청 본문을 자바 객체로 변환(역직렬화)하는 역할을 담당한다.

### 4단계: ModelAndView 반환

핸들러가 실행을 완료하면 처리 결과를 담은 `ModelAndView` 객체를 반환하는데, 이 객체는 뷰 이름(논리적 뷰 이름)과 모델 데이터(뷰에 전달할 데이터)를 포함하며, `@RestController`나 `@ResponseBody`를 사용하는 경우에는 ViewResolver를 거치지 않고 직접 응답 본문으로 데이터를 직렬화한다.

### 5단계: ViewResolver를 통한 View 검색

ViewResolver는 컨트롤러가 반환한 논리적 뷰 이름을 실제 뷰 객체로 변환하는 역할을 하며, `InternalResourceViewResolver`는 JSP 파일 경로로 변환하고 `ThymeleafViewResolver`는 Thymeleaf 템플릿으로 변환하는 등 다양한 ViewResolver 구현체가 존재하고, 설정된 prefix와 suffix를 조합하여 실제 뷰 파일의 경로를 생성한다.

### 6단계: View 렌더링

ViewResolver가 찾은 View 객체의 `render()` 메서드를 호출하여 모델 데이터를 바탕으로 HTML, JSON, XML 등의 응답을 생성하며, JSP의 경우 서블릿 엔진이 JSP 파일을 컴파일하고 실행하여 최종 HTML을 생성하고 Thymeleaf는 템플릿 엔진이 템플릿 파일을 처리하여 동적 콘텐츠를 생성한다.

### 7단계: HTTP 응답 반환

렌더링된 결과가 `HttpServletResponse` 객체에 작성되어 클라이언트에게 전달되며, 이때 응답 상태 코드, 헤더, 본문이 포함되고 서블릿 컨테이너는 이 응답을 HTTP 프로토콜에 맞게 변환하여 네트워크를 통해 클라이언트에게 전송한다.

## 주요 컴포넌트 상세 설명

### HandlerMapping

HandlerMapping은 HTTP 요청을 적절한 핸들러에 매핑하는 전략 인터페이스로, `RequestMappingHandlerMapping`은 `@RequestMapping` 계열 어노테이션을 기반으로 매핑하고 `BeanNameUrlHandlerMapping`은 빈 이름을 URL로 매핑하며 `SimpleUrlHandlerMapping`은 URL 패턴과 핸들러를 직접 매핑하는 등 다양한 구현체가 존재하고, 여러 HandlerMapping이 등록되어 있을 경우 우선순위(Order)에 따라 순차적으로 검색하여 첫 번째로 매칭되는 핸들러를 사용한다.

### HandlerAdapter

HandlerAdapter는 다양한 타입의 핸들러를 일관된 방식으로 호출할 수 있도록 어댑터 패턴을 구현한 인터페이스로, `RequestMappingHandlerAdapter`는 `@Controller`와 `@RequestMapping`을 사용하는 메서드를 처리하고 `HttpRequestHandlerAdapter`는 `HttpRequestHandler` 인터페이스 구현체를 처리하며 `SimpleControllerHandlerAdapter`는 전통적인 `Controller` 인터페이스를 처리하고, 이를 통해 스프링 MVC는 다양한 핸들러 타입을 유연하게 지원할 수 있다.

### ViewResolver

ViewResolver는 논리적 뷰 이름을 실제 뷰 객체로 변환하는 역할을 하며, `InternalResourceViewResolver`는 JSP와 같은 내부 리소스를 처리하고 prefix와 suffix를 설정하여 뷰 이름에 경로와 확장자를 추가하며, `ThymeleafViewResolver`와 `FreeMarkerViewResolver`는 각각 Thymeleaf와 FreeMarker 템플릿 엔진을 위한 ViewResolver로 서버 사이드 렌더링을 지원하고, 여러 ViewResolver가 체인 형태로 동작하여 순차적으로 뷰를 찾는다.

### HandlerExceptionResolver

HandlerExceptionResolver는 핸들러 실행 중 발생한 예외를 처리하는 전략 인터페이스로, `ExceptionHandlerExceptionResolver`는 `@ExceptionHandler` 어노테이션을 처리하고 `ResponseStatusExceptionResolver`는 `@ResponseStatus` 어노테이션을 처리하며 `DefaultHandlerExceptionResolver`는 스프링 MVC의 표준 예외를 HTTP 상태 코드로 변환하고, 이를 통해 일관된 예외 처리와 사용자 정의 에러 페이지를 제공할 수 있다.

### MultipartResolver

MultipartResolver는 파일 업로드 요청(multipart/form-data)을 처리하는 컴포넌트로, `CommonsMultipartResolver`는 Apache Commons FileUpload 라이브러리를 사용하고 `StandardServletMultipartResolver`는 Servlet 3.0의 표준 멀티파트 API를 사용하며, Spring Boot는 기본적으로 StandardServletMultipartResolver를 자동 설정하고 `spring.servlet.multipart.*` 프로퍼티로 최대 파일 크기와 요청 크기를 제한할 수 있다.

### LocaleResolver

LocaleResolver는 클라이언트의 로케일(언어 및 지역 정보)을 결정하는 전략 인터페이스로, `AcceptHeaderLocaleResolver`는 HTTP Accept-Language 헤더를 기반으로 로케일을 결정하고 `SessionLocaleResolver`는 세션에 저장된 로케일을 사용하며 `CookieLocaleResolver`는 쿠키에 저장된 로케일을 사용하고, 이를 통해 국제화(i18n)를 지원하여 다양한 언어로 콘텐츠를 제공할 수 있다.

### ThemeResolver

ThemeResolver는 웹 애플리케이션의 테마(CSS, 이미지 등의 시각적 요소)를 동적으로 전환하는 기능을 제공하며, `FixedThemeResolver`는 고정된 테마를 사용하고 `SessionThemeResolver`는 세션에 테마 정보를 저장하며 `CookieThemeResolver`는 쿠키에 테마 정보를 저장하고, 사용자가 선호하는 테마를 선택하거나 관리자가 전체 테마를 변경하는 등의 유연한 UI 커스터마이징이 가능하다.

## @RestController와의 동작 차이

`@Controller`는 전통적인 MVC 패턴을 따라 ModelAndView를 반환하고 ViewResolver를 통해 HTML 페이지를 렌더링하지만, `@RestController`는 `@Controller`와 `@ResponseBody`를 결합한 어노테이션으로 메서드의 반환 값이 뷰 이름이 아닌 HTTP 응답 본문으로 직접 전달되며, 이때 `HttpMessageConverter`가 자바 객체를 JSON, XML 등의 포맷으로 직렬화한다. 가장 일반적으로 사용되는 `MappingJackson2HttpMessageConverter`는 Jackson 라이브러리를 사용하여 객체를 JSON으로 변환하고 `GsonHttpMessageConverter`는 Gson 라이브러리를 사용하며, `Accept` 헤더와 `Content-Type` 헤더를 기반으로 적절한 컨버터가 자동으로 선택되어 RESTful API 개발에 최적화된 방식으로 동작한다.

## DispatcherServlet 초기화 과정

DispatcherServlet이 초기화될 때 먼저 `WebApplicationContext`를 생성하거나 기존 컨텍스트를 참조하며, 이 컨텍스트는 스프링 빈들을 관리하는 컨테이너로 컨트롤러, 서비스, 리포지토리 등의 컴포넌트를 포함한다. 빈 초기화 순서는 `ContextLoaderListener`가 먼저 Root WebApplicationContext를 생성하고 공통 빈(데이터소스, 트랜잭션 매니저 등)을 등록한 후, DispatcherServlet이 Servlet WebApplicationContext를 생성하여 웹 계층 빈(컨트롤러, ViewResolver 등)을 등록하며, Servlet WebApplicationContext는 Root WebApplicationContext를 부모로 참조하여 계층 구조를 형성한다. 이러한 이중 컨텍스트 구조는 여러 DispatcherServlet이 존재할 때 공통 빈을 공유하면서도 각 서블릿이 독립적인 웹 계층 설정을 가질 수 있도록 한다.

## Spring Boot에서의 자동 설정

Spring Boot는 `DispatcherServletAutoConfiguration`을 통해 DispatcherServlet을 자동으로 설정하고 등록하며, 개발자가 별도의 web.xml이나 자바 설정 없이도 즉시 웹 애플리케이션을 실행할 수 있도록 한다. `spring.mvc.*` 프로퍼티를 통해 다양한 설정을 커스터마이징할 수 있으며, `spring.mvc.view.prefix`와 `spring.mvc.view.suffix`로 ViewResolver를 설정하고 `spring.mvc.static-path-pattern`으로 정적 리소스 경로를 지정하며 `spring.mvc.throw-exception-if-no-handler-found`로 핸들러 미발견 시 예외 발생 여부를 제어할 수 있다. 더 세밀한 커스터마이징이 필요한 경우 `WebMvcConfigurer` 인터페이스를 구현하여 인터셉터, 포매터, 메시지 컨버터, CORS 설정 등을 프로그래밍 방식으로 추가하거나 수정할 수 있으며, `@EnableWebMvc`를 사용하면 자동 설정을 완전히 비활성화하고 수동 설정으로 전환할 수 있다.

## 실전 팁

### Interceptor vs Filter 차이

Filter는 서블릿 스펙의 일부로 서블릿 컨테이너 레벨에서 동작하며 DispatcherServlet 실행 전후에 요청과 응답을 가로채지만, Interceptor는 스프링 MVC의 일부로 DispatcherServlet 내부에서 HandlerMapping 이후 Handler 실행 전후에 동작하며 스프링 빈에 접근할 수 있고 ModelAndView를 수정할 수 있다. Filter는 보안, 인코딩, 로깅과 같은 저수준 처리에 적합하고 Interceptor는 인증, 권한 검사, 로깅과 같은 비즈니스 로직 관련 처리에 적합하며, Interceptor는 `HandlerInterceptor` 인터페이스의 `preHandle()`, `postHandle()`, `afterCompletion()` 메서드를 구현하여 요청 처리의 각 단계에 개입할 수 있다.

### 비동기 요청 처리

스프링 MVC는 Servlet 3.0의 비동기 요청 처리를 지원하며, 컨트롤러 메서드에서 `Callable`이나 `DeferredResult`를 반환하면 요청 처리 스레드를 즉시 반환하고 별도의 스레드에서 작업을 수행한 후 결과를 응답할 수 있다. 이는 긴 처리 시간이 필요한 작업(외부 API 호출, 대용량 데이터 처리)에서 스레드를 효율적으로 사용하여 동시 처리 성능을 향상시키며, Spring WebFlux를 사용하면 리액티브 프로그래밍 모델을 통해 완전히 논블로킹 방식으로 요청을 처리할 수 있다.

### 성능 최적화 방법

DispatcherServlet의 성능을 최적화하려면 여러 전략을 사용할 수 있으며, 정적 리소스는 DispatcherServlet을 거치지 않고 서블릿 컨테이너나 웹 서버(Nginx, Apache)가 직접 처리하도록 설정하고, ViewResolver 체인을 최소화하여 불필요한 뷰 검색을 줄이며, `@ResponseBody`나 `@RestController`를 사용할 때는 적절한 HttpMessageConverter를 선택하여 직렬화 성능을 개선하고, 인터셉터와 필터는 필수적인 것만 등록하여 오버헤드를 최소화하며, 캐싱 전략(HTTP 캐시 헤더, Spring Cache)을 적용하여 중복 요청의 처리 시간을 단축할 수 있다.

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

## 결론

DispatcherServlet은 Spring MVC의 핵심 컴포넌트로서 Front Controller 패턴을 구현하여 모든 HTTP 요청을 중앙에서 처리하고 HandlerMapping, HandlerAdapter, ViewResolver 등의 전략 인터페이스를 통해 유연하고 확장 가능한 아키텍처를 제공한다. 2004년 등장 이후 Servlet 3.0 지원과 자바 설정, Spring Boot의 자동 설정을 통해 지속적으로 발전해 왔으며, @Controller와 @RestController를 통한 전통적인 MVC와 RESTful API 개발을 모두 지원하고, 다양한 컴포넌트와 설정 옵션을 통해 인터셉터, 예외 처리, 파일 업로드, 국제화 등의 기능을 제공하며, 개발자가 비즈니스 로직에 집중할 수 있도록 웹 계층의 복잡성을 추상화하고 강력한 웹 애플리케이션 개발을 가능하게 한다.
