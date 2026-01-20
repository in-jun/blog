---
title: "HTTP 메서드 완벽 가이드: GET, POST, PUT, DELETE부터 보안까지"
date: 2024-05-25T14:05:29+09:00
tags: ["HTTP", "REST API", "웹 개발", "CORS"]
draft: false
description: "HTTP/1.1 표준 명세(RFC 7231)에 정의된 9가지 HTTP 메서드의 역사, 특성, 활용법을 다루며, 멱등성과 안전성 개념부터 RESTful API 설계 원칙, CORS preflight 요청 처리, 실전 예제, 보안 고려사항까지 웹 개발에서 HTTP 메서드를 올바르게 사용하는 방법을 포괄적으로 설명한다."
---

HTTP(HyperText Transfer Protocol) 메서드는 1991년 Tim Berners-Lee가 World Wide Web을 고안하면서 처음 등장한 이후 지속적으로 발전해온 클라이언트-서버 간 통신 규약의 핵심 요소로, HTTP/1.1 표준(RFC 7231)에서는 GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, CONNECT, TRACE의 9가지 표준 메서드를 정의하고 있으며, 각 메서드는 멱등성(Idempotency)과 안전성(Safety)이라는 중요한 특성을 가지고 RESTful API 설계와 웹 애플리케이션 개발에서 핵심적인 역할을 담당한다.

## HTTP의 역사와 메서드의 발전

> **HTTP(HyperText Transfer Protocol)란?**
>
> 웹에서 클라이언트와 서버 간에 하이퍼텍스트 문서를 전송하기 위한 응용 계층 프로토콜로, 요청-응답 모델을 기반으로 동작하며 각 요청에 사용되는 메서드가 수행할 작업의 의미를 정의한다.

HTTP 프로토콜은 1989년 CERN의 Tim Berners-Lee가 정보 공유 시스템으로 제안한 이후 지속적으로 발전해왔으며, 메서드의 종류와 의미론도 함께 확장되어 왔다.

### HTTP/0.9 (1991)

최초의 HTTP 버전으로 GET 메서드만 존재했으며, 단순히 HTML 문서를 가져오는 기능만 제공했고 헤더나 상태 코드 개념이 없어 서버는 요청받은 문서를 그대로 반환하거나 연결을 끊는 것만 가능했다.

### HTTP/1.0 (1996, RFC 1945)

POST와 HEAD 메서드가 추가되었고 요청/응답 헤더와 상태 코드가 도입되어 다양한 콘텐츠 타입(이미지, 비디오 등)을 전송할 수 있게 되었으며, Content-Type 헤더를 통해 MIME 타입을 지정하는 것이 가능해졌다.

### HTTP/1.1 (1997, RFC 2068 → 2014, RFC 7230-7235)

현재까지 가장 널리 사용되는 버전으로, PUT, DELETE, OPTIONS, TRACE, CONNECT 메서드가 추가되었고 지속 연결(persistent connection)과 파이프라이닝(pipelining)이 도입되어 성능이 크게 향상되었으며, 청크 전송 인코딩(chunked transfer encoding)과 호스트 헤더 필수화 등의 중요한 기능이 추가되었다.

### HTTP/2 (2015, RFC 7540)와 HTTP/3 (2022, RFC 9114)

HTTP 메서드 자체는 HTTP/1.1과 동일하게 유지되며 프로토콜의 전송 계층만 개선되었는데, HTTP/2는 바이너리 프로토콜과 멀티플렉싱을 도입하여 단일 연결에서 여러 요청을 동시에 처리할 수 있게 되었고, HTTP/3는 UDP 기반의 QUIC 프로토콜을 사용하여 연결 설정 지연 시간을 줄이고 패킷 손실 시 성능 저하를 방지한다.

## 멱등성과 안전성

HTTP 메서드를 이해하는 데 있어 가장 중요한 두 가지 개념은 멱등성(Idempotency)과 안전성(Safety)이며, 이 특성들은 캐싱, 재시도 정책, API 설계 등에 직접적인 영향을 미친다.

### 안전성(Safety)

> **안전한 메서드란?**
>
> 서버의 상태를 변경하지 않는 읽기 전용 메서드로, 같은 요청을 여러 번 수행해도 서버의 리소스에 부작용(side effect)이 발생하지 않는다.

안전한 메서드(GET, HEAD, OPTIONS, TRACE)는 서버의 데이터를 변경하지 않으므로 캐싱이 가능하고, 브라우저의 프리페칭(prefetching)이나 검색 엔진 크롤러가 안심하고 호출할 수 있으며, 북마크나 히스토리에 저장되어 다시 실행되어도 문제가 없다.

### 멱등성(Idempotency)

> **멱등한 메서드란?**
>
> 동일한 요청을 한 번 수행한 것과 여러 번 수행한 것이 서버에 동일한 결과를 남기는 메서드로, 네트워크 오류로 인해 요청이 중복 전송되더라도 안전하게 재시도할 수 있다.

멱등성은 분산 시스템에서 특히 중요한데, 네트워크 타임아웃이나 일시적 장애로 인해 클라이언트가 응답을 받지 못하고 같은 요청을 재전송하는 경우가 빈번하기 때문이며, 멱등한 메서드(GET, PUT, DELETE, HEAD, OPTIONS, TRACE)는 이러한 상황에서 안전하게 재시도할 수 있다.

### 메서드별 특성 비교

| 메서드 | 안전성 | 멱등성 | 캐시 가능 | 요청 body | 응답 body | 주요 용도 |
|--------|--------|--------|-----------|-----------|-----------|-----------|
| GET | O | O | O | X | O | 리소스 조회 |
| HEAD | O | O | O | X | X | 메타데이터 확인 |
| OPTIONS | O | O | X | X | O | 지원 메서드 확인 |
| TRACE | O | O | X | X | O | 경로 추적/디버깅 |
| POST | X | X | 조건부 | O | O | 리소스 생성/데이터 처리 |
| PUT | X | O | X | O | O | 리소스 전체 교체 |
| PATCH | X | 구현 의존 | 조건부 | O | O | 리소스 부분 수정 |
| DELETE | X | O | X | X | O | 리소스 삭제 |
| CONNECT | X | X | X | X | O | 터널 연결 설정 |

## 9가지 HTTP 메서드 상세

### GET - 리소스 조회

GET 메서드는 지정한 리소스의 표현(representation)을 요청하는 메서드로, 서버로부터 데이터를 조회하는 데 사용되며 데이터 변경 없이 요청에 대한 응답으로 리소스를 반환한다.

**핵심 특성**

- 안전하고 멱등하여 캐싱이 가능하며, 브라우저 히스토리에 남고 북마크가 가능하다
- 데이터는 URL의 쿼리 문자열(query string)을 통해 전달하며, 요청 본문(body)에 데이터를 포함하지 않는다
- URL에 파라미터가 노출되므로 비밀번호나 개인정보 같은 민감한 데이터를 전송해서는 안 된다

**쿼리 파라미터와 URL 길이 제한**

```http
GET /api/users?page=1&limit=10&sort=created_at&order=desc HTTP/1.1
Host: api.example.com
Accept: application/json
```

URL 길이는 브라우저와 서버에 따라 제한이 다르며, Internet Explorer는 2,083자, Chrome은 약 8,000자, Apache 서버는 기본 8,190자, Nginx 서버는 기본 4,096자로 제한된다.

**캐싱 제어**

```http
HTTP/1.1 200 OK
Cache-Control: max-age=3600, public
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2025 07:28:00 GMT
Vary: Accept-Encoding
```

**실전 예제**

```bash
# 기본 GET 요청
curl -X GET https://api.example.com/users/123

# 쿼리 파라미터와 헤더 포함
curl -X GET "https://api.example.com/users?role=admin&active=true" \
  -H "Authorization: Bearer token123" \
  -H "Accept: application/json"

# 조건부 GET (캐시 검증)
curl -X GET https://api.example.com/users/123 \
  -H "If-None-Match: \"33a64df551425fcc55e4d42a148795d9f25f89d4\""
```

### POST - 리소스 생성 및 데이터 처리

POST 메서드는 서버에 데이터를 제출하여 새로운 리소스를 생성하거나, 데이터를 처리하도록 요청하는 메서드로, 폼 데이터 제출, 파일 업로드, 복잡한 검색 조건 전달 등 다양한 용도로 사용된다.

**핵심 특성**

- 안전하지 않고 멱등하지 않아, 동일한 요청을 여러 번 보내면 매번 새로운 리소스가 생성될 수 있다
- 데이터를 HTTP 메시지 본문(body)에 포함하여 전송하며, 민감한 정보도 URL에 노출되지 않는다
- 기본적으로 캐싱되지 않지만, Cache-Control 헤더로 명시적 설정 시 캐싱 가능하다

**콘텐츠 타입별 요청 형식**

```bash
# JSON 형식
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "홍길동",
    "email": "hong@example.com",
    "age": 30
  }'

# 폼 데이터 형식 (URL 인코딩)
curl -X POST https://api.example.com/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=hong&password=secret123"

# 멀티파트 폼 데이터 (파일 업로드)
curl -X POST https://api.example.com/upload \
  -F "file=@photo.jpg" \
  -F "description=프로필 사진" \
  -F "category=profile"
```

**응답 상태 코드**

| 상태 코드 | 의미 | 설명 |
|-----------|------|------|
| 201 Created | 생성 성공 | Location 헤더에 새 리소스 URI 포함 |
| 200 OK | 처리 성공 | 처리 결과를 응답 body에 포함 |
| 204 No Content | 처리 성공 | 응답 body 없음 |
| 400 Bad Request | 잘못된 요청 | 유효성 검사 실패 등 |
| 409 Conflict | 충돌 | 중복 데이터 등 |

### PUT - 리소스 전체 교체

PUT 메서드는 지정한 URI에 리소스를 저장하는 메서드로, 해당 URI에 리소스가 존재하면 전체를 교체하고 존재하지 않으면 새로 생성하는 upsert 동작을 수행한다.

**핵심 특성**

- 안전하지 않지만 멱등하여, 동일한 PUT 요청을 여러 번 수행해도 결과가 동일하다
- 리소스 전체를 교체하므로, 요청 본문에 포함되지 않은 필드는 삭제되거나 기본값으로 설정된다
- 클라이언트가 리소스의 URI를 알고 있어야 한다 (POST와의 차이점)

**전체 교체 동작 예시**

```bash
# 기존 리소스
{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com",
  "age": 30,
  "address": "서울시 강남구"
}

# PUT 요청 (age만 변경하려 해도 전체 데이터 필요)
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

### PATCH - 리소스 부분 수정

PATCH 메서드는 리소스의 일부분만 수정하는 메서드로, PUT과 달리 요청 본문에 포함된 필드만 수정하고 나머지 필드는 유지한다.

**핵심 특성**

- 안전하지 않으며, 멱등성은 구현 방식에 따라 다르다
- PUT보다 효율적으로 대역폭을 사용할 수 있다 (변경된 부분만 전송)
- JSON Merge Patch(RFC 7396)와 JSON Patch(RFC 6902) 두 가지 표준 형식이 존재한다

**PUT vs PATCH 비교**

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

**JSON Patch (RFC 6902)**

```bash
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json-patch+json" \
  -d '[
    {"op": "replace", "path": "/email", "value": "new@example.com"},
    {"op": "add", "path": "/phone", "value": "010-1234-5678"},
    {"op": "remove", "path": "/address"},
    {"op": "test", "path": "/age", "value": 30}
  ]'
```

**멱등성 주의사항**

```bash
# 멱등한 PATCH (값 설정 - 여러 번 실행해도 결과 동일)
PATCH /users/123 {"age": 31}

# 멱등하지 않은 PATCH (값 증가 - 실행할 때마다 결과 다름)
PATCH /users/123 {"age_increment": 1}
```

### DELETE - 리소스 삭제

DELETE 메서드는 지정한 리소스를 삭제하도록 서버에 요청하는 메서드로, 성공적으로 삭제되면 해당 URI의 리소스는 더 이상 접근할 수 없게 된다.

**핵심 특성**

- 안전하지 않지만 멱등하여, 이미 삭제된 리소스에 대한 DELETE 요청도 동일한 결과(리소스 없음)를 반환한다
- 일반적으로 요청 본문을 포함하지 않지만, 일부 구현에서는 삭제 조건을 본문에 포함하기도 한다

**응답 상태 코드**

| 상태 코드 | 의미 | 설명 |
|-----------|------|------|
| 204 No Content | 삭제 성공 | 응답 body 없음 (가장 일반적) |
| 200 OK | 삭제 성공 | 삭제된 리소스 정보 반환 |
| 202 Accepted | 삭제 수락 | 비동기 처리 중 |
| 404 Not Found | 리소스 없음 | 구현에 따라 다름 |

**소프트 삭제 vs 하드 삭제**

```bash
# 하드 삭제 (물리적 삭제)
curl -X DELETE https://api.example.com/users/123

# 소프트 삭제 (논리적 삭제 - 실제로는 PATCH)
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"deleted_at": "2025-01-15T10:30:00Z", "is_active": false}'
```

소프트 삭제는 데이터 복구, 감사 추적(audit trail), 외래 키 무결성 유지 등의 이유로 많이 사용되며, 실제로 데이터를 삭제하지 않고 삭제 플래그만 설정한다.

### HEAD - 메타데이터 조회

HEAD 메서드는 GET 요청과 동일하지만 응답 본문(body) 없이 헤더만 반환하는 메서드로, 리소스의 메타데이터만 필요할 때 대역폭을 절약하면서 정보를 얻을 수 있다.

**핵심 특성**

- 안전하고 멱등하며, 캐시 가능하다
- GET 요청과 동일한 응답 헤더를 반환하지만, 응답 본문은 포함하지 않는다
- 서버는 GET과 HEAD에 대해 동일한 헤더를 반환해야 한다 (RFC 7231)

**사용 사례**

```bash
# 파일 크기 및 수정 시간 확인 (다운로드 전)
curl -I https://example.com/large-file.zip

HTTP/1.1 200 OK
Content-Length: 104857600
Content-Type: application/zip
Last-Modified: Mon, 13 Jan 2025 10:00:00 GMT
ETag: "abc123"
Accept-Ranges: bytes
```

- 리소스 존재 여부 확인 (다운로드하지 않고)
- 파일 크기 확인 (Content-Length)
- 마지막 수정 시간 확인 (Last-Modified)
- 캐시 유효성 검증 (ETag, Last-Modified)
- 링크 유효성 검사 (웹 크롤러)

### OPTIONS - 지원 메서드 확인

OPTIONS 메서드는 특정 리소스에 대해 서버가 지원하는 통신 옵션(메서드, 헤더 등)을 요청하는 메서드로, CORS(Cross-Origin Resource Sharing) preflight 요청에서 핵심적인 역할을 한다.

**핵심 특성**

- 안전하고 멱등하다
- 응답의 Allow 헤더에 지원 메서드 목록이 포함된다
- CORS preflight 요청 시 브라우저가 자동으로 전송한다

**일반 OPTIONS 요청**

```bash
curl -X OPTIONS https://api.example.com/users

HTTP/1.1 200 OK
Allow: GET, POST, HEAD, OPTIONS
```

**CORS Preflight 요청**

브라우저는 특정 조건(PUT/DELETE 메서드, 커스텀 헤더, application/json 등)에서 실제 요청 전에 OPTIONS preflight 요청을 자동으로 전송한다.

```http
OPTIONS /api/users HTTP/1.1
Host: api.example.com
Origin: https://frontend.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://frontend.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
Access-Control-Allow-Credentials: true
```

### CONNECT - 터널 연결

CONNECT 메서드는 목적 서버로의 TCP 터널을 설정하도록 프록시 서버에 요청하는 메서드로, 주로 HTTPS 연결을 프록시를 통해 중계할 때 사용된다.

**핵심 특성**

- 안전하지 않고 멱등하지 않다
- 프록시 서버가 클라이언트와 목적 서버 사이의 TCP 연결을 중계한다
- 터널이 설정된 후 데이터는 암호화되어 프록시가 내용을 볼 수 없다

**동작 방식**

```http
CONNECT api.example.com:443 HTTP/1.1
Host: api.example.com:443
Proxy-Authorization: Basic YWxhZGRpbjpvcGVuc2VzYW1l

HTTP/1.1 200 Connection Established

(이후 TLS 핸드셰이크 및 암호화된 HTTPS 통신 시작)
```

**보안 고려사항**

CONNECT 메서드는 프록시를 우회하는 용도로 악용될 수 있어 보안 위험이 존재하며, 대부분의 프록시 서버는 443 포트(HTTPS)로만 CONNECT를 제한하여 악의적인 포트 접근을 방지한다.

### TRACE - 경로 추적

TRACE 메서드는 목적 서버까지의 경로를 따라 요청 메시지의 루프백 테스트를 수행하는 디버깅용 메서드로, 서버는 받은 요청을 그대로 응답 본문에 포함하여 반환한다.

**핵심 특성**

- 안전하고 멱등하다
- 요청이 중간 프록시를 거치면서 어떻게 변경되는지 확인할 수 있다
- 보안 위험으로 인해 대부분의 프로덕션 서버에서 비활성화된다

**동작 방식**

```http
TRACE /path HTTP/1.1
Host: api.example.com
X-Custom-Header: test-value

HTTP/1.1 200 OK
Content-Type: message/http

TRACE /path HTTP/1.1
Host: api.example.com
X-Custom-Header: test-value
Via: 1.1 proxy.example.com
```

**보안 위험 (XST 공격)**

TRACE 메서드는 XST(Cross-Site Tracing) 공격에 악용될 수 있는데, 공격자가 XSS와 결합하여 HttpOnly 쿠키나 Authorization 헤더 값을 탈취할 수 있기 때문이다. 따라서 프로덕션 환경에서는 TRACE를 비활성화해야 한다.

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

REST(Representational State Transfer)는 Roy Fielding이 2000년 박사 논문에서 제안한 아키텍처 스타일로, HTTP 메서드의 의미론을 활용하여 일관성 있고 직관적인 API를 설계하는 원칙을 제시한다.

### 리소스 중심 설계

URL은 리소스(명사)를 나타내고, HTTP 메서드는 해당 리소스에 대한 동작(동사)을 나타낸다.

```
# 좋은 예 (리소스 중심)
GET    /users          # 사용자 목록 조회
GET    /users/123      # ID가 123인 사용자 조회
POST   /users          # 새 사용자 생성
PUT    /users/123      # 사용자 전체 업데이트
PATCH  /users/123      # 사용자 부분 업데이트
DELETE /users/123      # 사용자 삭제

# 나쁜 예 (동작 중심)
GET    /getUsers
POST   /createUser
POST   /updateUser
POST   /deleteUser
```

### CRUD 매핑

| 작업 | HTTP 메서드 | URI 패턴 | 응답 코드 |
|------|-------------|----------|-----------|
| 목록 조회 (Collection) | GET | /users | 200 OK |
| 단일 조회 (Document) | GET | /users/{id} | 200 OK, 404 Not Found |
| 생성 | POST | /users | 201 Created |
| 전체 수정 | PUT | /users/{id} | 200 OK, 204 No Content |
| 부분 수정 | PATCH | /users/{id} | 200 OK |
| 삭제 | DELETE | /users/{id} | 204 No Content |
| 검색 | GET | /users?name=홍길동 | 200 OK |
| 중첩 리소스 | GET | /users/{id}/posts | 200 OK |

### URL 설계 규칙

- **복수형 명사 사용**: `/users`, `/posts`, `/comments`
- **소문자 사용**: `/user-profiles` (하이픈으로 단어 구분)
- **계층 구조 표현**: `/users/123/posts/456/comments`
- **동사 사용 지양**: `/users` (O), `/getUsers` (X)
- **파일 확장자 제외**: `/users/123` (O), `/users/123.json` (X)
- **버전 관리**: `/v1/users`, `/v2/users`

## CORS와 Preflight 요청

CORS(Cross-Origin Resource Sharing)는 웹 브라우저의 동일 출처 정책(Same-Origin Policy)을 우회하여 다른 도메인의 리소스에 접근할 수 있도록 하는 메커니즘으로, OPTIONS 메서드를 활용한 preflight 요청이 핵심이다.

### Simple Request vs Preflight Request

**Simple Request 조건** (preflight 없이 바로 전송)

- 메서드: GET, HEAD, POST 중 하나
- 헤더: Accept, Accept-Language, Content-Language, Content-Type만 사용
- Content-Type: application/x-www-form-urlencoded, multipart/form-data, text/plain 중 하나

**Preflight가 필요한 경우**

- 메서드: PUT, DELETE, PATCH 등
- 커스텀 헤더: Authorization, X-Custom-Header 등
- Content-Type: application/json 등

### Preflight 요청 흐름

```
1. 브라우저가 OPTIONS preflight 요청 전송
   OPTIONS /api/users HTTP/1.1
   Origin: https://frontend.example.com
   Access-Control-Request-Method: POST
   Access-Control-Request-Headers: Content-Type, Authorization

2. 서버가 CORS 정책 응답
   HTTP/1.1 200 OK
   Access-Control-Allow-Origin: https://frontend.example.com
   Access-Control-Allow-Methods: GET, POST, PUT, DELETE
   Access-Control-Allow-Headers: Content-Type, Authorization
   Access-Control-Max-Age: 86400

3. 브라우저가 실제 요청 전송
   POST /api/users HTTP/1.1
   Origin: https://frontend.example.com
   Content-Type: application/json
   Authorization: Bearer token123

4. 서버가 실제 응답 반환
   HTTP/1.1 201 Created
   Access-Control-Allow-Origin: https://frontend.example.com
```

### CORS 서버 설정 예시

**Node.js (Express)**

```javascript
const cors = require('cors');

app.use(cors({
  origin: ['https://frontend.example.com', 'https://app.example.com'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400
}));
```

**Nginx**

```nginx
location /api/ {
    add_header Access-Control-Allow-Origin https://frontend.example.com;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
    add_header Access-Control-Allow-Headers "Content-Type, Authorization";
    add_header Access-Control-Max-Age 86400;

    if ($request_method = OPTIONS) {
        return 204;
    }
}
```

## 보안 고려사항

HTTP 메서드 사용 시 고려해야 할 주요 보안 사항들이다.

### GET으로 상태 변경 금지

GET 요청은 안전해야 하며 서버 상태를 변경해서는 안 된다.

```
# 나쁜 예 (보안 취약)
GET /users/123/delete
GET /posts/456/publish

# 좋은 예
DELETE /users/123
PATCH /posts/456 {"status": "published"}
```

GET으로 상태를 변경하면 다음과 같은 문제가 발생한다:
- 브라우저 프리페칭으로 의도치 않은 상태 변경 발생
- 검색 엔진 크롤러가 삭제/수정 URL을 따라갈 수 있음
- 브라우저 히스토리나 북마크에서 재실행될 수 있음
- CSRF 공격에 더 취약해짐

### CSRF 공격 방지

POST, PUT, DELETE 등 상태 변경 메서드는 CSRF(Cross-Site Request Forgery) 공격에 취약하다.

**방어 방법**

```javascript
// CSRF 토큰 사용
<form method="POST" action="/api/users">
  <input type="hidden" name="csrf_token" value="random_token_value">
</form>

// SameSite 쿠키 설정
Set-Cookie: session=abc123; SameSite=Strict; Secure; HttpOnly

// 커스텀 헤더 검증
if (!request.headers['X-Requested-With']) {
  return 403; // AJAX 요청만 허용
}
```

### TRACE 메서드 비활성화

TRACE는 XST 공격에 취약하므로 프로덕션에서 반드시 비활성화해야 한다.

### 인증 및 권한 검증

상태 변경 메서드(POST, PUT, PATCH, DELETE)는 항상 인증과 권한을 검증해야 한다.

```javascript
app.delete('/users/:id',
  authenticateToken,  // 인증 확인
  authorizeUser,      // 권한 확인
  (req, res) => {
    // 삭제 로직
  }
);
```

### 입력 검증 및 제한

- 요청 본문 크기 제한 (DoS 방지)
- 입력 데이터 유효성 검증
- SQL 인젝션, XSS 방지

## 결론

HTTP 메서드는 웹에서 클라이언트와 서버 간 통신을 정의하는 핵심 요소로, 1991년 GET 메서드만 존재하던 HTTP/0.9에서 시작하여 HTTP/1.1에서 9가지 표준 메서드가 정립되었다. 각 메서드는 안전성과 멱등성이라는 중요한 특성을 가지며, 이 특성은 캐싱, 재시도 정책, API 설계에 직접적인 영향을 미친다.

RESTful API 설계에서 HTTP 메서드의 의미론을 올바르게 활용하면 일관성 있고 직관적인 API를 만들 수 있으며, CORS를 이해하고 보안 고려사항(CSRF 방지, TRACE 비활성화, 인증/권한 검증)을 적용하면 안전하고 확장 가능한 웹 서비스를 구축할 수 있다.

## 참고 자료

- [RFC 7231 - HTTP/1.1 Semantics and Content](https://tools.ietf.org/html/rfc7231)
- [RFC 6902 - JSON Patch](https://tools.ietf.org/html/rfc6902)
- [RFC 7396 - JSON Merge Patch](https://tools.ietf.org/html/rfc7396)
- [MDN Web Docs - HTTP Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
- [REST API Tutorial](https://restfulapi.net/)
