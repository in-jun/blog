---
title: "홈랩 쿠버네티스 #5 - DDNS와 포트포워딩으로 외부에서 접속하기"
date: 2025-02-26T14:07:36+09:00
draft: false
description: "홈랩 쿠버네티스 클러스터의 서비스를 외부 인터넷에서 접근할 수 있도록 Cloudflare DNS 설정, 커스텀 DDNS Worker 구현, 라우터 포트포워딩 구성 방법을 다룬다."
tags: ["kubernetes", "homelab", "traefik", "cloudflare", "ddns", "gitops", "port-forwarding"]
series: ["홈랩 쿠버네티스"]
---

## 개요

[이전 글](/posts/homelab-k8s-internal-services/)에서는 Traefik 인그레스 컨트롤러를 설치하고 내부와 외부 서비스를 분리하여 관리 인터페이스를 안전하게 접근할 수 있도록 구성했다. 이번 글에서는 홈랩 쿠버네티스 클러스터의 서비스를 외부 인터넷에서 접근할 수 있도록 DDNS와 포트포워딩을 구성하는 방법을 알아본다.

## 네트워크 아키텍처 요약

먼저 이전 글에서 구성한 네트워크 아키텍처를 간략히 요약한다:

1. **내부용 로드밸런서(192.168.0.200)**: ArgoCD, Longhorn, Traefik 대시보드 같은 관리 인터페이스만 노출하며 내부 네트워크에서만 접근 가능하다.
2. **외부용 로드밸런서(192.168.0.201)**: 블로그, 개인 프로젝트 등 공개 서비스만 노출하며 라우터 포트포워딩을 통해 외부 인터넷에서 접근 가능하다.

![네트워크 아키텍처](image.png)

이 설계는 서비스 수준에서 분리가 이루어져 실수로 관리 인터페이스가 외부에 노출될 위험을 줄이며, 포트포워딩 대상을 외부용 로드밸런서 IP로만 설정하여 내부용 로드밸런서는 외부 접근에서 완전히 격리된다.

## 외부 접근 설정

외부 인터넷에서 쿠버네티스 서비스에 접근하기 위해 세 가지 주요 단계가 필요하다:

1. **도메인 DNS 설정**: Cloudflare에서 도메인의 DNS 레코드를 구성한다.
2. **동적 IP 관리(DDNS)**: 가정용 인터넷의 동적 IP가 변경될 때마다 DNS 레코드를 자동으로 업데이트한다.
3. **라우터 포트포워딩**: 외부에서 들어오는 HTTP/HTTPS 트래픽을 쿠버네티스 클러스터의 Traefik으로 전달한다.

### 1. Cloudflare DNS 구성

> **Cloudflare란?**
>
> Cloudflare는 2009년에 설립된 웹 인프라 및 보안 회사로, 전 세계에 분산된 CDN(Content Delivery Network), DDoS 방어, DNS 서비스, WAF(Web Application Firewall) 등을 제공하며, 무료 플랜에서도 강력한 보안 기능과 DNS 관리 기능을 사용할 수 있어 홈랩 환경에서 널리 사용된다.

Cloudflare 대시보드에서 도메인의 DNS 레코드를 다음과 같이 구성한다:

- **A 레코드**: `injunweb.com` → 공인 IP 주소
- **A 레코드**: `*.injunweb.com` → 공인 IP 주소 (와일드카드 서브도메인)

와일드카드 서브도메인(`*.injunweb.com`)을 설정하면 별도로 등록하지 않은 모든 서브도메인이 동일한 IP로 해석되어 `hello.injunweb.com`, `blog.injunweb.com`, `api.injunweb.com` 등 어떤 서브도메인이든 별도 DNS 레코드 추가 없이 Traefik으로 라우팅되고, Traefik이 호스트 이름에 따라 적절한 서비스로 트래픽을 분배한다.

Cloudflare의 프록시 기능(주황색 구름 아이콘)을 활성화하면 모든 트래픽이 Cloudflare 서버를 경유하게 되어 DDoS 방어, 캐싱, WAF 등 보안 기능이 적용되고, 도메인의 실제 IP 주소가 숨겨져 직접적인 공격을 방지할 수 있다.

SSL/TLS 설정은 "Full" 또는 "Full (Strict)" 모드로 설정하여 Cloudflare와 원본 서버(Traefik) 간의 연결도 암호화하도록 구성한다.

### 2. 동적 DNS(DDNS) 설정

가정용 인터넷 서비스는 대부분 ISP(인터넷 서비스 제공자)가 동적으로 IP 주소를 할당하여 라우터 재부팅이나 임대 시간 만료 시 IP가 변경될 수 있으므로, IP 변경 시 자동으로 DNS 레코드를 업데이트하는 DDNS(Dynamic DNS) 설정이 필요하다.

처음에는 No-IP, DuckDNS, Dyn 같은 기존 DDNS 서비스들을 시도했으나 다음과 같은 제한사항이 있었다:

1. **서브도메인 제한**: 대부분의 무료 플랜에서는 제한된 수의 서브도메인만 제공하여 와일드카드 도메인 지원이 불가능하다.
2. **갱신 필요**: 무료 서비스는 보통 30일마다 수동으로 계정을 갱신해야 한다.
3. **맞춤 설정 제한**: API를 통한 세밀한 제어가 어렵고 특정 설정(프록시 활성화 등)을 조정할 수 없다.

이미 Cloudflare로 도메인을 관리하고 있었기 때문에 Cloudflare의 API와 Workers를 활용한 커스텀 DDNS 솔루션을 개발하기로 했으며, 이 방법으로 모든 제한사항을 해결하고 와일드카드 도메인과 다중 서브도메인을 손쉽게 관리할 수 있게 되었다.

#### Cloudflare Worker 구현

> **Cloudflare Workers란?**
>
> Cloudflare Workers는 Cloudflare의 글로벌 엣지 네트워크에서 JavaScript 코드를 실행할 수 있는 서버리스 플랫폼으로, 2017년에 출시되었으며 요청마다 코드가 실행되어 API 엔드포인트, 리다이렉트, 인증 등 다양한 용도로 사용할 수 있고 무료 플랜에서 하루 10만 건의 요청을 처리할 수 있다.

Cloudflare Worker를 생성하는 단계는 다음과 같다:

1. [Cloudflare 대시보드](https://dash.cloudflare.com)에 로그인한다.
2. 좌측 메뉴에서 "Workers & Pages"를 선택한다.
3. "Create Worker" 버튼을 클릭한다.
4. Worker 편집 화면에서 다음 코드를 붙여넣는다:

```javascript
const CONFIG = {
    API_TOKEN: "your-cloudflare-api-token",
    ZONE_ID: "your-cloudflare-zone-id",
    USE_BASIC_AUTH: true,
    USERNAME: "ddns-username",
    PASSWORD: "ddns-password",
    DEFAULT_TTL: 120,
    PROXY_ENABLED: false,
    DNS_RECORDS_IPV4: {
        "injunweb.com": "dns-record-id-for-domain",
    },
    DNS_RECORDS_IPV6: {},
};

const IP_PATTERNS = {
    IPv4: /^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}$/,
    IPv6: /^(?:(?:[a-fA-F\d]{1,4}:){7}(?:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){6}(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){5}(?::(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,2}|:)|(?:[a-fA-F\d]{1,4}:){4}(?:(?::[a-fA-F\d]{1,4}){0,1}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,3}|:)|(?:[a-fA-F\d]{1,4}:){3}(?:(?::[a-fA-F\d]{1,4}){0,2}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,4}|:)|(?:[a-fA-F\d]{1,4}:){2}(?:(?::[a-fA-F\d]{1,4}){0,3}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,5}|:)|(?:[a-fA-F\d]{1,4}:){1}(?:(?::[a-fA-F\d]{1,4}){0,4}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,6}|:)|(?::(?:(?::[a-fA-F\d]{1,4}){0,5}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,7}|:)))(?:%[0-9a-zA-Z]{1,})?$/,
};

const createResponse = (data, status = 200) => {
    return new Response(JSON.stringify(data), {
        status,
        headers: {
            "Content-Type": "application/json",
            "Cache-Control": "no-store, no-cache, must-revalidate",
        },
    });
};

const validateIPAddress = (ip) => {
    if (IP_PATTERNS.IPv4.test(ip)) return { valid: true, type: "A" };
    if (IP_PATTERNS.IPv6.test(ip)) return { valid: true, type: "AAAA" };
    return { valid: false, type: null };
};

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

async function handleRequest(request) {
    if (!checkAuthentication(request)) {
        return createResponse({ success: false, error: "Unauthorized" }, 401);
    }

    const url = new URL(request.url);
    const domain = url.searchParams.get("domain");
    if (!domain) {
        return createResponse({ success: false, error: "Domain name missing" }, 400);
    }

    const clientIP = request.headers.get("CF-Connecting-IP");
    if (!clientIP) {
        return createResponse({ success: false, error: "Could not determine client IP" }, 500);
    }

    const ipValidation = validateIPAddress(clientIP);
    if (!ipValidation.valid) {
        return createResponse({ success: false, error: "Invalid IP address format" }, 400);
    }

    const dnsRecords = ipValidation.type === "A" ? CONFIG.DNS_RECORDS_IPV4 : CONFIG.DNS_RECORDS_IPV6;
    const dnsRecordId = dnsRecords[domain];
    if (!dnsRecordId) {
        return createResponse({ success: false, error: "Domain not found" }, 404);
    }

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
            return createResponse({
                success: false,
                error: "Failed to update DNS record",
                details: result.errors?.[0]?.message || "Unknown error",
            }, 500);
        }
    } catch (error) {
        return createResponse({
            success: false,
            error: "Internal server error",
            details: error.message,
        }, 500);
    }
}

addEventListener("fetch", (event) => {
    event.respondWith(handleRequest(event.request));
});
```

이 Worker 코드는 다음과 같은 기능을 제공한다:

- **기본 인증**: 사용자 이름과 비밀번호로 요청을 인증하여 무단 접근을 방지한다.
- **IP 주소 검증**: 요청한 클라이언트의 IP가 유효한 IPv4 또는 IPv6 형식인지 확인한다.
- **DNS 레코드 업데이트**: Cloudflare API를 호출하여 지정된 도메인의 DNS 레코드를 클라이언트 IP로 업데이트한다.
- **응답 처리**: 성공 또는 실패 상태를 JSON 형식으로 반환하여 라우터가 결과를 파싱할 수 있도록 한다.

5. "Save and Deploy" 버튼을 클릭하여 Worker를 배포한다.
6. 배포가 완료되면 Worker URL(예: `your-worker.workers.dev`)을 메모한다.

#### Cloudflare API 토큰 및 DNS 레코드 ID 얻기

**API 토큰 생성**:

1. Cloudflare 대시보드에서 "My Profile" → "API Tokens" → "Create Token"으로 이동한다.
2. "Edit Zone DNS" 템플릿을 선택하거나 직접 "Zone.DNS" 편집 권한을 설정한다.
3. 특정 도메인에만 접근 가능하도록 Zone Resources를 제한한다.
4. 토큰을 생성하고 안전한 곳에 저장한다.

**Zone ID 찾기**:

Cloudflare 대시보드에서 도메인을 선택하고 "Overview" 페이지 오른쪽 사이드바에서 "Zone ID"를 찾는다.

**DNS 레코드 ID 찾기**:

터미널에서 다음 명령을 실행하여 도메인의 DNS 레코드 목록과 각 레코드의 ID를 조회한다:

```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/{Zone-ID}/dns_records" \
     -H "Authorization: Bearer {API-Token}" \
     -H "Content-Type: application/json"
```

응답에서 각 도메인의 `id` 필드를 찾아 Worker 코드의 `DNS_RECORDS_IPV4` 객체에 설정한다.

#### TP-Link 라우터 DDNS 설정

대부분의 라우터는 No-IP, DynDNS 같은 기본 DDNS 제공자를 지원하지만, 커스텀 DDNS 서비스를 사용하려면 라우터가 이 기능을 지원하는지 확인해야 한다. TP-Link 라우터는 "Custom" DDNS 옵션을 제공하여 임의의 DDNS 서비스를 구성할 수 있다.

![TP-Link DDNS 설정](image-1.png)

1. 라우터 관리 인터페이스에서 "Services" → "Dynamic DNS" → "Custom DNS"로 이동한다.
2. "Add" 버튼을 클릭하고 다음과 같이 설정한다:
    - **Update URL**: `http://[USERNAME]:[PASSWORD]@your-worker.workers.dev?domain=[DOMAIN]`
    - **Interface**: WAN 인터페이스
    - **Account Name** 및 **Password**: Worker 코드에서 설정한 USERNAME과 PASSWORD 값
    - **Domain Name**: 업데이트할 도메인(예: `injunweb.com`)

URL 형식에서 `[USERNAME]`, `[PASSWORD]`, `[DOMAIN]`은 플레이스홀더로 그대로 유지해야 하며, 라우터가 실제 값으로 자동 대체한다. `your-worker.workers.dev` 부분만 실제 Worker URL로 교체한다.

라우터가 보내는 요청에는 IP 주소가 쿼리 파라미터로 포함되지 않으므로 Worker에서 Cloudflare의 `CF-Connecting-IP` 헤더를 사용하여 요청한 클라이언트(라우터)의 공인 IP를 얻어온다.

### 3. 라우터 포트포워딩 설정

외부 인터넷에서 들어오는 HTTP(80)와 HTTPS(443) 트래픽이 홈 네트워크를 통과하여 쿠버네티스 클러스터의 Traefik에 도달할 수 있도록 라우터에서 포트포워딩을 설정한다.

1. 웹 브라우저에서 라우터 관리 페이지에 접속한다(일반적으로 `http://192.168.0.1` 또는 `http://192.168.1.1`).
2. 라우터 관리자 계정으로 로그인한다.
3. TP-Link 라우터의 경우 "Transmission" → "NAT" → "Virtual Servers" 메뉴로 이동한다.
4. 다음과 같이 두 개의 포트포워딩 규칙을 추가한다:

![라우터 포트포워딩](image-2.png)

| 외부 포트 | 내부 IP        | 내부 포트 | 프로토콜 |
| --------- | -------------- | --------- | -------- |
| 80        | 192.168.0.201  | 80        | TCP      |
| 443       | 192.168.0.201  | 443       | TCP      |

5. 설정을 저장하고 적용한다.

중요한 점은 내부 서버 IP를 **192.168.0.201**(외부용 로드밸런서)로 설정하는 것이며, 이렇게 하면 내부용 로드밸런서(192.168.0.200)는 포트포워딩 대상에서 제외되어 외부에서 완전히 격리된다.

## 외부 서비스 라우팅 구성

포트포워딩이 완료되었으니 이제 외부에서 접근 가능한 서비스에 대한 IngressRoute를 구성한다. 외부용 엔트리포인트인 `web`과 `websecure`를 사용하여 트래픽이 외부용 로드밸런서(192.168.0.201)를 통해 들어오도록 설정한다.

## Let's Encrypt 인증서 발급 확인

외부 접근이 가능해지면 Traefik의 Let's Encrypt 통합 기능이 HTTP-01 챌린지를 통해 도메인 소유권을 확인하고 SSL/TLS 인증서를 자동으로 발급한다. 인증서 발급 상태는 다음 명령으로 확인할 수 있다:

```bash
kubectl exec -n traefik $(kubectl get pods -n traefik -l app.kubernetes.io/name=traefik -o jsonpath='{.items[0].metadata.name}') -- cat /data/acme.json | jq
```

이 명령어는 Traefik 파드에 접속하여 인증서 정보가 저장된 `acme.json` 파일의 내용을 조회하며, `jq`는 JSON 데이터를 읽기 쉽게 포맷팅한다. 정상적으로 인증서가 발급되면 도메인별 인증서 정보가 표시되고, Traefik은 인증서 만료 30일 전부터 자동으로 갱신을 시도한다.

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

이 매니페스트는 세 가지 리소스를 정의한다:

1. **Deployment**: `nginxdemos/hello` 이미지를 실행하는 파드를 배포하며, 이 이미지는 서버 정보를 표시하는 간단한 Nginx 데모 페이지를 제공한다.
2. **Service**: 배포된 파드에 클러스터 내부에서 접근할 수 있는 ClusterIP 서비스를 생성한다.
3. **IngressRoute**: `hello.injunweb.com` 호스트에 대한 요청을 외부 엔트리포인트(`web`, `websecure`)를 통해 hello-world 서비스로 라우팅한다.

다음 명령으로 애플리케이션을 배포한다:

```bash
kubectl apply -f hello-world.yaml
```

## 접근 테스트

모든 구성이 완료되었으니 내부 및 외부 네트워크에서 접근이 가능한지 테스트한다.

### 내부 네트워크 테스트

내부 네트워크(홈 네트워크)에서 다음 URL로 각 서비스에 접근하여 정상적으로 표시되는지 확인한다:

- `http://traefik.injunweb.com/dashboard/` - Traefik 대시보드
- `http://argocd.injunweb.com` - ArgoCD UI
- `http://longhorn.injunweb.com` - Longhorn UI
- `http://hello.injunweb.com` - 테스트 애플리케이션

### 외부 네트워크 테스트

외부 네트워크(모바일 데이터 또는 다른 네트워크)에서 다음 URL로 접근하여 서비스 분리가 의도한 대로 작동하는지 확인한다:

- `https://traefik.injunweb.com/dashboard/` - 접근 불가 (의도한 대로)
- `https://argocd.injunweb.com` - 접근 불가 (의도한 대로)
- `https://longhorn.injunweb.com` - 접근 불가 (의도한 대로)
- `https://hello.injunweb.com` - 정상 접근 가능

내부 관리 서비스들은 외부에서 접근할 수 없고 테스트 애플리케이션만 외부에서 접근 가능하면 서비스 분리 전략이 의도한 대로 작동하는 것이다.

## 마치며

이번 글에서는 홈랩 쿠버네티스 클러스터의 서비스를 외부 인터넷에서 접근할 수 있도록 DDNS와 포트포워딩을 구성하는 방법을 살펴보았다. 내부용과 외부용 로드밸런서를 분리하고 포트포워딩 대상을 외부용 IP로만 설정함으로써 관리 인터페이스가 외부에 노출되는 것을 방지할 수 있다.

다음 글에서는 HashiCorp Vault를 설치하여 비밀번호, API 키 같은 민감한 정보를 안전하게 관리하는 방법을 알아본다.

[다음 글: 홈랩 쿠버네티스 #6 - HashiCorp Vault로 시크릿 관리하기](/posts/homelab-k8s-secrets/)
