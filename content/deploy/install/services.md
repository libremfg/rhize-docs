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

After setting up your Kubernetes environment and using keycloak to create the proper clients and roles for each service.

## Prerequisites

- This topic assumes you have [Set up kubernetes]({{< relref "setup-kubernetes" >}}) and [Configured Keycloak]({{< relref "keycloak" >}}). All the prerequisites for those topics apply here.
- Configure load balancing for the following DNS records:

    | Service  | Domain                                                                |
    |----------|-----------------------------------------------------------------------|
    | Admin UI | `<CUSTOMER>-{{< param application_name >}}.{{< param domain_name >}}` |
    | Keycloak | `<CUSTOMER>-auth.{{< param domain_name >}}`                           |
    | GraphQL  | `<CUSTOMER>-graphql.{{< param domain_name >}}`                        |
    | NATS     | `<CUSTOMER>-mqtt.{{< param domain_name >}}`                           |
    | Highbyte | `<CUSTOMER>-highbyte.{{< param domain_name >}}`                       |
    | Grafana  | `<CUSTOMER>-grafana.{{< param domain_name >}}`                        |
    | BPMN     | `<CUSTOMER>-bpmn.{{< param domain_name >}}`                           |



## Get client secrets.

1. Go to Keycloak and get the secrets for each client you've created.
1. Create a kubernetes secrets for each service with this command:
    ```bash
    kubectl delete secret generic libre-client-secrets -n libre --from-literal=dashboard=123 --from-literal=libreAgent=123 --from-literal=libreBaas=KYbMHlRLhXwiDNFuDCl3qtPj1cNdeMSl --from-literal=libreBPMN=123 --from-literal=libreCore=123 --from-literal=libreUI=123 --from-literal=router=123
    ```

As you install services through Helm, their respective YAML files reference these secrets.

## Install the DB and configure permissions

The first service to install must be the {{< param db >}}.
You also need to configure {{< param db >}} service to have roles in Keycloak.

    
1. Use helm to install the database:

    ```bash
    helm install -f baas.yaml libre-baas libre/baas -n libre
    ```

    To confirm it works, run the following 

    ```bash
    kubectl get pods
    ```

    All statuses should be `RUNNING`.


1. Return to the Keycloak UI and add all {{< param application_name >}} to the admin group.

1. Proxy the `http:8080` port on `{{< param application_name >}}-baas-dgraph-alpha`

1. Get a token using the credentials. With curl, it looks like this:

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

1. Post the schema:

    ```bash
    curl --location --request POST 'http://localhost:{{ FORWARDED PORT }}/admin/schema' \
    --header 'Authorization: Bearer {{ TOKEN }}' \
    --data grant_type=urn:ietf:params:oauth:grant-type:uma-ticket" \
    --header 'Content-Type: application/octet-stream' \
    --data-binary '{ SCHEMA FILE }’
    ```
  
  This creates more roles.
  
1. Go to Keycloak UI and all new Baas roles to the `ADMIN` group.

## Install services

Each of the following procedures installs a service through Helm.

The syntax to install a Rhize service must have arguments for the the following:
- The chart YAML file
- The packaged chart
- The path to the unpackaged chart or directory

Additionally, use the `-n` flag to ensure that the install is scoped to the correct namespace:


```
helm install <service_name> \
  -f <service-overide-file>.yaml \
  <path/to/directory> \
  -n <ns>
```

For the full configuration options,
read the official [Helm `install` reference](https://helm.sh/docs/helm/helm_install/).
  
### NATS

NATS is the message broker that powers Rhize's event-driven architecture.

1. Open `NATS-overrides.yaml` with your code editor.

```
helm install core -f core.yaml libre/core -n libre
```

### Tempo

Rhize uses Tempo to trace BPMN processes.

1. If it doesn't exist, add the Tempo repo:

    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    ```
    
1. Install with Helm:

    ```bash
    helm install tempo -f tempo.yaml grafana/tempo -n libre
    ```

### Core

> **Requirements**: Core requires the {{< param db >}} and NATS services.
    


### BPMN

> The BPMN service requires the {{< param db >}}, NATS, and Tempo

1. Open `bpmn.yaml` Update the `clientSecret` and `password` for your BPMN Keycloak credentials.
1. Install with Helm:

   ```bash
   helm install bpmn -f bpmn.yaml {{< param application_name >}}/bpmn -n {{< param application_name >}}
   ```

### Router

> **Requirements:** Router requires the GraphDB, BPMN, and Core services.

The Apollo router distributes queries across your services


### UI

The UI is the graphical frontend for to configure processes and material.

> **Requirements:** The UI GraphDB, BPMN, Core, and Router services.

### Grafana

Grafana is the dashboard to monitor real time data.

## Troubleshoot

- **Installed service too early**.
    If you installed a service too early, use Helm to uninstall:

    ```bash
    helm uninstall {{< param db >}}
    ```

    Then perform the steps you need and reinstall when ready.

