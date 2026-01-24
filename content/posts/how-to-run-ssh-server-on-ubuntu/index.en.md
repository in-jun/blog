---
title: "Running OpenSSH Server on Ubuntu"
date: 2024-08-14T15:16:40+09:00
tags: ["Linux", "Ubuntu", "SSH"]
description: "Installing and configuring OpenSSH server on Ubuntu."
draft: false
---

SSH (Secure Shell) is an encrypted network protocol that enables secure remote access to other computers over a network for executing commands and transferring files. It was developed in 1995 by Tatu Ylönen at Helsinki University of Technology in Finland to address security vulnerabilities in Telnet and rsh (remote shell). Today, OpenSSH has become the de facto standard implementation and serves as a core tool for server management worldwide. Installing and configuring an SSH server on Ubuntu enables remote server management not only within local networks but also over the internet. This guide covers the entire process from OpenSSH server installation to security configuration.

## SSH Protocol Overview

> **What is SSH (Secure Shell)?**
>
> SSH is a protocol for securely connecting to remote systems through encrypted communication channels. It uses port 22 by default and combines symmetric encryption, asymmetric encryption, and hash functions to ensure confidentiality, integrity, and authentication.

SSH evolved from the initial SSH-1 protocol to the current standard SSH-2. SSH-2 addressed security vulnerabilities and enhanced file transfer capabilities with SFTP (SSH File Transfer Protocol) support. An SSH connection begins with key exchange between client and server to generate a session key, after which all communication is encrypted with this session key.

### SSH vs Legacy Remote Access Protocols

| Protocol | Encryption | Port | Security Level | Current Status |
|----------|------------|------|----------------|----------------|
| **Telnet** | None (plaintext) | 23 | Very Low | Deprecated |
| **rsh/rlogin** | None | 513/514 | Very Low | Deprecated |
| **SSH** | AES, ChaCha20, etc. | 22 | High | Standard |
| **Mosh** | AES-128-OCB | UDP 60000+ | High | SSH complement |

### SSH Authentication Methods

SSH supports multiple authentication methods that can be selected based on security level and convenience requirements.

| Authentication Method | Description | Security Level | Recommendation |
|-----------------------|-------------|----------------|----------------|
| **Password** | Authenticate with user account password | Medium | Internal networks only |
| **Public Key** | Uses RSA, Ed25519 key pairs | High | Recommended |
| **Certificate-based** | Uses CA-signed certificates | Very High | Large-scale environments |
| **GSSAPI/Kerberos** | Centralized authentication | High | Enterprise |

## Prerequisites

Before installing an SSH server, verify system requirements and gather necessary information. The installation process is identical for both Ubuntu Desktop and Server editions.

### Required Information

| Item | Description | How to Check |
|------|-------------|--------------|
| **Server IP Address** | Network address of the server | `ip a` or `hostname -I` |
| **User Account** | Account for SSH access | `whoami` |
| **Network Status** | Internet or local network connection | `ping 8.8.8.8` |
| **Firewall Status** | UFW activation status | `sudo ufw status` |

## SSH Server Installation

### Step 1: System Update and OpenSSH Installation

Update the system package list and install the OpenSSH server. The SSH service starts automatically upon installation completion.

```bash
# Update package list
sudo apt update

# Install OpenSSH server
sudo apt install openssh-server -y
```

### Step 2: Verify SSH Service Status

After installation, verify that the SSH service is running properly and configure it to start automatically on boot.

```bash
# Check service status
sudo systemctl status ssh

# Start service if not running
sudo systemctl start ssh

# Enable automatic start on boot
sudo systemctl enable ssh
```

If the service status output shows `Active: active (running)`, the SSH server is running properly.

## SSH Server Configuration

> **The sshd_config File**
>
> `/etc/ssh/sshd_config` is the configuration file for the SSH daemon (sshd), controlling all SSH server behavior including port number, authentication methods, and access restrictions. The SSH service must be restarted after configuration changes for them to take effect.

You can modify the SSH configuration file to enhance security and customize settings according to your needs. Creating a backup before modifying the configuration file is recommended.

```bash
# Backup configuration file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# Edit configuration file
sudo nano /etc/ssh/sshd_config
```

### Key Configuration Options

| Setting | Default | Recommended | Description |
|---------|---------|-------------|-------------|
| **Port** | 22 | Non-standard port | SSH connection port |
| **PermitRootLogin** | prohibit-password | no | Allow root login |
| **PasswordAuthentication** | yes | no (with key auth) | Allow password authentication |
| **PubkeyAuthentication** | yes | yes | Allow public key authentication |
| **MaxAuthTries** | 6 | 3 | Maximum authentication attempts |
| **ClientAliveInterval** | 0 | 300 | Client alive check interval (seconds) |

### Configuration Example

```
# Change port (use instead of default 22)
Port 2222

# Disable root login
PermitRootLogin no

# Disable password authentication (when using public key auth)
PasswordAuthentication no

# Enable public key authentication
PubkeyAuthentication yes

# Disallow empty passwords
PermitEmptyPasswords no

# Maximum authentication attempts
MaxAuthTries 3

# Session timeout settings
ClientAliveInterval 300
ClientAliveCountMax 2
```

Restart the SSH service after configuration changes to apply them.

```bash
# Check configuration syntax
sudo sshd -t

# Restart SSH service
sudo systemctl restart ssh
```

## Firewall Configuration

If using UFW (Uncomplicated Firewall), Ubuntu's default firewall, you must allow SSH connections. You can skip this step if the firewall is not enabled.

```bash
# Check firewall status
sudo ufw status

# Allow SSH (default port 22)
sudo ufw allow ssh

# For non-standard ports
sudo ufw allow 2222/tcp

# Enable firewall (if disabled)
sudo ufw enable
```

### Allow SSH from Specific IPs Only

For enhanced security, you can restrict SSH access to specific IP addresses or network ranges.

```bash
# Allow SSH from specific IP only
sudo ufw allow from 192.168.1.100 to any port 22

# Allow SSH from specific subnet only
sudo ufw allow from 192.168.1.0/24 to any port 22
```

## Public Key Authentication Setup

> **What is Public Key Authentication?**
>
> Public key authentication uses asymmetric encryption where the private key is kept on the client and the public key is registered on the server, enabling secure authentication without passwords. It provides much stronger security than password authentication.

### Generate Key Pair on Client

Generate an SSH key pair on the client computer. The Ed25519 algorithm is currently the most recommended algorithm.

```bash
# Generate Ed25519 key (recommended)
ssh-keygen -t ed25519 -C "your_email@example.com"

# Generate RSA key (for compatibility)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### Key Algorithm Comparison

| Algorithm | Key Length | Security Level | Performance | Recommendation |
|-----------|------------|----------------|-------------|----------------|
| **Ed25519** | 256-bit | Very High | Very Fast | Recommended |
| **RSA** | 4096-bit | High | Moderate | For compatibility |
| **ECDSA** | 256/384/521-bit | High | Fast | Acceptable |
| **DSA** | 1024-bit | Low | Moderate | Deprecated |

### Register Public Key on Server

Registering the generated public key on the server enables passwordless SSH access.

```bash
# Automatically copy public key (recommended)
ssh-copy-id username@server_ip

# Manually copy public key
cat ~/.ssh/id_ed25519.pub | ssh username@server_ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

Disabling password authentication after registering the public key significantly enhances security.

## SSH Connection

### Basic Connection

Connect to the server using the SSH command from the client. On first connection, a message asking to verify the server's host key fingerprint will appear.

```bash
# Basic connection
ssh username@server_ip

# Connection with port specification
ssh -p 2222 username@server_ip

# Use specific private key
ssh -i ~/.ssh/id_ed25519 username@server_ip
```

### Simplify Connections with SSH Config File

Creating a `~/.ssh/config` file to store settings for frequently accessed servers simplifies connections.

```
Host myserver
    HostName 192.168.1.100
    User ubuntu
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
```

After configuration, you can connect simply with `ssh myserver`.

## Security Hardening

### Key Security Measures

| Security Measure | Effect | Implementation Difficulty |
|------------------|--------|---------------------------|
| **Non-standard port** | Avoid automated scans | Easy |
| **Public key authentication** | Prevent password theft | Medium |
| **Disable root login** | Prevent privilege escalation | Easy |
| **Install fail2ban** | Block brute force attacks | Medium |
| **Two-factor authentication (2FA)** | Additional authentication layer | Difficult |

### fail2ban Installation and Configuration

fail2ban is a tool that monitors log files to detect repeated authentication failures and automatically blocks the offending IP addresses. It is effective against brute force attacks.

```bash
# Install fail2ban
sudo apt install fail2ban -y

# Start and enable service
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

## Troubleshooting

### Common Problems and Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| **Connection refused** | SSH service not running or firewall | Check `systemctl status ssh`, `ufw status` |
| **Permission denied** | Authentication failure or key permission issue | Check key permissions: `chmod 600 ~/.ssh/id_*` |
| **Host key verification failed** | Server key changed | Delete entry from `~/.ssh/known_hosts` |
| **Connection timed out** | Network issue or wrong IP | Verify network connection and IP address |

If SSH key file permissions are incorrect, connections will be refused. Private keys must be set so only the owner can read them.

```bash
# Set private key permissions
chmod 600 ~/.ssh/id_ed25519

# Set .ssh directory permissions
chmod 700 ~/.ssh
```

## Conclusion

This guide covered the process of installing and configuring an SSH server on Ubuntu. OpenSSH originated from the OpenBSD project in 1999 and has become the most widely used SSH implementation. SSH serves various purposes including server management, remote development, and file transfer. A secure remote access environment can be established through public key authentication and proper security configuration. For servers exposed to the internet, security measures such as non-standard port usage, public key authentication only, and fail2ban installation must be applied to protect against threats like brute force attacks.
