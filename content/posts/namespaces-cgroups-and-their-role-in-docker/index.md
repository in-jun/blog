---
title: "Docker의 Namespace와 Cgroup"
date: 2024-06-05T21:59:22+09:00
tags: ["Docker", "Linux", "컨테이너"]
description: "Docker 컨테이너 격리를 위한 Linux Namespace와 Cgroup을 설명한다."
draft: false
---

Linux 컨테이너 기술은 2002년 커널 2.4.19에서 mount namespace가 처음 도입된 이래로 꾸준히 발전하여 현대 클라우드 인프라의 핵심 기반이 되었으며, 이 기술의 중심에는 프로세스 격리를 담당하는 Namespace와 리소스 제어를 담당하는 Cgroups(Control Groups)가 있다. Docker, Kubernetes, Podman 등 모든 컨테이너 런타임은 이 두 가지 커널 기능을 활용하여 가상 머신보다 훨씬 가볍고 빠른 격리 환경을 제공하며, 이를 이해하는 것이 컨테이너 기술을 깊이 파악하는 첫걸음이다.

## 컨테이너 기술의 역사적 배경

> **왜 컨테이너가 필요한가?**
>
> 전통적인 가상 머신은 하드웨어 전체를 에뮬레이션하여 완전한 운영체제를 실행하기 때문에 리소스 오버헤드가 크고 시작 시간이 길다. 컨테이너는 호스트 커널을 공유하면서도 프로세스 수준에서 격리를 제공하여, 밀리초 단위의 빠른 시작과 최소한의 리소스 사용으로 동일한 격리 효과를 달성한다.

Linux namespace의 개념은 Bell Labs의 Plan 9 운영체제에서 영감을 받았으며, 2002년 Linux 커널 2.4.19에서 mount namespace로 첫 구현이 시작되었다. 이후 2006년부터 본격적인 확장이 이루어져 2007년에 PID namespace와 network namespace가 추가되었고, 2008년에는 memory cgroups가 등장하면서 리소스 제어 기능이 강화되었다. 커널 3.8에서 user namespace가 도입되면서 비로소 완전한 컨테이너 지원을 위한 기술적 기반이 완성되었으며, LXC(Linux Containers)가 2008년에 이러한 기능들을 활용하는 사용자 도구를 제공했고, Docker는 2013년에 이미지 빌드와 배포 도구를 결합하여 컨테이너 기술을 대중화했다.

## Namespace: 커널 리소스의 격리

> **Namespace란?**
>
> Namespace는 Linux 커널의 기능으로, 특정 시스템 리소스를 프로세스 그룹별로 분리하여 각 그룹이 해당 리소스의 독립적인 인스턴스를 가지는 것처럼 보이게 한다. 가상 머신이 하드웨어를 가상화하는 것과 달리, namespace는 커널 기능 자체를 분할하여 더 가볍고 효율적인 격리를 제공한다.

현재 Linux 커널(6.1 이상)은 8가지 유형의 namespace를 제공하며, 각 namespace는 특정 시스템 리소스를 격리하는 역할을 담당한다. 컨테이너 런타임은 새로운 컨테이너를 생성할 때 필요한 namespace들을 조합하여 격리된 환경을 만들고, 컨테이너 내부의 프로세스는 자신만의 고유한 리소스 뷰를 갖게 된다.

### Namespace 유형별 상세 설명

| Namespace | 격리 대상 | 도입 버전 | 설명 |
|-----------|----------|----------|------|
| **Mount (mnt)** | 파일 시스템 마운트 포인트 | 커널 2.4.19 (2002) | 각 namespace가 독립적인 마운트 포인트 목록을 가짐 |
| **UTS** | 호스트명, 도메인명 | 커널 2.6.19 (2006) | 컨테이너별로 다른 호스트명 설정 가능 |
| **IPC** | System V IPC, POSIX 메시지 큐 | 커널 2.6.19 (2006) | 세마포어, 메시지 큐, 공유 메모리 격리 |
| **PID** | 프로세스 ID | 커널 2.6.24 (2008) | 각 namespace에서 PID 1부터 시작하는 독립적인 번호 체계 |
| **Network (net)** | 네트워크 스택 | 커널 2.6.29 (2009) | IP 주소, 라우팅 테이블, 소켓, 방화벽 규칙 격리 |
| **User** | UID/GID 매핑 | 커널 3.8 (2013) | 컨테이너 내 root를 호스트의 일반 사용자로 매핑 |
| **Cgroup** | Cgroup 계층 뷰 | 커널 4.6 (2016) | 각 컨테이너가 격리된 cgroup 계층 구조를 봄 |
| **Time** | 시스템 시간 | 커널 5.6 (2020) | 프로세스별로 다른 시스템 시간 설정 가능 |

### PID Namespace의 동작 원리

PID namespace에서 생성된 첫 번째 프로세스는 PID 1을 할당받으며 전통적인 init 프로세스와 동일한 특별 대우를 받는데, 이 프로세스가 종료되면 해당 namespace 내의 모든 프로세스가 즉시 종료된다. 고아 프로세스(부모가 종료된 프로세스)는 이 PID 1 프로세스에 재부모화(re-parenting)되며, 이로 인해 각 컨테이너는 자체적인 프로세스 트리를 가지게 된다. 중첩된 PID namespace를 사용할 수 있어 컨테이너 안에서 또 다른 컨테이너를 실행하는 것도 가능하다.

### Network Namespace의 동작 원리

Network namespace가 생성되면 초기에는 루프백 인터페이스(lo)만 포함되며, 외부와 통신하려면 가상 네트워크 인터페이스(veth pair)를 생성하여 호스트 namespace와 연결해야 한다. 각 network namespace는 독립적인 IP 주소, 라우팅 테이블, iptables 규칙, 소켓을 가지며, 물리적 또는 가상 네트워크 인터페이스는 정확히 하나의 namespace에만 속할 수 있지만 namespace 간에 이동이 가능하다. Docker는 브리지 네트워크 모드에서 veth pair를 사용하여 컨테이너와 호스트 간의 네트워크 연결을 구현한다.

### User Namespace와 보안

User namespace는 컨테이너 보안에서 가장 중요한 역할을 하며, 컨테이너 내부의 UID/GID를 호스트의 다른 UID/GID로 매핑하여 권한 분리를 구현한다. 예를 들어 컨테이너 내부에서 root(UID 0)로 실행되는 프로세스가 호스트에서는 UID 100000과 같은 비권한 사용자로 매핑될 수 있으며, 이로 인해 컨테이너 탈출 공격이 성공하더라도 호스트에서 root 권한을 얻지 못한다. 이 기능을 "rootless 컨테이너"라고 부르며, Podman은 기본적으로 이 모드를 사용하고 Docker도 rootless 모드를 지원한다.

## Cgroups: 리소스 할당과 제한

> **Cgroups란?**
>
> Cgroups(Control Groups)는 프로세스 그룹의 리소스 사용량을 제한, 계량, 격리하는 Linux 커널 기능으로, 2007년 Google 엔지니어들이 개발하여 커널 2.6.24에 병합되었다. CPU, 메모리, 디스크 I/O, 네트워크 대역폭 등의 리소스를 세밀하게 제어할 수 있으며, 컨테이너 환경에서 "noisy neighbor" 문제를 방지하는 핵심 메커니즘이다.

Cgroups는 계층적 구조로 구성되며, 자식 cgroup은 부모 cgroup의 리소스 제한을 상속받는다. 각 cgroup에는 여러 프로세스가 속할 수 있고, 각 프로세스는 정확히 하나의 cgroup에만 속한다. 리소스 컨트롤러(서브시스템)가 실제 리소스 제한을 수행하며, 주요 컨트롤러로는 cpu, cpuacct, memory, blkio, net_cls, pids 등이 있다.

### Cgroups의 주요 리소스 컨트롤러

| 컨트롤러 | 기능 | 주요 파라미터 |
|---------|------|-------------|
| **cpu** | CPU 시간 할당 비율 조정 | cpu.shares, cpu.cfs_quota_us |
| **cpuacct** | CPU 사용량 계량 | cpuacct.usage, cpuacct.stat |
| **memory** | 메모리 사용량 제한 | memory.limit_in_bytes, memory.soft_limit_in_bytes |
| **blkio** | 블록 I/O 대역폭 제한 | blkio.throttle.read_bps_device |
| **pids** | 생성 가능한 프로세스 수 제한 | pids.max |
| **devices** | 장치 접근 제어 | devices.allow, devices.deny |

### Cgroups v1과 v2의 차이

Cgroups v1은 각 리소스 컨트롤러가 별도의 계층 구조를 가질 수 있어 구성이 유연했지만, 이로 인해 복잡성이 증가하고 컨트롤러 간 일관성이 부족했다. Cgroups v2는 2016년 커널 4.5에서 도입되어 단일 통합 계층 구조를 사용하며, 모든 컨트롤러가 동일한 계층에서 작동하여 관리가 단순해졌다. v2에서는 프로세스를 리프 노드에만 연결할 수 있고, 스레드 수준의 세분화된 제어 대신 프로세스 단위로 작동하며, 메모리 컨트롤러가 기본적으로 계층적 메모리 제한을 지원한다.

| 특성 | Cgroups v1 | Cgroups v2 |
|------|-----------|------------|
| **계층 구조** | 컨트롤러별 다중 계층 | 단일 통합 계층 |
| **프로세스 연결** | 모든 노드 가능 | 리프 노드만 가능 |
| **스레드 지원** | 스레드별 cgroup 할당 가능 | 프로세스 단위로만 작동 |
| **메모리 계층** | 선택적 | 기본 지원 |
| **Kubernetes 지원** | 유지보수 모드 (v1.31~) | 권장 |

Kubernetes 커뮤니티는 v1.31부터 cgroups v1 지원을 유지보수 모드로 전환했으며, RHEL 10은 cgroups v2만 지원한다. 새로운 배포에서는 cgroups v2를 사용하는 것이 권장된다.

## Docker와 컨테이너 격리

Docker는 컨테이너를 생성할 때 기본적으로 mount, UTS, IPC, PID, network namespace를 사용하며, user namespace는 보안 강화를 위해 선택적으로 활성화할 수 있다. 컨테이너가 시작되면 Docker 데몬은 해당 컨테이너 전용의 namespace 세트와 cgroup을 생성하고, runc(OCI 런타임)가 실제로 커널 인터페이스를 호출하여 격리 환경을 구성한다.

![Docker 컨테이너 격리 아키텍처](container-isolation.png)

### Docker의 리소스 제한 옵션

Docker는 cgroups를 추상화하여 간단한 플래그로 리소스 제한을 설정할 수 있도록 하며, `docker run` 명령어에서 `--memory`, `--cpus`, `--blkio-weight` 등의 옵션을 사용하여 컨테이너별 리소스를 제어한다. 예를 들어 메모리를 512MB로 제한하고 CPU를 1.5개 코어로 제한하려면 `--memory=512m --cpus=1.5` 플래그를 사용하며, 이러한 설정은 해당 컨테이너의 cgroup 파라미터에 직접 반영된다.

### 격리 메커니즘 확인 방법

시스템 수준에서 namespace와 cgroups를 확인하려면 `lsns` 명령어로 현재 시스템의 모든 namespace를 조회하고, `/proc/<PID>/ns/` 디렉토리에서 특정 프로세스의 namespace 심볼릭 링크를 확인할 수 있다. cgroups 설정은 `/sys/fs/cgroup/` 디렉토리에서 확인하며, cgroups v2를 사용하는 시스템에서는 `/sys/fs/cgroup/system.slice/` 하위에서 각 서비스의 리소스 설정을 볼 수 있다. Docker 컨테이너의 경우 `docker inspect` 명령어로 해당 컨테이너의 namespace ID와 cgroup 경로를 확인할 수 있다.

## 보안 고려사항과 한계

> **컨테이너의 근본적 한계**
>
> 컨테이너는 가상 머신과 달리 호스트 커널을 공유하므로, 커널 취약점이 발견되면 모든 컨테이너가 영향을 받을 수 있다. "Containers don't contain"이라는 표현이 있듯이, namespace와 cgroups만으로는 완전한 보안 경계를 제공하지 못하며, 추가적인 보안 계층이 필요하다.

커널 공유로 인한 보안 위험 외에도, 기본 설정에서는 프로세스 생성 수에 제한이 없어 포크 폭탄(fork bomb) 같은 리소스 고갈 공격에 취약하고, cgroups 설정이 부적절하면 한 컨테이너가 과도한 리소스를 사용하여 다른 컨테이너의 성능을 저하시키는 noisy neighbor 문제가 발생할 수 있다. 또한 컨테이너가 호스트의 특권 리소스에 접근하도록 설정된 경우(`--privileged` 플래그) 격리가 사실상 무력화된다.

### 보안 강화 방안

컨테이너 보안을 강화하기 위해서는 다층 방어(defense-in-depth) 접근 방식이 필요하다. User namespace를 활성화하여 컨테이너 내 root가 호스트에서 비권한 사용자로 매핑되도록 하고, AppArmor나 SELinux 같은 MAC(Mandatory Access Control) 시스템을 사용하여 프로세스의 행동을 제한한다. Seccomp 프로파일을 적용하여 컨테이너가 호출할 수 있는 시스템 콜을 화이트리스트 방식으로 제한하고, 불필요한 Linux capabilities를 제거하며, 읽기 전용 파일 시스템과 최소 권한 원칙을 적용한다. eBPF 기반의 런타임 보안 도구(Falco, Cilium, Tetragon 등)를 사용하면 컨테이너의 이상 행동을 실시간으로 감지하고 차단할 수 있다.

| 보안 계층 | 기술 | 효과 |
|----------|------|------|
| **사용자 격리** | User namespace, Rootless 모드 | 컨테이너 탈출 시 호스트 권한 제한 |
| **접근 제어** | AppArmor, SELinux | 프로세스 행동 제한 |
| **시스템 콜 필터링** | Seccomp | 위험한 시스템 콜 차단 |
| **Capability 제한** | --cap-drop | 불필요한 권한 제거 |
| **런타임 보안** | eBPF, Falco | 실시간 이상 탐지 |

## 마치며

Linux namespace와 cgroups는 2002년부터 시작된 오랜 발전 과정을 거쳐 현대 컨테이너 기술의 핵심 기반이 되었으며, Docker, Kubernetes 등 모든 컨테이너 생태계가 이 두 가지 커널 기능 위에 구축되어 있다. Namespace는 프로세스, 네트워크, 파일 시스템, 사용자 ID 등 8가지 리소스 유형을 격리하여 각 컨테이너가 독립적인 시스템처럼 동작하게 하고, cgroups는 CPU, 메모리, I/O 등의 리소스를 정밀하게 할당하고 제한하여 공정한 리소스 분배와 noisy neighbor 방지를 가능하게 한다. 그러나 커널을 공유하는 구조적 특성상 완전한 보안 격리는 제공하지 못하므로, user namespace, MAC, seccomp, eBPF 등 다층적 보안 메커니즘을 함께 적용하는 것이 안전한 컨테이너 환경 구축의 핵심이다.
