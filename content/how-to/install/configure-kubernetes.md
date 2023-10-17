---
title: 'Install Rhize on Kubernetes'
date: '2023-09-22T14:49:53-03:00'
draft: true
categories: how-to
description:
  How to install Rhize services on your Kubernetes cluster.
weight: 050
menu:
  main:
    parent: install
    identifier:
domain_name: libremfg.ai
brand_name: Libre
application_name: libre
---

This procedure guides you on how to install Rhize services on your Kubernetes cluster.

## Prerequisites

This guide assumes that you are comfortable navigating the command line.

Besides that, ensure you have the following technical requirements:

- Access to our helm charts
- Administrative priviliges for running Kubernetes cluster
For AWS, refer to our [Set up AWS EKS]({{< ref "set-up-aws-eks" >}}) guide.
- Internet access
- [kubectx](https://github.com/ahmetb/kubectx) and kubens installed
- A way to programmatically make HTTP requests (this guide uses Curl)
- MQTT Explorer
- DNS records created and pointing to the following subdomains:

| Service  | Domain                                                                    |
|----------|---------------------------------------------------------------------------|
| Admin UI | `<CUSTOMER>-{{< param application_name >}}.{{< param domain_name >}}` |
| Keycloak | `<CUSTOMER>-auth.{{< param domain_name >}}`                          |
| GraphQL  | `<CUSTOMER>-graphql.{{< param domain_name >}}`                       |
| NATS     | `<CUSTOMER>-mqtt.{{< param domain_name >}}`                          |
| Highbyte | `<CUSTOMER>-highbyte.{{< param domain_name >}}`                      |
| Grafana  | `<CUSTOMER>-grafana.{{< param domain_name >}}`                       |
| BPMN     | `<CUSTOMER>-bpmn.{{< param domain_name >}}`                          |



## Create a namespace

Create a namespace inside the cluster with the following command:

```bash
kubectl create ns {{< param application_name >}}
```

Confirm it works, run `kubectl get ns`.

The output should how an active {{< param application_name >}} namespace.

## Clone the helm charts

After you clone the {{< param application_name >}}, confirm that the `heml-charts` exists.

## Install the Keycloak service

To install {{< param application_name >}}-Keycloak service:

1. Open `key-cloak-overrides.yaml` in your editor.
1. Change the certificate ARN and subnets to match them
1. Run the following command

```bash
helm install -f ./key-cloak-overrides.yaml keycloak ./keycloak-13.0.0/keycloak/ -n {{< param application_name >}}
```
If the process succeeds, Keycloak should be accessible after 5 minutes.

Now configure a DNS entry for your load balancer.
1. If using AWS ALB, the values are as follows:
- **Record name**: `CUSTOMER`-auth
- **Type:** A (routes traffic to an IPv5)
- **Alias:** enable
- **Route Traffic to** "Alias to application and classic load balancer"
- In the load balancer config, enable:
  - Simple routing
  - Evaluate target health
2. Repeat this process for IPv6 (type AAAA in ALB).

Confirm access to keycloak at `https://CUSTOMER_NAME.auth.{{< param domain_name >}}`.
On success, the service should be available within 5 minutes.

## Configure Keycloak {#keycloak-dns}

To configure Keycloak for authentication, read [Authenticate with Keycloak]({{< relref "keycloak.md" >}})

Record the client and secret key. You'll need it for the next step.

## Install the backend

Install Rhize's database backend with the following tasks:

```bash
helm install {{< param application_name >}}-baas ./{{< param application_name >}}Baas \
-n {{< param application_name >}} \
--set alpha.persistence.storageClass=standard \
--set alpha.persistence.size=30Gi \
--set zero.persistence.storageClass=standard \
--set zero.persistence.size=10Gi \
--set alpha.extraFlags="--oidc
\"url=http://keycloak;realm={{< param application_name >}};client-
id={{< param application_name >}}Baas;client-secret=<secret from above>
```

Now return to finish the Keycloak authentication.

## Deploy the schema

1. Proxy the `http:8080` port on `{{< param application_name >}}-baas-dgraph-alpha`

1. Get a token using the credentials. In curl, it looks like this:

```bash
curl --location --request POST 'https://<customer>-
auth.{{< param application_name >}}/realms/{{< param application_name >}}/protocol/openid-connect/token' \
--header 'Content-Type: application/x-www-form-urlencoded' \
--data-urlencode 'grant_type=password' \
--data-urlencode 'username=system@{{< param application_name >}}.com' \
--data-urlencode 'password=<password>' \
--data-urlencode 'client_id={{< param application_name >}}Baas' \
--data-urlencode 'client_secret=<client secret>'
```

Add the GraphQL schema to keycloak.

## Install NATS

1. Open `NATS-overrides.yaml` with your code editor.
1. Update for your certs and subnets.
1. Install NATS with:

    ```bash
    helm install nats -f nats-overrides.yaml ./nats-0.19.4/nats/ -n {{< param application_name >}}
    ```

## Configure DNS NLB for MQTT

In AWS, this is done through Route 53. You can use the values from the preceding [Keycloak DNS](#keycloak-dns) section.

Using the MQTT explorer, confirm access at this location

```
mqtts://<CUSTOMER>-mqtt.{{< param domain_name >}}:1883`
```

## Install router

1. Open `router-overrides.yaml` in your code editor.
1. Change the certificate ARN and update the `hostname` to match.
1. Check the tags.
1. Check that the subnet IDs refer to

    ```bash
    helm install router -f router-overrides.yaml -n {{< param application_name >}}
    ```

Confirm that it's available at:

```
<CUSTOMER>-api.{{< param domain_name >}}`
```

## Configure ALB DNS for router

In AWS, this is done through Route 53.
