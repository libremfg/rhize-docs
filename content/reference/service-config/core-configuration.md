---
title: 'Core configuration'
categories: ["reference"]
description: Configuration for the Rhize core
weight: 900
menu:
  main:
    parent: reference-service-config
    identifier:
---

 The Core service oversees data sources such as OPC-UA servers and manages the publication and subscription of topics within the NATS messaging system.

# Configurations

## `bpmn`

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`        | The URL of the BPMN endpoint to use for interacting with Rhize services. <br />(Default: `http://localhost:8081`) |  

## `graphQlServer`

 The server used to connect to the GraphQL playground.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `port`              | The port used within the URL that connects to the graphQLServer. <br />(Default: `4001`)     |           

## `libreDataStoreGraphQl`

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`        | The URL of the GraphQL endpoint to use for interacting with Rhize services. <br />(Default: `http://localhost:8080/graphql`) |       

## `logging`

 Logs the configuration to the console.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`              | Specifies the logging configuration type: `json`, `multi`, or console. <br />(Default: `console`)                                                                                   |                                                                                                                                                 
| `level`             | Configures the level of logging: `Trace`, `Debug`, `Info`, `Warn`, `Error`, `Fatal`, and `Panic`. <br />(Default: `Trace`)                                                                     |

## `nats`

 Message broker that drives Rhize's event-based architecture.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the NATS server. <br />(Default: `nats://system:system@localhost:4222`)       |                                                                                                                                                 
| `replicas`          | The number of replicas or instances of the NATS server to be deployed. <br />(Default: `1`)                                                                                                    |


## `oidc`

 Configurations for Keycloak authentication and connection with OpenID Connect.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenID Connect server. <br />(Default: `http://localhost:8090`)    |                                                                                                                    
| `realm`             | Identifies the authentication domain for which the authentication request is being made.                                                                              |
| `clientId`         | The unique identifier assigned to the client application by the OIDC server.                                                                                      |
| `clientSecret`     | Used to authenticate the client when making confidential requests.                                                                       |
| `username`          | The username credentials of the user who is attempting to authenticate with the OIDC server.                                                           |
| `password`          | The password credentials of the user who is attempting to authenticate with the OIDC server.                                                                         |

## `openTelemetry`

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenTelemetry server. <br />(Default: `localhost:4317`)                                                                                                                         | 
| `samplingRate`      | The sampling rate for traces. <br />(Default: `1`)                                                                                                                                         | 

## `secret`

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `key`               | The SECRET KEY used for authorization within Core.       |              

## `timeSeries`

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `enabled`           | Enables the use of TimeSeries. <br />(Default: `false`)     |                                                                                                                                                 
