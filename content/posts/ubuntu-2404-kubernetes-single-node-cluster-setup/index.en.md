---
title: "Setting Up a Single-Node Kubernetes Cluster on Ubuntu 24.04 LTS"
date: 2024-07-27T23:23:40+09:00
tags: ["kubernetes", "ubuntu"]
draft: false
---

## 1. Introduction

Kubernetes is a powerful open-source platform for automating the deployment, scaling, and management of containerized applications. Primarily useful for large-scale distributed systems, it can also be deployed on a single node for development and testing purposes. This guide will walk you through the step-by-step process of installing and configuring a single-node Kubernetes cluster on Ubuntu 24.04 LTS.

## 2. Prerequisites

-   A machine with Ubuntu 24.04 LTS (recommended minimum 2 CPUs, 2GB RAM, 20GB storage)
-   Root or sudo privileges
-   Internet connectivity

## 3. Installation Procedure

### 3.1 Update the System and Install Prerequisite Packages

First, let's update your system to the latest state and install some essential base packages.

```bash
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
```

### 3.2 Install Docker

Kubernetes requires a container runtime, and we will be using Docker for that.

```bash
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo 
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu 
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | 
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io

sudo systemctl start docker
sudo systemctl enable docker
```

### 3.3 Install Kubernetes Components

Now, let's install the core Kubernetes components: kubelet, kubeadm, and kubectl.

```bash
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl
```

### 3.4 Configure the System

A few system settings need to be adjusted for Kubernetes to work correctly.

```bash
# Disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Configure iptables
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

### 3.5 Configure containerd

Let's also configure containerd to work with Kubernetes.

```bash
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd
```

### 3.6 Pull kubeadm Images

Before initializing the Kubernetes cluster using kubeadm, let's pull the required images in advance.

```bash
sudo kubeadm config images pull
```

### 3.7 Initialize the Kubernetes Cluster

We are now ready to initialize the Kubernetes cluster.

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

Upon successful initialization, you should see output similar to:

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

Follow the instructions to complete the kubectl setup:

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

### 3.8 Install a Network Plugin

For pods to communicate with each other, we need to install a network plugin. We will be using Calico:

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

### 3.9 Complete Single-Node Setup

By default, Kubernetes does not schedule workloads on the control plane node. To enable running workloads on the master node, execute the following command:

```bash
kubectl taint nodes --all node-role.kubernetes.io/control-plane-
```

## 4. Verify Cluster Status

With the installation complete, let's verify the status of our cluster:

```bash
kubectl get nodes
```

If everything is set up correctly, you should see output similar to:

```
NAME               STATUS   ROLES           AGE     VERSION
your-hostname      Ready    control-plane   5m      v1.30.x
```

## 5. Conclusion

Congratulations! You have successfully deployed a single-node Kubernetes cluster on Ubuntu 24.04 LTS. This environment is suitable for development, testing, and learning purposes. For production deployments, it is recommended to set up a multi-node cluster for high availability and scalability.
