---
title: Install Rhize services
description: >-
  Instructions to install services in the Rhize Kubernetes cluster.
weight: 100
categories: "how-to"
menu:
  main:
    parent: install
    identifier: install-services
---

The final installation step is to install the Rhize services in your Kubernetes cluster.

## Prerequisites

- This topic assumes you have [Set up Kubernetes](/deploy/install/setup-kubernetes) and [Configured Keycloak]({{< relref "keycloak" >}}). All the prerequisites for those topics apply here.
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

### Overrides

Each service is installed through a Helm YAML file.
For some of these services, you might need to edit this file to add credential information and modify defaults.

Common values that are changed include:
- URLs and URL links
- The number of replicas running for each pod
- Ingress values for services exposed on the internet

## Get client secrets.

1. Go to Keycloak and get the secrets for each client you've created.
1. Create a Kubernetes secrets for each service with this command:
    ```bash
    kubectl delete secret generic {{< param application_name >}}-client-secrets -n {{< param application_name >}} --from-literal=dashboard=123 --from-literal={{< param application_name >}}Agent=123 --from-literal={{< param application_name >}}Baas=KYbMHlRLhXwiDNFuDCl3qtPj1cNdeMSl --from-literal={{< param application_name >}}BPMN=123 --from-literal={{< param application_name >}}Core=123 --from-literal={{< param application_name >}}UI=123 --from-literal=router=123
    ```

As you install services through Helm, their respective YAML files reference these secrets.

## Install and add roles for the DB {#db}

The first service to install must be the {{< param db >}} database.
You also need to configure {{< param db >}} service to have roles in Keycloak.


1. Use Helm to install the database:

    ```bash
    helm install -f baas.yaml {{< param application_name >}}-baas {{< param application_name >}}/baas -n {{< param application_name >}}
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

1. Go to Keycloak UI and all new {{< param db >}} roles to the `ADMIN` group.

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

### NATS {#nats}

[NATS](https://nats.io) is the message broker that powers Rhize's event-driven architecture.

Install NATS with these steps:

1. Modify the NATS Helm file with your code editor. Edit any necessary overrides.
1. Install with Helm:

    ```
    helm install nats -f nats.yaml {{< param application_name >}}/nats -n {{< param application_name >}}
    ```


### Tempo

Rhize uses [Tempo](https://grafana.com/oss/tempo/) to trace BPMN processes.

Install Tempo with these steps:

1. If it doesn't exist, add the Tempo repo:

    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    ```

1. Modify the Helm file as needed.
1. Install with Helm:

    ```bash
    helm install tempo -f tempo.yaml grafana/tempo -n {{< param application_name >}}
    ```

### Core

The {{< param application_name >}} service is the custom edge agent that monitors data sources, like OPC-UA servers, and publishes and subscribes topics to NATS.

> **Requirements**: Core requires the [{{< param db >}}](#db) and [NATS](#nats) services.

Install the Core agent with these steps:

1. In the `core.yaml` Helm file, edit the `clientSecret` and `password` with settings from the Keycloak client.
1. Override any other values, as needed.
1. Install with Helm:

    ```bash
    helm install core -f core.yaml {{< param application_name >}}/core -n {{< param application_name >}}
    ```



### BPMN

The BPMN service is the custom engine Rhize uses to process low-code workflows modelled in the BPMN UI.

> **Requirements**: The BPMN service requires the [{{< param db >}}](#db), [NATS](#nats), and [Tempo](#tempo) services.

Install the BPMN engine with these steps:

1. Open `bpmn.yaml` Update the `clientSecret` and `password` for your BPMN Keycloak credentials.
1. Modify any other values, as needed.
1. Install with Helm:

   ```bash
   helm install bpmn -f bpmn.yaml {{< param application_name >}}/bpmn -n {{< param application_name >}}
   ```

### Router

Rhize uses the [Apollo router](https://duckduckgo.com/?t=ffab&q=apollo+router&ia=web) to unite queries for different services in a single endpoint.

> **Requirements:** Router requires the [GraphDB](#db), [BPMN](#bpmn), and [Core](#core) services.

Install the router with these steps:

1. Modify the router Helm YAML file as needed.
1. Install with Helm:

    ```bash
    helm install router -f router.yaml {{< param application_name >}}/router -n {{< param application_name >}}
    ```


### Grafana

Rhize uses [Grafana](https://grafana.com) for its dashboard to monitor real time data.

Install Grafana with these steps:

1. Modify the Grafana Helm YAML file as needed.
1. Install with Helm:

    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    ```

## Install UI


The [UI]({{< relref "/how-to/" >}}) is the graphical frontend to progrman business processes and define work masters.

> **Requirements:** The UI requires the [GraphDB](#db), [BPMN](#bpmn), [Core](#core), and [Router](#router) services.

After installing all other services, install the UI with these steps:

1. Forward the port from the Router API.
1. Open the UI YAML file. Update the `envVars` object with settings from the UI Keycloak client.
1. Modify any other values, as needed.
1. Install with Helm:

    ```bash
    helm install ui -f ui-overrides.yaml {{< param application_name >}}/admin-ui -n {{< param application_name >}}
    ```

On success, the UI is accessible on its port.

## Troubleshoot

- **Is my service running?**

   To check that an installed service is running, use this command:

   ```bash
    kubectl get pods
    ```

    Look for the pod name and its status.

- **I installed a service too early**.
    If you installed a service too early, use Helm to uninstall:

    ```bash
    helm uninstall {{< param db >}}
    ```

    Then perform the steps you need and reinstall when ready.
