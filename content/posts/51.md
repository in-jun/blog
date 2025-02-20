---
title: "바로 이해하는 OAuth 2.0: 프론트엔드와 백엔드에서의 역할 구분"
date: 2024-08-03T11:21:01+09:00
tags: ["oauth2.0", "인증", "github", "spring boot"]
draft: false
---

## 서론

**OAuth 2.0**에 대해 상세히 설명하려고 한다. **GitHub OAuth**를 예로 들어 전체적인 흐름을 자세히 살펴본 후, **프론트엔드**와 **백엔드**에서의 역할을 구분하여 구현 예제를 제시하겠다.

## OAuth 2.0이란?

**OAuth 2.0**은 사용자 데이터에 대한 제 3자 접근 권한을 안전하게 위임하기 위한 **표준 프로토콜**이다.
쉽게 말해, **사용자**가 다른 애플리케이션에 자신의 데이터에 대한 접근 권한을 부여할 때 사용되는 프로토콜이다.
주로 **로그인 시스템**을 구현할 때, 사용자가 다른 서비스의 계정으로 로그인할 수 있도록 하는데 사용된다.

## OAuth 2.0의 용어 정리

설명하기에 앞서, **OAuth 2.0**에서 사용되는 주요 용어를 정리하고 넘어가자.

1. **Resource Owner**: 보호된 자원의 소유자, 즉 **사용자**이다.
2. **Client**: Resource Owner를 대신하여 보호된 자원에 접근하려는 **애플리케이션**이다 (우리가 만드는 애플리케이션).
3. **Resource Server**: 보호된 자원을 호스팅하는 **서버**이다 (예: GitHub의 API 서버).
4. **Authorization Server**: 인증을 처리하고 **액세스 토큰**을 발급하는 서버이다.

## OAuth 2.0 흐름

**GitHub OAuth**를 예로 들어 전체 흐름을 단계별로 상세히 설명해 보겠다.

### 1. 애플리케이션 등록

**OAuth 흐름**을 시작하기 전에, 개발자는 **GitHub**에 애플리케이션을 등록해야 한다.

-   GitHub의 **Developer Settings**에서 새 **OAuth App**을 생성한다.
-   애플리케이션 이름, 홈페이지 URL, **Authorization callback URL**을 입력한다.
-   GitHub는 **Client ID**와 **Client Secret**을 발급한다.

### 2. 권한 요청 (Authorization Request)

사용자가 **"GitHub로 로그인"** 버튼을 클릭하면 다음 과정이 시작된다:

1. **프론트 Client**는 사용자를 GitHub의 **Authorization 엔드포인트**로 리다이렉트한다.

-   URL 구조:
    ```http
    https://github.com/login/oauth/authorize?
    client_id=YOUR_CLIENT_ID
    &redirect_uri=YOUR_CALLBACK_URL
    &scope=user
    &state=RANDOM_STRING
    ```
-   `client_id`: GitHub에서 발급받은 **Client ID**
-   `redirect_uri`: 인증 후 리다이렉트될 **URL**
-   `scope`: 요청하는 권한 범위 (예: user, repo 등)
-   `state`: **CSRF 공격**을 방지하기 위한 랜덤 문자열

2. 사용자는 GitHub **로그인 페이지**에서 자신의 credentials를 입력한다.

3. GitHub는 사용자에게 요청된 **권한**을 보여주고 **승인**을 요청한다.

### 3. 권한 부여 (Authorization Grant)

1. 사용자가 권한을 승인하면, GitHub는 사용자를 권한 요청 시 설정한 **`redirect_uri`** 로 **`code`** 와 **`state`** 쿼리를 추가해서 리다이렉트한다.

-   리다이렉트 URL 예:
    ```http
    https://your-app.com/callback?code=TEMPORARY_CODE&state=RANDOM_STRING
    ```
-   `code`: 임시 인증 코드
-   `state`: 요청 시 전송한 **state** 값과 동일해야 한다

2. **프론트 Client**는 이 **임시 코드**를 받아 **백엔드 Client**로 전송한다.

### 4. 액세스 토큰 요청 (Access Token Request)

1. **Client의 백엔드**는 받은 **임시 코드**, **client_id**, **client_secret**을 GitHub의 **토큰 엔드포인트**로 전송한다.

-   POST 요청을 `https://github.com/login/oauth/access_token`로 보낸다.
-   요청 본문 예:
    ```http
    client_id=YOUR_CLIENT_ID
    &client_secret=YOUR_CLIENT_SECRET
    &code=TEMPORARY_CODE
    &redirect_uri=YOUR_CALLBACK_URL
    ```

2. GitHub는 이 정보를 검증한다.

### 5. 액세스 토큰 발급 (Access Token Grant)

1. 검증이 성공하면, GitHub는 **액세스 토큰**을 **백엔드 Client**에게 발급한다.

-   응답 예:
    ```json
    {
        "access_token": "gho_16C7e42F292c6912E7710c838347Ae178B4a",
        "token_type": "bearer",
        "scope": "user"
    }
    ```

2. **백엔드 Client**는 이 **액세스 토큰**을 안전하게 저장한다.

### 6. 보호된 리소스 접근 (Protected Resource Access)

1. **백엔드 Client**는 발급받은 **액세스 토큰**을 사용하여 GitHub **API**에 사용자 정보를 요청한다.

-   GET 요청을 `https://api.github.com/user`로 보낸다.
-   헤더에 **액세스 토큰**을 포함시킨다:
    ```http
    Authorization: token ACCESS_TOKEN
    ```

2. GitHub는 토큰을 검증하고, 요청된 사용자 정보를 반환한다.

### 7. 사용자 인증 완료

1. **백엔드 Client**는 받은 **사용자 정보**를 사용하여 자체 시스템에서 **사용자**를 인증하거나 **계정**을 생성한다. (예: 회원가입)

2. 사용자는 이제 **Client 애플리케이션**에 로그인된 상태가 된다.

이로써 **GitHub OAuth 흐름**이 완료된다.

## 프론트엔드와 백엔드의 역할 구분

### 프론트엔드 (React)에서 해야 할 일:

1. **GitHub로 로그인** 버튼을 생성하고, 사용자가 이를 클릭하면 **GitHub의 Authorization 페이지**로 리다이렉트한다.
2. 인증 후, **콜백 URL**에서 임시 인증 코드를 받아 **백엔드**로 전송한다.

### 백엔드 (Spring Boot)에서 해야 할 일:

1. **프론트엔드**로부터 받은 **임시 인증 코드**를 사용해 **액세스 토큰**을 요청한다.
2. **액세스 토큰**을 사용해 **GitHub API**로부터 사용자 정보를 가져온다.
3. **사용자 정보**를 이용해 자체 시스템에서 **사용자**를 인증하거나 **계정**을 생성한다.

## 구현 예제

### 프론트엔드 (React) - 예시

1. **GitHub 로그인 버튼** 구현:

```jsx
import React from "react";

export const GitHubLogin = () => {
    const CLIENT_ID = "YOUR_GITHUB_CLIENT_ID";
    const REDIRECT_URI = "http://localhost:3000/callback";

    // GitHub 로그인 페이지로 리다이렉트
    const handleLogin = () => {
        window.location.href = `https://github.com/login/oauth/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=user`;
    };

    return <button onClick={handleLogin}>GitHub로 로그인</button>;
};
```

2. **콜백 처리**:

```jsx
import React, { useEffect } from "react";
import axios from "axios";

// 콜백 페이지
export const Callback = () => {
    useEffect(() => {
        // 콜백 URL에서 code 값 추출
        const code = new URLSearchParams(window.location.search).get("code");
        // 얻어온 code 값이 있으면 백엔드로 전송
        if (code) {
            axios
                .post("/api/github-callback", { code })
                .then((response) => {
                    // 로그인 성공 처리
                    console.log(response.data);
                })
                .catch((error) => {
                    console.error("Error:", error);
                });
        }
    }, []);

    return <div>Processing login...</div>;
};
```

### 백엔드 (Golang-net/http) - 예시

1. **Package**와 **상수 정의**:

```go
package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"net/url"
	"strings"
)

const (
	clientID     = "your-client-id"
	clientSecret = "your-client-secret"
	githubTokenURL = "https://github.com/login/oauth/access_token"
	githubUserURL  = "https://api.github.com/user"
)
```

2. **main 함수 정의**, 라우터를 설정하고 서버를 시작:

```go
func main() {
	http.HandleFunc("/callback", handleCallback) // 콜백 핸들러 등록
	http.ListenAndServe(":8080", nil)
}
```

3. **콜백 핸들러 구현**:

```go
func handleCallback(w http.ResponseWriter, r *http.Request) {
	code := r.URL.Query().Get("code") // 클라이언트가 보낸 code 값 쿼리에서 추출
	if code == "" {
		http.Error(w, "Missing code", http.StatusBadRequest)
		return
	}

	token, err := getAccessToken(code) // 액세스 토큰 요청 함수 호출
	if err != nil {
		http.Error(w, "Failed to get token", http.StatusInternalServerError)
		return
	}

	userInfo, err := getUserInfo(token) // 사용자 정보 요청 함수 호출
	if err != nil {
		http.Error(w, "Failed to get user info", http.StatusInternalServerError)
		return
	}

	// 원래는 받아온 사용자의 정보를 이용해 jwt 토큰을 발급하거나 세션을 생성하는 등의 작업을 수행
	// 이 예제에서는 회원가입, 로그인 작업을 생략하고 사용자 정보를 그대로 보내줌

	fmt.Fprintf(w, "User Info: %s", userInfo)
}
```

5. **액세스 토큰 요청 함수** 구현:

```go
func getAccessToken(code string) (string, error) {
    // POST 요청을 보내기 위해 URL 값 설정
    // 유저가 보낸 code 값과 클라이언트 ID, 시크릿 값 설정
	data := url.Values{
		"grant_type":    {"authorization_code"},
		"code":          {code},
		"client_id":     {clientID},
		"client_secret": {clientSecret},
	}

    // Authorization Server로 POST 요청 보내기
	resp, err := http.Post(githubTokenURL, "application/x-www-form-urlencoded", strings.NewReader(data.Encode()))
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

    // 응답받은 JSON 파싱
	var result map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
		return "", err
	}

    // 파싱한 JSON에서 액세스 토큰 추출
	return result["access_token"].(string), nil
}
```

6. **사용자 정보 요청 함수** 구현:

```go
func getUserInfo(token string) (string, error) {
	req, err := http.NewRequest("GET", githubUserURL, nil)
	if err != nil {
		return "", err
	}

    // 헤더에 받은 액세스 토큰 추가
	req.Header.Set("Authorization", "token "+token)

	// Authorization Server로 GET 요청 보내기
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	var userInfo map[string]interface{}
	if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
		return "", err
	}

    // 사용자 정보 반환
	return fmt.Sprintf("%v", userInfo), nil
}
```

## 결론

**OAuth 2.0**은 사용자 데이터에 대한 안전한 접근을 위임하기 위한 표준 프로토콜이다.
