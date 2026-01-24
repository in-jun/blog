---
title: "Web Authentication with Cookies, Sessions, and JWT"
date: 2024-06-02T14:18:40+09:00
tags: ["Authentication", "Security", "JWT"]
description: "Cookie, Session, and JWT-based web authentication with refresh token strategies."
draft: false
---

Web Authentication is a core mechanism designed to solve the user identification problem arising from the stateless nature of the HTTP protocol. Since Lou Montulli of Netscape Communications invented cookies in 1994, authentication has evolved from session-based to token-based approaches. Modern web applications widely use hybrid methods combining JWT and Refresh Tokens to satisfy both security and scalability requirements.

## Understanding Authentication and Authorization

> **The Difference Between Authentication and Authorization**
>
> Authentication is the process of confirming "who you are" by verifying a user's identity, while Authorization is the process of determining "what you can do" by granting access permissions to specific resources for authenticated users. Authentication must be performed before authorization is possible, and these two concepts should be clearly distinguished.

### Real-World Examples of Authentication and Authorization

| Scenario        | Authentication              | Authorization                            |
| --------------- | --------------------------- | ---------------------------------------- |
| Office Entry    | ID card verification        | Access to specific floors/areas          |
| Banking Service | Account password            | Transfer limits, service access rights   |
| Web Application | Login (ID/PW verification)  | Admin page access, post deletion rights  |
| API Call        | API key validation          | Permission to call specific endpoints    |

## HTTP Characteristics and the Need for Authentication

> **HTTP Statelessness**
>
> The HTTP protocol inherently possesses stateless and connectionless characteristics, meaning each request is processed independently and the server does not remember information about previous requests. This design increases server scalability and simplifies implementation, but requires separate state management mechanisms to implement features that need user identification, such as maintaining login status.

The impact of HTTP statelessness on authentication is as follows:

1. **Connection Independence**: Each HTTP request is processed independently with no connection to previous requests
2. **State Non-preservation**: The server does not store information about the client after processing a request
3. **Explicit Identification Required**: Authentication information must be transmitted with every request to identify users

These characteristics led to the development of various authentication mechanisms such as Cookies, Sessions, and JWT.

## Cookie-Based Authentication

> **What is a Cookie?**
>
> A cookie is a technology invented by Lou Montulli of Netscape in 1994 to implement web shopping carts. It is a small text data file of up to 4KB that the server sends to and stores on the client (browser). Cookies are automatically sent along with subsequent requests to the same server, enabling the maintenance of state information as a core web technology.

### How Cookies Work

![Cookie Authentication Flow](cookie-flow.png)

The cookie-based authentication flow begins when a user submits login information, after which the server verifies the credentials and generates a Set-Cookie header to send to the client, causing the browser to store this cookie locally. On subsequent requests, the browser automatically includes the stored cookie in request headers, allowing the server to identify the user.

### Key Cookie Attributes

Cookies have various attributes for security and access control. The `Domain` attribute specifies which domain can receive the cookie and determines subdomain inclusion, while `Path` restricts which URL paths can access the cookie. The `Expires` or `Max-Age` attributes determine the cookie's lifetime, distinguishing between session cookies that expire when the browser closes and persistent cookies that survive browser restarts. The `Secure` attribute ensures cookies are only transmitted over HTTPS connections, preventing man-in-the-middle attacks. The `HttpOnly` attribute blocks JavaScript access to the cookie, providing protection against XSS attacks. The `SameSite` attribute controls whether cookies are sent with cross-site requests, with options including `Strict` (same-site only), `Lax` (same-site plus safe navigation), and `None` (all requests, requires Secure).

### Limitations of Cookie-Based Authentication

Using cookies alone for authentication is not recommended in modern web development due to several security vulnerabilities. Cookies are stored on the client, allowing users to potentially modify cookie values. They are susceptible to XSS (Cross-Site Scripting) and CSRF (Cross-Site Request Forgery) attacks. Cookies are limited to 4KB maximum storage. Additionally, the Same-Origin Policy prevents cookie sharing across different domains.

## Session-Based Authentication

> **What is a Session?**
>
> A session is a method of managing client state information on the server side. It issues only a unique session ID to the client while storing actual user information in server memory or database. This authentication mechanism compensates for cookie security vulnerabilities and was widely adopted as the standard authentication method in server-side languages like PHP and ASP in the late 1990s.

### How Sessions Work

![Session Authentication Flow](session-flow.png)

Session-based authentication operates by having the server create a unique session after verifying user credentials, storing user information (such as user ID, username, and roles) in server-side storage, and sending only the session ID to the client via a cookie. When subsequent requests arrive, the server looks up the session ID in its storage to retrieve the associated user information. The session can be configured with a timeout period, after which the user must re-authenticate. Upon logout, the server invalidates the session, making the session ID unusable.

### Session Storage Options

Session information is stored in server memory by default and is lost when the server restarts. In production environments, external storage solutions such as Redis or database-backed session stores are recommended to ensure session persistence across server restarts and to enable session sharing in distributed deployments.

### Advantages and Disadvantages of Session-Based Authentication

| Advantages                                   | Disadvantages                                   |
| -------------------------------------------- | ----------------------------------------------- |
| Server can forcibly expire sessions          | Increased server memory usage                   |
| Client cannot manipulate data                | Difficult horizontal scaling (Scale-out)        |
| Only session ID exposed, high security       | Session store lookup required per request       |
| Relatively simple implementation             | Violates HTTP statelessness principle           |
| Easy to modify session attributes            | Session synchronization needed in distributed environments |

## JWT (JSON Web Token) Based Authentication

> **What is JWT?**
>
> JWT (JSON Web Token) is a token-based authentication method standardized as RFC 7519 by the IETF (Internet Engineering Task Force) in 2010. It is a compact, self-contained method for securely transmitting information between parties by encoding JSON objects in Base64Url. JWT enables stateless authentication without storing state on the server and is widely used in microservice architectures and distributed systems.

### JWT Structure

JWT consists of three parts separated by dots: Header, Payload, and Signature.

```
xxxxx.yyyyy.zzzzz
  │      │     │
  │      │     └── Signature
  │      └──────── Payload
  └─────────────── Header
```

The **Header** contains metadata about the token, including the signing algorithm (such as HS256, RS256, or ES256) and token type (JWT). The **Payload** contains claims, which are statements about the user and additional data. Registered claims include `sub` (subject/user ID), `iat` (issued at), `exp` (expiration), `nbf` (not before), `iss` (issuer), and `aud` (audience). Custom claims can include user-specific data like name, email, and roles. The **Signature** is created by hashing the encoded header and payload with a secret key, ensuring token integrity and authenticity.

### JWT Signing Algorithm Comparison

| Algorithm | Type       | Key               | Use Case                       |
| --------- | ---------- | ----------------- | ------------------------------ |
| HS256     | Symmetric  | Shared secret     | Single server, trusted parties |
| RS256     | Asymmetric | Public/Private    | Microservices, public verification |
| ES256     | Asymmetric | Elliptic curve    | Mobile, IoT (smaller key size) |

### How JWT Works

![JWT Authentication Flow](jwt-flow.png)

JWT authentication begins when a user logs in and the server validates credentials, then generates a JWT containing user claims signed with a secret key. The client stores this token and includes it in the Authorization header (as a Bearer token) with each subsequent request. The server validates the token by verifying the signature and checking expiration, then extracts user information from the payload without any database lookup. This stateless nature allows any server instance to validate the token independently.

### Advantages and Disadvantages of JWT

| Advantages                                        | Disadvantages                                     |
| ------------------------------------------------- | ------------------------------------------------- |
| No state storage required on server (Stateless)   | Difficult to forcibly invalidate after issuance   |
| Easy horizontal scaling (Scale-out)               | Token size larger than session ID                 |
| Authentication info shareable across microservices| Payload exposed via Base64 encoding               |
| Verification possible without database lookup     | Can be exploited until expiration if stolen       |
| Usable across various platforms                   | UX degradation without Refresh Token              |

### JWT Security Considerations

Essential security practices for JWT include using a sufficiently long secret key (minimum 256 bits), setting short expiration times (typically 15 minutes), never including sensitive information like passwords in the payload (only include necessary identifiers), using HTTPS exclusively for token transmission, and storing tokens securely using HttpOnly cookies or in-memory variables rather than localStorage.

## Refresh Token Strategy

> **What is a Refresh Token?**
>
> A Refresh Token is a long-lived token introduced to solve the user experience degradation caused by the short expiration time of Access Tokens. It allows users to obtain a new Access Token without logging in again when the Access Token expires. Officially defined in the OAuth 2.0 specification (RFC 6749), it is used as a core component of hybrid authentication that combines the security of sessions with the scalability of JWT.

### Comparison of Access Token and Refresh Token

| Aspect                | Access Token              | Refresh Token               |
| --------------------- | ------------------------- | --------------------------- |
| Purpose               | API request authentication| Access Token reissuance     |
| Expiration Time       | Short (15 min ~ 1 hour)   | Long (7 ~ 30 days)          |
| Storage Location      | Memory or localStorage    | HttpOnly cookie             |
| Transmission Frequency| Every API request         | Only when Access Token expires |
| Server Storage        | Not required (Stateless)  | Recommended (enables invalidation) |
| Risk Level if Stolen  | Short-term                | Long-term                   |

### How Refresh Token Works

![Refresh Token Flow](refresh-token-flow.png)

The Refresh Token flow begins at login when the server issues both an Access Token (short-lived) and a Refresh Token (long-lived). The Access Token is used for API requests, while the Refresh Token is stored securely, typically in an HttpOnly cookie. When the Access Token expires and an API request returns a 401 error, the client sends the Refresh Token to a dedicated refresh endpoint. The server validates the Refresh Token against its stored records, and if valid, issues a new Access Token. Upon logout, the server deletes the stored Refresh Token, preventing further token refresh.

### Refresh Token Storage and Security

The server should store Refresh Tokens in a database with the token value, associated user ID, expiration date, and creation timestamp. The Refresh Token should be sent to the client as an HttpOnly, Secure, SameSite=Strict cookie, limiting its transmission to the refresh endpoint path only. This prevents the token from being accessed by JavaScript or sent with cross-site requests.

## RTR (Refresh Token Rotation) Strategy

> **What is RTR (Refresh Token Rotation)?**
>
> Refresh Token Rotation is a security enhancement strategy that issues a new Refresh Token along with invalidating the previous one each time a Refresh Token is used to reissue an Access Token. Recommended in the OAuth 2.0 Security Best Current Practice (RFC 6819) document, it mitigates long-term security threats from Refresh Token theft and enables detection of Token Replay Attacks.

### How RTR Works

![RTR (Refresh Token Rotation) Flow](rtr-flow.png)

RTR enhances security by rotating the Refresh Token with each use. When a client requests a token refresh, the server validates the Refresh Token, marks it as used (rather than deleting it immediately), and issues both a new Access Token and a new Refresh Token. If an attacker attempts to use a stolen Refresh Token that has already been used, the server detects this reuse attempt and can invalidate all tokens in that token family, forcing the legitimate user to re-authenticate while blocking the attacker.

### Token Reuse Detection

The key security feature of RTR is token reuse detection. Each Refresh Token is tracked with a "used" flag and belongs to a token family (representing a single login session). When a token marked as "used" is presented again, this indicates either a replay attack or a synchronization issue. As a security measure, all tokens in that family are invalidated, terminating all sessions for that user and requiring fresh authentication.

### Advantages and Disadvantages of RTR

| Advantages                                      | Disadvantages                                  |
| ----------------------------------------------- | ---------------------------------------------- |
| Prevents reuse of stolen Refresh Token          | Increased implementation complexity            |
| Enables detection of token replay attacks       | Synchronization issues on network errors       |
| Significantly improved security                 | Increased data storage requirements            |
| Can extend Refresh Token expiration             | Client must manage new tokens                  |

### RTR Implementation Considerations

When implementing RTR, several factors require attention. Network failure handling should include a retry allowance period when the token refresh response fails to reach the client. A grace period of a few seconds may be granted for the previous token to handle race conditions. Tokens issued from the same login session should be managed as a token family. Comprehensive audit logging should record all token issuance, refresh, and invalidation events for security monitoring.

## Comprehensive Comparison of Authentication Methods

| Characteristic            | Cookie    | Session   | JWT       | JWT + Refresh |
| ------------------------- | --------- | --------- | --------- | ------------- |
| **State Management**      | Client    | Server    | Client    | Hybrid        |
| **Scalability**           | High      | Low       | High      | High          |
| **Security**              | Low       | High      | Medium    | High          |
| **Force Logout**          | Impossible| Possible  | Difficult | Possible      |
| **Server Load**           | Low       | High      | Low       | Medium        |
| **Implementation Complexity** | Low   | Low       | Medium    | High          |
| **Microservice Suitability** | Low    | Low       | High      | High          |
| **Mobile App Suitability**| Low       | Medium    | High      | High          |

### Recommended Methods by Scenario

| Scenario                      | Recommended Method      | Reason                                          |
| ----------------------------- | ----------------------- | ----------------------------------------------- |
| Single Server Web Application | Session                 | Simple implementation, high security            |
| Microservice Architecture     | JWT + Refresh Token     | Stateless, authentication sharing across services|
| Mobile App                    | JWT + Refresh Token     | No cookie support needed, offline support       |
| SPA (Single Page Application) | JWT + Refresh Token     | Avoids CORS issues, API-centric                 |
| Financial/Healthcare Services | Session + Enhanced Security | Strict session control, immediate logout    |
| IoT Devices                   | JWT (long-lived)        | Resource constraints, intermittent network      |

## Security Comparison by Token Storage Location

| Storage Location  | XSS Vulnerability | CSRF Vulnerability | Recommended Use       |
| ----------------- | ----------------- | ------------------ | --------------------- |
| localStorage      | High              | None               | Not recommended       |
| sessionStorage    | High              | None               | Temporary data only   |
| Regular Cookie    | Medium            | High               | Not recommended       |
| HttpOnly Cookie   | Low               | Medium             | Refresh Token         |
| Memory (variable) | Low               | None               | Access Token          |

### Recommended Token Storage Strategy

The recommended approach stores Access Tokens in memory (JavaScript variables) where they are protected from XSS but lost on page refresh, while Refresh Tokens are stored in HttpOnly cookies managed entirely by the server. When an Access Token expires or is lost due to page refresh, the client makes a request to the refresh endpoint, and the browser automatically includes the HttpOnly cookie. If valid, a new Access Token is returned and stored in memory. This strategy minimizes exposure to both XSS and CSRF attacks.

## Conclusion

Web authentication methods have evolved from Cookies and Sessions to JWT, Refresh Tokens, and RTR, each with its own advantages and disadvantages. Cookies provide the foundation for client-side state maintenance, Sessions strengthen server-side security, and JWT provides stateless authentication and scalability in microservice environments. Refresh Tokens and RTR complement JWT's security vulnerabilities, enabling implementation of the hybrid authentication approach most recommended in practice.

When selecting an authentication method, consider the service characteristics, security requirements, scalability needs, and development complexity comprehensively. Regardless of the method chosen, security best practices such as HTTPS usage, appropriate token expiration times, secure storage, and audit logging should be applied.
