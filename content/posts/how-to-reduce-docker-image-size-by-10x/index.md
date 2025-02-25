---
title: "도커 이미지 크기 10배 줄인 비결"
date: 2025-02-17T22:39:45+09:00
tags: ["Docker", "최적화", "이미지", "용량", "멀티스테이지"]
description: "도커 이미지의 크기를 효과적으로 줄이는 실전 최적화 기법과 적용 사례를 설명한다."
draft: false
---

## 최적화 전 상태

일반적인 Node.js 애플리케이션의 도커파일은 다음과 같다.

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

이 이미지의 크기는 1GB를 넘는다. 주된 원인은 다음과 같다:

1. 무거운 베이스 이미지
2. 개발 도구 포함
3. 불필요한 파일 존재
4. 캐시 파일 누적

## 최적화 기법

### 1. 멀티 스테이지 빌드 적용

빌드 단계와 실행 단계를 분리한다.

```dockerfile
# 빌드 스테이지
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# 실행 스테이지
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/package*.json ./
RUN npm install --production
CMD ["npm", "start"]
```

### 2. 알파인 리눅스 사용

알파인 리눅스는 기본 이미지 크기를 크게 줄인다.

```dockerfile
# 나쁜 예: node:18 (~1GB)
FROM node:18

# 좋은 예: node:18-alpine (~120MB)
FROM node:18-alpine
```

### 3. 프로덕션 의존성만 포함

개발 의존성을 제외한다.

```dockerfile
# 나쁜 예
RUN npm install

# 좋은 예
RUN npm ci --only=production
```

### 4. 불필요한 파일 제거

.dockerignore 파일을 사용한다.

```
node_modules
.git
.vscode
*.log
tests
docs
```

### 5. 레이어 최적화

명령어를 결합하여 레이어 수를 줄인다.

```dockerfile
# 나쁜 예
RUN apk update
RUN apk add python3
RUN rm -rf /var/cache/apk/*

# 좋은 예
RUN apk update && \
    apk add python3 && \
    rm -rf /var/cache/apk/*
```

## 실제 적용 사례

### Node.js 웹 애플리케이션

최적화 전:

```dockerfile
FROM node:18
WORKDIR /app
COPY . .
RUN npm install
CMD ["npm", "start"]
```

이미지 크기: 1.2GB

최적화 후:

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
RUN npm ci --only=production && \
    npm cache clean --force
CMD ["npm", "start"]
```

이미지 크기: 120MB

### Go 애플리케이션

최적화 전:

```dockerfile
FROM golang:1.16
WORKDIR /app
COPY . .
RUN go build -o main .
CMD ["./main"]
```

이미지 크기: 850MB

최적화 후:

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

이미지 크기: 15MB

### Python 웹 애플리케이션

최적화 전:

```dockerfile
FROM python:3.9
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

이미지 크기: 900MB

최적화 후:

```dockerfile
FROM python:3.9-alpine AS builder
WORKDIR /app
COPY requirements.txt .
RUN apk add --no-cache gcc musl-dev && \
    pip install --user -r requirements.txt

FROM python:3.9-alpine
WORKDIR /app
COPY --from=builder /root/.local /root/.local
COPY . .
ENV PATH=/root/.local/bin:$PATH
CMD ["python", "app.py"]
```

이미지 크기: 100MB

## 성능 영향

이미지 크기 감소는 다음과 같은 이점을 제공한다:

1. 배포 시간 단축
2. 네트워크 대역폭 절약
3. 컨테이너 시작 시간 감소
4. 스토리지 비용 절감
5. 보안 취약점 감소

이미지 최적화는 지속적인 과정이다. 새로운 버전이 릴리스될 때마다 최적화 기법을 적용하고 결과를 측정한다. 이는 운영 비용 절감과 시스템 성능 향상으로 이어진다.
