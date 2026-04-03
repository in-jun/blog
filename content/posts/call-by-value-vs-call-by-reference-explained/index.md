---
title: "Call by Value와 Call by Reference"
date: 2024-05-16T22:14:17+09:00
tags: ["프로그래밍", "컴퓨터과학"]
description: "함수 인자 전달 방식인 Call by Value와 Call by Reference의 차이를 설명한다."
draft: false
---

함수 인자 전달 방식(Parameter Passing Mechanism)은 함수를 호출할 때 인자를 어떻게 넘길지 정하는 개념이다. 이 방식은 코드의 동작 방식과 성능에 직접적인 영향을 주기 때문에 프로그래밍에서 매우 중요하다. 대표적인 방식인 Call by Value와 Call by Reference의 차이를 이해하면 더 효율적이고 안전한 코드를 작성할 수 있다.

## 함수 인자 전달 방식 개요

> **함수 인자 전달 방식이란?**
>
> 함수 인자 전달 방식(Parameter Passing Mechanism)은 함수 호출 시 실인자(Actual Parameter)의 값이나 참조를 형식 매개변수(Formal Parameter)에 어떻게 전달하는지를 정의하는 메커니즘으로, Call by Value, Call by Reference, Call by Name, Call by Need 등 다양한 방식이 존재한다.

### 역사적 배경

함수 인자 전달 방식은 1960년대 프로그래밍 언어 설계와 함께 본격적으로 발전했다. ALGOL 60은 Call by Value와 Call by Name을 함께 지원한 초기 언어였고, 이후 많은 프로그래밍 언어가 이를 바탕으로 각자의 전달 방식을 발전시켰다.

| 연도 | 언어/개념 | 인자 전달 방식 |
|------|-----------|----------------|
| **1960** | ALGOL 60 | Call by Value, Call by Name |
| **1972** | C | Call by Value (포인터로 참조 시뮬레이션) |
| **1979** | C++ | Call by Value, Call by Reference |
| **1995** | Java | Call by Value (객체 참조값 전달) |
| **1991** | Python | Call by Object Reference (Call by Sharing) |

### 주요 전달 방식 비교

| 특성 | Call by Value | Call by Reference |
|------|---------------|-------------------|
| **전달 대상** | 값의 복사본 | 원본의 주소/참조 |
| **원본 수정** | 불가능 | 가능 |
| **메모리 사용** | 복사본 생성으로 추가 메모리 필요 | 주소만 전달하므로 효율적 |
| **성능** | 대용량 데이터에서 느림 | 대용량 데이터에서 빠름 |
| **안전성** | 원본 보호됨 | 원본 변경 가능성 있음 |
| **사용 사례** | 기본 타입, 원본 보호 필요 시 | 대용량 객체, 다중 반환값 |

## Call by Value (값에 의한 호출)

> **Call by Value란?**
>
> Call by Value는 함수 호출 시 실인자의 값을 복사하여 형식 매개변수에 전달하는 방식으로, 함수 내부에서 매개변수의 값을 변경해도 호출자의 원본 변수에는 영향을 미치지 않는 가장 기본적이고 안전한 인자 전달 방식이다.

### 메모리 동작 원리

Call by Value 방식에서는 함수 호출 시 실인자의 값이 스택 메모리에 복사되어 새로운 지역 변수가 생성되며, 이 복사본은 함수의 스코프 내에서만 유효하고 함수 종료 시 스택에서 제거된다.

```
호출 전 메모리 상태:
┌─────────────┐
│ main()      │
│ a = 10      │  ← 원본 변수
│ b = 20      │
└─────────────┘

swap(a, b) 호출 후:
┌─────────────┐
│ swap()      │
│ a = 10      │  ← 복사된 값 (별도 메모리)
│ b = 20      │  ← 복사된 값 (별도 메모리)
├─────────────┤
│ main()      │
│ a = 10      │  ← 원본 (변경되지 않음)
│ b = 20      │
└─────────────┘
```

### C 언어에서의 Call by Value

C 언어는 기본적으로 Call by Value만 지원하며, 모든 함수 인자는 값으로 전달되고, 참조에 의한 전달이 필요한 경우 포인터를 사용하여 시뮬레이션한다.

```c
#include <stdio.h>

void swap_by_value(int a, int b) {
    int temp = a;
    a = b;
    b = temp;
    printf("함수 내부: a = %d, b = %d\n", a, b);
}

int main() {
    int x = 10, y = 20;
    printf("호출 전: x = %d, y = %d\n", x, y);
    swap_by_value(x, y);
    printf("호출 후: x = %d, y = %d\n", x, y);
    return 0;
}
```

실행 결과:

```
호출 전: x = 10, y = 20
함수 내부: a = 20, b = 10
호출 후: x = 10, y = 20
```

함수 내부에서 a와 b의 값이 교환되었지만, main 함수의 x와 y는 변경되지 않았으며, 이는 x와 y의 값이 복사되어 전달되었기 때문이다.

### Call by Value의 장단점

| 장점 | 단점 |
|------|------|
| 원본 데이터 보호 | 대용량 데이터 복사 시 성능 저하 |
| 부작용(Side Effect) 방지 | 메모리 사용량 증가 |
| 코드의 예측 가능성 향상 | 다중 반환값 처리 어려움 |
| 디버깅 용이 | 원본 수정이 필요한 경우 별도 처리 필요 |

## 참조 전달 개념

> **참조 전달이란?**
>
> 참조 전달은 함수가 값의 복사본이 아니라 원본 변수에 접근하고 수정할 수 있게 하는 일반적인 개념이다. 언어에 따라 이것이 순수한 Call by Reference로 구현되기도 하고, 포인터나 주소 전달로 시뮬레이션되기도 한다.

### 핵심 동작 원리

참조 기반 전달에서는 함수가 별도의 복사본 대신 원본 변수에 접근할 수 있는 참조나 주소를 받는다. 따라서 함수 내부에서 값을 바꾸면 호출한 쪽의 데이터에도 그대로 반영될 수 있다.

```
호출 전 메모리 상태:
┌─────────────┐
│ main()      │
│ a = 10      │  주소: 0x1000
│ b = 20      │  주소: 0x1004
└─────────────┘

swap(&a, &b) 호출 후:
┌─────────────┐
│ swap()      │
│ a → 0x1000  │  ← 원본 a를 가리킴
│ b → 0x1004  │  ← 원본 b를 가리킴
├─────────────┤
│ main()      │
│ a = 10      │  ← 동일한 메모리 위치
│ b = 20      │
└─────────────┘
```

### C 언어에서의 포인터를 이용한 참조 전달

C 언어는 언어 차원에서 순수한 Call by Reference를 지원하지 않고, 기본적으로 값을 복사해 전달한다. 대신 원본 데이터를 수정해야 할 때는 포인터를 사용해 비슷한 효과를 낼 수 있다. 이 방식은 "Call by Address" 또는 "Simulated Call by Reference"라고도 불린다.

```c
#include <stdio.h>

void swap_by_pointer(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
    printf("함수 내부: *a = %d, *b = %d\n", *a, *b);
}

int main() {
    int x = 10, y = 20;
    printf("호출 전: x = %d, y = %d\n", x, y);
    swap_by_pointer(&x, &y);
    printf("호출 후: x = %d, y = %d\n", x, y);
    return 0;
}
```

실행 결과:

```
호출 전: x = 10, y = 20
함수 내부: *a = 20, *b = 10
호출 후: x = 20, y = 10
```

포인터를 통해 원본 변수의 주소를 전달했기 때문에, 함수 내부에서의 변경이 main 함수의 x와 y에 반영되었다.

### C++의 참조자(Reference)

C++은 참조자(&)를 도입하여 순수한 Call by Reference를 언어 차원에서 지원하며, 참조자는 포인터보다 문법적으로 간결하고 널 포인터 문제를 방지할 수 있다.

```cpp
#include <iostream>
using namespace std;

void swap_by_reference(int &a, int &b) {
    int temp = a;
    a = b;
    b = temp;
    cout << "함수 내부: a = " << a << ", b = " << b << endl;
}

int main() {
    int x = 10, y = 20;
    cout << "호출 전: x = " << x << ", y = " << y << endl;
    swap_by_reference(x, y);
    cout << "호출 후: x = " << x << ", y = " << y << endl;
    return 0;
}
```

### Call by Reference의 장단점

| 장점 | 단점 |
|------|------|
| 대용량 데이터 전달 시 효율적 | 원본 데이터 변경 위험 |
| 다중 반환값 처리 가능 | 부작용(Side Effect) 발생 가능 |
| 메모리 절약 | 코드 추적 어려움 |
| 빠른 성능 | 의도치 않은 수정 가능성 |

## 언어별 인자 전달 방식

### Java: Call by Value (객체 참조의 값 전달)

Java는 모든 것이 Call by Value로 전달되며, 기본 타입(primitive type)은 값이 복사되고, 객체 타입은 객체 참조(reference)의 값이 복사되어 전달된다.

```java
public class ParameterPassing {
    public static void modifyPrimitive(int value) {
        value = 100;
        System.out.println("함수 내부 value: " + value);
    }

    public static void modifyObject(StringBuilder sb) {
        sb.append(" World");
        System.out.println("함수 내부 sb: " + sb);
    }

    public static void reassignObject(StringBuilder sb) {
        sb = new StringBuilder("New Object");
        System.out.println("함수 내부 sb: " + sb);
    }

    public static void main(String[] args) {
        int num = 10;
        modifyPrimitive(num);
        System.out.println("호출 후 num: " + num);

        StringBuilder str = new StringBuilder("Hello");
        modifyObject(str);
        System.out.println("호출 후 str: " + str);

        StringBuilder str2 = new StringBuilder("Original");
        reassignObject(str2);
        System.out.println("호출 후 str2: " + str2);
    }
}
```

실행 결과:

```
함수 내부 value: 100
호출 후 num: 10
함수 내부 sb: Hello World
호출 후 str: Hello World
함수 내부 sb: New Object
호출 후 str2: Original
```

Java에서 객체의 내용은 수정할 수 있지만 참조 자체를 재할당해도 원본에는 영향이 없으며, 이는 참조의 "값"이 복사되어 전달되기 때문이다.

### Python: Call by Object Reference (Call by Sharing)

Python은 Call by Object Reference, 또는 Call by Sharing이라고 불리는 방식을 사용한다. 모든 값이 객체이며 함수에는 객체를 가리키는 참조가 전달된다. 다만 가변(mutable) 객체와 불변(immutable) 객체는 함수 안에서 다르게 동작한다.

```python
def modify_list(lst):
    lst.append(4)
    print(f"함수 내부 리스트: {lst}")

def modify_number(num):
    num = 100
    print(f"함수 내부 숫자: {num}")

def reassign_list(lst):
    lst = [10, 20, 30]
    print(f"함수 내부 재할당 후: {lst}")

# 가변 객체 (리스트)
my_list = [1, 2, 3]
modify_list(my_list)
print(f"호출 후 리스트: {my_list}")

# 불변 객체 (정수)
my_num = 10
modify_number(my_num)
print(f"호출 후 숫자: {my_num}")

# 재할당
my_list2 = [1, 2, 3]
reassign_list(my_list2)
print(f"호출 후 리스트2: {my_list2}")
```

실행 결과:

```
함수 내부 리스트: [1, 2, 3, 4]
호출 후 리스트: [1, 2, 3, 4]
함수 내부 숫자: 100
호출 후 숫자: 10
함수 내부 재할당 후: [10, 20, 30]
호출 후 리스트2: [1, 2, 3]
```

### 언어별 비교 요약

| 언어 | 기본 타입 | 객체/참조 타입 | 특징 |
|------|-----------|----------------|------|
| **C** | Call by Value | 포인터로 시뮬레이션 | 순수 Call by Value |
| **C++** | Call by Value | Value/Reference 선택 | 참조자(&) 지원 |
| **Java** | Call by Value | 참조값의 Call by Value | 순수 Call by Reference 없음 |
| **Python** | - | Call by Object Reference | 모든 것이 객체 |
| **JavaScript** | Call by Value | Call by Sharing | Python과 유사 |
| **Go** | Call by Value | 포인터로 시뮬레이션 | C와 유사 |

## 성능 비교와 최적화

### 데이터 크기에 따른 성능 차이

대용량 데이터 구조체를 전달할 때 Call by Value와 Call by Reference의 성능 차이는 크게 나타나며, 특히 복사 비용이 높은 데이터의 경우 참조 전달이 효율적이다.

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

### const 참조를 통한 안전한 최적화

C++에서는 const 참조를 사용하여 참조 전달의 성능 이점을 유지하면서 원본 수정을 방지할 수 있으며, 이는 대용량 객체를 읽기 전용으로 전달할 때 권장되는 방식이다.

```cpp
void process_safely(const LargeData &data) {
    // data.data[0] = 1;  // 컴파일 에러: const 객체 수정 불가
    int value = data.data[0];  // 읽기는 가능
}
```

### 사용 시나리오별 권장 방식

| 시나리오 | 권장 방식 | 이유 |
|----------|-----------|------|
| 기본 타입(int, float) | Call by Value | 복사 비용이 낮음 |
| 대용량 구조체 읽기 | const Reference | 복사 방지, 수정 불가 |
| 대용량 구조체 수정 | Reference/Pointer | 직접 수정 필요 |
| 다중 반환값 | Reference/Pointer | 여러 값 반환 |
| 함수형 프로그래밍 | Call by Value | 불변성 보장 |

## 실전 활용 가이드

### 스왑 함수 구현 비교

다양한 언어와 방식으로 스왑 함수를 구현한 예제를 통해 인자 전달 방식의 차이를 확인할 수 있다.

**C (포인터 사용):**

```c
void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}
```

**C++ (참조자 사용):**

```cpp
void swap(int &a, int &b) {
    int temp = a;
    a = b;
    b = temp;
}
```

**Python (튜플 언패킹):**

```python
def swap(a, b):
    return b, a

x, y = 10, 20
x, y = swap(x, y)
```

### 배열/컬렉션 처리

배열이나 컬렉션을 함수에 전달할 때는 대부분의 언어에서 참조가 전달되어 원본이 수정될 수 있으므로 주의해야 한다.

```python
# Python에서 리스트 복사 전달
def modify_copy(lst):
    lst = lst.copy()  # 복사본 생성
    lst.append(4)
    return lst

original = [1, 2, 3]
modified = modify_copy(original)
print(f"Original: {original}")  # [1, 2, 3]
print(f"Modified: {modified}")  # [1, 2, 3, 4]
```

### 콜백 함수와 클로저

인자 전달 방식과는 조금 다른 주제지만, 함수가 외부 상태를 다루는 방식까지 함께 보면 값 변경이 어떻게 유지되는지 감을 잡기 쉽다. 콜백 함수에서 외부 변수를 수정할 때는 클로저의 특성도 함께 고려해야 한다.

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

## 결론

함수 인자 전달 방식은 프로그래밍의 기초이지만, 언어마다 구현과 표현이 조금씩 달라 정확히 이해할 필요가 있다. Call by Value는 값을 복사해 원본을 보호하고 부작용을 줄이는 데 유리하며, Call by Reference는 원본에 직접 접근해 효율적인 데이터 처리와 값 수정을 가능하게 한다.

C 언어는 포인터로 참조 전달을 시뮬레이션하고, C++은 참조자를 통해 이를 언어 차원에서 지원한다. Java는 객체 참조의 값이 복사되어 전달되고, Python은 Call by Object Reference(Call by Sharing) 방식을 사용한다. 각 방식의 특성을 이해하고 상황에 맞게 활용하면 더 효율적이고 안전한 코드를 작성할 수 있다.

결국 중요한 것은 언어가 인자를 어떻게 다루는지 정확히 이해하고, 상황에 맞는 전달 방식을 선택하는 것이다.
