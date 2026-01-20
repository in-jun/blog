---
title: "Complete Helm Guide: Everything About Kubernetes Package Management"
date: 2024-07-28T23:22:52+09:00
tags: ["Kubernetes", "Helm", "DevOps", "Cloud Native", "Package Management"]
description: "Understand Helm's core concepts and operation principles, covering the entire process of Kubernetes application packaging and deployment from chart structure, template writing, release management, to CI/CD integration"
draft: false
---

Helm is a package manager for packaging, deploying, and version management of Kubernetes applications. It was first developed by Deis (now Microsoft) in 2015, joined CNCF (Cloud Native Computing Foundation) in 2018, and has become the most widely used deployment tool in the Kubernetes ecosystem. Helm performs a similar role in Kubernetes as apt or yum in Linux or Homebrew in macOS. It bundles complex Kubernetes manifest files into packages called Charts, enabling installation, upgrade, and rollback with a single command while automating environment-specific configuration management and dependency handling to significantly reduce deployment complexity.

## Helm Overview

> **What is Helm?**
>
> Helm is a package manager for Kubernetes that defines, installs, and upgrades Kubernetes applications through packages called Charts. Known as "apt/yum for Kubernetes," it enables deploying complex applications with a single command.

### Helm Development History

| Year | Event | Significance |
|------|-------|--------------|
| **2015** | Helm v1 released (Deis) | Introduced Kubernetes package management concept |
| **2016** | Helm v2 released | Introduced Tiller server, expanded production use |
| **2018** | Joined CNCF | Recognized as official Kubernetes ecosystem project |
| **2019** | Helm v3 released | Removed Tiller, enhanced security, 3-way merge |
| **Current** | Helm v3.x | CNCF Graduated project |

### Helm v2 vs Helm v3

| Feature | Helm v2 | Helm v3 |
|---------|---------|---------|
| **Tiller** | Required (server component) | Removed |
| **Security** | Tiller needed broad permissions | Uses user kubeconfig permissions |
| **Release Storage** | ConfigMap (Tiller namespace) | Secret (release namespace) |
| **3-way Merge** | Not supported | Supported (reflects live state) |
| **Namespace** | Managed by Tiller | Per-release namespace |
| **Chart Validation** | Basic validation | JSON Schema support |

## Core Concepts

### Chart

> **What is a Chart?**
>
> A Chart is a collection of files describing Kubernetes resources, consisting of templated YAML manifests, metadata (Chart.yaml), and default configuration values (values.yaml). It is Helm's basic deployment unit.

### Release

A release is a running instance of a Chart. The same Chart can be installed multiple times with different configurations, and each installation has a unique release name. For example, a MySQL Chart can be installed as two releases named `mysql-production` and `mysql-staging`.

### Repository

A place to store and share Charts, hosted on HTTP servers with chart listings managed through an index.yaml file. Notable repositories include Artifact Hub (formerly Helm Hub) and Bitnami Charts.

### Values

Configuration values that override Chart defaults, defined in values.yaml or passed as command-line arguments.

## Helm Installation

### Installation Methods by Operating System

| Operating System | Installation Command |
|-----------------|---------------------|
| **macOS (Homebrew)** | `brew install helm` |
| **Linux (Script)** | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| **Windows (Chocolatey)** | `choco install kubernetes-helm` |

Verify installation:

```bash
helm version
```

## Basic Commands

### Repository Management

```bash
# Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# List repositories
helm repo list

# Update repositories (sync latest chart info)
helm repo update

# Remove repository
helm repo remove bitnami
```

### Chart Search and Information

```bash
# Search charts in repository
helm search repo nginx

# Search in Artifact Hub
helm search hub nginx

# View chart information
helm show chart bitnami/nginx
helm show values bitnami/nginx
helm show readme bitnami/nginx
```

### Release Management

| Command | Description |
|---------|-------------|
| `helm install <release> <chart>` | Install chart |
| `helm upgrade <release> <chart>` | Upgrade release |
| `helm rollback <release> <revision>` | Rollback to previous version |
| `helm uninstall <release>` | Delete release |
| `helm list` | List installed releases |
| `helm history <release>` | Release history |
| `helm status <release>` | Check release status |

```bash
# Install chart
helm install my-nginx bitnami/nginx

# Install with custom values
helm install my-nginx bitnami/nginx -f custom-values.yaml

# Specify values from command line
helm install my-nginx bitnami/nginx --set service.type=LoadBalancer

# Install in specific namespace
helm install my-nginx bitnami/nginx -n production --create-namespace

# Upgrade (install if not exists)
helm upgrade --install my-nginx bitnami/nginx

# Rollback
helm rollback my-nginx 1

# Uninstall
helm uninstall my-nginx
```

## Chart Structure

Standard Helm Chart directory structure:

```
mychart/
├── Chart.yaml          # Chart metadata
├── Chart.lock          # Dependency version lock
├── values.yaml         # Default configuration values
├── values.schema.json  # Values schema (optional)
├── charts/             # Dependency charts (subcharts)
├── crds/               # Custom Resource Definitions
├── templates/          # Template files
│   ├── NOTES.txt       # Post-install message
│   ├── _helpers.tpl    # Reusable template definitions
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
└── README.md
```

### Chart.yaml

```yaml
apiVersion: v2           # Helm 3 uses v2
name: mychart
version: 1.0.0           # Chart version (SemVer)
appVersion: "1.16.0"     # Application version
description: My application Helm chart
type: application        # application or library
keywords:
  - web
  - nginx
maintainers:
  - name: DevOps Team
    email: devops@example.com
dependencies:
  - name: redis
    version: "17.x.x"
    repository: "https://charts.bitnami.com/bitnami"
    condition: redis.enabled
```

### values.yaml

```yaml
replicaCount: 1

image:
  repository: nginx
  tag: "1.21"
  pullPolicy: IfNotPresent

service:
  type: ClusterIP
  port: 80

resources:
  limits:
    cpu: 100m
    memory: 128Mi
  requests:
    cpu: 50m
    memory: 64Mi

nodeSelector: {}
tolerations: []
affinity: {}
```

## Template Writing

Helm templates are based on the Go template language, dynamically generating Kubernetes manifests by referencing values from values.yaml.

### Basic Syntax

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Release.Name }}-{{ .Chart.Name }}
  labels:
    app: {{ .Chart.Name }}
    release: {{ .Release.Name }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Chart.Name }}
  template:
    spec:
      containers:
        - name: {{ .Chart.Name }}
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          ports:
            - containerPort: {{ .Values.service.port }}
```

### Key Built-in Objects

| Object | Description |
|--------|-------------|
| `.Values` | Values from values.yaml or passed via --set |
| `.Release` | Release information (Name, Namespace, IsInstall, etc.) |
| `.Chart` | Contents of Chart.yaml |
| `.Files` | Access to files in the chart |
| `.Capabilities` | Cluster information (API versions, etc.) |
| `.Template` | Current template information |

### Control Structures

```yaml
# Conditional
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{- end }}

# Loop
{{- range .Values.extraEnvVars }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}

# with (scope change)
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
```

### Useful Functions

| Function | Description | Example |
|----------|-------------|---------|
| `default` | Set default value | `{{ .Values.name \| default "nginx" }}` |
| `quote` | Quote string | `{{ .Values.name \| quote }}` |
| `upper` / `lower` | Case conversion | `{{ .Values.name \| upper }}` |
| `toYaml` | Convert to YAML | `{{ toYaml .Values.labels \| nindent 4 }}` |
| `indent` / `nindent` | Indentation | `{{ include "mychart.labels" . \| nindent 4 }}` |
| `b64enc` | Base64 encoding | `{{ .Values.secret \| b64enc }}` |

### Reusable Templates (_helpers.tpl)

```yaml
{{/* Common labels definition */}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Usage */}}
metadata:
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
```

## Chart Development and Testing

```bash
# Create new chart
helm create mychart

# Lint chart
helm lint mychart

# Render templates (without installing)
helm template my-release mychart

# Render with specific values
helm template my-release mychart -f prod-values.yaml

# Dry run (API server validation)
helm install my-release mychart --dry-run --debug

# Package chart
helm package mychart

# Update dependencies
helm dependency update mychart
```

## Hooks

Helm Hooks allow defining resources that execute at specific points in the release lifecycle.

| Hook | Execution Point |
|------|----------------|
| `pre-install` | After template rendering, before resource creation |
| `post-install` | After all resources created |
| `pre-upgrade` | After template rendering during upgrade, before resource update |
| `post-upgrade` | After upgrade completion |
| `pre-delete` | On delete request, before resource deletion |
| `post-delete` | After all resources deleted |
| `pre-rollback` | After template rendering during rollback, before resource restoration |
| `post-rollback` | After rollback completion |

Hook definition example:

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: "{{ .Release.Name }}-db-migrate"
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    spec:
      containers:
        - name: migrate
          image: myapp:{{ .Values.image.tag }}
          command: ["./migrate.sh"]
      restartPolicy: Never
```

## CI/CD Integration

Helm integrates easily into CI/CD pipelines. GitLab CI example:

```yaml
stages:
  - lint
  - test
  - deploy

lint:
  stage: lint
  script:
    - helm lint ./charts/myapp

test:
  stage: test
  script:
    - helm template myapp ./charts/myapp
    - helm install myapp ./charts/myapp --dry-run --debug

deploy:
  stage: deploy
  script:
    - helm upgrade --install myapp ./charts/myapp
      --namespace production
      --create-namespace
      -f values-prod.yaml
      --wait
      --timeout 5m
  only:
    - main
```

## Security Considerations

| Item | Recommendation |
|------|----------------|
| **Sensitive Information** | Do not include directly in values.yaml; use Kubernetes Secrets or external secret management tools |
| **Chart Validation** | Only use charts from trusted repositories; review contents before installation |
| **RBAC** | Apply principle of least privilege; separate permissions by namespace |
| **Signature Verification** | Verify chart signatures with `helm verify` command |

## Conclusion

Helm is a core tool that standardizes packaging, deployment, and version management of Kubernetes applications. Since its initial development in 2015, it has become the de facto standard package manager in the Kubernetes ecosystem. It enables managing complex applications as single deployment units through Charts, environment-specific configuration management using templates and values, rollback functionality through release history, and sharing and reuse through chart repositories, significantly reducing the complexity of Kubernetes operations.
