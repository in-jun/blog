---
title: "HTTP 상태 코드 완벽 가이드: 1xx부터 5xx까지 모든 코드 이해하기"
date: 2024-06-05T09:38:59+09:00
tags: ["HTTP", "상태 코드", "REST API", "웹 개발", "네트워크"]
draft: false
description: "HTTP 상태 코드의 역사부터 RESTful API 설계까지, 1xx 정보 응답부터 5xx 서버 에러까지 모든 상태 코드를 실용적인 예제와 함께 상세히 다루며, 418 I'm a teapot 같은 특이한 코드와 브라우저 동작 방식까지 포괄적으로 설명한다."
---

HTTP 상태 코드(HTTP Status Code)는 클라이언트가 서버에 요청을 보낸 후 서버가 해당 요청의 처리 결과를 알려주기 위해 반환하는 세 자리 숫자로 구성된 표준화된 응답 코드이며, 이 코드는 웹 브라우저, API 클라이언트, 검색 엔진 등 모든 HTTP 기반 통신에서 요청의 성공 여부, 리다이렉션 필요성, 클라이언트나 서버 측 오류 발생 여부를 명확하게 전달하는 핵심적인 역할을 수행하고, RESTful API 설계에서 적절한 상태 코드의 선택은 API의 직관성과 개발자 경험을 크게 좌우하는 중요한 요소이다.

> **HTTP 상태 코드란?**
>
> HTTP 상태 코드는 클라이언트의 요청에 대한 서버의 응답 상태를 나타내는 세 자리 숫자 코드로, 첫 번째 숫자가 응답의 카테고리를 결정하며, 1xx(정보), 2xx(성공), 3xx(리다이렉션), 4xx(클라이언트 에러), 5xx(서버 에러)의 다섯 가지 범주로 분류된다.

## HTTP 상태 코드의 역사와 발전

HTTP 상태 코드는 웹의 발전과 함께 진화해왔으며, 초기의 단순한 형태에서 현대의 복잡한 웹 애플리케이션 요구사항을 충족하는 정교한 시스템으로 발전했다.

### HTTP/0.9 시대 (1991년)

Tim Berners-Lee가 CERN에서 개발한 최초의 HTTP 버전인 0.9는 상태 코드라는 개념 자체가 존재하지 않았으며, GET 메서드만 지원하고 HTML 문서를 반환하거나 연결을 종료하는 것이 전부였기 때문에 에러 처리나 응답 상태를 표현할 방법이 없었다. 이 시기의 HTTP는 단순히 하이퍼텍스트 문서를 전송하기 위한 프로토콜로, 현대 웹에서 필수적인 메타데이터나 헤더 정보도 포함하지 않았다.

### HTTP/1.0의 등장 (1996년, RFC 1945)

HTTP/1.0은 상태 코드를 처음으로 도입한 버전으로, 16개의 기본 상태 코드가 정의되어 성공(2xx), 리다이렉션(3xx), 클라이언트 에러(4xx), 서버 에러(5xx)의 카테고리 체계가 확립되었으며, 200 OK, 301 Moved Permanently, 404 Not Found, 500 Internal Server Error와 같은 가장 기본적이고 널리 사용되는 코드들이 이때 탄생했다. 이 버전에서 요청과 응답에 헤더가 추가되어 Content-Type, Content-Length 등의 메타데이터를 전달할 수 있게 되었고, POST 메서드도 도입되어 데이터 전송이 가능해졌다.

### HTTP/1.1의 확장 (1999년, RFC 2616)

HTTP/1.1은 상태 코드를 40개 이상으로 대폭 확장하여 더욱 세밀한 상태 표현이 가능해졌는데, 100 Continue를 통한 대용량 요청의 사전 확인, 206 Partial Content를 통한 범위 요청 지원, 409 Conflict를 통한 리소스 충돌 감지, 410 Gone을 통한 영구 삭제 표시 등 실무에서 필요한 다양한 시나리오를 처리할 수 있게 되었다. 또한 정보성 응답인 1xx 카테고리가 공식적으로 추가되었고, 지속 연결(Keep-Alive)과 파이프라이닝이 도입되어 성능이 크게 향상되었으며, Host 헤더가 필수가 되어 하나의 IP 주소에서 여러 도메인을 호스팅할 수 있게 되었다.

### 현대 표준의 정립 (2014년, RFC 7231)

HTTP/1.1 명세가 RFC 2616에서 RFC 7230-7235의 여러 문서로 분리되면서 RFC 7231이 상태 코드의 현대 표준으로 자리잡았으며, 기존 코드들의 의미가 더욱 명확하게 정의되었고, 308 Permanent Redirect(메서드를 유지하는 영구 리다이렉션)와 426 Upgrade Required(프로토콜 업그레이드 필요) 등의 새로운 코드가 추가되어 HTTPS 전환, WebSocket 업그레이드 등 현대 웹의 요구사항을 충족하게 되었다.

### HTTP/2와 HTTP/3 시대

HTTP/2(2015년, RFC 7540)와 HTTP/3(2022년, RFC 9114)는 전송 계층의 효율성을 크게 개선했지만 상태 코드 체계 자체는 변경하지 않았으며, 대신 103 Early Hints(RFC 8297, 2017년)와 같은 성능 최적화를 위한 새로운 코드가 추가되어 서버가 최종 응답을 준비하는 동안 클라이언트가 필요한 리소스를 미리 로드할 수 있게 되었다.

## 1xx (Informational): 정보성 응답

1xx 상태 코드는 요청이 수신되었고 서버가 처리를 계속하고 있음을 나타내는 중간 응답으로, 최종 응답이 아니며 실제 응답 전에 전송되어 클라이언트에게 진행 상황을 알려주는 역할을 한다.

> **1xx 응답의 특징**
>
> 1xx 응답은 일반적인 HTTP 클라이언트 라이브러리에서 자동으로 처리되어 애플리케이션 코드에서 직접 다룰 일이 드물지만, 대용량 파일 업로드나 성능 최적화 시나리오에서 중요한 역할을 수행한다.

### 주요 1xx 상태 코드

| 코드 | 이름 | 설명 | 실제 사용 |
|------|------|------|----------|
| 100 | Continue | 클라이언트가 요청 본문을 계속 전송해도 됨 | 대용량 파일 업로드 전 서버 승인 확인 |
| 101 | Switching Protocols | 서버가 프로토콜 변경 요청을 수락 | WebSocket 업그레이드, HTTP/2 전환 |
| 102 | Processing | 서버가 요청을 수신하고 처리 중 | WebDAV 환경의 장시간 작업 |
| 103 | Early Hints | 최종 응답 전 리소스 힌트 제공 | CSS/JS 프리로드로 성능 최적화 |

### 100 Continue의 작동 원리

대용량 파일 업로드 시 클라이언트가 `Expect: 100-continue` 헤더와 함께 요청을 보내면 서버는 요청 헤더만 먼저 검사하여 요청을 처리할 수 있는지 판단한 후, 처리 가능하면 100 Continue 응답을 보내 클라이언트가 본문을 전송하도록 하고, 그렇지 않으면 4xx나 5xx 에러를 즉시 반환하여 불필요한 대용량 데이터 전송을 방지한다.

```http
POST /upload HTTP/1.1
Host: api.example.com
Content-Type: multipart/form-data
Content-Length: 104857600
Expect: 100-continue

(서버의 100 Continue 응답을 기다림)

HTTP/1.1 100 Continue

(파일 본문 전송 시작)
```

### 103 Early Hints의 성능 최적화

103 Early Hints는 서버가 최종 응답을 생성하는 동안(데이터베이스 쿼리, 템플릿 렌더링 등) 브라우저가 CSS, JavaScript, 폰트 등 중요한 리소스를 미리 다운로드할 수 있게 하여 페이지 로딩 속도를 20-30% 개선할 수 있으며, HTTP/2 이상에서 더욱 효과적으로 작동한다.

```http
HTTP/1.1 103 Early Hints
Link: </styles/main.css>; rel=preload; as=style
Link: </scripts/app.js>; rel=preload; as=script
Link: </fonts/roboto.woff2>; rel=preload; as=font

(서버가 응답 준비 중...)

HTTP/1.1 200 OK
Content-Type: text/html
...
```

## 2xx (Successful): 성공 응답

2xx 상태 코드는 클라이언트의 요청이 성공적으로 수신되고 이해되었으며 수락되었음을 나타내는 응답으로, RESTful API에서 가장 중요한 카테고리이며 각 상황에 맞는 적절한 코드 선택이 API의 직관성과 일관성을 결정한다.

> **2xx 응답 선택의 중요성**
>
> 모든 성공 응답에 200 OK만 사용하는 것은 API 설계의 나쁜 관행이며, 201 Created(리소스 생성), 204 No Content(본문 없음), 202 Accepted(비동기 처리) 등 상황에 맞는 적절한 코드를 선택해야 클라이언트가 응답을 올바르게 해석할 수 있다.

### 주요 2xx 상태 코드

| 코드 | 이름 | 설명 | RESTful API 사용 |
|------|------|------|-----------------|
| 200 | OK | 요청 성공, 응답 본문에 결과 포함 | GET으로 리소스 조회, PUT/PATCH 업데이트 후 결과 반환 |
| 201 | Created | 새 리소스 생성 성공 | POST로 리소스 생성 (Location 헤더 필수) |
| 202 | Accepted | 요청 수락, 처리는 완료되지 않음 | 비동기 작업 시작 (이메일 발송, 대용량 처리) |
| 204 | No Content | 요청 성공, 응답 본문 없음 | DELETE 성공, PUT 업데이트만 수행 |
| 206 | Partial Content | 부분 콘텐츠 반환 | Range 요청으로 파일 일부 다운로드 |

### 200 OK vs 201 Created vs 204 No Content

**200 OK**는 가장 일반적인 성공 응답으로, GET 요청으로 리소스를 조회하거나 PUT/PATCH로 업데이트 후 변경된 리소스를 응답 본문에 포함하여 반환할 때 사용한다.

```http
GET /api/users/123 HTTP/1.1

HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com"
}
```

**201 Created**는 POST 요청으로 새 리소스가 생성되었을 때 사용하며, 반드시 `Location` 헤더에 생성된 리소스의 URI를 포함해야 하고, 선택적으로 응답 본문에 생성된 리소스를 포함할 수 있다.

```http
POST /api/users HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": "hong@example.com"}

HTTP/1.1 201 Created
Location: /api/users/123
Content-Type: application/json

{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com",
  "created_at": "2024-06-05T09:38:59Z"
}
```

**204 No Content**는 요청은 성공했지만 응답 본문이 없을 때 사용하며, DELETE 성공 후 본문이 불필요하거나 PUT으로 업데이트만 수행하고 결과를 반환할 필요가 없을 때 적합하다.

```http
DELETE /api/users/123 HTTP/1.1

HTTP/1.1 204 No Content
```

### 202 Accepted의 비동기 처리 패턴

202 Accepted는 요청이 수락되었지만 처리가 완료되지 않았을 때 사용하며, 이메일 발송, 대용량 파일 처리, 외부 시스템 연동 등 시간이 오래 걸리는 비동기 작업에 적합하다.

```http
POST /api/reports/generate HTTP/1.1
Content-Type: application/json

{"type": "annual", "year": 2024}

HTTP/1.1 202 Accepted
Content-Type: application/json

{
  "job_id": "job_abc123",
  "status": "processing",
  "estimated_completion": "2024-06-05T10:00:00Z",
  "status_url": "/api/jobs/job_abc123"
}
```

### 모든 2xx 상태 코드 목록

- **200 OK**: 요청이 성공적으로 처리됨
- **201 Created**: 새로운 리소스가 생성됨
- **202 Accepted**: 요청이 수락되었으나 처리가 완료되지 않음
- **203 Non-Authoritative Information**: 응답이 원본 서버가 아닌 프록시에서 제공됨
- **204 No Content**: 요청 성공, 응답 본문 없음
- **205 Reset Content**: 요청 성공, 클라이언트가 문서 뷰를 재설정해야 함
- **206 Partial Content**: Range 요청에 대한 부분 응답
- **207 Multi-Status**: WebDAV에서 여러 리소스에 대한 상태 반환
- **208 Already Reported**: WebDAV에서 이미 보고된 바인딩 멤버
- **226 IM Used**: Delta encoding을 사용한 GET 요청 응답

## 3xx (Redirection): 리다이렉션 응답

3xx 상태 코드는 클라이언트가 요청을 완료하기 위해 추가 작업이 필요함을 나타내며, 주로 URL 변경, 캐싱 검증, 리소스 이동 시 사용되어 사용자를 올바른 위치로 안내하거나 네트워크 효율성을 개선하는 역할을 한다.

> **리다이렉션의 종류**
>
> 리다이렉션은 크게 영구 리다이렉션(301, 308)과 임시 리다이렉션(302, 303, 307)으로 나뉘며, 영구 리다이렉션은 검색 엔진이 새 URL을 색인하고 SEO 점수를 이전하는 반면, 임시 리다이렉션은 원래 URL을 유지한다.

### 리다이렉션 코드 비교

| 코드 | 유형 | HTTP 메서드 | 캐싱 | 사용 사례 |
|------|------|-------------|------|----------|
| 301 | 영구 | 변경 가능 (POST→GET) | 브라우저 캐싱 | 도메인 변경, HTTP→HTTPS 전환 |
| 302 | 임시 | 변경 가능 (POST→GET) | 캐싱 안 됨 | 로그인 후 원래 페이지로 이동 |
| 303 | 임시 | 항상 GET으로 변경 | 캐싱 안 됨 | POST 후 결과 페이지로 이동 |
| 307 | 임시 | 유지 (POST는 POST) | 캐싱 안 됨 | 유지보수 페이지, POST 리다이렉트 |
| 308 | 영구 | 유지 (POST는 POST) | 브라우저 캐싱 | RESTful API 엔드포인트 영구 변경 |

### 301 vs 308: 메서드 보존의 차이

**301 Moved Permanently**는 URL이 영구적으로 변경되었음을 나타내지만, 일부 클라이언트가 POST 요청을 GET으로 변환하는 문제가 있어 HTTP/1.0 시절의 동작을 유지하는 반면, **308 Permanent Redirect**는 HTTP 메서드를 반드시 유지하므로 POST 요청이 POST로 리다이렉트되어야 할 때 사용한다.

```http
# 301: HTTP → HTTPS 영구 전환 (메서드 변경 가능)
GET http://example.com/page HTTP/1.1

HTTP/1.1 301 Moved Permanently
Location: https://example.com/page

# 308: API 엔드포인트 변경 (메서드 유지 필수)
POST /api/v1/users HTTP/1.1

HTTP/1.1 308 Permanent Redirect
Location: /api/v2/users
```

### 302 vs 303 vs 307: 임시 리다이렉션의 선택

**302 Found**는 가장 오래된 임시 리다이렉션 코드로 널리 사용되지만 메서드 변환 동작이 명확하지 않아 **303 See Other**(항상 GET으로 변환)와 **307 Temporary Redirect**(메서드 유지)가 HTTP/1.1에서 추가되었으며, 새로운 API에서는 용도에 따라 303 또는 307을 사용하는 것이 권장된다.

```http
# 303: POST 후 결과 페이지로 이동 (GET으로 변환)
POST /api/orders HTTP/1.1
Content-Type: application/json

{"product_id": 123, "quantity": 2}

HTTP/1.1 303 See Other
Location: /orders/456/confirmation

# 307: 임시 유지보수 중 요청 재전송 (메서드 유지)
POST /api/payments HTTP/1.1

HTTP/1.1 307 Temporary Redirect
Location: /api/payments-backup
```

### 304 Not Modified와 캐싱

304 Not Modified는 리소스가 마지막 요청 이후 수정되지 않았음을 나타내며, 클라이언트가 캐시된 버전을 그대로 사용할 수 있어 대역폭을 절약하고 응답 시간을 단축한다.

```http
# 첫 번째 요청
GET /api/users/123 HTTP/1.1

HTTP/1.1 200 OK
ETag: "abc123"
Last-Modified: Sat, 01 Jun 2024 10:00:00 GMT
Content-Type: application/json

{"id": 123, "name": "홍길동"}

# 두 번째 요청 (조건부)
GET /api/users/123 HTTP/1.1
If-None-Match: "abc123"
If-Modified-Since: Sat, 01 Jun 2024 10:00:00 GMT

HTTP/1.1 304 Not Modified
ETag: "abc123"
```

### 모든 3xx 상태 코드 목록

- **300 Multiple Choices**: 요청에 대해 여러 옵션이 존재함
- **301 Moved Permanently**: 리소스가 영구적으로 새 URL로 이동함
- **302 Found**: 리소스가 임시로 다른 URL에 위치함
- **303 See Other**: 다른 URL에서 GET으로 리소스를 조회해야 함
- **304 Not Modified**: 리소스가 수정되지 않음 (캐시 사용)
- **305 Use Proxy**: 프록시를 통해 접근해야 함 (보안 문제로 비권장)
- **306 (Unused)**: 더 이상 사용되지 않음
- **307 Temporary Redirect**: 임시 리다이렉트 (메서드 유지)
- **308 Permanent Redirect**: 영구 리다이렉트 (메서드 유지)

## 4xx (Client Error): 클라이언트 에러 응답

4xx 상태 코드는 클라이언트의 요청에 문제가 있음을 나타내며, 잘못된 구문, 인증 실패, 권한 부족, 존재하지 않는 리소스 접근 등 클라이언트가 요청을 수정하지 않으면 같은 에러가 반복되는 상황에서 사용된다.

> **클라이언트 에러 처리의 핵심**
>
> 4xx 에러는 클라이언트에게 무엇이 잘못되었는지 명확하게 알려주어야 하며, 에러 응답 본문에 상세한 에러 코드, 메시지, 해결 방법을 포함하여 개발자가 문제를 빠르게 파악하고 수정할 수 있도록 해야 한다.

### 가장 중요한 4xx 상태 코드

| 코드 | 이름 | 원인 | 해결 방법 |
|------|------|------|----------|
| 400 | Bad Request | 잘못된 구문, 유효하지 않은 데이터 | 요청 형식과 데이터 검증 |
| 401 | Unauthorized | 인증 필요 또는 인증 실패 | 유효한 인증 정보 제공 |
| 403 | Forbidden | 인증됨, 권한 부족 | 적절한 권한 획득 |
| 404 | Not Found | 리소스 존재하지 않음 | URL 확인 또는 리소스 생성 |
| 409 | Conflict | 리소스 충돌 | 최신 상태 확인 후 재시도 |
| 422 | Unprocessable Entity | 구문 올바름, 의미 오류 | 비즈니스 로직 검증 |
| 429 | Too Many Requests | 요청 제한 초과 | Retry-After 후 재시도 |

### 400 Bad Request vs 422 Unprocessable Entity

**400 Bad Request**는 요청의 구문이 잘못되었을 때(잘못된 JSON 형식, 필수 필드 누락, 잘못된 데이터 타입) 사용하며, **422 Unprocessable Entity**는 구문은 올바르지만 의미적으로 처리할 수 없을 때(비즈니스 로직 위반, 유효성 검증 실패) 사용한다.

```http
# 400: JSON 구문 오류
POST /api/users HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": }  # 잘못된 JSON

HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "INVALID_JSON",
  "message": "Request body is not valid JSON"
}

# 422: 구문은 올바르나 비즈니스 규칙 위반
POST /api/users HTTP/1.1
Content-Type: application/json

{"name": "홍길동", "email": "invalid-email", "age": -5}

HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json

{
  "error": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "details": [
    {"field": "email", "message": "Invalid email format"},
    {"field": "age", "message": "Must be a positive integer"}
  ]
}
```

### 401 Unauthorized vs 403 Forbidden

**401 Unauthorized**는 인증이 필요하거나 제공된 인증 정보가 유효하지 않을 때 사용하며 `WWW-Authenticate` 헤더를 포함해야 하는 반면, **403 Forbidden**은 인증은 되었지만 해당 리소스에 접근할 권한이 없을 때 사용한다.

```http
# 401: 인증 필요 (로그인하지 않은 사용자)
GET /api/profile HTTP/1.1

HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="api"
Content-Type: application/json

{
  "error": "AUTHENTICATION_REQUIRED",
  "message": "Please provide a valid access token"
}

# 403: 인증됨, 권한 부족 (일반 사용자가 관리자 기능 접근)
DELETE /api/admin/users/456 HTTP/1.1
Authorization: Bearer user_token_123

HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "error": "INSUFFICIENT_PERMISSIONS",
  "message": "Admin role required for this operation"
}
```

### 404 Not Found의 보안적 고려

404 Not Found는 리소스가 존재하지 않을 때 사용하지만, 보안적으로 민감한 경우 403 대신 404를 반환하여 리소스의 존재 여부를 숨길 수 있다. 예를 들어, 다른 사용자의 비공개 리소스에 접근할 때 403을 반환하면 해당 리소스가 존재한다는 정보가 노출되므로 404를 반환하는 것이 더 안전할 수 있다.

```http
# 보안적 404: 리소스 존재 여부 숨김
GET /api/users/999/private-data HTTP/1.1
Authorization: Bearer other_user_token

HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "RESOURCE_NOT_FOUND",
  "message": "The requested resource was not found"
}
```

### 409 Conflict와 낙관적 잠금

409 Conflict는 리소스의 현재 상태와 충돌이 발생했을 때 사용하며, 버전 충돌(낙관적 잠금 실패), 중복 리소스 생성 시도, 삭제된 리소스 수정 시도 등의 상황에서 반환한다.

```http
# 낙관적 잠금 충돌
PUT /api/documents/123 HTTP/1.1
Content-Type: application/json
If-Match: "version_5"

{"title": "Updated Title", "content": "..."}

HTTP/1.1 409 Conflict
Content-Type: application/json

{
  "error": "VERSION_CONFLICT",
  "message": "Document was modified by another user",
  "current_version": "version_7",
  "your_version": "version_5"
}
```

### 429 Too Many Requests와 Rate Limiting

429 Too Many Requests는 클라이언트가 일정 시간 내에 너무 많은 요청을 보냈을 때 사용하며, `Retry-After` 헤더로 재시도 가능 시점을 알려주고, `X-RateLimit-*` 헤더로 제한 정보를 제공해야 한다.

```http
GET /api/search?q=example HTTP/1.1
Authorization: Bearer token_123

HTTP/1.1 429 Too Many Requests
Retry-After: 60
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1717581600
Content-Type: application/json

{
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "API rate limit exceeded. Please retry after 60 seconds.",
  "limit": 100,
  "reset_at": "2024-06-05T10:00:00Z"
}
```

### 모든 4xx 상태 코드 목록

- **400 Bad Request**: 잘못된 요청 구문
- **401 Unauthorized**: 인증 필요
- **402 Payment Required**: 결제 필요 (향후 사용을 위해 예약됨)
- **403 Forbidden**: 접근 권한 없음
- **404 Not Found**: 리소스 없음
- **405 Method Not Allowed**: 허용되지 않는 HTTP 메서드
- **406 Not Acceptable**: 클라이언트가 수용 불가능한 콘텐츠 타입
- **407 Proxy Authentication Required**: 프록시 인증 필요
- **408 Request Timeout**: 요청 시간 초과
- **409 Conflict**: 리소스 충돌
- **410 Gone**: 리소스가 영구적으로 삭제됨
- **411 Length Required**: Content-Length 헤더 필요
- **412 Precondition Failed**: 조건부 요청의 전제 조건 실패
- **413 Payload Too Large**: 요청 본문이 너무 큼
- **414 URI Too Long**: URI가 너무 김
- **415 Unsupported Media Type**: 지원하지 않는 미디어 타입
- **416 Range Not Satisfiable**: 요청한 범위를 충족할 수 없음
- **417 Expectation Failed**: Expect 헤더 조건 실패
- **418 I'm a teapot**: HTCPCP 만우절 농담 코드
- **421 Misdirected Request**: 잘못된 서버로 요청됨
- **422 Unprocessable Entity**: 의미적 오류로 처리 불가
- **423 Locked**: WebDAV 리소스 잠김
- **424 Failed Dependency**: WebDAV 의존성 실패
- **425 Too Early**: TLS Early Data 재생 공격 방지
- **426 Upgrade Required**: 프로토콜 업그레이드 필요
- **428 Precondition Required**: 조건부 요청 필요
- **429 Too Many Requests**: 요청 제한 초과
- **431 Request Header Fields Too Large**: 헤더 필드가 너무 큼
- **451 Unavailable For Legal Reasons**: 법적 이유로 이용 불가

## 5xx (Server Error): 서버 에러 응답

5xx 상태 코드는 서버가 유효한 요청을 처리하지 못했음을 나타내며, 클라이언트에게는 책임이 없고 서버 측에서 문제를 해결해야 하는 상황으로, 즉각적인 모니터링과 대응이 필요한 심각한 상황이다.

> **5xx 에러 처리의 원칙**
>
> 5xx 에러는 내부 구현 세부사항(스택 트레이스, 데이터베이스 연결 정보 등)을 클라이언트에게 노출하지 않아야 하며, 대신 고유한 에러 ID를 제공하여 서버 로그에서 상세 정보를 추적할 수 있게 해야 한다.

### 주요 5xx 상태 코드

| 코드 | 이름 | 원인 | 해결 방법 |
|------|------|------|----------|
| 500 | Internal Server Error | 처리되지 않은 예외, 버그 | 에러 로깅 및 버그 수정 |
| 502 | Bad Gateway | 업스트림 서버 응답 오류 | 업스트림 서버 상태 확인 |
| 503 | Service Unavailable | 서버 과부하, 유지보수 | 용량 증설, 유지보수 완료 대기 |
| 504 | Gateway Timeout | 업스트림 서버 응답 시간 초과 | 타임아웃 설정 조정, 쿼리 최적화 |

### 500 Internal Server Error

500 Internal Server Error는 서버에서 예상하지 못한 오류가 발생했을 때 사용하는 가장 일반적인 서버 에러로, 처리되지 않은 예외, 데이터베이스 연결 실패, 코드 버그 등이 원인이다.

```http
GET /api/users/123 HTTP/1.1

HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "error": "INTERNAL_ERROR",
  "message": "An unexpected error occurred. Please try again later.",
  "error_id": "err_20240605_abc123",
  "timestamp": "2024-06-05T09:38:59Z"
}
```

### 502 Bad Gateway vs 503 Service Unavailable vs 504 Gateway Timeout

**502 Bad Gateway**는 게이트웨이나 프록시 서버가 업스트림 서버로부터 유효하지 않은 응답을 받았을 때 발생하며, Nginx가 백엔드 애플리케이션 서버와 통신할 수 없는 상황이 대표적이다. **503 Service Unavailable**은 서버가 일시적으로 요청을 처리할 수 없을 때(과부하, 유지보수, 배포 중) 사용하며 `Retry-After` 헤더로 재시도 시점을 알려주어야 한다. **504 Gateway Timeout**은 게이트웨이가 업스트림 서버로부터 제시간에 응답을 받지 못했을 때 발생한다.

```http
# 502: 업스트림 서버 연결 실패
HTTP/1.1 502 Bad Gateway
Content-Type: application/json

{
  "error": "UPSTREAM_ERROR",
  "message": "Failed to connect to upstream server"
}

# 503: 유지보수 중
HTTP/1.1 503 Service Unavailable
Retry-After: 3600
Content-Type: application/json

{
  "error": "SERVICE_UNAVAILABLE",
  "message": "Server is under maintenance. Expected completion: 2024-06-05T10:00:00Z"
}

# 504: 업스트림 응답 시간 초과
HTTP/1.1 504 Gateway Timeout
Content-Type: application/json

{
  "error": "GATEWAY_TIMEOUT",
  "message": "Upstream server did not respond in time"
}
```

### 모든 5xx 상태 코드 목록

- **500 Internal Server Error**: 서버 내부 오류
- **501 Not Implemented**: 요청된 기능이 구현되지 않음
- **502 Bad Gateway**: 게이트웨이/프록시가 잘못된 응답 수신
- **503 Service Unavailable**: 서비스 일시적 불가
- **504 Gateway Timeout**: 게이트웨이/프록시 응답 시간 초과
- **505 HTTP Version Not Supported**: HTTP 버전 미지원
- **506 Variant Also Negotiates**: 콘텐츠 협상 순환 참조
- **507 Insufficient Storage**: WebDAV 저장 공간 부족
- **508 Loop Detected**: WebDAV 무한 루프 감지
- **510 Not Extended**: 요청 처리에 추가 확장 필요
- **511 Network Authentication Required**: 네트워크 인증 필요 (캡티브 포털)

## 특이하고 흥미로운 상태 코드

### 418 I'm a teapot

418 I'm a teapot은 1998년 4월 1일 만우절에 RFC 2324로 정의된 HTCPCP(Hyper Text Coffee Pot Control Protocol)의 일부로, 티포트가 커피를 만들 수 없음을 나타내는 농담 코드이지만 많은 웹 프레임워크(Express, Spring, Django 등)에서 실제로 구현되어 있으며, Google이 2014년 만우절에 사용하는 등 개발자 문화의 일부로 자리잡았다.

### 451 Unavailable For Legal Reasons

451은 Ray Bradbury의 소설 "화씨 451(Fahrenheit 451)"에서 영감을 받은 코드로, 2015년 RFC 7725로 공식 추가되어 법적 이유(저작권 침해, 정부 검열, GDPR 삭제 요청 등)로 콘텐츠를 제공할 수 없을 때 사용된다.

### 425 Too Early

425 Too Early는 RFC 8470으로 2018년에 추가된 코드로, TLS 1.3의 0-RTT(zero round-trip time) 기능 사용 시 발생할 수 있는 재생 공격(replay attack)을 방지하기 위해 서버가 안전하지 않다고 판단되는 Early Data 요청을 거부할 때 사용한다.

## RESTful API 상태 코드 설계 가이드

### CRUD 작업별 권장 상태 코드

| 작업 | HTTP 메서드 | 성공 | 리소스 없음 | 에러 |
|------|-------------|------|-------------|------|
| 생성 | POST | 201 Created + Location | - | 400, 409, 422 |
| 조회 (단일) | GET | 200 OK | 404 Not Found | 403 |
| 조회 (목록) | GET | 200 OK (빈 배열 가능) | - | - |
| 전체 수정 | PUT | 200 OK, 204 No Content | 404 Not Found | 400, 409, 422 |
| 부분 수정 | PATCH | 200 OK, 204 No Content | 404 Not Found | 400, 409, 422 |
| 삭제 | DELETE | 204 No Content | 404 (선택적) | 403 |

### 일관된 에러 응답 구조

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Invalid email format"
      }
    ],
    "timestamp": "2024-06-05T09:38:59Z",
    "path": "/api/users",
    "request_id": "req_abc123"
  }
}
```

## 브라우저 동작과 상태 코드

### 자동 리다이렉션

브라우저는 3xx 상태 코드를 받으면 자동으로 `Location` 헤더의 URL로 이동하며, 사용자는 이 과정을 인식하지 못한다. 301과 308은 브라우저가 영구적으로 캐싱하여 다음 요청 시 원래 URL에 요청하지 않고 바로 새 URL로 이동한다.

### 인증 팝업

401 상태 코드와 `WWW-Authenticate: Basic realm="..."` 헤더를 받으면 브라우저는 자동으로 인증 다이얼로그를 표시하지만, 현대 웹 애플리케이션에서는 폼 기반 인증이나 OAuth를 선호하여 이 동작을 활용하는 경우가 드물다.

### 캐싱 동작

- **200 OK**: `Cache-Control`, `ETag`, `Last-Modified` 헤더에 따라 캐싱
- **301 Moved Permanently**: 브라우저가 영구적으로 새 URL을 기억
- **304 Not Modified**: 서버가 캐시된 버전 사용을 확인, 본문 전송 없음

## 모니터링과 에러 처리 전략

### 상태 코드 비율 모니터링

- **2xx 비율**: 95% 이상 유지 목표
- **4xx 비율**: 갑작스런 증가는 API 변경이나 클라이언트 버그 신호
- **5xx 비율**: 1% 미만 유지, 초과 시 즉시 알림 및 조사
- **429 발생률**: Rate limit 설정의 적절성 검토

### 에러 로깅 전략

```json
{
  "timestamp": "2024-06-05T09:38:59Z",
  "level": "ERROR",
  "status_code": 500,
  "error_type": "DatabaseConnectionError",
  "message": "Failed to connect to database",
  "stack_trace": "...",
  "request": {
    "method": "POST",
    "path": "/api/users",
    "user_id": "user_123",
    "ip": "192.168.1.100",
    "request_id": "req_abc123"
  }
}
```

## 결론

HTTP 상태 코드는 클라이언트와 서버 간 통신의 핵심 요소로, 1991년 HTTP/0.9의 상태 코드 없는 단순한 형태에서 현재의 정교한 시스템으로 발전해왔으며, 올바른 상태 코드의 선택은 API의 직관성, 디버깅 용이성, 사용자 경험에 직접적인 영향을 미친다. RESTful API 설계 시 각 상황에 맞는 적절한 상태 코드를 선택하고, 일관된 에러 응답 구조를 제공하며, 효과적인 모니터링을 통해 문제를 조기에 발견하고 대응하는 것이 중요하다.

## 참고 자료

- [MDN Web Docs - HTTP 상태 코드](https://developer.mozilla.org/ko/docs/Web/HTTP/Status)
- [RFC 7231 - Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content](https://datatracker.ietf.org/doc/html/rfc7231)
- [RFC 2324 - Hyper Text Coffee Pot Control Protocol (HTCPCP/1.0)](https://datatracker.ietf.org/doc/html/rfc2324)
- [RFC 7725 - An HTTP Status Code to Report Legal Obstacles](https://datatracker.ietf.org/doc/html/rfc7725)
