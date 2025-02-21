---
title: "Comprehensive Guide to Subnet Masks"
date: 2025-02-20T10:20:05+09:00
tags: ["subnet mask", "networking", "IP", "subnetting"]
description: "A Comprehensive Explanation on the History, Concept, and Implementation of Subnet Masks."
draft: false
---

The concept of a subnet mask was introduced in the evolution of TCP/IP protocols around 1985. The early internet used a classful addressing system (A, B, C classes), which was proving to be too rigid, and inefficient for IP address allocation. Subnet masks came into the picture to address this issue.

## History and Need for Subnet Masks

In the early days of the internet, the class of an IP address was determined by looking at just the first octet (byte) of the address:

-   Class A: Starts with 1-126
-   Class B: Starts with 128-191
-   Class C: Starts with 192-223

This approach had a major drawback - an organization needing 1000 hosts would have to be allocated a Class B (65,534 addresses), resulting in severe address wastage. Subnet masks were the answer to this inefficiency.

## Structure and Principle of a Subnet Mask

A subnet mask is a 32-bit value consisting of consecutive 1s followed by consecutive 0s:

-   255.255.255.0

    -   Binary: 11111111.11111111.11111111.00000000
    -   1s: Network Part (Fixed)
    -   0s: Host Part (Variable)

-   255.255.255.128

    -   Binary: 11111111.11111111.11111111.10000000
    -   Capable of Subdividing into Smaller Networks

## Practical Working of a Subnet Mask

When an IP address (192.168.1.10) and a subnet mask (255.255.255.0) are combined:

1. ANDing to Calculate Network Address

```
IP:    192.168.1.10   11000000.10101000.00000001.00001010
Mask:  255.255.255.0  11111111.11111111.11111111.00000000
-----------------------------------------------------
Net:   192.168.1.0    11000000.10101000.00000001.00000000
```

2. Determining Network Range

-   Network Address: 192.168.1.0
-   First Host: 192.168.1.1
-   Last Host: 192.168.1.254
-   Broadcast: 192.168.1.255

## Common Subnet Mask Values and Their Usage

-   255.0.0.0 (Class A)

    -   For very large networks
    -   Approximately 16 million hosts
    -   Used by governments, large organizations

-   255.255.0.0 (Class B)

    -   For medium-sized networks
    -   Approximately 65 thousand hosts
    -   Used by universities, corporations

-   255.255.255.0 (Class C)

    -   For small networks
    -   254 hosts
    -   Used by small offices, homes

-   255.255.255.192
    -   For very small networks
    -   62 hosts
    -   Used by departments, project teams

## Relationship with CIDR

With the introduction of CIDR in 1993, subnet masks started being represented as prefixes like /24:

-   255.255.255.0 = /24
-   255.255.255.128 = /25
-   255.255.255.192 = /26

This allowed for more flexible network design.
