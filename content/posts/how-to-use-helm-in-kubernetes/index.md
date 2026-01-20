---
title: "Helm 완벽 가이드: Kubernetes 패키지 관리의 모든 것"
date: 2024-07-28T23:22:52+09:00
tags: ["Kubernetes", "Helm", "DevOps", "Cloud Native", "Package Management"]
description: "Helm의 핵심 개념과 동작 원리를 이해하고, 차트 구조, 템플릿 작성, 릴리스 관리, CI/CD 통합까지 Kubernetes 애플리케이션 패키징과 배포의 전체 과정을 다룬다"
draft: false
---

Helm은 Kubernetes 애플리케이션의 패키징, 배포, 버전 관리를 위한 패키지 관리자로, 2015년 Deis(현재 Microsoft)에서 처음 개발되어 2018년 CNCF(Cloud Native Computing Foundation)에 합류했으며, 현재 Kubernetes 생태계에서 가장 널리 사용되는 배포 도구로 자리잡았다. Helm은 Linux의 apt나 yum, macOS의 Homebrew와 유사한 역할을 Kubernetes에서 수행하며, 복잡한 Kubernetes 매니페스트 파일들을 Chart라는 패키지 형태로 묶어 한 번의 명령으로 설치, 업그레이드, 롤백할 수 있게 하고, 환경별 설정 관리와 의존성 처리를 자동화하여 애플리케이션 배포의 복잡성을 크게 줄여준다.

## Helm 개요

> **Helm이란?**
>
> Helm은 Kubernetes용 패키지 관리자로, Chart라 불리는 패키지를 통해 Kubernetes 애플리케이션을 정의, 설치, 업그레이드한다. "Kubernetes의 apt/yum"으로 불리며, 복잡한 애플리케이션을 단일 명령으로 배포할 수 있게 한다.

### Helm의 발전 역사

| 연도 | 이벤트 | 의미 |
|-----|--------|------|
| **2015** | Helm v1 출시 (Deis) | Kubernetes 패키지 관리 개념 도입 |
| **2016** | Helm v2 출시 | Tiller 서버 도입, 프로덕션 사용 확대 |
| **2018** | CNCF 합류 | Kubernetes 생태계 공식 프로젝트로 인정 |
| **2019** | Helm v3 출시 | Tiller 제거, 보안 강화, 3-way 병합 |
| **현재** | Helm v3.x | CNCF Graduated 프로젝트 |

### Helm v2 vs Helm v3

| 특성 | Helm v2 | Helm v3 |
|-----|---------|---------|
| **Tiller** | 필수 (서버 컴포넌트) | 제거됨 |
| **보안** | Tiller에 광범위한 권한 필요 | 사용자 kubeconfig 권한 사용 |
| **릴리스 저장소** | ConfigMap (Tiller 네임스페이스) | Secret (릴리스 네임스페이스) |
| **3-way 병합** | 미지원 | 지원 (실시간 상태 반영) |
| **네임스페이스** | Tiller가 관리 | 릴리스별 네임스페이스 |
| **차트 유효성 검사** | 기본적인 검사 | JSON Schema 지원 |

## 핵심 개념

### Chart (차트)

> **Chart란?**
>
> Chart는 Kubernetes 리소스를 설명하는 파일들의 집합으로, 템플릿화된 YAML 매니페스트, 메타데이터(Chart.yaml), 기본 설정값(values.yaml)으로 구성되며, Helm의 기본 배포 단위이다.

### Release (릴리스)

릴리스는 Chart의 실행 중인 인스턴스로, 동일한 Chart를 다른 설정으로 여러 번 설치할 수 있으며 각 설치는 고유한 릴리스 이름을 가진다. 예를 들어 MySQL Chart를 `mysql-production`과 `mysql-staging`이라는 두 개의 릴리스로 설치할 수 있다.

### Repository (저장소)

Chart들을 저장하고 공유하는 장소로, HTTP 서버에서 호스팅되며 index.yaml 파일로 차트 목록을 관리한다. 대표적인 저장소로는 Artifact Hub(구 Helm Hub), Bitnami Charts 등이 있다.

### Values (값)

Chart의 기본 설정을 오버라이드하는 설정값으로, values.yaml 파일에 정의되거나 명령행 인자로 전달된다.

## Helm 설치

### 운영체제별 설치 방법

| 운영체제 | 설치 명령 |
|---------|----------|
| **macOS (Homebrew)** | `brew install helm` |
| **Linux (스크립트)** | `curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \| bash` |
| **Windows (Chocolatey)** | `choco install kubernetes-helm` |

설치 확인:

```bash
helm version
```

## 기본 명령어

### 저장소 관리

```bash
# 저장소 추가
helm repo add bitnami https://charts.bitnami.com/bitnami

# 저장소 목록 확인
helm repo list

# 저장소 업데이트 (최신 차트 정보 동기화)
helm repo update

# 저장소 제거
helm repo remove bitnami
```

### 차트 검색 및 정보 확인

```bash
# 저장소에서 차트 검색
helm search repo nginx

# Artifact Hub에서 검색
helm search hub nginx

# 차트 정보 확인
helm show chart bitnami/nginx
helm show values bitnami/nginx
helm show readme bitnami/nginx
```

### 릴리스 관리

| 명령 | 설명 |
|------|------|
| `helm install <릴리스명> <차트>` | 차트 설치 |
| `helm upgrade <릴리스명> <차트>` | 릴리스 업그레이드 |
| `helm rollback <릴리스명> <리비전>` | 이전 버전으로 롤백 |
| `helm uninstall <릴리스명>` | 릴리스 삭제 |
| `helm list` | 설치된 릴리스 목록 |
| `helm history <릴리스명>` | 릴리스 히스토리 |
| `helm status <릴리스명>` | 릴리스 상태 확인 |

```bash
# 차트 설치
helm install my-nginx bitnami/nginx

# 커스텀 values로 설치
helm install my-nginx bitnami/nginx -f custom-values.yaml

# 명령행에서 값 지정
helm install my-nginx bitnami/nginx --set service.type=LoadBalancer

# 특정 네임스페이스에 설치
helm install my-nginx bitnami/nginx -n production --create-namespace

# 업그레이드 (없으면 설치)
helm upgrade --install my-nginx bitnami/nginx

# 롤백
helm rollback my-nginx 1

# 삭제
helm uninstall my-nginx
```

## Chart 구조

표준 Helm Chart의 디렉토리 구조:

```
mychart/
├── Chart.yaml          # 차트 메타데이터
├── Chart.lock          # 종속성 버전 잠금
├── values.yaml         # 기본 설정값
├── values.schema.json  # values 스키마 (선택)
├── charts/             # 종속 차트 (서브차트)
├── crds/               # Custom Resource Definitions
├── templates/          # 템플릿 파일들
│   ├── NOTES.txt       # 설치 후 표시 메시지
│   ├── _helpers.tpl    # 재사용 템플릿 정의
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ...
└── README.md
```

### Chart.yaml

```yaml
apiVersion: v2           # Helm 3는 v2 사용
name: mychart
version: 1.0.0           # 차트 버전 (SemVer)
appVersion: "1.16.0"     # 애플리케이션 버전
description: My application Helm chart
type: application        # application 또는 library
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

## 템플릿 작성

Helm 템플릿은 Go 템플릿 언어를 기반으로 하며, values.yaml의 값을 참조하여 Kubernetes 매니페스트를 동적으로 생성한다.

### 기본 문법

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

### 주요 내장 객체

| 객체 | 설명 |
|-----|------|
| `.Values` | values.yaml 또는 --set으로 전달된 값 |
| `.Release` | 릴리스 정보 (Name, Namespace, IsInstall 등) |
| `.Chart` | Chart.yaml의 내용 |
| `.Files` | 차트 내 파일 접근 |
| `.Capabilities` | 클러스터 정보 (API 버전 등) |
| `.Template` | 현재 템플릿 정보 |

### 제어 구조

```yaml
# 조건문
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
...
{{- end }}

# 반복문
{{- range .Values.extraEnvVars }}
- name: {{ .name }}
  value: {{ .value | quote }}
{{- end }}

# with (스코프 변경)
{{- with .Values.nodeSelector }}
nodeSelector:
  {{- toYaml . | nindent 2 }}
{{- end }}
```

### 유용한 함수

| 함수 | 설명 | 예시 |
|-----|------|------|
| `default` | 기본값 설정 | `{{ .Values.name \| default "nginx" }}` |
| `quote` | 문자열 따옴표 처리 | `{{ .Values.name \| quote }}` |
| `upper` / `lower` | 대/소문자 변환 | `{{ .Values.name \| upper }}` |
| `toYaml` | YAML로 변환 | `{{ toYaml .Values.labels \| nindent 4 }}` |
| `indent` / `nindent` | 들여쓰기 | `{{ include "mychart.labels" . \| nindent 4 }}` |
| `b64enc` | Base64 인코딩 | `{{ .Values.secret \| b64enc }}` |

### 재사용 템플릿 (_helpers.tpl)

```yaml
{{/* 공통 레이블 정의 */}}
{{- define "mychart.labels" -}}
helm.sh/chart: {{ .Chart.Name }}-{{ .Chart.Version }}
app.kubernetes.io/name: {{ .Chart.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* 사용 */}}
metadata:
  labels:
    {{- include "mychart.labels" . | nindent 4 }}
```

## 차트 개발 및 테스트

```bash
# 새 차트 생성
helm create mychart

# 차트 문법 검사
helm lint mychart

# 템플릿 렌더링 확인 (설치 없이)
helm template my-release mychart

# 특정 values로 렌더링
helm template my-release mychart -f prod-values.yaml

# 드라이런 (API 서버 검증)
helm install my-release mychart --dry-run --debug

# 차트 패키징
helm package mychart

# 종속성 업데이트
helm dependency update mychart
```

## Hooks

Helm Hook은 릴리스 라이프사이클의 특정 시점에 실행되는 리소스를 정의할 수 있게 한다.

| Hook | 실행 시점 |
|------|----------|
| `pre-install` | 템플릿 렌더링 후, 리소스 생성 전 |
| `post-install` | 모든 리소스 생성 후 |
| `pre-upgrade` | 업그레이드 시 템플릿 렌더링 후, 리소스 업데이트 전 |
| `post-upgrade` | 업그레이드 완료 후 |
| `pre-delete` | 삭제 요청 시, 리소스 삭제 전 |
| `post-delete` | 모든 리소스 삭제 후 |
| `pre-rollback` | 롤백 시 템플릿 렌더링 후, 리소스 복원 전 |
| `post-rollback` | 롤백 완료 후 |

Hook 정의 예시:

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

## CI/CD 통합

Helm은 CI/CD 파이프라인에 쉽게 통합된다. GitLab CI 예시:

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

## 보안 고려사항

| 항목 | 권장 사항 |
|-----|----------|
| **민감 정보** | values.yaml에 직접 포함하지 않고 Kubernetes Secret 또는 외부 시크릿 관리 도구 사용 |
| **차트 검증** | 신뢰할 수 있는 저장소의 차트만 사용, 설치 전 내용 검토 |
| **RBAC** | 최소 권한 원칙 적용, 네임스페이스별 권한 분리 |
| **서명 검증** | `helm verify` 명령으로 차트 서명 검증 |

## 결론

Helm은 Kubernetes 애플리케이션의 패키징, 배포, 버전 관리를 표준화하는 핵심 도구로, 2015년 처음 개발된 이후 Kubernetes 생태계의 사실상 표준 패키지 관리자로 자리잡았다. Chart를 통해 복잡한 애플리케이션을 단일 배포 단위로 관리하고, 템플릿과 values를 활용한 환경별 설정 관리, 릴리스 히스토리를 통한 롤백 기능, 차트 저장소를 통한 공유와 재사용이 가능하여 Kubernetes 운영의 복잡성을 크게 줄여준다.
