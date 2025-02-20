---
title: "Ubuntu 24.04 LTS IP 고정 설정하기"
date: 2024-08-10T11:26:57+09:00
tags: ["ubuntu", "ip", "networking"]
draft: false
---

## 서론

**Ubuntu 24.04 LTS**에서 **IP**를 **고정**하는 방법을 알아보자. 고정 IP 주소는 네트워크 관리를 용이하게 하고, 서버와의 연결을 안정적으로 유지하는 데 도움이 된다. 이 글에서는 **netplan**을 사용하여 IP 주소를 설정하는 방법을 다룬다. 추가로 network-manager를 이용한 TUI(nmtui), CLI(nmcli) 방법도 소개한다.

## IP 고정의 이점

1. **일관성**: 항상 같은 IP 주소를 사용하므로 네트워크 구성이 안정적이다.
2. **원격 접속**: 외부에서 서버에 접속할 때 IP 주소가 변경되지 않아 편리하다.
3. **서비스 호스팅**: 웹 서버, 메일 서버 등을 운영할 때 고정 IP가 필수적이다.
4. **방화벽 설정**: IP 기반의 방화벽 규칙을 더 쉽게 관리할 수 있다.
5. **네트워크 문제 해결**: 고정 IP를 사용하면 네트워크 문제를 진단하고 해결하기가 더 쉬워진다.

## 방법

### 1. netplan을 이용한 설정 (CLI)

#### 네트워크 설정 파일 열기

Ubuntu 24.04 LTS에서는 `netplan`을 사용하여 네트워크 설정을 관리한다. 터미널을 열고 다음 명령어를 입력하여 네트워크 설정 파일을 연다.

```bash
sudo vim /etc/netplan/<파일 이름>.yaml
```

예를 들어, `50-cloud-init.yaml` 파일을 열려면 다음과 같이 입력한다:

```bash
sudo vim /etc/netplan/50-cloud-init.yaml
```

> **참고:** 파일 이름은 시스템에 따라 다를 수 있다. `ls /etc/netplan/` 명령어로 확인 후 적절한 파일을 선택하자.

#### IP 고정 설정 추가

파일을 열면 YAML 형식의 설정이 보일 것이다. 이 설정을 수정하여 고정 IP 주소를 추가한다. 다음은 기본적인 설정 예시다:

```yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        <인터페이스 이름>:
            dhcp4: no
            addresses:
                - <고정 IP 주소>/24
            gateway4: <게이트웨이 IP 주소>
            nameservers:
                addresses:
                    - <DNS 서버 IP 주소>
```

각 항목에 대한 상세 설명:

-   `<인터페이스 이름>`: 네트워크 인터페이스의 이름이다. 예를 들어 `eth0`, `ens33` 등이 될 수 있다. `ip a` 명령어로 확인할 수 있다.
-   `dhcp4: no`: DHCP를 사용하지 않고 수동으로 IP를 설정한다는 의미다.
-   `<고정 IP 주소>`: 할당하고자 하는 고정 IP 주소다. 예: `192.168.1.100`.
-   `/24`: 서브넷 마스크를 의미한다. `/24`는 255.255.255.0과 동일하다.
-   `<게이트웨이 IP 주소>`: 네트워크의 게이트웨이 주소다. 일반적으로 라우터의 IP 주소이며, 예를 들어 `192.168.1.1`이 될 수 있다.
-   `<DNS 서버 IP 주소>`: 사용할 DNS 서버의 IP 주소다. DNS는 도메인 이름을 IP 주소로 변환하는 중요한 역할을 한다. 보통 `8.8.8.8`(Google DNS) 또는 `1.1.1.1`(Cloudflare DNS)를 많이 사용한다.

실제 예시:

```yaml
network:
    version: 2
    renderer: networkd
    ethernets:
        ens33:
            dhcp4: no
            addresses:
                - 192.168.1.100/24
            gateway4: 192.168.1.1
            nameservers:
                addresses:
                    - 8.8.8.8
                    - 8.8.4.4
```

#### 설정 적용

설정 파일을 수정한 후, 변경 사항을 시스템에 적용해야 한다. 다음 명령어를 사용하여 새로운 네트워크 설정을 적용한다:

```bash
sudo netplan apply
```

### 2. CLI를 이용한 설정 (nmcli)

명령줄 인터페이스(CLI)를 사용하여 IP를 고정하는 방법도 있다. `nmcli` 명령어를 사용한다.

```bash
sudo nmcli connection modify <연결 이름> ipv4.addresses <IP 주소>/<서브넷 마스크>
sudo nmcli connection modify <연결 이름> ipv4.gateway <게이트웨이 주소>
sudo nmcli connection modify <연결 이름> ipv4.dns <DNS 서버 주소>
sudo nmcli connection modify <연결 이름> ipv4.method manual
sudo nmcli connection up <연결 이름>
```

예를 들어:

```bash
sudo nmcli connection modify "Wired connection 1" ipv4.addresses 192.168.1.100/24
sudo nmcli connection modify "Wired connection 1" ipv4.gateway 192.168.1.1
sudo nmcli connection modify "Wired connection 1" ipv4.dns "8.8.8.8 8.8.4.4"
sudo nmcli connection modify "Wired connection 1" ipv4.method manual
sudo nmcli connection up "Wired connection 1"
```

### 3. TUI를 이용한 설정 (nmtui)

텍스트 기반 사용자 인터페이스(TUI)를 선호하는 경우, `nmtui` 명령어를 사용할 수 있다.

1. 터미널에서 `sudo nmtui` 명령어를 실행한다.
2. "Edit a connection"을 선택한다.
3. 수정할 네트워크 연결을 선택한다.
4. "IPv4 CONFIGURATION"에서 "Automatic"을 "Manual"로 변경한다.
5. Addresses, Gateway, DNS servers를 입력한다.
6. "OK"를 선택하여 설정을 저장한다.
7. "Back"을 선택하고 "Quit"를 선택하여 nmtui를 종료한다.

## 설정 확인

새로운 IP 설정이 제대로 적용되었는지 확인하는 것은 매우 중요하다. 다음 명령어들을 사용하여 네트워크 설정을 확인할 수 있다:

1. IP 주소 확인:

    ```bash
    ip a
    ```

2. 네트워크 연결 테스트:

    ```bash
    ping -c 4 8.8.8.8
    ```

3. DNS 확인:
    ```bash
    nslookup www.google.com
    ```

## 문제 해결

IP 고정 설정 후 문제가 발생할 경우, 다음 사항들을 확인해 보자:

1. **설정 파일 문법**: YAML 파일의 들여 쓰기가 올바른지 확인한다. YAML은 들여 쓰기에 민감하며, 탭 대신 스페이스를 사용해야 한다.
2. **중복 IP**: 설정한 IP 주소가 네트워크 내의 다른 장치와 충돌하지 않는지 확인한다.
3. **게이트웨이 주소**: 게이트웨이 주소가 올바른지 확인한다. 보통 라우터의 IP 주소다.
4. **DNS 서버**: DNS 서버 주소가 올바른지, 그리고 접근 가능한지 확인한다.
5. **네트워크 인터페이스 이름**: `ip a` 명령어로 실제 네트워크 인터페이스 이름을 확인하고, 설정 파일에서 올바르게 사용했는지 확인한다.
6. **네트워크 관리자 재시작**: 문제가 지속될 경우, 네트워크 관리자를 재시작해 본다. `sudo systemctl restart NetworkManager`

## 결론

이제 Ubuntu 24.04 LTS에서 여러 가지 방법으로 고정 IP 주소를 성공적으로 설정하는 방법을 알아보았다. netplan, TUI (nmtui), CLI (nmcli) 등 다양한 방식으로 IP를 고정할 수 있다. 각 방법은 사용자의 편의성과 상황에 따라 선택할 수 있다. 고정 IP 주소를 사용하면 네트워크 관리가 더 용이해지며, 서버와의 연결이 안정적이게 된다. 필요에 따라 추가적인 네트워크 설정을 진행할 수 있다.
