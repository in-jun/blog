---
title: Understand How the ARP Protocol Works
date: 2025-02-20T12:24:07+09:00
tags: ["ARP", "Network", "MAC address", "IP address"]
description: "ARP(Address Resolution Protocol)의 개념과 동작 방식을 쉽게 설명한다."
draft: false
---

ARP(Address Resolution Protocol) is a protocol that finds the MAC address corresponding to an IP address. When communication occurs between devices on a network, it is necessary to find out the MAC address to deliver the packet to the destination.

## The Role of ARP

1. **Convert IP addresses to MAC addresses**
2. **Identify devices that can communicate directly within the network**
3. **Optimize performance through ARP caching**
4. **Detect duplicate IP conflicts (using Gratuitous ARP)**

## ARP Operation Process

### 1. ARP Request (ARP Request)

When a host knows the destination IP address but not the MAC address, it broadcasts an ARP request to the network.

-   Source MAC address: MAC address of the device that sent the request
-   Destination MAC address: FF:FF:FF:FF:FF:FF (broadcast)
-   Source IP address: IP address of the device that sent the request
-   Destination IP address: IP address of the destination device

### 2. ARP Reply (ARP Reply)

The device with the destination IP sends its MAC address as a reply.

-   Source MAC address: MAC address of the destination device
-   Destination MAC address: MAC address of the device that sent the request
-   Source IP address: IP address of the destination device
-   Destination IP address: IP address of the device that sent the request

The sender then stores the MAC address in the cache for quick access the next time a request is made.

## ARP Cache and TTL

ARP caches MAC addresses for performance, and the information expires after a certain period of time. This is called **TTL (Time To Live)**. Expired MAC address information is refreshed by sending an ARP request again.

-   **Dynamic ARP Cache**: MAC addresses that are learned automatically, deleted after a certain period of time.
-   **Static ARP Cache**: MAC addresses that are manually set by the administrator, maintained permanently.

## ARP Issues and Security Issues

Since ARP does not have security features, it is vulnerable to attacks such as:

-   **ARP Spoofing**: An attacker can intercept traffic by responding with a fake MAC address.
-   **MITM (Man-in-the-Middle) Attack**: Communication content can be intercepted in the middle using ARP spoofing.
-   **Cache Poisoning**: Incorrect MAC information can be stored in the cache, causing network failures.

### How to Enhance ARP Security

1. **Use static ARP table**: Manually register the MAC address for important devices.
2. **Use ARP Inspection**: Block unauthorized ARP packets on the switch.
3. **Use secure tunneling such as VPN**: Prevent ARP spoofing on untrusted networks.

## Conclusion

ARP is an essential protocol for network communication, but it also has security vulnerabilities. It is important for network administrators to understand the working principle of ARP and to prepare security measures.
