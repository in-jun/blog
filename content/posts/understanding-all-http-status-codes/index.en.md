---
title: "Understanding HTTP Status Codes"
date: 2024-06-05T09:38:59+09:00
tages: ["http", "status code"]
draft: false
---

## 1xx (Informational): Request received and process is continuing

-   100 Continue: Server has received part of the request and the client should continue sending the request
-   101 Switching Protocols: Server has accepted the upgrade request and switched the protocol
-   102 Processing: Server has received the request and is processing it
-   103 Early Hints: Server has sent some of the response and the client can continue sending the request

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

## Reference

-   [https://developer.mozilla.org/en-US/docs/Web/HTTP/Status](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status)

> 418 I'm a teapot: This status code was defined on April 1, 1998, by the IETF as an extension to the Hyper Text Coffee Pot Control Protocol (HTCPCP) and is intended to be used to test if a coffee pot is connected and has hot water available. It is a joke and not meant to be used in real applications.
