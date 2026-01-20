---
title: "How to Reduce Docker Image Size by 10x: Practical Optimization Guide"
date: 2025-02-17T22:39:45+09:00
tags: ["Docker", "Optimization", "Image", "Container", "Multistage", "DevOps"]
description: "A complete guide to reducing Docker image size by 10x or more, covering analysis of image size increase causes, multi-stage builds, Alpine Linux, distroless images, layer optimization, and language-specific optimization techniques"
draft: false
---

Docker image optimization is a core technology that directly impacts build time reduction, deployment speed improvement, storage cost savings, and security vulnerability reduction for container-based applications. By applying techniques such as appropriate base image selection, multi-stage builds, and layer optimization, you can reduce image size by 10x or more, which also significantly affects CI/CD pipeline efficiency and cloud infrastructure costs.

## Understanding Docker Image Size Problems

> **Why is Image Size Important?**
>
> Docker image size directly affects build time, push/pull time, container startup time, storage costs, and security attack surface. Image optimization is essential for efficient operations in production environments.

### Main Causes of Image Size Increase

Typically, unoptimized Docker images become bloated for the following reasons. Understanding each cause is necessary to establish appropriate optimization strategies.

| Cause | Description | Impact |
|-------|-------------|--------|
| **Heavy base image** | Using debian, ubuntu, etc. with full OS packages | Adds hundreds of MB ~ 1GB |
| **Development tools included** | Compilers, build tools unnecessarily included at runtime | Adds hundreds of MB |
| **Development dependencies included** | devDependencies, test libraries included | Adds tens to hundreds of MB |
| **Unnecessary files copied** | .git, node_modules, test files copied | Adds tens of MB ~ several GB |
| **Layer inefficiency** | Temporary files created in each RUN command not deleted | Accumulates per layer |
| **Cache files accumulated** | apt, pip, npm caches included in image | Adds tens to hundreds of MB |

### Analyzing Images Before Optimization

Before starting optimization, you need to analyze the current image size and layer composition.

```bash
# Check image size
docker images myapp:latest

# Analyze size by layer
docker history myapp:latest

# Detailed analysis with dive tool
dive myapp:latest
```

Here is an example of a typical Node.js application Dockerfile before optimization.

```dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
```

Images built with this Dockerfile reach approximately 1.2GB ~ 1.5GB because node_modules and build artifacts are added on top of the node:20 base image (approximately 1GB).

## Base Image Optimization

> **Importance of Base Image Selection**
>
> The base image accounts for the largest portion of final image size. Selecting the minimal base image that meets application requirements is the first step in optimization.

### Comparison by Base Image Type

| Image Type | Size Range | Features | Suitable Use Cases |
|------------|------------|----------|-------------------|
| **Regular images** (debian, ubuntu) | 100MB ~ 1GB | Full package manager, shell, debugging tools | Development environment, debugging needed |
| **slim images** (node:slim, python:slim) | 50MB ~ 200MB | Essential runtime only, some tools removed | General production environment |
| **Alpine images** (node:alpine, python:alpine) | 5MB ~ 50MB | musl libc based, minimal packages | Size optimization critical |
| **distroless images** (gcr.io/distroless) | 2MB ~ 20MB | No shell, application runtime only | Security-critical production |
| **scratch** | 0MB | Completely empty image | Static binaries (Go, Rust) |

### Alpine Linux Based Images

Alpine Linux is a lightweight Linux distribution based on musl libc and BusyBox. With a base image size of only about 5MB, it is widely used for Docker image optimization.

```dockerfile
# Before: ~1GB
FROM node:20

# After: ~180MB
FROM node:20-alpine
```

When using Alpine images, note that it uses musl libc instead of glibc, which may cause compatibility issues with some native modules. In such cases, additional package installation may be required during build.

```dockerfile
FROM node:20-alpine

# Install packages for native module builds
RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```

### distroless Images

Google's distroless images are minimal images containing only the application runtime without a shell or package manager. They reduce the attack surface to enhance security and minimize image size.

```dockerfile
# Build stage
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Runtime stage - using distroless
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["dist/index.js"]
```

## Multi-Stage Builds

> **What is Multi-Stage Build?**
>
> Multi-stage build is a technique that uses multiple FROM instructions in a single Dockerfile to separate build and runtime environments. By excluding build tools and intermediate artifacts from the final image, it dramatically reduces image size.

### Multi-Stage Build Principles

Multi-stage build is a feature introduced in Docker 17.05 that operates in the following stages:

1. **Build stage**: Performs build tasks such as source code compilation, dependency installation, and test execution
2. **Runtime stage**: Creates final image by copying only artifacts generated from build stage
3. **Layer separation**: Each stage has independent layers, and only the last stage's layers are included in the final image

### Node.js Application Optimization

Here is a multi-stage build example for Node.js applications.

**Before optimization (~1.2GB):**

```dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
```

**After optimization (~150MB):**

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

# Copy dependency files first (cache utilization)
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code and build
COPY . .
RUN npm run build

# Reinstall production dependencies only
RUN rm -rf node_modules && npm ci --only=production

# ===== Runtime Stage =====
FROM node:20-alpine

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app

# Copy only build artifacts and production dependencies
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

# Switch to non-root user
USER nextjs

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Go Application Optimization

Go can generate static binaries, allowing the smallest images when using scratch image.

**Before optimization (~800MB):**

```dockerfile
FROM golang:1.22
WORKDIR /app
COPY . .
RUN go build -o main .
CMD ["./main"]
```

**After optimization (~10MB):**

```dockerfile
# ===== Build Stage =====
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code and build static binary
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o main .

# ===== Runtime Stage =====
FROM scratch

# Copy SSL certificates (needed for HTTPS requests)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy only the binary
COPY --from=builder /app/main /main

EXPOSE 8080
ENTRYPOINT ["/main"]
```

The `-ldflags="-w -s"` option removes debug information and symbol table to further reduce binary size.

### Python Application Optimization

Python applications can be optimized using virtual environments.

**Before optimization (~900MB):**

```dockerfile
FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

**After optimization (~120MB):**

```dockerfile
# ===== Build Stage =====
FROM python:3.12-alpine AS builder

WORKDIR /app

# Install build tools (for native extension modules)
RUN apk add --no-cache gcc musl-dev libffi-dev

# Create virtual environment and install dependencies
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ===== Runtime Stage =====
FROM python:3.12-alpine

# Install only runtime libraries
RUN apk add --no-cache libffi

WORKDIR /app

# Copy virtual environment
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy source code
COPY . .

# Create and switch to non-root user
RUN adduser -D appuser
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
```

### Java Application Optimization

Java applications can use runtime images containing only JRE, and additional optimization is possible by creating custom JRE with jlink.

**Before optimization (~700MB):**

```dockerfile
FROM maven:3.9-eclipse-temurin-21
WORKDIR /app
COPY . .
RUN mvn package -DskipTests
CMD ["java", "-jar", "target/app.jar"]
```

**After optimization (~150MB):**

```dockerfile
# ===== Build Stage =====
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# ===== Runtime Stage =====
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy only JAR file
COPY --from=builder /app/target/*.jar app.jar

# Create and switch to non-root user
RUN adduser -D appuser
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## Layer Optimization

> **Layer Optimization Principles**
>
> Each instruction (RUN, COPY, ADD) in a Dockerfile creates a new layer. Files added to a layer are not removed from image size even if deleted in later layers, so unnecessary files must be deleted within the same layer.

### Command Consolidation

Connect multiple RUN instructions with `&&` and delete temporary files in the same layer.

**Inefficient approach:**

```dockerfile
RUN apt-get update
RUN apt-get install -y nginx curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
```

**Optimized approach:**

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### Using .dockerignore

Using a `.dockerignore` file excludes unnecessary files from the build context, improving build speed and image size.

```
# Version control
.git
.gitignore

# Dependencies (reinstalled during build)
node_modules
vendor
__pycache__

# Development environment
.env.local
.env.development
*.log
.vscode
.idea

# Tests
tests
test
coverage
.nyc_output

# Documentation
docs
README.md
CHANGELOG.md

# Build artifacts (regenerated in multi-stage)
dist
build
target
```

### Cache Cleanup

Delete package manager caches in the same layer.

```dockerfile
# apt (Debian/Ubuntu)
RUN apt-get update && \
    apt-get install -y --no-install-recommends package && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# apk (Alpine)
RUN apk add --no-cache package

# pip (Python)
RUN pip install --no-cache-dir -r requirements.txt

# npm (Node.js)
RUN npm ci --only=production && \
    npm cache clean --force
```

## Optimization Results Comparison

Comparing results after applying various languages and optimization techniques:

| Language | Before | After | Reduction | Key Techniques |
|----------|--------|-------|-----------|----------------|
| **Node.js** | 1.2GB | 150MB | 87% | Alpine + multi-stage |
| **Go** | 800MB | 10MB | 99% | scratch + static build |
| **Python** | 900MB | 120MB | 87% | Alpine + virtual env |
| **Java** | 700MB | 150MB | 79% | JRE-alpine + multi-stage |
| **Rust** | 1.5GB | 8MB | 99% | scratch + static build |

## Benefits of Optimization

Docker image size optimization provides the following practical benefits:

| Benefit | Description |
|---------|-------------|
| **Reduced build time** | CI/CD pipeline speed improvement with smaller base images and efficient layer caching |
| **Improved deployment speed** | Deployment cycle improvement by reducing image push/pull time |
| **Storage cost savings** | Reduced storage usage on container registries and nodes |
| **Enhanced security** | Reduced attack surface and CVE vulnerabilities by removing unnecessary packages |
| **Faster container startup** | Improved scale-out speed by reducing image pull time |
| **Network bandwidth savings** | Especially effective in edge environments or bandwidth-limited environments |

## Conclusion

Docker image optimization can reduce image size by 10x or more by combining techniques such as appropriate base image selection, multi-stage builds, layer optimization, and cache cleanup. This leads to reduced build time, improved deployment speed, storage cost savings, and enhanced security. Since optimal strategies differ by language and framework, it is important to select optimization techniques appropriate for application characteristics and continuously monitor and improve image size.
