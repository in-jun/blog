---
title: "Homelab #7 - Building CI/CD for Deployment Automation (1)"
date: 2025-02-28T04:32:32+09:00
draft: false
description: "This guide explains how to install Harbor registry, Argo Events, and Argo Workflows, which form the foundation of a CI/CD system in a homelab Kubernetes environment."
tags:
    [
        "kubernetes",
        "homelab",
        "ci/cd",
        "harbor",
        "argo-events",
        "argo-workflows",
        "gitops",
    ]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-secrets), we installed Vault in the homelab Kubernetes cluster and set up a secrets management system. In this post, we will explore how to install and configure three core components that form the foundation of a CI/CD system: Harbor registry, Argo Events, and Argo Workflows.

![CI/CD](image.png)

## Components of the CI/CD System

To build a complete CI/CD pipeline in a homelab environment, the following core components are required:

1. **Container Registry**: A repository for storing and managing built images
2. **Event Processing System**: A system that detects and processes events such as code changes
3. **Workflow Engine**: An engine that executes tasks like building, testing, and deployment
4. **Declarative Deployment System**: A system that manages and synchronizes deployment state

Among these, component 4 (declarative deployment system) is already handled by ArgoCD, which was installed in a previous post. In this post, we will install and configure the remaining three components.

## 1. Installing Harbor

Harbor is an open-source registry project hosted by the CNCF that provides functionality for storing and managing container images and Helm charts. We chose Harbor to build a completely self-hosted CI/CD environment without depending on public registries like Docker Hub.

### Harbor Features

-   Fine-grained access control through RBAC (Role-Based Access Control)
-   Enhanced security with vulnerability scanning
-   Unified management of container images and Helm charts
-   Project-level isolation and quota management
-   Image replication and mirroring capabilities

### Preparing GitOps-based Harbor Installation

As with previous posts, we will install Harbor using the GitOps approach. First, create the directory and files for Harbor installation in the Git repository:

```bash
mkdir -p k8s-resource/apps/harbor/templates
cd k8s-resource/apps/harbor
```

Create the `Chart.yaml` file:

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

Create the `values.yaml` file to define Harbor configuration:

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

Note that the `harborAdminPassword` configuration uses a Vault reference. This value will be replaced with the actual value from Vault during deployment through ArgoCD's Vault plugin. Additionally, 15GB of volume is allocated for registry storage.

Now create a Traefik IngressRoute to enable access to the Harbor UI. Create the `templates/ingressroute.yaml` file:

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

Here, we define two routing rules:

1. Default path (`/`) routes to the Harbor web portal
2. API, service, and registry paths route to the Harbor core service

We also need middleware for large image uploads. Create the `templates/middleware.yaml` file:

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

This middleware handles buffering configuration for large file uploads. By setting the maximum request size and memory buffer to approximately 1GB, large container images can be uploaded smoothly.

### Committing Changes and Deploying

Commit and push the changes:

```bash
git add .
git commit -m "Add Harbor configuration"
git push
```

ArgoCD will now detect the changes and automatically deploy Harbor. You can check the deployment status with the following command:

```bash
kubectl get pods -n harbor
```

When all pods reach the Ready state, Harbor has been successfully deployed.

### Accessing and Configuring Harbor UI

To access the Harbor UI, add the following entry to your hosts file:

```
192.168.0.200 harbor.injunweb.com
```

Access `https://harbor.injunweb.com` in your web browser. The login credentials are:

-   Username: admin
-   Password: Password retrieved from Vault

After logging in, proceed with the following configuration:

1. Create a new project:

    - Go to 'Projects' > 'NEW PROJECT'
    - Name: injunweb
    - Access Level: Private

2. Test login from Docker CLI:

    ```bash
    docker login harbor.injunweb.com -u admin -p <password>
    ```

3. Push a test image:
    ```bash
    docker pull nginx:alpine
    docker tag nginx:alpine harbor.injunweb.com/injunweb/nginx:alpine
    docker push harbor.injunweb.com/injunweb/nginx:alpine
    ```

Once the image is successfully pushed, you can verify it in the Harbor UI.

## 2. Installing Argo Events

Argo Events is a Kubernetes-based event-driven automation framework. It can detect events from various event sources (Git webhooks, message queues, AWS SNS, etc.) and trigger corresponding workflows.

### Argo Events Features

-   Event-driven workflows through declarative configuration
-   Support for various event sources
-   Extensible event filtering and transformation
-   Support for various trigger targets (Argo Workflows, Kubernetes resources, etc.)

### Preparing GitOps-based Argo Events Installation

Create the directory and files for Argo Events installation in the Git repository:

```bash
mkdir -p k8s-resource/apps/argo-events/templates
cd k8s-resource/apps/argo-events
```

Create the `Chart.yaml` file:

```yaml
apiVersion: v2
name: argo-event
description: argo-event chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v1.9.3"
dependencies:
    - name: argo-events
      version: "2.4.9"
      repository: "https://argoproj.github.io/argo-helm"
```

The `values.yaml` file uses default settings, so create it as an empty file. You can add configuration only when needed:

```yaml
# Using default configuration
```

### Committing Changes and Deploying

Commit and push the changes:

```bash
git add .
git commit -m "Add Argo Events configuration"
git push
```

You can check the deployment status with the following command:

```bash
kubectl get pods -n argo-events
```

## 3. Installing Argo Workflows

Argo Workflows is a tool for defining and executing complex container-based workflows on Kubernetes. It serves as the execution engine for CI/CD tasks such as building, testing, and deployment.

### Argo Workflows Features

-   DAG (Directed Acyclic Graph) or step-based workflow definitions
-   Parallel processing and artifact sharing
-   Retry strategies and timeout configuration
-   Conditional execution and loop operations
-   Flexible template system

### Preparing GitOps-based Argo Workflows Installation

Create the directory and files for Argo Workflows installation in the Git repository:

```bash
mkdir -p k8s-resource/apps/argo-workflows/templates
cd k8s-resource/apps/argo-workflows
```

Create the `Chart.yaml` file:

```yaml
apiVersion: v2
name: argocd-workflow
description: argocd-workflow chart for Kubernetes
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

Start with a simple configuration and add more settings as needed. Here, only the server authentication mode is specified.

Create a Traefik IngressRoute to enable access to the Argo Workflows UI. Create the `templates/ingressroute.yaml` file:

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

This route directs requests coming to the `argo-workflows.injunweb.com` host to the Argo Workflows server.

### Committing Changes and Deploying

Commit and push the changes:

```bash
git add .
git commit -m "Add Argo Workflows configuration"
git push
```

You can check the deployment status with the following command:

```bash
kubectl get pods -n argo-workflows
```

To access the Argo Workflows UI, add the following entry to your hosts file:

```
192.168.0.200 argo-workflows.injunweb.com
```

Access `https://argo-workflows.injunweb.com` in your web browser.

## 4. EventBus and Basic Event Source Configuration

Argo Events uses a component called EventBus to manage communication between event sources and sensors. Now let's configure the basic EventBus and EventSource for GitHub webhooks.

### Creating EventBus

Create the `eventbus.yaml` file:

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

This manifest creates a NATS-based EventBus. NATS is a lightweight messaging system that handles communication between event sources and sensors. Three replicas are created to ensure high availability.

### Creating GitHub EventSource

Create an EventSource to receive GitHub webhooks:

```bash
kubectl apply -f - <<EOF
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
EOF
```

This manifest creates an EventSource that receives push events from a GitHub repository.

-   Receives webhooks on port 12000
-   Detects push events from the injunweb/example-repo repository
-   GitHub API token is retrieved from the 'github-access' secret

Now you can check the status of the EventBus and EventSource:

```bash
kubectl get eventbus -n argo-events
kubectl get eventsource -n argo-events
```

## 5. Component Integration

All three core components are now installed. The role of each component can be summarized as follows:

1. **Harbor**: Securely stores and manages container images.
2. **Argo Events**: Detects and processes events such as GitHub webhooks.
3. **Argo Workflows**: Executes CI/CD tasks such as building and testing.
4. **ArgoCD** (previously installed): Automatically deploys applications using the GitOps approach.

How to integrate these four components to build a complete CI/CD pipeline will be covered in detail in the next post.

### Basic Testing

Let's do some basic testing to ensure the components are working correctly.

#### Pushing an Image to Harbor

```bash
docker pull nginx:alpine
docker tag nginx:alpine harbor.injunweb.com/injunweb/nginx:test
docker push harbor.injunweb.com/injunweb/nginx:test
```

This command pulls the nginx image, tags it for the Harbor registry, and pushes it.

#### Running a Simple Workflow in Argo Workflows

Create a simple workflow YAML file (`hello-world.yaml`):

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

This workflow uses the docker/whalesay image to output a "Hello World!" message.

Execute the workflow:

```bash
kubectl apply -f hello-world.yaml
```

You can check the execution result in the Argo Workflows UI.

## 6. Next Steps

The basic components of the CI/CD system are now installed, but some additional configuration is needed to integrate them effectively:

1. **Sensor Configuration**: Configure sensors that detect events from Argo Events EventSource and trigger Argo Workflows.

2. **Creating Workflow Templates**: Create reusable workflow templates for application building, image creation, and deployment.

3. **Configuring GitOps Pipeline**: Configure the complete pipeline that automatically builds and deploys when code changes occur in GitHub.

4. **Security Hardening**: Add security-related configurations such as secrets management and access control.

These additional configurations will be covered in detail in the next post.

## Conclusion

In this post, we explored how to install and configure Harbor, Argo Events, and Argo Workflows, the core components of a CI/CD system. By integrating these three components with the previously installed ArgoCD, we can build a complete CI/CD pipeline that automates the entire process from code changes to automatic deployment.

In the [next post](homelab-k8s-cicd-2), we will cover how to integrate these components to build a fully functional CI/CD pipeline.
