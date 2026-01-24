---
title: "Network Switch Types and Selection"
date: 2024-08-01T16:20:21+09:00
tags: ["Network", "Switch", "Hardware"]
description: "Network switch types and selection criteria."
draft: false
---

Network switches emerged in the early 1990s to overcome the performance limitations of Ethernet networks. They addressed the inefficiency of traditional hubs that broadcast data to all ports by providing the capability to selectively forward frames based on destination MAC addresses, becoming a core component of modern network infrastructure. In the OSI (Open Systems Interconnection) 7-layer model, switches are classified from L1 to L7 based on which layer they operate at. Each layer's switch has unique characteristics and purposes, analyzing protocol information at that layer to process traffic.

## Historical Development of Network Switches

> **The Birth of Switching Technology**
>
> Until the early 1990s, Ethernet networks used hubs to connect devices. Since hubs broadcast received data indiscriminately to all ports, larger networks suffered from frequent collisions and rapidly declining bandwidth utilization efficiency.

In 1990, Kalpana released the first Ethernet switch called EtherSwitch, marking the commercialization of switching technology. This device dramatically improved network efficiency by using a MAC address table to forward frames only to specific ports. When Cisco acquired Kalpana in 1994, switching technology quickly became the standard for enterprise networks. Subsequently, various features such as VLAN, Spanning Tree Protocol (STP), and QoS were added, transforming simple frame forwarding devices into intelligent network equipment.

## OSI Layers and Switch Classification

Network switches are classified according to which layer of the OSI 7-layer model they process information at. Higher layers can analyze more protocol information for more sophisticated traffic control, but processing overhead also increases.

| Switch Type | OSI Layer | Processing Unit | Main Functions | Representative Equipment |
|-------------|-----------|-----------------|----------------|-------------------------|
| **L1 Switch** | Physical Layer | Bit/Signal | Signal amplification, retransmission | Hub, Repeater |
| **L2 Switch** | Data Link Layer | Frame | MAC address-based switching, VLAN | Standard Switch |
| **L3 Switch** | Network Layer | Packet | IP routing, inter-subnet communication | Multilayer Switch |
| **L4 Switch** | Transport Layer | Segment | Port-based load balancing | Load Balancer |
| **L7 Switch** | Application Layer | Message | Content-based switching, WAF | ADC |

## L1 Switch: Physical Layer Device

> **What is an L1 Switch (Hub)?**
>
> An L1 switch is the most basic network device operating at the Physical Layer (Layer 1) of the OSI model. It only performs the function of amplifying electrical signals and retransmitting them to all ports, and is commonly known as a "Hub" today.

A hub does not interpret or filter received signals but simply amplifies and broadcasts them to all connected devices. This means all ports form a single collision domain, and when two or more devices transmit data simultaneously, collisions occur requiring retransmission through the CSMA/CD (Carrier Sense Multiple Access with Collision Detection) mechanism. Due to these characteristics, collision frequency increases and effective bandwidth decreases dramatically as the number of connected devices grows. While hubs are rarely used in modern networks, they hold important conceptual significance for understanding basic network principles.

### L1 Switch Characteristics

| Characteristic | Description |
|----------------|-------------|
| **Signal Processing** | Only performs electrical signal amplification and regeneration |
| **Address Recognition** | Cannot recognize MAC addresses |
| **Collision Domain** | All ports share a single collision domain |
| **Bandwidth Sharing** | All devices share total bandwidth |
| **Cost** | Very inexpensive |

## L2 Switch: Data Link Layer Device

> **What is an L2 Switch?**
>
> An L2 switch operates at the Data Link Layer (Layer 2) of the OSI model. It learns MAC (Media Access Control) addresses and forwards frames only to specific ports based on them, making it the most common form of network switch.

An L2 switch learns the MAC addresses of devices connected to each port and stores them in a MAC address table (CAM table). When a frame arrives, it looks up the destination MAC address and forwards the frame only to the port where that device is connected. Unlike hubs, each port forms an independent collision domain, greatly improving overall network efficiency. Additionally, VLAN (Virtual LAN) functionality allows devices physically connected to the same switch to be configured as logically separated networks, enabling enhanced security and broadcast domain segmentation. It also supports Spanning Tree Protocol (STP) to prevent network loops and provide high availability through link redundancy.

### L2 Switch Core Functions

| Function | Description | Effect |
|----------|-------------|--------|
| **MAC Address Learning** | Stores source MAC address to port mapping | Selective forwarding based on destination |
| **Frame Switching** | Forwarding based on MAC table | Improved network efficiency |
| **VLAN** | Logical network segmentation | Enhanced security, broadcast isolation |
| **STP** | Loop prevention and path redundancy | High availability |
| **Port Mirroring** | Traffic replication and monitoring | Network analysis support |

### Managed vs Unmanaged Switches

L2 switches are divided into Unmanaged switches and Managed switches based on the presence of management features. Unmanaged switches operate immediately upon connection without any configuration in a plug-and-play manner, making them suitable for small networks or home use. Managed switches allow various settings such as VLAN, QoS, and port security through web interfaces or CLI (Command Line Interface), and are primarily used in enterprise environments.

| Category | Unmanaged | Managed |
|----------|-----------|---------|
| **Configuration** | Not required (plug and play) | Web/CLI configurable |
| **VLAN** | Not supported | Supported |
| **QoS** | Not supported | Supported |
| **Monitoring** | Limited | SNMP, port statistics, etc. |
| **Cost** | Inexpensive | Expensive |
| **Suitable Environment** | Home, small office | Enterprise, data center |

## L3 Switch: Network Layer Device

> **What is an L3 Switch?**
>
> An L3 switch operates at the Network Layer (Layer 3) of the OSI model. In addition to all L2 switch functions, it is a multilayer switch that handles packet routing based on IP addresses at the hardware level.

While traditional routers process packets through software resulting in relatively slow speeds, L3 switches use ASIC (Application-Specific Integrated Circuit) chips to perform routing at the hardware level, enabling high-speed packet processing at near wire speed. L3 switches enable communication between different VLANs or subnets, support dynamic routing protocols such as OSPF, EIGRP, and BGP to automatically calculate optimal paths in large networks and respond flexibly to network changes. They also enable fine-grained traffic filtering through ACL (Access Control List) and QoS policy application.

### L3 Switch vs Router

| Comparison Item | L3 Switch | Router |
|-----------------|-----------|--------|
| **Processing Method** | Hardware (ASIC) | Software |
| **Processing Speed** | Wire speed | Relatively slow |
| **Port Density** | High (24-48 ports typical) | Low |
| **WAN Interface** | Limited | Various WAN support |
| **Advanced Routing** | Limited | Rich features |
| **Suitable Environment** | LAN internal routing | WAN connection, complex routing |

## L4 Switch: Transport Layer Load Balancer

> **What is an L4 Switch?**
>
> An L4 switch operates at the Transport Layer (Layer 4) of the OSI model. It primarily performs load balancing functions by analyzing TCP/UDP port number information to distribute traffic across multiple servers.

L4 switches emerged in the late 1990s as the explosive growth of web services increased the need for server load distribution. They analyze client requests based on IP addresses and port numbers and distribute them to backend server pools, preventing single server overload and increasing service availability. Load balancing algorithms include Round Robin, Weighted, Least Connections, and IP Hash. Health check functionality automatically detects failed servers and excludes them from traffic distribution, ensuring service continuity.

### L4 Load Balancing Algorithms

| Algorithm | Description | Suitable Situation |
|-----------|-------------|-------------------|
| **Round Robin** | Sequential server assignment | Servers with equal performance |
| **Weighted** | Allocation by ratio based on server performance | Heterogeneous server environments |
| **Least Connections** | Select server with fewest current connections | Requests with long connection times |
| **IP Hash** | Fix server based on client IP | When session persistence is needed |

### L4 Switch Main Functions

In addition to load balancing, L4 switches hide internal server real IP addresses through NAT (Network Address Translation) and provide services via Virtual IP (VIP). Session persistence (or Sticky Session) functionality forwards all requests from a specific client to the same server, ensuring proper operation of session-based applications. They also support SSL offloading to handle encryption/decryption processing on the switch, reducing backend server CPU load. Connection multiplexing reuses server connections to reduce connection setup overhead.

## L5-L6 Layers: Theoretical Classification

> **The Reality of L5 and L6 Switches**
>
> Independent switch hardware for the Session Layer (L5) and Presentation Layer (L6) of the OSI model virtually does not exist. The functions of these layers are mostly integrated into L7 switches or ADCs (Application Delivery Controllers).

Session layer functions such as session management, connection setup/teardown, and checkpointing, along with presentation layer functions such as data format conversion, encryption/decryption, and compression, are typically implemented as additional features of L4 or L7 switches in modern network equipment or handled at the application level. Therefore, there is no need to consider L5 or L6 switches separately when selecting network equipment. Instead, review the feature specifications of L4 load balancers or L7 ADCs to verify that required session management and data processing functions are included.

## L7 Switch: Application Layer Device

> **What is an L7 Switch (ADC)?**
>
> An L7 switch operates at the Application Layer (Layer 7) of the OSI model. It analyzes application-level data such as HTTP headers, URLs, and cookies to provide content-based switching and advanced security functions. It is also called an ADC (Application Delivery Controller).

L7 switches use DPI (Deep Packet Inspection) technology to deeply analyze packet payloads, enabling traffic processing based on actual request content beyond simple IP and port information. For example, they can route traffic to different server groups based on URL paths or make load balancing decisions based on specific values in HTTP headers. They also detect and block OWASP Top 10 vulnerability attacks such as SQL injection, XSS (Cross-Site Scripting), and CSRF (Cross-Site Request Forgery) through WAF (Web Application Firewall) functionality. They can serve as API gateways to handle API request authentication, rate limiting, and transformation.

### L7 Switch Core Functions

| Function | Description | Effect |
|----------|-------------|--------|
| **Content Switching** | Routing based on URL, headers, cookies | Fine-grained traffic control |
| **WAF** | Web attack detection and blocking | Enhanced application security |
| **SSL Termination** | TLS handshake processing | Reduced server load |
| **Caching** | Static content caching | Improved response speed |
| **Compression** | HTTP response compression | Bandwidth savings |
| **API Gateway** | API authentication, rate limiting | API management and security |

### L4 vs L7 Load Balancing

| Comparison Item | L4 Load Balancing | L7 Load Balancing |
|-----------------|-------------------|-------------------|
| **Analyzed Information** | IP, TCP/UDP port | HTTP headers, URL, cookies |
| **Routing Decision** | Per connection | Per request |
| **Processing Speed** | Fast | Relatively slow |
| **Feature Scope** | Simple distribution | Content-based routing |
| **Security Features** | Limited | WAF, DPI, etc. |
| **Suitable Environment** | Simple load distribution | Complex web services |

## Switch Selection Guide

When selecting a network switch, network scale, traffic characteristics, security requirements, and budget should be comprehensively considered. Selecting equipment more advanced than necessary results in cost waste, while selecting equipment with insufficient features creates constraints on future expansion or feature additions.

| Environment | Recommended Switch | Reason |
|-------------|-------------------|--------|
| **Home/Small Office** | Unmanaged L2 | Simple, inexpensive, no configuration needed |
| **SMB** | Managed L2 | VLAN, QoS, monitoring needed |
| **Enterprise LAN** | L3 Switch | Inter-subnet routing, high performance |
| **Web Server Farm** | L4 Load Balancer | Load distribution, high availability |
| **Complex Web Services** | L7 ADC | Content routing, WAF |

## Conclusion

Network switches range from L1 hubs to L7 ADCs according to OSI layers, with each layer's switch providing unique functions by analyzing protocol information at that layer. L1 hubs perform only simple signal amplification, L2 switches provide MAC address-based frame switching and VLAN, and L3 switches handle IP routing at the hardware level. L4 switches perform load balancing based on TCP/UDP port information, and L7 switches analyze application content to provide sophisticated traffic control and security functions. Selecting the appropriate layer switch based on network environment scale, traffic characteristics, and security requirements is key to building an efficient network.
