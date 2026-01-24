---
title: "미니PC Kubernetes #9: Prometheus 모니터링"
date: 2025-02-28T08:46:48+09:00
draft: false
description: "Prometheus와 Grafana를 사용한 쿠버네티스 모니터링 구성을 설명한다."
tags: ["Kubernetes", "모니터링", "Prometheus"]
series: ["미니PC Kubernetes"]
---

## 개요

[이전 글](/posts/homelab-k8s-cicd-2/)에서는 Helm 차트 기반 프로젝트 템플릿과 ArgoCD ApplicationSet을 활용하여 내부 개발자 플랫폼(IDP)을 구축했다. 이번 글에서는 홈랩 쿠버네티스 클러스터를 모니터링하기 위해 Prometheus와 Grafana를 설치하여 메트릭을 수집하고 시각화하며, Loki를 설치하여 로그를 중앙에서 수집하고 분석할 수 있는 통합 모니터링 환경을 구성하는 방법을 알아본다.

![Grafana](image.png)

## 모니터링의 필요성

홈랩 쿠버네티스 클러스터를 운영하다 보면 노드와 파드의 상태, CPU와 메모리 같은 리소스 사용량, 애플리케이션의 정상 작동 여부, 문제 발생 시 원인 파악을 위한 로그 데이터 등을 주기적으로 확인해야 하며, 이런 정보를 시각적으로 모니터링하기 위해 다음과 같은 도구들을 사용한다.

> **Prometheus란?**
>
> Prometheus는 2012년 SoundCloud에서 시작되어 2016년 CNCF(Cloud Native Computing Foundation)에 합류한 오픈소스 모니터링 시스템으로, 시계열 데이터베이스에 메트릭을 수집하고 저장하며 강력한 쿼리 언어인 PromQL을 통해 데이터를 조회하고 분석할 수 있고 쿠버네티스 환경에서 가장 널리 사용되는 모니터링 도구이다.

> **Grafana란?**
>
> Grafana는 2014년 Torkel Ödegaard가 개발한 오픈소스 데이터 시각화 플랫폼으로, Prometheus, Loki, Elasticsearch 같은 다양한 데이터소스와 연동하여 대시보드를 구성할 수 있으며 직관적인 UI와 풍부한 시각화 옵션을 제공하여 모니터링 데이터를 효과적으로 표현할 수 있다.

> **Loki란?**
>
> Loki는 Grafana Labs에서 2018년에 개발한 로그 집계 시스템으로, Prometheus에서 영감을 받아 라벨 기반의 인덱싱 방식을 사용하여 로그를 수집하고 저장하며, 전체 로그 내용을 인덱싱하지 않고 메타데이터만 인덱싱하여 리소스 효율적인 로그 관리가 가능하다.

## Kube-Prometheus-Stack 설치

Prometheus와 Grafana를 개별적으로 설치하고 구성하는 것은 복잡하므로, 두 도구를 한 번에 설치하고 관리할 수 있는 Helm 차트인 Kube-Prometheus-Stack을 사용하며 이전 글들과 마찬가지로 GitOps 방식으로 설치한다.

### 1. 디렉토리 및 파일 구조 생성

```bash
mkdir -p k8s-resource/apps/kube-prometheus-stack/templates
cd k8s-resource/apps/kube-prometheus-stack
```

### 2. Chart.yaml 생성

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

이 설정은 Prometheus Community에서 제공하는 kube-prometheus-stack 차트의 68.1.0 버전을 사용하도록 정의하며, 이 차트는 Prometheus, Grafana, Alertmanager, Node Exporter, Kube State Metrics 등 모니터링에 필요한 모든 컴포넌트를 포함한다.

### 3. values.yaml 생성

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

이 설정의 주요 특징은 다음과 같다:

- **Alertmanager**: 홈랩 환경에서는 알림 시스템이 필수적이지 않으므로 비활성화하여 리소스를 절약한다.
- **Grafana**: 익명 접근을 허용하여 로그인 없이 대시보드를 볼 수 있도록 구성하고, Loki 데이터소스를 미리 추가하여 로그 조회가 가능하도록 한다.
- **Prometheus**: 데이터 보존 기간을 5일로 설정하여 디스크 사용량을 제한하고, 20Gi 스토리지를 할당한다.
- **리소스 제한**: 각 컴포넌트에 적절한 CPU와 메모리 제한을 설정하여 클러스터 리소스를 효율적으로 사용한다.

### 4. 인그레스 설정

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

이 IngressRoute는 `intweb`과 `intwebsec` 엔트리포인트를 사용하여 내부 네트워크에서만 접근 가능하도록 구성하며, `prometheus.injunweb.com`은 Prometheus 서버로, `grafana.injunweb.com`은 Grafana로 라우팅된다.

### 5. 변경사항 커밋 및 배포

작성한 파일들을 Git 저장소에 추가하고 커밋한다:

```bash
git add .
git commit -m "Add kube-prometheus-stack configuration"
git push
```

ArgoCD가 변경사항을 감지하고 Kube-Prometheus-Stack을 자동으로 배포하며, 설치 상태는 다음 명령어로 확인할 수 있다:

```bash
kubectl get pods -n kube-prometheus-stack
```

정상적으로 설치되면 다음과 비슷한 결과가 표시된다:

```
NAME                                                       READY   STATUS    RESTARTS   AGE
kube-prometheus-stack-grafana-7dc95d688d-vwm6j             3/3     Running   0          2m
kube-prometheus-stack-kube-state-metrics-c6d6bc845-zrdbp   1/1     Running   0          2m
kube-prometheus-stack-operator-5dc88c8847-9xp6g            1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-4jlnz       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-7m8nj       1/1     Running   0          2m
kube-prometheus-stack-prometheus-node-exporter-c445j       1/1     Running   0          2m
prometheus-kube-prometheus-stack-prometheus-0              2/2     Running   0          2m
```

## Loki-Stack 설치

이제 로그 수집 및 분석을 위한 Loki-Stack을 설치하며, Loki는 Prometheus와 유사한 라벨 기반 인덱싱 방식을 사용하여 로그를 수집하고 저장하는 수평적 확장이 가능한 로그 집계 시스템이다.

### 1. 디렉토리 및 파일 구조 생성

```bash
mkdir -p k8s-resource/apps/loki-stack/templates
cd k8s-resource/apps/loki-stack
```

### 2. Chart.yaml 생성

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

### 3. values.yaml 생성

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

이 설정의 주요 특징은 다음과 같다:

- **Loki**: 로그 데이터를 저장하기 위한 20Gi 스토리지를 할당하고, 7일(168시간) 이상 된 로그는 거부하도록 설정하여 디스크 사용량을 관리한다.
- **Promtail**: 각 노드에서 컨테이너 로그를 수집하여 Loki로 전송하는 DaemonSet 에이전트를 활성화한다.
- **Grafana, Prometheus**: 이미 Kube-Prometheus-Stack으로 설치했으므로 비활성화한다.
- **ServiceMonitor**: Prometheus가 Loki의 메트릭을 수집할 수 있도록 ServiceMonitor를 활성화한다.

### 4. 변경사항 커밋 및 배포

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

```
NAME                            READY   STATUS    RESTARTS   AGE
loki-stack-0                    1/1     Running   0          2m
loki-stack-promtail-xxxxx       1/1     Running   0          2m
loki-stack-promtail-yyyyy       1/1     Running   0          2m
```

## 모니터링 시스템 접근

로컬 컴퓨터의 호스트 파일을 수정하여 Grafana와 Prometheus에 접근할 수 있도록 설정한다:

```
192.168.0.200 prometheus.injunweb.com grafana.injunweb.com
```

이제 웹 브라우저에서 다음 URL로 접속할 수 있다:

- Grafana: `http://grafana.injunweb.com`
- Prometheus: `http://prometheus.injunweb.com`

## Grafana 대시보드 활용

Kube-Prometheus-Stack은 클러스터 모니터링에 유용한 여러 대시보드를 기본으로 제공하며, Grafana에 접속하면 좌측 메뉴의 "Dashboards" 아이콘을 클릭하고 "Browse" 섹션에서 미리 구성된 대시보드 목록을 확인할 수 있다.

특히 "General" 폴더 안에 있는 "Kubernetes / Compute Resources" 관련 대시보드들은 클러스터의 CPU, 메모리, 네트워크 사용량을 네임스페이스, 파드, 컨테이너 단위로 파악하는 데 매우 유용하며, "Node Exporter" 관련 대시보드는 각 노드의 디스크 I/O, 네트워크 트래픽, 시스템 부하 같은 상세한 하드웨어 수준의 메트릭을 확인할 수 있어 인프라 모니터링에 도움이 된다.

## Loki로 로그 탐색

Grafana에서 Loki 데이터소스를 사용하여 클러스터의 모든 컨테이너 로그를 중앙에서 탐색할 수 있으며, Loki는 LogQL이라는 쿼리 언어를 사용하여 로그를 필터링하고 검색한다.

### 기본 로그 쿼리

Grafana에서 "Explore" 메뉴로 이동한 후 데이터소스로 "Loki"를 선택하면 로그 쿼리를 시작할 수 있으며, 몇 가지 유용한 쿼리 예시는 다음과 같다:

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

**특정 시간 범위 내 로그 조회:**

```
{namespace="default"} |= "timeout" | json
```

Loki를 통해 여러 파드와 노드에 분산된 로그를 중앙에서 관리하고, 문제 발생 시 LogQL 쿼리를 통해 신속하게 원인을 파악할 수 있다.

## 마치며

이번 글에서는 홈랩 쿠버네티스 클러스터에 Kube-Prometheus-Stack과 Loki-Stack을 설치하여 메트릭 수집, 시각화, 로그 집계가 가능한 통합 모니터링 시스템을 구축하는 방법을 살펴보았다.

이것으로 홈랩 쿠버네티스 시리즈를 마무리한다. 기본 클러스터 설치부터 ArgoCD GitOps 환경, Longhorn 분산 스토리지, Traefik 인그레스 컨트롤러, Vault 시크릿 관리, CI/CD 파이프라인, 그리고 Prometheus와 Grafana, Loki를 활용한 모니터링 시스템까지 구축하여 완전한 홈랩 쿠버네티스 환경을 완성했다. 이 인프라를 기반으로 클라우드 서비스 비용 부담 없이 프로덕션과 유사한 쿠버네티스 환경에서 다양한 프로젝트를 테스트하고 개발할 수 있다.
