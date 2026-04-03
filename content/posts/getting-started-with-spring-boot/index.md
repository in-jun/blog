---
title: "Spring Boot 시작하기"
date: 2024-05-16T22:14:17+09:00
tags: ["Spring", "Java", "프레임워크"]
description: "Spring Boot의 핵심 개념과 프로젝트 설정 방법을 다룬다."
draft: false
---

## Spring Framework의 역사와 등장 배경

Spring Framework는 2002년 Rod Johnson이 그의 저서 "Expert One-on-One J2EE Design and Development"에서 제시한 아이디어를 바탕으로, 2003년에 처음 공개된 자바 기반 엔터프라이즈 애플리케이션 프레임워크다. 당시 복잡하고 무거웠던 EJB(Enterprise JavaBeans) 2.x는 컨테이너에 강하게 결합되어 단위 테스트가 어렵고 XML 설정이 방대해 개발 생산성이 낮았다. Spring은 이에 대한 대안으로 등장해 POJO(Plain Old Java Object) 기반의 경량 개발 방식을 제시했고, IoC(Inversion of Control)와 DI(Dependency Injection)를 핵심으로 객체 간 결합도를 낮추고 테스트 용이성을 높였다.

Spring Framework는 2004년 1.0 정식 출시 이후 지속적으로 발전해 왔다. 2006년 Spring 2.0에서는 XML 네임스페이스와 어노테이션 지원이 추가되었고, 2009년 Spring 3.0에서는 자바 5 기반의 어노테이션 구성(@Configuration, @Bean)과 REST 지원이 강화되었다. 이어 2013년 Spring 4.0에서는 자바 8 람다와 웹소켓 지원이 도입되었다. 현재 Spring 6.0(2022년)은 자바 17을 기본으로 하며, Jakarta EE 9+ 네임스페이스를 채택해 javax.* 대신 jakarta.*를 사용한다. 또한 GraalVM 네이티브 이미지 지원을 강화해 클라우드 네이티브 환경에 더욱 적합해졌다.

## Spring Boot의 탄생과 철학

Spring Boot는 2014년 Pivotal(현재 VMware)에서 Spring Framework 기반 애플리케이션의 복잡한 설정을 자동화하고, 빠른 프로토타이핑을 가능하게 하기 위해 출시한 프레임워크다. "Convention over Configuration(설정보다 관례)" 철학을 바탕으로 개발자가 비즈니스 로직에 더 집중할 수 있게 한다. Spring Boot 이전에는 Spring MVC 웹 애플리케이션을 만들기 위해 web.xml, applicationContext.xml, dispatcher-servlet.xml 등 수십 줄에서 수백 줄에 달하는 XML 설정이 필요했고, 톰캣이나 제티 같은 외부 서블릿 컨테이너를 별도로 설치한 뒤 WAR 파일을 배포해야 했다.

Spring Boot의 핵심 기능으로는 자동 구성(Auto-configuration), 내장 서버(Embedded Server), 스타터 의존성(Starter Dependencies), 액추에이터(Actuator)가 있다. 자동 구성은 클래스패스에 있는 라이브러리를 감지해 해당 기술에 필요한 빈을 자동으로 등록한다. 내장 서버는 톰캣, 제티, 언더토우를 JAR 파일 안에 포함해 `java -jar` 명령만으로 애플리케이션을 실행할 수 있게 한다. 스타터 의존성은 관련 라이브러리를 하나의 의존성으로 묶어 버전 호환성 문제를 줄여 주며, 액추에이터는 애플리케이션의 상태, 메트릭, 헬스 체크 엔드포인트를 제공해 운영 환경의 모니터링을 쉽게 해 준다.

## Spring IoC 컨테이너와 의존성 주입

### 제어의 역전(IoC)

제어의 역전(Inversion of Control)은 프로그램의 제어 흐름을 개발자가 아닌 프레임워크가 관리하는 설계 원칙으로, 전통적인 프로그래밍에서는 개발자가 객체를 직접 생성하고 메서드를 호출하는 반면, IoC에서는 프레임워크가 객체의 생성과 생명주기를 관리하고 적절한 시점에 개발자의 코드를 호출한다. Spring의 IoC 컨테이너(ApplicationContext)는 빈(Bean) 정의를 읽어 객체를 생성하고, 의존성을 주입하며, 빈의 초기화와 소멸을 관리하는 역할을 하며, 이를 통해 객체 간의 결합도가 낮아지고 테스트와 유지보수가 용이해진다.

### 의존성 주입(DI)

의존성 주입(Dependency Injection)은 객체가 필요로 하는 의존 객체를 외부에서 주입받는 패턴으로, 객체가 직접 의존 객체를 생성하거나 찾지 않고 컨테이너가 주입해주므로 느슨한 결합(Loose Coupling)이 실현된다. Spring은 생성자 주입(Constructor Injection), 세터 주입(Setter Injection), 필드 주입(Field Injection) 세 가지 방식을 지원하며, Spring 4.3 이후부터는 단일 생성자에 대해 @Autowired 생략이 가능해졌고, 현재는 불변성과 테스트 용이성 때문에 생성자 주입이 권장된다.

```java
@Service
public class OrderService {
    private final OrderRepository orderRepository;
    private final PaymentService paymentService;

    // 생성자 주입 - @Autowired 생략 가능 (단일 생성자)
    public OrderService(OrderRepository orderRepository, PaymentService paymentService) {
        this.orderRepository = orderRepository;
        this.paymentService = paymentService;
    }
}
```

## 스프링 빈과 빈 스코프

### 스프링 빈의 개념

스프링 빈(Spring Bean)은 Spring IoC 컨테이너가 관리하는 자바 객체로, 컨테이너가 객체의 생성, 의존성 주입, 초기화, 소멸까지 전체 생명주기를 관리한다. 빈은 @Component, @Service, @Repository, @Controller 같은 스테레오타입 어노테이션으로 자동 스캔하거나, @Configuration 클래스 내의 @Bean 메서드로 명시적으로 등록할 수 있으며, Spring Boot는 @SpringBootApplication 어노테이션에 포함된 @ComponentScan이 기본 패키지와 하위 패키지의 모든 컴포넌트를 자동으로 스캔한다.

### 빈 스코프

빈 스코프(Bean Scope)는 빈 인스턴스가 존재하는 범위를 정의하며, 기본값인 싱글톤(Singleton) 스코프에서는 Spring 컨테이너당 하나의 인스턴스만 생성되어 모든 요청에서 공유된다. 프로토타입(Prototype) 스코프는 빈을 요청할 때마다 새 인스턴스를 생성한다. 웹 환경에서는 리퀘스트(Request), 세션(Session), 애플리케이션(Application) 스코프가 추가로 제공되며, 각각 HTTP 요청, HTTP 세션, 서블릿 컨텍스트와 생명주기를 함께한다.

| 스코프 | 설명 | 생명주기 |
|--------|------|----------|
| singleton | 컨테이너당 하나의 인스턴스 (기본값) | 컨테이너 시작 ~ 종료 |
| prototype | 요청마다 새 인스턴스 생성 | 생성 후 컨테이너가 관리하지 않음 |
| request | HTTP 요청마다 생성 | 요청 시작 ~ 종료 |
| session | HTTP 세션마다 생성 | 세션 생성 ~ 만료 |
| application | 서블릿 컨텍스트마다 생성 | 컨텍스트 시작 ~ 종료 |

## AOP(관점 지향 프로그래밍)

### AOP의 개념과 용어

AOP(Aspect-Oriented Programming)는 횡단 관심사(Cross-cutting Concerns)를 모듈화하는 프로그래밍 패러다임으로, 로깅, 트랜잭션 관리, 보안, 캐싱처럼 여러 모듈에 걸쳐 반복되는 코드를 핵심 비즈니스 로직에서 분리하여 관리한다. AOP의 핵심 용어로는 Aspect(횡단 관심사를 모듈화한 클래스), Join Point(Advice가 적용될 수 있는 지점), Pointcut(Join Point를 선별하는 표현식), Advice(특정 Join Point에서 실행되는 코드), Weaving(Aspect를 대상 객체에 적용하는 과정)이 있으며, Spring AOP는 런타임에 프록시를 생성하여 Weaving을 수행한다.

### Advice 종류

Spring AOP는 다섯 가지 Advice 타입을 제공한다. `@Before`는 대상 메서드 실행 전에, `@AfterReturning`은 정상 반환 후에, `@AfterThrowing`은 예외 발생 시에 실행된다. `@After`는 정상 종료 여부와 관계없이 실행되며, `@Around`는 대상 메서드 실행 전후를 모두 제어할 수 있다. `@Around`가 가장 강력해 메서드 실행 여부 결정, 반환값 조작, 예외 처리까지 모두 제어할 수 있지만, 단순한 작업에는 목적에 맞는 Advice를 사용하는 편이 코드 가독성에 더 좋다.

```java
@Aspect
@Component
public class PerformanceAspect {

    @Around("execution(* com.example.service.*.*(..))")
    public Object measureExecutionTime(ProceedingJoinPoint joinPoint) throws Throwable {
        long start = System.currentTimeMillis();
        Object result = joinPoint.proceed();
        long executionTime = System.currentTimeMillis() - start;
        System.out.println(joinPoint.getSignature() + " 실행 시간: " + executionTime + "ms");
        return result;
    }
}
```

## Spring Boot 자동 구성

### 자동 구성의 동작 원리

Spring Boot의 자동 구성(Auto-configuration)은 `@SpringBootApplication`에 포함된 `@EnableAutoConfiguration`에 의해 활성화된다. 이 기능은 `spring-boot-autoconfigure` 모듈의 `META-INF/spring/org.springframework.boot.autoconfigure.AutoConfiguration.imports` 파일에 정의된 설정 클래스들을 조건부로 로드한다. 각 자동 구성 클래스는 `@ConditionalOnClass`, `@ConditionalOnMissingBean`, `@ConditionalOnProperty` 같은 조건부 어노테이션을 사용해 특정 클래스가 클래스패스에 있거나, 특정 빈이 없거나, 특정 프로퍼티가 설정된 경우에만 활성화된다. 따라서 개발자가 명시적으로 설정한 빈이 있으면 자동 구성은 물러나고 개발자의 설정이 우선한다.

### 스타터 의존성

스타터 의존성(Starter Dependencies)은 특정 기능을 사용하는 데 필요한 모든 라이브러리를 하나의 의존성으로 묶은 것으로, spring-boot-starter-web은 Spring MVC, 내장 톰캣, Jackson JSON 등 웹 개발에 필요한 의존성을 포함하고, spring-boot-starter-data-jpa는 Spring Data JPA, Hibernate, HikariCP 등 JPA 관련 의존성을 포함한다. 스타터를 사용하면 개별 라이브러리의 버전을 일일이 관리할 필요 없이 spring-boot-dependencies BOM(Bill of Materials)에서 관리하는 호환 버전이 자동으로 적용되어 버전 충돌 문제를 방지할 수 있다.

## 결론

Spring Framework는 2003년 EJB의 복잡성에 대한 대안으로 등장해, IoC와 DI를 통해 자바 엔터프라이즈 개발의 패러다임을 바꿨다. 2014년에 출시된 Spring Boot는 자동 구성과 내장 서버를 통해 설정의 복잡성을 크게 줄였고, 마이크로서비스와 클라우드 네이티브 개발에 적합한 환경을 제공했다.

Spring의 핵심은 IoC 컨테이너를 통한 의존성 주입에 있다. 이를 통해 객체 간 결합도를 낮추고 테스트 용이성을 높일 수 있으며, 빈 스코프와 AOP를 활용해 객체의 생명주기와 횡단 관심사를 선언적으로 관리할 수 있다.

또한 Spring Boot의 스타터와 자동 구성은 개발자가 비즈니스 로직에 더 집중할 수 있게 돕고, 액추에이터는 운영 환경에서 모니터링과 관리를 쉽게 해 준다. 이런 점에서 Spring Boot는 현대 자바 백엔드 개발의 사실상 표준으로 자리 잡았다.
