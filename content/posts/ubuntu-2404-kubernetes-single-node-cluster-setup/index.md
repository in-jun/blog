---
title: "Ubuntu 24.04 LTS 단일 노드 쿠버네티스 클러스터 구축 완벽 가이드"
date: 2024-07-27T23:23:40+09:00
tags: ["Kubernetes", "Ubuntu", "Container", "kubeadm", "DevOps"]
description: "Ubuntu 24.04 LTS에서 kubeadm을 사용하여 단일 노드 쿠버네티스 클러스터를 구축하는 전체 과정을 다루며, 컨테이너 런타임 설정부터 네트워크 플러그인 설치까지 단계별로 설명한다"
draft: false
---

쿠버네티스(Kubernetes)는 2014년 Google이 오픈소스로 공개한 컨테이너 오케스트레이션 플랫폼으로, 현재 CNCF(Cloud Native Computing Foundation)에서 관리하며 컨테이너화된 애플리케이션의 배포, 확장, 관리를 자동화하는 데 사실상의 표준으로 자리잡았다. 프로덕션 환경에서는 고가용성을 위해 다중 노드 클러스터를 구성하지만, 개발, 테스트, 학습 목적으로는 단일 노드 클러스터도 충분히 활용할 수 있으며 이 글에서는 Ubuntu 24.04 LTS에서 kubeadm을 사용하여 단일 노드 쿠버네티스 클러스터를 구축하는 전체 과정을 다룬다.

## 쿠버네티스 아키텍처 개요

> **쿠버네티스 클러스터 구성요소**
>
> 쿠버네티스 클러스터는 컨트롤 플레인(Control Plane)과 워커 노드(Worker Node)로 구성되며, 컨트롤 플레인은 클러스터의 상태를 관리하고 워커 노드는 실제 컨테이너 워크로드를 실행한다.

쿠버네티스의 컨트롤 플레인은 API 서버(kube-apiserver), 스케줄러(kube-scheduler), 컨트롤러 매니저(kube-controller-manager), etcd 등의 컴포넌트로 구성되며, 워커 노드에서는 kubelet이 컨테이너 런타임과 통신하여 Pod를 생성하고 관리한다. 단일 노드 클러스터에서는 하나의 노드가 컨트롤 플레인과 워커 노드 역할을 모두 수행하므로 리소스 효율적으로 학습 및 개발 환경을 구성할 수 있다.

### 주요 컴포넌트

| 컴포넌트 | 역할 | 위치 |
|---------|------|------|
| **kube-apiserver** | 클러스터의 API 엔드포인트, 모든 통신 허브 | 컨트롤 플레인 |
| **etcd** | 클러스터 상태 저장소 (키-값 데이터베이스) | 컨트롤 플레인 |
| **kube-scheduler** | Pod를 적절한 노드에 배치 | 컨트롤 플레인 |
| **kube-controller-manager** | 클러스터 상태 조정 (복제, 노드 관리 등) | 컨트롤 플레인 |
| **kubelet** | 노드에서 Pod 생명주기 관리 | 모든 노드 |
| **kube-proxy** | 서비스 네트워킹, 로드밸런싱 | 모든 노드 |

## 사전 준비 사항

단일 노드 쿠버네티스 클러스터를 구축하기 위해서는 최소 2개의 CPU 코어, 2GB RAM, 20GB 저장공간이 필요하며, Ubuntu 24.04 LTS가 설치된 환경에서 root 또는 sudo 권한과 인터넷 연결이 필요하다. 가상 머신이나 클라우드 인스턴스에서도 동일하게 구축할 수 있으며, 물리적 서버에서 구축하는 경우에도 절차는 동일하다.

### 시스템 요구사항

| 항목 | 최소 사양 | 권장 사양 |
|-----|----------|----------|
| **CPU** | 2 코어 | 4 코어 이상 |
| **RAM** | 2 GB | 4 GB 이상 |
| **저장공간** | 20 GB | 50 GB 이상 |
| **네트워크** | 인터넷 연결 | 고정 IP 권장 |

## 설치 과정

### 1단계: 시스템 업데이트 및 필수 패키지 설치

시스템을 최신 상태로 업데이트하고 HTTPS 리포지토리 접근에 필요한 패키지들을 설치한다.

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg
```

### 2단계: containerd 설치 및 구성

> **컨테이너 런타임 선택**
>
> 쿠버네티스 1.24 버전부터 dockershim이 제거되어 Docker를 직접 컨테이너 런타임으로 사용할 수 없으며, containerd, CRI-O 등 CRI(Container Runtime Interface)를 구현한 런타임을 사용해야 한다.

containerd는 Docker에서 분리된 산업 표준 컨테이너 런타임으로, 쿠버네티스와 함께 가장 널리 사용되는 런타임이다. Docker를 설치하면 containerd가 함께 설치되지만, 쿠버네티스 전용으로 containerd만 설치해도 된다.

```bash
# Docker 리포지토리 설정
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# containerd 설치
sudo apt-get update
sudo apt-get install -y containerd.io

# containerd 설정
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

SystemdCgroup을 true로 설정하는 것은 kubelet과 containerd가 동일한 cgroup 드라이버(systemd)를 사용하도록 하여 안정성을 높이기 위함이다.

### 3단계: 시스템 설정

쿠버네티스가 정상 작동하려면 스왑을 비활성화하고 네트워크 관련 커널 모듈과 파라미터를 설정해야 한다.

```bash
# 스왑 비활성화 (쿠버네티스 필수 요구사항)
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# 필요한 커널 모듈 로드
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# 네트워크 설정
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

스왑을 비활성화하는 이유는 쿠버네티스의 스케줄러가 노드의 실제 메모리 사용량을 기반으로 Pod를 배치하는데, 스왑이 활성화되어 있으면 메모리 사용량 계산이 부정확해지고 성능 예측이 어려워지기 때문이다.

### 4단계: 쿠버네티스 컴포넌트 설치

kubeadm, kubelet, kubectl을 설치한다. kubeadm은 클러스터 부트스트래핑 도구이고, kubelet은 노드에서 실행되는 에이전트이며, kubectl은 클러스터 관리를 위한 CLI 도구다.

```bash
# 쿠버네티스 리포지토리 설정
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# 설치
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# 자동 업데이트 방지 (클러스터 안정성을 위해)
sudo apt-mark hold kubelet kubeadm kubectl
```

### 5단계: 클러스터 초기화

kubeadm을 사용하여 컨트롤 플레인을 초기화한다. `--pod-network-cidr` 옵션은 Pod 네트워크의 IP 대역을 지정하며, 사용할 CNI 플러그인에 맞게 설정해야 한다.

```bash
# 필요한 이미지 미리 다운로드
sudo kubeadm config images pull

# 클러스터 초기화
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

초기화가 완료되면 kubectl 설정을 위한 안내가 출력된다.

```bash
# kubectl 설정
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 6단계: CNI 네트워크 플러그인 설치

> **CNI(Container Network Interface)란?**
>
> CNI는 컨테이너 네트워크 설정을 위한 표준 인터페이스로, 쿠버네티스에서 Pod 간 통신, 서비스 디스커버리, 네트워크 정책 등을 구현하는 플러그인이 이 인터페이스를 구현한다.

Calico, Flannel, Weave Net 등 다양한 CNI 플러그인이 있으며, 여기서는 네트워크 정책 지원과 성능이 우수한 Calico를 사용한다.

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 7단계: 단일 노드 설정 완료

기본적으로 쿠버네티스는 보안상의 이유로 컨트롤 플레인 노드에 일반 워크로드를 스케줄링하지 않는다. 단일 노드 클러스터에서 Pod를 실행하려면 이 제한(taint)을 제거해야 한다.

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## 클러스터 상태 확인

설치가 완료되면 다음 명령들로 클러스터 상태를 확인한다.

```bash
# 노드 상태 확인
kubectl get nodes

# 시스템 Pod 상태 확인
kubectl get pods -n kube-system
```

노드 상태가 `Ready`로 표시되고 모든 시스템 Pod가 `Running` 상태이면 클러스터가 정상적으로 구성된 것이다.

### 정상 출력 예시

```
NAME           STATUS   ROLES           AGE   VERSION
ubuntu-node    Ready    control-plane   5m    v1.30.x
```

## 테스트 애플리케이션 배포

클러스터가 정상 작동하는지 확인하기 위해 간단한 nginx Pod를 배포하고 서비스로 노출할 수 있다.

```bash
# nginx Pod 생성
kubectl run nginx --image=nginx --port=80

# 서비스로 노출
kubectl expose pod nginx --type=NodePort --port=80

# 확인
kubectl get pods
kubectl get services
```

## 문제 해결

### 일반적인 문제

| 문제 | 원인 | 해결 방법 |
|-----|------|----------|
| **노드 NotReady** | CNI 미설치 또는 오류 | CNI 플러그인 재설치, Pod 로그 확인 |
| **Pod Pending** | 리소스 부족 또는 taint | 리소스 확인, taint 제거 |
| **ImagePullBackOff** | 이미지 다운로드 실패 | 네트워크 확인, 이미지 이름 확인 |
| **CrashLoopBackOff** | 컨테이너 시작 실패 | Pod 로그 확인: `kubectl logs <pod>` |

클러스터 재설정이 필요한 경우 `sudo kubeadm reset` 명령으로 초기화하고 처음부터 다시 시작할 수 있으며, 이 경우 `/etc/cni/net.d/` 디렉토리와 `$HOME/.kube/` 디렉토리의 내용도 삭제해야 깨끗하게 재설치할 수 있다.

## 결론

Ubuntu 24.04 LTS에서 kubeadm을 사용하여 단일 노드 쿠버네티스 클러스터를 구축하는 과정을 살펴보았다. 단일 노드 클러스터는 쿠버네티스 학습, 개발 환경 구성, 테스트 용도로 적합하며, 프로덕션 환경에서는 고가용성을 위해 최소 3개의 컨트롤 플레인 노드와 별도의 워커 노드로 구성된 다중 노드 클러스터를 권장한다.
