---
title: "call by value&call by reference 알아보기"
date: 2024-05-16T22:14:17+09:00
tags: ["용어정리"]
draft: false
---

## call by value, call by reference 차이점

함수에 인자를 넘길 때 call by value와 call by reference 방식이 있다. 두 방식의 차이점을 알아보자.

### call by value

> -   함수에 인자를 넘길 때 값만 넘기는 방식
> -   함수 내에서 인자의 값이 변경되어도 호출한 쪽의 값은 변경되지 않는다.
> -   보통 변수를 넘길 때 사용한다.

```c
#include <stdio.h>

void swap(int a, int b) {
    int temp = a;
    a = b;
    b = temp;
}

int main() {
    int a = 10, b = 20;
    swap(a, b);
    printf("a: %d, b: %d", a, b);
    return 0;
}
```

실행결과:

```
a: 10, b: 20
```

결과를 보면 `swap` 함수에서 `a`와 `b`의 값이 변경되었지만 `main` 함수에서 `a`와 `b`의 값은 변경되지 않았다.

> 큰 데이터를 넘길 때는 call by value 방식을 사용하면 메모리 사용량이 많아지기 때문에 call by reference 방식을 사용한다.
> 또한 call by value 방식은 함수 호출 시 값을 복사하기 때문에 속도가 느리다.

### call by reference

> -   함수에 인자를 넘길 때 주소를 넘기는 방식
> -   함수 내에서 인자의 값이 변경되면 호출한 쪽의 값도 변경된다.
> -   포인터를 사용하여 구현할 수 있다.

```c
#include <stdio.h>

void swap(int *a, int *b) {
    int temp = *a;
    *a = *b;
    *b = temp;
}

int main() {
    int a = 10, b = 20;
    swap(&a, &b);
    printf("a: %d, b: %d", a, b);
    return 0;
}
```

실행결과:

```
a: 20, b: 10
```

결과를 보면 `swap` 함수에서 `a`와 `b`의 값이 변경되었고 `main` 함수에서 `a`와 `b`의 값도 변경되었다.

> call by reference 방식은 함수 호출 시 주소를 복사하기 때문에 값이 변경될 수 있기 때문에 주의해야 한다.
