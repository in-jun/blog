---
title: "Homelab #9 - Building a Monitoring System"
date: 2025-02-28T08:46:48+09:00
draft: false
description: "This guide explains how to build a simple monitoring system by installing Prometheus, Grafana, and Loki in a homelab Kubernetes environment."
tags:
    [
        "kubernetes",
        "homelab",
        "monitoring",
        "prometheus",
        "grafana",
        "loki",
        "gitops",
    ]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-cicd-2), we completed the CI/CD system and built a project automation system. This guide explores how to build a basic monitoring system for the homelab Kubernetes cluster. We will install Prometheus and Grafana and configure basic dashboards to provide an at-a-glance view of cluster status. Additionally, we will install Loki for log collection to create an integrated monitoring environment.

![Grafana](image.png)

## The Need for Monitoring

When operating a homelab Kubernetes cluster, the following information needs to be checked periodically:

1. **Cluster Status**: Status of nodes, pods, deployments, etc.
2. **Resource Usage**: CPU, memory, disk, and network usage
3. **Application Status**: Whether pods are operating normally
4. **System Logs**: Log data for identifying causes when problems occur

To visually monitor this information, we use the following tools:

-   **Prometheus**: Collection and storage of time-series metric data
-   **Grafana**: Visualization of collected data and dashboard provision
-   **Loki**: Log collection and query tool

## Installing Kube-Prometheus-Stack

We use Kube-Prometheus-Stack, a Helm chart that allows us to install and manage both Prometheus and Grafana at once. As with previous guides, we will install using the GitOps approach.

### Creating Directory and File Structure

```bash
mkdir -p k8s-resource/apps/kube-prometheus-stack/templates
cd k8s-resource/apps/kube-prometheus-stack
```

### Creating Chart.yaml

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

This file defines the use of version 68.1.0 of the kube-prometheus-stack chart provided by the Prometheus Community.

### Creating values.yaml

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

The characteristics of this configuration are as follows:

1. **Alertmanager**: Disabled to conserve resources.
2. **Grafana**: Allows anonymous access so dashboards can be viewed without login.
3. **Prometheus**: Data retention period is set to 5 days to limit disk usage.
4. **Resource Limits**: Appropriate resource limits are set for each component.
5. **Loki Data Source**: Pre-adds Loki data source to Grafana to enable log querying.

### Configuring Ingress

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

### Committing Changes and Deploying

Add and commit the created files to the Git repository:

```bash
git add .
git commit -m "Add kube-prometheus-stack configuration"
git push
```

ArgoCD will detect the changes and automatically deploy Kube-Prometheus-Stack. You can check the installation status with the following command:

```bash
kubectl get pods -n kube-prometheus-stack
```

When successfully installed, you should see results similar to the following:

```
NAME                                                      READY   STATUS    RESTARTS   AGE
alertmanager-kube-prometheus-stack-alertmanager-0         2/2     Running   0          2m
kube-prometheus-stack-grafana-7dc95d688d-vwm6j            3/3     Running   0          2m
kube-prometheus-stack-kube-state-metrics-c6d6bc845-zrdbp  1/1     Running   0          2m
kube-prometheus-stack-operator-5dc88c8847-9xp6g           1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-4jlnz       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-7m8nj       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-c445j       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-j7lf6       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-w4q9v       1/1     Running   0          2m
prometheus-kube-prometheus-stack-prometheus-0              2/2     Running   0          2m
```

## Installing Loki-Stack

Now we install Loki-Stack for log collection and analysis. Loki is a horizontally scalable log aggregation system inspired by Prometheus.

### Creating Directory and File Structure

```bash
mkdir -p k8s-resource/apps/loki-stack/templates
cd k8s-resource/apps/loki-stack
```

### Creating Chart.yaml

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

### Creating values.yaml

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

The characteristics of this configuration are as follows:

1. **Loki**: Allocates 20Gi storage for storing log data and is configured to reject logs older than 7 days (168 hours).
2. **Promtail**: Enables the agent that collects logs from each node and sends them to Loki.
3. **Grafana**: Disabled since it was already installed with Kube-Prometheus-Stack.
4. **ServiceMonitor**: Enabled so that Prometheus can collect Loki metrics.

### Committing Changes and Deploying

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

## Accessing the Monitoring System

Modify the hosts file to enable access to Grafana and Prometheus:

```
192.168.0.200 prometheus.injunweb.com grafana.injunweb.com
```

You can now access the following URLs in your web browser:

-   Grafana: http://grafana.injunweb.com
-   Prometheus: http://prometheus.injunweb.com

## Exploring Grafana Dashboards

Kube-Prometheus-Stack provides several useful dashboards by default. When you access Grafana, click the "Dashboards" icon in the left menu and check the list of pre-configured dashboards in the "Browse" section.

In particular, the "Kubernetes / Compute Resources" related dashboards in the "General" folder are very useful for understanding cluster resource usage. Additionally, the "Node Exporter" related dashboards allow you to check detailed system metrics for each node, which helps with hardware-level monitoring.

## Exploring Logs with Loki

You can explore system logs in Grafana using the Loki data source. Loki uses a query language called LogQL to filter and search logs.

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

Through Loki, you can manage various logs centrally and quickly identify causes when problems occur.

## Conclusion

This concludes the homelab Kubernetes series. We have completed a full homelab Kubernetes environment by building everything from basic cluster installation to storage, networking, GitOps, CI/CD, and monitoring systems. With this infrastructure as a foundation, you can now test and develop various projects. Having a cloud-like environment at home without cost burden will be a great help for technology learning and experimentation.
