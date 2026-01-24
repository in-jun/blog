---
title: "Docker 설치와 첫 컨테이너 실행"
date: 2025-02-17T22:37:02+09:00
tags: ["Docker", "컨테이너", "Linux"]
description: "우분투에서 Docker를 설치하고 컨테이너를 실행하는 방법을 설명한다."
draft: false
---

Docker는 컨테이너 기반 애플리케이션을 개발, 배포, 실행하기 위한 플랫폼으로, 리눅스 커널의 네임스페이스와 cgroups를 활용하여 격리된 환경에서 애플리케이션을 실행하며, 이 가이드에서는 우분투 리눅스에서 Docker를 설치하고 첫 컨테이너를 실행하는 전체 과정을 단계별로 설명한다.

## Docker 설치 전 요구사항

> **Docker 설치 요구사항**
>
> Docker Engine은 64비트 리눅스 시스템에서 실행되며, 커널 버전 3.10 이상이 필요하다. 우분투의 경우 20.04 LTS, 22.04 LTS, 24.04 LTS 버전이 공식 지원된다.

### 지원되는 우분투 버전

| 우분투 버전 | 코드명 | 지원 상태 | 권장 여부 |
|------------|--------|----------|----------|
| **Ubuntu 24.04 LTS** | Noble Numbat | 공식 지원 | 권장 |
| **Ubuntu 22.04 LTS** | Jammy Jellyfish | 공식 지원 | 권장 |
| **Ubuntu 20.04 LTS** | Focal Fossa | 공식 지원 | 지원 |
| Ubuntu 23.10 | Mantic Minotaur | 공식 지원 | 비LTS |
| Ubuntu 18.04 LTS | Bionic Beaver | 지원 종료 예정 | 비권장 |

### 시스템 아키텍처 지원

Docker는 다양한 CPU 아키텍처를 지원하며, 각 아키텍처에 따라 설치 방법이 약간 다를 수 있다.

| 아키텍처 | 설명 | 지원 여부 |
|----------|------|----------|
| **x86_64 / amd64** | 일반적인 데스크탑/서버 CPU | 완전 지원 |
| **arm64 / aarch64** | ARM 기반 서버 (AWS Graviton, Apple M 시리즈 등) | 완전 지원 |
| **armhf** | 32비트 ARM (Raspberry Pi 등) | 제한적 지원 |
| **s390x** | IBM Z 시리즈 메인프레임 | 완전 지원 |

## Docker 설치 과정

### Step 1: 기존 Docker 패키지 제거

새로운 Docker 설치 전에 시스템에 설치되어 있을 수 있는 비공식 Docker 패키지나 이전 버전을 제거해야 하며, 이는 패키지 충돌을 방지하고 깨끗한 설치 환경을 보장한다.

```bash
# 기존 Docker 관련 패키지 제거
sudo apt-get remove docker docker-engine docker.io containerd runc

# 제거 후에도 /var/lib/docker/ 디렉토리의 이미지, 컨테이너, 볼륨은 유지됨
# 완전 삭제가 필요한 경우:
# sudo rm -rf /var/lib/docker
# sudo rm -rf /var/lib/containerd
```

### Step 2: 필수 패키지 설치

Docker 저장소를 HTTPS로 접근하기 위해 필요한 패키지들을 설치한다.

```bash
# 패키지 목록 업데이트
sudo apt-get update

# 필수 패키지 설치
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

각 패키지의 역할은 다음과 같다.

| 패키지 | 역할 |
|--------|------|
| **apt-transport-https** | APT가 HTTPS를 통해 패키지를 다운로드할 수 있게 함 |
| **ca-certificates** | SSL 인증서 검증을 위한 CA 인증서 번들 |
| **curl** | URL을 통한 데이터 전송 도구 |
| **gnupg** | GPG 키 관리 및 서명 검증 |
| **lsb-release** | Linux 배포판 정보 확인 유틸리티 |

### Step 3: Docker 공식 GPG 키 추가

Docker 패키지의 무결성과 신뢰성을 검증하기 위해 Docker의 공식 GPG 키를 시스템에 추가해야 하며, 이 키는 패키지가 Docker에 의해 서명되었음을 확인하는 데 사용된다.

```bash
# Docker의 공식 GPG 키 다운로드 및 설치
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
```

### Step 4: Docker 저장소 추가

Docker 패키지를 다운로드할 저장소를 APT 소스 목록에 추가한다.

```bash
# Docker 저장소 추가
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### Step 5: Docker Engine 설치

저장소가 추가되면 Docker Engine과 관련 구성 요소를 설치할 수 있다.

```bash
# 패키지 목록 업데이트
sudo apt-get update

# Docker Engine, CLI, containerd, Docker Compose 플러그인 설치
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

설치되는 패키지의 역할은 다음과 같다.

| 패키지 | 역할 |
|--------|------|
| **docker-ce** | Docker Engine (Community Edition) |
| **docker-ce-cli** | Docker 명령줄 인터페이스 |
| **containerd.io** | 컨테이너 런타임 |
| **docker-buildx-plugin** | 확장된 빌드 기능 (멀티 플랫폼 빌드 등) |
| **docker-compose-plugin** | Docker Compose V2 플러그인 |

## Docker 설정

### 비루트 사용자로 Docker 실행

> **Docker 그룹 권한**
>
> 기본적으로 Docker 데몬은 root 권한으로 실행되며, docker 명령어도 sudo가 필요하다. 보안과 편의성을 위해 현재 사용자를 docker 그룹에 추가하면 sudo 없이 Docker 명령어를 실행할 수 있다.

```bash
# docker 그룹에 현재 사용자 추가
sudo usermod -aG docker $USER

# 그룹 변경 적용 (로그아웃 없이 적용)
newgrp docker

# 또는 시스템 재시작
# sudo reboot
```

### Docker 서비스 관리

Docker 서비스를 시작하고 시스템 부팅 시 자동으로 시작되도록 설정한다.

```bash
# Docker 서비스 시작
sudo systemctl start docker

# 부팅 시 자동 시작 설정
sudo systemctl enable docker

# Docker 서비스 상태 확인
sudo systemctl status docker
```

출력 예시:

```
● docker.service - Docker Application Container Engine
     Loaded: loaded (/lib/systemd/system/docker.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2025-01-20 10:00:00 KST; 1min ago
       Docs: https://docs.docker.com
   Main PID: 1234 (dockerd)
      Tasks: 10
     Memory: 100.0M
        CPU: 500ms
     CGroup: /system.slice/docker.service
             └─1234 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
```

## 설치 확인

### Docker 버전 확인

```bash
# Docker 버전 확인
docker --version

# 상세 버전 정보
docker version
```

상세 버전 정보 출력 예시:

```
Client: Docker Engine - Community
 Version:           24.0.7
 API version:       1.43
 Go version:        go1.20.10
 Git commit:        afdd53b
 Built:             Thu Oct 26 09:07:41 2023
 OS/Arch:           linux/amd64
 Context:           default

Server: Docker Engine - Community
 Engine:
  Version:          24.0.7
  API version:      1.43 (minimum version 1.12)
  Go version:       go1.20.10
  Git commit:       311b9ff
  Built:            Thu Oct 26 09:07:41 2023
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.6.24
  GitCommit:        61f9fd88f79f081d64d6fa3bb1a0dc71ec870523
 runc:
  Version:          1.1.9
  GitCommit:        v1.1.9-0-gccaecfc
 docker-init:
  Version:          0.19.0
  GitCommit:        de40ad0
```

### hello-world 컨테이너 실행

Docker가 정상적으로 작동하는지 확인하기 위해 공식 hello-world 이미지를 실행한다.

```bash
docker run hello-world
```

출력 예시:

```
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
c1ec31eb5944: Pull complete
Digest: sha256:4bd78111b6914a99dbc560e6a20eab57ff6655aea4a80c50b0c5491968cbc2e6
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.
```

## 첫 컨테이너 실행하기

### Nginx 웹 서버 실행

실용적인 예제로 Nginx 웹 서버 컨테이너를 실행해 보겠다.

```bash
# Nginx 컨테이너 실행
docker run -d -p 8080:80 --name my-nginx nginx:latest
```

이 명령어의 각 옵션 설명은 다음과 같다.

| 옵션 | 설명 |
|------|------|
| **-d** | 백그라운드(detached) 모드로 실행 |
| **-p 8080:80** | 호스트의 8080 포트를 컨테이너의 80 포트에 매핑 |
| **--name my-nginx** | 컨테이너에 'my-nginx'라는 이름 부여 |
| **nginx:latest** | 사용할 이미지와 태그 지정 |

웹 브라우저에서 `http://localhost:8080`으로 접속하면 Nginx 기본 페이지가 표시된다.

### 컨테이너 상태 확인

```bash
# 실행 중인 컨테이너 목록
docker ps

# 모든 컨테이너 목록 (중지된 컨테이너 포함)
docker ps -a
```

출력 예시:

```
CONTAINER ID   IMAGE          COMMAND                  CREATED         STATUS         PORTS                                   NAMES
a1b2c3d4e5f6   nginx:latest   "/docker-entrypoint.…"   2 minutes ago   Up 2 minutes   0.0.0.0:8080->80/tcp, :::8080->80/tcp   my-nginx
```

### 컨테이너 로그 확인

```bash
# 컨테이너 로그 확인
docker logs my-nginx

# 실시간 로그 스트리밍 (-f: follow)
docker logs -f my-nginx

# 최근 100줄만 표시
docker logs --tail 100 my-nginx
```

### 컨테이너 내부 접속

```bash
# 컨테이너 내부에서 bash 셸 실행
docker exec -it my-nginx bash

# 컨테이너 내부에서 명령어 실행
docker exec my-nginx cat /etc/nginx/nginx.conf
```

## 필수 Docker 명령어

### 이미지 관리 명령어

```bash
# 로컬 이미지 목록 확인
docker images

# 이미지 다운로드 (pull)
docker pull ubuntu:22.04
docker pull python:3.11-slim

# 이미지 검색
docker search nginx

# 이미지 삭제
docker rmi nginx:latest

# 사용하지 않는 이미지 정리
docker image prune

# 모든 미사용 이미지 삭제
docker image prune -a
```

### 컨테이너 관리 명령어

```bash
# 컨테이너 생성 및 실행
docker run -d --name myapp nginx

# 컨테이너 중지
docker stop my-nginx

# 컨테이너 시작
docker start my-nginx

# 컨테이너 재시작
docker restart my-nginx

# 컨테이너 삭제 (중지된 컨테이너만)
docker rm my-nginx

# 실행 중인 컨테이너 강제 삭제
docker rm -f my-nginx

# 모든 중지된 컨테이너 삭제
docker container prune
```

### 시스템 정보 및 정리

```bash
# Docker 시스템 정보
docker info

# 디스크 사용량 확인
docker system df

# 상세 디스크 사용량
docker system df -v

# 사용하지 않는 모든 리소스 정리 (이미지, 컨테이너, 네트워크, 캐시)
docker system prune

# 볼륨까지 포함하여 정리
docker system prune --volumes
```

## Docker 네트워크

> **Docker 네트워크란?**
>
> Docker 네트워크는 컨테이너 간 통신을 관리하는 가상 네트워크 인프라로, 컨테이너를 격리하거나 연결하여 마이크로서비스 아키텍처를 구현할 수 있게 한다.

### 네트워크 유형

| 네트워크 드라이버 | 설명 | 사용 사례 |
|------------------|------|----------|
| **bridge** | 기본 네트워크, 동일 호스트 내 컨테이너 통신 | 단일 호스트 애플리케이션 |
| **host** | 호스트 네트워크 직접 사용, 격리 없음 | 성능이 중요한 애플리케이션 |
| **none** | 네트워크 비활성화 | 완전히 격리된 컨테이너 |
| **overlay** | 여러 Docker 호스트 간 네트워크 | Docker Swarm, 멀티 호스트 |
| **macvlan** | 컨테이너에 MAC 주소 할당 | 레거시 애플리케이션 |

### 네트워크 생성 및 관리

```bash
# 네트워크 목록 확인
docker network ls

# 사용자 정의 브리지 네트워크 생성
docker network create my-network

# 서브넷 지정하여 네트워크 생성
docker network create --subnet=172.20.0.0/16 my-custom-network

# 네트워크에 컨테이너 연결하여 실행
docker run -d --name app --network my-network nginx

# 기존 컨테이너를 네트워크에 연결
docker network connect my-network my-nginx

# 네트워크에서 컨테이너 분리
docker network disconnect my-network my-nginx

# 네트워크 상세 정보
docker network inspect my-network

# 네트워크 삭제
docker network rm my-network
```

### 컨테이너 간 통신 예제

```bash
# 네트워크 생성
docker network create app-network

# 데이터베이스 컨테이너 실행
docker run -d \
    --name mysql-db \
    --network app-network \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=myapp \
    mysql:8.0

# 애플리케이션 컨테이너 실행 (같은 네트워크)
docker run -d \
    --name web-app \
    --network app-network \
    -e DB_HOST=mysql-db \
    -p 8080:8080 \
    my-web-app:latest

# 같은 네트워크 내에서는 컨테이너 이름으로 통신 가능
# web-app 컨테이너에서 mysql-db:3306으로 접속 가능
```

## Docker 볼륨

> **Docker 볼륨이란?**
>
> Docker 볼륨은 컨테이너의 데이터를 영구적으로 저장하기 위한 메커니즘으로, 컨테이너가 삭제되어도 데이터가 유지되며, 여러 컨테이너 간에 데이터를 공유할 수 있다.

### 데이터 저장 방식 비교

| 저장 방식 | 설명 | 사용 사례 |
|----------|------|----------|
| **볼륨 (volume)** | Docker가 관리하는 저장소 | 프로덕션 데이터베이스, 영구 데이터 |
| **바인드 마운트 (bind mount)** | 호스트 파일 시스템의 특정 경로 마운트 | 개발 환경, 설정 파일 |
| **tmpfs 마운트** | 메모리에만 저장 (Linux) | 민감한 임시 데이터 |

### 볼륨 생성 및 관리

```bash
# 볼륨 목록 확인
docker volume ls

# 볼륨 생성
docker volume create my-data

# 볼륨 상세 정보
docker volume inspect my-data

# 볼륨을 사용하여 컨테이너 실행
docker run -d \
    --name postgres-db \
    -v my-data:/var/lib/postgresql/data \
    -e POSTGRES_PASSWORD=secret \
    postgres:15

# 바인드 마운트 사용 (호스트 디렉토리 연결)
docker run -d \
    --name dev-nginx \
    -v $(pwd)/html:/usr/share/nginx/html:ro \
    -p 8080:80 \
    nginx

# 볼륨 삭제
docker volume rm my-data

# 사용하지 않는 볼륨 정리
docker volume prune
```

### 데이터베이스 데이터 영구 저장 예제

```bash
# PostgreSQL 데이터를 볼륨에 저장
docker volume create postgres-data

docker run -d \
    --name postgres \
    -v postgres-data:/var/lib/postgresql/data \
    -e POSTGRES_USER=admin \
    -e POSTGRES_PASSWORD=secret \
    -e POSTGRES_DB=myapp \
    -p 5432:5432 \
    postgres:15

# 컨테이너를 삭제해도 데이터는 유지됨
docker rm -f postgres

# 같은 볼륨으로 새 컨테이너 실행하면 데이터 복원
docker run -d \
    --name postgres-new \
    -v postgres-data:/var/lib/postgresql/data \
    -p 5432:5432 \
    postgres:15
```

## 문제 해결

### Docker 데몬 문제

```bash
# Docker 서비스 상태 확인
sudo systemctl status docker

# Docker 데몬 로그 확인
sudo journalctl -u docker.service -f

# Docker 데몬 재시작
sudo systemctl restart docker
```

### 권한 문제

```bash
# "permission denied" 오류 발생 시
# 1. docker 그룹에 사용자 추가 확인
groups $USER

# 2. 그룹이 없으면 추가
sudo usermod -aG docker $USER

# 3. 재로그인 또는 newgrp 실행
newgrp docker
```

### 디스크 공간 부족

```bash
# Docker 디스크 사용량 확인
docker system df

# 사용하지 않는 리소스 정리
docker system prune -a --volumes

# 특정 이미지 삭제
docker rmi $(docker images -q -f "dangling=true")

# 중지된 컨테이너 전체 삭제
docker rm $(docker ps -a -q -f "status=exited")
```

### 네트워크 문제

```bash
# 네트워크 상태 확인
docker network ls
docker network inspect bridge

# 컨테이너 IP 확인
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' my-nginx

# DNS 해결 테스트
docker run --rm alpine nslookup google.com
```

## 다음 단계

Docker 기본 설치와 사용법을 익힌 후에는 다음 주제들을 학습하면 컨테이너 기술을 더 효과적으로 활용할 수 있다.

| 다음 단계 | 설명 |
|----------|------|
| **Dockerfile 작성** | 커스텀 이미지 빌드 방법 |
| **Docker Compose** | 멀티 컨테이너 애플리케이션 관리 |
| **Docker 이미지 최적화** | 이미지 크기 줄이기, 빌드 캐싱 |
| **Docker 보안** | 보안 모범 사례, 취약점 스캔 |
| **Kubernetes** | 컨테이너 오케스트레이션 플랫폼 |

## 결론

Docker 설치는 컨테이너 기술을 시작하는 첫 단계이며, 공식 저장소를 통한 설치가 가장 안정적이고 최신 버전을 유지할 수 있는 방법이다. 기본적인 컨테이너 실행, 이미지 관리, 네트워크 및 볼륨 구성을 익히면 복잡한 마이크로서비스 아키텍처도 효과적으로 구축할 수 있다.

Docker는 개발 환경의 일관성을 보장하고 배포 프로세스를 단순화하며, 리소스 효율성을 높이는 강력한 도구로서 현대 소프트웨어 개발에서 필수적인 기술이 되었다.
