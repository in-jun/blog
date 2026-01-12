---
title: "Homelab #6 - Secret Management with Vault"
date: 2025-02-26T16:20:14+09:00
draft: false
description: "This guide explains how to install HashiCorp Vault in a homelab Kubernetes environment and build a secure secret management system."
tags: ["kubernetes", "homelab", "vault", "secrets", "gitops", "security"]
series: ["Homelab"]
---

## Overview

In the [previous post](homelab-k8s-external-access), we installed the Traefik ingress controller on our homelab Kubernetes cluster and configured external access. This post covers installing and configuring HashiCorp Vault for securely managing sensitive information (passwords, API keys, certificates, etc.) in the Kubernetes cluster.

![Vault Logo](image.png)

## Why Default Kubernetes Secrets Were Insufficient

Secret management proved challenging while building the homelab environment using the GitOps approach. Several limitations became clear when using default Kubernetes Secrets.

First, there is the integration issue with GitOps. Secrets cannot be stored directly in Git, and even base64 encoding is vulnerable to security risks since it can be easily decoded. While we reviewed tools like Sealed Secrets and SOPS, we needed a comprehensive secret management solution beyond simple encryption.

Second, there is the secret rotation problem. External API tokens and certificates require periodic renewal, but manual handling is inefficient. Automated secret rotation management was necessary.

HashiCorp Vault solves these problems. It provides secret encryption, access control, and automatic renewal features along with Kubernetes integration. It also offers methods to integrate with GitOps workflows, which led to its selection.

## Installing Vault in the Homelab Environment

### 1. Preparing Directories for GitOps Configuration

Since everything in the homelab environment is managed through GitOps, Vault installation follows the same approach. First, create the necessary directory structure.

```bash
mkdir -p k8s-resources/apps/vault/templates
cd k8s-resources/apps/vault
```

### 2. Helm Chart Configuration

Create the `Chart.yaml` file as follows.

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

Add Vault settings to the `values.yaml` file.

```yaml
vault:
    server:
        enabled: true

    ui:
        enabled: true # Enable web-based management UI
```

High availability configuration was considered, but it was deemed wasteful of resources in the homelab environment. The approach was to upgrade later if needed.

### 3. Ingress Configuration

Configure an ingress route to access the Vault UI. This uses the Traefik ingress controller configured previously.

`templates/ingressroute.yaml` file:

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

Setting `entryPoints` to `intweb` and `intwebsec` ensures the Vault UI is only accessible from the internal network. External exposure poses a security risk since it is a secret management interface.

### 4. Add Changes to GitHub and Deploy with ArgoCD

```bash
git add .
git commit -m "Add Vault Helm chart configuration"
git push origin main
```

## Vault Initialization and Unsealing

After Vault installation, two important steps are required: initialization and unsealing. These processes involve encryption key generation and activation. They are performed manually rather than automated for security reasons.

### 1. Perform Initialization

Access the Vault pod to perform initialization.

```bash
# Access Vault server
kubectl -n vault exec -it vault-0 -- /bin/sh

# Perform initialization (default 5 keys, 3 required)
vault operator init
```

Execution result:

```
Unseal Key 1: wO14Gu9jIfGtae33/8U3l9mFv9QERnQS/IMoA1jJZ0vF
Unseal Key 2: FfL8J4QoIP/7fRrKJ7NN/5W8zG2ODzL9MiCJV5UcQmjx
Unseal Key 3: IgNkd4APfXmJywTqh+JjWbkiVgEHBTS+wjUGy/mtQ1pL
Unseal Key 4: +3Q0TUmCtw91/TNjdg7+dIh/8tHmfkoMykMTB9BPkMKn
Unseal Key 5: tJGLuUEYjpXc+K2jjxnMZ2JW7BUQ0KVYq7pGGBhEFLvG

Initial Root Token: hvs.6xu4j8TSoFBJ3EFNpW791e0I
```

> **Warning**: These keys are examples only. In a real environment, this information should never be disclosed. Store them securely in a password manager.

### 2. Perform Unsealing

After initialization, the unsealing process is required. Use 3 of the 5 keys to unseal Vault.

```bash
# Perform unsealing (3 keys required)
vault operator unseal wO14Gu9jIfGtae33/8U3l9mFv9QERnQS/IMoA1jJZ0vF
vault operator unseal FfL8J4QoIP/7fRrKJ7NN/5W8zG2ODzL9MiCJV5UcQmjx
vault operator unseal IgNkd4APfXmJywTqh+JjWbkiVgEHBTS+wjUGy/mtQ1pL
```

After entering the third key, Vault becomes active. Check status:

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

The `Sealed: false` indication means unsealing was successful.

The use of Shamir's Secret Sharing algorithm is noteworthy. In enterprise environments, these 5 keys are distributed to different administrators so that Vault can only be opened with the agreement of at least 3 people, implementing the four-eyes principle. Although managed by one person in the homelab, this provides experience with enterprise security principles.

## Accessing the Vault Web UI

Once Vault is active, it can be managed through the web UI. Add the following entry to the hosts file.

```
192.168.0.200 vault.injunweb.com
```

Access `http://vault.injunweb.com` in a browser to see the Vault UI. Use the root token obtained during initialization for login.

![Vault UI Login](image-1.png)

Dashboard displayed after login:

![Vault Dashboard](image-2.png)

The UI is intuitively organized, allowing efficient execution of complex policy settings and secret management tasks.

## Configuring Vault Basics

Once Vault installation and initialization are complete, proceed with basic configuration for Kubernetes integration.

### 1. Kubernetes Authentication Setup

Using Kubernetes authentication allows pods to authenticate to Vault with their service account tokens. Access the Vault pod and execute the following commands.

```bash
# Vault login (using root token)
vault login hvs.6xu4j8TSoFBJ3EFNpW791e0I

# Enable Kubernetes authentication
vault auth enable kubernetes

# Configure Kubernetes authentication
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_PORT_443_TCP_ADDR:443" \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_ca_cert="$(cat /var/run/secrets/kubernetes.io/serviceaccount/ca.crt)" \
  issuer="https://kubernetes.default.svc.cluster.local"
```

This configuration enables Vault to verify the validity of Kubernetes service account tokens.

### 2. Enable KV Secret Engine

The Key-Value (KV) engine is the most basic secret storage method. Enable the version 2 engine.

```bash
vault secrets enable -path=secret kv-v2
```

KV version 2 provides useful features like secret versioning and soft deletion.

### 3. Create Policy and Role

Policies are the core of access control in Vault. Create a sample policy for application use.

```bash
# Create sample policy
cat <<EOF > app-policy.hcl
# Read permission for all secrets under app/* path
path "secret/data/app/*" {
  capabilities = ["read"]
}

# Read permission for metadata under app/* path
path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}
EOF

# Register policy
vault policy write app-policy app-policy.hcl
```

Then create a role for Kubernetes authentication.

```bash
# Create Kubernetes authentication role
vault write auth/kubernetes/role/app \
  bound_service_account_names=app \
  bound_service_account_namespaces=default \
  policies=app-policy \
  ttl=1h
```

This configuration means that when the `app` service account in the `default` namespace authenticates to Vault, the `app-policy` policy applies and the token expires after 1 hour.

### 4. Create Sample Secret

Create a sample secret for testing.

```bash
# Create KV version 2 secret
vault kv put secret/app/config \
  db.username="dbuser" \
  db.password="supersecret" \
  api.key="api12345"

# Verify created secret
vault kv get secret/app/config
```

Secret verification result:

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

Now basic secrets are stored in Vault. Next, implement two methods for using these secrets in Kubernetes applications.

## Installing Vault Secrets Operator

The first approach is to use the Vault Secrets Operator. This Operator automatically synchronizes Vault secrets to Kubernetes Secrets. It has the advantage of enabling Vault secret usage without changing existing application code.

### 1. Add Operator Configuration

`k8s-resources/apps/vault-secrets-operator/Chart.yaml` file:

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

`k8s-resources/apps/vault-secrets-operator/values.yaml` file:

```yaml
vault-secrets-operator:
    defaultVaultConnection:
        enabled: true
        address: "http://vault.vault.svc.cluster.local:8200" # Vault address within cluster
```

This configuration provides basic information for the Operator to access Vault.

### 2. Create Vault Role for Operator

Access Vault to create a policy and role for the Operator.

```bash
# Create policy file
cat <<EOF > operator-policy.hcl
# Read permission for secrets under app/* path
path "secret/data/app/*" {
  capabilities = ["read"]
}

# Read permission for metadata under app/* path
path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}
EOF

# Register policy
vault policy write operator-policy operator-policy.hcl

# Create role
vault write auth/kubernetes/role/vault-secrets-operator \
  bound_service_account_names=vault-secrets-operator \
  bound_service_account_namespaces=vault-secrets-operator \
  policies=operator-policy \
  ttl=1h
```

### 3. Add to Git and Deploy

```bash
cd k8s-resources
git add apps/vault-secrets-operator
git commit -m "Add Vault Secrets Operator configuration"
git push origin main
```

Verify after deployment:

```bash
kubectl get pods -n vault-secrets-operator
```

Result:

```
NAME                                      READY   STATUS    RESTARTS   AGE
vault-secrets-operator-75bcd5b69d-x2jf9   2/2     Running   0          45s
```

## Configuring Secret Synchronization Resources

Configure settings to synchronize Vault secrets to Kubernetes Secrets through the Vault Secrets Operator.

### 1. Create VaultAuth Resource

The `VaultAuth` resource defines how to authenticate to Vault.

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultAuth
metadata:
    name: default
    namespace: default
spec:
    method: kubernetes # Authentication method (Kubernetes)
    mount: kubernetes # Vault authentication mount path
    kubernetes:
        role: vault-secrets-operator # Vault Kubernetes authentication role
        serviceAccount: default # Service account to use
```

### 2. Create VaultStaticSecret Resource

The `VaultStaticSecret` resource specifies synchronization of a specific Vault secret to a Kubernetes Secret.

```yaml
apiVersion: secrets.hashicorp.com/v1beta1
kind: VaultStaticSecret
metadata:
    name: app-config
    namespace: default
spec:
    type: kv-v2 # Secret engine type
    mount: secret # Secret engine mount path
    path: app/config # Vault secret path
    destination:
        name: app-config # Kubernetes Secret name to create
        create: true # Create Secret if it doesn't exist
    refreshAfter: 30s # Synchronize every 30 seconds
    vaultAuthRef: default # VaultAuth resource to use
```

The `refreshAfter: 30s` setting ensures that when secrets change in Vault, the Kubernetes Secret is automatically updated within 30 seconds.

### 3. Deploy and Verify

```bash
kubectl apply -f vault-auth.yaml
kubectl apply -f static-secret.yaml
```

Verify Secret creation:

```bash
kubectl get secret app-config
```

Result:

```
NAME        TYPE     DATA   AGE
app-config  Opaque   3      15s
```

Verify secret contents:

```bash
kubectl get secret app-config -o jsonpath="{.data.db\.password}" | base64 -d
```

### 4. Test Automatic Secret Renewal

Verify that when a secret changes in Vault, the Kubernetes Secret is automatically updated:

```bash
# Change secret in Vault
vault kv put secret/app/config \
  db.username="dbuser" \
  db.password="newpassword" \
  api.key="newapi12345"

# Check Kubernetes Secret after 30 seconds
kubectl get secret app-config -o jsonpath="{.data.db\.password}" | base64 -d
```

If the result changes to `newpassword`, automatic renewal is working correctly.

## Installing ArgoCD Vault Plugin

The second approach is to configure the ArgoCD Vault Plugin. This plugin integrates deeply with GitOps workflows by storing only secret references in the Git repository and replacing them with actual values when ArgoCD deploys.

### 1. Modify ArgoCD Helm Chart Values File

Add the following content to the `k8s-resources/apps/argocd/values.yaml` file:

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

### 2. Create Vault Role for ArgoCD

Access Vault to create a policy and role for ArgoCD:

```bash
# Create ArgoCD policy
cat <<EOF > argocd-policy.hcl
# Read permission for secrets under app/* path
path "secret/data/app/*" {
  capabilities = ["read"]
}

# Read permission for metadata under app/* path
path "secret/metadata/app/*" {
  capabilities = ["read", "list"]
}
EOF

# Register policy
vault policy write argocd argocd-policy.hcl

# Create Kubernetes authentication role
vault write auth/kubernetes/role/argocd \
  bound_service_account_names=argocd-repo-server \
  bound_service_account_namespaces=argocd \
  policies=argocd \
  ttl=1h
```

### 3. Create Authentication Secret

Create the `k8s-resources/apps/argocd/templates/avp-secret.yaml` file:

```yaml
apiVersion: v1
kind: Secret
metadata:
    name: argocd-vault-plugin-credentials
    namespace: argocd
type: Opaque
stringData:
    AVP_AUTH_TYPE: "k8s" # Kubernetes authentication method
    AVP_K8S_ROLE: "argocd" # Vault role name
    AVP_TYPE: "vault" # Vault type
    VAULT_ADDR: "http://vault.vault.svc.cluster.local:8200" # Vault address
```

### 4. Create ConfigMap

`k8s-resources/apps/argocd/templates/configmap.yaml` file:

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

## Using Secrets in Applications

Now Vault secrets can be used in applications through two methods.

### 1. Using Secrets Synchronized by Vault Secrets Operator

Simple test Deployment:

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
                                name: app-config # Secret synchronized by Operator
                                key: db.password
```

The advantage of this method is that no modification to existing application code is needed. The standard Kubernetes Secret reference method is used as is.

```bash
kubectl apply -f demo-app.yaml
```

### 2. Using Secrets Replaced by ArgoCD Vault Plugin

Deployment using plugin reference:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
    name: demo-app-avp
    namespace: default
    annotations:
        avp.kubernetes.io/path: "secret/data/app/config" # Vault path
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
                        value: <path:secret/data/app/config#db.password> # Placeholder
```

The advantage of this method is that secret values are not stored in Git. Only placeholders like `<path:secret/data/app/config#db.password>` are stored in Git, and actual values are retrieved from Vault by ArgoCD at deployment time.

When creating an application in ArgoCD, select "argocd-vault-plugin" as the Config Management Plugin. ArgoCD will then replace `<path:...>` format references with actual values before applying manifests to the cluster.

## Conclusion

This post covered installing Vault in a homelab Kubernetes cluster and building a secure secret management system. It also explored managing secrets in a GitOps manner through the ArgoCD Vault Plugin and Vault Secrets Operator.

In the [next post](homelab-k8s-cicd-1), we will explore building a CI/CD pipeline.
