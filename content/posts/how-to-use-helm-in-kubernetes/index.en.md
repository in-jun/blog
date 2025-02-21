---
title: "Working with Helm: The Kubernetes Application Package Manager"
date: 2024-07-28T23:22:52+09:00
tags: ["kubernetes", "helm", "package-management", "cloud-native"]
draft: false
---

## Introduction

Helm is a tool for seamlessly packaging and deploying Kubernetes applications. Dubbed as the "package manager for Kubernetes," helm simplifies complex application constructs, eases version management, and streamlines the application lifecycle management. In this article, we will delve into the concepts of helm, from the basics to advanced usage.

## 1. Helm Fundamentals

### 1.1 What is Helm?

Helm is a "package manager" in the Kubernetes ecosystem. It plays a similar role in Kubernetes as apt or yum in Linux or Homebrew in macOS. With helm, you can easily define, install, and upgrade complex Kubernetes applications.

### 1.2 Key Helm Concepts

1. **Chart**: A collection of files describing Kubernetes resources. A chart consists of templated YAML manifest files, a Chart.yaml file containing metadata about the chart, and other supporting configuration files.

2. **Repository**: A place to store and share charts. It can be a GitHub repository or a dedicated chart repository server.

3. **Release**: An instance of a specific chart, representing a particular deployment of the chart running in a Kubernetes cluster. A single chart can be installed multiple times within the same cluster, with each installation creating a new release.

4. **Values**: Configuration values used to override the default settings of a chart. They enable customization of a chart for different environments.

## 2. Installing Helm

The installation method for helm varies depending on your operating system. Here are the installation instructions for major operating systems:

### 2.1 macOS (Using Homebrew)

```bash
brew install helm
```

### 2.2 Linux (Using Script)

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 2.3 Download Binaries Directly

You can also download the binary for your operating system from the [official GitHub releases page](https://github.com/helm/helm/releases) and install it.

Once installed, you can check the helm version using the following command:

```bash
helm version
```

## 3. Basic Helm Usage

### 3.1 Repository Management

#### Adding a Repository

```bash
helm repo add stable https://charts.helm.sh/stable
```

#### Listing Repositories

```bash
helm repo list
```

#### Updating Repositories

```bash
helm repo update
```

### 3.2 Searching and Getting Chart Information

#### Searching Charts

```bash
helm search repo stable
```

#### Getting Information About a Specific Chart

```bash
helm show chart stable/mysql
```

### 3.3 Chart Installation and Management

#### Installing a Chart

```bash
helm install my-release stable/mysql
```

#### Listing Installed Releases

```bash
helm list
```

#### Upgrading a Release

```bash
helm upgrade my-release stable/mysql
```

#### Rolling Back a Release

```bash
helm rollback my-release 1
```

#### Deleting a Release

```bash
helm uninstall my-release
```

## 4. Inside a Helm Chart Structure

A basic Helm chart has the following structure:

```
mychart/
  Chart.yaml
  values.yaml
  charts/
  templates/
  crds/
  README.md
  LICENSE
```

### 4.1 Chart.yaml

A YAML file containing metadata about the chart. Key fields include:

-   `apiVersion`: The chart API version ("v2" for Helm 3)
-   `name`: The chart name
-   `version`: SemVer 2 version of the chart
-   `kubeVersion`: Supported Kubernetes versions (optional)
-   `description`: A short description of the chart
-   `type`: The chart type (application or library)
-   `dependencies`: A list of dependencies for the chart

### 4.2 values.yaml

A file defining the default configuration values for the chart. Values from this file can be referenced in templates and overridden during installation.

### 4.3 templates/ Directory

Contains template files that define Kubernetes resources. These templates are written in the Go template language and can reference values from values.yaml.

### 4.4 charts/ Directory

Contains dependencies (subcharts) for the chart.

### 4.5 crds/ Directory

Contains Custom Resource Definitions (CRDs).

## 5. Writing Helm Templates

Helm templates are based on the Go template language. Key features include:

### 5.1 Value Referencing

Use the `.Values` object to reference values from the values.yaml file:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  drink: {{ .Values.favorite.drink }}
```

### 5.2 Control Structures

Conditional statements and loops are supported:

```yaml
{{- if .Values.create }}
# Create resources
{{- end }}

{{- range .Values.list }}
- {{ . }}
{{- end }}
```

### 5.3 Functions and Pipelines

Helm provides a variety of built-in functions, and functions can be chained together using pipelines:

```yaml
value: { { .Values.string | upper | quote } }
```

### 5.4 Named Templates

Reusable template sections can be defined and used:

```yaml
{{- define "mychart.labels" }}
  labels:
    generator: helm
    date: {{ now | htmlDate }}
{{- end }}

apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
  {{- template "mychart.labels" . }}
```

## 6. Helm Chart Development and Testing

### 6.1 Creating a Chart

To create a new chart, use the following command:

```bash
helm create mychart
```

### 6.2 Linting a Chart

Validates the chart's structure and files:

```bash
helm lint mychart
```

### 6.3 Testing Chart Template Rendering

See how the templates render without actually installing:

```bash
helm template mychart
```

### 6.4 Testing Chart Installation

Install a chart for testing purposes and delete it immediately:

```bash
helm install --dry-run --debug test-release mychart
```

## 7. Helm Chart Distribution and Sharing

### 7.1 Packaging a Chart

Packages the chart into a distributable archive:

```bash
helm package mychart
```

### 7.2 Hosting a Chart Repository

Chart repositories can be hosted using tools like GitHub Pages or Chart Museum.

### 7.3 Generating a Repository Index

Generates an index file for the repository:

```bash
helm repo index --url https://example.com/charts .
```

## 8. Advanced Helm Features

### 8.1 Hooks

Scripts can be defined to execute at specific points in the lifecycle of a release. Key hook points include:

-   pre-install, post-install
-   pre-delete, post-delete
-   pre-upgrade, post-upgrade
-   pre-rollback, post-rollback
-   test

### 8.2 Chart Testing

Chart functionality can be tested by including pod definitions for testing in the `templates/tests/` directory.

### 8.3 Library Charts

Reusable chart components can be created to share across multiple charts.

### 8.4 Subcharts and Global Values

Complex applications can be composed of multiple subcharts, and global values can be used to manage settings that are shared across the whole chart.

## 9. Helm and CI/CD

Helm can be easily integrated into CI/CD pipelines. Key use cases include:

-   Building and linting charts
-   Managing chart versions
-   Packaging and uploading charts to repositories
-   Deploying charts to test environments
-   Rolling out to production

Example of using helm in GitLab CI:

```yaml
stages:
    - build
    - test
    - deploy

build:
    stage: build
    script:
        - helm dependency update ./mychart
        - helm lint ./mychart
        - helm package ./mychart

test:
    stage: test
    script:
        - helm install --dry-run --debug test-release ./mychart

deploy:
    stage: deploy
    script:
        - helm upgrade --install my-release ./mychart
    only:
        - master
```

## 10. Helm Security Considerations

Security aspects to consider when using helm:

1. **values File Management**: Avoid putting sensitive information directly into values files; use Kubernetes Secrets or external secret management tools.

2. **Chart Validation**: Only use charts from trusted sources and always review the chart's contents before installing.

## 11. Conclusion

Helm is a powerful tool that greatly simplifies the packaging, deployment, and management of Kubernetes applications. It enables easy packaging, versioning, and sharing of complex applications, playing a critical role in the Kubernetes ecosystem.
