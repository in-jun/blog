---
title: "Understanding OAuth 2.0: Role Distribution Between Frontend and Backend"
date: 2024-08-03T11:21:01+09:00
tags: ["oauth2.0", "authentication", "github", "spring boot"]
draft: false
---

## Introduction

Let's dive into a detailed explanation of **OAuth 2.0**. We'll examine the entire flow using **GitHub OAuth** as an example, then break down the implementation roles between the **frontend** and **backend** with practical examples.

## What is OAuth 2.0?

**OAuth 2.0** is a **standard protocol** for securely delegating third-party access to user data.
In simpler terms, it's a protocol used when a **user** wants to grant another application access to their data.
It's commonly used in implementing **login systems**, allowing users to sign in using their accounts from other services.

## OAuth 2.0 Terminology

Before we proceed, let's clarify the key terms used in **OAuth 2.0**:

1. **Resource Owner**: The owner of the protected resource - the **user**.
2. **Client**: The **application** seeking access to protected resources on behalf of the Resource Owner (the application we're building).
3. **Resource Server**: The **server** hosting the protected resources (e.g., GitHub's API server).
4. **Authorization Server**: The server that handles authentication and issues **access tokens**.

## OAuth 2.0 Flow

Let's break down the entire flow step by step using **GitHub OAuth** as an example.

### 1. Application Registration

Before starting the **OAuth flow**, developers need to register their application with **GitHub**.

-   Create a new **OAuth App** in GitHub's **Developer Settings**.
-   Enter the application name, homepage URL, and **Authorization callback URL**.
-   GitHub will issue a **Client ID** and **Client Secret**.

### 2. Authorization Request

When a user clicks the **"Login with GitHub"** button, the following process begins:

1. The **Frontend Client** redirects the user to GitHub's **Authorization endpoint**.

-   URL structure:
    ```http
    https://github.com/login/oauth/authorize?
    client_id=YOUR_CLIENT_ID
    &redirect_uri=YOUR_CALLBACK_URL
    &scope=user
    &state=RANDOM_STRING
    ```
-   `client_id`: **Client ID** issued by GitHub
-   `redirect_uri`: **URL** to redirect to after authentication
-   `scope`: Requested permission scope (e.g., user, repo)
-   `state`: Random string to prevent **CSRF attacks**

2. The user enters their credentials on the GitHub **login page**.

3. GitHub shows the requested **permissions** to the user and asks for **approval**.

### 3. Authorization Grant

1. After user approval, GitHub redirects to the specified **`redirect_uri`** with **`code`** and **`state`** query parameters.

-   Redirect URL example:
    ```http
    https://your-app.com/callback?code=TEMPORARY_CODE&state=RANDOM_STRING
    ```
-   `code`: Temporary authorization code
-   `state`: Must match the **state** value sent in the request

2. The **Frontend Client** receives this **temporary code** and sends it to the **Backend Client**.

### 4. Access Token Request

1. The **Backend Client** sends the **temporary code**, **client_id**, and **client_secret** to GitHub's **token endpoint**.

-   Sends a POST request to `https://github.com/login/oauth/access_token`
-   Request body example:
    ```http
    client_id=YOUR_CLIENT_ID
    &client_secret=YOUR_CLIENT_SECRET
    &code=TEMPORARY_CODE
    &redirect_uri=YOUR_CALLBACK_URL
    ```

2. GitHub validates this information.

### 5. Access Token Grant

1. Upon successful validation, GitHub issues an **access token** to the **Backend Client**.

-   Response example:
    ```json
    {
        "access_token": "gho_16C7e42F292c6912E7710c838347Ae178B4a",
        "token_type": "bearer",
        "scope": "user"
    }
    ```

2. The **Backend Client** securely stores this **access token**.

### 6. Protected Resource Access

1. The **Backend Client** uses the **access token** to request user information from the GitHub **API**.

-   Sends a GET request to `https://api.github.com/user`
-   Includes the **access token** in the header:
    ```http
    Authorization: token ACCESS_TOKEN
    ```

2. GitHub validates the token and returns the requested user information.

### 7. User Authentication Complete

1. The **Backend Client** uses the received **user information** to authenticate the user or create an account in its system (e.g., registration).

2. The user is now logged into the **Client application**.

This completes the **GitHub OAuth flow**.

## Role Distribution Between Frontend and Backend

### Frontend (React) Responsibilities:

1. Create a **Login with GitHub** button that redirects users to **GitHub's Authorization page** when clicked.
2. Receive the temporary authorization code from the **callback URL** and send it to the **backend**.

### Backend (Spring Boot) Responsibilities:

1. Request an **access token** using the **temporary authorization code** received from the **frontend**.
2. Use the **access token** to fetch user information from the **GitHub API**.
3. Authenticate the user or create an account in the system using the **user information**.

## Implementation Examples

### Frontend (React) - Example

1. Implementing the **GitHub Login Button**:

```jsx
import React from "react";

export const GitHubLogin = () => {
    const CLIENT_ID = "YOUR_GITHUB_CLIENT_ID";
    const REDIRECT_URI = "http://localhost:3000/callback";

    // Redirect to GitHub login page
    const handleLogin = () => {
        window.location.href = `https://github.com/login/oauth/authorize?client_id=${CLIENT_ID}&redirect_uri=${REDIRECT_URI}&scope=user`;
    };

    return <button onClick={handleLogin}>Login with GitHub</button>;
};
```

2. **Callback Handling**:

```jsx
import React, { useEffect } from "react";
import axios from "axios";

// Callback page
export const Callback = () => {
    useEffect(() => {
        // Extract code from callback URL
        const code = new URLSearchParams(window.location.search).get("code");
        // If code exists, send it to backend
        if (code) {
            axios
                .post("/api/github-callback", { code })
                .then((response) => {
                    // Handle successful login
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

### Backend (Golang-net/http) - Example

1. **Package** and **Constants Definition**:

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

2. Define **main function**, set up router and start server:

```go
func main() {
    http.HandleFunc("/callback", handleCallback) // Register callback handler
    http.ListenAndServe(":8080", nil)
}
```

3. Implement **callback handler**:

```go
func handleCallback(w http.ResponseWriter, r *http.Request) {
    code := r.URL.Query().Get("code") // Extract code from query parameters
    if code == "" {
        http.Error(w, "Missing code", http.StatusBadRequest)
        return
    }

    token, err := getAccessToken(code) // Call function to request access token
    if err != nil {
        http.Error(w, "Failed to get token", http.StatusInternalServerError)
        return
    }

    userInfo, err := getUserInfo(token) // Call function to request user info
    if err != nil {
        http.Error(w, "Failed to get user info", http.StatusInternalServerError)
        return
    }

    // Normally, you would issue a JWT token or create a session using the user info
    // This example simply returns the user info directly

    fmt.Fprintf(w, "User Info: %s", userInfo)
}
```

5. Implement **access token request function**:

```go
func getAccessToken(code string) (string, error) {
    // Set up URL values for POST request
    // Include user's code and client credentials
    data := url.Values{
        "grant_type":    {"authorization_code"},
        "code":          {code},
        "client_id":     {clientID},
        "client_secret": {clientSecret},
    }

    // Send POST request to Authorization Server
    resp, err := http.Post(githubTokenURL, "application/x-www-form-urlencoded", strings.NewReader(data.Encode()))
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    // Parse JSON response
    var result map[string]interface{}
    if err := json.NewDecoder(resp.Body).Decode(&result); err != nil {
        return "", err
    }

    // Extract access token from parsed JSON
    return result["access_token"].(string), nil
}
```

6. Implement **user information request function**:

```go
func getUserInfo(token string) (string, error) {
    req, err := http.NewRequest("GET", githubUserURL, nil)
    if err != nil {
        return "", err
    }

    // Add access token to header
    req.Header.Set("Authorization", "token "+token)

    // Send GET request to Authorization Server
    resp, err := http.DefaultClient.Do(req)
    if err != nil {
        return "", err
    }
    defer resp.Body.Close()

    var userInfo map[string]interface{}
    if err := json.NewDecoder(resp.Body).Decode(&userInfo); err != nil {
        return "", err
    }

    // Return user information
    return fmt.Sprintf("%v", userInfo), nil
}
```

## Conclusion

**OAuth 2.0** is a standard protocol for securely delegating access to user data. Through this implementation guide, we've seen how to properly implement GitHub OAuth in both frontend and backend systems while maintaining security and following best practices.
