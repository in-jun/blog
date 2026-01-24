---
title: "REST API 설계 원칙과 모범 사례"
date: 2024-07-20T16:23:17+09:00
tags: ["REST", "API", "설계"]
description: "REST API 설계 원칙과 모범 사례를 다룬다."
draft: false
---

REST(Representational State Transfer)는 2000년 Roy Fielding이 UC Irvine에서 발표한 박사 학위 논문 "Architectural Styles and the Design of Network-based Software Architectures"에서 처음 소개된 분산 하이퍼미디어 시스템을 위한 아키텍처 스타일로, HTTP 프로토콜의 주요 저자 중 한 명이었던 Fielding이 웹의 성공 요인을 분석하고 이를 체계적인 아키텍처 원칙으로 정리한 것이며, 현대 웹 API 설계의 사실상 표준으로 자리잡아 마이크로서비스 아키텍처, 모바일 애플리케이션, SPA(Single Page Application) 등 다양한 분산 시스템 간의 통신에 널리 활용되고 있다.

> **REST란?**
>
> REST(Representational State Transfer)는 네트워크 기반 소프트웨어 아키텍처 스타일로, 리소스를 URI로 식별하고 HTTP 메서드를 통해 상태를 전송(transfer)하는 방식이다. "Representational"은 리소스의 표현(JSON, XML 등)을 의미하며, "State Transfer"는 클라이언트와 서버 간에 리소스 상태가 전송되는 것을 의미한다.

## REST의 역사와 배경

### 웹 서비스의 진화

REST가 등장하기 전 웹 서비스는 주로 SOAP(Simple Object Access Protocol)과 XML-RPC를 사용했으며, 이 프로토콜들은 복잡한 XML 기반 메시지 포맷, 엄격한 타입 시스템, WSDL(Web Services Description Language)을 통한 서비스 정의를 요구하여 구현과 유지보수가 어려웠다. SOAP은 엔터프라이즈 환경에서 트랜잭션, 보안, 메시지 신뢰성 등을 지원하는 장점이 있었지만, 단순한 데이터 조회에도 복잡한 XML 봉투(envelope)를 사용해야 하는 오버헤드가 있었다.

### Roy Fielding의 기여

Roy Fielding은 HTTP/1.0과 HTTP/1.1 명세의 주요 저자이자 Apache HTTP Server 프로젝트의 공동 창립자로, 웹의 아키텍처를 깊이 이해하고 있었다. 그는 박사 학위 논문에서 웹이 성공할 수 있었던 이유를 분석하고, 이를 REST라는 아키텍처 스타일로 체계화했다. REST는 기존 웹 인프라(HTTP, URI, 캐시, 프록시)를 최대한 활용하면서 단순하고 확장 가능한 시스템을 구축할 수 있도록 설계되었다.

### REST API의 확산

REST가 실제로 널리 채택되기 시작한 것은 2000년대 중반 이후로, Flickr(2004년), Amazon Web Services(2006년), Twitter(2006년) 등이 REST API를 공개하면서 웹 API의 표준으로 자리잡았다. JSON 포맷의 부상과 함께 REST는 SOAP의 복잡성을 피하고 싶어하는 개발자들에게 매력적인 대안이 되었으며, Ajax와 모바일 앱의 등장으로 그 인기가 더욱 높아졌다.

## REST의 6가지 제약 조건

REST는 특정 프로토콜이나 기술이 아닌 아키텍처 스타일이며, 다음 6가지 제약 조건을 따르는 시스템을 RESTful하다고 한다.

### 1. 클라이언트-서버 (Client-Server)

클라이언트와 서버의 관심사를 분리하여 독립적인 발전을 가능하게 하는 제약 조건으로, 서버는 데이터 저장과 비즈니스 로직을 담당하고 클라이언트는 사용자 인터페이스를 담당함으로써 각각 독립적으로 개발, 배포, 확장할 수 있다.

> **관심사 분리의 이점**
>
> 클라이언트-서버 분리는 서버의 단순화를 통해 확장성을 향상시키고, 다양한 클라이언트(웹, 모바일, IoT)가 동일한 서버 API를 사용할 수 있게 하며, 각 컴포넌트의 독립적인 발전을 가능하게 한다.

### 2. 무상태 (Stateless)

각 요청은 독립적이며 서버는 클라이언트의 세션 상태를 저장하지 않아야 하는 제약 조건으로, 요청에 필요한 모든 정보(인증 토큰, 컨텍스트 데이터)는 요청 자체에 포함되어야 한다.

```http
GET /api/users/me HTTP/1.1
Host: api.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Accept: application/json
```

**무상태의 장점:**
- **확장성**: 서버가 세션을 유지하지 않으므로 수평적 확장이 용이
- **신뢰성**: 서버 장애 시 다른 서버가 요청을 처리할 수 있음
- **단순성**: 서버 구현이 단순해지고 리소스 효율성 향상

**무상태의 단점:**
- 매 요청마다 인증 정보를 포함해야 하므로 요청 크기 증가
- 클라이언트 측에서 상태 관리 책임이 증가

### 3. 캐시 가능 (Cacheable)

응답은 캐시 가능 여부를 명시적으로 표시해야 하며, 캐시 가능한 응답은 클라이언트나 중간 캐시(CDN, 프록시)에서 재사용될 수 있어 서버 부하를 줄이고 응답 시간을 단축한다.

```http
HTTP/1.1 200 OK
Content-Type: application/json
Cache-Control: max-age=3600, must-revalidate
ETag: "a1b2c3d4e5f6"
Last-Modified: Sat, 20 Jul 2024 10:00:00 GMT

{"id": 123, "name": "홍길동", "email": "hong@example.com"}
```

**캐시 관련 헤더:**

| 헤더 | 설명 | 예시 |
|------|------|------|
| Cache-Control | 캐시 정책 지정 | `max-age=3600, private` |
| ETag | 리소스 버전 식별자 | `"a1b2c3d4e5f6"` |
| Last-Modified | 마지막 수정 시간 | `Sat, 20 Jul 2024 10:00:00 GMT` |
| Expires | 캐시 만료 시간 (레거시) | `Sun, 21 Jul 2024 10:00:00 GMT` |

### 4. 계층화 시스템 (Layered System)

클라이언트는 직접 연결된 계층만 알면 되며 그 너머의 시스템 구조를 알 필요가 없는 제약 조건으로, API Gateway, 로드 밸런서, 캐시 서버, CDN 등 중간 계층을 추가하여 시스템의 확장성, 보안성, 성능을 향상시킬 수 있다.

```
[클라이언트] → [CDN] → [로드 밸런서] → [API Gateway] → [마이크로서비스]
```

**계층화의 이점:**
- **보안**: 방화벽, 인증 서버 등을 중간 계층에 배치
- **확장성**: 로드 밸런서를 통한 수평적 확장
- **성능**: CDN과 캐시 서버를 통한 응답 시간 단축
- **유연성**: 클라이언트에 영향 없이 내부 구조 변경 가능

### 5. 인터페이스 일관성 (Uniform Interface)

REST의 가장 중요한 제약 조건으로, 일관된 인터페이스를 통해 시스템 아키텍처를 단순화하고 클라이언트-서버 간 결합도를 낮춘다.

> **인터페이스 일관성의 4가지 요소**
>
> 1. **리소스 식별**: URI를 통해 리소스를 고유하게 식별
> 2. **표현을 통한 리소스 조작**: JSON, XML 등의 표현을 통해 리소스 상태 전송
> 3. **자기 서술적 메시지**: 메시지 자체에 처리 방법에 대한 정보 포함
> 4. **HATEOAS**: 응답에 다음 가능한 행위에 대한 하이퍼링크 포함

### 6. 코드 온 디맨드 (Code on Demand, 선택 사항)

서버가 클라이언트에게 실행 가능한 코드(JavaScript 등)를 전송하여 클라이언트 기능을 동적으로 확장할 수 있는 선택적 제약 조건이다. 웹 브라우저에서 JavaScript를 다운로드받아 실행하는 것이 대표적인 예시이며, 이 제약 조건은 REST의 유일한 선택 사항이다.

## Richardson 성숙도 모델

Leonard Richardson은 2008년 QCon 컨퍼런스에서 REST API의 성숙도를 4단계로 분류하는 모델을 발표했으며, 이 모델은 API가 얼마나 RESTful한지를 평가하는 기준으로 널리 사용된다.

| 수준 | 이름 | 특징 | 예시 |
|------|------|------|------|
| Level 0 | The Swamp of POX | 단일 URI, 단일 HTTP 메서드 (주로 POST) | SOAP, XML-RPC |
| Level 1 | Resources | 개별 리소스에 URI 부여, 단일 메서드 | `/users/123`에 모든 작업을 POST |
| Level 2 | HTTP Verbs | HTTP 메서드와 상태 코드 적절히 활용 | GET, POST, PUT, DELETE 구분 |
| Level 3 | Hypermedia Controls | HATEOAS 구현, 응답에 링크 포함 | `_links` 필드에 관련 리소스 링크 |

### RESTful API vs REST-like API

**RESTful API**는 HATEOAS를 포함한 모든 REST 제약 조건을 완벽히 준수하는 API를 의미하며, **REST-like API**는 HTTP 메서드와 리소스 기반 URL을 사용하지만 HATEOAS 등 일부 제약 조건을 준수하지 않는 API를 의미한다. 현실에서 대부분의 API는 Richardson 성숙도 모델 Level 2에 해당하는 REST-like API이며, Level 3의 완전한 RESTful API를 구현하는 경우는 드물다.

## REST API 설계 원칙

### 1. 리소스 중심 URL 설계

REST API의 URL은 동작(action)이 아닌 리소스(resource)를 나타내야 하며, 명사를 사용하고 복수형을 권장한다.

**좋은 예시:**
```
GET    /users              # 사용자 목록 조회
GET    /users/123          # 특정 사용자 조회
POST   /users              # 새 사용자 생성
PUT    /users/123          # 사용자 정보 전체 수정
PATCH  /users/123          # 사용자 정보 부분 수정
DELETE /users/123          # 사용자 삭제
```

**나쁜 예시:**
```
GET    /getUsers
POST   /createUser
POST   /deleteUser?id=123
GET    /user/123/get
```

**계층적 리소스 표현:**
```
GET /users/123/posts                    # 사용자 123의 게시글 목록
GET /users/123/posts/456               # 사용자 123의 게시글 456
GET /users/123/posts/456/comments      # 게시글 456의 댓글 목록
```

**URL 설계 규칙:**
- 소문자 사용
- 단어 구분은 하이픈(-) 사용 (언더스코어 지양)
- 파일 확장자 포함하지 않음
- 마지막 슬래시(/) 포함하지 않음
- 3단계 이상의 중첩은 피함

### 2. HTTP 메서드의 올바른 사용

각 HTTP 메서드는 고유한 의미를 가지며, 안전성(safe)과 멱등성(idempotent) 속성을 이해하고 올바르게 사용해야 한다.

| 메서드 | 용도 | 안전 | 멱등 | 요청 본문 | 응답 본문 |
|--------|------|------|------|-----------|-----------|
| GET | 리소스 조회 | O | O | X | O |
| POST | 리소스 생성 | X | X | O | O |
| PUT | 리소스 전체 수정 | X | O | O | O |
| PATCH | 리소스 부분 수정 | X | X | O | O |
| DELETE | 리소스 삭제 | X | O | X | X/O |
| HEAD | 헤더만 조회 | O | O | X | X |
| OPTIONS | 지원 메서드 조회 | O | O | X | O |

> **안전성과 멱등성**
>
> **안전(Safe)**: 요청이 서버 상태를 변경하지 않음 (GET, HEAD, OPTIONS)
> **멱등(Idempotent)**: 동일한 요청을 여러 번 실행해도 결과가 같음 (GET, PUT, DELETE)

### 3. HTTP 상태 코드의 적절한 사용

HTTP 상태 코드를 통해 요청 처리 결과를 명확하게 전달해야 한다.

**성공 응답 (2xx):**

| 코드 | 의미 | 사용 상황 |
|------|------|----------|
| 200 OK | 성공 | GET, PUT, PATCH 성공 시 |
| 201 Created | 생성 성공 | POST로 리소스 생성 시 (Location 헤더 필수) |
| 204 No Content | 성공, 본문 없음 | DELETE 성공, PUT으로 업데이트만 |
| 206 Partial Content | 부분 콘텐츠 | Range 요청 처리 시 |

**클라이언트 에러 (4xx):**

| 코드 | 의미 | 사용 상황 |
|------|------|----------|
| 400 Bad Request | 잘못된 요청 | 요청 구문 오류, 유효하지 않은 데이터 |
| 401 Unauthorized | 인증 필요 | 인증 정보 없음 또는 유효하지 않음 |
| 403 Forbidden | 권한 없음 | 인증됨, 권한 부족 |
| 404 Not Found | 리소스 없음 | 존재하지 않는 리소스 |
| 409 Conflict | 충돌 | 리소스 상태 충돌 |
| 422 Unprocessable Entity | 처리 불가 | 문법 올바름, 의미적 오류 |
| 429 Too Many Requests | 요청 제한 초과 | Rate limiting |

**서버 에러 (5xx):**

| 코드 | 의미 | 사용 상황 |
|------|------|----------|
| 500 Internal Server Error | 서버 오류 | 예상하지 못한 서버 에러 |
| 502 Bad Gateway | 게이트웨이 오류 | 업스트림 서버 응답 오류 |
| 503 Service Unavailable | 서비스 불가 | 서버 과부하, 유지보수 |
| 504 Gateway Timeout | 게이트웨이 시간 초과 | 업스트림 응답 시간 초과 |

### 4. 버전 관리 전략

API는 시간이 지남에 따라 변경될 수 있으므로 하위 호환성을 유지하면서 새로운 기능을 추가하기 위한 버전 관리 전략이 필요하다.

**URL 경로 버전 관리:**
```
GET /api/v1/users
GET /api/v2/users
```

**장점**: 명확하고 직관적, 브라우저에서 테스트 용이, 캐싱 간단
**단점**: URL이 길어짐, REST 원칙 논란 (URI는 리소스를 식별해야 함)

**헤더 버전 관리:**
```http
GET /api/users HTTP/1.1
Accept: application/vnd.myapp.v1+json
```

**장점**: URL이 깔끔, REST 원칙에 부합, 콘텐츠 협상 활용
**단점**: 브라우저 테스트 어려움, 캐싱 구성 복잡

**쿼리 파라미터 버전 관리:**
```
GET /api/users?version=1
```

**장점**: 구현 간단, 브라우저 테스트 용이
**단점**: 버전이 선택적으로 보일 수 있음, 캐싱 복잡

**실무 권장**: URL 경로 버전 관리가 가장 널리 사용되며, 대부분의 대형 API(Google, Facebook, Twitter)에서 채택하고 있다.

### 5. 페이지네이션 전략

대량의 데이터를 반환할 때는 페이지네이션을 통해 응답 크기를 제한해야 한다.

**오프셋 기반 페이지네이션:**
```
GET /api/users?page=2&per_page=20
GET /api/users?offset=20&limit=20
```

**커서 기반 페이지네이션:**
```
GET /api/users?cursor=eyJpZCI6MTAwfQ==&limit=20
```

| 방식 | 장점 | 단점 | 적합한 상황 |
|------|------|------|------------|
| 오프셋 기반 | 구현 간단, 특정 페이지 직접 이동 가능 | 대량 데이터에서 성능 저하, 데이터 변경 시 중복/누락 | 소규모 데이터, 페이지 번호 필요 |
| 커서 기반 | 대량 데이터에서도 일관된 성능, 실시간 데이터에 안정적 | 특정 페이지 직접 이동 불가, 구현 복잡 | 대규모 데이터, 무한 스크롤, 실시간 피드 |

**페이지네이션 응답 예시:**
```json
{
  "data": [...],
  "pagination": {
    "total": 1000,
    "page": 2,
    "per_page": 20,
    "total_pages": 50,
    "next_cursor": "eyJpZCI6MTIwfQ=="
  },
  "_links": {
    "self": "/api/users?page=2",
    "next": "/api/users?page=3",
    "prev": "/api/users?page=1",
    "first": "/api/users?page=1",
    "last": "/api/users?page=50"
  }
}
```

### 6. 필터링, 정렬, 검색

쿼리 파라미터를 통해 필터링, 정렬, 검색 기능을 제공한다.

**필터링:**
```
GET /api/users?status=active&role=admin
GET /api/posts?created_after=2024-01-01&tag=javascript
```

**정렬:**
```
GET /api/users?sort=created_at           # 오름차순
GET /api/users?sort=-created_at          # 내림차순 (- 접두사)
GET /api/users?sort=name,-created_at     # 다중 정렬
```

**검색:**
```
GET /api/users?q=홍길동
GET /api/posts?search=REST+API
```

**필드 선택 (Sparse Fieldsets):**
```
GET /api/users?fields=id,name,email
GET /api/posts?fields[posts]=title,content&fields[author]=name
```

### 7. HATEOAS (Hypermedia as the Engine of Application State)

응답에 관련 리소스의 링크를 포함하여 클라이언트가 다음 가능한 행위를 발견할 수 있게 하는 REST의 핵심 원칙이다.

```json
{
  "id": 123,
  "name": "홍길동",
  "email": "hong@example.com",
  "status": "active",
  "_links": {
    "self": {"href": "/api/users/123"},
    "posts": {"href": "/api/users/123/posts"},
    "deactivate": {"href": "/api/users/123/deactivate", "method": "POST"},
    "delete": {"href": "/api/users/123", "method": "DELETE"}
  }
}
```

> **HATEOAS의 이점**
>
> 클라이언트가 하드코딩된 URL 대신 응답의 링크를 따라가므로, 서버가 URL 구조를 변경해도 클라이언트 수정 없이 작동할 수 있다. 그러나 구현 복잡성이 증가하고 대부분의 클라이언트가 이를 활용하지 않아 실무에서는 선택적으로 구현한다.

### 8. 에러 처리

일관된 에러 응답 형식을 사용하여 개발자 경험을 향상시킨다.

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "요청 유효성 검증 실패",
    "details": [
      {
        "field": "email",
        "message": "유효하지 않은 이메일 형식입니다",
        "code": "INVALID_FORMAT"
      },
      {
        "field": "age",
        "message": "나이는 양수여야 합니다",
        "code": "INVALID_VALUE"
      }
    ],
    "timestamp": "2024-07-20T16:23:17Z",
    "path": "/api/users",
    "request_id": "req_abc123"
  }
}
```

**에러 응답 필드:**
- `code`: 프로그래밍 방식 처리를 위한 에러 코드
- `message`: 사람이 읽을 수 있는 에러 설명
- `details`: 필드별 상세 에러 정보
- `request_id`: 로그 추적을 위한 고유 식별자

## 보안 고려사항

### 인증 방식

| 방식 | 특징 | 적합한 상황 |
|------|------|------------|
| API Key | 간단, 요청 헤더나 쿼리에 포함 | 서버 간 통신, 내부 시스템 |
| Basic Auth | 사용자명:비밀번호 Base64 인코딩 | 간단한 인증, HTTPS 필수 |
| Bearer Token (JWT) | 무상태, 자체 포함된 토큰 | 일반적인 사용자 인증 |
| OAuth 2.0 | 위임된 권한 부여 | 제3자 앱 통합, 소셜 로그인 |

### Rate Limiting

API 남용을 방지하고 서버 리소스를 보호하기 위해 요청 제한을 설정한다.

```http
HTTP/1.1 429 Too Many Requests
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1721484600
Retry-After: 3600
Content-Type: application/json

{
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "요청 제한을 초과했습니다. 1시간 후 다시 시도해주세요."
  }
}
```

**Rate Limiting 알고리즘:**
- **Token Bucket**: 버스트 트래픽 허용, 구현 복잡
- **Sliding Window**: 정확한 제한, Redis 활용
- **Fixed Window**: 구현 간단, 경계 시점에 버스트 가능

### CORS (Cross-Origin Resource Sharing)

다른 도메인에서 API에 접근할 수 있도록 CORS 헤더를 설정한다.

```http
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

## API 문서화

### OpenAPI (Swagger)

OpenAPI Specification은 REST API를 정의하기 위한 업계 표준으로, YAML 또는 JSON 형식으로 API를 기술하고 Swagger UI를 통해 인터랙티브한 문서를 제공할 수 있다.

```yaml
openapi: 3.0.0
info:
  title: 사용자 API
  version: 1.0.0
paths:
  /users:
    get:
      summary: 사용자 목록 조회
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
      responses:
        '200':
          description: 성공
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/User'
```

**문서화 도구 선택:**
- **공개 API**: OpenAPI/Swagger (표준, 도구 생태계 풍부)
- **내부 API**: Postman Collections (팀 협업 용이)
- **빠른 프로토타입**: API Blueprint (Markdown 기반)

## REST의 한계와 대안

REST는 범용적이고 널리 채택된 아키텍처 스타일이지만, 모든 상황에 최적인 것은 아니다.

| 기술 | 장점 | 단점 | 적합한 상황 |
|------|------|------|------------|
| REST | 단순, 표준화, 캐싱 용이 | Over-fetching, 다중 요청 필요 | 일반적인 CRUD, 공개 API |
| GraphQL | 정확한 데이터 요청, 단일 엔드포인트 | 캐싱 복잡, 학습 곡선 | 복잡한 데이터 요구, 모바일 앱 |
| gRPC | 고성능, 강타입, 양방향 스트리밍 | 브라우저 지원 제한, 디버깅 어려움 | 마이크로서비스 간 통신 |
| WebSocket | 실시간 양방향 통신, 낮은 지연 | 무상태 아님, 로드 밸런싱 복잡 | 채팅, 실시간 알림, 게임 |

## 결론

REST API 설계는 단순히 기술적 결정을 넘어 사용자 경험과 비즈니스 요구사항을 모두 고려해야 하는 복잡한 과정으로, REST의 6가지 제약 조건을 이해하고 Richardson 성숙도 모델을 참고하되 맹목적으로 따르기보다는 각 설계 결정의 트레이드오프를 파악하고 프로젝트 특성에 맞게 유연하게 적용하는 것이 중요하다. 완벽한 RESTful API(Level 3)를 구현하는 것보다 실용적이고 일관성 있는 REST-like API(Level 2)를 목표로 하면서 충실한 문서화와 개발자 경험을 중시하는 것이 성공적인 API 설계의 핵심이다.

## 참고 자료

- [Roy Fielding의 박사 학위 논문](https://www.ics.uci.edu/~fielding/pubs/dissertation/top.htm)
- [Richardson Maturity Model](https://martinfowler.com/articles/richardsonMaturityModel.html)
- [OpenAPI Specification](https://spec.openapis.org/oas/latest.html)
- [MDN Web Docs - HTTP](https://developer.mozilla.org/ko/docs/Web/HTTP)
