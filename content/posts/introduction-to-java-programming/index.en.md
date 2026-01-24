---
title: "Introduction to Java Programming"
date: 2024-05-16T08:30:54+09:00
tags: ["Java", "Programming", "OOP"]
description: "Java fundamentals and object-oriented programming concepts."
draft: false
---

Java is an object-oriented programming language developed in 1995 at Sun Microsystems by a team led by James Gosling. Under the slogan "Write Once, Run Anywhere," it provides a platform-independent execution environment. As of 2024, Java consistently ranks among the top programming languages in the TIOBE index, making it one of the most widely used programming languages in the world. It serves as a core language in various fields including enterprise applications, Android apps, big data processing, and web services. Java continues to evolve based on its strong type system, rich standard library, and active community.

## Java Overview

> **What is Java?**
>
> Java is a general-purpose object-oriented programming language developed by Sun Microsystems (now Oracle). It runs on the JVM (Java Virtual Machine) to provide platform independence and features strong type checking, automatic memory management (garbage collection), and multithreading support.

### Birth and History of Java

Java's history began in 1991 with Sun Microsystems' "Green Project." James Gosling, Mike Sheridan, and Patrick Naughton started a project to develop a programming language for consumer electronics, which became the origin of Java.

| Year | Version/Event | Key Features |
|------|---------------|--------------|
| **1991** | Green Project starts | James Gosling begins developing Oak language |
| **1995** | Java 1.0 released | "Write Once, Run Anywhere" slogan, web applet support |
| **1997** | Java 1.1 | Inner Class, JDBC, JavaBeans introduced |
| **1998** | Java 1.2 (J2SE) | Collections Framework, Swing GUI |
| **2004** | Java 5.0 (1.5) | Generics, Annotations, Enum, Autoboxing |
| **2006** | Java 6 | Performance improvements, Scripting API |
| **2010** | Oracle acquisition | Oracle acquires Sun Microsystems |
| **2014** | Java 8 (LTS) | Lambda, Stream API, Optional, Date/Time API |
| **2017** | Java 9 | Module System (Jigsaw), JShell |
| **2018** | Java 11 (LTS) | var keyword, HTTP Client API |
| **2021** | Java 17 (LTS) | Sealed Classes, Pattern Matching |
| **2023** | Java 21 (LTS) | Virtual Threads, Pattern Matching extensions |

### Java vs Other Languages

| Characteristic | Java | C++ | Python | C# |
|----------------|------|-----|--------|-----|
| **Paradigm** | Object-oriented | Multi-paradigm | Multi-paradigm | Object-oriented |
| **Memory Management** | Automatic (GC) | Manual | Automatic (GC) | Automatic (GC) |
| **Platform** | Cross-platform (JVM) | Native | Cross-platform | Primarily Windows |
| **Type System** | Static | Static | Dynamic | Static |
| **Execution** | Compile+Interpret | Compile | Interpret | Compile |
| **Performance** | Medium-High | Highest | Low | Medium-High |
| **Learning Curve** | Medium | High | Low | Medium |

## JVM and Java Execution Environment

> **What is JVM?**
>
> JVM (Java Virtual Machine) is a virtual machine that executes Java bytecode. It provides an execution environment independent of the operating system and hardware, realizing Java's "Write Once, Run Anywhere" philosophy.

### Java Execution Process

The execution process of a Java program goes through several stages from writing source code to execution on the JVM. The compiler and JVM play key roles in this process.

```
Source Code (.java)
       ↓ javac (compiler)
Bytecode (.class)
       ↓ Class Loader
Load to JVM Memory
       ↓ JIT Compiler/Interpreter
Native Code Execution
```

### JDK, JRE, JVM Relationship

| Component | Description | Included Elements |
|-----------|-------------|-------------------|
| **JVM** | Executes Java bytecode | Execution Engine, Memory Management |
| **JRE** | Java Runtime Environment | JVM + Standard Libraries |
| **JDK** | Java Development Kit | JRE + Compiler (javac) + Development Tools |

### Java Compilation and Execution

To run a Java program, you must first compile the source code to generate bytecode, then execute it on the JVM.

```java
// HelloWorld.java
public class HelloWorld {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
```

```bash
# Compile: .java → .class (bytecode)
javac HelloWorld.java

# Execute: JVM runs bytecode
java HelloWorld
```

## Four Pillars of Object-Oriented Programming

Java is designed based on four core principles of object-oriented programming (OOP): encapsulation, inheritance, polymorphism, and abstraction. Understanding and properly utilizing these principles enables writing maintainable and extensible code.

### Encapsulation

> **What is Encapsulation?**
>
> Encapsulation bundles data (fields) and methods that process that data into a single unit (class), restricting direct external access to protect data integrity. It is a core principle of object-orientation.

```java
public class BankAccount {
    // private fields block external access
    private double balance;
    private String accountNumber;

    // Constructor
    public BankAccount(String accountNumber, double initialBalance) {
        this.accountNumber = accountNumber;
        this.balance = initialBalance;
    }

    // getter allows reading
    public double getBalance() {
        return balance;
    }

    // Methods with validation logic change data
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

### Inheritance

> **What is Inheritance?**
>
> Inheritance is a mechanism where a new class (child class) inherits fields and methods from an existing class (parent class) to reuse and extend code. Java uses the `extends` keyword and supports only single inheritance.

```java
// Parent class
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

// Child class
public class Car extends Vehicle {
    private int numberOfDoors;

    public Car(String brand, int year, int numberOfDoors) {
        super(brand, year);  // Call parent constructor
        this.numberOfDoors = numberOfDoors;
    }

    // Method overriding
    @Override
    public void start() {
        System.out.println("Car engine is starting...");
    }

    // Child class specific method
    public void honk() {
        System.out.println("Beep beep!");
    }
}
```

### Polymorphism

> **What is Polymorphism?**
>
> Polymorphism is the ability to handle multiple implementations through a single interface or parent class type. It is implemented through method overriding (runtime polymorphism) and method overloading (compile-time polymorphism).

```java
// Polymorphism example
public class PolymorphismExample {
    public static void main(String[] args) {
        // Reference child object with parent type (upcasting)
        Vehicle myVehicle = new Car("Toyota", 2023, 4);
        myVehicle.start();  // Outputs "Car engine is starting..."

        // Method overloading example
        Calculator calc = new Calculator();
        System.out.println(calc.add(5, 3));       // int version
        System.out.println(calc.add(5.0, 3.0));   // double version
        System.out.println(calc.add(1, 2, 3));    // three argument version
    }
}

class Calculator {
    // Method overloading: same name, different parameters
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

### Abstraction

> **What is Abstraction?**
>
> Abstraction extracts core concepts or functions from complex systems and expresses them as simple interfaces. In Java, it is implemented through abstract classes and interfaces.

```java
// Abstract class
public abstract class Animal {
    protected String name;

    public Animal(String name) {
        this.name = name;
    }

    // Abstract method: no implementation, must be implemented in child class
    public abstract void makeSound();

    // Concrete method: has implementation
    public void sleep() {
        System.out.println(name + " is sleeping...");
    }
}

// Implementation classes
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

## Interfaces and Abstract Classes

### Interfaces

An interface is a contract that defines method signatures that a class must implement. Since Java 8, interfaces can also include default and static methods. Multiple implementation is possible, compensating for the limitations of multiple inheritance.

```java
// Interface definition
public interface Flyable {
    // Abstract method (public abstract omitted)
    void fly();

    // Java 8+ default method
    default void land() {
        System.out.println("Landing...");
    }

    // Java 8+ static method
    static void checkWeather() {
        System.out.println("Checking weather conditions...");
    }
}

public interface Swimmable {
    void swim();
}

// Multiple interface implementation
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

### Abstract Class vs Interface

| Characteristic | Abstract Class | Interface |
|----------------|----------------|-----------|
| **Keyword** | abstract class | interface |
| **Inheritance/Implementation** | extends (single) | implements (multiple) |
| **Constructor** | Possible | Not possible |
| **Fields** | All access modifiers | public static final only |
| **Methods** | All types | public (Java 8+: default, static) |
| **Use Case** | IS-A relationship, common functionality | CAN-DO relationship, contract definition |

## Generics

> **What are Generics?**
>
> Generics is a feature that specifies data types to be used in classes or methods at compile time, ensuring type safety and reducing the hassle of type casting. It was introduced in Java 5.

```java
// Generic class
public class Box<T> {
    private T content;

    public void set(T content) {
        this.content = content;
    }

    public T get() {
        return content;
    }
}

// Generic method
public class GenericUtils {
    public static <T> void printArray(T[] array) {
        for (T element : array) {
            System.out.println(element);
        }
    }

    // Bounded type parameter
    public static <T extends Number> double sum(T[] numbers) {
        double total = 0.0;
        for (T number : numbers) {
            total += number.doubleValue();
        }
        return total;
    }
}

// Usage example
public class GenericExample {
    public static void main(String[] args) {
        Box<String> stringBox = new Box<>();
        stringBox.set("Hello");
        String str = stringBox.get();  // No casting needed

        Box<Integer> intBox = new Box<>();
        intBox.set(123);
        Integer num = intBox.get();

        Integer[] numbers = {1, 2, 3, 4, 5};
        System.out.println(GenericUtils.sum(numbers));
    }
}
```

### Wildcards

```java
// Unbounded wildcard
public void printList(List<?> list) {
    for (Object item : list) {
        System.out.println(item);
    }
}

// Upper bounded wildcard (for reading)
public double sumOfList(List<? extends Number> list) {
    double sum = 0.0;
    for (Number num : list) {
        sum += num.doubleValue();
    }
    return sum;
}

// Lower bounded wildcard (for writing)
public void addNumbers(List<? super Integer> list) {
    list.add(1);
    list.add(2);
}
```

## Collection Framework

> **What is Collection Framework?**
>
> Collection Framework is a set of standardized interfaces and classes for storing and manipulating data. It provides interfaces like List, Set, Map, Queue and implementations like ArrayList, HashSet, HashMap.

### Collection Interface Hierarchy

```
Iterable
    └── Collection
            ├── List: ordered, allows duplicates
            │       ├── ArrayList
            │       ├── LinkedList
            │       └── Vector
            ├── Set: unordered, no duplicates
            │       ├── HashSet
            │       ├── LinkedHashSet
            │       └── TreeSet
            └── Queue: FIFO
                    ├── LinkedList
                    └── PriorityQueue

Map: key-value pairs
    ├── HashMap
    ├── LinkedHashMap
    ├── TreeMap
    └── Hashtable
```

### List

List is an interface for storing ordered data. It allows index-based access and duplicate elements. Implementations include ArrayList, LinkedList, and Vector.

```java
import java.util.ArrayList;
import java.util.LinkedList;
import java.util.List;

public class ListExample {
    public static void main(String[] args) {
        // ArrayList: dynamic array, fast random access
        List<String> arrayList = new ArrayList<>();
        arrayList.add("Java");
        arrayList.add("Python");
        arrayList.add("JavaScript");

        // Access by index
        System.out.println(arrayList.get(0));  // "Java"

        // Iteration
        for (String lang : arrayList) {
            System.out.println(lang);
        }

        // LinkedList: fast insertion/deletion
        List<Integer> linkedList = new LinkedList<>();
        linkedList.add(1);
        linkedList.add(0, 0);  // Insert at front
        linkedList.remove(1);
    }
}
```

### Set

Set is a collection of elements that does not allow duplicates. HashSet provides fast search based on hash tables. TreeSet maintains sorted order. LinkedHashSet maintains insertion order.

```java
import java.util.HashSet;
import java.util.LinkedHashSet;
import java.util.Set;
import java.util.TreeSet;

public class SetExample {
    public static void main(String[] args) {
        // HashSet: no order guarantee, fast search
        Set<String> hashSet = new HashSet<>();
        hashSet.add("Apple");
        hashSet.add("Banana");
        hashSet.add("Apple");  // Duplicate ignored
        System.out.println(hashSet.size());  // 2

        // TreeSet: maintains sorted order
        Set<Integer> treeSet = new TreeSet<>();
        treeSet.add(3);
        treeSet.add(1);
        treeSet.add(2);
        // Output: 1, 2, 3 (sorted)

        // LinkedHashSet: maintains insertion order
        Set<String> linkedHashSet = new LinkedHashSet<>();
        linkedHashSet.add("First");
        linkedHashSet.add("Second");
        linkedHashSet.add("Third");
    }
}
```

### Map

Map is an interface for storing key-value pair data. HashMap provides fast search based on hash tables. TreeMap maintains key-based sorting. LinkedHashMap maintains insertion order.

```java
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.TreeMap;

public class MapExample {
    public static void main(String[] args) {
        // HashMap: fast search, no order guarantee
        Map<String, Integer> hashMap = new HashMap<>();
        hashMap.put("Java", 1995);
        hashMap.put("Python", 1991);
        hashMap.put("JavaScript", 1995);

        // Value lookup
        Integer year = hashMap.get("Java");
        System.out.println("Java was released in: " + year);

        // Check key existence
        if (hashMap.containsKey("Python")) {
            System.out.println("Python exists!");
        }

        // Iteration
        for (Map.Entry<String, Integer> entry : hashMap.entrySet()) {
            System.out.println(entry.getKey() + ": " + entry.getValue());
        }

        // getOrDefault
        int cYear = hashMap.getOrDefault("C", 1972);
    }
}
```

### Collection Selection Guide

| Requirement | Recommended Collection | Reason |
|-------------|----------------------|--------|
| Order maintained, index access | ArrayList | Random access O(1) |
| Frequent insertion/deletion | LinkedList | Insertion/deletion O(1) |
| Remove duplicates, fast search | HashSet | Search O(1) |
| Sorted unique elements | TreeSet | Auto sorting |
| Key-value pairs, fast search | HashMap | Search O(1) |
| Sorted by key | TreeMap | Auto key sorting |

## Exception Handling

> **What is Exception Handling?**
>
> Exception handling is a mechanism that detects and appropriately responds to exceptional situations that may occur during program execution, preventing abnormal program termination. Java uses try-catch-finally syntax.

### Exception Hierarchy

```
Throwable
    ├── Error (unrecoverable)
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

### Exception Handling Example

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

        // Multiple catch
        try {
            String str = null;
            str.length();
        } catch (NullPointerException | IllegalArgumentException e) {
            System.out.println("Error: " + e.getMessage());
        }
    }

    // Propagate exception with throws
    public static int divide(int a, int b) throws ArithmeticException {
        if (b == 0) {
            throw new ArithmeticException("Cannot divide by zero");
        }
        return a / b;
    }
}
```

## Conclusion

Java is an object-oriented programming language that has continuously evolved for nearly 30 years since its birth in 1995. It provides JVM-based platform independence, a strong type system, automatic memory management, and rich standard libraries. Java has established itself as the standard for enterprise application development.

Understanding and properly utilizing the four pillars of object-oriented programming—encapsulation, inheritance, polymorphism, and abstraction—enables writing maintainable and extensible code. Generics and the collection framework greatly improve type safety and data structure utilization. With continuous language development including lambda expressions and Stream API in Java 8, and virtual threads in Java 21, Java also supports modern programming paradigms.
