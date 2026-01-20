---
title: "Docker Compose 완벽 가이드: 멀티 컨테이너 개발 환경 구성의 모든 것"
date: 2025-02-17T22:49:32+09:00
tags: ["Docker Compose", "개발환경", "인프라", "DevOps", "컨테이너", "마이크로서비스"]
description: "Docker Compose의 개념과 역사, YAML 파일 구조, 실전 개발 환경 구성 예제, 네트워크와 볼륨 관리, 환경별 설정 분리, 문제 해결 방법까지 멀티 컨테이너 애플리케이션 관리의 모든 것을 체계적으로 설명하는 완벽 가이드"
draft: false
---

Docker Compose는 다중 컨테이너 Docker 애플리케이션을 정의하고 실행하기 위한 도구로, YAML 파일을 사용하여 애플리케이션의 서비스를 구성하고 단일 명령어로 모든 서비스를 생성하고 시작할 수 있으며, 개발 환경과 프로덕션 환경 간의 일관성을 보장하고 복잡한 멀티 컨테이너 아키텍처를 간단하게 관리할 수 있도록 한다.

## Docker Compose의 개요

> **Docker Compose란?**
>
> Docker Compose는 여러 컨테이너로 구성된 애플리케이션을 정의, 실행, 관리하기 위한 도구로, docker-compose.yml 파일에 서비스, 네트워크, 볼륨을 선언적으로 정의하고 단일 명령어로 전체 애플리케이션 스택을 관리할 수 있다.

### Docker Compose의 역사

| 연도 | 이벤트 | 설명 |
|------|--------|------|
| **2013** | Fig 프로젝트 시작 | Orchard 팀이 Docker 컨테이너 오케스트레이션 도구 Fig 개발 시작 |
| **2014** | Docker의 Fig 인수 | Docker가 Orchard를 인수하고 Fig를 Docker Compose로 리브랜딩 |
| **2015** | Compose v1 안정화 | Docker Compose가 공식 Docker 도구로 통합 |
| **2020** | Compose Specification | Docker Compose 사양이 오픈 표준으로 공개 |
| **2021** | Compose v2 출시 | Go로 재작성된 Compose v2가 Docker CLI 플러그인으로 통합 |
| **2023** | Compose v2 기본화 | docker-compose 명령이 docker compose로 대체되어 기본 도구로 채택 |

### Docker Compose의 필요성

현대 웹 애플리케이션은 단일 컨테이너로 구성되는 경우가 드물며, 일반적으로 웹 서버, 애플리케이션 서버, 데이터베이스, 캐시, 메시지 큐 등 여러 서비스가 협력하여 동작한다. 이러한 멀티 컨테이너 환경을 개별 docker run 명령으로 관리하는 것은 다음과 같은 문제점을 야기한다.

| 문제점 | 설명 |
|--------|------|
| **명령어 복잡성** | 각 컨테이너마다 긴 docker run 명령어를 실행해야 함 |
| **시작 순서 관리** | 서비스 간 의존성에 따른 시작 순서를 수동으로 관리해야 함 |
| **네트워크 구성** | 컨테이너 간 통신을 위한 네트워크를 수동으로 생성하고 연결해야 함 |
| **환경 재현성** | 동일한 환경을 다른 머신에서 재현하기 어려움 |
| **문서화 부재** | 인프라 구성이 명시적으로 문서화되지 않음 |

Docker Compose는 이러한 문제들을 해결하여 선언적 구성 파일을 통해 전체 애플리케이션 스택을 정의하고 관리할 수 있게 한다.

## docker-compose.yml 파일 구조

> **YAML 파일 구조**
>
> docker-compose.yml 파일은 version, services, networks, volumes, configs, secrets 등의 최상위 키로 구성되며, 각 키 아래에 해당 리소스의 세부 설정을 정의한다.

### 기본 파일 구조

```yaml
# Compose 파일 버전 (선택사항, Compose v2에서는 생략 가능)
version: "3.8"

# 서비스 정의 (필수)
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

# 네트워크 정의 (선택사항)
networks:
  frontend:
  backend:

# 볼륨 정의 (선택사항)
volumes:
  db-data:

# 시크릿 정의 (선택사항)
secrets:
  db_password:
    file: ./secrets/db_password.txt
```

### 주요 서비스 옵션

| 옵션 | 설명 | 예시 |
|------|------|------|
| **image** | 사용할 이미지 지정 | `image: nginx:latest` |
| **build** | Dockerfile 경로 지정 | `build: ./app` |
| **ports** | 포트 매핑 | `ports: ["8080:80"]` |
| **volumes** | 볼륨 마운트 | `volumes: ["./data:/data"]` |
| **environment** | 환경 변수 설정 | `environment: ["NODE_ENV=prod"]` |
| **env_file** | 환경 변수 파일 | `env_file: .env` |
| **depends_on** | 서비스 의존성 | `depends_on: ["db", "redis"]` |
| **networks** | 연결할 네트워크 | `networks: ["backend"]` |
| **restart** | 재시작 정책 | `restart: always` |
| **command** | 시작 명령어 오버라이드 | `command: npm start` |
| **healthcheck** | 헬스체크 설정 | 아래 예시 참조 |

## 실전 개발 환경 구성

### Node.js + Express + MySQL + Redis 스택

풀스택 JavaScript 애플리케이션을 위한 완전한 개발 환경 구성 예제이다.

```yaml
version: "3.8"

services:
  # Node.js 애플리케이션
  app:
    build:
      context: .
      dockerfile: Dockerfile.dev
    container_name: node-app
    volumes:
      - .:/app                    # 소스 코드 마운트
      - /app/node_modules         # node_modules 보존
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

  # MySQL 데이터베이스
  mysql:
    image: mysql:8.0
    container_name: mysql-db
    volumes:
      - mysql-data:/var/lib/mysql
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql  # 초기화 스크립트
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

  # Redis 캐시
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

  # Adminer (데이터베이스 관리 UI)
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

### React + Spring Boot + PostgreSQL 스택

프론트엔드와 백엔드가 분리된 풀스택 애플리케이션 구성 예제이다.

```yaml
version: "3.8"

services:
  # React 프론트엔드
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
      - CHOKIDAR_USEPOLLING=true  # 파일 변경 감지 활성화
    depends_on:
      - backend
    networks:
      - frontend-network

  # Spring Boot 백엔드
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
      - "5005:5005"  # 디버그 포트
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

  # PostgreSQL 데이터베이스
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

  # pgAdmin (PostgreSQL 관리 UI)
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

### Django + Celery + RabbitMQ + PostgreSQL 스택

비동기 작업 처리가 필요한 Python 웹 애플리케이션 구성 예제이다.

```yaml
version: "3.8"

services:
  # Django 웹 애플리케이션
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

  # Celery Beat (스케줄러)
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

  # Flower (Celery 모니터링)
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

  # RabbitMQ (메시지 브로커)
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

  # Redis (결과 백엔드)
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

## 고급 설정

### 환경별 설정 파일 분리

> **환경별 Compose 파일**
>
> Docker Compose는 여러 파일을 조합하여 사용할 수 있으며, 기본 설정 파일 위에 환경별 오버라이드 파일을 적용하여 개발, 스테이징, 프로덕션 환경의 차이를 관리할 수 있다.

**기본 설정 (docker-compose.yml):**

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

**개발 환경 오버라이드 (docker-compose.dev.yml):**

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
      - "9229:9229"  # 디버깅 포트
    environment:
      - NODE_ENV=development
      - DEBUG=true

  db:
    ports:
      - "5432:5432"
    environment:
      POSTGRES_PASSWORD: devpassword
```

**프로덕션 환경 오버라이드 (docker-compose.prod.yml):**

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

**환경별 실행 방법:**

```bash
# 개발 환경
docker compose -f docker-compose.yml -f docker-compose.dev.yml up

# 프로덕션 환경
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 헬스체크 설정

헬스체크는 서비스의 상태를 주기적으로 확인하여 비정상 컨테이너를 감지하고, depends_on의 condition과 함께 사용하면 서비스 간 안전한 의존성 관리를 할 수 있다.

```yaml
services:
  web:
    image: nginx
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost/health"]
      interval: 30s      # 체크 주기
      timeout: 10s       # 타임아웃
      retries: 3         # 실패 시 재시도 횟수
      start_period: 40s  # 시작 후 대기 시간

  api:
    build: .
    depends_on:
      web:
        condition: service_healthy
      db:
        condition: service_healthy
```

### 리소스 제한

프로덕션 환경에서는 컨테이너의 리소스 사용량을 제한하여 시스템 안정성을 확보해야 한다.

```yaml
services:
  web:
    image: nginx
    deploy:
      resources:
        limits:
          cpus: "0.5"      # CPU 50% 제한
          memory: 256M     # 메모리 256MB 제한
        reservations:
          cpus: "0.25"     # 최소 CPU 25% 보장
          memory: 128M     # 최소 메모리 128MB 보장
```

### 로깅 설정

컨테이너 로그를 효과적으로 관리하기 위한 설정이다.

```yaml
services:
  web:
    image: nginx
    logging:
      driver: "json-file"
      options:
        max-size: "10m"    # 로그 파일 최대 크기
        max-file: "3"      # 보관할 로그 파일 수
        labels: "production"
        env: "os,customer"
```

## Docker Compose 명령어

### 기본 명령어

| 명령어 | 설명 |
|--------|------|
| `docker compose up` | 서비스 생성 및 시작 |
| `docker compose up -d` | 백그라운드에서 서비스 시작 |
| `docker compose up --build` | 이미지 재빌드 후 시작 |
| `docker compose down` | 서비스 중지 및 컨테이너 삭제 |
| `docker compose down -v` | 볼륨까지 함께 삭제 |
| `docker compose start` | 중지된 서비스 시작 |
| `docker compose stop` | 서비스 중지 (컨테이너 유지) |
| `docker compose restart` | 서비스 재시작 |

### 모니터링 및 디버깅 명령어

| 명령어 | 설명 |
|--------|------|
| `docker compose ps` | 서비스 상태 확인 |
| `docker compose logs` | 모든 서비스 로그 확인 |
| `docker compose logs -f web` | 특정 서비스 로그 실시간 확인 |
| `docker compose top` | 실행 중인 프로세스 확인 |
| `docker compose exec web bash` | 컨테이너 내부 셸 접속 |
| `docker compose run web npm test` | 일회성 명령 실행 |

### 빌드 및 이미지 관리 명령어

| 명령어 | 설명 |
|--------|------|
| `docker compose build` | 서비스 이미지 빌드 |
| `docker compose build --no-cache` | 캐시 없이 빌드 |
| `docker compose pull` | 서비스 이미지 다운로드 |
| `docker compose push` | 서비스 이미지 푸시 |
| `docker compose images` | 서비스 이미지 목록 |

### 실제 사용 예시

```bash
# 개발 환경 시작
docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d

# 특정 서비스만 재빌드
docker compose build --no-cache web

# 로그 확인 (최근 100줄, 실시간)
docker compose logs -f --tail=100

# 데이터베이스 접속
docker compose exec db psql -U postgres -d myapp

# 스케일 조정
docker compose up -d --scale web=3

# 환경 정리 (볼륨 포함)
docker compose down -v --remove-orphans
```

## 문제 해결

### 일반적인 문제와 해결책

| 문제 | 원인 | 해결책 |
|------|------|--------|
| **포트 충돌** | 호스트에서 이미 사용 중인 포트 | 포트 번호 변경 또는 충돌 프로세스 종료 |
| **볼륨 권한 오류** | 컨테이너와 호스트의 사용자 ID 불일치 | `user: "1000:1000"` 설정 추가 |
| **서비스 시작 실패** | 의존 서비스가 아직 준비되지 않음 | healthcheck와 condition 사용 |
| **네트워크 연결 실패** | 잘못된 네트워크 설정 | 네트워크 이름 및 연결 확인 |
| **이미지 빌드 실패** | Dockerfile 오류 또는 컨텍스트 문제 | 빌드 로그 확인 및 Dockerfile 수정 |

### 디버깅 명령어

```bash
# 컨테이너 상세 정보 확인
docker compose ps -a

# 서비스 설정 검증
docker compose config

# 이벤트 로그 확인
docker compose events

# 네트워크 확인
docker network ls
docker network inspect <network_name>

# 볼륨 확인
docker volume ls
docker volume inspect <volume_name>
```

### 성능 최적화 팁

```yaml
# 빌드 캐시 최적화
services:
  web:
    build:
      context: .
      cache_from:
        - myapp:latest

# 불필요한 레이어 제거
services:
  web:
    build:
      target: production  # 멀티스테이지 빌드 타겟 지정
```

## 결론

Docker Compose는 복잡한 멀티 컨테이너 애플리케이션을 선언적으로 정의하고 관리할 수 있는 강력한 도구이다. YAML 파일 하나로 전체 개발 환경을 코드화하여 버전 관리 시스템에 포함시킬 수 있으며, 이를 통해 팀 전체가 동일한 환경에서 작업할 수 있다.

환경별 설정 파일 분리, 헬스체크를 통한 안전한 서비스 시작, 네트워크와 볼륨을 통한 서비스 간 통신 및 데이터 영속성 관리 등 Docker Compose의 다양한 기능을 활용하면 개발 생산성을 크게 향상시킬 수 있다.
