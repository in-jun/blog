---
title: "Mini PC Kubernetes #2: ArgoCD GitOps"
date: 2025-02-25T03:06:44+09:00
draft: false
description: "GitOps-based Kubernetes deployment with ArgoCD."
tags: ["Kubernetes", "GitOps", "ArgoCD"]
series: ["Mini PC Kubernetes"]
---

## Overview

In the [previous post](/posts/homelab-k8s-setup/), we set up a homelab Kubernetes cluster using Dell OptiPlex Micro machines and completed the basic configuration. This post covers installing ArgoCD, a GitOps tool for declaratively managing all cluster components from a Git repository, and applying the App of Apps pattern to build a scalable infrastructure management system.

![GitOps Concept Diagram](image.png)

## Understanding GitOps

> **What is GitOps?**
>
> GitOps is an operational model first proposed by Alexis Richardson of Weaveworks in 2017. It uses a Git repository as the Single Source of Truth for infrastructure and application configurations. All infrastructure changes are tracked through Git commits, reviewed via Pull Requests, and reflected in the actual environment through automated processes, enabling infrastructure to be managed like code.

Traditional infrastructure management involved administrators directly connecting to servers to execute commands or change settings through consoles. This approach had problems including difficulty tracking change history, complex root cause analysis and recovery when failures occurred due to mistakes, and difficulty maintaining consistency across multiple environments. GitOps addresses these issues by defining all infrastructure configuration as code, version controlling it in Git repositories, and having automated tools continuously compare the Git repository state with the actual cluster state, automatically synchronizing when differences occur.

### Core Principles of GitOps

The GitOps methodology is based on four core principles:

- **Declarative**: Define the desired state of the system declaratively rather than imperatively, storing it in a Git repository in the form of "this is what it should be." Kubernetes YAML manifests are a prime example.
- **Versioned**: All changes are recorded as Git commits, allowing tracking of who changed what, when, and why. When problems occur, you can immediately restore to a previous state by rolling back to a specific commit.
- **Automatically Applied**: Approved changes are automatically applied to the system without manual intervention, preventing human error and increasing deployment speed.
- **Continuously Reconciled**: Software agents continuously compare the desired state defined in the Git repository with the actual system state, automatically adjusting when differences occur to prevent drift.

### Benefits of GitOps

Adopting the GitOps approach provides the following advantages:

- **Audit Trail**: All infrastructure changes are recorded in Git history, which is useful for compliance audits and failure root cause analysis.
- **Enhanced Collaboration**: The code review process through Pull Requests can also be applied to infrastructure changes, enabling knowledge sharing and quality improvement among team members.
- **Easier Disaster Recovery**: Since the entire infrastructure configuration is stored as code in the Git repository, the same state can be quickly reconstructed in a new environment during cluster failures.
- **Environment Consistency**: Managing development, staging, and production environment configurations from the same codebase minimizes problems caused by environment differences.

## Introduction to ArgoCD

> **What is ArgoCD?**
>
> ArgoCD is a declarative GitOps continuous deployment tool for Kubernetes. It was developed by Intuit and released as open source in 2018, and is now widely used as a graduated project of the CNCF (Cloud Native Computing Foundation). It automatically synchronizes Kubernetes manifests defined in Git repositories to clusters and provides functionality for visually monitoring application status through a web UI and CLI.

![ArgoCD Logo](image-1.png)

ArgoCD uses a pull-based deployment model. Unlike the push model, where external CI systems directly access clusters for deployment, ArgoCD runs inside the cluster and continuously polls Git repositories to detect and apply changes. This model offers higher security by avoiding external exposure of cluster credentials and makes it easier to deploy to clusters behind network firewalls.

### Core Components of ArgoCD

ArgoCD consists of several components, each performing the following roles:

- **API Server**: The central component that handles all requests through web UI, CLI, and gRPC/REST API, and manages authentication and authorization.
- **Repository Server**: Responsible for fetching manifests from Git repositories and running template tools like Helm, Kustomize, and Jsonnet to generate final Kubernetes resources.
- **Application Controller**: The core controller that continuously compares the desired state defined in Git repositories with the actual cluster state, performing synchronization when differences occur.
- **Dex**: An OpenID Connect (OIDC) provider that supports SSO (Single Sign-On) integration, enabling connection with external authentication systems like GitHub, GitLab, and LDAP.
- **Redis**: An in-memory data store used for application state caching and session management.

### Core Concepts in ArgoCD

There are two core concepts to understand when using ArgoCD:

- **Application**: The basic unit of ArgoCD that defines a group of Kubernetes resources. It connects a source (Git repository path) with a destination (Kubernetes cluster and namespace) to specify which manifests to deploy where.
- **Project**: A policy container that logically groups multiple Applications and restricts access permissions, allowed source repositories, and deployable clusters and namespaces. It is used for resource isolation and security in multi-tenant environments.

## Installing ArgoCD

ArgoCD can be installed in several ways, but in my homelab I used Helm because it was the simplest option to keep in GitOps.

> **What is Helm?**
>
> Helm is a package manager for Kubernetes applications. It was first developed by Deis (now Microsoft) in 2015 and is currently maintained as a CNCF graduated project. It defines complex Kubernetes applications in a package format called "Charts," can apply different settings per environment through templates and values files, and performs a role similar to apt on Linux or Homebrew on macOS in the Kubernetes environment.

![Helm Logo](image-2.png)

### Installing Helm

I started by installing Helm:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

This command downloads and runs the official Helm install script. After that, I checked the installed version with:

```bash
helm version
```

```
version.BuildInfo{Version:"v3.12.0", GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.20.4"}
```

### Creating the ArgoCD Namespace

I created a dedicated namespace for ArgoCD:

```bash
kubectl create namespace argocd
```

```
namespace/argocd created
```

### Installing the ArgoCD Helm Chart

Then I added the official ArgoCD Helm chart repository:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

And installed ArgoCD with:

```bash
helm upgrade --install argocd argo/argo-cd --namespace argocd
```

The `upgrade --install` option is idempotent: it upgrades ArgoCD if it is already installed, and installs it if it is not. That makes the command safe to run repeatedly. When the installation is complete, the following message is displayed:

```
Release "argocd" does not exist. Installing it now.
NAME: argocd
LAST DEPLOYED: Tue Feb 25 12:34:56 2025
NAMESPACE: argocd
STATUS: deployed
REVISION: 1
```

### Verifying Installation

After installation, I checked the Pod status first:

```bash
kubectl get pods -n argocd
```

```
NAME                                               READY   STATUS    RESTARTS   AGE
argocd-application-controller-5f8c95f7b8-5xglw     1/1     Running   0          5m
argocd-dex-server-7589cfcbb9-ntzwx                 1/1     Running   0          5m
argocd-redis-74cb89f446-c6jsb                      1/1     Running   0          5m
argocd-repo-server-6dddb4b65d-gx9vh                1/1     Running   0          5m
argocd-server-54f988d66b-l69zc                     1/1     Running   0          5m
```

If all Pods are in `Running` status and the `READY` column shows `1/1`, ArgoCD has been successfully installed.

### Retrieving the Initial Admin Password

The initial admin password for the ArgoCD web UI is stored in a Kubernetes secret, so I retrieved it with:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

This command extracts and decodes the base64-encoded password from the secret. I saved the generated password immediately and changed it after logging in.

### Accessing the Web UI

For the initial access, I simply used port forwarding:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

```
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

Access `https://localhost:8080` in a web browser to see the ArgoCD login screen. ArgoCD uses a self-signed certificate by default, so the browser may display a security warning. In development environments, you can safely ignore the warning and proceed.

![ArgoCD Login Screen](image-3.png)

Enter the username `admin` and the initial password retrieved earlier to log in and view the ArgoCD dashboard.

![ArgoCD Dashboard](image-4.png)

## Designing the GitOps Repository Structure

To make ArgoCD manageable in this homelab, I split responsibilities across two Git repositories:

- **app-of-apps repository**: Repository defining the top-level bootstrap application, managing the list of applications to deploy to the cluster and their settings.
- **k8s-resource repository**: Repository containing actual Kubernetes resources and Helm charts, managing the specific configuration of each application.

This separation structure reduces management complexity by separating bootstrap logic from actual resource definitions, and is advantageous for security management as different access permissions can be set for each repository.

### App of Apps Pattern

> **What is the App of Apps Pattern?**
>
> The App of Apps pattern is a design pattern for hierarchically managing multiple applications in ArgoCD. It has a structure where one root Application creates and manages multiple child Applications. Using this pattern provides excellent scalability since you only need to add a directory to the Git repository when adding new applications, and management is easy since you can understand the entire cluster configuration from a single entry point.

![App of Apps Structure](image-5.png)

In my setup, the App of Apps pattern works roughly like this:

1. **Root Application Creation**: The administrator applies the root Application manifest to the cluster.
2. **Child Application Creation**: The root Application references the Git repository and automatically creates child Applications.
3. **Actual Resource Deployment**: Each child Application deploys the manifests from its referenced Git path to the cluster.

### app-of-apps Repository Structure

The first repository looks like this:

```
app-of-apps/
├── Chart.yaml
├── templates/
│   └── infra-apps-root.yaml
└── values.yaml
```

This repository follows the Helm chart format. The `infra-apps-root.yaml` file in the `templates/` directory defines an ArgoCD Application that references the ApplicationSet in the second repository.

### k8s-resource Repository Structure

The second repository looks like this:

```
k8s-resource/
├── applicationset.yaml
└── apps/
    ├── example-app/
    │   ├── Chart.yaml
    │   ├── templates/
    │   └── values.yaml
    └── another-app/
        ├── Chart.yaml
        ├── templates/
        └── values.yaml
```

In this structure, each subdirectory under the `apps/` directory represents one application, and the ApplicationSet automatically detects these directories and creates ArgoCD Applications.

## Configuring ArgoCD Applications

### Creating the Root Application

I saved the following manifest as `app-of-apps.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: app-of-apps
    namespace: argocd
spec:
    project: default
    source:
        repoURL: https://github.com/injunweb/app-of-apps.git
        targetRevision: HEAD
        path: .
    destination:
        server: https://kubernetes.default.svc
        namespace: argocd
    syncPolicy:
        automated:
            prune: true
            selfHeal: true
        syncOptions:
            - CreateNamespace=true
```

This Application uses the root directory of the `app-of-apps` repository as its source. The `syncPolicy.automated` setting automatically detects changes in the Git repository and applies them to the cluster. `prune: true` automatically deletes resources from the cluster that were deleted from the Git repository, and `selfHeal: true` automatically restores resources manually changed in the cluster to the Git repository state.

Then I applied it to the cluster:

```bash
kubectl apply -f app-of-apps.yaml
```

```
application.argoproj.io/app-of-apps created
```

### Configuring the infra-apps-root Application

The `templates/infra-apps-root.yaml` file in the `app-of-apps` repository was set up like this:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: infra-apps-root
    namespace: argocd
spec:
    project: default
    source:
        repoURL: https://github.com/injunweb/k8s-resource.git
        targetRevision: HEAD
        path: .
        directory:
            recurse: false
            include: "applicationset.yaml"
    destination:
        server: {{ .Values.spec.destination.server }}
        namespace: argocd
    syncPolicy:
        automated:
            prune: true
            selfHeal: true
        syncOptions:
            - CreateNamespace=true
```

This Application fetches and applies only the `applicationset.yaml` file from the root directory of the `k8s-resource` repository. The `directory.include` setting allows selective inclusion of specific files.

### Configuring the ApplicationSet

> **What is ApplicationSet?**
>
> ApplicationSet is an ArgoCD feature that uses templates and Generators to automatically create and manage multiple Applications. It can dynamically create Applications based on Git repository directory structures, cluster lists, external data sources, and more. It is useful for managing large-scale multi-cluster environments or many microservices, allowing dozens of Applications to be automatically created and maintained with a single definition.

The `applicationset.yaml` file in the `k8s-resource` repository looks like this:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
    name: infra-apps
    namespace: argocd
spec:
    generators:
        - git:
              repoURL: https://github.com/injunweb/k8s-resource.git
              revision: HEAD
              directories:
                  - path: apps/*
    template:
        metadata:
            name: "{{path.basename}}"
            namespace: argocd
        spec:
            project: default
            source:
                repoURL: https://github.com/injunweb/k8s-resource.git
                targetRevision: HEAD
                path: "{{path}}"
            destination:
                server: https://kubernetes.default.svc
                namespace: "{{path.basename}}"
            syncPolicy:
                automated:
                    prune: true
                    selfHeal: true
                syncOptions:
                    - ServerSideApply=true
                    - CreateNamespace=true
```

This ApplicationSet uses a Git generator to find all directories matching the `apps/*` pattern and automatically creates an ArgoCD Application for each directory. `{{path.basename}}` is a template variable that references the directory name, used as both the application name and namespace.

In practice, this configuration behaves like this:

1. **Directory Discovery**: The Git generator finds all subdirectories under the `apps/` directory.
2. **Application Creation**: Applies the template to each found directory to create an ArgoCD Application.
3. **Automatic Synchronization**: Each created Application deploys the Helm charts or manifests from its directory to the cluster.
4. **Dynamic Management**: When a new folder is added to the `apps/` directory, a new Application is automatically created. When a folder is deleted, the corresponding Application is also automatically deleted.

## Complete Workflow

Once that wiring was in place, the GitOps workflow in my homelab looked like this:

![Complete GitOps Workflow](image-6.png)

1. **Initial Bootstrap**: When the administrator applies `app-of-apps.yaml` to the cluster, the root Application is created.
2. **First Synchronization**: The root Application synchronizes the `app-of-apps` repository to create the `infra-apps-root` Application.
3. **Second Synchronization**: The `infra-apps-root` Application synchronizes the `applicationset.yaml` from the `k8s-resource` repository to create the ApplicationSet.
4. **Third Synchronization**: The ApplicationSet creates individual Applications for each folder in the `apps/` directory, and each Application deploys actual Kubernetes resources.

From that point on, adding a new folder under `apps/` in the `k8s-resource` repository was enough for ArgoCD to detect and deploy a new application. Existing applications followed the same pattern: update the files in that directory, commit, and let ArgoCD reconcile the changes.

## Conclusion

In this post, I installed ArgoCD on my homelab Kubernetes cluster and used the App of Apps pattern to shape the GitOps workflow I wanted. From this point on, most of the cluster configuration lived in Git, and later pieces like storage, networking, and monitoring were all added on top of this structure.

[Next Post: Mini PC Kubernetes #3: Longhorn Storage](/posts/homelab-k8s-storage/)
