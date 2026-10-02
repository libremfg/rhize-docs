---
title: 'DRAFT Agent configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize agent
draft: true
aliases:
  - /reference/service-config/agent-configuration
  - "/reference/agent-configuration/"
weight: 900
---


Configure the libre-agent service through its Helm chart.

The chart's `rhizeAgentConfig`
value holds the application configuration, and the other chart values control
the deployment, including environment variables that override individual
settings.

## Application configuration

Everything in this section goes into the chart's `rhizeAgentConfig` value, which
becomes libre-agent's entire configuration file. 

The chart ships a populated
`rhizeAgentConfig` with defaults.
If you delete a key, most take no value.
Some revert to a built-in value meant for a developer's own machine:
-`libreDataStoreGraphQl.serverUrl` becomes`http://localhost:8080/graphql`
- `oidc.serverUrl` becomes `http://localhost:8090`,
- `nats.serverUrl` becomes `nats://localhost:4222`,
- `datasource.id` becomes `server`.


To override individual keys, use the environment variable supplied through the chart's `envVars` or `additionalSecrets`.

Many of the following sections are required for only some deployments. 
There are three ways to set libre-agent up:

- **Run a subscription:** watches a source system and publishes every value change it
   sees.
    This source is configured by the `datasource.id` value on the BAAS data source record.
- **Answer commands:** answers a caller's request to read a tag, write a value, or call
    a method on a device.
- **Bridge:** carries messages from one broker to another.

A subscription and commands can run in the same deployment, and most deployments run both.
However, a bridge cannot run with a subscription or command.

<!--
A subscription has libre-agent watch a source system and publish every value
change it sees. The source is not chosen here — that choice is made on the data
source record in BAAS named by `datasource.id`, and is one of an OPC UA server,
an MQTT broker, a Kafka broker, Azure Event Hubs, or Azure Service Bus. Fill in
the matching section — `opcUa`, `mqtt`, `kafka`, `eventHubs`, or `azure` — so
libre-agent can connect to that system, and list where the values go under
`egress`.

Commands go the other way: a caller asks libre-agent to read a tag now, write a
value to a tag or topic on the data source, or call a method on a device. Every
command answers: a read and a method call with a value, a write with the outcome
for each tag or topic it wrote. The answer goes back to the caller rather than to
the `egress` handlers, so the command settings cover how the command API is
reached and leave the subscription alone.


A bridge carries messages from one broker to another, and everything it needs is
in the `bridge` section.
-->

### General settings

| Value | Description |
| --- | --- |
| **`datasource.id`**<br>[Required] | <ul><li>ID of the data source record in BAAS that drives this deployment. Everything libre-agent subscribes to and publishes is read from that record, so a value matching no record in BAAS leaves libre-agent running but idle. Also used to build the OPC UA session name.</li><li>Environment variable: `RHIZE_AGENT_DATASOURCE_ID`</li><li>Default: `libre-agent`</li><li>Example: `DS_0806`</li><li>Type: string</li></ul> |
| **`libreDataStoreGraphQl.serverUrl`**<br>[Required] | <ul><li>GraphQL endpoint libre-agent fetches the data source record from. Give the full address of the BAAS alpha Service, including the port and the `/graphql` path, since the path is not added for you. Startup fails with `Unable to get initial config`` if this endpoint is unreachable.</li><li>Environment variable: `RHIZE_AGENT_LIBREDATASTOREGRAPHQL_SERVERURL`</li><li>Default: `http://baas-alpha:8080/graphql`</li><li>Example: `http://baas-alpha:8080/graphql`</li><li>Type: string</li></ul> |
| **`libreDataStoreGraphQl.caFile`** | <ul><li>Path to a PEM CA certificate libre-agent trusts in addition to the system roots when making outbound HTTPS calls to BAAS and to the OIDC provider. Set it to the path the certificate is mounted at, which is `/certs/ca-cert.pem` for a certificate supplied through the chart's `caFile` value. A path that cannot be read or parsed stops the calls that need it.</li><li>Environment variable: `RHIZE_AGENT_LIBREDATASTOREGRAPHQL_CAFILE`</li><li>Example: `/certs/ca-cert.pem`</li><li>Type: string</li></ul> |
| **`logging.level`** | <ul><li>Lowest severity that reaches the log, one of `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`, or `disabled`. Each level lets through itself and everything more severe, so `info` keeps informational messages, warnings, and errors but drops trace and debug, and `disabled` stops libre-agent logging at all. Setting `trace` or `debug` also logs the full configuration libre-agent is running with at startup, which is the quickest way to check that a value you set actually reached libre-agent.</li><li>Environment variable: `RHIZE_AGENT_LOGGING_LEVEL`</li><li>Default: `info`</li><li>Example: `info`</li><li>Type: string</li></ul> |
| **`logging.type`** | <ul><li>Output format. `json` writes structured JSON to stderr, for collection by a log aggregator. `multi` writes human-readable lines to stderr and JSON to stdout at the same time. `console` writes human-readable lines to stderr.</li><li>Environment variable: `RHIZE_AGENT_LOGGING_TYPE`</li><li>Default: `console`</li><li>Example: `json`</li><li>Type: string</li></ul> |
| **`openTelemetry.serverUrl`** | <ul><li>OTLP gRPC endpoint for trace export, given as host and port with no scheme. Failure to initialise is logged as a warning and libre-agent continues without tracing.</li><li>Environment variable: `RHIZE_AGENT_OPENTELEMETRY_SERVERURL`</li><li>Default: `otel:4317`</li><li>Example: `tempo-distributor.monitoring.svc.cluster.local:4317`</li><li>Type: string</li></ul> |

### `oidc`

| Value | Description |
| --- | --- |
| **`oidc.serverUrl`**<br>[Required] | <ul><li>Base URL of the OIDC provider. Endpoints are discovered from `<SERVER_URL>/.well-known/openid-configuration`.</li><li>Environment variable: `RHIZE_AGENT_OIDC_SERVERURL`</li><li>Default: `http://keycloak:80`</li><li>Example: `http://keycloak:80`</li><li>Type: string</li></ul> |
| **`oidc.realm`**<br>[Required when `oidc.enableGenericOidc` is `false`] | <ul><li>Keycloak realm.</li><li>Environment variable: `RHIZE_AGENT_OIDC_REALM`</li><li>Default: `libre`</li><li>Example: `libre`</li><li>Type: string</li></ul> |
| **`oidc.clientId`**<br>[Required] | <ul><li>Client ID. Tokens are obtained with the client credentials grant, so the client's service account needs the required roles in the provider.</li><li>Environment variable: `RHIZE_AGENT_OIDC_CLIENTID`</li><li>Default: `libreAgent`</li><li>Example: `libreAgent`</li><li>Type: string</li></ul> |
| **`oidc.clientSecret`**<br>[Required] | <ul><li>Client secret paired with `oidc.clientId`. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_AGENT_OIDC_CLIENTSECRET`</li><li>Example: `8f3b6c21-4d5e-4a7b-9c0d-1e2f3a4b5c6d`</li><li>Type: string</li></ul> |
| **`oidc.enableGenericOidc`** | <ul><li>Switches to a generic OIDC provider, such as Okta, rather than Keycloak-specific handling.</li><li>Environment variable: `RHIZE_AGENT_OIDC_ENABLEGENERICOIDC`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`oidc.customAudienceKey`** | <ul><li>Claim to read the audience from when using a non-Keycloak provider.</li><li>Environment variable: `RHIZE_AGENT_OIDC_CUSTOMAUDIENCEKEY`</li><li>Example: `rhize.com/aud`</li><li>Type: string</li></ul> |
| **`oidc.credentialsScope`** | <ul><li>Optional scope requested during the client credentials grant.</li><li>Environment variable: `RHIZE_AGENT_OIDC_CREDENTIALSSCOPE`</li><li>Example: `openid`</li><li>Type: string</li></ul> |

### Commands

Alongside the subscription, libre-agent answers individual commands:
- Read a tag now.
- Write a value to a tag or topic on the data source.
- Call a method on a device.

When `restate.enabled` is on, which is the chart's default, the command
API is served through Restate, and these settings describe how it is reached.
An answer returns to the caller the same way it came rather than through an
`egress` handler.

Which commands can be answered depends on the type of data source.
- An OPC UA data source answers all three. The libre-agent will not start without
`restate.enabled`, stopping with `At least one of NATS or Kafka or Restate must be enabled for OPCUA data source`.
- An MQTT data source answers writes only, and requires `restate.enabled` to be `true`: if `false`, libre-agent runs but accepts no commands at all.
- A Kafka, Azure Service Bus, or Azure Event Hubs data source
answers no commands. These need `restate.enabled` to be `false`. If `true`, libre-agent
still tries to register with Restate at startup and exits if it cannot.

| Value | Description |
| --- | --- |
| **`restate.enabled`**<br>[Required when the data source is Kafka, Azure Service Bus, or Azure Event Hubs] | <ul><li>Makes libre-agent serve read, write, and method call commands over HTTP on the port the chart's `service.port` sets and register itself with Restate at startup, after which a caller reaches libre-agent by invoking it through Restate rather than by sending to it directly. Registration is a single attempt: libre-agent exits if it fails, so turn this off for a data source that answers no commands.</li><li>Environment variable: `RHIZE_AGENT_RESTATE_ENABLED`</li><li>Default: `true`</li><li>Example: `true`</li><li>Type: boolean</li></ul> |
| **`restate.adminUrl`**<br>[Required when `restate.enabled` is `true`] | <ul><li>Restate admin API libre-agent registers itself with.</li><li>Environment variable: `RHIZE_AGENT_RESTATE_ADMINURL`</li><li>Default: `http://restate:9070`</li><li>Example: `http://restate:9070`</li><li>Type: string</li></ul> |
| **`restate.serviceName`** | <ul><li>Hostname Restate calls back on. Derived from the pod hostname. </li><li>Environment variable: `RHIZE_AGENT_RESTATE_SERVICENAME`</li><li>Default: the Deployment name</li><li>Example: `libre-agent`</li><li>Type: string</li></ul> |

### Data sources

How libre-agent connects to the system it reads from. Fill in the one section
that matches the data source record in BAAS — `kafka`, `opcUa`, `mqtt`, `azure`
for Azure Service Bus, or `eventHubs` — and leave the others out. `health`
applies only to an OPC UA server.

#### `kafka`

How libre-agent connects to the Kafka broker supplying the data.

| Value | Description |
| --- | --- |
| **`kafka.bootstrapServerUrl`**<br>[Required when the data source is Kafka] | <ul><li>Kafka bootstrap server.</li><li>Environment variable: `RHIZE_AGENT_KAFKA_BOOTSTRAPSERVERURL`</li><li>Example: `redpanda:9092`</li><li>Type: string</li></ul> |
| **`kafka.groupId`**<br>[Required when the data source is Kafka] | <ul><li>Name of the Kafka consumer group libre-agent reads under. Every replica reads under this group, so the topics are split between them and each message is read once rather than once per replica. The group also remembers how far it has read, so a restart continues from the last read. A group ID that has not been used before starts at the oldest message the topic still holds.</li><li>Environment variable: `RHIZE_AGENT_KAFKA_GROUPID`</li><li>Example: `libre-agent`</li><li>Type: string</li></ul> |
| **`kafka.workerThreads`** | <ul><li>Number of worker threads reading from the broker in parallel.</li><li>Environment variable: `RHIZE_AGENT_KAFKA_WORKERTHREADS`</li><li>Default: `1`</li><li>Example: `1`</li><li>Type: integer</li></ul> |
| **`kafka.sessionTimeout`** | <ul><li>Consumer session timeout in milliseconds.</li><li>Environment variable: `RHIZE_AGENT_KAFKA_SESSIONTIMEOUT`</li><li>Default: `60000`</li><li>Example: `30000`</li><li>Type: integer</li></ul> |
| **`kafka.maxSendRetries`** | <ul><li>Retries for a failed send.</li><li>Environment variable: `RHIZE_AGENT_KAFKA_MAXSENDRETRIES`</li><li>Default: `3`</li><li>Example: `3`</li><li>Type: integer</li></ul> |

#### `opcUa`

How libre-agent connects to the OPC UA server supplying the data. Relevant
only when the data source is an OPC UA server.

| Value | Description |
| --- | --- |
| **`opcUa.serverUrl`**<br>[Required when the data source is OPC UA] | <ul><li>OPC UA endpoint to connect to.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_SERVERURL`</li><li>Default: `opc.tcp://opcua-server`</li><li>Example: `opc.tcp://opcua-server:4840`</li><li>Type: string</li></ul> |
| **`opcUa.discoveryUrl`**<br>[Required when the data source is OPC UA] | <ul><li>OPC UA discovery endpoint, usually the same as `serverUrl`.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_DISCOVERYURL`</li><li>Default: `opc.tcp://opcua-server`</li><li>Example: `opc.tcp://opcua-server:4840`</li><li>Type: string</li></ul> |
| **`opcUa.authentication`** | <ul><li>How libre-agent identifies itself to the server. `Anonymous` presents no identity and ignores `opcUa.username` and `opcUa.password`. `UserName` signs in with that pair. `Certificate` presents the client certificate from `opcUa.certFile` and proves ownership with `opcUa.keyFile`. The server has to offer the chosen method on the endpoint it selects.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_AUTHENTICATION`</li><li>Default: `Anonymous`</li><li>Example: `UserName`</li><li>Type: string</li></ul> |
| **`opcUa.username`**<br>[Required when `opcUa.authentication` is `UserName`] | <ul><li>OPC UA username.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_USERNAME`</li><li>Example: `opcuauser`</li><li>Type: string</li></ul> |
| **`opcUa.password`**<br>[Required when `opcUa.authentication` is `UserName`] | <ul><li>OPC UA password. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_PASSWORD`</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`opcUa.mode`** | <ul><li>What protection is applied to each message. `None` sends them unsigned and in the clear. `Sign` signs them, so tampering is detectable while the contents stay readable on the wire. `SignAndEncrypt` signs and encrypts them. `Auto` takes the strongest mode the server advertises. Any other value logs "Invalid security Mode", matches no endpoint, and leaves libre-agent unable to connect.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_MODE`</li><li>Default: `Auto`</li><li>Example: `SignAndEncrypt`</li><li>Type: string</li></ul> |
| **`opcUa.policy`** | <ul><li>Cryptographic suite used for the signing and encryption `opcUa.mode` asks for, from the list under this table. Setting either this or `opcUa.mode` to `None` forces both to `None`, so security is off unless both carry a real value. Any other value stops libre-agent with "Invalid security Policy".</li><li>Environment variable: `RHIZE_AGENT_OPCUA_POLICY`</li><li>Default: `None`</li><li>Example: `Basic256Sha256`</li><li>Type: string</li></ul> |
| **`opcUa.applicationUri`** | <ul><li>Application URI libre-agent presents. Must match the URI in the client certificate when a security policy is in use.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_APPLICATIONURI`</li><li>Default: `urn:opcua-server.server.application`</li><li>Example: `urn:opcua-server.server.application`</li><li>Type: string</li></ul> |
| **`opcUa.certFile`** / **`opcUa.keyFile`**<br>[Required when `opcUa.mode` is `Sign` or `SignAndEncrypt`, `opcUa.authentication` is `Certificate`, or `opcUa.genCert` is `true`] | <ul><li>Paths inside the container to the client certificate and its private key, which has to be RSA. Both have to be set for either to be read. Mount the pair with `extraVolumes` and `extraVolumeMounts`, and register the certificate with the OPC UA server as a trusted client. A pair that fails to load logs `Failed to load certificate` and the connection goes on without a certificate, which the server then refuses.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_CERTFILE` / `RHIZE_AGENT_OPCUA_KEYFILE`</li><li>Example: `/certs/opcua-client.pem` / `/certs/opcua-client.key`</li><li>Type: string</li></ul> |
| **`opcUa.genCert`** | <ul><li>Generates a self-signed 2048-bit certificate for `opcUa.applicationUri` at startup and writes it to `opcUa.certFile` and `opcUa.keyFile`, so both need to name writable paths; left empty, the certificate is written to `cert.pem` and `key.pem` and then not found, which logs `Failed to load certificate`. A new certificate is generated on every start, even when the files already exist, so a server that trusted the last one rejects the next.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_GENCERT`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`opcUa.subscription.publishingInterval`** | <ul><li>How often, in milliseconds, the server publishes notifications.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_SUBSCRIPTION_PUBLISHINGINTERVAL`</li><li>Default: `1000`</li><li>Example: `1000`</li><li>Type: integer</li></ul> |
| **`opcUa.subscription.lifetimeCount`** | <ul><li>Publishing cycles the server keeps the subscription alive without a publish request. Should be at least three times `maxKeepAliveCount`.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_SUBSCRIPTION_LIFETIMECOUNT`</li><li>Default: `10000`</li><li>Example: `10000`</li><li>Type: integer</li></ul> |
| **`opcUa.subscription.maxKeepAliveCount`** | <ul><li>Publishing cycles without data before the server sends a keep-alive.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_SUBSCRIPTION_MAXKEEPALIVECOUNT`</li><li>Default: `3000`</li><li>Example: `3000`</li><li>Type: integer</li></ul> |
| **`opcUa.subscription.maxNotificationsPerPublish`** | <ul><li>The maximum notifications in a single publish response.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_SUBSCRIPTION_MAXNOTIFICATIONSPERPUBLISH`</li><li>Default: `10000`</li><li>Example: `10000`</li><li>Type: integer</li></ul> |
| **`opcUa.subscription.priority`** | <ul><li>Relative priority of this subscription on the server.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_SUBSCRIPTION_PRIORITY`</li><li>Default: `0`</li><li>Example: `0`</li><li>Type: integer</li></ul> |
| **`opcUa.monitoredItem.samplingInterval`** | <ul><li>How often, in milliseconds, the server samples each item. `0` means as fast as the server allows.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_MONITOREDITEM_SAMPLINGINTERVAL`</li><li>Default: `0`</li><li>Example: `0`</li><li>Type: integer</li></ul> |
| **`opcUa.monitoredItem.queueSize`** | <ul><li>Server-side queue depth per monitored item between publications. If samples are being lost between publishes, raise the queue size.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_MONITOREDITEM_QUEUESIZE`</li><li>Default: `100`</li><li>Example: `100`</li><li>Type: integer</li></ul> |
| **`opcUa.monitoredItem.discardOldest`** | <ul><li>Whether a full queue discards the oldest sample rather than the newest.</li><li>Environment variable: `RHIZE_AGENT_OPCUA_MONITOREDITEM_DISCARDOLDEST`</li><li>Default: `true`</li><li>Example: `true`</li><li>Type: boolean</li></ul> |

The `opcUa.policy` value accepts the following security policies:

| Value | Description |
| --- | --- |
| `Auto` | Takes the strongest policy the server advertises, leaving the choice to the server. |
| `None` | No signing or encryption, and it forces `opcUa.mode` to `None` as well. |
| `Basic128Rsa15` | 128-bit AES with SHA-1 signatures and RSA PKCS#1 v1.5 key exchange. Deprecated in OPC UA 1.04 and refused by many servers; set it only for equipment that offers nothing else. |
| `Basic256` | 256-bit AES with SHA-1 signatures. Deprecated on the same grounds as `Basic128Rsa15`. |
| `Basic256Sha256` | 256-bit AES with SHA-256 signatures. The policy most servers have in common, and the usual choice. |
| `Aes128_Sha256_RsaOaep` | 128-bit AES with SHA-256 signatures and RSA-OAEP key exchange, introduced in OPC UA 1.04. |
| `Aes256_Sha256_RsaPss` | 256-bit AES with SHA-256 signatures and RSA-PSS key exchange. The strongest of the set and the newest, so the least widely supported. |

#### `health`

Watches the tags libre-agent has subscribed to and renews the subscription for any
that stop reporting or begin returning errors. Only relevant when the data
source is an OPC UA server.

| Value | Description |
| --- | --- |
| **`health.pollInterval`** | <ul><li>How often, in milliseconds, every subscribed tag is checked. `0` turns the watcher off, so nothing is renewed. Anything under 200 is raised to 200, which is logged as `Poll interval is too low. Clamping.`</li><li>Environment variable: `RHIZE_AGENT_HEALTH_POLLINTERVAL`</li><li>Default: `1000`</li><li>Example: `1000`</li><li>Type: integer</li></ul> |
| **`health.subscriptionTimeout`** | <ul><li>How long, in milliseconds, a tag may report a bad status before its subscription is renewed. Anything over 24 hours is lowered to 24 hours, logged as `Node timeout is too high. Clamping.`</li><li>Environment variable: `RHIZE_AGENT_HEALTH_SUBSCRIPTIONTIMEOUT`</li><li>Default: `60000`</li><li>Example: `60000`</li><li>Type: integer</li></ul> |
| **`health.subscriptionMaxCount`** | <ul><li>How many OPC UA subscriptions libre-agent opens before it stops creating more and shares the existing ones between tags. Raise it where a server limits how many monitored items one subscription may carry.</li><li>Environment variable: `RHIZE_AGENT_HEALTH_SUBSCRIPTIONMAXCOUNT`</li><li>Default: `5`</li><li>Example: `5`</li><li>Type: integer</li></ul> |

Health is reported in two places:
- The log carries a line per tag as it is
renewed, at warn level, reading `Node status is not OK. Last seen 1m2s. Renewing
subscription.` with the tag in a `node` field and the OPC UA status alongside,
so a tag renewing over and over is a tag worth investigating at the server. Set
`logging.level` to `debug` to also see the intervals in force at startup, or to
`trace` to see every health update as it lands.

- Counts come from a Prometheus endpoint each pod serves on port 6061 at
`/metrics`. Scrape it at the pod's own address, since the Service carries only
`service.port`. Five values are published:
`opcua_handles_active`, the number of monitored items currently subscribed;
`opcua_monitored_item_handled` and `opcua_messages_handled_total`, counters that
should keep climbing while the source is alive; and
`opcua_notify_channel_length` with `message_handler_data_channel_length`, queue
depths inside libre-agent that sit near zero unless it is falling behind what it
is being sent.

#### `mqtt`

How libre-agent connects to the MQTT broker supplying the data. Only relevant
when the data source is MQTT.

| Value | Description |
| --- | --- |
| **`mqtt.serverUrl`**<br>[Required when the data source is MQTT] | <ul><li>Broker URL.</li><li>Environment variable: `RHIZE_AGENT_MQTT_SERVERURL`</li><li>Default: `mqtt://mqtt:1883`</li><li>Example: `mqtt://mqtt-broker:1883`</li><li>Type: string</li></ul> |
| **`mqtt.version`** | <ul><li>Which MQTT client libre-agent connects with. `3.1.1` selects the MQTT 3.1.1 client, for brokers that do not speak MQTT 5. `5` selects the MQTT 5 client.</li><li>Environment variable: `RHIZE_AGENT_MQTT_VERSION`</li><li>Default: `5`</li><li>Example: `5`</li><li>Type: string</li></ul> |
| **`mqtt.clientId`** | <ul><li>MQTT client ID. Must be unique per broker connection; two agents sharing one will disconnect each other.</li><li>Environment variable: `RHIZE_AGENT_MQTT_CLIENTID`</li><li>Default: `rhize-agent`</li><li>Example: `rhize-agent`</li><li>Type: string</li></ul> |
| **`mqtt.username`** | <ul><li>Broker username. Empty means anonymous.</li><li>Environment variable: `RHIZE_AGENT_MQTT_USERNAME`</li><li>Example: `system`</li><li>Type: string</li></ul> |
| **`mqtt.password`** | <ul><li>Broker password. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_AGENT_MQTT_PASSWORD`</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`mqtt.qos`** | <ul><li>How hard the broker works to deliver each message, chosen from the list under this table. One value covers both directions: the topics libre-agent subscribes to, and the values it publishes when answering a write. Anything outside `0`, `1`, and `2` fails the connection with `mqtt.qos must be 0, 1, or 2`.</li><li>Environment variable: `RHIZE_AGENT_MQTT_QOS`</li><li>Default: `0`</li><li>Example: `1`</li><li>Type: integer</li></ul> |
| **`mqtt.decomposeJson`** | <ul><li>On, each field in a JSON payload is published as a reading in its own right. Off, the whole payload goes out as one value, leaving whatever consumes it to pull the readings apart. Turn it on for a device that reports several readings in one message. Fields whose name starts with `_` are left out.</li><li>Environment variable: `RHIZE_AGENT_MQTT_DECOMPOSEJSON`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`mqtt.timestampField`** | <ul><li>Field in the payload holding the sample timestamp.</li><li>Environment variable: `RHIZE_AGENT_MQTT_TIMESTAMPFIELD`</li><li>Default: `timestamp`</li><li>Example: `timestamp`</li><li>Type: string</li></ul> |
| **`mqtt.timestampFormat`** | <ul><li>Valid formats are : `RFC3339`, `RFC3339Nano`, `RFC822`, `RFC822Z`, `RFC850`, `RFC1123`, `RFC1123Z`, `ANSIC`, `UnixDate`, `RubyDate`, `Kitchen`, `Stamp`, `StampMilli`, `StampMicro`, `StampNano`, `UnixSeconds`, `UnixMilli`, `UnixMicro`, or `UnixNano`. An unset or unrecognised format logs `time format not recognized` and the value is stamped with the time libre-agent received it instead.</li><li>Environment variable: `RHIZE_AGENT_MQTT_TIMESTAMPFORMAT`</li><li>Default: `RFC3339Nano`</li><li>Example: `RFC3339Nano`</li><li>Type: string</li></ul> |
| **`mqtt.requestTimeout`** | <ul><li>Request timeout in seconds.</li><li>Environment variable: `RHIZE_AGENT_MQTT_REQUESTTIMEOUT`</li><li>Default: `5`</li><li>Example: `5`</li><li>Type: integer</li></ul> |

The delivery guarantees `mqtt.qos` accepts:

| Value | Description |
| --- | --- |
| `0` | Sent once, with no acknowledgement and no retry. The cheapest and the fastest, and the level at which a message is simply gone if it does not arrive. |
| `1` | Redelivered until it is acknowledged, so a message is not lost, at the price of the same message sometimes arriving more than once. Nothing downstream filters repeats, so a second delivery becomes a second value change carrying the same reading. |
| `2` | Delivered exactly once, using a four-step exchange per message. The slowest of the three, so consider lowering the guarantee on a fast-moving feed. |

Two things bound what raising the level buys:
- A message is delivered at the
lower of the level it was published with and the level libre-agent subscribed
with, so `2` cannot improve on a device that publishes at `0`.
- And a level above
`0` only covers messages that arrive while libre-agent is connected, unless the
broker is holding a session for it: on `3.1.1` the session outlives a dropped
connection after the first one, so the broker queues what was missed and
delivers it on reconnect, while the MQTT 5 path asks for no session expiry, which
ends the session with the connection and leaves nothing to queue into.

#### `azure`

Azure Service Bus credentials, used when the data source is Service Bus.

| Value | Description |
| --- | --- |
| **`azure.clientId`**<br>[Required when the data source is Azure Service Bus] | <ul><li>Azure AD application client ID.</li><li>Environment variable: `RHIZE_AGENT_AZURE_CLIENTID`</li><li>Example: `7c9e6679-7425-40de-944b-e07fc1f90ae7`</li><li>Type: string</li></ul> |
| **`azure.clientSecret`**<br>[Required when the data source is Azure Service Bus] | <ul><li>Azure AD client secret. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_AGENT_AZURE_CLIENTSECRET`</li><li>Example: `Exa8Q~ExampleClientSecretValue1234567890`</li><li>Type: string</li></ul> |
| **`azure.tenantId`**<br>[Required when the data source is Azure Service Bus] | <ul><li>Azure AD tenant ID.</li><li>Environment variable: `RHIZE_AGENT_AZURE_TENANTID`</li><li>Example: `2b1f8d4c-93ae-4a61-8f0b-6d5c4e3a2b1f`</li><li>Type: string</li></ul> |
| **`azure.serviceBusHostName`**<br>[Required when the data source is Azure Service Bus] | <ul><li>Service Bus namespace hostname.</li><li>Environment variable: `RHIZE_AGENT_AZURE_SERVICEBUSHOSTNAME`</li><li>Example: `example.servicebus.windows.net`</li><li>Type: string</li></ul> |

#### `eventHubs`

Azure Event Hubs consumer. Hub entity names come from the data source topic
labels in BAAS rather than from configuration.

| Value | Description |
| --- | --- |
| **`eventHubs.namespaceConnectionString`**<br>[Required when the data source is Event Hubs and `eventHubs.fullyQualifiedNamespace` is empty] | <ul><li>Connection string for the Event Hubs namespace.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_NAMESPACECONNECTIONSTRING`</li><li>Example: `Endpoint=sb://example-ns.servicebus.windows.net/;SharedAccessKeyName=listen-policy;SharedAccessKey=ExampleSharedAccessKey1234567890=`</li><li>Type: string</li></ul> |
| **`eventHubs.fullyQualifiedNamespace`** | <ul><li>Namespace hostname, used for Azure AD authentication instead of a connection string.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_FULLYQUALIFIEDNAMESPACE`</li><li>Example: `example-ns.servicebus.windows.net`</li><li>Type: string</li></ul> |
| **`eventHubs.consumerGroup`** | <ul><li>Event Hubs consumer group.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_CONSUMERGROUP`</li><li>Default: `$Default`</li><li>Example: `agent-consumer`</li><li>Type: string</li></ul> |
| **`eventHubs.checkpointStorageConnectionString`**<br>[Required when the data source is Event Hubs and `eventHubs.checkpointStorageAccountUrl` is empty] | <ul><li>Storage account connection string for the blob checkpoint store, authenticating with a storage account key or a SAS token.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_CHECKPOINTSTORAGECONNECTIONSTRING`</li><li>Example: `DefaultEndpointsProtocol=https;AccountName=examplestorage;AccountKey=ExampleStorageAccountKey1234567890==;EndpointSuffix=core.windows.net`</li><li>Type: string</li></ul> |
| **`eventHubs.checkpointStorageAccountUrl`** | <ul><li>Blob service URL for the checkpoint store. When set, it takes precedence over `eventHubs.checkpointStorageConnectionString`, and libre-agent signs in to the storage account as an Azure AD application rather than with a key. Set the application's tenant ID, client ID and client secret in the `AZURE_TENANT_ID`, `AZURE_CLIENT_ID` and `AZURE_CLIENT_SECRET` environment variables, which are separate from the `azure` settings. With them unset, it uses the managed identity of the node the pod runs on. Either identity needs the Storage Blob Data Contributor role on the account.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_CHECKPOINTSTORAGEACCOUNTURL`</li><li>Example: `https://examplestorage.blob.core.windows.net`</li><li>Type: string</li></ul> |
| **`eventHubs.checkpointBlobContainerName`**<br>[Required when the data source is Event Hubs] | <ul><li>Blob container holding the checkpoints.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_CHECKPOINTBLOBCONTAINERNAME`</li><li>Example: `checkpoints`</li><li>Type: string</li></ul> |
| **`eventHubs.receivePartitionId`** | <ul><li>Restricts the consumer to a single partition. Empty means all partitions are handled by the processor.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_RECEIVEPARTITIONID`</li><li>Example: `0`</li><li>Type: string</li></ul> |
| **`eventHubs.receiveAllPartitions`** | <ul><li>Receives from all partitions.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_RECEIVEALLPARTITIONS`</li><li>Default: `false`</li><li>Example: `false`</li><li>Type: boolean</li></ul> |
| **`eventHubs.receiveMaxBatchSize`** | <ul><li>Maximum events fetched per receive call. Unset or `0` means `100`, and anything above `300` is rejected at startup.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_RECEIVEMAXBATCHSIZE`</li><li>Default: `100`</li><li>Example: `10`</li><li>Type: integer</li></ul> |
| **`eventHubs.receiveStartFromEarliest`** | <ul><li>Starts from the earliest available event when no checkpoint exists, rather than from the latest.</li><li>Environment variable: `RHIZE_AGENT_EVENTHUBS_RECEIVESTARTFROMEARLIEST`</li><li>Default: `false`</li><li>Example: `true`</li><li>Type: boolean</li></ul> |

### `egress`

Where the subscription sends what it reads. **Each handler listed receives
every value change, and with no handler listed nothing is published at all**, so
a deployment that subscribes to anything defines at least one.

`egress.handlers` is a map whose keys are names you choose, so each setting is
written `egress.handlers.<name>.<field>`. Define each handler in
`rhizeAgentConfig`. The environment variables in the table then set that
handler's fields, provided each field is written in the handler's block. To
take a field's value from its variable alone, write it in the block as `""`.

| Value | Description |
| --- | --- |
| **`egress.handlers.<name>.protocol`**<br>[Required when the handler is defined] | <ul><li>Where the handler sends messages. `kafka` produces to the Kafka topic named by `topic`, or to the topic a `patterns` entry picks. `http` POSTs each message to `serverUrl`. `nats` publishes to a NATS subject over the connection the `nats` section configures. Any other value logs `Unknown egress protocol` and the handler is skipped.</li><li>Environment variable: `RHIZE_AGENT_EGRESS_HANDLERS_<NAME>_PROTOCOL`</li><li>Example: `kafka`</li><li>Type: string</li></ul> |
| **`egress.handlers.<name>.serverUrl`**<br>[Required when the handler's `protocol` is not `nats`] | <ul><li>Where to publish. For `kafka`, the broker address. For `http`, the URL to POST to, where a literal `{id}` in the URL is replaced with the message subject; the body is JSON and carries an `idempotency-key` header. Not used by `nats`, which takes its connection from the `nats` section instead. An empty value crashes libre-agent at startup for `kafka` and `http`.</li><li>Environment variable: `RHIZE_AGENT_EGRESS_HANDLERS_<NAME>_SERVERURL`</li><li>Example: `kafka:9092` for Kafka, `http://ingest:8080/values/{id}` for HTTP</li><li>Type: string</li></ul> |
| **`egress.handlers.<name>.topic`**<br>[Required when the handler's `protocol` is `kafka`] | <ul><li>Kafka only. Topic to publish to when no entry in `patterns` matches. Topics are created on demand if the broker allows it.</li><li>Environment variable: `RHIZE_AGENT_EGRESS_HANDLERS_<NAME>_TOPIC`</li><li>Example: `value-changes`</li><li>Type: string</li></ul> |
| **`egress.handlers.<name>.patterns`** | <ul><li>Kafka only. List of `{topic, regex}` pairs that route by source node name. When the regex matches the node, the message goes to that pair's `topic` instead of the handler's `topic`, and a `$1` in that topic is replaced with the text of the first capture group, so a single pattern can give each site or line its own topic. Keep the patterns mutually exclusive: when several match, which one wins is not predictable. An entry with an empty `topic`, or a regex that does not compile, crashes libre-agent at startup.</li><li>Environment variable: None</li><li>Example: see the example block below</li><li>Type: list</li></ul> |

A Kafka handler that splits temperatures onto their own topic, alongside an HTTP
handler, as the block appears inside `rhizeAgentConfig`:

```yaml
egress:
  handlers:
    kafka-values:
      protocol: kafka
      serverUrl: kafka:9092
      topic: value-changes
      patterns:
        - topic: temperatures
          regex: '.*Temperature$'
        - topic: 'values_$1'
          regex: '^bulktimeseries/Acme/([^/]+)/.*'
    historian:
      protocol: http
      serverUrl: http://ingest:8080/values/{id}
```

### `nats`

The NATS connection an `egress` handler with protocol `nats` opens. Nothing else
on this page uses it, and without such a handler none of these settings are
read.

| Value | Description |
| --- | --- |
| **`nats.serverUrl`** | <ul><li>NATS server address. The default reaches a NATS Service named `nats` on its usual port in the same namespace, so it only needs setting where the server is named or ported differently. An unreachable address stops libre-agent at startup.</li><li>Environment variable: `RHIZE_AGENT_NATS_SERVERURL`</li><li>Default: `nats:4222`</li><li>Example: `nats://nats:4222`</li><li>Type: string</li></ul> |
| **`nats.username`** | <ul><li>NATS username.</li><li>Environment variable: `RHIZE_AGENT_NATS_USERNAME`</li><li>Default: `system`</li><li>Example: `system`</li><li>Type: string</li></ul> |
| **`nats.password`** | <ul><li>NATS password. Supply from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_AGENT_NATS_PASSWORD`</li><li>Default: `system`</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |

### `bridge`

Turns libre-agent into a broker-to-broker message bridge. This is a
**replacement** for normal operation.
When a `bridge` section is present, libre-agent forwards messages between the brokers defined here and
ignores every other section on this page, `datasource` included.

Each handler is one broker connection, and a message arriving on one is published
to all others. Messages are never sent back to the handler they arrived
on, and a message that has already been routed once is not routed again, so two
handlers cannot loop.

`bridge.handlers` is a map whose keys are names you choose, and the name is what
identifies the connection in the logs. As with `egress`, define each handler in
`rhizeAgentConfig`, writing every field that its variable should set, using `""`
for a field whose value comes only from the variable.

| Value | Description |
| --- | --- |
| **`bridge.topics`**<br>[Required when a `bridge` section is present] | <ul><li>Topics to carry across the bridge, written the NATS way: a `.` between levels, `*` for any single level, and `>` for everything below that point. Every broker here subscribes to all of them. An MQTT broker gets the topics converted to MQTT form on the way, so `libre.*.values` reaches that broker as `libre/+/values`.</li><li>Environment variable: None</li><li>Example: `[libre.>]`</li><li>Type: list</li></ul> |
| **`bridge.handlers.<name>.protocol`**<br>[Required when the handler is defined] | <ul><li>Which broker the handler speaks to: `nats` for a NATS server, `mqtt` for an MQTT broker. A handler naming anything else is left out of the bridge.</li><li>Environment variable: `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_PROTOCOL`</li><li>Example: `mqtt`</li><li>Type: string</li></ul> |
| **`bridge.handlers.<name>.serverUrl`**<br>[Required when the handler is defined] | <ul><li>Broker address, including scheme and port.</li><li>Environment variable: `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_SERVERURL`</li><li>Example: `mqtt://broker:1883` for MQTT, `nats://nats:4222` for NATS</li><li>Type: string</li></ul> |
| **`bridge.handlers.<name>.username`** | <ul><li>Username for the broker. Omit for an anonymous connection.</li><li>Environment variable: `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_USERNAME`</li><li>Example: `bridge`</li><li>Type: string</li></ul> |
| **`bridge.handlers.<name>.password`** | <ul><li>Password for the broker. Write it here as an empty value and supply the real one from a Kubernetes Secret.</li><li>Environment variable: `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_PASSWORD`</li><li>Example: `ExamplePassword123`</li><li>Type: string</li></ul> |
| **`bridge.handlers.<name>.clientId`** | <ul><li>MQTT only. Client id for the connection. Must be unique per broker, since two connections sharing one will disconnect each other.</li><li>Environment variable: `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_CLIENTID`</li><li>Example: `libre-bridge`</li><li>Type: string</li></ul> |

A minimal two-broker bridge, as the block appears inside `rhizeAgentConfig`,
with the NATS password left empty for `additionalSecrets` to fill:

```yaml
bridge:
  topics:
    - libre.>
  handlers:
    plant:
      protocol: mqtt
      serverUrl: mqtt://plant-broker:1883
      clientId: libre-bridge
    central:
      protocol: nats
      serverUrl: nats://nats:4222
      username: bridge
      password: ""
```

### Environment-only settings

These are read directly from the environment and carry no `RHIZE_AGENT_` prefix.

| Value | Description |
| --- | --- |
| **``all_proxy``** | <ul><li>SOCKS5 proxy that libre-agent dials MQTT broker connections through, both for an MQTT data source and for MQTT connections in the bridge. Requires either a `socks5://` or `socks5h://` URL. An MQTT data source pinned to `mqtt.version` `3.1.1` connects directly, as do all other connections libre-agent makes, including NATS, Kafka, and calls to BAAS.</li><li>Example: `socks5://proxy.example.com:1080`</li><li>Type: string</li></ul> |

## Helm chart values

Values shared by every chart.

| Value | Description |
| --- | --- |
| **`rhizeAgentConfig`**<br>[Required] | <ul><li>The complete application configuration, rendered into a ConfigMap named after the release and mounted at `/config`. libre-agent exits if the file is missing.</li><li>Default: the block described above</li><li>Example: the Application configuration section</li><li>Type: object</li></ul> |
| **`envVars`** | <ul><li>Map of environment variable names to values passed to the container.</li><li>Example: see the example block below</li><li>Type: map</li></ul> |
| **`additionalSecrets`** | <ul><li>List of entries that each carry one value from a Kubernetes Secret into an environment variable: `name` is the variable the service reads, `secretName` is the Secret to take the value from, and `secretKey` is the name of the entry within that Secret. This is how every credential should reach libre-agent, using the variable names in the second column of the tables above: `RHIZE_AGENT_OIDC_CLIENTSECRET` for the OIDC client, and `RHIZE_AGENT_OPCUA_PASSWORD`, `RHIZE_AGENT_MQTT_PASSWORD`, or `RHIZE_AGENT_NATS_PASSWORD` for the data source or broker in use.</li><li>Example: see the example block below</li><li>Type: list</li></ul> |
| **`caFile`** | <ul><li>Contents of a PEM CA certificate for outbound HTTPS calls, given as a YAML block, `caFile: \|`, with the certificate's lines indented beneath. Trusting a certificate takes two values: give the certificate here, which mounts it at `/certs/ca-cert.pem`, and set `libreDataStoreGraphQl.caFile` in `rhizeAgentConfig` to that path.</li><li>Example: `-----BEGIN CERTIFICATE-----…`</li><li>Type: string</li></ul> |
| **`service.port`** | <ul><li>Port for the Service, the container port, and the port libre-agent serves Restate handlers on. The chart writes it into the configuration as `restate.servicePort` as well, so the port Restate calls back on is always the one the Service exposes.</li><li>Default: `8887`</li><li>Example: `8887`</li><li>Type: integer</li></ul> |
| **`extraVolumes`** / **`extraVolumeMounts`** | <ul><li>How an OPC UA client certificate and key get into the container, which is the one file libre-agent reads that the chart does not place itself. Mount the pair, then name the mounted paths in `opcUa.certFile` and `opcUa.keyFile`. Give each value as a list of standard Kubernetes volume and volume mount entries, and set both: a mount whose volume is missing stops the pod from starting.</li><li>Example: refer to following block</li><li>Type: list</li></ul> |

A log level set directly, two credentials taken from Secrets, and an OPC UA
certificate pair mounted from a third:

```yaml
envVars:
  RHIZE_AGENT_LOGGING_LEVEL: info
additionalSecrets:
  - name: RHIZE_AGENT_OIDC_CLIENTSECRET
    secretName: libre-client-secrets
    secretKey: libreAgent
  - name: RHIZE_AGENT_MQTT_PASSWORD
    secretName: libre-passwords
    secretKey: agentMqtt
extraVolumes:
  - name: opcua-certs
    secret:
      secretName: agent-opcua-certs
extraVolumeMounts:
  - name: opcua-certs
    mountPath: /opcua-certs
    readOnly: true
```


