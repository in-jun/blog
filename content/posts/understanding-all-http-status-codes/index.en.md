---
title: "Understanding HTTP Status Codes"
date: 2024-06-05T09:38:59+09:00
tags: ["HTTP", "Protocol", "Web"]
draft: false
description: "HTTP status code categories and meanings."
---

HTTP status codes are standardized three-digit numeric response codes that a server returns to indicate the result of processing a client's request. These codes play a crucial role in all HTTP-based communications including web browsers, API clients, and search engines, clearly conveying whether requests succeeded, require redirection, or encountered client or server-side errors. In RESTful API design, selecting appropriate status codes is a key factor that significantly impacts API intuitiveness and developer experience.

> **What is an HTTP Status Code?**
>
> An HTTP status code is a three-digit numeric code that represents the server's response status to a client's request. The first digit determines the response category, classifying codes into five ranges: 1xx (informational), 2xx (success), 3xx (redirection), 4xx (client error), and 5xx (server error).

## History and Evolution of HTTP Status Codes

HTTP status codes have evolved alongside the web, progressing from simple early forms to a sophisticated system that meets the requirements of modern complex web applications.

### The HTTP/0.9 Era (1991)

HTTP version 0.9, the first HTTP version developed by Tim Berners-Lee at CERN, had no concept of status codes at all. It only supported the GET method and simply returned HTML documents or closed the connection, providing no way to express error handling or response status. HTTP during this period was merely a protocol for transferring hypertext documents, lacking the metadata and header information that are essential in modern web.

### The Emergence of HTTP/1.0 (1996, RFC 1945)

HTTP/1.0 was the first version to introduce status codes. It defined 16 basic status codes, establishing the category system of success (2xx), redirection (3xx), client error (4xx), and server error (5xx). The most fundamental and widely used codes such as 200 OK, 301 Moved Permanently, 404 Not Found, and 500 Internal Server Error were born at this time. This version added headers to requests and responses, enabling metadata like Content-Type and Content-Length to be transmitted, and also introduced the POST method for data transmission.

### The Expansion of HTTP/1.1 (1999, RFC 2616)

HTTP/1.1 significantly expanded status codes to over 40, enabling more granular status representation. It introduced capabilities like 100 Continue for pre-validation of large requests, 206 Partial Content for range request support, 409 Conflict for resource collision detection, and 410 Gone for permanent deletion indication, handling various scenarios needed in practice. The 1xx category for informational responses was officially added, and persistent connections (Keep-Alive) and pipelining were introduced, greatly improving performance. The Host header became mandatory, enabling multiple domains to be hosted on a single IP address.

### Establishment of Modern Standards (2014, RFC 7231)

As the HTTP/1.1 specification was split from RFC 2616 into multiple documents (RFC 7230-7235), RFC 7231 became the modern standard for status codes. The meanings of existing codes were defined more clearly, and new codes like 308 Permanent Redirect (permanent redirection that preserves the method) and 426 Upgrade Required (protocol upgrade needed) were added to meet modern web requirements such as HTTPS transition and WebSocket upgrades.

### The HTTP/2 and HTTP/3 Era

HTTP/2 (2015, RFC 7540) and HTTP/3 (2022, RFC 9114) greatly improved transport layer efficiency but did not change the status code system itself. Instead, new codes for performance optimization like 103 Early Hints (RFC 8297, 2017) were added, allowing clients to preload needed resources while the server prepares the final response.

## 1xx (Informational): Informational Responses

1xx status codes are intermediate responses indicating that the request has been received and the server is continuing to process it. They are not final responses and are sent before the actual response to inform the client of progress.

> **Characteristics of 1xx Responses**
>
> 1xx responses are automatically handled by typical HTTP client libraries and are rarely dealt with directly in application code. However, they play an important role in large file upload scenarios and performance optimization.

### Key 1xx Status Codes

| Code | Name | Description | Practical Use |
|------|------|-------------|---------------|
| 100 | Continue | Client may continue sending request body | Server approval check before large file upload |
| 101 | Switching Protocols | Server accepts protocol change request | WebSocket upgrade, HTTP/2 transition |
| 102 | Processing | Server has received and is processing request | Long-running operations in WebDAV |
| 103 | Early Hints | Provides resource hints before final response | Performance optimization via CSS/JS preload |

### How 100 Continue Works

When uploading large files, if the client sends a request with the `Expect: 100-continue` header, the server first examines only the request headers to determine if it can process the request. If processable, it sends a 100 Continue response so the client can transmit the body. Otherwise, it immediately returns a 4xx or 5xx error, preventing unnecessary large data transmission.

```http
POST /upload HTTP/1.1
Host: api.example.com
Content-Type: multipart/form-data
Content-Length: 104857600
Expect: 100-continue

(Waiting for server's 100 Continue response)

HTTP/1.1 100 Continue

(File body transmission begins)
```

### Performance Optimization with 103 Early Hints

103 Early Hints allows browsers to download important resources like CSS, JavaScript, and fonts in advance while the server generates the final response (database queries, template rendering, etc.). This can improve page loading speed by 20-30% and works more effectively with HTTP/2 and above.

```http
HTTP/1.1 103 Early Hints
Link: </styles/main.css>; rel=preload; as=style
Link: </scripts/app.js>; rel=preload; as=script
Link: </fonts/roboto.woff2>; rel=preload; as=font

(Server preparing response...)

HTTP/1.1 200 OK
Content-Type: text/html
...
```

## 2xx (Successful): Success Responses

2xx status codes indicate that the client's request was successfully received, understood, and accepted. This is the most important category in RESTful APIs, where selecting the appropriate code for each situation determines API intuitiveness and consistency.

> **Importance of 2xx Response Selection**
>
> Using only 200 OK for all success responses is a bad API design practice. Selecting appropriate codes for each situation—201 Created (resource creation), 204 No Content (no body), 202 Accepted (async processing)—ensures clients can correctly interpret responses.

### Key 2xx Status Codes

| Code | Name | Description | RESTful API Usage |
|------|------|-------------|-------------------|
| 200 | OK | Request successful, result in response body | Resource retrieval with GET, result return after PUT/PATCH update |
| 201 | Created | New resource creation successful | Resource creation with POST (Location header required) |
| 202 | Accepted | Request accepted, processing not complete | Starting async jobs (email sending, bulk processing) |
| 204 | No Content | Request successful, no response body | DELETE success, PUT update only |
| 206 | Partial Content | Partial content returned | Partial file download via Range request |

### 200 OK vs 201 Created vs 204 No Content

**200 OK** is the most common success response, used when retrieving resources with GET requests or returning changed resources in the response body after updating with PUT/PATCH.

```http
GET /api/users/123 HTTP/1.1

HTTP/1.1 200 OK
Content-Type: application/json

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com"
}
```

**201 Created** is used when a new resource has been created with a POST request. It must include the URI of the created resource in the `Location` header and may optionally include the created resource in the response body.

```http
POST /api/users HTTP/1.1
Content-Type: application/json

{"name": "John Doe", "email": "john@example.com"}

HTTP/1.1 201 Created
Location: /api/users/123
Content-Type: application/json

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "created_at": "2024-06-05T09:38:59Z"
}
```

**204 No Content** is used when the request succeeded but there is no response body. It's appropriate after successful DELETE when no body is needed, or when PUT only performs an update without needing to return results.

```http
DELETE /api/users/123 HTTP/1.1

HTTP/1.1 204 No Content
```

### Async Processing Pattern with 202 Accepted

202 Accepted is used when a request has been accepted but processing is not complete. It's suitable for long-running asynchronous jobs like email sending, large file processing, or external system integration.

```http
POST /api/reports/generate HTTP/1.1
Content-Type: application/json

{"type": "annual", "year": 2024}

HTTP/1.1 202 Accepted
Content-Type: application/json

{
  "job_id": "job_abc123",
  "status": "processing",
  "estimated_completion": "2024-06-05T10:00:00Z",
  "status_url": "/api/jobs/job_abc123"
}
```

### Complete List of 2xx Status Codes

- **200 OK**: Request processed successfully
- **201 Created**: New resource created
- **202 Accepted**: Request accepted but processing not complete
- **203 Non-Authoritative Information**: Response provided by proxy, not origin server
- **204 No Content**: Request successful, no response body
- **205 Reset Content**: Request successful, client should reset document view
- **206 Partial Content**: Partial response to Range request
- **207 Multi-Status**: Status for multiple resources in WebDAV
- **208 Already Reported**: Already reported binding members in WebDAV
- **226 IM Used**: Response to GET request using delta encoding

## 3xx (Redirection): Redirection Responses

3xx status codes indicate that the client needs to take additional action to complete the request. They are primarily used for URL changes, cache validation, and resource movement, guiding users to the correct location or improving network efficiency.

> **Types of Redirection**
>
> Redirections are broadly divided into permanent redirects (301, 308) and temporary redirects (302, 303, 307). Permanent redirects cause search engines to index the new URL and transfer SEO scores, while temporary redirects maintain the original URL.

### Redirection Code Comparison

| Code | Type | HTTP Method | Caching | Use Cases |
|------|------|-------------|---------|-----------|
| 301 | Permanent | May change (POST→GET) | Browser caching | Domain change, HTTP→HTTPS transition |
| 302 | Temporary | May change (POST→GET) | No caching | Return to original page after login |
| 303 | Temporary | Always changes to GET | No caching | Move to result page after POST |
| 307 | Temporary | Preserved (POST stays POST) | No caching | Maintenance page, POST redirect |
| 308 | Permanent | Preserved (POST stays POST) | Browser caching | Permanent RESTful API endpoint change |

### 301 vs 308: The Difference in Method Preservation

**301 Moved Permanently** indicates that the URL has permanently changed, but some clients convert POST requests to GET, maintaining HTTP/1.0 era behavior. **308 Permanent Redirect** must preserve the HTTP method, making it suitable when POST requests should redirect as POST.

```http
# 301: Permanent HTTP → HTTPS transition (method may change)
GET http://example.com/page HTTP/1.1

HTTP/1.1 301 Moved Permanently
Location: https://example.com/page

# 308: API endpoint change (method must be preserved)
POST /api/v1/users HTTP/1.1

HTTP/1.1 308 Permanent Redirect
Location: /api/v2/users
```

### 302 vs 303 vs 307: Choosing Temporary Redirections

**302 Found** is the oldest temporary redirection code and widely used, but its method conversion behavior was unclear. **303 See Other** (always converts to GET) and **307 Temporary Redirect** (preserves method) were added in HTTP/1.1. For new APIs, using 303 or 307 according to purpose is recommended.

```http
# 303: Move to result page after POST (converts to GET)
POST /api/orders HTTP/1.1
Content-Type: application/json

{"product_id": 123, "quantity": 2}

HTTP/1.1 303 See Other
Location: /orders/456/confirmation

# 307: Resend request during temporary maintenance (preserves method)
POST /api/payments HTTP/1.1

HTTP/1.1 307 Temporary Redirect
Location: /api/payments-backup
```

### 304 Not Modified and Caching

304 Not Modified indicates that the resource has not been modified since the last request. The client can use the cached version as-is, saving bandwidth and reducing response time.

```http
# First request
GET /api/users/123 HTTP/1.1

HTTP/1.1 200 OK
ETag: "abc123"
Last-Modified: Sat, 01 Jun 2024 10:00:00 GMT
Content-Type: application/json

{"id": 123, "name": "John Doe"}

# Second request (conditional)
GET /api/users/123 HTTP/1.1
If-None-Match: "abc123"
If-Modified-Since: Sat, 01 Jun 2024 10:00:00 GMT

HTTP/1.1 304 Not Modified
ETag: "abc123"
```

### Complete List of 3xx Status Codes

- **300 Multiple Choices**: Multiple options exist for the request
- **301 Moved Permanently**: Resource permanently moved to new URL
- **302 Found**: Resource temporarily located at different URL
- **303 See Other**: Should retrieve resource with GET from different URL
- **304 Not Modified**: Resource not modified (use cache)
- **305 Use Proxy**: Must access through proxy (deprecated for security)
- **306 (Unused)**: No longer used
- **307 Temporary Redirect**: Temporary redirect (preserves method)
- **308 Permanent Redirect**: Permanent redirect (preserves method)

## 4xx (Client Error): Client Error Responses

4xx status codes indicate a problem with the client's request. They are used in situations like malformed syntax, authentication failure, insufficient permissions, or accessing non-existent resources, where the same error will repeat unless the client modifies the request.

> **Key to Client Error Handling**
>
> 4xx errors should clearly tell the client what went wrong. Include detailed error codes, messages, and resolution methods in the error response body so developers can quickly identify and fix issues.

### Most Important 4xx Status Codes

| Code | Name | Cause | Resolution |
|------|------|-------|------------|
| 400 | Bad Request | Malformed syntax, invalid data | Validate request format and data |
| 401 | Unauthorized | Authentication required or failed | Provide valid credentials |
| 403 | Forbidden | Authenticated but insufficient permissions | Obtain appropriate permissions |
| 404 | Not Found | Resource doesn't exist | Verify URL or create resource |
| 409 | Conflict | Resource conflict | Check latest state and retry |
| 422 | Unprocessable Entity | Syntax correct, semantic error | Verify business logic |
| 429 | Too Many Requests | Request limit exceeded | Retry after Retry-After |

### 400 Bad Request vs 422 Unprocessable Entity

**400 Bad Request** is used when request syntax is malformed (invalid JSON format, missing required fields, wrong data types). **422 Unprocessable Entity** is used when syntax is correct but semantically unprocessable (business logic violation, validation failure).

```http
# 400: JSON syntax error
POST /api/users HTTP/1.1
Content-Type: application/json

{"name": "John Doe", "email": }  # Invalid JSON

HTTP/1.1 400 Bad Request
Content-Type: application/json

{
  "error": "INVALID_JSON",
  "message": "Request body is not valid JSON"
}

# 422: Syntax correct but business rule violation
POST /api/users HTTP/1.1
Content-Type: application/json

{"name": "John Doe", "email": "invalid-email", "age": -5}

HTTP/1.1 422 Unprocessable Entity
Content-Type: application/json

{
  "error": "VALIDATION_ERROR",
  "message": "Request validation failed",
  "details": [
    {"field": "email", "message": "Invalid email format"},
    {"field": "age", "message": "Must be a positive integer"}
  ]
}
```

### 401 Unauthorized vs 403 Forbidden

**401 Unauthorized** is used when authentication is required or provided credentials are invalid, and must include the `WWW-Authenticate` header. **403 Forbidden** is used when authenticated but lacking permission to access the resource.

```http
# 401: Authentication required (user not logged in)
GET /api/profile HTTP/1.1

HTTP/1.1 401 Unauthorized
WWW-Authenticate: Bearer realm="api"
Content-Type: application/json

{
  "error": "AUTHENTICATION_REQUIRED",
  "message": "Please provide a valid access token"
}

# 403: Authenticated but insufficient permissions (regular user accessing admin function)
DELETE /api/admin/users/456 HTTP/1.1
Authorization: Bearer user_token_123

HTTP/1.1 403 Forbidden
Content-Type: application/json

{
  "error": "INSUFFICIENT_PERMISSIONS",
  "message": "Admin role required for this operation"
}
```

### Security Considerations for 404 Not Found

404 Not Found is used when a resource doesn't exist, but for security-sensitive cases, you can return 404 instead of 403 to hide whether a resource exists. For example, when accessing another user's private resource, returning 403 reveals that the resource exists, so returning 404 may be safer.

```http
# Security 404: Hide resource existence
GET /api/users/999/private-data HTTP/1.1
Authorization: Bearer other_user_token

HTTP/1.1 404 Not Found
Content-Type: application/json

{
  "error": "RESOURCE_NOT_FOUND",
  "message": "The requested resource was not found"
}
```

### 409 Conflict and Optimistic Locking

409 Conflict is used when a conflict occurs with the current state of a resource. It's returned in situations like version conflicts (optimistic locking failure), duplicate resource creation attempts, or attempts to modify deleted resources.

```http
# Optimistic locking conflict
PUT /api/documents/123 HTTP/1.1
Content-Type: application/json
If-Match: "version_5"

{"title": "Updated Title", "content": "..."}

HTTP/1.1 409 Conflict
Content-Type: application/json

{
  "error": "VERSION_CONFLICT",
  "message": "Document was modified by another user",
  "current_version": "version_7",
  "your_version": "version_5"
}
```

### 429 Too Many Requests and Rate Limiting

429 Too Many Requests is used when a client has sent too many requests within a certain time period. It should indicate when retry is possible via the `Retry-After` header and provide limit information via `X-RateLimit-*` headers.

```http
GET /api/search?q=example HTTP/1.1
Authorization: Bearer token_123

HTTP/1.1 429 Too Many Requests
Retry-After: 60
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1717581600
Content-Type: application/json

{
  "error": "RATE_LIMIT_EXCEEDED",
  "message": "API rate limit exceeded. Please retry after 60 seconds.",
  "limit": 100,
  "reset_at": "2024-06-05T10:00:00Z"
}
```

### Complete List of 4xx Status Codes

- **400 Bad Request**: Malformed request syntax
- **401 Unauthorized**: Authentication required
- **402 Payment Required**: Payment required (reserved for future use)
- **403 Forbidden**: Access permission denied
- **404 Not Found**: Resource doesn't exist
- **405 Method Not Allowed**: HTTP method not allowed
- **406 Not Acceptable**: Content type unacceptable to client
- **407 Proxy Authentication Required**: Proxy authentication required
- **408 Request Timeout**: Request timed out
- **409 Conflict**: Resource conflict
- **410 Gone**: Resource permanently deleted
- **411 Length Required**: Content-Length header required
- **412 Precondition Failed**: Conditional request precondition failed
- **413 Payload Too Large**: Request body too large
- **414 URI Too Long**: URI too long
- **415 Unsupported Media Type**: Unsupported media type
- **416 Range Not Satisfiable**: Requested range cannot be satisfied
- **417 Expectation Failed**: Expect header condition failed
- **418 I'm a teapot**: HTCPCP April Fool's joke code
- **421 Misdirected Request**: Request directed to wrong server
- **422 Unprocessable Entity**: Cannot process due to semantic error
- **423 Locked**: WebDAV resource locked
- **424 Failed Dependency**: WebDAV dependency failed
- **425 Too Early**: TLS Early Data replay attack prevention
- **426 Upgrade Required**: Protocol upgrade required
- **428 Precondition Required**: Conditional request required
- **429 Too Many Requests**: Request limit exceeded
- **431 Request Header Fields Too Large**: Header fields too large
- **451 Unavailable For Legal Reasons**: Unavailable for legal reasons

## 5xx (Server Error): Server Error Responses

5xx status codes indicate that the server failed to process a valid request. The client is not responsible, and the server side must resolve the issue. These are serious situations requiring immediate monitoring and response.

> **Principles of 5xx Error Handling**
>
> 5xx errors should not expose internal implementation details (stack traces, database connection info, etc.) to clients. Instead, provide a unique error ID so detailed information can be tracked in server logs.

### Key 5xx Status Codes

| Code | Name | Cause | Resolution |
|------|------|-------|------------|
| 500 | Internal Server Error | Unhandled exception, bug | Error logging and bug fix |
| 502 | Bad Gateway | Upstream server response error | Check upstream server status |
| 503 | Service Unavailable | Server overload, maintenance | Capacity expansion, wait for maintenance completion |
| 504 | Gateway Timeout | Upstream server response timeout | Adjust timeout settings, optimize queries |

### 500 Internal Server Error

500 Internal Server Error is the most common server error, used when an unexpected error occurs on the server. Causes include unhandled exceptions, database connection failures, and code bugs.

```http
GET /api/users/123 HTTP/1.1

HTTP/1.1 500 Internal Server Error
Content-Type: application/json

{
  "error": "INTERNAL_ERROR",
  "message": "An unexpected error occurred. Please try again later.",
  "error_id": "err_20240605_abc123",
  "timestamp": "2024-06-05T09:38:59Z"
}
```

### 502 Bad Gateway vs 503 Service Unavailable vs 504 Gateway Timeout

**502 Bad Gateway** occurs when a gateway or proxy server receives an invalid response from the upstream server. A typical example is Nginx being unable to communicate with the backend application server. **503 Service Unavailable** is used when the server temporarily cannot handle requests (overload, maintenance, deploying) and should indicate retry timing via the `Retry-After` header. **504 Gateway Timeout** occurs when the gateway doesn't receive a timely response from the upstream server.

```http
# 502: Upstream server connection failure
HTTP/1.1 502 Bad Gateway
Content-Type: application/json

{
  "error": "UPSTREAM_ERROR",
  "message": "Failed to connect to upstream server"
}

# 503: Under maintenance
HTTP/1.1 503 Service Unavailable
Retry-After: 3600
Content-Type: application/json

{
  "error": "SERVICE_UNAVAILABLE",
  "message": "Server is under maintenance. Expected completion: 2024-06-05T10:00:00Z"
}

# 504: Upstream response timeout
HTTP/1.1 504 Gateway Timeout
Content-Type: application/json

{
  "error": "GATEWAY_TIMEOUT",
  "message": "Upstream server did not respond in time"
}
```

### Complete List of 5xx Status Codes

- **500 Internal Server Error**: Server internal error
- **501 Not Implemented**: Requested functionality not implemented
- **502 Bad Gateway**: Gateway/proxy received invalid response
- **503 Service Unavailable**: Service temporarily unavailable
- **504 Gateway Timeout**: Gateway/proxy response timeout
- **505 HTTP Version Not Supported**: HTTP version not supported
- **506 Variant Also Negotiates**: Content negotiation circular reference
- **507 Insufficient Storage**: WebDAV insufficient storage
- **508 Loop Detected**: WebDAV infinite loop detected
- **510 Not Extended**: Additional extension needed for request processing
- **511 Network Authentication Required**: Network authentication required (captive portal)

## Unusual and Interesting Status Codes

### 418 I'm a teapot

418 I'm a teapot was defined on April 1, 1998, as part of HTCPCP (Hyper Text Coffee Pot Control Protocol) in RFC 2324. This joke code indicates that a teapot cannot brew coffee. Although it's a joke, it's actually implemented in many web frameworks (Express, Spring, Django, etc.), and has become part of developer culture, used by Google on April Fool's Day 2014.

### 451 Unavailable For Legal Reasons

451 is a code inspired by Ray Bradbury's novel "Fahrenheit 451." It was officially added in 2015 as RFC 7725 and is used when content cannot be provided for legal reasons (copyright infringement, government censorship, GDPR deletion requests, etc.).

### 425 Too Early

425 Too Early was added in 2018 as RFC 8470. It's used when the server rejects Early Data requests deemed unsafe to prevent replay attacks that can occur when using TLS 1.3's 0-RTT (zero round-trip time) feature.

## RESTful API Status Code Design Guide

### Recommended Status Codes by CRUD Operation

| Operation | HTTP Method | Success | Resource Not Found | Errors |
|-----------|-------------|---------|-------------------|--------|
| Create | POST | 201 Created + Location | - | 400, 409, 422 |
| Read (single) | GET | 200 OK | 404 Not Found | 403 |
| Read (list) | GET | 200 OK (empty array possible) | - | - |
| Full Update | PUT | 200 OK, 204 No Content | 404 Not Found | 400, 409, 422 |
| Partial Update | PATCH | 200 OK, 204 No Content | 404 Not Found | 400, 409, 422 |
| Delete | DELETE | 204 No Content | 404 (optional) | 403 |

### Consistent Error Response Structure

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": [
      {
        "field": "email",
        "code": "INVALID_FORMAT",
        "message": "Invalid email format"
      }
    ],
    "timestamp": "2024-06-05T09:38:59Z",
    "path": "/api/users",
    "request_id": "req_abc123"
  }
}
```

## Browser Behavior and Status Codes

### Automatic Redirection

When browsers receive 3xx status codes, they automatically navigate to the URL in the `Location` header. Users are unaware of this process. For 301 and 308, browsers permanently cache the redirect, navigating directly to the new URL without requesting the original URL on subsequent visits.

### Authentication Popup

When receiving a 401 status code with `WWW-Authenticate: Basic realm="..."` header, browsers automatically display an authentication dialog. However, modern web applications prefer form-based authentication or OAuth, making this behavior rarely utilized.

### Caching Behavior

- **200 OK**: Cached according to `Cache-Control`, `ETag`, `Last-Modified` headers
- **301 Moved Permanently**: Browser permanently remembers the new URL
- **304 Not Modified**: Server confirms use of cached version, no body transmitted

## Monitoring and Error Handling Strategies

### Status Code Rate Monitoring

- **2xx Rate**: Target maintaining above 95%
- **4xx Rate**: Sudden increases signal API changes or client bugs
- **5xx Rate**: Keep below 1%, alert immediately if exceeded
- **429 Occurrence**: Review appropriateness of rate limit settings

### Error Logging Strategy

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
    "request_id": "req_abc123"
  }
}
```

## Conclusion

HTTP status codes are a core element of client-server communication. They have evolved from the simple form without status codes in HTTP/0.9 in 1991 to the sophisticated system of today. Choosing the correct status code directly impacts API intuitiveness, debugging ease, and user experience. When designing RESTful APIs, it's important to select appropriate status codes for each situation, provide consistent error response structures, and detect and respond to issues early through effective monitoring.

## References

- [MDN Web Docs - HTTP Status Codes](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)
- [RFC 7231 - Hypertext Transfer Protocol (HTTP/1.1): Semantics and Content](https://datatracker.ietf.org/doc/html/rfc7231)
- [RFC 2324 - Hyper Text Coffee Pot Control Protocol (HTCPCP/1.0)](https://datatracker.ietf.org/doc/html/rfc2324)
- [RFC 7725 - An HTTP Status Code to Report Legal Obstacles](https://datatracker.ietf.org/doc/html/rfc7725)
