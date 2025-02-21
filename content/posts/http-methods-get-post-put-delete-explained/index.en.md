---
title: "HTTP methods in a nutshell"
date: 2024-05-25T14:05:29+09:00
tags: ["Definitions", "HTTP"]
draft: false
---

> The HTTP protocol is a communication protocol for transmitting data between a client and a server. The HTTP protocol consists of requests and responses, and the methods used in requests and responses are called HTTP methods.

## HTTP Methods

An HTTP method is a method used by a client to send a request to a server. There are various methods depending on the type of request.

1. **GET**
2. **POST**
3. **PUT**
4. **PATCH**
5. **DELETE**
6. **HEAD**
7. **OPTIONS**
8. **CONNECT**
9. **TRACE**

### GET

The GET method is used to retrieve a specific resource. This method is used to query data from the server and returns the resource as a response to the request without modifying the data.

-   Requests can be cached.
-   When sending a request, data is not included in the body of the HTTP message, but is sent through the query string.
-   It is commonly used to retrieve data or request a page.

GET requests should only be used to retrieve data and should not change the state of the server. This makes GET requests safe and idempotent. In other words, executing the same GET request multiple times should return the same result.

> Idempotence: A property of a method that, when executed multiple times, produces the same result.

### POST

The POST method is used to send data to the server. This method is mainly used to create new resources or submit data to the server.

-   Requests cannot be cached.
-   When sending a request, the data is included in the body of the HTTP message.
-   It is commonly used for submitting form data, uploading files, and requesting data processing.

POST requests do not guarantee idempotence, so sending the same request multiple times can change the state of the server multiple times.

### PUT

The PUT method is used to create or modify a resource. This method can be used to save a resource at a location specified by the client or to update an existing resource at that location.

-   Requests cannot be cached.
-   When sending a request, the data is included in the body of the HTTP message.
-   It is used to update the entire resource or create a new resource.

PUT requests are idempotent. Executing the same PUT request multiple times will give the same result. This is because it makes changes to the entire state of the resource, so no partial changes occur.

### PATCH

The PATCH method is used to modify parts of a resource. This method changes only part of the existing resource.

-   Requests cannot be cached.
-   When sending a request, the data is included in the body of the HTTP message.
-   It is used to update parts of a resource.

The difference between PUT and PATCH is that PUT is used to modify the entire resource, while PATCH is used to modify parts of the resource.

The entire resource:

```json
{
    "name": "John",
    "age": 25
}
```

PATCH request:

```json
{
    "age": 26
}
```

With a resource like the one above, you can update only the `age` field using a PATCH request.

### DELETE

The DELETE method is used to delete a resource. This method is used when the client wants the server to delete a specific resource.

-   Requests cannot be cached.
-   It is used to delete a resource.

DELETE requests are idempotent. Executing the same DELETE request multiple times leaves the state of the server the same.

### HEAD

The HEAD method is similar to the GET method, but it does not have a body in the response. This method is mainly used to obtain the header information of the resource.

-   It is used to get only the header information of the server.

HEAD requests return the same response headers as GET requests, but they do not include the response body. This allows the client to check the metadata of the resource.

### OPTIONS

The OPTIONS method requests the communication methods that are allowed for the server. This method is used to check the supported HTTP methods for a specific resource.

-   It is used to request the allowed communication methods for the server.

OPTIONS requests return the methods supported by the server and other options. This is useful for checking Cross-Origin Resource Sharing (CORS) settings.

### CONNECT

The CONNECT method establishes a tunnel to the server identified by the target resource. This method is mainly used to set up tunneling through a proxy server that uses SSL (HTTPS).

-   It is used to establish a connection through a proxy server.

CONNECT requests establish a TCP tunnel between the client and the server, allowing the client to connect directly to the destination server through the proxy server.

### TRACE

The TRACE method performs a message loopback test along the path to the target resource. This method is used to check whether a request was received by the server when sent by the client.

-   It is used to send a request to the server and check whether the request was received by the server.

TRACE requests return the request sent by the client as it is, allowing you to check whether there were any modifications by proxies or servers along the way.

## Summary

HTTP methods are used by clients to send requests to servers. HTTP methods vary depending on the type of request, and each method has a specific purpose and function. The GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS, CONNECT, and TRACE methods are used to meet various requirements for HTTP requests and responses.

### Reference

-   [MDN web docs - HTTP](https://developer.mozilla.org/en-US/docs/Web/HTTP)
