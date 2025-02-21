---
title: "Streamlining Development Environment Setup with Docker Compose"
date: 2025-02-17T22:49:32+09:00
tags:
    [
        "Docker Compose",
        "Development Environment",
        "Infrastructure",
        "Environment Setup",
    ]
description: "A comprehensive guide to efficiently setting up complex development environments using Docker Compose."
draft: false
---

## The Challenge of Development Environment Setup

Building web applications requires various infrastructure components like databases, cache servers, and message queues. Setting up and configuring each of these components can be time-consuming and tedious. This process becomes particularly challenging when onboarding new team members, as they need to replicate the entire setup process.

## Why Docker Compose?

Docker Compose addresses these challenges by providing a powerful orchestration tool. With a single YAML file, you can define and manage multiple containers, launching your entire development environment with just one command. By including this configuration in your version control system, you ensure that every team member can reproduce the exact same environment effortlessly.

## Basic Configuration File

Here's a simple docker-compose.yml file to get you started:

```yaml
version: "3.8"

services:
    web:
        build: .
        ports:
            - "3000:3000"

    db:
        image: mysql:8.0
        environment:
            MYSQL_ROOT_PASSWORD: secret
```

## Production-Ready Development Environments

### Node.js + MySQL + Redis Stack

```yaml
version: "3.8"

services:
    app:
        build:
            context: .
            dockerfile: Dockerfile
        volumes:
            - .:/app
            - /app/node_modules
        ports:
            - "3000:3000"
        environment:
            - NODE_ENV=development
            - DB_HOST=db
            - REDIS_HOST=redis
        depends_on:
            - db
            - redis

    db:
        image: mysql:8.0
        volumes:
            - mysql_data:/var/lib/mysql
        environment:
            MYSQL_ROOT_PASSWORD: secret
            MYSQL_DATABASE: myapp
        ports:
            - "3306:3306"

    redis:
        image: redis:alpine
        ports:
            - "6379:6379"

volumes:
    mysql_data:
```

### React + Spring Boot + PostgreSQL Stack

```yaml
version: "3.8"

services:
    frontend:
        build:
            context: ./frontend
            dockerfile: Dockerfile
        volumes:
            - ./frontend:/app
            - /app/node_modules
        ports:
            - "3000:3000"
        environment:
            - REACT_APP_API_URL=http://localhost:8080

    backend:
        build:
            context: ./backend
            dockerfile: Dockerfile
        volumes:
            - ./backend:/app
        ports:
            - "8080:8080"
        environment:
            - SPRING_PROFILES_ACTIVE=dev
            - DB_URL=jdbc:postgresql://db:5432/myapp
        depends_on:
            - db

    db:
        image: postgres:13
        volumes:
            - postgres_data:/var/lib/postgresql/data
        environment:
            POSTGRES_DB: myapp
            POSTGRES_USER: user
            POSTGRES_PASSWORD: secret
        ports:
            - "5432:5432"

volumes:
    postgres_data:
```

## Advanced Configuration Options

### Volume Mounts for Development

Enable real-time code updates with proper volume configuration:

```yaml
volumes:
    - .:/app # Mount source code
    - /app/node_modules # Preserve container node_modules
```

### Environment Variable Management

Securely manage sensitive information using environment files:

```yaml
services:
    web:
        env_file:
            - .env.development
```

### Network Configuration

Implement service isolation and communication through networks:

```yaml
services:
    web:
        networks:
            - frontend
            - backend

    db:
        networks:
            - backend

networks:
    frontend:
    backend:
```

## Development Workflow Features

### Logging Configuration

Implement robust logging for better debugging:

```yaml
services:
    web:
        logging:
            driver: "json-file"
            options:
                max-size: "10m"
                max-file: "3"
```

### Health Monitoring

Ensure service reliability with health checks:

```yaml
services:
    web:
        healthcheck:
            test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
            interval: 30s
            timeout: 10s
            retries: 3
```

## Essential Commands

Here are the most frequently used Docker Compose commands:

```bash
# Launch services in detached mode
docker-compose up -d

# Stop and remove containers
docker-compose down

# Monitor service logs
docker-compose logs -f

# Restart services
docker-compose restart

# View container status
docker-compose ps
```

## Common Issues and Solutions

### Volume Permission Management

Handle file permission issues effectively:

```yaml
services:
    app:
        user: "1000:1000" # Match host user's UID:GID
```

### Resource Management

Control container resource usage:

```yaml
services:
    app:
        deploy:
            resources:
                limits:
                    memory: 512M
```

### Network Access Control

Manage service accessibility:

```yaml
services:
    web:
        ports:
            - "127.0.0.1:3000:3000" # Restrict to localhost
```

## Production Deployment Considerations

1. Environment-Specific Configurations

Maintain separate configurations for different environments:

```bash
docker-compose.yml          # Base configuration
docker-compose.dev.yml      # Development settings
docker-compose.prod.yml     # Production settings
```

2. Security Best Practices

Implement security measures:

```yaml
services:
    web:
        security_opt:
            - no-new-privileges:true
```

## Conclusion

Docker Compose streamlines the development environment setup process. By managing all services in a single file and incorporating it into version control, teams can ensure consistent development environments across all members. This approach significantly reduces onboarding time and eliminates environment-related issues, allowing developers to focus on what matters most: writing code.
