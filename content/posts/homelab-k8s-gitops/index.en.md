---
title: "Homelab #2 - Building a GitOps Environment with ArgoCD"
date: 2025-02-25T03:06:44+09:00
draft: false
description: "This guide explains how to install ArgoCD in a homelab Kubernetes environment to build a GitOps-based infrastructure."
tags: ["kubernetes", "homelab", "gitops", "argocd", "helm"]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-setup), we installed a homelab Kubernetes cluster and completed the basic configuration. This post provides a detailed guide on installing and configuring ArgoCD to manage cluster components using the GitOps approach. The GitOps methodology offers various benefits such as version control, collaboration, and automation by managing infrastructure as code.

## What is GitOps?

GitOps is an operational model that uses a Git repository as the "Single Source of Truth" for infrastructure and application configurations. Simply put, it is an approach where all infrastructure configuration information is stored as code in a Git repository, and this code is automatically applied to the actual environment.

![GitOps Concept Diagram](image.png)

For example, if you want to change database server settings:

1. Traditional approach: Connect directly to the cluster and execute commands
2. GitOps approach: Modify configuration files in the Git repository and commit; changes are automatically applied to the cluster

### Key Advantages of GitOps

This approach offers several significant advantages:

-   **History Management**: All changes are recorded as Git commits, allowing you to track who changed what and when.
-   **Easy Rollback**: When problems occur, you can easily revert to previous versions. (Example: "We need to go back to the previous configuration!" → rollback to a specific commit)
-   **Enhanced Collaboration**: Developers can participate in infrastructure changes through Git. (Pull request-based reviews are possible)
-   **Automation**: Changes are automatically deployed without manual work.

### Core Principles of GitOps

1. **Declarative Definition**: All system configurations are defined in the Git repository in the form of "this is how it should be."
2. **Version Control**: All changes are tracked and version-controlled through Git.
3. **Automatic Application**: Changes are automatically applied to the system. (No need for people to manually enter commands)
4. **Continuous Reconciliation**: The system automatically adjusts when the actual state differs from the state defined in Git.

## Introduction to ArgoCD

ArgoCD is a GitOps tool for Kubernetes. Simply put, it retrieves Kubernetes manifests (YAML files) from a Git repository and automatically applies them to the cluster.

![ArgoCD Logo](image-1.png)

### What ArgoCD Does

1. Monitors Git repositories.
2. Detects changes when they occur.
3. Applies changed manifests to the Kubernetes cluster.
4. Alerts or automatically adjusts when the cluster state differs from the Git repository.

### Key Concepts in ArgoCD

ArgoCD has two core concepts:

-   **Application**: A set of Kubernetes resources that connects a Git repository path to a cluster destination.

    Example: An application called "web server deployment" deploys YAML files from the `my-repo/webapp` directory in GitHub to the `webapp` namespace in the cluster.

-   **Project**: A logical unit that groups applications and manages permissions.

    Example: Projects can be divided into "backend systems," "frontend systems," etc. Different teams can have access permissions to each project.

## ArgoCD Installation Guide

### Step 1: Install Helm

ArgoCD can be installed in several ways, but here we use Helm, a Kubernetes package manager. Helm is a tool that makes it easy to install and manage complex applications.

![Helm Logo](image-2.png)

> **What is Helm?**
>
> Helm is a package manager for Kubernetes. It plays a similar role to apt or yum on Linux, and Homebrew on macOS.
> It allows you to easily install, upgrade, and delete complex Kubernetes applications by packaging them into "Charts."
> Helm charts contain multiple Kubernetes manifest files and configuration values, enabling you to deploy complex applications to Kubernetes with a single command.

First, install Helm:

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

These commands download the Helm installation script, grant it execution permissions, and run it. The script detects the operating system and automatically installs the appropriate version of Helm.

Verify that the installation is complete:

```bash
helm version
```

If the version information is displayed, Helm has been successfully installed. You should see output similar to the following:

```
version.BuildInfo{Version:"v3.12.0", GitCommit:"...", GitTreeState:"clean", GoVersion:"go1.20.4"}
```

### Step 2: Create a Namespace for ArgoCD

In Kubernetes, namespaces are used to logically separate resources. Create a dedicated namespace for ArgoCD:

```bash
kubectl create namespace argocd
```

This command creates a dedicated namespace for ArgoCD, allowing it to operate independently without resource conflicts with other applications.

If successful, the message `namespace/argocd created` will be displayed.

### Step 3: Install ArgoCD Helm Chart

Now install ArgoCD using Helm. First, add ArgoCD's Helm chart repository:

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
```

These commands add ArgoCD's official Helm chart repository and update it with the latest information.

Then install ArgoCD:

```bash
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd
```

The `upgrade --install` option means it will upgrade if already installed, or install new if not. This approach is convenient because it handles both installation and updates with the same command.

When the installation completes successfully, a message similar to the following will be displayed:

```
Release "argocd" does not exist. Installing it now.
NAME: argocd
LAST DEPLOYED: Tue Feb 25 12:34:56 2025
NAMESPACE: argocd
STATUS: deployed
REVISION: 1
TEST SUITE: None
```

### Step 4: Verify Installation

To verify that the installation is complete, check the status of the pods:

```bash
kubectl get pods -n argocd
```

All of the following pods should be in the `Running` state:

```
NAME                                             READY   STATUS    RESTARTS   AGE
argocd-application-controller-5f8c95f7b8-5xglw   1/1     Running   0          5m
argocd-dex-server-7589cfcbb9-ntzwx               1/1     Running   0          5m
argocd-redis-74cb89f446-c6jsb                    1/1     Running   0          5m
argocd-repo-server-6dddb4b65d-gx9vh              1/1     Running   0          5m
argocd-server-54f988d66b-l69zc                   1/1     Running   0          5m
```

Role of each pod:

-   **application-controller**: Core component that compares and reconciles Git repository and cluster states
-   **dex-server**: Server responsible for authentication (SSO integration, etc.)
-   **redis**: Database for caching and state storage
-   **repo-server**: Server that retrieves manifests from Git repositories
-   **server**: Web UI and API server

### Step 5: Retrieve Initial Admin Password

To log in to ArgoCD for the first time, you need the initial password. The default username is `admin`, and the initial password can be retrieved with the following command:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

This command extracts the initial admin password for ArgoCD from a Kubernetes secret. Since secrets are base64 encoded, it decodes them to display as plain text.

This command decodes and displays the base64 encoded password. The output password is a randomly generated value that can be changed later in the web UI.

Example: A value like `uLxMkS7H2L8A9jZ` will be output.

**Important**: You must record this password. It is recommended to change it after logging in for security purposes.

### Step 6: Port Forwarding for Web UI Access

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

This command connects local port 8080 to port 443 (HTTPS) of the ArgoCD server. This allows you to access the ArgoCD UI through a web browser locally.

You must keep the terminal where you executed the command open. The following message will be displayed:

```
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
```

## Accessing ArgoCD UI and Initial Configuration

### Step 1: Access Web UI

Now access `https://localhost:8080` in your web browser.

**Note**: Since ArgoCD uses HTTPS by default, you may encounter certificate errors in your browser such as "This connection is not secure." In a development environment, you can ignore this and proceed. (Advanced → Proceed to unsafe site)

Enter the following information on the login screen:

-   Username: `admin`
-   Password: The initial password retrieved in Step 5 above

![ArgoCD Login Screen](image-3.png)

If login is successful, the ArgoCD dashboard will be displayed. It will be empty because no applications have been configured yet.

![ArgoCD Dashboard](image-4.png)

## GitOps Architecture Design: Designing Repository Structure

Now design the Git repository structure for managing the cluster using the GitOps approach. Here we use two Git repositories:

1. **app-of-apps repository**: Repository for managing top-level applications (https://github.com/injunweb/app-of-apps)
2. **k8s-resource repository**: Repository for managing actual application configurations (https://github.com/injunweb/k8s-resource)

### Introduction to the "App of Apps" Pattern

To efficiently manage multiple applications, we use the "App of Apps" pattern. This pattern works as follows:

1. Create one "root" application.
2. This root application manages multiple child applications.
3. Child applications deploy actual Kubernetes resources.

![App of Apps Structure](image-5.png)

The advantages of this pattern are:

-   You can deploy and manage multiple applications at once.
-   When adding a new application, you only need to modify the Git repository.
-   You can grasp the entire cluster configuration at a glance.

### Repository 1: app-of-apps Structure Design

The first repository (https://github.com/injunweb/app-of-apps) is structured as follows:

```
app-of-apps/
├── Chart.yaml            # Helm chart information
├── templates/
│   └── infra-apps-root.yaml  # Application that synchronizes infrastructure-related helm charts
└── values.yaml           # Values configuration file
```

This structure follows the Helm chart format. The `infra-apps-root.yaml` file defines an ArgoCD application that points to the ApplicationSet in the second repository (k8s-resource).

### Step 1: Configure Root Application

Now write a manifest to register the app-of-apps repository with ArgoCD. Save this manifest as `app-of-apps.yaml`:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: app-of-apps # Application name
    namespace: argocd # Namespace where ArgoCD is installed
spec:
    project: default # ArgoCD project (using default)
    source:
        repoURL: https://github.com/injunweb/app-of-apps.git # First Git repository URL
        targetRevision: HEAD # Use latest commit
        path: . # Use root directory of repository
    destination:
        server: https://kubernetes.default.svc # Use current cluster
        namespace: argocd # Deploy to ArgoCD namespace
    syncPolicy:
        automated: # Automatic synchronization settings
            prune: true # Automatically remove deleted resources
            selfHeal: true # Automatically restore manually changed resources
        syncOptions:
            - CreateNamespace=true # Automatically create namespace if needed
```

This manifest configures ArgoCD to monitor the first Git repository (app-of-apps) and automatically synchronize whenever there are changes. Due to the `syncPolicy.automated` section settings, deleted resources are also automatically removed, and manually changed resources are restored to their original state.

Apply this manifest to the cluster with the following command:

```bash
kubectl apply -f app-of-apps.yaml
```

If successful, the message `application.argoproj.io/app-of-apps created` will be displayed.

### Step 2: Configure infra-apps-root Application

The `templates/infra-apps-root.yaml` file in the first repository (app-of-apps) is configured as follows:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
    name: infra-apps-root # Second application name
    namespace: argocd # ArgoCD namespace
spec:
    project: default
    source:
        repoURL: https://github.com/injunweb/k8s-resource.git # Second Git repository URL
        targetRevision: HEAD
        path: . # Root directory of repository
        directory:
            recurse: false # Do not search subdirectories
            include: "applicationset.yaml" # Include only applicationset.yaml file
    destination:
        server: { { .Values.spec.destination.server } } # Get server address from Helm values
        namespace: argocd
    syncPolicy:
        automated:
            prune: true
            selfHeal: true
        syncOptions:
            - CreateNamespace=true
```

This manifest points to the second Git repository (k8s-resource) and retrieves only the `applicationset.yaml` file. This file defines an ApplicationSet that automatically creates various applications.

### Repository 2: k8s-resource Structure Design

The second repository (https://github.com/injunweb/k8s-resource) is structured as follows:

```
k8s-resource/
├── applicationset.yaml  # ApplicationSet definition
└── apps/  # Directory where actual applications are located
    ├── example-app/  # First application
    │   ├── Chart.yaml  # Helm chart defining dependencies
    │   ├── templates/  # Templates directory
    │   │   └── (template files to redefine)
    │   └── values.yaml  # Values configuration file
    └── example-app-2/  # Second application
        ├── Chart.yaml
        ├── templates/
        └── values.yaml
```

This structure increases modularity and reusability by managing each application as an independent Helm chart.

### Step 3: Configure ApplicationSet

ApplicationSet is a powerful feature of ArgoCD that allows you to automatically create multiple applications with a single configuration.

> **What is ApplicationSet?**
>
> ApplicationSet is a feature that automatically generates multiple ArgoCD applications based on templates.
> For example, it is very useful when deploying the same application to multiple environments (development/staging/production) or managing microservices for multiple teams. With just one definition, you can automatically create and manage tens or hundreds of applications.
>
> ApplicationSet is particularly useful in the following cases:
>
> -   Deploying the same application to multiple environments (development, testing, production)
> -   Deploying the same application to multiple clusters (multi-cluster scenarios)
> -   Automatically creating multiple applications based on the folder structure of a Git repository

The `applicationset.yaml` file in the root directory of the second repository (k8s-resource) is configured as follows:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
    name: infra-apps
    namespace: argocd
spec:
    generators: # Define how to create applications
        - git: # Search directories in Git repository
              repoURL: https://github.com/injunweb/k8s-resource.git # Second Git repository
              revision: HEAD
              directories:
                  - path: apps/* # Search all directories under apps directory
    template: # Template for applications to create
        metadata:
            name: "{{path.basename}}" # Use directory name as application name
            namespace: argocd
        spec:
            project: default
            source:
                repoURL: https://github.com/injunweb/k8s-resource.git
                targetRevision: HEAD
                path: "{{path}}" # Use each directory's path
            destination:
                server: https://kubernetes.default.svc
                namespace: "{{path.basename}}" # Use directory name as namespace
            syncPolicy:
                automated:
                    prune: true
                    selfHeal: true
                syncOptions:
                    - ServerSideApply=true
                    - CreateNamespace=true
```

This ApplicationSet finds all directories matching the `apps/*` pattern and creates an ArgoCD application for each one. Directory names are used as application names and namespace names.

> **How This ApplicationSet Works**
>
> This ApplicationSet operates in the following steps:
>
> 1. **generators**: Finds all directories matching the 'apps/\*' path pattern in the Git repository.
>    For example, it finds directories like `apps/database`, `apps/webserver`, etc.
>
> 2. **template**: Creates an ArgoCD application for each directory found.
>
>     - Application name: Directory name (e.g., "database", "webserver")
>     - Source path: Path of the found directory (e.g., "apps/database")
>     - Target namespace: Same as directory name (e.g., "database", "webserver")
>
> 3. **syncPolicy**: Automatic synchronization settings for each created application:
>     - `prune: true`: Resources deleted from the repository are automatically deleted from the cluster
>     - `selfHeal: true`: Resources manually changed in the cluster are automatically restored to the Git repository state
>     - `CreateNamespace: true`: Automatically creates necessary namespaces if they don't exist

This ApplicationSet performs the following tasks:

1. Finds all subdirectories in the `apps` directory of the `k8s-resource` repository.
2. Automatically creates an ArgoCD application for each subdirectory (e.g., `apps/example-app`).
3. Each created application uses the Helm chart from that directory.
4. Each application is deployed to a namespace with the same name as the directory. (e.g., contents of the `example-app` directory are deployed to the `example-app` namespace)

## Complete GitOps Workflow

Now that all configuration is complete, the complete GitOps workflow can be summarized as follows:

1. **Initial Setup**: We directly applied the `app-of-apps.yaml` manifest to the cluster. (`kubectl apply -f app-of-apps.yaml`)

2. **First Synchronization**:

    - ArgoCD retrieves the first repository (app-of-apps) and renders the Helm chart.
    - As a result, the `infra-apps-root` application is created.

3. **Second Synchronization**:

    - The `infra-apps-root` application retrieves the `applicationset.yaml` file from the second repository (k8s-resource).
    - This ApplicationSet creates applications for all subdirectories in the `apps` directory.

4. **Third Synchronization**:
    - Each created application (`example-app`, `example-app-2`, etc.) applies the Helm chart from its directory to the cluster.
    - Each application is deployed to a namespace with the same name as itself.

![Complete GitOps Workflow](image-6.png)

> **Why Use This Complex Structure?**
>
> This structure may seem complex at first, but it greatly improves scalability and manageability:
>
> 1. **Centralized Management**: All infrastructure configuration is managed in Git repositories, making it easy to track changes and collaborate.
>
> 2. **Automated Deployment**: To add a new application, you simply add a new directory to the Git repository.
>    ArgoCD automatically detects and deploys it.
>
> 3. **Consistent Configuration**: All applications are managed with the same patterns and structure, making it easy for new team members to understand and work with.
>
> 4. **Cluster State Synchronization**: ArgoCD continuously compares the Git repository and cluster states and automatically adjusts when there are differences. This prevents "drift," which is configuration differences.

## Conclusion

You have now learned how to install and configure ArgoCD to manage your cluster using the GitOps approach. With ArgoCD, you can manage cluster configuration through Git repositories and automatically apply changes.

In the [next post](homelab-k8s-storage), we will explore how to install and configure the storage solutions needed for the homelab environment using this structure.
