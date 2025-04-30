---
title: "Understanding NAT (Network Address Translation)"
date: 2025-05-01T19:46:09+09:00
draft: false
description: "This article explains the basic concepts, types, operational principles, and pros and cons of Network Address Translation (NAT)."
tags:
    [
        "networking",
        "NAT",
        "SNAT",
        "DNAT",
        "IP address",
        "network security",
        "port forwarding",
        "firewall",
        "router",
        "PAT",
    ]
---

## Introduction

NAT (Network Address Translation) is a core technology that mediates between private IP addresses and public IP addresses in network communications. It emerged in the mid-1990s to address the IPv4 address depletion problem and was first standardized through the IETF's RFC 1631 document. Today, NAT has become an essential technology forming the foundation of global internet infrastructure, from home routers to large-scale corporate networks and cloud infrastructure.

## Basic Concepts of NAT

NAT operates on network devices such as routers or firewalls, translating IP addresses between internal networks (private IP) and external networks (public IP). During this process, it modifies the IP addresses and TCP/UDP port numbers in packet headers and records the translation information in a NAT table to enable bidirectional communication. Private IP address ranges defined in RFC 1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) are widely used in internal network configurations in NAT environments. When a packet passes through a NAT device, the checksum is also recalculated, which is essential to ensure the integrity of IP and TCP/UDP headers.

## Types of NAT

### 1. Static NAT

Static NAT maps one private IP address to one public IP address in a 1:1 relationship. This method is primarily used when external users need constant access to specific internal servers (web, mail, game, database, etc.). The mapping relationship is permanently maintained by the NAT device's configuration and persists even after system restarts.

**Examples:**

-   Internal web server 192.168.1.10 → Public IP 203.0.113.10
-   Internal mail server 192.168.1.20 → Public IP 203.0.113.20
-   When an external user accesses 203.0.113.10:80, the NAT device precisely forwards the traffic to the internal web server (192.168.1.10:80).

**Characteristics:**

-   Fixed configuration makes it predictable and stable.
-   Perfect support for bidirectional connections allows complex protocols to work without issues.
-   Requires many public IP addresses, resulting in less efficient IP address utilization.
-   Increases management overhead in large-scale networks.

### 2. Dynamic NAT

Dynamic NAT dynamically allocates available IPs from a pool of public IP addresses to internal hosts. When a connection is terminated, the public IP returns to the pool and becomes available for other internal devices.

**Examples:**

-   Public IP pool: 203.0.113.10 ~ 203.0.113.20
-   Internal host A (192.168.1.5) receives 203.0.113.10 when connecting externally
-   Internal host B (192.168.1.6) receives 203.0.113.11 when connecting externally
-   When host A's connection terminates, 203.0.113.10 returns to the pool for use by other hosts

**Characteristics:**

-   More flexible IP management than static NAT with higher IP utilization.
-   Resource efficiency by allocating public IPs only when needed.
-   When the IP pool is exhausted, additional external connections become impossible, potentially causing bottlenecks during traffic surges.
-   Difficult to initiate connections from external to internal networks, making it unsuitable for server operations.

### 3. PAT (Port Address Translation) / NAPT

PAT (Port Address Translation) or NAPT (Network Address Port Translation) is the most commonly used NAT method, where multiple internal IPs share a single public IP. It distinguishes each connection by changing TCP/UDP port numbers and tracks each session through a state table.

**Examples:**

-   Internal host A (192.168.1.2:1234) connecting externally → translated to 203.0.113.1:40000
-   Internal host B (192.168.1.3:1234) connecting externally with the same port → translated to 203.0.113.1:40001
-   Internal host A connecting with a different port (5678) → translated to 203.0.113.1:40002

**Characteristics:**

-   Default method used in home routers and small business networks.
-   Can support tens of thousands of simultaneous connections with a single public IP, maximizing IP address conservation.
-   Theoretically limited to about 65,000 simultaneous connections per single IP due to the range of TCP/UDP port numbers (0-65535).
-   Protocols like FTP, SIP, and H.323 that include IP address information in packet payloads require additional processing (ALG, Application Layer Gateway).

### 4. DNAT (Destination NAT)

DNAT changes the destination address of incoming packets from external sources to internal IP addresses. This method is primarily used to allow external users to access internal servers while concealing the internal network structure. Port forwarding is a typical example of DNAT, which can selectively forward traffic coming to specific ports to particular internal servers.

**Examples:**

-   External access to public IP 203.0.113.1:80 → forwarded to internal web server 192.168.1.10:80
-   External access to public IP 203.0.113.1:443 → forwarded to internal web server 192.168.1.10:443
-   External access to public IP 203.0.113.1:22 → forwarded to internal SSH server 192.168.1.20:22
-   External access to public IP 203.0.113.1:25 → forwarded to internal mail server 192.168.1.30:25

**Application Areas:**

-   Operating internal web, mail, game servers while providing services externally
-   Configuring remote access environments through port forwarding
-   Maintaining a balance between internal network security and external service provision through DMZ (Demilitarized Zone) configuration
-   Implementing reverse proxy systems
-   Distributing traffic through load balancers

**Characteristics:**

-   Enables service provision without exposing the actual IP addresses of internal servers.
-   Multiple internal servers can be exposed externally with a single public IP, achieving both IP address conservation and server operation.
-   Can enhance security by combining with detailed firewall rules to allow access only to specific services.
-   In large-scale service environments, multiple intertwined DNAT rules can increase management complexity.

### 5. SNAT (Source NAT)

SNAT changes the source address of outgoing packets from internal to public IP addresses. As the most common form of NAT, it is almost always used when internal users access the internet. PAT can be considered a type of SNAT, but SNAT is a broader concept referring to source address translation in general.

**Examples:**

-   Packet sent from internal host 192.168.1.10 to external network → source changed to public IP 203.0.113.1
-   External communication through a single public IP in a cluster containing multiple servers
-   Changing the source IP of specific traffic to a different public IP in a multi-homed environment (multiple ISP connections)

**Application Areas:**

-   Thousands of internal devices in large enterprise networks accessing the internet with limited public IPs
-   Managing outbound traffic of virtual machines in cloud environments
-   Implementing source-based routing in environments using multiple ISPs
-   Automatic source traffic switching in high-availability systems during failures

**Characteristics:**

-   Enhanced security by not exposing internal network structure externally.
-   Consistent access control from external sources as all internal devices use the same public IP.
-   Proper delivery of return traffic to the correct internal host through connection tracking.
-   In high-volume traffic environments, managing NAT tables can consume significant system resources.

## Detailed Analysis of NAT Traffic Flow

Examining how packets are processed in a real NAT environment step by step helps to understand NAT's operational principles more clearly. Below is a detailed analysis of the process of an internal client connecting to an external web server in a PAT (Port Address Translation) environment.

### 1. Request from Internal to External (Outbound Packet)

1. An internal host (192.168.1.2) attempts an HTTP request to an external server (8.8.8.8:80) via a web browser.
2. The internal host's operating system allocates a temporary port (ephemeral port, e.g., 1234) and creates a TCP SYN packet.
3. Packet content: `Source IP=192.168.1.2, Source Port=1234, Destination IP=8.8.8.8, Destination Port=80, TCP Flag=SYN`
4. This packet is sent to the default gateway (NAT device) of the internal network.
5. The NAT device receives the packet and begins NAT processing:
    - Changes the source IP to the public IP (203.0.113.1)
    - Changes the source port to a temporary NAT port (40000)
    - Recalculates the checksums in the IP and TCP headers
    - Records the translation information `192.168.1.2:1234 ↔ 203.0.113.1:40000` in the NAT table
6. Transformed packet content: `Source IP=203.0.113.1, Source Port=40000, Destination IP=8.8.8.8, Destination Port=80, TCP Flag=SYN`
7. The NAT device transmits the transformed packet to the external network.

### 2. Response from External to Internal (Inbound Packet)

1. The external server (8.8.8.8:80) processes the request and generates a response packet (TCP SYN-ACK).
2. Packet content: `Source IP=8.8.8.8, Source Port=80, Destination IP=203.0.113.1, Destination Port=40000, TCP Flag=SYN-ACK`
3. This response packet is transmitted to the public IP of the NAT device through the internet.
4. The NAT device receives the packet and checks the destination IP:port (203.0.113.1:40000).
5. It looks up the NAT table to find the corresponding internal mapping information (192.168.1.2:1234).
6. It performs NAT processing:
    - Changes the destination IP to the internal host IP (192.168.1.2)
    - Changes the destination port to the original host port (1234)
    - Recalculates the checksums in the IP and TCP headers
7. Transformed packet content: `Source IP=8.8.8.8, Source Port=80, Destination IP=192.168.1.2, Destination Port=1234, TCP Flag=SYN-ACK`
8. The NAT device transmits the transformed packet to the internal network, and the packet reaches the host that made the original request.

### 3. Data Transfer and Connection Maintenance

1. Once the TCP 3-way handshake is complete, the actual HTTP data exchange begins.
2. The same NAT rules apply to all subsequent packets:
    - Internal→External: Source 192.168.1.2:1234 → 203.0.113.1:40000
    - External→Internal: Destination 203.0.113.1:40000 → 192.168.1.2:1234
3. The NAT device continuously tracks the state of the connection to keep the NAT table updated.
4. The NAT device removes connection information from the table that has had no traffic for a certain period (timeout) to efficiently manage resources.

### 4. Connection Termination and Resource Release

1. When the internal host requests to terminate the connection, a TCP FIN packet is sent.
2. The NAT device processes the FIN packet using the same NAT rules.
3. The external server also responds with a FIN packet, and the TCP 4-way termination process is completed.
4. The NAT device recognizes the connection termination and sets a timeout for the NAT table entry for that connection.
5. After the timeout (typically about 60 seconds for TCP, about 30 seconds for UDP), the NAT device removes the mapping information from the table.
6. Port 40000 becomes available for reuse by connections from other internal hosts.

The above process is a basic HTTP communication example, but complex protocols like FTP (File Transfer Protocol) create separate data channels, requiring special processing (ALG, Application Layer Gateway) in NAT devices. ALG inspects the packet payload to perform additional translations, ensuring the protocol works correctly in a NAT environment.

## Analysis of NAT Advantages and Disadvantages

NAT is a technology that affects various aspects of the network environment, and it's important to understand its advantages and disadvantages in depth.

### Security Aspect

**Advantages:**

-   **Internal Network Concealment:** NAT completely hides the actual IP address structure of the internal network from the outside, significantly reducing direct attack vectors against internal systems.
-   **State-based Filtering:** Most NAT implementations provide basic firewall functionality by allowing only responses to connections initiated from the inside through state tracking.
-   **Address Scanning Prevention:** Making it difficult for external attackers to identify the IP address range of the internal network greatly reduces the effectiveness of indiscriminate scanning attacks.

**Disadvantages:**

-   **Difficulty in Detailed Security Control:** NAT alone cannot respond to application-layer security threats and requires additional security solutions.
-   **Complexity of Bidirectional Connections:** Explicit port forwarding rules are needed to allow external access to specific internal servers, increasing management complexity.
-   **Logging and Auditing Challenges:** Since multiple internal users share the same public IP, detailed session-level logging is necessary to accurately trace the source of specific malicious activities.

### Address Management Aspect

**Advantages:**

-   **IPv4 Address Conservation:** Thousands of internal devices can connect to the internet with a single public IP address, effectively mitigating the serious IPv4 address shortage.
-   **Address Independence:** The address scheme of the internal network can be designed and managed independently of ISPs or external networks.
-   **Network Redesign Simplicity:** The internal network configuration can be maintained even when changing ISPs or public IPs, facilitating management.

**Disadvantages:**

-   **Port Limitations:** In PAT environments, there's a limit to the number of simultaneous connections a single public IP can handle due to TCP/UDP port number ranges (maximum 65,535).
-   **Address Conflict Issues:** Network conflicts can occur during company mergers or VPN connections when networks use the same private IP ranges.
-   **IPv6 Transition Delay:** There are criticisms that NAT has reduced the necessity and speed of transitioning to IPv6 by alleviating the IPv4 address shortage problem.

### Network Configuration and Management Aspect

**Advantages:**

-   **Easy Configuration:** NAT functionality is provided as a basic feature in most routers and firewall devices, making setup straightforward.
-   **Cost Efficiency:** Large-scale networks can be operated with a small number of public IPs, reducing IP address purchase and management costs.
-   **Flexible Network Design:** Changes to the internal network structure don't affect external connections, increasing network design flexibility.

**Disadvantages:**

-   **Server Operation Complexity:** Additional configurations such as port forwarding or DMZ setup are required to provide services from internal networks.
-   **Difficulty Implementing Advanced Features:** Some advanced network features like IP-based P2P applications, multicast, and IPsec VPN can be difficult to implement in NAT environments.
-   **Performance Issues in Large Environments:** In large-scale environments handling many simultaneous connections, NAT device performance can become a bottleneck.

### Application Compatibility Aspect

**Advantages:**

-   **Compatibility with Most Applications:** Common internet activities such as web browsing, email, and file downloading work without issues in NAT environments.
-   **ALG Support:** Many NAT devices provide ALG (Application Layer Gateway) for complex protocols like FTP and SIP.
-   **Widespread Usability:** Since most networks worldwide use NAT, many applications are designed with NAT environments in consideration.

**Disadvantages:**

-   **Protocol Constraints:** Special protocols like VoIP, online games, and P2P file sharing may not work smoothly in NAT environments without additional processing.
-   **Connection Initiation Asymmetry:** External-to-internal connection initiation is blocked by default, creating constraints for remote access and server operations.
-   **Need for NAT Traversal:** Technologies like WebRTC require complex NAT traversal techniques such as STUN, TURN, and ICE for P2P communication in NAT environments.

## Conclusion

NAT is one of the essential core technologies in IPv4 environments. In particular, the PAT method is commonly used in homes and businesses, providing a practical solution to the public IP shortage problem. Although the need for NAT is gradually decreasing with the introduction of IPv6, it is still widely used today. Understanding the various methods and operational principles of NAT will be of great help in network troubleshooting and configuration.
