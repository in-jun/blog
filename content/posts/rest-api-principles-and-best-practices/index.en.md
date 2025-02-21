---
title: "REST API: From Principles to Considerations"
date: 2024-07-20T16:23:17+09:00
tags: ["rest", "api", "design"]
draft: false
---

## Introduction

In modern web development, Representational State Transfer (REST) APIs play a pivotal role. A well-designed REST API enables efficient communication between systems and greatly enhances developer productivity. In this article, we'll cover everything from the fundamental concepts of REST to the 6 core principles, and delve into specific rules and best practices that you can apply when designing real-world APIs.

## REST Fundamentals

REST is a software architectural style introduced by Roy Fielding in his 2000 doctoral dissertation. REST leverages existing web technologies and the HTTP protocol to define an architecture for distributed hypermedia systems.

The key components of REST are as follows:

1. **Resources**: All information is represented as resources that have unique identifiers.
2. **Methods**: HTTP methods (GET, POST, PUT, DELETE, etc.) are used to define actions on resources.
3. **Representations**: The format in which data is exchanged between clients and servers, commonly JSON.

## 6 Principles of REST

REST is based on the following 6 principles:

### 1. Client-Server

- **Description**: Separates concerns of clients and servers.
- **Benefits**:
    - Clients and servers can evolve independently.
    - Improves system scalability.
- **Implementation**:
    - Define a clear interface.
    - Server handles data storage, client handles user interface.

### 2. Stateless

- **Description**: Each request is independent, and the server does not store the state of the client.
- **Benefits**:
    - High reliability and scalability.
    - Efficient use of server resources.
- **Implementation**:
    - Manage session state on the client-side.
    - Include all necessary information in requests.

### 3. Cacheable

- **Description**: Responses must indicate whether they are cacheable or not.
- **Benefits**:
    - Improved performance.
    - Reduced server load.
- **Implementation**:
    - Use HTTP caching headers (Cache-Control, ETag, etc.).
    - Define caching policies in responses.

### 4. Layered System

- **Description**: Clients only need to know about the immediately adjacent layer.
- **Benefits**:
    - Increased system scalability.
    - Improved security.
- **Implementation**:
    - Use proxies, gateways.
    - Implement microservice architecture.

### 5. Code on Demand (Optional)

- **Description**: The server can transfer executable code to the client.
- **Benefits**: Dynamically extend client functionality.
- **Implementation**: Client-side scripting with JavaScript.

### 6. Uniform Interface

- **Description**: The core principle of REST, it includes the following four constraints:
    1. Resource identification.
    2. Resource manipulation through representations.
    3. Self-descriptive messages.
    4. Hypermedia as the engine of application state (HATEOAS).
- **Benefits**:
    - Simplifies system architecture.
    - Enhances client-server independence.
- **Implementation**:
    - Consistent resource naming conventions.
    - Proper use of HTTP methods.
    - Include hyperlinks in responses (HATEOAS).

## REST API Design Rules

Let's examine specific rules for designing effective REST APIs:

### 1. Resource-Oriented URL Design

- Represent resources using nouns (e.g., `/users`, `/articles`).
- Pluralize nouns, where applicable.
- Use consistent casing (lowercase recommended).
- Use hyphens (-), avoid underscores (_).

Example:

- Good: `/api/users`, `/api/blog-posts`.
- Bad: `/api/getUsers`, `/api/blog_posts`.

### 2. Proper Use of HTTP Methods

- GET: Retrieve a resource.
- POST: Create a new resource.
- PUT: Update an entire resource.
- PATCH: Update a partial resource.
- DELETE: Delete a resource.

Example:

- Retrieve a user: GET /users.
- Create a new user: POST /users.
- Update all user information: PUT /users/{id}.
- Update part of user information: PATCH /users/{id}.

### 3. Use Appropriate HTTP Status Codes

- 200: Success.
- 201: Created successfully.
- 204: Success (no content in response body).
- 400: Bad request.
- 401: Unauthorized.
- 403: Forbidden.
- 404: Resource not found.
- 500: Internal server error.

### 4. Versioning

- Include version information in the URL: `/api/v1/users`.
- Specify version via header: `Accept: application/vnd.myapp.v1+json`.

### 5. Support Filtering, Sorting, and Pagination

- Filtering: `/users?role=admin`.
- Sorting: `/users?sort=name:asc,created_at:desc`.
- Pagination: `/users?page=2&per_page=100`.

### 6. Implement HATEOAS

Include links to related resources in responses:

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

### 7. Error Handling

Use a consistent error response format:

```json
{
    "status": 400,
    "code": "INVALID_EMAIL",
    "message": "The provided email is invalid",
    "details": "The email 'johndoe@' is missing a domain name"
}
```

## Considerations When Implementing REST APIs

### 1. Security

- Enforce HTTPS.
- Implement proper authentication and authorization mechanisms (OAuth, JWT, etc.).
- Implement rate limiting.

### 2. Performance Optimization

- Caching strategies (leveraging ETag, Cache-Control headers).
- Response compression (gzip, etc.).
- Minimize payload size (return only necessary data).

### 3. Documentation

- Use OpenAPI (Swagger).
- Provide sample requests and responses.
- Maintain a change log.

## Limitations and Alternatives to REST

While REST offers many advantages, it's not the optimal solution for every scenario:

- For real-time communication: Consider WebSocket.
- For complex data requirements: Explore GraphQL.
- For high-performance needs: Look into alternatives like gRPC.

## Conclusion

Designing REST APIs is not just a technical decision but a multifaceted process that should consider both user experience and business requirements. It is crucial to build upon the principles and rules covered in this article while flexibly adapting them to the unique characteristics of each project.
