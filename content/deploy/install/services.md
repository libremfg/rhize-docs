---
title: Install Rhize services
description: >-
  Instructions to install services in the Rhize Kubernetes.
weight: 100
categories: "how-to"
menu:
  main:
    parent: install
    identifier: install-services
---

## Services

### Install the Rhize DB

Requires: Keycloak

helm install -f baas.yaml

```bash
helm install -f baas.yaml libre-baas libre/baas -n libre
```

Now return to finish the Keycloak authentication.

### Deploy the schema

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

### Install NATS

NATS is the message broker

1. Open `NATS-overrides.yaml` with your code editor.


### Install BPMN

> The BPMN service requires the Graph database, NATS, and Tempo

1. Open `bpmn.yaml` Update the `clientSecret` and `password` for your BPMN Keycloak credentials.
1. Install with Helm:

   ```bash
   helm install bpmn -f bpmn.yaml {{< param application_name >}}/bpmn -n {{< param application_name >}}
   ```

### Install router

> Router requires the GraphDB, BPMN, and Core

The Apollo router distributes queries across your services

## Next steps

Configure load balancing for the following DNS records:


| Service  | Domain                                                                    |
|----------|---------------------------------------------------------------------------|
| Admin UI | `<CUSTOMER>-{{< param application_name >}}.{{< param domain_name >}}` |
| Keycloak | `<CUSTOMER>-auth.{{< param domain_name >}}`                          |
| GraphQL  | `<CUSTOMER>-graphql.{{< param domain_name >}}`                       |
| NATS     | `<CUSTOMER>-mqtt.{{< param domain_name >}}`                          |
| Highbyte | `<CUSTOMER>-highbyte.{{< param domain_name >}}`                      |
| Grafana  | `<CUSTOMER>-grafana.{{< param domain_name >}}`                       |
| BPMN     | `<CUSTOMER>-bpmn.{{< param domain_name >}}`                          |
