---
title: Install Rhize services
description: >-
  Instructions to install services in the Rhize Kubernetes cluster.
weight: 100
categories: "how-to"
---

The final installation step is to install the Rhize services in your Kubernetes cluster.

## Prerequisites

This topic assumes you have done the following:
- [Set up Kubernetes]({{< relref "setup-kubernetes" >}}) and [Configured Keycloak]({{< relref "keycloak" >}}). All the prerequisites for those topics apply here.
- Configured load balancing for the following DNS records:

    {{< reusable/default-urls >}}

    _Note that `rhize-` is only the recommended prefix of the subdomain. Your organization may use something else._


### Overrides

Each service is installed through a Helm YAML file.
For some of these services, you might need to edit this file to add credential information and modify defaults.

Common values that are changed include:
- URLs and URL links
- The number of replicas running for each pod
- Ingress values for services exposed on the internet

## Get client secrets.

1. Go to Keycloak and get the secrets for each client you've created.

1. Create Kubernetes secrets for each service. You can either create a secret file, or pass raw data from the command line.

   {{< callout type="caution" >}}
   How you create Kubernetes secrets **depends on your implementation details and security procedures.**
   For guidance, refer to the official Kubernetes topic, [Managing Secrets using `kubectl`](https://kubernetes.io/docs/tasks/configmap-secret/managing-secret-using-kubectl/).
   {{< /callout >}}

   With raw data, the command might look something like this.

   ```bash
   kubectl create secret generic {{< param application_name >}}-client-secrets \
     -n {{< param application_name >}} \
     --from-literal=dashboard=G4hoxIL37F5S9DQgeDYGQejcJ6oJhOPA \
     --from-literal={{< param application_name >}}Workflow=GTy1x64U0IHAUTWizugEAnN47a9kWgX8 \
     --from-literal={{< param application_name >}}ISA95=Yvtx1tZWCPFayvDCzHTTInEz9gnuLyLc \
     --from-literal={{< param application_name >}}Baas=KYbMHlRLhXwiDNFuDCl3qtPj1cNdeMSl \
     --from-literal={{< param application_name >}}UI=54yUQqmvgcxoKPaIbPZTQGlEs8Xu2qH0
   ```

   As you install services through Helm, their respective YAML files reference these secrets.

## Add the Rhize Helm Chart Repository

You must add the helm chart repository for Rhize.

1. Add the Helm Chart Repository

    ```bash
    helm repo add {{< param application_name >}} https://gitlab.com/api/v4/projects/42214456/packages/helm/stable
    ```

## Install and add roles for the DB {#db}

You must install the {{< param db >}} database service first.
You also need to configure the {{< param db >}} service to have roles in Keycloak.

If enabling the Audit Trail, also the include the configuration in [Enable change data capture](#enable-change-data-capture).


1. Use Helm to install the database:

    ```bash
    helm install -f baas.yaml {{< param application_name >}}-baas {{< param application_name >}}/baas -n {{< param application_name >}}
    ```

    To confirm it works, run the following command:

    ```bash
    kubectl get pods
    ```

    All statuses should be `RUNNING`.

1. Return to the Keycloak UI and add all `{{< param application_name >}}` roles to the admin group.

1. Proxy the `http:8080` port on `{{< param application_name >}}-baas-dgraph-alpha`.

   ```bash
   kubectl port-forward -n {{< param application_name >}} pod/baas-baas-alpha-0 8080:8080
   ```

1. Get a token using the credentials. With `curl`, it looks like this:

    ```bash
    curl --location --request POST 'https://<customer>-
    auth.{{< param application_name >}}/realms/{{< param application_name >}}/protocol/openid-connect/token' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'username=system@{{< param application_name >}}.com' \
    --data-urlencode 'password=<PASSWORD>' \
    --data-urlencode 'client_id={{< param application_name >}}Baas' \
    --data-urlencode 'client_secret=<CLIENT_SECRET>'
    ```

1. Post the schema:

    ```bash
    curl --location --request POST 'http://localhost:<FORWARDED_PORT>/admin/schema' \
    --header 'Authorization: Bearer <TOKEN>' \
    --header 'Content-Type: application/octet-stream' \
    --data-binary '@<SCHEMA_FILE>'
    ```

    This creates more roles.

1. Go to Keycloak UI and add all new {{< param db >}} roles to the `ADMIN` group.

If the install is successful, the Keycloak UI is available on its
[default port]({{< relref "../../reference/default-ports" >}}).


## Install services

Each of the following procedures installs a service through Helm.

The syntax to install a Rhize service must have arguments for the following:
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

### Redpanda

Rhize uses Redpanda to buffer requests to Restate and connect to Agent.

Install Redpanda with these steps:

1. If the Redpanda repository doesn't exist, add it:

    ```bash
    helm repo add redpanda https://charts.redpanda.com
    helm repo update
    ```

1. Modify the Redpanda Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install redpanda -f redpanda.yaml redpanda/redpanda -n {{< param application_name >}}
    ```

### Tempo

Rhize uses [Tempo](https://grafana.com/oss/tempo/) to trace BPMN processes.

Install Tempo with these steps:

1. If it doesn't exist, add the Tempo repository:

    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    ```

1. Modify the Tempo Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install tempo -f tempo.yaml grafana/tempo -n {{< param application_name >}}
    ```

> [!NOTE] 
> Depending on your configuration you may need to run Tempo in distributed mode. When installing with Helm instead of using `grafana/tempo` instead do `grafana/tempo-distributed`.

### Restate

Rhize uses Restate as a platform for orchestrating other services.

Install Restate with these steps:

1. Modify the Restate Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install restate -f restate.yaml oci://ghcr.io/restatedev/restate-helm -n {{< param application_name >}}
    ```

So that you can register certain services with Restate, proxy the Restate port:

   ```bash
   kubectl port-forward -n {{< param application_name >}} pod/restate-0 9070:9070
   ```

### Workflow

The Workflow service is the custom engine Rhize uses to process low-code workflows modeled in the Workflow UI.

> **Requirements**: The Workflow service requires the [{{< param db >}}](#db), [Restate](#restate), and [Tempo](#tempo) services.

Install Workflow with these steps:

1. Modify the Workflow Helm overrides as needed.

1. Install with Helm:

   ```bash
   helm install workflow -f workflow.yaml {{< param application_name >}}/workflow -n {{< param application_name >}}
   ```

1. When the Workflow service starts, it should register with Restate. Verify this with:

    ```bash
    curl localhost:9070/deployments | jq '.deployments[].uri'
    ```

    This will show the URL of each registered service. If Workflow's URL is not present, register it with:

    ```bash
    curl --location 'http://localhost:9070/deployments' \
      --header 'Content-Type: application/json' \
      --data '{"uri":"http://workflow.{{< param application_name >}}.svc.cluster.local:29080", "force":true}'
    ```

### Typescript Host Service

Install Typescript Host Service with these steps:

1. Modify the Typescript Host Service Helm overrides as needed.

1. Install with Helm:

   ```bash
   helm install typescript-host-service -f typescript-host-service.yaml {{< param application_name >}}/typescript-host-service -n {{< param application_name >}}
   ```

1. Register with Restate:

    ```bash
    curl --location 'http://localhost:9070/deployments' \
      --header 'Content-Type: application/json' \
      --data '{"uri":"http://typescript-host-service.{{< param application_name >}}.svc.cluster.local:9081", "force":true}'
    ```

### QuestDB

QuestDB is used by Rhize to store timeseries data, however it can be substitude for another historian.

Install QuestDB with these steps:

1. If it doesn't exist, add the QuestDB repository:

    ```bash
    helm repo add questdb https://helm.questdb.io/
    helm repo update
    ```

1. Modify the QuestDB Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install questdb -f questdb.yaml questdb/questdb -n {{< param application_name >}}
    ```

### ISA-95

Install ISA-95 with these steps:

1. Modify the ISA-95 Helm overrides as needed.

1. Install with Helm:

   ```bash
   helm install isa95 -f isa95.yaml {{< param application_name >}}/isa95 -n {{< param application_name >}}
   ```

1. When the ISA-95 service starts, it should register with Restate. Verify this with:

    ```bash
    curl localhost:9070/deployments | jq '.deployments[].uri'
    ```

    This will show the URL of each registered service. If ISA-95's URL is not present, register it with:

    ```bash
    curl --location 'http://localhost:9070/deployments' \
      --header 'Content-Type: application/json' \
      --data '{"uri":"http://isa95.{{< param application_name >}}.svc.cluster.local:29080", "force":true}'
    ```


### Grafana

Rhize uses [Grafana](https://grafana.com) for its dashboard to monitor real time data.

Install Grafana with these steps:

1. Add the Helm repository
    ```bash
    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    ```

1. Modify the Grafana Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install grafana -f grafana.yaml grafana/grafana -n {{< param application_name >}}
    ```

If the install is successful, the Grafana service is available on its
[default port]({{< relref "../../reference/default-ports" >}}).

## Install Admin UI

The Rhize agent bridges your plant processes with the Rhize data hub.

The Admin UI is the graphical frontend to [handle events]({{< relref "/how-to/bpmn" >}}) and [define work masters]({{< relref "/how-to/model" >}}).

> **Requirements:** The Admin UI requires the [Workflow](#workflow) services.

After installing all other services, install the UI with these steps:

1. Modify the UI Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install admin-ui -f admin-ui.yaml {{< param application_name >}}/admin-ui -n {{< param application_name >}}
    ```

If the install is successful, the UI is available on its
[default port]({{< ref "default-ports" >}}).

### Agent

The Rhize agent bridges your plant processes with the Rhize data hub.
It collects data emitted from the plant and publishes it to the message broker.

> **Requirements:** Agent requires the [Graph DB](#db), [Tempo](#tempo), Redpanda, and an event broker service to communicate with.

Install Agent with these steps:

1. Modify the Agent Helm overrides as needed.

1. In the Rhize UI, add a Data Source for Agent to interact with:
    - In the lefthand menu, open **Master Data > Data Sources > + Create Data Source**.
    - Input a name for the Data Source.
    - Add a Connection String and Create.
    - Add any relevant Topics.
    - Activate the Data Source.

1. Install with Helm:

    ```bash
    helm install agent -f agent.yaml {{< param application_name >}}/agent -n {{< param application_name >}}
    ```

To verify that Agent is working, check the Redpanda UI.

## Optional Services

### Audit Trail

The Rhize [Audit]({{< relref "/how-to/audit" >}}) service provides an audit trail for database changes. The Audit service uses PostgreSQL for storage.

Install Audit with these steps:

1. Modify the Audit trail Helm YAML file. It is *recommended* to change the PostgreSQL username and password values.

1. Install with Helm:

    ```bash
    helm install audit -f audit.yaml {{< param application_name >}}/audit -n {{< param application_name >}}
    ```

1. Create partition tables in the PostgreSQL database:

    ```sql
    create table public.audit_log_partition( like public.audit_log );
    select partman.create_parent( p_parent_table := 'public.audit_log', p_control := 'time',  p_interval := '1 Month', p_template_table := 'public.audit_log_partition');
    ```

For details about maintaining the Audit trail, read [Archive the PostgresQL Audit trail]({{< relref "../maintain/audit/" >}}).

#### Enable change data capture

The Audit trail requires [change data capture (CDC)]({{< relref "../../how-to/publish-subscribe/track-changes" >}}) to function. To enable CDC in {{< param application_name >}} BAAS, include the following values for the Helm chart overrides:

```yaml
alpha:
  # Change Data Capture (CDC)
  cdc:
    # Enable
    enabled: true
    # If configured for security, configure in NATS url. For example `nats://username:password@nats:4222`
    nats: nats://nats:4222
    # Adjust based on high-availability requirements and cluster size.
    replicas: 1
```

### KPI

The Rhize KPI service is a GraphQL service which calcualtes ISO22400 KPIs using timseries tables.

Install KPI with these steps:

1. Modify the KPI Helm overrides as needed.

1. Install with Helm:

   ```bash
   helm install kpi -f kpi.yaml {{< param application_name >}}/kpi -n {{< param application_name >}}
   ```

### Solace

Solace is an event broker that can be used alongside Agent, though it can be substituted for any other event broker.

1. Add the Solace Charts Helm repo.

    ```bash
    helm repo add solacecharts https://solaceproducts.github.io/pubsubplus-kubernetes-helm-quickstart/helm-charts
    ```

1. Modify the Solace Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install solace -f solace.yaml solacecharts/pubsubplus -n {{< param application_name >}}
    ```

> [!NOTE]
> Solace can be installed in high availability by using `pubsubplus-ha` instead of `pubsubplus`.
> See detailed instructions on [github](https://github.com/SolaceProducts/pubsubplus-kubernetes-helm-quickstart).

### Apollo Router

While Rhize provides a built in GraphQL Playground using Apollo's Sandobx, [Apollo Router](https://www.apollographql.com/docs/router) can be installed to unite queries for different services in a single endpoint outside of Rhize's interface.

> **Requirements:** Router requires the [GraphDB](#db) service.

Install Router with these steps:

1. Modify the Router Helm overrides as needed.

1. Install with Helm:

    ```bash
    helm install router -f router.yaml {{< param application_name >}}/router -n {{< param application_name >}}
    ```

If the install is successful, the Router explorer is available on its [default port]({{< relref "../../reference/default-ports" >}}).

## Optional: change service configuration

The services installed in the previous step have many parameters that you can configure for your performance and deployment requirements.
Review the full list in the [Service configuration]({{< relref "../../reference/service-config" >}}) reference.

## Troubleshoot

For general Kubernetes issues, the [Kubernetes dashboard](https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/) is great for troubleshooting, and you can configure it to be accessible through the browser.

For particular problems, try these commands:

- **Is my service running?**

   To check deployment status, use this command:

   ```bash
    kubectl get deployments
    ```

    Look for the pod name and its status.

- **Access service through browser**

    Some services are accessible through the browser.
    To access them, visit local host on the service's [default port]({{< relref "../../reference/default-ports" >}}).

- **I installed a service too early**.
    If you installed a service too early, use Helm to uninstall:

    ```bash
    helm uninstall {{< param db >}}
    ```

    Then perform the steps you need and reinstall when ready.
