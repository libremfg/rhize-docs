---
title: 'Agent configuration'
categories: ["reference"]
description: Configuration parameters for the Rhize agent
aliases:
  - "/reference/agent-configuration/"
weight: 900
menu:
  main:
    parent: reference-service-config
    identifier:
---

The Rhize agent collects data that is emitted in the manufacturing process and makes this data visible in the Rhize system.
It works by connecting to equipment or groups of equipment that run over protocols such as OPC UA.

As the communication bridge between the Rhize Data Hub and your plant, the agent has multiple functions:
- It subscribes to tags and republishes the changes in NATS.
- It creates an interface for the BPMN engine to send reads and writes to a data source and its associated equipment.


## OPC UA authentication types

 When authenticating over OPC UA, Rhize supports the following authentication types:

| Authentication type | Behavior                                                                                                                                                                                       |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Anonymous           | Connects without any necessary credential.                                                                                                                                                      |
| Username            | Authenticates through a `username` and `password` in the config file, or through a Kubernetes secret.                                                                                                                           |
| Certificate         | Uses the certificate on disk specified in the  `opcUa.CertFile` and `opcUa.KeyFile` configs. If no certificate exists and the config specifies the `opcUa.GenCert` property as `true`, automatically generates one. |

## `logging`

 Logs the configurations to the console.

| Attributes | Description |   
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`                | Specifies the logging configuration type: `json`, `multi`, or console. <br />(Default: `console`) |
| `level`               | Configures the level of logging: `Trace`, `Debug`, `Info`, `Warn`, `Error`, `Fatal`, `Panic`. Defaults to `Trace`. <br />(Default: `trace`) |

## `libreDataStoreGraphQl`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the GraphQL endpoint to use for interacting with Rhize services. <br />(Default: `http://localhost:8080/graphql`) |

## `nats`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
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
| `serverUrl`         | The URL of the OpenTelemetry server.  <br />(Default: `localhost:4317`) |   

## `opcUa`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `discoveryUrl`         | The URL to locate and connect to OPC UA servers on a network. <br />(Default: `opc.tcp://localhost:4840`) |
| `serverUrl`         | The URL of the OPC UA service server.  <br />(Default: `opc.tcp://localhost:4840`) |
| `username`         | The username credentials to authenticate with the OPC UA server. |
| `password`         | The password credentials to authenticate with the OPC UA server. |
| `mode`         | The operational mode of the OPC UA server/client.  <br />(Default: `None`) |
| `policy`         | The security measures for OPC UA server communication.  <br />(Default: `None`) |
| `authentication`         | The authentication mechanisms and user access control.  <br />(Default: `Anonymous`) |
| `applicationUri`         | The application's unique URI within the OPC UA system.  <br />(Default: `opc.tcp://localhost:4840`) |

## `buffers`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `protocolQueueType`         | The type of queue used for buffering communication protocol data.  <br />(Default: `0`) |   

## `health`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `pollInterval`         | The frequency of scans for component status and health.  <br />(Default: `1000`) |   
| `subscriptionTimeout`         | The maximum duration to wait to receive updates from subscribed data sources.  <br />(Default: `60000`) |   
| `subscriptionMaxCount`         | The maximum number of concurrent subscriptions for monitoring.  <br />(Default: `5`) |   

## `mqtt`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `version`         | The version of MQTT used: `5.0` or `3.1.1`. <br />(Default: `3.1.1`) |   
| `clientId`         | The ID used in the MQTT broker.  <br />(Default: `mqtt-client`) |   
| `serverUrl`         | The URL of the MQTT broker.  <br />(Default: `mqtt://localhost:1883`) |   
| `username`         | The username credentials to authenticate with the MQTT broker. |   
| `password`         | The password credentials to authenticate with the MQTT broker. |   
| `decomposeJson`         | Enables or disables JSON payload decomposition into individual data fields.  <br />(Default: `false`) |   
| `timestampField`         | The field to search to return timestamp information.  <br />(Default: `timestamp`) |   
| `requestTimeout`         | The maximum duration to wait to receive a response to an MQTT request from the broker.  <br />(Default: `10`) |   

## `datasource`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `id`              | The source ID to retrieve payload data from.  <br />(Default: `DS_0806`) |   

## `azure`

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `clientId`         | The ID used to securely authenticate Azure service access. |   
| `clientSecret`         | The secret key associated with the client ID for authentication. |  
| `tenantId`         | The ID of the Azure Active Directory tenant where the service is registered. |  
| `serviceBusHostName`         | The URL of the Azure Service Bus namespace used for Azure ecosystem communication.  <br />(Default: `bsl-dev.servicebus.windows.net`) |  
