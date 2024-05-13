---
title: 'Agent configuration'
categories: ["reference"]
description: Authentication types for the Rhize agent
weight: 900
menu:
  main:
    parent: reference
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
| Certificate         | Uses the certificate on disk specified in the  `OPCUA.CertFile` and `OPCUA.KeyFile` configs. If no certificate exists and the config specifies the `OPCUA.GenCert` property as `true`, automatically generates one. |

## logging

 Logs the configurations to the console.

| Attributes | Description |   
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`                | Specifies the logging configuration type: `json`, `multi`, or console. <br />(Default: `console`) |
| `Level`               | Configures the level of logging: `Trace`, `Debug`, `Info`, `Warn`, `Error`, `Fatal`, `Panic`. Defaults to `Trace`. <br />(Default: `trace`) |

## libreDataStoreGraphQL

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `GRAPHQL_URL`         | The URL of the GraphQL endpoint to use for interacting with Rhize services. <br />(Default: `http://localhost:8080/graphql`) |

## NATS

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `SERVER_URL`         | The URL for connecting to the NATS server. <br />(Default: `nats://system:system@localhost:4222`) | 

## OIDC

 Configurations for Keycloak authentication and connection with OpenID Connect.

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenID Connect server. <br />(Default: `http://localhost:8090`) |
| `realm`         | Identifies the authentication domain for which the authentication request is being made. |
| `client_id`         | The unique identifier assigned to the client application by the OIDC server. |
| `client_secret`         | Used to authenticate the client alongside the client ID when making confidential requests. |
| `username`         | The username credentials to authenticate with the OIDC server. |
| `password`         | The password credentials to authenticate with the OIDC server. |

## OpenTelemetry

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenTelemetry server.  <br />(Default: `localhost:4317`) |   

## OPCUA 

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `DiscoveryUrl`         | The URL to locate and connect to OPC UA servers on a network. <br />(Default: `opc.tcp://localhost:4840`) |
| `Endpoint`         | The URL of the OPC UA service server.  <br />(Default: `opc.tcp://localhost:4840`) |
| `Username`         | The username credentials to authenticate with the OPC UA server. |
| `Password`         | The password credentials to authenticate with the. |
| `Mode`         | The operational mode of the OPC UA server/client.  <br />(Default: `None`) |
| `Policy`         | The security measures for OPC UA server communication.  <br />(Default: `None`) |
| `Auth`         | The authentication mechanisms and user access control.  <br />(Default: `Anonymous`) |
| `AppUri`         | The application's unique URI within the OPC UA system.  <br />(Default: `opc.tcp://localhost:4840`) |

## BUFFERS

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ProtocolQueueType`         | The type of queue used for buffering communication protocol data.  <br />(Default: `0`) |   

## HEALTH

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `PollInterval`         | The frequency of scans for component status and health.  <br />(Default: `1000`) |   
| `SubscriptionTimeout`         | The maximum duration to wait to receive updates from subscribed data sources.  <br />(Default: `60000`) |   
| `SubscriptionMaxCount`         | The maximum number of concurrent subscriptions for monitoring.  <br />(Default: `5`) |   

## MQTT

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Version`         | The version of MQTT used: `5.0` or `3.1.1`. <br />(Default: `3.1.1`) |   
| `ClientId`         | The ID used in the MQTT broker.  <br />(Default: `mqtt-client`) |   
| `Endpoint`         | The URL of the MQTT broker.  <br />(Default: `mqtt://localhost:1883`) |   
| `Username`         | The username credentials to authenticate with the MQTT broker. |   
| `Password`         | The password credentials to authenticate with the MQTT broker. |   
| `DecomposeJSON`         | Enables or disables JSON payload decomposition into individual data fields.  <br />(Default: `false`) |   
| `TimestampField`         | The field to search to return timestamp information.  <br />(Default: `timestamp`) |   
| `RequestTimeout`         | The maximum duration to wait to receive a response to an MQTT request from the broker.  <br />(Default: `10`) |   

## DATASOURCE

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `ID`              | The source ID to retrieve payload data from.  <br />(Default: `DS_0806`) |   

## AZURE

| Attribute | Description |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `CLIENT_ID`         | The ID used to securely authenticate Azure service access. |   
| `CLIENT_SECRET`         | The secret key associated with the client ID for authentication. |  
| `TENANT_ID`         | The ID of the Azure Active Directory tenant where the service is registered. |  
| `SERVICEBUS_HOSTNAME`         | The URL of the Azure Service Bus namespace used for Azure ecosystem communication.  <br />(Default: `bsl-dev.servicebus.windows.net`) |  
