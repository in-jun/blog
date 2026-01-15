---
title: "Understanding HTTP Status Codes"
date: 2024-06-05T09:38:59+09:00
tags: ["http", "status code"]
draft: false
description: "A comprehensive guide to HTTP status codes from their history to RESTful API design. Learn about all status codes from 1xx to 5xx with practical examples, covering common codes and unique ones like 418 I'm a teapot."
---

## Overview

HTTP status codes are three-digit numeric codes that represent the server's response status to a client's request. Using appropriate status codes is essential for API design, error handling, and improving user experience. They are a core component of RESTful APIs.

This guide comprehensively covers the history and evolution of HTTP status codes, detailed explanations of five categories (1xx-5xx), practical use cases for frequently used codes, RESTful API design patterns, and browser and server behavior.

## History of HTTP Status Codes

HTTP status codes have evolved alongside the web. Each version reflected new requirements.

### HTTP/0.9 (1991)

The first HTTP version, 0.9, had no status codes. It simply returned an HTML document or closed the connection. There was no way to express error handling or response status.

### HTTP/1.0 (1996, RFC 1945)

HTTP/1.0 introduced status codes for the first time. Sixteen basic status codes were defined. The concepts of success (2xx), redirection (3xx), client error (4xx), and server error (5xx) were established. Basic codes like 200 OK, 404 Not Found, and 500 Internal Server Error were created at this time.

### HTTP/1.1 (1999, RFC 2616)

HTTP/1.1 expanded status codes to over 40. More granular status expressions became possible with codes like 100 Continue, 206 Partial Content, 409 Conflict, and 410 Gone. Informational responses (1xx) were officially added in this version. Caching-related 304 Not Modified became important.

### RFC 7231 (2014)

As the HTTP/1.1 specification was split into multiple RFCs, RFC 7231 became the modern standard for status codes. The meanings of existing codes became clearer. New codes like 308 Permanent Redirect and 426 Upgrade Required were added.

### Special Code: 418 I'm a teapot

Created on April 1, 1998, as part of HTCPCP (Hyper Text Coffee Pot Control Protocol) defined in RFC 2324. Started as an April Fool's joke, this code indicates that a teapot cannot brew coffee. While not used in practice, it is implemented as an easter egg in many frameworks and servers.

## Detailed Category Explanations

### 1xx (Informational): Informational Responses

1xx status codes indicate that the request has been received and the server is continuing to process it. These codes are not final responses. They are intermediate messages sent before the actual response.

**Real Use Cases:**

-   **100 Continue**: When uploading large files, if the client sends an `Expect: 100-continue` header, the server approves with a 100 response before the body is sent. This prevents unnecessary large transfers if the server would reject the request.
-   **103 Early Hints**: The server provides hints to the client to preload important resources (CSS, JavaScript) while preparing the final response. This can significantly improve page loading performance.

**Note**: Most web applications rarely handle 1xx codes directly. In HTTP/2, 103 Early Hints is used for performance optimization.

## 1xx (Informational): Request received and process is continuing

-   100 Continue: Server has received part of the request and the client should continue sending the request
-   101 Switching Protocols: Server has accepted the upgrade request and switched the protocol
-   102 Processing: Server has received the request and is processing it
-   103 Early Hints: Server has sent some of the response and the client can continue sending the request

### 2xx (Successful): Success

2xx status codes indicate that the client's request was successfully received, understood, and accepted. This is the most important category in RESTful APIs. Selecting the appropriate code for each situation is crucial.

**Proper Usage in RESTful APIs:**

-   **GET requests**: 200 OK (return resource), 404 Not Found (resource doesn't exist)
-   **POST requests**: 201 Created (new resource created, includes Location header), 200 OK (action performed, no resource created)
-   **PUT requests**: 200 OK (update successful, includes response body), 204 No Content (update successful, no body)
-   **DELETE requests**: 204 No Content (deletion successful), 200 OK (includes deletion info)

**Important Codes in Detail:**

-   **200 OK**: The most common success response. Used when retrieving resources with GET or returning changed resources after updating with PUT/PATCH.
-   **201 Created**: Used when a new resource is created with POST. The `Location` header must include the URI of the created resource. Example: `Location: /api/users/123`
-   **204 No Content**: The request succeeded but there is no response body. Suitable for successful DELETE or when PUT updates without needing a response. The client maintains the current view.

## 2xx (Successful): Request received successfully and understood, accepted

-   200 OK: Request has been successfully received and understood
-   201 Created: Request has been successfully received and a new resource has been created
-   202 Accepted: Request has been received but not yet completed
-   203 Non-Authoritative Information: Request has been successfully received and the response is coming from the proxy
-   204 No Content: Request has been successfully received and there is no content in the response
-   205 Reset Content: Request has been successfully received and the user agent should reset the document view
-   206 Partial Content: Request has been successfully received and only part of the response has been transmitted
-   207 Multi-Status: Request has been successfully received and multiple status codes are returned
-   208 Already Reported: Request has been successfully received and a multi-status response is returned
-   226 IM Used: Request has been successfully received and an instance manipulated multi-status response is returned

### 3xx (Redirection): Redirection

3xx status codes indicate that the client needs to take additional action to complete the request. These are mainly used for URL changes, caching, and resource movement.

**Differences between 301 vs 302 vs 307 vs 308:**

| Code | Type | HTTP Method Preservation | Caching | Use Cases |
|------|------|--------------------------|---------|-----------|
| 301 Moved Permanently | Permanent redirect | Not preserved (POST→GET conversion possible) | Browser caching | Domain change, URL structure change, SEO |
| 302 Found | Temporary redirect | Not preserved (POST→GET conversion possible) | No caching | Temporary page movement |
| 307 Temporary Redirect | Temporary redirect | Preserved (POST stays POST) | No caching | Maintenance page, POST request redirect |
| 308 Permanent Redirect | Permanent redirect | Preserved (POST stays POST) | Browser caching | RESTful API endpoint permanent change |

**Important Codes in Detail:**

-   **301 Moved Permanently**: The URL has permanently changed. Search engines index the new URL and transfer the SEO score from the old URL. The `Location` header includes the new URL. Examples: HTTP→HTTPS transition, adding/removing www subdomain
-   **302 Found**: A temporary redirect. The original URL remains bookmarked. Search engines keep the existing URL. Used for returning to the original page after login, A/B testing, etc.
-   **304 Not Modified**: The resource has not been modified. The client uses the cached version. Used with `If-None-Match` (ETag) and `If-Modified-Since` (Last-Modified) headers to save bandwidth.

**SEO Impact**: 301 transfers link juice, but 302 does not. For permanent moves, you must use 301.

## 3xx (Redirection): Client needs to take further action

-   300 Multiple Choices: Request has multiple options
-   301 Moved Permanently: Requested resource has been permanently moved to a new URL
-   302 Found: Requested resource has been temporarily moved to a different URL
-   303 See Other: Requested resource can be found at a different URL
-   304 Not Modified: Requested resource has not been modified
-   305 Use Proxy: Requested resource must be accessed through a proxy
-   306 Switch Proxy: Requested resource must be accessed through a different proxy
-   307 Temporary Redirect: Requested resource has been temporarily moved to a different URL
-   308 Permanent Redirect: Requested resource has been permanently moved to a new URL

### 4xx (Client Error): Client Errors

4xx status codes indicate there is a problem with the client's request. The same error will repeat unless the client modifies the request.

**Most Common Errors and Solutions:**

**400 Bad Request**
-   **Causes**: Invalid JSON format, missing required fields, invalid data types
-   **Solution**: Validate request body and headers. Include detailed error messages in the response body
-   **Example Response**:
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
-   **401**: Authentication is required or credentials are invalid. Must include `WWW-Authenticate` header. Can succeed after logging in.
-   **403**: Authenticated but lacks permission. Logging in again won't resolve it. Used when accessing resources requiring admin privileges.
-   **Real Examples**: Regular user accessing admin page → 403, Unauthenticated user accessing protected resource → 401

**404 Not Found**
-   **When to Use**: Resource doesn't exist or client doesn't have permission to know
-   **Soft 404 Warning**: Don't return 200 OK with "Not Found" message. This confuses search engines and clients.
-   **Security Consideration**: Return 404 instead of 403 to hide resource existence (for sensitive cases)

**405 Method Not Allowed**
-   **Meaning**: Resource exists but doesn't support that HTTP method
-   **Required Header**: `Allow: GET, POST, HEAD` header indicates allowed methods
-   **Example**: Sending DELETE to `/users/123` when it's a read-only API

**409 Conflict**
-   **Use Cases**: Version conflicts, duplicate resource creation attempts, optimistic locking failures
-   **Examples**: Second signup attempt with same email, editing a document that another user modified first
-   **Resolution**: Client fetches latest state and retries

**429 Too Many Requests**
-   **Purpose**: Rate limiting, API usage restrictions
-   **Required Headers**: `Retry-After: 3600` (in seconds) or `X-RateLimit-Reset: 1640995200` (timestamp)
-   **Additional Headers**: `X-RateLimit-Limit: 100`, `X-RateLimit-Remaining: 0`
-   **Strategy**: Retry with exponential backoff

## 4xx (Client Error): There is an error on the client's side

-   400 Bad Request: Request is malformed
-   401 Unauthorized: Authentication is required
-   402 Payment Required: Payment is required
-   403 Forbidden: Request is forbidden
-   404 Not Found: Requested resource does not exist
-   405 Method Not Allowed: Requested method is not allowed
-   406 Not Acceptable: Requested resource is not acceptable by the client
-   407 Proxy Authentication Required: Proxy authentication is required
-   408 Request Timeout: Request timed out
-   409 Conflict: Request conflicts with the current state of the server
-   410 Gone: Requested resource is no longer available
-   411 Length Required: Content-Length header is required
-   412 Precondition Failed: Request precondition failed
-   413 Payload Too Large: Request is too large
-   414 URI Too Long: URI is too long
-   415 Unsupported Media Type: Unsupported media type
-   416 Range Not Satisfiable: Range is not satisfiable
-   417 Expectation Failed: Request failed
-   418 I'm a teapot: I am a teapot
-   421 Misdirected Request: Request is misdirected
-   422 Unprocessable Entity: Unprocessable entity
-   423 Locked: Resource is locked
-   424 Failed Dependency: Dependency failed
-   425 Too Early: Request is premature
-   426 Upgrade Required: Upgrade is required
-   428 Precondition Required: Precondition is required
-   429 Too Many Requests: Too many requests
-   431 Request Header Fields Too Large: Request header fields are too large
-   451 Unavailable For Legal Reasons: Unavailable for legal reasons

### 5xx (Server Error): Server Errors

5xx status codes indicate that the server failed to process a valid request. The client is not responsible. The server side must resolve it.

**Server Error Handling Strategies:**

**500 Internal Server Error**
-   **Meaning**: An unexpected error occurred on the server. The most common server error.
-   **Causes**: Unhandled exceptions, database connection failures, code bugs
-   **Required Actions**:
    - Log the error to a logging system (include stack trace and request info)
    - Don't expose specific error details to the client (security)
    - Set up monitoring alerts
-   **Response Example**: `{"error": "An unexpected error occurred. Please try again later.", "error_id": "err_123456"}`

**502 Bad Gateway**
-   **Meaning**: A gateway or proxy server received an invalid response from the upstream server
-   **Scenarios**: Nginx fails to receive response from backend application server, connection issues between load balancer and server
-   **Resolution**: Check upstream server status, adjust timeout settings

**503 Service Unavailable**
-   **When to Use**: Server temporarily cannot handle requests (overload, maintenance, deploying)
-   **Required Header**: `Retry-After: 3600` header indicates when to retry
-   **Real Use**: During deployment health check failures, server restart, database migration
-   **vs 500**: 503 is temporary and expected, 500 is unexpected error

**504 Gateway Timeout**
-   **Meaning**: Gateway or proxy didn't receive a timely response from upstream server
-   **Causes**: Backend server is too slow or not responding, network issues
-   **Resolution**: Adjust timeout values, optimize queries, switch to async processing

**Monitoring Metrics:**
-   **4xx Rate**: Sudden increase in client error rate suggests API changes or client bugs
-   **5xx Rate**: Server error rate above 1% requires immediate investigation
-   **429 Occurrence**: Check if rate limit settings are appropriate

## 5xx (Server Error): There is an error on the server's side

-   500 Internal Server Error: Server has encountered an error
-   501 Not Implemented: Request is not implemented
-   502 Bad Gateway: Gateway is malformed
-   503 Service Unavailable: Service is unavailable
-   504 Gateway Timeout: Gateway timed out
-   505 HTTP Version Not Supported: HTTP version is not supported
-   506 Variant Also Negotiates: Variant also negotiates
-   507 Insufficient Storage: Insufficient storage
-   508 Loop Detected: Loop detected
-   510 Not Extended: Not extended
-   511 Network Authentication Required: Network authentication required
-   599 Network Connect Timeout Error: Network connect timeout error

## RESTful API Design Guide

Using appropriate HTTP status codes in RESTful APIs greatly improves API intuitiveness and developer experience.

### Status Code Mapping for CRUD Operations

| Operation | HTTP Method | On Success | Resource Not Found | Errors |
|-----------|-------------|------------|-------------------|--------|
| Create | POST | 201 Created (Location header) | - | 400 Bad Request, 409 Conflict |
| Read (single) | GET | 200 OK | 404 Not Found | 403 Forbidden |
| Read (list) | GET | 200 OK (includes empty array) | - | - |
| Update (full) | PUT | 200 OK, 204 No Content | 404 Not Found | 400 Bad Request, 409 Conflict |
| Update (partial) | PATCH | 200 OK, 204 No Content | 404 Not Found | 400 Bad Request, 409 Conflict |
| Delete | DELETE | 204 No Content, 200 OK | 404 Not Found (optional) | 403 Forbidden |

### POST: Choosing Between 201 and 200

**Use 201 Created:**
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

**Use 200 OK (action performed, no resource created):**
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

### Error Response Body Structure

A consistent error response format is crucial for client developers.

**Recommended Structure:**
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

## Unusual and Interesting Status Codes

### 418 I'm a teapot

Defined on April 1, 1998, as part of HTCPCP (Hyper Text Coffee Pot Control Protocol) in RFC 2324. This joke code indicates that a teapot cannot brew coffee. It's actually implemented in many frameworks.

**Real Use Cases:**
-   Used in Google's 2014 April Fool's project
-   Supported in Node.js Express framework
-   Developers often use it in API documentation examples and test code

### 451 Unavailable For Legal Reasons

Inspired by Ray Bradbury's novel "Fahrenheit 451". Officially added in 2015 as RFC 7725. Used when content cannot be provided for legal reasons.

**Real Use Cases:**
-   Content removed for copyright infringement
-   Content blocked by government censorship
-   Personal information deleted per GDPR requests
-   Geo-restricted content

### 103 Early Hints

Added in 2017 as RFC 8297 for performance optimization. It allows clients to preload needed resources while the server prepares the final response.

**Performance Improvement Example:**
```http
HTTP/1.1 103 Early Hints
Link: </style.css>; rel=preload; as=style
Link: </script.js>; rel=preload; as=script

(Server preparing response...)

HTTP/1.1 200 OK
Content-Type: text/html
...
```

This allows browsers to download CSS and JavaScript before parsing HTML. Page loading speed can improve by 20-30%.

### 425 Too Early

Added in 2018 as RFC 8470. It prevents TLS 1.3 0-RTT (zero round-trip time) replay attacks. Used when the server judges that a request has the risk of being a replay attack.

## Browsers and HTTP Status Codes

Browsers automatically perform specific actions based on status codes.

### Automatic Redirect Handling

When browsers receive 3xx status codes, they automatically navigate to the URL in the `Location` header. Users are unaware of this process.

-   **301, 302, 307, 308**: Automatically redirect
-   **303**: Convert POST request to GET and redirect
-   **304**: Use cached resource, no new request

### Authentication Popup

When receiving a 401 status code with `WWW-Authenticate` header, browsers automatically display an authentication dialog.

```http
HTTP/1.1 401 Unauthorized
WWW-Authenticate: Basic realm="User Area"
```

This method is useful for simple authentication. Modern web applications prefer form-based authentication or OAuth.

### Caching Behavior

-   **200 OK**: Cached according to `Cache-Control` and `Expires` headers
-   **301 Moved Permanently**: Browser permanently remembers and caches the new URL
-   **304 Not Modified**: Use cached version, save network traffic

## Monitoring and Error Handling Best Practices

### Status Code Rate Monitoring

Track the following metrics to understand API health status.

**Key Metrics:**
-   **2xx Rate**: Target to maintain above 95%
-   **4xx Rate**: Sudden increases signal API changes or client issues
-   **5xx Rate**: Keep below 1%, alert immediately if exceeded
-   **Per-Endpoint Rates**: Identify specific problematic APIs

### Error Logging Strategy

**Server Error (5xx) Logging:**
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

**Client Error (4xx) Logging (Optional):**
-   400, 422: Analyze validation failure patterns
-   401, 403: Track authentication/permission issues
-   404: Identify incorrect URL patterns
-   429: Determine need for rate limit adjustment

### User-Friendly Error Pages

Provide appropriate guidance for each error type.

**404 Page:**
-   Clear message: "Page not found"
-   Provide search functionality
-   Links to popular pages
-   Return to home button

**500 Page:**
-   Apology message: "A temporary error occurred"
-   Retry button
-   Customer support contact
-   Provide reference number (error_id)

**503 Page:**
-   Maintenance notice: "System under maintenance"
-   Expected recovery time
-   Status page link

## Reference

-   [https://developer.mozilla.org/en-US/docs/Web/HTTP/Status](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

> 418 I'm a teapot: This status code was defined on April 1, 1998, by the IETF as an extension to the Hyper Text Coffee Pot Control Protocol (HTCPCP) and is intended to be used to test if a coffee pot is connected and has hot water available. It is a joke and not meant to be used in real applications.
