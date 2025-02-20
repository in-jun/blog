---
title: "helm 사용하기: Kubernetes 애플리케이션 패키지 관리 도구"
date: 2024-07-28T23:22:52+09:00
tags: ["kubernetes", "helm", "package-management", "cloud-native"]
draft: false
---

## 서론

helm은 Kubernetes 애플리케이션을 손쉽게 패키징하고 배포하기 위한 도구이다. "Kubernetes를 위한 패키지 관리자"로 불리는 helm은 복잡한 애플리케이션 구조를 단순화하고, 버전 관리를 용이하게 하며, 애플리케이션의 생명주기 관리를 효율적으로 만들어준다. 이 글에서는 helm의 개념부터 고급 사용법까지 상세히 다뤄보겠다.

## 1. helm의 기본 개념

### 1.1 helm이란?

helm은 Kubernetes 생태계에서 "패키지 관리자"로 불리는 도구이다. 리눅스의 apt나 yum, macOS의 Homebrew와 같은 역할을 Kubernetes에서 수행한다. helm을 사용하면 복잡한 Kubernetes 애플리케이션을 쉽게 정의하고, 설치하고, 업그레이드할 수 있다.

### 1.2 helm의 주요 개념

1. **차트(Chart)**: Kubernetes 리소스를 설명하는 파일들의 집합이다. 차트는 템플릿화된 YAML 매니페스트 파일, 차트의 메타데이터를 포함하는 Chart.yaml 파일, 그리고 기타 설정 파일들로 구성된다.

2. **저장소(Repository)**: 차트들을 모아두고 공유할 수 있는 장소이다. GitHub 저장소나 전용 차트 저장소 서버가 될 수 있다.

3. **릴리스(Release)**: 특정 차트의 인스턴스로, Kubernetes 클러스터에서 실행 중인 차트의 특정 배포를 나타낸다. 하나의 차트는 같은 클러스터 내에 여러 번 설치될 수 있으며, 각 설치는 새로운 릴리스를 생성한다.

4. **값(Values)**: 차트의 기본 설정을 오버라이드하는 데 사용되는 설정값이다. 이를 통해 하나의 차트를 다양한 환경에 맞게 커스터마이즈할 수 있다.

## 2. helm 설치하기

helm을 설치하는 방법은 운영체제에 따라 다르다. 여기서는 주요 운영체제별 설치 방법을 소개하겠다.

### 2.1 macOS (Homebrew 사용)

```bash
brew install helm
```

### 2.2 Linux (스크립트 사용)

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

### 2.3 직접 바이너리 다운로드

[공식 GitHub 릴리스 페이지](https://github.com/helm/helm/releases)에서 운영체제에 맞는 바이너리를 다운로드하여 설치할 수도 있다.

설치가 완료되면 다음 명령어로 helm 버전을 확인할 수 있다:

```bash
helm version
```

## 3. helm 기본 사용법

### 3.1 저장소 관리

#### 저장소 추가

```bash
helm repo add stable https://charts.helm.sh/stable
```

#### 저장소 목록 확인

```bash
helm repo list
```

#### 저장소 업데이트

```bash
helm repo update
```

### 3.2 차트 검색 및 정보 확인

#### 차트 검색

```bash
helm search repo stable
```

#### 특정 차트 정보 확인

```bash
helm show chart stable/mysql
```

### 3.3 차트 설치 및 관리

#### 차트 설치

```bash
helm install my-release stable/mysql
```

#### 설치된 릴리스 목록 확인

```bash
helm list
```

#### 릴리스 업그레이드

```bash
helm upgrade my-release stable/mysql
```

#### 릴리스 롤백

```bash
helm rollback my-release 1
```

#### 릴리스 삭제

```bash
helm uninstall my-release
```

## 4. helm 차트 구조 상세 분석

helm 차트의 기본 구조는 다음과 같다:

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

차트의 메타데이터를 포함하는 YAML 파일이다. 주요 필드는 다음과 같다:

-   `apiVersion`: 차트 API 버전 (helm 3에서는 "v2")
-   `name`: 차트 이름
-   `version`: 차트의 SemVer 2 버전
-   `kubeVersion`: 지원하는 Kubernetes 버전 (선택적)
-   `description`: 차트에 대한 간단한 설명
-   `type`: 차트 타입 (application 또는 library)
-   `dependencies`: 차트의 종속성 목록

### 4.2 values.yaml

차트의 기본 설정값을 정의하는 파일이다. 이 파일의 값들은 템플릿에서 참조될 수 있으며, 설치 시 오버라이드 될 수 있다.

### 4.3 templates/ 디렉토리

Kubernetes 리소스를 정의하는 템플릿 파일들이 위치한다. 이 템플릿들은 Go 템플릿 언어로 작성되며, values.yaml의 값들을 참조할 수 있다.

### 4.4 charts/ 디렉토리

차트의 종속성(서브차트)들이 위치하는 디렉토리이다.

### 4.5 crds/ 디렉토리

Custom Resource Definitions(CRDs)를 포함하는 디렉토리이다.

## 5. helm 템플릿 작성하기

helm 템플릿은 Go 템플릿 언어를 기반으로 한다. 주요 기능은 다음과 같다:

### 5.1 값 참조

values.yaml 파일의 값을 참조할 때는 `.Values` 객체를 사용한다:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Release.Name }}-configmap
data:
  myvalue: "Hello World"
  drink: {{ .Values.favorite.drink }}
```

### 5.2 제어 구조

조건문과 반복문을 사용할 수 있다:

```yaml
{{- if .Values.create }}
# 리소스 생성
{{- end }}

{{- range .Values.list }}
- {{ . }}
{{- end }}
```

### 5.3 함수와 파이프라인

helm은 다양한 내장 함수를 제공하며, 파이프라인을 통해 함수를 연결할 수 있다:

```yaml
value: { { .Values.string | upper | quote } }
```

### 5.4 Named Templates

재사용할 수 있는 템플릿 부분을 정의하고 사용할 수 있다:

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

## 6. helm 차트 개발 및 테스트

### 6.1 차트 생성

새로운 차트를 생성하려면 다음 명령을 사용한다:

```bash
helm create mychart
```

### 6.2 차트 린팅

차트의 구조와 파일들을 검증한다:

```bash
helm lint mychart
```

### 6.3 차트 템플릿 렌더링 테스트

실제로 설치하지 않고 템플릿이 어떻게 렌더링 되는지 확인할 수 있다:

```bash
helm template mychart
```

### 6.4 차트 설치 테스트

차트를 테스트 목적으로 설치하고 즉시 삭제할 수 있다:

```bash
helm install --dry-run --debug test-release mychart
```

## 7. helm 차트 배포 및 공유

### 7.1 차트 패키징

차트를 배포 가능한 아카이브로 패키징 한다:

```bash
helm package mychart
```

### 7.2 차트 저장소 호스팅

GitHub Pages나 Chart Museum과 같은 도구를 사용하여 차트 저장소를 호스팅 할 수 있다.

### 7.3 차트 저장소 인덱스 생성

저장소의 인덱스 파일을 생성한다:

```bash
helm repo index --url https://example.com/charts .
```

## 8. helm의 고급 기능

### 8.1 Hooks

릴리스의 라이프사이클 중 특정 시점에 실행되는 스크립트를 정의할 수 있다. 주요 hook 포인트는 다음과 같다:

-   pre-install, post-install
-   pre-delete, post-delete
-   pre-upgrade, post-upgrade
-   pre-rollback, post-rollback
-   test

### 8.2 차트 테스트

`templates/tests/` 디렉토리에 테스트를 위한 pod 정의를 포함해 차트의 기능을 테스트할 수 있다.

### 8.3 Library Charts

재사용할 수 있는 차트 컴포넌트를 만들어 여러 차트에서 공유할 수 있다.

### 8.4 Subcharts와 Global Values

복잡한 애플리케이션을

여러 개의 서브 차트로 구성하고, 글로벌 값을 통해 전체 차트에서 공유되는 설정을 관리할 수 있다.

## 9. helm과 CI/CD

helm은 CI/CD 파이프라인에 쉽게 통합될 수 있다. 주요 사용 사례는 다음과 같다:

-   차트 빌드 및 린팅
-   차트 버전 관리
-   차트 패키징 및 저장소 업로드
-   테스트 환경에 차트 배포
-   프로덕션 환경으로 롤아웃

예를 들어, GitLab CI에서의 helm 사용 예시:

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

## 10. helm의 보안 고려사항

helm을 사용할 때 주의해야 할 보안 사항들:

1. **values 파일 관리**: 민감한 정보는 values 파일에 직접 포함시키지 않고, Kubernetes Secrets나 외부 시크릿 관리 도구를 사용해야 한다.

2. **차트 검증**: 신뢰할 수 있는 소스의 차트만 사용하고, 설치 전 항상 차트의 내용을 검토해야 한다.

## 11. 결론

helm은 Kubernetes 애플리케이션의 패키징, 배포, 관리를 크게 단순화하는 강력한 도구이다. 복잡한 애플리케이션을 쉽게 패키징하고, 버전 관리하며, 공유할 수 있게 해 주며, Kubernetes 생태계에서 중요한 역할을 담당하고 있다.
