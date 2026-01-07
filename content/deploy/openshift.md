---
title: 'Red Hat OpenShift ClickOps Installation'
date: '2023-10-18T15:02:24-03:00'
categories: ["how-to"]
description: How to install Rhize on the Red Had OpenShift platform using the Red Hat OpenShift Console
weight: 600
---

This procedure will guide you through the installation of Rhize, including monitoring applications on the Red Hat OpenShift platform v4.x.x.

Prerequisites:

 - Red Hat OpenShift Platform running
 - kubeadmin permissions to 
    - create/list namespaces
    - create/list cluster Helm chart repositories
    - create secret in `openshift-config` namespace
    - create release
 - Your cluster has access to public Helm chart repositories
 - OpenShift CLI `oc` available

## 1. Create the OpenShift Projects

With the Red Hat OpenShift Console:
1. Login using your existing credentials.
1. Using the left hand menu, navigate to _Home_ and _Projects_.
1. Click _Create Project_ and create the following projects:
   - rhize
   - monitoring
   - cnpg-operator
1. Click _Create_ for each project.

> The 'rhize', 'monitoring', and 'cloudnative-pg-operator' projects have now been created

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.

## 2. Configure Helm Chart Repositories

{{% steps %}}

### Add Libre Helm Chart Secret

The Libre Helm chart repository requires authentication to access. Create a secret using the Red Hat OpenShift command line utility using your provided access token.

```shell
$ oc create secret generic libre-helmchart-repository --from-literal=username='tom561' --from-literal=password='glpat-XXXXX' --namespace openshift-config
```

Now that the secret is configured, we can use it in the next step to create the Helm chart repositories.

### Add Helm Chart Repositories

With the Red Hat OpenShift Console:
1. Login using your existing credentials.
1. Using the left hand menu, navigate to _Helm_ and _Repositories_.
1. Click _Create Helm Repository_ and create the following Helm Chart Repositories (HCR).

| Type           | name                 | label                | url                                                              |
| :------------- | :------------------- | :------------------- | :--------------------------------------------------------------- |
| Cluster Scoped | appsmith-ee          | appsmith-ee          | https://helm-ee.appsmith.com                                     |
| Cluster Scoped | cloudnative-pg       | cloudnative-pg       | https://cloudnative-pg.github.io/charts                          |
| Cluster Scoped | codecentric          | codecentric          | https://codecentric.github.io/helm-charts                        |
| Cluster Scoped | grafana              | grafana              | https://grafana.github.io/helm-charts                            |
| Cluster Scoped | libre                | libre                | https://gitlab.com/api/v4/projects/42214456/packages/helm/stable |
| Cluster Scoped | prometheus-community | prometheus-community | https://prometheus-community.github.io/helm-charts               |
| Cluster Scoped | questdb              | questdb              | https://helm.questdb.io                                          |
| Cluster Scoped | redpanda             | redpanda             | https://charts.redpanda.com                                      |

Example configured helm repositories:
![redhat-openshift-console-helm-repositories](./images/helm-chart-repositories.png)

{{% /steps %}}

## 3. Install CloudNativePG Postgres Operator

{{% steps %}}

### Install the CloudNativePG Operator

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'cloudnative-pg-operator' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'cloudnative-pg'
1. In the search filter for 'cloudnative-pg'
1. Click the 'cloudnative-pg' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below
   ```YAML {filename="Values.yaml",linenos=table}
   config:
     clusterWide: true
     create: true
   containerSecurityContext: null
   crds:
     create: true
   image:
     pullPolicy: IfNotPresent
     repository: ghcr.io/cloudnative-pg/cloudnative-pg
     tag: ''
   monitoring:
     grafanaDashboard:
        configMapName: cnpg-grafana-dashboard
        create: true
        namespace: monitoring
   podSecurityContext: null
   rbac:
     aggregateClusterRoles: false
     create: true
   replicaCount: 1
   serviceAccount:
     create: true
     name: ''
   ```
{{% /steps %}}

## 4. Install Monitoring Applications

| Rhize recommends a separate namespace for monitoring¹

{{% steps %}}

### Install prometheus
1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'monitoring' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'prometheus-community'
1. In the search filter for 'prometheus'
1. Click the 'prometheus' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select version '27.52.0 / App Version v3.8.1 (Provided by Prometheus Community)' from the drop down.
1. Make any environmental specific changes in the _YAML view_, including changing the replicas to 2  
   ```YAML {filename="Values.yaml",linenos=table}
   alertmanager:
     enabled: true
     persistence:
       enabled: true
       size: 2Gi
     podSecurityContext: null
     securityContext: null
   imagePullSecrets: []
   kube-state-metrics:
     enabled: false
   networkPolicy:
     enabled: false
   prometheus-node-exporter:
     enabled: false
   prometheus-pushgateway:
     enabled: false
   rbac:
     create: true
   server:
     containerSecurityContext: null
     image:
       pullPolicy: IfNotPresent
       repository: quay.io/prometheus/prometheus
     name: server
     persistentVolume:
       enabled: true
       size: 8Gi
     securityContext: null
   ```
1. Click the _Create_ button

> Prometheus has now been installed

### Install lgtm-distributed
1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'monitoring' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'grafana'
1. In the search filter for 'lgtm distributed'
1. Click the 'LGTM Distributed' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select version '0.80.6' from the drop down.
1. Make any environmental specific changes in the _YAML view_.  Replace `grafana.<openshift-domain>` (highlighted in the file below)  
{{% details title="Sample of working Values.yaml" closed="true" %}}

```YAML {filename="Values.yaml",linenos=table,hl_lines=[43]}
grafana:
  datasources:
    datasources.yaml:
      apiVersion: 1
      datasources:
        - isDefault: false
          name: Loki
          type: loki
          uid: loki
          url: 'http://{{ .Release.Name }}-loki-gateway'
        - isDefault: true
          name: Mimir
          type: prometheus
          uid: prom
          url: 'http://{{ .Release.Name }}-mimir-nginx/prometheus'
        - isDefault: false
          jsonData:
            lokiSearch:
              datasourceUid: loki
            serviceMap:
              datasourceUid: prom
            tracesToLogsV2:
              datasourceUid: loki
            tracesToMetrics:
              datasourceUid: prom
          name: Tempo
          type: tempo
          uid: tempo
          url: 'http://{{ .Release.Name }}-tempo-query-frontend:3200'
        - name: Prometheus
          type: prometheus
          url: http://prometheus-server
          access: proxy
          isDefault: true
  enabled: true
  extraObjects:
    - apiVersion: route.openshift.io/v1
      kind: Route
      metadata:
        name: grafana
        namespace: monitoring
      spec:
        host: grafana.<openshift-domain>
        port:
          targetPort: service
        tls:
          insecureEdgeTerminationPolicy: Redirect
          termination: edge
        to:
          kind: Service
          name: lgtm-distributed-grafana
          weight: 100
        wildcardPolicy: None
  securityContext: null
grafana-oncall:
  enabled: false
loki:
  enabled: true
  gateway:
    podSecurityContext: null
  loki:
    podSecurityContext: null
  memcached:
    podSecurityContext: null
mimir:
  enabled: false
tempo:
  containerSecurityContext: null
  enabled: true
  ingester:
    replicas: 1
  securityContext: null
  tempo:
    podSecurityContext: null
    securityContext: null
  tokengenJob:
    containerSecurityContext: null
```

{{% /details %}}
1. Click the _Create_ button

> Loki, Grafana, and Tempo have now been installed

{{% /steps %}}

Example running releases in the 'monitoring' namespace:
![redhat-openshift-console-helm-repositories](./images/helm-monitoring-releases.png)

## 5. Install and configure Keycloak

### 5.1 Install Postgres for Keycloak

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'keycloak' is selected (create the project if it doesn't exist).
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'cloudnative-pg'
1. In the search filter for 'cluster'
1. Click the 'cluster' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
backups:
  enabled: false
cluster:
  initdb:
    database: keycloak
    owner: keycloak
  instances: 3
  logLevel: info
  monitoring:
    enabled: false
  postgresGID: -1
  postgresUID: -1
  storage:
    size: 8Gi
    storageClass: ''
databases: []
imageCatalog:
  create: true
  images: []
mode: standalone
nameOverride: keycloak-cnpg-cluster
replica: null
type: postgresql
version:
  postgis: '3.4'
  postgresql: '16'
  timescaledb: '2.15'
```

1. Click the _Create_ button

> The Keycloak Postgres cluster has now been installed

### 5.2 Create Keycloak Admin Secret

With the Red Hat OpenShift Console:
1. Using the left hand menu, navigate to _Workloads_ and _Secrets_.
1. Using the project selector, click the down arrow and ensure 'keycloak' is selected.
1. Click _Create_ and select _Key/value secret_.
1. Enter the following details:
   - **Secret name**: keycloak-admin-password
   - **Key**: password
   - **Value**: <insert password here>
1. Click _Create_.

> The Keycloak admin secret has now been created.

### 5.3 Install Keycloak

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'keycloak' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'codecentric'
1. In the search filter for 'keycloak'
1. Click the 'keycloak' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
clusterDomain: console-openshift-console.<openshift-domain>
command:
  - /opt/keycloak/bin/kc.sh
  - start
  - '--http-port=8080'
  - '--hostname-strict=false'
database:
  database: keycloak
  existingSecret: keycloak-cnpg-cluster-app
  existingSecretKey: password
  hostname: keycloak-cnpg-cluster-rw
  username: keycloak
  vendor: postgres
extraEnv: |
  - name: JAVA_OPTS_APPEND
    value: >-
      -Djgroups.dns.query={{ include "keycloak.fullname" . }}-headless
  - name: KC_BOOTSTRAP_ADMIN_USERNAME
    value: admin
  - name: KC_BOOTSTRAP_ADMIN_PASSWORD
    valueFrom:
      secretKeyRef:
        name: keycloak-admin-password
        key: password
health:
  enabled: true
image:
  digest: ''
  pullPolicy: IfNotPresent
  repository: quay.io/keycloak/keycloak
  tag: 26.4.5
metrics:
  enabled: true
nameOverride: keycloak
podSecurityContext: null
prometheusRule:
  enabled: true
  namespace: monitoring
replicas: 1
route:
  enabled: true
  host: keycloak.<openshift-domain>
  path: /
  tls:
    enabled: true
    insecureEdgeTerminationPolicy: Redirect
    termination: edge
securityContext: null
```

1. Click the _Create_ button

> Keycloak has now been installed

#### 5.3.1 Keycloak Configuration

## 6. Install Rhize Applications

{{% steps %}}

### 6.1 Install Redpanda, including Redpanda Console

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'redpanda'
1. In the search filter for 'redpanda'
1. Click the 'redpanda' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
console:
  enabled: true
  podSecurityContext: null
  securityContext: null
image:
  repository: docker.redpanda.com/redpandadata/redpanda
logging:
  usageStats:
    enabled: true
  logLevel: info
monitoring:
  enabled: false
  scrapeInterval: 30s
podTemplate:
  spec:
    securityContext: null
post_install_job:
  podTemplate:
    spec:
      containers:
        - name: post-install
  enabled: true
resources:
  cpu:
    cores: 1
  memory:
    container:
      max: 2.5Gi
serviceAccount:
  create: true
statefulset:
  sideCars:
    configWatcher:
      enabled: true
    image:
      repository: docker.redpanda.com/redpandadata/redpanda-operator
      tag: v25.3.1
  replicas: 3
storage:
  persistentVolume:
    enabled: true
    size: 10Gi
tests:
  enabled: true
tls:
  certs:
    default:
      caEnabled: true
    external:
      caEnabled: true
  enabled: false
tuning:
  tune_aio_events: false
clusterDomain: cluster.local.
```

1. Click the _Create_ button

> Redpanda has now been installed

#### 6.1.1 Create Redpanda Console Route

1. Using the left hand menu, navigate to _Networking_ and _Routes_.
1. Click _Create Route_
1. Fill in the following details:
   - **Name**: redpanda-console
   - **Hostname**: redpanda-console.<openshift-domain>
   - **Service**: redpanda-console
   - **Target port**: 8080 → 8080
   - **Secure Route**: ✓
   - **TLS termination**: Edge
   - **Insecure traffic**: Redirect
1. Click _Create_

> Redpanda Console is now available

### 6.2 Install QuestDB

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'questdb'
1. In the search filter for 'questdb'
1. Click the 'questdb' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
image:
  pullPolicy: IfNotPresent
  repository: questdb/questdb
  tag: 8.2.1
persistence:
  enabled: true
  size: 50Gi
  storageClass: ''
podSecurityContext: null
resources:
  limits:
    cpu: 2000m
    memory: 4Gi
  requests:
    cpu: 1000m
    memory: 2Gi
securityContext: null
service:
  port: 9000
  type: ClusterIP
```

1. Click the _Create_ button

> QuestDB has now been installed

#### 6.2.1 Create QuestDB Route

1. Using the left hand menu, navigate to _Networking_ and _Routes_.
1. Click _Create Route_
1. Fill in the following details:
   - **Name**: questdb
   - **Hostname**: questdb.<openshift-domain>
   - **Service**: questdb
   - **Target port**: 9000 → 9000
   - **Secure Route**: ✓
   - **TLS termination**: Edge
   - **Insecure traffic**: Redirect
1. Click _Create_

> QuestDB console is now available

### 6.3 Install Restate

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'restate'
1. Click the 'restate' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Restate has now been installed

### 6.4 Install AppSmith-EE

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'appsmith-ee'
1. In the search filter for 'appsmith'
1. Click the 'appsmith' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> AppSmith-EE has now been installed

#### 6.4.1 Create AppSmith Route

1. Using the left hand menu, navigate to _Networking_ and _Routes_.
1. Click _Create Route_
1. Fill in the following details:
   - **Name**: appsmith
   - **Hostname**: appsmith.<openshift-domain>
   - **Service**: appsmith
   - **Target port**: 80 → 80
   - **Secure Route**: ✓
   - **TLS termination**: Edge
   - **Insecure traffic**: Redirect
1. Click _Create_

> AppSmith console is now available

1. Click the _Create_ button

> The Rhize Postgres cluster has now been installed

### 6.6 Install Rhize Typescript Host Service

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'typescript-host'
1. Click the 'rhize-typescript-host' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Rhize Typescript Host Service has now been installed

### 6.7 Install Rhize BaaS

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'baas'
1. Click the 'rhize-baas' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Rhize BaaS has now been installed

### 6.8 Install Rhize ISA-95

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'isa-95'
1. Click the 'rhize-isa95' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Rhize ISA-95 has now been installed

### 6.9 Install Rhize Workflow

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'workflow'
1. Click the 'rhize-workflow' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Rhize Workflow has now been installed

### 6.10 Install Rhize Admin UI

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'admin-ui'
1. Click the 'rhize-admin-ui' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Rhize Admin UI has now been installed

#### 6.10.1 Create Admin UI Route

1. Using the left hand menu, navigate to _Networking_ and _Routes_.
1. Click _Create Route_
1. Fill in the following details:
   - **Name**: rhize-admin-ui
   - **Hostname**: rhize-admin.<openshift-domain>
   - **Service**: rhize-admin-ui
   - **Target port**: 80 → 80
   - **Secure Route**: ✓
   - **TLS termination**: Edge
   - **Insecure traffic**: Redirect
1. Click _Create_

> Rhize Admin UI is now available

### 6.11 Install Rhize Audit (Optional)

The Rhize Audit service is optional and provides additional audit logging capabilities.

#### 6.11.1 Install Postgres (High Availability) for Rhize Audit

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'cloudnative-pg'
1. In the search filter for 'cluster'
1. Click the 'cluster' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> The Rhize Audit Postgres cluster has now been installed

#### 6.11.2 Install Rhize Audit Service

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'libre'
1. In the search filter for 'audit'
1. Click the 'rhize-audit' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select the latest version
1. Make any environmental specific changes in the _YAML view_, using the Values.yaml below

```YAML {filename="Values.yaml",linenos=table}
```

1. Click the _Create_ button

> Rhize Audit has now been installed

{{% /steps %}}

Example running releases in the 'rhize' namespace:
![redhat-openshift-console-helm-repositories](./images/helm-rhize-releases.png)

# Footnotes 

¹ - The 'monitoring' namespace is optional. The monitoring applications can be installed into the same namespace however these applications are typically used by other deployments and namespaces. Separating them into their own allows for better control and centralization of application services.