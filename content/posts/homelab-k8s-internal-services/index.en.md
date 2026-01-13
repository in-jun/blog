---
title: "Homelab #4 - Configuring Internal Service Access"
date: 2025-02-25T11:37:43+09:00
draft: false
description: "This guide explains how to install the Traefik ingress controller and configure internal network access for a homelab Kubernetes cluster."
tags: ["kubernetes", "homelab", "traefik", "ingress", "gitops"]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-storage), we installed the Longhorn distributed storage system. This post explores how to install the Traefik ingress controller on a homelab Kubernetes cluster and configure internal network access.

![Traefik Logo](image.png)

## Choosing an Ingress Controller

There are several methods for exposing Kubernetes services externally in a homelab environment:

1. **NodePort**: Access services through specific ports (30000-32767) on each node
2. **LoadBalancer**: Use load balancer implementations like MetalLB
3. **Ingress**: Define rules for routing HTTP/HTTPS traffic to services

NodePort is simple to configure but requires remembering port numbers. LoadBalancer requires a separate IP for each service. In contrast, an ingress controller provides various features such as URL path and hostname-based routing, SSL/TLS termination, and authentication. This makes it the most suitable method for homelab environments.

### Why Traefik Was Chosen

Initially, I installed the Nginx Ingress Controller. However, it required separately installing cert-manager for Let's Encrypt certificate issuance and configuring an appropriate ClusterIssuer. The configuration was complex, and I encountered several failures particularly with custom headers and middleware configuration. Eventually, I sought a more integrated solution. Traefik was chosen because it provides all necessary features in a single package.

Key advantages of Traefik:

1. **Configuration simplicity**: Let's Encrypt integration is built-in by default, facilitating certificate automation.
2. **Dashboard functionality**: Traffic routes and service status can be visually monitored.
3. **Helm chart support**: An official Helm chart is provided for easy GitOps-style deployment.
4. **CRD support**: Fine-grained routing rules can be defined with CRDs like IngressRoute.
5. **Middleware capabilities**: Provides middleware functions for request/response transformation, authentication, retry, etc.

## Separating Internal and External Services

One important consideration in homelab environments is security. Management interfaces like ArgoCD, Longhorn, and Traefik dashboard should not be exposed externally. To achieve this, we use a strategy that clearly separates internal and external services:

![Network Separation](image-1.png)

1. **Internal load balancer (192.168.0.200)**: Exposes only management interfaces and is accessible only from the internal network
2. **External load balancer (192.168.0.201)**: Exposes only public services and is accessible from outside through port forwarding

This design implements separation at the service level, reducing the risk of accidentally exposing critical management interfaces externally. Note that this setup represents service separation rather than complete network isolation.

## Preparing for Traefik Installation

### 1. Configuring MetalLB IP Address Pools

Before deploying Traefik, we must first configure IP address pools in MetalLB for internal/external service separation. The following files were created in the [GitHub repository](https://github.com/injunweb/k8s-resources):

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

This manifest defines an IP address pool that MetalLB can allocate to LoadBalancer services. The pool includes two IPs (192.168.0.200-201) for internal and external services.

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

This manifest defines MetalLB's Layer 2 mode advertisement configuration. The defined IP address pool is advertised on the network so traffic can be routed.

### 2. Helm Chart Configuration

`apps/traefik/Chart.yaml` file:

```yaml
apiVersion: v2
name: traefik
description: traefik chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v3.2.2"
dependencies:
    - name: traefik
      version: "33.2.1"
      repository: "https://traefik.github.io/charts"
```

This file defines the version and repository information for the Traefik Helm chart. We will use version v33.2.1 from the official Traefik chart repository.

The `apps/traefik/values.yaml` file contains various configurations. I'll explain only the key sections:

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

Here, `web` and `websecure` are external entrypoints, while `intweb` and `intwebsec` are internal entrypoints. Each entrypoint uses different ports internally but is exposed externally on the same standard ports (80, 443). The `expose` setting determines which service each entrypoint is exposed to (internal or external).

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

This configuration enables automatic issuance and renewal of SSL/TLS certificates using Let's Encrypt. The HTTP challenge method uses HTTP requests to prove control over the domain. Certificate issuance will work properly after external access configuration is completed. This will be covered in the next post.

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

This configuration creates two separate services:

1. **Default service**: Named `traefik`, with IP address `192.168.0.201`, for externally accessible services.
2. **Internal service**: Named `traefik-internal`, with IP address `192.168.0.200`, for internal management services.

The `metallb.universe.tf/loadBalancerIPs` annotation assigns specific IPs to each service. Exclude these IP addresses from DHCP server settings to avoid conflicts.

#### Permissions and Certificate Configuration

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
    storageClass: longhorn # Longhorn storage class

podSecurityContext:
    fsGroup: 65532
    fsGroupChangePolicy: "OnRootMismatch"
    runAsGroup: 65532
    runAsNonRoot: true
    runAsUser: 65532
```

This configuration sets up volume permissions for certificate storage and uses the Longhorn storage class to persist data. An init container sets appropriate permissions and ownership. This allows Traefik to securely store and manage certificate files.

### 3. Deploying with GitOps

Push the configuration files to the Git repository so ArgoCD automatically deploys them:

```bash
git add apps/traefik
git commit -m "Add Traefik configuration with MetalLB IP pool"
git push origin main
```

To verify the deployment is complete, run the following command:

```bash
kubectl get pods -n traefik
```

If deployed successfully, the Traefik pod will appear in Running status:

```
NAME                       READY   STATUS    RESTARTS   AGE
traefik-5d7b9b4f6c-xtz89   1/1     Running   0          5m
```

## Configuring Internal Service Access

Now that Traefik is installed, we configure access to internal management interfaces (ArgoCD, Longhorn, Traefik dashboard).

### 1. Configuring Internal Service Routing

We set up IngressRoutes for internal management interfaces. These routes use the `intweb` and `intwebsec` entrypoints to be accessible only from the internal network.

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

This manifest routes requests for the `argocd.injunweb.com` host to the ArgoCD server through internal entrypoints (`intweb`, `intwebsec`).

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

Add the created manifest files to the Git repository:

```bash
git add apps/argocd/templates/ingressroute.yaml
git add apps/longhorn-system/templates/ingressroute.yaml
git commit -m "Add internal IngressRoutes for admin interfaces"
git push origin main
```

The Traefik dashboard was configured directly in the Traefik Helm chart settings under the `ingressRoute.dashboard` section:

```yaml
ingressRoute:
    dashboard:
        enabled: true
        annotations: {}
        labels: {}
        matchRule: Host(`traefik.injunweb.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
        services:
            - name: api@internal
              kind: TraefikService
        entryPoints: ["intweb", "intwebsec"]
```

This configuration makes the Traefik dashboard accessible through the `traefik.injunweb.com/dashboard` path. The `api@internal` service points to Traefik's internal API. The dashboard is implemented through this internal API.

### 2. Local Host Configuration

To easily access internal services, modify the hosts file:

**Linux/macOS**:

```bash
sudo vim /etc/hosts
```

Add the following line to the hosts file:

```
192.168.0.200 traefik.injunweb.com argocd.injunweb.com longhorn.injunweb.com
```

This resolves the domain names to the internal IP (192.168.0.200). You can now access internal services.

Save and exit.

## Testing Access

Now that all configurations are complete, let's test whether access is possible from the internal network.

### Internal Network Testing

From the internal network, access each service through the following URLs:

-   http://traefik.injunweb.com/dashboard/ - Traefik dashboard
-   http://argocd.injunweb.com - ArgoCD UI
-   http://longhorn.injunweb.com - Longhorn UI

Verify that all services are properly accessible.

## Conclusion

This post explored how to install the Traefik ingress controller on a homelab Kubernetes cluster and configure secure access to internal services.

In the current state, internal services are connected only to the internal IP (192.168.0.200), and DDNS configuration and port forwarding for external access have not yet been configured. Therefore, access from external networks is not possible.

The [next post](homelab-k8s-external-access) will explore external access configuration and DDNS setup for the homelab Kubernetes cluster.
