---
title: "JAVA 알아보기"
date: 2024-05-16T08:30:54+09:00
tags: ["JAVA"]
draft: false
---

## 자바 알아보기

### JAVA 란?

**JAVA** 는 객체 지향 프로그래밍 언어이다.
**Sun Microsystems** 에서 개발되었으며, **James Gosling** 이 주도적으로 개발하였다.
**Write Once, Run Anywhere** 라는 슬로건을 가지고 있으며, 이는 JAVA로 작성된 프로그램은 어떤 플랫폼에서도 실행될 수 있다는 것을 의미한다.

### JAVA 특징

1.  **객체 지향 프로그래밍 언어**
    -   객체 지향 프로그래밍 언어를 사용하면 코드의 재사용성이 높아지고 유지보수가 쉬워진다.
2.  **플랫폼 독립성**
    -   JAVA로 작성된 프로그램은 어떤 플랫폼에서도 실행될 수 있다.
3.  **멀티 스레드 지원**
    -   멀티 스레드를 사용하면 여러 작업을 동시에 처리할 수 있어서 프로그램의 성능이 향상된다.
4.  **동적 로딩 지원**
    -   동적 로딩을 사용하면 프로그램 실행 시에 필요한 클래스를 동적으로 로딩할 수 있다.
5.  **예외 처리 지원**
    -   예외 처리를 사용하면 프로그램 실행 중에 발생한 예외를 처리할 수 있다.

### JAVA 개발 환경 구축

1.  **JDK(Java Development Kit) 설치**
    -   JDK를 설치하면 JAVA 프로그램을 개발할 수 있는 환경을 구축할 수 있다.
2.  **코드 에디터 설치**
    -   코드 에디터를 설치하면 JAVA 코드를 작성할 수 있다.
    -   대표적인 코드 에디터: **IntelliJ IDEA**, **Eclipse**

### JAVA 실행 방법

1.  **컴파일**
    -   JAVA 소스 코드를 컴파일하면 바이트 코드가 생성된다.
    -   컴파일 명령어: `javac HelloWorld.java`
2.  **실행**
    -   바이트 코드를 실행하면 JAVA 프로그램이 실행된다.
    -   실행 명령어: `java HelloWorld`

## JAVA 기본 문법

### 연사자와 반복분

1.  **연산자**
    -   JAVA에서는 다양한 연산자를 제공한다.
    -   대표적인 연산자: `+`, `-`, `*`, `/`, `%`
    -   연산자를 사용하면 특정 작업을 수행할 수 있다.
    -   ```java
         int a = 10;
         int b = 20;
         int c = a + b;
         System.out.println(c);
        ```
2.  **반복문**
    -   JAVA에서는 다양한 반복문을 제공한다.
    -   대표적인 반복문: `for`, `while`, `do-while`
    -   반복문을 사용하면 특정 작업을 반복해서 수행할 수 있다.
    -   ```java
         for (int i = 0; i < 10; i++) {
             System.out.println(i);
         }
        ```

### 매서드와 필드

1.  **매서드**

    -   클래스에 정의된 함수이다.
    -   특정 작업을 수행할 수 있다.
    -   코드의 재사용성이 높아진다.
    -   ```java
         class Car {
             String color;
             int speed;

             void drive() {
                 System.out.println("Driving...");
             }
         }
        ```

2.  **필드**

    -   클래스에 정의된 변수이다.
    -   객체의 상태를 나타낼 수 있다.
    -   객체의 상태를 저장할 수 있다.
    -   ```java
         class Car {
             String color;
             int speed;
         }
        ```

### 클래스와 객체

1.  **클래스**
    -   JAVA에서는 클래스를 사용하여 객체를 만들 수 있다.
    -   클래스는 객체를 만들기 위한 틀이다.
    -   객체를 만들 수 있고, 객체를 사용하여 작업을 수행할 수 있다.
    -   ```java
         class Car {
             String color;
             int speed;
         }
        ```
2.  **객체**

    -   JAVA에서는 클래스를 사용하여 객체를 만들 수 있다.
    -   객체는 클래스의 인스턴스이다.
    -   클래스에 정의된 필드와 메서드를 사용할 수 있다.
    -   ```java
         Car myCar = new Car();
         myCar.color = "Red";
         myCar.speed = 100;

        ```

### 생성자

1.  **생성자**

    -   객체를 초기화하는 데 사용된다.
    -   클래스의 이름과 동일한 이름을 가진다.
    -   사용하면 객체를 만들 때 필요한 초기화 작업을 수행할 수 있다.
    -   ```java
         class Car {
             String color;
             int speed;

             Car(String color, int speed) {
                 this.color = color;
                 this.speed = speed;
             }
         }
        ```

### 인터페이스

1.  **인터페이스**
    -   클래스의 일종이다.
    -   클래스에 정의된 메서드를 구현할 수 있다.
    -   다형성을 구현할 수 있다.
    -   ```java
         interface Animal {
             void eat();
             void sleep();
         }
        ```

### 상속

1. **상속**

    - 클래스의 특성을 다른 클래스에게 물려주는 것을 말한다.
    - 코드의 재사용성이 높아진다.
    - 클래스의 계층 구조를 만들 수 있다.
    - ```java
       class Animal {
           void eat() {
               System.out.println("Eating...");
           }
       }

       class Dog extends Animal {
           void bark() {
               System.out.println("Barking...");
           }
       }
      ```

### 오버라이딩

1.  **오버라이딩**

    -   부모 클래스에 정의된 메서드를 자식 클래스에서 재정의하는 것을 말한다.
    -   다형성을 구현할 수 있다.
    -   ```java
         class Animal {
             void eat() {
                 System.out.println("Eating...");
             }
         }

         class Dog extends Animal {
             void eat() {
                 System.out.println("Eating dog food...");
             }
         }
        ```

### 오버로딩

1.  **오버로딩**

    -   같은 이름의 메서드를 여러 개 정의하는 것을 말한다.
    -   메서드의 이름을 동일하게 유지하면서 다양한 매개변수를 사용할 수 있다.
    -   ```java
         class Calculator {
             int add(int a, int b) {
                 return a + b;
             }

             int add(int a, int b, int c) {
                 return a + b + c;
             }
         }
        ```

### 추상화와 다형성

1.  **추상화**
    -   객체의 공통적인 특성을 추출하는 것을 말한다.
    -   객체의 공통적인 특성을 나타낼 수 있다.
    -   ```java
         abstract class Animal {
             abstract void eat();
         }
        ```
        > **abstract**란?
        >
        > -   추상 클래스나 추상 메서드를 정의할 때 사용된다.
        > -   추상 클래스나 추상 메서드는 구현되지 않은 메서드를 가지고 있다.
2.  **다형성**

    -   객체의 다양한 형태를 나타내는 것을 말한다.
    -   ```java
         class Animal {
             void eat() {
                 System.out.println("Eating...");
             }
         }

         class Dog extends Animal {
             void eat() {
                 System.out.println("Eating dog food...");
             }
         }
        ```

### 제네릭

1.  **제네릭**

    -   클래스나 메서드를 정의할 때 타입을 파라미터로 사용하는 것이다.
    -   ```java
         class Box<T> {
             T value;

             Box(T value) {
                 this.value = value;
             }
         }
        ```

### 컬렉션 프레임워크

1.  **컬렉션 프레임워크**

    -   데이터를 저장하고 관리하는 데 사용되는 클래스들의 집합을 말한다.
    -   JAVA에서는 다양한 컬렉션 프레임워크를 제공한다.
    -   ```java
            import java.util.ArrayList;
            import java.util.HashSet;
            import java.util.HashMap;
        ```

2.  **List**
    -   List는 순서가 있는 데이터를 저장하는 데 사용되는 인터페이스이다.
    -   ```java
         List<String> list = new ArrayList<>();
         list.add("Java");
         list.add("Python");
         list.add("C++");
        ```
3.  **Set**
    -   Set은 순서가 없는 데이터를 저장하는 데 사용되는 인터페이스이다.
    -   ```java
         Set<String> set = new HashSet<>();
         set.add("Java");
         set.add("Python");
         set.add("C++");
        ```
4.  **Map**
    -   Map은 키와 값으로 이루어진 데이터를 저장하는 데 사용되는 인터페이스이다.
    -   ```java
         Map<String, String> map = new HashMap<>();
         map.put("Java", "Object-Oriented Programming Language");
         map.put("Python", "High-Level Programming Language");
         map.put("C++", "General-Purpose Programming Language");
        ```
