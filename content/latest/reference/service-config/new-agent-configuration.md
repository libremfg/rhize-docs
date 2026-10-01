---
title: 'Agent configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize agent
draft: true
aliases:
  - /reference/service-config/agent-configuration
  - "/reference/agent-configuration/"
weight: 900
---

The Rhize agent collects data that is emitted in the manufacturing process and makes this data visible in the Rhize system.

## Application configuration

Everything in this section goes into the chart's `rhizeAgentConfig` value, which
becomes libre-agent's entire configuration file. The chart ships a populated
`rhizeAgentConfig`, and the Default column is what libre-agent runs with when a
setting is left alone. Delete a key from that block and most settings are left
with no value at all, but a handful fall back to a built-in value meant for a
developer's own machine: `libreDataStoreGraphQl.serverUrl` becomes
`http://localhost:8080/graphql`, `oidc.serverUrl` becomes `http://localhost:8090`,
`nats.serverUrl` becomes `nats://localhost:4222`, and `datasource.id` becomes
`server`. Individual keys can be overridden with the environment variable in the
second column, supplied through the chart's `envVars` or `additionalSecrets`.

Most of the sections below will not apply to any one deployment. There are three
ways to set libre-agent up, and which sections matter follows from which one
this deployment is: a subscription, commands, or a bridge. A subscription and
commands belong in the same deployment, and most deployments run both. A bridge
is on its own, and cannot be run with subscription or command.

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

### General settings

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `datasource.id` | `RHIZE_AGENT_DATASOURCE_ID` | ID of the data source record in BAAS that drives this deployment. Everything libre-agent subscribes to and publishes is read from that record, so a value matching no record in BAAS leaves libre-agent running but idle. Also used to build the OPC UA session name. | `libre-agent` | `DS_0806` | string | Yes |  |
| `libreDataStoreGraphQl.serverUrl` | `RHIZE_AGENT_LIBREDATASTOREGRAPHQL_SERVERURL` | GraphQL endpoint libre-agent fetches the data source record from. Give the full address of the BAAS alpha Service, including the port and the `/graphql` path, since the path is not added for you. Startup fails with "Unable to get initial config" if this endpoint is unreachable. | `http://baas-alpha:8080/graphql` | `http://baas-alpha:8080/graphql` | string | Yes |  |
| `libreDataStoreGraphQl.caFile` | `RHIZE_AGENT_LIBREDATASTOREGRAPHQL_CAFILE` | Path to a PEM CA certificate libre-agent trusts in addition to the system roots when making outbound HTTPS calls, to BAAS and to the OIDC provider. Set it to the path the certificate is mounted at, which is `/certs/ca-cert.pem` for a certificate supplied through the chart's `caFile` value. A path that cannot be read or parsed stops the calls that need it. |  | `/certs/ca-cert.pem` | string | No |  |
| `logging.level` | `RHIZE_AGENT_LOGGING_LEVEL` | Lowest severity that reaches the log, one of `trace`, `debug`, `info`, `warn`, `error`, `fatal`, `panic`, or `disabled`. Each level lets through itself and everything more severe, so `info` keeps informational messages, warnings, and errors but drops trace and debug, and `disabled` stops libre-agent logging at all. Setting `trace` or `debug` also logs the full configuration libre-agent is running with at startup, which is the quickest way to check that a value you set actually reached libre-agent. | `info` | `info` | string | No |  |
| `logging.type` | `RHIZE_AGENT_LOGGING_TYPE` | Output format. `json` writes structured JSON to stderr, for collection by a log aggregator. `multi` writes human-readable lines to stderr and JSON to stdout at the same time. `console`, which the chart ships, writes human-readable lines to stderr. | `console` | `json` | string | No |  |
| `openTelemetry.serverUrl` | `RHIZE_AGENT_OPENTELEMETRY_SERVERURL` | OTLP gRPC endpoint for trace export, given as host and port with no scheme. Failure to initialise is logged as a warning and libre-agent continues without tracing. | `otel:4317` | `tempo-distributor.monitoring.svc.cluster.local:4317` | string | No |  |

### `oidc`

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `oidc.serverUrl` | `RHIZE_AGENT_OIDC_SERVERURL` | Base URL of the OIDC provider. Endpoints are discovered from `<serverUrl>/.well-known/openid-configuration`. | `http://keycloak:80` | `http://keycloak:80` | string | Yes |  |
| `oidc.realm` | `RHIZE_AGENT_OIDC_REALM` | Keycloak realm. | `libre` | `libre` | string | Yes | `oidc.enableGenericOidc` is `false` |
| `oidc.clientId` | `RHIZE_AGENT_OIDC_CLIENTID` | Client ID. Tokens are obtained with the client credentials grant, so the client's service account needs the required roles in the provider. | `libreAgent` | `libreAgent` | string | Yes |  |
| `oidc.clientSecret` | `RHIZE_AGENT_OIDC_CLIENTSECRET` | Client secret paired with `oidc.clientId`. Supply from a Kubernetes Secret. |  | `8f3b6c21-4d5e-4a7b-9c0d-1e2f3a4b5c6d` | string | Yes |  |
| `oidc.enableGenericOidc` | `RHIZE_AGENT_OIDC_ENABLEGENERICOIDC` | Switches to a generic OIDC provider such as Okta rather than Keycloak-specific handling. | `false` | `false` | boolean | No |  |
| `oidc.customAudienceKey` | `RHIZE_AGENT_OIDC_CUSTOMAUDIENCEKEY` | Claim to read the audience from when using a non-Keycloak provider. |  | `rhize.com/aud` | string | No |  |
| `oidc.credentialsScope` | `RHIZE_AGENT_OIDC_CREDENTIALSSCOPE` | Optional scope requested during the client credentials grant. |  | `openid` | string | No |  |

### Commands

Alongside the subscription, libre-agent answers individual commands: read a tag
now, write a value to a tag or topic on the data source, or call a method on a
device. When `restate.enabled` is on, which is the chart's default, the command
API is served through Restate, and these settings describe how it is reached.
An answer returns to the caller the same way it came rather than through an
`egress` handler.

Which commands can be answered depends on the type of data source. An OPC UA
data source answers all three, and libre-agent will not start without
`restate.enabled`, stopping with "At least one of NATS or Kafka or Restate must
be enabled for OPCUA data source". An MQTT data source answers writes only, and
needs `restate.enabled` for them: turned off, libre-agent runs but accepts no
commands at all. A Kafka, Azure Service Bus, or Azure Event Hubs data source
answers no commands, so turn `restate.enabled` off there; left on, libre-agent
still tries to register with Restate at startup and exits if it cannot.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `restate.enabled` | `RHIZE_AGENT_RESTATE_ENABLED` | Makes libre-agent serve read, write, and method call commands over HTTP on the port the chart's `service.port` sets and register itself with Restate at startup, after which a caller reaches libre-agent by invoking it through Restate rather than by sending to it directly. Registration is a single attempt: libre-agent exits if it fails, so turn this off for a data source that answers no commands. | `true` | `true` | boolean | Yes | The data source is Kafka, Azure Service Bus, or Azure Event Hubs |
| `restate.adminUrl` | `RHIZE_AGENT_RESTATE_ADMINURL` | Restate admin API libre-agent registers itself with. | `http://restate:9070` | `http://restate:9070` | string | Yes | `restate.enabled` is `true` |
| `restate.serviceName` | `RHIZE_AGENT_RESTATE_SERVICENAME` | Hostname Restate calls back on. Derived from the pod hostname, which is the right answer in Kubernetes. | the Deployment name | `libre-agent` | string | No |  |

### Data sources

How libre-agent connects to the system it reads from. Fill in the one section
that matches the data source record in BAAS — `kafka`, `opcUa`, `mqtt`, `azure`
for Azure Service Bus, or `eventHubs` — and leave the others out. `health`
applies only to an OPC UA server.

#### `kafka`

How libre-agent connects to the Kafka broker supplying the data.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `kafka.bootstrapServerUrl` | `RHIZE_AGENT_KAFKA_BOOTSTRAPSERVERURL` | Kafka bootstrap server. |  | `redpanda:9092` | string | Yes | The data source is Kafka |
| `kafka.groupId` | `RHIZE_AGENT_KAFKA_GROUPID` | Name of the Kafka consumer group libre-agent reads under. Every replica reads under this one group, so the topics are split between them and each message is read once rather than once per replica. The group also remembers how far it has read, so a restart carries on from there, and a group id that has not been used before starts at the oldest message the topic still holds. |  | `libre-agent` | string | Yes | The data source is Kafka |
| `kafka.workerThreads` | `RHIZE_AGENT_KAFKA_WORKERTHREADS` | Number of worker threads reading from the broker in parallel. | `1` | `1` | integer | No |  |
| `kafka.sessionTimeout` | `RHIZE_AGENT_KAFKA_SESSIONTIMEOUT` | Consumer session timeout in milliseconds. | `60000` | `30000` | integer | No |  |
| `kafka.maxSendRetries` | `RHIZE_AGENT_KAFKA_MAXSENDRETRIES` | Retries for a failed send. | `3` | `3` | integer | No |  |

#### `opcUa`

How libre-agent connects to the OPC UA server supplying the data. Only relevant
when the data source is an OPC UA server.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `opcUa.serverUrl` | `RHIZE_AGENT_OPCUA_SERVERURL` | OPC UA endpoint to connect to. | `opc.tcp://opcua-server` | `opc.tcp://opcua-server:4840` | string | Yes | The data source is OPC UA |
| `opcUa.discoveryUrl` | `RHIZE_AGENT_OPCUA_DISCOVERYURL` | OPC UA discovery endpoint, usually the same as `serverUrl`. | `opc.tcp://opcua-server` | `opc.tcp://opcua-server:4840` | string | Yes | The data source is OPC UA |
| `opcUa.authentication` | `RHIZE_AGENT_OPCUA_AUTHENTICATION` | How libre-agent identifies itself to the server. `Anonymous` presents no identity and ignores `opcUa.username` and `opcUa.password`. `UserName` signs in with that pair. `Certificate` presents the client certificate from `opcUa.certFile` and proves ownership with `opcUa.keyFile`. The server has to offer the chosen method on the endpoint it selects. | `Anonymous` | `UserName` | string | No |  |
| `opcUa.username` | `RHIZE_AGENT_OPCUA_USERNAME` | OPC UA username. |  | `opcuauser` | string | Yes | `opcUa.authentication` is `UserName` |
| `opcUa.password` | `RHIZE_AGENT_OPCUA_PASSWORD` | OPC UA password. Supply from a Kubernetes Secret. |  | `ExamplePassword123` | string | Yes | `opcUa.authentication` is `UserName` |
| `opcUa.mode` | `RHIZE_AGENT_OPCUA_MODE` | What protection is applied to each message. `None` sends them unsigned and in the clear. `Sign` signs them, so tampering is detectable while the contents stay readable on the wire. `SignAndEncrypt` signs and encrypts them. `Auto` takes the strongest mode the server advertises. Any other value logs "Invalid security Mode", matches no endpoint, and leaves libre-agent unable to connect. | `Auto` | `SignAndEncrypt` | string | No |  |
| `opcUa.policy` | `RHIZE_AGENT_OPCUA_POLICY` | Cryptographic suite used for the signing and encryption `opcUa.mode` asks for, from the list under this table. Setting either this or `opcUa.mode` to `None` forces both to `None`, so security is off unless both carry a real value. Any other value stops libre-agent with "Invalid security Policy". | `None` | `Basic256Sha256` | string | No |  |
| `opcUa.applicationUri` | `RHIZE_AGENT_OPCUA_APPLICATIONURI` | Application URI libre-agent presents. Must match the URI in the client certificate when a security policy is in use. | `urn:opcua-server.server.application` | `urn:opcua-server.server.application` | string | No |  |
| `opcUa.certFile` / `opcUa.keyFile` | `RHIZE_AGENT_OPCUA_CERTFILE` / `RHIZE_AGENT_OPCUA_KEYFILE` | Paths inside the container to the client certificate and its private key, which has to be RSA. Both have to be set for either to be read. Mount the pair with `extraVolumes` and `extraVolumeMounts`, and register the certificate with the OPC UA server as a trusted client. A pair that fails to load logs "Failed to load certificate" and the connection goes on without a certificate, which the server then refuses. |  | `/certs/opcua-client.pem` / `/certs/opcua-client.key` | string | Yes | `opcUa.mode` is `Sign` or `SignAndEncrypt`, `opcUa.authentication` is `Certificate`, or `opcUa.genCert` is `true` |
| `opcUa.genCert` | `RHIZE_AGENT_OPCUA_GENCERT` | Generates a self-signed 2048-bit certificate for `opcUa.applicationUri` at startup and writes it to `opcUa.certFile` and `opcUa.keyFile`, so both need to name writable paths; left empty, the certificate is written to `cert.pem` and `key.pem` and then not found, which logs "Failed to load certificate". A new certificate is generated on every start, even when the files already exist, so a server that trusted the last one rejects the next. | `false` | `false` | boolean | No |  |
| `opcUa.subscription.publishingInterval` | `RHIZE_AGENT_OPCUA_SUBSCRIPTION_PUBLISHINGINTERVAL` | How often, in milliseconds, the server publishes notifications. | `1000` | `1000` | integer | No |  |
| `opcUa.subscription.lifetimeCount` | `RHIZE_AGENT_OPCUA_SUBSCRIPTION_LIFETIMECOUNT` | Publishing cycles the server keeps the subscription alive without a publish request. Should be at least three times `maxKeepAliveCount`. | `10000` | `10000` | integer | No |  |
| `opcUa.subscription.maxKeepAliveCount` | `RHIZE_AGENT_OPCUA_SUBSCRIPTION_MAXKEEPALIVECOUNT` | Publishing cycles without data before the server sends a keep-alive. | `3000` | `3000` | integer | No |  |
| `opcUa.subscription.maxNotificationsPerPublish` | `RHIZE_AGENT_OPCUA_SUBSCRIPTION_MAXNOTIFICATIONSPERPUBLISH` | Cap on notifications in a single publish response. | `10000` | `10000` | integer | No |  |
| `opcUa.subscription.priority` | `RHIZE_AGENT_OPCUA_SUBSCRIPTION_PRIORITY` | Relative priority of this subscription on the server. | `0` | `0` | integer | No |  |
| `opcUa.monitoredItem.samplingInterval` | `RHIZE_AGENT_OPCUA_MONITOREDITEM_SAMPLINGINTERVAL` | How often, in milliseconds, the server samples each item. `0` means as fast as the server allows. | `0` | `0` | integer | No |  |
| `opcUa.monitoredItem.queueSize` | `RHIZE_AGENT_OPCUA_MONITOREDITEM_QUEUESIZE` | Server-side queue depth per monitored item between publications. Raise the queue size if samples are being lost between publishes. | `100` | `100` | integer | No |  |
| `opcUa.monitoredItem.discardOldest` | `RHIZE_AGENT_OPCUA_MONITOREDITEM_DISCARDOLDEST` | Whether a full queue discards the oldest sample rather than the newest. | `true` | `true` | boolean | No |  |

The security policies `opcUa.policy` accepts:

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

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `health.pollInterval` | `RHIZE_AGENT_HEALTH_POLLINTERVAL` | How often, in milliseconds, every subscribed tag is checked. `0` turns the watcher off, so nothing is renewed. Anything under 200 is raised to 200, which is logged as "Poll interval is too low. Clamping." | `1000` | `1000` | integer | No |  |
| `health.subscriptionTimeout` | `RHIZE_AGENT_HEALTH_SUBSCRIPTIONTIMEOUT` | How long, in milliseconds, a tag may report a bad status before its subscription is renewed. Anything over 24 hours is lowered to 24 hours, logged as "Node timeout is too high. Clamping." | `60000` | `60000` | integer | No |  |
| `health.subscriptionMaxCount` | `RHIZE_AGENT_HEALTH_SUBSCRIPTIONMAXCOUNT` | How many OPC UA subscriptions libre-agent opens before it stops creating more and shares the existing ones between tags. Raise it where a server limits how many monitored items one subscription may carry. | `5` | `5` | integer | No |  |

Health is reported in two places. The log carries a line per tag as it is
renewed, at warn level, reading "Node status is not OK. Last seen 1m2s. Renewing
subscription." with the tag in a `node` field and the OPC UA status alongside,
so a tag renewing over and over is a tag worth investigating at the server. Set
`logging.level` to `debug` to also see the intervals in force at startup, or to
`trace` to see every health update as it lands.

Counts come from a Prometheus endpoint each pod serves on port 6061 at
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

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `mqtt.serverUrl` | `RHIZE_AGENT_MQTT_SERVERURL` | Broker URL. | `mqtt://mqtt:1883` | `mqtt://mqtt-broker:1883` | string | Yes | The data source is MQTT |
| `mqtt.version` | `RHIZE_AGENT_MQTT_VERSION` | Which MQTT client libre-agent connects with. `3.1.1` selects the MQTT 3.1.1 client, for brokers that do not speak MQTT 5. `5` selects the MQTT 5 client. | `5` | `5` | string | No |  |
| `mqtt.clientId` | `RHIZE_AGENT_MQTT_CLIENTID` | MQTT client id. Must be unique per broker connection; two agents sharing one will disconnect each other. | `rhize-agent` | `rhize-agent` | string | No |  |
| `mqtt.username` | `RHIZE_AGENT_MQTT_USERNAME` | Broker username. Empty means anonymous. |  | `system` | string | No |  |
| `mqtt.password` | `RHIZE_AGENT_MQTT_PASSWORD` | Broker password. Supply from a Kubernetes Secret. |  | `ExamplePassword123` | string | No |  |
| `mqtt.qos` | `RHIZE_AGENT_MQTT_QOS` | How hard the broker works to deliver each message, chosen from the list under this table. One value covers both directions: the topics libre-agent subscribes to, and the values it publishes when answering a write. Anything outside `0`, `1`, and `2` fails the connection with "mqtt.qos must be 0, 1, or 2". | `0` | `1` | integer | No |  |
| `mqtt.decomposeJson` | `RHIZE_AGENT_MQTT_DECOMPOSEJSON` | On, each field in a JSON payload is published as a reading in its own right. Off, the whole payload goes out as one value, leaving whatever consumes it to pull the readings apart. Turn it on for a device that reports several readings in one message. Fields whose name starts with `_` are left out. | `false` | `false` | boolean | No |  |
| `mqtt.timestampField` | `RHIZE_AGENT_MQTT_TIMESTAMPFIELD` | Field in the payload holding the sample timestamp. | `timestamp` | `timestamp` | string | No |  |
| `mqtt.timestampFormat` | `RHIZE_AGENT_MQTT_TIMESTAMPFORMAT` | Valid formats are : `RFC3339`, `RFC3339Nano`, `RFC822`, `RFC822Z`, `RFC850`, `RFC1123`, `RFC1123Z`, `ANSIC`, `UnixDate`, `RubyDate`, `Kitchen`, `Stamp`, `StampMilli`, `StampMicro`, `StampNano`, `UnixSeconds`, `UnixMilli`, `UnixMicro`, or `UnixNano`. An unset or unrecognised format logs "time format not recognized" and the value is stamped with the time libre-agent received it instead. | `RFC3339Nano` | `RFC3339Nano` | string | No |  |
| `mqtt.requestTimeout` | `RHIZE_AGENT_MQTT_REQUESTTIMEOUT` | Request timeout in seconds. | `5` | `5` | integer | No |  |

The delivery guarantees `mqtt.qos` accepts:

| Value | Description |
| --- | --- |
| `0` | Sent once, with no acknowledgement and no retry. The cheapest and the fastest, and the level at which a message is simply gone if it does not arrive. |
| `1` | Redelivered until it is acknowledged, so a message is not lost, at the price of the same message sometimes arriving more than once. Nothing downstream filters repeats, so a second delivery becomes a second value change carrying the same reading. |
| `2` | Delivered exactly once, using a four-step exchange per message where `1` uses two. The slowest of the three, and the one to think twice about on a fast-moving feed. |

Two things bound what raising the level buys. A message is delivered at the
lower of the level it was published with and the level libre-agent subscribed
with, so `2` cannot improve on a device that publishes at `0`. And a level above
`0` only covers messages that arrive while libre-agent is connected, unless the
broker is holding a session for it: on `3.1.1` the session outlives a dropped
connection after the first one, so the broker queues what was missed and
delivers it on reconnect, while the MQTT 5 path asks for no session expiry, which
ends the session with the connection and leaves nothing to queue into.

#### `azure`

Azure Service Bus credentials, used when the data source is Service Bus.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `azure.clientId` | `RHIZE_AGENT_AZURE_CLIENTID` | Azure AD application client ID. |  | `7c9e6679-7425-40de-944b-e07fc1f90ae7` | string | Yes | The data source is Azure Service Bus |
| `azure.clientSecret` | `RHIZE_AGENT_AZURE_CLIENTSECRET` | Azure AD client secret. Supply from a Kubernetes Secret. |  | `Exa8Q~ExampleClientSecretValue1234567890` | string | Yes | The data source is Azure Service Bus |
| `azure.tenantId` | `RHIZE_AGENT_AZURE_TENANTID` | Azure AD tenant ID. |  | `2b1f8d4c-93ae-4a61-8f0b-6d5c4e3a2b1f` | string | Yes | The data source is Azure Service Bus |
| `azure.serviceBusHostName` | `RHIZE_AGENT_AZURE_SERVICEBUSHOSTNAME` | Service Bus namespace hostname. |  | `example.servicebus.windows.net` | string | Yes | The data source is Azure Service Bus |

#### `eventHubs`

Azure Event Hubs consumer. Hub entity names come from the data source topic
labels in BAAS rather than from configuration.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `eventHubs.namespaceConnectionString` | `RHIZE_AGENT_EVENTHUBS_NAMESPACECONNECTIONSTRING` | Connection string for the Event Hubs namespace. |  | `Endpoint=sb://example-ns.servicebus.windows.net/;SharedAccessKeyName=listen-policy;SharedAccessKey=ExampleSharedAccessKey1234567890=` | string | Yes | The data source is Event Hubs and `eventHubs.fullyQualifiedNamespace` is empty |
| `eventHubs.fullyQualifiedNamespace` | `RHIZE_AGENT_EVENTHUBS_FULLYQUALIFIEDNAMESPACE` | Namespace hostname, used for Azure AD authentication instead of a connection string. |  | `example-ns.servicebus.windows.net` | string | No |  |
| `eventHubs.consumerGroup` | `RHIZE_AGENT_EVENTHUBS_CONSUMERGROUP` | Event Hubs consumer group. | `$Default` | `agent-consumer` | string | No |  |
| `eventHubs.checkpointStorageConnectionString` | `RHIZE_AGENT_EVENTHUBS_CHECKPOINTSTORAGECONNECTIONSTRING` | Storage account connection string for the blob checkpoint store, authenticating with a storage account key or a SAS token. |  | `DefaultEndpointsProtocol=https;AccountName=examplestorage;AccountKey=ExampleStorageAccountKey1234567890==;EndpointSuffix=core.windows.net` | string | Yes | The data source is Event Hubs and `eventHubs.checkpointStorageAccountUrl` is empty |
| `eventHubs.checkpointStorageAccountUrl` | `RHIZE_AGENT_EVENTHUBS_CHECKPOINTSTORAGEACCOUNTURL` | Blob service URL for the checkpoint store. When set, it takes precedence over `eventHubs.checkpointStorageConnectionString`, and libre-agent signs in to the storage account as an Azure AD application rather than with a key. Set the application's tenant ID, client ID and client secret in the `AZURE_TENANT_ID`, `AZURE_CLIENT_ID` and `AZURE_CLIENT_SECRET` environment variables, which are separate from the `azure` settings. With them unset, it uses the managed identity of the node the pod runs on. Either identity needs the Storage Blob Data Contributor role on the account. |  | `https://examplestorage.blob.core.windows.net` | string | No |  |
| `eventHubs.checkpointBlobContainerName` | `RHIZE_AGENT_EVENTHUBS_CHECKPOINTBLOBCONTAINERNAME` | Blob container holding the checkpoints. |  | `checkpoints` | string | Yes | The data source is Event Hubs |
| `eventHubs.receivePartitionId` | `RHIZE_AGENT_EVENTHUBS_RECEIVEPARTITIONID` | Restricts the consumer to a single partition. Empty means all partitions are handled by the processor. |  | `0` | string | No |  |
| `eventHubs.receiveAllPartitions` | `RHIZE_AGENT_EVENTHUBS_RECEIVEALLPARTITIONS` | Receives from all partitions. | `false` | `false` | boolean | No |  |
| `eventHubs.receiveMaxBatchSize` | `RHIZE_AGENT_EVENTHUBS_RECEIVEMAXBATCHSIZE` | Maximum events fetched per receive call. Unset or `0` means `100`, and anything above `300` is rejected at startup. | `100` | `10` | integer | No |  |
| `eventHubs.receiveStartFromEarliest` | `RHIZE_AGENT_EVENTHUBS_RECEIVESTARTFROMEARLIEST` | Starts from the earliest available event when no checkpoint exists, rather than from the latest. | `false` | `true` | boolean | No |  |

### `egress`

Where the subscription sends what it reads. **Each handler listed receives
every value change, and with no handler listed nothing is published at all**, so
a deployment that subscribes to anything defines at least one.

`egress.handlers` is a map whose keys are names you choose, so each setting is
written `egress.handlers.<name>.<field>`. Define each handler in
`rhizeAgentConfig`. The environment variables in the table then set that
handler's fields, provided each field is written in the handler's block. To
take a field's value from its variable alone, write it in the block as `""`.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `egress.handlers.<name>.protocol` | `RHIZE_AGENT_EGRESS_HANDLERS_<NAME>_PROTOCOL` | Where the handler sends messages. `kafka` produces to the Kafka topic named by `topic`, or to the topic a `patterns` entry picks. `http` POSTs each message to `serverUrl`. `nats` publishes to a NATS subject over the connection the `nats` section configures. Any other value logs "Unknown egress protocol" and the handler is skipped. |  | `kafka` | string | Yes | The handler is defined |
| `egress.handlers.<name>.serverUrl` | `RHIZE_AGENT_EGRESS_HANDLERS_<NAME>_SERVERURL` | Where to publish. For `kafka`, the broker address. For `http`, the URL to POST to, where a literal `{id}` in the URL is replaced with the message subject; the body is JSON and carries an `idempotency-key` header. Not used by `nats`, which takes its connection from the `nats` section instead. An empty value crashes libre-agent at startup for `kafka` and `http`. |  | `kafka:9092` for Kafka, `http://ingest:8080/values/{id}` for HTTP | string | Yes | The handler's `protocol` is not `nats` |
| `egress.handlers.<name>.topic` | `RHIZE_AGENT_EGRESS_HANDLERS_<NAME>_TOPIC` | Kafka only. Topic to publish to when no entry in `patterns` matches. Topics are created on demand if the broker allows it. |  | `value-changes` | string | Yes | The handler's `protocol` is `kafka` |
| `egress.handlers.<name>.patterns` | — | Kafka only. List of `{topic, regex}` pairs that route by source node name. When the regex matches the node, the message goes to that pair's `topic` instead of the handler's `topic`, and a `$1` in that topic is replaced with the text of the first capture group, so a single pattern can give each site or line its own topic. Keep the patterns mutually exclusive: when several match, which one wins is not predictable. An entry with an empty `topic`, or a regex that does not compile, crashes libre-agent at startup. |  | see the example block below | list | No |  |

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

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `nats.serverUrl` | `RHIZE_AGENT_NATS_SERVERURL` | NATS server address. The default reaches a NATS Service named `nats` on its usual port in the same namespace, so it only needs setting where the server is named or ported differently. An unreachable address stops libre-agent at startup. | `nats:4222` | `nats://nats:4222` | string | No |  |
| `nats.username` | `RHIZE_AGENT_NATS_USERNAME` | NATS username. | `system` | `system` | string | No |  |
| `nats.password` | `RHIZE_AGENT_NATS_PASSWORD` | NATS password. Supply from a Kubernetes Secret. | `system` | `ExamplePassword123` | string | No |  |

### `bridge`

Turns libre-agent into a broker-to-broker message bridge. This is a
**replacement** for normal operation, not an addition: when a `bridge` section
is present, libre-agent forwards messages between the brokers defined here and
ignores every other section on this page, `datasource` included.

Each handler is one broker connection, and a message arriving on one is published
to all of the others. Messages are never sent back to the handler they arrived
on, and a message that has already been routed once is not routed again, so two
handlers cannot loop.

`bridge.handlers` is a map whose keys are names you choose, and the name is what
identifies the connection in the logs. As with `egress`, define each handler in
`rhizeAgentConfig`, writing every field that its variable should set, using `""`
for a field whose value comes only from the variable.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `bridge.topics` | — | Topics to carry across the bridge, written the NATS way: a `.` between levels, `*` for any single level, and `>` for everything below that point. Every broker here subscribes to all of them. An MQTT broker gets the topics converted to MQTT form on the way, so `libre.*.values` reaches that broker as `libre/+/values`. |  | `[libre.>]` | list | Yes | A `bridge` section is present |
| `bridge.handlers.<name>.protocol` | `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_PROTOCOL` | Which broker the handler speaks to: `nats` for a NATS server, `mqtt` for an MQTT broker. A handler naming anything else is left out of the bridge. |  | `mqtt` | string | Yes | The handler is defined |
| `bridge.handlers.<name>.serverUrl` | `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_SERVERURL` | Broker address, including scheme and port. |  | `mqtt://broker:1883` for MQTT, `nats://nats:4222` for NATS | string | Yes | The handler is defined |
| `bridge.handlers.<name>.username` | `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_USERNAME` | Username for the broker. Omit for an anonymous connection. |  | `bridge` | string | No |  |
| `bridge.handlers.<name>.password` | `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_PASSWORD` | Password for the broker. Write it here as an empty value and supply the real one from a Kubernetes Secret. |  | `ExamplePassword123` | string | No |  |
| `bridge.handlers.<name>.clientId` | `RHIZE_AGENT_BRIDGE_HANDLERS_<NAME>_CLIENTID` | MQTT only. Client id for the connection. Must be unique per broker, since two connections sharing one will disconnect each other. |  | `libre-bridge` | string | No |  |

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

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| — | `all_proxy` | SOCKS5 proxy that libre-agent dials MQTT broker connections through, both for an MQTT data source and for MQTT connections in the bridge. Requires either a `socks5://` or `socks5h://` URL. An MQTT data source pinned to `mqtt.version` `3.1.1` connects directly, as do all other connections libre-agent makes, including NATS, Kafka, and calls to BAAS. |  | `socks5://proxy.example.com:1080` | string | No |  |

## Helm chart values

Values shared by every chart are documented in
`shared-helm-values.md`.

| Name | Environment variable | Description | Default | Example value | Type | Required | Required when |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `rhizeAgentConfig` | — | The complete application configuration, rendered into a ConfigMap named after the release and mounted at `/config`. libre-agent exits if the file is missing. | the block described above | the Application configuration section | object | Yes |  |
| `envVars` | — | Map of environment variable names to values passed to the container. |  | see the example block below | map | No |  |
| `additionalSecrets` | — | List of entries that each carry one value from a Kubernetes Secret into an environment variable: `name` is the variable the service reads, `secretName` is the Secret to take the value from, and `secretKey` is the name of the entry within that Secret. This is how every credential should reach libre-agent, using the variable names in the second column of the tables above: `RHIZE_AGENT_OIDC_CLIENTSECRET` for the OIDC client, and `RHIZE_AGENT_OPCUA_PASSWORD`, `RHIZE_AGENT_MQTT_PASSWORD`, or `RHIZE_AGENT_NATS_PASSWORD` for the data source or broker in use. |  | see the example block below | list | No |  |
| `caFile` | — | Contents of a PEM CA certificate for outbound HTTPS calls, given as a YAML block, `caFile: \|`, with the certificate's lines indented beneath. Trusting a certificate takes two values: give the certificate here, which mounts it at `/certs/ca-cert.pem`, and set `libreDataStoreGraphQl.caFile` in `rhizeAgentConfig` to that path. |  | `-----BEGIN CERTIFICATE-----…` | string | No |  |
| `service.port` | — | Port for the Service, the container port, and the port libre-agent serves Restate handlers on. The chart writes it into the configuration as `restate.servicePort` as well, so the port Restate calls back on is always the one the Service exposes. | `8887` | `8887` | integer | No |  |
| `extraVolumes` / `extraVolumeMounts` | — | How an OPC UA client certificate and key get into the container, which is the one file libre-agent reads that the chart does not place itself. Mount the pair, then name the mounted paths in `opcUa.certFile` and `opcUa.keyFile`. Give each value as a list of standard Kubernetes volume and volume mount entries, and set both: a mount whose volume is missing stops the pod from starting. |  | see the example block below | list | No |  |

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
