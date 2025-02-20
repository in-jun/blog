---
title: "쿠버네티스에 GoCD 설치, YAML로 파이프라인 구축"
date: 2024-08-01T20:40:22+09:00
tags: ["kubernetes", "gocd", "ci/cd", "continuous-integration", "continuous-delivery"]
draft: false
---

## 1. 서론

쿠버네티스 환경에 GoCD를 설치하고 YAML을 사용하여 Docker 빌드 및 쿠버네티스 프로덕션 배포를 위한 CI/CD 파이프라인을 구축하는 방법에 대해 자세히 알아보자.

## 2. GoCD 소개

GoCD는 지속적 통합(CI)과 지속적 배포(CD)를 위한 강력한 오픈소스 도구이다. 복잡한 워크플로우를 시각화하고 모델링할 수 있는 기능을 제공하며, 파이프라인을 코드로 정의할 수 있어 버전 관리가 용이하다. 이를 통해 개발팀은 다양한 환경에서 일관된 배포 프로세스를 구축할 수 있으며, 자동화된 배포로 인해 오류를 줄이고 효율성을 높일 수 있다.

## 3. 쿠버네티스에 GoCD 설치

[우분투에 쿠버네티스 구성](/post/47)

[Helm 설치하기](/post/48)

쿠버네티스 환경에 GoCD를 설치하기 위해 Helm 차트를 사용한다. Helm은 쿠버네티스 애플리케이션의 설치 및 관리를 위한 패키지 관리 도구로, 여러 리소스를 한 번에 관리할 수 있어 편리하다. 다음 명령어를 실행하자:

```bash
helm repo add gocd https://gocd.github.io/helm-chart
helm repo update
helm install gocd gocd/gocd
```

이 명령어는 GoCD의 Helm 차트를 사용하여 쿠버네티스 클러스터에 GoCD 서버와 에이전트를 설치한다. 각 명령어의 의미는 다음과 같다:

-   `helm repo add`: GoCD Helm 차트 저장소를 추가하는 명령어이다. 이 저장소에는 GoCD를 설치하기 위한 모든 리소스가 포함되어 있다.
-   `helm repo update`: 로컬 Helm 저장소 목록을 업데이트하여 최신 상태로 유지한다.
-   `helm install`: GoCD Helm 차트를 사용하여 GoCD 서버와 에이전트를 설치한다. 이때 `gocd/gocd`는 설치할 차트의 이름을 나타낸다.

설치가 완료되면 GoCD 웹 인터페이스에 접속하여 파이프라인을 구성할 수 있다. 웹 인터페이스에서는 파이프라인의 상태를 모니터링하고, 각 스테이지의 세부 사항을 확인할 수 있다.

## 4. YAML을 사용한 파이프라인 구성

이제 YAML 형식을 사용하여 Docker 빌드와 쿠버네티스 프로덕션 배포를 위한 파이프라인을 구성해 보자. YAML 파일을 통해 파이프라인의 모든 단계와 작업을 코드로 정의할 수 있으며, 이를 통해 버전 관리와 복제가 용이해진다. 아래 YAML 파일을 자세히 살펴보자.

```yaml
format_version: 10
pipelines:
    myapp-deploy:
        group: production-apps
        label_template: ${COUNT}
        lock_behavior: none
        display_order: -1
        materials:
            app-git:
                git: https://github.com/myorg/myapp.git
                branch: main
        stages:
            - build:
                  fetch_materials: true
                  jobs:
                      docker-build:
                          tasks:
                              - exec:
                                    command: docker
                                    arguments:
                                        - build
                                        - -t
                                        - myrepo/myapp:${GO_PIPELINE_LABEL}
                                        - .
                              - exec:
                                    command: docker
                                    arguments:
                                        - push
                                        - myrepo/myapp:${GO_PIPELINE_LABEL}
            - deploy:
                  fetch_materials: true
                  jobs:
                      k8s-deploy:
                          tasks:
                              - exec:
                                    command: /bin/bash
                                    arguments:
                                        - -c
                                        - |
                                            cat <<EOF > deployment.yaml
                                            apiVersion: apps/v1
                                            kind: Deployment
                                            metadata:
                                              name: myapp
                                              namespace: production
                                            spec:
                                              replicas: 3
                                              selector:
                                                matchLabels:
                                                  app: myapp
                                              template:
                                                metadata:
                                                  labels:
                                                    app: myapp
                                                spec:
                                                  containers:
                                                  - name: myapp
                                                    image: myrepo/myapp:${GO_PIPELINE_LABEL}
                                                    ports:
                                                    - containerPort: 8080
                                            ---
                                            apiVersion: v1
                                            kind: Service
                                            metadata:
                                              name: myapp-service
                                              namespace: production
                                            spec:
                                              selector:
                                                app: myapp
                                              ports:
                                                - protocol: TCP
                                                  port: 80
                                                  targetPort: 8080
                                              type: LoadBalancer
                                            EOF
                              - exec:
                                    command: kubectl
                                    arguments:
                                        - apply
                                        - -f
                                        - deployment.yaml
```

### 4.1 파이프라인 기본 설정

YAML 파일의 첫 번째 부분에서는 파이프라인의 기본 설정을 정의한다:

```yaml
format_version: 10
pipelines:
    myapp-deploy:
        group: production-apps
        label_template: ${COUNT}
        lock_behavior: none
        display_order: -1
```

-   `format_version`: GoCD 파이프라인 설정 파일의 버전을 지정한다. 여기서는 버전 10을 사용하며, 이는 YAML 파일의 형식과 구문을 정의하는 데 사용된다.
-   `pipelines`: 여러 파이프라인을 정의할 수 있는 최상위 항목이다. 이 섹션 아래에 각 파이프라인의 세부 설정이 위치한다.
-   `myapp-deploy`: 파이프라인의 이름이다. 이 이름은 GoCD 대시보드에서 파이프라인을 식별하는 데 사용된다.
-   `group`: 파이프라인이 속한 그룹을 지정한다. 이는 여러 파이프라인을 논리적으로 그룹화하여 관리할 수 있게 한다.
-   `label_template`: 파이프라인 실행마다 부여되는 고유 레이블의 형식을 정의한다. `${COUNT}`는 파이프라인 실행 번호로, 실행마다 증가하는 숫자가 레이블로 사용된다.
-   `lock_behavior`: 파이프라인 실행 간의 잠금 동작을 정의한다. `none`으로 설정하면 여러 파이프라인 실행이 동시에 수행될 수 있다.
-   `display_order`: GoCD 대시보드에서 파이프라인의 표시 순서를 정의한다. 음수 값을 사용하면 대시보드 상단에 배치된다.

### 4.2 소스 코드 관리

다음으로, 파이프라인에서 사용할 소스 코드의 출처를 정의한다:

```yaml
materials:
    app-git:
        git: https://github.com/myorg/myapp.git
        branch: main
```

-   `materials`: 파이프라인에서 사용하는 소스 코드나 외부 의존성을 정의하는 섹션이다. 여기에는 Git, SVN, Mercurial 등 여러 종류의 소스 관리 시스템을 정의할 수 있다.
-   `app-git`: 소스 코드가 위치한 Git 저장소를 지정하는 이름이다. 이 이름은 이후 단계에서 소스 코드를 참조할 때 사용된다.
-   `git`: 소스 코드가 저장된 Git 저장소의 URL을 지정한다. 여기서는 `https://github.com/myorg/myapp.git`이 사용된다.
-   `branch`: 파이프라인에서 사용할 Git 브랜치를 지정한다. 이 예시에서는 `main` 브랜치를 사용한다.

이 설정을 통해 GoCD는 지정된 Git 저장소에서 `main` 브랜치의 최신 코드를 가져와 파이프라인의 재료로 사용한다.

### 4.3 빌드 스테이지

이제 빌드 스테이지를 정의한다. 이 스테이지에서는 Docker 이미지를 빌드하고, 이를 레지스트리에 푸시하는 작업을 수행한다:

```yaml
stages:
    - build:
          fetch_materials: true
          jobs:
              docker-build:
                  tasks:
                      - exec:
                            command: docker
                            arguments:
                                - build
                                - -t
                                - myrepo/myapp:${GO_PIPELINE_LABEL}
                                - .
                      - exec:
                            command: docker
                            arguments:
                                - push
                                - myrepo/myapp:${GO_PIPELINE_LABEL}
```

-   `stages`: 파이프라인의 각 단계를 정의하는 섹션이다. 파이프라인은 여러 스테이지로 구성되며, 각 스테이지는 여러 작업을 포함할 수 있다.
-   `build`: 첫 번째 스테이지의 이름이다. 이 스테이지는 Docker 이미지를 빌드하는 작업을 포함한다.
-   `fetch_materials`: 이 스테이지에서 파이프라인의 재료(소스 코드 등)를 가져올지 여부를 지정한다. `true`로 설정하면, 이전에 정의된 `materials` 섹션에서 설정된 소스를 가져온다.
-   `jobs`: 이 스테이지에서 실행할 작업을 정의하는 섹션이다. 각 스테이지는 하나 이상의 작업을 포함할 수 있다.
-   `docker-build`: Docker 이미지를 빌드하고 푸시하는 작업을 정의한 이름이다.
-   `tasks`: 각 작업에서 실행할 구체적인 명령어들을 나열하는 섹션이다. 여기서는 Docker 이미지를 빌드하고 푸시하는 두 가지 명령어가 포함되어 있다.
    -   첫 번째 `exec` task는 Docker 이미지를 빌드하는 명령어를 실행한다. `docker build -t myrepo/myapp:${GO_PIPELINE_LABEL} .` 명령어는 현재 디렉터

리(`.`)의 Dockerfile을 사용하여 이미지를 빌드하며, 이미지 태그는 파이프라인 실행 번호로 지정된다.

-   두 번째 `exec` task는 빌드된 Docker 이미지를 `myrepo/myapp:${GO_PIPELINE_LABEL}` 레지스트리로 푸시한다. 여기서 `${GO_PIPELINE_LABEL}`은 GoCD가 제공하는 환경 변수로, 현재 파이프라인 실행의 고유 레이블을 나타낸다.

### 4.4 배포 스테이지

이제 Docker 이미지를 쿠버네티스 클러스터에 배포하는 배포 스테이지를 정의한다:

```yaml
- deploy:
      fetch_materials: true
      jobs:
          k8s-deploy:
              tasks:
                  - exec:
                        command: /bin/bash
                        arguments:
                            - -c
                            - |
                                cat <<EOF > deployment.yaml
                                apiVersion: apps/v1
                                kind: Deployment
                                metadata:
                                  name: myapp
                                  namespace: production
                                spec:
                                  replicas: 3
                                  selector:
                                    matchLabels:
                                      app: myapp
                                  template:
                                    metadata:
                                      labels:
                                        app: myapp
                                    spec:
                                      containers:
                                      - name: myapp
                                        image: myrepo/myapp:${GO_PIPELINE_LABEL}
                                        ports:
                                        - containerPort: 8080
                                ---
                                apiVersion: v1
                                kind: Service
                                metadata:
                                  name: myapp-service
                                  namespace: production
                                spec:
                                  selector:
                                    app: myapp
                                  ports:
                                    - protocol: TCP
                                      port: 80
                                      targetPort: 8080
                                  type: LoadBalancer
                                EOF
                  - exec:
                        command: kubectl
                        arguments:
                            - apply
                            - -f
                            - deployment.yaml
```

-   `deploy`: 두 번째 스테이지의 이름이다. 이 스테이지는 빌드된 Docker 이미지를 쿠버네티스 클러스터에 배포하는 작업을 포함한다.
-   `k8s-deploy`: 쿠버네티스 배포 작업을 정의하는 이름이다.
-   첫 번째 `exec` task는 쿠버네티스 매니페스트 파일을 생성하는 명령어를 실행한다. 이 명령어는 Bash 스크립트를 사용하여 `deployment.yaml` 파일을 생성한다.
    -   `cat <<EOF > deployment.yaml ... EOF`: 이 명령어는 여러 줄의 텍스트를 파일에 작성하는 Bash 스크립트이다. 여기서는 쿠버네티스 배포와 서비스를 정의하는 매니페스트 파일을 생성한다.
    -   생성된 `deployment.yaml` 파일은 애플리케이션을 배포하기 위한 Deployment와 외부 트래픽을 수신하는 LoadBalancer 타입의 서비스를 정의한다.
-   두 번째 `exec` task는 생성된 `deployment.yaml` 파일을 쿠버네티스 클러스터에 적용하는 명령어를 실행한다.
    -   `kubectl apply -f deployment.yaml`: 이 명령어는 `deployment.yaml` 파일에 정의된 리소스를 쿠버네티스 클러스터에 배포한다.

### 4.5 쿠버네티스 매니페스트

`deployment.yaml` 파일은 쿠버네티스 클러스터에서 애플리케이션을 배포하고 관리하기 위한 리소스를 정의한다. 아래는 매니페스트의 세부 사항이다:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: myapp
    namespace: production
spec:
    replicas: 3
    selector:
        matchLabels:
            app: myapp
    template:
        metadata:
            labels:
                app: myapp
        spec:
            containers:
                - name: myapp
                  image: myrepo/myapp:${GO_PIPELINE_LABEL}
                  ports:
                      - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
    name: myapp-service
    namespace: production
spec:
    selector:
        app: myapp
    ports:
        - protocol: TCP
          port: 80
          targetPort: 8080
    type: LoadBalancer
```

-   `Deployment`: 애플리케이션의 배포 및 관리를 담당하는 쿠버네티스 리소스이다.

    -   `apiVersion: apps/v1`: Deployment 리소스의 API 버전을 지정한다.
    -   `kind: Deployment`: 리소스의 종류를 지정한다.
    -   `metadata`: 리소스의 메타데이터를 정의하는 섹션이다.
        -   `name`: Deployment 리소스의 이름이다. 이 예시에서는 `myapp`으로 지정된다.
        -   `namespace`: 리소스가 속할 네임스페이스를 지정한다. 여기서는 `production` 네임스페이스를 사용한다.
    -   `spec`: Deployment의 세부 스펙을 정의하는 섹션이다.
        -   `replicas`: 애플리케이션의 인스턴스(레플리카) 수를 지정한다. 여기서는 3개의 인스턴스를 생성한다.
        -   `selector`: 이 Deployment가 관리할 포드를 선택하는 기준을 정의한다.
            -   `matchLabels`: 특정 레이블을 가진 포드를 선택한다. 여기서는 `app: myapp` 레이블을 가진 포드를 선택한다.
        -   `template`: 생성할 포드의 템플릿을 정의한다.
            -   `metadata`: 포드에 적용할 메타데이터를 정의한다.
                -   `labels`: 포드에 적용할 레이블을 지정한다. 여기서는 `app: myapp` 레이블이 적용된다.
            -   `spec`: 포드의 컨테이너 스펙을 정의한다.
                -   `containers`: 포드 내의 컨테이너 목록을 정의한다.
                    -   `name`: 컨테이너의 이름을 지정한다.
                    -   `image`: 컨테이너에서 실행할 Docker 이미지를 지정한다. 여기서는 `myrepo/myapp:${GO_PIPELINE_LABEL}` 이미지를 사용한다.
                    -   `ports`: 컨테이너에서 노출할 포트를 지정한다. 여기서는 8080 포트를 노출한다.

-   `Service`: 애플리케이션을 외부 트래픽에 노출하기 위한 쿠버네티스 리소스이다.
    -   `apiVersion: v1`: Service 리소스의 API 버전을 지정한다.
    -   `kind: Service`: 리소스의 종류를 지정한다.
    -   `metadata`: 리소스의 메타데이터를 정의하는 섹션이다.
        -   `name`: Service 리소스의 이름이다. 이 예시에서는 `myapp-service`로 지정된다.
        -   `namespace`: 리소스가 속할 네임스페이스를 지정한다.
    -   `spec`: Service의 세부 스펙을 정의하는 섹션이다.
        -   `selector`: 이 서비스가 연결할 포드를 선택하는 기준을 정의한다. 여기서는 `app: myapp` 레이블을 가진 포드를 선택한다.
        -   `ports`: Service가 노출할 포트를 지정한다. 여기서는 80 포트를 노출하고, 이 포트에 대한 트래픽을 포드의 8080 포트로 전달한다.
        -   `type`: Service의 타입을 지정한다. 여기서는 `LoadBalancer` 타입으로 설정하여 외부 IP 주소를 통해 접근 가능하게 만든다.

## 5. 파이프라인 실행 결과

이 YAML 구성을 사용하면 다음과 같은 프로세스가 자동화된다:

소스 코드 가져오기: GoCD 파이프라인은 설정된 Git 저장소의 main 브랜치에서 최신 소스 코드를 가져온다. 이는 파이프라인의 materials 섹션에서 정의되었다.

Docker 이미지 빌드 및 푸시: 첫 번째 스테이지에서는 Docker 이미지를 빌드하고 이를 Docker 레지스트리에 푸시한다. 이 과정은 두 개의 exec task를 통해 수행되며, 각각 docker build와 docker push 명령어를 사용한다. 빌드된 이미지는 myrepo/myapp:${GO_PIPELINE_LABEL}이라는 태그로 저장된다. 여기서 ${GO_PIPELINE_LABEL}은 파이프라인 실행 번호로 대체된다.

쿠버네티스 배포: 두 번째 스테이지에서는 애플리케이션을 쿠버네티스 클러스터에 배포한다. 먼저 Bash 스크립트를 사용해 deployment.yaml 파일을 생성한 다음, 이 파일을 사용해 쿠버네티스 클러스터에 애플리케이션을 배포한다. kubectl apply -f deployment.yaml 명령어를 통해 생성된 매니페스트 파일이 클러스터에 적용된다.

애플리케이션 서비스 노출: deployment.yaml 파일에는 애플리케이션을 외부에 노출하기 위한 서비스 리소스도 포함된다. 이 서비스는 LoadBalancer 타입으로 설정되어, 클러스터 외부에서 애플리케이션에 접근할 수 있게 된다.

### 5.1 결과 확인

파이프라인이 성공적으로 실행되면, 애플리케이션은 쿠버네티스 클러스터에 배포되고, 외부 트래픽을 받을 수 있게 된다. 쿠버네티스 클러스터의 서비스 목록을 확인하여 애플리케이션에 대한 외부 IP 주소를 확인할 수 있다. 이를 위해 `kubectl get services -n production` 명령어를 사용하면 다음과 같은 정보를 확인할 수 있다:

```bash
NAME            TYPE           CLUSTER-IP     EXTERNAL-IP    PORT(S)        AGE
myapp-service   LoadBalancer   10.0.171.239   35.238.123.45  80:32212/TCP   5m
```

위와 같이 EXTERNAL-IP 열에 표시된 IP 주소를 통해 애플리케이션에 접근할 수 있다. 이제 브라우저를 열고 해당 IP 주소로 접속하여 애플리케이션을 확인할 수 있다.

## 6. 결론

이제 쿠버네티스 환경에 GoCD를 설치하고, YAML을 사용하여 Docker 빌드 및 쿠버네티스 프로덕션 배포를 위한 CI/CD 파이프라인을 구축하는 방법을 간단하게 알아보았다. 이를 통해 개발팀은 손쉽게 파이프라인을 정의하고 관리할 수 있으며, 애플리케이션의 지속적인 통합과 배포를 자동화하여 개발 생산성을 향상할 수 있다.
