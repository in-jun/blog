---
title: "도커 컴포즈로 개발 환경 한 방에 세팅하기"
date: 2025-02-17T22:49:32+09:00
tags: ["Docker Compose", "개발환경", "인프라", "환경구성"]
description: "도커 컴포즈를 활용하여 복잡한 개발 환경을 손쉽게 구성하는 방법을 설명한다."
draft: false
---

## 개발 환경 구성의 어려움

웹 애플리케이션을 개발하다 보면 데이터베이스, 캐시 서버, 메시지 큐 등 다양한 미들웨어가 필요하다. 각각의 미들웨어를 설치하고 설정하는 과정은 번거롭고 시간도 많이 걸린다. 새로운 팀원이 합류할 때마다 이 과정을 반복해야 한다면 더욱 비효율적이다.

## 도커 컴포즈의 필요성

도커 컴포즈는 이러한 문제를 해결하는 도구다. YAML 파일 하나로 여러 컨테이너의 구성을 정의하고, 한 번의 명령으로 전체 환경을 실행할 수 있다. 버전 관리 시스템에 이 파일을 포함하면 모든 팀원이 동일한 환경을 쉽게 구성할 수 있다.

## 기본 구성 파일

docker-compose.yml 파일의 기본 구조는 다음과 같다.

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

## 실전 개발 환경 구성

### Node.js + MySQL + Redis 환경

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

### React + Spring Boot + PostgreSQL 환경

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

## 유용한 설정

### 볼륨 마운트

소스 코드 변경을 실시간으로 반영한다.

```yaml
volumes:
    - .:/app # 소스 코드 마운트
    - /app/node_modules # node_modules 제외
```

### 환경 변수 파일

민감한 정보는 .env 파일로 분리한다.

```yaml
services:
    web:
        env_file:
            - .env.development
```

### 네트워크 설정

서비스 간 통신을 위한 네트워크를 구성한다.

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

## 개발 편의 기능

### 로그 설정

서비스별 로그를 관리한다.

```yaml
services:
    web:
        logging:
            driver: "json-file"
            options:
                max-size: "10m"
                max-file: "3"
```

### 상태 체크

서비스 의존성을 체크한다.

```yaml
services:
    web:
        healthcheck:
            test: ["CMD", "curl", "-f", "http://localhost:3000/health"]
            interval: 30s
            timeout: 10s
            retries: 3
```

## 실행 명령어

주요 도커 컴포즈 명령어:

```bash
# 서비스 시작
docker-compose up -d

# 서비스 중지
docker-compose down

# 로그 확인
docker-compose logs -f

# 서비스 재시작
docker-compose restart

# 컨테이너 상태 확인
docker-compose ps
```

## 문제 해결

### 볼륨 권한 문제

```yaml
services:
    app:
        user: "1000:1000" # 현재 사용자 UID:GID
```

### 메모리 제한

```yaml
services:
    app:
        deploy:
            resources:
                limits:
                    memory: 512M
```

### 포트 충돌

```yaml
services:
    web:
        ports:
            - "127.0.0.1:3000:3000" # localhost만 접근 가능
```

## 프로덕션 고려사항

1. 환경별 설정 파일 분리

```bash
docker-compose.yml          # 기본 설정
docker-compose.dev.yml      # 개발 환경
docker-compose.prod.yml     # 운영 환경
```

2. 보안 설정

```yaml
services:
    web:
        security_opt:
            - no-new-privileges:true
```

도커 컴포즈는 개발 환경 구성을 단순화한다. 모든 서비스를 하나의 파일로 관리하고 버전 관리 시스템에 포함할 수 있다. 이는 팀 전체의 개발 환경 일관성을 보장한다.
