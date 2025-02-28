---
title: "홈랩 #7 - CI/CD 구축해서 배포 자동화하기 (1)"
date: 2025-02-28T04:32:32+09:00
draft: false
description: "홈랩 쿠버네티스 환경에 CI/CD 시스템의 기반이 되는 Harbor 레지스트리, Argo Events, Argo Workflows를 설치하는 방법을 설명한다."
tags:
    [
        "kubernetes",
        "homelab",
        "ci/cd",
        "harbor",
        "argo-events",
        "argo-workflows",
        "gitops",
    ]
series: ["홈랩"]
---

## 개요

이전 글에서는 홈랩 쿠버네티스 클러스터에 Vault를 설치하고 시크릿 관리 시스템을 구축했다. 이번 글에서는 CI/CD 시스템의 기반이 되는 세 가지 핵심 컴포넌트인 Harbor 레지스트리, Argo Events, Argo Workflows를 설치하고 기본 설정하는 방법을 알아본다.

![CI/CD](image.png)

## CI/CD 시스템의 구성 요소

홈랩 환경에서 완전한 CI/CD 파이프라인을 구축하기 위해서는 다음과 같은 핵심 컴포넌트들이 필요하다:

1. **컨테이너 레지스트리**: 빌드된 이미지를 저장하고 관리하는 저장소
2. **이벤트 처리 시스템**: 코드 변경 등의 이벤트를 감지하고 처리하는 시스템
3. **워크플로우 엔진**: 빌드, 테스트, 배포 등의 작업을 실행하는 엔진
4. **선언적 배포 시스템**: 배포 상태를 관리하고 동기화하는 시스템

이 중 4번(선언적 배포 시스템)은 이미 이전 글에서 설치한 ArgoCD가 담당한다. 이번 글에서는 나머지 세 가지 컴포넌트를 설치하고 구성한다.

## 1. Harbor 설치

Harbor는 CNCF가 호스팅하는 오픈소스 레지스트리 프로젝트로, 컨테이너 이미지와 Helm 차트를 저장하고 관리할 수 있는 기능을 제공한다. Docker Hub와 같은 퍼블릭 레지스트리에 의존하지 않고 완전히 자체 호스팅된 CI/CD 환경을 구축하기 위해 Harbor를 선택했다.

### Harbor 특징

-   RBAC(역할 기반 접근 제어)를 통한 세밀한 접근 권한 관리
-   취약점 스캐닝 기능으로 보안 강화
-   컨테이너 이미지와 Helm 차트를 함께 관리
-   프로젝트별 격리 및 할당량 관리
-   이미지 복제 및 미러링 기능

### GitOps 방식 Harbor 설치 준비

이전 글에서와 마찬가지로 GitOps 방식으로 Harbor를 설치한다. 먼저 Git 저장소에 Harbor 설치를 위한 디렉토리와 파일들을 생성한다:

```bash
mkdir -p k8s-resource/apps/harbor/templates
cd k8s-resource/apps/harbor
```

`Chart.yaml` 파일을 생성한다:

```yaml
apiVersion: v2
name: harbor
description: harbor chart for Kubernetes
type: application
version: 1.0.0
appVersion: "2.12.0"
dependencies:
    - name: harbor
      version: "1.16.0"
      repository: "https://helm.goharbor.io"
```

`values.yaml` 파일을 생성하여 Harbor 설정을 정의한다:

```yaml
harbor:
    expose:
        type: ClusterIP
        tls:
            enabled: false

    externalURL: "https://harbor.injunweb.com:443"

    harborAdminPassword: "<path:argocd/data/harbor#harborAdminPassword>"

    registry:
        relativeurls: true
        upload_purging:
            age: 12h
            interval: 12h

    persistence:
        persistentVolumeClaim:
            registry:
                size: 15Gi
```

위 설정에서 주목할 점은 `harborAdminPassword`에 Vault 참조가 사용되었다는 것이다. ArgoCD의 Vault 플러그인을 통해 실제 배포 시 이 값이 Vault에서 가져온 값으로 대체된다.

이제 Traefik IngressRoute를 만들어 Harbor UI에 접근할 수 있게 한다. `templates/ingressroute.yaml` 파일을 생성한다:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: harbor
    namespace: harbor
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - match: Host(`harbor.injunweb.com`) && PathPrefix(`/`)
          kind: Rule
          services:
              - name: harbor-portal
                namespace: harbor
                port: 80
          middlewares:
              - name: harbor-buffer
                namespace: harbor
        - match: Host(`harbor.injunweb.com`) && (PathPrefix(`/api/`) || PathPrefix(`/service/`) || PathPrefix(`/v2/`) || PathPrefix(`/chartrepo/`) || PathPrefix(`/c/`))
          kind: Rule
          services:
              - name: harbor-core
                namespace: harbor
                port: 80
          middlewares:
              - name: harbor-buffer
                namespace: harbor
```

여기서는 세부 경로별로 적절한 서비스(portal 또는 core)로 라우팅하도록 설정했다. 또한 대용량 이미지 업로드를 위한 미들웨어도 필요하다. `templates/middleware.yaml` 파일을 생성한다:

```yaml
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
    name: harbor-buffer
    namespace: harbor
spec:
    buffering:
        maxRequestBodyBytes: 1000000000
        memRequestBodyBytes: 1000000000
        retryExpression: ""
```

이 미들웨어는 대용량 파일 업로드를 처리하기 위한 버퍼 설정을 담당한다.

### 변경 사항 커밋 및 배포

변경 사항을 커밋하고 푸시한다:

```bash
git add .
git commit -m "Add Harbor configuration"
git push
```

이제 ArgoCD가 변경 사항을 감지하고 Harbor를 자동으로 배포할 것이다. 배포 상태는 다음 명령어로 확인할 수 있다:

```bash
kubectl get pods -n harbor
```

모든 Pod가 Ready 상태가 되면 Harbor가 성공적으로 배포된 것이다.

### Harbor UI 접속 및 구성

Harbor UI에 접속하기 위해 호스트 파일에 다음 항목을 추가한다:

```
192.168.0.200 harbor.injunweb.com
```

웹 브라우저에서 `https://harbor.injunweb.com`으로 접속한다. 로그인 정보는 다음과 같다:

-   사용자명: admin
-   비밀번호: Vault에서 가져온 비밀번호

로그인 후 다음과 같은 설정을 진행한다:

1. 새 프로젝트 생성:

    - 'Projects' > 'NEW PROJECT'
    - Name: injunweb
    - Access Level: Private

2. Docker CLI에서 로그인 테스트:

    ```bash
    docker login harbor.injunweb.com -u admin -p <비밀번호>
    ```

3. 테스트 이미지 푸시:
    ```bash
    docker pull nginx:alpine
    docker tag nginx:alpine harbor.injunweb.com/injunweb/nginx:alpine
    docker push harbor.injunweb.com/injunweb/nginx:alpine
    ```

이미지가 성공적으로 푸시되면 Harbor UI에서 이를 확인할 수 있다.

## 2. Argo Events 설치

Argo Events는 쿠버네티스 기반의 이벤트 중심 자동화 프레임워크다. 다양한 이벤트 소스(Git 웹훅, 메시지 큐, AWS SNS 등)의 이벤트를 감지하고, 그에 따른 워크플로우를 트리거할 수 있다.

### Argo Events 특징

-   선언적 설정을 통한 이벤트 중심 워크플로우
-   다양한 이벤트 소스 지원
-   확장 가능한 이벤트 필터링과 변환
-   다양한 트리거 대상 지원 (Argo Workflows, 쿠버네티스 리소스 등)

### GitOps 방식 Argo Events 설치 준비

Git 저장소에 Argo Events 설치를 위한 디렉토리와 파일들을 생성한다:

```bash
mkdir -p k8s-resource/apps/argo-events/templates
cd k8s-resource/apps/argo-events
```

`Chart.yaml` 파일을 생성한다:

```yaml
apiVersion: v2
name: argo-event
description: argo-event chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v1.9.3"
dependencies:
    - name: argo-events
      version: "2.4.9"
      repository: "https://argoproj.github.io/argo-helm"
```

`values.yaml` 파일은 기본 설정을 사용하므로 빈 파일로 생성한다. 필요한 경우에만 설정을 추가할 수 있다:

```yaml
# 기본 설정을 사용
```

### 변경 사항 커밋 및 배포

변경 사항을 커밋하고 푸시한다:

```bash
git add .
git commit -m "Add Argo Events configuration"
git push
```

배포 상태는 다음 명령어로 확인할 수 있다:

```bash
kubectl get pods -n argo-events
```

## 3. Argo Workflows 설치

Argo Workflows는 쿠버네티스 위에서 복잡한 컨테이너 기반 워크플로우를 정의하고 실행하기 위한 도구다. 빌드, 테스트, 배포와 같은 CI/CD 작업의 실행 엔진 역할을 한다.

### Argo Workflows 특징

-   DAG(Directed Acyclic Graph) 또는 단계별 워크플로우 정의
-   병렬 처리 및 아티팩트 공유
-   재시도 전략 및 타임아웃 설정
-   조건부 실행 및 반복 작업
-   유연한 템플릿 시스템

### GitOps 방식 Argo Workflows 설치 준비

Git 저장소에 Argo Workflows 설치를 위한 디렉토리와 파일들을 생성한다:

```bash
mkdir -p k8s-resource/apps/argo-workflows/templates
cd k8s-resource/apps/argo-workflows
```

`Chart.yaml` 파일을 생성한다:

```yaml
apiVersion: v2
name: argocd-workflow
description: argocd-workflow chart for Kubernetes
type: application
version: 1.0.0
appVersion: "v3.6.2"
dependencies:
    - name: argo-workflows
      version: "0.45.2"
      repository: "https://argoproj.github.io/argo-helm"
```

`values.yaml` 파일을 생성한다:

```yaml
argo-workflows:
    server:
        authMode: "server"
```

간단한 설정으로 시작하고, 필요에 따라 추가 설정을 할 수 있다.

Traefik IngressRoute를 만들어 Argo Workflows UI에 접근할 수 있게 한다. `templates/ingressroute.yaml` 파일을 생성한다:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: argo-workflows-server
    namespace: argo-workflows
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - kind: Rule
          match: Host(`argo-workflows.injunweb.com`)
          services:
              - name: argo-workflows-server
                port: 2746
```

### 변경 사항 커밋 및 배포

변경 사항을 커밋하고 푸시한다:

```bash
git add .
git commit -m "Add Argo Workflows configuration"
git push
```

배포 상태는 다음 명령어로 확인할 수 있다:

```bash
kubectl get pods -n argo-workflows
```

Argo Workflows UI에 접속하기 위해 호스트 파일에 다음 항목을 추가한다:

```
192.168.0.200 argo-workflows.injunweb.com
```

웹 브라우저에서 `https://argo-workflows.injunweb.com`으로 접속한다.

## 4. EventBus 및 기본 이벤트 소스 설정

Argo Events는 EventBus라는 컴포넌트를 사용하여 이벤트 소스와 센서 간의 통신을 관리한다. 이제 기본 EventBus 및 GitHub 웹훅을 위한 EventSource를 설정한다.

### EventBus 생성

`eventbus.yaml` 파일을 생성한다:

```yaml
apiVersion: argoproj.io/v1alpha1
kind: EventBus
metadata:
    name: default
    namespace: argo-events
spec:
    nats:
        native:
            replicas: 3
            auth: none
```

### GitHub EventSource 생성

GitHub 웹훅을 받기 위한 EventSource를 생성한다:

```bash
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: EventSource
metadata:
  name: github
  namespace: argo-events
spec:
  service:
    ports:
      - port: 12000
        targetPort: 12000
  github:
    example:
      repositories:
        - owner: injunweb
          names:
            - example-repo
      webhook:
        endpoint: /webhook
        port: "12000"
        method: POST
      events:
        - push
      apiToken:
        name: github-access
        key: token
      insecure: true
      active: true
      contentType: json
EOF
```

이제 EventBus와 EventSource의 상태를 확인할 수 있다:

```bash
kubectl get eventbus -n argo-events
kubectl get eventsource -n argo-events
```

## 5. 구성 요소 통합

이제 세 가지 핵심 구성 요소가 모두 설치되었다. 각 구성 요소의 역할을 정리하면 다음과 같다:

1. **Harbor**: 컨테이너 이미지를 안전하게 저장하고 관리한다.
2. **Argo Events**: GitHub 웹훅 등의 이벤트를 감지하고 처리한다.
3. **Argo Workflows**: 빌드, 테스트 등의 CI/CD 작업을 실행한다.
4. **ArgoCD**(이전에 설치): GitOps 방식으로 애플리케이션을 자동 배포한다.

이 네 가지 구성 요소를 통합하여 완전한 CI/CD 파이프라인을 구축하는 방법은 다음 글에서 자세히 다룰 것이다.

### 기본 테스트

구성 요소들이 정상적으로 작동하는지 간단히 테스트해보자.

#### Harbor에 이미지 푸시

```bash
docker pull nginx:alpine
docker tag nginx:alpine harbor.injunweb.com/injunweb/nginx:test
docker push harbor.injunweb.com/injunweb/nginx:test
```

#### Argo Workflows에서 간단한 워크플로우 실행

간단한 워크플로우 YAML 파일을 생성한다 (`hello-world.yaml`):

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Workflow
metadata:
    generateName: hello-world-
    namespace: argo-workflows
spec:
    entrypoint: whalesay
    templates:
        - name: whalesay
          container:
              image: docker/whalesay:latest
              command: [cowsay]
              args: ["Hello World!"]
```

워크플로우를 실행한다:

```bash
kubectl apply -f hello-world.yaml
```

Argo Workflows UI에서 실행 결과를 확인할 수 있다.

## 6. 다음 단계

이제 CI/CD 시스템의 기본 구성 요소가 설치되었지만, 이들을 효과적으로 통합하려면 몇 가지 추가 구성이 필요하다:

1. **Sensor 설정**: Argo Events의 EventSource에서 이벤트를 감지하고 Argo Workflows를 트리거하는 Sensor를 구성해야 한다.

2. **워크플로우 템플릿 생성**: 애플리케이션 빌드, 이미지 생성, 배포를 위한 재사용 가능한 워크플로우 템플릿을 만들어야 한다.

3. **GitOps 파이프라인 구성**: GitHub에서 코드 변경이 발생하면 자동으로 빌드하고 배포하는 전체 파이프라인을 구성해야 한다.

4. **보안 강화**: 시크릿 관리, 접근 제어 등의 보안 관련 설정을 추가해야 한다.

이러한 추가 구성은 다음 글에서 자세히 다룰 예정이다.

## 마치며

이번 글에서는 CI/CD 시스템의 핵심 구성 요소인 Harbor, Argo Events, Argo Workflows를 설치하고 기본 설정하는 방법을 알아보았다. 이 세 가지 구성 요소와 이전에 설치한 ArgoCD를 통합하면, 코드 변경에서부터 자동 배포까지 전체 과정을 자동화하는 완전한 CI/CD 파이프라인을 구축할 수 있다.

다음 글에서는 이 구성 요소들을 통합하여 실제로 작동하는 CI/CD 파이프라인을 구축하는 방법을 다룰 것이다.
