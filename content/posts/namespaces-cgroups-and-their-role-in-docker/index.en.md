---
title: "Namespaces, Cgroups and Their Relationship with Docker"
date: 2024-06-05T21:59:22+09:00
tags: ["linux", "docker"]
description: "A comprehensive guide covering Linux kernel container technology history, detailed explanation of 7 namespace types (PID, Network, Mount, IPC, UTS, User, Cgroup), cgroups v1 vs v2 differences, Docker's isolation mechanism implementation, verifying resource management with actual commands, and security limitations with solutions"
draft: false
---

## History of Linux Container Technology

### Birth of Namespaces

Linux namespaces first began in 2002 in kernel 2.4.19 with work on the mount namespace. They were inspired by the namespace functionality widely used in Plan 9 from Bell Labs.

### Major Development Process

Additional namespaces continued to be added starting from 2006.

- **July 2007**: PID namespace introduced
- **September 2007**: NET namespace added
- **February 2008**: Memory cgroups appeared
- **Kernel 3.8**: User namespace introduction completed proper container support functionality

As of kernel version 5.6, there are now 8 types of namespaces.

### Evolution of Container Technology

LXC (Linux Containers) provided tooling to leverage the cgroups and namespace functionality in the Linux kernel in 2008. Docker emerged in 2013, combining process isolation via kernel cgroups and namespaces with tools to build and retrieve named images.

### Role of Namespaces

Namespaces are a required aspect of functioning containers in Linux. As a feature of the Linux kernel, they partition kernel resources so that one set of processes sees one set of resources while another set of processes sees a different set of resources.

Virtual machines virtualize hardware, while namespaces partition kernel functionality.

## Concept and Role of Namespaces

Namespaces are a technology that separates processes so they don't share resources. They are lighter and faster than virtual machines.

### Resource Isolation Mechanism

Namespaces provide a mechanism for isolating system resources. They enable processes within a namespace to have their own view of the system, such as process IDs, network interfaces, and file systems.

They prevent conflicts and limit resource sharing between processes by partitioning kernel functionality.

### Relationship with Containers

Various container software like Docker combine Linux namespaces with cgroups to isolate their processes. Namespaces perform isolation by creating separate environments that prevent one process from accessing or affecting other processes or the system.

### Role Distinction Between Namespaces and Cgroups

- **Namespaces**: Create isolation so processes can run in separate environments
- **Cgroups**: Distribute and limit resources like CPU, memory, and I/O among process groups

In containerization, they are used to reduce the risk of noisy neighbors—containers that use so many resources that they degrade the performance of other containers on the same host.

## Detailed Explanation of 7 Namespace Types

Linux kernel v4.4.0 provides 7 types of namespaces: cgroup, pid, net, mnt, uts, ipc, and user. Modern kernels (Linux 6.1.0+) also include a time namespace, making it 8 types total.

### PID Namespace

Isolates process IDs, providing a separate PID numbering sequence.

The first process created in a PID namespace is assigned process ID number 1. It receives the same special treatment as the normal init process, and orphaned processes within the namespace are attached to it.

The termination of this PID 1 process immediately terminates all processes in that PID namespace and any descendants.

### Network Namespace

Virtualizes the network stack. Each namespace has an independent network environment:

- **IP address set**: Unique IP address assignment
- **Routing table**: Independent routing rules
- **Socket list**: Isolated socket connections
- **Firewall**: Independent firewall rules

On creation, a network namespace contains only a loopback interface. Each network interface (physical or virtual) exists in exactly 1 namespace and can be moved between namespaces.

### Mount Namespace (MNT)

Has an independent list of mount points seen by the processes in the namespace. You can mount and unmount filesystems in a mount namespace without affecting the host filesystem.

It is useful for providing processes with an isolated view of the filesystem and ensuring that processes don't interfere with files that belong to other processes on the host.

### IPC Namespace (Inter-Process Communication)

Isolates System V IPC and POSIX message queues.

Process communication mechanisms that are isolated include:

- **Semaphores**: Synchronization between processes
- **Message queues**: Message passing between processes
- **Shared memory segments**: Memory sharing between processes

### UTS Namespace (UNIX Time-Sharing)

Allows a single system to appear to have different host and domain names to different processes. It isolates hostname and NIS domain name.

It sets the hostname used by a process, which is why containers have different hostnames than their underlying VMs.

### User Namespace

A feature available since kernel 3.8 that provides both privilege isolation and user identification segregation across multiple sets of processes.

From the container's point of view, it contains a mapping table converting user IDs to the system's point of view. For example, the root user can have user ID 0 in the container but is actually treated as user ID 1,400,000 by the system for ownership checks.

It adds an extra layer of security by mapping user IDs inside the container to different user IDs on the host. This means a process running as the root user inside a container does not have root privileges on the host.

This feature significantly reduces the risk of container breakout attacks where an attacker tries to escape the container and gain control over the host system.

### Cgroup Namespace

Isolates cgroup root directory and hierarchy view, providing containers with an isolated view of the cgroup hierarchy. It gives containers their own isolated cgroups.

## How to Use Namespaces

### Main System Calls

The main methods for using namespaces are:

- **unshare**: Separates the namespace of the current process
- **setns**: Joins the namespace of another process
- **clone**: Creates a new process while specifying the namespace

### Usage in Docker

By default, Docker uses mnt, uts, ipc, pid, and net namespaces when creating containers. When a container is launched, Docker generates a unique set of namespaces and cgroups specifically allocated to that container.

### Role of Runc

Runc interfaces directly with the Linux kernel's container features (like namespaces, cgroups, etc.) to create an isolated environment for each container. Namespaces and cgroups are often used together for process isolation and resource management.

## Concept and Components of cgroups

Cgroups (Control groups) are a feature of the Linux kernel that creates process groups and allocates and manages resources to these groups. They are designed to help control a process's resource usage on a Linux system.

### Resource Distribution and Limitation

Cgroups distribute and limit resources like CPU, memory, and I/O among process groups. Through this, they control the concurrent execution of multiple processes and can limit resource usage or assign priorities.

### Main Components

The main components of cgroups are:

- **CPU**: CPU time allocation
- **Memory**: Memory usage limitation
- **Block I/O**: Block device I/O traffic control
- **Network**: Network bandwidth limitation

### Background for Introducing Cgroup Namespace

Traditionally, cgroups assigned to processes were not namespaced, so there was some risk that information about processes would leak from one container to another. This led to the introduction of the cgroup namespace, which provides containers with their own isolated cgroups.

## Differences Between cgroups v1 and v2

### Hierarchy Structure Change

Unlike cgroups v1 which had multiple hierarchies, v2 uses a single unified hierarchy. Cgroups v2 provides a unified hierarchy against which all controllers are mounted.

Cgroups v1 allowed different resource controllers to operate in separate hierarchies for CPU, memory, block I/O, and other resources. Unlike v1, cgroup v2 has only a single process hierarchy.

Because a controller can only be assigned to one hierarchy, processes in separate hierarchies cannot be managed by the same controller. This change solved the problem, simplifying resource management and improving consistency across the system.

### Process Attachment Rules

In cgroups v1, you could attach processes to non-leaf nodes as well. In cgroups v2, you cannot attach a process to an internal subgroup if it has any controller enabled. You can only attach processes to leaves.

### Thread Management

In cgroups v1, you could assign threads of the same process to different cgroups. This is not possible in cgroups v2.

It removed the ability to discriminate between threads, choosing to work on a granularity of processes instead.

### Background for v2 Introduction

Due to the complexity of V1 implementation and inconsistency within limits in V1, V2 was created. The goal is to simplify the CGroup hierarchy and keep CGroup actions consistent across subsystems.

### Industry Trends

Kubernetes has deprecated cgroup v1. Removal will follow Kubernetes deprecation policy. The community has decided to move cgroup v1 support into maintenance mode in v1.31.

### Support by RHEL Version

- **RHEL 6 and 7**: Historically implemented CGroups V1 only
- **RHEL 8 and 9**: CGroups V1 and V2 are available with V1 being the default
- **RHEL 10**: Only CGroups V2 is available

## Using Namespaces and cgroups in Docker

Docker is a tool that simplifies the deployment and management of applications using container technology. Docker containers use namespace and cgroups functionality to run applications in isolated environments.

### Namespace Utilization

The main namespaces used in Docker are:

- **PID namespace**: Each container has an independent process space and runs in a different PID namespace than the host
- **Network namespace**: Containers have an independent network stack and use IP addresses, routing tables, etc. separately from the host
- **Mount namespace**: Each container has an independent filesystem view and has a filesystem tree separate from the host filesystem

### Cgroups Utilization

Docker can allocate and limit resources to each container using cgroups.

Controllable resources include:

- **CPU**: Processor usage limitation
- **Memory**: RAM usage limitation
- **Disk I/O**: Disk input/output speed limitation

Through cgroups, you can monitor and manage each container's resource usage.

### Abstraction and Ease of Use

Docker abstracts Linux cgroups and namespaces so users can easily create and manage containers. You can manage containers with simple commands without worrying about complex cgroups and namespace settings.

When you use the Docker command `docker run`, the necessary namespaces and cgroups are automatically set up and the container is executed.

## How to Verify Isolation Mechanisms

Linux namespaces and cgroups are core technologies of Docker that support Docker container isolation and resource management functionality. Through these, you can efficiently deploy, scale, and manage applications.

### System Level Verification

Methods for actually verifying namespaces and cgroups include:

- **`lsns` command**: Check the current system's namespaces
- **`/proc/<PID>/ns/` directory**: Check specific process namespace information
- **`/sys/fs/cgroup/` directory**: Check cgroups settings

### Docker Container Verification

Commands for verifying Docker container isolation mechanisms include:

- **`docker inspect <container_id>`**: Check that container's namespace and cgroups settings
- **`docker exec <container_id> ps aux`**: Check isolated process list
- **`docker stats <container_id>`**: Monitor real-time resource usage

## Security Limitations

### Shared Kernel Problem

While containers are isolated from each other and the host, they still share the same kernel. In Linux, namespaces, cgroups, and seccomp filters work together to create the appearance of containment. But they all run on top of the same kernel.

If that kernel is compromised, the shared kernel vulnerabilities mean those boundaries collapse. As the increasingly popular saying goes: "Containers don't contain." This represents a fundamental limitation of container isolation.

### Resource Exhaustion Attacks

By default, Linux processes and subsequently containers do not impose any limitations on the number of processes that can be generated. This can lead to the risk of resource exhaustion attacks.

### Importance of Proper Configuration

Without proper cgroups settings, one container can use excessive resources and affect other containers on the same host or the host system itself. Namespaces alone do not provide complete security and additional security layers are needed.

## Security Enhancement Solutions

### Using Security Modules

One area where container isolation can be enhanced is through the use of security modules like AppArmor and SELinux. These tools enforce additional restrictions on what processes inside containers can do.

Combined with namespaces and cgroups, they offer a defense-in-depth approach to container security.

### User Namespace Utilization

User namespaces add an extra layer of security by mapping user IDs inside the container to different user IDs on the host. This means a process running as the root user inside a container does not have root privileges on the host.

This feature significantly reduces the risk of container breakout attacks.

### eBPF Technology

eBPF, now supported by Edera, allows safe, sandboxed programs to run inside the Linux kernel. These programs can observe system calls, enforce security policies, and emit logs without requiring user-space agents.

### Modern Security Approach

In 2025-2026, while namespaces and cgroups provide essential isolation and resource management, organizations are increasingly adopting layered security approaches and advanced runtime enforcement technologies to address inherent limitations.

Best practices include:

- **Setting resource limits**: Appropriate CPU, memory, and I/O limits
- **Seccomp profiles**: System call filtering
- **Read-only filesystems**: Immutable container environments
- **Principle of least privilege**: Granting only the minimum necessary privileges

## Conclusion

Linux namespaces started in 2002 and have evolved into 8 types, becoming the core foundation of container technology. PID, Network, Mount, IPC, UTS, User, and Cgroup namespaces each isolate processes, network, filesystem, inter-process communication, hostname, user IDs, and cgroup hierarchy.

Cgroups provide functionality to allocate and limit resources for process groups. Evolution from v1 to v2 introduced a unified hierarchy structure to simplify management. Kubernetes has deprecated cgroup v1 and the transition to v2 is underway.

Docker abstracts namespaces and cgroups so users can create and manage containers with simple commands. With a single `docker run` command, all necessary isolation mechanisms are automatically set up.

From a security perspective, containers share the same kernel and do not provide complete isolation. Additional security layers like User namespace, AppArmor, SELinux, and eBPF must be used to implement a defense-in-depth approach.

In real environments, you can build a secure and efficient container environment by following best practices such as setting appropriate resource limits, using security profiles, and applying the principle of least privilege.
