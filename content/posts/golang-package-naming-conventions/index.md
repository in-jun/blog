---
title: "Go 패키지 네이밍 규칙"
date: 2025-02-15T21:40:48+09:00
tags: ["Go", "프로그래밍"]
description: "Go 언어의 패키지 이름 작성 규칙과 모범 사례를 설명한다."
draft: false
---

> 이 글은 Go 공식 블로그의 "Package Names"와 Go 코드 리뷰 코멘트, 표준 라이브러리 설계 사례를 참고하여 작성했다.

## Go 패키지 설계 철학

Go의 패키지 시스템은 다른 언어들과 비교하여 독특한 철학을 가지고 있으며, 이는 Go 언어의 설계 원칙인 단순성(Simplicity)과 명확성(Clarity)을 반영한다. Go는 Java처럼 복잡한 패키지 계층 구조나 C++의 네임스페이스 시스템을 채택하지 않았으며, 대신 패키지 경로(Package Path)와 패키지 이름(Package Name)을 분리하여 간결하면서도 표현력 있는 코드를 작성할 수 있도록 설계되었다.

Go의 패키지 컨벤션은 디렉토리 구조나 아키텍처 패턴에 대한 엄격한 규칙을 강제하지 않으며, 이는 Go 팀이 의도적으로 선택한 설계 철학이다. Rob Pike와 Ken Thompson을 비롯한 Go 언어 창시자들은 프로그래머에게 유연성을 제공하면서도 명확한 가이드라인을 제시하는 접근 방식을 선호했으며, 이러한 철학은 표준 라이브러리의 패키지 구조에서 실제로 확인할 수 있다. Go의 패키지 컨벤션은 다음과 같은 핵심 원칙들을 중심으로 구성되어 있다.

## 1. 책임 중심 패키지 구성 (Organize by Responsibility)

Go에서는 모든 인터페이스를 `interfaces` 패키지에 모으거나 모든 데이터 구조를 `models` 패키지에 집중시키는 타입 중심 구조를 지양하며, 이는 Java의 전통적인 패키지 구조 방식에서 흔히 볼 수 있는 안티패턴이다. 대신 Go는 "Organize by responsibility" 원칙에 따라 각 패키지가 특정 도메인의 책임을 담당하도록 구성하는 것을 권장하며, 이는 응집도(Cohesion)를 높이고 결합도(Coupling)를 낮추는 소프트웨어 설계의 기본 원칙과 일치한다.

### 안티패턴: 타입별 패키지 구성

많은 Go 초보자들이 다른 언어의 경험을 바탕으로 다음과 같은 구조를 만드는 실수를 범한다.

```
myapp/
├── interfaces/
│   ├── user.go
│   └── order.go
├── models/
│   ├── user.go
│   └── order.go
└── services/
    ├── user.go
    └── order.go
```

이러한 구조는 특정 기능을 수정할 때 여러 패키지를 동시에 변경해야 하므로 유지보수가 어렵고, 패키지 간 순환 의존성(Circular Dependency) 문제가 발생하기 쉬우며, 코드의 응집도가 낮아 관련 로직을 찾기 어렵다.

### 권장 패턴: 책임별 패키지 구성

대신 각 도메인의 책임을 중심으로 패키지를 구성하면 관련 타입과 로직이 하나의 패키지에 모여 응집도가 높아진다.

```
myapp/
├── user/
│   ├── user.go        // User 타입과 관련 메서드
│   ├── repository.go  // 저장소 인터페이스와 구현
│   └── service.go     // 비즈니스 로직
└── order/
    ├── order.go       // Order 타입과 관련 메서드
    ├── repository.go
    └── service.go
```

이 구조에서는 사용자 관련 모든 코드가 `user` 패키지에 모여 있고, 주문 관련 모든 코드가 `order` 패키지에 모여 있어 기능을 수정하거나 이해할 때 하나의 패키지만 확인하면 된다. Go 표준 라이브러리의 `net/http` 패키지도 이러한 원칙을 따르며, HTTP 서버, 클라이언트, 핸들러, 요청/응답 타입 등 HTTP와 관련된 모든 것을 하나의 패키지로 제공한다.

## 2. 패키지 경로를 통한 네임스페이스 활용

Go는 패키지 경로(Package Path) 자체를 표현 수단과 네임스페이스로 활용하며, 이는 Go의 독특한 특징 중 하나이다. 패키지 경로는 단순히 파일 시스템의 위치를 나타내는 것이 아니라 패키지의 목적과 범주를 표현하는 의미론적 도구로 사용되며, Go 표준 라이브러리는 이 원칙을 일관되게 적용한 대표적인 사례이다.

### 표준 라이브러리의 계층적 네임스페이스

Go 표준 라이브러리는 관련 패키지들을 상위 디렉토리로 그룹화하여 명확한 네임스페이스를 제공한다.

-   `crypto/`: 암호화 관련 패키지들의 네임스페이스로, `crypto/aes`, `crypto/rsa`, `crypto/sha256` 등이 포함되며 모든 암호화 알고리즘과 기능을 일관된 경로 아래 제공한다.
-   `encoding/`: 데이터 인코딩 관련 패키지들의 네임스페이스로, `encoding/json`, `encoding/xml`, `encoding/base64` 등이 포함되며 다양한 인코딩 형식을 지원한다.
-   `net/`: 네트워크 관련 패키지들의 네임스페이스로, `net/http`, `net/url`, `net/rpc` 등이 포함되며 모든 네트워크 프로그래밍 기능을 제공한다.

### 동일 이름 패키지의 명확한 구분

패키지 경로를 활용하면 동일한 이름을 가진 패키지들도 목적과 용도를 명확히 구분할 수 있으며, 대표적인 예시가 `pprof` 패키지이다.

-   `runtime/pprof`: 런타임 프로파일링 데이터를 생성하고 저장하는 저수준 패키지로, 프로파일링 데이터를 파일로 저장하거나 직접 제어해야 하는 경우에 사용한다.
-   `net/http/pprof`: HTTP 서버를 통해 프로파일링 데이터를 제공하는 고수준 패키지로, 웹 브라우저에서 프로파일링 정보를 확인할 수 있도록 HTTP 핸들러를 등록한다.

두 패키지 모두 `pprof`라는 이름을 사용하지만 경로를 통해 `runtime/pprof`는 런타임 관련 기능을, `net/http/pprof`는 HTTP 서버 관련 기능을 제공한다는 것을 명확히 알 수 있으며, 사용자는 import 경로만 보고도 어떤 패키지를 사용해야 할지 판단할 수 있다.

### 프로젝트 내 네임스페이스 구성

표준 라이브러리의 패턴을 프로젝트에 적용하면 코드 구조가 명확해지며, 예를 들어 전자상거래 시스템에서는 다음과 같이 구성할 수 있다.

```
myapp/
├── payment/
│   ├── stripe/      // Stripe 결제 구현
│   ├── paypal/      // PayPal 결제 구현
│   └── payment.go   // 공통 인터페이스
└── storage/
    ├── postgres/    // PostgreSQL 구현
    ├── mongodb/     // MongoDB 구현
    └── storage.go   // 공통 인터페이스
```

이 구조에서 `payment` 디렉토리는 결제 관련 모든 구현을 그룹화하고, `storage` 디렉토리는 저장소 관련 모든 구현을 그룹화하여 관련 패키지들을 쉽게 찾을 수 있다.

## 3. 중복 표현 제거 (Avoid Stuttering)

Go에서는 패키지 이름과 내보낸(Exported) 타입이나 함수의 이름이 결합되어 사용되므로, 패키지 경로가 이미 제공하는 정보를 패키지 이름이나 타입 이름에서 반복하지 않는 것이 중요하다. 이를 "stuttering(말더듬)"을 피한다고 표현하며, 코드의 간결성과 가독성을 크게 향상시킨다.

### 안티패턴: 말더듬 (Stuttering)

다음은 흔히 볼 수 있는 말더듬 패턴의 예시이다.

```go
// 나쁜 예: 패키지 이름과 타입 이름의 중복
package user
type UserService struct {}    // user.UserService (중복!)
type UserRepository struct {} // user.UserRepository (중복!)

// 나쁜 예: encoding/json 패키지를 잘못 모방한 경우
package json
type JSONEncoder struct {}    // json.JSONEncoder (중복!)
```

이러한 코드는 사용 시 `user.UserService`나 `json.JSONEncoder`처럼 `user`와 `json`이라는 정보가 두 번 반복되어 불필요하게 장황해진다.

### 권장 패턴: 간결한 네이밍

패키지 이름이 이미 컨텍스트를 제공하므로, 타입과 함수 이름은 간결하게 작성한다.

```go
// 좋은 예: 간결하고 명확한 이름
package user
type Service struct {}    // user.Service (명확하고 간결)
type Repository struct {} // user.Repository (명확하고 간결)

// 표준 라이브러리의 예시
package bytes
type Buffer struct {} // bytes.Buffer (완벽)

package http
type Request struct {}  // http.Request (완벽)
type Response struct {} // http.Response (완벽)
```

이 코드는 사용 시 `user.Service`, `bytes.Buffer`, `http.Request`처럼 자연스럽고 읽기 쉬우며, 패키지 이름과 타입 이름이 결합되었을 때 가장 명확한 의미를 전달한다.

### 함수 네이밍에서의 중복 제거

함수 이름에서도 동일한 원칙을 적용하며, 패키지 이름이 이미 제공하는 컨텍스트를 반복하지 않는다.

```go
// 나쁜 예
package log
func LogMessage(msg string) {} // log.LogMessage (중복!)

// 좋은 예
package log
func Print(msg string) {}      // log.Print (간결하고 명확)
func Printf(format string, args ...interface{}) {} // log.Printf
```

표준 라이브러리의 `log` 패키지는 `LogMessage` 대신 `Print`, `Printf`, `Println` 같은 간결한 이름을 사용하며, 사용 시 `log.Print()`로 자연스럽게 읽힌다.

## 4. 패키지 이름 선택 원칙

패키지 이름 자체도 Go의 철학을 따르며, 간결하고 명확하며 소문자만 사용하는 것이 원칙이다.

### 소문자와 단일 단어 선호

Go 패키지 이름은 소문자만 사용하며 언더스코어(`_`)나 대문자를 포함하지 않는다. 가능하면 단일 단어를 사용하고, 여러 단어가 필요한 경우에도 단어를 붙여쓴다.

```go
// 좋은 예
package httputil  // HTTP 유틸리티
package strconv   // String Conversion
package filepath  // File Path

// 나쁜 예
package http_util  // 언더스코어 사용 (지양)
package HttpUtil   // 대문자 사용 (불가능)
package stringconversion // 너무 긴 이름
```

### 명확하고 설명적인 이름

패키지 이름은 해당 패키지가 무엇을 하는지 명확히 전달해야 하며, 너무 일반적이거나 모호한 이름은 피해야 한다.

```go
// 좋은 예
package user      // 사용자 관리
package payment   // 결제 처리
package auth      // 인증

// 나쁜 예
package util      // 너무 일반적
package common    // 너무 모호
package helpers   // 목적이 불명확
```

`util`, `common`, `helpers` 같은 이름은 패키지의 목적을 명확히 전달하지 못하며, 시간이 지나면서 관련 없는 코드들이 모이는 "쓰레기통" 패키지가 되기 쉽다.

### 축약어 사용 원칙

Go에서는 널리 알려진 축약어를 사용하는 것을 허용하며, 표준 라이브러리에서도 이러한 패턴을 확인할 수 있다.

```go
package fmt       // format
package strconv   // string conversion
package syscall   // system call
package regexp    // regular expression
```

단, 축약어는 해당 도메인에서 일반적으로 사용되는 것이어야 하며, 임의로 만든 축약어는 피해야 한다.

## 실전 적용 사례

### 표준 라이브러리 분석

Go 표준 라이브러리는 이러한 원칙들을 완벽하게 적용한 사례이며, 몇 가지 예시를 살펴보자.

**`encoding/json` 패키지:**
- 패키지 경로: `encoding/json` (JSON 인코딩을 명확히 표현)
- 주요 함수: `json.Marshal()`, `json.Unmarshal()` (간결하고 명확)
- 타입: `json.Encoder`, `json.Decoder` (말더듬 없음)

**`net/http` 패키지:**
- 패키지 경로: `net/http` (네트워크의 HTTP 프로토콜)
- 주요 타입: `http.Client`, `http.Server`, `http.Request` (간결)
- 주요 함수: `http.Get()`, `http.Post()` (말더듬 없이 명확)

이러한 패턴은 20년 가까이 사용되면서 검증된 설계이며, 새로운 Go 프로젝트에서도 동일한 원칙을 따르는 것이 권장된다.

## 결론

Go의 패키지 컨벤션은 단순한 규칙이 아니라 코드의 명확성, 유지보수성, 그리고 Go 커뮤니티 전체의 일관성을 위한 가이드라인이며, 이러한 원칙들은 Go 언어 창시자들의 수십 년간의 프로그래밍 경험과 철학이 반영된 결과이다. 책임 중심의 패키지 구성은 높은 응집도와 낮은 결합도를 달성하고, 패키지 경로를 통한 네임스페이스 활용은 명확한 구조를 제공하며, 중복 표현 제거는 간결하고 읽기 쉬운 코드를 만든다.

각 프로젝트의 맥락과 규모에 맞게 이러한 원칙들을 적절히 적용하는 것이 중요하며, 작은 프로젝트에서는 간단한 구조로 시작하여 필요에 따라 점진적으로 확장하고, 큰 프로젝트에서는 처음부터 명확한 패키지 경계와 책임 분리를 고려해야 한다. Go 표준 라이브러리와 유명한 오픈 소스 프로젝트들을 참고하면 실제 적용 사례를 배울 수 있으며, 이는 Go다운 코드를 작성하는 데 큰 도움이 된다.

> 참고: https://go.dev/blog/package-names
