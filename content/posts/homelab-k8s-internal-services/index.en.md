---
title: "Homelab Build Log #4: Internal Services"
date: 2025-02-25T11:37:43+09:00
draft: false
description: "Configuring internal services in Kubernetes cluster."
tags: ["Kubernetes", "Network", "Service"]
series: ["Homelab Build Log"]
---

## Overview

In the [previous post](/posts/homelab-k8s-storage/), we installed the Longhorn distributed storage system to build a persistent storage environment where data is retained even when pods restart or move to different nodes. This post covers installing the Traefik ingress controller on a homelab Kubernetes cluster and configuring secure access to management interfaces from the internal network.

![Traefik Logo](image.png)

## Choosing an Ingress Controller

There are several methods for exposing Kubernetes services externally in a homelab environment:

1. **NodePort**: A method for accessing services through specific ports (30000-32767 range) on each node. While simple to configure, it requires remembering port numbers and cannot use standard HTTP/HTTPS ports.

2. **LoadBalancer**: A method that uses load balancer implementations like MetalLB to assign dedicated IPs to each service. While standard ports can be used, requiring a separate IP for each service can be inefficient in homelab environments with limited IP resources.

3. **Ingress**: A method that defines rules for routing HTTP/HTTPS traffic to services. It provides various features such as URL path and hostname-based routing, SSL/TLS termination, and authentication, allowing multiple services to be exposed through a single IP.

In my homelab, an ingress controller ended up being the best fit because it let me route multiple services with a single IP and the standard 80/443 ports.

### Why Traefik Was Chosen

Initially, I installed the Nginx Ingress Controller, which is the most widely used option in the Kubernetes ecosystem. However, it required installing cert-manager separately for automatic Let's Encrypt certificate issuance and configuring a ClusterIssuer. I also ran into several configuration issues, particularly with custom headers and middleware.

> **What is Traefik?**
>
> Traefik is a cloud-native reverse proxy and load balancer that Containous (now Traefik Labs) began developing in 2015. It is optimized for microservices environments and Kubernetes, with built-in support for dynamic configuration changes and Let's Encrypt integration, making it widely used in container orchestration environments.

Eventually, I wanted a more integrated solution, so I chose Traefik because it provided all the features I needed in a single package:

- **Configuration Simplicity**: The Let's Encrypt ACME protocol is built-in by default, enabling automatic certificate issuance and renewal without a separate cert-manager.
- **Dashboard Functionality**: A built-in web dashboard allows visual monitoring of current routing status, service status, and middleware configuration.
- **Helm Chart Support**: An official Helm chart is provided, facilitating declarative deployment in a GitOps manner.
- **CRD Support**: CRDs (Custom Resource Definitions) like IngressRoute and Middleware enable finer-grained routing rules and traffic control than standard Ingress.
- **Middleware Capabilities**: Various middleware can be declaratively configured for request/response transformation, Basic/Digest authentication, retry, rate limiting, and more.

## Separating Internal and External Services

Security was one of my main concerns in the homelab. If I exposed cluster management interfaces like ArgoCD, the Longhorn dashboard, and the Traefik dashboard to the internet, I would be putting those tools directly in front of public traffic. To reduce that risk, I separated internal management services and external public services by assigning them different IP addresses.

![Network Separation](image-1.png)

1. **Internal Load Balancer (192.168.0.200)**: Exposes only management interfaces like ArgoCD, Longhorn, and Traefik dashboard. Accessible only from within the home network and excluded from router port forwarding targets.

2. **External Load Balancer (192.168.0.201)**: Exposes only public services like blogs and personal projects. Configured with router port forwarding to be accessible from the external internet.

This design implements separation at the service level. Even if a management interface's IngressRoute is accidentally connected to an external entrypoint, the IP itself is not routed externally, preventing security incidents. Note that this setup represents service-level separation rather than complete network isolation.

## Preparing for Traefik Installation

### 1. Configuring MetalLB IP Address Pools

Before deploying Traefik, I first carved out IP pools in MetalLB for internal and external separation. I committed the following files to the [GitHub repository](https://github.com/injunweb/k8s-resources).

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

This file declares a dependency on v33.2.1 of the official Traefik Helm chart, so Helm fetches and installs it from the upstream repository.

The `apps/traefik/values.yaml` file contains the settings I actually used for Traefik. The important parts are below.

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

This configuration sets up automatic SSL/TLS certificate issuance and renewal using the Let's Encrypt ACME protocol. The HTTP-01 challenge method uses HTTP requests entering through the `web` entrypoint to prove control over the domain. Certificate issuance started working once I finished the external access configuration, which I cover in the next post.

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

This configuration sets up a persistent volume for storing Let's Encrypt certificates using the Longhorn storage class. The init container sets appropriate permissions (600) and ownership on the ACME certificate file so Traefik can store and manage certificates safely, even when pods restart or move to different nodes.

### 3. Deploying with GitOps

After committing and pushing these files, ArgoCD picked them up and deployed Traefik to the cluster:

```bash
git add apps/traefik
git commit -m "Add Traefik ingress controller with internal/external separation"
git push origin main
```

Once that finished, I checked the deployment status with:

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

With Traefik in place, I added IngressRoutes for ArgoCD, Longhorn, and the Traefik dashboard. These routes use only the internal entrypoints (`intweb`, `intwebsec`).

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

This configuration exposes Traefik's internal API service (`api@internal`) through the `traefik.injunweb.com/dashboard` path.

I then added those manifests to the Git repository:

```bash
git add apps/argocd/templates/ingressroute.yaml
git add apps/longhorn-system/templates/ingressroute.yaml
git commit -m "Add internal IngressRoutes for admin interfaces"
git push origin main
```

### 2. Local Hosts File Configuration

On my workstation, I also added those hostnames to the hosts file so I could reach the services by domain name.

**Linux/macOS**:

```bash
sudo vim /etc/hosts
```

**Windows** (administrator privileges required):

```
C:\Windows\System32\drivers\etc\hosts
```

I added the following line to the hosts file:

```
192.168.0.200 traefik.injunweb.com argocd.injunweb.com longhorn.injunweb.com
```

This maps the domain names to the internal load balancer IP (192.168.0.200), which let me reach the internal services directly without relying on DNS.

## Testing Access

Once everything was wired up, I checked that each service was actually reachable from inside the network.

I opened the following URLs in a web browser to verify that each service loaded properly:

- `http://traefik.injunweb.com/dashboard/` - Traefik dashboard
- `http://argocd.injunweb.com` - ArgoCD UI
- `http://longhorn.injunweb.com` - Longhorn UI

If all services are properly accessible, the internal service configuration is complete. In the current state, these services are connected only to the internal IP (192.168.0.200), so they are not accessible from the external internet.

## Conclusion

This post covered how I installed Traefik in the homelab Kubernetes cluster and separated internal and external services. Splitting the load balancers with MetalLB IP pools made the management interfaces much easier to keep off the public side.

The next post covers configuring DDNS and port forwarding to make homelab services accessible from the external internet using the external load balancer.

[Next Post: Homelab Build Log #5: External Access](/posts/homelab-k8s-external-access/)
