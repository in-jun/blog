---
title: "Setting Up a Static IP on Ubuntu 24.04 LTS"
date: 2024-08-10T11:26:57+09:00
tags: ["ubuntu", "ip", "networking"]
draft: false
---

## Introduction

In this article, we will discuss how to **configure a static IP** on **Ubuntu 24.04 LTS**. Static IP addresses are helpful for streamlining network management and ensuring reliable connections to your servers. We will cover the steps for configuring an IP address using **netplan**. Additionally, we will discuss the TUI (nmtui) and CLI (nmcli) methods for setting up a static IP address using NetworkManager.

## Benefits of a Static IP

1. **Consistency:** Static IP addresses ensure stability by always using the same IP for network configurations.
2. **Remote Access:** They simplify connecting to your server externally since the IP address remains consistent.
3. **Hosting Services:** Static IPs are crucial for running services such as web servers and mail servers.
4. **Firewall Configuration:** IP-based firewall rules are easier to manage with static IPs.
5. **Network Troubleshooting:** Static IPs simplify diagnosing and resolving network issues.

## Methods

### 1. Configure a Static IP Using netplan (CLI)

#### Open the Network Configuration File

Ubuntu 24.04 LTS uses `netplan` to manage network configurations. Open a terminal window and run the following command to open your network configuration file:

```bash
sudo vim /etc/netplan/<file name>.yaml
```

For example, to open the `50-cloud-init.yaml` file, you would type:

```bash
sudo vim /etc/netplan/50-cloud-init.yaml
```

> **Note:** The file name may vary based on your system. Use `ls /etc/netplan/` to check and specify the appropriate file.

#### Add Static IP Configuration

Once you have opened the file, you will see the configuration in YAML format. Modify this configuration to add a static IP address. Here's an example of a basic configuration:

```yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        <interface name>:
            dhcp4: no
            addresses:
                - <static IP address>/24
            gateway4: <gateway IP address>
            nameservers:
                addresses:
                    - <DNS server IP address>
```

Here's a breakdown of each entry:

-   `<interface name>`: This is the name of your network interface. It could be something like `eth0`, `ens33`, etc. You can find it using the `ip a` command.
-   `dhcp4: no`: This specifies that we won't be using DHCP and will manually set the IP.
-   `<static IP address>`: This is the static IP address you want to assign. For example: `192.168.1.100`.
-   `/24`: This is the subnet mask. `/24` is equivalent to 255.255.255.0.
-   `<gateway IP address>`: This is the gateway address for your network. It's usually the IP address of your router, for example: `192.168.1.1`.
-   `<DNS server IP address>`: This is the IP address of the DNS server you want to use. DNS is responsible for translating domain names into IP addresses. Common options include `8.8.8.8` (Google DNS) or `1.1.1.1` (Cloudflare DNS).

A real-world example:

```yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        ens33:
            dhcp4: no
            addresses:
                - 192.168.1.100/24
            gateway4: 192.168.1.1
            nameservers:
                addresses:
                    - 8.8.8.8
                    - 8.8.4.4
```

#### Apply the Configuration

After modifying the configuration file, you need to apply the changes to your system. Use the following command to apply the new network configuration:

```bash
sudo netplan apply
```

### 2. Configure a Static IP Using CLI (nmcli)

You can also configure a static IP using the command-line interface (CLI) with the `nmcli` command.

```bash
sudo nmcli connection modify <connection-name> ipv4.addresses <ip-address>/<subnetmask>
sudo nmcli connection modify <connection-name> ipv4.gateway <gateway-address>
sudo nmcli connection modify <connection-name> ipv4.dns <dns-server-address>
sudo nmcli connection modify <connection-name> ipv4.method manual
sudo nmcli connection up <connection-name>
```

For example:

```bash
sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.1.100/24
sudo nmcli connection modify "Wired connection 1" ipv4.gateway 192.168.1.1
sudo nmcli connection modify "Wired connection 1" ipv4.dns "8.8.8.8 8.8.4.4"
sudo nmcli connection modify "Wired connection 1" ipv4.method manual
sudo nmcli connection up "Wired connection 1"
```

### 3. Configure a Static IP Using TUI (nmtui)

If you prefer a text-based user interface (TUI), you can use the `nmtui` command.

1. Run the `sudo nmtui` command in your terminal.
2. Select "Edit a connection".
3. Choose the network connection you want to modify.
4. In the "IPv4 CONFIGURATION" section, change "Automatic" to "Manual".
5. Enter the Addresses, Gateway, and DNS servers.
6. Select "OK" to save the settings.
7. Select "Back" and then "Quit" to exit nmtui.

## Verifying the Configuration

Once you have configured a static IP, it's important to verify that it's working as expected. You can use the following commands to check your network configuration:

1. Check the IP address:

    ```bash
    ip a
    ```

2. Test the network connection:

    ```bash
    ping -c 4 8.8.8.8
    ```

3. Check the DNS:
    ```bash
    nslookup www.google.com
    ```

## Troubleshooting

If you encounter any issues after configuring a static IP, check the following:

1. **Configuration File Syntax**: Make sure the YAML file has the correct indentation. YAML is indentation-sensitive, and spaces should be used instead of tabs.
2. **Duplicate IP**: Ensure that the IP address you have configured does not conflict with other devices on your network.
3. **Gateway Address**: Verify that the gateway address is correct. This is typically the IP address of your router.
4. **DNS Server**: Make sure that the DNS server address is correct and that it is accessible.
5. **Network Interface Name**: Use `ip a` command to check the actual network interface name and ensure that it's used correctly in your configuration file.
6. **Restart Network Manager**: If you continue to experience issues, try restarting the network manager. Run `sudo systemctl restart NetworkManager`.

## Conclusion

In this article, we explored different methods to successfully set up a static IP address in Ubuntu 24.04 LTS. You can configure a static IP using netplan, TUI (nmtui), or CLI (nmcli), depending on your preferences and situation. Using a static IP address streamlines network management and ensures reliable connections to your servers. You can further customize your network configuration based on your specific requirements.
