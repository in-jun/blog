---
title: "Docker 이미지 레이어 완벽 가이드: 구조, 원리, 최적화 전략"
date: 2025-02-17T15:25:00+09:00
tags: ["Docker", "레이어", "이미지", "최적화", "컨테이너", "DevOps"]
description: "Docker 이미지 레이어의 개념과 역사, Union File System의 동작 원리, Copy-on-Write 메커니즘, 레이어 캐싱 전략, 멀티 스테이지 빌드, 이미지 최적화 기법까지 Docker 이미지 레이어의 모든 것을 체계적으로 설명하는 완벽 가이드"
draft: false
---

Docker 이미지 레이어(Layer)는 Docker 이미지를 구성하는 기본 단위로, 각 레이어는 파일 시스템의 변경 사항을 캡처하며 이전 레이어 위에 쌓이는 읽기 전용 계층이고, 이러한 레이어들이 Union File System을 통해 단일 파일 시스템으로 통합되어 컨테이너에 제공되므로, 레이어 구조의 이해는 효율적인 이미지 빌드와 스토리지 최적화의 핵심이 된다.

## Docker 이미지 레이어의 개요

> **Docker 이미지 레이어란?**
>
> Docker 이미지 레이어는 Dockerfile의 각 명령어에 의해 생성되는 파일 시스템의 스냅샷으로, 마치 Git의 커밋처럼 이전 상태로부터의 변경 사항만을 저장하여 공간 효율성을 극대화하는 구조이다.

### 레이어 시스템의 역사와 배경

Docker의 레이어 시스템은 Linux의 Union File System 개념에 뿌리를 두고 있으며, 이 기술은 2004년 SUNY Stony Brook 대학의 Erez Zadok 교수 연구팀이 개발한 Unionfs에서 시작되었다. Docker는 초기에 AUFS(Another Union File System)를 사용했으나, 현재는 overlay2가 기본 스토리지 드라이버로 채택되어 Linux 커널 3.18 이상에서 네이티브로 지원된다.

| 연도 | 이벤트 | 설명 |
|------|--------|------|
| **2004** | Unionfs 개발 | 최초의 Union File System 구현 |
| **2006** | AUFS 출시 | Unionfs의 개선 버전으로 Docker 초기에 사용 |
| **2013** | Docker 출시 | AUFS 기반 레이어 시스템 채택 |
| **2014** | overlay 도입 | Linux 커널 3.18에 OverlayFS 통합 |
| **2016** | overlay2 기본화 | Docker 1.12에서 overlay2가 권장 드라이버로 채택 |
| **2020** | 최적화 진행 | overlay2의 성능 개선 및 안정화 완료 |

### 레이어가 필요한 이유

Docker 이미지를 단일 파일 시스템으로 구성하면 여러 가지 비효율이 발생하는데, 레이어 시스템은 다음과 같은 문제들을 해결한다.

| 문제점 | 단일 구조의 한계 | 레이어 시스템의 해결책 |
|--------|------------------|------------------------|
| **저장 공간 낭비** | 동일한 베이스 이미지도 매번 전체 복제 | 공통 레이어 공유로 중복 제거 |
| **빌드 시간 증가** | 코드 한 줄 변경에도 전체 재빌드 필요 | 변경된 레이어만 재빌드 |
| **네트워크 대역폭 소비** | 이미지 전송 시 전체 파일 전송 | 누락된 레이어만 다운로드 |
| **버전 관리 어려움** | 변경 이력 추적 불가 | 각 레이어가 변경 이력 역할 |

## Union File System의 동작 원리

> **Union File System이란?**
>
> Union File System은 여러 개의 디렉토리(브랜치)를 하나의 통합된 파일 시스템 뷰로 마운트하는 기술로, 각 브랜치는 읽기 전용 또는 읽기/쓰기 권한을 가지며 상위 브랜치가 하위 브랜치를 가리는(overlay) 방식으로 동작한다.

### overlay2 스토리지 드라이버

현재 Docker의 기본 스토리지 드라이버인 overlay2는 Linux 커널의 OverlayFS를 기반으로 하며, lowerdir(읽기 전용 하위 레이어), upperdir(읽기/쓰기 상위 레이어), workdir(내부 작업 디렉토리), merged(통합 뷰)의 네 가지 디렉토리로 구성된다.

![overlay2 스토리지 드라이버 구조](overlay-structure.png)

### 레이어 스택의 동작

여러 레이어가 스택처럼 쌓일 때 파일 시스템은 다음과 같은 규칙으로 동작하는데, 상위 레이어의 파일이 하위 레이어의 동일 경로 파일을 가리며(shadow), 파일 삭제는 whiteout 파일로 표시되고, 파일 읽기 시 상위 레이어부터 순차적으로 검색하여 처음 발견된 파일을 반환한다.

```dockerfile
FROM ubuntu:22.04           # 레이어 1: 약 77MB - Ubuntu 기본 파일 시스템
RUN apt-get update          # 레이어 2: 약 45MB - 패키지 캐시 생성
RUN apt-get install -y nginx # 레이어 3: 약 60MB - nginx 바이너리 및 설정
COPY nginx.conf /etc/nginx/  # 레이어 4: 약 1KB - 설정 파일만 포함
COPY app /var/www/html/      # 레이어 5: 가변 - 애플리케이션 파일
```

각 레이어는 이전 레이어로부터의 변경 사항(delta)만을 저장하므로, 레이어 3은 nginx 설치로 추가된 파일들만 포함하고 Ubuntu 기본 파일들은 레이어 1을 참조한다.

## Copy-on-Write 메커니즘

> **Copy-on-Write(CoW)란?**
>
> Copy-on-Write는 리소스 복제를 실제 수정이 발생할 때까지 지연시키는 최적화 기법으로, Docker에서는 컨테이너가 이미지 레이어의 파일을 수정할 때 해당 파일을 컨테이너 레이어로 복사한 후 수정하는 방식으로 구현된다.

### CoW 동작 과정

컨테이너에서 파일을 수정할 때 Copy-on-Write는 다음과 같은 단계로 동작한다.

1. **파일 읽기 요청**: 컨테이너가 `/etc/nginx/nginx.conf` 파일 수정 요청
2. **파일 검색**: 상위 레이어(upperdir)에서 파일 검색, 없으면 하위 레이어(lowerdir) 검색
3. **파일 복사**: lowerdir에서 파일 발견 시 upperdir로 복사 (copy-up)
4. **파일 수정**: upperdir의 복사본에 수정 적용
5. **이후 접근**: 모든 후속 접근은 upperdir의 수정된 파일로 이루어짐

### CoW의 성능 특성

Copy-on-Write 메커니즘은 공간 효율성과 빠른 컨테이너 시작의 장점이 있지만, 대용량 파일의 첫 수정 시 복사 오버헤드가 발생하고, 쓰기 집중 워크로드에서는 성능 저하가 발생할 수 있으므로, 이런 경우에는 볼륨 마운트를 사용하여 CoW 오버헤드를 우회하는 것이 권장된다.

```yaml
# docker-compose.yml - 쓰기 집중 디렉토리에 볼륨 사용
services:
  database:
    image: postgres:15
    volumes:
      - db-data:/var/lib/postgresql/data  # CoW 우회

volumes:
  db-data:
```

## 레이어 캐싱 전략

> **빌드 캐시란?**
>
> Docker 빌드 캐시는 이전 빌드에서 생성된 레이어를 저장하고, 동일한 명령어와 컨텍스트가 감지되면 새로 빌드하는 대신 캐시된 레이어를 재사용하는 메커니즘으로, 빌드 시간을 획기적으로 단축시킨다.

### 캐시 무효화 규칙

Docker는 다음 조건 중 하나라도 만족하면 해당 레이어와 모든 후속 레이어의 캐시를 무효화하는데, 이는 레이어 순서가 빌드 성능에 직접적인 영향을 미친다는 것을 의미한다.

| 조건 | 설명 | 예시 |
|------|------|------|
| **명령어 변경** | Dockerfile 명령어 텍스트가 변경됨 | `RUN apt-get install nginx` → `RUN apt-get install -y nginx` |
| **COPY/ADD 파일 변경** | 복사할 파일의 내용이나 메타데이터 변경 | 소스 코드 수정 |
| **ARG 값 변경** | 빌드 인자 값 변경 | `--build-arg VERSION=2.0` |
| **이전 레이어 무효화** | 선행 레이어가 재빌드됨 | 레이어 1 변경 시 레이어 2~N 모두 재빌드 |

### 캐시 최적화 Dockerfile 작성

캐시 효율을 극대화하기 위해서는 변경 빈도가 낮은 레이어를 먼저 배치하고, 변경이 잦은 레이어는 Dockerfile 하단에 배치해야 한다.

**비효율적인 Dockerfile:**

```dockerfile
FROM node:20-alpine
WORKDIR /app
COPY . .                    # 모든 파일 복사 - 소스 변경 시 캐시 무효화
RUN npm install             # 매번 재실행
RUN npm run build
```

**최적화된 Dockerfile:**

```dockerfile
FROM node:20-alpine
WORKDIR /app

# 의존성 파일만 먼저 복사 (변경 빈도 낮음)
COPY package.json package-lock.json ./
RUN npm ci --only=production    # 의존성 변경 시에만 재실행

# 소스 코드 복사 (변경 빈도 높음)
COPY . .
RUN npm run build
```

최적화된 버전에서는 소스 코드가 변경되어도 `package.json`이 변경되지 않았다면 npm 설치 레이어는 캐시에서 재사용되므로, 빌드 시간이 크게 단축된다.

## 레이어 통합과 최적화

> **레이어 수 최소화**
>
> Dockerfile의 각 RUN, COPY, ADD 명령어는 새로운 레이어를 생성하므로, 관련 명령어를 하나로 통합하면 레이어 수와 이미지 크기를 줄일 수 있다.

### 명령어 통합 기법

여러 RUN 명령어를 `&&`로 연결하고, 같은 레이어 내에서 임시 파일을 삭제하면 최종 이미지 크기를 줄일 수 있다.

**비효율적인 방식:**

```dockerfile
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get install -y curl
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

최적화된 버전은 5개의 레이어 대신 1개의 레이어만 생성하며, 임시 파일(apt 캐시)이 같은 레이어에서 삭제되므로 최종 이미지에 포함되지 않는다.

### .dockerignore 활용

`.dockerignore` 파일을 사용하면 불필요한 파일이 빌드 컨텍스트에 포함되지 않아 빌드 속도가 향상되고 이미지 크기가 줄어든다.

```
# .dockerignore
node_modules
npm-debug.log
.git
.gitignore
README.md
docker-compose*.yml
.env*
*.test.js
coverage/
.nyc_output/
```

## 멀티 스테이지 빌드

> **멀티 스테이지 빌드란?**
>
> 멀티 스테이지 빌드는 하나의 Dockerfile에서 여러 개의 FROM 명령어를 사용하여 빌드 환경과 실행 환경을 분리하는 기법으로, 빌드 도구와 중간 결과물을 최종 이미지에서 제외하여 이미지 크기를 획기적으로 줄일 수 있다.

### 멀티 스테이지 빌드 예시

Go 애플리케이션의 멀티 스테이지 빌드 예시를 통해 빌드 환경과 실행 환경의 분리가 어떻게 이미지 크기를 줄이는지 확인할 수 있다.

```dockerfile
# ===== 빌드 스테이지 =====
FROM golang:1.21-alpine AS builder

WORKDIR /app

# 의존성 파일 복사 및 다운로드
COPY go.mod go.sum ./
RUN go mod download

# 소스 코드 복사 및 빌드
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# ===== 실행 스테이지 =====
FROM alpine:3.19

# 보안을 위한 비루트 사용자 생성
RUN adduser -D -g '' appuser

WORKDIR /app

# 빌드 스테이지에서 바이너리만 복사
COPY --from=builder /app/main .

# 비루트 사용자로 전환
USER appuser

EXPOSE 8080
CMD ["./main"]
```

이 예시에서 빌드 스테이지의 golang:1.21-alpine 이미지는 약 300MB이지만, 최종 실행 이미지는 alpine:3.19 기반으로 약 10MB 정도가 되어 이미지 크기가 97% 이상 감소한다.

### Node.js 멀티 스테이지 빌드

프론트엔드 애플리케이션의 멀티 스테이지 빌드 예시이다.

```dockerfile
# ===== 의존성 스테이지 =====
FROM node:20-alpine AS deps
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci --only=production

# ===== 빌드 스테이지 =====
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# ===== 실행 스테이지 =====
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 레이어 분석 도구

### docker history 명령어

`docker history` 명령어는 이미지의 각 레이어에 대한 정보를 표시하며, 어떤 명령어가 어느 정도의 크기를 차지하는지 파악할 수 있다.

```bash
# 레이어 히스토리 확인
docker history nginx:latest

# 전체 명령어 표시 (잘리지 않음)
docker history --no-trunc nginx:latest

# 크기 기준 정렬을 위한 형식 지정
docker history --format "table {{.Size}}\t{{.CreatedBy}}" nginx:latest
```

출력 예시:

```
IMAGE          CREATED       CREATED BY                                      SIZE
a8758716bb6a   2 weeks ago   CMD ["nginx" "-g" "daemon off;"]                0B
<missing>      2 weeks ago   STOPSIGNAL SIGQUIT                              0B
<missing>      2 weeks ago   EXPOSE 80                                       0B
<missing>      2 weeks ago   ENTRYPOINT ["/docker-entrypoint.sh"]            0B
<missing>      2 weeks ago   COPY 30-tune-worker-processes.sh /docker-ent…   4.62kB
<missing>      2 weeks ago   COPY 20-envsubst-on-templates.sh /docker-ent…   3.02kB
<missing>      2 weeks ago   COPY 10-listen-on-ipv6-by-default.sh /docker…   2.12kB
<missing>      2 weeks ago   COPY docker-entrypoint.sh / # buildkit          1.62kB
<missing>      2 weeks ago   RUN /bin/sh -c set -x     && groupadd --syst…   112MB
<missing>      2 weeks ago   ENV DYNPKG_RELEASE=1~bookworm                   0B
```

### docker inspect 명령어

`docker inspect` 명령어는 이미지의 상세 메타데이터를 JSON 형식으로 제공하며, 레이어 ID, 환경 변수, 볼륨 설정 등을 확인할 수 있다.

```bash
# 레이어 ID 목록 확인
docker inspect --format '{{json .RootFS.Layers}}' nginx:latest | jq .

# 이미지 전체 크기 확인
docker inspect --format '{{.Size}}' nginx:latest

# 가상 크기 (공유 레이어 포함) 확인
docker inspect --format '{{.VirtualSize}}' nginx:latest
```

### dive 도구

dive는 Docker 이미지 레이어를 시각적으로 탐색하고 분석할 수 있는 서드파티 도구로, 각 레이어에서 추가/수정/삭제된 파일을 확인하고 이미지 효율성 점수를 제공한다.

```bash
# dive 설치 (Ubuntu/Debian)
wget https://github.com/wagoodman/dive/releases/download/v0.12.0/dive_0.12.0_linux_amd64.deb
sudo dpkg -i dive_0.12.0_linux_amd64.deb

# 이미지 분석
dive nginx:latest

# CI/CD에서 효율성 검사
CI=true dive nginx:latest --ci-config .dive-ci.yml
```

## 결론

Docker 이미지 레이어 시스템은 효율적인 스토리지 사용, 빠른 이미지 빌드, 신속한 컨테이너 시작의 핵심 기술로, Union File System과 Copy-on-Write 메커니즘을 기반으로 동작한다. 레이어 구조를 이해하고 캐시 최적화, 명령어 통합, 멀티 스테이지 빌드 등의 기법을 적용하면 빌드 시간을 단축하고 이미지 크기를 줄이며 전반적인 개발 및 배포 효율성을 향상시킬 수 있다.

효과적인 Dockerfile 작성을 위해서는 변경 빈도가 낮은 레이어를 먼저 배치하고, 관련 명령어를 통합하며, 멀티 스테이지 빌드로 빌드 환경과 실행 환경을 분리하고, docker history와 dive 같은 도구로 레이어를 분석하여 최적화 기회를 발견하는 것이 중요하다.
