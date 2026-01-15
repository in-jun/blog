---
title: "REST API: 원칙부터 고려 사항까지"
date: 2024-07-20T16:23:17+09:00
tags: ["rest", "api", "design"]
description: "REST API 설계의 핵심 원칙과 모범 사례를 다룬다. Roy Fielding의 REST 아키텍처 스타일, 6가지 제약 조건, HTTP 메서드 활용, 리소스 중심 URL 설계, 버전 관리 전략, 에러 처리, 페이지네이션, HATEOAS까지 실무에 적용 가능한 REST API 설계 가이드를 제공한다"
draft: false
---

## 서론

현대 웹 개발에서 REST(Representational State Transfer) API는 핵심적인 역할을 한다. 잘 설계된 REST API는 시스템 간의 효율적인 통신을 가능하게 하며, 개발자의 생산성을 크게 향상한다. 이 글에서는 REST의 기본 개념부터 시작해 6가지 핵심 원칙, 그리고 실제 API 설계 시 고려해야 할 의사결정 기준과 트레이드오프를 중심으로 다루겠다.

## REST의 기본 개념

REST는 2000년 로이 필딩(Roy Fielding)의 박사 학위 논문에서 소개된 소프트웨어 아키텍처 스타일이다. REST 이전의 웹 서비스는 주로 SOAP과 XML-RPC를 사용했으며, 이는 복잡한 XML 기반 메시지 포맷과 엄격한 프로토콜을 요구했다. Roy Fielding은 HTTP의 장점을 최대한 활용하면서도 단순하고 확장 가능한 아키텍처를 제안했다.

### Richardson 성숙도 모델

Leonard Richardson은 REST API의 성숙도를 4단계로 분류했다:

- **Level 0**: 단일 URI와 메서드만 사용 (HTTP를 단순 전송 수단으로 활용)
- **Level 1**: 개별 리소스에 대한 URI를 정의하나 단일 HTTP 메서드만 사용
- **Level 2**: HTTP 메서드와 상태 코드를 적절히 활용 (대부분의 실무 API 목표)
- **Level 3**: HATEOAS를 구현해 응답에 다음 가능한 행위 링크 포함 (드물게 구현)

### RESTful vs REST-like

실제로 완벽한 REST API를 구현하는 것은 어렵다. **RESTful API**는 HATEOAS를 포함한 모든 제약 조건을 완벽히 준수하며, **REST-like API**는 주로 HTTP 메서드와 리소스 기반 URL만 사용한다. 현실에서는 대부분의 API가 REST-like에 가깝다.

## REST의 6가지 원칙

### 1. 클라이언트-서버 (Client-Server)

클라이언트와 서버의 관심사를 분리해 독립적인 발전을 가능하게 한다. 명확한 인터페이스 정의를 통해 서버는 데이터 저장, 클라이언트는 사용자 인터페이스를 담당하며 시스템의 확장성을 향상한다.

### 2. 무상태 (Stateless)

각 요청은 독립적이며 서버는 클라이언트의 상태를 저장하지 않는다. 이는 높은 신뢰성과 확장성, 서버 리소스의 효율적 사용을 가능하게 한다. JWT 토큰처럼 모든 필요한 정보를 요청에 포함시켜 세션 상태를 클라이언트 측에서 관리한다.

```http
GET /api/users/me HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. 캐시 가능 (Cacheable)

응답은 캐시 가능 여부를 명시해야 한다. HTTP 캐시 헤더(Cache-Control, ETag)를 사용해 성능을 향상하고 서버 부하를 감소시킨다. ETag를 사용하면 리소스가 변경되지 않았을 때 304 상태 코드를 반환해 네트워크 대역폭을 절약할 수 있다.

### 4. 계층화 시스템 (Layered System)

클라이언트는 직접 연결된 계층만 알면 된다. API Gateway 패턴을 통해 클라이언트는 게이트웨이와만 통신하며, 내부 마이크로서비스들의 존재를 알 필요가 없다. 이는 시스템 확장성과 보안성을 강화한다.

### 5. 인터페이스 일관성 (Uniform Interface)

REST의 핵심 원칙으로, 리소스 식별, 표현을 통한 리소스 조작, 자기 서술적 메시지, HATEOAS를 포함한다. 일관된 리소스 명명 규칙과 HTTP 메서드의 적절한 사용, 응답에 하이퍼링크 포함을 통해 시스템 아키텍처를 단순화하고 클라이언트-서버 독립성을 향상한다.

### 6. 코드 온 디맨드 (Code on Demand, 선택사항)

서버가 클라이언트로 실행 가능한 코드를 전송해 클라이언트 기능을 동적으로 확장할 수 있다. JavaScript를 통한 클라이언트 측 스크립팅이 대표적이다.

## REST API 설계 규칙

### 1. 리소스 중심의 URL 설계

명사를 사용해 리소스를 표현하며(`/users`, `/articles`), 복수형 사용을 권장하고, 소문자와 하이픈(-)을 사용한다. 계층적 리소스 표현을 통해 관계를 명확히 한다:

```
GET /users/{userId}/posts/{postId}/comments
```

**액션 기반 엔드포인트**: 표준 CRUD로 표현하기 어려운 작업은 동사를 사용한다:

```
POST /users/{id}/activate
POST /orders/{id}/cancel
```

**URL 길이 제한**: 대부분의 브라우저는 2000-8000자 제한이 있으므로, 복잡한 검색 조건은 POST 요청 본문으로 전송하거나 별도의 검색 API를 만드는 것을 고려한다.

### 2. HTTP 메서드와 상태 코드

- **GET**: 리소스 조회 (멱등성)
- **POST**: 새 리소스 생성
- **PUT**: 리소스 전체 수정 (멱등성)
- **PATCH**: 리소스 부분 수정
- **DELETE**: 리소스 삭제 (멱등성)

주요 상태 코드: 200(성공), 201(생성), 204(내용 없음), 400(잘못된 요청), 401(인증 필요), 403(권한 없음), 404(없음), 500(서버 오류)

### 3. 버전 관리 전략

#### URL 버전 관리

```
GET /api/v1/users
```

**장점**: 명확하고 직관적이며, 브라우저 테스트가 쉽고, 캐싱이 간단하다.
**단점**: URL이 길어지고, 리소스 URI 변경으로 REST 원칙 논란이 있다.

#### 헤더 버전 관리

```http
Accept: application/vnd.myapp.v1+json
```

**장점**: URL이 깔끔하고 REST 원칙에 부합하며, Content negotiation을 활용한다.
**단점**: 브라우저 테스트가 어렵고 캐싱 구성이 복잡하다.

#### 버전 변경 기준

- **Major 변경**: 기존 엔드포인트 제거, 응답 형식의 근본적 변경, 인증 방식 변경
- **Minor 변경**: 새 엔드포인트/필드 추가(하위 호환), 선택적 파라미터 추가
- **변경 불필요**: 버그 수정, 성능 개선, 내부 구현 변경

실무에서는 URL 버전 관리가 가장 널리 사용되며, 헤더 방식은 REST 순수주의를 추구하는 경우 선택한다.

### 4. 페이지네이션 전략

#### Offset-based Pagination

```
GET /api/users?page=2&per_page=20
```

**장점**: 구현이 간단하고 특정 페이지로 직접 이동 가능
**단점**: 대량 데이터에서 성능 저하, 데이터 추가/삭제 시 중복이나 누락 발생

#### Cursor-based Pagination

```
GET /api/users?cursor=eyJpZCI6MTAwfQ==&limit=20
```

**장점**: 대량 데이터에서 일관된 성능, 실시간 데이터 변경에 안정적
**단점**: 특정 페이지로 직접 이동 불가, 구현이 복잡

**선택 기준**: 소규모 데이터나 페이지 번호가 필요하면 Offset 방식, 대규모 데이터나 실시간 피드는 Cursor 방식을 사용한다.

### 5. HATEOAS

응답에 관련 리소스의 링크를 포함해 클라이언트가 다음 가능한 행위를 발견할 수 있게 한다:

```json
{
  "id": 711,
  "name": "John Doe",
  "_links": {
    "self": { "href": "/users/711" },
    "posts": { "href": "/users/711/posts" }
  }
}
```

완벽한 REST(Level 3)를 추구하지 않는다면 선택적으로 구현하며, 클라이언트와 서버 간 결합도를 낮추는 효과가 있다.

### 6. 에러 처리

일관된 에러 응답 형식을 사용해 개발자 경험을 향상한다:

```json
{
  "status": 400,
  "code": "INVALID_EMAIL",
  "message": "The provided email is invalid",
  "details": "The email 'johndoe@' is missing a domain name"
}
```

`code`는 프로그래밍 방식 처리를, `message`는 사람이 읽을 수 있는 설명을, `details`는 추가 컨텍스트를 제공한다.

## 보안 고려사항

### 인증 및 인가

**Basic Authentication**: 간단하지만 HTTPS 필수. 서버 간 통신이나 내부 시스템에 적합하다.

**Bearer Token (JWT)**: 가장 널리 사용되며 무상태성을 유지한다. Header(알고리즘), Payload(사용자 정보), Signature(무결성 검증)로 구성된다.

**OAuth 2.0**: 제3자 애플리케이션에 안전하게 접근 권한을 부여한다. 사용자를 대신한 접근이나 세밀한 권한 제어가 필요할 때 선택한다.

**선택 기준**:
- 내부 시스템, 서버 간 통신: API Key 또는 Basic Auth
- 일반적인 사용자 인증: JWT
- 제3자 앱 통합, 소셜 로그인: OAuth 2.0

### Rate Limiting

과도한 API 호출을 방지하고 서버 리소스를 보호한다. 429 Too Many Requests와 함께 `X-RateLimit-*` 헤더로 제한 정보를 제공한다:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1735689600
```

**Token Bucket**: 버스트 트래픽 처리 가능, 구현이 복잡
**Sliding Window**: 더 정확한 제한, Redis 활용 가능

## 성능 최적화

- **캐싱**: Cache-Control, ETag 헤더 활용
- **응답 압축**: gzip 등을 사용해 대역폭 절약
- **페이로드 최소화**: 필요한 데이터만 반환, 필드 선택(Sparse Fieldsets) 지원 고려

## 문서화

좋은 API 문서는 개발자 경험을 크게 향상한다.

### OpenAPI/Swagger

가장 널리 사용되는 표준으로, YAML/JSON으로 API를 정의하고 Swagger UI로 인터랙티브한 문서를 제공한다. FastAPI나 Express+Swagger JSDoc을 통해 코드에서 자동 생성할 수 있다.

### 문서화 도구 선택

- **공개 API**: OpenAPI/Swagger (표준, 도구 생태계 풍부)
- **내부 API**: Postman Collections (팀 협업 용이)
- **빠른 프로토타입**: API Blueprint (Markdown 기반)

## 실전 설계 예제

블로그 API의 핵심 엔드포인트 구조:

```
POST   /api/auth/register           # 회원가입
POST   /api/auth/login              # 로그인
GET    /api/users/{id}              # 프로필 조회
PATCH  /api/users/{id}              # 프로필 수정

GET    /api/posts                   # 게시글 목록 (필터링, 페이징)
GET    /api/posts/{id}              # 게시글 상세
POST   /api/posts                   # 게시글 작성
PUT    /api/posts/{id}              # 게시글 수정
DELETE /api/posts/{id}              # 게시글 삭제

GET    /api/posts/{id}/comments     # 댓글 목록
POST   /api/posts/{id}/comments     # 댓글 작성
PATCH  /api/posts/{id}/comments/{cid} # 댓글 수정
DELETE /api/posts/{id}/comments/{cid} # 댓글 삭제
```

쿼리 파라미터로 필터링(`?status=published&tag=javascript`), 정렬(`?sort=-created_at`), 페이징(`?page=1&per_page=20`)을 지원하며, 응답에는 메타데이터와 링크를 포함한다.

## REST의 한계와 대안

REST는 범용적이지만 모든 상황의 최적 솔루션은 아니다:

- **실시간 통신**: WebSocket (양방향, 낮은 지연시간)
- **복잡한 데이터 요구**: GraphQL (클라이언트가 필요한 데이터만 요청, Over-fetching 방지)
- **고성능 마이크로서비스**: gRPC (Protobuf, HTTP/2 기반)

각 기술의 트레이드오프를 이해하고 프로젝트 요구사항에 맞게 선택한다.

## 결론

REST API 설계는 기술적 결정뿐 아니라 사용자 경험과 비즈니스 요구사항을 모두 고려해야 하는 복잡한 과정이다. 원칙을 이해하되, 맹목적으로 따르기보다는 각 설계 결정의 트레이드오프를 파악하고 프로젝트 특성에 맞게 유연하게 적용하는 것이 중요하다. 완벽한 RESTful API보다는 실용적이고 일관성 있는 API를 목표로 하며, 문서화와 개발자 경험을 중시하는 것이 성공적인 API 설계의 핵심이다.
