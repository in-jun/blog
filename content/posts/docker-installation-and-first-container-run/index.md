---
title: "도커 설치부터 첫 컨테이너 실행까지"
date: 2025-02-17T22:37:02+09:00
tags: ["Docker", "설치", "컨테이너", "시작하기", "우분투"]
description: "리눅스 환경에서 도커를 설치하고 첫 컨테이너를 실행하는 전체 과정을 단계별로 설명한다."
draft: false
---

## 운영체제 준비

도커는 리눅스 운영체제에서 가장 안정적으로 동작한다. 이 가이드는 우분투 20.04 LTS를 기준으로 한다.

## 도커 설치

### 기존 패키지 제거

시스템에 이전 버전의 도커가 설치되어 있다면 제거한다.

```bash
sudo apt-get remove docker docker-engine docker.io containerd runc
```

### 필수 패키지 설치

도커 설치에 필요한 패키지를 설치한다.

```bash
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

### 도커 공식 GPG 키 추가

도커의 패키지 저장소를 사용하기 위해 GPG 키를 추가한다.

```bash
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

### 도커 저장소 추가

도커 패키지 저장소를 시스템에 등록한다.

```bash
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

### 도커 엔진 설치

도커 엔진과 관련 도구를 설치한다.

```bash
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

## 도커 설정

### 사용자 권한 설정

도커 명령어를 sudo 없이 실행할 수 있게 설정한다.

```bash
sudo usermod -aG docker $USER
newgrp docker
```

### 도커 서비스 시작

도커 서비스를 시작하고 시스템 부팅 시 자동 시작되도록 설정한다.

```bash
sudo systemctl start docker
sudo systemctl enable docker
```

## 설치 확인

도커가 정상적으로 설치되었는지 확인한다.

```bash
docker --version
docker run hello-world
```

## 첫 컨테이너 실행

### nginx 웹 서버 실행

nginx 웹 서버 컨테이너를 실행한다.

```bash
docker run -d -p 80:80 --name webserver nginx
```

이 명령어의 의미:

1. -d: 백그라운드 실행
2. -p 80:80: 호스트의 80 포트와 컨테이너의 80 포트 연결
3. --name webserver: 컨테이너 이름 지정
4. nginx: 사용할 이미지 이름

### 컨테이너 상태 확인

실행 중인 컨테이너 목록을 확인한다.

```bash
docker ps
```

### 컨테이너 로그 확인

컨테이너의 로그를 확인한다.

```bash
docker logs webserver
```

### 컨테이너 접속

실행 중인 컨테이너에 접속한다.

```bash
docker exec -it webserver bash
```

## 기본 도커 명령어

### 이미지 관리

```bash
# 이미지 목록 확인
docker images

# 이미지 다운로드
docker pull ubuntu:20.04

# 이미지 삭제
docker rmi nginx
```

### 컨테이너 관리

```bash
# 컨테이너 중지
docker stop webserver

# 컨테이너 시작
docker start webserver

# 컨테이너 재시작
docker restart webserver

# 컨테이너 삭제
docker rm webserver
```

## 도커 네트워크

### 네트워크 생성

컨테이너 간 통신을 위한 네트워크를 생성한다.

```bash
docker network create mynetwork
```

### 네트워크에 컨테이너 연결

생성한 네트워크에 컨테이너를 연결한다.

```bash
docker run -d --name db --network mynetwork mysql
```

## 도커 볼륨

### 볼륨 생성

데이터 영구 저장을 위한 볼륨을 생성한다.

```bash
docker volume create mydata
```

### 볼륨 마운트

컨테이너에 볼륨을 마운트한다.

```bash
docker run -d \
  --name db \
  -v mydata:/var/lib/mysql \
  mysql
```

## 문제 해결

1. 도커 데몬이 시작되지 않는 경우:

```bash
sudo systemctl status docker
sudo journalctl -u docker
```

2. 권한 문제가 발생하는 경우:

```bash
sudo chown $USER:$USER /var/run/docker.sock
```

3. 디스크 공간 부족:

```bash
docker system prune -a
```

도커는 컨테이너 기술의 진입점이다. 기본적인 설치와 설정만으로도 컨테이너의 장점을 경험할 수 있다. 이후 도커 컴포즈, 도커 스웜, 쿠버네티스로 발전하면서 더 복잡한 컨테이너 환경을 구축할 수 있다.
