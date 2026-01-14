---
title: "MVC 패턴이란?"
date: 2024-06-05T15:22:37+09:00
tags: ["mvc", "design pattern", "spring", "architecture"]
description: "1979년 탄생한 MVC 패턴의 역사부터 Spring MVC의 동작 원리, 장단점, MVP/MVVM과의 비교까지 정리"
draft: false
---

## MVC 패턴의 탄생

MVC 패턴은 1979년 제록스 팰러앨토 연구소(Xerox PARC)에서 스몰토크(Smalltalk) 프로젝트를 진행하던 노르웨이 컴퓨터 과학자 Trygve Reenskaug에 의해 처음 고안되었다. 당시 그래픽 사용자 인터페이스(GUI) 소프트웨어를 설계하면서 사용자가 복잡한 데이터를 효과적으로 제어하고 시각화할 수 있는 방법을 모색하던 중 탄생했다.

초기에는 여러 명칭으로 불리다가 Adele Goldberg와의 논의 끝에 1979년 12월 10일 Model-View-Controller라는 명칭으로 정리되었다. 이후 40년 이상 소프트웨어 아키텍처의 근간을 이루는 패턴으로 자리 잡았다.

## MVC 패턴의 핵심 개념

MVC 패턴은 애플리케이션을 Model, View, Controller라는 세 가지 역할로 분리하여 각 구성 요소가 독립적인 책임을 가지도록 설계하는 아키텍처 패턴이다. 사용자 인터페이스와 비즈니스 로직을 분리함으로써 코드의 재사용성을 높이고 유지보수를 용이하게 만든다. 여러 개발자가 동시에 각 레이어를 독립적으로 개발할 수 있도록 하여 협업 효율성을 극대화한다.

### Model (모델)

Model은 애플리케이션의 핵심 데이터와 비즈니스 로직을 담당하는 계층이다.

주요 역할은 다음과 같다.

- 데이터베이스와 상호작용하며 데이터의 상태를 관리
- 데이터의 유효성을 검증
- 데이터 변환 및 계산 로직을 포함
- View나 Controller에 대한 의존성 없이 독립적으로 동작하여 재사용성을 극대화

Spring Boot에서는 Entity, DTO, Repository, Service 등의 컴포넌트로 구성되며, JPA를 통해 데이터베이스 테이블과 매핑되고 트랜잭션 처리와 비즈니스 규칙을 구현한다.

### View (뷰)

View는 사용자에게 데이터를 시각적으로 표현하는 프레젠테이션 계층이다.

다양한 형태로 구현될 수 있다.

- HTML, CSS, JavaScript를 사용한 웹 페이지
- 템플릿 엔진(Thymeleaf, JSP, Freemarker 등)을 통한 동적 화면 생성
- JSON/XML 형태의 API 응답

View는 Model의 데이터를 받아 사용자에게 보여주는 역할만 수행하고 비즈니스 로직을 포함하지 않아야 한다. 사용자 입력을 받아 Controller에게 전달하며, 동일한 Model 데이터를 여러 View가 다른 방식으로 표현할 수 있어 다양한 클라이언트(웹, 모바일, API 등)를 지원하기 용이하다.

### Controller (컨트롤러)

Controller는 사용자의 요청을 받아 Model과 View 사이의 흐름을 제어하는 중재자 역할을 수행한다.

주요 책임은 다음과 같다.

- 사용자 입력을 검증
- 적절한 비즈니스 로직을 호출
- Model의 상태를 업데이트
- 결과를 표시할 적절한 View를 선택하여 응답을 생성

Spring Boot에서는 `@Controller` 또는 `@RestController` 어노테이션을 사용하여 정의되며, `@GetMapping`, `@PostMapping` 등으로 HTTP 요청을 메서드에 매핑하고, `@RequestParam`, `@PathVariable`, `@RequestBody` 등으로 파라미터를 바인딩한다.

## Spring MVC의 동작 원리

Spring MVC는 프론트 컨트롤러 패턴(Front Controller Pattern)을 기반으로 설계되었다. DispatcherServlet이라는 중앙 집중식 컨트롤러가 모든 HTTP 요청을 받아 적절한 핸들러(Handler)에게 위임하는 구조로 동작한다. 이를 통해 공통 관심사(인증, 로깅, 예외 처리 등)를 한 곳에서 처리할 수 있으며 개발자는 비즈니스 로직에만 집중할 수 있다.

### 요청 처리 흐름

1. 클라이언트의 HTTP 요청이 DispatcherServlet에 도착
2. HandlerMapping을 통해 요청 URL에 매핑되는 Controller를 찾음
3. HandlerAdapter가 해당 Controller의 메서드를 실행
4. Controller는 비즈니스 로직을 수행한 후 Model 데이터와 View 이름을 반환
5. ViewResolver가 실제 View 객체를 찾아 렌더링
6. 최종 HTTP 응답을 클라이언트에게 전달

이 과정에서 인터셉터(Interceptor)가 요청 전후에 개입하여 로깅, 인증, 권한 검사 등의 공통 처리를 수행할 수 있다. 예외가 발생하면 ExceptionHandler가 이를 처리하여 적절한 에러 응답을 생성한다.

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
