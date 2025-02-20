---
title: "리액트 애플리케이션 도커파일 작성법"
date: 2025-02-17T21:56:12+09:00
tags: ["React", "Docker", "최적화", "배포", "컨테이너"]
description: "리액트 애플리케이션의 효율적인 컨테이너화를 위한 도커파일 작성 방법과 실전 최적화 기법을 설명한다."
draft: false
---

## 도커파일의 필요성

리액트 애플리케이션을 도커 컨테이너로 배포하면 다음과 같은 이점이 있다:

1. 개발 환경과 운영 환경의 일관성 유지
2. 빌드, 테스트, 배포 프로세스의 표준화
3. 확장성과 유연성 향상
4. 환경 변수 관리 용이성

## 기본 도커파일 구조

가장 단순한 형태의 도커파일은 다음과 같다.

```dockerfile
FROM node:18
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build
EXPOSE 3000
CMD ["npm", "start"]
```

이 방식은 동작하지만 최적화되지 않았다. 이미지 크기가 크고 빌드 시간이 길다.

## 멀티 스테이지 빌드 적용

멀티 스테이지 빌드는 최종 이미지의 크기를 줄인다. 빌드 단계와 실행 단계를 분리한다.

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

이 구조는 다음과 같은 이점이 있다:

1. 최종 이미지에는 빌드 도구가 포함되지 않는다
2. nginx는 정적 파일 서빙에 최적화되어 있다
3. 알파인 리눅스 기반 이미지로 크기가 작다

## 캐시 레이어 최적화

도커는 레이어 단위로 캐시를 관리한다. 의존성 설치와 소스 코드 복사를 분리하면 빌드 속도가 향상된다.

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app

# 의존성 파일만 먼저 복사
COPY package*.json ./
RUN npm install

# 나머지 소스 복사
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 환경 변수 처리

리액트 애플리케이션은 빌드 시점에 환경 변수를 포함한다. 도커 빌드 시 환경 변수를 주입할 수 있다.

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=$REACT_APP_API_URL
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## nginx 설정 최적화

싱글 페이지 애플리케이션은 적절한 nginx 설정이 필요하다.

```nginx
server {
    listen 80;
    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

이 설정을 도커파일에 포함한다.

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=builder /app/build /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```
