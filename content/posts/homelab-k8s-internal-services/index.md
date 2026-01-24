---
title: "미니PC Kubernetes #4: 내부 서비스 구성"
date: 2025-02-25T11:37:43+09:00
draft: false
description: "쿠버네티스 클러스터 내부 서비스 구성 방법을 다룬다."
tags: ["Kubernetes", "네트워크", "서비스"]
series: ["미니PC Kubernetes"]
---

## 개요

[이전 글](/posts/homelab-k8s-storage/)에서는 Longhorn 분산 스토리지 시스템을 설치하여 파드가 재시작되거나 다른 노드로 이동해도 데이터가 유지되는 영구 스토리지 환경을 구축했다. 이번 글에서는 홈랩 쿠버네티스 클러스터에 Traefik 인그레스 컨트롤러를 설치하고, 내부 네트워크에서 관리 인터페이스에 안전하게 접근할 수 있도록 구성하는 방법을 알아본다.

![Traefik Logo](image.png)

## 인그레스 컨트롤러 선택

홈랩 환경에서 쿠버네티스 서비스를 외부에 노출하는 방법은 여러 가지가 있다:

1. **NodePort**: 각 노드의 특정 포트(30000-32767 범위)를 통해 서비스에 접근하는 방식으로 설정이 간단하지만 포트 번호를 기억해야 하는 불편함이 있고, 표준 HTTP/HTTPS 포트를 사용할 수 없다.

2. **LoadBalancer**: MetalLB와 같은 로드밸런서 구현체를 사용하여 각 서비스에 전용 IP를 할당하는 방식으로 표준 포트를 사용할 수 있지만, 서비스마다 별도의 IP가 필요하여 IP 자원이 제한적인 홈랩 환경에서는 비효율적일 수 있다.

3. **Ingress**: HTTP/HTTPS 트래픽을 서비스로 라우팅하는 규칙을 정의하는 방식으로, URL 경로와 호스트 이름 기반 라우팅, SSL/TLS 종료, 인증 등 다양한 기능을 제공하여 하나의 IP로 여러 서비스를 노출할 수 있다.

인그레스 컨트롤러를 사용하면 단일 IP 주소와 표준 포트(80, 443)만으로 다수의 서비스를 호스트 이름이나 경로 기반으로 라우팅할 수 있어 홈랩 환경에서 가장 적합한 방법이다.

### Traefik을 선택한 이유

처음에는 쿠버네티스 생태계에서 가장 널리 사용되는 Nginx Ingress Controller를 설치했으나, Let's Encrypt 인증서 자동 발급을 위해 cert-manager를 별도로 설치하고 ClusterIssuer를 구성해야 했으며, 사용자 정의 헤더와 미들웨어 구성에서 여러 번 설정 오류를 경험했다.

> **Traefik이란?**
>
> Traefik은 Containous(현재 Traefik Labs)에서 2015년에 개발을 시작한 클라우드 네이티브 리버스 프록시 및 로드밸런서로, 마이크로서비스 환경과 쿠버네티스에 최적화되어 있으며 동적 설정 변경과 Let's Encrypt 통합을 기본으로 지원하여 컨테이너 오케스트레이션 환경에서 널리 사용된다.

결국 더 통합된 솔루션을 찾게 되었고, Traefik은 필요한 모든 기능이 단일 패키지로 제공되어 선택하게 되었으며 다음과 같은 장점이 있다:

- **설정의 단순함**: Let's Encrypt ACME 프로토콜이 기본으로 내장되어 있어 별도의 cert-manager 없이 인증서 자동 발급과 갱신이 가능하다.
- **대시보드 기능**: 현재 라우팅 상태, 서비스 상태, 미들웨어 구성 등을 시각적으로 확인할 수 있는 웹 대시보드가 내장되어 있다.
- **Helm 차트 지원**: 공식 Helm 차트가 제공되어 GitOps 방식으로 선언적 배포가 용이하다.
- **CRD 지원**: IngressRoute, Middleware 등의 CRD(Custom Resource Definition)를 통해 표준 Ingress보다 세밀한 라우팅 규칙과 트래픽 제어가 가능하다.
- **미들웨어 기능**: 요청/응답 변환, Basic/Digest 인증, 재시도, 속도 제한 등 다양한 미들웨어를 선언적으로 구성할 수 있다.

## 내부와 외부 서비스 분리

홈랩 환경에서 보안은 매우 중요한 고려사항이며, ArgoCD, Longhorn 대시보드, Traefik 대시보드 같은 클러스터 관리 인터페이스가 외부 인터넷에 노출되면 보안 위협에 직접 노출될 수 있다. 이를 방지하기 위해 내부 관리용 서비스와 외부 공개용 서비스를 서로 다른 IP 주소로 분리하는 전략을 사용한다.

![Network Separation](image-1.png)

1. **내부용 로드밸런서(192.168.0.200)**: ArgoCD, Longhorn, Traefik 대시보드 같은 관리 인터페이스만 노출하며, 홈 네트워크 내부에서만 접근 가능하고 라우터의 포트 포워딩 대상에서 제외한다.

2. **외부용 로드밸런서(192.168.0.201)**: 블로그, 개인 프로젝트 등 공개 서비스만 노출하며, 라우터에서 포트 포워딩을 설정하여 외부 인터넷에서 접근 가능하도록 구성한다.

이 설계는 서비스 수준에서 분리가 이루어져 실수로 관리 인터페이스의 IngressRoute를 외부 엔트리포인트에 연결하더라도 해당 IP 자체가 외부에서 라우팅되지 않으므로 보안 사고를 예방할 수 있다. 다만 이 설정은 완전한 네트워크 격리가 아닌 서비스 레벨 분리라는 점을 유의해야 한다.

## Traefik 설치 준비

### 1. MetalLB IP 주소 풀 구성

Traefik을 배포하기 전에 먼저 내부/외부 서비스 분리를 위한 IP 주소 풀을 MetalLB에 구성해야 하며, [GitHub 저장소](https://github.com/injunweb/k8s-resources)에 다음 설정 파일들을 생성한다.

`apps/traefik/templates/ipaddresspool.yaml` 파일:

```yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
    name: traefik-ip-pool
    namespace: metallb-system
spec:
    addresses:
        - 192.168.0.200-192.168.0.201
```

이 매니페스트는 MetalLB가 LoadBalancer 타입 서비스에 할당할 수 있는 IP 주소 풀을 정의하며, 내부용(192.168.0.200)과 외부용(192.168.0.201) 두 개의 IP를 포함한다. 이 IP 주소들은 홈 네트워크의 DHCP 서버 할당 범위에서 제외하여 IP 충돌을 방지해야 한다.

`apps/traefik/templates/l2advertisement.yaml` 파일:

```yaml
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
    name: traefik-l2-advertisement
    namespace: metallb-system
spec:
    ipAddressPools:
        - traefik-ip-pool
```

이 매니페스트는 MetalLB의 Layer 2 모드 광고 설정을 정의하며, 정의된 IP 주소 풀의 IP가 ARP 프로토콜을 통해 네트워크에 광고되어 트래픽이 올바른 노드로 라우팅될 수 있게 한다.

### 2. Helm 차트 구성

`apps/traefik/Chart.yaml` 파일:

```yaml
apiVersion: v2
name: traefik
description: Traefik Ingress Controller for Kubernetes
type: application
version: 1.0.0
appVersion: "v3.2.2"
dependencies:
    - name: traefik
      version: "33.2.1"
      repository: "https://traefik.github.io/charts"
```

이 파일은 Traefik 공식 Helm 차트 저장소에서 v33.2.1 버전 차트를 가져와 설치하도록 정의한다.

`apps/traefik/values.yaml` 파일에는 Traefik의 상세 설정이 포함되며, 주요 설정을 살펴본다.

#### 내부/외부 엔트리포인트 설정

```yaml
ports:
    web:
        port: 8000
        expose:
            default: true
            internal: false
        exposedPort: 80
        protocol: TCP
    websecure:
        port: 8443
        expose:
            default: true
            internal: false
        exposedPort: 443
        protocol: TCP
        tls:
            enabled: true
            certResolver: "letsencrypt"
    intweb:
        port: 8001
        expose:
            default: false
            internal: true
        exposedPort: 80
        protocol: TCP
    intwebsec:
        port: 8444
        expose:
            default: false
            internal: true
        exposedPort: 443
        protocol: TCP
        tls:
            enabled: true
            certResolver: "letsencrypt"
```

여기서 `web`과 `websecure`는 외부용 엔트리포인트로 외부 로드밸런서(192.168.0.201)를 통해 노출되고, `intweb`과 `intwebsec`는 내부용 엔트리포인트로 내부 로드밸런서(192.168.0.200)를 통해서만 접근 가능하다. 각 엔트리포인트는 내부적으로 다른 포트를 사용하지만 외부에는 표준 HTTP(80)와 HTTPS(443) 포트로 노출된다.

#### Let's Encrypt 설정

```yaml
certificatesResolvers:
    letsencrypt:
        acme:
            email: your-email@example.com
            httpChallenge:
                entryPoint: web
            storage: /data/acme.json
```

이 설정은 Let's Encrypt ACME 프로토콜을 사용하여 SSL/TLS 인증서를 자동으로 발급하고 갱신하도록 구성하며, HTTP-01 챌린지 방식은 도메인에 대한 제어권을 증명하기 위해 `web` 엔트리포인트로 들어오는 HTTP 요청을 사용한다. 인증서 발급은 다음 글에서 다룰 외부 접근 설정이 완료된 이후에 정상적으로 동작한다.

#### 내부/외부 서비스 분리

```yaml
service:
    enabled: true
    single: true
    type: LoadBalancer
    annotations:
        metallb.universe.tf/loadBalancerIPs: 192.168.0.201
    additionalServices:
        internal:
            type: LoadBalancer
            annotations:
                metallb.universe.tf/loadBalancerIPs: 192.168.0.200
            labels:
                traefik-service-type: internal
```

이 설정은 두 개의 별도 LoadBalancer 서비스를 생성한다:

1. **기본 서비스(traefik)**: IP 주소 192.168.0.201을 할당받아 외부에서 접근 가능한 공개 서비스용 트래픽을 처리한다.
2. **내부 서비스(traefik-internal)**: IP 주소 192.168.0.200을 할당받아 내부 네트워크에서만 접근 가능한 관리 인터페이스용 트래픽을 처리한다.

`metallb.universe.tf/loadBalancerIPs` 어노테이션은 MetalLB에게 특정 IP 주소를 해당 서비스에 할당하도록 지시한다.

#### 인증서 저장을 위한 영구 볼륨 설정

```yaml
deployment:
    initContainers:
        - name: volume-permissions
          image: busybox:1.36
          command:
              [
                  "sh",
                  "-c",
                  "touch /data/acme.json; chmod -v 600 /data/acme.json; adduser -S 65532 65532; chown -R 65532:65532 /data/acme.json",
              ]
          volumeMounts:
              - name: data
                mountPath: /data

persistence:
    enabled: true
    accessMode: ReadWriteOnce
    size: 128Mi
    storageClass: longhorn

podSecurityContext:
    fsGroup: 65532
    fsGroupChangePolicy: "OnRootMismatch"
    runAsGroup: 65532
    runAsNonRoot: true
    runAsUser: 65532
```

이 설정은 Let's Encrypt 인증서를 저장하기 위한 영구 볼륨을 Longhorn 스토리지 클래스를 사용하여 구성하며, 초기화 컨테이너(initContainer)가 ACME 인증서 파일에 적절한 권한(600)과 소유권을 설정하여 Traefik이 인증서를 안전하게 저장하고 관리할 수 있도록 한다. 파드가 재시작되거나 다른 노드로 이동해도 인증서가 유지된다.

### 3. GitOps로 배포하기

설정 파일을 Git 저장소에 커밋하고 푸시하면 ArgoCD가 자동으로 변경사항을 감지하여 클러스터에 배포한다:

```bash
git add apps/traefik
git commit -m "Add Traefik ingress controller with internal/external separation"
git push origin main
```

배포가 완료되었는지 확인한다:

```bash
kubectl get pods -n traefik
```

Traefik 파드가 Running 상태로 표시되면 정상이다:

```
NAME                       READY   STATUS    RESTARTS   AGE
traefik-5d7b9b4f6c-xtz89   1/1     Running   0          5m
```

두 개의 LoadBalancer 서비스가 생성되었는지 확인한다:

```bash
kubectl get svc -n traefik
```

```
NAME               TYPE           CLUSTER-IP      EXTERNAL-IP     PORT(S)                      AGE
traefik            LoadBalancer   10.43.xxx.xxx   192.168.0.201   80:xxxxx/TCP,443:xxxxx/TCP   5m
traefik-internal   LoadBalancer   10.43.xxx.xxx   192.168.0.200   80:xxxxx/TCP,443:xxxxx/TCP   5m
```

## 내부 서비스 접근 구성

Traefik이 설치되었으니 이제 ArgoCD, Longhorn, Traefik 대시보드 같은 내부 관리 인터페이스에 접근할 수 있도록 IngressRoute를 구성한다. 이 라우트들은 내부 엔트리포인트(`intweb`, `intwebsec`)를 사용하여 내부 네트워크에서만 접근 가능하도록 설정한다.

### 1. 내부 서비스 라우팅 구성

ArgoCD 접근을 위한 `apps/argocd/templates/ingressroute.yaml` 파일:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: argocd-server-internal
    namespace: argocd
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - match: Host(`argocd.injunweb.com`)
          kind: Rule
          services:
              - name: argocd-server
                port: 80
```

이 매니페스트는 `argocd.injunweb.com` 호스트에 대한 요청을 내부 엔트리포인트를 통해 ArgoCD 서버 서비스의 80 포트로 라우팅한다.

Longhorn UI를 위한 `apps/longhorn-system/templates/ingressroute.yaml` 파일:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: longhorn-frontend-internal
    namespace: longhorn-system
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - match: Host(`longhorn.injunweb.com`)
          kind: Rule
          services:
              - name: longhorn-frontend
                port: 80
```

이 매니페스트는 `longhorn.injunweb.com` 호스트에 대한 요청을 내부 엔트리포인트를 통해 Longhorn 프론트엔드 서비스로 라우팅한다.

Traefik 대시보드는 Helm 차트의 `values.yaml`에서 직접 구성했다:

```yaml
ingressRoute:
    dashboard:
        enabled: true
        matchRule: Host(`traefik.injunweb.com`) && (PathPrefix(`/dashboard`) || PathPrefix(`/api`))
        services:
            - name: api@internal
              kind: TraefikService
        entryPoints: ["intweb", "intwebsec"]
```

이 설정은 `traefik.injunweb.com/dashboard` 경로를 통해 Traefik 내부 API 서비스(`api@internal`)에 접근하여 대시보드를 사용할 수 있도록 한다.

생성한 매니페스트 파일들을 Git 저장소에 추가한다:

```bash
git add apps/argocd/templates/ingressroute.yaml
git add apps/longhorn-system/templates/ingressroute.yaml
git commit -m "Add internal IngressRoutes for admin interfaces"
git push origin main
```

### 2. 로컬 호스트 파일 설정

내부 서비스에 도메인 이름으로 접근하기 위해 로컬 컴퓨터의 호스트 파일을 수정한다.

**Linux/macOS**:

```bash
sudo vim /etc/hosts
```

**Windows** (관리자 권한 필요):

```
C:\Windows\System32\drivers\etc\hosts
```

호스트 파일에 다음 라인을 추가한다:

```
192.168.0.200 traefik.injunweb.com argocd.injunweb.com longhorn.injunweb.com
```

이 설정은 해당 도메인 이름을 내부 로드밸런서 IP(192.168.0.200)로 해석하도록 하여 DNS 서버를 거치지 않고 직접 내부 서비스에 접근할 수 있게 한다.

## 접근 테스트

모든 구성이 완료되었으니 내부 네트워크에서 각 서비스에 접근이 가능한지 테스트한다.

웹 브라우저에서 다음 URL로 접속하여 각 서비스가 정상적으로 표시되는지 확인한다:

- `http://traefik.injunweb.com/dashboard/` - Traefik 대시보드
- `http://argocd.injunweb.com` - ArgoCD UI
- `http://longhorn.injunweb.com` - Longhorn UI

모든 서비스가 정상적으로 접근 가능하면 내부 서비스 구성이 완료된 것이다. 현재 상태에서는 이 서비스들이 내부 IP(192.168.0.200)에만 연결되어 있으므로 외부 인터넷에서는 접근이 불가능하다.

## 마치며

이번 글에서는 홈랩 쿠버네티스 클러스터에 Traefik 인그레스 컨트롤러를 설치하고, 내부와 외부 서비스를 분리하여 관리 인터페이스를 안전하게 접근할 수 있도록 구성하는 방법을 살펴보았다. MetalLB의 IP 주소 풀을 활용하여 내부용과 외부용 로드밸런서를 분리함으로써 관리 인터페이스가 외부에 노출되는 것을 방지할 수 있다.

다음 글에서는 외부용 로드밸런서를 활용하여 홈랩 서비스를 외부 인터넷에서 접근할 수 있도록 DDNS와 포트 포워딩을 구성하는 방법을 알아본다.

[다음 글: 미니PC Kubernetes #5: 외부 접근 설정](/posts/homelab-k8s-external-access/)
