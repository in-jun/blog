---
title: "A Quick Understanding of CIDR"
date: 2025-02-20T09:39:33+09:00
tags: ["CIDR", "Subnet", "Network", "IP"]
description: "This article summarizes the concept and practical use of CIDR, an IP address allocation method."
draft: false
---

CIDR (Classless Inter-Domain Routing) was introduced to overcome the limitations of the existing class-based IP allocation. It allows flexible allocation of IP addresses as needed, preventing address waste.

## CIDR Notation and Structure

CIDR represents the network bit count with the '/' symbol followed by the IP address:

-   192.168.1.0/24

    -   Network part: 192.168.1 (24 bits)
    -   Host part: Last 8 bits
    -   Available IPs: 254

-   192.168.1.0/25
    -   Network part: 192.168.1.0 (25 bits)
    -   Host part: Last 7 bits
    -   Available IPs: 126

## Relation with Subnet Mask

CIDR prefixes correspond one-to-one with subnet masks:

-   /24 = 255.255.255.0

    -   Binary: 11111111.11111111.11111111.00000000
    -   Available IPs: 254

-   /25 = 255.255.255.128

    -   Binary: 11111111.11111111.11111111.10000000
    -   Available IPs: 126

-   /26 = 255.255.255.192
    -   Binary: 11111111.11111111.11111111.11000000
    -   Available IPs: 62

## Understanding Network Size

The network size based on the CIDR prefix is calculated as a power of 2:

-   /24 = 2^8 = 256 addresses
-   /25 = 2^7 = 128 addresses
-   /26 = 2^6 = 64 addresses
-   /27 = 2^5 = 32 addresses

The first and last addresses in each network are reserved for network and broadcast addresses and are not available for actual use.
