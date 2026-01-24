---
title: "Writing Dockerfile for React Applications"
date: 2025-02-17T21:56:12+09:00
tags: ["React", "Docker", "DevOps"]
description: "Writing and optimizing Dockerfiles for React applications."
draft: false
---

Packaging React applications as Docker containers maintains consistency between development and production environments, facilitates integration with CI/CD pipelines, enables using the same image across various deployment environments (Kubernetes, AWS ECS, Azure Container Instances, etc.) to standardize deployment processes, and allows creating optimized production images through multi-stage builds and nginx-based static file serving.

## Understanding React Application Containerization

> **Why Containerize React Apps?**
>
> React is a client-side JavaScript application that, after building, is bundled into static files (HTML, CSS, JavaScript) and served through a web server. Using Docker containers ensures build environment consistency, enables deployment automation, and simplifies environment-specific configuration management.

### Benefits of Containerization

| Benefit | Description |
|---------|-------------|
| **Environment consistency** | Ensures identical runtime across development, staging, and production |
| **Build reproducibility** | Node.js version, npm package versions are specified in Dockerfile, ensuring identical build results for everyone |
| **Deployment standardization** | Unified deployment process through container registry-based image distribution |
| **Scalability** | Easy integration with orchestration tools like Kubernetes, Docker Swarm |
| **Easy rollback** | Version management through image tags enables simple rollback to previous versions |

### Understanding React Build Process

To effectively create Docker images for React applications, you need to understand the React build process first.

1. **Dependency installation**: Install node_modules with `npm install` or `npm ci`
2. **Build execution**: Generate static file bundles with `npm run build`
3. **Build output**: Static files created in `build/` or `dist/` directory
4. **Serving**: Web server (nginx, Apache, etc.) delivers static files to clients

In this process, Node.js and npm required for building are not needed at runtime, so they can be excluded from the final image through multi-stage builds.

## Writing Basic Dockerfile

### Single-Stage Dockerfile (Not Recommended)

This is the simplest form of Dockerfile but has several issues.

```dockerfile
FROM node:20
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

**Issues:**

| Issue | Description |
|-------|-------------|
| **Image size** | Very large as it includes full Node.js image (~1GB) + node_modules |
| **Security risk** | Unnecessary packages like build tools, development dependencies included in production |
| **Performance inefficiency** | Node.js `serve` command is not optimized for production static file serving |
| **Cache inefficiency** | Requires full layer rebuild when source code changes |

### Multi-Stage Build Dockerfile (Recommended)

Multi-stage builds solve the above issues by separating build and runtime environments.

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

# Copy only dependency files first (cache utilization)
COPY package.json package-lock.json ./

# Install all dependencies, not just production (devDependencies needed for build)
RUN npm ci

# Copy source code and build
COPY . .
RUN npm run build

# ===== Runtime Stage =====
FROM nginx:alpine

# Copy only build artifacts
COPY --from=builder /app/build /usr/share/nginx/html

# Expose nginx port
EXPOSE 80

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
```

**Benefits:**

| Benefit | Description |
|---------|-------------|
| **Image size reduction** | node:20 (~1GB) → nginx:alpine (~25MB), approximately 97% reduction |
| **Enhanced security** | Node.js, npm, devDependencies not included in final image |
| **Performance improvement** | nginx is a high-performance web server optimized for static file serving |
| **Cache efficiency** | Separating dependency and source code layers improves build speed |

## Layer Caching Optimization

> **Docker Layer Caching**
>
> Docker caches each Dockerfile instruction as a layer and rebuilds all layers after a changed layer. Therefore, layers with low change frequency (dependencies) should be placed first, and layers with high change frequency (source code) should be placed later.

### Optimized Layer Structure

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

# 1. Copy only dependency files (low change frequency)
COPY package.json package-lock.json ./

# 2. Install dependencies (only re-runs when package.json changes)
RUN npm ci

# 3. Copy source code (high change frequency)
COPY public ./public
COPY src ./src

# 4. Copy TypeScript config, etc. (if needed)
COPY tsconfig.json ./

# 5. Run build
RUN npm run build

# ===== Runtime Stage =====
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### .dockerignore Configuration

Exclude unnecessary files from build context to improve build speed.

```
# Dependencies (reinstalled during build)
node_modules

# Build output (regenerated during build)
build
dist

# Version control
.git
.gitignore

# Development environment files
.env.local
.env.development
.env*.local

# IDE settings
.vscode
.idea

# Tests
coverage
*.test.js
*.test.tsx
__tests__

# Documentation
README.md
CHANGELOG.md
docs

# Docker related
Dockerfile*
docker-compose*
.dockerignore
```

## Environment Variable Management

### Build-Time Environment Variables

In React applications (Create React App), environment variables with the `REACT_APP_` prefix are included in the JavaScript bundle at build time, so they must be injected as ARG during Docker build.

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

# Declare build arguments
ARG REACT_APP_API_URL
ARG REACT_APP_ENVIRONMENT

# Set as environment variables (used during build)
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENVIRONMENT=$REACT_APP_ENVIRONMENT

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ===== Runtime Stage =====
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**Build command:**

```bash
docker build \
  --build-arg REACT_APP_API_URL=https://api.production.com \
  --build-arg REACT_APP_ENVIRONMENT=production \
  -t myapp:latest .
```

### Environment Variables in Vite Projects

Projects using Vite use the `VITE_` prefix.

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

# Vite environment variables
ARG VITE_API_URL
ARG VITE_APP_TITLE

ENV VITE_API_URL=$VITE_API_URL
ENV VITE_APP_TITLE=$VITE_APP_TITLE

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ===== Runtime Stage =====
FROM nginx:alpine

# Vite builds to dist directory by default
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Runtime Environment Variable Injection (Advanced)

When you need to inject environment variables at container startup rather than build time, you can use the following approach.

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# Build with placeholder
ENV REACT_APP_API_URL=__REACT_APP_API_URL__
RUN npm run build

# ===== Runtime Stage =====
FROM nginx:alpine

# Install envsubst
RUN apk add --no-cache gettext

COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Environment variable substitution script
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
```

**docker-entrypoint.sh:**

```bash
#!/bin/sh

# Substitute placeholders in JavaScript files
for file in /usr/share/nginx/html/static/js/*.js; do
  sed -i "s|__REACT_APP_API_URL__|${REACT_APP_API_URL}|g" "$file"
done

# Start nginx
nginx -g "daemon off;"
```

## nginx Configuration Optimization

### SPA (Single Page Application) Routing

In SPAs using React Router, `index.html` must be returned for all paths for client-side routing to work.

**nginx.conf:**

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # SPA routing: return index.html for all paths
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static file caching (files with build hash)
    location ~* \.(?:css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Cache images, fonts, etc.
    location ~* \.(?:jpg|jpeg|gif|png|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Don't cache index.html (reflect new deployments)
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
```

### gzip Compression Settings

Enable gzip compression to reduce transfer size.

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Enable gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types
        text/plain
        text/css
        text/javascript
        application/javascript
        application/json
        application/xml
        image/svg+xml;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Adding Security Headers

Adding security headers is recommended for production environments.

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Content Security Policy (needs adjustment for your application)
    # add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### Complete Dockerfile and nginx.conf

**Dockerfile:**

```dockerfile
# ===== Build Stage =====
FROM node:20-alpine AS builder

WORKDIR /app

# Build arguments
ARG REACT_APP_API_URL
ARG REACT_APP_ENVIRONMENT=production

ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENVIRONMENT=$REACT_APP_ENVIRONMENT

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy source code and build
COPY . .
RUN npm run build

# ===== Runtime Stage =====
FROM nginx:alpine

# Set up non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S react -u 1001

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy build artifacts
COPY --from=builder /app/build /usr/share/nginx/html

# Set permissions
RUN chown -R react:nodejs /usr/share/nginx/html && \
    chown -R react:nodejs /var/cache/nginx && \
    chown -R react:nodejs /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown react:nodejs /var/run/nginx.pid

# Switch to non-root user
USER react

EXPOSE 80

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --quiet --tries=1 --spider http://localhost:80/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
```

**nginx.conf:**

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types text/plain text/css text/javascript application/javascript application/json application/xml image/svg+xml;

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # SPA routing
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Static file caching
    location ~* \.(?:css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location ~* \.(?:jpg|jpeg|gif|png|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Prevent index.html caching
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
```

## Image Size Comparison

Comparing image sizes before and after optimization:

| Configuration | Image Size | Description |
|---------------|------------|-------------|
| **node:20 single stage** | ~1.2GB | Includes Node.js + node_modules + build tools |
| **node:20-alpine single stage** | ~400MB | Alpine-based but still contains unnecessary files |
| **Multi-stage + nginx:alpine** | ~25MB | Contains only build artifacts, optimized |

## Conclusion

The key to writing Dockerfiles for React applications is separating build and runtime environments through multi-stage builds, optimizing layer caching, and configuring efficient static file serving through nginx. By applying additional optimizations such as environment variable management, security header configuration, and gzip compression, you can create secure and efficient production-level container images, which significantly contributes to reducing CI/CD pipeline build times and maintaining deployment environment consistency.
