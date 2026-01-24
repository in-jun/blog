---
title: "Changing MAC Address in Ubuntu"
date: 2025-04-27T18:02:28+09:00
draft: false
description: "Modifying MAC addresses in Ubuntu using macchanger."
tags: ["Linux", "Network", "Ubuntu"]
---

## The Need for Changing MAC Address

MAC address (Media Access Control address) is a unique physical address that identifies network devices. It is permanently assigned to the Network Interface Card (NIC) during manufacturing and is designed to remain unchanged. However, there are situations where you may need to temporarily or permanently change your MAC address for reasons such as security, privacy protection, bypassing network access controls, or setting up test environments. This is particularly useful when using public Wi-Fi or when you want to prevent network tracking. Most Linux distributions, including Ubuntu, provide the ability to change MAC addresses through software. This post explores how to safely and effectively change MAC addresses in Ubuntu.

## MAC Address Structure and Role

MAC address is a unique identifier assigned to a Network Interface Card (NIC). It operates at the Data Link layer (Layer 2) of the OSI model and is used to identify devices within the same network segment. This 48-bit (6-byte) address is typically displayed in hexadecimal format as `XX:XX:XX:XX:XX:XX`. It follows a standard system managed by IEEE (Institute of Electrical and Electronics Engineers) to ensure global uniqueness.

The MAC address consists of two parts. The first 3 bytes (24 bits) represent the OUI (Organizationally Unique Identifier), which IEEE uniquely assigns to each manufacturer. The remaining 3 bytes (24 bits) are unique numbers assigned by the manufacturer to each device. Theoretically, one OUI can generate approximately 16.77 million unique MAC addresses. For example, in `00:1A:2B:3C:4D:5E`, `00:1A:2B` represents the manufacturer and `3C:4D:5E` represents the unique number within that manufacturer.

## Checking Your MAC Address

Before changing your MAC address, it is important to check your current address. In Ubuntu, you can use the `ip` command to query the MAC address of network interfaces. This command is a modern network management tool that replaces the legacy `ifconfig` command, providing more features and accurate information.

To check all network interface information on your system, use the following command.

```bash
ip link show
```

To check information for a specific interface, specify the interface name with the `dev` option.

```bash
ip link show dev <interface_name>
```

The command output displays the network interface's status, MTU, queue length, and other information along with the MAC address.

```
2: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
```

Here, `00:11:22:33:44:55` following `link/ether` is your current MAC address, and `brd ff:ff:ff:ff:ff:ff` represents the broadcast address. The interface name `wlp0s20f3` is generated according to Ubuntu's predictable network interface naming scheme, where `wl` stands for wireless and `p0s20f3` indicates the PCI bus location.

## How to Change MAC Address: Using macchanger

`macchanger` is a dedicated command-line tool for changing MAC addresses. It is open-source software distributed under the GNU General Public License and provides various options and safe MAC address changing capabilities. This tool not only changes MAC addresses but also supports advanced features such as querying manufacturer information, generating MAC addresses from specific manufacturers, and creating completely random addresses to accommodate various use cases.

### 1. Installing macchanger

You can install macchanger from Ubuntu's official repository. The installation process is very straightforward.

```bash
sudo apt update
sudo apt install macchanger
```

During installation, a debconf configuration screen will appear asking "Automatically change MAC address at boot?" If you enable this option, your MAC address will automatically change to a random value every time the system boots. It is recommended to select 'Yes' in environments where security and privacy are important, and 'No' in typical usage environments. You can change this setting later by modifying scripts in the `/etc/network/if-pre-up.d/` directory.

### 2. Changing the MAC Address

Changing a MAC address involves three steps, each necessary to safely manage the network interface state while changing the address. Changing the MAC address while the network interface is active can cause unstable network connections or system errors. Therefore, you must disable the interface before changing it and then re-enable it.

#### 2.1 Disable the Network Interface

Before changing the MAC address, disable the network interface. This brings down the interface at the hardware level, stopping network communication.

```bash
sudo ip link set <interface_name> down
```

For example, to disable the wireless interface `wlp0s20f3`, execute the following.

```bash
sudo ip link set wlp0s20f3 down
```

This command immediately disconnects all network connections through that interface. If you are working through a remote SSH session, make sure to verify that the interface you are changing is not the one being used for the SSH connection.

#### 2.2 Change the MAC Address

With the interface disabled, use macchanger to change the MAC address. You can change to a completely random MAC address or set a specific address.

**Change to a completely random MAC address:**

```bash
sudo macchanger -r <interface_name>
```

This option generates random values for all 48 bits including the OUI, creating an address unrelated to any actual manufacturer. It provides the highest anonymity but may be recognized as an abnormal device on some networks.

**Change to a specific MAC address:**

```bash
sudo macchanger -m XX:XX:XX:XX:XX:XX <interface_name>
```

For example, to change to `00:11:22:33:44:55`, execute the following.

```bash
sudo macchanger -m 00:11:22:33:44:55 wlp0s20f3
```

After executing the command, macchanger displays the original MAC address, new MAC address, and change result on the screen, allowing you to verify that the change was successful.

#### 2.3 Enable the Network Interface

Once the MAC address change is complete, re-enable the network interface to connect to the network with the new MAC address.

```bash
sudo ip link set <interface_name> up
```

When the interface is enabled, the DHCP client automatically runs to request an IP address and connects to the network with the new MAC address. For wireless networks, NetworkManager or wpa_supplicant automatically attempts to reconnect, so the network connection is restored without additional configuration.

### 3. Additional macchanger Options

macchanger provides various options to support different use cases, allowing you to change or query MAC addresses according to specific purposes and security levels.

| Option | Description                   | Example                                          |
| ------ | ----------------------------- | ------------------------------------------------ |
| `-r`   | Completely random MAC address | `sudo macchanger -r wlp0s20f3`                   |
| `-a`   | Random MAC from same vendor   | `sudo macchanger -a wlp0s20f3`                   |
| `-A`   | Random MAC of same type       | `sudo macchanger -A wlp0s20f3`                   |
| `-p`   | Reset to original MAC address | `sudo macchanger -p wlp0s20f3`                   |
| `-m`   | Set specific MAC address      | `sudo macchanger -m 00:11:22:33:44:55 wlp0s20f3` |
| `-s`   | Show MAC address information  | `sudo macchanger -s wlp0s20f3`                   |

**Detailed Option Descriptions:**

- **`-r` (Completely random)**: Generates random values for all 48 bits including the OUI, creating an address unrelated to any actual manufacturer. It provides the highest anonymity but may be recognized as an abnormal device on some networks.
- **`-a` (Random from same vendor)**: Maintains the OUI of the current MAC address while randomizing only the remaining 24 bits, making it appear as another device from the same manufacturer and attracting less suspicion from network administrators.
- **`-A` (Random of same type)**: Selects an OUI appropriate for the network interface type (wired, wireless, etc.) and generates a random MAC address. Wired interfaces use OUIs for wired devices, while wireless interfaces use OUIs for wireless devices.
- **`-p` (Reset to original)**: Returns to the original MAC address (Permanent MAC address) set in the hardware. macchanger automatically records the address before changes, making restoration easy.
- **`-m` (Set specific address)**: Changes to a specific MAC address specified by the user. This is useful in test environments or when you need to mimic a specific device.
- **`-s` (Show information)**: Displays the current MAC address, original MAC address, and manufacturer information. You can check information without actually changing the address.

## Precautions

Changing MAC addresses should be used for legitimate security and privacy purposes, and you must be aware of several important precautions.

**Legal Considerations**: While changing MAC addresses is legal in most countries, bypassing network access controls or impersonating another person's device to gain unauthorized network access is illegal and can be considered a computer crime. Bypassing time restrictions on public Wi-Fi or unauthorized circumvention of MAC filtering may violate service terms or be illegal, so caution is necessary.

**Network Conflicts**: Changing to a MAC address that already exists on the same network can cause IP address conflicts, and both devices may not connect to the network properly. Network administrators may detect this and trigger security alerts. It is safer to generate completely random MAC addresses or select addresses that are not actually in use.

**Reset on Reboot**: MAC addresses changed with macchanger are software-based changes, so they revert to the hardware's original MAC address when the system is rebooted. If you want permanent changes, you must configure them to change automatically at boot through NetworkManager settings or systemd services.

**Remote Connection Caution**: If you change the MAC address while connected remotely to the system via SSH or remote desktop, the network connection may be disconnected. It is safer to work with physical access to the system or maintain a backup connection through another network interface.

## Conclusion

Changing MAC addresses is a useful technique for security and privacy protection. It can be used for purposes such as preventing tracking when using public Wi-Fi, building network test environments, and enhancing privacy. In Ubuntu, you can safely change MAC addresses with simple commands using the `macchanger` tool. It provides various options from generating completely random addresses to creating addresses from specific manufacturers, allowing you to adjust according to your needs. However, you must be aware of precautions to prevent legal issues and network conflicts, use it only for legal and ethical purposes, and it is important to comply with network administrator policies and service terms.
