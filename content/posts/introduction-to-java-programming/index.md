---
title: "Java 완벽 가이드: 역사부터 핵심 문법까지"
date: 2024-05-16T08:30:54+09:00
tags: ["Java", "Programming", "OOP", "JVM"]
description: "Java의 탄생 배경과 발전 역사, Write Once Run Anywhere 철학, JVM 동작 원리, 객체지향 프로그래밍의 4대 원칙, 클래스와 인터페이스, 제네릭과 컬렉션 프레임워크까지 Java 프로그래밍의 핵심을 체계적으로 정리"
draft: false
---

Java는 1995년 Sun Microsystems에서 James Gosling이 이끄는 팀에 의해 개발된 객체지향 프로그래밍 언어로, "Write Once, Run Anywhere(한 번 작성하면 어디서나 실행)"라는 슬로건 아래 플랫폼 독립적인 실행 환경을 제공하며, 2024년 현재 TIOBE 프로그래밍 언어 순위에서 꾸준히 상위권을 유지하고 있는 세계에서 가장 널리 사용되는 프로그래밍 언어 중 하나이다. 기업용 애플리케이션, 안드로이드 앱, 빅데이터 처리, 웹 서비스 등 다양한 분야에서 핵심 언어로 사용되고 있으며, 강력한 타입 시스템과 풍부한 표준 라이브러리, 그리고 활발한 커뮤니티를 기반으로 지속적으로 발전하고 있다.

## Java 개요

> **Java란?**
>
> Java는 Sun Microsystems(현재 Oracle)에서 개발한 범용 객체지향 프로그래밍 언어로, JVM(Java Virtual Machine) 위에서 실행되어 플랫폼 독립성을 제공하며, 강력한 타입 검사, 자동 메모리 관리(가비지 컬렉션), 멀티스레딩 지원 등의 특징을 가진다.

### Java의 탄생과 역사

Java의 역사는 1991년 Sun Microsystems의 "Green Project"에서 시작되었으며, James Gosling, Mike Sheridan, Patrick Naughton이 가전제품에 사용할 프로그래밍 언어를 개발하기 위해 시작한 프로젝트가 Java의 기원이 되었다.

| 연도 | 버전/이벤트 | 주요 특징 |
|------|-------------|-----------|
| **1991** | Green Project 시작 | James Gosling이 Oak 언어 개발 시작 |
| **1995** | Java 1.0 출시 | "Write Once, Run Anywhere" 슬로건, 웹 애플릿 지원 |
| **1997** | Java 1.1 | Inner Class, JDBC, JavaBeans 도입 |
| **1998** | Java 1.2 (J2SE) | Collections Framework, Swing GUI |
| **2004** | Java 5.0 (1.5) | Generics, Annotations, Enum, Autoboxing |
| **2006** | Java 6 | 성능 개선, Scripting API |
| **2010** | Oracle 인수 | Sun Microsystems를 Oracle이 인수 |
| **2014** | Java 8 (LTS) | Lambda, Stream API, Optional, Date/Time API |
| **2017** | Java 9 | Module System (Jigsaw), JShell |
| **2018** | Java 11 (LTS) | var 키워드, HTTP Client API |
| **2021** | Java 17 (LTS) | Sealed Classes, Pattern Matching |
| **2023** | Java 21 (LTS) | Virtual Threads, Pattern Matching 확장 |

### Java vs 다른 언어 비교

| 특성 | Java | C++ | Python | C# |
|------|------|-----|--------|-----|
| **패러다임** | 객체지향 | 멀티 패러다임 | 멀티 패러다임 | 객체지향 |
| **메모리 관리** | 자동 (GC) | 수동 | 자동 (GC) | 자동 (GC) |
| **플랫폼** | 크로스 플랫폼 (JVM) | 네이티브 | 크로스 플랫폼 | 주로 Windows |
| **타입 시스템** | 정적 | 정적 | 동적 | 정적 |
| **실행 방식** | 컴파일+인터프리터 | 컴파일 | 인터프리터 | 컴파일 |
| **성능** | 중상 | 최상 | 낮음 | 중상 |
| **학습 난이도** | 중간 | 높음 | 낮음 | 중간 |

## JVM과 Java 실행 환경

> **JVM이란?**
>
> JVM(Java Virtual Machine)은 Java 바이트코드를 실행하는 가상 머신으로, 운영체제와 하드웨어에 독립적인 실행 환경을 제공하여 Java의 "Write Once, Run Anywhere" 철학을 실현하는 핵심 컴포넌트이다.

### Java 실행 과정

Java 프로그램의 실행 과정은 소스 코드 작성부터 JVM에서의 실행까지 여러 단계를 거치며, 이 과정에서 컴파일러와 JVM이 핵심적인 역할을 수행한다.

```
소스 코드 (.java)
       ↓ javac (컴파일러)
바이트코드 (.class)
       ↓ 클래스 로더
JVM 메모리 로드
       ↓ JIT 컴파일러/인터프리터
네이티브 코드 실행
```

### JDK, JRE, JVM 관계

| 구성요소 | 설명 | 포함 요소 |
|----------|------|-----------|
| **JVM** | Java 바이트코드 실행 | Execution Engine, Memory Management |
| **JRE** | Java 실행 환경 | JVM + 표준 라이브러리 |
| **JDK** | Java 개발 키트 | JRE + 컴파일러(javac) + 개발 도구 |

### Java 컴파일과 실행

Java 프로그램을 실행하기 위해서는 먼저 소스 코드를 컴파일하여 바이트코드를 생성한 후, JVM에서 실행해야 한다.

```java
// HelloWorld.java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

```bash
# 컴파일: .java → .class (바이트코드)
javac HelloWorld.java

# 실행: JVM이 바이트코드 실행
java HelloWorld
```

## 객체지향 프로그래밍의 4대 원칙

Java는 객체지향 프로그래밍(OOP) 언어로서 캡슐화, 상속, 다형성, 추상화라는 네 가지 핵심 원칙을 기반으로 설계되었으며, 이 원칙들을 이해하고 적절히 활용하면 유지보수가 용이하고 확장 가능한 코드를 작성할 수 있다.

### 캡슐화 (Encapsulation)

> **캡슐화란?**
>
> 캡슐화는 데이터(필드)와 해당 데이터를 처리하는 메서드를 하나의 단위(클래스)로 묶고, 외부에서 직접 접근을 제한하여 데이터의 무결성을 보호하는 객체지향의 핵심 원칙이다.

```java
public class BankAccount {
    // private 필드로 외부 접근 차단
    private double balance;
    private String accountNumber;

    // 생성자
    public BankAccount(String accountNumber, double initialBalance) {
        this.accountNumber = accountNumber;
        this.balance = initialBalance;
    }

    // getter로 읽기 허용
    public double getBalance() {
        return balance;
    }

    // 검증 로직이 포함된 메서드로 데이터 변경
    public void deposit(double amount) {
        if (amount > 0) {
            balance += amount;
        }
    }

    public boolean withdraw(double amount) {
        if (amount > 0 && balance >= amount) {
            balance -= amount;
            return true;
        }
        return false;
    }
}
```

### 상속 (Inheritance)

> **상속이란?**
>
> 상속은 기존 클래스(부모 클래스)의 필드와 메서드를 새로운 클래스(자식 클래스)가 물려받아 코드를 재사용하고 확장하는 메커니즘으로, Java에서는 `extends` 키워드를 사용하며 단일 상속만 지원한다.

```java
// 부모 클래스
public class Vehicle {
    protected String brand;
    protected int year;

    public Vehicle(String brand, int year) {
        this.brand = brand;
        this.year = year;
    }

    public void start() {
        System.out.println("Vehicle is starting...");
    }

    public void stop() {
        System.out.println("Vehicle is stopping...");
    }
}

// 자식 클래스
public class Car extends Vehicle {
    private int numberOfDoors;

    public Car(String brand, int year, int numberOfDoors) {
        super(brand, year);  // 부모 생성자 호출
        this.numberOfDoors = numberOfDoors;
    }

    // 메서드 오버라이딩
    @Override
    public void start() {
        System.out.println("Car engine is starting...");
    }

    // 자식 클래스만의 메서드
    public void honk() {
        System.out.println("Beep beep!");
    }
}
```

### 다형성 (Polymorphism)

> **다형성이란?**
>
> 다형성은 하나의 인터페이스나 부모 클래스 타입으로 여러 가지 구현체를 다룰 수 있는 능력으로, 메서드 오버라이딩(런타임 다형성)과 메서드 오버로딩(컴파일타임 다형성)을 통해 구현된다.

```java
// 다형성 예제
public class PolymorphismExample {
    public static void main(String[] args) {
        // 부모 타입으로 자식 객체 참조 (업캐스팅)
        Vehicle myVehicle = new Car("Toyota", 2023, 4);
        myVehicle.start();  // "Car engine is starting..." 출력

        // 메서드 오버로딩 예제
        Calculator calc = new Calculator();
        System.out.println(calc.add(5, 3));       // int 버전
        System.out.println(calc.add(5.0, 3.0));   // double 버전
        System.out.println(calc.add(1, 2, 3));    // 세 개 인자 버전
    }
}

class Calculator {
    // 메서드 오버로딩: 같은 이름, 다른 매개변수
    public int add(int a, int b) {
        return a + b;
    }

    public double add(double a, double b) {
        return a + b;
    }

    public int add(int a, int b, int c) {
        return a + b + c;
    }
}
```

### 추상화 (Abstraction)

> **추상화란?**
>
> 추상화는 복잡한 시스템에서 핵심적인 개념이나 기능만을 추출하여 간단한 인터페이스로 표현하는 것으로, Java에서는 추상 클래스(abstract class)와 인터페이스(interface)를 통해 구현된다.

```java
// 추상 클래스
public abstract class Animal {
    protected String name;

    public Animal(String name) {
        this.name = name;
    }

    // 추상 메서드: 구현 없음, 자식 클래스에서 반드시 구현
    public abstract void makeSound();

    // 일반 메서드: 구현 있음
    public void sleep() {
        System.out.println(name + " is sleeping...");
    }
}

// 구현 클래스
public class Dog extends Animal {
    public Dog(String name) {
        super(name);
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Woof!");
    }
}

public class Cat extends Animal {
    public Cat(String name) {
        super(name);
    }

    @Override
    public void makeSound() {
        System.out.println(name + " says: Meow!");
    }
}
```

## 인터페이스와 추상 클래스

### 인터페이스

인터페이스는 클래스가 구현해야 하는 메서드의 시그니처를 정의하는 계약(contract)으로, Java 8부터 default 메서드와 static 메서드도 포함할 수 있게 되었으며, 다중 구현이 가능하여 다중 상속의 한계를 보완한다.

```java
// 인터페이스 정의
public interface Flyable {
    // 추상 메서드 (public abstract 생략)
    void fly();

    // Java 8+ default 메서드
    default void land() {
        System.out.println("Landing...");
    }

    // Java 8+ static 메서드
    static void checkWeather() {
        System.out.println("Checking weather conditions...");
    }
}

public interface Swimmable {
    void swim();
}

// 다중 인터페이스 구현
public class Duck implements Flyable, Swimmable {
    @Override
    public void fly() {
        System.out.println("Duck is flying!");
    }

    @Override
    public void swim() {
        System.out.println("Duck is swimming!");
    }
}
```

### 추상 클래스 vs 인터페이스

| 특성 | 추상 클래스 | 인터페이스 |
|------|-------------|------------|
| **키워드** | abstract class | interface |
| **상속/구현** | extends (단일) | implements (다중) |
| **생성자** | 가능 | 불가능 |
| **필드** | 모든 접근 제어자 | public static final만 |
| **메서드** | 모든 종류 | public (Java 8+: default, static) |
| **사용 목적** | IS-A 관계, 공통 기능 | CAN-DO 관계, 계약 정의 |

## 제네릭 (Generics)

> **제네릭이란?**
>
> 제네릭은 클래스나 메서드에서 사용할 데이터 타입을 컴파일 시점에 지정하여 타입 안전성을 보장하고 형변환의 번거로움을 줄여주는 기능으로, Java 5에서 도입되었다.

```java
// 제네릭 클래스
public class Box<T> {
    private T content;

    public void set(T content) {
        this.content = content;
    }

    public T get() {
        return content;
    }
}

// 제네릭 메서드
public class GenericUtils {
    public static <T> void printArray(T[] array) {
        for (T element : array) {
            System.out.println(element);
        }
    }

    // 제한된 타입 파라미터
    public static <T extends Number> double sum(T[] numbers) {
        double total = 0.0;
        for (T number : numbers) {
            total += number.doubleValue();
        }
        return total;
    }
}

// 사용 예제
public class GenericExample {
    public static void main(String[] args) {
        Box<String> stringBox = new Box<>();
        stringBox.set("Hello");
        String str = stringBox.get();  // 형변환 불필요

        Box<Integer> intBox = new Box<>();
        intBox.set(123);
        Integer num = intBox.get();

        Integer[] numbers = {1, 2, 3, 4, 5};
        System.out.println(GenericUtils.sum(numbers));
    }
}
```

### 와일드카드

```java
// 무제한 와일드카드
public void printList(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
}

// 상한 제한 와일드카드 (읽기용)
public double sumOfList(List<? extends Number> list) {
    double sum = 0.0;
    for (Number num : list) {
        sum += num.doubleValue();
    }
    return sum;
}

// 하한 제한 와일드카드 (쓰기용)
public void addNumbers(List<? super Integer> list) {
    list.add(1);
    list.add(2);
}
```

## 컬렉션 프레임워크

> **컬렉션 프레임워크란?**
>
> 컬렉션 프레임워크는 데이터를 저장하고 조작하기 위한 표준화된 인터페이스와 클래스의 집합으로, List, Set, Map, Queue 등의 인터페이스와 ArrayList, HashSet, HashMap 등의 구현체를 제공한다.

### 컬렉션 인터페이스 계층 구조

```
Iterable
    └── Collection
            ├── List: 순서 있음, 중복 허용
            │       ├── ArrayList
            │       ├── LinkedList
            │       └── Vector
            ├── Set: 순서 없음, 중복 불허
            │       ├── HashSet
            │       ├── LinkedHashSet
            │       └── TreeSet
            └── Queue: FIFO
                    ├── LinkedList
                    └── PriorityQueue

Map: 키-값 쌍
    ├── HashMap
    ├── LinkedHashMap
    ├── TreeMap
    └── Hashtable
```

### List

List는 순서가 있는 데이터를 저장하는 인터페이스로, 인덱스를 통한 접근이 가능하고 중복 요소를 허용하며, ArrayList, LinkedList, Vector 등의 구현체가 있다.

```java
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class ListExample {
    public static void main(String[] args) {
        // ArrayList: 동적 배열, 랜덤 접근 빠름
        List<String> arrayList = new ArrayList<>();
        arrayList.add("Java");
        arrayList.add("Python");
        arrayList.add("JavaScript");

        // 인덱스로 접근
        System.out.println(arrayList.get(0));  // "Java"

        // 반복
        for (String lang : arrayList) {
            System.out.println(lang);
        }

        // LinkedList: 삽입/삭제 빠름
        List<Integer> linkedList = new LinkedList<>();
        linkedList.add(1);
        linkedList.add(0, 0);  // 맨 앞에 삽입
        linkedList.remove(1);
    }
}
```

### Set

Set은 중복을 허용하지 않는 요소들의 집합으로, HashSet은 해시 테이블 기반으로 빠른 검색을 제공하고, TreeSet은 정렬된 순서를 유지하며, LinkedHashSet은 삽입 순서를 유지한다.

```java
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TreeSet;

public class SetExample {
    public static void main(String[] args) {
        // HashSet: 순서 보장 안됨, 빠른 검색
        Set<String> hashSet = new HashSet<>();
        hashSet.add("Apple");
        hashSet.add("Banana");
        hashSet.add("Apple");  // 중복 무시
        System.out.println(hashSet.size());  // 2

        // TreeSet: 정렬된 순서 유지
        Set<Integer> treeSet = new TreeSet<>();
        treeSet.add(3);
        treeSet.add(1);
        treeSet.add(2);
        // 출력: 1, 2, 3 (정렬됨)

        // LinkedHashSet: 삽입 순서 유지
        Set<String> linkedHashSet = new LinkedHashSet<>();
        linkedHashSet.add("First");
        linkedHashSet.add("Second");
        linkedHashSet.add("Third");
    }
}
```

### Map

Map은 키-값 쌍으로 데이터를 저장하는 인터페이스로, HashMap은 해시 테이블 기반으로 빠른 검색을 제공하고, TreeMap은 키 기준 정렬을 유지하며, LinkedHashMap은 삽입 순서를 유지한다.

```java
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

public class MapExample {
    public static void main(String[] args) {
        // HashMap: 빠른 검색, 순서 보장 안됨
        Map<String, Integer> hashMap = new HashMap<>();
        hashMap.put("Java", 1995);
        hashMap.put("Python", 1991);
        hashMap.put("JavaScript", 1995);

        // 값 조회
        Integer year = hashMap.get("Java");
        System.out.println("Java was released in: " + year);

        // 키 존재 확인
        if (hashMap.containsKey("Python")) {
            System.out.println("Python exists!");
        }

        // 반복
        for (Map.Entry<String, Integer> entry : hashMap.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }

        // getOrDefault
        int cYear = hashMap.getOrDefault("C", 1972);
    }
}
```

### 컬렉션 선택 가이드

| 요구사항 | 권장 컬렉션 | 이유 |
|----------|-------------|------|
| 순서 유지, 인덱스 접근 | ArrayList | 랜덤 접근 O(1) |
| 빈번한 삽입/삭제 | LinkedList | 삽입/삭제 O(1) |
| 중복 제거, 빠른 검색 | HashSet | 검색 O(1) |
| 정렬된 유일 요소 | TreeSet | 자동 정렬 |
| 키-값 쌍, 빠른 검색 | HashMap | 검색 O(1) |
| 키 기준 정렬 | TreeMap | 키 자동 정렬 |

## 예외 처리

> **예외 처리란?**
>
> 예외 처리는 프로그램 실행 중 발생할 수 있는 예외 상황을 감지하고 적절히 대응하여 프로그램의 비정상적인 종료를 방지하는 메커니즘으로, Java에서는 try-catch-finally 구문을 사용한다.

### 예외 계층 구조

```
Throwable
    ├── Error (복구 불가능)
    │       ├── OutOfMemoryError
    │       └── StackOverflowError
    └── Exception
            ├── RuntimeException (Unchecked)
            │       ├── NullPointerException
            │       ├── ArrayIndexOutOfBoundsException
            │       └── IllegalArgumentException
            └── Checked Exception
                    ├── IOException
                    ├── SQLException
                    └── FileNotFoundException
```

### 예외 처리 예제

```java
import java.io.*;

public class ExceptionExample {
    public static void main(String[] args) {
        // try-catch-finally
        try {
            int result = divide(10, 0);
        } catch (ArithmeticException e) {
            System.out.println("Division error: " + e.getMessage());
        } finally {
            System.out.println("This always executes");
        }

        // try-with-resources (Java 7+)
        try (BufferedReader reader = new BufferedReader(new FileReader("file.txt"))) {
            String line = reader.readLine();
            System.out.println(line);
        } catch (IOException e) {
            System.out.println("IO error: " + e.getMessage());
        }

        // 다중 catch
        try {
            String str = null;
            str.length();
        } catch (NullPointerException | IllegalArgumentException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    // throws로 예외 전파
    public static int divide(int a, int b) throws ArithmeticException {
        if (b == 0) {
            throw new ArithmeticException("Cannot divide by zero");
        }
        return a / b;
    }
}
```

## 결론

Java는 1995년 탄생 이후 30년 가까이 지속적으로 발전해 온 객체지향 프로그래밍 언어로, JVM 기반의 플랫폼 독립성, 강력한 타입 시스템, 자동 메모리 관리, 풍부한 표준 라이브러리를 제공하며 기업용 애플리케이션 개발의 표준으로 자리잡았다.

객체지향 프로그래밍의 4대 원칙인 캡슐화, 상속, 다형성, 추상화를 이해하고 적절히 활용하면 유지보수가 용이하고 확장 가능한 코드를 작성할 수 있으며, 제네릭과 컬렉션 프레임워크는 타입 안전성과 데이터 구조 활용을 크게 향상시킨다. Java 8의 람다 표현식과 스트림 API, Java 21의 가상 스레드 등 지속적인 언어 발전으로 현대적인 프로그래밍 패러다임도 지원한다.
