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

## 1. Create the Rhize OpenShift Project

With the Red Hat OpenShift Console:
1. Login using your existing credentials.
1. Using the left hand menu, navigate to _Home_ and _Projects_.
1. Click _Create Project_ and enter name 'rhize'
1. Click _Create_ 

> The 'rhize' project with the 'rhize' namespace has now been created

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'rhize' is selected.

## 2. Configure Helm Chart Repositories

### 2.1 Add Libre Helm Chart Secret

The Libre Helm chart repository requires authentication to access. Create a secret using the Red Hat OpenShift command line utility using your provided access token.

```shell
$ oc create secret generic libre-helmchart-repository --from-literal=username='tom561' --from-literal=password='glpat-XXXXX' --namespace openshift-config
```

Now that the secret is configured, we can use it in the next step to create the Helm chart repositories.

### 2.1 Add Helm Chart Repositories

With the Red Hat OpenShift Console:
1. Login using your existing credentials.
1. Using the left hand menu, navigate to _Helm_ and _Repositories_.
1. Click _Create Helm Repository_ and create the following Helm Chart Repositories (HCR).

| Type           | name                 | label                | description | url                                                              |
| Cluster Scoped | appsmith-ee          | appsmith-ee          |             | https://helm-ee.appsmith.com                                     |
| Cluster Scoped | bitnami              | bitnami              |             | https://charts.bitnami.com/bitnami                               |
| Cluster Scoped | codecentric          | codecentric          |             | https://codecentric.github.io/helm-charts                        |
| Cluster Scoped | grafana              | grafana              |             | https://grafana.github.io/helm-charts                            |
| Cluster Scoped | libre                | libre                |             | https://gitlab.com/api/v4/projects/42214456/packages/helm/stable |
| Cluster Scoped | prometheus-community | prometheus-community |             | https://prometheus-community.github.io/helm-charts               |
| Cluster Scoped | questdb              | questdb              |             | https://helm.questdb.io                                          |
| Cluster Scoped | redpanda             | redpanda             |             | https://charts.redpanda.com                                      |

Example configured helm repositories:
![redhat-openshift-console-helm-repositories](./images/helm-chart-repositories.png)

## 3. Install Monitoring Applications

| Rhize recommends a separate namespace for monitoring¹

With the Red Hat OpenShift Console:
1. Login using your existing credentials.
1. Using the left hand menu, navigate to _Administration_ and _Namespaces_.
1. Click _Create Namespace_ and enter name 'monitoring'
1. Click _Create_

> The monitoring and rhize namespace has now been created.

1. Using the left hand menu, navigate to _Helm_ and _Releases_.
1. Using the project selector, click the down arrow and ensure 'monitoring' is selected.

### 3.1 Install loki-distributed
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'grafana'
1. In the search filter for 'loki distributed'
1. Click the 'Loki Distributed' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select version '0.80.6' from the drop down.
1. Make any environmental specific changes in the _YAML view_
1. Click the _Create_ button

> Loki has now been installed

### 3.2 Install tempo-distributed
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'grafana'
1. In the search filter for 'tempo distributed'
1. Click the 'Tempo Distributed' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select version '1.57.1' from the drop down.
1. Make any environmental specific changes in the _YAML view_
1. Click the _Create_ button

> Tempo has now been installed

### 3.3 Install prometheus
1. Click _Create Helm Release_
1. Using the filter, select _Chart Repository_: 'prometheus-community'
1. In the search filter for 'prometheus'
1. Click the 'prometheus' helm chart
1. Click the _Create_ button
1. Click the _Chart Version_ dropdown and wait for it to finish loading
1. Select version '27.50.1' from the drop down.
1. Make any environmental specific changes in the _YAML view_, including
  - Change the replicas to 2
1. Click the _Create_ button

> Prometheus has now been installed

### 3.4 Install Grafana
<todo>

Example running releases in the 'monitoring' namespace:
![redhat-openshift-console-helm-repositories](./image/helm-chart-repositories.png)

## 4. Install and configure Keycloak

### 4.1 Install Postgres (High Availability) for Keycloak
<todo>

### 4.3 Install Keycloak
<todo>

#### 4.3.1 Keycloak Configuration
<todo>

## 5. Install Rhize Applications
<todo>

### 5.1 Install Redpanda, including Redpanda Console
<todo>

### 5.2 Install QuestDB
<todo>

### 3.3 Install Restate
<todo>

### 3.4 Install AppSmith-EE
<todo>

### 3.5 Install Rhize Typescript Host Service
<todo>

### 3.6 Install Rhize BaaS
<todo>

### 3.7 Install Rhize ISA-95
<todo>

### 3.8 Install Rhize Workflow
<todo>

### 3.9 Install Rhize Admin UI
<todo>

### 3. Install Rhize Audit (Optional)
<todo>

### 4.2 Install Postgres (High Availability) for Rhize Audit
<todo>

# Footnotes 

¹ - The 'monitoring' namespace is optional. The monitoring applications can be installed into the same namespace however these applications are typically used by other deployments and namespaces. Separating them into their own allows for better control and centralization of application services.