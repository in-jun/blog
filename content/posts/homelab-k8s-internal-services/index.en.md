---
title: "Homelab Kubernetes #4 - Traefik Ingress and Internal/External Service Separation"
date: 2025-02-25T11:37:43+09:00
draft: false
description: "This guide covers installing the Traefik ingress controller on a homelab Kubernetes cluster and configuring secure access to management interfaces like ArgoCD and Longhorn by separating internal and external services."
tags: ["kubernetes", "homelab", "traefik", "ingress", "gitops", "argocd", "metallb"]
series: ["Homelab Kubernetes"]
---

## Overview

In the [previous post](/posts/homelab-k8s-storage/), we installed the Longhorn distributed storage system to build a persistent storage environment where data is retained even when pods restart or move to different nodes. This post covers installing the Traefik ingress controller on a homelab Kubernetes cluster and configuring secure access to management interfaces from the internal network.

![Traefik Logo](image.png)

## Choosing an Ingress Controller

There are several methods for exposing Kubernetes services externally in a homelab environment:

1. **NodePort**: A method for accessing services through specific ports (30000-32767 range) on each node. While simple to configure, it requires remembering port numbers and cannot use standard HTTP/HTTPS ports.

2. **LoadBalancer**: A method that uses load balancer implementations like MetalLB to assign dedicated IPs to each service. While standard ports can be used, requiring a separate IP for each service can be inefficient in homelab environments with limited IP resources.

3. **Ingress**: A method that defines rules for routing HTTP/HTTPS traffic to services. It provides various features such as URL path and hostname-based routing, SSL/TLS termination, and authentication, allowing multiple services to be exposed through a single IP.

Using an ingress controller allows routing multiple services based on hostnames or paths with just a single IP address and standard ports (80, 443), making it the most suitable method for homelab environments.

### Why Traefik Was Chosen

Initially, the Nginx Ingress Controller, the most widely used in the Kubernetes ecosystem, was installed. However, it required separately installing cert-manager for automatic Let's Encrypt certificate issuance and configuring a ClusterIssuer. Several configuration errors were experienced, particularly with custom headers and middleware configuration.

> **What is Traefik?**
>
> Traefik is a cloud-native reverse proxy and load balancer that Containous (now Traefik Labs) began developing in 2015. It is optimized for microservices environments and Kubernetes, with built-in support for dynamic configuration changes and Let's Encrypt integration, making it widely used in container orchestration environments.

Eventually, a more integrated solution was sought. Traefik was chosen because it provides all necessary features in a single package, with the following advantages:

- **Configuration Simplicity**: The Let's Encrypt ACME protocol is built-in by default, enabling automatic certificate issuance and renewal without a separate cert-manager.
- **Dashboard Functionality**: A built-in web dashboard allows visual monitoring of current routing status, service status, and middleware configuration.
- **Helm Chart Support**: An official Helm chart is provided, facilitating declarative deployment in a GitOps manner.
- **CRD Support**: CRDs (Custom Resource Definitions) like IngressRoute and Middleware enable finer-grained routing rules and traffic control than standard Ingress.
- **Middleware Capabilities**: Various middleware can be declaratively configured for request/response transformation, Basic/Digest authentication, retry, rate limiting, and more.

## Separating Internal and External Services

Security is a critical consideration in homelab environments. If cluster management interfaces like ArgoCD, Longhorn dashboard, and Traefik dashboard are exposed to the external internet, they become directly exposed to security threats. To prevent this, a strategy of separating internal management services and external public services with different IP addresses is used.

![Network Separation](image-1.png)

1. **Internal Load Balancer (192.168.0.200)**: Exposes only management interfaces like ArgoCD, Longhorn, and Traefik dashboard. Accessible only from within the home network and excluded from router port forwarding targets.

2. **External Load Balancer (192.168.0.201)**: Exposes only public services like blogs and personal projects. Configured with router port forwarding to be accessible from the external internet.

This design implements separation at the service level. Even if a management interface's IngressRoute is accidentally connected to an external entrypoint, the IP itself is not routed externally, preventing security incidents. Note that this setup represents service-level separation rather than complete network isolation.

## Preparing for Traefik Installation

### 1. Configuring MetalLB IP Address Pools

Before deploying Traefik, IP address pools must first be configured in MetalLB for internal/external service separation. The following configuration files are created in the [GitHub repository](https://github.com/injunweb/k8s-resources).

`apps/traefik/templates/ipaddresspool.yaml` file:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
    name: traefik-ip-pool
    namespace: metallb-system
spec:
    addresses:
        - 192.168.0.200-192.168.0.201
```

This manifest defines an IP address pool that MetalLB can allocate to LoadBalancer-type services, including two IPs for internal (192.168.0.200) and external (192.168.0.201) use. These IP addresses should be excluded from the home network's DHCP server allocation range to prevent IP conflicts.

`apps/traefik/templates/l2advertisement.yaml` file:

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
    name: traefik-l2-advertisement
    namespace: metallb-system
spec:
    ipAddressPools:
        - traefik-ip-pool
```

This manifest defines MetalLB's Layer 2 mode advertisement configuration, allowing IPs from the defined IP address pool to be advertised on the network via the ARP protocol so traffic can be routed to the correct nodes.

### 2. Helm Chart Configuration

`apps/traefik/Chart.yaml` file:

```yaml
apiVersion: v2
name: traefik
description: Traefik Ingress Controller for Kubernetes
type: application
version: 1.0.0
appVersion: "v3.2.2"
dependencies:
    - name: traefik
      version: "33.2.1"
      repository: "https://traefik.github.io/charts"
```

This file defines fetching and installing the v33.2.1 chart from the official Traefik Helm chart repository.

The `apps/traefik/values.yaml` file contains detailed Traefik settings. The key configurations are examined below.

#### Internal/External Entrypoint Configuration

```yaml
ports:
    web:
        port: 8000
        expose:
            default: true
            internal: false
        exposedPort: 80
        protocol: TCP
    websecure:
        port: 8443
        expose:
            default: true
            internal: false
        exposedPort: 443
        protocol: TCP
        tls:
            enabled: true
            certResolver: "letsencrypt"
    intweb:
        port: 8001
        expose:
            default: false
            internal: true
        exposedPort: 80
        protocol: TCP
    intwebsec:
        port: 8444
        expose:
            default: false
            internal: true
        exposedPort: 443
        protocol: TCP
        tls:
            enabled: true
            certResolver: "letsencrypt"
```

Here, `web` and `websecure` are external entrypoints exposed through the external load balancer (192.168.0.201), while `intweb` and `intwebsec` are internal entrypoints accessible only through the internal load balancer (192.168.0.200). Each entrypoint uses different ports internally but is exposed externally on standard HTTP (80) and HTTPS (443) ports.

#### Let's Encrypt Configuration

```yaml
certificatesResolvers:
    letsencrypt:
        acme:
            email: your-email@example.com
            httpChallenge:
                entryPoint: web
            storage: /data/acme.json
```

This configuration sets up automatic SSL/TLS certificate issuance and renewal using the Let's Encrypt ACME protocol. The HTTP-01 challenge method uses HTTP requests entering through the `web` entrypoint to prove control over the domain. Certificate issuance will work properly after external access configuration is completed, which will be covered in the next post.

#### Internal/External Service Separation

```yaml
service:
    enabled: true
    single: true
    type: LoadBalancer
    annotations:
        metallb.universe.tf/loadBalancerIPs: 192.168.0.201
    additionalServices:
        internal:
            type: LoadBalancer
            annotations:
                metallb.universe.tf/loadBalancerIPs: 192.168.0.200
            labels:
                traefik-service-type: internal
```

This configuration creates two separate LoadBalancer services:

1. **Default Service (traefik)**: Assigned IP address 192.168.0.201 to handle traffic for externally accessible public services.
2. **Internal Service (traefik-internal)**: Assigned IP address 192.168.0.200 to handle traffic for management interfaces accessible only from the internal network.

The `metallb.universe.tf/loadBalancerIPs` annotation instructs MetalLB to assign specific IP addresses to the respective services.

#### Persistent Volume Configuration for Certificate Storage

```yaml
deployment:
    initContainers:
        - name: volume-permissions
          image: busybox:1.36
          command:
              [
                  "sh",
                  "-c",
                  "touch /data/acme.json; chmod -v 600 /data/acme.json; adduser -S 65532 65532; chown -R 65532:65532 /data/acme.json",
              ]
          volumeMounts:
              - name: data
                mountPath: /data

persistence:
    enabled: true
    accessMode: ReadWriteOnce
    size: 128Mi
    storageClass: longhorn

podSecurityContext:
    fsGroup: 65532
    fsGroupChangePolicy: "OnRootMismatch"
    runAsGroup: 65532
    runAsNonRoot: true
    runAsUser: 65532
```

This configuration sets up a persistent volume for storing Let's Encrypt certificates using the Longhorn storage class. The init container sets appropriate permissions (600) and ownership on the ACME certificate file, allowing Traefik to securely store and manage certificates. Certificates are retained even when pods restart or move to different nodes.

### 3. Deploying with GitOps

Committing and pushing the configuration files to the Git repository triggers ArgoCD to automatically detect changes and deploy to the cluster:

```bash
git add apps/traefik
git commit -m "Add Traefik ingress controller with internal/external separation"
git push origin main
```

Verify that deployment is complete:

```bash
kubectl get pods -n traefik
```

The Traefik pod should appear in Running status:

```
NAME                       READY   STATUS    RESTARTS   AGE
traefik-5d7b9b4f6c-xtz89   1/1     Running   0          5m
```

Verify that two LoadBalancer services have been created:

```bash
kubectl get svc -n traefik
```

```
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
traefik            LoadBalancer   10.43.xxx.xxx   192.168.0.201   80:xxxxx/TCP,443:xxxxx/TCP   5m
traefik-internal   LoadBalancer   10.43.xxx.xxx   192.168.0.200   80:xxxxx/TCP,443:xxxxx/TCP   5m
```

## Configuring Internal Service Access

Now that Traefik is installed, IngressRoutes are configured to access internal management interfaces like ArgoCD, Longhorn, and Traefik dashboard. These routes use internal entrypoints (`intweb`, `intwebsec`) to be accessible only from the internal network.

### 1. Configuring Internal Service Routing

`apps/argocd/templates/ingressroute.yaml` file for ArgoCD access:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: argocd-server-internal
    namespace: argocd
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - match: Host(`argocd.injunweb.com`)
          kind: Rule
          services:
              - name: argocd-server
                port: 80
```

This manifest routes requests for the `argocd.injunweb.com` host to port 80 of the ArgoCD server service through internal entrypoints.

`apps/longhorn-system/templates/ingressroute.yaml` file for Longhorn UI:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: longhorn-frontend-internal
    namespace: longhorn-system
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - match: Host(`longhorn.injunweb.com`)
          kind: Rule
          services:
              - name: longhorn-frontend
                port: 80
```

This manifest routes requests for the `longhorn.injunweb.com` host to the Longhorn frontend service through internal entrypoints.

The Traefik dashboard was configured directly in the Helm chart's `values.yaml`:

```yaml
ingressRoute:
    dashboard:
        enabled: true
        matchRule: Host(`traefik.injunweb.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
        services:
            - name: api@internal
              kind: TraefikService
        entryPoints: ["intweb", "intwebsec"]
```

This configuration enables access to Traefik's internal API service (`api@internal`) through the `traefik.injunweb.com/dashboard` path to use the dashboard.

Add the created manifest files to the Git repository:

```bash
git add apps/argocd/templates/ingressroute.yaml
git add apps/longhorn-system/templates/ingressroute.yaml
git commit -m "Add internal IngressRoutes for admin interfaces"
git push origin main
```

### 2. Local Hosts File Configuration

Modify the local computer's hosts file to access internal services by domain name.

**Linux/macOS**:

```bash
sudo vim /etc/hosts
```

**Windows** (administrator privileges required):

```
C:\Windows\System32\drivers\etc\hosts
```

Add the following line to the hosts file:

```
192.168.0.200 traefik.injunweb.com argocd.injunweb.com longhorn.injunweb.com
```

This configuration resolves the domain names to the internal load balancer IP (192.168.0.200), allowing direct access to internal services without going through a DNS server.

## Testing Access

With all configurations complete, test whether each service is accessible from the internal network.

Access the following URLs in a web browser and verify that each service displays properly:

- `http://traefik.injunweb.com/dashboard/` - Traefik dashboard
- `http://argocd.injunweb.com` - ArgoCD UI
- `http://longhorn.injunweb.com` - Longhorn UI

If all services are properly accessible, the internal service configuration is complete. In the current state, these services are connected only to the internal IP (192.168.0.200), so they are not accessible from the external internet.

## Conclusion

This post covered installing the Traefik ingress controller on a homelab Kubernetes cluster and configuring secure access to management interfaces by separating internal and external services. By utilizing MetalLB's IP address pools to separate internal and external load balancers, exposure of management interfaces to the outside can be prevented.

The next post covers configuring DDNS and port forwarding to make homelab services accessible from the external internet using the external load balancer.

[Next Post: Homelab Kubernetes #5 - External Access with DDNS and Port Forwarding](/posts/homelab-k8s-external-access/)
