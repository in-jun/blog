---
title: "Homelab #8 - Building CI/CD for Automated Deployment (2)"
date: 2025-02-28T07:47:18+09:00
draft: false
description: "This post explains how to build a GitOps-based project automation system in a homelab Kubernetes environment and complete a full CI/CD pipeline."
tags:
    [
        "kubernetes",
        "homelab",
        "ci/cd",
        "gitops",
        "argocd",
        "argo-events",
        "argo-workflows",
        "helm",
    ]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-cicd-1), we installed the core components of the CI/CD system: Harbor registry, Argo Events, and Argo Workflows. In this post, we will integrate these three components with the previously installed ArgoCD to complete a full CI/CD pipeline and build a GitOps-based project automation system.

## Integrating CI/CD with GitOps

The integration of traditional CI systems with GitOps is a natural evolution. Traditional CI focused on detecting code changes, building, and testing, while GitOps focuses on declaratively managing deployment state and automatically synchronizing it. Combining these two approaches enables building a fully automated pipeline from code changes to automatic deployment.

![Integrating CI/CD with GitOps](image.png)

## Designing the Project Template

Designing a template that can be reused across multiple projects is very important. This reduces the burden of building infrastructure from scratch every time you start a new project. In this post, we will use Helm charts to create a reusable project template and learn how to build a complete CI/CD pipeline with simple declarations.

### Project Template Requirements

To easily manage multiple projects in a homelab environment, the template should include the following features:

1. **Automated CI/CD Pipeline**: Automatic build and deployment on code changes
2. **Declarative Resource Management**: Application and database configuration via YAML files
3. **Security Management**: Safe management of secrets and authentication information
4. **Network Configuration**: Ingress setup for internal and external access

## Git Repository Structure for Project Management

We use two Git repositories for project management:

1. **Project Configuration Repository**: `https://github.com/injunweb/projects-gitops`

    - Stores configuration information (YAML files) for each project
    - Defines applications to deploy and database information

2. **Helm Chart Repository**: `chart` directory in the same repository
    - Contains Helm charts defining project templates
    - Defines CI/CD pipeline and Kubernetes resource templates

### Repository Directory Structure

The project configuration repository is designed with the following structure:

```
projects-gitops/
├── .github/workflows/      # GitHub Action workflows
│   └── update-config.yaml  # Configuration update API workflow
├── applicationset.yaml     # ArgoCD ApplicationSet definition
├── chart/                  # Helm chart directory
│   ├── Chart.yaml          # Chart information
│   └── templates/          # Template directory
│       ├── app/            # Application-related templates
│       │   ├── ci/         # CI pipeline templates
│       │   ├── deployment.yaml  # Deployment template
│       │   └── ...
│       ├── db/             # Database-related templates
│       └── ...
└── projects/               # Project configuration directory
    ├── project1.yaml       # Project 1 configuration
    ├── project2.yaml       # Project 2 configuration
    └── ...
```

## Designing the ApplicationSet

ApplicationSet is a powerful mechanism that automatically creates multiple ArgoCD applications. This allows you to deploy new projects simply by adding a new file to the `projects` directory.

Create the `applicationset.yaml` file as follows:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
    name: projects-apps
    namespace: argocd
spec:
    goTemplate: true
    goTemplateOptions: ["missingkey=error"]
    generators:
        - git:
              repoURL: https://github.com/injunweb/projects-gitops.git
              revision: HEAD
              files:
                  - path: "projects/*.yaml"
    template:
        metadata:
            name: '{{.path.filenameNormalized | trimSuffix ".yaml"}}'
            namespace: argocd
        spec:
            project: default
            source:
                repoURL: https://github.com/injunweb/projects-gitops.git
                targetRevision: HEAD
                path: chart
                plugin:
                    name: argocd-vault-plugin-helm
                    env:
                        - name: HELM_ARGS
                          value: >-
                              -f ../projects/{{.path.filename}}
                              --set project={{.path.filenameNormalized | trimSuffix ".yaml"}}
            destination:
                server: https://kubernetes.default.svc
                namespace: '{{.path.filenameNormalized | trimSuffix ".yaml"}}'
            syncPolicy:
                automated:
                    prune: true
                    selfHeal: true
                syncOptions:
                    - CreateNamespace=true
```

The core features of this ApplicationSet are:

1. It finds all files matching the `projects/*.yaml` pattern.
2. It creates an ArgoCD application for each file.
3. Applications use the Helm chart in the chart directory and the project configuration file.
4. It securely handles secret values through the ArgoCD Vault Plugin.

Go template syntax is used to extract project names and namespaces from file names. For example, the `projects/myapp.yaml` file creates an application and namespace named `myapp`.

## Project Configuration Structure

Each project is defined by a YAML file with the following structure:

```yaml
applications:
    - name: app1 # Application name
      git:
          type: github # Git repository type
          owner: example-org # Repository owner
          repo: custom-app # Repository name
          branch: develop # Branch
          hash: ~ # Commit hash to build and deploy
      port: 8000 # Container port
      domains: # List of access domains
          - custom1.example.com

databases:
    - name: mysql # Database name
      type: mysql # Database type (mysql, postgres, redis, mongodb)
      version: "8.0" # Version
      port: 3306 # Port
      size: 2Gi # Storage size
```

This structure is concise yet contains all necessary information. The `applications[].git.hash` field specifies the specific commit to build and deploy. If this value is empty, no deployment is created. It is automatically set after the CI pipeline completes successfully.

## Designing the CI Pipeline

The CI pipeline is built using Argo Events and Argo Workflows. This pipeline consists of the following steps:

1. **Event Detection**: Detect changes in Git repository (Argo Events)
2. **Build Trigger**: Start build workflow when changes are detected (Argo Events → Argo Workflows)
3. **Container Build**: Build source code to create container image (Argo Workflows)
4. **Image Push**: Push built image to Harbor registry (Argo Workflows)
5. **Configuration Update**: Update project configuration with built image hash (GitHub API)

### EventBus Configuration

Configure an event bus for each project:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: EventBus
metadata:
  name: {{ $.Values.project }}-ci-eventbus
  namespace: {{ $.Values.project }}
spec:
  nats:
    native:
      auth: none
      replicas: 3
      antiAffinity: false
```

This template creates an independent event bus for each project. The NATS-based event bus handles communication between event sources and sensors.

### GitHub EventSource Configuration

Configure EventSource to receive GitHub webhooks:

```yaml
{{- range $app := .Values.applications }}
---
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: {{ $.Values.project }}-{{ $app.name }}-github-eventsource
  namespace: {{ $.Values.project }}
spec:
  eventBusName: {{ $.Values.project }}-ci-eventbus
  template:
    serviceAccountName: {{ $.Values.project }}-ci-workflow-sa
  service:
    ports:
      - port: 12000
        targetPort: 12000
        name: webhook
  github:
    {{ $.Values.project }}-{{ $app.name }}-github-trigger:
      repositories:
        - owner: {{ $app.git.owner }}
          names:
            - {{ $app.git.repo }}
      webhook:
        endpoint: /{{ $.Values.project }}-{{ $app.name }}
        port: "12000"
        method: POST
        url: https://webhook.injunweb.com
      events:
        - push
      apiToken:
        name: {{ $.Values.project }}-github-access-secret
        key: token
      insecure: false
      active: true
      contentType: json
{{- end }}
```

This template creates an EventSource that receives GitHub webhooks for each application in the project. Each application detects push events from its own GitHub repository.

### Sensor Configuration (Event Filtering)

Configure Sensor to detect only push events to specific branches:

```yaml
{{- range $app := .Values.applications }}
---
apiVersion: argoproj.io/v1alpha1
kind: Sensor
metadata:
  name: {{ $.Values.project }}-{{ $app.name }}-github-workflow-sensor
  namespace: {{ $.Values.project }}
spec:
  eventBusName: {{ $.Values.project }}-ci-eventbus
  template:
    serviceAccountName: {{ $.Values.project }}-ci-workflow-sa
  dependencies:
    - name: github-dep
      eventSourceName: {{ $.Values.project }}-{{ $app.name }}-github-eventsource
      eventName: {{ $.Values.project }}-{{ $app.name }}-github-trigger
      filters:
        data:
          - path: body.ref
            type: string
            comparator: "="
            value:
              - "refs/heads/{{ $app.git.branch }}"
  triggers:
    - template:
        name: workflow-trigger
        k8s:
          operation: create
          source:
            resource:
              apiVersion: argoproj.io/v1alpha1
              kind: Workflow
              metadata:
                generateName: {{ $.Values.project }}-{{ $app.name }}-build-workflow-
              spec:
                arguments:
                  parameters:
                    - name: git_sha
                workflowTemplateRef:
                  name: {{ $.Values.project }}-{{ $app.name }}-build-workflow-template
          parameters:
            - src:
                dependencyName: github-dep
                dataKey: body.after
              dest: spec.arguments.parameters.0.value
      retryStrategy:
        steps: 3
{{- end }}
```

This template creates a Sensor for each application. The Sensor detects only push events to a specific branch (e.g., "develop") and passes the commit hash to the workflow. Filters allow processing only events from the desired branch.

### Workflow Template (CI Job Definition)

Define workflow template for build and deployment tasks:

```yaml
{{- range $app := .Values.applications }}
---
apiVersion: argoproj.io/v1alpha1
kind: WorkflowTemplate
metadata:
  name: {{ $.Values.project }}-{{ $app.name }}-build-workflow-template
  namespace: {{ $.Values.project }}
spec:
  serviceAccountName: {{ $.Values.project }}-ci-workflow-sa
  entrypoint: build
  arguments:
    parameters:
      - name: git_sha
        description: "Git commit hash"
  volumes:
    - name: docker-config
      secret:
        secretName: registry-secret
        items:
          - key: .dockerconfigjson
            path: config.json
  templates:
    - name: build
      dag:
        tasks:
          - name: build
            template: build-container
            arguments:
              parameters:
                - name: sha
                  value: "{{`{{workflow.parameters.git_sha}}`}}"
          - name: update-config
            template: update-config
            dependencies: [build]
            arguments:
              parameters:
                - name: sha
                  value: "{{`{{workflow.parameters.git_sha}}`}}"

    - name: build-container
      inputs:
        parameters:
          - name: sha
      hostAliases:
        - ip: "192.168.0.200"
          hostnames:
            - "harbor.injunweb.com"
      container:
        image: gcr.io/kaniko-project/executor:latest
        args:
          - "--context=git://github.com/{{ $app.git.owner }}/{{ $app.git.repo }}.git#refs/heads/{{ $app.git.branch }}#{{`{{inputs.parameters.sha}}`}}"
          - "--dockerfile=Dockerfile"
          - "--destination=harbor.injunweb.com/injunweb/{{ $.Values.project }}-{{ $app.name }}:{{`{{inputs.parameters.sha}}`}}"
          - "--destination=harbor.injunweb.com/injunweb/{{ $.Values.project }}-{{ $app.name }}:latest"
          - "--registry-mirror=harbor.injunweb.com/proxy"
          - "--cache=true"
          - "--cache-repo=harbor.injunweb.com/injunweb/cache"
        env:
          - name: GIT_USERNAME
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.project }}-github-access-secret
                key: username
          - name: GIT_PASSWORD
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.project }}-github-access-secret
                key: token
        volumeMounts:
          - name: docker-config
            mountPath: /kaniko/.docker/

    - name: update-config
      inputs:
        parameters:
          - name: sha
      container:
        image: curlimages/curl:latest
        command: ["/bin/sh", "-c"]
        args:
          - |
            echo "[CONFIG] Updating gitops repository..."
            curl -X POST https://api.github.com/repos/injunweb/projects-gitops/dispatches \
              -H "Accept: application/vnd.github.v3+json" \
              -H "Authorization: Bearer $GITHUB_TOKEN" \
              -d '{
                "event_type": "config-api",
                "client_payload": {
                  "path": "projects/{{$.Values.project}}/applications/{{$app.name}}",
                  "action": "apply",
                  "spec": {
                    "git": {
                      "hash": "'"{{`{{inputs.parameters.sha}}`}}"'"
                    }
                  }
                }
              }'
        env:
          - name: GITHUB_TOKEN
            valueFrom:
              secretKeyRef:
                name: {{ $.Values.project }}-github-access-secret
                key: token
{{- end }}
```

The key features of the workflow template are:

1. **Kaniko**: Builds container images securely without Docker daemon. This allows building images without privilege escalation, which is good for security.
2. **Caching**: Uses caching to reduce build time. Reuses layers from previous builds to improve performance.
3. **GitHub API**: Calls GitHub API to update project configuration after build. This automatically updates the hash value of the image to deploy.

DAG (Directed Acyclic Graph) template is used to define dependencies between tasks. The configuration update task runs only after the build completes successfully.

## Designing the CD Pipeline

The CD pipeline is implemented through ArgoCD. Deployment occurs automatically by detecting project configuration updates from the CI pipeline. Deployment resources are defined as follows:

```yaml
{{- range $app := .Values.applications }}
{{- if $app.git.hash }}
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ $app.name }}-app
  namespace: {{ $.Values.project }}
spec:
  replicas: 1
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 0
  selector:
    matchLabels:
      app: {{ $app.name }}-app
  template:
    metadata:
      labels:
        app: {{ $app.name }}-app
    spec:
      affinity:
        podAntiAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 100
              podAffinityTerm:
                labelSelector:
                  matchExpressions:
                    - key: app
                      operator: In
                      values:
                        - {{ $app.name }}-app
                topologyKey: "kubernetes.io/hostname"
      terminationGracePeriodSeconds: 120
      containers:
        - name: {{ $app.name }}-app
          image: harbor.injunweb.com/injunweb/{{ $.Values.project }}-{{ $app.name }}:{{ $app.git.hash }}
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh", "-c", "sleep 10"]
          ports:
            - containerPort: {{ $app.port }}
          readinessProbe:
            tcpSocket:
              port: {{ $app.port }}
            initialDelaySeconds: 20
            periodSeconds: 10
            successThreshold: 3
          envFrom:
            - secretRef:
                name: {{ $.Values.project }}-{{ $app.name }}-secret
                optional: true
          env:
            {{- range $db := $.Values.databases }}
            {{- if eq $db.type "mysql" }}
            - name: {{ $db.name | upper }}_HOST
              value: {{ $db.name }}
            - name: {{ $db.name | upper }}_PORT
              value: {{ $db.port | quote }}
            - name: {{ $db.name | upper }}_DATABASE
              value: {{ $db.name }}_db
            - name: {{ $db.name | upper }}_USER
              value: {{ $db.name }}_user
            - name: {{ $db.name | upper }}_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ $.Values.project }}-{{ $db.name }}-secret
                  key: password
            {{- end }}
            {{- if eq $db.type "redis" }}
            - name: {{ $db.name | upper }}_HOST
              value: {{ $db.name }}
            - name: {{ $db.name | upper }}_PORT
              value: {{ $db.port | quote }}
            - name: {{ $db.name | upper }}_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ $.Values.project }}-{{ $db.name }}-secret
                  key: password
            {{- end }}
            {{- if eq $db.type "postgres" }}
            - name: {{ $db.name | upper }}_HOST
              value: {{ $db.name }}
            - name: {{ $db.name | upper }}_PORT
              value: {{ $db.port | quote }}
            - name: {{ $db.name | upper }}_DB
              value: {{ $db.name }}_db
            - name: {{ $db.name | upper }}_USER
              value: {{ $db.name }}_user
            - name: {{ $db.name | upper }}_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ $.Values.project }}-{{ $db.name }}-secret
                  key: password
            {{- end }}
            {{- if eq $db.type "mongodb" }}
            - name: {{ $db.name | upper }}_HOST
              value: {{ $db.name }}
            - name: {{ $db.name | upper }}_PORT
              value: {{ $db.port | quote }}
            - name: {{ $db.name | upper }}_DB
              value: {{ $db.name }}_db
            - name: {{ $db.name | upper }}_USER
              value: {{ $db.name }}_user
            - name: {{ $db.name | upper }}_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: {{ $.Values.project }}-{{ $db.name }}_secret
                  key: password
            {{- end }}
            {{- end }}
      imagePullSecrets:
        - name: registry-secret
{{- end }}
{{- end }}
```

An important point here is that deployment is created only when the `$app.git.hash` value exists. This means deployment occurs only after the CI pipeline completes successfully and the project configuration is updated.

The key features of the deployment template are:

1. **Rolling Update**: Uses rolling update as deployment strategy to implement zero-downtime deployment.
2. **Pod Distribution**: Distributes pods of the same application across different nodes through pod anti-affinity.
3. **Graceful Shutdown**: Allows application to terminate gracefully through `preStop` hook and appropriate termination grace period.
4. **Environment Variables**: Provides database connection information and other settings as environment variables.

## Ingress Configuration

Configure ingress routes to access applications:

```yaml
{{- range $app := .Values.applications }}
{{- if $app.git.hash }}
{{- range $domain := $app.domains }}
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: {{ $.Values.project }}-{{ $app.name }}-{{ $domain | replace "." "-" }}-route
  namespace: {{ $.Values.project }}
spec:
  entryPoints:
    - web
    - websecure
  routes:
    - match: Host(`{{ $domain }}`)
      kind: Rule
      services:
        - name: {{ $app.name }}
          port: {{ $app.port }}
{{- end }}
{{- end }}
{{- end }}
```

This template creates a Traefik IngressRoute for each application domain. It uses `web` and `websecure` entry points for external access.

## Database Configuration

Deploy databases defined in project configuration:

```yaml
{{- range $db := .Values.databases }}
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: {{ $.Values.project }}-{{ $db.name }}-db
  namespace: {{ $.Values.project }}
spec:
  serviceName: {{ $db.name }}
  selector:
    matchLabels:
      app: {{ $.Values.project }}-{{ $db.name }}-db
  template:
    metadata:
      labels:
        app: {{ $.Values.project }}-{{ $db.name }}-db
    spec:
      containers:
      - name: {{ $db.name }}
        image: {{ $db.type }}:{{ $db.version }}
        {{- if eq $db.type "mysql" }}
        env:
        - name: MYSQL_DATABASE
          value: {{ $db.name }}_db
        - name: MYSQL_USER
          value: {{ $db.name }}_user
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ $.Values.project }}-{{ $db.name }}-secret
              key: password
        - name: MYSQL_ROOT_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ $.Values.project }}-{{ $db.name }}-secret
              key: password
        {{- else if eq $db.type "redis" }}
        args: ["--requirepass", "$(REDIS_PASSWORD)"]
        env:
        - name: REDIS_PASSWORD
          valueFrom:
            secretKeyRef:
              name: {{ $.Values.project }}-{{ $db.name }}-secret
              key: password
        # ... configuration for other database types ...
        {{- end }}
        ports:
        - containerPort: {{ $db.port }}
        volumeMounts:
        - name: {{ $.Values.project }}-{{ $db.name }}-data
          {{- if eq $db.type "mysql" }}
          mountPath: /var/lib/mysql
          {{- else if eq $db.type "redis" }}
          mountPath: /data
          {{- else if eq $db.type "postgres" }}
          mountPath: /var/lib/postgresql/data
          {{- else if eq $db.type "mongodb" }}
          mountPath: /data/db
          {{- end }}
  volumeClaimTemplates:
  - metadata:
      name: {{ $.Values.project }}-{{ $db.name }}-data
    spec:
      accessModes: [ "ReadWriteOnce" ]
      resources:
        requests:
          storage: {{ $db.size }}
{{- end }}
```

This template creates a StatefulSet for each database defined in project configuration. It applies different configurations depending on database type (MySQL, Redis, PostgreSQL, MongoDB) and creates persistent volumes for data storage.

## GitHub Action for Configuration Updates

Configure GitHub Action called by CI pipeline to update project configuration:

```yaml
name: Configuration API

on:
    repository_dispatch:
        types: [config-api]

jobs:
    handle-request:
        runs-on: ubuntu-latest
        concurrency:
            group: config-update
            cancel-in-progress: false
        steps:
            - uses: actions/checkout@v3

            - name: Install yq
              run: |
                  wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/local/bin/yq
                  chmod +x /usr/local/bin/yq

            - name: Process Request
              run: |
                  PATH_PARAMS="${{ github.event.client_payload.path }}"
                  ACTION="${{ github.event.client_payload.action }}"
                  SPEC='${{ toJson(github.event.client_payload.spec) }}'

                  IFS='/' read -r -a PATH_ARRAY <<< "$PATH_PARAMS"
                  RESOURCE_TYPE="${PATH_ARRAY[0]}"
                  PROJECT="${PATH_ARRAY[1]}"
                  SUB_RESOURCE="${PATH_ARRAY[2]}"
                  NAME="${PATH_ARRAY[3]}"

                  FILE="projects/$PROJECT.yaml"

                  case "$ACTION" in
                    "apply")
                      mkdir -p $(dirname $FILE)
                      if [ "$RESOURCE_TYPE" = "projects" ] && [ ! -f "$FILE" ]; then
                        echo "applications: []" > $FILE
                        echo "databases: []" >> $FILE
                      fi

                      if [ -f "$FILE" ]; then
                        if [ "$SUB_RESOURCE" = "applications" ]; then
                          yq eval "(.applications[] | select(.name == \"$NAME\")) *= ${SPEC}" -i $FILE
                        elif [ "$SUB_RESOURCE" = "databases" ]; then
                          yq eval "(.databases[] | select(.name == \"$NAME\")) *= ${SPEC}" -i $FILE
                        fi
                      fi
                      ;;

                    "remove")
                      if [ -f "$FILE" ]; then
                        if [ "$SUB_RESOURCE" = "applications" ]; then
                          yq eval "del(.applications[] | select(.name == \"$NAME\"))" -i $FILE
                        elif [ "$SUB_RESOURCE" = "databases" ]; then
                          yq eval "del(.databases[] | select(.name == \"$NAME\"))" -i $FILE
                        elif [ -z "$SUB_RESOURCE" ]; then
                          rm $FILE
                        fi
                      fi
                      ;;
                  esac

            - name: Commit and push changes
              run: |
                  git config user.name "in-jun"
                  git config user.email "injuninjune@gmail.com"
                  git add .
                  git commit -m "${{ github.event.client_payload.action }} ${{ github.event.client_payload.path }}"
                  git push
```

This GitHub Action receives repository dispatch events to update project configuration files. It uses the `yq` tool to parse and modify YAML files. When the CI pipeline completes successfully, it calls this API to update project configuration with the built image hash.

## Creating and Using Projects

Now let's learn how to create a new project with a complete CI/CD pipeline.

### 1. Create Project Definition File

Create `projects/myproject.yaml` file:

```yaml
applications:
    - name: api
      git:
          type: github
          owner: myorg
          repo: my-app-api
          branch: main
      port: 8080
      domains:
          - api.example.com
    - name: frontend
      git:
          type: github
          owner: myorg
          repo: my-app-frontend
          branch: main
      port: 80
      domains:
          - example.com
databases:
    - name: mysql
      type: mysql
      version: "8.0"
      port: 3306
      size: 1Gi
```

This file defines a project with two applications (API and frontend) and a MySQL database.

### 2. Store Secrets in Vault

Store required secrets for the application in Vault:

```bash
# Store GitHub access token
vault kv put injunweb/myproject-github-access username=myusername token=ghp_xxxxxxxxxxxx

# Store application secrets
vault kv put injunweb/myproject-api API_KEY=secretkey DB_PASSWORD=dbpass
```

### 3. Verify Project Deployment

After committing and pushing the new project definition file, ArgoCD automatically creates the application. You can check deployment status in the ArgoCD UI:

```bash
# Verify namespace creation
kubectl get ns myproject

# Verify CI/CD resources
kubectl get eventbus,eventsource,sensor -n myproject

# Verify database deployment
kubectl get statefulset -n myproject
```

## Conclusion

In this post, we learned how to build a complete CI/CD pipeline in a homelab Kubernetes environment. The greatest achievement is designing a reusable template for all projects and being able to build a complete CI/CD pipeline with just simple YAML files.

In the [next post](homelab-k8s-monitoring), we will learn how to enhance monitoring and logging systems and build dashboards for system management.
