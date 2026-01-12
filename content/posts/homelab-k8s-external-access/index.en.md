---
title: "Homelab #5 - Configuring External Access"
date: 2025-02-26T14:07:36+09:00
draft: false
description: "Learn how to configure external access to a homelab Kubernetes cluster and set up DDNS using Cloudflare."
tags: ["kubernetes", "homelab", "traefik", "cloudflare", "ddns", "gitops"]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-internal-services), we installed the Traefik ingress controller in our homelab Kubernetes cluster and configured secure access to internal management services. In this post, we will explore how to configure external access to services running in the homelab Kubernetes cluster.

## Network Architecture Summary

First, let's briefly summarize our network architecture:

1. **Internal Load Balancer (192.168.0.200)**: Exposes only management interfaces and is accessible only from the internal network
2. **External Load Balancer (192.168.0.201)**: Exposes only public services and is accessible from outside through port forwarding

![Network Architecture](image.png)

This design provides separation at the service level, reducing the risk of accidentally exposing critical management interfaces to the outside.

## Configuring External Access

To access Kubernetes services from outside, three main steps are required:

1. Domain DNS configuration (Cloudflare)
2. Dynamic IP management (DDNS)
3. Router port forwarding

### 1. Cloudflare DNS Configuration

Add the following DNS records in the Cloudflare dashboard:

-   A record: `injunweb.com` → Public IP address
-   A record: `*.injunweb.com` → Public IP address (wildcard subdomain)

Configuring a wildcard subdomain (`*.injunweb.com`) allows all subdomains that are not separately registered to resolve to the same IP. This makes management convenient because you don't need to add a DNS record every time you add a new service. For example, subdomains like `hello.injunweb.com`, `blog.injunweb.com`, and `api.injunweb.com` all connect to the same IP without separate configuration. Traefik then routes to the appropriate service based on the hostname.

Cloudflare's proxy feature (orange cloud icon) provides several security features including DDoS protection, caching, and Web Application Firewall (WAF). When this feature is enabled, requests are routed through Cloudflare's servers, which also has the effect of hiding the actual IP address of the domain.

Cloudflare's SSL/TLS setting should be set to "Full" mode to encrypt the connection between Cloudflare and the server as well.

### 2. Dynamic DNS (DDNS) Configuration

Home internet connections typically use dynamic IPs, so DDNS configuration is necessary. Initially, I tried existing DDNS services like No-IP, DuckDNS, and Dyn. However, these services had several limitations:

1. **Subdomain limitations**: Most free plans provided only a limited number of subdomains.
2. **Renewal requirements**: Free services usually required manual renewal every 30 days.
3. **Limited customization**: Fine-grained control through APIs was difficult.

Since I was already managing the domain with Cloudflare, developing a custom DDNS solution using Cloudflare's API and Workers was a better choice. This approach resolved all limitations and made it easy to manage wildcard domains and multiple subdomains in particular.

#### Cloudflare Worker Implementation

Steps to create a Cloudflare Worker:

1. Log in to the [Cloudflare dashboard](https://dash.cloudflare.com).
2. Select "Workers & Pages" from the left menu.
3. Click the "Create Worker" button.
4. Paste the following code in the Worker edit screen:

```javascript
const CONFIG = {
    API_TOKEN: "your-cloudflare-api-token", // Cloudflare API token
    ZONE_ID: "your-cloudflare-zone-id", // Zone ID for your domain
    USE_BASIC_AUTH: true, // Whether to use basic authentication
    USERNAME: "ddns-username", // Authentication username
    PASSWORD: "ddns-password", // Authentication password
    DEFAULT_TTL: 120, // DNS record TTL
    PROXY_ENABLED: false, // Whether to enable Cloudflare proxy
    DNS_RECORDS_IPV4: {
        "injunweb.com": "dns-record-id-for-domain", // Domain and DNS record ID
    },
    DNS_RECORDS_IPV6: {}, // IPv6 records (add if needed)
};

// IP pattern validation regex
const IP_PATTERNS = {
    IPv4: /^(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}$/,
    IPv6: /^(?:(?:[a-fA-F\d]{1,4}:){7}(?:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){6}(?:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|:[a-fA-F\d]{1,4}|:)|(?:[a-fA-F\d]{1,4}:){5}(?::(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,2}|:)|(?:[a-fA-F\d]{1,4}:){4}(?:(?::[a-fA-F\d]{1,4}){0,1}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,3}|:)|(?:[a-fA-F\d]{1,4}:){3}(?:(?::[a-fA-F\d]{1,4}){0,2}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,4}|:)|(?:[a-fA-F\d]{1,4}:){2}(?:(?::[a-fA-F\d]{1,4}){0,3}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,5}|:)|(?:[a-fA-F\d]{1,4}:){1}(?:(?::[a-fA-F\d]{1,4}){0,4}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,6}|:)|(?::(?:(?::[a-fA-F\d]{1,4}){0,5}:(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)(?:\\.(?:25[0-5]|2[0-4]\d|1\d\d|[1-9]\d|\d)){3}|(?::[a-fA-F\d]{1,4}){1,7}|:)))(?:%[0-9a-zA-Z]{1,})?$/,
};

// Response creation function
const createResponse = (data, status = 200) => {
    return new Response(JSON.stringify(data), {
        status,
        headers: {
            "Content-Type": "application/json",
            "Cache-Control": "no-store, no-cache, must-revalidate",
        },
    });
};

// IP address validation function
const validateIPAddress = (ip) => {
    if (IP_PATTERNS.IPv4.test(ip)) return { valid: true, type: "A" };
    if (IP_PATTERNS.IPv6.test(ip)) return { valid: true, type: "AAAA" };
    return { valid: false, type: null };
};

// Basic authentication check function
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

// DNS record update function
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

// Request handling function
async function handleRequest(request) {
    // Check authentication
    if (!checkAuthentication(request)) {
        return createResponse({ success: false, error: "Unauthorized" }, 401);
    }

    // Check domain parameter
    const url = new URL(request.url);
    const domain = url.searchParams.get("domain");
    if (!domain) {
        return createResponse(
            { success: false, error: "Domain name missing" },
            400
        );
    }

    // Get client IP address
    const clientIP = request.headers.get("CF-Connecting-IP");
    if (!clientIP) {
        return createResponse(
            { success: false, error: "Could not determine client IP" },
            500
        );
    }

    // Validate IP address format
    const ipValidation = validateIPAddress(clientIP);
    if (!ipValidation.valid) {
        return createResponse(
            { success: false, error: "Invalid IP address format" },
            400
        );
    }

    // Find DNS record ID
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

    // Update DNS record
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

// Worker event listener
addEventListener("fetch", (event) => {
    event.respondWith(handleRequest(event.request));
});
```

This code provides the following key features:

1. **Basic authentication**: Authenticates requests using username and password.
2. **IP address validation**: Verifies that the client IP format is valid.
3. **DNS record update**: Updates DNS records using the Cloudflare API.
4. **Response handling**: Returns success or failure status in JSON format.

5. Click the "Save and Deploy" button.
6. Once deployment is complete, note the Worker name. You will use this name (e.g., `your-worker.workers.dev`) in the router configuration.

#### Obtaining Cloudflare API Token and DNS Record IDs

1. **Generate API token**:

    - Navigate to "My Profile" → "API Tokens" → "Create Token" in the Cloudflare dashboard.
    - Select the "Edit Zone DNS" template or set permissions manually.
    - Restrict access to only the specific domain.
    - Generate the token and store it securely.

2. **Find Zone ID**:

    - Navigate to your domain in the Cloudflare dashboard.
    - Find the "Zone ID" in the right sidebar of the "Overview" page.

3. **Find DNS record IDs**:
    - Run the following command in a terminal:
        ```bash
        curl -X GET "https://api.cloudflare.com/client/v4/zones/{Zone-ID}/dns_records" \
             -H "Authorization: Bearer {API-Token}" \
             -H "Content-Type: application/json"
        ```
    - Find the `id` field for each domain in the response and set it in the `DNS_RECORDS_IPV4` object.

#### TP-Link Router DDNS Configuration

DDNS configuration options vary widely across router manufacturers. For TP-Link routers, most natively support well-known DDNS providers such as No-IP and DynDNS. I initially tried to use these default services, but decided to use custom DDNS configuration due to the limitations mentioned above.

Fortunately, TP-Link routers provide a "Custom" DDNS service option:

![TP-Link DDNS Configuration](image-1.png)

1. Navigate to "Services" → "Dynamic DNS" → "Custom DNS" in the router management interface.
2. Click the "Add" button and configure as follows:

    - **Update URL**: `http://[USERNAME]:[PASSWORD]@your-worker.workers.dev?domain=[DOMAIN]`
    - **Interface**: The network interface you are using (typically WAN)
    - **Account Name** and **Password**: Values set in the Worker code
    - **Domain Name**: The domain name to update
      (Replace "your-worker.workers.dev" with your Worker URL here, and keep [USERNAME], [PASSWORD], and [DOMAIN] as-is. The router automatically substitutes these with the appropriate values.)

The URL format was particularly tricky. Initially, I filled in the actual values but it did not work. After several attempts, I discovered that placeholders like [USERNAME], [PASSWORD], and [DOMAIN] must be left as-is for the router to automatically substitute them. Additionally, requests sent by the router did not include its own IP address as a query parameter. Instead, the Worker had to use Cloudflare's "CF-Connecting-IP" header to obtain the IP of the requesting client.

### 3. Router Port Forwarding Configuration

Finally, port forwarding must be configured on the router so that incoming traffic from outside can pass through the home network and reach Traefik in the Kubernetes cluster:

1.  Access the router management page in a web browser (typically `http://192.168.0.1` or `http://192.168.1.1`).
2.  Log in with the router administrator account.
3.  For TP-Link routers, navigate to "Transmission" → "NAT" → "Virtual Servers" menu.
4.  Add two rules as follows:

    ![Router Port Forwarding](image-2.png)

5.  Save and apply the settings.

The important point is to set the Internal Server IP to **192.168.0.201**. This completely isolates the internal load balancer (192.168.0.200) from outside access. This prevents the risk of accidentally exposing management services to the outside.

## Configuring External Service Routing

Now we configure ingress routes for externally accessible services. Let's deploy a simple web application for testing:

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

The key point here is setting the `entryPoints` to `web` and `websecure` to make it accessible from outside. In the earlier Traefik configuration, these entry points are connected to the external load balancer (192.168.0.201).

## Verifying Let's Encrypt Certificate Issuance

Once external access is available, Let's Encrypt can verify domain ownership through HTTP challenge and automatically issue SSL/TLS certificates. Certificate issuance status can be checked with the following command:

```bash
kubectl exec -n traefik $(kubectl get pods -n traefik -l app.kubernetes.io/name=traefik -o jsonpath='{.items[0].metadata.name}') -- cat /data/acme.json | jq
```

This command accesses the Traefik pod and checks the contents of the acme.json file where certificate information is stored. jq formats the JSON data for readability.

When certificates are issued successfully, certificate information is stored in the `acme.json` file. Traefik then automatically renews certificates when their expiration approaches.

## Deploying a Test Application

Deploy a simple test application to verify the configuration works properly:

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

1. **Deployment**: Deploys a pod running the nginxdemos/hello image.
2. **Service**: Creates a service to access the deployed pods.
3. **IngressRoute**: Sets up routing rules to access the service through the hello.injunweb.com domain.

Deploy the application with the following command:

```bash
kubectl apply -f hello-world.yaml
```

## Access Testing

Now that all configuration is complete, let's test access from both internal and external networks.

### 1. Internal Network Test

From the internal network, access each service through the following URLs:

-   http://traefik.injunweb.com/dashboard/ - Traefik dashboard
-   http://argocd.injunweb.com - ArgoCD UI
-   http://longhorn.injunweb.com - Longhorn UI
-   http://hello.injunweb.com - Test application

Verify that all services are accessible normally.

### 2. External Network Test

Now access the following URLs from an external network (e.g., mobile data network):

-   https://traefik.injunweb.com/dashboard/ - Not accessible (as intended)
-   https://argocd.injunweb.com - Not accessible (as intended)
-   https://longhorn.injunweb.com - Not accessible (as intended)
-   https://hello.injunweb.com - Accessible

Verify that internal management services are not accessible from outside, and only the test application is accessible from outside. This demonstrates that the service separation strategy is working as intended.

## Conclusion

In this post, we explored how to install the Traefik ingress controller in a homelab Kubernetes cluster and configure safe separation and access for internal services and external services. We also implemented a custom DDNS solution for domain management in a dynamic IP environment.

In the [next post](homelab-k8s-secrets), we will learn how to install Vault in the homelab Kubernetes cluster to securely manage secrets.
