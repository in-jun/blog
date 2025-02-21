---
title: "The Secrets to Slash Docker Image Size by 10x"
date: 2025-02-17T22:39:45+09:00
tags: ["Docker", "Optimization", "Image", "Size", "Multistage"]
description: "Explores practical optimization techniques to effectively reduce the size of Docker images with real-world examples."
draft: false
---

## Before Optimization

A typical Dockerfile for a Node.js application looks like this:

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

This image ends up being over 1GB in size. The main reasons for this are:

1. Heavy base image
2. Development tools included
3. Presence of unnecessary files
4. Accumulation of cache files

## Optimization Techniques

### 1. Implement Multi-Stage Builds

Separate the build and runtime stages.

```dockerfile
# Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm install --production
CMD ["npm", "start"]
```

### 2. Use Alpine Linux

Alpine Linux significantly reduces the base image size.

```dockerfile
# Bad example: node:18 (~1GB)
FROM node:18

# Good example: node:18-alpine (~120MB)
FROM node:18-alpine
```

### 3. Include Production Dependencies Only

Exclude development dependencies.

```dockerfile
# Bad example
RUN npm install

# Good example
RUN npm ci --only=production
```

### 4. Remove Unnecessary Files

Use a .dockerignore file.

```
node_modules
.git
.vscode
*.log
tests
docs
```

### 5. Optimize Layers

Combine commands to reduce the number of layers.

```dockerfile
# Bad example
RUN apk update
RUN apk add python3
RUN rm -rf /var/cache/apk/*

# Good example
RUN apk update && 
    apk add python3 && 
    rm -rf /var/cache/apk/*
```

## Real-World Use Cases

### Node.js Web Application

Before optimization:

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

Image size: 1.2GB

After optimization:

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY package*.json ./
RUN npm ci --only=production && 
    npm cache clean --force
CMD ["npm", "start"]
```

Image size: 120MB

### Go Application

Before optimization:

```dockerfile
FROM golang:1.16
WORKDIR /app
COPY . .
RUN go build -o main .
CMD ["./main"]
```

Image size: 850MB

After optimization:

```dockerfile
FROM golang:1.16-alpine AS builder
WORKDIR /app
COPY go.* ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM scratch
COPY --from=builder /app/main .
CMD ["./main"]
```

Image size: 15MB

### Python Web Application

Before optimization:

```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

Image size: 900MB

After optimization:

```dockerfile
FROM python:3.9-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN apk add --no-cache gcc musl-dev && 
    pip install --user -r requirements.txt

FROM python:3.9-alpine
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

Image size: 100MB

## Performance Impact

Reducing image size provides the following benefits:

1. Faster deployment times
2. Network bandwidth savings
3. Reduced container startup times
4. Lower storage costs
5. Decreased security vulnerabilities

Image optimization is an ongoing process. With each new release, optimization techniques should be applied and results measured. This leads to reduced operational costs and improved system performance.
