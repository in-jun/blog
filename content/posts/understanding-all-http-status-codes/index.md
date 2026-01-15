---
title: "모든 http 상태코드 알아보기"
date: 2024-06-05T09:38:59+09:00
tags: ["http", "status code"]
draft: false
description: "HTTP 상태 코드의 역사부터 RESTful API 설계까지, 1xx부터 5xx까지 모든 상태 코드를 실용적인 예제와 함께 상세히 알아본다. 일반적인 코드부터 418 I'm a teapot 같은 특이한 코드까지 포괄적으로 다룬다."
---

## 개요

HTTP 상태 코드는 클라이언트의 요청에 대한 서버의 응답 상태를 나타내는 세 자리 숫자 코드다. 웹 개발에서 적절한 상태 코드를 사용하는 것은 API 설계, 에러 처리, 사용자 경험 개선에 필수적이며, RESTful API의 핵심 구성 요소다.

이 가이드에서는 HTTP 상태 코드의 역사와 진화, 다섯 가지 카테고리(1xx-5xx)의 상세한 설명, 실무에서 자주 사용되는 코드들의 실용적인 사용 사례, RESTful API 설계 패턴, 그리고 브라우저와 서버의 동작 방식까지 포괄적으로 다룬다.

## HTTP 상태 코드의 역사

HTTP 상태 코드는 웹의 발전과 함께 진화해왔으며, 각 버전마다 새로운 요구사항을 반영했다.

### HTTP/0.9 (1991년)

최초의 HTTP 버전인 0.9에는 상태 코드가 존재하지 않았다. 단순히 HTML 문서를 반환하거나 연결을 종료하는 것이 전부였으며, 에러 처리나 응답 상태를 표현할 방법이 없었다.

### HTTP/1.0 (1996년, RFC 1945)

HTTP/1.0에서 처음으로 상태 코드가 도입되었다. 16개의 기본 상태 코드가 정의되었으며, 성공(2xx), 리다이렉션(3xx), 클라이언트 에러(4xx), 서버 에러(5xx)의 개념이 확립되었다. 200 OK, 404 Not Found, 500 Internal Server Error와 같은 기본적인 코드들이 이때 만들어졌다.

### HTTP/1.1 (1999년, RFC 2616)

HTTP/1.1은 상태 코드를 40개 이상으로 확장했다. 100 Continue, 206 Partial Content, 409 Conflict, 410 Gone 등 더욱 세밀한 상태 표현이 가능해졌다. 이 버전에서 정보성 응답(1xx)이 공식적으로 추가되었으며, 캐싱과 관련된 304 Not Modified가 중요해졌다.

### RFC 7231 (2014년)

HTTP/1.1 명세가 여러 RFC로 분리되면서 RFC 7231이 상태 코드의 현대 표준이 되었다. 기존 코드들의 의미가 더욱 명확해졌고, 308 Permanent Redirect, 426 Upgrade Required 등이 추가되었다.

### 특별한 코드: 418 I'm a teapot

1998년 4월 1일, RFC 2324로 정의된 HTCPCP(Hyper Text Coffee Pot Control Protocol)의 일부로 418 I'm a teapot이 만들어졌다. 만우절 농담으로 시작된 이 코드는 커피포트가 차를 만들 수 없음을 나타내며, 실제로는 사용되지 않지만 많은 프레임워크와 서버에서 이스터 에그로 구현되어 있다.

## 상태 코드 카테고리별 상세 설명

### 1xx (Informational): 정보성 응답

1xx 상태 코드는 요청이 수신되었고 서버가 처리를 계속하고 있음을 나타낸다. 이 코드들은 최종 응답이 아니며, 실제 응답 전에 전송되는 중간 메시지다.

**실제 사용 사례:**

-   **100 Continue**: 대용량 파일 업로드 시, 클라이언트가 `Expect: 100-continue` 헤더를 보내면 서버가 100 응답으로 승인한 후 본문을 전송한다. 이를 통해 서버가 요청을 거부할 경우 불필요한 대용량 전송을 방지한다.
-   **103 Early Hints**: 서버가 최종 응답을 준비하는 동안 클라이언트에게 중요한 리소스(CSS, JavaScript)를 미리 로드하도록 힌트를 제공한다. 페이지 로딩 성능을 크게 개선할 수 있다.

**주의사항**: 대부분의 웹 애플리케이션에서 1xx 코드를 직접 다룰 일은 드물며, HTTP/2에서는 103 Early Hints가 성능 최적화에 활용된다.

## 1xx (Informational) : 요청이 수신되었으며 프로세스가 계속 진행 중

-   100 Continue : 서버가 요청의 일부를 받았으며 클라이언트가 요청을 계속해도 됨을 알림
-   101 Switching Protocols : 서버가 업그레이드 요청을 수락하고 프로토콜 변경을 알림
-   102 Processing : 서버가 요청을 수신하고 처리 중임
-   103 Early Hints : 서버가 일부 응답을 보냈으며 클라이언트가 요청을 계속해도 됨을 알림

### 2xx (Successful): 성공

2xx 상태 코드는 클라이언트의 요청이 성공적으로 수신되고 이해되었으며 수락되었음을 나타낸다. RESTful API에서 가장 중요한 카테고리며, 각 상황에 맞는 적절한 코드 선택이 중요하다.

**RESTful API에서의 올바른 사용:**

-   **GET 요청**: 200 OK (리소스 반환), 404 Not Found (리소스 없음)
-   **POST 요청**: 201 Created (새 리소스 생성, Location 헤더 포함), 200 OK (작업 수행, 리소스 미생성)
-   **PUT 요청**: 200 OK (업데이트 성공, 응답 본문 포함), 204 No Content (업데이트 성공, 본문 없음)
-   **DELETE 요청**: 204 No Content (삭제 성공), 200 OK (삭제 정보 포함)

**중요 코드 상세:**

-   **200 OK**: 가장 일반적인 성공 응답이다. GET으로 리소스를 조회하거나 PUT/PATCH로 업데이트 후 변경된 리소스를 반환할 때 사용한다.
-   **201 Created**: POST로 새 리소스를 생성했을 때 사용하며, `Location` 헤더에 생성된 리소스의 URI를 포함해야 한다. 예: `Location: /api/users/123`
-   **204 No Content**: 요청은 성공했지만 응답 본문이 없다. DELETE 성공, PUT으로 업데이트만 하고 응답이 불필요할 때 적합하다. 클라이언트는 현재 뷰를 유지한다.

## 2xx (Successful) : 요청이 성공적으로 수신되었으며 이해되었고 수락되었음

-   200 OK : 요청이 성공적으로 수신되었으며 이해되었음
-   201 Created : 요청이 성공적으로 수신되었으며 새로운 리소스가 생성되었음
-   202 Accepted : 요청이 수신되었으며 처리가 완료되지 않았음
-   203 Non-Authoritative Information : 요청이 성공적으로 수신되었으며 응답은 프록시에서 제공됨
-   204 No Content : 요청이 성공적으로 수신되었으며 응답에 컨텐츠가 없음
-   205 Reset Content : 요청이 성공적으로 수신되었으며 사용자 에이전트가 문서 뷰를 재설정해야 함
-   206 Partial Content : 요청이 성공적으로 수신되었으며 일부 응답이 전송됨
-   207 Multi-Status : 요청이 성공적으로 수신되었으며 여러 상태 코드가 반환됨
-   208 Already Reported : 요청이 성공적으로 수신되었으며 멀티-상태 응답이 반환됨
-   226 IM Used : 요청이 성공적으로 수신되었으며 인스턴스가 멀티 상태 응답을 반환함

### 3xx (Redirection): 리다이렉션

3xx 상태 코드는 클라이언트가 요청을 완료하기 위해 추가 작업이 필요함을 나타낸다. 주로 URL 변경, 캐싱, 리소스 이동 시 사용된다.

**301 vs 302 vs 307 vs 308 차이:**

| 코드 | 유형 | HTTP 메서드 보존 | 캐싱 | 사용 사례 |
|------|------|------------------|------|-----------|
| 301 Moved Permanently | 영구 리다이렉트 | 보존 안 됨 (POST→GET 변환 가능) | 브라우저 캐싱 | 도메인 변경, URL 구조 변경, SEO |
| 302 Found | 임시 리다이렉트 | 보존 안 됨 (POST→GET 변환 가능) | 캐싱 안 됨 | 임시 페이지 이동 |
| 307 Temporary Redirect | 임시 리다이렉트 | 보존됨 (POST는 POST 유지) | 캐싱 안 됨 | 유지보수 페이지, POST 요청 리다이렉트 |
| 308 Permanent Redirect | 영구 리다이렉트 | 보존됨 (POST는 POST 유지) | 브라우저 캐싱 | RESTful API 엔드포인트 영구 변경 |

**중요 코드 상세:**

-   **301 Moved Permanently**: URL이 영구적으로 변경되었다. 검색 엔진은 새 URL을 색인하고 이전 URL의 SEO 점수를 이전한다. `Location` 헤더에 새 URL을 포함한다. 예: HTTP→HTTPS 전환, www 서브도메인 추가/제거
-   **302 Found**: 임시 리다이렉트다. 원래 URL을 북마크하고 검색 엔진은 기존 URL을 유지한다. 로그인 후 원래 페이지로 돌아가기, A/B 테스트 등에 사용된다.
-   **304 Not Modified**: 리소스가 수정되지 않았다. 클라이언트는 캐시된 버전을 사용한다. `If-None-Match` (ETag), `If-Modified-Since` (Last-Modified) 헤더와 함께 사용되어 대역폭을 절약한다.

**SEO 영향**: 301은 링크 주스(link juice)를 전달하지만, 302는 전달하지 않는다. 영구 이동 시 반드시 301을 사용해야 한다.

## 3xx (Redirection) : 클라이언트는 추가 작업이 필요함

-   300 Multiple Choices : 요청이 여러 옵션을 가지고 있음
-   301 Moved Permanently : 요청한 리소스가 새로운 URL로 영구적으로 이동됨
-   302 Found : 요청한 리소스가 일시적으로 다른 URL로 이동됨
-   303 See Other : 요청한 리소스가 다른 URL로 이동됨
-   304 Not Modified : 요청한 리소스가 수정되지 않았음
-   305 Use Proxy : 요청한 리소스는 프록시를 사용해야 함
-   306 Switch Proxy : 요청한 리소스는 다른 프록시를 사용해야 함
-   307 Temporary Redirect : 요청한 리소스가 일시적으로 다른 URL로 이동됨
-   308 Permanent Redirect : 요청한 리소스가 새로운 URL로 영구적으로 이동됨

### 4xx (Client Error): 클라이언트 에러

4xx 상태 코드는 클라이언트의 요청에 문제가 있음을 나타낸다. 클라이언트가 요청을 수정하지 않으면 같은 에러가 반복된다.

**가장 흔한 에러와 해결 방법:**

**400 Bad Request**
-   **원인**: 잘못된 JSON 형식, 필수 필드 누락, 유효하지 않은 데이터 타입
-   **해결**: 요청 본문과 헤더를 검증하고, 상세한 에러 메시지를 응답 본문에 포함한다
-   **예제 응답**:
```json
{
  "error": "Validation failed",
  "details": [
    {"field": "email", "message": "Invalid email format"},
    {"field": "age", "message": "Must be a positive integer"}
  ]
}
```

**401 Unauthorized vs 403 Forbidden**
-   **401**: 인증이 필요하거나 인증 정보가 잘못되었다. `WWW-Authenticate` 헤더를 포함해야 하며, 로그인 후 재시도하면 성공할 수 있다.
-   **403**: 인증은 되었지만 권한이 없다. 로그인을 다시 해도 해결되지 않으며, 관리자 권한이 필요한 리소스 접근 시 사용한다.
-   **실제 사례**: 일반 사용자가 관리자 페이지 접근 → 403, 로그인하지 않은 사용자가 보호된 리소스 접근 → 401

**404 Not Found**
-   **사용 시점**: 리소스가 존재하지 않거나 클라이언트가 알 권한이 없을 때
-   **Soft 404 주의**: 200 OK로 "Not Found" 메시지를 반환하면 안 된다. 검색 엔진과 클라이언트가 혼란스러워한다.
-   **보안 고려**: 403 대신 404를 반환하여 리소스 존재 여부를 숨길 수 있다 (보안상 민감한 경우)

**405 Method Not Allowed**
-   **의미**: 리소스는 존재하지만 해당 HTTP 메서드를 지원하지 않는다
-   **필수 헤더**: `Allow: GET, POST, HEAD` 헤더로 허용되는 메서드를 알려준다
-   **예시**: `/users/123`에 DELETE를 보냈지만 읽기 전용 API인 경우

**409 Conflict**
-   **사용 사례**: 버전 충돌, 중복 리소스 생성 시도, 낙관적 잠금(optimistic locking) 실패
-   **예시**: 같은 이메일로 두 번째 회원가입 시도, 수정 중인 문서를 다른 사용자가 먼저 수정함
-   **해결 방법**: 클라이언트가 최신 상태를 가져온 후 재시도

**429 Too Many Requests**
-   **용도**: Rate limiting, API 사용량 제한
-   **필수 헤더**: `Retry-After: 3600` (초 단위) 또는 `X-RateLimit-Reset: 1640995200` (타임스탬프)
-   **추가 헤더**: `X-RateLimit-Limit: 100`, `X-RateLimit-Remaining: 0`
-   **전략**: 지수 백오프(exponential backoff)로 재시도

## 4xx (Client Error) : 클라이언트에 오류가 있음

-   400 Bad Request : 요청이 잘못되었음
-   401 Unauthorized : 인증이 필요함
-   402 Payment Required : 결제가 필요함
-   403 Forbidden : 요청이 거부됨
-   404 Not Found : 요청한 리소스가 없음
-   405 Method Not Allowed : 요청된 메소드가 허용되지 않음
-   406 Not Acceptable : 요청된 리소스가 클라이언트가 허용하지 않음
-   407 Proxy Authentication Required : 프록시 인증이 필요함
-   408 Request Timeout : 요청 시간이 초과됨
-   409 Conflict : 요청이 충돌함
-   410 Gone : 요청한 리소스가 더 이상 사용되지 않음
-   411 Length Required : Content-Length 헤더가 필요함
-   412 Precondition Failed : 요청 전제 조건이 실패함
-   413 Payload Too Large : 요청이 너무 큼
-   414 URI Too Long : URI가 너무 김
-   415 Unsupported Media Type : 지원하지 않는 미디어 타입
-   416 Range Not Satisfiable : 범위가 만족되지 않음
-   417 Expectation Failed : 요청이 실패함
-   418 I'm a teapot : 나는 주전자입니다
-   421 Misdirected Request : 잘못된 요청
-   422 Unprocessable Entity : 처리할 수 없는 엔티티
-   423 Locked : 잠김
-   424 Failed Dependency : 의존성 실패
-   425 Too Early : 너무 이른 요청
-   426 Upgrade Required : 업그레이드 필요
-   428 Precondition Required : 전제 조건 필요
-   429 Too Many Requests : 요청이 너무 많음
-   431 Request Header Fields Too Large : 요청 헤더 필드가 너무 큼
-   451 Unavailable For Legal Reasons : 법적 이유로 사용할 수 없음

### 5xx (Server Error): 서버 에러

5xx 상태 코드는 서버가 유효한 요청을 처리하지 못했음을 나타낸다. 클라이언트에게는 책임이 없으며, 서버 측에서 해결해야 한다.

**서버 에러 처리 전략:**

**500 Internal Server Error**
-   **의미**: 서버에서 예상하지 못한 에러가 발생했다. 가장 일반적인 서버 에러다.
-   **원인**: 처리되지 않은 예외, 데이터베이스 연결 실패, 코드 버그
-   **필수 조치**:
    - 에러를 로깅 시스템에 기록한다 (스택 트레이스, 요청 정보 포함)
    - 클라이언트에게는 구체적인 에러 정보를 노출하지 않는다 (보안)
    - 모니터링 알림을 설정한다
-   **응답 예제**: `{"error": "An unexpected error occurred. Please try again later.", "error_id": "err_123456"}`

**502 Bad Gateway**
-   **의미**: 게이트웨이나 프록시 서버가 업스트림 서버로부터 잘못된 응답을 받았다
-   **시나리오**: Nginx가 백엔드 애플리케이션 서버로부터 응답을 받지 못함, 로드 밸런서와 서버 간 연결 문제
-   **해결**: 업스트림 서버 상태 확인, 타임아웃 설정 조정

**503 Service Unavailable**
-   **사용 시점**: 서버가 일시적으로 요청을 처리할 수 없다 (과부하, 유지보수, 배포 중)
-   **필수 헤더**: `Retry-After: 3600` 헤더로 재시도 시점을 알려준다
-   **실제 사용**: 배포 중 헬스체크 실패 시, 서버 재시작 중, 데이터베이스 마이그레이션 중
-   **vs 500**: 503은 일시적이고 예상된 상황, 500은 예상하지 못한 에러

**504 Gateway Timeout**
-   **의미**: 게이트웨이나 프록시가 업스트림 서버로부터 제시간에 응답을 받지 못했다
-   **원인**: 백엔드 서버가 너무 느리거나 응답하지 않음, 네트워크 문제
-   **해결**: 타임아웃 값 조정, 쿼리 최적화, 비동기 처리 전환

**모니터링 지표:**
-   **4xx 비율**: 클라이언트 에러 비율이 갑자기 증가하면 API 변경이나 클라이언트 버그를 의심한다
-   **5xx 비율**: 서버 에러 비율이 1% 이상이면 즉시 조사가 필요하다
-   **429 발생률**: Rate limit 설정이 적절한지 확인한다

## 5xx (Server Error) : 서버에 오류가 있음

-   500 Internal Server Error : 서버에 오류가 있음
-   501 Not Implemented : 요청이 구현되지 않음
-   502 Bad Gateway : 게이트웨이가 잘못됨
-   503 Service Unavailable : 서비스를 사용할 수 없음
-   504 Gateway Timeout : 게이트웨이 시간 초과
-   505 HTTP Version Not Supported : HTTP 버전이 지원되지 않음
-   506 Variant Also Negotiates : 변형도 협상함
-   507 Insufficient Storage : 저장 공간이 부족함
-   508 Loop Detected : 루프가 감지됨
-   510 Not Extended : 확장되지 않음
-   511 Network Authentication Required : 네트워크 인증이 필요함
-   599 Network Connect Timeout Error : 네트워크 연결 시간 초과 오류

## RESTful API 설계 가이드

RESTful API에서 적절한 HTTP 상태 코드 사용은 API의 직관성과 개발자 경험을 크게 향상시킨다.

### CRUD 작업별 상태 코드 매핑

| 작업 | HTTP 메서드 | 성공 시 | 리소스 없음 | 에러 |
|------|-------------|---------|-------------|------|
| Create | POST | 201 Created (Location 헤더) | - | 400 Bad Request, 409 Conflict |
| Read (단일) | GET | 200 OK | 404 Not Found | 403 Forbidden |
| Read (목록) | GET | 200 OK (빈 배열 포함) | - | - |
| Update (전체) | PUT | 200 OK, 204 No Content | 404 Not Found | 400 Bad Request, 409 Conflict |
| Update (부분) | PATCH | 200 OK, 204 No Content | 404 Not Found | 400 Bad Request, 409 Conflict |
| Delete | DELETE | 204 No Content, 200 OK | 404 Not Found (선택적) | 403 Forbidden |

### POST: 201 vs 200 선택 기준

**201 Created 사용:**
```http
POST /api/users
Content-Type: application/json

{"name": "John", "email": "john@example.com"}

Response: 201 Created
Location: /api/users/123
{
  "id": 123,
  "name": "John",
  "email": "john@example.com",
  "created_at": "2024-06-05T09:38:59Z"
}
```

**200 OK 사용 (작업 수행, 리소스 미생성):**
```http
POST /api/users/123/send-email
Content-Type: application/json

{"subject": "Welcome", "body": "Welcome to our service"}

Response: 200 OK
{
  "message": "Email sent successfully",
  "sent_at": "2024-06-05T09:40:00Z"
}
```

### 에러 응답 본문 구조

일관된 에러 응답 형식은 클라이언트 개발자에게 매우 중요하다.

**권장 구조:**
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "message": "Email is already registered",
        "code": "DUPLICATE_EMAIL"
      }
    ],
    "timestamp": "2024-06-05T09:38:59Z",
    "path": "/api/users",
    "request_id": "req_abc123"
  }
}
```

## 특이하고 흥미로운 상태 코드들

### 418 I'm a teapot

1998년 4월 1일 만우절에 RFC 2324로 정의된 HTCPCP(Hyper Text Coffee Pot Control Protocol)의 일부다. 티포트가 커피를 내릴 수 없음을 나타내는 농담 코드지만, 많은 프레임워크에서 실제로 구현되어 있다.

**실제 사용 사례:**
-   Google의 2014년 만우절 프로젝트에서 사용
-   Node.js의 Express 프레임워크에서 지원
-   개발자들이 API 문서의 예제나 테스트 코드에서 종종 사용

### 451 Unavailable For Legal Reasons

Ray Bradbury의 소설 "Fahrenheit 451"에서 영감을 받았으며, 2015년 RFC 7725로 공식 추가되었다. 법적 이유로 콘텐츠를 제공할 수 없을 때 사용한다.

**실제 사용 사례:**
-   저작권 침해로 삭제된 콘텐츠
-   정부 검열로 차단된 콘텐츠
-   GDPR 요청으로 삭제된 개인 정보
-   지역 제한이 있는 콘텐츠

### 103 Early Hints

성능 최적화를 위해 RFC 8297로 2017년 추가되었다. 서버가 최종 응답을 준비하는 동안 클라이언트가 필요한 리소스를 미리 로드할 수 있게 한다.

**성능 향상 예제:**
```http
HTTP/1.1 103 Early Hints
Link: </style.css>; rel=preload; as=style
Link: </script.js>; rel=preload; as=script

(서버가 응답 준비 중...)

HTTP/1.1 200 OK
Content-Type: text/html
...
```

이렇게 하면 브라우저는 HTML을 파싱하기 전에 CSS와 JavaScript를 미리 다운로드하여 페이지 로딩 속도를 20-30% 개선할 수 있다.

### 425 Too Early

RFC 8470으로 2018년 추가되었으며, TLS 1.3의 0-RTT(zero round-trip time) 재사용 공격을 방지한다. 서버가 요청이 재전송 공격의 위험이 있다고 판단할 때 사용한다.

## 브라우저와 HTTP 상태 코드

브라우저는 상태 코드에 따라 자동으로 특정 동작을 수행한다.

### 자동 리다이렉트 처리

브라우저는 3xx 상태 코드를 받으면 자동으로 `Location` 헤더의 URL로 이동한다. 사용자는 이 과정을 의식하지 못한다.

-   **301, 302, 307, 308**: 자동으로 리다이렉트
-   **303**: POST 요청을 GET으로 변환하여 리다이렉트
-   **304**: 캐시된 리소스 사용, 새로운 요청 없음

### 인증 팝업

401 상태 코드와 `WWW-Authenticate` 헤더를 받으면 브라우저는 자동으로 인증 다이얼로그를 표시한다.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="User Area"
```

이 방식은 간단한 인증에는 유용하지만, 현대 웹 애플리케이션에서는 폼 기반 인증이나 OAuth를 선호한다.

### 캐싱 동작

-   **200 OK**: `Cache-Control`, `Expires` 헤더에 따라 캐싱
-   **301 Moved Permanently**: 브라우저가 영구적으로 새 URL을 기억하고 캐싱
-   **304 Not Modified**: 캐시된 버전 사용, 네트워크 트래픽 절약

## 모니터링과 에러 처리 베스트 프랙티스

### 상태 코드 비율 모니터링

API의 건강 상태를 파악하기 위해 다음 지표를 추적한다.

**핵심 지표:**
-   **2xx 비율**: 95% 이상 유지 목표
-   **4xx 비율**: 갑작스런 증가는 API 변경이나 클라이언트 문제 신호
-   **5xx 비율**: 1% 미만 유지, 초과 시 즉시 알림
-   **특정 엔드포인트별 비율**: 문제가 있는 특정 API 식별

### 에러 로깅 전략

**서버 에러 (5xx) 로깅:**
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
    "user_agent": "Mozilla/5.0...",
    "request_id": "req_abc123"
  },
  "context": {
    "database_host": "db.example.com",
    "retry_count": 3
  }
}
```

**클라이언트 에러 (4xx) 로깅 (선택적):**
-   400, 422: 유효성 검증 실패 패턴 분석
-   401, 403: 인증/권한 문제 추적
-   404: 잘못된 URL 패턴 식별
-   429: Rate limit 조정 필요성 판단

### 사용자 친화적 에러 페이지

각 에러 유형에 맞는 적절한 안내를 제공한다.

**404 페이지:**
-   명확한 메시지: "페이지를 찾을 수 없습니다"
-   검색 기능 제공
-   인기 페이지 링크
-   홈으로 돌아가기 버튼

**500 페이지:**
-   사과 메시지: "일시적인 오류가 발생했습니다"
-   재시도 버튼
-   고객 지원 연락처
-   참조 번호 (error_id) 제공

**503 페이지:**
-   유지보수 안내: "시스템 점검 중입니다"
-   예상 복구 시간
-   상태 페이지 링크

## 참고

-   [https://developer.mozilla.org/ko/docs/Web/HTTP/Status](https://developer.mozilla.org/ko/docs/Web/HTTP/Status)

> 418 I'm a teapot : 이 상태 코드는 1998년 4월 1일에 IETF에 의해 정의되었으며, Hyper Text Coffee Pot Control Protocol (HTCPCP)의 확장으로서, 커피포트가 차 있는지 확인하는 데 사용됩니다. 이것은 농담이며 실제로 사용되지 않습니다.
