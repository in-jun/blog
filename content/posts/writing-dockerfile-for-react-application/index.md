---
title: "React 애플리케이션 Dockerfile 작성"
date: 2025-02-17T21:56:12+09:00
tags: ["React", "Docker", "DevOps"]
description: "React 애플리케이션용 Dockerfile 작성과 최적화 방법을 다룬다."
draft: false
---

React 애플리케이션을 Docker 컨테이너로 패키징하면 개발 환경과 프로덕션 환경 간의 일관성을 유지하고, CI/CD 파이프라인과의 통합이 용이해지며, 다양한 배포 환경(Kubernetes, AWS ECS, Azure Container Instances 등)에서 동일한 이미지를 사용할 수 있어 배포 프로세스가 표준화되고, 멀티 스테이지 빌드와 nginx 기반 정적 파일 서빙을 통해 최적화된 프로덕션 이미지를 생성할 수 있다.

## React 애플리케이션 컨테이너화의 이해

> **왜 React 앱을 컨테이너화하는가?**
>
> React는 클라이언트 사이드 JavaScript 애플리케이션으로, 빌드 후 정적 파일(HTML, CSS, JavaScript)로 번들링되어 웹 서버를 통해 제공되는데, Docker 컨테이너를 사용하면 빌드 환경의 일관성 보장, 배포 자동화, 환경별 설정 관리가 용이해진다.

### 컨테이너화의 이점

| 이점 | 설명 |
|------|------|
| **환경 일관성** | 개발, 스테이징, 프로덕션 환경에서 동일한 런타임 보장 |
| **빌드 재현성** | Node.js 버전, npm 패키지 버전 등이 Dockerfile에 명시되어 누구나 동일한 빌드 결과 |
| **배포 표준화** | 컨테이너 레지스트리를 통한 이미지 배포로 배포 프로세스 통일 |
| **확장성** | Kubernetes, Docker Swarm 등 오케스트레이션 도구와의 통합 용이 |
| **롤백 용이성** | 이미지 태그를 통한 버전 관리로 이전 버전으로의 롤백 간편 |

### React 빌드 프로세스 이해

React 애플리케이션의 Docker 이미지를 효과적으로 만들기 위해서는 먼저 React 빌드 프로세스를 이해해야 한다.

1. **의존성 설치**: `npm install` 또는 `npm ci`로 node_modules 설치
2. **빌드 실행**: `npm run build`로 정적 파일 번들 생성
3. **빌드 결과물**: `build/` 또는 `dist/` 디렉토리에 정적 파일 생성
4. **서빙**: 웹 서버(nginx, Apache 등)가 정적 파일을 클라이언트에 제공

이 과정에서 빌드에 필요한 Node.js와 npm은 런타임에 필요하지 않으므로, 멀티 스테이지 빌드를 통해 최종 이미지에서 제외할 수 있다.

## 기본 Dockerfile 작성

### 단일 스테이지 Dockerfile (권장하지 않음)

가장 단순한 형태의 Dockerfile이지만 여러 문제점이 있다.

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

**문제점:**

| 문제 | 설명 |
|------|------|
| **이미지 크기** | Node.js 전체 이미지(약 1GB) + node_modules가 포함되어 매우 큼 |
| **보안 위험** | 빌드 도구, 개발 의존성 등 불필요한 패키지가 프로덕션에 포함 |
| **성능 비효율** | Node.js의 `serve` 명령은 프로덕션 정적 파일 서빙에 최적화되지 않음 |
| **캐시 비효율** | 소스 코드 변경 시 전체 레이어 재빌드 필요 |

### 멀티 스테이지 빌드 Dockerfile (권장)

멀티 스테이지 빌드를 사용하면 빌드 환경과 런타임 환경을 분리하여 위 문제들을 해결할 수 있다.

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 활용)
COPY package.json package-lock.json ./

# 프로덕션 의존성만 설치하지 않고 전체 설치 (빌드에 devDependencies 필요)
RUN npm ci

# 소스 코드 복사 및 빌드
COPY . .
RUN npm run build

# ===== 런타임 스테이지 =====
FROM nginx:alpine

# 빌드 결과물만 복사
COPY --from=builder /app/build /usr/share/nginx/html

# nginx 포트 노출
EXPOSE 80

# nginx 실행
CMD ["nginx", "-g", "daemon off;"]
```

**이점:**

| 이점 | 설명 |
|------|------|
| **이미지 크기 감소** | node:20 (약 1GB) → nginx:alpine (약 25MB), 약 97% 감소 |
| **보안 강화** | Node.js, npm, devDependencies가 최종 이미지에 미포함 |
| **성능 향상** | nginx는 정적 파일 서빙에 최적화된 고성능 웹 서버 |
| **캐시 효율성** | 의존성 레이어와 소스 코드 레이어 분리로 빌드 속도 향상 |

## 레이어 캐싱 최적화

> **Docker 레이어 캐싱**
>
> Docker는 Dockerfile의 각 명령어를 레이어로 캐싱하며, 변경된 레이어 이후의 모든 레이어를 재빌드한다. 따라서 변경 빈도가 낮은 레이어(의존성)를 먼저 배치하고 변경 빈도가 높은 레이어(소스 코드)를 나중에 배치해야 한다.

### 최적화된 레이어 구조

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

# 1. 의존성 파일만 복사 (변경 빈도 낮음)
COPY package.json package-lock.json ./

# 2. 의존성 설치 (package.json 변경 시에만 재실행)
RUN npm ci

# 3. 소스 코드 복사 (변경 빈도 높음)
COPY public ./public
COPY src ./src

# 4. 타입스크립트 설정 등 복사 (필요한 경우)
COPY tsconfig.json ./

# 5. 빌드 실행
RUN npm run build

# ===== 런타임 스테이지 =====
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### .dockerignore 설정

빌드 컨텍스트에서 불필요한 파일을 제외하여 빌드 속도를 향상시킨다.

```
# 의존성 (빌드 시 재설치)
node_modules

# 빌드 결과물 (빌드 시 재생성)
build
dist

# 버전 관리
.git
.gitignore

# 개발 환경 파일
.env.local
.env.development
.env*.local

# IDE 설정
.vscode
.idea

# 테스트
coverage
*.test.js
*.test.tsx
__tests__

# 문서
README.md
CHANGELOG.md
docs

# Docker 관련
Dockerfile*
docker-compose*
.dockerignore
```

## 환경 변수 관리

### 빌드 타임 환경 변수

React 애플리케이션(Create React App 기준)에서 `REACT_APP_` 접두사가 붙은 환경 변수는 빌드 시점에 JavaScript 번들에 포함되므로, Docker 빌드 시 ARG로 주입해야 한다.

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

# 빌드 인자 선언
ARG REACT_APP_API_URL
ARG REACT_APP_ENVIRONMENT

# 환경 변수로 설정 (빌드 시 사용)
ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENVIRONMENT=$REACT_APP_ENVIRONMENT

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ===== 런타임 스테이지 =====
FROM nginx:alpine

COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

**빌드 명령:**

```bash
docker build \
  --build-arg REACT_APP_API_URL=https://api.production.com \
  --build-arg REACT_APP_ENVIRONMENT=production \
  -t myapp:latest .
```

### Vite 프로젝트의 환경 변수

Vite를 사용하는 프로젝트에서는 `VITE_` 접두사를 사용한다.

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

# Vite 환경 변수
ARG VITE_API_URL
ARG VITE_APP_TITLE

ENV VITE_API_URL=$VITE_API_URL
ENV VITE_APP_TITLE=$VITE_APP_TITLE

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build

# ===== 런타임 스테이지 =====
FROM nginx:alpine

# Vite는 기본적으로 dist 디렉토리에 빌드
COPY --from=builder /app/dist /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### 런타임 환경 변수 주입 (고급)

빌드 시점이 아닌 컨테이너 시작 시점에 환경 변수를 주입해야 하는 경우, 다음과 같은 방법을 사용할 수 있다.

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .

# 플레이스홀더로 빌드
ENV REACT_APP_API_URL=__REACT_APP_API_URL__
RUN npm run build

# ===== 런타임 스테이지 =====
FROM nginx:alpine

# envsubst 설치
RUN apk add --no-cache gettext

COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 환경 변수 치환 스크립트
COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

EXPOSE 80
ENTRYPOINT ["/docker-entrypoint.sh"]
```

**docker-entrypoint.sh:**

```bash
#!/bin/sh

# JavaScript 파일에서 플레이스홀더 치환
for file in /usr/share/nginx/html/static/js/*.js; do
  sed -i "s|__REACT_APP_API_URL__|${REACT_APP_API_URL}|g" "$file"
done

# nginx 시작
nginx -g "daemon off;"
```

## nginx 설정 최적화

### SPA(Single Page Application) 라우팅

React Router를 사용하는 SPA에서는 모든 경로에서 `index.html`을 반환해야 클라이언트 사이드 라우팅이 동작한다.

**nginx.conf:**

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # SPA 라우팅: 모든 경로에서 index.html 반환
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 정적 파일 캐싱 (빌드 해시가 포함된 파일)
    location ~* \.(?:css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # 이미지, 폰트 등 캐싱
    location ~* \.(?:jpg|jpeg|gif|png|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # index.html은 캐싱하지 않음 (새 배포 반영)
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
```

### gzip 압축 설정

전송 크기를 줄이기 위해 gzip 압축을 활성화한다.

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # gzip 압축 활성화
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

### 보안 헤더 추가

프로덕션 환경에서는 보안 헤더를 추가하는 것이 좋다.

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # 보안 헤더
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Content Security Policy (애플리케이션에 맞게 조정 필요)
    # add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline';" always;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

### 완성된 Dockerfile과 nginx.conf

**Dockerfile:**

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

# 빌드 인자
ARG REACT_APP_API_URL
ARG REACT_APP_ENVIRONMENT=production

ENV REACT_APP_API_URL=$REACT_APP_API_URL
ENV REACT_APP_ENVIRONMENT=$REACT_APP_ENVIRONMENT

# 의존성 설치
COPY package.json package-lock.json ./
RUN npm ci

# 소스 코드 복사 및 빌드
COPY . .
RUN npm run build

# ===== 런타임 스테이지 =====
FROM nginx:alpine

# 보안을 위한 비루트 사용자 설정
RUN addgroup -g 1001 -S nodejs && \
    adduser -S react -u 1001

# nginx 설정 복사
COPY nginx.conf /etc/nginx/conf.d/default.conf

# 빌드 결과물 복사
COPY --from=builder /app/build /usr/share/nginx/html

# 권한 설정
RUN chown -R react:nodejs /usr/share/nginx/html && \
    chown -R react:nodejs /var/cache/nginx && \
    chown -R react:nodejs /var/log/nginx && \
    touch /var/run/nginx.pid && \
    chown react:nodejs /var/run/nginx.pid

# 비루트 사용자로 전환
USER react

EXPOSE 80

# 헬스체크
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

    # gzip 압축
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_types text/plain text/css text/javascript application/javascript application/json application/xml image/svg+xml;

    # 보안 헤더
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # SPA 라우팅
    location / {
        try_files $uri $uri/ /index.html;
    }

    # 정적 파일 캐싱
    location ~* \.(?:css|js)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location ~* \.(?:jpg|jpeg|gif|png|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # index.html 캐싱 방지
    location = /index.html {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
    }
}
```

## 이미지 크기 비교

최적화 전후의 이미지 크기를 비교하면 다음과 같다.

| 구성 | 이미지 크기 | 설명 |
|------|-------------|------|
| **node:20 단일 스테이지** | 약 1.2GB | Node.js + node_modules + 빌드 도구 포함 |
| **node:20-alpine 단일 스테이지** | 약 400MB | Alpine 기반이지만 여전히 불필요한 파일 포함 |
| **멀티 스테이지 + nginx:alpine** | 약 25MB | 빌드 결과물만 포함, 최적화됨 |

## 결론

React 애플리케이션의 Dockerfile 작성에서 핵심은 멀티 스테이지 빌드를 통해 빌드 환경과 런타임 환경을 분리하고, 레이어 캐싱을 최적화하며, nginx를 통한 효율적인 정적 파일 서빙을 구성하는 것이다. 환경 변수 관리, 보안 헤더 설정, gzip 압축 등의 추가 최적화를 통해 프로덕션 수준의 안전하고 효율적인 컨테이너 이미지를 생성할 수 있으며, 이는 CI/CD 파이프라인의 빌드 시간 단축과 배포 환경의 일관성 유지에 크게 기여한다.
