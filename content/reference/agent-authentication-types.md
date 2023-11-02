---
title: 'Agent authentication types'
categories: ["how-to"]
description: Authentication types for the Rhize agent
weight: 900
menu:
  main:
    parent: reference
    identifier:
---

The Rhize agent collects data emitted in the manufacturing process to make it visible in the Rhize system.

It works by connecting to equipment or groups of equipment that run over protocols like OPC UA,
then reading and writing tags to re-publish them to NATS.

## OPC UA authentication types

 When authenticating over OPC UA, Rhize supports the following authentication types:

| Authentication type | Behavior                                                                                                                                                                                       |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Anonymous           | Connects without any necessary credential                                                                                                                                                      |
| Username            | Authenticates through a `username` and `password` in the config file                                                                                                                           |
| Certificate         | Uses the certificate on disk specified in the config at `OPCUA.CertFile/KeyFile`. If none exists and the config specifies the `OPCUA.GenCert` property as `true`, automatically generates one. |



