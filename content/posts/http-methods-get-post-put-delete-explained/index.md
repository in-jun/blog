---
title: "http method 알아보기"
date: 2024-05-25T14:05:29+09:00
tags: ["용어정리", "http"]
draft: false
description: "HTTP/1.1 표준 명세(RFC 7231)에 정의된 9가지 HTTP 메서드의 특성과 활용법을 다룬다. 멱등성과 안전성 개념, RESTful API 설계 원칙, CORS preflight 요청 처리, 실전 예제 및 보안 고려사항을 포함하여 웹 개발에서 HTTP 메서드를 올바르게 사용하는 방법을 설명한다."
---

> HTTP 프로토콜은 클라이언트와 서버 간에 데이터를 주고받기 위한 통신 규약이다. HTTP 프로토콜은 요청과 응답으로 이루어져 있으며, 요청과 응답에 사용되는 메서드를 HTTP 메서드라고 한다. HTTP/1.1 표준(RFC 7231)은 9개의 표준 메서드를 정의하고 있으며, 각 메서드는 멱등성과 안전성이라는 중요한 특성을 가지고 있다.

## HTTP의 역사와 메서드의 발전

HTTP 프로토콜은 1991년 Tim Berners-Lee가 처음 고안한 이후 지속적으로 발전해왔다.

### HTTP/0.9 (1991)

최초의 HTTP 버전으로 GET 메서드만 존재했다. 단순히 HTML 문서를 가져오는 기능만 제공했으며, 헤더나 상태 코드 개념이 없었다.

### HTTP/1.0 (1996)

POST와 HEAD 메서드가 추가되었고, 헤더와 상태 코드가 도입되었다. 이를 통해 다양한 콘텐츠 타입을 전송할 수 있게 되었다.

### HTTP/1.1 (1997)

현재까지 가장 널리 사용되는 버전으로, PUT, DELETE, OPTIONS, TRACE, CONNECT 메서드가 추가되었다. RFC 2616으로 표준화되었으며, 2014년 RFC 7230-7235로 개정되었다. 지속 연결(persistent connection)과 파이프라이닝이 도입되어 성능이 크게 향상되었다.

### HTTP/2 (2015)와 HTTP/3 (2020)

HTTP 메서드 자체는 HTTP/1.1과 동일하게 유지되며, 프로토콜의 전송 계층만 개선되었다. HTTP/2는 바이너리 프로토콜과 멀티플렉싱을 도입했고, HTTP/3는 QUIC 프로토콜을 기반으로 한다.

## HTTP 메서드

HTTP 메서드는 클라이언트가 서버에 요청을 보낼 때 사용하는 메서드이다. HTTP/1.1 표준은 다음 9개의 메서드를 정의하고 있다.

1. **GET** - 리소스 조회
2. **POST** - 리소스 생성 및 데이터 처리
3. **PUT** - 리소스 전체 교체
4. **PATCH** - 리소스 부분 수정
5. **DELETE** - 리소스 삭제
6. **HEAD** - 메타데이터 조회
7. **OPTIONS** - 지원 메서드 확인
8. **CONNECT** - 터널 연결 설정
9. **TRACE** - 경로 추적

## 멱등성과 안전성

HTTP 메서드는 두 가지 중요한 특성으로 분류된다.

### 안전성(Safety)

안전한 메서드는 서버의 상태를 변경하지 않는 읽기 전용 메서드를 의미한다. 안전한 메서드는 캐싱이 가능하며, 프리페칭이나 크롤링에 사용될 수 있다.

### 멱등성(Idempotency)

멱등한 메서드는 동일한 요청을 여러 번 수행해도 한 번 수행한 것과 동일한 결과를 반환하는 메서드를 의미한다. 네트워크 오류로 인한 재시도 시 안전하게 처리할 수 있다.

### 메서드별 특성 비교

| 메서드  | 안전성 | 멱등성 | 캐시 가능 | 요청 body | 응답 body | 일반적 용도           |
| ------- | ------ | ------ | --------- | --------- | --------- | --------------------- |
| GET     | O      | O      | O         | X         | O         | 리소스 조회           |
| HEAD    | O      | O      | O         | X         | X         | 메타데이터 확인       |
| OPTIONS | O      | O      | X         | X         | O         | 지원 메서드 확인      |
| TRACE   | O      | O      | X         | X         | O         | 경로 추적             |
| POST    | X      | X      | O\*       | O         | O         | 리소스 생성/데이터 처리 |
| PUT     | X      | O      | X         | O         | O         | 리소스 전체 교체      |
| PATCH   | X      | X\*    | O\*       | O         | O         | 리소스 부분 수정      |
| DELETE  | X      | O      | X         | X         | O         | 리소스 삭제           |
| CONNECT | X      | X      | X         | X         | O         | 터널 연결             |

\* POST는 명시적 캐시 설정 시 가능, PATCH는 구현에 따라 멱등성과 캐시 가능 여부가 다름

## 메서드 상세 설명

### GET

GET 메서드는 특정 리소스를 가져올 때 사용된다. 이 메서드는 서버에서 데이터를 조회하는데 사용되며, 데이터 변경 없이 요청에 대한 응답으로 리소스를 반환한다.

#### 주요 특징

-   요청을 캐싱할 수 있다.
-   요청을 전송할 때 데이터를 HTTP 메시지의 body에 포함하지 않고, 쿼리스트링을 통해 전송한다.
-   주로 데이터를 조회하거나 페이지를 요청할 때 사용된다.
-   안전하고 멱등성이 있다.

#### 쿼리 파라미터와 URL 길이 제한

GET 요청은 쿼리 파라미터를 통해 데이터를 전달한다. URL에 파라미터가 노출되므로 민감한 정보를 전송해서는 안 된다.

```http
GET /api/users?page=1&limit=10&sort=name HTTP/1.1
Host: api.example.com
```

브라우저와 서버에 따라 URL 길이 제한이 다르다.

-   Internet Explorer: 2,083자
-   Chrome: 약 8,000자
-   Apache 서버: 8,190자 (기본값)
-   Nginx 서버: 4,096자 (기본값)

#### 캐싱 전략

GET 요청은 브라우저와 중간 프록시에서 캐싱될 수 있다. 캐시 제어는 다음 헤더를 통해 이루어진다.

```http
Cache-Control: max-age=3600, public
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2025 07:28:00 GMT
```

#### 실전 예제

```bash
# 기본 GET 요청
curl -X GET https://api.example.com/users/123

# 쿼리 파라미터 포함
curl -X GET "https://api.example.com/users?role=admin&active=true"

# 헤더 포함
curl -X GET https://api.example.com/users/123 \
  -H "Authorization: Bearer token123" \
  -H "Accept: application/json"
```

### POST

POST 메서드는 서버에 데이터를 전송할 때 사용된다. 이 메서드는 주로 새로운 리소스를 생성하거나 서버에 데이터를 제출하는 데 사용된다.

#### 주요 특징

-   요청을 기본적으로 캐싱하지 않는다. (명시적 캐시 설정 시 가능)
-   요청을 전송할 때 데이터를 HTTP 메시지의 body에 포함시킨다.
-   주로 폼 데이터 제출, 파일 업로드, 데이터 처리 요청 등에 사용된다.
-   안전하지 않고 멱등하지 않다.

POST 요청은 멱등성을 보장하지 않기 때문에 동일한 요청을 여러 번 보내면 서버의 상태가 여러 번 변경될 수 있다.

#### 콘텐츠 타입별 요청 형식

**JSON 요청**

```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "홍길동",
    "email": "hong@example.com",
    "age": 30
  }'
```

**폼 데이터 요청**

```bash
curl -X POST https://api.example.com/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=hong&password=secret123"
```

**멀티파트 폼 데이터 (파일 업로드)**

```bash
curl -X POST https://api.example.com/upload \
  -F "file=@photo.jpg" \
  -F "description=프로필 사진"
```

#### 응답 상태 코드

POST 요청에 대한 일반적인 응답 코드는 다음과 같다.

-   `201 Created`: 리소스 생성 성공, Location 헤더에 생성된 리소스 URI 포함
-   `200 OK`: 요청 처리 성공, 처리 결과를 응답 body에 포함
-   `204 No Content`: 요청 처리 성공, 응답 body 없음
-   `400 Bad Request`: 잘못된 요청 데이터
-   `409 Conflict`: 리소스 충돌 (예: 중복된 이메일)

```http
HTTP/1.1 201 Created
Location: /api/users/123
Content-Type: application/json

{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com"
}
```

### PUT

PUT 메서드는 리소스를 생성하거나 수정할 때 사용된다. 이 메서드는 클라이언트가 지정한 위치에 리소스를 저장하거나, 해당 위치에 이미 존재하는 리소스를 업데이트하는 데 사용된다.

#### 주요 특징

-   요청을 캐싱할 수 없다.
-   요청을 전송할 때 데이터를 HTTP 메시지의 body에 포함시킨다.
-   리소스 전체를 업데이트하거나 새로운 리소스를 생성할 때 사용된다.
-   안전하지 않지만 멱등하다.

PUT 요청은 멱등성이 있다. 동일한 PUT 요청을 여러 번 수행해도 동일한 결과를 얻을 수 있다. 이는 리소스의 전체 상태를 변경하기 때문에 부분적인 변경이 발생하지 않는다.

#### 전체 교체 동작

PUT은 리소스 전체를 교체한다. 요청 body에 포함되지 않은 필드는 삭제되거나 기본값으로 설정될 수 있다.

```bash
# 기존 리소스
{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com",
  "age": 30,
  "address": "서울시 강남구"
}

# PUT 요청
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "홍길동",
    "email": "newemail@example.com",
    "age": 31
  }'

# 결과 (address 필드가 제거됨)
{
  "id": 123,
  "name": "홍길동",
  "email": "newemail@example.com",
  "age": 31
}
```

#### 응답 상태 코드

-   `200 OK`: 리소스 업데이트 성공, 응답 body에 업데이트된 리소스 포함
-   `204 No Content`: 리소스 업데이트 성공, 응답 body 없음
-   `201 Created`: 리소스 생성 성공 (리소스가 존재하지 않았던 경우)
-   `404 Not Found`: 리소스를 찾을 수 없음 (생성을 지원하지 않는 경우)

#### Upsert(Update or Insert) 패턴

PUT은 리소스가 없으면 생성하고, 있으면 업데이트하는 upsert 패턴으로 사용될 수 있다.

```bash
# 리소스 생성 또는 업데이트
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "홍길동",
    "email": "hong@example.com"
  }'
```

### PATCH

PATCH 메서드는 리소스의 일부를 수정할 때 사용된다. 이 메서드는 기존 리소스의 일부만 변경하기 위해 사용된다.

#### 주요 특징

-   요청을 기본적으로 캐싱하지 않는다. (명시적 캐시 설정 시 가능)
-   요청을 전송할 때 데이터를 HTTP 메시지의 body에 포함시킨다.
-   리소스의 일부를 업데이트할 때 사용된다.
-   안전하지 않고, 구현에 따라 멱등성이 다르다.

#### PUT vs PATCH

PUT은 리소스 전체를 수정할 때 사용하고, PATCH는 리소스의 일부를 수정할 때 사용한다는 점이다.

```bash
# 기존 리소스
{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com",
  "age": 30,
  "address": "서울시 강남구"
}

# PATCH 요청 (age 필드만 업데이트)
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"age": 31}'

# 결과 (다른 필드는 유지됨)
{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com",
  "age": 31,
  "address": "서울시 강남구"
}
```

#### JSON Patch (RFC 6902)

표준화된 PATCH 형식으로 RFC 6902에 정의되어 있다. 복잡한 업데이트 작업을 표현할 수 있다.

```bash
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json-patch+json" \
  -d '[
    {"op": "replace", "path": "/email", "value": "new@example.com"},
    {"op": "add", "path": "/phone", "value": "010-1234-5678"},
    {"op": "remove", "path": "/address"}
  ]'
```

지원되는 연산:

-   `add`: 값 추가
-   `remove`: 값 제거
-   `replace`: 값 교체
-   `move`: 값 이동
-   `copy`: 값 복사
-   `test`: 값 검증

#### 멱등성 논란

PATCH의 멱등성은 구현 방식에 따라 다르다.

```bash
# 멱등한 PATCH (값 설정)
PATCH /users/123 {"age": 31}

# 멱등하지 않은 PATCH (값 증가)
PATCH /users/123 {"age_increment": 1}
```

단순 필드 교체는 멱등하지만, 증가/감소 연산은 멱등하지 않다. 따라서 PATCH 구현 시 멱등성을 신중하게 고려해야 한다.

### DELETE

DELETE 메서드는 리소스를 삭제할 때 사용된다. 이 메서드는 클라이언트가 서버에서 특정 리소스를 삭제할 것을 요청하는 데 사용된다.

#### 주요 특징

-   요청을 캐싱할 수 없다.
-   리소스를 삭제할 때 사용된다.
-   안전하지 않지만 멱등하다.

DELETE 요청은 멱등성이 있다. 동일한 DELETE 요청을 여러 번 수행해도 서버의 상태는 동일하다. 첫 번째 요청에서 리소스가 삭제되고, 이후 요청은 이미 삭제된 상태를 유지한다.

#### 응답 상태 코드

```bash
# 리소스 삭제
curl -X DELETE https://api.example.com/users/123
```

일반적인 응답 코드:

-   `204 No Content`: 삭제 성공, 응답 body 없음 (가장 일반적)
-   `200 OK`: 삭제 성공, 삭제된 리소스 정보를 응답 body에 포함
-   `202 Accepted`: 삭제 요청이 수락되었으나 아직 처리되지 않음 (비동기 처리)
-   `404 Not Found`: 삭제할 리소스가 존재하지 않음

#### 404 처리 논란

이미 삭제된 리소스에 대한 DELETE 요청의 응답 코드는 구현에 따라 다르다.

**204 No Content 반환 (권장)**

멱등성을 엄격히 준수하는 방식이다. 리소스가 없는 상태가 목표이므로, 이미 삭제된 경우에도 성공으로 간주한다.

```http
DELETE /users/123
HTTP/1.1 204 No Content
```

**404 Not Found 반환**

리소스의 존재 여부를 명확히 알려주는 방식이다. 클라이언트가 잘못된 ID를 사용했음을 알 수 있다.

```http
DELETE /users/999
HTTP/1.1 404 Not Found
```

#### 소프트 삭제 vs 하드 삭제

**하드 삭제 (물리적 삭제)**

```bash
# 데이터베이스에서 완전히 제거
DELETE /users/123
```

**소프트 삭제 (논리적 삭제)**

```bash
# deleted_at 필드를 설정하여 논리적으로만 삭제
PATCH /users/123
{"deleted_at": "2025-01-15T10:30:00Z"}
```

소프트 삭제는 데이터 복구, 감사 추적, 외래 키 무결성 유지 등의 이유로 많이 사용된다.

### HEAD

HEAD 메서드는 GET 메서드와 동일하지만, 응답에 body가 없다. 이 메서드는 주로 리소스의 헤더 정보를 가져오기 위해 사용된다.

#### 주요 특징

-   서버의 헤더 정보만 가져올 때 사용된다.
-   안전하고 멱등하다.
-   캐시 가능하다.

HEAD 요청은 GET 요청과 동일한 응답 헤더를 반환하지만, 응답 본문을 포함하지 않는다. 이를 통해 클라이언트는 리소스의 메타데이터를 확인할 수 있다.

#### 사용 사례

```bash
# 파일 크기 확인 (다운로드 전)
curl -I https://example.com/large-file.zip

HTTP/1.1 200 OK
Content-Length: 104857600
Content-Type: application/zip
Last-Modified: Mon, 13 Jan 2025 10:00:00 GMT
```

-   리소스 존재 여부 확인
-   파일 크기 확인 (Content-Length)
-   마지막 수정 시간 확인 (Last-Modified)
-   콘텐츠 타입 확인 (Content-Type)
-   캐시 유효성 검증 (ETag)

### OPTIONS

OPTIONS 메서드는 서버에 대한 통신 가능한 메서드를 요청한다. 이 메서드는 클라이언트가 특정 리소스에 대해 지원하는 HTTP 메서드를 확인하기 위해 사용된다.

#### 주요 특징

-   서버에 대한 통신 가능한 메서드를 요청할 때 사용된다.
-   안전하고 멱등하다.
-   주로 CORS preflight 요청에 사용된다.

OPTIONS 요청은 서버가 지원하는 메서드와 기타 옵션을 반환한다. 이는 CORS(Cross-Origin Resource Sharing) 설정을 확인하는 데 유용하다.

#### 일반 OPTIONS 요청

```bash
curl -X OPTIONS https://api.example.com/users

HTTP/1.1 200 OK
Allow: GET, POST, HEAD, OPTIONS
```

#### CORS Preflight 요청

브라우저는 특정 조건에서 실제 요청 전에 OPTIONS 요청을 자동으로 보낸다.

```http
OPTIONS /api/users HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

### CONNECT

CONNECT 메서드는 목적 리소스로 식별되는 서버로의 터널을 설정한다. 이 메서드는 주로 SSL(HTTPS)을 사용하는 프록시 서버를 통해 터널링을 설정하기 위해 사용된다.

#### 주요 특징

-   프록시 서버를 통해 연결을 설정할 때 사용된다.
-   안전하지 않고 멱등하지 않다.
-   일반적으로 HTTPS 프록시에서 사용된다.

CONNECT 요청은 클라이언트와 서버 간에 TCP 터널을 설정하여 클라이언트가 프록시 서버를 통해 목적 서버에 직접 연결할 수 있도록 한다.

#### 동작 방식

```http
CONNECT example.com:443 HTTP/1.1
Host: example.com:443

HTTP/1.1 200 Connection Established
```

프록시 서버는 터널을 설정한 후, 클라이언트와 목적 서버 간의 데이터를 중계한다. 이후 전송되는 데이터는 암호화되어 프록시가 내용을 볼 수 없다.

#### 보안 고려사항

CONNECT 메서드는 프록시를 우회 경로로 사용할 수 있어 보안 위험이 있다. 대부분의 프록시는 443 포트(HTTPS)로만 CONNECT를 제한한다.

### TRACE

TRACE 메서드는 목적 리소스로의 경로를 따라 메시지 루프백 테스트를 수행한다. 이 메서드는 클라이언트가 요청을 보내고, 서버가 요청을 받았는지 확인하기 위해 사용된다.

#### 주요 특징

-   서버에 요청을 보내고, 서버가 요청을 받았는지 확인할 때 사용된다.
-   안전하고 멱등하다.
-   디버깅 목적으로 사용된다.

TRACE 요청은 클라이언트가 보낸 요청을 그대로 반환하여 중간 경로에 있는 프록시나 서버의 변조 여부를 확인할 수 있도록 한다.

#### 동작 방식

```http
TRACE /path HTTP/1.1
Host: example.com
Custom-Header: value

HTTP/1.1 200 OK
Content-Type: message/http

TRACE /path HTTP/1.1
Host: example.com
Custom-Header: value
```

#### 보안 위험

TRACE 메서드는 XST(Cross-Site Tracing) 공격에 악용될 수 있다. 공격자가 TRACE를 이용해 HttpOnly 쿠키를 포함한 요청을 받아볼 수 있기 때문이다. 이러한 이유로 대부분의 웹 서버에서는 TRACE 메서드를 비활성화하는 것이 권장된다.

```apache
# Apache 설정
TraceEnable off
```

```nginx
# Nginx 설정
if ($request_method = TRACE) {
    return 405;
}
```

## RESTful API 설계 원칙

REST(Representational State Transfer)는 HTTP 메서드를 활용한 API 설계 아키텍처 스타일이다.

### 리소스 중심 설계

URL은 리소스를 나타내고, HTTP 메서드는 해당 리소스에 대한 동작을 나타낸다.

```
# 좋은 예 (리소스 중심)
GET    /users          # 사용자 목록 조회
GET    /users/123      # 특정 사용자 조회
POST   /users          # 사용자 생성
PUT    /users/123      # 사용자 전체 업데이트
PATCH  /users/123      # 사용자 부분 업데이트
DELETE /users/123      # 사용자 삭제

# 나쁜 예 (동작 중심)
GET    /getUsers
POST   /createUser
POST   /updateUser
POST   /deleteUser
```

### HTTP 메서드의 적절한 사용

각 메서드를 올바른 용도로 사용해야 한다.

| 작업           | HTTP 메서드 | URL 예시                  |
| -------------- | ----------- | ------------------------- |
| 목록 조회      | GET         | /users                    |
| 단일 조회      | GET         | /users/123                |
| 생성           | POST        | /users                    |
| 전체 업데이트  | PUT         | /users/123                |
| 부분 업데이트  | PATCH       | /users/123                |
| 삭제           | DELETE      | /users/123                |
| 검색           | GET         | /users?name=홍길동        |
| 관계 리소스    | GET         | /users/123/posts          |
| 관계 리소스 생성 | POST      | /users/123/posts          |

### 상태 코드와의 조합

HTTP 메서드와 적절한 상태 코드를 조합하여 사용한다.

```
GET /users/123
  200 OK              - 성공
  404 Not Found       - 리소스 없음

POST /users
  201 Created         - 생성 성공
  400 Bad Request     - 잘못된 요청
  409 Conflict        - 리소스 충돌

PUT /users/123
  200 OK              - 업데이트 성공
  204 No Content      - 업데이트 성공 (body 없음)
  404 Not Found       - 리소스 없음

PATCH /users/123
  200 OK              - 업데이트 성공
  404 Not Found       - 리소스 없음

DELETE /users/123
  204 No Content      - 삭제 성공
  404 Not Found       - 리소스 없음
```

### URL 설계 규칙

-   복수형 명사 사용: `/users`, `/posts`
-   소문자 사용: `/user-profiles` (하이픈 사용)
-   계층 구조 표현: `/users/123/posts/456/comments`
-   동사 사용 지양: `/users` (O), `/getUsers` (X)
-   확장자 사용 지양: `/users/123` (O), `/users/123.json` (X)

## CORS와 Preflight 요청

CORS(Cross-Origin Resource Sharing)는 다른 도메인의 리소스에 접근할 수 있도록 하는 메커니즘이다.

### Simple Request vs Preflight Request

**Simple Request 조건**

다음 조건을 모두 만족하면 preflight 없이 바로 요청이 전송된다.

-   메서드: `GET`, `HEAD`, `POST` 중 하나
-   헤더: `Accept`, `Accept-Language`, `Content-Language`, `Content-Type` 등 허용된 헤더만 사용
-   Content-Type: `application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain` 중 하나

**Preflight Request가 필요한 경우**

다음 중 하나라도 해당하면 OPTIONS preflight 요청이 먼저 전송된다.

-   메서드: `PUT`, `DELETE`, `PATCH` 등
-   커스텀 헤더: `Authorization`, `X-Custom-Header` 등
-   Content-Type: `application/json` 등

### Preflight 요청 흐름

```
1. 브라우저가 OPTIONS preflight 요청 전송
   OPTIONS /api/users HTTP/1.1
   Origin: https://example.com
   Access-Control-Request-Method: POST
   Access-Control-Request-Headers: Content-Type, Authorization

2. 서버가 허용 여부 응답
   HTTP/1.1 200 OK
   Access-Control-Allow-Origin: https://example.com
   Access-Control-Allow-Methods: GET, POST, PUT, DELETE
   Access-Control-Allow-Headers: Content-Type, Authorization
   Access-Control-Max-Age: 86400

3. 실제 POST 요청 전송
   POST /api/users HTTP/1.1
   Origin: https://example.com
   Content-Type: application/json
   Authorization: Bearer token123

4. 서버가 실제 응답 반환
   HTTP/1.1 201 Created
   Access-Control-Allow-Origin: https://example.com
```

### CORS 에러 해결 방법

**서버 측 설정 (Node.js/Express 예시)**

```javascript
const cors = require('cors');

// 모든 도메인 허용
app.use(cors());

// 특정 도메인만 허용
app.use(cors({
  origin: 'https://example.com',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400
}));
```

**서버 측 설정 (Nginx 예시)**

```nginx
add_header Access-Control-Allow-Origin https://example.com;
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
add_header Access-Control-Allow-Headers "Content-Type, Authorization";
add_header Access-Control-Max-Age 86400;

if ($request_method = OPTIONS) {
    return 204;
}
```

## 실전 예제: 블로그 API 설계

실제 블로그 시스템의 RESTful API 엔드포인트 설계 예제이다.

### 게시글 관리

```bash
# 게시글 목록 조회 (페이지네이션, 필터링)
curl -X GET "https://api.blog.com/posts?page=1&limit=10&category=tech&sort=created_at"

# 게시글 상세 조회
curl -X GET https://api.blog.com/posts/123

# 게시글 생성
curl -X POST https://api.blog.com/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "title": "HTTP 메서드 완벽 가이드",
    "content": "내용...",
    "category": "tech",
    "tags": ["http", "rest"]
  }'

# 게시글 전체 업데이트
curl -X PUT https://api.blog.com/posts/123 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "title": "수정된 제목",
    "content": "수정된 내용...",
    "category": "tech",
    "tags": ["http", "rest", "api"]
  }'

# 게시글 부분 업데이트 (제목만 수정)
curl -X PATCH https://api.blog.com/posts/123 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{"title": "새로운 제목"}'

# 게시글 삭제
curl -X DELETE https://api.blog.com/posts/123 \
  -H "Authorization: Bearer token123"
```

### 댓글 관리 (중첩 리소스)

```bash
# 특정 게시글의 댓글 목록 조회
curl -X GET https://api.blog.com/posts/123/comments

# 댓글 생성
curl -X POST https://api.blog.com/posts/123/comments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "content": "좋은 글 감사합니다!",
    "author": "홍길동"
  }'

# 댓글 수정
curl -X PATCH https://api.blog.com/posts/123/comments/456 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{"content": "수정된 댓글 내용"}'

# 댓글 삭제
curl -X DELETE https://api.blog.com/posts/123/comments/456 \
  -H "Authorization: Bearer token123"
```

### 파일 업로드

```bash
# 이미지 업로드
curl -X POST https://api.blog.com/posts/123/images \
  -H "Authorization: Bearer token123" \
  -F "image=@photo.jpg" \
  -F "caption=게시글 이미지"
```

## 보안 고려사항

HTTP 메서드를 사용할 때 주의해야 할 보안 사항이다.

### TRACE 메서드 비활성화 권장

TRACE는 XST(Cross-Site Tracing) 공격에 취약하므로 프로덕션 환경에서는 비활성화해야 한다.

```apache
# Apache
TraceEnable off
```

```nginx
# Nginx
if ($request_method = TRACE) {
    return 405;
}
```

### GET으로 상태 변경 금지

GET 요청은 안전해야 하며, 서버 상태를 변경해서는 안 된다.

```
# 나쁜 예
GET /users/123/delete
GET /posts/456/publish

# 좋은 예
DELETE /users/123
PATCH /posts/456 {"status": "published"}
```

이유:

-   브라우저가 GET 요청을 미리 가져올 수 있음 (prefetching)
-   검색 엔진 크롤러가 GET 요청을 따라갈 수 있음
-   브라우저 히스토리에 남아 재실행될 수 있음

### CSRF(Cross-Site Request Forgery) 공격 방지

POST, PUT, DELETE 요청은 CSRF 공격에 취약할 수 있다.

**CSRF 토큰 사용**

```html
<form method="POST" action="/api/users">
  <input type="hidden" name="csrf_token" value="random_token_value">
  <!-- 폼 필드 -->
</form>
```

**SameSite 쿠키 속성 설정**

```http
Set-Cookie: session=abc123; SameSite=Strict; Secure; HttpOnly
```

**커스텀 헤더 검증**

```javascript
// 클라이언트
fetch('/api/users', {
  method: 'POST',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});

// 서버
if (!request.headers['X-Requested-With']) {
  return 403; // Forbidden
}
```

### 인증 및 권한 검증

상태 변경 메서드(POST, PUT, PATCH, DELETE)는 항상 인증과 권한을 검증해야 한다.

```javascript
// Express 미들웨어 예시
app.delete('/users/:id', authenticateToken, authorizeUser, (req, res) => {
  // 사용자 삭제 로직
});

function authenticateToken(req, res, next) {
  const token = req.headers['authorization'];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

function authorizeUser(req, res, next) {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.sendStatus(403);
  }
  next();
}
```

### 입력 검증 및 제한

-   요청 body 크기 제한 (DoS 방지)
-   입력 데이터 검증 및 정제
-   SQL 인젝션, XSS 방지

```javascript
// Express body 크기 제한
app.use(express.json({ limit: '10mb' }));

// 입력 검증 (Joi 라이브러리 예시)
const schema = Joi.object({
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(0).max(150)
});

const { error, value } = schema.validate(req.body);
if (error) return res.status(400).json({ error: error.details });
```

## 요약

HTTP 메서드는 클라이언트와 서버 간의 통신에서 수행할 작업을 정의하는 핵심 요소이다. HTTP/1.1 표준은 9개의 메서드를 정의하고 있으며, 각 메서드는 안전성과 멱등성이라는 중요한 특성을 가진다.

### 핵심 요점

-   **안전한 메서드** (GET, HEAD, OPTIONS, TRACE): 서버 상태를 변경하지 않음
-   **멱등한 메서드** (GET, PUT, DELETE, HEAD, OPTIONS, TRACE): 여러 번 실행해도 동일한 결과
-   **비멱등 메서드** (POST, PATCH): 실행할 때마다 다른 결과 가능

### 실무 활용

-   **RESTful API 설계**: 리소스 중심 URL과 적절한 HTTP 메서드 조합
-   **CORS 이해**: preflight 요청 메커니즘과 서버 설정
-   **보안**: CSRF 방지, 인증/권한 검증, 입력 검증

HTTP 메서드를 올바르게 이해하고 사용하면 확장 가능하고 유지보수가 쉬운 웹 API를 설계할 수 있다.

### 참고

-   [MDN web docs - HTTP](https://developer.mozilla.org/ko/docs/Web/HTTP)
-   [RFC 7231 - HTTP/1.1 Semantics and Content](https://tools.ietf.org/html/rfc7231)
-   [RFC 6902 - JSON Patch](https://tools.ietf.org/html/rfc6902)
-   [REST API Design Best Practices](https://restfulapi.net/)
