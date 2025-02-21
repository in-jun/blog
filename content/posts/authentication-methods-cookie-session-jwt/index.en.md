---
title: "Getting to Know Authentication Methods (Cookies, Sessions, JWTs)"
date: 2024-06-02T14:18:40+09:00
tags: ["Authentication", "JWT", "session", "cookie"]
draft: false
---

### Authentication/Authorization

-   **Authentication**: Verifying who a user is.
-   **Authorization**: Granting a user specific permissions.

### HTTP Features

-   **Statelessness**: A feature where the client and server sever their connection after making a request and receiving a response.
-   **Request/Response:** The server forgets the client's information after the request and response cycle is complete.
-   These features necessitate additional configurations for implementing services requiring authentication.

## Cookie

> A small piece of data that the server sends to the client.

Cookies are data stored on the client and are used to maintain the client's state. Since cookies are stored on the client, they can be manipulated by the client, unlike sessions stored on the server.

Cookies function according to the following sequence:

1. The client sends a request to the server.
2. The server issues a cookie to the client.
3. The client stores the cookie and sends it to the server in the header of subsequent requests.
4. The server verifies the cookie to authenticate the client.

In modern web development, it is not recommended to handle authentication **using only cookies** due to the following reasons:

-   Easy to manipulate
-   Vulnerable to security risks
-   May increase server load
-   Have capacity limitations (4KB)

## Session

> A method of storing client information on the server.

Sessions are based on cookies. While cookies are stored on the client, sessions are stored on the server. Since sessions are stored on the server, they are more secure than cookies.

Session authentication works in the following sequence:

1. The client sends a login request to the server.
2. The server issues a unique session ID to the client.
3. The client stores the session ID in a cookie.
4. The client sends requests to the server with the session ID.
5. The server checks its session storage for the session ID.
6. If the session ID is found, the client is authenticated.

On the server, the session ID and user information are stored in key-value pairs. Spring uses HttpSession to manage sessions.

```java
@GetMapping("/session")
public String session(HttpSession session) {
    session.setAttribute("name", "session");
    return "session";
}
```

By default, session information is stored in memory, and when the server restarts, the session information is reset. To address this, store session information in a database or external storage like Redis. HttpSession allows for changing the method of session storage.

(application.properties)

```properties
spring.session.store-type=redis
```

```properties
spring.session.store-type=jdbc
```

Session authentication requires checking the session information stored on the server with every request, which can increase the server load. Additionally, it can reduce server scalability as it disrupts the stateless nature of HTTP.

To address these drawbacks, JWTs (JSON Web Tokens) are used.

## JWT

> A way to send information securely by using a JSON object.

A JWT is a token stored on the client, and its basic operation is similar to cookies. However, JWTs are signed tokens that make it difficult for clients to manipulate tokens. Since JWTs are signed using a secret key stored on the server, clients must know the secret key to manipulate tokens.

JWTs function in the following sequence:

1. The client sends a login request to the server.
2. The server issues an encrypted JWT to the client using a secret key.
3. The client stores the JWT and inserts the JWT in the header of subsequent requests.
4. The server verifies the validity of the JWT to authenticate the client.

A JWT's structure is as follows:

-   Header: Includes token type and hashing algorithm
-   Payload: Contains information known as "claims"
-   Signature: A signature that verifies the token's validity

### Header

```json
{
    "alg": "HS256",
    "typ": "JWT"
}
```

-   **alg**: Hashing algorithm
    -   Algorithm used for signing the token
    -   Some examples include HS256, RS256, etc.
-   **typ**: Token type
    -   JWT
    -   Specifies the token type

### Payload

```json
{
    "sub": "1234567890",
    "exp": 1516239022,
    "nbf": 1516239022,
    "iat": 1516239022
}
```

-   **sub**: Token subject (usually a user ID)
-   **exp**: Token expiration time (the token will be invalid after the expiration time passes)
-   **nbf**: Token activation time (the token will be invalid before it is activated)
-   **iat**: Token issuance time (indicates when the token was issued)

Headers and payloads are encoded using base64UrlEncode, so clients can decode tokens to check information. Therefore, sensitive information should not be stored in tokens.

### Signature

```
HMACSHA256(
    base64UrlEncode(header) + "." +
    base64UrlEncode(payload),
    ${SECRET} // Secret key
)
```

The signature is a hashed value calculated by combining the header and payload, then using the secret key for hashing. After receiving the JWT from the client, the server hashes the JWT then compares the result with the value hashed using the secret key to verify the token's validity.

### Drawbacks

JWTs must be manually invalidated in case of compromised security or changes to a user's permissions. For this reason, when using JWTs, setting a short expiration time is common. However, setting a short expiration time leads to the inconvenience of requiring users to log in frequently.

This drawback can be addressed by using **refresh tokens**.

## Refresh Token

> A method of issuing a new access token when the access token expires.

Refresh tokens combine session and JWT methods, and they use access and refresh tokens to handle authentication. To enhance security, access tokens are given a short expiration time, and when the access token expires, clients can send an authentication request to the server with the refresh token. The server then verifies the validity of the refresh token and, if valid, issues a new access token. Refresh tokens are stored on the server, so they can be invalidated by the server if needed.

The sequence of actions is as follows:

1. The client sends a login request to the server.
2. The server issues an access token and a refresh token to the client.
3. The client stores the access token and refresh token and sends the access token in the header when making subsequent requests to the server.
4. When the access token expires, the client sends an authentication request to the server with the refresh token.
5. The server verifies the validity of the refresh token and, if valid, issues a new access token.

So how will server load change when using JWTs and refresh tokens as opposed to session methods?

Session methods require checking session information stored on the server with every request, which can lead to increased server load. However, when using JWTs and refresh tokens, authentication requests are only sent to the server when access tokens expire, which can lead to a lower server load.

## RTR (Refresh Token Rotation)

> A method that issues a new refresh token every time.

RTR is a method that further enhances the security of traditional refresh tokens. When issuing a new access token, a new refresh token is also issued at the same time.

### RTR Workflow

1. The client sends a login request to the server.
2. The server issues an access token and a refresh token to the client.
3. When the access token expires, the client requests a new token from the server with the refresh token.
4. The server verifies the validity of the refresh token and, if valid, issues a new access token and refresh token.
5. The previous refresh token is immediately invalidated.

### Advantages of RTR

-   Prevents the reuse of stolen refresh tokens.
-   Allows for longer refresh token lifespans.
-   Improves security.

### Drawbacks of RTR

-   Implementation is complex.
-   Increases the volume of data that must be stored on the server.
-   Leads to increased network communication.

### RTR Implementation Considerations

-   All tokens of a user must be invalidated if reuse of refresh token is detected.
-   Clients must securely store newly received refresh tokens.
-   Situations of token renewal failure due to network errors must be considered.

## Summary

-   **Cookies**: Data stored on the client.
-   **Sessions**: Data stored on the server.
-   **JWTs**: Signed token method.
-   **Refresh tokens**: Method for reissuing access tokens.
-   **RTR**: A security-enhanced method of issuing new refresh tokens every time.

Each authentication method has its pros and cons, and you can choose the appropriate method based on the service's characteristics and security requirements.
