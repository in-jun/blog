---
title: "Network Classes A B C D E"
date: 2025-02-20T09:27:27+09:00
tags: ["Network", "IP", "IPv4"]
description: "IPv4 network class structure and address ranges."
draft: false
---

## What is Classful Addressing

Classful Addressing is an IP address allocation method officially introduced in 1981 through the IETF's RFC 791 document alongside the IPv4 protocol. It was designed to efficiently distribute address space and minimize routing tables in the early Internet network. The system divides network sizes into 5 classes (A, B, C, D, E) based on the bit pattern of the first octet (8 bits) of the IP address, providing different sizes of network address space for each class.

This system was designed in the early 1980s when the Internet was still small-scale, enabling clear distinctions between large organizations, medium enterprises, and small networks for address allocation. Each class had fixed lengths for network and host portions, allowing routers to immediately determine network boundaries by examining only the first byte of an IP address. However, as the Internet grew rapidly in the 1990s, the problem of inefficient address space usage became severe, leading to its replacement by CIDR (Classless Inter-Domain Routing) starting in 1993.

## Basic Structure of IP Addresses

An IPv4 address consists of 32 bits (4 bytes), divided into 4 octets of 8 bits each and expressed in dotted decimal notation. Each octet can have values from 0 to 255. Logically, it is separated into two regions: the 'Network ID' that distinguishes between networks and the 'Host ID' that identifies individual hosts within that network, enabling addressing and routing at the network layer.

It's similar to the address system of office buildings. If 'Seoul, Gangnam-gu, Teheran-ro 123' is the network portion, then 'Floor 3, Room 301' is the host portion. Devices with the same network portion are considered to belong to the same network (broadcast domain) and can communicate directly without a router, but if the network portions differ, they are recognized as different networks requiring routing through a router.

Given an IP address of 192.168.1.100 (Class C basis):
- The first 24 bits (192.168.1) are the Network ID that identifies the network
- The last 8 bits (100) are the Host ID that refers to a specific device within that network
- The network address is 192.168.1.0 with all host bits set to 0, representing the network itself
- The broadcast address is 192.168.1.255 with all host bits set to 1, used to transmit data to all hosts in the network

## Class Distinction by Bit Pattern

The classful system distinguishes classes through the upper bit pattern of the first octet of the IP address. This was designed so routers could quickly identify network boundaries without complex calculations.

![Class Bit Pattern Decision Tree](class-bits.png)

Bit patterns for each class:
- **Class A**: First bit is 0 (0xxxxxxx), first octet range 1-126
- **Class B**: First two bits are 10 (10xxxxxx), first octet range 128-191
- **Class C**: First three bits are 110 (110xxxxx), first octet range 192-223
- **Class D**: First four bits are 1110 (1110xxxx), first octet range 224-239
- **Class E**: First four bits are 1111 (1111xxxx), first octet range 240-255

Note that 0.x.x.x and 127.x.x.x are reserved for special purposes. 0.0.0.0 represents the default route, and the 127.0.0.0/8 range (especially 127.0.0.1) is used as a loopback address pointing to the host itself. This limits the practical first octet range of Class A from 1 to 126.

## Class A

![Class Structure Comparison](class-structure.png)

Class A provides the largest network address space. In the early Internet, it was allocated only to a very small number of large organizations and government agencies such as MIT, IBM, HP, AT&T, Apple, the U.S. Department of Defense (DoD), and Ford Motor Company. It uses only the first 8 bits as the network portion and all remaining 24 bits as the host portion, allowing accommodation of over 16 million hosts within a single network.

**Technical Characteristics**:
- **First octet**: 1 ~ 126 (0xxxxxxx bit pattern)
- **Address range**: 1.0.0.0 ~ 126.255.255.255
- **Network portion**: First 8 bits
- **Host portion**: Remaining 24 bits
- **Number of networks**: 126 (actually 2^7 = 128, but 0 and 127 are reserved for special purposes)
- **Number of hosts**: 16,777,214 (2^24 - 2, excluding network and broadcast addresses)
- **Default subnet mask**: 255.0.0.0 (/8)

**Real Allocation Examples**:
- 3.0.0.0/8: General Electric Company
- 8.0.0.0/8: Level 3 Communications (current legacy Internet backbone)
- 12.0.0.0/8: AT&T Services
- 15.0.0.0/8: Hewlett-Packard Company
- 16.0.0.0/8: Digital Equipment Corporation (now acquired by HP)
- 17.0.0.0/8: Apple Inc.

**Network Address Calculation Example**:
```
IP address: 10.45.123.200
Class: A (first octet 10 is in 1-126 range)
Network ID: 10.0.0.0
Host ID: 0.45.123.200 (decimal 45.123.200)
Network address: 10.0.0.0 (all host bits are 0)
Broadcast address: 10.255.255.255 (all host bits are 1)
Usable host range: 10.0.0.1 ~ 10.255.255.254
```

## Class B

Class B was designed for medium-sized networks and was primarily allocated to universities, medium to large enterprises, and ISPs (Internet Service Providers). It uses the first 16 bits as the network portion and the remaining 16 bits as the host portion, providing a balance between the number of networks and hosts. As an intermediate size between Classes A and C, it can accommodate over 60,000 hosts, making it suitable for medium to large organizations.

**Technical Characteristics**:
- **First octet**: 128 ~ 191 (10xxxxxx bit pattern)
- **Address range**: 128.0.0.0 ~ 191.255.255.255
- **Network portion**: First 16 bits
- **Host portion**: Remaining 16 bits
- **Number of networks**: 16,384 (2^14, first 2 bits are for class identification)
- **Number of hosts**: 65,534 (2^16 - 2)
- **Default subnet mask**: 255.255.0.0 (/16)

**Real Allocation Examples**:
- 128.2.0.0/16: Carnegie Mellon University
- 129.6.0.0/16: Massachusetts Institute of Technology (MIT)
- 130.94.0.0/16: University of Cambridge
- 132.163.0.0/16: Princeton University
- 172.16.0.0 ~ 172.31.0.0: Private network range (RFC 1918)

**Network Address Calculation Example**:
```
IP address: 172.16.45.200
Class: B (first octet 172 is in 128-191 range)
Network ID: 172.16.0.0
Host ID: 0.0.45.200 (decimal 45 × 256 + 200 = 11,720)
Network address: 172.16.0.0
Broadcast address: 172.16.255.255
Usable host range: 172.16.0.1 ~ 172.16.255.254
```

## Class C

Class C was designed for small networks and was primarily allocated to small businesses, branch offices, and small organizations. It uses the first 24 bits as the network portion and only the last 8 bits as the host portion, accommodating only 254 hosts in a single network. However, the total number of networks exceeds 2 million, designed to provide address space to many small organizations.

**Technical Characteristics**:
- **First octet**: 192 ~ 223 (110xxxxx bit pattern)
- **Address range**: 192.0.0.0 ~ 223.255.255.255
- **Network portion**: First 24 bits
- **Host portion**: Last 8 bits
- **Number of networks**: 2,097,152 (2^21, first 3 bits are for class identification)
- **Number of hosts**: 254 (2^8 - 2)
- **Default subnet mask**: 255.255.255.0 (/24)

**Real Allocation Examples**:
- 192.168.0.0 ~ 192.168.255.0: Private network range (RFC 1918, most widely used)
- 193.0.0.0/8 ~ 223.0.0.0/8: Public IP addresses distributed to ISPs and organizations worldwide

**Network Address Calculation Example**:
```
IP address: 192.168.1.100
Class: C (first octet 192 is in 192-223 range)
Network ID: 192.168.1.0
Host ID: 0.0.0.100 (decimal 100)
Network address: 192.168.1.0
Broadcast address: 192.168.1.255
Usable host range: 192.168.1.1 ~ 192.168.1.254
```

The reason for subtracting 2 from each class is to exclude the network address and broadcast address. The network address has all 0s in the host portion and represents the network itself, so it cannot be assigned to hosts. The broadcast address has all 1s in the host portion and is used to simultaneously transmit packets to all hosts in the network, so it also cannot be assigned to individual hosts.

## Class D and E

Classes D and E are address spaces reserved for special purposes, not for general unicast communication. Unlike Classes A, B, and C, they have no distinction between network and host portions and are used only for specific purposes.

### Class D (Multicast)

Class D is an address space reserved for multicast communication. It is used when a single sender transmits data to multiple receivers simultaneously. Each receiver joins a multicast group and receives packets transmitted to the specific multicast address.

**Technical Characteristics**:
- **First octet**: 224 ~ 239 (1110xxxx bit pattern)
- **Address range**: 224.0.0.0 ~ 239.255.255.255
- **Protocol**: Group management through IGMP (Internet Group Management Protocol)
- **No network/host distinction**: All 32 bits are used as the multicast group ID

**Key Use Cases**:
- **224.0.0.1**: All Hosts on the same subnet
- **224.0.0.2**: All Routers on the same subnet
- **224.0.0.5**: OSPF router communication
- **224.0.0.9**: RIPv2 routing protocol
- **239.0.0.0 ~ 239.255.255.255**: Private addresses for intra-organization multicast

**Real Applications**:
- IPTV streaming (transmitting identical video streams from one source to multiple receivers)
- Video conferencing systems (simultaneously transmitting video/audio to multiple participants)
- Financial market data feeds (real-time transmission of stock prices to multiple trading terminals)
- Online gaming (game servers simultaneously transmitting game state to multiple clients)

### Class E (Experimental/Reserved)

Class E is address space reserved by IETF for experimental purposes and future use. It is not used in typical network environments, and most routers and operating systems are configured to filter or reject addresses in this range.

**Technical Characteristics**:
- **First octet**: 240 ~ 255 (1111xxxx bit pattern)
- **Address range**: 240.0.0.0 ~ 255.255.255.255
- **Usage restriction**: Prohibited from use in standard Internet protocols
- **Special address**: 255.255.255.255 is used as a limited broadcast address

**Special Purpose of 255.255.255.255**:
As a limited broadcast address, it is transmitted only to the local network segment and does not cross routers. DHCP clients use 255.255.255.255 as the destination address to find DHCP servers when they have not yet been assigned an IP address, transmitting DHCP Discover messages to all hosts on the same physical network.

## Private Network Addresses (RFC 1918)

Private IP address ranges officially defined through RFC 1918 in 1996 are address spaces reserved for free use in internal networks not directly connected to the Internet. They are non-routable on Internet routers and can communicate with the external Internet by being converted to public IP addresses through NAT (Network Address Translation).

**Private Address Ranges by Class**:
- **Class A**: 10.0.0.0 ~ 10.255.255.255 (10.0.0.0/8)
  - One Class A network, 16,777,216 addresses
  - Primarily used in large enterprise internal networks and data centers
- **Class B**: 172.16.0.0 ~ 172.31.255.255 (172.16.0.0/12)
  - 16 consecutive Class B networks, 1,048,576 addresses
  - Primarily used in medium enterprise networks and campus networks
- **Class C**: 192.168.0.0 ~ 192.168.255.255 (192.168.0.0/16)
  - 256 consecutive Class C networks, 65,536 addresses
  - Most widely used in home routers and small office networks

**Advantages of Private Addresses**:
- **Address conservation**: Multiple organizations can reuse the same private address ranges, mitigating public IP address exhaustion
- **Enhanced security**: Cannot be directly accessed from the external Internet, providing a basic security layer
- **Flexible network design**: Internal network structure can be freely changed without external exposure
- **Cost savings**: No need to purchase large quantities of public IP addresses; many internal hosts can operate with few public IPs

**Real Application Examples**:
- Most home Wi-Fi routers use 192.168.0.0/24 or 192.168.1.0/24 networks
- Enterprise internal networks subnet the 10.0.0.0/8 range for division by department, floor, and building
- AWS VPC (Virtual Private Cloud) provides 172.31.0.0/16 range by default

## Limitations of Classful System and Transition to CIDR

The classful addressing system was effective in the early 1980s small-scale Internet environment. However, with the emergence of the World Wide Web (WWW) and the surge in commercial Internet use in the 1990s, serious limitations became apparent. This eventually led to the introduction of CIDR (Classless Inter-Domain Routing) in 1993.

**Major Problems of Classful System**:

1. **Severe Address Space Waste**
   - Organizations needing 500 hosts found Class C (254) insufficient and had to be allocated Class B (65,534), resulting in the waste of over 65,000 addresses
   - Only 126 Class A networks exist, most allocated early to large corporations and government agencies, leaving new large organizations unable to obtain them
   - Class B addresses were nearly exhausted in the early 1990s, accelerating the IPv4 address exhaustion problem

2. **Explosive Growth of Routing Tables**
   - Class C could create over 2 million networks, each requiring a separate routing entry
   - In the early 1990s, the routing table size of Internet backbone routers increased exponentially, placing serious burden on router memory and processing capacity
   - There was no way to aggregate multiple Class C networks into one, significantly degrading routing efficiency

3. **Lack of Flexibility**
   - Network sizes were fixed at 3 options (254, 65,534, 16,777,214 hosts), making it impossible to select appropriate sizes matching actual requirements
   - Even with subnetting, it was only possible within the basic class boundaries, with many constraints
   - Network supernetting or flexible address allocation was impossible

**Emergence and Advantages of CIDR**:

CIDR, introduced in 1993 through IETF RFCs 1517, 1518, and 1519, eliminated the class concept and enabled network size adjustment in 1-bit units using Variable Length Subnet Masking (VLSM). This enabled efficient use of address space and greatly reduced routing table size through route aggregation. Currently, almost all Internet routing operates on a CIDR basis, but the concept of network classes still holds important meaning as a foundation for understanding the IP address system.

## Modern Significance of Classful System

Although the classful addressing system was replaced by CIDR in 1993, it remains important in network learning and practice for the following reasons:

1. **Historical understanding**: Essential for understanding early Internet structure and causes of IPv4 address exhaustion
2. **Basic concepts**: The concepts of network and host portions form the foundation of CIDR and subnetting
3. **Legacy systems**: Some older network equipment and documentation still use class concepts
4. **Private addresses**: RFC 1918 private addresses are still defined and widely used in class-based ranges
5. **Educational purposes**: Provides an intuitive starting point for network beginners to understand IP address structure

## Conclusion

The network class A, B, C, D, E system was an early IP address allocation method introduced in 1981 alongside IPv4. It aimed for efficient address distribution and routing by dividing address space into 5 classes according to network size. However, with the explosive growth of the Internet in the 1990s, problems of address space waste and routing table bloat became severe, leading to its replacement by CIDR in 1993. Although modern networks do not directly use class concepts, many concepts remain, including the distinction between network and host portions, private IP address ranges (RFC 1918), and multicast addresses (Class D). It plays an essential role in network learning as foundational knowledge for understanding IP address systems and subnetting.
