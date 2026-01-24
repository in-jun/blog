---
title: "Multi-Container Development with Docker Compose"
date: 2025-02-17T22:49:32+09:00
tags: ["Docker", "Container", "DevOps"]
description: "Multi-container development environment configuration with Docker Compose."
draft: false
---

Docker Compose is a tool for defining and running multi-container Docker applications that uses YAML files to configure application services, allows you to create and start all services with a single command, ensures consistency between development and production environments, and simplifies the management of complex multi-container architectures.

## Docker Compose Overview

> **What is Docker Compose?**
>
> Docker Compose is a tool for defining, running, and managing applications composed of multiple containers. It allows you to declaratively define services, networks, and volumes in a docker-compose.yml file and manage the entire application stack with a single command.

### History of Docker Compose

| Year | Event | Description |
|------|-------|-------------|
| **2013** | Fig project started | Orchard team begins developing Fig, a Docker container orchestration tool |
| **2014** | Docker acquires Fig | Docker acquires Orchard and rebrands Fig as Docker Compose |
| **2015** | Compose v1 stabilized | Docker Compose is integrated as an official Docker tool |
| **2020** | Compose Specification | Docker Compose specification is released as an open standard |
| **2021** | Compose v2 released | Compose v2, rewritten in Go, is integrated as a Docker CLI plugin |
| **2023** | Compose v2 becomes default | docker-compose command is replaced by docker compose as the default tool |

### Why Docker Compose is Necessary

Modern web applications are rarely composed of a single container. Typically, multiple services such as web servers, application servers, databases, caches, and message queues work together. Managing such multi-container environments with individual docker run commands causes the following problems.

| Problem | Description |
|---------|-------------|
| **Command complexity** | Long docker run commands must be executed for each container |
| **Startup order management** | Service startup order based on dependencies must be managed manually |
| **Network configuration** | Networks for inter-container communication must be created and connected manually |
| **Environment reproducibility** | Difficult to reproduce the same environment on different machines |
| **Lack of documentation** | Infrastructure configuration is not explicitly documented |

Docker Compose solves these problems by allowing you to define and manage the entire application stack through declarative configuration files.

## docker-compose.yml File Structure

> **YAML File Structure**
>
> The docker-compose.yml file consists of top-level keys such as version, services, networks, volumes, configs, and secrets, with detailed settings for each resource defined under each key.

### Basic File Structure

```yaml
# Compose file version (optional, can be omitted in Compose v2)
version: "3.8"

# Service definitions (required)
services:
  web:
    image: nginx:latest
    ports:
      - "80:80"

  api:
    build: ./api
    ports:
      - "8080:8080"
    depends_on:
      - db

  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: secret

# Network definitions (optional)
networks:
  frontend:
  backend:

# Volume definitions (optional)
volumes:
  db-data:

# Secret definitions (optional)
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### Main Service Options

| Option | Description | Example |
|--------|-------------|---------|
| **image** | Specify the image to use | `image: nginx:latest` |
| **build** | Specify Dockerfile path | `build: ./app` |
| **ports** | Port mapping | `ports: ["8080:80"]` |
| **volumes** | Volume mounts | `volumes: ["./data:/data"]` |
| **environment** | Environment variable settings | `environment: ["NODE_ENV=prod"]` |
| **env_file** | Environment variable file | `env_file: .env` |
| **depends_on** | Service dependencies | `depends_on: ["db", "redis"]` |
| **networks** | Networks to connect | `networks: ["backend"]` |
| **restart** | Restart policy | `restart: always` |
| **command** | Override start command | `command: npm start` |
| **healthcheck** | Health check settings | See example below |

## Practical Development Environment Setup

### Node.js + Express + MySQL + Redis Stack

This is a complete development environment configuration example for a full-stack JavaScript application.

```yaml
version: "3.8"

services:
  # Node.js application
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: node-app
    volumes:
      - .:/app                    # Source code mount
      - /app/node_modules         # Preserve node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DB_HOST=mysql
      - DB_PORT=3306
      - DB_USER=root
      - DB_PASSWORD=secret
      - DB_NAME=myapp
      - REDIS_HOST=redis
      - REDIS_PORT=6379
    depends_on:
      mysql:
        condition: service_healthy
      redis:
        condition: service_started
    networks:
      - app-network
    command: npm run dev

  # MySQL database
  mysql:
    image: mysql:8.0
    container_name: mysql-db
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # Initialization script
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: myapp
    ports:
      - "3306:3306"
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # Redis cache
  redis:
    image: redis:7-alpine
    container_name: redis-cache
    volumes:
      - redis-data:/data
    ports:
      - "6379:6379"
    command: redis-server --appendonly yes
    networks:
      - app-network

  # Adminer (database management UI)
  adminer:
    image: adminer:latest
    container_name: adminer
    ports:
      - "8080:8080"
    depends_on:
      - mysql
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  mysql-data:
  redis-data:
```

### React + Spring Boot + PostgreSQL Stack

This is a full-stack application configuration example with separated frontend and backend.

```yaml
version: "3.8"

services:
  # React frontend
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    container_name: react-app
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - REACT_APP_API_URL=http://localhost:8080/api
      - CHOKIDAR_USEPOLLING=true  # Enable file change detection
    depends_on:
      - backend
    networks:
      - frontend-network

  # Spring Boot backend
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.dev
    container_name: spring-app
    volumes:
      - ./backend:/app
      - maven-cache:/root/.m2
    ports:
      - "8080:8080"
      - "5005:5005"  # Debug port
    environment:
      - SPRING_PROFILES_ACTIVE=dev
      - SPRING_DATASOURCE_URL=jdbc:postgresql://postgres:5432/myapp
      - SPRING_DATASOURCE_USERNAME=postgres
      - SPRING_DATASOURCE_PASSWORD=secret
      - JAVA_TOOL_OPTIONS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5005
    depends_on:
      postgres:
        condition: service_healthy
    networks:
      - frontend-network
      - backend-network

  # PostgreSQL database
  postgres:
    image: postgres:15-alpine
    container_name: postgres-db
    volumes:
      - postgres-data:/var/lib/postgresql/data
      - ./init-scripts:/docker-entrypoint-initdb.d
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: secret
    ports:
      - "5432:5432"
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - backend-network

  # pgAdmin (PostgreSQL management UI)
  pgadmin:
    image: dpage/pgadmin4:latest
    container_name: pgadmin
    environment:
      PGADMIN_DEFAULT_EMAIL: admin@admin.com
      PGADMIN_DEFAULT_PASSWORD: admin
    ports:
      - "5050:80"
    depends_on:
      - postgres
    networks:
      - backend-network

networks:
  frontend-network:
    driver: bridge
  backend-network:
    driver: bridge

volumes:
  postgres-data:
  maven-cache:
```

### Django + Celery + RabbitMQ + PostgreSQL Stack

This is a Python web application configuration example that requires asynchronous task processing.

```yaml
version: "3.8"

services:
  # Django web application
  web:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: django-web
    volumes:
      - .:/app
      - static-data:/app/staticfiles
    ports:
      - "8000:8000"
    environment:
      - DEBUG=1
      - DATABASE_URL=postgres://postgres:secret@postgres:5432/myapp
      - CELERY_BROKER_URL=amqp://guest:guest@rabbitmq:5672//
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      postgres:
        condition: service_healthy
      rabbitmq:
        condition: service_healthy
      redis:
        condition: service_started
    command: python manage.py runserver 0.0.0.0:8000
    networks:
      - app-network

  # Celery Worker
  celery-worker:
    build: .
    container_name: celery-worker
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=postgres://postgres:secret@postgres:5432/myapp
      - CELERY_BROKER_URL=amqp://guest:guest@rabbitmq:5672//
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - web
      - rabbitmq
    command: celery -A myapp worker -l info
    networks:
      - app-network

  # Celery Beat (scheduler)
  celery-beat:
    build: .
    container_name: celery-beat
    volumes:
      - .:/app
    environment:
      - DATABASE_URL=postgres://postgres:secret@postgres:5432/myapp
      - CELERY_BROKER_URL=amqp://guest:guest@rabbitmq:5672//
    depends_on:
      - web
      - rabbitmq
    command: celery -A myapp beat -l info
    networks:
      - app-network

  # Flower (Celery monitoring)
  flower:
    build: .
    container_name: flower
    ports:
      - "5555:5555"
    environment:
      - CELERY_BROKER_URL=amqp://guest:guest@rabbitmq:5672//
    depends_on:
      - celery-worker
    command: celery -A myapp flower
    networks:
      - app-network

  # PostgreSQL
  postgres:
    image: postgres:15-alpine
    container_name: postgres
    volumes:
      - postgres-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: secret
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # RabbitMQ (message broker)
  rabbitmq:
    image: rabbitmq:3-management-alpine
    container_name: rabbitmq
    ports:
      - "5672:5672"
      - "15672:15672"  # Management UI
    healthcheck:
      test: ["CMD", "rabbitmq-diagnostics", "check_running"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - app-network

  # Redis (result backend)
  redis:
    image: redis:7-alpine
    container_name: redis
    networks:
      - app-network

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:
  static-data:
```

## Advanced Configuration

### Environment-Specific Configuration File Separation

> **Environment-Specific Compose Files**
>
> Docker Compose can combine multiple files, and by applying environment-specific override files on top of a base configuration file, you can manage differences between development, staging, and production environments.

**Base configuration (docker-compose.yml):**

```yaml
version: "3.8"

services:
  web:
    build: .
    environment:
      - DATABASE_URL=postgres://db:5432/myapp
    depends_on:
      - db

  db:
    image: postgres:15
    volumes:
      - db-data:/var/lib/postgresql/data

volumes:
  db-data:
```

**Development environment override (docker-compose.dev.yml):**

```yaml
version: "3.8"

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    volumes:
      - .:/app
    ports:
      - "3000:3000"
      - "9229:9229"  # Debugging port
    environment:
      - NODE_ENV=development
      - DEBUG=true

  db:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: devpassword
```

**Production environment override (docker-compose.prod.yml):**

```yaml
version: "3.8"

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.prod
    restart: always
    environment:
      - NODE_ENV=production
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: "0.5"
          memory: 512M

  db:
    restart: always
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

secrets:
  db_password:
    external: true
```

**Running for each environment:**

```bash
# Development environment
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# Production environment
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### Health Check Configuration

Health checks periodically verify service status to detect unhealthy containers. When used with the condition option of depends_on, they enable safe dependency management between services.

```yaml
services:
  web:
    image: nginx
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s      # Check interval
      timeout: 10s       # Timeout
      retries: 3         # Number of retries on failure
      start_period: 40s  # Wait time after startup

  api:
    build: .
    depends_on:
      web:
        condition: service_healthy
      db:
        condition: service_healthy
```

### Resource Limits

In production environments, you should limit container resource usage to ensure system stability.

```yaml
services:
  web:
    image: nginx
    deploy:
      resources:
        limits:
          cpus: "0.5"      # CPU 50% limit
          memory: 256M     # Memory 256MB limit
        reservations:
          cpus: "0.25"     # Minimum CPU 25% guaranteed
          memory: 128M     # Minimum memory 128MB guaranteed
```

### Logging Configuration

This is a configuration for effectively managing container logs.

```yaml
services:
  web:
    image: nginx
    logging:
      driver: "json-file"
      options:
        max-size: "10m"    # Maximum log file size
        max-file: "3"      # Number of log files to retain
        labels: "production"
        env: "os,customer"
```

## Docker Compose Commands

### Basic Commands

| Command | Description |
|---------|-------------|
| `docker compose up` | Create and start services |
| `docker compose up -d` | Start services in background |
| `docker compose up --build` | Rebuild images and start |
| `docker compose down` | Stop services and remove containers |
| `docker compose down -v` | Remove volumes as well |
| `docker compose start` | Start stopped services |
| `docker compose stop` | Stop services (keep containers) |
| `docker compose restart` | Restart services |

### Monitoring and Debugging Commands

| Command | Description |
|---------|-------------|
| `docker compose ps` | Check service status |
| `docker compose logs` | View all service logs |
| `docker compose logs -f web` | View specific service logs in real-time |
| `docker compose top` | View running processes |
| `docker compose exec web bash` | Access container shell |
| `docker compose run web npm test` | Run one-time command |

### Build and Image Management Commands

| Command | Description |
|---------|-------------|
| `docker compose build` | Build service images |
| `docker compose build --no-cache` | Build without cache |
| `docker compose pull` | Download service images |
| `docker compose push` | Push service images |
| `docker compose images` | List service images |

### Practical Usage Examples

```bash
# Start development environment
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# Rebuild only specific service
docker compose build --no-cache web

# View logs (last 100 lines, real-time)
docker compose logs -f --tail=100

# Access database
docker compose exec db psql -U postgres -d myapp

# Scale adjustment
docker compose up -d --scale web=3

# Clean up environment (including volumes)
docker compose down -v --remove-orphans
```

## Troubleshooting

### Common Problems and Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| **Port conflict** | Port already in use on host | Change port number or terminate conflicting process |
| **Volume permission error** | User ID mismatch between container and host | Add `user: "1000:1000"` setting |
| **Service startup failure** | Dependent service not ready yet | Use healthcheck with condition |
| **Network connection failure** | Incorrect network configuration | Verify network names and connections |
| **Image build failure** | Dockerfile error or context issue | Check build logs and fix Dockerfile |

### Debugging Commands

```bash
# Check detailed container information
docker compose ps -a

# Validate service configuration
docker compose config

# Check event logs
docker compose events

# Check networks
docker network ls
docker network inspect <network_name>

# Check volumes
docker volume ls
docker volume inspect <volume_name>
```

### Performance Optimization Tips

```yaml
# Build cache optimization
services:
  web:
    build:
      context: .
      cache_from:
        - myapp:latest

# Remove unnecessary layers
services:
  web:
    build:
      target: production  # Specify multi-stage build target
```

## Conclusion

Docker Compose is a powerful tool that allows you to declaratively define and manage complex multi-container applications. By codifying the entire development environment in a single YAML file, you can include it in your version control system, enabling the entire team to work in the same environment.

By leveraging various Docker Compose features such as environment-specific configuration file separation, safe service startup through health checks, and inter-service communication and data persistence management through networks and volumes, you can significantly improve development productivity.
