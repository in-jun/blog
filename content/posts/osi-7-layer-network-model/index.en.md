---
title: "OSI 7-Layer Network Model"
date: 2025-02-20T11:59:28+09:00
tags: ["Network", "Protocol", "OSI"]
description: "OSI 7-layer network model structure and layer functions."
draft: false
---

## Overview

Network communication involves complex processes, and understanding these processes systematically requires a standardized reference model. The OSI (Open Systems Interconnection) 7-layer model is a network communication standard published by the International Organization for Standardization (ISO) in 1984. It divides communication between different systems into seven layers, defining how each layer operates independently while cooperating with others to transmit data. This model serves as a fundamental conceptual framework for network engineers and software developers to understand complex communication processes and diagnose problems.

> **What is the OSI 7-Layer Model?**
>
> The OSI 7-layer model is a reference model that divides the network communication process into seven abstracted layers, from the Physical layer to the Application layer. It was developed by ISO in the late 1970s to address interoperability issues caused by different network equipment vendors using proprietary protocols. Today, it serves primarily as a reference model for understanding network concepts and diagnosing problems rather than as an actual implementation specification.

## The Origins of the OSI Model

During the 1970s and early 1980s, each vendor used proprietary network architectures such as IBM's SNA (Systems Network Architecture), DEC's DECnet, and Xerox's XNS (Xerox Network Systems). This made communication between equipment from different manufacturers impossible or extremely difficult. Companies faced vendor lock-in problems where adopting one vendor's equipment meant being tied to that vendor's ecosystem. ISO began developing standards for open systems interconnection in 1977 to address these interoperability issues. After seven years of development, ISO officially published the OSI model as an international standard (ISO 7498) in 1984.

The core design principle of the OSI model is that each layer performs clearly defined functions and provides services to upper layers, enabling independent evolution through inter-layer interfaces. This achieves a modular structure where changes to protocols or technologies in one layer do not affect other layers. This layering concept has become the foundation for design patterns widely used in modern software architecture.

## OSI 7-Layer Architecture Overview

The following diagram illustrates how data is transmitted from sender to receiver through the OSI 7-layer model.

![OSI 7-Layer Data Transmission Process](osi-layers.png)

## Layer 7 - Application Layer

The Application layer is the topmost layer of the OSI model and the closest to the user. It is where applications that actually use network services operate. When users access network resources through web browsers, email clients, or file transfer programs, the protocols of this layer are at work. This layer provides user interfaces and defines methods for accessing network resources. Protocols such as HTTP, FTP, SMTP, DNS, SSH, and SNMP operate at this layer. Application layer protocols are designed to meet the requirements of specific applications, each having unique message formats and communication rules.

The primary function of the Application layer is to provide network application services that users directly interact with, including file transfer, email, remote access, directory services, and network management. Typical examples include web browsers communicating with web servers using the HTTP protocol, email clients sending and receiving mail using SMTP and IMAP, and network administrators monitoring network equipment through SNMP. Protocols operating at this layer are designed and optimized for their specific use cases.

**Key Protocols:**

- **HTTP/HTTPS**: Protocols for web page transfer that exchange requests and responses based on the client-server model, forming the foundation of the World Wide Web. HTTPS provides encrypted HTTP communication through TLS/SSL.
- **FTP**: File Transfer Protocol that separates control connections (port 21) from data connections (port 20) for uploading and downloading files. It supports two transfer modes: Active and Passive.
- **SMTP/IMAP/POP3**: Protocols for email transfer and retrieval. SMTP (ports 25, 587) handles sending, IMAP (port 143) synchronizes mail while keeping it on the server, and POP3 (port 110) downloads mail locally.
- **DNS**: A distributed database system that translates domain names to IP addresses. It manages domain names globally through a hierarchical structure (root → TLD → authoritative nameserver) and serves as the internet's phone book.
- **SSH**: An encrypted protocol for secure remote access. Developed by Tatu Ylönen in 1995 to address security vulnerabilities in Telnet (plaintext transmission), it combines public key-based authentication with symmetric key session encryption to provide secure communication channels.

## Layer 6 - Presentation Layer

The Presentation layer sits between the Application and Session layers, responsible for converting and adjusting data representation formats. It acts as a translator when exchanging data between different systems, resolving differences in data formats. Thanks to this layer, data can be correctly interpreted even between heterogeneous systems. This layer handles data encoding and decoding, encryption and decryption, and compression and decompression. These functions contribute to increasing transmission efficiency and security while preserving data meaning.

The Presentation layer is necessary because different computer systems may represent data differently internally. For example, Intel x86 processors store bytes in little-endian format while some network protocols use big-endian format, requiring conversion of these byte order differences. Additionally, differences in character encoding schemes such as EBCDIC used in mainframes and ASCII/UTF-8 used in modern systems are also handled at this layer.

**Key Functions:**

- **Data Conversion**: Performs conversion between different character encodings such as ASCII, EBCDIC, UTF-8, and UTF-16 to ensure system interoperability. Also includes conversion between data serialization formats like JSON, XML, and ASN.1.
- **Encryption/Decryption**: Encrypts data through SSL/TLS protocols to prevent information leakage and tampering during transmission, and decrypts on the receiving end. Various encryption algorithms such as AES, RSA, and ChaCha20 are used.
- **Compression/Decompression**: Compresses data using algorithms such as gzip, deflate, and Brotli to improve transmission efficiency, and restores it to original form on the receiving end.
- **Multimedia Format Processing**: Handles image formats like JPEG, PNG, GIF, and WebP, audio formats like MP3, AAC, and FLAC, and video codecs like H.264, H.265, and VP9.

## Layer 5 - Session Layer

The Session layer is responsible for establishing, managing, and terminating conversations (sessions) between two systems. It controls logical connections between applications and manages synchronization of data exchange, ensuring that both communicating parties recognize each other and maintain the conversation. This layer determines full-duplex (bidirectional simultaneous communication) or half-duplex (alternating communication) modes, manages checkpoints for recovery in case of communication failures, and governs session start and termination.

One important function of the Session layer is setting synchronization points. When a connection is lost during large file transfers, this allows retransmission from the last checkpoint rather than from the beginning, efficiently using network resources and improving user experience. Token management also controls which side can transmit data, preventing collisions. This plays an important role in maintaining data integrity in bidirectional communication.

**Key Functions:**

- **Session Establishment and Termination**: Manages the start and end of communication sessions, which may include user authentication, authorization, and session ID assignment.
- **Session Maintenance**: Monitors connection status, handles timeouts for idle sessions, and uses keep-alive messages to confirm connection persistence.
- **Synchronization and Recovery**: Uses checkpoints for recovery from the interrupted point when failures occur during data transmission, ensuring stability in large data transfers.
- **Dialog Control**: Controls the direction of data flow in bidirectional communication and prevents collisions from simultaneous transmission.

**Practical Applications:**

- Session management and transaction processing in database connection pools
- Session state management in Remote Procedure Calls (RPC) and gRPC
- User login session maintenance and cookie/token-based session management in web servers
- Session establishment and synchronization among participants in video conferencing systems

## Layer 4 - Transport Layer

The Transport layer is responsible for end-to-end data transmission. It divides data from upper layers into segments and reassembles them on the receiving end, managing transmission quality (QoS) such as ensuring reliable data delivery or prioritizing fast transmission. This layer builds reliable communication channels on top of the unreliable communication provided by the Network layer. It uses port numbers (0-65535) to distinguish between multiple applications running on the same host. Port ranges are divided into well-known ports (0-1023), registered ports (1024-49151), and dynamic/private ports (49152-65535).

The most representative protocols of the Transport layer are TCP (Transmission Control Protocol) and UDP (User Datagram Protocol). TCP, defined in RFC 793 in 1981, is a connection-oriented and reliable data transmission protocol that includes flow control and congestion control functions. UDP, defined in RFC 768 in 1980, is a connectionless protocol that does not guarantee reliability but has lower overhead, making it suitable for applications where speed is important and some data loss is acceptable, such as real-time streaming, online gaming, VoIP, and DNS queries.

**Key TCP Characteristics:**

- **3-way Handshake**: Establishes connections by exchanging SYN → SYN-ACK → ACK packets, and terminates connections with FIN → FIN-ACK → ACK or RST packets. This process confirms that both sides are ready to communicate.
- **Sequence Guarantee**: Uses 32-bit sequence numbers to track packet order, reassembles in correct order on the receiving end, and detects and removes duplicate packets.
- **Flow Control**: Uses sliding window mechanism to send only as much data as the receiver can process, preventing receiver buffer overflow.
- **Congestion Control**: Uses algorithms such as Slow Start, Congestion Avoidance, Fast Retransmit, and Fast Recovery to detect network congestion and adjust transmission speed to prevent network collapse.
- **Error Detection and Retransmission**: Detects errors with 16-bit checksums, retransmits segments that do not receive ACK after timeout, and supports selective retransmission through Selective ACK (SACK).

**Key UDP Characteristics:**

- **Connectionless**: Transmits data immediately without connection establishment (handshake), resulting in lower latency. Does not maintain connection state, consuming fewer server resources.
- **Best-effort Delivery**: Does not retransmit on failure and does not guarantee order. Upper layers must handle datagrams that do not arrive, arrive duplicated, or arrive out of order.
- **Low Overhead**: UDP header (8 bytes) is smaller than TCP header (20-60 bytes), making it more efficient. Header includes only source port, destination port, length, and checksum.
- **Broadcast/Multicast Support**: Can simultaneously transmit a single packet to multiple receivers, utilized in IPTV, streaming services, and service discovery.

## Layer 3 - Network Layer

The Network layer enables communication between different networks. It performs routing functions to determine packet paths as its core function, using logical addresses (IP addresses) to deliver data from source to destination across multiple networks. Without this layer, communication would only be possible within the same local network, and global networks like the internet could not exist. Routers are the representative devices operating at this layer. Routers forward packets to the next hop by referencing routing tables and determine optimal paths through static routing and dynamic routing protocols.

IP (Internet Protocol), the core protocol of the Network layer, currently exists in two versions: IPv4 and IPv6. IPv4, defined in RFC 791 in 1981, uses a 32-bit address system providing approximately 4.3 billion (2^32) addresses. IPv6, defined in RFC 2460 in 1998, uses a 128-bit address system providing approximately 3.4×10^38 addresses, securing virtually unlimited address space. IP is designed as a connectionless and unreliable protocol that does not handle packet loss or out-of-order delivery. Reliability guarantee is the responsibility of TCP in the upper layer (Transport layer).

**Key Protocols:**

- **IP (Internet Protocol)**: The core protocol for delivering packets from source to destination. Uses TTL (Time To Live) field to limit packet lifespan (decrements by 1 when passing through each router) and prevent infinite loops. Supports fragmentation to pass through networks with different MTUs.
- **ICMP (Internet Control Message Protocol)**: Protocol for reporting and diagnosing network errors. Used by ping command (Echo Request/Reply) and traceroute command (TTL exceeded messages), delivering control messages such as destination unreachable and redirect.
- **ARP (Address Resolution Protocol)**: Protocol for translating IP addresses to physical MAC addresses. Operates between the Network and Data Link layers. Stores and reuses translation results through ARP cache.
- **Routing Protocols**: Includes Interior Gateway Protocols (IGP) such as RIP (distance vector), OSPF (link state), EIGRP (hybrid), and Exterior Gateway Protocol (EGP) BGP. Exchanges routing information between routers to dynamically determine optimal paths.

## Layer 2 - Data Link Layer

The Data Link layer organizes bit streams transmitted through the Physical layer into meaningful data units called frames and handles reliable data transmission between adjacent nodes. While the Network layer uses logical addresses (IP), this layer uses physical addresses (MAC addresses) to identify devices within the same network segment and provides error detection and flow control functions. Switches and bridges are representative devices operating at this layer. Switches learn MAC address tables to forward frames only to specific ports, separating collision domains and improving network efficiency.

The Data Link layer is divided by IEEE into two sublayers: LLC (Logical Link Control, IEEE 802.2) and MAC (Media Access Control). The LLC sublayer handles the interface with the Network layer, performs flow control and error control, and allows multiple network protocols to share the same physical medium. The MAC sublayer defines methods for accessing the physical layer, handles physical addressing, and has various standards defined according to media type, such as IEEE 802.3 (Ethernet) and IEEE 802.11 (Wi-Fi).

**Key Characteristics:**

- **Framing**: Divides bit streams into frame units to identify start and end. For Ethernet, frame start is marked with preamble (7 bytes) and SFD (Start Frame Delimiter, 1 byte).
- **Physical Addressing**: Uses 48-bit (6-byte) MAC addresses to uniquely identify network interfaces. First 24 bits are OUI (manufacturer identifier), last 24 bits are device-specific number.
- **Error Detection**: Uses CRC-32 (Cyclic Redundancy Check) to detect bit errors during transmission. Frames with detected errors are discarded (error correction is handled by retransmission in upper layers).
- **Media Access Control**: Wired Ethernet uses CSMA/CD (Carrier Sense Multiple Access with Collision Detection), wireless Wi-Fi uses CSMA/CA (Collision Avoidance) to coordinate access to shared media.

**Key Protocols:**

- **Ethernet**: The most widely used wired LAN technology, developed by Robert Metcalfe at Xerox PARC in 1973. Defined in IEEE 802.3 standard, supporting various speeds from 10Mbps (10BASE-T) to 400Gbps (400GBASE).
- **Wi-Fi**: Wireless LAN technology defined in IEEE 802.11 standard. Multiple generations exist including 802.11a/b/g/n/ac/ax (Wi-Fi 6)/be (Wi-Fi 7), using 2.4GHz, 5GHz, and 6GHz frequency bands.
- **PPP (Point-to-Point Protocol)**: Protocol for direct connections between two nodes. Provides authentication (PAP, CHAP), encryption, and IP address assignment functions, used in dial-up or VPN connections.

## Layer 1 - Physical Layer

The Physical layer is the lowest layer of the OSI model, responsible for converting actual data into electrical signals (copper wire), optical signals (fiber optic), or electromagnetic waves (wireless) and transmitting them through physical media. This layer does not understand the meaning or structure of data and focuses only on converting bits (0s and 1s) into physical signals. It defines hardware characteristics such as cables, connectors, voltage levels, signal timing, data transmission rates, and pin arrangements. This standardization enables equipment from different manufacturers to connect physically and communicate.

Elements defined by the Physical layer include electrical characteristics (voltage levels, signal duration, impedance), mechanical characteristics (connector shapes, number of pins, pin arrangements), functional characteristics (function definitions of each pin), and procedural characteristics (bit transmission procedures, synchronization methods). Standardizing these four characteristics enables various manufacturers' network equipment to physically interconnect.

**Physical Transmission Media:**

- **Twisted Pair Cable**: The most common wired medium, available in UTP (Unshielded Twisted Pair) and STP (Shielded Twisted Pair) types. Transmission speeds and distances vary by category: Cat5e (1Gbps), Cat6 (10Gbps/55m), Cat6a (10Gbps/100m), Cat7 (10Gbps/shielded), Cat8 (25-40Gbps).
- **Coaxial Cable**: Used in early Ethernet (10BASE5, 10BASE2), cable TV, and CATV internet. Structure where central conductor is wrapped by insulator and shielding layer, resistant to external electromagnetic interference.
- **Fiber Optic Cable**: Transmits data using light. Two types exist: single-mode (SM, long distance/high speed) and multi-mode (MM, short distance/low cost). No electromagnetic interference, difficult to eavesdrop, suitable for long-distance high-speed transmission of 100km or more.
- **Radio Frequency**: Used in Wi-Fi (2.4/5/6GHz), Bluetooth (2.4GHz), cellular communications (700MHz-6GHz, mmWave), and satellite communications. Transmits data through electromagnetic waves without physical cables.

## Data Encapsulation and De-encapsulation

In the OSI model, when data is transmitted from sender to receiver, it undergoes encapsulation and de-encapsulation as it passes through each layer. This process is similar to putting a letter in an envelope and writing an address, where each layer adds necessary control information as headers. On the sending side, data starts at the Application layer and descends through lower layers, with each layer's header (and sometimes trailer) being added. On the receiving side, the process starts at the Physical layer and ascends through upper layers, with each layer's header being removed until only the original data is delivered to the Application layer.

![Data Encapsulation Process](encapsulation.png)

Each layer's data unit has a unique name: Data at the Application/Presentation/Session layers, Segment (TCP) or Datagram (UDP) at the Transport layer, Packet at the Network layer, Frame at the Data Link layer, and Bit at the Physical layer. This encapsulation process ensures that each layer's information is processed and transmitted independently. Each layer on the receiving side checks and processes only its corresponding header before passing it to the upper layer.

## Comparing OSI and TCP/IP Models

The actual internet operates based on the TCP/IP 4-layer model rather than the OSI 7-layer model. While the OSI model is a theoretical and conceptual reference model published by ISO in 1984, the TCP/IP model is a practical model based on ARPANET developed by DARPA (Defense Advanced Research Projects Agency) in the 1970s, reflecting actual internet protocol implementations. The TCP/IP model consists of four layers: Application, Transport, Internet, and Network Access. OSI layers 5, 6, and 7 are consolidated into TCP/IP's Application layer, and layers 1 and 2 are consolidated into the Network Access layer.

The OSI model remains important in practice because it allows network problems to be diagnosed and resolved by narrowing down the problem area layer by layer. For example, when a connection problem occurs, you can systematically identify the issue by checking cable connections and LED status (Layer 1), MAC address resolution and switch ports (Layer 2), IP addresses and routing tables (Layer 3), port connections and firewall rules (Layer 4), and application settings and logs (Layer 7) in sequence.

| OSI Layer       | TCP/IP Layer   | Key Protocols             | PDU     |
| --------------- | -------------- | ------------------------- | ------- |
| 7. Application  | Application    | HTTP, FTP, DNS, SMTP, SSH | Data    |
| 6. Presentation | Application    | SSL/TLS, JPEG, ASCII      | Data    |
| 5. Session      | Application    | NetBIOS, RPC, SIP         | Data    |
| 4. Transport    | Transport      | TCP, UDP, SCTP            | Segment |
| 3. Network      | Internet       | IP, ICMP, ARP, OSPF       | Packet  |
| 2. Data Link    | Network Access | Ethernet, Wi-Fi, PPP      | Frame   |
| 1. Physical     | Network Access | Cables, Hubs, Repeaters   | Bit     |

## Practical Use of OSI Model

The OSI model shines brightest in network troubleshooting. Systematic layer-by-layer approach enables quick identification of complex network problem causes.

**Layer-by-Layer Troubleshooting Checklist:**

1. **Physical Layer (L1)**: Are cables properly connected? Are link LEDs lit? Are there any cable breaks or damage?
2. **Data Link Layer (L2)**: Has MAC address been learned via `arp -a` command? Are switch ports active? Is VLAN configuration correct?
3. **Network Layer (L3)**: Is destination reachable via `ping` command? Where does packet stop via `traceroute`? Is routing table correct?
4. **Transport Layer (L4)**: Is port listening via `netstat -an` or `ss -tuln`? Is firewall not blocking the port?
5. **Application Layer (L7)**: Are there errors in application logs? Is DNS resolution normal? Are certificates valid?

## Conclusion

This post covered the OSI 7-layer model in detail, from its historical background to the role of each layer, key protocols, comparison with the TCP/IP model, the data encapsulation process, and practical applications. While the OSI model is not directly used in actual internet implementations, it has remained a fundamental framework for systematically understanding network concepts and diagnosing problems for 40 years since its publication in 1984. It has established itself as essential knowledge that network engineers and developers must understand.
