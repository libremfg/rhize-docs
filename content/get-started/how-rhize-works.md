---
title: 'How Rhize works'
date: '2023-10-03T19:39:39-03:00'
draft: false
category: concept
description: >-
  A high-level overview of how Rhize collects, exchanges, and stores, starting with data collection and ending with user interaction.
weight: 200
menu:
  main:
    parent: get-started
    identifier:
---

The heart of the Rhize platform is its manufacturing knowledge graph, which stores data from all levels of the operation and exposes this data through a single endpoint.
Around the database are services that exchange messages and process events in real-time.
Finally, outside of the Rhize deployment are the two most important components: the manufacturing operation, which sends event data to Rhize, and the Rhize users, who interact with Rhize data through a number of special-purpose interfaces.

{{< figure
src="/get-started/diagram-rhize-arch-overview.png"
alt="A simplified diagram of Rhize's architecture"
caption="<em><small>A simplified view of Rhize's architecture</small></em>"
width="40%"
>}}

This article provides a high-level overview of how Rhize works, starting with data collection and ending with user interaction.
To make these concepts more concrete, the final section provides examples of each process.

## Data collection

A manufacturing data hub is useless without manufacturing data.

Rhize's database schema is modeled on the ISA-95 standard.
ISA-95 covers all levels of the manufacturing operation.
Correspondingly, Rhize accepts data from all levels, including measurements, schedules, and ERP documents.

Common sources of data collection come from MQTT brokers and devices, OPC-UA servers, and over HTTP through the GraphQL endpoint.
This depends entirely on what you want to send to the Rhize message broker or database.


## The message broker

{{< figure
src="/get-started/rhize-diagram-data-sources.png"
alt="More granular view of Rhize-Customer messaging"
width="80%"
>}}

Rhize's architecture is event-driven, low-latency, and scalable.
To communicate events in real-time and across services, Rhize uses a publish-subscribe model through the NATS message broker.

Services in the Rhize application subscribe to their relevant topics and handle events as they come in.
Services also publish events to the event broker.
Thus, Rhize services can communicate with each other and with customer systems in a completely decoupled manner.

The message infrastructure enables complex interaction between services without creating dependencies between them.

## The database

The Graph database creates a contextual, queryable relationship between all data in the system.
Additionally, real-time data streams to the time-series component of the database.

Using the ISA-95 standard to define its schema, the graph database is how Rhize stores event data from disparate places and decoupled services.
It also stores declarative configuration data to instruct different services on how to respond to events.
This graph data, accessible through a single endpoint, provides a single source to perform vast combinations of analysis.

## The interfaces

The Rhize application comes with a graphical interface.
Some uses include:
- **Configure BPMN rules.** A low-code tool for analysts and operators to create programmable events.
- **Upload master data.**  Based on the ISA-85 object models.
- **Administrate.** Authenticate and scope access to systems and personnel.

The UIs sit on top of the GraphQL API gateway, which serves as a programming interface for data analysis.
Rhize customers also use the GraphQL interface to build their own applications, either with dedicated frontend developers or through low-code tools like Appsmith.

Last but not least, the time-series data is observable through monitoring tools like Grafana.

## Examples in practice

To make the previous sections less abstract, consider these ways that Rhize creates common data hub for diverse human and system interaction.

|Process| Examples in practice|
|-|-|
|Data collection| <ul><li>An instrumenter configures an MQTT-compatible device to send sensor data to Rhize.</li><li> A business analyst sends an ERP order through an integration with the GraphQL API.</li></ul>|
|Message exchange| <ol> <li> A piece of equipment publishes information about its status over MQTT.</li> <li> A BPMN process subscribes to the equipment's `TestResult` subtopic. When the `TestResult` status changes to `fail`, the BPMN process publishes a maintenance order to the broker.</li> <li>The ERP system, which subscribes to the `maintenance` topic, prepares a document for maintenance personnel.</li> </ol> |
|Data storage| <ul><li>A data scientist writes a Python script that discovers production outliers for a specific segment class across all production sites</li><li>A procurer uses an Excel-Rhize integration to call the API and receive a production order that the BPMN process wrote to the database one month earlier.</li></ul> |
| User-data interaction | <ul><li>An operator queries sensor values from a custom-built mobile interface</li><li>A quality-engineer observes real-time data in a custom dashboard built for statistical process control</li></ul>|
