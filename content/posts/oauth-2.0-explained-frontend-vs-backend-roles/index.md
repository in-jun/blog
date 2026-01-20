---
title: "OAuth 2.0 완벽 가이드: 인가 코드 플로우부터 보안 고려사항까지"
date: 2024-08-03T11:21:01+09:00
tags: ["OAuth", "인증", "보안", "API", "소셜 로그인"]
description: "OAuth 2.0의 핵심 개념과 Authorization Code Flow의 동작 원리를 상세히 설명하고, 프론트엔드와 백엔드의 역할 분담 및 보안 모범 사례를 다룬다"
draft: false
---

OAuth 2.0은 2012년 IETF(Internet Engineering Task Force)가 RFC 6749로 표준화한 인가(Authorization) 프레임워크로, 사용자가 자신의 자격 증명(비밀번호)을 제3자 애플리케이션에 노출하지 않으면서도 해당 애플리케이션에 자신의 리소스에 대한 제한된 접근 권한을 부여할 수 있도록 설계되었으며, 현재 Google, Facebook, GitHub, Twitter 등 대부분의 주요 인터넷 서비스에서 소셜 로그인과 API 인가의 표준으로 채택되어 사용되고 있다.

## OAuth의 탄생 배경

> **OAuth가 해결하는 문제**
>
> OAuth 이전에는 사용자가 제3자 애플리케이션에 자신의 아이디와 비밀번호를 직접 제공해야 했는데, 이는 심각한 보안 위험을 초래했다. 사용자는 어떤 애플리케이션이 자신의 자격 증명을 안전하게 관리하는지 알 수 없었고, 접근 권한을 세밀하게 제어하거나 언제든지 철회할 수 있는 방법도 없었다.

OAuth 1.0은 2007년 Twitter와 여러 기업들이 협력하여 만든 최초의 개방형 인가 표준이었으나, 구현이 복잡하고 암호화 서명 요구사항이 까다로워 널리 채택되지 못했다. 이러한 문제를 해결하기 위해 2012년 OAuth 2.0이 발표되었으며, 이전 버전과의 하위 호환성을 포기하는 대신 단순성과 유연성에 초점을 맞추어 설계되었고, HTTPS를 통한 전송 계층 보안에 의존함으로써 클라이언트 구현의 복잡성을 크게 줄였다.

## OAuth 2.0의 핵심 구성요소

### 역할(Roles) 정의

OAuth 2.0은 네 가지 역할을 정의하며, 각 역할이 인가 과정에서 어떻게 상호작용하는지 이해하는 것이 프로토콜 전체를 파악하는 핵심이다.

| 역할 | 설명 | 예시 |
|------|------|------|
| **Resource Owner** | 보호된 리소스에 대한 접근을 허가할 수 있는 엔티티로, 일반적으로 최종 사용자를 의미한다 | GitHub 계정을 가진 사용자 |
| **Client** | Resource Owner를 대신하여 보호된 리소스에 접근하는 애플리케이션이다 | GitHub 로그인을 지원하는 웹 애플리케이션 |
| **Resource Server** | 보호된 리소스를 호스팅하고 액세스 토큰을 사용한 요청을 수락하는 서버이다 | GitHub API 서버 |
| **Authorization Server** | Resource Owner를 인증하고 인가를 획득한 후 액세스 토큰을 발급하는 서버이다 | GitHub OAuth 서버 |

### 인증(Authentication)과 인가(Authorization)의 구분

> **OAuth 2.0은 인가 프로토콜이다**
>
> OAuth 2.0은 본질적으로 인가(Authorization) 프로토콜이며 인증(Authentication) 프로토콜이 아니다. 인증은 "당신이 누구인지" 확인하는 과정이고, 인가는 "당신이 무엇을 할 수 있는지" 결정하는 과정이다. OAuth 2.0 위에 인증 계층을 추가한 것이 바로 OpenID Connect(OIDC)이다.

## Grant Types (인가 유형)

OAuth 2.0은 다양한 사용 시나리오를 지원하기 위해 여러 Grant Type을 정의하며, 각 유형은 특정 환경과 보안 요구사항에 맞게 설계되었다.

| Grant Type | 사용 환경 | 특징 |
|------------|----------|------|
| **Authorization Code** | 서버 사이드 웹 애플리케이션 | 가장 안전하며 Refresh Token 지원 |
| **Authorization Code + PKCE** | SPA, 모바일 앱 | Client Secret 없이 안전한 인가 가능 |
| **Client Credentials** | 서버 간 통신 | 사용자 개입 없이 클라이언트 자체 인증 |
| **Device Code** | 스마트 TV, IoT 기기 | 입력 기능이 제한된 장치용 |
| **Refresh Token** | 모든 환경 | 액세스 토큰 갱신용 |

Implicit Grant와 Resource Owner Password Credentials Grant는 OAuth 2.1 초안에서 공식적으로 폐기 예정(deprecated)으로 지정되었으며, 보안상의 이유로 신규 구현에서는 사용하지 않아야 한다.

## Authorization Code Flow 상세 분석

Authorization Code Flow는 기밀 클라이언트(Confidential Client)를 위한 가장 안전한 OAuth 2.0 흐름으로, 백엔드 서버가 있는 웹 애플리케이션에서 사용된다.

![OAuth 2.0 Authorization Code Flow](oauth-flow.png)

### 1단계: 애플리케이션 등록

OAuth 흐름을 시작하기 전에 개발자는 Authorization Server에 클라이언트 애플리케이션을 등록해야 하며, 이 과정에서 애플리케이션 이름, 홈페이지 URL, Redirect URI(Authorization Callback URL)를 제공한다. 등록이 완료되면 Authorization Server는 Client ID와 Client Secret을 발급하는데, Client ID는 공개 식별자로 프론트엔드에서 사용할 수 있지만 Client Secret은 절대로 클라이언트 측 코드에 노출되어서는 안 되며 백엔드 서버에서만 안전하게 관리해야 한다.

### 2단계: 인가 요청 (Authorization Request)

사용자가 "소셜 로그인" 버튼을 클릭하면 클라이언트는 사용자를 Authorization Server의 인가 엔드포인트로 리다이렉트하며, 이 요청에는 여러 중요한 파라미터가 포함된다. `client_id`는 등록 시 발급받은 클라이언트 식별자이고, `redirect_uri`는 인가 완료 후 사용자가 돌아올 URI이며, `response_type=code`는 Authorization Code를 요청한다는 것을 나타낸다. `scope`는 요청하는 권한의 범위를 지정하고, `state`는 CSRF 공격을 방지하기 위한 무작위 문자열로 인가 응답에서 동일한 값이 반환되어야 한다.

### 3단계: 사용자 인증 및 동의

Authorization Server는 사용자에게 로그인을 요청하고(이미 로그인 상태가 아니라면), 클라이언트가 요청한 권한(scope)을 보여주며 동의를 구한다. 사용자가 동의하면 Authorization Server는 인가 코드(Authorization Code)를 생성하고, 지정된 `redirect_uri`로 사용자를 리다이렉트하면서 URL 쿼리 파라미터에 인가 코드와 state 값을 포함시킨다.

### 4단계: 인가 코드 교환 (Token Exchange)

클라이언트의 백엔드 서버는 받은 인가 코드를 Authorization Server의 토큰 엔드포인트에 제출하여 액세스 토큰으로 교환한다. 이 요청은 반드시 백엔드에서 수행해야 하는데, Client Secret이 포함되기 때문이며, 인가 코드는 일회용이고 유효 기간이 매우 짧아(일반적으로 1-10분) 탈취되더라도 악용하기 어렵다.

### 5단계: 토큰 응답

검증이 성공하면 Authorization Server는 액세스 토큰을 발급하며, 일반적으로 토큰 타입(Bearer), 만료 시간(expires_in), 권한 범위(scope), 그리고 선택적으로 Refresh Token을 함께 반환한다.

### 6단계: 리소스 접근

클라이언트는 발급받은 액세스 토큰을 HTTP Authorization 헤더에 Bearer 토큰으로 포함시켜 Resource Server의 API를 호출하고, Resource Server는 토큰을 검증한 후 요청된 리소스를 반환한다.

## PKCE (Proof Key for Code Exchange)

> **PKCE란?**
>
> PKCE(Proof Key for Code Exchange, 발음: "픽시")는 RFC 7636에 정의된 OAuth 2.0 확장으로, 원래는 모바일 앱에서 인가 코드 가로채기 공격을 방지하기 위해 설계되었으나, 현재는 SPA를 포함한 모든 공개 클라이언트(Public Client)에서 권장된다. OAuth 2.1에서는 모든 클라이언트 유형에 대해 PKCE 사용이 필수화될 예정이다.

PKCE는 동적으로 생성되는 비밀을 사용하여 인가 요청과 토큰 요청을 연결하는 방식으로 동작한다. 클라이언트는 먼저 고엔트로피 무작위 문자열인 `code_verifier`를 생성하고, 이를 SHA-256으로 해시한 후 Base64URL 인코딩한 `code_challenge`를 인가 요청에 포함시킨다. 토큰 요청 시에는 원본 `code_verifier`를 함께 전송하고, Authorization Server는 이를 해시하여 저장된 `code_challenge`와 비교함으로써 요청의 진위를 검증한다. 이 메커니즘을 통해 인가 코드를 가로챈 공격자가 토큰을 획득하는 것을 방지할 수 있다.

## 프론트엔드와 백엔드의 역할 분담

### 프론트엔드의 역할

프론트엔드는 사용자를 Authorization Server의 인가 페이지로 리다이렉트하는 역할을 담당하며, 이 과정에서 CSRF 방지를 위한 state 값을 생성하고 저장하며, PKCE를 사용할 경우 code_verifier를 생성하고 안전하게 보관해야 한다. 인가 완료 후 콜백 URL에서 인가 코드를 추출하여 백엔드에 전달하고, state 값을 검증하여 응답의 무결성을 확인한다. 백엔드로부터 받은 액세스 토큰이나 세션 정보를 적절히 저장하고 관리하는 것도 프론트엔드의 책임이다.

### 백엔드의 역할

백엔드는 OAuth 흐름에서 가장 보안에 민감한 작업들을 처리하며, Client Secret을 안전하게 보관하고 절대 클라이언트에 노출시키지 않아야 한다. 프론트엔드로부터 받은 인가 코드를 Authorization Server의 토큰 엔드포인트에 제출하여 액세스 토큰으로 교환하고, 발급받은 토큰을 사용하여 Resource Server에서 사용자 정보를 조회한다. 조회된 정보를 바탕으로 자체 시스템에서 사용자 계정을 생성하거나 기존 계정과 연동하고, 자체 인증 세션이나 JWT를 발급하여 클라이언트에 반환한다.

## 보안 고려사항

### 필수 보안 조치

OAuth 2.0 구현 시 반드시 준수해야 할 보안 조치들이 있다. 모든 통신은 HTTPS를 통해 이루어져야 하며, HTTP를 사용하면 토큰과 인가 코드가 네트워크에서 탈취될 수 있다. state 파라미터는 암호학적으로 안전한 무작위 값이어야 하며, 세션에 저장했다가 콜백에서 검증하여 CSRF 공격을 방지해야 한다. redirect_uri는 사전에 등록된 값과 정확히 일치해야 하며, 오픈 리다이렉트 취약점을 방지하기 위해 와일드카드를 허용해서는 안 된다.

### 토큰 보안

액세스 토큰은 짧은 유효 기간(일반적으로 15분에서 1시간)으로 설정하여 토큰이 탈취되더라도 피해를 최소화해야 하며, Refresh Token을 사용하여 새로운 액세스 토큰을 발급받도록 한다. Refresh Token은 HttpOnly, Secure, SameSite 속성이 설정된 쿠키에 저장하거나 백엔드 세션에 보관하는 것이 안전하며, 브라우저의 localStorage나 sessionStorage에 저장하면 XSS 공격에 취약해진다.

### Scope 최소화 원칙

애플리케이션이 필요로 하는 최소한의 권한만 요청하는 것이 보안의 기본 원칙이다. 과도한 권한 요청은 사용자의 동의율을 낮출 뿐만 아니라, 토큰이 탈취될 경우 더 큰 피해로 이어질 수 있으므로, 꼭 필요한 scope만 선별하여 요청해야 한다.

## OAuth 2.0 vs OpenID Connect

| 구분 | OAuth 2.0 | OpenID Connect |
|------|-----------|----------------|
| **목적** | 인가(Authorization) | 인증(Authentication) + 인가 |
| **토큰** | Access Token, Refresh Token | ID Token 추가 |
| **사용자 정보** | 별도 API 호출 필요 | ID Token에 포함 또는 UserInfo 엔드포인트 |
| **표준화** | 사용자 정보 형식 미정의 | 표준 클레임(sub, email, name 등) 정의 |

소셜 로그인을 구현할 때 대부분의 제공자들이 OAuth 2.0과 함께 OpenID Connect를 지원하므로, 사용자 인증이 필요한 경우에는 OIDC의 ID Token을 활용하는 것이 더 표준화된 방식이다.

## 마치며

OAuth 2.0은 현대 웹과 모바일 애플리케이션에서 제3자 인가를 처리하는 사실상의 표준이며, 정확한 이해와 올바른 구현이 서비스의 보안을 좌우한다. Authorization Code Flow는 가장 안전한 흐름이지만 구현의 복잡성이 있고, PKCE를 추가하면 공개 클라이언트에서도 안전하게 사용할 수 있다. 프론트엔드와 백엔드의 역할을 명확히 분리하고, Client Secret과 토큰을 안전하게 관리하며, 항상 최신 보안 모범 사례를 따르는 것이 성공적인 OAuth 구현의 핵심이다.
