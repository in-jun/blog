---
title: "Homelab Kubernetes #5 - External Access with DDNS and Port Forwarding"
date: 2025-02-26T14:07:36+09:00
draft: false
description: "This guide covers configuring Cloudflare DNS settings, implementing a custom DDNS Worker, and setting up router port forwarding to enable external internet access to services running in a homelab Kubernetes cluster."
tags: ["kubernetes", "homelab", "traefik", "cloudflare", "ddns", "gitops", "port-forwarding"]
series: ["Homelab Kubernetes"]
---

## Overview

In the [previous post](/posts/homelab-k8s-internal-services/), we installed the Traefik ingress controller and configured secure access to management interfaces by separating internal and external services. This post covers how to configure DDNS and port forwarding to enable external internet access to services running in the homelab Kubernetes cluster.

## Network Architecture Summary

First, let's briefly summarize the network architecture configured in the previous post:

1. **Internal Load Balancer (192.168.0.200)**: Exposes only management interfaces like ArgoCD, Longhorn, and Traefik dashboard, accessible only from within the internal network.
2. **External Load Balancer (192.168.0.201)**: Exposes only public services like blogs and personal projects, accessible from the external internet through router port forwarding.

![Network Architecture](image.png)

This design provides service-level separation that reduces the risk of accidentally exposing management interfaces to the outside. By setting port forwarding targets only to the external load balancer IP, the internal load balancer is completely isolated from external access.

## Configuring External Access

Three main steps are required to enable external internet access to Kubernetes services:

1. **Domain DNS Configuration**: Configure DNS records for the domain in Cloudflare.
2. **Dynamic IP Management (DDNS)**: Automatically update DNS records whenever the dynamic IP of home internet changes.
3. **Router Port Forwarding**: Forward incoming HTTP/HTTPS traffic from outside to Traefik in the Kubernetes cluster.

### 1. Cloudflare DNS Configuration

> **What is Cloudflare?**
>
> Cloudflare is a web infrastructure and security company founded in 2009 that provides CDN (Content Delivery Network) distributed across the globe, DDoS protection, DNS services, and WAF (Web Application Firewall). Its free plan offers powerful security features and DNS management capabilities, making it widely used in homelab environments.

Configure the domain's DNS records in the Cloudflare dashboard as follows:

- **A Record**: `injunweb.com` → Public IP address
- **A Record**: `*.injunweb.com` → Public IP address (wildcard subdomain)

Setting up a wildcard subdomain (`*.injunweb.com`) causes all subdomains not separately registered to resolve to the same IP. This means subdomains like `hello.injunweb.com`, `blog.injunweb.com`, and `api.injunweb.com` are all routed to Traefik without requiring separate DNS record additions, and Traefik distributes traffic to the appropriate service based on hostname.

Enabling Cloudflare's proxy feature (orange cloud icon) routes all traffic through Cloudflare servers, applying security features like DDoS protection, caching, and WAF, while also hiding the domain's actual IP address to prevent direct attacks.

Configure SSL/TLS settings to "Full" or "Full (Strict)" mode to encrypt the connection between Cloudflare and the origin server (Traefik) as well.

### 2. Dynamic DNS (DDNS) Configuration

Home internet services typically have ISPs (Internet Service Providers) dynamically assign IP addresses, which can change when routers reboot or lease times expire. This necessitates DDNS (Dynamic DNS) configuration to automatically update DNS records when IP changes occur.

Initially, existing DDNS services like No-IP, DuckDNS, and Dyn were tried, but they had the following limitations:

1. **Subdomain Limitations**: Most free plans provided only a limited number of subdomains, making wildcard domain support impossible.
2. **Renewal Requirements**: Free services usually required manual account renewal every 30 days.
3. **Limited Customization**: Fine-grained control through APIs was difficult, and certain settings (like enabling proxying) could not be adjusted.

Since the domain was already managed with Cloudflare, the decision was made to develop a custom DDNS solution using Cloudflare's API and Workers. This approach resolved all limitations and enabled easy management of wildcard domains and multiple subdomains.

#### Cloudflare Worker Implementation

> **What is Cloudflare Workers?**
>
> Cloudflare Workers is a serverless platform that allows JavaScript code to run on Cloudflare's global edge network. Launched in 2017, code executes on each request and can be used for various purposes including API endpoints, redirects, and authentication. The free plan allows processing up to 100,000 requests per day.

The steps to create a Cloudflare Worker are as follows:

1. Log in to the [Cloudflare dashboard](https://dash.cloudflare.com).
2. Select "Workers & Pages" from the left menu.
3. Click the "Create Worker" button.
4. Paste the following code in the Worker edit screen:

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

This Worker code provides the following functionality:

- **Basic Authentication**: Authenticates requests with username and password to prevent unauthorized access.
- **IP Address Validation**: Verifies that the requesting client's IP is a valid IPv4 or IPv6 format.
- **DNS Record Update**: Calls the Cloudflare API to update the DNS record of the specified domain to the client IP.
- **Response Handling**: Returns success or failure status in JSON format so the router can parse the result.

5. Click the "Save and Deploy" button to deploy the Worker.
6. Once deployment is complete, note the Worker URL (e.g., `your-worker.workers.dev`).

#### Obtaining Cloudflare API Token and DNS Record IDs

**Generate API Token**:

1. Navigate to "My Profile" → "API Tokens" → "Create Token" in the Cloudflare dashboard.
2. Select the "Edit Zone DNS" template or manually set "Zone.DNS" edit permission.
3. Restrict Zone Resources to allow access only to the specific domain.
4. Generate the token and store it securely.

**Find Zone ID**:

Select the domain in the Cloudflare dashboard and find "Zone ID" in the right sidebar of the "Overview" page.

**Find DNS Record IDs**:

Run the following command in the terminal to query the list of DNS records and each record's ID for the domain:

```bash
curl -X GET "https://api.cloudflare.com/client/v4/zones/{Zone-ID}/dns_records" \
     -H "Authorization: Bearer {API-Token}" \
     -H "Content-Type: application/json"
```

Find the `id` field for each domain in the response and set it in the `DNS_RECORDS_IPV4` object in the Worker code.

#### TP-Link Router DDNS Configuration

Most routers support default DDNS providers like No-IP and DynDNS, but if using a custom DDNS service, the router must support this capability. TP-Link routers provide a "Custom" DDNS option that allows configuring arbitrary DDNS services.

![TP-Link DDNS Configuration](image-1.png)

1. Navigate to "Services" → "Dynamic DNS" → "Custom DNS" in the router management interface.
2. Click the "Add" button and configure as follows:
    - **Update URL**: `http://[USERNAME]:[PASSWORD]@your-worker.workers.dev?domain=[DOMAIN]`
    - **Interface**: WAN interface
    - **Account Name** and **Password**: USERNAME and PASSWORD values set in the Worker code
    - **Domain Name**: The domain to update (e.g., `injunweb.com`)

In the URL format, `[USERNAME]`, `[PASSWORD]`, and `[DOMAIN]` are placeholders that should be kept as-is, as the router automatically substitutes them with actual values. Only replace the `your-worker.workers.dev` part with the actual Worker URL.

Since the router's request does not include the IP address as a query parameter, the Worker uses Cloudflare's `CF-Connecting-IP` header to obtain the public IP of the requesting client (router).

### 3. Router Port Forwarding Configuration

Configure port forwarding on the router so that HTTP (80) and HTTPS (443) traffic from the external internet can pass through the home network and reach Traefik in the Kubernetes cluster.

1. Access the router management page in a web browser (typically `http://192.168.0.1` or `http://192.168.1.1`).
2. Log in with the router administrator account.
3. For TP-Link routers, navigate to "Transmission" → "NAT" → "Virtual Servers" menu.
4. Add two port forwarding rules as follows:

![Router Port Forwarding](image-2.png)

| External Port | Internal IP   | Internal Port | Protocol |
| ------------- | ------------- | ------------- | -------- |
| 80            | 192.168.0.201 | 80            | TCP      |
| 443           | 192.168.0.201 | 443           | TCP      |

5. Save and apply the settings.

The important point is to set the Internal Server IP to **192.168.0.201** (external load balancer). This excludes the internal load balancer (192.168.0.200) from port forwarding targets, completely isolating it from external access.

## Configuring External Service Routing

With port forwarding complete, configure IngressRoutes for externally accessible services. Use the external entrypoints `web` and `websecure` so that traffic enters through the external load balancer (192.168.0.201).

## Verifying Let's Encrypt Certificate Issuance

Once external access is available, Traefik's Let's Encrypt integration verifies domain ownership through HTTP-01 challenge and automatically issues SSL/TLS certificates. Certificate issuance status can be checked with the following command:

```bash
kubectl exec -n traefik $(kubectl get pods -n traefik -l app.kubernetes.io/name=traefik -o jsonpath='{.items[0].metadata.name}') -- cat /data/acme.json | jq
```

This command accesses the Traefik pod to query the contents of the `acme.json` file where certificate information is stored, and `jq` formats the JSON data for readability. When certificates are successfully issued, certificate information for each domain is displayed, and Traefik automatically attempts renewal starting 30 days before certificate expiration.

## Deploying a Test Application

Deploy a simple test application to verify the configuration is working properly:

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

This manifest defines three resources:

1. **Deployment**: Deploys a pod running the `nginxdemos/hello` image, which provides a simple Nginx demo page displaying server information.
2. **Service**: Creates a ClusterIP service to access the deployed pods from within the cluster.
3. **IngressRoute**: Routes requests for the `hello.injunweb.com` host to the hello-world service through external entrypoints (`web`, `websecure`).

Deploy the application with the following command:

```bash
kubectl apply -f hello-world.yaml
```

## Access Testing

With all configuration complete, test whether access is available from both internal and external networks.

### Internal Network Test

From the internal network (home network), access each service through the following URLs and verify they display properly:

- `http://traefik.injunweb.com/dashboard/` - Traefik dashboard
- `http://argocd.injunweb.com` - ArgoCD UI
- `http://longhorn.injunweb.com` - Longhorn UI
- `http://hello.injunweb.com` - Test application

### External Network Test

From an external network (mobile data or another network), access the following URLs and verify that service separation is working as intended:

- `https://traefik.injunweb.com/dashboard/` - Not accessible (as intended)
- `https://argocd.injunweb.com` - Not accessible (as intended)
- `https://longhorn.injunweb.com` - Not accessible (as intended)
- `https://hello.injunweb.com` - Accessible normally

If internal management services are not accessible from outside and only the test application is accessible from outside, the service separation strategy is working as intended.

## Conclusion

This post covered configuring DDNS and port forwarding to enable external internet access to homelab Kubernetes cluster services. By separating internal and external load balancers and setting port forwarding targets only to the external IP, exposure of management interfaces to the outside can be prevented.

The next post covers installing HashiCorp Vault to securely manage sensitive information like passwords and API keys.

[Next Post: Homelab Kubernetes #6 - Secret Management with HashiCorp Vault](/posts/homelab-k8s-secrets/)
