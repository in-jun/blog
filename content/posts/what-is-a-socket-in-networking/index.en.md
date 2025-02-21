---
title: "What is a Socket?"
date: 2024-06-08T21:22:40+09:00
tags: ["network", "socket"]
draft: false
---

### Sockets

A **socket** is software that provides an interface for network communication. Sockets help facilitate communication between clients and servers, allowing them to send and receive data.

Sockets offer an Application Programming Interface (API) for network communication. They work with both TCP (Transmission Control Protocol) and UDP (User Datagram Protocol), each providing a means to transfer data reliably.

### Socket Communication Methods

Sockets provide the following methods to facilitate communication between clients and servers:

1. **TCP (Transmission Control Protocol)**:

    - **Connection-Oriented**: Establishes a connection between the client and server, transferring data reliably.
    - **Reliable**: Transmits data in order, with error detection and retransmission for lost packets.
    - **Flow Control**: Regulates the rate of data transmission to prevent data loss.
    - **Congestion Control**: Detects network congestion and adjusts data transmission rates accordingly.

2. **UDP (User Datagram Protocol)**:

    - **Connectionless**: Transmits data without establishing a connection between the client and server.
    - **Unreliable**: Does not guarantee the order of data or retransmission of lost packets.
    - **No Flow Control**: Does not regulate the rate of data transmission.
    - **No Congestion Control**: Does not detect network congestion.

### Socket Communication Process

#### Server:

1. Create a socket
2. Bind it to an IP address and port
3. Listen for incoming connections
4. Accept incoming connection
5. Communicate (send and receive data)
6. Close the socket

#### Client:

1. Create a socket
2. Connect to the server
3. Accept (receive file descriptor of client socket)
4. Communicate (send and receive data)
5. Close the socket

### HTTP vs. Sockets

**HTTP (HyperText Transfer Protocol)** is a protocol for communication between web servers and clients. It runs on top of TCP and is used to transfer web pages.

Sockets are an interface for network communication. Therefore, HTTP uses sockets to transfer data.
