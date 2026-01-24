---
title: "Setting Up Single-Node Kubernetes Cluster on Ubuntu 24.04"
date: 2024-07-27T23:23:40+09:00
tags: ["Ubuntu", "Kubernetes", "Linux"]
description: "Setting up single-node Kubernetes cluster on Ubuntu 24.04."
draft: false
---

Kubernetes is a container orchestration platform that Google open-sourced in 2014. It is now managed by CNCF (Cloud Native Computing Foundation) and has become the de facto standard for automating the deployment, scaling, and management of containerized applications. Production environments configure multi-node clusters for high availability, but single-node clusters are sufficient for development, testing, and learning purposes. This guide covers the entire process of building a single-node Kubernetes cluster using kubeadm on Ubuntu 24.04 LTS.

## Kubernetes Architecture Overview

> **Kubernetes Cluster Components**
>
> A Kubernetes cluster consists of a Control Plane and Worker Nodes. The control plane manages the cluster state, while worker nodes run actual container workloads.

The Kubernetes control plane consists of components including the API server (kube-apiserver), scheduler (kube-scheduler), controller manager (kube-controller-manager), and etcd. On worker nodes, kubelet communicates with the container runtime to create and manage Pods. In a single-node cluster, one node performs both control plane and worker node roles, enabling resource-efficient learning and development environment configuration.

### Main Components

| Component | Role | Location |
|-----------|------|----------|
| **kube-apiserver** | Cluster API endpoint, all communication hub | Control Plane |
| **etcd** | Cluster state store (key-value database) | Control Plane |
| **kube-scheduler** | Places Pods on appropriate nodes | Control Plane |
| **kube-controller-manager** | Cluster state reconciliation (replication, node management, etc.) | Control Plane |
| **kubelet** | Manages Pod lifecycle on nodes | All Nodes |
| **kube-proxy** | Service networking, load balancing | All Nodes |

## Prerequisites

Building a single-node Kubernetes cluster requires at least 2 CPU cores, 2GB RAM, and 20GB storage. An Ubuntu 24.04 LTS environment with root or sudo privileges and internet connectivity is needed. The same procedure applies whether building on virtual machines, cloud instances, or physical servers.

### System Requirements

| Item | Minimum | Recommended |
|------|---------|-------------|
| **CPU** | 2 cores | 4+ cores |
| **RAM** | 2 GB | 4+ GB |
| **Storage** | 20 GB | 50+ GB |
| **Network** | Internet connection | Static IP recommended |

## Installation Process

### Step 1: System Update and Essential Package Installation

Update the system to the latest state and install packages required for HTTPS repository access.

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common gnupg
```

### Step 2: containerd Installation and Configuration

> **Container Runtime Selection**
>
> Since Kubernetes 1.24, dockershim has been removed, meaning Docker cannot be used directly as a container runtime. Runtimes that implement CRI (Container Runtime Interface) such as containerd or CRI-O must be used.

containerd is an industry-standard container runtime that was separated from Docker and is the most widely used runtime with Kubernetes. Installing Docker also installs containerd, but containerd alone can be installed for Kubernetes-only use.

```bash
# Docker repository setup
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# containerd installation
sudo apt-get update
sudo apt-get install -y containerd.io

# containerd configuration
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
sudo systemctl enable containerd
```

Setting SystemdCgroup to true ensures that kubelet and containerd use the same cgroup driver (systemd), improving stability.

### Step 3: System Configuration

For Kubernetes to work properly, swap must be disabled and network-related kernel modules and parameters must be configured.

```bash
# Disable swap (Kubernetes requirement)
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Load required kernel modules
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# Network settings
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

sudo sysctl --system
```

The reason for disabling swap is that the Kubernetes scheduler places Pods based on actual node memory usage. If swap is enabled, memory usage calculations become inaccurate and performance prediction becomes difficult.

### Step 4: Kubernetes Component Installation

Install kubeadm, kubelet, and kubectl. kubeadm is a cluster bootstrapping tool, kubelet is an agent running on nodes, and kubectl is a CLI tool for cluster management.

```bash
# Kubernetes repository setup
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Installation
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

# Prevent automatic updates (for cluster stability)
sudo apt-mark hold kubelet kubeadm kubectl
```

### Step 5: Cluster Initialization

Initialize the control plane using kubeadm. The `--pod-network-cidr` option specifies the IP range for the Pod network and must be set according to the CNI plugin being used.

```bash
# Pre-download required images
sudo kubeadm config images pull

# Initialize cluster
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

Upon completion, instructions for kubectl configuration are displayed.

```bash
# kubectl configuration
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### Step 6: CNI Network Plugin Installation

> **What is CNI (Container Network Interface)?**
>
> CNI is a standard interface for container network configuration. Plugins that implement Pod-to-Pod communication, service discovery, and network policies in Kubernetes implement this interface.

Various CNI plugins exist including Calico, Flannel, and Weave Net. Here we use Calico for its excellent network policy support and performance.

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### Step 7: Complete Single-Node Setup

By default, Kubernetes does not schedule general workloads on control plane nodes for security reasons. To run Pods on a single-node cluster, this restriction (taint) must be removed.

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## Verify Cluster Status

After installation, verify cluster status with the following commands.

```bash
# Check node status
kubectl get nodes

# Check system Pod status
kubectl get pods -n kube-system
```

If the node status shows `Ready` and all system Pods are `Running`, the cluster is properly configured.

### Expected Output Example

```
NAME           STATUS   ROLES           AGE   VERSION
ubuntu-node    Ready    control-plane   5m    v1.30.x
```

## Test Application Deployment

To verify the cluster is working properly, deploy a simple nginx Pod and expose it as a service.

```bash
# Create nginx Pod
kubectl run nginx --image=nginx --port=80

# Expose as service
kubectl expose pod nginx --type=NodePort --port=80

# Verify
kubectl get pods
kubectl get services
```

## Troubleshooting

### Common Problems

| Problem | Cause | Solution |
|---------|-------|----------|
| **Node NotReady** | CNI not installed or error | Reinstall CNI plugin, check Pod logs |
| **Pod Pending** | Insufficient resources or taint | Check resources, remove taint |
| **ImagePullBackOff** | Image download failure | Check network, verify image name |
| **CrashLoopBackOff** | Container start failure | Check Pod logs: `kubectl logs <pod>` |

If cluster reset is needed, initialize with `sudo kubeadm reset` and start over. In this case, contents of `/etc/cni/net.d/` directory and `$HOME/.kube/` directory should also be deleted for a clean reinstall.

## Conclusion

This guide covered the process of building a single-node Kubernetes cluster using kubeadm on Ubuntu 24.04 LTS. Single-node clusters are suitable for Kubernetes learning, development environment configuration, and testing purposes. For production environments, a multi-node cluster with at least 3 control plane nodes and separate worker nodes is recommended for high availability.
