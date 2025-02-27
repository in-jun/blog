---
title: "홈랩 쿠버네티스 시크릿 관리하기"
date: 2025-02-26T16:20:14+09:00
draft: false
description: "홈랩 쿠버네티스 환경에 HashiCorp Vault를 설치하고 안전한 시크릿 관리 시스템을 구축하는 방법을 설명한다."
tags: ["kubernetes", "homelab", "vault", "secrets", "gitops", "security"]
series: ["홈랩 쿠버네티스"]
---

## 개요

이전 글에서는 홈랩 쿠버네티스 클러스터에 Traefik 인그레스 컨트롤러를 설치하고 외부 접근을 구성했다. 이번 글에서는 쿠버네티스 클러스터에서 민감한 정보(비밀번호, API 키, 인증서 등)를 안전하게 관리하기 위한 HashiCorp Vault 설치와 구성 방법을 다룬다.

![Vault Logo](image.png)

## 왜 기본 쿠버네티스 시크릿으로는 부족했나?

GitOps 방식으로 홈랩 환경을 구성하면서 시크릿 관리가 난제였다. 기본 쿠버네티스 Secret을 사용해보니 몇 가지 한계가 명확했다.

첫째, GitOps와의 통합 문제다. Git에 시크릿을 그대로 저장할 수 없고, base64로 인코딩해도 쉽게 복원 가능해 보안에 취약하다. Sealed Secrets나 SOPS 같은 도구도 검토했으나 단순 암호화를 넘어선 종합적인 시크릿 관리 솔루션이 필요했다.

둘째, 시크릿 갱신 문제다. 외부 API 토큰이나 인증서는 주기적으로 갱신이 필요한데, 매번 수동으로 처리하는 건 비효율적이다. 자동화된 방식의 시크릿 로테이션 관리가 필요했다.

HashiCorp Vault는 이런 문제들을 해결해주는 솔루션이다. 시크릿 암호화, 접근 제어, 자동 갱신 기능과 함께 쿠버네티스와의 통합도 지원한다. GitOps 워크플로우에 통합할 수 있는 방법도 제공해 선택하게 되었다.

## 홈랩 환경에 Vault 설치하기

### 1. GitOps 구성을 위한 디렉토리 준비

홈랩 환경의 모든 것을 GitOps로 관리하므로 Vault 설치도 같은 방식으로 진행했다. 먼저 필요한 디렉토리 구조를 생성한다.

```bash
mkdir -p k8s-resources/apps/vault/templates
cd k8s-resources/apps/vault
```

### 2. Helm 차트 구성

`Chart.yaml` 파일을 다음과 같이 작성했다.

```yaml
apiVersion: v2
name: vault
description: HashiCorp Vault installation
type: application
version: 1.0.0
appVersion: "1.15.2"
dependencies:
    - name: vault
      version: "0.27.0"
      repository: "https://helm.releases.hashicorp.com"
```

`values.yaml` 파일에는 Vault 설정을 추가했다.

```yaml
vault:
    server:
        enabled: true

    ui:
        enabled: true # 웹 기반 관리 UI 활성화
```

고가용성 설정도 고려했으나, 홈랩 환경에서는 자원 낭비라고 판단해 간소화했다. 필요시 후에 업그레이드하는 방식으로 접근했다.

### 3. 인그레스 구성

Vault UI에 접근하기 위한 인그레스 라우트를 구성했다. 이전에 설정한 Traefik 인그레스 컨트롤러를 활용했다.

`templates/ingressroute.yaml` 파일:

```yaml
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: vault-ui
    namespace: vault
spec:
    entryPoints:
        - intweb
        - intwebsec
    routes:
        - kind: Rule
          match: Host(`vault.injunweb.com`)
          services:
              - name: vault-ui
                port: 8200
```

`entryPoints`를 `intweb`과 `intwebsec`로 설정해 Vault UI는 내부 네트워크에서만 접근 가능하도록 했다. 시크릿 관리 인터페이스인 만큼 외부 노출은 보안 위험이기 때문이다.

### 4. GitHub에 변경사항 추가 및 ArgoCD로 배포

```bash
git add .
git commit -m "Add Vault Helm chart configuration"
git push origin main
```

## Vault 초기화 및 언실링

Vault 설치 후에는 두 가지 중요한 단계가 필요하다: 초기화와 언실링. 이 과정은 암호화 키 생성과 활성화 과정으로, 보안을 위해 자동화하지 않고 수동으로 진행한다.

### 1. 초기화 수행

Vault 파드에 접속하여 초기화를 수행한다.

```bash
# Vault 서버에 접속
kubectl -n vault exec -it vault-0 -- /bin/sh

# 초기화 수행 (기본 5개 키, 3개 필요)
vault operator init
```

실행 결과:

```
Unseal Key 1: wO14Gu9jIfGtae33/8U3l9mFv9QERnQS/IMoA1jJZ0vF
Unseal Key 2: FfL8J4QoIP/7fRrKJ7NN/5W8zG2ODzL9MiCJV5UcQmjx
Unseal Key 3: IgNkd4APfXmJywTqh+JjWbkiVgEHBTS+wjUGy/mtQ1pL
Unseal Key 4: +3Q0TUmCtw91/TNjdg7+dIh/8tHmfkoMykMTB9BPkMKn
Unseal Key 5: tJGLuUEYjpXc+K2jjxnMZ2JW7BUQ0KVYq7pGGBhEFLvG

Initial Root Token: hvs.6xu4j8TSoFBJ3EFNpW791e0I
```

> **주의**: 이 키들은 예시일 뿐이며, 실제 환경에서는 절대로 이런 정보를 공개해서는 안 된다. 패스워드 관리자에 안전하게 저장해야 한다.

### 2. 언실링 수행

초기화 후에는 언실링 과정이 필요하다. 5개 중 3개의 키를 사용하여 Vault를 언실링한다.

```bash
# 언실링 수행 (3개 키 필요)
vault operator unseal wO14Gu9jIfGtae33/8U3l9mFv9QERnQS/IMoA1jJZ0vF
vault operator unseal FfL8J4QoIP/7fRrKJ7NN/5W8zG2ODzL9MiCJV5UcQmjx
vault operator unseal IgNkd4APfXmJywTqh+JjWbkiVgEHBTS+wjUGy/mtQ1pL
```

세 번째 키를 입력하면 Vault가 활성화된다. 상태 확인:

```bash
vault status
```

```
Key             Value
---             -----
Seal Type       shamir
Initialized     true
Sealed          false
Total Shares    5
Threshold       3
...
```

`Sealed: false` 표시는 정상적으로 언실링되었음을 의미한다.

Shamir의 비밀 공유 알고리즘을 활용하는 점이 주목할 만하다. 기업 환경에서는 이 5개의 키를 서로 다른 관리자에게 분산시켜, 최소 3명이 동의해야만 Vault를 열 수 있게 하는 4-eyes principle을 구현한다. 홈랩에서는 한 사람이 관리하지만, 엔터프라이즈 보안 원칙을 경험해볼 수 있는 부분이다.

## Vault 웹 UI 접근

Vault가 활성화되면 웹 UI를 통해 관리할 수 있다. 호스트 파일에 다음 항목을 추가한다.

```
192.168.0.200 vault.injunweb.com
```

브라우저에서 `http://vault.injunweb.com`으로 접속하면 Vault UI를 볼 수 있다. 로그인에는 초기화 과정에서 받은 루트 토큰을 사용한다.

![Vault UI Login](image-1.png)

로그인 후 표시되는 대시보드:

![Vault Dashboard](image-2.png)

UI는 직관적으로 구성되어 있어 복잡한 정책 설정이나 시크릿 관리 작업도 효율적으로 수행할 수 있다.

## Vault 기본 설정하기

Vault 설치와 초기화가 완료되었으면 쿠버네티스와의 통합을 위한 기본 설정을 진행한다.

### 1. 쿠버네티스 인증 설정

쿠버네티스 인증 방식을 사용하면 파드가 자신의 서비스 계정 토큰으로 Vault에 인증할 수 있다. Vault 파드에 접속하여 다음 명령을 실행한다.

```bash
# Vault 로그인 (루트 토큰 사용)
vault login hvs.6xu4j8TSoFBJ3EFNpW791e0I

# Kubernetes 인증 활성화
vault auth enable kubernetes

# Kubernetes 인증 구성
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_ca_cert="$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)" \
  issuer="https://kubernetes.default.svc.cluster.local"
```

이 설정은 Vault가 쿠버네티스 서비스 계정 토큰의 유효성을 검증할 수 있게 해준다.

### 2. KV 시크릿 엔진 활성화

Key-Value(KV) 엔진은 가장 기본적인 시크릿 저장 방식이다. 버전 2 엔진을 활성화한다.

```bash
vault secrets enable -path=secret kv-v2
```

KV 버전 2는 시크릿 버전 관리, 소프트 삭제 등 유용한 기능을 제공한다.

### 3. 정책 및 역할 생성

Vault에서 접근 제어의 핵심은 정책(Policy)이다. 애플리케이션에서 사용할 샘플 정책을 생성한다.

```bash
# 샘플 정책 생성
cat <<EOF > app-policy.hcl
# app/* 경로의 모든 시크릿에 대한 읽기 권한
path "secret/data/app/*" {
  capabilities = ["read"]
}

# app/* 경로의 메타데이터 읽기 권한
path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}
EOF

# 정책 등록
vault policy write app-policy app-policy.hcl
```

그리고 쿠버네티스 인증을 위한 역할을 생성한다.

```bash
# Kubernetes 인증 역할 생성
vault write auth/kubernetes/role/app \
  bound_service_account_names=app \
  bound_service_account_namespaces=default \
  policies=app-policy \
  ttl=1h
```

이 설정은 `default` 네임스페이스의 `app` 서비스 계정이 Vault에 인증할 때 `app-policy` 정책이 적용되며, 토큰은 1시간 후 만료됨을 의미한다.

### 4. 샘플 시크릿 생성

테스트를 위한 샘플 시크릿을 생성한다.

```bash
# KV 버전 2 시크릿 생성
vault kv put secret/app/config \
  db.username="dbuser" \
  db.password="supersecret" \
  api.key="api12345"

# 생성한 시크릿 확인
vault kv get secret/app/config
```

시크릿 확인 결과:

```
====== Metadata ======
Key              Value
---              -----
created_time     2025-02-26T07:45:22.123456789Z
deletion_time    n/a
destroyed        false
version          1

====== Data ======
Key            Value
---            -----
api.key        api12345
db.password    supersecret
db.username    dbuser
```

이제 Vault에 기본적인 시크릿이 저장되었다. 다음으로 이 시크릿을 쿠버네티스 애플리케이션에서 사용할 수 있는 방법 두 가지를 구현해본다.

## Vault Secrets Operator 설치하기

첫 번째 접근법은 Vault Secrets Operator를 사용하는 것이다. 이 Operator는 Vault의 시크릿을 쿠버네티스 Secret으로 자동 동기화해준다. 기존 애플리케이션 코드 변경 없이 Vault 시크릿을 활용할 수 있는 장점이 있다.

### 1. Operator 설정 추가

`k8s-resources/apps/vault-secrets-operator/Chart.yaml` 파일:

```yaml
apiVersion: v2
name: vault-secrets-operator
description: Vault Secrets Operator installation
type: application
version: 1.0.0
appVersion: "0.4.1"
dependencies:
    - name: vault-secrets-operator
      version: "0.3.4"
      repository: "https://helm.releases.hashicorp.com"
```

`k8s-resources/apps/vault-secrets-operator/values.yaml` 파일:

```yaml
vault-secrets-operator:
    defaultVaultConnection:
        enabled: true
        address: "http://vault.vault.svc.cluster.local:8200" # 클러스터 내부 Vault 주소
```

이 설정은 Operator가 Vault에 접근할 수 있는 기본 정보를 제공한다.

### 2. Operator용 Vault 역할 생성

Vault에 접속하여 Operator용 정책과 역할을 생성한다.

```bash
# 정책 파일 생성
cat <<EOF > operator-policy.hcl
# app/* 경로의 시크릿 읽기 권한
path "secret/data/app/*" {
  capabilities = ["read"]
}

# app/* 경로의 메타데이터 읽기 권한
path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}
EOF

# 정책 등록
vault policy write operator-policy operator-policy.hcl

# 역할 생성
vault write auth/kubernetes/role/vault-secrets-operator \
  bound_service_account_names=vault-secrets-operator \
  bound_service_account_namespaces=vault-secrets-operator \
  policies=operator-policy \
  ttl=1h
```

### 3. Git에 추가 및 배포

```bash
cd k8s-resources
git add apps/vault-secrets-operator
git commit -m "Add Vault Secrets Operator configuration"
git push origin main
```

배포 후 확인:

```bash
kubectl get pods -n vault-secrets-operator
```

결과:

```
NAME                                      READY   STATUS    RESTARTS   AGE
vault-secrets-operator-75bcd5b69d-x2jf9   2/2     Running   0          45s
```

## 시크릿 동기화 리소스 구성하기

Vault Secrets Operator를 통해 Vault의 시크릿을 쿠버네티스 Secret으로 동기화하는 설정을 한다.

### 1. VaultAuth 리소스 생성

`VaultAuth` 리소스는 Vault에 인증하는 방법을 정의한다.

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
    name: default
    namespace: default
spec:
    method: kubernetes # 인증 방식 (쿠버네티스)
    mount: kubernetes # Vault 인증 마운트 경로
    kubernetes:
        role: vault-secrets-operator # Vault 쿠버네티스 인증 역할
        serviceAccount: default # 사용할 서비스 계정
```

### 2. VaultStaticSecret 리소스 생성

`VaultStaticSecret` 리소스는 Vault의 특정 시크릿을 쿠버네티스 Secret으로 동기화하도록 지정한다.

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
    name: app-config
    namespace: default
spec:
    type: kv-v2 # 시크릿 엔진 타입
    mount: secret # 시크릿 엔진 마운트 경로
    path: app/config # Vault 시크릿 경로
    destination:
        name: app-config # 생성할 쿠버네티스 Secret 이름
        create: true # Secret이 없으면 생성
    refreshAfter: 30s # 30초마다 동기화
    vaultAuthRef: default # 사용할 VaultAuth 리소스
```

`refreshAfter: 30s` 설정은 Vault에서 시크릿이 변경될 때 30초 내에 쿠버네티스 Secret도 자동으로 업데이트되도록 한다.

### 3. 배포 및 확인

```bash
kubectl apply -f vault-auth.yaml
kubectl apply -f static-secret.yaml
```

Secret 생성 확인:

```bash
kubectl get secret app-config
```

결과:

```
NAME        TYPE     DATA   AGE
app-config  Opaque   3      15s
```

시크릿 내용 확인:

```bash
kubectl get secret app-config -o jsonpath="{.data.db\.password}" | base64 -d
```

### 4. 시크릿 자동 갱신 테스트

Vault에서 시크릿을 변경했을 때 자동으로 쿠버네티스 Secret이 업데이트되는지 확인:

```bash
# Vault에서 시크릿 변경
vault kv put secret/app/config \
  db.username="dbuser" \
  db.password="newpassword" \
  api.key="newapi12345"

# 30초 후 쿠버네티스 Secret 확인
kubectl get secret app-config -o jsonpath="{.data.db\.password}" | base64 -d
```

결과가 `newpassword`로 변경되면 자동 갱신이 정상 작동하는 것이다.

## ArgoCD Vault Plugin 설치하기

두 번째 접근법은 ArgoCD Vault Plugin을 구성하는 것이다. 이 플러그인은 GitOps 워크플로우에 깊게 통합되어, Git 저장소에는 시크릿 참조만 저장하고 ArgoCD가 배포할 때 실제 값으로 대체한다.

### 1. ArgoCD Helm 차트 값 파일 수정

`k8s-resources/apps/argocd/values.yaml` 파일에 다음 내용을 추가한다:

```yaml
argo-cd:
    configs:
        params:
            server.disable.auth: true
            server.insecure: true
    server:
        extraArgs:
            - --insecure
        ingress:
            enabled: false
        ingressGrpc:
            enabled: false

    repoServer:
        rbac:
            - verbs: ["get", "list", "watch"]
              apiGroups: [""]
              resources: ["secrets", "configmaps"]

        initContainers:
            - name: download-tools
              image: alpine/curl
              env:
                  - name: AVP_VERSION
                    value: "1.18.1"
              command: [sh, -c]
              args:
                  - >-
                      curl -L https://github.com/argoproj-labs/argocd-vault-plugin/releases/download/v$(AVP_VERSION)/argocd-vault-plugin_$(AVP_VERSION)_linux_amd64 -o argocd-vault-plugin &&
                      chmod +x argocd-vault-plugin &&
                      mv argocd-vault-plugin /custom-tools/
              volumeMounts:
                  - mountPath: /custom-tools
                    name: custom-tools

        extraContainers:
            - name: avp-helm
              command: ["/var/run/argocd/argocd-cmp-server"]
              image: quay.io/argoproj/argocd:v2.13.2
              securityContext:
                  runAsNonRoot: true
                  runAsUser: 999
              volumeMounts:
                  - mountPath: /var/run/argocd
                    name: var-files
                  - mountPath: /home/argocd/cmp-server/plugins
                    name: plugins
                  - mountPath: /tmp
                    name: tmp-dir
                  - mountPath: /home/argocd/cmp-server/config
                    name: cmp-plugin
                  - name: custom-tools
                    subPath: argocd-vault-plugin
                    mountPath: /usr/local/bin/argocd-vault-plugin
        volumes:
            - configMap:
                  name: cmp-plugin
              name: cmp-plugin
            - name: custom-tools
              emptyDir: {}
            - name: tmp-dir
              emptyDir: {}
```

이 설정은 ArgoCD Repo Server에 사이드카 컨테이너를 추가하고 플러그인 바이너리를 설치하는 과정이다.

### 2. ArgoCD용 Vault 역할 생성

Vault에 접속하여 ArgoCD용 정책과 역할을 생성한다:

```bash
# ArgoCD 정책 생성
cat <<EOF > argocd-policy.hcl
# app/* 경로의 시크릿 읽기 권한
path "secret/data/app/*" {
  capabilities = ["read"]
}

# app/* 경로의 메타데이터 읽기 권한
path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}
EOF

# 정책 등록
vault policy write argocd argocd-policy.hcl

# Kubernetes 인증 역할 생성
vault write auth/kubernetes/role/argocd \
  bound_service_account_names=argocd-repo-server \
  bound_service_account_namespaces=argocd \
  policies=argocd \
  ttl=1h
```

### 3. 인증 시크릿 생성

`k8s-resources/apps/argocd/templates/avp-secret.yaml` 파일을 생성한다:

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: argocd-vault-plugin-credentials
    namespace: argocd
type: Opaque
stringData:
    AVP_AUTH_TYPE: "k8s" # 쿠버네티스 인증 방식
    AVP_K8S_ROLE: "argocd" # Vault 역할 이름
    AVP_TYPE: "vault" # Vault 타입
    VAULT_ADDR: "http://vault.vault.svc.cluster.local:8200" # Vault 주소
```

### 4. ConfigMap 생성

`k8s-resources/apps/argocd/templates/configmap.yaml` 파일:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
    name: cmp-plugin
    namespace: argocd
data:
    plugin.yaml: |
        apiVersion: argoproj.io/v1alpha1
        kind: ConfigManagementPlugin
        metadata:
          name: argocd-vault-plugin-helm
        spec:
          allowConcurrency: true
          discover:
            find:
              command:
                - sh
                - "-c"
                - "find . -name 'Chart.yaml' && find . -name 'values.yaml'"
          init:
            command:
              - bash
              - "-c"
              - |
                helm repo add bitnami https://charts.bitnami.com/bitnami
                helm dependency build
          generate:
            command:
              - sh
              - "-c"
              - |
                helm template $ARGOCD_APP_NAME -n $ARGOCD_APP_NAMESPACE ${ARGOCD_ENV_HELM_ARGS} . --include-crds |
                argocd-vault-plugin generate -s argocd:argocd-vault-plugin-credentials -
          lockRepo: false
```

## 애플리케이션에서 시크릿 활용하기

이제 두 가지 방법으로 Vault 시크릿을 애플리케이션에서 사용할 수 있다.

### 1. Vault Secrets Operator로 동기화된 Secret 사용

간단한 테스트 Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: demo-app
    namespace: default
spec:
    replicas: 1
    selector:
        matchLabels:
            app: demo-app
    template:
        metadata:
            labels:
                app: demo-app
        spec:
            containers:
                - name: demo-app
                  image: nginx:alpine
                  env:
                      - name: DB_PASSWORD
                        valueFrom:
                            secretKeyRef:
                                name: app-config # Operator가 동기화한 Secret
                                key: db.password
```

이 방식의 장점은 기존 애플리케이션 코드를 전혀 수정할 필요가 없다는 것이다. 표준 쿠버네티스 Secret 참조 방식을 그대로 사용한다.

```bash
kubectl apply -f demo-app.yaml
```

### 2. ArgoCD Vault Plugin으로 대체되는 시크릿 사용

플러그인 참조를 사용하는 Deployment:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: demo-app-avp
    namespace: default
    annotations:
        avp.kubernetes.io/path: "secret/data/app/config" # Vault 경로
spec:
    replicas: 1
    selector:
        matchLabels:
            app: demo-app-avp
    template:
        metadata:
            labels:
                app: demo-app-avp
        spec:
            containers:
                - name: demo-app
                  image: nginx:alpine
                  env:
                      - name: DB_PASSWORD
                        value: <path:secret/data/app/config#db.password> # 플레이스홀더
```

이 방식의 장점은 시크릿 값이 Git에 저장되지 않는다는 점이다. `<path:secret/data/app/config#db.password>` 같은 플레이스홀더만 Git에 저장하고, 실제 값은 ArgoCD가 배포 시점에 Vault에서 가져온다.

ArgoCD에서 애플리케이션을 생성할 때 "argocd-vault-plugin"을 Config Management Plugin으로 선택해야 한다. 그러면 ArgoCD가 매니페스트를 클러스터에 적용하기 전에 `<path:...>` 형식의 참조를 실제 값으로 대체한다.

## 마치며

이번 글에서는 홈랩 쿠버네티스 클러스터에 Vault를 설치하고, 안전한 시크릿 관리 시스템을 구축하는 방법을 알아보았다. 또한 ArgoCD Vault Plugin과 Vault Secrets Operator를 통해 GitOps 방식으로 시크릿을 관리하는 방법도 살펴보았다.

다음 글에서는 CI/CD 파이프라인을 구축하는 방법을 알아볼 것이다.
