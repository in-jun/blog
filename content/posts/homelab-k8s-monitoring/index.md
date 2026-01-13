---
title: "홈랩 #9 - 모니터링 시스템 구축하기"
date: 2025-02-28T08:46:48+09:00
draft: false
description: "홈랩 쿠버네티스 환경에 Prometheus, Grafana, Loki를 설치하여 간단한 모니터링 시스템을 구축하는 방법을 설명한다."
tags:
    [
        "kubernetes",
        "homelab",
        "monitoring",
        "prometheus",
        "grafana",
        "loki",
        "gitops",
    ]
series: ["홈랩"]
---

## 개요

[이전 글](homelab-k8s-cicd-2)에서는 CI/CD 시스템을 완성하고 프로젝트 자동화 시스템을 구축했다. 이번 글에서는 홈랩 쿠버네티스 클러스터를 모니터링하기 위한 기본 시스템을 구축하는 방법을 알아본다. Prometheus와 Grafana를 설치하고 기본 대시보드를 활용하여 클러스터 상태를 한눈에 볼 수 있도록 구성할 것이다. 또한 로그 수집을 위한 Loki를 설치하여 통합 모니터링 환경을 구성한다.

![Grafana](image.png)

## 모니터링의 필요성

홈랩 쿠버네티스 클러스터를 운영하다 보면 다음과 같은 정보를 주기적으로 확인해야 한다:

1. **클러스터 상태**: 노드, 파드, 배포 등의 상태
2. **리소스 사용량**: CPU, 메모리, 디스크, 네트워크 사용량
3. **애플리케이션 상태**: 파드의 정상 작동 여부
4. **시스템 로그**: 문제 발생 시 원인 파악을 위한 로그 데이터

이런 정보를 시각적으로 모니터링하기 위해 다음 도구들을 사용한다:

-   **Prometheus**: 시계열 메트릭 데이터 수집 및 저장
-   **Grafana**: 수집된 데이터 시각화 및 대시보드 제공
-   **Loki**: 로그 수집 및 쿼리 도구

## Kube-Prometheus-Stack 설치

Prometheus와 Grafana를 한 번에 설치하고 관리할 수 있는 Helm 차트인 Kube-Prometheus-Stack을 사용한다. 이전 글들과 마찬가지로 GitOps 방식으로 설치한다.

### 디렉토리 및 파일 구조 생성

```bash
mkdir -p k8s-resource/apps/kube-prometheus-stack/templates
cd k8s-resource/apps/kube-prometheus-stack
```

### Chart.yaml 생성

`Chart.yaml` 파일을 다음과 같이 작성한다:

```yaml
apiVersion: v2
name: kube-prometheus-stack
description: kube-prometheus-stack chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v0.79.2"
dependencies:
    - name: kube-prometheus-stack
      version: "68.1.0"
      repository: "https://prometheus-community.github.io/helm-charts"
```

이 파일은 Prometheus Community에서 제공하는 kube-prometheus-stack 차트의 68.1.0 버전을 사용하도록 정의한다.

### values.yaml 생성

`values.yaml` 파일을 다음과 같이 작성한다:

```yaml
kube-prometheus-stack:
    alertmanager:
        enabled: false

    grafana:
        enabled: true
        adminPassword: prom-operator
        persistence:
            enabled: true
            size: 5Gi
        resources:
            requests:
                cpu: 200m
                memory: 512Mi
            limits:
                cpu: 500m
                memory: 1Gi
        ingress:
            enabled: false
        grafana.ini:
            auth:
                disable_login_form: true
            auth.anonymous:
                enabled: true
                org_role: Admin
        additionalDataSources:
            - name: Loki
              type: loki
              url: http://loki-stack.loki-stack.svc.cluster.local:3100

    prometheus:
        enabled: true
        ingress:
            enabled: false
        prometheusSpec:
            retention: 5d
            resources:
                requests:
                    cpu: 500m
                    memory: 2Gi
                limits:
                    cpu: 1
                    memory: 2Gi
            storageSpec:
                volumeClaimTemplate:
                    spec:
                        resources:
                            requests:
                                storage: 20Gi

    prometheusOperator:
        enabled: true
        resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 200m
                memory: 256Mi

    kubeStateMetrics:
        enabled: true
        resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 200m
                memory: 256Mi

    nodeExporter:
        enabled: true
        resources:
            requests:
                cpu: 100m
                memory: 128Mi
            limits:
                cpu: 200m
                memory: 256Mi

    thanosRuler:
        enabled: false
```

이 설정의 특징은 다음과 같다:

1. **알림 관리자(Alertmanager)**: 비활성화하여 자원을 절약한다.
2. **Grafana**: 익명 접근을 허용하여 로그인 없이 대시보드를 볼 수 있다.
3. **Prometheus**: 데이터 보존 기간을 5일로 설정하여 디스크 사용량을 제한한다.
4. **리소스 제한**: 각 컴포넌트에 적절한 리소스 제한을 설정한다.
5. **Loki 데이터소스**: Grafana에 Loki 데이터소스를 미리 추가하여 로그 조회가 가능하도록 한다.

### 인그레스 설정

`templates/ingressroute.yaml` 파일을 생성하여 Traefik을 통한 접근을 설정한다:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: prometheus-grafana-route
    namespace: kube-prometheus-stack
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - kind: Rule
          match: Host(`prometheus.injunweb.com`)
          services:
              - name: kube-prometheus-stack-prometheus
                port: 9090
        - kind: Rule
          match: Host(`grafana.injunweb.com`)
          services:
              - name: kube-prometheus-stack-grafana
                port: 80
```

이 IngressRoute는 내부 네트워크에서만 접근 가능하도록 `intweb`과 `intwebsec` 엔트리포인트를 사용한다. `prometheus.injunweb.com`은 Prometheus 서버로, `grafana.injunweb.com`은 Grafana로 라우팅된다.

### 변경사항 커밋 및 배포

작성한 파일들을 Git 저장소에 추가하고 커밋한다:

```bash
git add .
git commit -m "Add kube-prometheus-stack configuration"
git push
```

ArgoCD가 변경사항을 감지하고 Kube-Prometheus-Stack을 자동으로 배포할 것이다. 설치 상태는 다음 명령어로 확인할 수 있다:

```bash
kubectl get pods -n kube-prometheus-stack
```

정상적으로 설치되면 다음과 비슷한 결과가 표시된다:

```
NAME                                                      READY   STATUS    RESTARTS   AGE
alertmanager-kube-prometheus-stack-alertmanager-0         2/2     Running   0          2m
kube-prometheus-stack-grafana-7dc95d688d-vwm6j            3/3     Running   0          2m
kube-prometheus-stack-kube-state-metrics-c6d6bc845-zrdbp  1/1     Running   0          2m
kube-prometheus-stack-operator-5dc88c8847-9xp6g           1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-4jlnz       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-7m8nj       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-c445j       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-j7lf6       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-w4q9v       1/1     Running   0          2m
prometheus-kube-prometheus-stack-prometheus-0              2/2     Running   0          2m
```

## Loki-Stack 설치

이제 로그 수집 및 분석을 위한 Loki-Stack을 설치한다. Loki는 Prometheus에서 영감을 받은 수평적 확장이 가능한 로그 집계 시스템이다.

### 디렉토리 및 파일 구조 생성

```bash
mkdir -p k8s-resource/apps/loki-stack/templates
cd k8s-resource/apps/loki-stack
```

### Chart.yaml 생성

`Chart.yaml` 파일을 다음과 같이 작성한다:

```yaml
apiVersion: v2
name: loki-stack
description: loki-stack chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v2.9.3"
dependencies:
    - name: loki-stack
      version: "2.10.2"
      repository: "https://grafana.github.io/helm-charts"
```

### values.yaml 생성

`values.yaml` 파일을 다음과 같이 작성한다:

```yaml
loki-stack:
    loki:
        enabled: true
        persistence:
            enabled: true
            size: 20Gi
        config:
            limits_config:
                enforce_metric_name: false
                reject_old_samples: true
                reject_old_samples_max_age: 168h
            schema_config:
                configs:
                    - from: 2025-01-16
                      store: boltdb-shipper
                      object_store: filesystem
                      schema: v11
                      index:
                          prefix: index_
                          period: 24h
        resources:
            requests:
                cpu: 200m
                memory: 256Mi
            limits:
                cpu: 1000m
                memory: 1Gi

    promtail:
        enabled: true
    grafana:
        enabled: false
    prometheus:
        enabled: false
    filebeat:
        enabled: false
    fluent-bit:
        enabled: false
    logstash:
        enabled: false
    serviceMonitor:
        enabled: true
```

이 설정의 특징은 다음과 같다:

1. **Loki**: 로그 데이터를 저장하기 위한 20Gi 스토리지를 할당하고, 7일(168시간) 이상된 로그는 거부하도록 설정한다.
2. **Promtail**: 각 노드에서 로그를 수집하여 Loki로 전송하는 에이전트를 활성화한다.
3. **Grafana**: 이미 Kube-Prometheus-Stack으로 설치했으므로 비활성화한다.
4. **ServiceMonitor**: Prometheus가 Loki의 메트릭을 수집할 수 있도록 활성화한다.

### 변경사항 커밋 및 배포

작성한 파일들을 Git 저장소에 추가하고 커밋한다:

```bash
git add .
git commit -m "Add Loki-Stack configuration"
git push
```

설치가 완료되면 다음 명령어로 확인할 수 있다:

```bash
kubectl get pods -n loki-stack
```

## 모니터링 시스템 접근하기

호스트 파일을 수정하여 Grafana와 Prometheus에 접근할 수 있도록 설정한다:

```
192.168.0.200 prometheus.injunweb.com grafana.injunweb.com
```

이제 웹 브라우저에서 다음 URL로 접속할 수 있다:

-   Grafana: http://grafana.injunweb.com
-   Prometheus: http://prometheus.injunweb.com

## Grafana 대시보드 살펴보기

Kube-Prometheus-Stack은 여러 유용한 대시보드를 기본으로 제공한다. Grafana에 접속하면 좌측 메뉴의 "Dashboards" 아이콘을 클릭하고, "Browse" 섹션에서 미리 구성된 대시보드 목록을 확인할 수 있다.

특히 "General" 폴더 안에 있는 "Kubernetes / Compute Resources" 관련 대시보드들은 클러스터의 리소스 사용량을 파악하는 데 매우 유용하다.

또한 "Node Exporter" 관련 대시보드는 각 노드의 상세한 시스템 메트릭을 확인할 수 있어 하드웨어 수준의 모니터링에 도움이 된다.

## Loki로 로그 탐색하기

Grafana에서 Loki 데이터소스를 사용하여 시스템 로그를 탐색할 수 있다. Loki는 LogQL이라는 쿼리 언어를 사용하여 로그를 필터링하고 검색할 수 있다.

### 기본 로그 쿼리

Grafana에서 "Explore" 메뉴로 이동한 후 데이터소스로 "Loki"를 선택하면 로그 쿼리를 시작할 수 있다. 몇 가지 유용한 쿼리 예시는 다음과 같다:

**특정 네임스페이스의 로그 조회:**

```
{namespace="kube-system"}
```

**특정 파드의 로그 조회:**

```
{namespace="argocd", pod=~"argocd-server.*"}
```

**에러 로그만 필터링:**

```
{namespace="traefik"} |= "error"
```

Loki를 통해 다양한 로그를 중앙에서 관리하고 문제 발생 시 신속하게 원인을 파악할 수 있다.

## 마치며

이것으로 홈랩 쿠버네티스 시리즈를 마무리한다. 기본 클러스터 설치부터 스토리지, 네트워킹, GitOps, CI/CD, 그리고 모니터링 시스템까지 구축하여 완전한 홈랩 쿠버네티스 환경을 완성했다.

이 인프라를 기반으로 이제 다양한 프로젝트를 테스트하고 개발할 수 있게 되었다. 비용 부담 없이 집에서도 클라우드 환경과 유사한 경험을 할 수 있어 기술 학습과 실험에 큰 도움이 될 것이다.
