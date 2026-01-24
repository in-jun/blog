---
title: "우분투 24.04 LTS 고정 IP 설정"
date: 2024-08-10T11:26:57+09:00
tags: ["Ubuntu", "네트워크", "Linux"]
description: "우분투 24.04 LTS에서 고정 IP 주소를 설정하는 방법을 다룬다."
draft: false
---

고정 IP(Static IP) 주소는 DHCP 서버로부터 동적으로 할당받는 대신 네트워크 관리자가 수동으로 지정하는 IP 주소로, 서버 운영, 원격 접속, 네트워크 서비스 호스팅 등 IP 주소가 변경되지 않아야 하는 환경에서 필수적으로 사용된다. Ubuntu 24.04 LTS에서는 Netplan을 기본 네트워크 구성 도구로 사용하며, NetworkManager를 통한 nmcli와 nmtui 인터페이스도 지원하여 사용자가 선호하는 방식으로 네트워크를 설정할 수 있다.

## 고정 IP의 필요성

> **DHCP vs 고정 IP**
>
> DHCP(Dynamic Host Configuration Protocol)는 네트워크에 연결된 장치에 자동으로 IP 주소를 할당하는 프로토콜로 클라이언트 장치에 편리하지만, 서버나 네트워크 장비는 IP 주소가 변경되면 서비스 연결이 끊어지므로 고정 IP가 필수적이다.

고정 IP 주소를 사용하면 서버에 항상 동일한 IP로 접속할 수 있어 SSH 원격 접속, 웹 서버 운영, 데이터베이스 연결 등이 안정적으로 유지되고, DNS 레코드에 IP를 등록하거나 방화벽 규칙을 IP 기반으로 설정할 때도 IP가 변경될 걱정 없이 구성할 수 있다. 또한 네트워크 문제가 발생했을 때 각 장치의 IP가 명확하면 문제 진단과 해결이 용이하고, 로그 분석 시에도 어떤 장치에서 발생한 트래픽인지 쉽게 식별할 수 있다.

### 고정 IP가 필요한 상황

| 상황 | 이유 |
|-----|------|
| **서버 운영** | 웹 서버, DB 서버, 파일 서버 등 서비스 접근점이 변경되면 안됨 |
| **원격 접속** | SSH, RDP 등으로 접속 시 IP가 일정해야 함 |
| **DNS 설정** | 도메인에 연결할 A 레코드에 고정 IP 필요 |
| **방화벽 규칙** | IP 기반 허용/차단 규칙 설정 시 |
| **네트워크 모니터링** | 특정 IP의 트래픽 추적 및 분석 |
| **포트 포워딩** | 라우터에서 특정 IP로 포트 전달 시 |

## 네트워크 설정 방법 비교

Ubuntu 24.04 LTS에서 고정 IP를 설정하는 방법은 크게 세 가지로, 각 방법은 고유한 장단점이 있으며 환경과 사용자 선호도에 따라 선택할 수 있다.

| 방법 | 인터페이스 | 설정 파일 | 적합 환경 |
|-----|-----------|----------|----------|
| **Netplan** | CLI/YAML | /etc/netplan/*.yaml | 서버, 헤드리스 시스템 |
| **nmcli** | CLI | NetworkManager | 원격 관리, 스크립트 자동화 |
| **nmtui** | TUI | NetworkManager | 터미널 환경, 직관적 설정 |

## 사전 준비

고정 IP를 설정하기 전에 현재 네트워크 상태를 확인하고 필요한 정보를 수집해야 한다. 먼저 `ip a` 또는 `ip addr` 명령으로 네트워크 인터페이스 이름과 현재 IP 주소를 확인하고, `ip route` 명령으로 기본 게이트웨이 주소를 확인하며, `cat /etc/resolv.conf` 명령으로 현재 DNS 서버를 확인한다.

### 필요한 정보

| 항목 | 설명 | 예시 |
|-----|------|-----|
| **인터페이스 이름** | 네트워크 장치 식별자 | eth0, ens33, enp0s3 |
| **IP 주소** | 할당할 고정 IP | 192.168.1.100 |
| **서브넷 마스크** | 네트워크 범위 지정 | /24 (255.255.255.0) |
| **게이트웨이** | 네트워크 출구, 라우터 IP | 192.168.1.1 |
| **DNS 서버** | 도메인 이름 해석 서버 | 8.8.8.8, 1.1.1.1 |

## 방법 1: Netplan을 이용한 설정

> **Netplan이란?**
>
> Netplan은 Ubuntu 17.10부터 도입된 네트워크 구성 유틸리티로, YAML 형식의 설정 파일을 사용하여 네트워크를 구성하고 백엔드로 systemd-networkd 또는 NetworkManager를 사용할 수 있으며, 서버 환경에서 주로 사용된다.

Netplan 설정 파일은 `/etc/netplan/` 디렉토리에 위치하며, 파일명은 시스템에 따라 `01-netcfg.yaml`, `50-cloud-init.yaml`, `00-installer-config.yaml` 등 다양할 수 있으므로 `ls /etc/netplan/` 명령으로 확인한 후 해당 파일을 편집해야 한다.

### 설정 파일 구조

Netplan 설정 파일은 YAML 형식으로 작성되며, 들여쓰기에 민감하므로 탭 대신 스페이스(2칸 또는 4칸)를 사용해야 하고 콜론(:) 뒤에는 반드시 공백이 있어야 한다.

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
```

### 설정 항목 설명

| 항목 | 설명 |
|-----|------|
| **version: 2** | Netplan 버전 (항상 2 사용) |
| **renderer** | 백엔드 선택 (networkd 또는 NetworkManager) |
| **ethernets** | 유선 네트워크 인터페이스 설정 |
| **dhcp4: no** | DHCP 비활성화하여 수동 설정 |
| **addresses** | 할당할 IP 주소와 서브넷 마스크 |
| **routes** | 라우팅 설정, default는 기본 게이트웨이 |
| **nameservers** | DNS 서버 목록 |

### 설정 적용

설정 파일을 저장한 후 `sudo netplan apply` 명령으로 변경 사항을 적용하며, 문법 오류가 있으면 오류 메시지가 출력되고 원래 설정으로 롤백된다. 설정 적용 전에 `sudo netplan try` 명령을 사용하면 120초 후 자동으로 원래 설정으로 돌아가므로 원격 접속 환경에서 안전하게 테스트할 수 있다.

## 방법 2: nmcli를 이용한 설정

nmcli(NetworkManager Command Line Interface)는 NetworkManager를 제어하는 CLI 도구로, 스크립트를 통한 자동화가 가능하고 원격 SSH 세션에서도 안정적으로 네트워크를 설정할 수 있다.

### 현재 연결 확인

먼저 `nmcli connection show` 명령으로 현재 네트워크 연결 목록을 확인하고 수정할 연결의 이름을 파악한다.

### 고정 IP 설정 명령

```bash
# IP 주소 설정
sudo nmcli connection modify "연결이름" ipv4.addresses 192.168.1.100/24

# 게이트웨이 설정
sudo nmcli connection modify "연결이름" ipv4.gateway 192.168.1.1

# DNS 설정
sudo nmcli connection modify "연결이름" ipv4.dns "8.8.8.8 8.8.4.4"

# 수동 설정 모드로 변경
sudo nmcli connection modify "연결이름" ipv4.method manual

# 변경 사항 적용
sudo nmcli connection up "연결이름"
```

연결 이름에 공백이 있는 경우(예: "Wired connection 1") 따옴표로 감싸야 하며, 모든 설정을 한 번에 적용하려면 `nmcli connection modify` 명령에 여러 옵션을 연결하여 사용할 수 있다.

## 방법 3: nmtui를 이용한 설정

nmtui(NetworkManager Text User Interface)는 터미널에서 실행되는 텍스트 기반 사용자 인터페이스로, 시각적으로 설정 항목을 확인하면서 네트워크를 구성할 수 있어 명령어에 익숙하지 않은 사용자에게 유용하다.

### nmtui 사용 절차

`sudo nmtui` 명령으로 인터페이스를 실행한 후 "Edit a connection"을 선택하고 수정할 네트워크 연결을 선택한다. IPv4 CONFIGURATION 섹션에서 `<Automatic>`을 `<Manual>`로 변경하고 `<Show>`를 눌러 세부 설정을 펼친 다음, Addresses에 IP와 서브넷 마스크(예: 192.168.1.100/24), Gateway에 게이트웨이 주소, DNS servers에 DNS 서버 주소를 입력한다. `<OK>`를 선택하여 저장하고 `<Back>` → `<Quit>`로 종료한 뒤, `sudo nmcli connection up "연결이름"` 명령으로 변경 사항을 적용한다.

## 설정 확인

고정 IP 설정 후 다음 명령들로 설정이 올바르게 적용되었는지 확인한다.

| 확인 항목 | 명령 | 예상 결과 |
|----------|-----|----------|
| **IP 주소** | `ip a` | 설정한 IP 주소 표시 |
| **게이트웨이** | `ip route` | default via 게이트웨이주소 |
| **DNS** | `cat /etc/resolv.conf` | nameserver DNS주소 |
| **인터넷 연결** | `ping -c 4 8.8.8.8` | 패킷 손실 없음 |
| **DNS 해석** | `ping -c 4 google.com` | 도메인으로 ping 성공 |

## 문제 해결

### 일반적인 문제와 해결 방법

| 문제 | 원인 | 해결 방법 |
|-----|------|----------|
| **netplan apply 오류** | YAML 문법 오류 | 들여쓰기 확인, 탭 대신 스페이스 사용 |
| **인터넷 연결 안됨** | 게이트웨이 오류 | `ip route`로 게이트웨이 확인, 라우터 IP 확인 |
| **도메인 해석 안됨** | DNS 설정 오류 | DNS 서버 주소 확인, 8.8.8.8로 테스트 |
| **IP 충돌** | 같은 IP 사용 장치 존재 | 네트워크에서 사용 중인 IP 확인 후 변경 |
| **설정 후 연결 끊김** | 잘못된 IP 설정 | 콘솔 접속 후 설정 수정 |

Netplan 설정 후 원격 연결이 끊어진 경우, 물리적으로 시스템에 접근하여 설정 파일을 수정하거나 `sudo netplan try` 명령을 사용하여 자동 롤백 기능을 활용해야 한다. NetworkManager를 재시작하려면 `sudo systemctl restart NetworkManager` 명령을 사용하고, 네트워크 서비스 전체를 재시작하려면 `sudo systemctl restart systemd-networkd` 명령을 실행한다.

## 결론

Ubuntu 24.04 LTS에서 고정 IP를 설정하는 방법은 Netplan, nmcli, nmtui 세 가지가 있으며, 각각 서버 환경의 YAML 기반 설정, 스크립트 자동화가 필요한 CLI 환경, 직관적인 TUI 환경에 적합하다. 고정 IP를 설정하면 서버 운영, 원격 접속, 네트워크 서비스 호스팅이 안정적으로 유지되고 네트워크 관리가 용이해지므로, 서버나 네트워크 장비를 운영하는 환경에서는 고정 IP 설정을 권장한다.
