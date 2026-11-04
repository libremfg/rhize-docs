---
title: 'What is Rhize?'
date: '2023-09-26T12:25:46-03:00'
draft: false
categories: "concepts"
description: A hub to join all manufacturing data in place. Build manufacturing execution systems and do deep analysis.
weight: 1
aliases:
  - /get-started/introduction/

---

Rhize is a real-time, event-driven [manufacturing data hub]({{< relref "manufacturing-data-hub" >}}).
It unites data analysis, event monitoring, and process execution in one platform.
Its interface and architecture conform to your processes.
We assume nothing about what your operations looks like.

As a default, Rhize ships a schema to model all operational data on the [ISA-95 standard](https://www.isa.org/standards-and-publications/isa-standards/isa-standards-committees/isa95).
This standards-based schema is how Rhize connects every data event across an entire operation.

However, if you want to swap or extend schemas, Rhize's modular architecture is ready to support the data model you need.

## A data hub for manufacturing apps

Rhize is a data hub that collects, stores, integrates, and processes data from your manufacturing system.
Rhize accepts the _event_ as the driver of change in a manufacturing operation.
Its architecture is designed to receive and process message events emitted from the operation in real time.

As a default, Rhize uses the ISA-95 standard as its data model.
Operational data is represented a single graph, a structure ideally suited for the node and edge associations that link every element of a manfafcturing operation.

The database is exposed through a single GraphQL endpoint.
Besides keeping the interface small, the GraphQL query language aligns exactly with the underlying graph model.

The API is completely open. Your operators can use it as a backend to build any MES, MOM, and data-science applications they want.
Rhize also has a built-in low-code BPMN workflow creator, so operators can write logic to handle event data using only API calls and JSON transformation.

Rhize's architecture supports distributed deployment, and its components are loosely coupled microservices.
This clustered approach is necessary for organizations to scale horizontally and maintain high reliability.

## A tool that fits to your processes

The development of Rhize is the culmination of decades of experience from real practitioners.
We know manufacturing is messy, and each process has thousands of particulars.
Even within the same company and segment, processes often differ from site to site.

Our design philosophy empowers manufacturing operators to shape their tool for their work demands.
Some examples of the flexibility include:

- **A headless application platform for secure, custom apps**. While Rhize has a graphical interface, all data is reachable through a single API endpoint. This means your teams and agents can rapidly build custom frontends―and do it with the most comfortable API for frontend development, GraphQL.
- **Graphical presentation of operational processes**. Model your schema and execute processes using BPMN, a visual programming language. The visual interface makes Rhize and your manufacturing automation accessible to the widest possible audience.
- **Generic data collection**. Rhize receives data from all levels of the manufacturing process. The broker publishes and subscribes to low-level data from [MQTT](https://mqtt.org/) and [OPC-UA](https://opcfoundation.org/about/opc-technologies/opc-ua/), but the database can also receive ERP inventories and documents sent over HTTP.

[Read about use cases]({{< relref "../use-cases" >}}).

## Modern IT for manufacturing

Rhize's system design is flexible, practical, and built on modern tools and practices:

- **All data is accessible through a single endpoint.**
While the data collected and processed may span multiple segments, events, units, areas, and even plants, all data is stored in a graph database and exposed through a [GraphQL](https://graphql.org) interface.

- **Automated and containerized deployment.**
Rhize brings innovations from DevOps to manufacturing.
In practice, this means that Rhize is interoperable with whatever system the manufacturer uses,
deployment is version-controlled, and your system can use rolling upgrades with zero downtime.

- **Built on open standards.**
Rhize is based on open standards and protocols.
Open industry standards and protocols ensure that the application and your manufacturing processes speak a common language.
Rhize heavily uses open-source software, which brings interoperability, reduced vendor lock, and robust tooling ecosystems.
