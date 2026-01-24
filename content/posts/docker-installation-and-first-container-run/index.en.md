---
title: "Installing Docker and Running Your First Container"
date: 2025-02-17T22:37:02+09:00
tags: ["Docker", "Container", "Linux"]
description: "Installing Docker on Ubuntu and running your first container."
draft: false
---

Docker is a platform for developing, deploying, and running container-based applications. It uses Linux kernel namespaces and cgroups to run applications in isolated environments. This guide explains the step-by-step process of installing Docker and running your first container on Ubuntu Linux.

## Docker Installation Requirements

> **Docker Installation Requirements**
>
> Docker Engine runs on 64-bit Linux systems and requires kernel version 3.10 or higher. For Ubuntu, versions 20.04 LTS, 22.04 LTS, and 24.04 LTS are officially supported.

### Supported Ubuntu Versions

| Ubuntu Version | Codename | Support Status | Recommended |
|----------------|----------|----------------|-------------|
| **Ubuntu 24.04 LTS** | Noble Numbat | Officially Supported | Recommended |
| **Ubuntu 22.04 LTS** | Jammy Jellyfish | Officially Supported | Recommended |
| **Ubuntu 20.04 LTS** | Focal Fossa | Officially Supported | Supported |
| Ubuntu 23.10 | Mantic Minotaur | Officially Supported | Non-LTS |
| Ubuntu 18.04 LTS | Bionic Beaver | End of Support Soon | Not Recommended |

### System Architecture Support

Docker supports various CPU architectures, and installation methods may vary slightly depending on the architecture.

| Architecture | Description | Support Status |
|--------------|-------------|----------------|
| **x86_64 / amd64** | Standard desktop/server CPUs | Full Support |
| **arm64 / aarch64** | ARM-based servers (AWS Graviton, Apple M series, etc.) | Full Support |
| **armhf** | 32-bit ARM (Raspberry Pi, etc.) | Limited Support |
| **s390x** | IBM Z series mainframes | Full Support |

## Docker Installation Process

### Step 1: Remove Existing Docker Packages

Before installing new Docker, you should remove any unofficial Docker packages or previous versions that may be installed on the system. This prevents package conflicts and ensures a clean installation environment.

```bash
# Remove existing Docker-related packages
sudo apt-get remove docker docker-engine docker.io containerd runc

# Images, containers, and volumes in /var/lib/docker/ are preserved after removal
# For complete deletion if needed:
# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd
```

### Step 2: Install Required Packages

Install the packages required to access Docker repository over HTTPS.

```bash
# Update package list
sudo apt-get update

# Install required packages
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

The role of each package is as follows:

| Package | Role |
|---------|------|
| **apt-transport-https** | Enables APT to download packages over HTTPS |
| **ca-certificates** | CA certificate bundle for SSL certificate verification |
| **curl** | Data transfer tool via URL |
| **gnupg** | GPG key management and signature verification |
| **lsb-release** | Linux distribution information utility |

### Step 3: Add Docker's Official GPG Key

To verify the integrity and authenticity of Docker packages, you need to add Docker's official GPG key to the system. This key is used to confirm that packages are signed by Docker.

```bash
# Download and install Docker's official GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

### Step 4: Add Docker Repository

Add the repository for downloading Docker packages to the APT source list.

```bash
# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Install Docker Engine

Once the repository is added, you can install Docker Engine and related components.

```bash
# Update package list
sudo apt-get update

# Install Docker Engine, CLI, containerd, and Docker Compose plugin
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

The role of installed packages is as follows:

| Package | Role |
|---------|------|
| **docker-ce** | Docker Engine (Community Edition) |
| **docker-ce-cli** | Docker command-line interface |
| **containerd.io** | Container runtime |
| **docker-buildx-plugin** | Extended build features (multi-platform builds, etc.) |
| **docker-compose-plugin** | Docker Compose V2 plugin |

## Docker Configuration

### Running Docker as Non-root User

> **Docker Group Permissions**
>
> By default, the Docker daemon runs with root privileges, and docker commands require sudo. For security and convenience, adding the current user to the docker group allows running Docker commands without sudo.

```bash
# Add current user to docker group
sudo usermod -aG docker $USER

# Apply group change (without logout)
newgrp docker

# Or restart the system
# sudo reboot
```

### Docker Service Management

Start the Docker service and configure it to start automatically on system boot.

```bash
# Start Docker service
sudo systemctl start docker

# Enable auto-start on boot
sudo systemctl enable docker

# Check Docker service status
sudo systemctl status docker
```

Example output:

```
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-01-20 10:00:00 KST; 1min ago
       Docs: https://docs.docker.com
   Main PID: 1234 (dockerd)
      Tasks: 10
     Memory: 100.0M
        CPU: 500ms
     CGroup: /system.slice/docker.service
             └─1234 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

## Verifying Installation

### Check Docker Version

```bash
# Check Docker version
docker --version

# Detailed version information
docker version
```

Example detailed version output:

```
Client: Docker Engine - Community
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:07:41 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:07:41 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.24
  GitCommit:        61f9fd88f79f081d64d6fa3bb1a0dc71ec870523
 runc:
  Version:          1.1.9
  GitCommit:        v1.1.9-0-gccaecfc
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

### Run hello-world Container

Run the official hello-world image to verify that Docker is working correctly.

```bash
docker run hello-world
```

Example output:

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:4bd78111b6914a99dbc560e6a20eab57ff6655aea4a80c50b0c5491968cbc2e6
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

## Running Your First Container

### Running Nginx Web Server

As a practical example, let's run an Nginx web server container.

```bash
# Run Nginx container
docker run -d -p 8080:80 --name my-nginx nginx:latest
```

The description of each option in this command is as follows:

| Option | Description |
|--------|-------------|
| **-d** | Run in background (detached) mode |
| **-p 8080:80** | Map host port 8080 to container port 80 |
| **--name my-nginx** | Assign the name 'my-nginx' to the container |
| **nginx:latest** | Specify the image and tag to use |

Access `http://localhost:8080` in a web browser to see the Nginx default page.

### Check Container Status

```bash
# List running containers
docker ps

# List all containers (including stopped ones)
docker ps -a
```

Example output:

```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
a1b2c3d4e5f6   nginx:latest   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   my-nginx
```

### View Container Logs

```bash
# View container logs
docker logs my-nginx

# Stream logs in real-time (-f: follow)
docker logs -f my-nginx

# Show only last 100 lines
docker logs --tail 100 my-nginx
```

### Access Container Shell

```bash
# Run bash shell inside container
docker exec -it my-nginx bash

# Execute command inside container
docker exec my-nginx cat /etc/nginx/nginx.conf
```

## Essential Docker Commands

### Image Management Commands

```bash
# List local images
docker images

# Download (pull) image
docker pull ubuntu:22.04
docker pull python:3.11-slim

# Search for images
docker search nginx

# Delete image
docker rmi nginx:latest

# Clean up unused images
docker image prune

# Delete all unused images
docker image prune -a
```

### Container Management Commands

```bash
# Create and run container
docker run -d --name myapp nginx

# Stop container
docker stop my-nginx

# Start container
docker start my-nginx

# Restart container
docker restart my-nginx

# Delete container (stopped containers only)
docker rm my-nginx

# Force delete running container
docker rm -f my-nginx

# Delete all stopped containers
docker container prune
```

### System Information and Cleanup

```bash
# Docker system information
docker info

# Check disk usage
docker system df

# Detailed disk usage
docker system df -v

# Clean up all unused resources (images, containers, networks, cache)
docker system prune

# Clean up including volumes
docker system prune --volumes
```

## Docker Networking

> **What is Docker Networking?**
>
> Docker networking is a virtual network infrastructure that manages communication between containers. It enables implementing microservices architecture by isolating or connecting containers.

### Network Types

| Network Driver | Description | Use Case |
|----------------|-------------|----------|
| **bridge** | Default network, container communication within same host | Single-host applications |
| **host** | Direct use of host network, no isolation | Performance-critical applications |
| **none** | Network disabled | Completely isolated containers |
| **overlay** | Network across multiple Docker hosts | Docker Swarm, multi-host |
| **macvlan** | Assign MAC address to container | Legacy applications |

### Network Creation and Management

```bash
# List networks
docker network ls

# Create custom bridge network
docker network create my-network

# Create network with specified subnet
docker network create --subnet=172.20.0.0/16 my-custom-network

# Run container connected to network
docker run -d --name app --network my-network nginx

# Connect existing container to network
docker network connect my-network my-nginx

# Disconnect container from network
docker network disconnect my-network my-nginx

# Network detailed information
docker network inspect my-network

# Delete network
docker network rm my-network
```

### Container Communication Example

```bash
# Create network
docker network create app-network

# Run database container
docker run -d \
    --name mysql-db \
    --network app-network \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=myapp \
    mysql:8.0

# Run application container (same network)
docker run -d \
    --name web-app \
    --network app-network \
    -e DB_HOST=mysql-db \
    -p 8080:8080 \
    my-web-app:latest

# Containers in the same network can communicate using container names
# web-app container can connect to mysql-db:3306
```

## Docker Volumes

> **What is Docker Volume?**
>
> Docker volumes are a mechanism for persistently storing container data. Data is preserved even when containers are deleted, and data can be shared between multiple containers.

### Data Storage Method Comparison

| Storage Method | Description | Use Case |
|----------------|-------------|----------|
| **Volume** | Storage managed by Docker | Production databases, persistent data |
| **Bind mount** | Mount specific path from host file system | Development environment, config files |
| **tmpfs mount** | Store in memory only (Linux) | Sensitive temporary data |

### Volume Creation and Management

```bash
# List volumes
docker volume ls

# Create volume
docker volume create my-data

# Volume detailed information
docker volume inspect my-data

# Run container using volume
docker run -d \
    --name postgres-db \
    -v my-data:/var/lib/postgresql/data \
    -e POSTGRES_PASSWORD=secret \
    postgres:15

# Use bind mount (connect host directory)
docker run -d \
    --name dev-nginx \
    -v $(pwd)/html:/usr/share/nginx/html:ro \
    -p 8080:80 \
    nginx

# Delete volume
docker volume rm my-data

# Clean up unused volumes
docker volume prune
```

### Database Data Persistence Example

```bash
# Store PostgreSQL data in volume
docker volume create postgres-data

docker run -d \
    --name postgres \
    -v postgres-data:/var/lib/postgresql/data \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_DB=myapp \
    -p 5432:5432 \
    postgres:15

# Data is preserved even when container is deleted
docker rm -f postgres

# Running new container with same volume restores data
docker run -d \
    --name postgres-new \
    -v postgres-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:15
```

## Troubleshooting

### Docker Daemon Issues

```bash
# Check Docker service status
sudo systemctl status docker

# View Docker daemon logs
sudo journalctl -u docker.service -f

# Restart Docker daemon
sudo systemctl restart docker
```

### Permission Issues

```bash
# When "permission denied" error occurs
# 1. Verify user is in docker group
groups $USER

# 2. Add to group if not present
sudo usermod -aG docker $USER

# 3. Re-login or run newgrp
newgrp docker
```

### Disk Space Shortage

```bash
# Check Docker disk usage
docker system df

# Clean up unused resources
docker system prune -a --volumes

# Delete specific images
docker rmi $(docker images -q -f "dangling=true")

# Delete all stopped containers
docker rm $(docker ps -a -q -f "status=exited")
```

### Network Issues

```bash
# Check network status
docker network ls
docker network inspect bridge

# Check container IP
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-nginx

# Test DNS resolution
docker run --rm alpine nslookup google.com
```

## Next Steps

After learning Docker basic installation and usage, studying the following topics will help you utilize container technology more effectively.

| Next Step | Description |
|-----------|-------------|
| **Writing Dockerfile** | How to build custom images |
| **Docker Compose** | Managing multi-container applications |
| **Docker Image Optimization** | Reducing image size, build caching |
| **Docker Security** | Security best practices, vulnerability scanning |
| **Kubernetes** | Container orchestration platform |

## Conclusion

Docker installation is the first step to getting started with container technology, and installation through the official repository is the most stable way to maintain the latest version. Learning basic container execution, image management, and network and volume configuration enables effective construction of complex microservices architectures.

Docker has become an essential technology in modern software development as a powerful tool that ensures development environment consistency, simplifies deployment processes, and improves resource efficiency.
