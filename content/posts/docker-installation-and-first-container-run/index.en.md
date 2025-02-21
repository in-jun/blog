---
title: "From Docker Installation to Running the First Container"
date: 2025-02-17T22:37:02+09:00
tags: ["Docker", "Installation", "Container", "Getting Started", "Ubuntu"]
description: "This guide will walk you through the step-by-step process of installing Docker and running your first container in a Linux environment."
draft: false
---

## Preparing the Operating System

Docker runs most reliably on a Linux operating system. This guide is intended for Ubuntu 20.04 LTS.

## Installing Docker

### Removing Existing Packages

If you have a previous version of Docker installed on your system, remove it:

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

### Installing Prerequisites

Install the packages required for Docker installation:

```bash
sudo apt-get update
sudo apt-get install 
    apt-transport-https 
    ca-certificates 
    curl 
    gnupg 
    lsb-release
```

### Adding Docker's Official GPG Key

Add the GPG key to use Docker's package repository:

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### Adding Docker Repository

Register Docker's package repository with your system:

```bash
echo 
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu 
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Installing Docker Engine

Install Docker Engine and its dependencies:

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

## Configuring Docker

### Setting User Permissions

Configure your user to run Docker commands without sudo:

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### Starting the Docker Service

Start the Docker service and configure it to start automatically on system boot:

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## Verifying Installation

Verify that Docker is installed correctly:

```bash
docker --version
docker run hello-world
```

## Running Your First Container

### Running an Nginx Web Server

Run an Nginx web server container:

```bash
docker run -d -p 80:80 --name webserver nginx
```

Here's what this command does:

1. -d: Runs the container in the background
2. -p 80:80: Maps port 80 on the host to port 80 in the container
3. --name webserver: Specifies a name for the container
4. nginx: The name of the image to use

### Checking Container Status

Check the list of running containers:

```bash
docker ps
```

### Viewing Container Logs

View the logs of a container:

```bash
docker logs webserver
```

### Entering a Container

Enter a running container:

```bash
docker exec -it webserver bash
```

## Basic Docker Commands

### Image Management

```bash
# List images
docker images

# Pull an image
docker pull ubuntu:20.04

# Remove an image
docker rmi nginx
```

### Container Management

```bash
# Stop a container
docker stop webserver

# Start a container
docker start webserver

# Restart a container
docker restart webserver

# Remove a container
docker rm webserver
```

## Docker Networking

### Creating a Network

Create a network for containers to communicate with each other:

```bash
docker network create mynetwork
```

### Connecting a Container to a Network

Connect a container to the created network:

```bash
docker run -d --name db --network mynetwork mysql
```

## Docker Volumes

### Creating a Volume

Create a volume for persistent data storage:

```bash
docker volume create mydata
```

### Mounting a Volume

Mount the volume to a container:

```bash
docker run -d 
  --name db 
  -v mydata:/var/lib/mysql 
  mysql
```

## Troubleshooting

1. If the Docker daemon fails to start:

```bash
sudo systemctl status docker
sudo journalctl -u docker
```

2. If you encounter permission issues:

```bash
sudo chown $USER:$USER /var/run/docker.sock
```

3. If you run out of disk space:

```bash
docker system prune -a
```

Docker is a great way to get started with container technology. With just the basic installation and configuration, you can experience the benefits of containers. Later, you can progress to more advanced container environments with Docker Compose, Docker Swarm, and Kubernetes.
