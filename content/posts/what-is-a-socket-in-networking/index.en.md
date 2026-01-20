---
title: "Complete Guide to Sockets: From TCP/UDP to WebSocket"
date: 2024-06-08T21:22:40+09:00
tags: ["Network", "Socket", "TCP", "UDP", "WebSocket"]
description: "A comprehensive guide covering Berkeley Sockets history, TCP/UDP socket mechanics, core socket programming functions, client-server architecture, and the relationship with WebSocket"
draft: false
---

A socket is a software interface that abstracts network communication endpoints, first appearing in the 4.2BSD Unix operating system developed at UC Berkeley in 1983 and remaining a fundamental technology underlying internet communication to this day. It identifies unique communication points on a network through the combination of IP address and port number, providing a standardized API that enables data exchange between processes.

## History and Evolution of Sockets

> **The Birth of Berkeley Sockets**
>
> Berkeley Sockets (BSD Sockets) was first introduced in BSD UNIX 4.1 in 1982, with the refined version in BSD UNIX 4.3 from 1986 remaining widely used today. Initially a de facto standard, it was later adopted as an official component of the POSIX specification, enabling network programming with the same interface across virtually all operating systems.

Before the socket interface was standardized, each operating system and network stack used its own unique network programming interface, resulting in very low portability. The emergence of Berkeley Sockets laid the foundation for platform-independent network application development. Windows adopted the BSD socket API under the name Winsock (Windows Sockets), enabling nearly identical code to work for network programming across Unix-like systems and Windows.

## Basic Concepts of Sockets

> **What is a Socket?**
>
> A socket is an abstracted interface for sending and receiving data over a network, uniquely identified by three elements: protocol (TCP/UDP), IP address, and port number. Just as a telephone converts voice signals to electrical signals in telecommunications, a socket converts application data to network packets and vice versa.

Sockets can be broadly divided into two roles. Server sockets listen for incoming connection requests from clients at a specific IP address and port, while client sockets attempt to connect to server sockets to form a communication channel. Once a connection is established, both sides can send and receive data in the same manner. Since the operating system manages sockets as file descriptors, network communication can be handled similarly to file I/O operations.

## Transport Layer Protocols: TCP vs UDP

TCP and UDP are protocols that operate at Layer 4 (transport layer) of the OSI model, each with different characteristics and purposes, and are the key factors in determining socket types in socket programming.

### TCP (Transmission Control Protocol)

> **Core Characteristics of TCP**
>
> TCP is a connection-oriented and reliable transmission protocol that guarantees data arrives in order and correctly. It establishes connections through a 3-way handshake and provides error detection and retransmission, flow control, and congestion control mechanisms to ensure data integrity.

TCP connections are established through a 3-way handshake process of SYN → SYN-ACK → ACK, during which initial sequence numbers (ISN) are exchanged and connection parameters such as receive window size are negotiated. After connection establishment, each segment is assigned a sequence number allowing the receiver to reassemble the order, transmission success is confirmed through acknowledgments (ACK), and automatic retransmission occurs on timeout.

| Characteristic | Description |
|----------------|-------------|
| **Header Size** | 20-60 bytes (up to 60 with options) |
| **Data Unit** | Segment |
| **Connection Setup** | Requires 3-way handshake |
| **Reliability** | Order guarantee, error detection/retransmission, flow/congestion control |
| **Use Cases** | HTTP, HTTPS, FTP, SMTP, SSH, database connections |

### UDP (User Datagram Protocol)

> **Core Characteristics of UDP**
>
> UDP is a connectionless and unreliable transmission protocol that can transmit data immediately without a connection setup process. With low overhead and short latency, it is suitable for applications where real-time performance is important.

Since UDP has no connection establishment or termination process, it can transmit from the first datagram immediately, with each datagram processed independently without order guarantees. Even if packet loss occurs, there is no retransmission, so applications must implement their own reliability mechanisms when needed. However, this simplicity allows UDP to achieve much lower latency than TCP.

| Characteristic | Description |
|----------------|-------------|
| **Header Size** | Fixed 8 bytes |
| **Data Unit** | Datagram |
| **Connection Setup** | Not required (connectionless) |
| **Reliability** | None (application must handle) |
| **Use Cases** | DNS, DHCP, VoIP, video streaming, online games, QUIC |

### TCP vs UDP Selection Criteria

| Requirement | Recommended Protocol |
|-------------|---------------------|
| Data integrity is essential | TCP |
| Low latency needed | UDP |
| Order guarantee needed | TCP |
| Some loss is acceptable | UDP |
| Broadcast/Multicast | UDP |
| Large file transfer | TCP |

## Core Functions in Socket Programming

The main system calls used in socket programming are socket, bind, listen, accept, and connect. Servers and clients call these functions in a defined order to establish connections and exchange data.

### socket()

The socket() function creates a new socket and returns a file descriptor referencing that socket, taking domain (AF_INET for IPv4, AF_INET6 for IPv6), type (SOCK_STREAM for TCP, SOCK_DGRAM for UDP), and protocol as arguments to determine what kind of communication to perform. Both servers and clients must call this function before starting communication.

### bind()

The bind() function assigns a local IP address and port number to a socket, specifying the socket's location on the network, and is primarily used on the server side to receive connections on a specific port. Clients typically omit bind() to let the operating system automatically assign an available port.

### listen()

The listen() function converts a TCP server socket from active mode to passive mode to listen for incoming connection requests, with the second argument specifying the backlog queue size. Only after this function is called can client connect() requests reach the server.

### accept()

The accept() function retrieves the first connection request from the queue, creates and returns a new socket for that connection, while the original listening socket can continue to accept additional connections. This function blocks until a connection request arrives, and the actual data exchange with the client occurs through the returned new socket.

### connect()

The connect() function is used on the client side to attempt a connection to the specified server address and port, performing a 3-way handshake for TCP connections. connect() can also be called on UDP sockets, but in this case no actual connection is established; rather, a default destination address is set so the address can be omitted in subsequent send() calls.

### Communication Flow Diagram

![TCP Socket Communication Flow](socket-flow.png)

## Client-Server Architecture

> **The Client-Server Model**
>
> Client-server architecture is the most fundamental distributed computing model for network applications, with roles divided between clients requesting services and servers providing them. This model offers advantages in resource centralization, security management ease, and scalability, and most internet services including web, email, and databases follow this structure.

Clients and servers may run on the same physical machine or on separate hardware connected through a network, and it is common for a single server to handle thousands of client connections simultaneously. Servers are always running and waiting for client requests, while clients connect to servers when needed, request services, and then terminate the connection in a typical pattern.

### Concurrency Handling Models

Methods for servers to handle multiple clients simultaneously include multi-process, multi-threaded, event-based (non-blocking I/O), and hybrid models combining these approaches. Recently, event-based models utilizing operating system-level event notification mechanisms such as epoll (Linux), kqueue (BSD), and IOCP (Windows) are widely used for their high concurrency and efficiency, with Node.js, Nginx, and Redis adopting this approach.

## WebSocket: Bidirectional Communication for the Web

> **What is WebSocket?**
>
> WebSocket is a bidirectional communication protocol standardized by the IETF as RFC 6455 in 2011, providing a full-duplex communication channel over a single TCP connection. It overcomes the limitations of HTTP's unidirectional request-response model and allows servers to push data to clients, making it ideal for real-time web applications.

### Relationship Between Sockets and WebSocket

| Aspect | TCP/UDP Socket | WebSocket |
|--------|----------------|-----------|
| **OSI Layer** | Layer 4 (Transport) | Layer 7 (Application) |
| **Base Protocol** | IP | TCP + HTTP (handshake) |
| **Port** | Any port available | 80 (ws), 443 (wss) |
| **Proxy/Firewall** | Separate configuration needed | HTTP compatible, passes through most |
| **Message Framing** | Must implement manually | Provided by protocol |
| **Browser Support** | Not possible (direct access) | Native API provided |

WebSocket is based on TCP sockets but is a higher-layer protocol designed for HTTP compatibility. It uses HTTP Upgrade handshake during connection establishment to pass through existing HTTP infrastructure (proxies, load balancers, firewalls), and after connection is established, data is exchanged in a lightweight frame format without HTTP overhead.

### WebSocket Use Cases

WebSocket is used in all situations where data must be immediately pushed from server to client, including chat applications, real-time collaboration tools (Google Docs, Figma), stock tickers/cryptocurrency exchanges, online games, live sports scores, and IoT dashboards. It provides lower latency and bidirectional communication capabilities compared to traditional long polling or Server-Sent Events (SSE).

## Conclusion

Sockets started with Berkeley Sockets in 1983 and have remained the standard interface for network programming for over 40 years, satisfying the communication needs of various applications on top of two transport protocols: TCP and UDP. TCP is used where reliability and order guarantee are needed, while UDP is used where real-time performance and low latency are important, and this choice determines application performance and characteristics. WebSocket is a technology that abstracts these low-level socket concepts for the web environment, enabling real-time bidirectional communication even in browsers.
