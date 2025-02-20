---
title: "MVC 패턴이란?"
date: 2024-06-05T15:22:37+09:00
tags: ["mvc", "design pattern"]
draft: false
---

MVC 패턴(Model-View-Controller)은 소프트웨어 디자인 패턴 중 하나로, 소프트웨어를 세 가지 부분으로 나누어 개발하는 방법론이다. MVC 패턴은 소프트웨어를 Model, View, Controller 세 가지 부분으로 나누어 개발함으로써 소프트웨어의 유지보수성과 확장성을 높이고, 개발자들이 소프트웨어를 더 쉽게 이해하고 개발할 수 있도록 도와준다.

### Model

Model은 소프트웨어의 데이터를 담당하는 부분으로, 데이터의 구조와 데이터를 다루는 로직을 담당한다.

### View

View는 소프트웨어의 사용자 인터페이스를 담당하는 부분으로, 사용자에게 데이터를 보여주는 역할을 한다.

### Controller

Controller는 소프트웨어의 비즈니스 로직을 담당하는 부분으로, 사용자의 입력을 받아 Model과 View를 제어한다.

MVC 패턴은 소프트웨어를 세 가지 부분으로 나누어 개발함으로써 소프트웨어의 유지보수성과 확장성을 높이고, 개발자들이 소프트웨어를 더 쉽게 이해하고 개발할 수 있도록 도와준다. MVC 패턴은 웹 개발에서도 많이 사용되며, 대표적인 웹 프레임워크인 Spring, Django, Ruby on Rails 등에서도 MVC 패턴을 기반으로 개발되었다.

## Spring Boot에서 MVC 패턴 사용법

#### Model

Spring Boot에서 Model은 데이터를 담당하는 부분으로, 데이터의 구조와 데이터를 다루는 로직을 담당한다. Java 클래스로 정의되며, 데이터를 담는 필드와 데이터를 다루는 메소드로 구성된다. DTO, Entity, Repository 등의 컴포넌트를 사용하여 데이터를 정의하고 다룰 수 있다.

#### View

Spring Boot에서 View는 사용자 인터페이스를 담당하는 부분으로, 사용자에게 데이터를 보여주는 역할을 한다. HTML 파일로 정의되며, Thymeleaf, Freemarker, JSP 등의 템플릿 엔진을 사용하여 데이터를 보여준다. Thymeleaf 템플릿 엔진을 사용하여 HTML 파일을 작성하고, Controller에서 Model에 담긴 데이터를 View에 전달하여 사용자에게 보여줄 수 있다. `@RestController` 어노테이션을 사용하여 REST API를 구현할 때는 JSON 형식으로 데이터를 반환할 수 있다.

#### Controller

Spring Boot에서 Controller는 비즈니스 로직을 담당하는 부분으로, 사용자의 입력을 받아 Model과 View를 제어한다. Java 클래스로 정의되며, 사용자의 요청을 받아 Model을 처리하고 View를 보여준다. `@Controller` 어노테이션을 사용하여 Controller 클래스를 정의하고, `@GetMapping`, `@PostMapping` 어노테이션을 사용하여 사용자의 요청을 처리할 수 있다.
