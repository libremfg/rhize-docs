---
title: >-
  Use cases of Rhize
description: >-
  Handle manufacturing events, access the knowledge graph of the operation, build custom MOM applications. 
weight: 1
menu:
  main:
    identifier: use-case-overview
    parent: use-cases
    name: Overview
---

Rhize's flexible, event-centric architecture serves many functions.
While Rhize has components that can replace an {{< abbr "MES" >}}, historian, andon, and real-time monitoring solutions,
it can complement them just as well.
You can map data from an MES or {{< abbr "ERP" >}} into the database, creating a coherent data model to unite your operations IT.

Besides better performance and flexibility, Rhize has far tighter integration of plant and system data.
Yet, its data model is generic enough to conform to may use cases, chiefly:
- **A manufacturing knowledge graph**. Query the entire context and history of the operation.
- **Headless MES or MOM**. Use the API to build custom applications for a variety of MES and MOM activities.
- **An event handler**. Receive manufacturing message streams and react to them.

Of course, each of these use cases has many uses cases.
These use cases of Rhize are already implemented in discrete, continuous, and batch manufacturing operations.

## Manufacturing knowledge graph

All data that Rhize collects, whether from sensors or an ERP, is contextual and interconnected. Rather than a relational database, Rhize uses a graph database, where any node can link to any other, and users can query any data combination, without requiring complex joins.

The graph database unlocks new possibilities for manufacturing analysis and data science.
For example:
- Run queries to find anomalies in an operation---which may trace to a specific site, segment, equipment, material lot, personnel, and so on.
- Discover places to optimize the system, whether they are bottlenecks to remove or highly productive areas to replicate
- Train deep-learning models to detect conditions that lead to batch failures.
- Use the historical record as a model to run simulations of new events

Guide: [Use the knowledge graph]({{< relref "../how-to/gql" >}})

## Headless MES or MOM

Rhize serves as a backend to create custom applications to replace traditional MES or MOM systems.
Rather than force its opinion of what an MES interface should look like, Rhize provides the only data model, API, and BPMN engine.
Your frontend teams can then use the tools of their choice to make the MES designed for your use case, with all the backend work delegated to Rhize's normal operation features.


With the combination of its event-driven architecture and unified data model, Rhize can:
- calculate OEE, or far more granular metrics
- Handle schedules and maintenance orders
- Track and trace material
- Execute dynamic workflows.

Besides building bespoke frontends, many operators choose to integrate Rhize with low-code systems like Appsmith.
For some problems, lowcode models can reduce the time to create applications dramatically, making it easier to create and test prototypes, involve more stakeholders in the application design process, iterate on working models, and generally do useful things more quickly.

Guides: [Model production]({{< relref "../how-to/model" >}}), [Connect process data]({{< relref "../how-to/publish-subscribe" >}}).

## Real-time event handling

The fundamental design of Rhize is low-latency and event-driven.
Rhize can collect and monitor data from protocols like MQTT and OPC-UA.

Rhize also has components to monitor and react to this data stream, ensuring that you can stop problems early&mdash;and program corrective measures to execute automatically.
Event orchestration is handled through {{< abbr "BPMN" >}}, a low-code interface that can listen for events and initiate conditional flows.

Guide: [Handle events]({{< relref "../how-to/bpmn" >}})
