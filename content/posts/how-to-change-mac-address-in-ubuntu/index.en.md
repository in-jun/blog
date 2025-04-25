---
title: "How to Change MAC Address in Ubuntu"
date: 2025-04-27T18:02:28+09:00
draft: false
description: "Learn how to change MAC address in Ubuntu."
tags:
    [
        "ubuntu",
        "networking",
        "security",
        "privacy",
        "linux",
        "mac-address",
        "macchanger",
    ]
---

## Introduction

MAC address (Media Access Control address) is a unique identifier for network devices. For security or privacy reasons, you may need to change this address. In this post, we will explore how to change MAC address in Ubuntu.

## What is a MAC Address?

MAC address is a unique identifier assigned to a Network Interface Card (NIC). This 48-bit (6-byte) address is typically displayed in hexadecimal format as `XX:XX:XX:XX:XX:XX`. The structure of the address is as follows:

-   First 3 bytes: OUI (Organizationally Unique Identifier) representing the manufacturer
-   Remaining 3 bytes: Unique number assigned by the manufacturer

## Checking Your MAC Address

Before changing the MAC address, you can check your current address with the following command:

```bash
ip link show
```

Or to check information of a specific interface:

```bash
ip link show dev <interface_name>
```

The result will look like this:

```
2: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
```

Here, `00:11:22:33:44:55` is your current MAC address.

## How to Change MAC Address: Using macchanger

`macchanger` is a dedicated tool for changing MAC addresses, offering various options.

### 1. Installing macchanger

```bash
sudo apt update
sudo apt install macchanger
```

During installation, you'll be asked "Automatically change MAC address at boot?" Choose according to your needs.

### 2. Changing the MAC Address

Changing a MAC address involves three steps:

#### 2.1 Disable the Network Interface

```bash
sudo ip link set <interface_name> down
```

Example: `sudo ip link set wlp0s20f3 down`

#### 2.2 Change the MAC Address

Change to a random MAC address:

```bash
sudo macchanger -r <interface_name>
```

Or change to a specific MAC address:

```bash
sudo macchanger -m XX:XX:XX:XX:XX:XX <interface_name>
```

#### 2.3 Enable the Network Interface

```bash
sudo ip link set <interface_name> up
```

### 3. Additional macchanger Options

| Option | Description                   | Example                                          |
| ------ | ----------------------------- | ------------------------------------------------ |
| `-r`   | Completely random MAC address | `sudo macchanger -r wlp0s20f3`                   |
| `-a`   | Random MAC from same vendor   | `sudo macchanger -a wlp0s20f3`                   |
| `-A`   | Random MAC of same type       | `sudo macchanger -A wlp0s20f3`                   |
| `-p`   | Reset to original MAC address | `sudo macchanger -p wlp0s20f3`                   |
| `-m`   | Set specific MAC address      | `sudo macchanger -m 00:11:22:33:44:55 wlp0s20f3` |
| `-s`   | Show MAC address information  | `sudo macchanger -s wlp0s20f3`                   |

## Conclusion

Changing MAC address is a useful technique for security and privacy protection. In Ubuntu, you can easily change MAC address using the `macchanger` tool, and adjust it according to your needs through various options.
