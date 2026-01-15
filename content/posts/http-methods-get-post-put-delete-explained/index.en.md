---
title: "HTTP methods in a nutshell"
date: 2024-05-25T14:05:29+09:00
tags: ["Definitions", "HTTP"]
draft: false
description: "A comprehensive guide to the 9 HTTP methods defined in HTTP/1.1 specification (RFC 7231). Covers idempotency and safety concepts, method comparison tables, RESTful API design principles, CORS preflight handling, real-world examples, and security considerations for proper HTTP method usage in web development."
---

> HTTP is a communication protocol for data exchange between clients and servers. It consists of requests and responses. The methods used in requests and responses are called HTTP methods. The HTTP/1.1 standard (RFC 7231) defines 9 standard methods. Each method has important characteristics: idempotency and safety.

## History and Evolution of HTTP Methods

The HTTP protocol has continuously evolved since Tim Berners-Lee first conceived it in 1991.

### HTTP/0.9 (1991)

The first version of HTTP supported only the GET method. It provided only the functionality to fetch HTML documents. There were no concepts of headers or status codes.

### HTTP/1.0 (1996)

POST and HEAD methods were added. Headers and status codes were introduced. This enabled transmission of various content types.

### HTTP/1.1 (1997)

The most widely used version to date. PUT, DELETE, OPTIONS, TRACE, and CONNECT methods were added. It was standardized as RFC 2616 and revised as RFC 7230-7235 in 2014. Persistent connections and pipelining were introduced, significantly improving performance.

### HTTP/2 (2015) and HTTP/3 (2020)

HTTP methods remain the same as HTTP/1.1. Only the transport layer of the protocol was improved. HTTP/2 introduced binary protocol and multiplexing. HTTP/3 is based on the QUIC protocol.

## HTTP Methods

HTTP methods are used by clients when sending requests to servers. The HTTP/1.1 standard defines the following 9 methods.

1. **GET** - Retrieve resources
2. **POST** - Create resources and process data
3. **PUT** - Replace entire resource
4. **PATCH** - Modify part of resource
5. **DELETE** - Delete resource
6. **HEAD** - Retrieve metadata
7. **OPTIONS** - Check supported methods
8. **CONNECT** - Establish tunnel connection
9. **TRACE** - Trace path

## Idempotency and Safety

HTTP methods are classified by two important characteristics.

### Safety

Safe methods are read-only methods that do not change server state. Safe methods can be cached. They can be used for prefetching or crawling.

### Idempotency

Idempotent methods return the same result when executed multiple times as when executed once. They can be safely retried in case of network errors.

### Method Characteristics Comparison

| Method  | Safe | Idempotent | Cacheable | Request body | Response body | Common Usage           |
| ------- | ---- | ---------- | --------- | ------------ | ------------- | ---------------------- |
| GET     | Yes  | Yes        | Yes       | No           | Yes           | Retrieve resources     |
| HEAD    | Yes  | Yes        | Yes       | No           | No            | Check metadata         |
| OPTIONS | Yes  | Yes        | No        | No           | Yes           | Check supported methods|
| TRACE   | Yes  | Yes        | No        | No           | Yes           | Trace path             |
| POST    | No   | No         | Yes\*     | Yes          | Yes           | Create/process data    |
| PUT     | No   | Yes        | No        | Yes          | Yes           | Replace entire resource|
| PATCH   | No   | No\*       | Yes\*     | Yes          | Yes           | Modify part of resource|
| DELETE  | No   | Yes        | No        | No           | Yes           | Delete resource        |
| CONNECT | No   | No         | No        | No           | Yes           | Tunnel connection      |

\* POST is cacheable with explicit cache settings. PATCH idempotency and cacheability vary by implementation.

## Detailed Method Descriptions

### GET

GET retrieves a specific resource. It is used to query data from the server. It returns the resource as a response without modifying any data.

#### Key Features

- Requests can be cached.
- Data is sent via query string, not in HTTP message body.
- Mainly used to retrieve data or request pages.
- Safe and idempotent.

#### Query Parameters and URL Length Limits

GET requests pass data through query parameters. Sensitive information should not be sent in URLs as parameters are exposed.

```http
GET /api/users?page=1&limit=10&sort=name HTTP/1.1
Host: api.example.com
```

URL length limits vary by browser and server.

- Internet Explorer: 2,083 characters
- Chrome: approximately 8,000 characters
- Apache server: 8,190 characters (default)
- Nginx server: 4,096 characters (default)

#### Caching Strategy

GET requests can be cached by browsers and intermediate proxies. Cache control uses these headers.

```http
Cache-Control: max-age=3600, public
ETag: "33a64df551425fcc55e4d42a148795d9f25f89d4"
Last-Modified: Wed, 21 Oct 2025 07:28:00 GMT
```

#### Practical Examples

```bash
# Basic GET request
curl -X GET https://api.example.com/users/123

# With query parameters
curl -X GET "https://api.example.com/users?role=admin&active=true"

# With headers
curl -X GET https://api.example.com/users/123 \
  -H "Authorization: Bearer token123" \
  -H "Accept: application/json"
```

### POST

POST is used to send data to the server. It is mainly used to create new resources or submit data to the server.

#### Key Features

- Requests are not cached by default. (Cacheable with explicit settings)
- Data is included in the HTTP message body.
- Mainly used for form submission, file uploads, and data processing requests.
- Not safe and not idempotent.

POST requests do not guarantee idempotency. Sending the same request multiple times can change server state multiple times.

#### Request Formats by Content Type

**JSON Request**

```bash
curl -X POST https://api.example.com/users \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com",
    "age": 30
  }'
```

**Form Data Request**

```bash
curl -X POST https://api.example.com/login \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "username=john&password=secret123"
```

**Multipart Form Data (File Upload)**

```bash
curl -X POST https://api.example.com/upload \
  -F "file=@photo.jpg" \
  -F "description=Profile photo"
```

#### Response Status Codes

Common response codes for POST requests:

- `201 Created`: Resource created successfully, includes created resource URI in Location header
- `200 OK`: Request processed successfully, includes processing result in response body
- `204 No Content`: Request processed successfully, no response body
- `400 Bad Request`: Invalid request data
- `409 Conflict`: Resource conflict (e.g., duplicate email)

```http
HTTP/1.1 201 Created
Location: /api/users/123
Content-Type: application/json

{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com"
}
```

### PUT

PUT is used to create or modify resources. It stores a resource at a client-specified location. It can also update an existing resource at that location.

#### Key Features

- Requests cannot be cached.
- Data is included in the HTTP message body.
- Used to update entire resource or create new resource.
- Not safe but idempotent.

PUT requests are idempotent. Executing the same PUT request multiple times yields the same result. This is because it changes the entire state of the resource, so no partial changes occur.

#### Full Replacement Behavior

PUT replaces the entire resource. Fields not included in the request body may be deleted or set to default values.

```bash
# Existing resource
{
  "id": 123,
  "name": "John Doe",
  "email": "john@example.com",
  "age": 30,
  "address": "123 Main St"
}

# PUT request
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

#### Response Status Codes

- `200 OK`: Resource updated successfully, includes updated resource in response body
- `204 No Content`: Resource updated successfully, no response body
- `201 Created`: Resource created successfully (when resource didn't exist)
- `404 Not Found`: Resource not found (when creation is not supported)

#### Upsert (Update or Insert) Pattern

PUT can be used in an upsert pattern. It creates the resource if it doesn't exist, or updates it if it does.

```bash
# Create or update resource
curl -X PUT https://api.example.com/users/123 \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "email": "john@example.com"
  }'
```

### PATCH

PATCH is used to modify parts of a resource. It changes only part of an existing resource.

#### Key Features

- Requests are not cached by default. (Cacheable with explicit settings)
- Data is included in the HTTP message body.
- Used to update parts of a resource.
- Not safe, and idempotency varies by implementation.

#### PUT vs PATCH

PUT modifies the entire resource. PATCH modifies parts of the resource.

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

#### JSON Patch (RFC 6902)

A standardized PATCH format defined in RFC 6902. It can express complex update operations.

```bash
curl -X PATCH https://api.example.com/users/123 \
  -H "Content-Type: application/json-patch+json" \
  -d '[
    {"op": "replace", "path": "/email", "value": "new@example.com"},
    {"op": "add", "path": "/phone", "value": "555-1234"},
    {"op": "remove", "path": "/address"}
  ]'
```

Supported operations:

- `add`: Add value
- `remove`: Remove value
- `replace`: Replace value
- `move`: Move value
- `copy`: Copy value
- `test`: Validate value

#### Idempotency Debate

PATCH idempotency varies by implementation method.

```bash
# Idempotent PATCH (setting value)
PATCH /users/123 {"age": 31}

# Non-idempotent PATCH (increment operation)
PATCH /users/123 {"age_increment": 1}
```

Simple field replacement is idempotent. Increment/decrement operations are not idempotent. PATCH implementation requires careful consideration of idempotency.

### DELETE

DELETE is used to delete resources. It requests the server to delete a specific resource.

#### Key Features

- Requests cannot be cached.
- Used to delete resources.
- Not safe but idempotent.

DELETE requests are idempotent. Executing the same DELETE request multiple times leaves server state the same. The resource is deleted on the first request. Subsequent requests maintain the already-deleted state.

#### Response Status Codes

```bash
# Delete resource
curl -X DELETE https://api.example.com/users/123
```

Common response codes:

- `204 No Content`: Deletion successful, no response body (most common)
- `200 OK`: Deletion successful, includes deleted resource info in response body
- `202 Accepted`: Deletion request accepted but not yet processed (async processing)
- `404 Not Found`: Resource to delete does not exist

#### 404 Handling Debate

Response codes for DELETE requests on already-deleted resources vary by implementation.

**Return 204 No Content (Recommended)**

Strictly follows idempotency. The goal is resource absence. Even if already deleted, it's considered successful.

```http
DELETE /users/123
HTTP/1.1 204 No Content
```

**Return 404 Not Found**

Clearly indicates resource existence. The client knows they used an incorrect ID.

```http
DELETE /users/999
HTTP/1.1 404 Not Found
```

#### Soft Delete vs Hard Delete

**Hard Delete (Physical Deletion)**

```bash
# Completely remove from database
DELETE /users/123
```

**Soft Delete (Logical Deletion)**

```bash
# Set deleted_at field for logical deletion only
PATCH /users/123
{"deleted_at": "2025-01-15T10:30:00Z"}
```

Soft delete is commonly used for data recovery, audit trails, and maintaining foreign key integrity.

### HEAD

HEAD is identical to GET but has no response body. It is mainly used to retrieve resource header information.

#### Key Features

- Used to retrieve only server header information.
- Safe and idempotent.
- Cacheable.

HEAD requests return the same response headers as GET requests. They do not include the response body. This allows clients to check resource metadata.

#### Use Cases

```bash
# Check file size (before download)
curl -I https://example.com/large-file.zip

HTTP/1.1 200 OK
Content-Length: 104857600
Content-Type: application/zip
Last-Modified: Mon, 13 Jan 2025 10:00:00 GMT
```

- Check resource existence
- Check file size (Content-Length)
- Check last modified time (Last-Modified)
- Check content type (Content-Type)
- Validate cache (ETag)

### OPTIONS

OPTIONS requests the communication methods allowed for the server. It is used to check the HTTP methods supported for a specific resource.

#### Key Features

- Used to request allowed communication methods for the server.
- Safe and idempotent.
- Mainly used for CORS preflight requests.

OPTIONS requests return methods supported by the server and other options. This is useful for checking CORS (Cross-Origin Resource Sharing) settings.

#### General OPTIONS Request

```bash
curl -X OPTIONS https://api.example.com/users

HTTP/1.1 200 OK
Allow: GET, POST, HEAD, OPTIONS
```

#### CORS Preflight Request

Browsers automatically send OPTIONS requests before actual requests under certain conditions.

```http
OPTIONS /api/users HTTP/1.1
Origin: https://example.com
Access-Control-Request-Method: POST
Access-Control-Request-Headers: Content-Type, Authorization

HTTP/1.1 200 OK
Access-Control-Allow-Origin: https://example.com
Access-Control-Allow-Methods: GET, POST, PUT, DELETE
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 86400
```

### CONNECT

CONNECT establishes a tunnel to the server identified by the target resource. It is mainly used to set up tunneling through proxy servers using SSL (HTTPS).

#### Key Features

- Used to establish connections through proxy servers.
- Not safe and not idempotent.
- Commonly used for HTTPS proxies.

CONNECT requests establish TCP tunnels between client and server. The client can connect directly to the destination server through the proxy server.

#### How It Works

```http
CONNECT example.com:443 HTTP/1.1
Host: example.com:443

HTTP/1.1 200 Connection Established
```

The proxy server establishes the tunnel. It then relays data between client and destination server. Data transmitted afterward is encrypted. The proxy cannot see the content.

#### Security Considerations

CONNECT can use the proxy as a bypass route. This poses security risks. Most proxies restrict CONNECT to port 443 (HTTPS) only.

### TRACE

TRACE performs message loopback tests along the path to the target resource. It is used to check whether the server received the request sent by the client.

#### Key Features

- Used to send requests to the server and check if received.
- Safe and idempotent.
- Used for debugging purposes.

TRACE requests return the request sent by the client as-is. This allows checking for tampering by proxies or servers in the intermediate path.

#### How It Works

```http
TRACE /path HTTP/1.1
Host: example.com
Custom-Header: value

HTTP/1.1 200 OK
Content-Type: message/http

TRACE /path HTTP/1.1
Host: example.com
Custom-Header: value
```

#### Security Risks

TRACE can be exploited for XST (Cross-Site Tracing) attacks. Attackers can use TRACE to view requests containing HttpOnly cookies. For this reason, disabling TRACE on most web servers is recommended.

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

REST (Representational State Transfer) is an API design architectural style using HTTP methods.

### Resource-Centric Design

URLs represent resources. HTTP methods represent actions on those resources.

```
# Good example (resource-centric)
GET    /users          # Retrieve user list
GET    /users/123      # Retrieve specific user
POST   /users          # Create user
PUT    /users/123      # Update entire user
PATCH  /users/123      # Update part of user
DELETE /users/123      # Delete user

# Bad example (action-centric)
GET    /getUsers
POST   /createUser
POST   /updateUser
POST   /deleteUser
```

### Proper Use of HTTP Methods

Each method should be used for its correct purpose.

| Operation              | HTTP Method | URL Example           |
| ---------------------- | ----------- | --------------------- |
| List retrieval         | GET         | /users                |
| Single retrieval       | GET         | /users/123            |
| Creation               | POST        | /users                |
| Full update            | PUT         | /users/123            |
| Partial update         | PATCH       | /users/123            |
| Deletion               | DELETE      | /users/123            |
| Search                 | GET         | /users?name=John      |
| Related resource       | GET         | /users/123/posts      |
| Create related resource| POST        | /users/123/posts      |

### Combination with Status Codes

Use HTTP methods with appropriate status codes.

```
GET /users/123
  200 OK              - Success
  404 Not Found       - Resource not found

POST /users
  201 Created         - Creation successful
  400 Bad Request     - Invalid request
  409 Conflict        - Resource conflict

PUT /users/123
  200 OK              - Update successful
  204 No Content      - Update successful (no body)
  404 Not Found       - Resource not found

PATCH /users/123
  200 OK              - Update successful
  404 Not Found       - Resource not found

DELETE /users/123
  204 No Content      - Deletion successful
  404 Not Found       - Resource not found
```

### URL Design Rules

- Use plural nouns: `/users`, `/posts`
- Use lowercase: `/user-profiles` (with hyphens)
- Express hierarchy: `/users/123/posts/456/comments`
- Avoid verbs: `/users` (good), `/getUsers` (bad)
- Avoid extensions: `/users/123` (good), `/users/123.json` (bad)

## CORS and Preflight Requests

CORS (Cross-Origin Resource Sharing) is a mechanism allowing access to resources from different domains.

### Simple Request vs Preflight Request

**Simple Request Conditions**

Requests are sent immediately without preflight if all these conditions are met:

- Method: One of `GET`, `HEAD`, `POST`
- Headers: Only allowed headers like `Accept`, `Accept-Language`, `Content-Language`, `Content-Type`
- Content-Type: One of `application/x-www-form-urlencoded`, `multipart/form-data`, `text/plain`

**When Preflight Request is Needed**

OPTIONS preflight request is sent first if any of these apply:

- Method: `PUT`, `DELETE`, `PATCH`, etc.
- Custom headers: `Authorization`, `X-Custom-Header`, etc.
- Content-Type: `application/json`, etc.

### Preflight Request Flow

```
1. Browser sends OPTIONS preflight request
   OPTIONS /api/users HTTP/1.1
   Origin: https://example.com
   Access-Control-Request-Method: POST
   Access-Control-Request-Headers: Content-Type, Authorization

2. Server responds with allowed methods
   HTTP/1.1 200 OK
   Access-Control-Allow-Origin: https://example.com
   Access-Control-Allow-Methods: GET, POST, PUT, DELETE
   Access-Control-Allow-Headers: Content-Type, Authorization
   Access-Control-Max-Age: 86400

3. Actual POST request is sent
   POST /api/users HTTP/1.1
   Origin: https://example.com
   Content-Type: application/json
   Authorization: Bearer token123

4. Server returns actual response
   HTTP/1.1 201 Created
   Access-Control-Allow-Origin: https://example.com
```

### Resolving CORS Errors

**Server-Side Configuration (Node.js/Express Example)**

```javascript
const cors = require('cors');

// Allow all domains
app.use(cors());

// Allow specific domains only
app.use(cors({
  origin: 'https://example.com',
  methods: ['GET', 'POST', 'PUT', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  maxAge: 86400
}));
```

**Server-Side Configuration (Nginx Example)**

```nginx
add_header Access-Control-Allow-Origin https://example.com;
add_header Access-Control-Allow-Methods "GET, POST, PUT, DELETE, OPTIONS";
add_header Access-Control-Allow-Headers "Content-Type, Authorization";
add_header Access-Control-Max-Age 86400;

if ($request_method = OPTIONS) {
    return 204;
}
```

## Practical Example: Blog API Design

A RESTful API endpoint design example for an actual blog system.

### Post Management

```bash
# Retrieve post list (pagination, filtering)
curl -X GET "https://api.blog.com/posts?page=1&limit=10&category=tech&sort=created_at"

# Retrieve post details
curl -X GET https://api.blog.com/posts/123

# Create post
curl -X POST https://api.blog.com/posts \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "title": "Complete HTTP Methods Guide",
    "content": "Content...",
    "category": "tech",
    "tags": ["http", "rest"]
  }'

# Full post update
curl -X PUT https://api.blog.com/posts/123 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "title": "Updated Title",
    "content": "Updated content...",
    "category": "tech",
    "tags": ["http", "rest", "api"]
  }'

# Partial post update (title only)
curl -X PATCH https://api.blog.com/posts/123 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{"title": "New Title"}'

# Delete post
curl -X DELETE https://api.blog.com/posts/123 \
  -H "Authorization: Bearer token123"
```

### Comment Management (Nested Resources)

```bash
# Retrieve comments for specific post
curl -X GET https://api.blog.com/posts/123/comments

# Create comment
curl -X POST https://api.blog.com/posts/123/comments \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{
    "content": "Great article, thanks!",
    "author": "John Doe"
  }'

# Update comment
curl -X PATCH https://api.blog.com/posts/123/comments/456 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer token123" \
  -d '{"content": "Updated comment content"}'

# Delete comment
curl -X DELETE https://api.blog.com/posts/123/comments/456 \
  -H "Authorization: Bearer token123"
```

### File Upload

```bash
# Image upload
curl -X POST https://api.blog.com/posts/123/images \
  -H "Authorization: Bearer token123" \
  -F "image=@photo.jpg" \
  -F "caption=Post image"
```

## Security Considerations

Security considerations when using HTTP methods.

### Recommend Disabling TRACE Method

TRACE is vulnerable to XST (Cross-Site Tracing) attacks. It should be disabled in production environments.

```apache
# Apache
TraceEnable off
```

```nginx
# Nginx
if ($request_method = TRACE) {
    return 405;
}
```

### Prohibit State Changes with GET

GET requests should be safe. They should not change server state.

```
# Bad examples
GET /users/123/delete
GET /posts/456/publish

# Good examples
DELETE /users/123
PATCH /posts/456 {"status": "published"}
```

Reasons:

- Browsers can prefetch GET requests
- Search engine crawlers can follow GET requests
- Requests remain in browser history and can be re-executed

### CSRF (Cross-Site Request Forgery) Attack Prevention

POST, PUT, DELETE requests can be vulnerable to CSRF attacks.

**Using CSRF Tokens**

```html
<form method="POST" action="/api/users">
  <input type="hidden" name="csrf_token" value="random_token_value">
  <!-- Form fields -->
</form>
```

**Setting SameSite Cookie Attribute**

```http
Set-Cookie: session=abc123; SameSite=Strict; Secure; HttpOnly
```

**Custom Header Validation**

```javascript
// Client
fetch('/api/users', {
  method: 'POST',
  headers: {
    'X-Requested-With': 'XMLHttpRequest',
    'Content-Type': 'application/json'
  },
  body: JSON.stringify(data)
});

// Server
if (!request.headers['X-Requested-With']) {
  return 403; // Forbidden
}
```

### Authentication and Authorization Validation

State-changing methods (POST, PUT, PATCH, DELETE) must always validate authentication and authorization.

```javascript
// Express middleware example
app.delete('/users/:id', authenticateToken, authorizeUser, (req, res) => {
  // User deletion logic
});

function authenticateToken(req, res, next) {
  const token = req.headers['authorization'];
  if (!token) return res.sendStatus(401);

  jwt.verify(token, SECRET_KEY, (err, user) => {
    if (err) return res.sendStatus(403);
    req.user = user;
    next();
  });
}

function authorizeUser(req, res, next) {
  if (req.user.id !== req.params.id && !req.user.isAdmin) {
    return res.sendStatus(403);
  }
  next();
}
```

### Input Validation and Limits

- Limit request body size (prevent DoS)
- Validate and sanitize input data
- Prevent SQL injection and XSS

```javascript
// Express body size limit
app.use(express.json({ limit: '10mb' }));

// Input validation (Joi library example)
const schema = Joi.object({
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(0).max(150)
});

const { error, value } = schema.validate(req.body);
if (error) return res.status(400).json({ error: error.details });
```

## Summary

HTTP methods are core elements defining operations in client-server communication. The HTTP/1.1 standard defines 9 methods. Each method has important characteristics: safety and idempotency.

### Key Points

- **Safe Methods** (GET, HEAD, OPTIONS, TRACE): Do not change server state
- **Idempotent Methods** (GET, PUT, DELETE, HEAD, OPTIONS, TRACE): Same result when executed multiple times
- **Non-Idempotent Methods** (POST, PATCH): Different results possible each execution

### Practical Application

- **RESTful API Design**: Resource-centric URLs with appropriate HTTP method combinations
- **CORS Understanding**: Preflight request mechanism and server configuration
- **Security**: CSRF prevention, authentication/authorization validation, input validation

Proper understanding and use of HTTP methods enables designing scalable and maintainable web APIs.

### References

- [MDN web docs - HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP)
- [RFC 7231 - HTTP/1.1 Semantics and Content](https://tools.ietf.org/html/rfc7231)
- [RFC 6902 - JSON Patch](https://tools.ietf.org/html/rfc6902)
- [REST API Design Best Practices](https://restfulapi.net/)
