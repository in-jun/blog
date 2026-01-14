---
title: "What is a Socket?"
date: 2024-06-08T21:22:40+09:00
tags: ["network", "socket"]
description: "A comprehensive guide covering Berkeley Sockets history from 1983, detailed comparison of TCP and UDP sockets, socket programming process (socket, bind, listen, accept, connect), client-server architecture, and differences from WebSocket"
draft: false
---

## History of Sockets

Sockets were created at the University of California, Berkeley and originated with the 4.2BSD Unix operating system released in 1983.

### Birth of Berkeley Socket

Berkeley sockets or BSD sockets are APIs for internet domain sockets and Unix domain sockets used in inter-process communication (IPC):

- **1982**: First introduced in BSD UNIX 4.1
- **1986**: The widely used version was refined in BSD UNIX 4.3
- Evolved from de facto standard to becoming a component of the POSIX specification with minimal modifications

## What are Sockets

Sockets are software that provides an interface for network communication. They enable communication between clients and servers and allow data exchange.

### Socket Functions

- Provide APIs for network communication
- Support both TCP and UDP
- Connect two nodes on a network to communicate

### Communication Method

One socket listens on a specific port at a specific IP. Another socket approaches the other to form a connection.

## Detailed Comparison of TCP and UDP Sockets

TCP and UDP are protocols used in the transport layer of TCP/IP. The transport layer is responsible for checking errors in packets delivered by IP and controlling retransmission requests.

### TCP Socket

TCP is a connection-oriented, reliable transmission protocol.

#### Connection-Oriented Services

- Performs 3-way handshaking before transmitting data
- Establishes a logical connection between the transport layers of two hosts
- TCP communication is divided into three stages: connection setup, data transfer, and connection termination

#### Reliability Guarantee Mechanisms

- **Error control**: Detects and retransmits damaged segments, retransmits lost segments
- **Order guarantee**: Sorts segments that arrived out of order and detects and discards duplicate segments
- **Flow control**: Transmits data at a rate the receiver can process
- **Congestion control**: Detects network congestion and adjusts transmission rate

#### Characteristics

- Header size: 20 bytes
- Data transmission unit: Segment
- Speed: Relatively slow (overhead due to reliability guarantee)

#### Use Cases

- Communication where reliability is important (HTTP, file transfer, etc.)
- Financial transaction systems where data order and reliability are important
- Database management systems

### UDP Socket

UDP is a connectionless, unreliable transmission protocol.

#### Connectionless Characteristics

- No session establishment process like 3-way handshake
- No connection setup and termination process

#### Unreliable Characteristics

- Does not provide flow control, error control, or congestion control
- Does not confirm receipt

#### Characteristics

- Header size: 8 bytes (low overhead)
- Data transmission unit: Message
- Speed: Fast (thanks to simplicity)

#### Use Cases

- Communication where real-time performance is important (video streaming, etc.)
- Domain Name Service (DNS)
- IPTV, Voice over Internet Protocol (VoIP)
- Video streaming
- Online games

## Socket Programming Process

The main functions in socket programming are socket, bind, listen, accept, and connect.

### socket()

The initial step that creates a socket, used by both client and server:

- Creates a socket object and returns a file descriptor
- Specifies the protocol (TCP or UDP)

### bind()

Assigns a local protocol address to a socket:

- For Internet protocols, it means a combination of an IPv4 or IPv6 address and a 16-bit TCP port number
- Typically used on the server side
- Binds a socket to a socket address structure, specifically a specified local IP address and port number

### listen()

Converts an unconnected socket into a passive socket:

- Indicates that the kernel should accept incoming connection requests directed to this socket
- Used on the server side
- Causes a bound TCP socket to enter listening state

### accept()

Used on the server side. Accepts a received incoming attempt to create a new TCP connection from a remote client:

- Creates a new socket object associated with the socket address pair of this connection
- Blocks execution and waits for an incoming connection
- When a client connects, returns a new socket object representing the connection and a tuple holding the client's address

### connect()

Used on the client side. Assigns a free local port number to a socket:

- For TCP sockets, attempts to establish a new TCP connection
- Clients typically do not perform an explicit bind operation before initiating a connection
- Allows the service provider to perform an implicit bind on their behalf

### Typical Flow

#### Server

socket() → bind() → listen() → accept() → send/recv → close()

#### Client

socket() → connect() → send/recv → close()

## Client-Server Architecture

Client-server architecture is a distributed application structure that partitions tasks or workloads between resource or service providers (servers) and service requesters (clients).

### Components

- **Client**: Requests services on a network
- **Server**: Provides those services

### Communication Method

Clients and servers often communicate over a computer network on separate hardware. However, both client and server may be on the same device:

- Clients initiate communication sessions with servers
- Servers await incoming requests

### Usage Examples

Computer applications that use the client-server model include:

- Email
- Network printing
- World Wide Web
- Social media platforms
- Online shopping malls
- Content management systems (CMS)

### Advantages

- **Centralization**: Strengthens data management and security through centralization of data and resources
- **Various client support**: Enables services to be used from various client devices
- **Maintainability**: Since servers and clients are separated, they can be developed and updated independently
- **Scalability**: System scalability and maintainability are improved

## Differences from WebSocket

### OSI Layer Differences

Based on the OSI 7-layer model, they are distinguished as follows:

- **Socket**: Located at layer 4 where TCP and UDP belong because they are based on Internet protocols
- **WebSocket**: Depends on TCP but is based on HTTP, so it is located at layer 7

WebSocket is a socket operating at the HTTP layer, with a different layer than TCP/IP sockets.

### TCP Socket Characteristics

- Reliable connection-oriented protocol
- Provides bidirectional data streams
- Primarily used to establish connections between servers and clients and reliably exchange data

### WebSocket Characteristics

A bidirectional communication protocol introduced in HTML5, designed for real-time communication between web applications and servers.

#### Main Features

- A computer communication protocol that provides simultaneous bidirectional communication channels over a single TCP connection
- Designed to operate over HTTP ports 80 and 443
- Designed to support HTTP proxies and intermediate layers, making it compatible with the HTTP protocol

### Relationship

In short, WebSocket is not separate from TCP sockets but is an abstracted form of TCP sockets. It performs socket communication in a form evolved to suit web applications based on socket communication.

WebSocket, which enables real-time bidirectional communication, was standardized as RFC 6455 by the Internet Engineering Task Force (IETF) in 2011.

## Conclusion

Sockets started with Berkeley Sockets in 1983 and evolved as an API for inter-process communication. They provide an interface for network communication, enabling communication between clients and servers.

TCP sockets are connection-oriented and provide reliable communication. They perform 3-way handshaking, error control, flow control, and congestion control. They are used for services where reliability is important such as HTTP or file transfer.

UDP sockets are connectionless and provide fast speed. They are used for services where real-time performance is important such as DNS, streaming, and online games.

Socket programming is done through socket, bind, listen, accept, and connect functions. Servers and clients call functions in a defined order to perform communication.

Client-server architecture enables data centralization and independent development. WebSocket is an application layer protocol operating at the HTTP layer based on TCP sockets. It was standardized as RFC 6455 in 2011 to easily implement real-time bidirectional communication in web environments.
