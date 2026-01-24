---
title: "MVC 패턴"
date: 2024-06-05T15:22:37+09:00
tags: ["디자인패턴", "아키텍처", "Spring"]
description: "Model-View-Controller 디자인 패턴의 구조와 Spring MVC 구현을 설명한다."
draft: false
---

## MVC 패턴의 탄생과 역사적 배경

MVC 패턴은 1979년 제록스 팰러앨토 연구소(Xerox PARC)에서 스몰토크(Smalltalk-76) 프로젝트를 진행하던 노르웨이 컴퓨터 과학자 Trygve Reenskaug에 의해 처음 고안되었으며, 이는 개인용 컴퓨터의 태동기에 그래픽 사용자 인터페이스(GUI)를 혁신적으로 발전시키려는 시도의 일환이었다. 당시 제록스 PARC는 현대 컴퓨팅의 많은 개념들을 개척한 곳으로, 이더넷, 레이저 프린터, 객체 지향 프로그래밍 등이 이곳에서 탄생했으며, Reenskaug는 사용자가 복잡한 데이터 구조를 효과적으로 제어하고 시각화할 수 있는 방법을 모색하던 중 데이터(Model), 표현(View), 제어(Controller)의 분리라는 아이디어를 착안했다.

초기에는 "Thing-Model-View-Editor"를 포함한 여러 명칭으로 불리다가 스몰토크 팀의 핵심 멤버였던 Adele Goldberg와의 집중적인 논의 끝에 1979년 12월 10일 Model-View-Controller라는 명칭으로 정리되었으며, 이는 각 구성 요소의 역할을 가장 명확하게 표현하는 이름으로 선택되었다. 이후 40년 이상 웹 개발, 데스크톱 애플리케이션, 모바일 앱 등 거의 모든 소프트웨어 분야에서 아키텍처의 근간을 이루는 패턴으로 자리 잡았으며, Ruby on Rails(2004), Spring Framework(2002), Django(2005), ASP.NET MVC(2009) 등 주요 웹 프레임워크의 설계 철학에 지대한 영향을 미쳤다.

## MVC 패턴의 핵심 개념과 설계 원칙

MVC 패턴은 애플리케이션을 Model, View, Controller라는 세 가지 명확히 구분된 역할로 분리하여 각 구성 요소가 독립적인 책임(Single Responsibility Principle)을 가지도록 설계하는 아키텍처 패턴이며, 이는 소프트웨어 공학의 핵심 원칙인 관심사의 분리(Separation of Concerns)를 구현하는 대표적인 방법이다. 사용자 인터페이스와 비즈니스 로직을 철저히 분리함으로써 코드의 재사용성을 높이고 변경에 대한 영향을 최소화하여 유지보수를 용이하게 만들며, 각 레이어가 명확한 경계를 가지므로 프론트엔드 개발자, 백엔드 개발자, 데이터베이스 설계자 등 여러 개발자가 동시에 각 레이어를 독립적으로 개발할 수 있어 대규모 팀의 협업 효율성을 극대화한다.

### Model (모델)

Model은 애플리케이션의 핵심 데이터와 비즈니스 로직을 담당하는 계층으로, 도메인 모델(Domain Model)이라고도 불리며 실제 세계의 비즈니스 규칙과 제약 조건을 코드로 표현한다.

주요 역할은 데이터베이스와 상호작용하며 데이터의 생명주기와 상태를 관리하고, Bean Validation(JSR-380)이나 커스텀 검증 로직을 통해 데이터의 무결성과 유효성을 검증하며, 비즈니스 요구사항에 따른 데이터 변환, 계산, 집계 로직을 포함하고, 가장 중요한 특징으로 View나 Controller에 대한 어떠한 의존성도 갖지 않고 순수한 비즈니스 로직만을 포함하여 독립적으로 동작함으로써 재사용성을 극대화하고 단위 테스트 작성을 용이하게 만든다.

Spring Boot에서는 Model이 여러 계층으로 세분화되어 구현되며, **Entity**는 JPA `@Entity` 어노테이션을 통해 데이터베이스 테이블과 1:1로 매핑되는 영속성 객체로 `@Id`, `@Column`, `@ManyToOne` 등의 어노테이션으로 테이블 구조를 정의하고, **DTO(Data Transfer Object)**는 계층 간 데이터 전송을 위한 객체로 Entity를 외부에 직접 노출하지 않고 필요한 데이터만 선택적으로 전달하여 보안과 성능을 향상시키며, **Repository**는 Spring Data JPA를 통해 데이터 접근 계층을 추상화하여 `JpaRepository` 인터페이스를 상속받아 기본적인 CRUD 메서드를 자동으로 제공받고 `@Query` 어노테이션으로 커스텀 쿼리를 정의할 수 있으며, **Service**는 `@Service` 어노테이션으로 정의되어 비즈니스 로직을 캡슐화하고 `@Transactional` 어노테이션으로 트랜잭션 경계를 설정하여 데이터의 일관성을 보장한다.

### View (뷰)

View는 사용자에게 데이터를 시각적으로 표현하는 프레젠테이션 계층으로, MVC 패턴에서 유일하게 사용자와 직접 상호작용하는 구성 요소이며 애플리케이션의 외관과 사용자 경험(UX)을 결정한다.

View는 웹 애플리케이션의 경우 HTML, CSS, JavaScript를 결합하여 구성되며 반응형 디자인과 접근성(Accessibility)을 고려하여 구현되고, 서버 사이드 렌더링을 위해 템플릿 엔진(Thymeleaf, JSP, Freemarker, Mustache 등)을 통해 동적 화면을 생성하며 각 템플릿 엔진은 조건문, 반복문, 변수 치환 등의 문법을 제공하여 데이터에 따라 다른 HTML을 렌더링할 수 있고, RESTful API 아키텍처에서는 JSON이나 XML 형태의 데이터 응답 자체가 View 역할을 수행하며 프론트엔드 프레임워크(React, Vue.js, Angular)가 이 데이터를 받아 실제 화면을 렌더링한다.

View의 가장 중요한 원칙은 Model의 데이터를 받아 사용자에게 보여주는 표현(Presentation) 역할만 수행하고 어떠한 비즈니스 로직이나 데이터 처리 로직도 포함하지 않아야 한다는 것이며, 사용자 입력(버튼 클릭, 폼 제출, 키보드 입력 등)을 받아 이를 Controller에게 전달하는 역할을 수행하고, 동일한 Model 데이터를 여러 View가 서로 다른 방식으로 표현할 수 있어 웹 브라우저, 모바일 앱, REST API 클라이언트 등 다양한 플랫폼을 동시에 지원하기 용이하며 이는 멀티 플랫폼 전략에 있어 MVC 패턴의 큰 장점이다.

### Controller (컨트롤러)

Controller는 사용자의 HTTP 요청을 받아 Model과 View 사이의 흐름을 조율하고 제어하는 중재자(Mediator) 역할을 수행하며, MVC 패턴의 세 구성 요소 중 유일하게 Model과 View 모두와 상호작용하는 계층이다.

Controller의 주요 책임은 사용자로부터 전달된 입력 데이터(쿼리 파라미터, 경로 변수, 요청 본문 등)를 검증하고 Bean Validation이나 커스텀 Validator를 통해 데이터의 형식과 값을 확인하며, 요청의 목적에 따라 적절한 Service 계층의 비즈니스 로직을 호출하고 여러 Service를 조합하여 복잡한 작업을 수행할 수 있으며, Service가 반환한 결과를 바탕으로 Model의 상태를 업데이트하거나 새로운 데이터를 생성하고, 처리 결과를 사용자에게 보여줄 적절한 View를 선택하거나 RESTful API의 경우 적절한 HTTP 상태 코드와 함께 JSON 응답을 생성하여 클라이언트에게 반환한다.

Spring Boot에서 Controller는 `@Controller` 어노테이션으로 전통적인 서버 사이드 렌더링을 수행하거나 `@RestController` 어노테이션(`@Controller` + `@ResponseBody`)으로 RESTful API 엔드포인트를 정의하며, `@GetMapping`, `@PostMapping`, `@PutMapping`, `@DeleteMapping`, `@PatchMapping` 등의 어노테이션으로 HTTP 메서드와 URL 경로를 메서드에 매핑하고, `@RequestParam`으로 쿼리 파라미터를, `@PathVariable`로 URL 경로 변수를, `@RequestBody`로 요청 본문의 JSON 데이터를, `@RequestHeader`로 HTTP 헤더를 메서드 파라미터로 바인딩할 수 있으며, `@Valid` 어노테이션과 함께 사용하여 자동으로 입력 검증을 수행하고 `BindingResult`로 검증 오류를 처리할 수 있다.

## Spring MVC의 동작 원리와 내부 아키텍처

Spring MVC는 GoF(Gang of Four) 디자인 패턴 중 하나인 프론트 컨트롤러 패턴(Front Controller Pattern)을 기반으로 설계되었으며, 이는 J2EE(Java 2 Platform, Enterprise Edition) 패턴 카탈로그에서도 권장하는 웹 애플리케이션 아키텍처 패턴이다. DispatcherServlet이라는 중앙 집중식 컨트롤러(Centralized Controller)가 모든 HTTP 요청을 최초로 받아들이고 적절한 핸들러(Handler)에게 위임하는 구조로 동작하며, 이를 통해 인증(Authentication), 인가(Authorization), 로깅(Logging), 예외 처리(Exception Handling), 국제화(i18n), CORS 설정 등의 공통 관심사(Cross-Cutting Concerns)를 한 곳에서 일관되게 처리할 수 있고 개발자는 비즈니스 로직 구현에만 집중할 수 있어 생산성이 크게 향상된다.

### 요청 처리 흐름의 상세 단계

1. **요청 수신**: 클라이언트(웹 브라우저, 모바일 앱, 외부 API 등)가 전송한 HTTP 요청이 웹 애플리케이션 서버(Tomcat, Jetty, Undertow 등)를 거쳐 DispatcherServlet에 도착하며, DispatcherServlet은 `web.xml` 또는 Java Config(`@EnableWebMvc`)를 통해 등록된 Spring의 핵심 서블릿이다.

2. **핸들러 매핑**: HandlerMapping 인터페이스의 구현체(`RequestMappingHandlerMapping`, `BeanNameUrlHandlerMapping` 등)가 요청 URL, HTTP 메서드, 헤더, 파라미터 등을 분석하여 해당 요청을 처리할 수 있는 Controller의 메서드(핸들러)를 찾으며, Spring Boot는 기본적으로 `@RequestMapping` 계열 어노테이션을 분석하는 `RequestMappingHandlerMapping`을 사용한다.

3. **핸들러 실행**: HandlerAdapter가 찾아진 핸들러를 실제로 실행하며 `@RequestParam`, `@PathVariable`, `@RequestBody` 등의 어노테이션을 분석하여 HTTP 요청의 데이터를 메서드 파라미터로 자동 변환(Data Binding)하고, `@Valid`와 함께 사용된 경우 Bean Validation을 수행하여 입력 데이터를 검증한다.

4. **비즈니스 로직 처리**: Controller 메서드가 Service 계층을 호출하여 비즈니스 로직을 수행하고 필요한 경우 Repository를 통해 데이터베이스에 접근하며, `@Transactional` 어노테이션으로 트랜잭션 경계가 설정된 경우 AOP(Aspect-Oriented Programming)를 통해 트랜잭션이 자동으로 관리되고, 처리가 완료되면 Model 데이터와 View 이름(또는 `@RestController`의 경우 직접 반환할 객체)을 반환한다.

5. **뷰 해석**: ViewResolver 인터페이스의 구현체(`InternalResourceViewResolver`, `ThymeleafViewResolver` 등)가 Controller가 반환한 View 이름(예: "user/list")을 실제 View 파일의 경로(예: "/WEB-INF/views/user/list.jsp" 또는 "/templates/user/list.html")로 변환하여 View 객체를 생성하며, RESTful API의 경우 `@RestController`가 반환하는 객체를 `HttpMessageConverter`(Jackson, Gson 등)가 JSON이나 XML로 직렬화한다.

6. **응답 생성**: View가 Model 데이터를 사용하여 HTML을 렌더링하거나 JSON 응답이 생성되고, 최종적으로 HTTP 응답(상태 코드, 헤더, 본문)이 클라이언트에게 전달되며, 브라우저는 이를 해석하여 사용자에게 시각적으로 표시한다.

이 전체 과정에서 HandlerInterceptor 인터페이스를 구현한 인터셉터들이 `preHandle()`(요청 전), `postHandle()`(요청 후, 뷰 렌더링 전), `afterCompletion()`(뷰 렌더링 후) 시점에 개입하여 로깅, 성능 측정, 인증 확인, 권한 검사 등의 공통 처리를 수행할 수 있으며, 예외가 발생하면 `@ExceptionHandler` 어노테이션이나 `@ControllerAdvice`를 통해 전역적으로 예외를 처리하여 사용자 친화적인 에러 페이지나 일관된 형식의 에러 응답을 생성한다.

## MVC 패턴의 장단점

### 장점

- **관심사의 분리**: 도메인 로직과 UI 로직을 독립적으로 개발하고 수정할 수 있다. 이는 코드의 가독성과 유지보수성을 크게 향상시킨다. 특정 부분의 변경이 다른 부분에 영향을 미치지 않도록 하여 안정성을 높인다.

- **높은 재사용성**: 동일한 Model을 여러 View에서 재사용할 수 있어 웹, 모바일, API 등 다양한 클라이언트를 동시에 지원하기 용이하다. View의 변경이 Model에 영향을 주지 않으므로 UI를 자유롭게 개선하거나 교체할 수 있다.

- **테스트 용이성**: 각 레이어를 독립적으로 테스트할 수 있어 단위 테스트 작성이 용이하다. Mock 객체를 활용하여 Controller와 Service 로직을 격리하여 테스트할 수 있다. 통합 테스트 시에도 각 구성 요소의 책임이 명확하여 오류 원인을 빠르게 파악할 수 있다.

### 단점

- **Massive Controller 현상**: 복잡한 애플리케이션에서는 Controller가 과도하게 비대해질 수 있다. 하나의 Controller가 여러 Model과 View를 동시에 다루면서 수백 줄의 코드를 포함하게 된다. 이는 코드 분석과 테스트를 어렵게 만들며 새로운 기능 추가 시 의존성 문제를 야기한다.

- **Model과 View의 의존성**: Model과 View 사이의 의존성을 완전히 제거하기 어렵다. 특히 전통적인 MVC 구현에서는 View가 Model을 직접 참조하는 경우가 많아 두 계층 간의 결합도가 높아진다. 이는 View나 Model의 변경이 서로에게 영향을 미칠 수 있어 유지보수를 복잡하게 만든다.

- **생명주기 공유 문제**: Controller와 View가 생명주기(Lifecycle)를 공유하는 경우가 많아 둘을 완전히 분리하기 어렵다. 특히 Android 등의 플랫폼에서는 Activity나 Fragment가 Controller와 View 역할을 동시에 수행하여 테스트와 재사용이 어려워진다.

## MVC vs MVP vs MVVM

MVC의 한계를 극복하기 위해 MVP(Model-View-Presenter)와 MVVM(Model-View-ViewModel) 패턴이 등장했다. 각 패턴은 View와 Model 사이의 의존성을 다르게 처리한다.

### MVP (Model-View-Presenter)

MVP 패턴은 MVC의 Controller를 Presenter로 대체하여 View와 Model 사이의 의존성을 완전히 제거한 패턴이다.

주요 특징은 다음과 같다.

- View는 Presenter를 통해서만 Model과 통신하며 직접적인 참조를 갖지 않음
- Presenter는 View 인터페이스를 통해 View를 제어하여 둘 사이의 결합도를 낮춤
- View를 쉽게 Mock으로 대체하여 Presenter를 독립적으로 테스트할 수 있음

하지만 View와 Presenter 사이에 1:1 관계가 형성되어 Presenter가 특정 View에 강하게 결합된다. 애플리케이션이 복잡해질수록 Presenter도 비대해지는 문제가 발생한다.

### MVVM (Model-View-ViewModel)

MVVM 패턴은 데이터 바인딩(Data Binding)을 활용하여 View와 ViewModel 사이의 동기화를 자동화한 패턴이다.

주요 특징은 다음과 같다.

- View의 변경이 ViewModel에 자동으로 반영되고 그 반대도 마찬가지로 동작
- ViewModel은 특정 View에 대한 의존성 없이 순수한 데이터와 로직만을 포함
- 재사용성과 테스트 용이성이 높음

MVVM은 Angular, React, Vue.js 등 현대적인 프론트엔드 프레임워크에서 널리 채택되었다. 양방향 데이터 바인딩을 통해 UI와 상태를 일치시키는 것이 용이하고, 선언적 프로그래밍 스타일을 지원하여 코드의 가독성이 높아진다.

### 패턴 선택 가이드

각 패턴의 적용 대상은 다음과 같다.

- **MVC**: 전통적인 서버 사이드 웹 애플리케이션(Spring, Django, Ruby on Rails)에 적합하다. 서버에서 HTML을 렌더링하여 반환하는 구조에 최적화되어 있다. 구현이 직관적이며 학습 곡선이 낮아 빠르게 프로토타입을 개발할 수 있다.

- **MVP**: Android 개발이나 테스트 가능성이 중요한 프로젝트에서 유용하다. View와 Model의 완전한 분리가 필요한 경우 선택된다. Presenter를 통해 View의 로직을 격리하여 단위 테스트를 작성하기 용이하다.

- **MVVM**: 프론트엔드 중심의 SPA 애플리케이션(React, Vue.js, Angular)에서 널리 사용된다. 데이터 바인딩과 반응형 프로그래밍을 통해 복잡한 UI 상태 관리를 효율적으로 처리한다. 컴포넌트 재사용성이 높아 대규모 프론트엔드 애플리케이션 개발에 적합하다.

## 결론

MVC 패턴은 1979년 탄생 이후 40년 이상 소프트웨어 아키텍처의 근간을 이루며 발전해 왔다. Spring, Django, Ruby on Rails 등 주요 웹 프레임워크의 기반이 되었으며, 관심사의 분리와 코드 재사용성 향상이라는 핵심 가치를 제공한다.

비록 Controller의 비대화, Model과 View의 의존성 문제 등의 한계가 존재하지만, Spring MVC의 DispatcherServlet, 인터셉터, AOP 등의 고급 기능과 REST API 아키텍처, 마이크로서비스 패턴 등과 결합하여 여전히 현대적인 웹 애플리케이션 개발에 효과적으로 활용되고 있다.

프로젝트의 요구사항, 팀의 기술 스택, 애플리케이션의 복잡도를 고려하여 MVC, MVP, MVVM 중 적절한 패턴을 선택하고, 필요에 따라 여러 패턴을 혼합하여 사용하는 것이 최선의 접근법이다. 패턴 자체보다는 각 패턴이 추구하는 관심사의 분리와 유지보수성 향상이라는 본질을 이해하고 적용하는 것이 중요하다.
