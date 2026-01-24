---
title: "Mini PC Kubernetes #1: Cluster Setup"
date: 2025-02-24T07:26:52+09:00
draft: false
description: "Building a Kubernetes cluster on Mini PC environment."
tags: ["Kubernetes", "Mini PC", "Infrastructure"]
series: ["Mini PC Kubernetes"]
---

## Overview

This series covers the process of building a Kubernetes cluster in a homelab environment and configuring a complete CI/CD pipeline for side projects and testing purposes. It demonstrates how to set up an environment where you can experiment with and learn various cloud-native technologies such as container orchestration, networking, storage, monitoring, and GitOps by running Kubernetes at home without the burden of cloud service costs.

![Cluster](image.png)

The hardware setup consists of five Dell OptiPlex Micro units as nodes with TP-Link router and switch for networking. The Dell OptiPlex Micro is a mini PC with low power consumption that can be purchased affordably on the used market. The purchased models are equipped with 9th generation i5 CPUs, 16GB of memory, and 256GB SSDs, providing sufficient specifications to handle Kubernetes workloads.

> **What is a Homelab?**
>
> A homelab is a personal server environment built at home, typically set up by IT professionals or developers for learning purposes or personal projects. It involves configuring servers, network equipment, and storage to create an environment similar to an actual data center, offering the advantage of experimenting with and experiencing various technologies without cloud costs.

## OS Installation

First, an operating system must be installed on each node. Windows 10, which was originally installed on the Dell OptiPlex Micro units, is removed and replaced with Ubuntu 24.04 LTS Server version. Ubuntu Server was chosen because it has no GUI, resulting in lower system resource usage and optimization for server environments like Kubernetes. The LTS (Long Term Support) version provides security updates and technical support for 5 years until 2029, making it suitable for stable server operations.

For installation, download the Ubuntu ISO file, create a bootable USB using tools like Rufus or balenaEtcher, then select USB boot in the BIOS to proceed with the installation.

![Installation initial screen](image-1.png)

After booting, select "Try or Install Ubuntu" and proceed with the installation. Basic setup screens for language selection, keyboard layout, and network configuration will appear. Following the defaults, the server configuration screen shown below will appear.

![SSH setup screen](image-2.png)

On this screen, the "Install OpenSSH server" option must be selected. This is an essential configuration for remotely accessing and managing the server over the network without a monitor and keyboard. In a headless server environment, SSH becomes the only means of access, so it is important to enable it at installation time.

![Additional package setup screen](image-3.png)

On the additional package installation screen, pre-configured packages like Docker or PostgreSQL are offered. However, since these will be installed separately in the Kubernetes environment, proceed without selecting anything here. Necessary packages can be installed directly after installation is complete.

![Installation complete screen](image-4.png)

When installation is complete, the screen shown above will appear. Select "Reboot Now" to restart the system. Repeat this process identically on all nodes to complete the operating system installation.

## Network Configuration

Once the operating system installation is complete, the network must be configured. In a Kubernetes cluster, inter-node communication is critical, making it essential to use static IPs instead of dynamic IPs assigned via DHCP.

![Network diagram](image-5.png)

The diagram above shows the configured network architecture, with one master node and four worker nodes connected through a switch and communicating with the external network through a router. Each node is assigned a static IP in the 192.168.0.x range.

For static IP configuration, refer to the [Ubuntu 24.04 LTS Static IP Configuration](/posts/ubuntu-2404-lts-set-static-ip/) post. IPs assigned via DHCP can change when the router reboots or the DHCP lease time expires, potentially compromising cluster stability. Using static IPs makes Kubernetes service discovery and load balancing configuration much simpler.

## Kubernetes Installation

With Ubuntu installation and network configuration complete, Kubernetes installation can now begin. To install Kubernetes, the container runtime containerd and the core Kubernetes components kubelet, kubeadm, and kubectl must first be installed.

> **Core Kubernetes Components**
>
> - **kubelet**: An agent running on each node that manages containers to ensure they run properly within pods.
> - **kubeadm**: A tool for bootstrapping Kubernetes clusters, responsible for cluster initialization and node joining.
> - **kubectl**: A CLI tool for interacting with the Kubernetes cluster, used for all management tasks.

Execute the following commands on all nodes (both master and worker nodes).

```bash
# Update system packages
sudo apt-get update && sudo apt-get upgrade -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Docker repository setup and containerd installation
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

# Kubernetes repository setup and installation
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

# Disable swap
sudo swapoff -a
sudo sed -i '/swap/d' /etc/fstab

# Load kernel modules and configure networking
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

# containerd configuration
sudo mkdir -p /etc/containerd
sudo containerd config default | sudo tee /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
sudo systemctl restart containerd

# Pre-download Kubernetes images
sudo kubeadm config images pull
```

The script above performs the following tasks:

1. **System package update**: Updates apt repositories to the latest state and installs essential dependency packages.
2. **containerd installation**: Installs containerd from the official Docker repository. Starting with Kubernetes 1.24, using containerd directly instead of Docker is recommended.
3. **Kubernetes component installation**: Installs kubelet, kubeadm, and kubectl from the official Kubernetes repository and prevents automatic upgrades with the `apt-mark hold` command.
4. **Swap disable**: Kubernetes requires swap to be disabled for memory management. Removing the swap entry from `/etc/fstab` maintains the disabled state after reboot.
5. **Kernel module and network configuration**: Loads the overlay and br_netfilter modules and enables IP forwarding to allow network communication between pods.
6. **containerd configuration optimization**: Enables SystemdCgroup so that kubelet and containerd use the same cgroup driver.

Once all required packages are installed on all nodes, initialize the Kubernetes cluster by executing the following command on the master node only.

```bash
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
```

The `--pod-network-cidr` option specifies the IP address range to use for the pod network. This value must match the CNI (Container Network Interface) plugin configuration. Here, 10.244.0.0/16 is used to match the default Calico network plugin configuration.

When initialization completes successfully, the following message will be displayed.

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

The `kubeadm join` command shown at the end of the output is used to add worker nodes to the cluster. This token expires after 24 hours, so note it down or generate a new one later with the `kubeadm token create --print-join-command` command.

Execute the following commands to configure the kubeconfig file so kubectl can be used on the master node.

```bash
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

The commands above copy the Kubernetes administrator configuration file to the current user's home directory and grant appropriate permissions to execute kubectl commands without sudo.

### CNI Plugin Installation

The Kubernetes cluster has been initialized, but pod communication between nodes is not yet possible. A CNI (Container Network Interface) plugin must be installed for the pod network to be configured and inter-node communication to be enabled.

> **What is Calico?**
>
> Calico is one of the most widely used CNI plugins in Kubernetes environments. Developed by Tigera and released as open source, it provides high-performance network routing using BGP (Border Gateway Protocol) and powerful network policy features that allow fine-grained control of inter-pod traffic.

Execute the following command on the master node to install Calico.

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/calico.yaml
```

This command installs all essential Calico components (calico-node, calico-kube-controllers, etc.) in the kube-system namespace. After installation, calico-node pods run on each node to handle inter-node network communication.

Now execute the previously saved `kubeadm join` command on all worker nodes to join them to the cluster.

```bash
sudo kubeadm join <master-ip>:6443 --token <token> --discovery-token-ca-cert-hash sha256:<hash>
```

Verify that all nodes have successfully joined the cluster with the following command on the master node.

```bash
kubectl get nodes
```

If all nodes are displayed in Ready status, the cluster has been successfully configured.

## Load Balancer Installation

One way to expose services externally in Kubernetes is to use the LoadBalancer type. In cloud environments like AWS or GCP, the cloud provider automatically provisions a load balancer, but in on-premises or homelab environments, a separate load balancer implementation is required.

> **What is MetalLB?**
>
> MetalLB is a load balancer implementation for bare-metal Kubernetes clusters. Development was started by Google's David Anderson in 2017 and is currently managed as a CNCF sandbox project. It supports Layer 2 mode and BGP mode, enabling LoadBalancer type services to be used in the same way as cloud environments.

Install MetalLB with the following command.

```bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.9/config/manifests/metallb-native.yaml
```

This command installs MetalLB's controller and speaker components in the metallb-system namespace. The controller manages IP address allocation, and the speaker runs on each node to handle network responses for assigned IPs.

Verify that the installation is complete with the following command.

```bash
kubectl get pods -n metallb-system
```

One controller pod and a speaker pod on each node should be displayed in Running status.

### MetalLB Layer 2 Mode

In this series, MetalLB is used in Layer 2 mode. In this mode, the MetalLB speaker implements load balancer functionality by using ARP (IPv4) or NDP (IPv6) protocols to respond to the assigned virtual IP with its own MAC address.

For example, when MetalLB assigns the virtual IP 192.168.0.200 to a service, when another device on the same network sends an ARP request asking for the MAC address of 192.168.0.200, the MetalLB speaker responds with the MAC address of the node hosting that service, ensuring traffic is delivered to the correct node.

To learn more about ARP and NDP protocols, refer to the following posts:

- [Complete Understanding of How ARP Protocol Works](/posts/how-arp-protocol-works/)
- [Understanding IPv6 NDP (Neighbor Discovery Protocol)](/posts/understanding-ipv6-ndp/)

## Conclusion

This post covered building a Kubernetes cluster consisting of 5 nodes using Dell OptiPlex Micro units, configuring the pod network with Calico CNI, and setting up a load balancer with MetalLB. A basic Kubernetes environment is now ready, and the foundation has been laid to deploy and operate various workloads on this cluster.

The next post covers installing ArgoCD to manage Kubernetes resources using the GitOps approach.

[Next Post: Homelab Kubernetes #2 - Setting Up GitOps with ArgoCD](/posts/homelab-k8s-gitops/)
