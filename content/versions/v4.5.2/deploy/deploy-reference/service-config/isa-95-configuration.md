---
title: 'ISA-95 configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize ISA-95 service
aliases:
  - /reference/service-config/isa-95-configuration
weight: 900
---

This document covers how to configure the ISA-95 service through its Helm Chart.

## Application configuration

isa95 is configured entirely through environment variables, set in the chart's
`envVars`. There is no configuration file, so any setting left unset takes its
default value.

### General settings

| Value | Description |
| --- | --- |
| **`port`** | <ul><li>Port isa95 listens on, serving the Restate handler, `/healthz`, `/metrics`, and the custom GraphQL endpoint. Keep this in step with the chart's container port and probes, which both use the default value.</li><li>Environment variable: `RHIZE_ISA95_PORT`</li><li>Default: `8081`</li><li>Example: `8081`</li><li>Type: string</li></ul> |
| **`servicename`** | <ul><li>Name Restate is told to call this service back on, combined with `port` to form the registered deployment URI. Derived from the pod hostname, so override it when the Kubernetes Service name differs from the Deployment name.</li><li>Environment variable: `RHIZE_ISA95_SERVICENAME`</li><li>Default: the Deployment name</li><li>Example: `isa95`</li><li>Type: string</li></ul> |
| **`baas.url`**<br>[Required] | <ul><li>URL of the BAAS GraphQL endpoint, used for all GraphQL queries, GraphQL mutations, and DQL transactions.</li><li>Environment variable: `RHIZE_ISA95_BAAS_URL`</li><li>Default: `http://baas-alpha:8080/graphql`</li><li>Example: `http://baas-alpha:8080/graphql`</li><li>Type: string</li></ul> |
| **`secret.key`**<br>[Required when a secret value is written or read] | <ul><li>Passphrase used to derive the `age` scrypt identity that encrypts and decrypts secret values. Creating or reading a secret fails with "LIBRE_SECRET_KEY is not configured" when empty. Must be the same passphrase used by other services that read the same secrets. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_ISA95_SECRET_KEY`</li><li>Example: `ExamplePassphrase-Rhize-2026`</li><li>Type: string</li></ul> |
| **`logging.level`** | <ul><li>Lowest severity that reaches the log, one of `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`, or `disabled`. Each level lets through itself and everything more severe, so `info` keeps informational messages, warnings, and errors but drops trace and debug, and `disabled` stops isa95 logging at all.</li><li>Environment variable: `RHIZE_ISA95_LOGGING_LEVEL`</li><li>Default: `trace`</li><li>Example: `info`</li><li>Type: string</li></ul> |
| **`logging.type`** | <ul><li>Output format. `json` writes structured JSON to stderr, for collection by a log aggregator. `multi` writes human-readable lines to stderr and JSON to stdout at the same time. Left unset, as the chart leaves it, logs are written as human-readable lines to stderr.</li><li>Environment variable: `RHIZE_ISA95_LOGGING_TYPE`</li><li>Example: `json`</li><li>Type: string</li></ul> |

### `oidc`

At startup isa95 fetches the provider's `.well-known/openid-configuration` and
public keys and then obtains an access token; **failure at either step exits the
process**. isa95 signs in as a user rather than as the client, so it takes a
username and password alongside the client id and secret.

| Value | Description |
| --- | --- |
| **`oidc.serverUrl`**<br>[Required] | <ul><li>Base URL of the OIDC provider. isa95 appends the realm path.</li><li>Environment variable: `RHIZE_ISA95_OIDC_SERVERURL`</li><li>Default: `http://localhost:8090`</li><li>Example: `http://keycloak:80`</li><li>Type: string</li></ul> |
| **`oidc.realm`**<br>[Required when `oidc.enableGenericOidc` is `false`] | <ul><li>Keycloak realm, appended to `oidc.serverUrl`.</li><li>Environment variable: `RHIZE_ISA95_OIDC_REALM`</li><li>Default: `libre`</li><li>Example: `libre`</li><li>Type: string</li></ul> |
| **`oidc.clientId`**<br>[Required] | <ul><li>Client ID isa95 authenticates as.</li><li>Environment variable: `RHIZE_ISA95_OIDC_CLIENTID`</li><li>Example: `libreISA95`</li><li>Type: string</li></ul> |
| **`oidc.clientSecret`**<br>[Required] | <ul><li>Client secret paired with `oidc.clientId`. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_ISA95_OIDC_CLIENTSECRET`</li><li>Example: `Qm7xT2vLp9RcW4nZk8HbY3jDf6sGa1Ue`</li><li>Type: string</li></ul> |
| **`oidc.username`**<br>[Required] | <ul><li>Service account isa95 signs in as.</li><li>Environment variable: `RHIZE_ISA95_OIDC_USERNAME`</li><li>Example: `libreisa95@libremfg.ai`</li><li>Type: string</li></ul> |
| **`oidc.password`**<br>[Required] | <ul><li>Password for `oidc.username`. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_ISA95_OIDC_PASSWORD`</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`oidc.enableGenericOidc`** | <ul><li>Switches from Keycloak-specific token handling to generic OIDC.</li><li>Environment variable: `RHIZE_ISA95_OIDC_ENABLEGENERICOIDC`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`oidc.customRolesKey`** | <ul><li>JWT claim holding roles under generic OIDC.</li><li>Environment variable: `RHIZE_ISA95_OIDC_CUSTOMROLESKEY`</li><li>Default: `rhize.com/roles`</li><li>Example: `rhize.com/roles`</li><li>Type: string</li></ul> |
| **`oidc.customAudienceKey`** | <ul><li>JWT claim holding the audience under generic OIDC. Falls back to the standard `aud` claim when empty.</li><li>Environment variable: `RHIZE_ISA95_OIDC_CUSTOMAUDIENCEKEY`</li><li>Default: `rhize.com/aud`</li><li>Example: `rhize.com/aud`</li><li>Type: string</li></ul> |
| **`libreDataStoreGraphQl.caFile`** | <ul><li>Path to a PEM CA certificate isa95 trusts in addition to the system roots when making outbound HTTPS calls. Empty means system roots only. Set it to the path the certificate is mounted at, which is `/certs/graphql_ca.crt` for a certificate supplied through the chart's `graphqlCA` value.</li><li>Environment variable: `RHIZE_ISA95_LIBREDATASTOREGRAPHQL_CAFILE`</li><li>Example: `/certs/graphql_ca.crt`</li><li>Type: string</li></ul> |

### `restate`

| Value | Description |
| --- | --- |
| **`restate.admin`**<br>[Required] | <ul><li>Restate admin API. Used at startup to register this deployment with `force: true`, and by the admin API service. A trailing slash is stripped. Registration failure is logged as a warning, but an unregistered service never receives work.</li><li>Environment variable: `RHIZE_ISA95_RESTATE_ADMIN`</li><li>Default: `http://localhost:9070`</li><li>Example: `http://restate:9070`</li><li>Type: string</li></ul> |
| **`restate.serverurl`**<br>[Required] | <ul><li>Restate ingress URL used when isa95 invokes handlers itself.</li><li>Environment variable: `RHIZE_ISA95_RESTATE_SERVERURL`</li><li>Default: `http://localhost:18080`</li><li>Example: `http://restate:8080`</li><li>Type: string</li></ul> |

### `kafka`

Consumed only when `valuechange.direct` is enabled, which puts isa95 into
direct Kafka consumption rather than receiving events through Restate.

| Value | Description |
| --- | --- |
| **`kafka.servername`**<br>[Required when `valuechange.direct` is `true`] | <ul><li>Broker hostname, joined with `kafka.serverport` to form the bootstrap address.</li><li>Environment variable: `RHIZE_ISA95_KAFKA_SERVERNAME`</li><li>Default: `localhost`</li><li>Example: `redpanda`</li><li>Type: string</li></ul> |
| **`kafka.serverport`**<br>[Required when `valuechange.direct` is `true`] | <ul><li>Broker port.</li><li>Environment variable: `RHIZE_ISA95_KAFKA_SERVERPORT`</li><li>Default: `29092`</li><li>Example: `9092`</li><li>Type: string</li></ul> |
| **`kafka.groupid`** | <ul><li>Consumer group id. Change the group id only if you intend to run an independent set of consumers.</li><li>Environment variable: `RHIZE_ISA95_KAFKA_GROUPID`</li><li>Default: `rhize-isa95`</li><li>Example: `rhize-isa95`</li><li>Type: string</li></ul> |
| **`kafka.consumer_count`** | <ul><li>Number of consumers started per topic. Raise the count to read faster, up to the number of partitions on the topic.</li><li>Environment variable: `RHIZE_ISA95_KAFKA_CONSUMER_COUNT`</li><li>Default: `1`</li><li>Example: `1`</li><li>Type: integer</li></ul> |
| **`valuechange.direct`** | <ul><li>Enables direct Kafka consumption of value change events. When off, none of the Kafka settings are used.</li><li>Environment variable: `RHIZE_ISA95_VALUECHANGE_DIRECT`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`valuechange.topic`** | <ul><li>Space-separated list of topics to consume. Empty means the single topic `ValueChange`.</li><li>Environment variable: `RHIZE_ISA95_VALUECHANGE_TOPIC`</li><li>Example: `ValueChange import_materials import`</li><li>Type: list</li></ul> |
| **`ludicrous.mode`** | <ul><li>Commits Kafka offsets in batches rather than one per message, which is faster but can replay or skip a few messages after an unclean restart.</li><li>Environment variable: `RHIZE_ISA95_LUDICROUS_MODE`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |

### `questdb`

The time series store for equipment property history. Reads and writes use two
different QuestDB ports: queries go over the PostgreSQL protocol, and writes go
over the InfluxDB line protocol on HTTP.

| Value | Description |
| --- | --- |
| **`questdb.host`**<br>[Required when `timeseries.enabled` is `true`] | <ul><li>QuestDB hostname, used for both queries and writes.</li><li>Environment variable: `RHIZE_ISA95_QUESTDB_HOST`</li><li>Default: `localhost`</li><li>Example: `questdb`</li><li>Type: string</li></ul> |
| **`questdb.port`**<br>[Required when `timeseries.enabled` is `true`] | <ul><li>Port QuestDB serves the PostgreSQL protocol on, used for queries only; writes always go to port 9000 unless `questdb.ilpconf` says otherwise. QuestDB serves this on `8812` unless it has been configured otherwise, so set this to match the QuestDB being used.</li><li>Environment variable: `RHIZE_ISA95_QUESTDB_PORT`</li><li>Default: `38812`</li><li>Example: `8812`</li><li>Type: integer</li></ul> |
| **`questdb.username`**<br>[Required when `timeseries.enabled` is `true`] | <ul><li>QuestDB username.</li><li>Environment variable: `RHIZE_ISA95_QUESTDB_USERNAME`</li><li>Example: `admin`</li><li>Type: string</li></ul> |
| **`questdb.password`**<br>[Required when `timeseries.enabled` is `true`] | <ul><li>QuestDB password. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_ISA95_QUESTDB_PASSWORD`</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`questdb.ilpconf`** | <ul><li>Complete line protocol connection string, which when set replaces the string built from host, username, and password. Use this string to reach QuestDB on a non-default line protocol port or over TLS.</li><li>Environment variable: `RHIZE_ISA95_QUESTDB_ILPCONF`</li><li>Example: `http::addr=questdb:9000;`</li><li>Type: string</li></ul> |
| **`timeseries.enabled`** | <ul><li>Enables time series recording of equipment property changes and binds the historical equipment property Restate service.</li><li>Environment variable: `RHIZE_ISA95_TIMESERIES_ENABLED`</li><li>Default: `true`</li><li>Example: `true`</li><li>Type: boolean</li></ul> |

### `equipment_property_change_buffer`

Batches equipment property changes before writing them to the time series store.
Each value falls back to the built-in default if it is zero or negative, with a
warning.

| Value | Description |
| --- | --- |
| **`equipment_property_change_buffer.flush_interval`** | <ul><li>How often buffered changes are flushed.</li><li>Environment variable: `RHIZE_ISA95_EQUIPMENT_PROPERTY_CHANGE_BUFFER_FLUSH_INTERVAL`</li><li>Default: `1s`</li><li>Example: `1s`</li><li>Type: duration</li></ul> |
| **`equipment_property_change_buffer.buffer_size_per_equipment`** | <ul><li>Maximum buffered changes held per equipment before an early flush.</li><li>Environment variable: `RHIZE_ISA95_EQUIPMENT_PROPERTY_CHANGE_BUFFER_BUFFER_SIZE_PER_EQUIPMENT`</li><li>Default: `50`</li><li>Example: `50`</li><li>Type: integer</li></ul> |
| **`equipment_property_change_buffer.receive_channel_size`** | <ul><li>Capacity of the channel feeding the buffer. Raise the capacity if bursts of incoming data are being dropped.</li><li>Environment variable: `RHIZE_ISA95_EQUIPMENT_PROPERTY_CHANGE_BUFFER_RECEIVE_CHANNEL_SIZE`</li><li>Default: `1000`</li><li>Example: `1000`</li><li>Type: integer</li></ul> |

### Other services

| Value | Description |
| --- | --- |
| **`jsonata.grpc`**<br>[Required] | <ul><li>Host and port of `typescript-host-service`, as a single `host:port` string.</li><li>Environment variable: `RHIZE_ISA95_JSONATA_GRPC`</li><li>Default: `localhost:19082`</li><li>Example: `typescript-host-service:9082`</li><li>Type: string</li></ul> |
| **`opentelemetry.serverurl`** | <ul><li>OTLP endpoint for trace export.</li><li>Environment variable: `RHIZE_ISA95_OPENTELEMETRY_SERVERURL`</li><li>Default: `localhost:4317`</li><li>Example: `tempo-distributor.monitoring.svc.cluster.local:4317`</li><li>Type: string</li></ul> |

## Helm chart values

Values shared by every chart are documented in
`shared-helm-values.md`. This chart deploys a Deployment, has no
ConfigMap, and passes all configuration as environment variables.

| Value | Description |
| --- | --- |
| **`envVars`**<br>[Required] | <ul><li>Map of environment variable names to values, passed straight to the container. This is the primary configuration mechanism for isa95.</li><li>Default: `RHIZE_ISA95_BAAS_URL` and `RHIZE_ISA95_PORT`</li><li>Example: see the example block below</li><li>Type: map</li></ul> |
| **`additionalSecrets`** | <ul><li>List of entries that each carry one value from a Kubernetes Secret into an environment variable: `name` is the variable the service reads, `secretName` is the Secret to take the value from, and `secretKey` is the name of the entry within that Secret. This is how every credential should reach isa95, using the environment variable names listed in the tables above: `RHIZE_ISA95_OIDC_CLIENTSECRET`, `RHIZE_ISA95_OIDC_PASSWORD`, `RHIZE_ISA95_SECRET_KEY`, and the QuestDB password.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`graphqlCA`** | <ul><li>Contents of a PEM CA certificate for outbound HTTPS calls, given as a YAML block, `graphqlCA: \|`, with the certificate's lines indented beneath. Trusting a certificate takes two values: give the certificate here, which mounts it at `/certs/graphql_ca.crt`, and set `RHIZE_ISA95_LIBREDATASTOREGRAPHQL_CAFILE` to that path through `envVars`.</li><li>Example: `-----BEGIN CERTIFICATE-----…`</li><li>Type: string</li></ul> |

The Deployment also sets `POD_IP` from the downward API.

The Restate admin URL set directly, and two credentials taken from Secrets:

```yaml
envVars:
  RHIZE_ISA95_RESTATE_ADMIN: "http://restate:9070"
additionalSecrets:
  - name: RHIZE_ISA95_OIDC_CLIENTSECRET
    secretName: libre-client-secrets
    secretKey: libreISA95
  - name: RHIZE_ISA95_SECRET_KEY
    secretName: libre-secrets
    secretKey: isa95SecretKey
```
