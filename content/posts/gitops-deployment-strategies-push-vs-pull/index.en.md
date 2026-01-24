---
title: "GitOps Deployment Strategies Push vs Pull"
date: 2025-02-14T03:52:02+09:00
tags: ["GitOps", "Kubernetes", "DevOps"]
description: "Comparing push and pull deployment strategies in GitOps."
draft: false
---

GitOps is an operational methodology that uses Git as the Single Source of Truth to manage declarative states of infrastructure and applications and deploy them automatically. The term was first proposed by Alexis Richardson, CEO of Weaveworks, in 2017 and introduced to the cloud-native community. GitOps extends the Git workflow familiar to developers (Pull Requests, code reviews, branching strategies, etc.) into the infrastructure operations domain, and has become a core paradigm of modern DevOps practices when combined with declarative infrastructure platforms like Kubernetes.

## The Birth of GitOps and Core Principles

> **What is GitOps?**
>
> An operational methodology that declaratively defines all infrastructure configurations and application settings in a Git repository and uses this repository as the single source of truth to automatically synchronize the actual system state.

The term GitOps first appeared in August 2017 in the Weaveworks blog post "GitOps - Operations by Pull Request." Alexis Richardson systematized the Git-centric operational approach based on his company's Kubernetes management experience and established it as the concept of GitOps. Subsequently, CNCF (Cloud Native Computing Foundation) formed the GitOps Working Group to standardize GitOps principles and best practices, and in 2021, the OpenGitOps project published the official definition and principles of GitOps.

### The Four Core Principles of GitOps

The core principles of GitOps as defined by the OpenGitOps project are as follows.

**Declarative**: The desired state of the system must be defined as declarations rather than commands. Like Kubernetes YAML manifests, it describes "what should be" and delegates "how to do it" to the system.

**Versioned and Immutable**: All declarative definitions must be stored in a version control system like Git, with change history preserved immutably to enable audit trails and allow rollback to previous states at any time.

**Pulled Automatically**: Approved changes must be automatically applied to the system by software agents. Rather than humans manually executing commands like kubectl apply, automated processes must continuously reflect the Git state to the system.

**Continuously Reconciled**: Software agents must continuously observe the actual system state and compare it to the desired state defined in Git, automatically reconciling when differences occur.

## Push-Based Deployment Strategy

> **What is Push-Based Deployment?**
>
> An approach where external CI/CD pipelines send deployment commands directly to the cluster after build completion, operating similarly to traditional CI/CD pipelines.

The push-based approach can be implemented using existing CI/CD tools such as Jenkins, GitLab CI, and GitHub Actions. When build and test are completed in the CI pipeline, the CD stage uses tools like kubectl, Helm, and Kustomize to send deployment commands directly to the Kubernetes cluster.

### How Push-Based Deployment Works

**Stage 1: Source Code Changes and CI Pipeline Start**

When a developer modifies application code and pushes to the Git repository, the CI pipeline is triggered and goes through verification processes including build, unit tests, integration tests, and static analysis. When all verifications pass, a container image is built and pushed to a container registry (Docker Hub, AWS ECR, Google GCR, etc.).

**Stage 2: Manifest Update**

When a new image is created, the CI/CD pipeline automatically updates the image tag in Kubernetes manifest files (Deployment, Service, etc.) and commits these changes to a separate config repository or deployment-related path in the same repository.

**Stage 3: Cluster Deployment**

The CD pipeline applies the updated manifests directly to the Kubernetes cluster. In this process, the CI/CD server must hold authentication information such as kubeconfig files or service account tokens to access the cluster.

**Stage 4: Deployment Verification**

After deployment, the pipeline verifies rollout status, performs health checks, runs smoke tests if necessary, and performs automatic or manual rollback if problems are found.

### Advantages and Disadvantages of Push-Based Approach

**Advantages**:
- Low adoption cost as existing CI/CD tools and pipelines can be used as-is
- Intuitive implementation with workflow familiar to developers
- Full control over deployment timing and content from CI/CD pipeline
- Same approach can be applied to various environments (VMs, serverless, etc. beyond Kubernetes)

**Disadvantages**:
- Security risk as CI/CD server must have cluster access permissions
- No automatic detection or recovery when state drift occurs after deployment
- Inconsistency with Git state when someone modifies the cluster directly with kubectl
- Manual re-execution or separate retry logic required on pipeline failure

## Pull-Based Deployment Strategy

> **What is Pull-Based Deployment?**
>
> An approach where a GitOps operator installed inside the Kubernetes cluster detects changes in the Git repository and automatically synchronizes the cluster state to the desired state defined in Git.

The pull-based approach is a deployment strategy that better aligns with the original intent of GitOps. ArgoCD and Flux are representative implementations, and an operator inside the cluster detects changes in the Git repository periodically or through webhooks and reflects them to the cluster.

### How Pull-Based Deployment Works

**Stage 1: Source Code Changes and Image Build**

When a developer modifies application code and pushes to the Git repository, the CI pipeline is triggered to perform build and test. When verification passes, a new container image is pushed to the registry. This part is identical to the push-based approach.

**Stage 2: Manifest Repository Update**

The CI pipeline updates the image tag in the Kubernetes manifests of the Config Repository and commits, or uses image tag auto-update features (ArgoCD Image Updater, Flux Image Automation, etc.) to detect new images and automatically update manifests.

**Stage 3: GitOps Operator Change Detection**

The GitOps operator running inside the cluster (ArgoCD Application Controller, Flux Source Controller, etc.) detects changes in the Git repository at configured intervals (default 3 minutes) or through webhook notifications and compares the current cluster state with the desired state defined in Git.

**Stage 4: Automatic Synchronization (Reconciliation)**

When drift is found between Git state and cluster state, the operator automatically adjusts the cluster to match the Git state. This adjustment process is called the Reconciliation Loop and runs continuously to maintain consistent state at all times.

**Stage 5: State Monitoring and Self-Healing**

Even after deployment, the operator continuously monitors cluster state. Even if someone makes direct changes with kubectl or Pods are unexpectedly deleted, it automatically recovers (Self-Healing) to the state defined in Git.

### Advantages and Disadvantages of Pull-Based Approach

**Advantages**:
- High security as cluster access permissions are not exposed externally
- Self-Healing feature that automatically detects and recovers from state drift
- Git repository acts as the only source of truth, ensuring consistency
- Continuous state synchronization through Reconciliation Loop
- Automatic retry and recovery on failures

**Disadvantages**:
- Requires installation and operation of dedicated GitOps tools (ArgoCD, Flux)
- Need to learn GitOps workflow separately from existing CI/CD pipelines
- Initial setup and configuration may be more complex than push-based approach
- Need to check operator logs instead of pipeline logs when debugging

## Push vs Pull Comparison

The two deployment strategies have fundamental differences, and the appropriate approach should be chosen based on organizational context and requirements.

| Comparison Item | Push-Based | Pull-Based |
|-----------------|------------|------------|
| Deployment Actor | External CI/CD Pipeline | Internal Cluster Operator |
| Cluster Access | CI/CD server holds kubeconfig | Only operator accesses cluster |
| State Synchronization | One-time application at deployment | Continuous Reconciliation |
| Self-Healing | None (manual redeployment needed) | Automatic recovery |
| Drift Detection | Separate implementation required | Automatic detection and alerts |
| Security | Relatively lower | High |
| Implementation Complexity | Low | Medium to High |
| Existing Tool Usage | Use existing CI/CD tools as-is | Dedicated GitOps tools required |

## Major GitOps Tool Comparison

### ArgoCD

ArgoCD is a Kubernetes-native GitOps tool developed by Intuit and released as open source in 2018. It is currently a CNCF Graduated project and one of the most widely used GitOps tools in the cloud-native ecosystem.

**Key Features**:
- Intuitive web UI dashboard to visually check application status and synchronization state
- Native multi-cluster management support to centrally manage multiple Kubernetes clusters
- Support for various deployment strategies (Blue/Green, Canary, Progressive Delivery) through integration with Argo Rollouts
- Fine-grained permission management through RBAC (Role-Based Access Control)
- SSO (Single Sign-On) integration support (OIDC, SAML, LDAP, etc.)
- Large-scale application templating and auto-generation through ApplicationSet

**Suitable Environments**:
- Large teams with users of various roles who need to check deployment status
- Multi-cluster environments requiring centralized management
- Cases requiring complex deployment strategies (Canary, Blue/Green)
- When powerful UI and visualization are important

### Flux

Flux is a GitOps tool developed by Weaveworks, the company that coined the term GitOps. It is currently a CNCF Graduated project and forms one of the two major GitOps tools alongside ArgoCD.

**Key Features**:
- Modular architecture provided by a set of controllers called GitOps Toolkit
- Native support for Helm and Kustomize for natural integration with existing Kubernetes package management approaches
- Image auto-update feature (Image Automation Controller) for automatic deployment when new images are detected
- Lightweight design with low resource usage
- CLI-centric workflow suitable for automation and scripting
- Deployment status notifications to Slack, Microsoft Teams, Discord, etc. through notification controller

**Suitable Environments**:
- CLI and automation-centric workflow preferences
- Resource-constrained environments requiring lightweight solutions
- Heavy use of Helm and Kustomize
- Cases wanting to selectively use only needed features through modular architecture

### ArgoCD vs Flux Comparison

| Comparison Item | ArgoCD | Flux |
|-----------------|--------|------|
| Web UI | Powerful dashboard provided | Not provided by default (Weave GitOps separate) |
| CLI | Auxiliary use | Primary interface |
| Multi-cluster | Native support, centralized management | Supported (Flux installed in each cluster) |
| Architecture | Single application | Modular controller set |
| Helm Support | Supported | Native support (Helm Controller) |
| Resource Usage | Relatively higher | Lightweight |
| Learning Curve | Medium (UI helps) | High (CLI-centric) |
| Community | Very active | Active |

## Tool Selection Guide

It is important to select the appropriate GitOps tool based on organizational context and requirements. The following criteria can be considered for decision-making.

**When to Choose ArgoCD**:
- When team members of various roles (developers, operators, managers) need to intuitively check deployment status
- When centralized management of multi-clusters is needed
- When advanced deployment strategies like Canary and Blue/Green are required
- Early stage of GitOps adoption where visual feedback helps learning

**When to Choose Flux**:
- When CLI and automation-centric workflow is preferred and UI is not essential
- When resources are limited or lightweight solution is needed
- When Helm and Kustomize are core tools
- When wanting to selectively configure only needed features through modular architecture

**When to Maintain Push-Based Approach (Jenkins, GitLab CI, etc.)**:
- When existing CI/CD pipeline investment is significant and immediate transition is difficult
- Early stage of GitOps adoption planning gradual transition
- When needing to deploy to various environments (VMs, serverless, etc.) beyond Kubernetes in the same way
- When integration with legacy systems is essential

## Conclusion

Since its birth at Weaveworks in 2017, GitOps has established itself as a core paradigm for deployment automation in cloud-native environments. Push-based and Pull-based approaches each have their own advantages and disadvantages. Push-based is easy to adopt as it can leverage existing CI/CD tools, but has limitations in security and state consistency. Pull-based excels in security and Self-Healing capabilities, but requires dedicated tool adoption and learning. ArgoCD is suitable for large teams with its powerful UI and multi-cluster support, while Flux is suitable for automation-preferring teams with its lightweight CLI-centric workflow. The appropriate strategy and tool should be selected by comprehensively considering organizational scale, technical capabilities, security requirements, and existing infrastructure. Regardless of which approach is chosen, the core value of GitOps is building a consistent and traceable deployment process by using Git as the single source of truth.
