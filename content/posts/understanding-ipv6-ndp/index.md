---
title: "IPv6 NDP 이웃 탐색 프로토콜"
date: 2025-02-24T01:01:25+09:00
draft: false
description: "IPv6 Neighbor Discovery Protocol의 동작 원리를 설명한다."
tags: ["네트워크", "IPv6", "프로토콜"]
---

## NDP란 무엇인가

NDP(Neighbor Discovery Protocol)는 2007년 IETF의 RFC 4861 문서를 통해 공식적으로 표준화된 IPv6 네트워크의 핵심 프로토콜로, IPv4에서 사용되던 ARP(Address Resolution Protocol), ICMP Router Discovery, ICMP Redirect 등 여러 프로토콜의 기능을 하나로 통합하여 더욱 효율적이고 안전한 네트워크 관리를 가능하게 하며, ICMPv6(Internet Control Message Protocol version 6)를 기반으로 동작하여 이웃 노드 탐색, 라우터 발견, 주소 자동 구성, 주소 중복 검사, 경로 최적화 등 다양한 기능을 수행한다.

IPv4 환경에서는 ARP, DHCP, ICMP 등 여러 프로토콜이 독립적으로 동작하여 네트워크 관리가 복잡했지만, IPv6에서는 NDP가 이러한 기능들을 통합하여 제공함으로써 프로토콜 스택을 단순화하고 보안성을 강화했으며, 특히 멀티캐스트(multicast) 기반 통신을 사용하여 IPv4의 브로드캐스트(broadcast) 방식보다 네트워크 효율성이 크게 향상되었고, 이는 대규모 네트워크 환경에서 불필요한 트래픽을 줄이고 전력 소비를 절감하는 데 기여한다.

## NDP의 등장 배경과 IPv4와의 차이점

IPv4 네트워크에서는 주소 해결(ARP), 라우터 발견(ICMP Router Discovery), 주소 할당(DHCP), 경로 재지정(ICMP Redirect) 등 각 기능을 수행하기 위해 별도의 프로토콜이 필요했고, 이는 네트워크 복잡도를 증가시키고 보안 취약점을 만드는 원인이 되었으며, 특히 ARP는 인증 메커니즘이 없어 스푸핑 공격에 취약했다.

IPv6 설계 시 IETF는 이러한 문제점을 해결하기 위해 NDP를 도입했으며, 다음과 같은 주요 개선사항을 반영했다:

**IPv4에서 IPv6로의 전환**:
- **ARP → NDP Neighbor Solicitation/Advertisement**: 브로드캐스트 대신 멀티캐스트 사용
- **DHCP → SLAAC (Stateless Address Autoconfiguration)**: 서버 없이 자동 주소 구성
- **ICMP Router Discovery → NDP Router Solicitation/Advertisement**: 통합된 라우터 발견 메커니즘
- **ICMP Redirect → NDP Redirect**: 향상된 경로 최적화

**주요 개선사항**:
1. **보안 강화**: SEND(SEcure Neighbor Discovery) 프로토콜을 통한 암호화 인증 지원
2. **네트워크 효율성**: 멀티캐스트 사용으로 불필요한 트래픽 감소 (브로드캐스트 대비 99% 이상 감소)
3. **자동화**: SLAAC를 통한 완전 자동 주소 구성, DHCP 서버 불필요
4. **확장성**: 대규모 네트워크에서도 효율적인 동작
5. **모바일 지원**: Mobile IPv6와 통합되어 이동성 지원

## NDP의 핵심 기능

![NDP 메시지 유형과 기능](ndp-messages.png)

NDP는 IPv6 네트워크에서 다음과 같은 핵심 기능을 수행하며, 이는 네트워크 통신이 정상적으로 이루어지기 위한 필수 요소다.

### 1. 라우터 발견 (Router Discovery)

호스트가 네트워크에 연결될 때 로컬 링크의 라우터를 자동으로 찾고, 라우터로부터 네트워크 프리픽스(prefix), MTU(Maximum Transmission Unit), 홉 제한(hop limit) 등의 구성 정보를 얻으며, 이를 통해 수동 게이트웨이 설정 없이도 외부 네트워크와 통신할 수 있다.

**동작 메커니즘**:
- 호스트는 Router Solicitation (RS) 메시지를 All-Routers 멀티캐스트 주소(FF02::2)로 전송
- 라우터는 Router Advertisement (RA) 메시지로 응답하거나 주기적으로(기본 200초마다) 브로드캐스트
- RA 메시지에는 네트워크 프리픽스, 기본 게이트웨이 정보, MTU, 주소 구성 플래그 등 포함

### 2. 주소 자동 구성 (Stateless Address Autoconfiguration, SLAAC)

호스트가 DHCP 서버 없이도 라우터로부터 받은 프리픽스와 자신의 인터페이스 ID를 결합하여 유일한 글로벌 유니캐스트 주소를 자동으로 생성하며, 이는 대규모 네트워크에서 주소 관리 부담을 크게 줄이고 플러그 앤 플레이(Plug and Play) 방식의 네트워크 연결을 가능하게 한다.

**주소 생성 방법**:
- **EUI-64 방식**: MAC 주소(48비트)를 64비트 인터페이스 ID로 변환
  - MAC 주소 중간에 FFFE 삽입: `00:11:22:33:44:55` → `02:11:22:FF:FE:33:44:55`
  - 7번째 비트 반전 (Universal/Local bit)
- **Privacy Extensions (RFC 4941)**: 무작위 인터페이스 ID 생성으로 프라이버시 보호
- **Stable Privacy (RFC 7217)**: 안정적이면서도 프라이버시를 보호하는 주소 생성

### 3. 이웃 노드 주소 해결 (Neighbor Address Resolution)

IPv4의 ARP를 대체하여 IPv6 주소를 Link-Layer 주소(MAC 주소)로 변환하는 기능으로, Neighbor Solicitation (NS)과 Neighbor Advertisement (NA) 메시지를 사용하며, 브로드캐스트 대신 Solicited-Node 멀티캐스트 주소를 사용하여 네트워크 효율성을 크게 향상시킨다.

**Solicited-Node 멀티캐스트**:
- 형식: `FF02::1:FF00:0000` + IPv6 주소의 마지막 24비트
- 예시: `2001:db8::1234` → `FF02::1:FF00:1234`
- 장점: 해당 주소를 가진 노드만 처리하므로 다른 노드의 CPU 사용 없음

### 4. 중복 주소 검출 (Duplicate Address Detection, DAD)

호스트가 새로운 IPv6 주소를 사용하기 전에 해당 주소가 이미 네트워크에서 사용 중인지 확인하는 필수 과정으로, IP 주소 충돌을 방지하고 네트워크 안정성을 보장하며, Neighbor Solicitation 메시지를 송신 주소 없이(::) 전송하여 중복 여부를 확인한다.

**DAD 프로세스**:
1. 호스트가 새 주소 생성 (Tentative 상태)
2. NS 메시지 전송 (송신 주소: `::`(unspecified), 목적지: Solicited-Node 멀티캐스트)
3. 1초 대기 (기본 DupAddrDetectTransmits = 1)
4. 응답 없으면 주소 사용 가능 (Preferred 상태)
5. 응답 있으면 주소 충돌, 새 주소 생성 필요

### 5. 이웃 도달 가능성 확인 (Neighbor Unreachability Detection, NUD)

캐시된 이웃 노드가 여전히 도달 가능한지 주기적으로 확인하여 네트워크 토폴로지 변경에 신속하게 대응하며, Neighbor Cache 상태 머신을 통해 관리되고, 도달 불가능한 노드는 캐시에서 제거하여 불필요한 패킷 전송을 방지한다.

**Neighbor Cache 상태**:
- **INCOMPLETE**: NS 전송 후 NA 대기 중
- **REACHABLE**: 최근에 도달 가능 확인됨 (기본 30초)
- **STALE**: 도달 가능성 확인 필요
- **DELAY**: 상위 계층 확인 대기 (5초)
- **PROBE**: NS 재전송 중 (최대 3회)

### 6. 경로 최적화 (Redirect)

라우터가 호스트에게 더 효율적인 다음 홉(next hop)을 알려주는 기능으로, 불필요한 라우터 홉을 줄여 네트워크 성능을 향상시키며, Redirect 메시지는 라우터만 전송할 수 있고 호스트는 이를 수신하여 경로 테이블을 업데이트한다.

**사용 시나리오**:
- 목적지가 같은 링크에 있는 경우 (직접 통신 가능)
- 더 나은 라우터가 같은 링크에 있는 경우
- 라우터가 받은 패킷을 동일한 인터페이스로 다시 전송해야 하는 경우

## NDP 메시지 유형과 ICMPv6 구조

NDP는 5가지 ICMPv6 메시지 유형을 사용하며, 각 메시지는 특정한 목적과 구조를 가진다.

### Router Solicitation (RS) - Type 133

라우터를 찾기 위해 호스트가 전송하는 메시지로, 네트워크 연결 시 즉시 전송되며 빠른 네트워크 구성을 가능하게 한다.

**패킷 구조**:
```
ICMPv6 Header (8 bytes):
  Type: 133
  Code: 0
  Checksum: (계산됨)
  Reserved: 0 (4 bytes)
Options:
  Source Link-Layer Address (선택, 8 bytes)
```

**전송 정보**:
- 송신 주소: Link-Local 주소 또는 ::(주소 미할당 시)
- 목적지 주소: FF02::2 (All-Routers 멀티캐스트)
- Hop Limit: 255 (라우터 검증용)

### Router Advertisement (RA) - Type 134

라우터가 네트워크 구성 정보를 제공하는 메시지로, 주기적으로 전송되거나 RS에 대한 응답으로 전송된다.

**패킷 구조**:
```
ICMPv6 Header (16 bytes):
  Type: 134
  Code: 0
  Checksum: (계산됨)
  Cur Hop Limit: 64 (기본값)
  M(Managed) Flag: DHCP 사용 여부
  O(Other) Flag: DHCP로 추가 정보 받을지 여부
  Router Lifetime: 1800 (초, 0 = 기본 라우터 아님)
  Reachable Time: 30000 (밀리초)
  Retrans Timer: 1000 (밀리초)
Options:
  Source Link-Layer Address (8 bytes)
  MTU (8 bytes)
  Prefix Information (32 bytes):
    Prefix Length: /64
    L(On-Link) Flag: 1
    A(Autonomous) Flag: 1 (SLAAC 허용)
    Valid Lifetime: 2592000 (30일)
    Preferred Lifetime: 604800 (7일)
    Prefix: 2001:db8::/64
```

**중요 플래그**:
- **M Flag = 1**: Stateful DHCPv6 사용 (주소를 DHCPv6에서 받음)
- **M Flag = 0, O Flag = 1**: Stateless DHCPv6 (주소는 SLAAC, 추가 정보는 DHCPv6)
- **M Flag = 0, O Flag = 0**: 완전한 SLAAC (DHCPv6 불필요)

### Neighbor Solicitation (NS) - Type 135

목적지의 Link-Layer 주소를 찾거나 이웃의 도달 가능성을 확인하는 메시지로, IPv4의 ARP Request를 대체한다.

**패킷 구조**:
```
ICMPv6 Header (24 bytes):
  Type: 135
  Code: 0
  Checksum: (계산됨)
  Reserved: 0 (4 bytes)
  Target Address: 2001:db8::20 (찾으려는 IPv6 주소, 16 bytes)
Options:
  Source Link-Layer Address (선택, DAD 시 생략, 8 bytes)
```

**전송 정보**:
- DAD 용도: 송신 주소 `::`, 목적지 Solicited-Node 멀티캐스트
- 주소 해결: 송신 주소 자신의 IPv6, 목적지 Solicited-Node 멀티캐스트
- NUD 용도: 송신 주소 자신의 IPv6, 목적지 유니캐스트

### Neighbor Advertisement (NA) - Type 136

Neighbor Solicitation에 대한 응답 또는 자신의 Link-Layer 주소 변경을 알리는 메시지다.

**패킷 구조**:
```
ICMPv6 Header (24 bytes):
  Type: 136
  Code: 0
  Checksum: (계산됨)
  R(Router) Flag: 라우터 여부
  S(Solicited) Flag: NS에 대한 응답 여부
  O(Override) Flag: 캐시 덮어쓰기 여부
  Reserved: 0
  Target Address: 2001:db8::20 (자신의 IPv6 주소, 16 bytes)
Options:
  Target Link-Layer Address (8 bytes)
```

**플래그 의미**:
- **R Flag = 1**: 이 노드는 라우터다
- **S Flag = 1**: NS에 대한 응답 (유니캐스트 전송)
- **S Flag = 0**: Gratuitous NA (멀티캐스트 전송, MAC 변경 알림)
- **O Flag = 1**: 캐시 엔트리 덮어쓰기 허용

### Redirect - Type 137

라우터가 호스트에게 더 나은 다음 홉을 알려주는 메시지로, 경로 최적화에 사용된다.

**패킷 구조**:
```
ICMPv6 Header (40+ bytes):
  Type: 137
  Code: 0
  Checksum: (계산됨)
  Reserved: 0 (4 bytes)
  Target Address: 2001:db8::7 (더 나은 다음 홉 주소, 16 bytes)
  Destination Address: 2001:db8::9 (최종 목적지 주소, 16 bytes)
Options:
  Target Link-Layer Address (8 bytes)
  Redirected Header (가변, 원본 패킷 일부)
```

**보안 제약**:
- Link-Local 주소에서만 전송 가능
- Hop Limit = 255 (라우터 검증)
- 라우터만 전송 가능, 호스트는 수신만

## NDP 동작 과정

![NDP 메시지 흐름](ndp-flow.png)

NDP의 전체 동작 과정은 5단계로 이루어지며, 각 단계는 특정 ICMPv6 메시지를 사용한다.

### 1단계: 라우터 탐색 (Router Discovery)

새로운 호스트가 네트워크에 연결되면 가장 먼저 라우터를 찾아 네트워크 구성 정보를 얻는다.

**메시지 교환**:
```
[Host → All-Routers (FF02::2)]
Router Solicitation (Type 133):
  송신 주소: FE80::1234:5678:9abc:def0 (Link-Local)
  목적지 주소: FF02::2
  Hop Limit: 255
  Options: Source Link-Layer Address

[Router → All-Nodes (FF02::1)]
Router Advertisement (Type 134):
  송신 주소: FE80::1 (Router Link-Local)
  목적지 주소: FF02::1 (또는 유니캐스트)
  Hop Limit: 255
  Cur Hop Limit: 64
  M Flag: 0, O Flag: 0 (SLAAC 사용)
  Router Lifetime: 1800초
  Reachable Time: 30000ms
  Retrans Timer: 1000ms
  Options:
    - Source Link-Layer Address: aa:bb:cc:dd:ee:ff
    - MTU: 1500
    - Prefix Information:
        Prefix: 2001:db8::/64
        Prefix Length: 64
        A Flag: 1 (SLAAC 허용)
        L Flag: 1 (On-Link)
        Valid Lifetime: 2592000초 (30일)
        Preferred Lifetime: 604800초 (7일)
```

### 2단계: 주소 자동 구성 (SLAAC)

라우터로부터 받은 프리픽스와 자신의 인터페이스 ID를 결합하여 글로벌 유니캐스트 주소를 생성한다.

**주소 생성 프로세스**:
```
1. Link-Local 주소 생성:
   프리픽스: FE80::/64
   인터페이스 ID: MAC 주소 기반 EUI-64 또는 무작위
   결과: FE80::1234:5678:9abc:def0

2. RA에서 받은 정보 분석:
   네트워크 프리픽스: 2001:db8::/64
   A Flag: 1 (자동 구성 허용)

3. 글로벌 유니캐스트 주소 생성:
   프리픽스: 2001:db8::/64 (RA에서)
   인터페이스 ID: 1234:5678:9abc:def0 (Link-Local과 동일)
   결과: 2001:db8::1234:5678:9abc:def0

4. 주소 상태: Tentative (DAD 완료 전까지)
```

### 3단계: 중복 주소 검출 (DAD)

생성한 주소가 네트워크에서 유일한지 확인하는 필수 단계다.

**DAD 메시지 교환**:
```
[Host → Solicited-Node Multicast]
Neighbor Solicitation (Type 135):
  송신 주소: :: (unspecified, DAD 특징)
  목적지 주소: FF02::1:FF9a:bcde (Solicited-Node)
  Hop Limit: 255
  Target Address: 2001:db8::1234:5678:9abc:def0
  Options: 없음 (송신 주소가 ::이므로)

[대기: 1초 (기본 RetransTimer)]

[중복 주소 없음]
→ 주소 상태: Preferred (사용 가능)
→ 주소를 인터페이스에 바인딩

[중복 주소 발견 시]
← Neighbor Advertisement (Type 136) 수신
→ 주소 상태: Duplicate
→ 새로운 인터페이스 ID로 주소 재생성
→ DAD 재시도
```

### 4단계: 이웃 노드 주소 해결 (Neighbor Discovery)

실제 통신을 위해 목적지 IPv6 주소의 MAC 주소를 찾는다.

**주소 해결 메시지 교환**:
```
[Host A (2001:db8::10) → Solicited-Node Multicast]
Neighbor Solicitation (Type 135):
  송신 주소: 2001:db8::10
  목적지 주소: FF02::1:FF00:20 (2001:db8::20의 Solicited-Node)
  Hop Limit: 255
  Target Address: 2001:db8::20
  Options: Source Link-Layer Address: aa:aa:aa:aa:aa:aa

[Host B (2001:db8::20) → Host A (Unicast)]
Neighbor Advertisement (Type 136):
  송신 주소: 2001:db8::20
  목적지 주소: 2001:db8::10 (유니캐스트)
  Hop Limit: 255
  R Flag: 0 (라우터 아님)
  S Flag: 1 (Solicited, NS에 대한 응답)
  O Flag: 1 (Override, 캐시 업데이트)
  Target Address: 2001:db8::20
  Options: Target Link-Layer Address: bb:bb:bb:bb:bb:bb

[Host A의 Neighbor Cache 업데이트]
2001:db8::20 → bb:bb:bb:bb:bb:bb (REACHABLE 상태)
```

### 5단계: 데이터 전송 및 이웃 도달 가능성 확인

캐시된 MAC 주소를 사용하여 데이터를 전송하고, 주기적으로 도달 가능성을 확인한다.

**Neighbor Cache 상태 전이**:
```
[데이터 전송 중]
REACHABLE (30초) → STALE (도달 가능성 확인 필요)
↓
[상위 계층에서 패킷 전송 시도]
STALE → DELAY (5초, 상위 계층 확인 대기)
↓
[상위 계층 확인 없음]
DELAY → PROBE (NS 재전송, 최대 3회)
↓
[NA 수신]
PROBE → REACHABLE
↓
[NA 수신 실패]
PROBE → (캐시에서 제거)
```

## SLAAC: Stateless Address Autoconfiguration

SLAAC는 NDP의 가장 혁신적인 기능 중 하나로, DHCP 서버 없이도 호스트가 자동으로 IPv6 주소를 구성할 수 있게 하며, 이는 대규모 네트워크나 IoT 환경에서 관리 부담을 크게 줄이고 플러그 앤 플레이 방식의 네트워크 연결을 가능하게 한다.

### SLAAC의 동작 원리

1. **Link-Local 주소 생성**: 호스트는 부팅 시 FE80::/64 프리픽스와 인터페이스 ID를 결합하여 Link-Local 주소 자동 생성
2. **DAD 수행**: 생성한 Link-Local 주소의 중복 여부 확인
3. **Router Discovery**: RS를 전송하여 라우터로부터 네트워크 프리픽스 획득
4. **글로벌 주소 생성**: 라우터가 제공한 프리픽스와 인터페이스 ID를 결합
5. **DAD 재수행**: 글로벌 주소의 중복 여부 확인
6. **주소 사용 시작**: DAD 통과 시 주소를 Preferred 상태로 전환

### 인터페이스 ID 생성 방법

**EUI-64 (Extended Unique Identifier-64)**:
```
MAC 주소: 00:11:22:33:44:55

1. MAC를 두 부분으로 분할:
   00:11:22 | 33:44:55

2. 중간에 FFFE 삽입:
   00:11:22:FF:FE:33:44:55

3. 7번째 비트 반전 (Universal/Local bit):
   00 (00000000) → 02 (00000010)

4. 최종 인터페이스 ID:
   02:11:22:FF:FE:33:44:55

5. IPv6 형식으로 변환:
   0211:22FF:FE33:4455

6. 전체 주소 (프리픽스 2001:db8::/64):
   2001:db8::211:22ff:fe33:4455
```

**Privacy Extensions (RFC 4941)**:
```
문제점: EUI-64는 MAC 주소를 노출하여 장치 추적 가능
해결책: 무작위 인터페이스 ID 생성

1. 암호학적으로 안전한 난수 생성기 사용
2. 128비트 무작위 값 생성
3. 마지막 64비트를 인터페이스 ID로 사용
4. 주기적으로(기본 1일) 새로운 주소 생성
5. 이전 주소는 Deprecated 상태로 전환 (수신만 가능)

예시:
2001:db8::a4b3:92c7:8def:1234 (임시 주소)
```

### SLAAC vs DHCPv6 비교

| 구분 | SLAAC | Stateful DHCPv6 | Stateless DHCPv6 |
|------|-------|-----------------|------------------|
| 주소 할당 | 호스트 자체 생성 | DHCPv6 서버 할당 | 호스트 자체 생성 |
| 서버 필요 | 불필요 | 필요 | 필요 (정보만) |
| RA M Flag | 0 | 1 | 0 |
| RA O Flag | 0 | - | 1 |
| DNS 정보 | RDNSS 옵션 | DHCPv6 | DHCPv6 |
| 주소 관리 | 중앙 집중 불가 | 중앙 집중 가능 | 중앙 집중 불가 |
| 확장성 | 매우 높음 | 중간 | 높음 |

## NDP의 보안 취약점과 공격

NDP는 IPv4 ARP보다 향상된 보안 기능을 제공하지만, 여전히 다양한 공격에 노출될 수 있으며, 특히 인증 메커니즘이 없는 기본 NDP는 중간자 공격(MITM)에 취약하다.

### 1. RA 스푸핑 (Router Advertisement Spoofing)

공격자가 위조된 RA 메시지를 전송하여 호스트의 네트워크 구성을 조작하는 공격으로, NDP 공격 중 가장 심각한 유형이다.

**공격 시나리오**:
```
[정상 상황]
정당한 라우터 → RA: 프리픽스 2001:db8::/64, 기본 게이트웨이 FE80::1

[공격 시작]
공격자 → RA (위조):
  프리픽스: 2001:db8:bad::/64 (악의적 네트워크)
  기본 게이트웨이: FE80::attacker (공격자)
  M Flag: 1 (공격자의 DHCPv6 서버 사용 유도)
  DNS: 공격자 제어 DNS 서버

[결과]
→ 호스트가 공격자가 제공한 프리픽스로 주소 생성
→ 모든 트래픽이 공격자를 통과 (MITM)
→ DNS 쿼리 조작 가능 (피싱)
```

**피해 유형**:
- 중간자 공격: 모든 트래픽 가로채기
- DNS 하이재킹: 악성 DNS 서버로 유도
- 서비스 거부: 잘못된 프리픽스로 통신 차단
- 네트워크 분할: 여러 개의 프리픽스로 네트워크 혼란

### 2. NS/NA 스푸핑 (Neighbor Solicitation/Advertisement Spoofing)

IPv4 ARP 스푸핑과 유사하게, 공격자가 위조된 NS 또는 NA 메시지를 전송하여 Neighbor Cache를 오염시키는 공격이다.

**공격 메커니즘**:
```
[정상 통신]
Host A (2001:db8::10) ↔ Host B (2001:db8::20)

[공격자의 위조 NA 전송]
Attacker → Host A:
  Neighbor Advertisement (Type 136)
  Target Address: 2001:db8::20 (Host B인 척)
  Target Link-Layer: cc:cc:cc:cc:cc:cc (공격자 MAC)
  S Flag: 0 (Gratuitous NA)
  O Flag: 1 (Override, 캐시 덮어쓰기)

[Host A의 Neighbor Cache 오염]
2001:db8::20 → cc:cc:cc:cc:cc:cc (공격자 MAC)

[결과]
Host A가 Host B로 보내는 패킷이 공격자에게 전달됨
```

### 3. DAD DoS 공격 (Duplicate Address Detection Denial of Service)

공격자가 모든 DAD NS 메시지에 NA로 응답하여 호스트가 주소를 할당받지 못하도록 하는 서비스 거부 공격이다.

**공격 흐름**:
```
[Host의 DAD 시도]
Host → NS: Target = 2001:db8::1234 (자신의 새 주소)

[공격자의 즉각 응답]
Attacker → NA: Target = 2001:db8::1234 (이미 사용 중이라고 거짓 응답)

[Host의 재시도]
Host → NS: Target = 2001:db8::5678 (새로운 주소)
Attacker → NA: Target = 2001:db8::5678 (또 거짓 응답)

[무한 반복]
→ 호스트가 영원히 주소를 할당받지 못함
→ 네트워크 접속 불가능
```

### 4. Redirect 공격

공격자가 위조된 Redirect 메시지를 전송하여 호스트의 라우팅 테이블을 조작하고 트래픽을 가로챈다.

**공격 예시**:
```
[Host A가 외부 서버 2001:db8:1::100으로 패킷 전송]
Host A → Router: 패킷 목적지 2001:db8:1::100

[공격자의 위조 Redirect]
Attacker → Host A:
  Redirect (Type 137)
  Target Address: FE80::attacker (공격자)
  Destination Address: 2001:db8:1::100

[Host A의 경로 테이블 변경]
2001:db8:1::100 → Next Hop: FE80::attacker

[결과]
외부 서버로 향하는 모든 패킷이 공격자를 경유
```

## NDP 보안 강화 방법

### 1. SEND (SEcure Neighbor Discovery, RFC 3971)

SEND는 NDP 메시지에 암호화 서명을 추가하여 인증과 무결성을 보장하는 프로토콜로, 공개 키 암호화(RSA) 기반 인증을 사용하며, RA 스푸핑과 NS/NA 스푸핑을 효과적으로 방지한다.

**SEND 동작 원리**:
1. **인증서 기반 인증**: X.509 인증서를 사용하여 라우터와 호스트 신원 확인
2. **CGA (Cryptographically Generated Addresses)**: 공개 키 해시를 인터페이스 ID로 사용
3. **Timestamp 옵션**: 재전송 공격(replay attack) 방지
4. **Nonce 옵션**: NS/NA 메시지 바인딩, 중간자 공격 방지
5. **RSA Signature 옵션**: 모든 메시지에 디지털 서명 추가

**SEND 메시지 구조**:
```
ICMPv6 Header (RA, NS, NA 등)
+ CGA Parameters Option (공개 키, CGA 파라미터)
+ Timestamp Option (타임스탬프, 재전송 방지)
+ Nonce Option (일회용 난수)
+ RSA Signature Option (전체 메시지의 RSA 서명)
```

**장단점**:
- 장점: 강력한 인증, RA/NS/NA 스푸핑 방지, 표준화됨 (RFC 3971)
- 단점: 높은 계산 비용 (RSA 서명 검증), PKI 인프라 필요, 제한적인 구현 (많은 장비 미지원)

### 2. RA Guard (RFC 6105)

스위치에서 비인가 RA 메시지를 차단하는 기능으로, 물리적 포트 기반 정책을 통해 라우터가 아닌 장치에서 전송된 RA를 필터링한다.

**RA Guard 동작 메커니즘**:
```
[스위치 포트 분류]
Trusted Port (Router Port):
  - RA 메시지 전송 허용
  - 예: 라우터 연결 포트, 업링크 포트

Untrusted Port (Host Port):
  - RA 메시지 차단
  - 예: 최종 사용자 컴퓨터, 프린터 등

[RA Guard 검증]
1. RA 메시지 수신
2. 수신 포트 확인
3. Untrusted Port에서 수신 → Drop
4. Trusted Port에서 수신 → Forward
```

**Cisco 스위치 설정 예시**:
```
! IPv6 RA Guard 정책 생성
ipv6 nd raguard policy HOST_POLICY
  device-role host

ipv6 nd raguard policy ROUTER_POLICY
  device-role router

! 인터페이스에 정책 적용
interface GigabitEthernet1/0/1
  description User PC
  ipv6 nd raguard attach-policy HOST_POLICY

interface GigabitEthernet1/0/24
  description Router Uplink
  ipv6 nd raguard attach-policy ROUTER_POLICY
```

**우회 공격과 대응**:
- **문제**: 공격자가 Extension Header를 사용하여 RA Guard 우회 시도
- **대응**: Extension Header 검증 강화, 모든 Fragment 패킷 차단

### 3. DHCPv6 Guard

RA Guard와 유사하게, 비인가 DHCPv6 서버 응답을 차단하는 기능이다.

**설정 예시 (Cisco)**:
```
ipv6 dhcp guard policy CLIENT_POLICY
  device-role client

interface GigabitEthernet1/0/1
  ipv6 dhcp guard attach-policy CLIENT_POLICY
```

### 4. IPv6 Source Guard

IPv6 주소 스푸핑을 방지하기 위해 송신 주소를 검증하는 기능으로, DHCPv6 바인딩 테이블이나 Neighbor Discovery 스누핑 테이블을 기반으로 동작한다.

**동작 원리**:
```
1. 스위치가 ND 메시지를 스누핑하여 바인딩 테이블 구축
   Port GigabitEthernet1/0/1:
     2001:db8::10 → aa:aa:aa:aa:aa:aa

2. 패킷 수신 시 송신 주소 검증
   송신 주소: 2001:db8::10
   수신 포트: GigabitEthernet1/0/1
   → 바인딩 테이블과 일치 → Forward

3. 불일치 시 패킷 차단
   송신 주소: 2001:db8::99 (스푸핑)
   수신 포트: GigabitEthernet1/0/1
   → 바인딩 테이블에 없음 → Drop
```

### 5. 접근 제어 리스트 (ACL)

방화벽이나 라우터에서 ICMPv6 메시지를 필터링하여 공격을 차단한다.

**권장 ACL 규칙**:
```
! RA는 라우터에서만 수신
permit icmp any any router-advertisement
deny icmp any any router-advertisement

! Link-Local 주소로만 제한
permit icmpv6 FE80::/10 any nd-na
permit icmpv6 FE80::/10 any nd-ns
deny icmpv6 any any nd-na
deny icmpv6 any any nd-ns

! Hop Limit = 255 검증 (라우터 메시지)
! (대부분 장비에서 자동 검증)
```

### 6. 네트워크 분할 (VLAN Segmentation)

VLAN을 사용하여 브로드캐스트/멀티캐스트 도메인을 분할하고, 공격 영향 범위를 제한한다.

**보안 강화 VLAN 설계**:
```
VLAN 10: Management (라우터, 스위치)
VLAN 20: Servers (중요 서버)
VLAN 30: Users (일반 사용자)
VLAN 40: Guest (게스트 네트워크)

각 VLAN 간 라우터에서 ACL 적용
```

## NDP와 IPv4 ARP 비교

| 구분 | IPv4 ARP | IPv6 NDP |
|------|----------|----------|
| 프로토콜 | 독립 프로토콜 | ICMPv6 (IP 계층) |
| 주소 해결 | ARP Request/Reply | NS/NA |
| 전송 방식 | 브로드캐스트 | 멀티캐스트 (Solicited-Node) |
| 라우터 발견 | ICMP Router Discovery (선택) | RA/RS (필수) |
| 주소 구성 | DHCP 필요 | SLAAC (자동) |
| 중복 주소 검사 | Gratuitous ARP (선택) | DAD (필수) |
| 보안 | 없음 (취약) | SEND (선택) |
| 경로 최적화 | ICMP Redirect | Redirect (통합) |
| 네트워크 효율 | 낮음 (브로드캐스트) | 높음 (멀티캐스트) |

## 마치며

NDP(Neighbor Discovery Protocol)는 2007년 RFC 4861을 통해 표준화된 이후 IPv6 네트워크의 핵심 프로토콜로 자리잡았으며, IPv4의 ARP, ICMP Router Discovery, ICMP Redirect 등 여러 프로토콜의 기능을 통합하여 더욱 효율적이고 자동화된 네트워크 관리를 가능하게 한다. 멀티캐스트 기반 통신을 통해 네트워크 트래픽을 크게 줄이고, SLAAC를 통한 완전 자동 주소 구성으로 DHCP 서버 없이도 대규모 네트워크를 운영할 수 있으며, Router Discovery, Address Resolution, Duplicate Address Detection, Neighbor Unreachability Detection, Redirect 등 다양한 기능을 ICMPv6 메시지 5가지(RS, RA, NS, NA, Redirect)를 통해 수행한다. 그러나 기본 NDP는 인증 메커니즘이 없어 RA 스푸핑, NS/NA 스푸핑, DAD DoS, Redirect 공격 등 다양한 보안 위협에 노출될 수 있으므로, 네트워크 관리자는 SEND(SEcure Neighbor Discovery), RA Guard, DHCPv6 Guard, IPv6 Source Guard, ACL 필터링, VLAN 분할 등의 보안 대책을 적절히 조합하여 안전한 IPv6 네트워크를 구축해야 하며, 현대 네트워크 환경에서 IPv6 도입이 가속화되는 만큼 NDP의 동작 원리와 보안 이슈를 정확히 이해하는 것은 네트워크 엔지니어와 보안 전문가에게 필수적인 지식이다.
