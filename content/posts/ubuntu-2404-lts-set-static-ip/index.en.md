---
title: "Complete Guide to Setting Static IP on Ubuntu 24.04 LTS: Netplan, nmcli, nmtui"
date: 2024-08-10T11:26:57+09:00
tags: ["Ubuntu", "Linux", "Networking", "Static IP", "Netplan"]
description: "A detailed explanation of three methods to set a static IP on Ubuntu 24.04 LTS: Netplan, nmcli, and nmtui, covering characteristics of each method and troubleshooting tips"
draft: false
---

A static IP address is an IP address manually specified by a network administrator instead of being dynamically assigned from a DHCP server. It is essential in environments where the IP address must not change, such as server operation, remote access, and network service hosting. Ubuntu 24.04 LTS uses Netplan as the default network configuration tool and also supports nmcli and nmtui interfaces through NetworkManager, allowing users to configure networks in their preferred way.

## The Need for Static IP

> **DHCP vs Static IP**
>
> DHCP (Dynamic Host Configuration Protocol) is a protocol that automatically assigns IP addresses to devices connected to the network, which is convenient for client devices. However, servers and network equipment require static IP because service connections break when IP addresses change.

Using a static IP address allows consistent access to servers with the same IP, maintaining stable SSH remote access, web server operation, and database connections. When registering IP in DNS records or setting firewall rules based on IP, configuration can be done without worrying about IP changes. When network problems occur, having clear IP addresses for each device makes problem diagnosis and resolution easier, and traffic from specific devices can be easily identified during log analysis.

### Situations Requiring Static IP

| Situation | Reason |
|-----------|--------|
| **Server Operation** | Service access points for web servers, DB servers, file servers must not change |
| **Remote Access** | IP must be consistent when connecting via SSH, RDP |
| **DNS Configuration** | Static IP needed for A records linked to domains |
| **Firewall Rules** | When setting IP-based allow/block rules |
| **Network Monitoring** | Tracking and analyzing traffic from specific IPs |
| **Port Forwarding** | When forwarding ports to specific IPs on router |

## Network Configuration Method Comparison

There are three main methods to set a static IP on Ubuntu 24.04 LTS. Each method has unique advantages and disadvantages and can be selected based on environment and user preference.

| Method | Interface | Config File | Suitable Environment |
|--------|-----------|-------------|---------------------|
| **Netplan** | CLI/YAML | /etc/netplan/*.yaml | Servers, headless systems |
| **nmcli** | CLI | NetworkManager | Remote management, script automation |
| **nmtui** | TUI | NetworkManager | Terminal environment, intuitive setup |

## Prerequisites

Before setting a static IP, current network status must be checked and necessary information collected. First, check the network interface name and current IP address with the `ip a` or `ip addr` command, check the default gateway address with the `ip route` command, and check the current DNS server with `cat /etc/resolv.conf`.

### Required Information

| Item | Description | Example |
|------|-------------|---------|
| **Interface Name** | Network device identifier | eth0, ens33, enp0s3 |
| **IP Address** | Static IP to assign | 192.168.1.100 |
| **Subnet Mask** | Network range specification | /24 (255.255.255.0) |
| **Gateway** | Network exit, router IP | 192.168.1.1 |
| **DNS Server** | Domain name resolution server | 8.8.8.8, 1.1.1.1 |

## Method 1: Configuration Using Netplan

> **What is Netplan?**
>
> Netplan is a network configuration utility introduced in Ubuntu 17.10 that uses YAML format configuration files to configure networks. It can use systemd-networkd or NetworkManager as backends and is primarily used in server environments.

Netplan configuration files are located in the `/etc/netplan/` directory. Filenames may vary by system, such as `01-netcfg.yaml`, `50-cloud-init.yaml`, or `00-installer-config.yaml`, so check with `ls /etc/netplan/` before editing the appropriate file.

### Configuration File Structure

Netplan configuration files are written in YAML format. They are sensitive to indentation, so spaces (2 or 4) must be used instead of tabs, and there must be a space after colons (:).

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

### Configuration Item Descriptions

| Item | Description |
|------|-------------|
| **version: 2** | Netplan version (always use 2) |
| **renderer** | Backend selection (networkd or NetworkManager) |
| **ethernets** | Wired network interface settings |
| **dhcp4: no** | Disable DHCP for manual configuration |
| **addresses** | IP address and subnet mask to assign |
| **routes** | Routing settings, default means default gateway |
| **nameservers** | DNS server list |

### Applying Configuration

After saving the configuration file, apply changes with `sudo netplan apply`. If there are syntax errors, error messages are displayed and the original settings are rolled back. Using `sudo netplan try` before applying automatically reverts to original settings after 120 seconds, allowing safe testing in remote access environments.

## Method 2: Configuration Using nmcli

nmcli (NetworkManager Command Line Interface) is a CLI tool for controlling NetworkManager. It enables automation through scripts and allows stable network configuration even in remote SSH sessions.

### Checking Current Connections

First, check the current network connection list with `nmcli connection show` and identify the name of the connection to modify.

### Static IP Configuration Commands

```bash
# Set IP address
sudo nmcli connection modify "connection-name" ipv4.addresses 192.168.1.100/24

# Set gateway
sudo nmcli connection modify "connection-name" ipv4.gateway 192.168.1.1

# Set DNS
sudo nmcli connection modify "connection-name" ipv4.dns "8.8.8.8 8.8.4.4"

# Change to manual configuration mode
sudo nmcli connection modify "connection-name" ipv4.method manual

# Apply changes
sudo nmcli connection up "connection-name"
```

If the connection name contains spaces (e.g., "Wired connection 1"), it must be enclosed in quotes. To apply all settings at once, multiple options can be chained to the `nmcli connection modify` command.

## Method 3: Configuration Using nmtui

nmtui (NetworkManager Text User Interface) is a text-based user interface that runs in the terminal. It allows network configuration while visually checking settings, making it useful for users unfamiliar with commands.

### nmtui Usage Procedure

Run the interface with `sudo nmtui`, select "Edit a connection", then select the network connection to modify. In the IPv4 CONFIGURATION section, change `<Automatic>` to `<Manual>` and press `<Show>` to expand detailed settings. Enter the IP and subnet mask (e.g., 192.168.1.100/24) in Addresses, gateway address in Gateway, and DNS server address in DNS servers. Select `<OK>` to save, exit with `<Back>` then `<Quit>`, and apply changes with `sudo nmcli connection up "connection-name"`.

## Verifying Configuration

After setting a static IP, verify that settings are correctly applied with the following commands.

| Check Item | Command | Expected Result |
|------------|---------|-----------------|
| **IP Address** | `ip a` | Shows configured IP address |
| **Gateway** | `ip route` | default via gateway-address |
| **DNS** | `cat /etc/resolv.conf` | nameserver DNS-address |
| **Internet Connection** | `ping -c 4 8.8.8.8` | No packet loss |
| **DNS Resolution** | `ping -c 4 google.com` | Ping succeeds with domain |

## Troubleshooting

### Common Problems and Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| **netplan apply error** | YAML syntax error | Check indentation, use spaces instead of tabs |
| **No internet connection** | Gateway error | Check gateway with `ip route`, verify router IP |
| **Domain resolution fails** | DNS configuration error | Verify DNS server address, test with 8.8.8.8 |
| **IP conflict** | Another device using same IP | Check IPs in use on network and change |
| **Connection lost after config** | Incorrect IP settings | Access via console and modify settings |

If remote connection is lost after Netplan configuration, physically access the system to modify the configuration file or use `sudo netplan try` to leverage the automatic rollback feature. To restart NetworkManager, use `sudo systemctl restart NetworkManager`. To restart the entire network service, run `sudo systemctl restart systemd-networkd`.

## Conclusion

There are three methods to set a static IP on Ubuntu 24.04 LTS: Netplan, nmcli, and nmtui. They are suitable for YAML-based configuration in server environments, CLI environments requiring script automation, and intuitive TUI environments respectively. Setting a static IP maintains stable server operation, remote access, and network service hosting while making network management easier. Static IP configuration is recommended in environments operating servers or network equipment.
