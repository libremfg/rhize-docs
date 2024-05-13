---
title: 'Audit configuration'
categories: ["reference"]
description: Configuration for the Rhize audit
weight: 900
menu:
  main:
    parent: reference-service-config
---

Audit offers a secure and unchangeable record of all activities that happen within the Rhize system.

## `logging`

 Logs the configuration to the console.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `type`              | Specifies the logging configuration type: `json`, `multi`, or console. <br />(Default: `console`)                                                                                   |                                                                                                                                                 
| `Level`             | Configures the level of logging: `Trace`, `Debug`, `Info`, `Warn`, `Error`, `Fatal`, and `Panic`. <br />(Default: `Trace`)                                                                     |

## `OIDC`

 Configurations for Keycloak authentication and connection with OpenID Connect.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenID Connect server. <br />(Default: `http://localhost:8090`) |                                                                                                                    
| `realm`             | Identifies the authentication domain for which the authentication request is being made.                                                                              |
| `client_id`         | The unique identifier assigned to the client application by the OIDC server.                                                                                     |
| `client_secret`     | Used to authenticate the client when making confidential requests.                                                                       |
| `username`          | The username credentials of the user who is attempting to authenticate with the OIDC server.                                                             |
| `password`          | The password credentials of the user who is attempting to authenticate with the OIDC server.                                                                      |

## `OpenTelemetry`

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the OpenTelemetry server. <br />(Default: `localhost:4317`)     |                                                                                                                                                 

## `storage`

| Description                                                                                                                                                                                                         |
|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Storage system for the configuration data. Value options include: `influxdb` and `pg`.                                                                                                                              |                              

## `influxdb`

 A time-series database that is used in conjunction with Grafana designed for handling time-stamped data, such as metrics, events, and logs, that change over time.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `serverUrl`         | The URL of the InfluxDB server. <br />(Default: `http://localhost:8086`)                                                                                                                       |    
| `token`             | The authentication token to authenticate requests to the InfluxDB server. <br />(Default: `my-token`)                                                                                     |               

## `pg`

 PostgreSQL is a general-purpose relational database management system that supports a wide range of features and data types.

| Attributes          | Description                                                                                                                                                                                    |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `host`              | The host name of the PostgreSQL database server to which the client application connects. <br />(Default: `dbname`)                                                                        |    
| `user`              | The username to authenticate with the PostgreSQL database server.                                                                                             |         
| `password`          | The password associated with the specified PostgreSQL user account.                                                                                              |    
| `port`              | The port number on which the PostgreSQL database server is listening for incoming connections. <br />(Default: `5432`)                                                                         |    
