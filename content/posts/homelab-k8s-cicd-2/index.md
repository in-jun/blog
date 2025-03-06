---
title: "홈랩 #8 - CI/CD 구축해서 배포 자동화하기 (2)"
date: 2025-02-28T07:47:18+09:00
draft: false
description: "홈랩 쿠버네티스 환경에서 GitOps 기반의 프로젝트 자동화 시스템을 구축하고 완전한 CI/CD 파이프라인을 완성하는 방법을 설명한다."
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
series: ["홈랩"]
---

## 개요

[이전 글](homelab-k8s-cicd-1)에서는 CI/CD 시스템의 핵심 구성 요소인 Harbor 레지스트리, Argo Events, Argo Workflows를 설치했다. 이번 글에서는 이 세 가지 구성 요소와 기존에 설치한 ArgoCD를 통합하여 완전한 CI/CD 파이프라인을 완성하고, GitOps 기반의 프로젝트 자동화 시스템을 구축하는 방법을 알아본다.

## CI/CD와 GitOps의 통합

기존 CI 시스템과 GitOps의 통합은 자연스러운 진화 과정이다. 기존의 CI는 코드 변경을 감지하여 빌드하고 테스트하는 데 중점을 두었다면, GitOps는 배포 상태를 선언적으로 관리하고 자동으로 동기화하는 데 중점을 둔다. 이 두 가지를 결합하면 코드 변경부터 자동 배포까지 완전 자동화된 파이프라인을 구축할 수 있다.

![CI/CD와 GitOps의 통합](image.png)

## 프로젝트 템플릿 설계

여러 프로젝트에서 재사용할 수 있는 템플릿을 설계하는 것은 매우 중요하다. 이를 통해 새로운 프로젝트를 시작할 때마다 인프라를 처음부터 구축하는 부담을 줄일 수 있다. 이번 글에서는 Helm 차트를 활용하여 재사용 가능한 프로젝트 템플릿을 만들고, 간단한 선언만으로 완전한 CI/CD 파이프라인을 구축하는 방법을 알아본다.

### 프로젝트 템플릿의 요구사항

홈랩 환경에서 여러 프로젝트를 쉽게 관리하기 위해 템플릿에 포함되어야 할 기능은 다음과 같다:

1. **자동화된 CI/CD 파이프라인**: 코드 변경 시 자동으로 빌드 및 배포
2. **선언적 리소스 관리**: YAML 파일로 애플리케이션과 데이터베이스 설정
3. **보안 관리**: 시크릿과 인증 정보의 안전한 관리
4. **네트워크 설정**: 내부/외부 접근을 위한 인그레스 설정

## 프로젝트 관리를 위한 Git 저장소 구조

프로젝트 관리를 위해 두 개의 Git 저장소를 사용한다:

1. **프로젝트 구성 저장소**: `https://github.com/injunweb/projects-gitops`

    - 각 프로젝트의 설정 정보(YAML 파일)를 저장
    - 배포할 애플리케이션과 데이터베이스 정보를 정의

2. **Helm 차트 저장소**: 동일 저장소의 `chart` 디렉토리
    - 프로젝트 템플릿을 정의하는 Helm 차트 포함
    - CI/CD 파이프라인과 쿠버네티스 리소스 템플릿 정의

### 저장소 디렉토리 구조

프로젝트 구성 저장소는 다음과 같은 구조로 설계되었다:

```
projects-gitops/
├── .github/workflows/      # GitHub Action 워크플로우
│   └── update-config.yaml  # 설정 업데이트 API 워크플로우
├── applicationset.yaml     # ArgoCD ApplicationSet 정의
├── chart/                  # Helm 차트 디렉토리
│   ├── Chart.yaml          # 차트 정보
│   └── templates/          # 템플릿 디렉토리
│       ├── app/            # 애플리케이션 관련 템플릿
│       │   ├── ci/         # CI 파이프라인 템플릿
│       │   ├── deployment.yaml  # 배포 템플릿
│       │   └── ...
│       ├── db/             # 데이터베이스 관련 템플릿
│       └── ...
└── projects/               # 프로젝트 설정 디렉토리
    ├── project1.yaml       # 프로젝트 1 설정
    ├── project2.yaml       # 프로젝트 2 설정
    └── ...
```

## ApplicationSet 설계

ApplicationSet은 여러 ArgoCD 애플리케이션을 자동으로 생성하는 강력한 메커니즘이다. 이를 통해 `projects` 디렉토리에 새 파일을 추가하는 것만으로 새로운 프로젝트를 배포할 수 있다.

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

이 ApplicationSet의 핵심 기능은 다음과 같다:

1. `projects/*.yaml` 패턴에 맞는 모든 파일을 찾는다.
2. 각 파일에 대해 ArgoCD 애플리케이션을 생성한다.
3. 애플리케이션은 차트 디렉토리의 Helm 차트와 프로젝트 설정 파일을 사용한다.
4. ArgoCD Vault Plugin을 통해 시크릿 값을 안전하게 처리한다.

Go 템플릿 문법을 사용하여 파일 이름에서 프로젝트 이름과 네임스페이스를 추출한다. 예를 들어, `projects/myapp.yaml` 파일은 `myapp`이라는 이름의 애플리케이션과 네임스페이스를 생성한다.

## 프로젝트 설정 구조

각 프로젝트는 YAML 파일로 정의되며, 다음과 같은 구조를 가진다:

```yaml
applications:
    - name: app1 # 애플리케이션 이름
      git:
          type: github # Git 저장소 유형
          owner: example-org # 저장소 소유자
          repo: custom-app # 저장소 이름
          branch: develop # 브랜치
          hash: ~ # 빌드 및 배포할 커밋 해시
      port: 8000 # 컨테이너 포트
      domains: # 접근 도메인 목록
          - custom1.example.com

databases:
    - name: mysql # 데이터베이스 이름
      type: mysql # 데이터베이스 유형 (mysql, postgres, redis, mongodb)
      version: "8.0" # 버전
      port: 3306 # 포트
      size: 2Gi # 저장 공간 크기
```

이 구조는 간결하면서도 필요한 모든 정보를 포함하고 있다. 특히 `applications[].git.hash` 필드는 CI 파이프라인이 빌드하고 배포할 특정 커밋을 지정한다. 이 값이 비어 있으면 배포가 생성되지 않으며, CI 파이프라인이 성공적으로 완료된 후 자동으로 설정된다.

## CI 파이프라인 설계

CI 파이프라인은 Argo Events와 Argo Workflows를 사용하여 구축된다. 이 파이프라인은 다음과 같은 단계로 구성된다:

1. **이벤트 감지**: Git 저장소의 변경을 감지 (Argo Events)
2. **빌드 트리거**: 변경이 감지되면 빌드 워크플로우 시작 (Argo Events → Argo Workflows)
3. **컨테이너 빌드**: 소스 코드를 빌드하여 컨테이너 이미지 생성 (Argo Workflows)
4. **이미지 푸시**: 빌드된 이미지를 Harbor 레지스트리에 푸시 (Argo Workflows)
5. **설정 업데이트**: 빌드된 이미지의 해시 값으로 프로젝트 설정 업데이트 (GitHub API)

### EventBus 설정

각 프로젝트마다 이벤트 버스를 설정한다:

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

이 템플릿은 각 프로젝트별로 독립적인 이벤트 버스를 생성한다. NATS 기반의 이벤트 버스는 이벤트 소스와 센서 간의 통신을 담당한다.

### GitHub EventSource 설정

GitHub 웹훅을 수신하기 위한 EventSource를 설정한다:

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

이 템플릿은 프로젝트의 각 애플리케이션마다 GitHub 웹훅을 수신하는 EventSource를 생성한다. 각 애플리케이션은 자신의 GitHub 저장소에서 푸시 이벤트를 감지한다.

### Sensor 설정 (이벤트 필터링)

특정 브랜치로의 푸시 이벤트만 감지하도록 Sensor를 설정한다:

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

이 템플릿은 각 애플리케이션마다 Sensor를 생성한다. Sensor는 특정 브랜치(예: "develop")로의 푸시 이벤트만 감지하고, 해당 커밋 해시를 워크플로우에 전달한다. 필터를 통해 원하는 브랜치의 이벤트만 처리할 수 있다.

### 워크플로우 템플릿 (CI 작업 정의)

빌드 및 배포 작업을 위한 워크플로우 템플릿을 정의한다:

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

워크플로우 템플릿의 주요 특징은 다음과 같다:

1. **Kaniko**: 도커 데몬 없이 컨테이너 이미지를 안전하게 빌드한다. 이는 권한 상승 없이 이미지를 빌드할 수 있어 보안에 좋다.
2. **캐싱**: 빌드 시간 단축을 위한 캐싱 기능을 사용한다. 이전 빌드의 레이어를 재사용하여 빌드 성능을 향상시킨다.
3. **GitHub API**: 빌드 후 프로젝트 설정 업데이트를 위해 GitHub API를 호출한다. 이를 통해 배포할 이미지의 해시 값이 자동으로 업데이트된다.

DAG(Directed Acyclic Graph) 템플릿을 사용하여 작업 간의 종속성을 정의한다. 빌드가 성공적으로 완료된 후에만 설정 업데이트 작업이 실행된다.

## CD 파이프라인 설계

CD 파이프라인은 ArgoCD를 통해 구현되며, CI 파이프라인에서 업데이트된 프로젝트 설정을 감지하여 자동으로 배포가 이루어진다. 배포 리소스는 다음과 같이 정의된다:

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
                  name: {{ $.Values.project }}-{{ $db.name }}-secret
                  key: password
            {{- end }}
            {{- end }}
      imagePullSecrets:
        - name: registry-secret
{{- end }}
{{- end }}
```

여기서 중요한 점은 `$app.git.hash` 값이 있는 경우에만 배포가 생성된다는 것이다. 이는 CI 파이프라인이 성공적으로 완료되어 프로젝트 설정이 업데이트된 후에만 배포가 이루어짐을 의미한다.

배포 템플릿의 주요 특징은 다음과 같다:

1. **롤링 업데이트**: 배포 전략으로 롤링 업데이트를 사용하여 무중단 배포를 구현한다.
2. **파드 분산**: 파드 안티-어피니티를 통해 동일한 애플리케이션의 파드가 서로 다른 노드에 분산되도록 한다.
3. **정상 종료**: `preStop` 훅과 적절한 종료 유예 기간을 통해 애플리케이션이 정상적으로 종료될 수 있도록 한다.
4. **환경 변수**: 데이터베이스 연결 정보 등을 환경 변수로 제공한다.

## 인그레스 설정

애플리케이션에 접근하기 위한 인그레스 경로를 설정한다:

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

이 템플릿은 각 애플리케이션의 도메인마다 Traefik IngressRoute를 생성한다. 외부에서 접근 가능하도록 `web`과 `websecure` 엔트리포인트를 사용한다.

## 데이터베이스 설정

프로젝트 설정에 정의된 데이터베이스를 배포한다:

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
        # ... 다른 데이터베이스 유형에 대한 설정 ...
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

이 템플릿은 프로젝트 설정에 정의된 데이터베이스마다 StatefulSet을 생성한다. 데이터베이스 유형(MySQL, Redis, PostgreSQL, MongoDB)에 따라 다른 설정을 적용하며, 데이터 저장을 위한 영구 볼륨을 생성한다.

## 설정 업데이트를 위한 GitHub Action

CI 파이프라인에서 호출하는 GitHub Action을 설정하여 프로젝트 설정을 업데이트한다:

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

이 GitHub Action은 저장소 디스패치 이벤트를 수신하여 프로젝트 설정 파일을 업데이트한다. `yq` 도구를 사용하여 YAML 파일을 파싱하고 수정한다. CI 파이프라인이 성공적으로 완료되면 이 API를 호출하여 빌드된 이미지의 해시 값으로 프로젝트 설정을 업데이트한다.

## 프로젝트 생성 및 사용

이제 완전한 CI/CD 파이프라인을 갖춘 새로운 프로젝트를 생성하는 방법을 알아보자.

### 1. 프로젝트 정의 파일 생성

`projects/myproject.yaml` 파일을 생성한다:

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

이 파일은 두 개의 애플리케이션(API와 프론트엔드)과 MySQL 데이터베이스를 가진 프로젝트를 정의한다.

### 2. Vault에 시크릿 저장

애플리케이션에 필요한 시크릿을 Vault에 저장한다:

```bash
# GitHub 접근 토큰 저장
vault kv put injunweb/myproject-github-access username=myusername token=ghp_xxxxxxxxxxxx

# 애플리케이션 시크릿 저장
vault kv put injunweb/myproject-api API_KEY=secretkey DB_PASSWORD=dbpass
```

### 3. 프로젝트 배포 확인

새 프로젝트 정의 파일을 커밋하고 푸시하면 ArgoCD가 자동으로 애플리케이션을 생성한다. 배포 상태는 ArgoCD UI에서 확인할 수 있다:

```bash
# 네임스페이스 생성 확인
kubectl get ns myproject

# CI/CD 리소스 확인
kubectl get eventbus,eventsource,sensor -n myproject

# 데이터베이스 배포 확인
kubectl get statefulset -n myproject
```

## 마치며

이번 글에서는 홈랩 쿠버네티스 환경에서 완전한 CI/CD 파이프라인을 구축하는 방법을 알아보았다. 가장 큰 성과는 모든 프로젝트에 대해 재사용 가능한 템플릿을 설계하고, 간단한 YAML 파일만으로 완전한 CI/CD 파이프라인을 구축할 수 있게 된 것이다.

[다음 글](homelab-k8s-monitoring)에서는 모니터링 및 로깅 시스템을 보강하고, 시스템 관리를 위한 대시보드를 구축하는 방법을 알아볼 것이다.
