---
title: 'What is Rhize?'
date: '2023-09-26T12:25:46-03:00'
draft: false
categories: "concepts"
description:
weight: 1
menu:
  main:
    parent: get-started
    identifier:
---

Rhize is a real-time, event-driven manufacturing data hub.
It unites data analysis, event monitoring, and process execution in one platform.
Its interface and architecture is designed to conform to your processes.
We assume nothing about what your manufacturing workflows look like.

Rhize has only one strong opinion: all manufacturing objects and data must be modeled on the [ISA-95 standard](https://www.isa.org/standards-and-publications/isa-standards/isa-standards-committees/isa95).
This standards-based schema is how Rhize connects every data event across an entire operation.
If you aren't an ISA-95 fan, we're happy to convert you, but adoption is a requirement to use the platform.

And if you do adopt ISA-95, you open your organization to Rhize's far-reaching transformations.

## Use cases

Rhize's flexible, data-centric architecture can serve many functions.
While Rhize has components that can replace an {{< abbr "MES" >}}, historian, andon, and real-time monitoring solutions,
it can complement them just as well.
You can map data from an MES or {{< abbr "ERP" >}} into the database, creating a coherent data model to unite your operations IT.

Besides better performance and flexibility, Rhize has far tighter integration of plant and system data.

Some uses of Rhize include:

- **Manufacturing knowledge graph**.

  All data that Rhize collects, whether from sensors or from an ERP, is contextual and interconnected. Rather than a relational database, Rhize uses a graph database, where any node can link to any other, and users can query any data combination, without requiring complex joins.

  The graph database unlocks new possibilities for manufacturing analysis and data science.
  For example, you can use it to find anomalies in a segment across many sites,
  or as a database to train deep-learning models to detect conditions that lead to batch failures.

  Guide: [Use the knowledge graph]({{< relref "../how-to/gql" >}})

- **Real-time monitoring and alerts**.

  The fundamental design of Rhize is low-latency and event-driven.
  Rhize can collect and monitor data from protocols like MQTT and OPC-UA.

  Rhize also has components to monitor and react to this data stream, ensuring that you can stop problems early&mdash;and program corrective measures to execute automatically.
  Event orchestration is handled through {{< abbr "BPMN" >}}, a low-code interface that can listen for events and initiate conditional flows.

  Guide: [Handle events]({{< relref "../how-to/bpmn" >}})

- **MES or MOM**

  Rhize serves as a drop-in replacement for a traditional MES or MOM.
  With the combination of its event-driven architecture and unified data model, it can calculate OEE, schedule, track, and execute dynamic workflows.

  Guides: [Model production]({{< relref "../how-to/model" >}}), [Connect process data]({{< relref "../how-to/publish-subscribe" >}}).

## Modern IT for manufacturing

Rhize's system design is flexible, practical, and built on modern tools and practices:

- **All data is accessible through a single endpoint.**
While the data collected and processed may span multiple segments, events, units, areas, and even plants, all data is stored in a graph database and exposed through a [GraphQL](https://graphql.org) interface.

- **Automated and containerized deployment.**
Rhize brings innovations from DevOps to manufacturing.
In practice, this means that Rhize is interoperable with whatever system the manufacturer uses,
deployment is version-controlled, and your system can use rolling upgrades with zero downtime.

- **Built on open standards.**
Rhize is based on open standards, like ISA-95, and open protocols, like MQTT.
Open industry standards and protocols ensure that the application and your manufacturing processes speak a common language.
Rhize heavily uses open-source software, which brings interoperability, reduced vendor lock, and robust tooling ecosystems.


## A tool that fits to your processes

The development of Rhize is the culmination of decades of experience from real practitioners.
We know that manufacturing is messy, and each process has thousands of particulars.
Even within the same company and segment, processes frequently differ from site to site.

Our design philosophy empowers manufacturing operators to shape their tool for their work demands.
Some examples of the flexibility include:

- **A headless MES**. While Rhize has a graphical interface, all data is reachable through a single API endpoint. This means your teams can rapidly build custom frontends―and do it with the most comfortable API for frontend development, GraphQL.
- **Low-code interface**. Model your schema and execute processes using BPMN, a visual programming language. The visual interface makes Rhize and your manufacturing automation accessible to the widest possible audience.
- **Generic data collection**. Rhize receives data from all levels of the manufacturing process. The [NATS](https://nats.io) broker publishes and subscribes to low-level data from [MQTT](https://mqtt.org/) and [OPC-UA](https://opcfoundation.org/about/opc-technologies/opc-ua/), but the database can also receive ERP inventories and documents sent over HTTP.
