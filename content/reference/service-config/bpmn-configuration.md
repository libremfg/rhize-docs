---
title: 'BPMN configuration'
categories: ["reference"]
description: Authentication types for the Rhize BPMN
weight: 900
menu:
  main:
    parent: reference-service-config
    identifier:
---

The Rhize BPMN acts as the tailored engine for processing low-code workflows designed within the [BPMN UI]{{< relref "/how-to/bpmn" >}}. The configurations manage the connection and data flow on the BPMN engine to the other Rhize microservices. 

# Configurations

## `commandConsumer`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `threads`         | The number of threads for command consumption. <br />(Default: `3`) |         

## `http`

 All HTTP configurations are measured in `seconds`.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `readHeaderTimeout`   | Wait duration for the request header to be fully read before timing out. <br />(Default: `10`)           |
| `readTimeout`         | Wait duration for the entire request to be read before timing out. <br />(Default: `15`)                 |
| `writeTimeout`        | Wait duration for the entire response to be written before timing out. <br />(Default: `10`)             |
| `idleTimeout`         | Wait duration for the next request while the connection is idle before timing out. <br />(Default: `30`)  |

## `libreDataStoreGraphQl`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the GraphQL endpoint to use for interacting with Rhize services. <br />(Default: `http://localhost:4000/`) |
| `caFile`     | The file path of the CA certificate used for secure communication with the GraphQL endpoint.  <br />(Default: `''`) |

## `logging`

 Logs the configurations to the console.

| Attributes | Description |   
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`                | Specifies the logging configuration type: `json`, `multi`, or console. <br />(Default: `console`) |
| `level`               | Configures the level of logging: `Trace`, `Debug`, `Info`, `Warn`, `Error`, `Fatal`, or `Panic`. <br />(Default: `Debug`) |

## `nats`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `commandStreamReplicas`         | The number of replicas for the command stream. <br />(Default: `1`) |
| `jobResponseKVMaxGB`         | The maximum size (in gigabytes) for the job response key-value store. <br />(Default: `2`) |
| `jobResponseKVReplicas`         | The number of replicas for the job response key-value store. <br />(Default: `1`) |
| `jobResponseKVTTLMinutes`         | the "time-to-live" (in minutes) for job response key-values. <br />(Default: `7`) |
| `workflowSpecificationKVReplicas`         | The number of replicas for the workflow specification key-value store. <br />(Default: `1`) |
| `serverUrl`         | The URL for connecting to the NATS server. <br />(Default: `nats://system:system@localhost:4222`) |

## `oidc`

 Configurations for Keycloak authentication and connection with OpenID Connect.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenID Connect server. <br />(Default: `http://localhost:8090`) |
| `realm`         | Identifies the authentication domain for which the authentication request is being made. |
| `clientId`         | The unique identifier assigned to the client application by the OIDC server. |
| `clientSecret`         | Used to authenticate the client alongside the client ID when making confidential requests. |
| `username`         | The username credentials to authenticate with the OIDC server. |
| `password`         | The password credentials to authenticate with the OIDC server. |

## `openTelemetry`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenTelemetry server.  <br />(Default: `localhost:4317`)                                                                                                                                    |
| `defaultDebug`         | Enables or disables default debug mode.  <br />(Default: `false`)                                                                                                               |

## `secret`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `key`         | The secret key used to connect to the BPMN client.  |

## `viewInstance`

 Configuration for service viewing instances.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `grafana`             | `org`: The organization ID for the Grafana instance (Default: `1`). <br /> `tempoUid`: The UID for Tempo integration in Grafana (Default: `libre-tempo`). <br /> `url`: The URL of the Grafana instance (Default: `http://localhost:3000`). |
| `loki`                | `accessToken`: The access token for authentication with Loki (Default: `''`). <br /> `url`:  The URL of the Loki instance (Default: `http://localhost:3100`).                                                                                   |
| `tempo`               | `accessToken`: The access token for authentication with Tempo (Default: `''`). <br /> `url`:  The URL of the Tempo instance (Default: `http://localhost:3200`).                                                                                 |
