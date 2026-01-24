---
title: "우분투 OpenSSH 서버 실행"
date: 2024-08-14T15:16:40+09:00
tags: ["Linux", "Ubuntu", "SSH"]
description: "우분투에서 OpenSSH 서버를 설치하고 구성하는 방법을 다룬다."
draft: false
---

SSH(Secure Shell)는 네트워크 상에서 다른 컴퓨터에 안전하게 접속하여 명령을 실행하고 파일을 전송할 수 있게 해주는 암호화된 네트워크 프로토콜로, 1995년 핀란드 헬싱키 공과대학의 Tatu Ylönen이 텔넷(Telnet)과 rsh(remote shell)의 보안 취약점을 해결하기 위해 개발했으며, 현재는 OpenSSH가 사실상의 표준 구현체로 자리잡아 전 세계 서버 관리의 핵심 도구로 사용되고 있다. Ubuntu에서 SSH 서버를 설치하고 설정하면 로컬 네트워크뿐만 아니라 인터넷을 통해서도 서버에 원격으로 접속하여 관리할 수 있으며, 이 글에서는 OpenSSH 서버의 설치부터 보안 설정까지 전체 과정을 단계별로 설명한다.

## SSH 프로토콜 개요

> **SSH(Secure Shell)란?**
>
> SSH는 암호화된 통신 채널을 통해 원격 시스템에 안전하게 접속하는 프로토콜로, 22번 포트를 기본으로 사용하며 대칭키 암호화, 비대칭키 암호화, 해시 함수를 조합하여 기밀성, 무결성, 인증을 보장한다.

SSH는 초기 SSH-1 프로토콜에서 발전하여 현재 SSH-2가 표준으로 사용되며, SSH-2는 보안 취약점이 개선되고 SFTP(SSH File Transfer Protocol)를 지원하여 파일 전송 기능이 강화되었다. SSH 연결은 클라이언트와 서버 간의 키 교환으로 시작되어 세션 키를 생성하고, 이후 모든 통신은 이 세션 키로 암호화되어 전송된다.

### SSH vs 기존 원격 접속 프로토콜

| 프로토콜 | 암호화 | 포트 | 보안 수준 | 현재 상태 |
|---------|--------|------|----------|----------|
| **Telnet** | 없음 (평문 전송) | 23 | 매우 낮음 | 사용 비권장 |
| **rsh/rlogin** | 없음 | 513/514 | 매우 낮음 | 사용 비권장 |
| **SSH** | AES, ChaCha20 등 | 22 | 높음 | 표준 |
| **Mosh** | AES-128-OCB | UDP 60000+ | 높음 | SSH 보완용 |

### SSH 인증 방식

SSH는 여러 가지 인증 방식을 지원하며, 보안 수준과 편의성에 따라 선택할 수 있다.

| 인증 방식 | 설명 | 보안 수준 | 권장 여부 |
|----------|------|----------|----------|
| **비밀번호 인증** | 사용자 계정 비밀번호로 인증 | 중간 | 내부망 한정 |
| **공개키 인증** | RSA, Ed25519 등 키 쌍 사용 | 높음 | 권장 |
| **인증서 기반** | CA 서명 인증서 사용 | 매우 높음 | 대규모 환경 |
| **GSSAPI/Kerberos** | 중앙 집중 인증 | 높음 | 엔터프라이즈 |

## 사전 준비 사항

SSH 서버를 설치하기 전에 시스템 요구사항을 확인하고 필요한 정보를 수집해야 하며, Ubuntu 데스크톱 또는 서버 버전에서 동일하게 설치할 수 있다.

### 필요 정보

| 항목 | 설명 | 확인 방법 |
|-----|------|----------|
| **서버 IP 주소** | 접속할 서버의 네트워크 주소 | `ip a` 또는 `hostname -I` |
| **사용자 계정** | SSH 접속에 사용할 계정 | `whoami` |
| **네트워크 상태** | 인터넷 또는 로컬 네트워크 연결 | `ping 8.8.8.8` |
| **방화벽 상태** | UFW 활성화 여부 | `sudo ufw status` |

## SSH 서버 설치

### 1단계: 시스템 업데이트 및 OpenSSH 설치

시스템 패키지 목록을 업데이트하고 OpenSSH 서버를 설치하며, 설치가 완료되면 SSH 서비스가 자동으로 시작된다.

```bash
# 패키지 목록 업데이트
sudo apt update

# OpenSSH 서버 설치
sudo apt install openssh-server -y
```

### 2단계: SSH 서비스 상태 확인

설치 후 SSH 서비스가 정상적으로 실행 중인지 확인하고, 부팅 시 자동 시작되도록 설정한다.

```bash
# 서비스 상태 확인
sudo systemctl status ssh

# 서비스가 실행 중이 아니면 시작
sudo systemctl start ssh

# 부팅 시 자동 시작 설정
sudo systemctl enable ssh
```

서비스 상태 출력에서 `Active: active (running)`이 표시되면 SSH 서버가 정상적으로 실행 중인 것이다.

## SSH 서버 설정

> **sshd_config 파일**
>
> `/etc/ssh/sshd_config`는 SSH 데몬(sshd)의 설정 파일로, 포트 번호, 인증 방식, 접속 제한 등 SSH 서버의 모든 동작을 제어한다. 설정 변경 후에는 SSH 서비스를 재시작해야 적용된다.

SSH 설정 파일을 수정하여 보안을 강화하고 필요에 맞게 커스터마이징할 수 있으며, 설정 파일 수정 전에 백업을 권장한다.

```bash
# 설정 파일 백업
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 설정 파일 편집
sudo nano /etc/ssh/sshd_config
```

### 주요 설정 항목

| 설정 항목 | 기본값 | 권장값 | 설명 |
|----------|--------|--------|------|
| **Port** | 22 | 비표준 포트 | SSH 접속 포트 |
| **PermitRootLogin** | prohibit-password | no | 루트 로그인 허용 여부 |
| **PasswordAuthentication** | yes | no (키 인증 시) | 비밀번호 인증 허용 |
| **PubkeyAuthentication** | yes | yes | 공개키 인증 허용 |
| **MaxAuthTries** | 6 | 3 | 최대 인증 시도 횟수 |
| **ClientAliveInterval** | 0 | 300 | 클라이언트 활성 확인 간격(초) |

### 설정 예시

```
# 포트 변경 (기본 22번 대신 사용)
Port 2222

# 루트 로그인 비활성화
PermitRootLogin no

# 비밀번호 인증 비활성화 (공개키 인증 사용 시)
PasswordAuthentication no

# 공개키 인증 활성화
PubkeyAuthentication yes

# 빈 비밀번호 허용 안 함
PermitEmptyPasswords no

# 최대 인증 시도 횟수
MaxAuthTries 3

# 세션 타임아웃 설정
ClientAliveInterval 300
ClientAliveCountMax 2
```

설정 변경 후 SSH 서비스를 재시작하여 적용한다.

```bash
# 설정 문법 검사
sudo sshd -t

# SSH 서비스 재시작
sudo systemctl restart ssh
```

## 방화벽 설정

Ubuntu의 기본 방화벽인 UFW(Uncomplicated Firewall)를 사용하는 경우 SSH 접속을 허용해야 하며, 방화벽이 활성화되어 있지 않으면 이 단계를 건너뛸 수 있다.

```bash
# 방화벽 상태 확인
sudo ufw status

# SSH 허용 (기본 포트 22)
sudo ufw allow ssh

# 비표준 포트 사용 시
sudo ufw allow 2222/tcp

# 방화벽 활성화 (비활성화 상태인 경우)
sudo ufw enable
```

### 특정 IP에서만 SSH 허용

보안을 더욱 강화하려면 특정 IP 주소나 네트워크 대역에서만 SSH 접속을 허용할 수 있다.

```bash
# 특정 IP에서만 SSH 허용
sudo ufw allow from 192.168.1.100 to any port 22

# 특정 서브넷에서만 SSH 허용
sudo ufw allow from 192.168.1.0/24 to any port 22
```

## 공개키 인증 설정

> **공개키 인증이란?**
>
> 공개키 인증은 비대칭 암호화를 사용하는 인증 방식으로, 개인키(private key)는 클라이언트에 보관하고 공개키(public key)를 서버에 등록하여 비밀번호 없이 안전하게 인증하며, 비밀번호보다 훨씬 강력한 보안을 제공한다.

### 클라이언트에서 키 쌍 생성

클라이언트 컴퓨터에서 SSH 키 쌍을 생성하며, Ed25519 알고리즘이 현재 가장 권장되는 알고리즘이다.

```bash
# Ed25519 키 생성 (권장)
ssh-keygen -t ed25519 -C "your_email@example.com"

# RSA 키 생성 (호환성 필요 시)
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

### 키 알고리즘 비교

| 알고리즘 | 키 길이 | 보안 수준 | 성능 | 권장 여부 |
|---------|--------|----------|------|----------|
| **Ed25519** | 256비트 | 매우 높음 | 매우 빠름 | 권장 |
| **RSA** | 4096비트 | 높음 | 보통 | 호환성 필요 시 |
| **ECDSA** | 256/384/521비트 | 높음 | 빠름 | 가능 |
| **DSA** | 1024비트 | 낮음 | 보통 | 사용 비권장 |

### 서버에 공개키 등록

생성된 공개키를 서버에 등록하면 비밀번호 없이 SSH 접속이 가능해진다.

```bash
# 자동으로 공개키 복사 (권장)
ssh-copy-id username@server_ip

# 수동으로 공개키 복사
cat ~/.ssh/id_ed25519.pub | ssh username@server_ip "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

공개키 등록 후 비밀번호 인증을 비활성화하면 보안이 크게 강화된다.

## SSH 접속

### 기본 접속

클라이언트에서 SSH 명령으로 서버에 접속하며, 처음 접속 시 서버의 호스트 키 지문(fingerprint)을 확인하는 메시지가 표시된다.

```bash
# 기본 접속
ssh username@server_ip

# 포트 지정 접속
ssh -p 2222 username@server_ip

# 특정 개인키 사용
ssh -i ~/.ssh/id_ed25519 username@server_ip
```

### SSH 설정 파일로 접속 간소화

`~/.ssh/config` 파일을 생성하여 자주 접속하는 서버의 설정을 저장하면 접속이 간편해진다.

```
Host myserver
    HostName 192.168.1.100
    User ubuntu
    Port 2222
    IdentityFile ~/.ssh/id_ed25519
```

설정 후 `ssh myserver` 명령으로 간단히 접속할 수 있다.

## 보안 강화

### 주요 보안 조치

| 보안 조치 | 효과 | 구현 난이도 |
|----------|------|-----------|
| **비표준 포트 사용** | 자동화된 스캔 회피 | 쉬움 |
| **공개키 인증** | 비밀번호 탈취 방지 | 보통 |
| **루트 로그인 비활성화** | 권한 상승 공격 방지 | 쉬움 |
| **fail2ban 설치** | 무차별 대입 공격 차단 | 보통 |
| **2단계 인증(2FA)** | 추가 인증 계층 | 어려움 |

### fail2ban 설치 및 설정

fail2ban은 로그 파일을 모니터링하여 반복적인 인증 실패를 감지하고 해당 IP를 자동으로 차단하는 도구로, 무차별 대입 공격(brute force attack)에 효과적이다.

```bash
# fail2ban 설치
sudo apt install fail2ban -y

# 서비스 시작 및 활성화
sudo systemctl start fail2ban
sudo systemctl enable fail2ban
```

## 문제 해결

### 일반적인 문제와 해결 방법

| 문제 | 원인 | 해결 방법 |
|-----|------|----------|
| **Connection refused** | SSH 서비스 미실행 또는 방화벽 | `systemctl status ssh`, `ufw status` 확인 |
| **Permission denied** | 인증 실패 또는 키 권한 문제 | 키 권한 확인: `chmod 600 ~/.ssh/id_*` |
| **Host key verification failed** | 서버 키 변경 | `~/.ssh/known_hosts`에서 해당 항목 삭제 |
| **Connection timed out** | 네트워크 문제 또는 잘못된 IP | 네트워크 연결 및 IP 주소 확인 |

SSH 키 파일의 권한이 올바르지 않으면 접속이 거부되므로, 개인키는 소유자만 읽을 수 있도록 설정해야 한다.

```bash
# 개인키 권한 설정
chmod 600 ~/.ssh/id_ed25519

# .ssh 디렉토리 권한 설정
chmod 700 ~/.ssh
```

## 결론

Ubuntu에서 SSH 서버를 설치하고 설정하는 과정을 살펴보았으며, OpenSSH는 1999년 OpenBSD 프로젝트에서 시작되어 현재 가장 널리 사용되는 SSH 구현체로 자리잡았다. SSH는 서버 관리, 원격 개발, 파일 전송 등 다양한 용도로 사용되며, 공개키 인증과 적절한 보안 설정을 통해 안전한 원격 접속 환경을 구축할 수 있다. 인터넷에 노출된 서버의 경우 비표준 포트 사용, 공개키 인증 전용, fail2ban 설치 등의 보안 조치를 반드시 적용하여 무차별 대입 공격과 같은 위협에 대비해야 한다.
