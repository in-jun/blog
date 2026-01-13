---
title: "Homelab #3 - Setting Up Kubernetes Storage"
date: 2025-02-25T08:05:41+09:00
draft: false
description: "This guide explains how to install and configure the Longhorn distributed storage system in a homelab Kubernetes environment."
tags: ["kubernetes", "homelab", "longhorn", "storage", "gitops", "argocd"]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-gitops), we set up a GitOps environment by installing ArgoCD. This guide explains how to install and configure the Longhorn distributed storage system in a homelab Kubernetes cluster.

![Longhorn Logo](image.png)

## Storage Challenges in a Homelab Environment

One of the biggest challenges when building a homelab Kubernetes cluster is configuring storage. However, most practical applications such as databases, monitoring tools, and backup systems require persistent storage.

![Storage Challenges](image-1.png)

Initially, I tried the following approaches:

1. **Local Storage**: I used local storage on each node, but this caused issues when pods were rescheduled to different nodes and couldn't access their data.

2. **NFS**: I used a separate NAS as an NFS server, but this created a single point of failure. NFS also had stability issues in Kubernetes environments.

3. **Rook-Ceph**: I attempted to use Rook-Ceph, but it had high overhead and resource requirements. It felt too heavy for my homelab environment (Dell OptiPlex Micro).

After several trials and errors, I chose Longhorn. Longhorn is lightweight, easy to install, and well-suited as a distributed storage system for homelab scale.

## Problems Solved by Longhorn

After adopting Longhorn, the following problems were resolved:

1. **Data Persistence**: Data is no longer lost even when node failures occur. Previously, data could disappear after node reboots.

2. **Workload Mobility**: Pods can now access the same volumes even when moved to different nodes.

3. **Backup and Recovery**: Important data can be easily protected with built-in backup functionality.

4. **Ease of Management**: Storage status can be viewed and managed at a glance through the UI dashboard.

## Introduction to Longhorn

Longhorn is a lightweight distributed block storage system for Kubernetes. It is a CNCF incubating project developed by Rancher and has the following characteristics:

![Longhorn Architecture](image-2.png)

-   Distributed storage system utilizing each node's disk
-   Provides high availability by replicating volume data across multiple nodes
-   Easy management with intuitive UI
-   Built-in backup and recovery features
-   Relatively lightweight, making it suitable for resource-constrained homelab environments

## Longhorn Installation Requirements

Before installing Longhorn, verify that nodes meet the following requirements:

1. **Supported OS**: Ubuntu, Debian, CentOS, RHEL, etc.
2. **Docker runtime** or **containerd** runtime
3. **open-iscsi** package installed
4. **NFSv4 client** (if using NFS for backups)

### Prerequisites

Install the required packages on all nodes:

```bash
# Run on all nodes
sudo apt-get update
sudo apt-get install -y open-iscsi nfs-common
sudo systemctl enable iscsid
sudo systemctl start iscsid
```

These commands perform the following tasks:

-   Update package lists
-   Install iSCSI initiator and NFS client
-   Enable and start the iSCSI service

Verify that the iSCSI service is running on each node:

```bash
sudo systemctl status iscsid
```

You should see `active (running)` status like this:

```
● iscsid.service - iSCSI Initiator Daemon
     Loaded: loaded (/lib/systemd/system/iscsid.service; enabled; vendor preset: enabled)
     Active: active (running) since Tue 2025-02-25 08:30:15 UTC; 5s ago
```

## Installing Longhorn with GitOps

We will install Longhorn using GitOps methodology with the ArgoCD setup from the previous guide. We will utilize our core Git repository at `https://github.com/injunweb/k8s-resource`.

### 1. Add Longhorn Helm Chart Configuration to Git Repository

First, clone the repository locally and create the Longhorn directory structure:

```bash
git clone https://github.com/injunweb/k8s-resource.git
cd k8s-resource
mkdir -p apps/longhorn-system
cd apps/longhorn-system
```

Create the `Chart.yaml` file:

```yaml
apiVersion: v2
name: longhorn
description: Longhorn Distributed Block Storage for Kubernetes
type: application
version: 1.0.0
appVersion: 1.4.0
dependencies:
    - name: longhorn
      version: 1.4.0
      repository: https://charts.longhorn.io
```

This file defines the Helm chart's metadata and dependencies. The chart will install Longhorn v1.4.0 from the official repository.

Create the `values.yaml` file to define Longhorn settings:

```yaml
longhorn:
    defaultSettings:
        defaultDataPath: /var/lib/longhorn # Default path where data will be stored
        defaultDataLocality: best-effort # Try to store data on local node when possible
        replicaAutoBalance: best-effort # Automatically balance replicas across nodes

    preUpgradeChecker:
        jobEnabled: false # Disable pre-upgrade check job
```

Explanation of each setting:

-   **defaultDataPath**: The path where Longhorn will store data on nodes. The default is `/var/lib/longhorn`.
-   **defaultDataLocality**: When set to `best-effort`, data is stored on the node where the workload is running when possible. This improves performance.
-   **replicaAutoBalance**: When set to `best-effort`, replicas are automatically balanced across nodes. This prevents storage usage imbalances between nodes.
-   **preUpgradeChecker.jobEnabled**: Disables the pre-upgrade check job for Longhorn upgrades. This must be set to `false` to work without errors in ArgoCD.

Commit and push the changes:

```bash
git add .
git commit -m "Add Longhorn configuration"
git push
```

### 2. Automatic Deployment Process via ApplicationSet

Let's examine the process where ArgoCD's ApplicationSet feature automatically creates the Longhorn application as configured in the previous guide:

![ApplicationSet Workflow](image-3.png)

1. The ApplicationSet controller monitors the registered Git repository (`https://github.com/injunweb/k8s-resource`).

2. When it detects the `apps/longhorn-system` directory, it creates a new ArgoCD application according to the template.

3. The created application name becomes `longhorn-system`, matching the directory name.

4. Similarly, the namespace is also created as `longhorn-system`.

5. ArgoCD applies the Helm chart detected in that directory to the cluster.

First, verify the application created by ApplicationSet:

```bash
kubectl get applications -n argocd
```

Confirm that the `longhorn-system` application has been created in the output:

```
NAME             SYNC STATUS   HEALTH STATUS
app-of-apps      Synced        Healthy
infra-apps-root  Synced        Healthy
longhorn-system  Synced        Healthy
```

You can also see the newly created `longhorn-system` application in the ArgoCD UI.

### 3. Verify Longhorn Deployment Status

Verify that Longhorn components have been successfully deployed:

```bash
kubectl -n longhorn-system get pods
```

All Pods should be in `Running` state like this:

```
NAME                                                READY   STATUS    RESTARTS   AGE
csi-attacher-77d87d4c79-bkw5r                       1/1     Running   0          5m
csi-attacher-77d87d4c79-d42zq                       1/1     Running   0          5m
csi-attacher-77d87d4c79-zlszr                       1/1     Running   0          5m
...
```

## Accessing the Longhorn Web UI

Longhorn provides an intuitive web UI. You can access the web UI using port forwarding:

```bash
kubectl port-forward -n longhorn-system svc/longhorn-frontend 8080:80
```

This command forwards port 8080 on your local system to port 80 of the Longhorn frontend service. Access `http://localhost:8080` in a web browser.

![Longhorn Dashboard](image-4.png)

## Testing

Let's verify that Longhorn works properly by creating a test PVC and Pod:

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
    name: longhorn-test-pvc
spec:
    accessModes:
        - ReadWriteOnce
    storageClassName: longhorn
    resources:
        requests:
            storage: 1Gi
---
apiVersion: v1
kind: Pod
metadata:
    name: volume-test
spec:
    containers:
        - name: volume-test
          image: nginx:alpine
          volumeMounts:
              - name: test-volume
                mountPath: /data
    volumes:
        - name: test-volume
          persistentVolumeClaim:
              claimName: longhorn-test-pvc
```

This manifest creates two resources:

1. A PVC requesting 1GB of Longhorn storage
2. A Pod running an nginx container that mounts this PVC at the `/data` path

Apply this manifest and verify that the volume is properly mounted:

```bash
kubectl apply -f test.yaml
kubectl exec -it volume-test -- df -h /data
```

If mounted successfully, the `/data` directory will be displayed as a 1GB volume.

## Conclusion

We have now built a distributed storage system for our homelab Kubernetes cluster. Longhorn is a lightweight storage solution suitable for homelab environments. It provides adequate data protection features with minimal resource requirements.

Previously, it was difficult to reliably operate stateful applications due to limitations of NFS or local storage. With Longhorn, we can now build cloud-like storage infrastructure in a homelab environment.

In the [next post](homelab-k8s-internal-services), we will explore how to configure external access to the homelab.
