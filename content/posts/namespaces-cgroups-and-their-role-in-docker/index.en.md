---
title: "Namespaces, cgroups, and their relationship with Docker"
date: 2024-06-05T21:59:22+09:00
tags: ["linux", "docker"]
draft: false
---

### Namespace

1. **Concept**:
    - A feature of the **Linux kernel** that enables the separation of processes so that they do not share resources.
    - **Lightweight and faster** than virtual machines.
    - Virtual machines **virtualize hardware**, while **namespaces** partition **kernel functionalities**.
    - Isolates kernel functionalities to prevent collision and limit resource sharing among processes.
2. **Components**:
    - **PID**: Process ID
    - **Network**: Network devices, IP addresses, port numbers, etc.
    - **Mount**: Filesystem
    - **IPC**: Message queues, semaphores, shared memory, etc.
    - **UTS**: Hostname, domain name
    - **User**: User ID, group ID
3. **Usage**:
    - **unshare**: Unshares the namespace of the current process.
    - **setns**: Joins the namespace of another process.
    - **clone**: Creates a new process while specifying a namespace.

### Control Groups (cgroups)

1. **Concept**:
    - A feature of the **Linux kernel** that enables the creation of process groups and the allocation and management of resources like CPU, memory, disk, etc. to these groups.
    - Provides control over the concurrent execution of processes and allows for resource limiting or prioritization.
2. **Components**:
    - **CPU**: CPU time allocation
    - **Memory**: Memory usage limits
    - **Block I/O**: I/O traffic control for block devices
    - **Network**: Network bandwidth limits
3. **Usage**:
    - **Mount cgroup filesystem**: `mount -t cgroup cgroup /sys/fs/cgroup`
    - **Create cgroup**: `mkdir /sys/fs/cgroup/memory/mygroup`
    - **Assign process and set resource limits**: Assign processes to the created cgroup and set the required resource limits.

### Relationship with Docker

1. **Docker Concept**:
    - Docker is a tool that simplifies the deployment and management of applications using container technology.
    - Docker containers use namespace and cgroup functionalities to run applications in isolated environments.
2. **Namespaces and Docker**:
    - **PID namespace**: Each container has an independent process space and runs in a different PID namespace from the host.
    - **Network namespace**: Containers have an independent network stack and can have their own IP addresses, routing tables, etc., separate from the host.
    - **Mount namespace**: Each container has an independent filesystem view and can have a separate filesystem tree isolated from the host filesystem.
3. **Cgroups and Docker**:
    - **Resource allocation**: Docker uses cgroups to allocate and limit resources like CPU, memory, disk I/O, etc. to each container.
    - **Resource monitoring**: Docker can monitor the resource usage of each container through cgroups.
4. **Conclusion**:
    - Docker abstracts the complexity of Linux cgroups and namespaces, making it easier for users to create and manage containers.
    - Users can manage containers with simple commands, without worrying about complex cgroup and namespace setups.
    - Using the Docker command `docker run` automatically sets up the required namespaces and cgroups, and runs the container.

Namespaces and cgroups in Linux are essential technologies in Docker, enabling the isolation and resource management capabilities of Docker containers. This allows for efficient deployment, scaling, and management of applications.
