---
title: "DNS 작동 원리와 구조"
date: 2025-02-20T12:15:59+09:00
tags: ["네트워크", "DNS", "프로토콜"]
description: "DNS의 계층 구조와 도메인 이름 해석 과정을 설명한다."
draft: false
---

## 개요

인터넷에서 웹사이트에 접속할 때 우리는 IP 주소 대신 도메인 이름을 사용하며, 이 도메인 이름을 실제 서버의 IP 주소로 변환하는 시스템이 바로 DNS(Domain Name System)다. DNS는 인터넷의 전화번호부에 비유되며, 1983년 Paul Mockapetris에 의해 설계된 이후 인터넷의 핵심 인프라로 자리잡았고, 매일 수십억 건의 DNS 쿼리를 처리하면서 사용자들이 192.168.0.1이나 2001:4860:4860::8888 같은 복잡한 IP 주소를 기억하지 않고도 www.example.com처럼 직관적인 도메인 이름만으로 웹 서비스에 접근할 수 있도록 한다.

> **DNS(Domain Name System)란?**
>
> DNS는 사람이 읽을 수 있는 도메인 이름(예: www.example.com)을 컴퓨터가 이해할 수 있는 IP 주소(예: 93.184.216.34)로 변환하는 분산 데이터베이스 시스템으로, 전 세계에 분산된 계층적 네임서버들이 협력하여 도메인 이름 해석 서비스를 제공하며, IETF에서 RFC 1034와 RFC 1035로 표준화되어 있다.

## DNS의 탄생 배경

인터넷 초기인 1970년대에는 네트워크에 연결된 호스트의 수가 수백 대에 불과했기 때문에 Stanford Research Institute(SRI)에서 관리하는 단일 텍스트 파일인 HOSTS.TXT를 사용하여 호스트 이름과 IP 주소를 매핑했으며, 네트워크 관리자들은 FTP를 통해 이 파일을 주기적으로 다운로드하여 자신의 시스템(/etc/hosts)에 적용했다. HOSTS.TXT는 간단하고 이해하기 쉬운 방식이었지만, ARPANET이 성장하면서 호스트 수가 급증하자 중앙 집중식 파일 관리 방식은 확장성(파일 크기 증가), 일관성(업데이트 충돌), 트래픽(다운로드 부하) 측면에서 심각한 한계를 드러냈다.

1983년 Paul Mockapetris는 이러한 문제를 해결하기 위해 분산형, 계층적 이름 해석 시스템인 DNS를 설계했으며, RFC 882와 RFC 883(이후 1987년 RFC 1034와 RFC 1035로 대체)에서 DNS의 개념과 구현을 정의했다. DNS의 핵심 설계 목표는 분산된 관리 권한(각 조직이 자신의 도메인을 독립적으로 관리), 확장 가능한 계층 구조(수백만 개의 도메인 지원), 효율적인 캐싱(반복 쿼리 최소화)을 통해 대규모 인터넷 환경에서도 안정적으로 동작하는 이름 해석 서비스를 제공하는 것이었으며, 이러한 설계 철학은 40년이 지난 현재까지도 유효하다.

## DNS의 핵심 역할

DNS가 수행하는 역할은 단순히 도메인 이름을 IP 주소로 변환하는 것을 넘어서며, 현대 인터넷 서비스의 다양한 요구사항을 지원하기 위해 여러 기능을 제공한다.

**정방향 조회(Forward Lookup)**: 가장 기본적인 DNS 기능으로, 도메인 이름을 IP 주소로 변환하며, 사용자가 웹 브라우저에 URL을 입력할 때 발생하는 대부분의 DNS 쿼리가 이에 해당하고, A 레코드(IPv4)와 AAAA 레코드(IPv6)가 정방향 조회에 사용된다.

**역방향 조회(Reverse Lookup)**: IP 주소를 도메인 이름으로 변환하는 기능으로, 주로 로그 분석(웹 서버 접속 로그에서 IP를 도메인으로 표시), 이메일 서버의 스팸 방지(송신자 서버의 정방향/역방향 DNS 일치 확인), 네트워크 진단 등에 활용되며, in-addr.arpa(IPv4) 또는 ip6.arpa(IPv6) 특수 도메인을 통해 구현되고 PTR 레코드가 사용된다.

**메일 라우팅**: MX(Mail Exchanger) 레코드를 통해 특정 도메인으로 전송되는 이메일을 처리할 메일 서버를 지정하며, 우선순위 값(낮을수록 우선)을 사용하여 여러 메일 서버 간의 부하 분산과 장애 복구(failover)를 지원하고, 메일 전송자는 수신자의 도메인에 대한 MX 레코드를 조회하여 어느 메일 서버로 메일을 전송해야 하는지 결정한다.

**부하 분산**: 하나의 도메인에 여러 IP 주소를 매핑하거나(라운드 로빈 DNS) 가중치 기반 라우팅을 구현하여 트래픽을 여러 서버에 분산시키며, 지리적 DNS(GeoDNS)는 사용자의 위치에 따라 가장 가까운 서버의 IP 주소를 반환하여 지연 시간을 최소화하고, 이러한 DNS 기반 부하 분산은 간단하지만 헬스 체크 기능이 제한적이라는 단점이 있다.

**서비스 검색**: SRV(Service) 레코드를 통해 특정 서비스를 제공하는 호스트와 포트를 검색할 수 있으며, VoIP(SIP), 메시징 프로토콜(XMPP), 마이크로서비스 아키텍처(Kubernetes의 서비스 디스커버리), Active Directory 환경 등에서 활용되어 클라이언트가 서비스 제공자를 동적으로 찾을 수 있도록 한다.

## DNS의 계층 구조

DNS는 도메인 이름을 점(.)으로 구분된 계층적 구조로 구성하며, 루트(Root), 최상위 도메인(TLD), 2차 도메인, 서브도메인 등의 계층으로 나뉘고, 이 계층 구조 덕분에 DNS 관리 권한이 분산되어 각 조직이 자신의 도메인을 독립적으로 관리할 수 있으며 단일 장애 지점(Single Point of Failure) 없이 확장 가능한 시스템을 구축할 수 있다.

![DNS 계층 구조](dns-hierarchy.png)

### 루트 도메인(Root Domain)

DNS 계층 구조의 최상위에 위치하는 루트 도메인은 빈 문자열로 표현되며 FQDN(Fully Qualified Domain Name)에서는 마지막 점으로 표시되고(예: www.example.com.), 전 세계에 분산된 13개의 루트 네임서버 클러스터(A-root부터 M-root까지, 각각 a.root-servers.net부터 m.root-servers.net)가 이를 관리한다. 실제로는 13개 이상의 물리적 서버가 존재하며, Anycast 기술을 통해 수백 개의 서버 인스턴스가 전 세계에 배치되어 사용자는 가장 가까운 루트 서버에 자동으로 연결되고 이를 통해 높은 가용성(99.99% 이상)과 낮은 지연 시간을 보장한다. 루트 네임서버는 ICANN(Internet Corporation for Assigned Names and Numbers)과 Verisign, NASA, US Army, University of Maryland 등 다양한 협력 기관들이 운영한다.

### 최상위 도메인(TLD, Top-Level Domain)

루트 바로 아래에 위치하는 최상위 도메인은 크게 일반 최상위 도메인(gTLD)과 국가 코드 최상위 도메인(ccTLD), 그리고 특수 용도 TLD로 구분된다.

**일반 최상위 도메인(gTLD)**: .com(상업용), .net(네트워크), .org(비영리 조직)와 같은 전통적인 gTLD부터 2013년 ICANN의 신규 gTLD 프로그램을 통해 도입된 .app(애플리케이션), .dev(개발자), .io(기술 스타트업), .cloud(클라우드 서비스), .ai(인공지능) 같은 신규 gTLD까지 1,500개 이상이 존재하며, ICANN의 승인을 받은 레지스트리가 각 gTLD를 관리한다. 예를 들어 .com과 .net은 Verisign이, .org는 Public Interest Registry가, .io는 Internet Computer Bureau가 관리한다.

**국가 코드 최상위 도메인(ccTLD)**: .kr(한국), .jp(일본), .uk(영국), .de(독일), .cn(중국) 등 ISO 3166-1 alpha-2 국가 코드를 기반으로 한 도메인으로 전 세계 250개 이상 존재하며, 각 국가의 NIC(Network Information Center)나 지정된 기관이 관리하고 해당 국가의 법률과 정책에 따라 등록 요건이 다르다. 한국의 .kr은 한국인터넷진흥원(KISA)이 관리하며, 일부 ccTLD(.tv, .io, .ai 등)는 기술 서비스를 위한 마케팅 도메인으로 재해석되어 인기를 얻고 있다.

### 2차 도메인(Second-Level Domain)

TLD 바로 아래에 위치하는 2차 도메인은 개인이나 조직이 도메인 레지스트라(GoDaddy, Namecheap, Cloudflare 등)를 통해 등록할 수 있는 도메인으로, example.com에서 'example'이 2차 도메인에 해당하고 .com이 TLD에 해당한다. 도메인 등록자는 2차 도메인에 대한 관리 권한을 가지며 권한 네임서버를 지정하고 DNS 레코드를 설정하며 하위에 서브도메인을 자유롭게 생성할 수 있고, 도메인은 연간 갱신 방식으로 운영되며 갱신하지 않으면 만료 후 타인이 등록할 수 있다.

### 서브도메인(Subdomain)

2차 도메인 아래에 위치하는 서브도메인은 도메인 소유자가 별도의 비용 없이 자유롭게 생성하고 관리할 수 있으며, www.example.com에서 'www'가 서브도메인에 해당하고, blog.example.com, mail.example.com, api.example.com 같은 형태로 무제한 생성 가능하다. 서브도메인은 조직 내 서비스 구분(mail.example.com, ftp.example.com, cdn.example.com), 환경 구분(dev.example.com, staging.example.com, prod.example.com), 지역 구분(us.example.com, asia.example.com) 등 다양한 목적으로 활용되며, 서브도메인의 서브도메인(api.dev.example.com)도 생성 가능하다.

## DNS 동작 과정

사용자가 웹 브라우저에 도메인 이름을 입력하면 DNS 해석(Resolution) 과정이 시작되며, 이 과정은 재귀적(Recursive) 쿼리와 반복적(Iterative) 쿼리의 조합으로 이루어지고, 여러 단계의 캐싱을 통해 효율성을 극대화한다.

![DNS 해석 과정](dns-resolution.png)

### 1단계: 로컬 캐시 확인

운영체제는 먼저 로컬 DNS 캐시를 확인하여 해당 도메인의 IP 주소가 캐시에 존재하는지 검사하고, 존재하면 캐시된 IP 주소를 즉시 반환하여 네트워크 요청 없이 해석을 완료한다. 리눅스에서는 `/etc/hosts` 파일도 함께 참조하며 이 파일에 정의된 호스트 이름은 DNS 쿼리보다 우선순위가 높아서 시스템 관리자가 특정 도메인을 원하는 IP 주소로 수동 매핑할 수 있고, 윈도우에서는 `C:\Windows\System32\drivers\etc\hosts` 파일이 같은 역할을 수행한다.

### 2단계: 리졸버(Resolver)에 쿼리

로컬 캐시에 정보가 없으면 운영체제는 설정된 DNS 리졸버(일반적으로 ISP의 DNS 서버 또는 Google DNS(8.8.8.8), Cloudflare DNS(1.1.1.1) 같은 공용 DNS 서버)에 재귀적 쿼리를 전송한다. 리졸버는 클라이언트를 대신하여 DNS 해석 과정을 완료해야 하는 책임을 가지며, 자체 캐시에 정보가 있으면 즉시 캐시된 응답을 반환하고 없으면 다음 단계로 진행하여 최종 응답을 얻을 때까지 다른 네임서버들에 반복적 쿼리를 전송한다.

### 3단계: 루트 네임서버 조회

리졸버 캐시에 정보가 없으면 리졸버는 루트 네임서버(13개 클러스터 중 하나)에 반복적 쿼리를 전송하며, 루트 네임서버는 최종 IP 주소를 알지 못하므로 해당 TLD(.com, .net, .org 등)를 담당하는 TLD 네임서버의 주소를 응답으로 반환한다. 루트 네임서버는 전 세계 DNS 쿼리의 진입점 역할을 하지만, 효율적인 캐싱 덕분에 실제로 루트 서버에 도달하는 쿼리는 전체의 1% 미만에 불과하며, 대부분의 리졸버는 TLD 네임서버 주소를 장기간 캐싱한다.

### 4단계: TLD 네임서버 조회

리졸버는 루트 네임서버로부터 받은 TLD 네임서버(.com의 경우 Verisign 운영) 주소로 쿼리를 전송하고, TLD 네임서버는 해당 2차 도메인(example.com)을 담당하는 권한 네임서버(Authoritative Name Server)의 주소를 응답으로 반환한다. 예를 들어 .com TLD 네임서버는 example.com 도메인을 관리하는 권한 네임서버의 위치(NS 레코드)를 알려주며, 일반적으로 2개 이상의 네임서버 주소를 반환하여 중복성을 보장한다.

### 5단계: 권한 네임서버 조회

리졸버는 TLD 네임서버로부터 받은 권한 네임서버 주소로 최종 쿼리를 전송하고, 권한 네임서버는 해당 도메인의 실제 DNS 레코드(A, AAAA, CNAME, MX 등)를 응답으로 반환한다. 권한 네임서버는 해당 도메인의 DNS 정보를 실제로 저장하고 관리하는 서버로, 도메인 소유자나 관리자가 설정한 DNS 레코드를 제공하며, 각 레코드에는 TTL 값이 설정되어 캐싱 기간이 결정된다.

### 6단계: 응답 반환 및 캐싱

리졸버는 권한 네임서버로부터 받은 응답(IP 주소)을 자체 캐시에 TTL 기간 동안 저장하고 클라이언트에 최종 IP 주소를 반환하며, 클라이언트의 운영체제와 웹 브라우저도 이 정보를 각자의 캐시에 저장한다. 캐시된 정보는 TTL(Time To Live) 값에 따라 유효 기간이 결정되며 TTL이 만료되면 다음 쿼리 시 새로운 해석 과정이 시작되고, 이러한 다층 캐싱 구조 덕분에 동일한 도메인에 대한 반복적인 쿼리가 빠르게 처리되고 상위 네임서버의 부하가 크게 감소한다.

## DNS 서버 유형

DNS 생태계에서 각 서버는 고유한 역할을 수행하며, 이들의 협력을 통해 분산된 이름 해석 서비스가 가능해진다.

### 재귀적 리졸버(Recursive Resolver)

재귀적 리졸버는 클라이언트의 DNS 쿼리를 받아 최종 IP 주소를 찾아 반환하는 서버로, ISP가 제공하는 DNS 서버나 Google Public DNS(8.8.8.8, 8.8.4.4), Cloudflare DNS(1.1.1.1, 1.0.0.1), OpenDNS(208.67.222.222, 208.67.220.220), Quad9(9.9.9.9) 같은 공용 DNS 서버가 이에 해당한다. 리졸버는 응답을 캐싱하여 반복적인 쿼리를 줄이고 응답 속도를 향상시키며(일반적으로 5~50ms 이내), DNSSEC 검증(응답 무결성 확인), 악성 도메인 차단(멀웨어, 피싱 사이트 필터링), 쿼리 로깅, 프라이버시 보호(쿼리 암호화, 로그 비저장) 등 부가 기능을 제공하기도 한다.

### 루트 네임서버(Root Name Server)

루트 네임서버는 DNS 계층의 최상위에서 TLD 네임서버 정보를 제공하는 서버로, A부터 M까지 13개의 논리적 루트 서버가 존재하며, Anycast를 통해 전 세계 1,500개 이상의 위치에서 운영된다. 13개로 제한된 이유는 DNS가 UDP를 사용하고 UDP 패킷 크기 제한(512바이트, EDNS0 적용 시 4096바이트)이 있기 때문이며, 실제로는 각 루트 서버 인스턴스가 전 세계에 분산 배치되어 있다. 루트 서버 운영자에는 Verisign(a.root-servers.net, j.root-servers.net), USC-ISI(b.root-servers.net), ICANN(l.root-servers.net), NASA(e.root-servers.net), US Army(e.root-servers.net), Internet Systems Consortium(f.root-servers.net), Netnod(i.root-servers.net) 등 다양한 기관이 포함된다.

### TLD 네임서버(TLD Name Server)

TLD 네임서버는 특정 최상위 도메인의 2차 도메인에 대한 권한 네임서버 정보를 제공하며, 각 TLD 레지스트리가 운영한다. 예를 들어 Verisign은 .com과 .net TLD 네임서버를 운영하고(전 세계 13개 클러스터로 분산), 한국인터넷진흥원(KISA)은 .kr TLD 네임서버를 운영하며(4개 네임서버로 구성), Public Interest Registry는 .org TLD 네임서버를 운영한다. TLD 네임서버는 수백만~수천만 개의 도메인 정보를 관리하며, 높은 성능과 가용성을 위해 GeoDNS와 Anycast를 활용한다.

### 권한 네임서버(Authoritative Name Server)

권한 네임서버는 특정 도메인의 DNS 레코드를 실제로 저장하고 관리하는 서버로, 도메인 소유자가 직접 운영(BIND, PowerDNS, NSD 등 소프트웨어 사용)하거나 DNS 호스팅 서비스(AWS Route 53, Cloudflare DNS, Google Cloud DNS, Azure DNS 등)를 통해 관리된다. 권한 네임서버만이 해당 도메인의 DNS 정보에 대한 공식적인 출처(Source of Truth)이며, 다른 서버들은 이 정보를 캐싱하여 제공하고, 일반적으로 2개 이상의 권한 네임서버를 운영하여(Primary, Secondary) 중복성과 장애 복구를 보장한다.

## 주요 DNS 레코드 유형

DNS 레코드는 도메인에 대한 다양한 정보를 저장하며, 각 레코드 유형은 특정한 목적을 가지고 있다.

### A 레코드와 AAAA 레코드

A 레코드(Address Record)는 도메인 이름을 IPv4 주소(32비트)로 매핑하고, AAAA 레코드는 IPv6 주소(128비트)로 매핑한다. 하나의 도메인에 여러 A 레코드나 AAAA 레코드를 설정하여 라운드 로빈 방식의 부하 분산이나 장애 복구를 구현할 수 있으며, 대부분의 DNS 클라이언트는 IPv4와 IPv6를 모두 지원하는 경우 AAAA 레코드를 우선적으로 사용하고 실패 시 A 레코드로 폴백(fallback)한다.

```
example.com.    IN    A       93.184.216.34
example.com.    IN    AAAA    2606:2800:220:1:248:1893:25c8:1946
```

### CNAME 레코드

CNAME(Canonical Name) 레코드는 도메인 이름을 다른 도메인 이름으로 매핑하는 별칭 레코드로, 여러 서브도메인이 동일한 서버를 가리킬 때 유용하고 서버 IP 주소가 변경되어도 CNAME 대상만 변경하면 되므로 관리가 편리하다. CNAME 레코드는 다른 레코드와 공존할 수 없으며(RFC 1034에 따라 MX, TXT, NS 등과 같은 레벨에서 CNAME을 사용할 수 없음), DNS 해석 시 추가적인 쿼리(CNAME 체이싱)가 필요하여 약간의 성능 오버헤드가 발생한다는 점을 고려해야 한다.

```
www.example.com.      IN    CNAME    example.com.
blog.example.com.     IN    CNAME    example.com.
```

### MX 레코드

MX(Mail Exchanger) 레코드는 해당 도메인의 이메일을 처리할 메일 서버를 지정하며, 우선순위 값(0~65535)을 통해 여러 메일 서버 간의 선호도를 설정한다. 낮은 우선순위 값이 더 높은 선호도를 의미하며(예: 10이 20보다 우선), 같은 우선순위의 서버들 간에는 랜덤하게 선택되어 부하 분산이 이루어진다. 메일 전송 시 SMTP 클라이언트는 우선순위가 가장 낮은(숫자가 작은) 서버에 먼저 연결을 시도하고, 연결 실패 시 다음 우선순위 서버로 폴백한다.

```
example.com.    IN    MX    10    mail1.example.com.
example.com.    IN    MX    20    mail2.example.com.
example.com.    IN    MX    20    mail3.example.com.
```

### TXT 레코드

TXT 레코드는 임의의 텍스트 데이터를 저장하며, 주로 도메인 소유권 검증(Google Search Console, SSL 인증서 발급), 이메일 인증(SPF, DKIM, DMARC), 보안 정책 게시(CAA) 등에 활용된다. SPF(Sender Policy Framework) 레코드는 해당 도메인에서 이메일을 보낼 수 있는 서버의 IP 주소나 도메인을 지정하여 스팸과 피싱을 방지하고, DKIM은 이메일에 디지털 서명을 추가하여 위변조를 방지하며, DMARC는 SPF와 DKIM 검증 실패 시 처리 방법을 정의한다.

```
example.com.    IN    TXT    "v=spf1 include:_spf.google.com ~all"
example.com.    IN    TXT    "google-site-verification=abc123xyz"
```

### NS 레코드

NS(Name Server) 레코드는 특정 도메인을 담당하는 권한 네임서버를 지정하며, 도메인 위임(Delegation)에 사용된다. 하나의 도메인에 여러 NS 레코드를 설정하여 중복성과 부하 분산을 구현하며, 일반적으로 최소 2개 이상의 네임서버를 지정하는 것이 권장되고 RFC에서는 2~7개를 권장한다. NS 레코드는 부모 존(Parent Zone)과 자식 존(Child Zone) 모두에 존재하며, 부모 존의 NS 레코드는 위임(Delegation)을, 자식 존의 NS 레코드는 권한(Authority)을 나타낸다.

```
example.com.    IN    NS    ns1.example.com.
example.com.    IN    NS    ns2.example.com.
```

### SOA 레코드

SOA(Start of Authority) 레코드는 DNS 존(Zone)의 권한 정보와 동작 파라미터를 정의하며, 주 네임서버(Primary Name Server), 관리자 이메일(@ 대신 .로 표현), 존 일련번호(Serial Number, 존 파일 변경 시 증가), 새로 고침 간격(Refresh, 2차 서버가 주 서버에 존 업데이트 확인 주기), 재시도 간격(Retry, 연결 실패 시 재시도 주기), 만료 시간(Expire, 주 서버 연결 불가 시 2차 서버의 데이터 유효 기간), 최소 TTL(Negative TTL, 존재하지 않는 레코드에 대한 캐싱 기간) 등의 정보를 포함한다. SOA 레코드는 존에 하나만 존재해야 하며(RFC 1035), 존 전송(Zone Transfer, AXFR/IXFR)과 캐싱 동작에 영향을 미친다.

### SRV 레코드

SRV(Service) 레코드는 특정 서비스를 제공하는 호스트의 위치(도메인)와 포트를 지정하며, 서비스 이름(_service), 프로토콜(_tcp 또는 _udp), 우선순위(낮을수록 우선), 가중치(같은 우선순위 내에서 부하 분산 비율), 포트(서비스 포트 번호), 대상 호스트(실제 서버 도메인) 정보를 포함한다. LDAP(디렉터리 서비스), SIP(VoIP), XMPP(메신저), Minecraft(게임 서버) 등의 프로토콜에서 서비스 검색에 활용되고, Kubernetes에서도 서비스 디스커버리에 SRV 레코드를 사용한다.

```
_ldap._tcp.example.com.    IN    SRV    10 0 389 ldap.example.com.
_minecraft._tcp.example.com. IN  SRV    0 5 25565 mc1.example.com.
```

### PTR 레코드

PTR(Pointer) 레코드는 IP 주소를 도메인 이름으로 매핑하는 역방향 조회(Reverse DNS Lookup)에 사용되며, in-addr.arpa(IPv4) 또는 ip6.arpa(IPv6) 특수 도메인 아래에 설정된다. 이메일 서버의 정방향/역방향 DNS 일치 확인(많은 메일 서버가 송신자의 IP 주소에 대한 PTR 레코드를 확인하여 스팸 필터링), 네트워크 진단(traceroute 결과에 호스트 이름 표시), 로그 분석(웹 서버 로그에 IP 대신 도메인 표시) 등에 활용된다. IPv4 주소 93.184.216.34의 PTR 레코드는 34.216.184.93.in-addr.arpa 형태로 역순으로 표현된다.

## DNS 캐싱과 TTL

DNS 캐싱은 DNS 쿼리의 응답 속도를 향상시키고 네트워크 트래픽을 줄이는 핵심 메커니즘으로, 브라우저 캐시, 운영체제 캐시, 리졸버 캐시 등 여러 수준에서 이루어지며, 캐싱이 없다면 모든 DNS 쿼리가 루트 서버부터 시작해야 하므로 인터넷이 제대로 작동하지 않을 것이다.

### TTL(Time To Live)

TTL은 DNS 레코드가 캐시에 저장될 수 있는 최대 시간을 초 단위로 지정하며, 권한 네임서버에서 각 레코드에 대해 설정한다. 낮은 TTL 값(60~300초)은 DNS 변경이 빠르게 전파되지만(장애 복구, A/B 테스트에 유리) 쿼리 부하가 증가하고, 높은 TTL 값(3600~86400초)은 캐싱 효율이 높고 네임서버 부하가 감소하지만 변경 전파가 느리다는 장단점이 있다.

일반적으로 안정적인 서비스에는 높은 TTL(3600초~86400초)을, 변경이 잦거나 장애 복구가 중요한 서비스에는 낮은 TTL(60초~300초)을 설정하며, DNS 마이그레이션이나 서버 이전 시 TTL을 낮추었다가(예: 300초) 변경 완료 후 다시 높이는(예: 3600초) 전략도 사용된다. Cloudflare는 기본 TTL을 자동(Auto)으로 설정하며, AWS Route 53은 60초를 권장한다.

### 캐싱 수준

**브라우저 캐시**: 웹 브라우저는 자체 DNS 캐시를 유지하며(Chrome은 60초 기본 TTL), chrome://net-internals/#dns(Chrome), about:networking#dns(Firefox)에서 확인하고 관리할 수 있다. 브라우저 캐시는 가장 빠른 응답 속도를 제공하지만 브라우저 재시작 시 초기화된다.

**운영체제 캐시**: 운영체제는 시스템 전체에서 사용되는 DNS 캐시를 유지하며, Windows에서는 `ipconfig /displaydns`로 확인하고 `ipconfig /flushdns`로 초기화할 수 있고, Linux에서는 systemd-resolved를 사용하는 경우 `resolvectl statistics` 또는 `resolvectl flush-caches`를 사용하고, macOS에서는 `sudo dscacheutil -flushcache`로 초기화할 수 있다.

**리졸버 캐시**: DNS 리졸버는 클라이언트들의 쿼리에 대한 응답을 캐싱하여 상위 서버로의 쿼리를 줄이고 응답 속도를 향상시키며, 리졸버 캐시는 수많은 클라이언트가 공유하므로 캐싱 효율이 가장 높고, 일반적으로 수백 GB의 메모리를 사용하여 수백만 개의 레코드를 캐싱한다.

## DNS 보안

DNS는 1983년 설계 당시 보안을 크게 고려하지 않았기 때문에 다양한 보안 위협에 노출되어 있으며, 이를 해결하기 위한 여러 보안 메커니즘이 개발되었다.

### DNS 스푸핑과 캐시 포이즈닝

공격자가 위조된 DNS 응답을 주입하여 사용자를 악성 사이트로 유도하는 공격으로, 캐시 포이즈닝(Cache Poisoning)은 리졸버의 캐시에 위조된 레코드를 삽입하여 해당 리졸버를 사용하는 모든 사용자에게 영향을 미친다. 2008년 Dan Kaminsky가 발견한 취약점은 DNS 쿼리의 트랜잭션 ID(16비트)를 무작위 대입하여 위조 응답을 삽입하는 것으로, 소스 포트 랜덤화(Source Port Randomization)를 통해 완화되었다.

### DNSSEC(DNS Security Extensions)

DNSSEC은 DNS 응답에 디지털 서명을 추가하여 데이터의 무결성과 출처를 검증하는 DNS 확장 기능으로, 2005년 RFC 4033~4035에서 표준화되었으며, RRSIG(서명 레코드), DNSKEY(공개키), DS(위임 서명), NSEC/NSEC3(존재하지 않는 레코드 증명) 레코드를 사용하여 루트부터 목표 도메인까지 신뢰 체인(Chain of Trust)을 구성한다. DNSSEC은 DNS 스푸핑과 캐시 포이즈닝을 효과적으로 방지하지만, 모든 도메인과 리졸버가 DNSSEC을 지원해야 효과적이며 구현 복잡성이 높고 응답 크기가 증가하며 존 열거(Zone Enumeration) 취약점이 존재한다는 단점이 있다.

### DNS over HTTPS(DoH)와 DNS over TLS(DoT)

DoH(RFC 8484, 2018)와 DoT(RFC 7858, 2016)는 DNS 쿼리를 암호화하여 중간자의 도청과 변조를 방지하는 프로토콜로, DoH는 HTTPS 포트(443)를 사용하여 일반 웹 트래픽에 숨어 방화벽 우회가 가능하고, DoT는 전용 포트(853)를 사용하여 명시적인 DNS 암호화를 제공한다. Chrome, Firefox, Edge 등 주요 브라우저와 Windows 11, Android 9+, iOS 14+ 운영체제가 DoH와 DoT를 지원하며, Cloudflare(1.1.1.1), Google(8.8.8.8), Quad9(9.9.9.9) 등의 공용 DNS 서버도 암호화된 DNS를 제공한다. 암호화된 DNS는 ISP의 DNS 기반 필터링과 감시를 우회할 수 있어 프라이버시를 향상시키지만, 기업 네트워크의 보안 정책과 충돌할 수 있다.

### CAA 레코드

CAA(Certification Authority Authorization) 레코드는 도메인 소유자가 어떤 인증 기관(CA)이 해당 도메인의 SSL/TLS 인증서를 발급할 수 있는지 지정하는 DNS 레코드로, 2013년 RFC 6844에서 표준화되었고 2017년부터 모든 CA가 인증서 발급 전 CAA 레코드 확인을 의무화했다. CAA 레코드는 무단 인증서 발급을 방지하여 피싱과 중간자 공격을 완화한다.

```
example.com.    IN    CAA    0 issue "letsencrypt.org"
example.com.    IN    CAA    0 issuewild ";"
```

## 마치며

이번 글에서는 DNS의 탄생 배경부터 계층 구조, 동작 원리, 다양한 레코드 유형, 캐싱 메커니즘, 보안 기능까지 도메인 네임 시스템의 전반을 상세히 살펴보았다. DNS는 1983년 설계된 이후 40년이 넘는 시간 동안 인터넷의 핵심 인프라로서 복잡한 IP 주소 없이도 사용자가 쉽게 서비스에 접근할 수 있게 하며, 분산된 계층 구조와 효율적인 캐싱을 통해 매일 수천억 건의 쿼리를 안정적으로 처리하고, DNSSEC, DoH, DoT 같은 보안 기능의 도입으로 점점 더 안전하고 프라이버시를 보호하는 시스템으로 진화하고 있다.
