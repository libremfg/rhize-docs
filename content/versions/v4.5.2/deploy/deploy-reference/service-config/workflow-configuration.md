---
title: 'Workflow configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize workflow service
aliases:
  - /reference/service-config/workflow-configuration
weight: 900
---

This document covers how to configure the workflow service through its Helm Chart.

## Application configuration

Everything in this section goes into the chart's `workflowConfig` value, which
becomes the workflow service's entire configuration file. 

The chart ships a
populated `workflowConfig`.
If you leave a setting unchanged, the workflow service runs with each setting's.
If you delete a key from that block, the service runs with no value, except `service.hostname`,
which is derived from
the pod's hostname.

To override individual keys, use the environment
variable listed with each setting, supplied through the chart's `envVars`,
`extraEnvVars`, or `additionalSecrets`.

### `http`

| Value | Description |
| --- | --- |
| **`http.port`** | <ul><li>Port the workflow service listens on. Serves the Restate handler, `/healthz`, and `/metrics`. The chart's container port, probes, and Service all assume the default, so changing the port means changing `service.port` with it.</li><li>Environment variable: `RHIZE_WORKFLOW_HTTP_PORT`</li><li>Default: `8081`</li><li>Example: `8081`</li><li>Type: string</li></ul> |

### `libreDataStoreGraphQl`

The BAAS GraphQL endpoint, and the CA certificate used to reach that endpoint
over TLS.

| Value | Description |
| --- | --- |
| **`libreDataStoreGraphQl.serverUrl`**<br>[Required] | <ul><li>URL of the BAAS GraphQL endpoint. Every query and mutation the engine performs goes here, so an unreachable value leaves the engine unable to load or record anything.</li><li>Environment variable: `RHIZE_WORKFLOW_LIBREDATASTOREGRAPHQL_SERVERURL`</li><li>Default: `http://baas-alpha:8080/graphql`</li><li>Example: `http://baas-alpha:8080/graphql`</li><li>Type: string</li></ul> |
| **`libreDataStoreGraphQl.caFile`** | <ul><li>Path to a PEM CA certificate to add to the system trust pool when calling the GraphQL endpoint over TLS. Leave empty to use system roots only. A path that cannot be read or parsed stops the workflow service from starting. Set to `/certs/ca-cert.pem` by the chart when `graphqlCA` is provided.</li><li>Environment variable: `RHIZE_WORKFLOW_LIBREDATASTOREGRAPHQL_CAFILE`</li><li>Example: `/certs/ca-cert.pem`</li><li>Type: string</li></ul> |

### `logging`

| Value | Description |
| --- | --- |
| **`logging.level`** | <ul><li>Minimum log level: `trace`, `debug`, `info`, `warn`, `error`, `fatal`, or `panic`. An invalid value logs a warning and falls back to `trace`.</li><li>Environment variable: `RHIZE_WORKFLOW_LOGGING_LEVEL`</li><li>Default: `debug`</li><li>Example: `info`</li><li>Type: string</li></ul> |
| **`logging.type`** | <ul><li>Output format. `json` emits structured JSON to stderr, `multi` writes console format to stderr and JSON to stdout, and anything else falls back to console.</li><li>Environment variable: `RHIZE_WORKFLOW_LOGGING_TYPE`</li><li>Default: `console`</li><li>Example: `console`</li><li>Type: string</li></ul> |

### `oidc`

| Value | Description |
| --- | --- |
| **`oidc.serverUrl`**<br>[Required] | <ul><li>Base URL of the OIDC provider.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_SERVERURL`</li><li>Default: `http://keycloak:80`</li><li>Example: `http://keycloak:80`</li><li>Type: string</li></ul> |
| **`oidc.realm`**<br>[Required when `oidc.enableGenericOidc` is `false`] | <ul><li>Keycloak realm.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_REALM`</li><li>Default: `libre`</li><li>Example: `libre`</li><li>Type: string</li></ul> |
| **`oidc.clientId`**<br>[Required] | <ul><li>Client ID. Tokens are obtained with the client credentials grant, so the client's service account needs the required roles in the provider.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_CLIENTID`</li><li>Example: `libreWorkflow`</li><li>Type: string</li></ul> |
| **`oidc.clientSecret`**<br>[Required] | <ul><li>Client secret paired with `oidc.clientId`. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_CLIENTSECRET`</li><li>Example: `Qm7xT2vLp9RcW4nZk8HbY3jDf6sGa1Ue`</li><li>Type: string</li></ul> |
| **`oidc.enableGenericOidc`** | <ul><li>Switches to a generic OIDC provider such as Okta rather than Keycloak-specific handling.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_ENABLEGENERICOIDC`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`oidc.customRolesKey`**<br>[Required when `oidc.enableGenericOidc` is `true`] | <ul><li>Claim to read roles from when using a non-Keycloak provider.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_CUSTOMROLESKEY`</li><li>Example: `rhize.com/roles`</li><li>Type: string</li></ul> |
| **`oidc.customAudienceKey`** | <ul><li>Claim to read the audience from when using a non-Keycloak provider.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_CUSTOMAUDIENCEKEY`</li><li>Example: `rhize.com/aud`</li><li>Type: string</li></ul> |
| **`oidc.credentialsScope`** | <ul><li>Optional scope requested during the client credentials grant.</li><li>Environment variable: `RHIZE_WORKFLOW_OIDC_CREDENTIALSSCOPE`</li><li>Example: `openid`</li><li>Type: string</li></ul> |

### `openTelemetry`

| Value | Description |
| --- | --- |
| **`openTelemetry.serverUrl`** | <ul><li>OTLP gRPC endpoint for trace export, sent without TLS.</li><li>Environment variable: `RHIZE_WORKFLOW_OPENTELEMETRY_SERVERURL`</li><li>Default: `http://grafana:4317`</li><li>Example: `http://tempo-distributor.monitoring.svc.cluster.local:4317`</li><li>Type: string</li></ul> |

### `secret`

| Value | Description |
| --- | --- |
| **`secret.key`**<br>[Required when a workflow reads a stored secret] | <ul><li>Passphrase used to derive the `age` scrypt identity that decrypts secret values stored in BAAS. Must be the same passphrase the secrets were encrypted with. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_WORKFLOW_SECRET_KEY`</li><li>Example: `ExamplePassphrase-Rhize-2026`</li><li>Type: string</li></ul> |

### `kafka`

| Value | Description |
| --- | --- |
| **`kafka.serverName`**<br>[Required when a workflow uses a Kafka write task] | <ul><li>Hostname of the Kafka or Redpanda broker, joined with `serverPort` to form the bootstrap address. Only used by the Kafka write task.</li><li>Environment variable: `RHIZE_WORKFLOW_KAFKA_SERVERNAME`</li><li>Default: `redpanda`</li><li>Example: `redpanda`</li><li>Type: string</li></ul> |
| **`kafka.serverPort`**<br>[Required when a workflow uses a Kafka write task] | <ul><li>Broker port.</li><li>Environment variable: `RHIZE_WORKFLOW_KAFKA_SERVERPORT`</li><li>Default: `29092`</li><li>Example: `9092`</li><li>Type: string</li></ul> |

### `typescript`

Where the expressions in JSONata, GraphQL, REST, and rule evaluation tasks are
evaluated: inside the workflow service, or by `typescript-host-service`.

| Value | Description |
| --- | --- |
| **`typescript.mode`** | <ul><li>`local` evaluates expressions inside the workflow service, so no `typescript-host-service` is needed. `grpc` sends them to `typescript-host-service` at `typescript.serverName` and `typescript.serverPort`.</li><li>Environment variable: `RHIZE_WORKFLOW_TYPESCRIPT_MODE`</li><li>Default: `local`</li><li>Example: `local`</li><li>Type: string</li></ul> |
| **`typescript.poolSize`** | <ul><li>Number of JavaScript runtimes kept ready for `local` evaluation. Size it to the most expressions evaluated at once, such as the branch count of a parallel gateway. `0` uses one per CPU, with a minimum of 4.</li><li>Environment variable: `RHIZE_WORKFLOW_TYPESCRIPT_POOLSIZE`</li><li>Default: `0`</li><li>Example: `0`</li><li>Type: integer</li></ul> |
| **`typescript.serverName`**<br>[Required when `typescript.mode` is `grpc`] | <ul><li>Hostname of `typescript-host-service`.</li><li>Environment variable: `RHIZE_WORKFLOW_TYPESCRIPT_SERVERNAME`</li><li>Example: `typescript-host-service`</li><li>Type: string</li></ul> |
| **`typescript.serverPort`**<br>[Required when `typescript.mode` is `grpc`] | <ul><li>gRPC port of `typescript-host-service`, matching that service's `grpc.listener` port.</li><li>Environment variable: `RHIZE_WORKFLOW_TYPESCRIPT_SERVERPORT`</li><li>Example: `9082`</li><li>Type: string</li></ul> |

### `restate`

| Value | Description |
| --- | --- |
| **`restate.adminUrl`**<br>[Required] | <ul><li>Restate admin API. Used at startup to register this deployment with Restate, and afterwards to list services and manage invocations. Registration failure is logged as a warning rather than being fatal, but an unregistered engine never receives work.</li><li>Environment variable: `RHIZE_WORKFLOW_RESTATE_ADMINURL`</li><li>Default: `http://restate:9070`</li><li>Example: `http://restate:9070`</li><li>Type: string</li></ul> |
| **`restate.serverUrl`**<br>[Required] | <ul><li>Restate ingress URL the workflow service posts to when invoking handlers.</li><li>Environment variable: `RHIZE_WORKFLOW_RESTATE_SERVERURL`</li><li>Example: `http://restate:8080`</li><li>Type: string</li></ul> |

### `service`

| Value | Description |
| --- | --- |
| **`service.hostname`**<br>[Required] | <ul><li>Address Restate is told to call this engine back on, combined with `http.port` to form the registered deployment URI. The derived value only resolves when that prefix happens to match the Kubernetes Service name, so existing deployments set it explicitly.</li><li>Environment variable: `RHIZE_WORKFLOW_SERVICE_HOSTNAME`</li><li>Default: pod hostname up to the first `-`</li><li>Example: `workflow`</li><li>Type: string</li></ul> |

### `jsonSchema`

| Value | Description |
| --- | --- |
| **`jsonSchema.registry`**<br>[Required when a workflow uses a JSON Schema task] | <ul><li>Base URL of the JSON Schema registry. Schema references in a JSON Schema task that are not already absolute `http://` or `https://` URLs are resolved against this prefix.</li><li>Environment variable: `RHIZE_WORKFLOW_JSONSCHEMA_REGISTRY`</li><li>Example: `http://schema-registry:8080`</li><li>Type: string</li></ul> |

## Helm chart values

Values shared by every chart are documented in `shared-helm-values.md`.
Only values specific to this chart are listed here.

Note that this chart deploys a **StatefulSet**, not a Deployment, and creates a
headless Service alongside the normal one.

| Value | Description |
| --- | --- |
| **`workflowConfig`**<br>[Required] | <ul><li>The complete application configuration, rendered verbatim into the `workflow-config` ConfigMap as `config.yaml`. Every key in the section above goes here.</li><li>Default: the block described above</li><li>Example: the Application configuration section</li><li>Type: object</li></ul> |
| **`envVars`** | <ul><li>Map of literal environment variable names to values, passed straight to the container. The usual way to override a single config key without restructuring `workflowConfig`.</li><li>Example: see the example block below</li><li>Type: map</li></ul> |
| **`extraEnvVars`** | <ul><li>Raw list of container `env` entries, rendered as-is so each supports `value` or `valueFrom`. Use for credentials sourced from an existing Secret.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`additionalSecrets`** | <ul><li>List of entries that each carry one value from a Kubernetes Secret into an environment variable: `name` is the variable the service reads, `secretName` is the Secret to take the value from, and `secretKey` is the name of the entry within that Secret. This is how every credential should reach the workflow service, using the environment variable names listed in the tables above: `RHIZE_WORKFLOW_OIDC_CLIENTSECRET` and `RHIZE_WORKFLOW_SECRET_KEY`. `extraEnvVars` does the same job and also accepts values from sources other than Secrets.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`podManagementPolicy`** | <ul><li>StatefulSet pod management. `OrderedReady` starts pods one at a time; `Parallel` starts them all at once for a faster rollout. This is safe because every replica receives a copy of each broker message, and the duplicate copies are discarded further along, so a message is still only acted on once.</li><li>Default: `OrderedReady`</li><li>Example: `OrderedReady`</li><li>Type: string</li></ul> |
| **`updateStrategy`** | <ul><li>Overrides the StatefulSet update strategy. Empty means the StatefulSet default of `RollingUpdate`.</li><li>Example: `{type: RollingUpdate}`</li><li>Type: object</li></ul> |
| **`graphqlCA`** | <ul><li>Contents of a PEM CA certificate for calling the GraphQL endpoint over TLS, given as a YAML block, `graphqlCA: \|`, with the certificate's lines indented beneath. When set, the certificate is mounted at `/certs/ca-cert.pem` and `libreDataStoreGraphQl.caFile` is set to that path.</li><li>Example: `-----BEGIN CERTIFICATE-----…`</li><li>Type: string</li></ul> |

A log level set directly, two credentials taken from Secrets, and one variable
taken from a Secret through `extraEnvVars`:

```yaml
envVars:
  RHIZE_WORKFLOW_LOGGING_LEVEL: info
additionalSecrets:
  - name: RHIZE_WORKFLOW_OIDC_CLIENTSECRET
    secretName: libre-secrets
    secretKey: libreBPMN
  - name: RHIZE_WORKFLOW_SECRET_KEY
    secretName: libre-secrets
    secretKey: workflowSecret
extraEnvVars:
  - name: EXTERNAL_DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: libre-secrets
        key: externalDbPassword
```

### `brokers`

Add a broker here for each MQTT or AMQP broker whose messages should start or
resume a workflow, or that a message throw event publishes to.
A message arriving on one of its topics starts a workflow with a matching message start
event and resumes a workflow waiting at a matching message catch event.

`brokers` is a map whose keys are broker ids you choose, so each setting is
written `brokers.<id>.<field>`. The id is meaningful: a BPMN message named
`<id>.<topic>` binds to `<topic>` on that broker.

These are the only chart values that reach the pod as environment variables and
nothing else, with no ConfigMap involved. The id and the field name both become part of the
variable name, so `brokers.test_mqtt.protocol` arrives as
`RHIZE_WORKFLOW_BROKERS_TEST_MQTT_PROTOCOL`. Every field accepts either a scalar,
which becomes a literal value, or a map naming an existing Kubernetes Secret and
the entry within it — `{secretName: …, secretKey: …}` — so that the value never
appears in the manifest.

| Value | Description |
| --- | --- |
| **`brokers.<id>.protocol`**<br>[Required when the broker entry is defined] | <ul><li>Kind of broker: `MQTT` or `AMQP`.</li><li>Environment variable: `RHIZE_WORKFLOW_BROKERS_<ID>_PROTOCOL`</li><li>Example: `MQTT` for MQTT, `AMQP` for AMQP</li><li>Type: string</li></ul> |
| **`brokers.<id>.connectionString`**<br>[Required when the broker entry is defined] | <ul><li>Address of the broker. The scheme has to match the protocol: `mqtt://` on 1883 or `mqtts://` for MQTT, `amqp://` on 5672 or `amqps://` on 5671 for AMQP. The `s` variants are the TLS ports.</li><li>Environment variable: `RHIZE_WORKFLOW_BROKERS_<ID>_CONNECTIONSTRING`</li><li>Example: `mqtt://mqtt:1883` for MQTT, `amqp://amqp-broker:5672` for AMQP</li><li>Type: string</li></ul> |
| **`brokers.<id>.username`** | <ul><li>Username for the broker. Usually a literal, since it is not sensitive. Omit for an anonymous connection.</li><li>Environment variable: `RHIZE_WORKFLOW_BROKERS_<ID>_USERNAME`</li><li>Example: `rhize-workflow`</li><li>Type: string or map</li></ul> |
| **`brokers.<id>.password`** | <ul><li>Password for the broker. Give this as a map naming a Kubernetes Secret and the entry within it rather than as a literal.</li><li>Environment variable: `RHIZE_WORKFLOW_BROKERS_<ID>_PASSWORD`</li><li>Example: `{secretName: libre-secrets, secretKey: mqttPassword}`</li><li>Type: string or map</li></ul> |
| **`brokers.<id>.certificate`** | <ul><li>Client certificate for the broker, for use with an `mqtts://` or `amqps://` connection string.</li><li>Environment variable: `RHIZE_WORKFLOW_BROKERS_<ID>_CERTIFICATE`</li><li>Example: `{secretName: libre-secrets, secretKey: mqttCert}`</li><li>Type: string or map</li></ul> |
| **`defaultBroker`** | <ul><li>Broker id that a BPMN message with a bare topic name, carrying no `<id>.` prefix, falls back to. Name one of the ids in `brokers`, or leave this empty to require every message name to carry a prefix.</li><li>Environment variable: `RHIZE_WORKFLOW_DEFAULTBROKER`</li><li>Example: `test_mqtt`</li><li>Type: string</li></ul> |

Two brokers, with the MQTT password taken from a Secret:

```yaml
defaultBroker: test_mqtt
brokers:
  test_mqtt:
    protocol: MQTT
    connectionString: "mqtt://mqtt:1883"
    password:
      secretName: libre-secrets
      secretKey: mqttPassword
  test_amqp:
    protocol: AMQP
    connectionString: "amqp://amqp-broker:5672"
    username: svc
```

A workflow uses a broker through the Message section of an event's properties
in the BPMN editor. Choose a Global message reference, or create one, and give
it a Name made of the broker id, a `.`, and the topic. With the brokers above:

- On a message start event, the Name `test_mqtt.orders` starts the workflow
  each time a message arrives on the `orders` topic of `test_mqtt`.
- On a message intermediate throw event, the Name `test_amqp.order-accepted`
  publishes to the `order-accepted` topic of `test_amqp` when the workflow
  reaches that event.
