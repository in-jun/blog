---
title: "Understanding Subnet Masks"
date: 2025-02-20T10:20:05+09:00
tags: ["Network", "IP", "Subnet"]
description: "Subnet mask structure and network segmentation using AND operations."
draft: false
---

## Background and History of Subnet Masks

Subnet masks were formally introduced to the TCP/IP protocol stack in RFC 950 in 1985 to address the inefficiency of the early internet's classful addressing system. In the early 1980s, the internet relied on Class A, B, and C networks. Class A used first-octet values from 1 to 126 and supported roughly 16 million hosts, Class B used 128 to 191 and supported about 65,000 hosts, and Class C used 192 to 223 and supported 254 hosts.

That rigid structure created obvious waste. An organization that needed around 1,000 hosts had to receive a Class B block because a Class C network was too small, leaving more than 64,000 addresses unused. Likewise, any organization that needed just over 254 hosts had to move up to a much larger Class B allocation.

Subnet masks solved this by allowing one network to be divided into smaller subnetworks and by letting administrators move the boundary between the network and host portions as needed. That flexibility later became the basis for CIDR (Classless Inter-Domain Routing), introduced in 1993, and remains a core concept in modern IP address management.

## Structure and Principles of Subnet Masks

Subnet masks are 32 bits long, just like IPv4 addresses, and they follow a simple binary pattern: consecutive 1s followed by consecutive 0s. Bits set to 1 represent the network portion, which must match across all hosts in the same network. Bits set to 0 represent the host portion, where each device can have its own unique value.

For example, `255.255.255.0` is `11111111.11111111.11111111.00000000` in binary. The first 24 bits are the network portion and the last 8 bits are the host portion, giving 256 total addresses and 254 usable host addresses after excluding the network and broadcast addresses. `255.255.255.128` is `/25`, with 25 network bits and 7 host bits, so it provides 128 total addresses and 126 usable hosts. `255.255.255.192` is `/26`, with 26 network bits and 6 host bits, so it provides 64 total addresses and 62 usable hosts.

Valid subnet masks must begin with uninterrupted 1s and end with uninterrupted 0s. A pattern such as `11111111.11111111.11111111.11001100` (`255.255.255.204`) is invalid because the 1s and 0s are mixed.

## AND Operation Principles of Subnet Masks

![Subnet Mask AND Operation](subnet-mask-and.png)

The key operating principle behind subnet masks is the bitwise AND operation. When an IP address and a subnet mask are both converted to binary, an AND operation is performed on each bit to extract the network address. Routers use this result to decide whether two IP addresses are on the same network and to make routing decisions.

The rule is simple: the result is `1` only when both bits are `1`. In all other cases, the result is `0`. In other words, `1 AND 1 = 1`, while `1 AND 0`, `0 AND 1`, and `0 AND 0` all produce `0`.

Consider the IP address `192.168.1.75` with subnet mask `255.255.255.192` (`/26`). In binary, `192.168.1.75` becomes `11000000.10101000.00000001.01001011`, and the subnet mask becomes `11111111.11111111.11111111.11000000`. Applying a bitwise AND produces `11000000.10101000.00000001.01000000`, which is `192.168.1.64` in decimal.

That means `192.168.1.75` belongs to the `192.168.1.64/26` network. The full address range is `192.168.1.64` to `192.168.1.127`, the network address is `.64`, the broadcast address is `.127`, and the usable host range is `.65` to `.126`.

## Major Subnet Mask Values and Use Cases

![Subnet Mask Table](subnet-mask-table.png)

### Class A-based Subnet Masks

**255.0.0.0 (/8)** is the default subnet mask for Class A networks. It uses 8 network bits and 24 host bits, providing 16,777,216 total addresses and 16,777,214 usable host addresses. It is commonly associated with very large networks such as major ISPs, cloud providers, global corporations, and large government environments. For example, `10.0.0.0/8` is a private IP range widely used in large internal enterprise networks.

Smaller subdivisions of a Class A block are also common. **255.128.0.0 (/9)** supports 8,388,606 hosts, **255.192.0.0 (/10)** supports 4,194,302 hosts, **255.224.0.0 (/11)** supports 2,097,150 hosts, and **255.240.0.0 (/12)** supports 1,048,574 hosts. These masks are useful when a large organization wants to split a Class A allocation by region, department, or service group.

### Class B-based Subnet Masks

**255.255.0.0 (/16)** is the default subnet mask for Class B networks. It uses 16 network bits and 16 host bits, providing 65,536 total addresses and 65,534 usable hosts. It is often used in medium-to-large environments such as universities, corporate headquarters, data centers, and government organizations. For example, `172.16.0.0/16` is part of the private IPv4 space commonly used for internal corporate networks.

Masks from `/17` to `/23` provide smaller host pools, from 32,766 hosts at `/17` down to 510 hosts at `/23`. These ranges are useful when a Class B-sized block needs to be divided into multiple subnets with VLSM (Variable Length Subnet Mask).

### Class C-based Subnet Masks

**255.255.255.0 (/24)** is the default subnet mask for Class C networks. It uses 24 network bits and 8 host bits, providing 256 total addresses and 254 usable hosts. This is the most common choice for small offices, branch networks, departments, and home networks. For example, `192.168.1.0/24` is a very common default range on home routers.

Smaller subnet sizes are often derived from `/24`. **255.255.255.128 (/25)** supports 126 hosts and splits a `/24` into two subnets. **255.255.255.192 (/26)** supports 62 hosts and creates four subnets. **255.255.255.224 (/27)** supports 30 hosts, **255.255.255.240 (/28)** supports 14, **255.255.255.248 (/29)** supports 6, and **255.255.255.252 (/30)** supports 2. A `/30` is commonly used for point-to-point links between routers, such as WAN links or BGP peer connections.

## Relationship Between Subnet Masks and CIDR Notation

When CIDR (Classless Inter-Domain Routing) was introduced in 1993, subnet masks began to be written in slash notation. Instead of writing the full mask, CIDR represents the number of network bits as `/n`, which makes network definitions shorter and easier to read.

CIDR notation maps directly to traditional subnet masks. For example, `/8` is `255.0.0.0`, `/16` is `255.255.0.0`, `/24` is `255.255.255.0`, `/25` is `255.255.255.128`, `/26` is `255.255.255.192`, `/27` is `255.255.255.224`, `/28` is `255.255.255.240`, `/29` is `255.255.255.248`, and `/30` is `255.255.255.252`.

CIDR notation has several practical advantages. It is more concise, as in `192.168.1.0/24` instead of `192.168.1.0 255.255.255.0`. It also makes address calculations more intuitive because `/24` immediately tells you that 24 bits are reserved for the network and 8 bits remain for hosts. Just as importantly, CIDR supports VLSM and route aggregation, which makes modern network design far more flexible.

## Subnet Mask Calculation Practice

### Calculating Subnet Mask from Host Count

To calculate the right subnet mask from a required host count, follow a simple sequence. First, add 2 to the host count to reserve addresses for the network and broadcast values. Next, find the smallest power of 2 that is equal to or greater than that result. The exponent becomes the number of host bits. Subtract the host-bit count from 32 to get the number of network bits, which gives you the CIDR prefix.

For example, if you need 50 hosts, start with `50 + 2 = 52`. The next power of 2 is `2^6 = 64`, so you need 6 host bits. That leaves `32 - 6 = 26` network bits, so the correct subnet is `/26` (`255.255.255.192`), which provides 62 usable hosts.

For 100 hosts, `100 + 2 = 102`, so `2^7 = 128` is the next power of 2. That means 7 host bits are needed, which gives a `/25` subnet and 126 usable hosts. For 500 hosts, `500 + 2 = 502`, so `2^9 = 512` is required. That means 9 host bits and a `/23` subnet (`255.255.254.0`), which provides 510 usable hosts.

### Subnet Division Calculation

To divide a `192.168.1.0/24` network into 4 equal-sized subnets, you need 2 additional subnet bits because `2^2 = 4`. Adding 2 bits to the original `/24` gives `/26`, which corresponds to the subnet mask `255.255.255.192`. Each subnet then contains 64 total addresses, or 62 usable host addresses.

The four resulting subnets are `192.168.1.0/26` (`192.168.1.0` to `192.168.1.63`, usable `.1` to `.62`), `192.168.1.64/26` (`192.168.1.64` to `192.168.1.127`, usable `.65` to `.126`), `192.168.1.128/26` (`192.168.1.128` to `192.168.1.191`, usable `.129` to `.190`), and `192.168.1.192/26` (`192.168.1.192` to `192.168.1.255`, usable `.193` to `.254`).

### Checking if Two IPs are in Same Network

To check whether `192.168.1.75` and `192.168.1.130` are in the same network with subnet mask `255.255.255.192` (`/26`), calculate the network address for each host. `192.168.1.75 AND 255.255.255.192 = 192.168.1.64`, while `192.168.1.130 AND 255.255.255.192 = 192.168.1.128`. Because the resulting network addresses are different, the two IPs belong to different subnets and need a router to communicate.

## Real-World Applications of Subnet Masks

### Enterprise Network Design

Suppose a small-to-medium enterprise receives the private block `192.168.0.0/16` and uses VLSM to allocate address space efficiently. One possible design is to assign headquarters with 200 employees to `192.168.0.0/24` (254 hosts), Branch A with 50 employees to `192.168.1.0/26` (62 hosts), and Branch B with 30 employees to `192.168.1.64/27` (30 hosts).

The same plan could assign a 20-machine server farm to `192.168.1.96/27` (30 hosts), DMZ web servers with 5 machines to `192.168.1.128/29` (6 hosts), and point-to-point router links to `192.168.1.136/30` and `192.168.1.140/30` (2 hosts each). The remaining address space stays available for future growth.

### Cloud Environment (AWS VPC)

In an AWS VPC built on `10.0.0.0/16`, subnet masks are used to separate public, private, and database tiers. For example, Public Subnet A might use `10.0.1.0/24` for web servers and load balancers, while Public Subnet B uses `10.0.2.0/24` in a different availability zone for high availability.

Private Subnet A could use `10.0.10.0/24` for application servers, and Private Subnet B could use `10.0.11.0/24` for redundancy. Database Subnet A and B might use `10.0.20.0/24` and `10.0.21.0/24` for services such as RDS and ElastiCache. The remaining space, from `10.0.30.0/24` through `10.0.255.0/24`, can be reserved for future expansion.

### Home Network

A typical home router uses the `192.168.1.0/24` network with subnet mask `255.255.255.0`. The router gateway is often `192.168.1.1`, the DHCP pool might span `192.168.1.100` to `192.168.1.200`, and static addresses such as `192.168.1.10` to `192.168.1.50` can be reserved for servers, NAS devices, or printers. The remaining addresses, such as `192.168.1.201` to `192.168.1.254`, are kept available for future use. With 254 usable host addresses, this is more than enough for a typical home environment.

## Subnet Mask Troubleshooting

### Incorrect Subnet Mask Configuration

An incorrect subnet mask can cause immediate communication failures. For example, if the real network is `192.168.1.0/24` but a host is configured with `255.255.0.0` (`/16`), that host will treat `192.168.0.0` through `192.168.255.255` as local. If it tries to reach `192.168.2.10`, it will send ARP requests directly instead of forwarding traffic to the router. Because `192.168.2.10` is actually on a different network, the request fails and communication breaks.

Common symptoms include successful communication within the true local subnet but failed communication with remote subnets, excessive ARP entries, degraded performance, and unnecessary broadcast traffic. The fix is to correct the subnet mask on the host, verify that DHCP is distributing the right value, and confirm that router, switch, and VLAN settings match the intended subnet design.

### Communication Failure from Subnet Mismatch

When hosts on the same physical network use different subnet masks, communication can become inconsistent. For example, suppose Host A is `192.168.1.10/24` (`255.255.255.0`) and Host B is `192.168.1.100/26` (`255.255.255.192`). Host A treats `192.168.1.0` through `192.168.1.255` as local, while Host B treats only `192.168.1.64` through `192.168.1.127` as local. That difference can create asymmetric behavior.

Host A will try to reach Host B directly with ARP because it sees Host B as local. Host B, however, may treat Host A as remote and try to send the reply through the gateway. The result is unstable or failed communication. The best fix is to standardize subnet masks across the segment, distribute settings through DHCP where possible, document subnet assignments clearly, and run regular audits to catch mismatches early.

### Subnet Boundary Violation

When subnet boundaries do not align with powers of 2, routing problems follow. For example, `192.168.1.50/26` is not a valid subnet boundary. A `/26` block has a size of 64 addresses, so valid starting points are `0`, `64`, `128`, and `192`. Because `50` is not one of those boundaries, a router cannot interpret it as a proper subnet definition.

To avoid this problem, always verify that the starting address is a multiple of the subnet size. Online subnet calculators can help, but the safest approach is to document subnet allocations carefully during the design phase and confirm after configuration that the expected routes appear in the routing table.

## Advantages and Limitations of Subnet Masks

### Advantages

The main advantage of subnet masks is flexibility in IP address allocation. Instead of being locked into the rigid size of classful addressing, administrators can choose a subnet that closely matches actual demand. If a network needs about 100 hosts, for example, a `/25` provides 126 usable addresses without wasting an oversized block. VLSM extends that flexibility by allowing different subnet sizes within the same larger network.

Subnetting also improves security and performance. Splitting a network into smaller broadcast domains reduces unnecessary traffic and limits the impact of broadcast storms. It also makes it easier to separate departments or services so that firewalls and access-control policies can be applied more precisely.

Routing and management both benefit as well. Routers can calculate network boundaries quickly, route aggregation can reduce the size of routing tables, and network teams can organize address space in ways that match geography, business units, or service boundaries. That structure makes troubleshooting easier and allows new subnets to be added without redesigning the whole network.

### Limitations

The biggest limitation of subnet masks is complexity. Working with binary values, bit boundaries, and host counts raises the learning curve for administrators, and subnet calculations become harder in VLSM environments where multiple subnet sizes coexist. Even small mistakes can lead to outages or confusing partial failures.

Configuration errors are especially troublesome. A wrong subnet mask can break connectivity, create asymmetric routing, or cause invalid subnet boundaries that routers cannot handle correctly. These issues are often harder to diagnose than simple cabling or interface problems because the network may appear to work in some cases and fail in others.

Subnetting also does not solve IPv4 exhaustion. It improves address efficiency, but it does not change the fact that IPv4 has a 32-bit address space. The long-term answer is IPv6, with its 128-bit address space. Even so, as long as IPv4 remains widely used, subnet masks will continue to be essential.

There are also compatibility concerns. Older devices may not fully support CIDR or VLSM, and some legacy applications still assume classful addressing. Differences in how vendors present subnet information can also create confusion during multi-vendor integration.

## Conclusion

Subnet masks have been a core part of TCP/IP networking for nearly 40 years. Since their introduction in RFC 950 in 1985, they have addressed the inefficiency of classful addressing, improved the flexibility of IPv4 allocation, and made it possible to divide networks logically for better security, performance, and manageability.

Their core mechanism, the bitwise AND operation, is fundamental to how routers identify network addresses and make forwarding decisions. CIDR made subnet notation shorter and easier to use, while VLSM made it practical to mix subnet sizes inside one larger network.

For network engineers, a solid understanding of subnet masks remains valuable in everyday work. It helps with designing efficient address plans, troubleshooting connectivity problems, building cloud networks such as AWS VPCs, Azure VNets, and GCP VPCs, and applying security policies at the subnet level. Even as IPv6 adoption grows, IPv4 is still everywhere, and subnet masks remain indispensable for managing it well.
