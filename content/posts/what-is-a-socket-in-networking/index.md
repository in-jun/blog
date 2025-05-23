---
title: "socket이란 무엇인가?"
date: 2024-06-08T21:22:40+09:00
tags: ["network", "socket"]
draft: false
---

### 소켓(Socket)이란

**소켓(Socket)** 은 네트워크 통신을 위한 인터페이스를 제공하는 소프트웨어이다. 소켓은 클라이언트와 서버 간의 통신을 가능하게 하며, 데이터를 주고받을 수 있다.

소켓은 네트워크 통신을 위한 API(Application Programming Interface)를 제공한다. 소켓은 TCP(Transmission Control Protocol)와 UDP(User Datagram Protocol)를 지원하며, 데이터를 안정적으로 전송할 수 있다.

### 소켓 통신 방식

소켓은 클라이언트와 서버 간의 통신을 위해 다음과 같은 방식을 제공한다.

1. **TCP(Transmission Control Protocol)**:

    - **연결 지향(Connection-Oriented)**: 클라이언트와 서버 간에 연결을 설정하고, 데이터를 안정적으로 전송한다.
    - **신뢰성(Reliability)**: 데이터를 순서대로 전송하고, 손실된 데이터를 재전송한다.
    - **흐름 제어(Flow Control)**: 데이터의 전송 속도를 조절하여 데이터 손실을 방지한다.
    - **혼잡 제어(Congestion Control)**: 네트워크의 혼잡 상태를 감지하고, 데이터의 전송 속도를 조절한다.

2. **UDP(User Datagram Protocol)**:

    - **비연결 지향(Connectionless)**: 클라이언트와 서버 간에 연결을 설정하지 않고, 데이터를 전송한다.
    - **신뢰성(Reliability)**: 데이터를 순서대로 전송하지 않고, 손실된 데이터를 재전송하지 않는다.
    - **흐름 제어(Flow Control)**: 데이터의 전송 속도를 조절하지 않는다.
    - **혼잡 제어(Congestion Control)**: 네트워크의 혼잡 상태를 감지하지 않는다.

### 소켓 통신 과정

#### 서버

1. 소켓 생성
2. 바인딩 (ip, port 설정)
3. 리슨 (연결 대기)
4. 억셉트 (클라이언트 연결 수락)
5. 통신 (데이터 송수신)
6. 클로즈 (연결 종료)

#### 클라이언트

1. 소켓 생성
2. 커넥트 (서버 연결)
3. 억셉트 (클라이언트의 socket descriptor 반환)
4. 통신 (데이터 송수신)
5. 클로즈 (연결 종료)

### HTTP와 소켓이 차이점

**HTTP(HyperText Transfer Protocol)** 는 웹 서버와 클라이언트 간의 통신을 위한 프로토콜이다. HTTP는 TCP를 기반으로 하며, 웹 페이지를 전송하는 데 사용된다.

소켓은 네트워크 통신을 위한 인터페이스를 제공하는 소프트웨어이다. 결론적으로, HTTP는 소켓을 사용하여 데이터를 전송한다.
