---
title: "Homelab Build Log #7: IDP Foundations"
date: 2025-02-28T04:32:32+09:00
draft: false
description: "Setting up Harbor, Argo Events, and Argo Workflows as the foundation for an internal developer platform."
tags: ["Kubernetes", "CI/CD", "DevOps"]
series: ["Homelab Build Log"]
---

## Overview

In the [previous post](/posts/homelab-k8s-secrets/), we installed HashiCorp Vault to build a secure secrets management system. This post covers the foundational pieces I set up before the internal developer platform itself: Harbor container registry, Argo Events, and Argo Workflows.

![IDP foundations](image.png)

## Foundation Components for the IDP

For the IDP I had in mind, I first needed the following core components:

- **Container Registry**: A central repository for storing and distributing built container images, enabling self-management of images without depending on public registries like Docker Hub.
- **Event Processing System**: Responsible for detecting various events such as code changes in Git repositories and webhook receipts, and triggering subsequent tasks in response.
- **Workflow Engine**: An engine for defining and executing actual CI/CD tasks such as code building, test execution, and container image creation.
- **GitOps Deployment System**: A system that automatically synchronizes the desired state defined in Git repositories to the cluster. ArgoCD, which was installed in an earlier post in this series, handles this role.

In this post, I set up the container registry, event processing system, and workflow engine using Harbor, Argo Events, and Argo Workflows. In the next post, I connect these pieces to ArgoCD and the project template structure so they start to behave like an actual IDP.

## Installing Harbor

> **What is Harbor?**
>
> Harbor is a graduated project of the CNCF (Cloud Native Computing Foundation). It is an open-source container registry that started at VMware and was donated to CNCF in 2018. Beyond basic image storage functionality like Docker Hub, it provides enterprise-grade features including RBAC (Role-Based Access Control), vulnerability scanning, image signing, and replication policies, offering a complete solution for securely managing container images in private environments.

I chose Harbor because I wanted to run the image registry for the platform myself instead of depending on a public registry. Its vulnerability scanning and access control features also fit well with the kind of homelab environment I was trying to build.

### Harbor Helm Chart Configuration

As with the previous posts, I installed Harbor through the GitOps flow. I started by adding the Harbor directory and files to the repository:

```bash
mkdir -p k8s-resource/apps/harbor/templates
cd k8s-resource/apps/harbor
```

The `Chart.yaml` file looked like this:

```yaml
apiVersion: v2
name: harbor
description: harbor chart for Kubernetes
type: application
version: 1.0.0
appVersion: "2.12.0"
dependencies:
    - name: harbor
      version: "1.16.0"
      repository: "https://helm.goharbor.io"
```

I used the following `values.yaml` for Harbor:

```yaml
harbor:
    expose:
        type: ClusterIP
        tls:
            enabled: false

    externalURL: "https://harbor.injunweb.com:443"

    harborAdminPassword: "<path:argocd/data/harbor#harborAdminPassword>"

    registry:
        relativeurls: true
        upload_purging:
            age: 12h
            interval: 12h

    persistence:
        persistentVolumeClaim:
            registry:
                size: 15Gi
```

The key points of this configuration are:

- **expose.type: ClusterIP**: Configures the Harbor service to be accessible only within the cluster, with external access provided through Traefik IngressRoute.
- **harborAdminPassword**: Uses a Vault path reference so ArgoCD Vault Plugin replaces it with the actual password during deployment.
- **persistence**: Allocates 15GB of persistent storage to the registry for storing container images.
- **upload_purging**: Cleans up old upload files every 12 hours to efficiently manage storage.

### Traefik IngressRoute Configuration

For Harbor UI and API access, I created the following `templates/ingressroute.yaml`:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: harbor
    namespace: harbor
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - match: Host(`harbor.injunweb.com`) && PathPrefix(`/`)
          kind: Rule
          services:
              - name: harbor-portal
                namespace: harbor
                port: 80
          middlewares:
              - name: harbor-buffer
                namespace: harbor
        - match: Host(`harbor.injunweb.com`) && (PathPrefix(`/api/`) || PathPrefix(`/service/`) || PathPrefix(`/v2/`) || PathPrefix(`/chartrepo/`) || PathPrefix(`/c/`))
          kind: Rule
          services:
              - name: harbor-core
                namespace: harbor
                port: 80
          middlewares:
              - name: harbor-buffer
                namespace: harbor
```

This IngressRoute defines two routing rules: the default path routes to the Harbor web portal, and API-related paths (`/api/`, `/service/`, `/v2/`, `/chartrepo/`, `/c/`) route to the Harbor core service. It uses the `intweb` and `intwebsec` entry points to allow access only from the internal network.

I also added a buffering middleware in `templates/middleware.yaml` for larger image uploads:

```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
    name: harbor-buffer
    namespace: harbor
spec:
    buffering:
        maxRequestBodyBytes: 1000000000
        memRequestBodyBytes: 1000000000
        retryExpression: ""
```

This middleware sets the request body size limit to approximately 1GB, allowing large container images to be uploaded.

### Deploying Harbor

Once those files were ready, I committed and pushed them:

```bash
git add .
git commit -m "Add Harbor configuration"
git push
```

After that, ArgoCD deployed Harbor automatically and I checked the status with:

```bash
kubectl get pods -n harbor
```

When all Pods are in `Running` status, Harbor has been successfully deployed.

### Accessing and Testing Harbor

On my local machine, I added the following hosts entry:

```
192.168.0.200 harbor.injunweb.com
```

I accessed `https://harbor.injunweb.com` in a web browser and logged in with the `admin` account using the password stored in Vault. After logging in, I created a new project and tested image pushing from the Docker CLI:

```bash
docker login harbor.injunweb.com -u admin -p <password>
docker pull nginx:alpine
docker tag nginx:alpine harbor.injunweb.com/injunweb/nginx:alpine
docker push harbor.injunweb.com/injunweb/nginx:alpine
```

Once the image is successfully pushed, you can verify it in the Harbor UI.

## Installing Argo Events

> **What is Argo Events?**
>
> Argo Events is a Kubernetes-native event-driven automation framework. It is part of the Argoproj ecosystem and was donated to CNCF where it is actively developed. It supports over 20 event sources including GitHub webhooks, AWS SQS, Kafka, and NATS. When events are detected, it can trigger various targets such as Argo Workflows, Kubernetes object creation, and AWS Lambda.

The Argo Events architecture consists of three core components:

- **EventBus**: The transport layer responsible for message delivery between event sources and sensors, using NATS or JetStream as the backend.
- **EventSource**: Responsible for receiving events from external systems (GitHub, AWS SNS, webhooks, etc.) and forwarding them to the EventBus.
- **Sensor**: Subscribes to events from the EventBus and performs specified triggers (Argo Workflow execution, HTTP requests, etc.) when events matching filter conditions occur.

### Argo Events Helm Chart Configuration

I added Argo Events to the same GitOps repository in the following structure:

```bash
mkdir -p k8s-resource/apps/argo-events/templates
cd k8s-resource/apps/argo-events
```

Create the `Chart.yaml` file:

```yaml
apiVersion: v2
name: argo-events
description: argo-events chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v1.9.3"
dependencies:
    - name: argo-events
      version: "2.4.9"
      repository: "https://argoproj.github.io/argo-helm"
```

The `values.yaml` file uses the default settings, so I left it empty:

```yaml
# Using default configuration
```

### Deploying Argo Events

Then I committed and pushed those changes:

```bash
git add .
git commit -m "Add Argo Events configuration"
git push
```

Check the deployment status:

```bash
kubectl get pods -n argo-events
```

## Installing Argo Workflows

> **What is Argo Workflows?**
>
> Argo Workflows is a Kubernetes-native workflow engine. It was developed by Applatix (now Intuit) in 2017 and is currently maintained as a CNCF graduated project. It can define and execute complex container-based tasks using DAG (Directed Acyclic Graph) or step-based approaches, and is used for various workloads including CI/CD pipelines, data processing, and machine learning pipelines.

The main features of Argo Workflows include:

- **DAG and Step-based Workflows**: Define dependencies between tasks to execute sequentially or in parallel.
- **Artifact Management**: Transfer files or data between workflow steps and store them in S3, GCS, MinIO, etc.
- **Retry and Timeout**: Support for automatic retry of failed steps and timeout settings.
- **Workflow Templates**: Manage reusable workflow definitions as templates to reduce code duplication.

### Argo Workflows Helm Chart Configuration

Argo Workflows followed the same pattern in the repository:

```bash
mkdir -p k8s-resource/apps/argo-workflows/templates
cd k8s-resource/apps/argo-workflows
```

Create the `Chart.yaml` file:

```yaml
apiVersion: v2
name: argo-workflows
description: argo-workflows chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v3.6.2"
dependencies:
    - name: argo-workflows
      version: "0.45.2"
      repository: "https://argoproj.github.io/argo-helm"
```

Create the `values.yaml` file:

```yaml
argo-workflows:
    server:
        authMode: "server"
```

`authMode: server` tells Argo Workflows to use the server's own authentication, which makes access simpler in a homelab environment.

Create an IngressRoute for accessing the Argo Workflows UI as the `templates/ingressroute.yaml` file:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: argo-workflows-server
    namespace: argo-workflows
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - kind: Rule
          match: Host(`argo-workflows.injunweb.com`)
          services:
              - name: argo-workflows-server
                port: 2746
```

### Deploying Argo Workflows

Commit and push the changes:

```bash
git add .
git commit -m "Add Argo Workflows configuration"
git push
```

Check the deployment status:

```bash
kubectl get pods -n argo-workflows
```

On my workstation, I added the following hosts entry and then verified the Argo Workflows UI at that hostname:

```
192.168.0.200 argo-workflows.injunweb.com
```

## EventBus and EventSource Configuration

To make Argo Events actually useful, I still needed an EventBus and an EventSource.

### Creating EventBus

The EventBus is the messaging backbone responsible for communication between event sources and sensors. Create a NATS-based EventBus:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: EventBus
metadata:
    name: default
    namespace: argo-events
spec:
    nats:
        native:
            replicas: 3
            auth: none
```

This EventBus creates 3 NATS replicas to ensure high availability. Because it is named `default`, EventSources and Sensors automatically use it without explicitly specifying an EventBus.

### Creating GitHub EventSource

Create an EventSource to receive webhook events from a GitHub repository:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
    name: github
    namespace: argo-events
spec:
    service:
        ports:
            - port: 12000
              targetPort: 12000
    github:
        example:
            repositories:
                - owner: injunweb
                  names:
                      - example-repo
            webhook:
                endpoint: /webhook
                port: "12000"
                method: POST
            events:
                - push
            apiToken:
                name: github-access
                key: token
            insecure: true
            active: true
            contentType: json
```

The components of this EventSource are:

- **service.ports**: Sets port 12000 for the EventSource to receive webhooks.
- **repositories**: Specifies the GitHub repository to receive webhooks from.
- **webhook.endpoint**: Sets the webhook receive path to `/webhook`.
- **events**: Configured to detect `push` events.
- **apiToken**: Retrieves the GitHub API token from the `github-access` secret.

Check the EventBus and EventSource status:

```bash
kubectl get eventbus -n argo-events
kubectl get eventsource -n argo-events
```

## Component Integration Testing

After the installs, I ran a few simple checks to make sure the pieces were alive.

### Harbor Image Push Test

```bash
docker pull nginx:alpine
docker tag nginx:alpine harbor.injunweb.com/injunweb/nginx:test
docker push harbor.injunweb.com/injunweb/nginx:test
```

You can verify the pushed image in the Harbor UI.

### Argo Workflows Workflow Test

Create a simple workflow to verify Argo Workflows is functioning correctly:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
    generateName: hello-world-
    namespace: argo-workflows
spec:
    entrypoint: whalesay
    templates:
        - name: whalesay
          container:
              image: docker/whalesay:latest
              command: [cowsay]
              args: ["Hello World!"]
```

Apply this workflow to the cluster:

```bash
kubectl apply -f hello-world.yaml
```

You can check the workflow execution results in the Argo Workflows UI.

## Next Steps

The three components installed in this post formed the base of the IDP, but there was still more to wire together before it became something developers could use easily:

- **Sensor Configuration**: Create Sensors that filter events received from EventSource and trigger Argo Workflows.
- **Workflow Templates**: Write reusable workflow templates that perform tasks such as application building, container image creation, and Harbor push.
- **ArgoCD Integration**: Automate the process of deploying new images to the cluster through ArgoCD after workflows complete.

## Conclusion

This post covered setting up Harbor container registry, Argo Events, and Argo Workflows as the foundation of the IDP in the homelab Kubernetes cluster.

The next post covers connecting these components with Sensors and workflow templates, then integrating them with ArgoCD so the overall structure starts to look like a usable IDP.

[Next Post: Homelab Build Log #8: Building IDP (2)](/posts/homelab-k8s-idp-2/)
