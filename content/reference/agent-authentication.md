---
title: 'Agent authentication types'
categories: ["reference"]
description: Authentication types for the Rhize agent
weight: 900
menu:
  main:
    parent: reference
    identifier:
---

The Rhize agent collects data that is emitted in the manufacturing process and makes this data visible in the Rhize system.
As the communication bridge between the Rhize Data Hub and your plant, the agent can handle reads and writes to and from data sources, and it can be called by a [BPMN task]({{< relref "bpmn/activities" >}}).

It works by connecting to equipment or groups of equipment that run over protocols such as OPC UA,
and then reading and writing tags to re-publish them to NATS.
This connection has various authentication options.

## OPC UA authentication types

 When authenticating over OPC UA, Rhize supports the following authentication types:

| Authentication type | Behavior                                                                                                                                                                                       |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Anonymous           | Connects without any necessary credential                                                                                                                                                      |
| Username            | Authenticates through a `username` and `password` in the config file, or through a Kubernetes secret                                                                                                                           |
| Certificate         | Uses the certificate on disk specified in the  `OPCUA.CertFile` and `OPCUA.KeyFile` configs. If no certificate exists and the config specifies the `OPCUA.GenCert` property as `true`, automatically generates one. |
