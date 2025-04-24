---
title: "Ubuntu에서 MAC 주소 변경하는 방법"
date: 2025-04-27T18:02:28+09:00
draft: false
description: "Ubuntu에서 MAC 주소를 변경하는 방법을 알아보자."
tags:
    [
        "ubuntu",
        "networking",
        "security",
        "privacy",
        "linux",
        "mac-address",
        "macchanger",
    ]
---

## 서론

MAC 주소(Media Access Control address)는 네트워크 장치를 식별하는 고유 주소이다. 보안이나 프라이버시 등의 이유로 이 주소를 변경해야 할 필요가 있을 수 있다. 이 글에서는 Ubuntu에서 MAC 주소를 변경하는 방법을 알아본다.

## MAC 주소란?

MAC 주소는 네트워크 인터페이스 카드(NIC)에 할당된 고유 식별자이다. 48비트(6바이트) 길이의 이 주소는 일반적으로 `XX:XX:XX:XX:XX:XX` 형식의 16진수로 표시된다. 주소의 구성은 다음과 같다:

-   처음 3바이트: 제조업체를 나타내는 OUI(Organizationally Unique Identifier)
-   나머지 3바이트: 제조업체가 할당한 고유 번호

## MAC 주소 확인하기

MAC 주소를 변경하기 전에 현재 주소를 확인하는 방법은 다음과 같다:

```bash
ip link show
```

또는 특정 인터페이스의 정보만 확인하려면:

```bash
ip link show dev <인터페이스명>
```

결과는 다음과 같이 나타난다:

```
2: wlp0s20f3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DORMANT group default qlen 1000
    link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
```

여기서 `00:11:22:33:44:55`가 현재 MAC 주소이다.

## MAC 주소 변경 방법: macchanger 사용하기

`macchanger`는 MAC 주소 변경을 위한 전용 도구로, 다양한 옵션을 제공한다.

### 1. macchanger 설치하기

```bash
sudo apt update
sudo apt install macchanger
```

설치 중 '부팅 시 MAC 주소를 자동으로 변경할까요?'라는 질문이 나타나면 필요에 따라 선택한다.

### 2. MAC 주소 변경하기

MAC 주소 변경은 다음 세 단계로 이루어진다:

#### 2.1 네트워크 인터페이스 비활성화

```bash
sudo ip link set <인터페이스명> down
```

예시: `sudo ip link set wlp0s20f3 down`

#### 2.2 MAC 주소 변경

무작위 MAC 주소로 변경:

```bash
sudo macchanger -r <인터페이스명>
```

또는 특정 MAC 주소로 변경:

```bash
sudo macchanger -m XX:XX:XX:XX:XX:XX <인터페이스명>
```

#### 2.3 네트워크 인터페이스 활성화

```bash
sudo ip link set <인터페이스명> up
```

### 3. macchanger 추가 옵션

| 옵션 | 설명                     | 예시                                             |
| ---- | ------------------------ | ------------------------------------------------ |
| `-r` | 완전히 무작위 MAC 주소   | `sudo macchanger -r wlp0s20f3`                   |
| `-a` | 같은 제조사의 무작위 MAC | `sudo macchanger -a wlp0s20f3`                   |
| `-A` | 같은 유형의 무작위 MAC   | `sudo macchanger -A wlp0s20f3`                   |
| `-p` | 원래 MAC 주소로 복원     | `sudo macchanger -p wlp0s20f3`                   |
| `-m` | 특정 MAC 주소로 설정     | `sudo macchanger -m 00:11:22:33:44:55 wlp0s20f3` |
| `-s` | MAC 주소 정보 조회       | `sudo macchanger -s wlp0s20f3`                   |

## 결론

MAC 주소 변경은 보안 및 개인 정보 보호를 위한 유용한 기술이다. Ubuntu에서 `macchanger` 도구를 사용하면 쉽게 MAC 주소를 변경할 수 있으며, 다양한 옵션을 통해 필요에 맞게 조정할 수 있다.
