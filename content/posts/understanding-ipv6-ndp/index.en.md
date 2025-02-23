---
title: "Understanding IPv6 Neighbor Discovery Protocol (NDP)"
date: 2025-02-24T01:01:25+09:00
draft: false
description: "In IPv6 networks, NDP (Neighbor Discovery Protocol) is a core protocol that replaces ARP. This article explains NDP's operation mechanisms along with SLAAC, security measures (SEND, RA Guard)."
tags:
    [
        "IPv6",
        "NDP",
        "NeighborDiscovery",
        "NetworkSecurity",
        "NetworkAutomation",
        "IPv6Protocol",
    ]
---

## Overview

In IPv6 networks, Neighbor Discovery Protocol (NDP) is a core protocol that manages interactions between network devices. It integrates several IPv4 protocol functions such as ARP and ICMP Router Discovery, enabling more efficient network management.

### Key Features

-   Multicast-based communication reduces network load
-   Automated address configuration improves management efficiency
-   Enhanced security features support secure network operations

## 1. Core Functions of Neighbor Discovery

### Neighbor Node Discovery

Automatically finds and verifies MAC addresses of other devices in IPv6 networks. This completely replaces ARP functionality from IPv4.

### Automatic Address Configuration

Configures IPv6 addresses automatically through SLAAC without requiring a DHCP server. This is particularly useful in large-scale networks.

### Router Discovery

Automatically discovers network routers and collects necessary information. This automates default gateway configuration.

## 2. NDP Operation Method and Message Flow

### ICMPv6 Message Types

| Message                | ICMPv6 Type | Code | Purpose                    |
| ---------------------- | ----------- | ---- | -------------------------- |
| Router Solicitation    | 133         | 0    | Request router information |
| Router Advertisement   | 134         | 0    | Provide router information |
| Neighbor Solicitation  | 135         | 0    | Request MAC address        |
| Neighbor Advertisement | 136         | 0    | Respond with MAC address   |
| Redirect               | 137         | 0    | Path optimization          |

### Step-by-Step Operation Process

#### Step 1: Router Discovery

When a new node connects to the network, it first looks for a router:

```plaintext
Host -> FF02::2: "Any routers here?" (Router Solicitation)
Router -> FF02::1: "Yes, prefix is 2001:db8::/64" (Router Advertisement)
```

#### Step 2: Automatic Address Configuration

The host generates an IPv6 address based on information provided by the router:

```plaintext
Host: "I will use address 2001:db8::1234"
Host -> FF02::1: "Can I use this address?" (DAD check)
(No response = Address available)
```

#### Step 3: Neighbor Discovery

To enable actual communication, find the MAC address of neighboring nodes:

```plaintext
NodeA -> FF02::1:ff00:5678: "What's the MAC address for 2001:db8::5678?" (NS)
NodeB -> NodeA: "My MAC is 00:11:22:33:44:55" (NA)
```

#### Step 4: Path Optimization

The router notifies if there's a more efficient path available:

```plaintext
NodeA -> Router: "I want to reach 2001:db8::9"
Router -> NodeA: "It's faster to go directly via 2001:db8::7" (Redirect)
```

### DAD Processing

Handling process when duplicate addresses are detected:

```plaintext
1. HostA -> FF02::1: "Planning to use 2001:db8::1234" (NS)
2. HostB -> HostA: "Already in use" (NA)
3. HostA: Generate new EUI-64 based address
4. HostA -> FF02::1: "Checking new address 2001:db8::5678" (NS)
5. (No response) -> Start using new address
```

## Frequently Asked Questions (FAQ)

### Q1: What's the difference between NDP and ARP?

NDP is used in IPv6 environments and provides enhanced security and automation features compared to ARP. It also offers improved network efficiency through multicast-based communication.

### Q2: How can I enhance NDP security?

Implementing SEND protocol and configuring RA Guard are essential. Additionally, filtering through Access Control Lists (ACL) is recommended.

### Q3: Can IPv6 NDP be blocked?

Yes. You can block specific ICMPv6 messages in the IPv6 firewall or prevent unauthorized router advertisements through RA Guard settings.

### Q4: Why isn't ARP needed in IPv6?

IPv6 uses NDP instead of ARP, operating on an ICMPv6 basis. NDP provides a more efficient and secure address resolution method.

## Conclusion

NDP significantly improves automation and efficiency in IPv6 networks. It integrates and enhances various IPv4 protocols to meet the complex requirements of modern networks. Understanding the step-by-step operation process and applying appropriate configurations enables stable and efficient network operations.

### Key Summary

-   Core protocol replacing ARP in IPv6 environments
-   Supports automated address management and path optimization
-   Requires appropriate protection mechanisms against security threats
