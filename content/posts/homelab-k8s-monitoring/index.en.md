---
title: "Homelab Kubernetes #9 - Monitoring with Prometheus and Grafana"
date: 2025-02-28T08:46:48+09:00
draft: false
description: "This guide covers installing Kube-Prometheus-Stack and Loki-Stack in a homelab Kubernetes cluster to build an integrated monitoring system for metric collection, visualization, and log aggregation."
tags: ["kubernetes", "homelab", "monitoring", "prometheus", "grafana", "loki", "gitops"]
series: ["Homelab Kubernetes"]
---

## Overview

In the [previous post](/posts/homelab-k8s-cicd-2/), we completed the CI/CD pipeline integrating GitHub Actions with ArgoCD and built a project automation system. This post covers how to install Prometheus and Grafana to collect and visualize metrics, and install Loki to centrally collect and analyze logs, building an integrated monitoring environment for the homelab Kubernetes cluster.

![Grafana](image.png)

## The Need for Monitoring

When operating a homelab Kubernetes cluster, you need to periodically check node and pod status, resource usage like CPU and memory, whether applications are operating normally, and log data for identifying causes when problems occur. To visually monitor this information, the following tools are used.

> **What is Prometheus?**
>
> Prometheus is an open-source monitoring system that started at SoundCloud in 2012 and joined the CNCF (Cloud Native Computing Foundation) in 2016. It collects and stores metrics in a time-series database and allows data querying and analysis through a powerful query language called PromQL. It is the most widely used monitoring tool in Kubernetes environments.

> **What is Grafana?**
>
> Grafana is an open-source data visualization platform developed by Torkel Ödegaard in 2014. It can integrate with various data sources like Prometheus, Loki, and Elasticsearch to build dashboards, and provides an intuitive UI and rich visualization options to effectively present monitoring data.

> **What is Loki?**
>
> Loki is a log aggregation system developed by Grafana Labs in 2018. Inspired by Prometheus, it uses label-based indexing to collect and store logs, and enables resource-efficient log management by indexing only metadata rather than full log content.

## Installing Kube-Prometheus-Stack

Since installing and configuring Prometheus and Grafana individually is complex, we use Kube-Prometheus-Stack, a Helm chart that allows installing and managing both tools at once. As with previous posts, we install using the GitOps approach.

### 1. Creating Directory and File Structure

```bash
mkdir -p k8s-resource/apps/kube-prometheus-stack/templates
cd k8s-resource/apps/kube-prometheus-stack
```

### 2. Creating Chart.yaml

Create the `Chart.yaml` file as follows:

```yaml
apiVersion: v2
name: kube-prometheus-stack
description: kube-prometheus-stack chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v0.79.2"
dependencies:
    - name: kube-prometheus-stack
      version: "68.1.0"
      repository: "https://prometheus-community.github.io/helm-charts"
```

This configuration defines using version 68.1.0 of the kube-prometheus-stack chart provided by the Prometheus Community. This chart includes all components needed for monitoring including Prometheus, Grafana, Alertmanager, Node Exporter, and Kube State Metrics.

### 3. Creating values.yaml

Create the `values.yaml` file as follows:

```yaml
kube-prometheus-stack:
    alertmanager:
        enabled: false

    grafana:
        enabled: true
        adminPassword: prom-operator
        persistence:
            enabled: true
            size: 5Gi
        resources:
            requests:
                cpu: 200m
                memory: 512Mi
            limits:
                cpu: 500m
                memory: 1Gi
        ingress:
            enabled: false
        grafana.ini:
            auth:
                disable_login_form: true
            auth.anonymous:
                enabled: true
                org_role: Admin
        additionalDataSources:
            - name: Loki
              type: loki
              url: http://loki-stack.loki-stack.svc.cluster.local:3100

    prometheus:
        enabled: true
        ingress:
            enabled: false
        prometheusSpec:
            retention: 5d
            resources:
                requests:
                    cpu: 500m
                    memory: 2Gi
                limits:
                    cpu: 1
                    memory: 2Gi
            storageSpec:
                volumeClaimTemplate:
                    spec:
                        resources:
                            requests:
                                storage: 20Gi

    prometheusOperator:
        enabled: true
        resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 200m
                memory: 256Mi

    kubeStateMetrics:
        enabled: true
        resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 200m
                memory: 256Mi

    nodeExporter:
        enabled: true
        resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 200m
                memory: 256Mi

    thanosRuler:
        enabled: false
```

The key characteristics of this configuration are as follows:

- **Alertmanager**: Disabled to conserve resources since an alerting system is not essential in a homelab environment.
- **Grafana**: Configured to allow anonymous access so dashboards can be viewed without login, and pre-adds the Loki data source to enable log querying.
- **Prometheus**: Data retention period is set to 5 days to limit disk usage, and 20Gi storage is allocated.
- **Resource Limits**: Appropriate CPU and memory limits are set for each component to efficiently use cluster resources.

### 4. Configuring Ingress

Create the `templates/ingressroute.yaml` file to configure access through Traefik:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: prometheus-grafana-route
    namespace: kube-prometheus-stack
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - kind: Rule
          match: Host(`prometheus.injunweb.com`)
          services:
              - name: kube-prometheus-stack-prometheus
                port: 9090
        - kind: Rule
          match: Host(`grafana.injunweb.com`)
          services:
              - name: kube-prometheus-stack-grafana
                port: 80
```

This IngressRoute uses the `intweb` and `intwebsec` entry points to make it accessible only from the internal network. `prometheus.injunweb.com` routes to the Prometheus server, and `grafana.injunweb.com` routes to Grafana.

### 5. Committing Changes and Deploying

Add and commit the created files to the Git repository:

```bash
git add .
git commit -m "Add kube-prometheus-stack configuration"
git push
```

ArgoCD detects the changes and automatically deploys Kube-Prometheus-Stack. You can check the installation status with the following command:

```bash
kubectl get pods -n kube-prometheus-stack
```

When successfully installed, results similar to the following are displayed:

```
NAME                                                       READY   STATUS    RESTARTS   AGE
kube-prometheus-stack-grafana-7dc95d688d-vwm6j             3/3     Running   0          2m
kube-prometheus-stack-kube-state-metrics-c6d6bc845-zrdbp   1/1     Running   0          2m
kube-prometheus-stack-operator-5dc88c8847-9xp6g            1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-4jlnz       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-7m8nj       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-c445j       1/1     Running   0          2m
prometheus-kube-prometheus-stack-prometheus-0              2/2     Running   0          2m
```

## Installing Loki-Stack

Now we install Loki-Stack for log collection and analysis. Loki is a horizontally scalable log aggregation system that uses label-based indexing similar to Prometheus to collect and store logs.

### 1. Creating Directory and File Structure

```bash
mkdir -p k8s-resource/apps/loki-stack/templates
cd k8s-resource/apps/loki-stack
```

### 2. Creating Chart.yaml

Create the `Chart.yaml` file as follows:

```yaml
apiVersion: v2
name: loki-stack
description: loki-stack chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v2.9.3"
dependencies:
    - name: loki-stack
      version: "2.10.2"
      repository: "https://grafana.github.io/helm-charts"
```

### 3. Creating values.yaml

Create the `values.yaml` file as follows:

```yaml
loki-stack:
    loki:
        enabled: true
        persistence:
            enabled: true
            size: 20Gi
        config:
            limits_config:
                enforce_metric_name: false
                reject_old_samples: true
                reject_old_samples_max_age: 168h
            schema_config:
                configs:
                    - from: 2025-01-16
                      store: boltdb-shipper
                      object_store: filesystem
                      schema: v11
                      index:
                          prefix: index_
                          period: 24h
        resources:
            requests:
                cpu: 200m
                memory: 256Mi
            limits:
                cpu: 1000m
                memory: 1Gi

    promtail:
        enabled: true
    grafana:
        enabled: false
    prometheus:
        enabled: false
    filebeat:
        enabled: false
    fluent-bit:
        enabled: false
    logstash:
        enabled: false
    serviceMonitor:
        enabled: true
```

The key characteristics of this configuration are as follows:

- **Loki**: Allocates 20Gi storage for storing log data and is configured to reject logs older than 7 days (168 hours) to manage disk usage.
- **Promtail**: Enables the DaemonSet agent that collects container logs from each node and sends them to Loki.
- **Grafana, Prometheus**: Disabled since they were already installed with Kube-Prometheus-Stack.
- **ServiceMonitor**: Enables ServiceMonitor so Prometheus can collect Loki metrics.

### 4. Committing Changes and Deploying

Add and commit the created files to the Git repository:

```bash
git add .
git commit -m "Add Loki-Stack configuration"
git push
```

After installation is complete, you can verify with the following command:

```bash
kubectl get pods -n loki-stack
```

```
NAME                            READY   STATUS    RESTARTS   AGE
loki-stack-0                    1/1     Running   0          2m
loki-stack-promtail-xxxxx       1/1     Running   0          2m
loki-stack-promtail-yyyyy       1/1     Running   0          2m
```

## Accessing the Monitoring System

Modify the local computer's hosts file to enable access to Grafana and Prometheus:

```
192.168.0.200 prometheus.injunweb.com grafana.injunweb.com
```

You can now access the following URLs in your web browser:

- Grafana: `http://grafana.injunweb.com`
- Prometheus: `http://prometheus.injunweb.com`

## Using Grafana Dashboards

Kube-Prometheus-Stack provides several useful dashboards for cluster monitoring by default. When you access Grafana, click the "Dashboards" icon in the left menu and check the list of pre-configured dashboards in the "Browse" section.

In particular, the "Kubernetes / Compute Resources" related dashboards in the "General" folder are very useful for understanding cluster CPU, memory, and network usage at the namespace, pod, and container level. The "Node Exporter" related dashboards allow checking detailed hardware-level metrics for each node such as disk I/O, network traffic, and system load, which helps with infrastructure monitoring.

## Exploring Logs with Loki

You can centrally explore all container logs in the cluster using the Loki data source in Grafana. Loki uses a query language called LogQL to filter and search logs.

### Basic Log Queries

After navigating to the "Explore" menu in Grafana and selecting "Loki" as the data source, you can start querying logs. Here are some useful query examples:

**Viewing logs for a specific namespace:**

```
{namespace="kube-system"}
```

**Viewing logs for a specific pod:**

```
{namespace="argocd", pod=~"argocd-server.*"}
```

**Filtering only error logs:**

```
{namespace="traefik"} |= "error"
```

**Viewing logs within a specific time range:**

```
{namespace="default"} |= "timeout" | json
```

Through Loki, you can centrally manage logs distributed across multiple pods and nodes, and quickly identify causes when problems occur using LogQL queries.

## Conclusion

This post covered installing Kube-Prometheus-Stack and Loki-Stack in a homelab Kubernetes cluster to build an integrated monitoring system for metric collection, visualization, and log aggregation.

This concludes the homelab Kubernetes series. We have completed a full homelab Kubernetes environment by building everything from basic cluster installation to ArgoCD GitOps environment, Longhorn distributed storage, Traefik ingress controller, Vault secret management, CI/CD pipeline, and a monitoring system using Prometheus, Grafana, and Loki. With this infrastructure as a foundation, you can test and develop various projects in a production-like Kubernetes environment without cloud service cost burden.
