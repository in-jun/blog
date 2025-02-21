---
title: "Learn about call by value & call by reference"
date: 2024-05-16T22:14:17+09:00
tags: ["Terminology"]
draft: false
---

## Differences between call by value and call by reference

There are call by value and call by reference methods when passing arguments to a function. Let's learn the differences between the two methods.

### Call by value

> - A method that passes only the value when passing an argument to a function
> - Even if the value of the argument is changed within the function, the value of the calling side is not changed.
> - Usually used when passing a variable

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

Execution result:

```
a: 10, b: 20
```

As you can see from the result, the values of `a` and `b` in the `swap` function have changed, but the values of `a` and `b` in the `main` function have not changed.

> When passing large data, the call by reference method is used because the call by value method uses a lot of memory.
> Also, the call by value method is slow because it copies the value when calling the function.

### Call by reference

> - A method that passes the address when passing an argument to a function
> - If the value of the argument is changed within the function, the value of the calling side is also changed.
> - Can be implemented using pointers

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

Execution result:

```
a: 20, b: 10
```

As you can see from the result, the values of `a` and `b` in the `swap` function have changed, and the values of `a` and `b` in the `main` function have also changed.

> Be careful with the call by reference method because the value can be changed because the address is copied when calling the function.
