---
title: "Docker 이미지 크기를 10배 줄이는 방법: 실전 최적화 가이드"
date: 2025-02-17T22:39:45+09:00
tags: ["Docker", "최적화", "이미지", "컨테이너", "멀티스테이지", "DevOps"]
description: "Docker 이미지 크기 증가의 원인 분석, 멀티 스테이지 빌드, Alpine Linux, distroless 이미지, 레이어 최적화, 언어별 최적화 기법까지 Docker 이미지를 10배 이상 줄이는 실전 최적화 전략을 체계적으로 설명하는 완벽 가이드"
draft: false
---

Docker 이미지 최적화는 컨테이너 기반 애플리케이션의 빌드 시간 단축, 배포 속도 향상, 스토리지 비용 절감, 보안 취약점 감소에 직접적인 영향을 미치는 핵심 기술로, 적절한 베이스 이미지 선택, 멀티 스테이지 빌드, 레이어 최적화 등의 기법을 적용하면 이미지 크기를 10배 이상 줄일 수 있으며, 이는 CI/CD 파이프라인의 효율성과 클라우드 인프라 비용에도 큰 영향을 미친다.

## Docker 이미지 크기 문제의 이해

> **왜 이미지 크기가 중요한가?**
>
> Docker 이미지 크기는 빌드 시간, 푸시/풀 시간, 컨테이너 시작 시간, 스토리지 비용, 보안 공격 표면에 직접적인 영향을 미치므로, 프로덕션 환경에서 효율적인 운영을 위해서는 이미지 최적화가 필수적이다.

### 이미지 크기 증가의 주요 원인

일반적으로 최적화되지 않은 Docker 이미지가 비대해지는 원인은 다음과 같으며, 각 원인을 이해해야 적절한 최적화 전략을 수립할 수 있다.

| 원인 | 설명 | 영향 |
|------|------|------|
| **무거운 베이스 이미지** | 전체 OS 패키지를 포함한 debian, ubuntu 등 사용 | 수백 MB ~ 1GB 추가 |
| **개발 도구 포함** | 컴파일러, 빌드 도구 등이 런타임에 불필요하게 포함 | 수백 MB 추가 |
| **개발 의존성 포함** | devDependencies, test 라이브러리 등 포함 | 수십 ~ 수백 MB 추가 |
| **불필요한 파일 복사** | .git, node_modules, 테스트 파일 등 복사 | 수십 MB ~ 수 GB 추가 |
| **레이어 비효율** | 각 RUN 명령에서 생성된 임시 파일이 삭제되지 않음 | 레이어마다 누적 |
| **캐시 파일 누적** | apt, pip, npm 캐시 등이 이미지에 포함 | 수십 ~ 수백 MB 추가 |

### 최적화 전 이미지 분석

최적화를 시작하기 전에 현재 이미지의 크기와 레이어 구성을 분석해야 한다.

```bash
# 이미지 크기 확인
docker images myapp:latest

# 레이어별 크기 분석
docker history myapp:latest

# dive 도구로 상세 분석
dive myapp:latest
```

일반적인 Node.js 애플리케이션의 최적화 전 Dockerfile 예시이다.

```dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
```

이 Dockerfile로 빌드된 이미지는 약 1.2GB ~ 1.5GB에 달하는데, 이는 node:20 베이스 이미지(약 1GB)에 node_modules와 빌드 아티팩트가 추가되기 때문이다.

## 베이스 이미지 최적화

> **베이스 이미지 선택의 중요성**
>
> 베이스 이미지는 최종 이미지 크기의 가장 큰 부분을 차지하므로, 애플리케이션 요구사항에 맞는 최소한의 베이스 이미지를 선택하는 것이 최적화의 첫 단계이다.

### 베이스 이미지 유형별 비교

| 이미지 유형 | 크기 범위 | 특징 | 적합한 사용 사례 |
|------------|----------|------|-----------------|
| **일반 이미지** (debian, ubuntu) | 100MB ~ 1GB | 전체 패키지 관리자, 쉘, 디버깅 도구 포함 | 개발 환경, 디버깅 필요 시 |
| **slim 이미지** (node:slim, python:slim) | 50MB ~ 200MB | 필수 런타임만 포함, 일부 도구 제거 | 일반적인 프로덕션 환경 |
| **Alpine 이미지** (node:alpine, python:alpine) | 5MB ~ 50MB | musl libc 기반, 최소 패키지 | 크기 최적화가 중요한 환경 |
| **distroless 이미지** (gcr.io/distroless) | 2MB ~ 20MB | 쉘 없음, 애플리케이션 런타임만 포함 | 보안이 중요한 프로덕션 환경 |
| **scratch** | 0MB | 완전히 비어있는 이미지 | 정적 바이너리 (Go, Rust) |

### Alpine Linux 기반 이미지

Alpine Linux는 musl libc와 BusyBox를 기반으로 하는 경량 Linux 배포판으로, 기본 이미지 크기가 약 5MB에 불과하여 Docker 이미지 최적화에 널리 사용된다.

```dockerfile
# Before: 약 1GB
FROM node:20

# After: 약 180MB
FROM node:20-alpine
```

Alpine 이미지 사용 시 주의사항으로는 glibc 대신 musl libc를 사용하므로 일부 네이티브 모듈과의 호환성 문제가 발생할 수 있으며, 이 경우 빌드 시 추가 패키지 설치가 필요할 수 있다.

```dockerfile
FROM node:20-alpine

# 네이티브 모듈 빌드를 위한 패키지 설치
RUN apk add --no-cache python3 make g++

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```

### distroless 이미지

Google의 distroless 이미지는 쉘이나 패키지 관리자 없이 애플리케이션 런타임만 포함하는 최소 이미지로, 공격 표면을 줄여 보안을 강화하고 이미지 크기를 최소화한다.

```dockerfile
# 빌드 스테이지
FROM node:20-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# 런타임 스테이지 - distroless 사용
FROM gcr.io/distroless/nodejs20-debian12
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
CMD ["dist/index.js"]
```

## 멀티 스테이지 빌드

> **멀티 스테이지 빌드란?**
>
> 멀티 스테이지 빌드는 하나의 Dockerfile에서 여러 FROM 명령을 사용하여 빌드 환경과 런타임 환경을 분리하는 기법으로, 빌드에 필요한 도구와 중간 결과물을 최종 이미지에서 제외하여 이미지 크기를 획기적으로 줄인다.

### 멀티 스테이지 빌드의 원리

멀티 스테이지 빌드는 Docker 17.05에서 도입된 기능으로, 다음과 같은 단계로 동작한다.

1. **빌드 스테이지**: 소스 코드 컴파일, 의존성 설치, 테스트 실행 등 빌드 작업 수행
2. **런타임 스테이지**: 빌드 스테이지에서 생성된 아티팩트만 복사하여 최종 이미지 생성
3. **레이어 분리**: 각 스테이지는 독립적인 레이어를 가지며, 최종 이미지에는 마지막 스테이지의 레이어만 포함

### Node.js 애플리케이션 최적화

Node.js 애플리케이션의 멀티 스테이지 빌드 예시이다.

**최적화 전 (약 1.2GB):**

```dockerfile
FROM node:20
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build
CMD ["npm", "start"]
```

**최적화 후 (약 150MB):**

```dockerfile
# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder

WORKDIR /app

# 의존성 파일만 먼저 복사 (캐시 활용)
COPY package.json package-lock.json ./
RUN npm ci

# 소스 코드 복사 및 빌드
COPY . .
RUN npm run build

# 프로덕션 의존성만 재설치
RUN rm -rf node_modules && npm ci --only=production

# ===== 런타임 스테이지 =====
FROM node:20-alpine

# 보안을 위한 비루트 사용자 생성
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nextjs -u 1001

WORKDIR /app

# 빌드 결과물과 프로덕션 의존성만 복사
COPY --from=builder --chown=nextjs:nodejs /app/dist ./dist
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=nextjs:nodejs /app/package.json ./

# 비루트 사용자로 전환
USER nextjs

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

### Go 애플리케이션 최적화

Go는 정적 바이너리를 생성할 수 있어 scratch 이미지를 사용하면 가장 작은 이미지를 만들 수 있다.

**최적화 전 (약 800MB):**

```dockerfile
FROM golang:1.22
WORKDIR /app
COPY . .
RUN go build -o main .
CMD ["./main"]
```

**최적화 후 (약 10MB):**

```dockerfile
# ===== 빌드 스테이지 =====
FROM golang:1.22-alpine AS builder

WORKDIR /app

# 의존성 다운로드
COPY go.mod go.sum ./
RUN go mod download

# 소스 코드 복사 및 정적 바이너리 빌드
COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o main .

# ===== 런타임 스테이지 =====
FROM scratch

# SSL 인증서 복사 (HTTPS 요청 시 필요)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# 바이너리만 복사
COPY --from=builder /app/main /main

EXPOSE 8080
ENTRYPOINT ["/main"]
```

`-ldflags="-w -s"` 옵션은 디버그 정보와 심볼 테이블을 제거하여 바이너리 크기를 추가로 줄인다.

### Python 애플리케이션 최적화

Python 애플리케이션은 가상 환경을 활용하여 최적화할 수 있다.

**최적화 전 (약 900MB):**

```dockerfile
FROM python:3.12
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
CMD ["python", "app.py"]
```

**최적화 후 (약 120MB):**

```dockerfile
# ===== 빌드 스테이지 =====
FROM python:3.12-alpine AS builder

WORKDIR /app

# 빌드 도구 설치 (네이티브 확장 모듈용)
RUN apk add --no-cache gcc musl-dev libffi-dev

# 가상 환경 생성 및 의존성 설치
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# ===== 런타임 스테이지 =====
FROM python:3.12-alpine

# 런타임 라이브러리만 설치
RUN apk add --no-cache libffi

WORKDIR /app

# 가상 환경 복사
COPY --from=builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# 소스 코드 복사
COPY . .

# 비루트 사용자 생성 및 전환
RUN adduser -D appuser
USER appuser

EXPOSE 8000
CMD ["python", "app.py"]
```

### Java 애플리케이션 최적화

Java 애플리케이션은 JRE만 포함하는 런타임 이미지를 사용하고, jlink로 커스텀 JRE를 생성하면 추가 최적화가 가능하다.

**최적화 전 (약 700MB):**

```dockerfile
FROM maven:3.9-eclipse-temurin-21
WORKDIR /app
COPY . .
RUN mvn package -DskipTests
CMD ["java", "-jar", "target/app.jar"]
```

**최적화 후 (약 150MB):**

```dockerfile
# ===== 빌드 스테이지 =====
FROM maven:3.9-eclipse-temurin-21-alpine AS builder

WORKDIR /app
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn package -DskipTests

# ===== 런타임 스테이지 =====
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# JAR 파일만 복사
COPY --from=builder /app/target/*.jar app.jar

# 비루트 사용자 생성 및 전환
RUN adduser -D appuser
USER appuser

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

## 레이어 최적화

> **레이어 최적화의 원리**
>
> Dockerfile의 각 명령어(RUN, COPY, ADD)는 새로운 레이어를 생성하며, 레이어에 추가된 파일은 이후 레이어에서 삭제하더라도 이미지 크기에서 제거되지 않으므로, 같은 레이어 내에서 불필요한 파일을 삭제해야 한다.

### 명령어 통합

여러 RUN 명령어를 `&&`로 연결하고 임시 파일을 같은 레이어에서 삭제한다.

**비효율적인 방식:**

```dockerfile
RUN apt-get update
RUN apt-get install -y nginx curl
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*
```

**최적화된 방식:**

```dockerfile
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        nginx \
        curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

### .dockerignore 활용

`.dockerignore` 파일을 사용하면 빌드 컨텍스트에서 불필요한 파일을 제외하여 빌드 속도와 이미지 크기를 개선할 수 있다.

```
# 버전 관리
.git
.gitignore

# 의존성 (빌드 시 재설치)
node_modules
vendor
__pycache__

# 개발 환경
.env.local
.env.development
*.log
.vscode
.idea

# 테스트
tests
test
coverage
.nyc_output

# 문서
docs
README.md
CHANGELOG.md

# 빌드 결과물 (멀티 스테이지에서 재생성)
dist
build
target
```

### 캐시 정리

패키지 관리자의 캐시를 같은 레이어에서 삭제한다.

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

## 최적화 결과 비교

다양한 언어와 최적화 기법을 적용한 결과를 비교하면 다음과 같다.

| 언어 | 최적화 전 | 최적화 후 | 감소율 | 주요 기법 |
|------|----------|----------|--------|----------|
| **Node.js** | 1.2GB | 150MB | 87% | Alpine + 멀티 스테이지 |
| **Go** | 800MB | 10MB | 99% | scratch + 정적 빌드 |
| **Python** | 900MB | 120MB | 87% | Alpine + 가상환경 |
| **Java** | 700MB | 150MB | 79% | JRE-alpine + 멀티 스테이지 |
| **Rust** | 1.5GB | 8MB | 99% | scratch + 정적 빌드 |

## 최적화의 이점

Docker 이미지 크기 최적화는 다음과 같은 실질적인 이점을 제공한다.

| 이점 | 설명 |
|------|------|
| **빌드 시간 단축** | 작은 베이스 이미지와 효율적인 레이어 캐싱으로 CI/CD 파이프라인 속도 향상 |
| **배포 속도 향상** | 이미지 푸시/풀 시간 단축으로 배포 주기 개선 |
| **스토리지 비용 절감** | 컨테이너 레지스트리와 노드의 스토리지 사용량 감소 |
| **보안 강화** | 불필요한 패키지 제거로 공격 표면 감소, CVE 취약점 감소 |
| **컨테이너 시작 시간 단축** | 이미지 풀 시간 감소로 스케일 아웃 속도 향상 |
| **네트워크 대역폭 절약** | 특히 엣지 환경이나 대역폭이 제한된 환경에서 효과적 |

## 결론

Docker 이미지 최적화는 적절한 베이스 이미지 선택, 멀티 스테이지 빌드, 레이어 최적화, 캐시 정리 등의 기법을 조합하여 이미지 크기를 10배 이상 줄일 수 있으며, 이는 빌드 시간 단축, 배포 속도 향상, 스토리지 비용 절감, 보안 강화로 이어진다. 언어와 프레임워크에 따라 최적의 전략이 다르므로, 애플리케이션 특성에 맞는 최적화 기법을 선택하고 지속적으로 이미지 크기를 모니터링하며 개선하는 것이 중요하다.
