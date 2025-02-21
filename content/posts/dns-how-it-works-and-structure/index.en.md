---
title: "Understanding the Mechanics and Structure of DNS"
date: 2025-02-20T12:15:59+09:00
tags: ["DNS", "Network", "Domain", "Name Server"]
description: "Describes the basic concepts, mechanics, and hierarchical structure of the DNS."
draft: false
---

DNS (Domain Name System) is a system that translates domain names into IP addresses on the Internet. When a user tries to access a website by typing in its domain name, DNS translates it into the IP address of the corresponding server and facilitates the connection.

## Role of DNS

1. **Translate domain names to IP addresses**
2. **Translate IP addresses to domain names (reverse lookup)**
3. **Provide mail server information (MX records)**
4. **Map multiple IPs for load balancing**

## DNS Resolution Process

DNS operates in a hierarchical structure and goes through the following steps:

### 1. User's Request (DNS Query)

When a user tries to access `www.example.com`, the browser or operating system sends a request to a DNS server for the IP address of that domain.

### 2. Local DNS Server Check

The operating system first checks its **local cache** (previously stored DNS information) and, if not found, it queries its **ISP's (Internet Service Provider) DNS server**.

### 3. Root Name Server Lookup

If the local DNS server does not have the information, it queries the **Root Name Server**. The root server returns the location of the Top-Level Domain (TLD) name servers, such as `.com`, `.net`.

### 4. TLD Name Server Lookup

It receives the location of the name server responsible for the `.com` domain from the root name server and queries that server for information about `example.com`.

### 5. Authoritative Name Server Lookup

The TLD name server finally provides the **authoritative name server** responsible for `example.com`. This name server returns the actual IP address.

### 6. Providing IP Address to User

The local DNS server returns the obtained IP address to the user, who then uses this IP address to access the website.

## Types of DNS Servers

DNS servers have different roles and can be categorized as:

-   **Root Name Servers**: Provide information about name servers for top-level domains.
-   **TLD Name Servers (Top Level Domain Name Servers)**: Manage information for top-level domains like `.com`, `.org`.
-   **Authoritative Name Servers**: Provide the final IP information for a specific domain.
-   **Recursive DNS Servers**: Handle and cache DNS requests from users.

## DNS Record Types

DNS has various types of records, with each record serving a specific purpose:

-   **A record**: Maps a domain to an IPv4 address
-   **AAAA record**: Maps a domain to an IPv6 address
-   **CNAME record**: Maps a domain to another domain
-   **MX record**: Provides mail server information
-   **TXT record**: Stores text information like SPF, DKIM

## DNS Caching and TTL

To optimize performance and prevent repeated lookups, **DNS caching** is employed. Cached information is automatically refreshed based on its **TTL (Time To Live)** value:

-   **Local cache**: Stored on the user's PC or browser
-   **ISP cache**: Stored on the DNS servers of the Internet provider
-   **Public DNS server cache**: Stored on servers like Google DNS (8.8.8.8)

## Conclusion

DNS plays a crucial role on the Internet and enables fast website access and stable network operations.
