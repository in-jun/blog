---
title: "A Guide to JAVA"
date: 2024-05-16T08:30:54+09:00
tags: ["JAVA"]
draft: false
---

## Introduction to JAVA

### What is JAVA?

**JAVA** is an object-oriented programming language.
It was developed at **Sun Microsystems** and was led by **James Gosling**.
It has the slogan **Write Once, Run Anywhere**, which means that programs written in JAVA can run on any platform.

### Features of JAVA

1.  **Object-oriented Programming Language**
    -   Using an object-oriented programming language increases code reusability and improves maintainability.
2.  **Platform Independence**
    -   Programs written in JAVA can run on any platform.
3.  **Multi-threaded Support**
    -   Using multi-threads allows multiple tasks to be processed simultaneously, improving program performance.
4.  **Dynamic Loading Support**
    -   Using dynamic loading allows classes required during program execution to be loaded dynamically.
5.  **Exception Handling Support**
    -   Using exception handling allows exceptions that occur during program execution to be handled.

### Setting up the JAVA Development Environment

1.  **Install JDK (Java Development Kit)**
    -   Installing JDK allows you to set up the environment to develop JAVA programs.
2.  **Install Code Editor**
    -   Installing a code editor allows you to write JAVA code.
    -   Popular code editors: **IntelliJ IDEA**, **Eclipse**

### Executing JAVA

1.  **Compile**
    -   Compiling JAVA source code generates bytecode.
    -   Compile command: `javac HelloWorld.java`
2.  **Run**
    -   Running bytecode executes the JAVA program.
    -   Run command: `java HelloWorld`

## JAVA Basic Syntax

### Operators and Iterations

1.  **Operators**
    -   JAVA provides various operators.
    -   Popular operators: `+`, `-`, `*`, `/`, `%`
    -   Operators allow you to perform specific operations.
    -   ```java
         int a = 10;
         int b = 20;
         int c = a + b;
         System.out.println(c);
        ```
2.  **Iterations**
    -   JAVA provides various iterations.
    -   Popular iterations: `for`, `while`, `do-while`
    -   Iterations allow you to repeatedly perform specific tasks.
    -   ```java
         for (int i = 0; i < 10; i++) {
             System.out.println(i);
         }
        ```

### Methods and Fields

1.  **Methods**

    -   Functions defined in a class.
    -   Specific tasks can be performed.
    -   Increases code reusability.
    -   ```java
         class Car {
             String color;
             int speed;

             void drive() {
                 System.out.println("Driving...");
             }
         }
        ```

2.  **Fields**

    -   Variables defined in a class.
    -   Can represent the state of an object.
    -   Can store the state of an object.
    -   ```java
         class Car {
             String color;
             int speed;
         }
        ```

### Classes and Objects

1.  **Classes**
    -   In JAVA, classes are used to create objects.
    -   Classes are a template for creating objects.
    -   Objects can be created and used to perform tasks.
    -   ```java
         class Car {
             String color;
             int speed;
         }
        ```
2.  **Objects**

    -   In JAVA, classes are used to create objects.
    -   Objects are instances of classes.
    -   Fields and methods defined in the class can be used.
    -   ```java
         Car myCar = new Car();
         myCar.color = "Red";
         myCar.speed = 100;

        ```

### Constructors

1.  **Constructors**

    -   Used to initialize objects.
    -   Has the same name as the class.
    -   When used, it allows the necessary initialization tasks to be performed when creating an object.
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

### Interfaces

1.  **Interfaces**
    -   A type of class.
    -   Methods defined in a class can be implemented.
    -   Polymorphism can be implemented.
    -   ```java
         interface Animal {
             void eat();
             void sleep();
         }
        ```

### Inheritance

1. **Inheritance**

    - Refers to passing the characteristics of a class to another class.
    - Increases code reusability.
    - Allows a hierarchy of classes to be created.
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

### Overriding

1.  **Overriding**

    -   Refers to redefining methods defined in a parent class in a child class.
    -   Polymorphism can be implemented.
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

### Overloading

1.  **Overloading**

    -   Refers to defining multiple methods with the same name.
    -   Allows different parameters to be used while keeping the method name the same.
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

### Abstraction and Polymorphism

1.  **Abstraction**
    -   Refers to extracting common characteristics of objects.
    -   Can represent common characteristics of objects.
    -   ```java
         abstract class Animal {
             abstract void eat();
         }
        ```
        > What is **abstract**?
        >
        > -   Used when defining abstract classes or abstract methods.
        > -   Abstract classes or abstract methods have unimplemented methods.
2.  **Polymorphism**

    -   Refers to representing various forms of objects.
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

### Generics

1.  **Generics**

    -   Refers to using types as parameters when defining classes or methods.
    -   ```java
         class Box<T> {
             T value;

             Box(T value) {
                 this.value = value;
             }
         }
        ```

### Collection Framework

1.  **Collection Framework**

    -   Refers to a set of classes used to store and manage data.
    -   JAVA provides various collection frameworks.
    -   ```java
            import java.util.ArrayList;
            import java.util.HashSet;
            import java.util.HashMap;
        ```

2.  **List**
    -   List is an interface used to store data in order.
    -   ```java
         List<String> list = new ArrayList<>();
         list.add("Java");
         list.add("Python");
         list.add("C++");
        ```
3.  **Set**
    -   Set is an interface used to store data without order.
    -   ```java
         Set<String> set = new HashSet<>();
         set.add("Java");
         set.add("Python");
         set.add("C++");
        ```
4.  **Map**
    -   Map is an interface used to store data in key-value pairs.
    -   ```java
         Map<String, String> map = new HashMap<>();
         map.put("Java", "Object-Oriented Programming Language");
         map.put("Python", "High-Level Programming Language");
         map.put("C++", "General-Purpose Programming Language");
        ```
