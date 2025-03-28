---
title: "Ubuntu 24.04 LTS 에서 단일 노드 쿠버네티스 클러스터 구축하기"
date: 2024-07-27T23:23:40+09:00
tags: ["kubernetes", "ubuntu"]
draft: false
---

## 1. 서론

쿠버네티스(Kubernetes)는 컨테이너화된 애플리케이션의 배포, 확장, 관리를 자동화하는 강력한 오픈소스 플랫폼이다. 대규모 분산 시스템에서 특히 유용하지만, 개발 및 테스트 목적으로 단일 노드에서도 구축할 수 있다. 이 글에서는 Ubuntu 24.04 LTS 환경에서 단일 노드 쿠버네티스 클러스터를 설치하고 구성하는 과정을 단계별로 알아보자.

## 2. 사전 준비

-   Ubuntu 24.04 LTS가 설치된 컴퓨터 (최소 2 CPU, 2GB RAM, 20GB 저장공간 권장)
-   root 또는 sudo 권한
-   인터넷 연결

## 3. 설치 과정

### 3.1 시스템 업데이트 및 필수 패키지 설치

먼저 시스템을 최신 상태로 업데이트하고, 필요한 기본 패키지들을 설치하자.

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```

### 3.2 도커 설치

쿠버네티스는 컨테이너 런타임이 필요하다. 여기서는 도커를 사용할 것이다.

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo systemctl start docker
sudo systemctl enable docker
```

### 3.3 쿠버네티스 컴포넌트 설치

이제 쿠버네티스의 주요 컴포넌트인 kubelet, kubeadm, kubectl을 설치해 보자.

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 3.4 시스템 설정

쿠버네티스가 제대로 작동하려면 몇 가지 시스템 설정을 바꿔야 한다.

```bash
# 스왑 비활성화
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# iptables 설정
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

### 3.5 containerd 설정

쿠버네티스와 함께 사용할 containerd를 설정해 보자.

```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
```

### 3.6 kubeadm 이미지 pull

kubeadm을 사용하여 쿠버네티스 클러스터를 초기화하기 전에 필요한 이미지를 미리 pull해 두자.

```bash
sudo kubeadm config images pull
```

### 3.7 쿠버네티스 클러스터 초기화

이제 쿠버네티스 클러스터를 초기화할 준비가 됐다.

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

초기화가 완료되면 다음과 비슷한 메시지가 나올 것이다:

```
Your Kubernetes control-plane has initialized successfully!

To start using your cluster, you need to run the following as a regular user:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

You should now deploy a pod network to the cluster.
Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
  https://kubernetes.io/docs/concepts/cluster-administration/addons/

Then you can join any number of worker nodes by running the following on each as root:

kubeadm join <your-master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

이 지침을 따라 kubectl 설정을 완료하자:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 3.8 네트워크 플러그인 설치

Pod 간 통신을 위해 네트워크 플러그인을 설치해야 한다. 여기서는 Calico를 사용할 것이다:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 3.9 단일 노드 설정 완료

기본적으로 쿠버네티스는 컨트롤 플레인 노드에 워크로드를 스케줄링하지 않는다.
마스터 노드에서 워크로드를 실행하려면 다음 명령을 실행해야 한다:

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## 4. 클러스터 상태 확인

설치가 끝났다! 이제 클러스터의 상태를 확인해 보자:

```bash
kubectl get nodes
```

정상적으로 설치됐다면 다음과 비슷한 출력이 나올 것이다:

```
NAME               STATUS   ROLES           AGE     VERSION
your-hostname      Ready    control-plane   5m      v1.30.x
```

## 5. 결론

이렇게 해서 Ubuntu 24.04 LTS에서 단일 노드 쿠버네티스 클러스터를 성공적으로 구축했다. 이 환경은 개발, 테스트, 학습 목적으로 쓰기에 좋다. 실제 프로덕션 환경에서는 고가용성과 확장성을 위해 다중 노드 클러스터를 구성하는 게 좋다. 다음에는 다중 노드 클러스터 구축 방법에 대해 알아보자.
