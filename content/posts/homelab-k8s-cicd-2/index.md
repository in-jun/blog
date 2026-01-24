---
title: "미니PC Kubernetes #8: IDP 구축 (2)"
date: 2025-02-28T07:47:18+09:00
draft: false
description: "쿠버네티스 기반 내부 개발자 플랫폼 구축 방법을 다룬다."
tags: ["Kubernetes", "DevOps", "플랫폼"]
series: ["미니PC Kubernetes"]
---

## 개요

[이전 글](/posts/homelab-k8s-cicd-1/)에서는 CI/CD 파이프라인의 기반이 되는 Harbor 컨테이너 레지스트리, Argo Events, Argo Workflows를 설치했다. 이번 글에서는 이 구성 요소들을 ArgoCD와 통합하고 Helm 차트 기반의 프로젝트 템플릿을 설계하여 YAML 파일 하나로 완전한 CI/CD 파이프라인을 갖춘 프로젝트를 배포할 수 있는 내부 개발 플랫폼(Internal Developer Platform, IDP)을 구축하는 방법을 다룬다.

![내부 개발 플랫폼 아키텍처](image.png)

## 내부 개발 플랫폼이란

> **내부 개발 플랫폼(IDP)이란?**
>
> 내부 개발 플랫폼(Internal Developer Platform)은 개발자가 인프라와 배포 파이프라인을 직접 구성하지 않고도 애플리케이션을 배포하고 운영할 수 있도록 추상화된 셀프서비스 인터페이스를 제공하는 시스템이다. 플랫폼 엔지니어링의 핵심 결과물로, 개발자 경험을 향상시키고 표준화된 배포 프로세스를 통해 운영 부담을 줄이는 것을 목표로 한다.

전통적인 CI/CD 파이프라인은 각 프로젝트마다 개별적으로 구성해야 하는 반면, 내부 개발 플랫폼은 템플릿 기반의 추상화를 통해 개발자가 간단한 설정 파일만 작성하면 CI/CD 파이프라인, 데이터베이스, 네트워크 설정 등 모든 인프라가 자동으로 프로비저닝된다. 이번 글에서 구축하는 플랫폼은 다음과 같은 흐름으로 동작한다:

1. **개발자가 코드를 Git 저장소에 푸시한다.**
2. **GitHub 웹훅이 Argo Events의 EventSource로 이벤트를 전송한다.**
3. **Argo Events의 Sensor가 이벤트를 필터링하고 Argo Workflows를 트리거한다.**
4. **Argo Workflows가 코드를 빌드하고 컨테이너 이미지를 Harbor에 푸시한다.**
5. **워크플로우가 완료되면 GitHub API를 호출하여 프로젝트 설정 파일을 업데이트한다.**
6. **ArgoCD가 변경된 설정 파일을 감지하고 새 이미지로 애플리케이션을 배포한다.**

## 프로젝트 템플릿 설계

여러 프로젝트에서 재사용할 수 있는 Helm 차트 기반의 프로젝트 템플릿을 설계한다. 이 템플릿을 사용하면 간단한 YAML 설정 파일만으로 완전한 CI/CD 파이프라인을 갖춘 프로젝트를 배포할 수 있다.

### 프로젝트 템플릿 요구사항

홈랩 환경에서 효율적으로 여러 프로젝트를 관리하기 위해 템플릿이 제공해야 하는 기능은 다음과 같다:

- **자동화된 CI/CD 파이프라인**: GitHub 저장소의 코드 변경 시 자동으로 빌드하고 배포한다.
- **선언적 리소스 관리**: 애플리케이션, 데이터베이스, 네트워크 설정을 YAML 파일로 정의한다.
- **시크릿 관리 통합**: Vault와 연동하여 비밀번호, API 키 등을 안전하게 관리한다.
- **멀티 애플리케이션 지원**: 하나의 프로젝트 내에서 여러 애플리케이션과 데이터베이스를 관리한다.

### Git 저장소 구조

프로젝트 관리를 위한 Git 저장소는 다음과 같은 구조로 설계한다:

```
projects-gitops/
├── .github/workflows/
│   └── update-config.yaml
├── applicationset.yaml
├── chart/
│   ├── Chart.yaml
│   └── templates/
│       ├── app/
│       │   ├── ci/
│       │   │   ├── eventbus.yaml
│       │   │   ├── eventsource.yaml
│       │   │   ├── sensor.yaml
│       │   │   └── workflow-template.yaml
│       │   ├── deployment.yaml
│       │   ├── service.yaml
│       │   └── ingressroute.yaml
│       └── db/
│           ├── statefulset.yaml
│           └── service.yaml
└── projects/
    ├── project-a.yaml
    ├── project-b.yaml
    └── ...
```

이 구조에서 `chart/` 디렉토리는 모든 프로젝트에서 공유하는 Helm 차트를 포함하고, `projects/` 디렉토리는 각 프로젝트의 설정 파일을 포함한다. 새 프로젝트를 배포하려면 `projects/` 디렉토리에 YAML 파일을 추가하기만 하면 된다.

## ApplicationSet 구성

> **ApplicationSet이란?**
>
> ApplicationSet은 ArgoCD의 기능으로, 템플릿과 생성기(Generator)를 사용하여 여러 Application을 자동으로 생성하고 관리하는 컨트롤러이다. Git 저장소의 파일 목록, 디렉토리 구조, 클러스터 목록 등을 기반으로 동적으로 Application을 생성할 수 있어 대규모 멀티 프로젝트 환경을 효율적으로 관리할 수 있다.

`applicationset.yaml` 파일을 다음과 같이 작성한다:

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

이 ApplicationSet은 Git 파일 생성기를 사용하여 `projects/*.yaml` 패턴에 맞는 모든 파일을 찾고, 각 파일에 대해 ArgoCD Application을 자동으로 생성한다. 파일 이름에서 `.yaml` 확장자를 제거한 값이 프로젝트 이름과 네임스페이스로 사용되며, ArgoCD Vault Plugin을 통해 Vault에 저장된 시크릿을 안전하게 주입한다.

## 프로젝트 설정 파일 구조

각 프로젝트는 다음과 같은 구조의 YAML 파일로 정의한다:

```yaml
applications:
    - name: api
      git:
          type: github
          owner: myorg
          repo: my-api
          branch: main
          hash: ~
      port: 8080
      domains:
          - api.example.com

    - name: frontend
      git:
          type: github
          owner: myorg
          repo: my-frontend
          branch: main
          hash: ~
      port: 80
      domains:
          - www.example.com
          - example.com

databases:
    - name: mysql
      type: mysql
      version: "8.0"
      port: 3306
      size: 5Gi

    - name: redis
      type: redis
      version: "7.0"
      port: 6379
      size: 1Gi
```

이 설정 파일의 핵심 필드는 다음과 같다:

- **applications[].git.hash**: CI 파이프라인이 빌드하고 배포할 Git 커밋 해시로, 초기에는 비어 있고 빌드가 성공하면 자동으로 업데이트된다. 이 값이 있을 때만 Deployment가 생성된다.
- **applications[].domains**: 애플리케이션에 접근할 도메인 목록으로, 각 도메인에 대해 Traefik IngressRoute가 생성된다.
- **databases[]**: 프로젝트에서 사용할 데이터베이스 목록으로, MySQL, PostgreSQL, Redis, MongoDB를 지원한다.

## CI 파이프라인 템플릿

CI 파이프라인은 Argo Events와 Argo Workflows의 조합으로 구현하며, Helm 차트 템플릿으로 정의하여 모든 프로젝트에서 재사용한다.

### EventBus 템플릿

각 프로젝트에 독립적인 이벤트 버스를 생성하는 템플릿이다:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: EventBus
metadata:
    name: {{ $.Values.project }}-ci-eventbus
    namespace: {{ $.Values.project }}
spec:
    nats:
        native:
            replicas: 3
            auth: none
            antiAffinity: false
```

이 EventBus는 3개의 NATS 복제본으로 구성되어 고가용성을 제공하며, 프로젝트별로 독립된 이벤트 전송 계층을 구성한다.

### EventSource 템플릿

GitHub 웹훅을 수신하는 EventSource 템플릿이다:

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

이 템플릿은 프로젝트 설정에 정의된 각 애플리케이션에 대해 EventSource를 생성하며, GitHub 저장소의 push 이벤트를 감지한다. `webhook.url`은 외부에서 접근 가능한 웹훅 엔드포인트이고, GitHub가 이 URL로 이벤트를 전송한다.

### Sensor 템플릿

이벤트를 필터링하고 워크플로우를 트리거하는 Sensor 템플릿이다:

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

이 Sensor는 `filters.data` 섹션에서 특정 브랜치(예: main, develop)로의 push 이벤트만 필터링하고, 조건에 맞는 이벤트가 발생하면 WorkflowTemplate을 참조하여 Workflow를 생성한다. `body.after` 값(push 이후의 커밋 해시)을 워크플로우 파라미터로 전달한다.

### WorkflowTemplate

빌드와 설정 업데이트 작업을 정의하는 WorkflowTemplate이다:

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

이 WorkflowTemplate의 핵심 구성 요소는 다음과 같다:

- **DAG 템플릿**: `build`와 `update-config` 두 개의 태스크를 DAG로 정의하여 빌드가 성공한 후에만 설정 업데이트가 실행되도록 의존성을 설정한다.
- **Kaniko**: Docker 데몬 없이 컨테이너 내부에서 이미지를 빌드하는 도구로, 권한 상승 없이 안전하게 이미지를 빌드할 수 있다. 캐싱 기능을 활성화하여 빌드 시간을 단축한다.
- **GitHub API 호출**: 빌드가 성공하면 repository_dispatch 이벤트를 발생시켜 프로젝트 설정 파일의 `git.hash` 값을 업데이트한다.

## CD 파이프라인 템플릿

CI 파이프라인이 프로젝트 설정 파일을 업데이트하면 ArgoCD가 변경을 감지하고 새 이미지로 배포를 수행한다.

### Deployment 템플릿

애플리케이션 배포를 위한 Deployment 템플릿이다:

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
            imagePullSecrets:
                - name: registry-secret
{{- end }}
{{- end }}
```

이 템플릿의 핵심 사항은 `{{- if $app.git.hash }}` 조건으로, `git.hash` 값이 설정되어 있을 때만 Deployment가 생성된다. 이를 통해 CI 파이프라인이 성공적으로 완료된 후에만 배포가 이루어지도록 보장한다.

Deployment 템플릿의 주요 특징은 다음과 같다:

- **롤링 업데이트**: `maxSurge: 1`, `maxUnavailable: 0` 설정으로 무중단 배포를 구현한다.
- **Pod 안티어피니티**: 동일한 애플리케이션의 Pod가 서로 다른 노드에 분산되도록 하여 가용성을 높인다.
- **정상 종료**: `preStop` 훅과 120초의 종료 유예 기간을 설정하여 기존 연결이 정상적으로 완료될 수 있도록 한다.

### IngressRoute 템플릿

애플리케이션에 외부 접근을 제공하는 IngressRoute 템플릿이다:

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

이 템플릿은 프로젝트 설정에 정의된 각 도메인에 대해 Traefik IngressRoute를 생성하며, `web`과 `websecure` 엔트리 포인트를 사용하여 HTTP와 HTTPS 요청을 모두 처리한다.

### Database StatefulSet 템플릿

데이터베이스 배포를 위한 StatefulSet 템플릿이다:

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
                  {{- end }}
                  ports:
                      - containerPort: {{ $db.port }}
                  volumeMounts:
                      - name: {{ $.Values.project }}-{{ $db.name }}-data
                        mountPath: {{- if eq $db.type "mysql" }} /var/lib/mysql
                                   {{- else if eq $db.type "redis" }} /data
                                   {{- else if eq $db.type "postgres" }} /var/lib/postgresql/data
                                   {{- else if eq $db.type "mongodb" }} /data/db
                                   {{- end }}
    volumeClaimTemplates:
        - metadata:
              name: {{ $.Values.project }}-{{ $db.name }}-data
          spec:
              accessModes: ["ReadWriteOnce"]
              resources:
                  requests:
                      storage: {{ $db.size }}
{{- end }}
```

이 템플릿은 MySQL, PostgreSQL, Redis, MongoDB 네 가지 데이터베이스 유형을 지원하며, 각 유형에 맞는 환경 변수와 볼륨 마운트 경로를 자동으로 설정한다.

## GitHub Actions 설정 업데이트 워크플로우

CI 파이프라인에서 호출하는 GitHub Actions 워크플로우로, 프로젝트 설정 파일을 업데이트한다:

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
                  PROJECT="${PATH_ARRAY[1]}"
                  SUB_RESOURCE="${PATH_ARRAY[2]}"
                  NAME="${PATH_ARRAY[3]}"

                  FILE="projects/$PROJECT.yaml"

                  if [ "$ACTION" = "apply" ] && [ -f "$FILE" ]; then
                    if [ "$SUB_RESOURCE" = "applications" ]; then
                      yq eval "(.applications[] | select(.name == \"$NAME\")) *= ${SPEC}" -i $FILE
                    elif [ "$SUB_RESOURCE" = "databases" ]; then
                      yq eval "(.databases[] | select(.name == \"$NAME\")) *= ${SPEC}" -i $FILE
                    fi
                  fi

            - name: Commit and push changes
              run: |
                  git config user.name "CI Bot"
                  git config user.email "ci@example.com"
                  git add .
                  git commit -m "${{ github.event.client_payload.action }} ${{ github.event.client_payload.path }}"
                  git push
```

이 워크플로우는 `repository_dispatch` 이벤트를 수신하여 `yq` 도구로 프로젝트 설정 파일을 파싱하고 수정한다. CI 파이프라인의 빌드가 성공하면 이 워크플로우가 트리거되어 `git.hash` 필드를 새 커밋 해시로 업데이트하고, ArgoCD가 이 변경을 감지하여 새 이미지로 배포를 수행한다.

## 프로젝트 생성 및 사용

완전한 CI/CD 파이프라인을 갖춘 새 프로젝트를 생성하는 방법은 다음과 같다:

### 프로젝트 설정 파일 생성

`projects/myproject.yaml` 파일을 생성한다:

```yaml
applications:
    - name: api
      git:
          type: github
          owner: myorg
          repo: my-api-server
          branch: main
      port: 8080
      domains:
          - api.myproject.example.com

databases:
    - name: mysql
      type: mysql
      version: "8.0"
      port: 3306
      size: 2Gi
```

### Vault에 시크릿 저장

프로젝트에 필요한 시크릿을 Vault에 저장한다:

```bash
vault kv put injunweb/myproject-github-access username=myuser token=ghp_xxxxx
vault kv put injunweb/myproject-mysql-secret password=mysecretpassword
vault kv put injunweb/myproject-api-secret API_KEY=my-api-key
```

### 배포 확인

프로젝트 설정 파일을 커밋하고 푸시하면 ArgoCD가 자동으로 리소스를 생성한다:

```bash
kubectl get ns myproject
kubectl get eventbus,eventsource,sensor -n myproject
kubectl get statefulset -n myproject
```

GitHub 저장소에 코드를 푸시하면 CI 파이프라인이 트리거되어 빌드와 배포가 자동으로 수행된다.

## 마치며

이번 글에서는 홈랩 쿠버네티스 클러스터에서 Helm 차트 기반 프로젝트 템플릿과 ArgoCD ApplicationSet을 활용하여 나만의 내부 개발 플랫폼(IDP)을 구축하는 방법을 살펴보았다. 이 플랫폼을 통해 개발자는 간단한 YAML 설정 파일만 작성하면 CI/CD 파이프라인, 데이터베이스, 네트워크 설정 등 모든 인프라가 자동으로 프로비저닝되며, 새 프로젝트를 추가할 때마다 반복적인 인프라 설정 작업 없이 개발에 집중할 수 있다.

다음 글에서는 Prometheus, Grafana, Loki를 설치하여 클러스터의 메트릭과 로그를 수집하고 시각화하는 모니터링 시스템을 구축하는 방법을 알아본다.

[다음 글: 홈랩 쿠버네티스 #9 - Prometheus와 Grafana로 모니터링하기](/posts/homelab-k8s-monitoring/)
