---
title: "Understanding Network Classes A, B, C, D, E"
date: 2025-02-20T09:27:27+09:00
tags: ["IP", "Class", "Network", "Addressing"]
description: "A detailed explanation of the structure of IP addresses and network classing system."
draft: false
---

## Basic Structure of an IP Address

An IP address is broadly divided into two parts: a 'network portion' that distinguishes between networks, and a 'host portion' that identifies individual devices within that network.

It's similar to the address system of an office building. If '123 Main Street, New York City' is the network portion, then 'Suite 301, 3rd Floor' is the host portion. Devices that share the same network portion belong to the same network.

Given an IP address such as 192.168.1.100:

-   The first part (192.168.1) identifies the network
-   The second part (100) refers to a specific device within that network

## Network Class Distinction

Depending on the network size, the length of the network portion and the host portion varies in an IP address. This is known as classing:

### Class A

-   First octet: 1 to 126 (0xxx xxxx)
-   Address range: 1.0.0.0 to 126.255.255.255
-   Network portion: First 8 bits
-   Host portion: Remaining 24 bits
-   Number of Networks: 126
-   Number of Hosts: 16,777,214 (2^24 - 2)

### Class B

-   First octet: 128 to 191 (10xx xxxx)
-   Address range: 128.0.0.0 to 191.255.255.255
-   Network portion: First 16 bits
-   Host portion: Remaining 16 bits
-   Number of Networks: 16,384
-   Number of Hosts: 65,534 (2^16 - 2)

### Class C

-   First octet: 192 to 223 (110x xxxx)
-   Address range: 192.0.0.0 to 223.255.255.255
-   Network portion: First 24 bits
-   Host portion: Last 8 bits
-   Number of Networks: 2,097,152
-   Number of Hosts: 254 (2^8 - 2)

The reason for subtracting 2 from each class is to exclude the network address and the broadcast address. The network address has all 0s in the host portion, and the broadcast address has all 1s in the host portion.

### Class D and E

-   Class D: 224 to 239 (Used for multicast)
-   Class E: 240 to 255 (Experimental/Reserved)
-   Not commonly used in typical networks

## Private Network Addresses

Addresses reserved for internal networks that are not directly connected to the internet:

-   Class A: 10.0.0.0 to 10.255.255.255
-   Class B: 172.16.0.0 to 172.31.255.255
-   Class C: 192.168.0.0 to 192.168.255.255

These addresses are not routed on the internet and can be freely used within an internal network.

## Why the Division?

The primary reason for network class distinction is:

-   Efficient address allocation
-   Ease of network management
-   Optimization of routing table size

For example, allocating a Class A to a company with 50 computers would result in millions of wasted addresses. Conversely, assigning a Class C to a large corporation would cause a shortage of addresses.

Nowadays, a more flexible scheme called CIDR is primarily used, but the concept of network classes still forms a foundational understanding of the IP addressing system.
