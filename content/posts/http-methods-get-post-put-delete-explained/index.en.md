---
title: "The Complete Guide to HTTP Methods: From GET, POST, PUT, DELETE to Security"
date: 2024-05-25T14:05:29+09:00
tags: ["HTTP", "REST API", "Web Development", "CORS"]
draft: false
description: "A comprehensive guide covering the history, characteristics, and usage of all 9 HTTP methods defined in the HTTP/1.1 specification (RFC 7231), from idempotency and safety concepts to RESTful API design principles, CORS preflight request handling, practical examples, and security considerations for proper HTTP method usage in web development."
---

HTTP (HyperText Transfer Protocol) methods are core elements of client-server communication protocols that have continuously evolved since Tim Berners-Lee first introduced them when designing the World Wide Web in 1991. The HTTP/1.1 standard (RFC 7231) defines 9 standard methods: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, CONNECT, and TRACE. Each method has important characteristics of idempotency and safety, playing essential roles in RESTful API design and web application development.

## History and Evolution of HTTP Methods

> **What is HTTP (HyperText Transfer Protocol)?**
>
> An application layer protocol for transferring hypertext documents between clients and servers on the web. It operates on a request-response model where the method used in each request defines the semantics of the operation to be performed.

The HTTP protocol has continuously evolved since Tim Berners-Lee proposed it as an information sharing system at CERN in 1989, with the types and semantics of methods expanding alongside.

### HTTP/0.9 (1991)

The first version of HTTP supported only the GET method. It provided only the functionality to fetch HTML documents. There were no concepts of headers or status codes, so the server could only return the requested document as-is or close the connection.

### HTTP/1.0 (1996, RFC 1945)

POST and HEAD methods were added along with request/response headers and status codes, enabling transmission of various content types (images, video, etc.). It also became possible to specify MIME types through the Content-Type header.

### HTTP/1.1 (1997, RFC 2068 → 2014, RFC 7230-7235)

The most widely used version to date. PUT, DELETE, OPTIONS, TRACE, and CONNECT methods were added. Persistent connections and pipelining were introduced, significantly improving performance. Important features such as chunked transfer encoding and mandatory host header were also added.

### HTTP/2 (2015, RFC 7540) and HTTP/3 (2022, RFC 9114)

HTTP methods themselves remain the same as HTTP/1.1, with only the transport layer of the protocol improved. HTTP/2 introduced binary protocol and multiplexing, enabling multiple requests to be processed simultaneously on a single connection. HTTP/3 uses the UDP-based QUIC protocol to reduce connection establishment latency and prevent performance degradation during packet loss.

## Idempotency and Safety

The two most important concepts for understanding HTTP methods are idempotency and safety. These characteristics directly affect caching, retry policies, and API design.

### Safety

> **What is a Safe Method?**
>
> A read-only method that does not change server state. Performing the same request multiple times causes no side effects on the server's resources.

Safe methods (GET, HEAD, OPTIONS, TRACE) do not modify server data, so they can be cached. Browser prefetching and search engine crawlers can call them safely. They can also be stored in bookmarks or history and re-executed without issues.

### Idempotency

> **What is an Idempotent Method?**
>
> A method where performing the same request once or multiple times leaves the same result on the server. Even if requests are duplicated due to network errors, they can be safely retried.

Idempotency is particularly important in distributed systems because clients frequently fail to receive responses due to network timeouts or temporary failures and resend the same requests. Idempotent methods (GET, PUT, DELETE, HEAD, OPTIONS, TRACE) can be safely retried in such situations.

### Method Characteristics Comparison

| Method | Safe | Idempotent | Cacheable | Request body | Response body | Primary Use |
|--------|------|------------|-----------|--------------|---------------|-------------|
| GET | Yes | Yes | Yes | No | Yes | Retrieve resource |
| HEAD | Yes | Yes | Yes | No | No | Check metadata |
| OPTIONS | Yes | Yes | No | No | Yes | Check supported methods |
| TRACE | Yes | Yes | No | No | Yes | Path tracing/debugging |
| POST | No | No | Conditional | Yes | Yes | Create resource/process data |
| PUT | No | Yes | No | Yes | Yes | Replace entire resource |
| PATCH | No | Implementation-dependent | Conditional | Yes | Yes | Partial resource modification |
| DELETE | No | Yes | No | No | Yes | Delete resource |
| CONNECT | No | No | No | No | Yes | Establish tunnel connection |

## The 9 HTTP Methods in Detail

### GET - Retrieve Resources

The GET method requests a representation of the specified resource. It is used to query data from the server and returns the resource as a response without modifying any data.

**Key Characteristics**

- Safe and idempotent, so it can be cached. It remains in browser history and can be bookmarked.
- Data is passed via URL query strings. The request body does not contain data.
- Sensitive data like passwords or personal information should not be transmitted as parameters are exposed in URLs.

**Query Parameters and URL Length Limits**

```http
GET /api/users?page=1&limit=10&sort=created_at&order=desc HTTP/1.1
Host: api.example.com
Accept: application/json
```

URL length limits vary by browser and server: Internet Explorer limits to 2,083 characters, Chrome approximately 8,000 characters, Apache server default 8,190 characters, and Nginx server default 4,096 characters.

**Cache Control**

```http
HTTP/1.1 200 OK
Cache-Control: max-age=3600, public
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2025 07:28:00 GMT
Vary: Accept-Encoding
```

**Practical Examples**

```bash
# Basic GET request
curl -X GET https://api.example.com/users/123

# With query parameters and headers
curl -X GET "https://api.example.com/users?role=admin&active=true" \
  -H "Authorization: Bearer token123" \
  -H "Accept: application/json"

# Conditional GET (cache validation)
curl -X GET https://api.example.com/users/123 \
  -H "If-None-Match: \"33a64df551425fcc55e4d42a148795d9f25f89d4\""
```

### POST - Create Resources and Process Data

The POST method submits data to the server to create new resources or request data processing. It is used for various purposes including form submission, file uploads, and passing complex search conditions.

**Key Characteristics**

- Neither safe nor idempotent. Sending the same request multiple times may create new resources each time.
- Data is included in the HTTP message body. Sensitive information is not exposed in URLs.
- Not cached by default, but cacheable with explicit Cache-Control header settings.

**Request Formats by Content Type**

```bash
# JSON format
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'

# Form data format (URL encoded)
curl -X POST https://api.example.com/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=john&password=secret123"

# Multipart form data (file upload)
curl -X POST https://api.example.com/upload \
  -F "file=@photo.jpg" \
  -F "description=Profile photo" \
  -F "category=profile"
```

**Response Status Codes**

| Status Code | Meaning | Description |
|-------------|---------|-------------|
| 201 Created | Creation successful | Location header contains new resource URI |
| 200 OK | Processing successful | Processing result in response body |
| 204 No Content | Processing successful | No response body |
| 400 Bad Request | Invalid request | Validation failure, etc. |
| 409 Conflict | Conflict | Duplicate data, etc. |

### PUT - Replace Entire Resource

The PUT method stores a resource at the specified URI. If a resource exists at that URI, it replaces the entire resource. If not, it creates a new one, performing an upsert operation.

**Key Characteristics**

- Not safe but idempotent. Multiple identical PUT requests yield the same result.
- Replaces the entire resource, so fields not included in the request body may be deleted or set to default values.
- The client must know the resource URI (key difference from POST).

**Full Replacement Example**

```bash
# Existing resource
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "address": "123 Main St"
}

# PUT request (full data needed even to change only age)
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "newemail@example.com",
    "age": 31
  }'

# Result (address field removed)
{
  "id": 123,
  "name": "John Doe",
  "email": "newemail@example.com",
  "age": 31
}
```

### PATCH - Partial Resource Modification

The PATCH method modifies only parts of a resource. Unlike PUT, it modifies only fields included in the request body while preserving other fields.

**Key Characteristics**

- Not safe, and idempotency depends on implementation.
- Uses bandwidth more efficiently than PUT (only changed parts transmitted).
- Two standard formats exist: JSON Merge Patch (RFC 7396) and JSON Patch (RFC 6902).

**PUT vs PATCH Comparison**

```bash
# Existing resource
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "address": "123 Main St"
}

# PATCH request (update only age field)
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"age": 31}'

# Result (other fields preserved)
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "age": 31,
  "address": "123 Main St"
}
```

**JSON Patch (RFC 6902)**

```bash
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json-patch+json" \
  -d '[
    {"op": "replace", "path": "/email", "value": "new@example.com"},
    {"op": "add", "path": "/phone", "value": "555-1234"},
    {"op": "remove", "path": "/address"},
    {"op": "test", "path": "/age", "value": 30}
  ]'
```

**Idempotency Considerations**

```bash
# Idempotent PATCH (setting value - same result when executed multiple times)
PATCH /users/123 {"age": 31}

# Non-idempotent PATCH (increment - different result each execution)
PATCH /users/123 {"age_increment": 1}
```

### DELETE - Delete Resources

The DELETE method requests the server to delete the specified resource. Once successfully deleted, the resource at that URI becomes inaccessible.

**Key Characteristics**

- Not safe but idempotent. DELETE requests on already-deleted resources return the same result (resource not found).
- Generally does not include a request body, though some implementations include deletion conditions in the body.

**Response Status Codes**

| Status Code | Meaning | Description |
|-------------|---------|-------------|
| 204 No Content | Deletion successful | No response body (most common) |
| 200 OK | Deletion successful | Returns deleted resource info |
| 202 Accepted | Deletion accepted | Async processing in progress |
| 404 Not Found | Resource not found | Varies by implementation |

**Soft Delete vs Hard Delete**

```bash
# Hard delete (physical deletion)
curl -X DELETE https://api.example.com/users/123

# Soft delete (logical deletion - actually PATCH)
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{"deleted_at": "2025-01-15T10:30:00Z", "is_active": false}'
```

Soft delete is commonly used for data recovery, audit trails, and maintaining foreign key integrity. It sets a deletion flag without actually deleting the data.

### HEAD - Retrieve Metadata

The HEAD method is identical to GET but returns only headers without a response body. It allows obtaining information while saving bandwidth when only resource metadata is needed.

**Key Characteristics**

- Safe, idempotent, and cacheable.
- Returns the same response headers as GET but without response body.
- Servers must return the same headers for GET and HEAD (RFC 7231).

**Use Cases**

```bash
# Check file size and modification time (before download)
curl -I https://example.com/large-file.zip

HTTP/1.1 200 OK
Content-Length: 104857600
Content-Type: application/zip
Last-Modified: Mon, 13 Jan 2025 10:00:00 GMT
ETag: "abc123"
Accept-Ranges: bytes
```

- Check resource existence (without downloading)
- Check file size (Content-Length)
- Check last modification time (Last-Modified)
- Validate cache (ETag, Last-Modified)
- Link validation (web crawlers)

### OPTIONS - Check Supported Methods

The OPTIONS method requests communication options (methods, headers, etc.) supported by the server for a specific resource. It plays a key role in CORS (Cross-Origin Resource Sharing) preflight requests.

**Key Characteristics**

- Safe and idempotent.
- The Allow header in the response contains the list of supported methods.
- Browsers automatically send it for CORS preflight requests.

**General OPTIONS Request**

```bash
curl -X OPTIONS https://api.example.com/users

HTTP/1.1 200 OK
Allow: GET, POST, HEAD, OPTIONS
```

**CORS Preflight Request**

Browsers automatically send OPTIONS preflight requests before actual requests under certain conditions (PUT/DELETE methods, custom headers, application/json, etc.).

```http
OPTIONS /api/users HTTP/1.1
Host: api.example.com
Origin: https://frontend.example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://frontend.example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
Access-Control-Allow-Credentials: true
```

### CONNECT - Tunnel Connection

The CONNECT method requests a proxy server to establish a TCP tunnel to the target server. It is primarily used to relay HTTPS connections through a proxy.

**Key Characteristics**

- Neither safe nor idempotent.
- The proxy server relays the TCP connection between client and target server.
- After the tunnel is established, data is encrypted and the proxy cannot see the contents.

**How It Works**

```http
CONNECT api.example.com:443 HTTP/1.1
Host: api.example.com:443
Proxy-Authorization: Basic YWxhZGRpbjpvcGVuc2VzYW1l

HTTP/1.1 200 Connection Established

(TLS handshake and encrypted HTTPS communication begins)
```

**Security Considerations**

The CONNECT method poses security risks as it can be abused to bypass proxies. Most proxy servers restrict CONNECT to port 443 (HTTPS) only to prevent malicious port access.

### TRACE - Path Tracing

The TRACE method performs a loopback test of the request message along the path to the target server for debugging purposes. The server returns the received request as-is in the response body.

**Key Characteristics**

- Safe and idempotent.
- Can check how requests are modified as they pass through intermediate proxies.
- Disabled on most production servers due to security risks.

**How It Works**

```http
TRACE /path HTTP/1.1
Host: api.example.com
X-Custom-Header: test-value

HTTP/1.1 200 OK
Content-Type: message/http

TRACE /path HTTP/1.1
Host: api.example.com
X-Custom-Header: test-value
Via: 1.1 proxy.example.com
```

**Security Risk (XST Attack)**

The TRACE method can be exploited for XST (Cross-Site Tracing) attacks because attackers can combine it with XSS to steal HttpOnly cookies or Authorization header values. Therefore, TRACE should be disabled in production environments.

```apache
# Apache configuration
TraceEnable off
```

```nginx
# Nginx configuration
if ($request_method = TRACE) {
    return 405;
}
```

## RESTful API Design Principles

REST (Representational State Transfer) is an architectural style proposed by Roy Fielding in his 2000 doctoral dissertation. It presents principles for designing consistent and intuitive APIs by leveraging HTTP method semantics.

### Resource-Centric Design

URLs represent resources (nouns), and HTTP methods represent actions (verbs) on those resources.

```
# Good example (resource-centric)
GET    /users          # Retrieve user list
GET    /users/123      # Retrieve user with ID 123
POST   /users          # Create new user
PUT    /users/123      # Update entire user
PATCH  /users/123      # Partially update user
DELETE /users/123      # Delete user

# Bad example (action-centric)
GET    /getUsers
POST   /createUser
POST   /updateUser
POST   /deleteUser
```

### CRUD Mapping

| Operation | HTTP Method | URI Pattern | Response Code |
|-----------|-------------|-------------|---------------|
| List (Collection) | GET | /users | 200 OK |
| Single (Document) | GET | /users/{id} | 200 OK, 404 Not Found |
| Create | POST | /users | 201 Created |
| Full Update | PUT | /users/{id} | 200 OK, 204 No Content |
| Partial Update | PATCH | /users/{id} | 200 OK |
| Delete | DELETE | /users/{id} | 204 No Content |
| Search | GET | /users?name=John | 200 OK |
| Nested Resource | GET | /users/{id}/posts | 200 OK |

### URL Design Rules

- **Use plural nouns**: `/users`, `/posts`, `/comments`
- **Use lowercase**: `/user-profiles` (hyphens to separate words)
- **Express hierarchy**: `/users/123/posts/456/comments`
- **Avoid verbs**: `/users` (good), `/getUsers` (bad)
- **Exclude file extensions**: `/users/123` (good), `/users/123.json` (bad)
- **Version management**: `/v1/users`, `/v2/users`

## CORS and Preflight Requests

CORS (Cross-Origin Resource Sharing) is a mechanism that allows access to resources from different domains by circumventing the web browser's Same-Origin Policy. Preflight requests using the OPTIONS method are central to this mechanism.

### Simple Request vs Preflight Request

**Simple Request Conditions** (sent directly without preflight)

- Method: One of GET, HEAD, POST
- Headers: Only Accept, Accept-Language, Content-Language, Content-Type
- Content-Type: One of application/x-www-form-urlencoded, multipart/form-data, text/plain

**When Preflight is Needed**

- Method: PUT, DELETE, PATCH, etc.
- Custom headers: Authorization, X-Custom-Header, etc.
- Content-Type: application/json, etc.

### Preflight Request Flow

```
1. Browser sends OPTIONS preflight request
   OPTIONS /api/users HTTP/1.1
   Origin: https://frontend.example.com
   Access-Control-Request-Method: POST
   Access-Control-Request-Headers: Content-Type, Authorization

2. Server responds with CORS policy
   HTTP/1.1 200 OK
   Access-Control-Allow-Origin: https://frontend.example.com
   Access-Control-Allow-Methods: GET, POST, PUT, DELETE
   Access-Control-Allow-Headers: Content-Type, Authorization
   Access-Control-Max-Age: 86400

3. Browser sends actual request
   POST /api/users HTTP/1.1
   Origin: https://frontend.example.com
   Content-Type: application/json
   Authorization: Bearer token123

4. Server returns actual response
   HTTP/1.1 201 Created
   Access-Control-Allow-Origin: https://frontend.example.com
```

### CORS Server Configuration Examples

**Node.js (Express)**

```javascript
const cors = require('cors');

app.use(cors({
  origin: ['https://frontend.example.com', 'https://app.example.com'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400
}));
```

**Nginx**

```nginx
location /api/ {
    add_header Access-Control-Allow-Origin https://frontend.example.com;
    add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
    add_header Access-Control-Allow-Headers "Content-Type, Authorization";
    add_header Access-Control-Max-Age 86400;

    if ($request_method = OPTIONS) {
        return 204;
    }
}
```

## Security Considerations

Key security considerations when using HTTP methods.

### Prohibit State Changes with GET

GET requests should be safe and must not change server state.

```
# Bad examples (security vulnerable)
GET /users/123/delete
GET /posts/456/publish

# Good examples
DELETE /users/123
PATCH /posts/456 {"status": "published"}
```

Changing state with GET causes these problems:
- Unintended state changes from browser prefetching
- Search engine crawlers may follow delete/modify URLs
- Can be re-executed from browser history or bookmarks
- More vulnerable to CSRF attacks

### CSRF Attack Prevention

State-changing methods such as POST, PUT, and DELETE are vulnerable to CSRF (Cross-Site Request Forgery) attacks.

**Defense Methods**

```javascript
// Using CSRF tokens
<form method="POST" action="/api/users">
  <input type="hidden" name="csrf_token" value="random_token_value">
</form>

// SameSite cookie setting
Set-Cookie: session=abc123; SameSite=Strict; Secure; HttpOnly

// Custom header validation
if (!request.headers['X-Requested-With']) {
  return 403; // Only allow AJAX requests
}
```

### Disable TRACE Method

TRACE is vulnerable to XST attacks and must be disabled in production.

### Authentication and Authorization Validation

State-changing methods (POST, PUT, PATCH, DELETE) must always validate authentication and authorization.

```javascript
app.delete('/users/:id',
  authenticateToken,  // Verify authentication
  authorizeUser,      // Verify authorization
  (req, res) => {
    // Deletion logic
  }
);
```

### Input Validation and Limits

- Limit request body size (prevent DoS)
- Validate input data
- Prevent SQL injection and XSS

## Conclusion

HTTP methods are core elements defining communication between clients and servers on the web. Starting with only the GET method in HTTP/0.9 in 1991, 9 standard methods were established in HTTP/1.1. Each method has important characteristics of safety and idempotency that directly affect caching, retry policies, and API design.

Properly leveraging HTTP method semantics in RESTful API design enables creation of consistent and intuitive APIs. Understanding CORS and applying security considerations (CSRF prevention, TRACE disabling, authentication/authorization validation) enables building secure and scalable web services.

## References

- [RFC 7231 - HTTP/1.1 Semantics and Content](https://tools.ietf.org/html/rfc7231)
- [RFC 6902 - JSON Patch](https://tools.ietf.org/html/rfc6902)
- [RFC 7396 - JSON Merge Patch](https://tools.ietf.org/html/rfc7396)
- [MDN Web Docs - HTTP Methods](https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods)
- [REST API Tutorial](https://restfulapi.net/)
