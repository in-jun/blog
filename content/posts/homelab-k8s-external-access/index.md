---
title: "홈랩 쿠버네티스 외부 접근 구성하기"
date: 2025-02-26T14:07:36+09:00
draft: false
description: "홈랩 쿠버네티스 클러스터에 외부 접근을 설정하고 Cloudflare를 이용한 DDNS를 구성하는 방법을 설명한다."
tags: ["kubernetes", "homelab", "traefik", "cloudflare", "ddns", "gitops"]
series: ["홈랩 쿠버네티스"]
---

## 개요

이전 글에서는 홈랩 쿠버네티스 클러스터에 Traefik 인그레스 컨트롤러를 설치하고 내부 관리 서비스에 안전하게 접근할 수 있도록 설정했다. 이번 글에서는 홈랩 쿠버네티스 클러스터의 서비스를 외부에서 접근할 수 있도록 설정하는 방법을 알아본다.

## 네트워크 아키텍처 요약

먼저 우리의 네트워크 아키텍처를 간략히 요약해보자:

1. **내부용 로드밸런서(192.168.0.200)**: 관리 인터페이스만 노출하고 내부 네트워크에서만 접근 가능
2. **외부용 로드밸런서(192.168.0.201)**: 공개 서비스만 노출하고 포트포워딩을 통해 외부에서 접근 가능

![네트워크 아키텍처](image.png)

이렇게 설계하면 서비스 수준에서 분리가 이루어져 실수로 중요한 관리 인터페이스가 외부에 노출될 위험이 줄어든다.

## 외부 접근 설정

외부에서 쿠버네티스 서비스에 접근하기 위해 세 가지 주요 단계가 필요하다:

1. 도메인 DNS 설정 (Cloudflare)
2. 동적 IP 관리 (DDNS)
3. 라우터 포트포워딩

### 1. Cloudflare DNS 구성

Cloudflare 대시보드에서 다음 DNS 레코드를 추가한다:

-   A 레코드: `injunweb.com` → 공인 IP 주소
-   A 레코드: `*.injunweb.com` → 공인 IP 주소 (와일드카드 서브도메인)

와일드카드 서브도메인(`*.injunweb.com`)을 설정하면 별도로 등록하지 않은 모든 서브도메인이 동일한 IP로 연결된다. 이는 새로운 서비스를 추가할 때마다 DNS 레코드를 추가하지 않아도 되므로 관리가 편리하다. 예를 들어 `hello.injunweb.com`, `blog.injunweb.com`, `api.injunweb.com` 등 어떤 서브도메인도 별도 설정 없이 동일한 IP로 연결되고, Traefik이 호스트 이름에 따라 적절한 서비스로 라우팅한다.

Cloudflare의 프록시 기능(주황색 구름 아이콘)은 DDoS 방어, 캐싱, 웹 애플리케이션 방화벽(WAF) 등 여러 보안 기능을 제공한다. 이 기능이 활성화되면 요청이 Cloudflare 서버를 통해 라우팅되며, 이는 도메인의 실제 IP 주소를 숨기는 효과도 있다.

Cloudflare의 SSL/TLS 설정은 "Full" 모드로 설정하여 Cloudflare와 서버 간의 연결도 암호화한다.

### 2. 동적 DNS(DDNS) 설정

가정용 인터넷은 대개 동적 IP를 사용하므로 DDNS 설정이 필요하다. 처음에는 No-IP, DuckDNS, Dyn 같은 기존 DDNS 서비스들을 시도했다. 그러나 이런 서비스들은 몇 가지 제한사항이 있었다:

1. **서브도메인 제한**: 대부분 무료 플랜에서는 제한된 수의 서브도메인만 제공했다.
2. **갱신 필요**: 무료 서비스는 보통 30일마다 수동 갱신이 필요했다.
3. **맞춤 설정 제한**: API를 통한 세밀한 제어가 어려웠다.

이미 Cloudflare로 도메인을 관리하고 있었기 때문에, Cloudflare의 API와 Worker를 활용한 커스텀 DDNS 솔루션을 개발하는 것이 더 나은 선택이었다. 이 방법으로 모든 제한사항을 해결할 수 있었고, 특히 와일드카드 도메인과 다중 서브도메인을 손쉽게 관리할 수 있게 되었다.

#### Cloudflare Worker 구현

Cloudflare Worker를 생성하기 위한 단계:

1. [Cloudflare 대시보드](https://dash.cloudflare.com)에 로그인한다.
2. 좌측 메뉴에서 "Workers & Pages"를 선택한다.
3. "Create Worker" 버튼을 클릭한다.
4. Worker 편집 화면에서 다음 코드를 붙여넣는다:

```javascript
const CONFIG = {
    API_TOKEN: "your-cloudflare-api-token", // Cloudflare API 토큰
    ZONE_ID: "your-cloudflare-zone-id", // 도메인의 Zone ID
    USE_BASIC_AUTH: true, // 기본 인증 사용 여부
    USERNAME: "ddns-username", // 인증 사용자 이름
    PASSWORD: "ddns-password", // 인증 비밀번호
    DEFAULT_TTL: 120, // DNS 레코드 TTL
    PROXY_ENABLED: false, // Cloudflare 프록시 활성화 여부
    DNS_RECORDS_IPV4: {
        "injunweb.com": "dns-record-id-for-domain", // 도메인 및 DNS 레코드 ID
    },
    DNS_RECORDS_IPV6: {}, // IPv6 레코드 (필요시 추가)
};

// IP 패턴 검증 정규식
const IP_PATTERNS = {
    IPv4: /^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}$/,
    IPv6: /^(?:(?:[a-fA-F\d]{1,4}:){7}(?:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){6}(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){5}(?::(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,2}|:)|(?:[a-fA-F\d]{1,4}:){4}(?:(?::[a-fA-F\d]{1,4}){0,1}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,3}|:)|(?:[a-fA-F\d]{1,4}:){3}(?:(?::[a-fA-F\d]{1,4}){0,2}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,4}|:)|(?:[a-fA-F\d]{1,4}:){2}(?:(?::[a-fA-F\d]{1,4}){0,3}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,5}|:)|(?:[a-fA-F\d]{1,4}:){1}(?:(?::[a-fA-F\d]{1,4}){0,4}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,6}|:)|(?::(?:(?::[a-fA-F\d]{1,4}){0,5}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,7}|:)))(?:%[0-9a-zA-Z]{1,})?$/,
};

// 응답 생성 함수
const createResponse = (data, status = 200) => {
    return new Response(JSON.stringify(data), {
        status,
        headers: {
            "Content-Type": "application/json",
            "Cache-Control": "no-store, no-cache, must-revalidate",
        },
    });
};

// IP 주소 유효성 검사 함수
const validateIPAddress = (ip) => {
    if (IP_PATTERNS.IPv4.test(ip)) return { valid: true, type: "A" };
    if (IP_PATTERNS.IPv6.test(ip)) return { valid: true, type: "AAAA" };
    return { valid: false, type: null };
};

// 기본 인증 확인 함수
const checkAuthentication = (request) => {
    if (!CONFIG.USE_BASIC_AUTH) return true;

    const authHeader = request.headers.get("Authorization");
    if (!authHeader?.startsWith("Basic ")) return false;

    try {
        const [username, password] = atob(authHeader.slice(6)).split(":");
        return username === CONFIG.USERNAME && password === CONFIG.PASSWORD;
    } catch {
        return false;
    }
};

// DNS 레코드 업데이트 함수
async function updateDNSRecord(recordId, data) {
    const response = await fetch(
        `https://api.cloudflare.com/client/v4/zones/${CONFIG.ZONE_ID}/dns_records/${recordId}`,
        {
            method: "PUT",
            headers: {
                Authorization: `Bearer ${CONFIG.API_TOKEN}`,
                "Content-Type": "application/json",
            },
            body: JSON.stringify(data),
        }
    );
    return await response.json();
}

// 요청 처리 함수
async function handleRequest(request) {
    // 인증 확인
    if (!checkAuthentication(request)) {
        return createResponse({ success: false, error: "Unauthorized" }, 401);
    }

    // 도메인 파라미터 확인
    const url = new URL(request.url);
    const domain = url.searchParams.get("domain");
    if (!domain) {
        return createResponse(
            { success: false, error: "Domain name missing" },
            400
        );
    }

    // 클라이언트 IP 주소 확인
    const clientIP = request.headers.get("CF-Connecting-IP");
    if (!clientIP) {
        return createResponse(
            { success: false, error: "Could not determine client IP" },
            500
        );
    }

    // 유효한 IP 주소인지 확인
    const ipValidation = validateIPAddress(clientIP);
    if (!ipValidation.valid) {
        return createResponse(
            { success: false, error: "Invalid IP address format" },
            400
        );
    }

    // DNS 레코드 ID 찾기
    const dnsRecords =
        ipValidation.type === "A"
            ? CONFIG.DNS_RECORDS_IPV4
            : CONFIG.DNS_RECORDS_IPV6;
    const dnsRecordId = dnsRecords[domain];
    if (!dnsRecordId) {
        return createResponse(
            { success: false, error: "Domain not found" },
            404
        );
    }

    // DNS 레코드 업데이트
    try {
        const updateData = {
            type: ipValidation.type,
            name: domain,
            content: clientIP,
            ttl: CONFIG.DEFAULT_TTL,
            proxied: CONFIG.PROXY_ENABLED,
        };

        const result = await updateDNSRecord(dnsRecordId, updateData);

        if (result.success) {
            return createResponse({
                success: true,
                message: `DNS record for ${domain} updated`,
                ip: clientIP,
                type: ipValidation.type,
            });
        } else {
            return createResponse(
                {
                    success: false,
                    error: "Failed to update DNS record",
                    details: result.errors?.[0]?.message || "Unknown error",
                },
                500
            );
        }
    } catch (error) {
        return createResponse(
            {
                success: false,
                error: "Internal server error",
                details: error.message,
            },
            500
        );
    }
}

// Worker 이벤트 리스너
addEventListener("fetch", (event) => {
    event.respondWith(handleRequest(event.request));
});
```

5. "Save and Deploy" 버튼을 클릭한다.
6. 배포가 완료되면 Worker 이름을 확인한다. 이 이름(예: `your-worker.workers.dev`)을 라우터 설정에 사용할 것이다.

#### Cloudflare API 토큰 및 DNS 레코드 ID 얻기

1. **API 토큰 생성**:

    - Cloudflare 대시보드에서 "My Profile" → "API Tokens" → "Create Token"으로 이동한다.
    - "Edit Zone DNS" 템플릿을 선택하거나 직접 권한을 설정한다.
    - 특정 도메인에만 접근 가능하도록 제한한다.
    - 토큰을 생성하고 안전하게 저장한다.

2. **Zone ID 찾기**:

    - Cloudflare 대시보드에서 도메인으로 이동한다.
    - "Overview" 페이지의 오른쪽 사이드바에서 "Zone ID"를 찾는다.

3. **DNS 레코드 ID 찾기**:
    - 터미널에서 다음 명령을 실행한다:
        ```bash
        curl -X GET "https://api.cloudflare.com/client/v4/zones/{Zone-ID}/dns_records" \
             -H "Authorization: Bearer {API-Token}" \
             -H "Content-Type: application/json"
        ```
    - 응답에서 각 도메인의 `id` 필드를 찾아 `DNS_RECORDS_IPV4` 객체에 설정한다.

#### TP-Link 라우터 DDNS 설정

여러 라우터 제조사가 제공하는 DDNS 설정은 매우 다양하다. TP-Link 라우터의 경우, 대부분 널리 알려진 DDNS 제공자(No-IP, DynDNS 등)을 기본적으로 지원한다. 처음에는 이들 기본 서비스를 사용하려 했지만, 위에서 언급한 제한 때문에 커스텀 DDNS 설정을 사용하기로 했다.

다행히 TP-Link 라우터는 "Custom" DDNS 서비스 옵션을 제공한다:

![TP-Link DDNS 설정](image-1.png)

1. 라우터 관리 인터페이스에서 "Services" → "Dynamic DNS" → "Custom DNS"로 이동한다.
2. "Add" 버튼을 클릭하고 다음과 같이 설정한다:

    - **Update URL**: `http://[USERNAME]:[PASSWORD]@your-worker.workers.dev?domain=[DOMAIN]`
    - **Interface**: 사용하는 네트워크 인터페이스(일반적으로 WAN)
    - **Account Name** 및 **Password**: Worker 코드에서 설정한 값
    - **Domain Name**: 업데이트할 도메인 이름
      (여기서 "your-worker.workers.dev"를 Worker URL로 교체하고, [USERNAME], [PASSWORD], [DOMAIN]은 그대로 유지한다. 이 값들은 라우터가 자동으로 적절한 값으로 대체한다)

URL 양식은 특히 까다로웠다. 처음에는 실제 값으로 채워넣었으나 작동하지 않았고, 여러 시도 끝에 [USERNAME], [PASSWORD], [DOMAIN] 같은 플레이스홀더를 그대로 두어야 라우터가 자동으로 대체한다는 것을 알게 되었다. 또한, 라우터가 보내는 요청에는 그 자체의 IP 주소가 쿼리 파라미터로 포함되지 않았다. 대신 Worker에서 Cloudflare의 "CF-Connecting-IP" 헤더를 사용해 요청한 클라이언트의 IP를 얻어와야 했다.

### 3. 라우터 포트포워딩 설정

마지막으로, 외부에서 들어오는 트래픽이 홈 네트워크를 통과하여 쿠버네티스 클러스터의 Traefik에 도달할 수 있도록 라우터에서 포트포워딩을 설정해야 한다:

1.  웹 브라우저에서 라우터 관리 페이지에 접속한다(일반적으로 `http://192.168.0.1` 또는 `http://192.168.1.1`).
2.  라우터 관리자 계정으로 로그인한다.
3.  TP-Link 라우터의 경우 "Transmission" → "NAT" → "Virtual Servers" 메뉴로 이동한다.
4.  다음과 같이 두 개의 규칙을 추가한다:

    ![라우터 포트포워딩](image-2.png)

5.  설정을 저장하고 적용한다.

중요한 점은 Internal Server IP를 **192.168.0.201**로 설정하는 것이다. 이렇게 함으로써 내부용 로드밸런서(192.168.0.200)는 외부에서 완전히 격리된다. 이는 실수로 관리 서비스가 외부에 노출되는 위험을 방지한다.

## 외부 서비스 라우팅 구성

이제 외부에서 접근 가능한 서비스에 대한 인그레스 라우트를 구성한다. 테스트를 위해 간단한 웹 애플리케이션을 배포해보자:

```yaml
apiVersion: traefik.containo.us/v1alpha1
kind: IngressRoute
metadata:
    name: hello-world
    namespace: default
spec:
    entryPoints:
        - web
        - websecure
    routes:
        - match: Host(`hello.injunweb.com`)
          kind: Rule
          services:
              - name: hello-world
                port: 80
```

여기서 중요한 점은 `entryPoints`를 `web`과 `websecure`로 설정하여 외부에서 접근 가능하도록 한 것이다. 앞서 Traefik 설정에서 이 엔트리포인트들은 외부용 로드밸런서(192.168.0.201)와 연결되어 있다.

## Let's Encrypt 인증서 발급 확인

외부 접근이 가능해지면, Let's Encrypt가 HTTP 챌린지를 통해 도메인 소유권을 확인하고 SSL/TLS 인증서를 자동으로 발급할 수 있다. 인증서 발급 상태는 다음 명령으로 확인할 수 있다:

```bash
kubectl exec -n traefik $(kubectl get pods -n traefik -l app.kubernetes.io/name=traefik -o jsonpath='{.items[0].metadata.name}') -- cat /data/acme.json | jq
```

정상적으로 인증서가 발급되면 `acme.json` 파일에 인증서 정보가 저장된다. 이후 Traefik은 인증서 만료 시점이 다가오면 자동으로 갱신한다.

## 테스트 애플리케이션 배포

구성이 제대로 작동하는지 확인하기 위해 간단한 테스트 애플리케이션을 배포한다:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: hello-world
    namespace: default
spec:
    replicas: 1
    selector:
        matchLabels:
            app: hello-world
    template:
        metadata:
            labels:
                app: hello-world
        spec:
            containers:
                - name: hello-world
                  image: nginxdemos/hello
                  ports:
                      - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
    name: hello-world
    namespace: default
spec:
    ports:
        - port: 80
          targetPort: 80
    selector:
        app: hello-world
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
    name: hello-world
    namespace: default
spec:
    entryPoints:
        - web
        - websecure
    routes:
        - match: Host(`hello.injunweb.com`)
          kind: Rule
          services:
              - name: hello-world
                port: 80
```

다음 명령으로 애플리케이션을 배포한다:

```bash
kubectl apply -f hello-world.yaml
```

## 접근 테스트

모든 구성이 완료되었으니 이제 내부 및 외부에서 접근이 가능한지 테스트해보자.

### 1. 내부 네트워크 테스트

내부 네트워크에서 다음 URL을 통해 각 서비스에 접근해본다:

-   http://traefik.injunweb.com/dashboard/ - Traefik 대시보드
-   http://argocd.injunweb.com - ArgoCD UI
-   http://longhorn.injunweb.com - Longhorn UI
-   http://hello.injunweb.com - 테스트 애플리케이션

모든 서비스가 정상적으로 접근 가능한지 확인한다.

### 2. 외부 네트워크 테스트

이제 외부 네트워크(예: 모바일 데이터 네트워크)에서 다음 URL에 접근해본다:

-   https://traefik.injunweb.com/dashboard/ - 접근 불가 (의도한 대로)
-   https://argocd.injunweb.com - 접근 불가 (의도한 대로)
-   https://longhorn.injunweb.com - 접근 불가 (의도한 대로)
-   https://hello.injunweb.com - 접근 가능

내부 관리 서비스들은 외부에서 접근할 수 없고, 테스트 애플리케이션만 외부에서 접근 가능한지 확인한다. 이는 서비스 분리 전략이 의도한 대로 작동한다는 것을 보여준다.

## 마치며

이 글에서는 홈랩 쿠버네티스 클러스터에 Traefik 인그레스 컨트롤러를 설치하고, 내부 서비스와 외부 서비스를 안전하게 분리하여 접근할 수 있도록 구성하는 방법을 살펴보았다. 또한 동적 IP 환경에서 도메인 관리를 위한 커스텀 DDNS 솔루션도 구현했다.

다음 글에서는 홈랩 쿠버네티스 클러스터에 Vault를 설치하여 시크릿을 안전하게 관리하는 방법을 알아볼 것이다.
