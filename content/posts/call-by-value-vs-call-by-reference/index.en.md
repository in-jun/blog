---
title: "Call by Value vs Call by Reference"
date: 2024-05-16T22:14:17+09:00
tags: ["Programming", "Computer Science"]
description: "Differences between call by value and call by reference parameter passing."
draft: false
---

Parameter passing determines what a function receives when you call it. The choice affects program behavior, safety, and performance across languages. Call by Value and Call by Reference are the two most familiar models, and understanding how they differ helps you write code that is both safer and more efficient.

## Overview of Function Parameter Passing

> **What is Parameter Passing Mechanism?**
>
> A parameter passing mechanism defines how actual parameter values or references are passed to formal parameters during function calls. Various methods exist including Call by Value, Call by Reference, Call by Name, and Call by Need.

### Historical Background

Parameter passing mechanisms evolved alongside programming language design in the 1960s. ALGOL 60 was one of the first languages to support both Call by Value and Call by Name. Many later languages built their parameter passing rules on top of these ideas.

| Year | Language/Concept | Parameter Passing Method |
|------|------------------|--------------------------|
| **1960** | ALGOL 60 | Call by Value, Call by Name |
| **1972** | C | Call by Value (reference simulated via pointers) |
| **1979** | C++ | Call by Value, Call by Reference |
| **1995** | Java | Call by Value (object reference value passing) |
| **1991** | Python | Call by Object Reference (Call by Sharing) |

### Comparison of Major Passing Methods

| Characteristic | Call by Value | Call by Reference |
|----------------|---------------|-------------------|
| **What is passed** | Copy of the value | Address/reference of original |
| **Original modification** | Not possible | Possible |
| **Memory usage** | Additional memory needed for copy | Efficient, only address passed |
| **Performance** | Slower for large data | Faster for large data |
| **Safety** | Original protected | Original can be modified |
| **Use cases** | Primitive types, when original protection needed | Large objects, multiple return values |

## Call by Value

> **What is Call by Value?**
>
> Call by Value copies the actual parameter's value and passes it to the formal parameter during function calls. Even if the parameter value is changed inside the function, it does not affect the caller's original variable. This is the most basic and safe parameter passing method.

### Memory Operation Principle

In Call by Value, the actual parameter's value is copied to stack memory during the function call, creating a new local variable. This copy is only valid within the function's scope and is removed from the stack when the function terminates.

```
Memory state before call:
┌─────────────┐
│ main()      │
│ a = 10      │  ← Original variable
│ b = 20      │
└─────────────┘

After swap(a, b) call:
┌─────────────┐
│ swap()      │
│ a = 10      │  ← Copied value (separate memory)
│ b = 20      │  ← Copied value (separate memory)
├─────────────┤
│ main()      │
│ a = 10      │  ← Original (unchanged)
│ b = 20      │
└─────────────┘
```

### Call by Value in C

C fundamentally supports only Call by Value. All function arguments are passed by value. When pass-by-reference is needed, pointers are used to simulate it.

```c
#include <stdio.h>

void swap_by_value(int a, int b) {
    int temp = a;
    a = b;
    b = temp;
    printf("Inside function: a = %d, b = %d\n", a, b);
}

int main() {
    int x = 10, y = 20;
    printf("Before call: x = %d, y = %d\n", x, y);
    swap_by_value(x, y);
    printf("After call: x = %d, y = %d\n", x, y);
    return 0;
}
```

Output:

```
Before call: x = 10, y = 20
Inside function: a = 20, b = 10
After call: x = 10, y = 20
```

Although a and b values were swapped inside the function, x and y in the main function remained unchanged. This is because the values of x and y were copied when passed.

### Advantages and Disadvantages of Call by Value

| Advantages | Disadvantages |
|------------|---------------|
| Original data protection | Performance degradation when copying large data |
| Prevents side effects | Increased memory usage |
| Improved code predictability | Difficulty handling multiple return values |
| Easier debugging | Requires additional handling when original modification needed |

## Call by Reference

> **What is Call by Reference?**
>
> Call by Reference lets a function work with the caller's original variable instead of a copied value. In some languages this is supported directly, while in others it is simulated with pointers or addresses.

### Core Idea

In Call by Reference and similar approaches, the function receives a way to reach the original variable rather than a separate copy. As a result, changes made inside the function can affect the caller's data.

```
Memory state before call:
┌─────────────┐
│ main()      │
│ a = 10      │  Address: 0x1000
│ b = 20      │  Address: 0x1004
└─────────────┘

After swap(&a, &b) call:
┌─────────────┐
│ swap()      │
│ a → 0x1000  │  ← Points to original a
│ b → 0x1004  │  ← Points to original b
├─────────────┤
│ main()      │
│ a = 10      │  ← Same memory location
│ b = 20      │
└─────────────┘
```

### Simulating Reference Passing with Pointers in C

C does not support true Call by Reference at the language level. Instead, it passes values by default and uses pointers when you need a function to modify the caller's original data. This approach is also called "Call by Address" or "Simulated Call by Reference."

```c
#include <stdio.h>

void swap_by_pointer(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
    printf("Inside function: *a = %d, *b = %d\n", *a, *b);
}

int main() {
    int x = 10, y = 20;
    printf("Before call: x = %d, y = %d\n", x, y);
    swap_by_pointer(&x, &y);
    printf("After call: x = %d, y = %d\n", x, y);
    return 0;
}
```

Output:

```
Before call: x = 10, y = 20
Inside function: *a = 20, *b = 10
After call: x = 20, y = 10
```

Since the address of the original variables was passed through pointers, changes made inside the function were reflected in x and y of the main function.

### C++ References

C++ introduced references (&) to support pure Call by Reference at the language level. References are syntactically more concise than pointers and can prevent null pointer issues.

```cpp
#include <iostream>
using namespace std;

void swap_by_reference(int &a, int &b) {
    int temp = a;
    a = b;
    b = temp;
    cout << "Inside function: a = " << a << ", b = " << b << endl;
}

int main() {
    int x = 10, y = 20;
    cout << "Before call: x = " << x << ", y = " << y << endl;
    swap_by_reference(x, y);
    cout << "After call: x = " << x << ", y = " << y << endl;
    return 0;
}
```

### Advantages and Disadvantages of Call by Reference

| Advantages | Disadvantages |
|------------|---------------|
| Efficient for large data transfer | Risk of original data modification |
| Enables multiple return values | Potential side effects |
| Memory savings | Difficulty tracking code |
| Fast performance | Possibility of unintended modifications |

## Language-Specific Parameter Passing Methods

### Java: Call by Value (Object Reference Value Passing)

Everything in Java is passed by Call by Value. Primitive types have their values copied, while object types have their reference values copied and passed.

```java
public class ParameterPassing {
    public static void modifyPrimitive(int value) {
        value = 100;
        System.out.println("Inside function value: " + value);
    }

    public static void modifyObject(StringBuilder sb) {
        sb.append(" World");
        System.out.println("Inside function sb: " + sb);
    }

    public static void reassignObject(StringBuilder sb) {
        sb = new StringBuilder("New Object");
        System.out.println("Inside function sb: " + sb);
    }

    public static void main(String[] args) {
        int num = 10;
        modifyPrimitive(num);
        System.out.println("After call num: " + num);

        StringBuilder str = new StringBuilder("Hello");
        modifyObject(str);
        System.out.println("After call str: " + str);

        StringBuilder str2 = new StringBuilder("Original");
        reassignObject(str2);
        System.out.println("After call str2: " + str2);
    }
}
```

Output:

```
Inside function value: 100
After call num: 10
Inside function sb: Hello World
After call str: Hello World
Inside function sb: New Object
After call str2: Original
```

In Java, object contents can be modified, but reassigning the reference itself does not affect the original. This is because the "value" of the reference is copied when passed.

### Python: Call by Object Reference (Call by Sharing)

Python uses a method called Call by Object Reference or Call by Sharing. Everything is an object and object references are passed, but mutable and immutable objects behave differently.

```python
def modify_list(lst):
    lst.append(4)
    print(f"Inside function list: {lst}")

def modify_number(num):
    num = 100
    print(f"Inside function number: {num}")

def reassign_list(lst):
    lst = [10, 20, 30]
    print(f"After reassignment inside function: {lst}")

# Mutable object (list)
my_list = [1, 2, 3]
modify_list(my_list)
print(f"After call list: {my_list}")

# Immutable object (integer)
my_num = 10
modify_number(my_num)
print(f"After call number: {my_num}")

# Reassignment
my_list2 = [1, 2, 3]
reassign_list(my_list2)
print(f"After call list2: {my_list2}")
```

Output:

```
Inside function list: [1, 2, 3, 4]
After call list: [1, 2, 3, 4]
Inside function number: 100
After call number: 10
After reassignment inside function: [10, 20, 30]
After call list2: [1, 2, 3]
```

### Language Comparison Summary

| Language | Primitive Types | Object/Reference Types | Characteristics |
|----------|-----------------|------------------------|-----------------|
| **C** | Call by Value | Simulated via pointers | Pure Call by Value |
| **C++** | Call by Value | Choice of Value/Reference | Reference (&) support |
| **Java** | Call by Value | Call by Value of reference | No pure Call by Reference |
| **Python** | - | Call by Object Reference | Everything is an object |
| **JavaScript** | Call by Value | Call by Sharing | Similar to Python |
| **Go** | Call by Value | Simulated via pointers | Similar to C |

## Performance Comparison and Optimization

### Performance Differences by Data Size

When passing large data structures, the performance difference between Call by Value and Call by Reference is significant. Reference passing is particularly efficient for data with high copy costs.

```cpp
#include <iostream>
#include <chrono>
#include <vector>
using namespace std;

struct LargeData {
    int data[10000];
};

void process_by_value(LargeData data) {
    data.data[0] = 1;
}

void process_by_reference(LargeData &data) {
    data.data[0] = 1;
}

int main() {
    LargeData obj;
    const int iterations = 100000;

    auto start = chrono::high_resolution_clock::now();
    for (int i = 0; i < iterations; i++) {
        process_by_value(obj);
    }
    auto end = chrono::high_resolution_clock::now();
    cout << "Call by Value: "
         << chrono::duration_cast<chrono::milliseconds>(end - start).count()
         << "ms" << endl;

    start = chrono::high_resolution_clock::now();
    for (int i = 0; i < iterations; i++) {
        process_by_reference(obj);
    }
    end = chrono::high_resolution_clock::now();
    cout << "Call by Reference: "
         << chrono::duration_cast<chrono::milliseconds>(end - start).count()
         << "ms" << endl;

    return 0;
}
```

### Safe Optimization with const References

In C++, const references maintain the performance benefits of reference passing while preventing original modification. This is the recommended approach when passing large objects as read-only.

```cpp
void process_safely(const LargeData &data) {
    // data.data[0] = 1;  // Compile error: cannot modify const object
    int value = data.data[0];  // Reading is allowed
}
```

### Recommended Methods by Usage Scenario

| Scenario | Recommended Method | Reason |
|----------|-------------------|--------|
| Primitive types (int, float) | Call by Value | Low copy cost |
| Reading large structures | const Reference | Prevents copy, no modification |
| Modifying large structures | Reference/Pointer | Direct modification needed |
| Multiple return values | Reference/Pointer | Return multiple values |
| Functional programming | Call by Value | Guarantees immutability |

## Practical Usage Guide

### Swap Function Implementation Comparison

Comparing swap implementations across languages is a simple way to see how parameter passing differs in practice.

**C (using pointers):**

```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
```

**C++ (using references):**

```cpp
void swap(int &a, int &b) {
    int temp = a;
    a = b;
    b = temp;
}
```

**Python (tuple unpacking):**

```python
def swap(a, b):
    return b, a

x, y = 10, 20
x, y = swap(x, y)
```

### Array/Collection Handling

When passing arrays or collections to functions, behavior depends on the language and the object model. In many cases, a function can still mutate the original data, so it is worth being explicit about whether you want to share or copy it.

```python
# Passing a list copy in Python
def modify_copy(lst):
    lst = lst.copy()  # Create a copy
    lst.append(4)
    return lst

original = [1, 2, 3]
modified = modify_copy(original)
print(f"Original: {original}")  # [1, 2, 3]
print(f"Modified: {modified}")  # [1, 2, 3, 4]
```

### Callback Functions and Closures

When a callback updates variables from an outer scope, parameter passing is only part of the story. Closure behavior also affects what state is shared and how updates are observed.

```javascript
function createCounter() {
    let count = 0;
    return {
        increment: function() { count++; },
        getCount: function() { return count; }
    };
}

const counter = createCounter();
counter.increment();
console.log(counter.getCount());  // 1
```

## Conclusion

Parameter passing is a basic programming concept, but the details vary enough across languages that it is easy to get wrong. Call by Value is generally safer because it works on copies and avoids side effects. Call by Reference works with the original data, which can be more efficient and more flexible when modification is required.

C simulates reference passing through pointers. C++ provides language-level support through references. Java and Python use a Call by Sharing approach that passes the value of object references. Understanding the characteristics of each method and applying them appropriately enables writing more efficient and safer code.

When handling large data, consider optimization using const references. When multiple return values are needed, reference passing or tuple returns are effective.
