---
title: "REST API: From Principles to Considerations"
date: 2024-07-20T16:23:17+09:00
tags: ["rest", "api", "design"]
description: "A comprehensive guide to REST API design principles and best practices. Covers Roy Fielding's REST architectural style, 6 constraints, HTTP method usage, resource-centric URL design, versioning strategies, error handling, pagination, HATEOAS for practical REST API implementation with focus on decision-making criteria and trade-offs"
draft: false
---

## Introduction

In modern web development, Representational State Transfer (REST) APIs play a pivotal role. A well-designed REST API enables efficient communication between systems and greatly enhances developer productivity. This article covers everything from fundamental REST concepts to the 6 core principles, focusing on decision-making criteria and trade-offs for real-world API design.

## REST Fundamentals

REST is a software architectural style introduced in Roy Fielding's 2000 doctoral dissertation. Before REST, web services primarily used SOAP and XML-RPC, which required complex XML-based message formats and strict protocols. Roy Fielding proposed a simple and scalable architecture that maximizes HTTP's advantages.

### Richardson Maturity Model

Leonard Richardson classified REST API maturity into 4 levels:

- **Level 0**: Uses a single URI and method (HTTP as mere transport)
- **Level 1**: Defines URIs for individual resources but uses only a single HTTP method
- **Level 2**: Properly uses HTTP methods and status codes (target for most production APIs)
- **Level 3**: Implements HATEOAS with links to possible next actions (rarely implemented)

### RESTful vs REST-like

Implementing a perfect REST API is challenging in practice. **RESTful APIs** fully comply with all constraints including HATEOAS, while **REST-like APIs** primarily use HTTP methods and resource-based URLs. Most real-world APIs are closer to being REST-like.

## 6 Principles of REST

### 1. Client-Server

Separates concerns of clients and servers, enabling independent evolution. Through clear interface definition, servers handle data storage while clients handle user interfaces, improving system scalability.

### 2. Stateless

Each request is independent, and the server does not store client state. This enables high reliability, scalability, and efficient use of server resources. Session state is managed client-side by including all necessary information in requests, such as JWT tokens.

```http
GET /api/users/me HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 3. Cacheable

Responses must indicate whether they are cacheable. Using HTTP caching headers (Cache-Control, ETag) improves performance and reduces server load. ETag saves network bandwidth by returning a 304 status code when resources haven't changed.

### 4. Layered System

Clients only need to know about the immediately adjacent layer. Through the API Gateway pattern, clients communicate only with the gateway without needing to know about internal microservices. This enhances system scalability and security.

### 5. Uniform Interface

The core principle of REST includes resource identification, resource manipulation through representations, self-descriptive messages, and HATEOAS. Through consistent resource naming conventions, proper HTTP method usage, and hyperlinks in responses, it simplifies system architecture and enhances client-server independence.

### 6. Code on Demand (Optional)

The server can transfer executable code to the client to dynamically extend client functionality. Client-side scripting with JavaScript is a typical example.

## REST API Design Rules

### 1. Resource-Oriented URL Design

Represent resources using nouns (`/users`, `/articles`), use plurals, lowercase, and hyphens (-). Express relationships clearly through hierarchical resource representation:

```
GET /users/{userId}/posts/{postId}/comments
```

**Action-Based Endpoints**: Use verbs for operations difficult to express with standard CRUD:

```
POST /users/{id}/activate
POST /orders/{id}/cancel
```

**URL Length Limits**: Most browsers have 2000-8000 character limits, so consider sending complex search conditions in POST request bodies or creating separate search APIs.

### 2. HTTP Methods and Status Codes

- **GET**: Retrieve resources (idempotent)
- **POST**: Create new resources
- **PUT**: Update entire resources (idempotent)
- **PATCH**: Partial resource updates
- **DELETE**: Delete resources (idempotent)

Key status codes: 200 (success), 201 (created), 204 (no content), 400 (bad request), 401 (unauthorized), 403 (forbidden), 404 (not found), 500 (server error)

### 3. Versioning Strategies

#### URL Versioning

```
GET /api/v1/users
```

**Pros**: Clear, intuitive, easy to test in browsers, simple caching
**Cons**: Longer URLs, debate about violating REST principles due to resource URI changes

#### Header Versioning

```http
Accept: application/vnd.myapp.v1+json
```

**Pros**: Cleaner URLs, aligns with REST principles, utilizes content negotiation
**Cons**: Difficult to test in browsers, complex caching configuration

#### Version Change Criteria

- **Major changes**: Removing endpoints, fundamental response format changes, authentication method changes
- **Minor changes**: Adding endpoints/fields (backward compatible), optional parameters
- **No change needed**: Bug fixes, performance improvements, internal implementation changes

In practice, URL versioning is most widely used, while header versioning is chosen when pursuing REST purism.

### 4. Pagination Strategies

#### Offset-based Pagination

```
GET /api/users?page=2&per_page=20
```

**Pros**: Simple implementation, can jump to specific pages
**Cons**: Performance degradation with large datasets, duplicates or omissions when data is added/deleted

#### Cursor-based Pagination

```
GET /api/users?cursor=eyJpZCI6MTAwfQ==&limit=20
```

**Pros**: Consistent performance with large datasets, stable with real-time data changes
**Cons**: Cannot jump to specific pages, complex implementation

**Selection criteria**: Use Offset for small datasets or when page numbers are needed, Cursor for large datasets or real-time feeds.

### 5. HATEOAS

Include links to related resources in responses, allowing clients to discover possible next actions:

```json
{
  "id": 711,
  "name": "John Doe",
  "_links": {
    "self": { "href": "/users/711" },
    "posts": { "href": "/users/711/posts" }
  }
}
```

If not pursuing perfect REST (Level 3), implement optionally. It reduces coupling between client and server.

### 6. Error Handling

Use consistent error response formats to enhance developer experience:

```json
{
  "status": 400,
  "code": "INVALID_EMAIL",
  "message": "The provided email is invalid",
  "details": "The email 'johndoe@' is missing a domain name"
}
```

`code` enables programmatic handling, `message` provides human-readable description, and `details` offers additional context.

## Security Considerations

### Authentication and Authorization

**Basic Authentication**: Simple but requires HTTPS. Suitable for server-to-server communication or internal systems.

**Bearer Token (JWT)**: Most widely used, maintains statelessness. Consists of Header (algorithm), Payload (user information), and Signature (integrity verification).

**OAuth 2.0**: Securely grants access to third-party applications. Choose when accessing on behalf of users or needing fine-grained permission control.

**Selection criteria**:
- Internal systems, server-to-server: API Key or Basic Auth
- General user authentication: JWT
- Third-party app integration, social login: OAuth 2.0

### Rate Limiting

Prevents excessive API calls and protects server resources. Provide limit information with 429 Too Many Requests and `X-RateLimit-*` headers:

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1735689600
```

**Token Bucket**: Can handle burst traffic, complex implementation
**Sliding Window**: More accurate limiting, can leverage Redis

## Performance Optimization

- **Caching**: Leverage Cache-Control, ETag headers
- **Response compression**: Use gzip to save bandwidth
- **Payload minimization**: Return only necessary data, consider supporting Sparse Fieldsets

## Documentation

Good API documentation significantly enhances developer experience.

### OpenAPI/Swagger

The most widely used standard. Define APIs in YAML/JSON and provide interactive documentation with Swagger UI. Can auto-generate from code using FastAPI or Express+Swagger JSDoc.

### Documentation Tool Selection

- **Public APIs**: OpenAPI/Swagger (standard, rich tool ecosystem)
- **Internal APIs**: Postman Collections (easy team collaboration)
- **Quick prototyping**: API Blueprint (Markdown-based)

## Practical Design Example

Core endpoint structure for a blog API:

```
POST   /api/auth/register           # User registration
POST   /api/auth/login              # Login
GET    /api/users/{id}              # Profile retrieval
PATCH  /api/users/{id}              # Profile update

GET    /api/posts                   # Post list (filtering, pagination)
GET    /api/posts/{id}              # Post details
POST   /api/posts                   # Create post
PUT    /api/posts/{id}              # Update post
DELETE /api/posts/{id}              # Delete post

GET    /api/posts/{id}/comments     # Comment list
POST   /api/posts/{id}/comments     # Create comment
PATCH  /api/posts/{id}/comments/{cid} # Update comment
DELETE /api/posts/{id}/comments/{cid} # Delete comment
```

Support filtering (`?status=published&tag=javascript`), sorting (`?sort=-created_at`), and pagination (`?page=1&per_page=20`) via query parameters, and include metadata and links in responses.

## Limitations and Alternatives to REST

REST is versatile but not the optimal solution for every scenario:

- **Real-time communication**: WebSocket (bidirectional, low latency)
- **Complex data requirements**: GraphQL (clients request only needed data, prevents over-fetching)
- **High-performance microservices**: gRPC (Protobuf, HTTP/2 based)

Understand trade-offs of each technology and select based on project requirements.

## Conclusion

REST API design is a complex process that must consider not just technical decisions but also user experience and business requirements. Understanding principles is important, but rather than blindly following them, it's crucial to grasp trade-offs of each design decision and apply them flexibly to project characteristics. The key to successful API design is targeting practical and consistent APIs rather than perfect RESTful APIs, while emphasizing documentation and developer experience.
