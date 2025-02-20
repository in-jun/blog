---
title: "도커 이미지 레이어의 이해"
date: 2025-02-17T15:25:00+09:00
tags: ["Docker", "레이어", "이미지", "최적화"]
description: "도커 이미지 레이어의 개념과 동작 원리를 상세히 설명한다."
draft: false
---

## 레이어의 개념과 구조

도커 이미지는 여러 개의 읽기 전용 레이어로 구성된다. 각 레이어는 도커파일의 명령어로 인한 파일 시스템의 변경사항을 저장한다. 이는 Git의 커밋과 유사하다. 변경된 내용만을 저장하여 효율성을 높인다.

도커는 유니온 파일 시스템을 사용하여 여러 레이어를 하나의 파일 시스템으로 마운트한다. 마지막 레이어 위에는 읽고 쓸 수 있는 컨테이너 레이어가 추가된다. 이는 마치 여러 장의 투명 필름을 겹쳐놓은 것과 같다.

## 레이어의 동작 방식

도커파일의 각 명령어는 새로운 레이어를 생성한다. 간단한 예시를 통해 살펴보자.

```dockerfile
FROM ubuntu:20.04      # 레이어 1: 기본 우분투 파일 시스템
RUN apt-get update    # 레이어 2: 패키지 목록 업데이트 내용
RUN apt-get install nginx  # 레이어 3: nginx 파일들
COPY app /app        # 레이어 4: 애플리케이션 파일
```

각 레이어는 이전 레이어로부터의 변경 사항만을 포함한다. 예를 들어 nginx 설치 레이어는 설치된 파일들만 포함하고, 이전 레이어의 파일은 다시 저장하지 않는다.

## 레이어의 특성과 장점

레이어 방식의 주요 이점:

1. 공간 효율성: 동일한 레이어는 여러 이미지가 공유한다. 예를 들어 ubuntu:20.04를 기반으로 하는 여러 이미지는 기본 우분투 레이어를 공유한다.

2. 빌드 캐시: 도커는 레이어 단위로 캐시를 저장한다. 이미지 빌드 시 변경되지 않은 레이어는 캐시를 재사용한다.

3. 증분 전송: 이미지 다운로드 시 이미 존재하는 레이어는 다시 받지 않는다.

## 레이어와 컨테이너 스토리지

컨테이너가 실행될 때의 레이어 구조:

1. 읽기 전용 이미지 레이어들
2. 읽기/쓰기 가능한 컨테이너 레이어
3. 컨테이너에서 파일 수정 시 Copy-on-Write 방식 사용

파일 수정이 발생하면:

1. 원본 파일을 컨테이너 레이어로 복사
2. 복사된 파일을 수정
3. 이후 접근은 수정된 파일로 이루어짐

## 레이어 최적화 전략

효율적인 레이어 구성 방법:

1. 변경이 잦은 레이어는 마지막에 배치:

```dockerfile
# 좋은 예
COPY package.json .
RUN npm install
COPY . .

# 나쁜 예
COPY . .
RUN npm install
```

2. 관련 명령어 통합:

```dockerfile
# 좋은 예
RUN apt-get update && \
    apt-get install -y nginx && \
    apt-get clean

# 나쁜 예
RUN apt-get update
RUN apt-get install -y nginx
RUN apt-get clean
```

3. 불필요한 파일 제거:

```dockerfile
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*
```

## 멀티 스테이지 빌드와 레이어

멀티 스테이지 빌드는 최종 이미지의 레이어를 최소화한다:

```dockerfile
# 빌드 스테이지
FROM node:18 AS builder
WORKDIR /app
COPY . .
RUN npm install
RUN npm run build

# 실행 스테이지
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
```

최종 이미지는 빌드 도구 없이 실행에 필요한 파일만 포함한다.

## 레이어 검사와 분석

도커는 레이어 정보를 확인하는 도구를 제공한다:

```bash
# 레이어 히스토리 확인
docker history nginx:latest

# 레이어 상세 정보
docker inspect nginx:latest
```

이를 통해 각 레이어의:

-   크기
-   생성 명령어
-   생성 시간
-   ID 정보

를 확인할 수 있다.

도커의 레이어 시스템은 컨테이너 기술의 핵심이다. 레이어의 특성을 이해하고 활용하면 효율적인 이미지 관리가 가능하다. 특히 빌드 시간 단축과 디스크 공간 절약에 큰 도움이 된다.
