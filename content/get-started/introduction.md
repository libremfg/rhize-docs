---
title: 'What is Rhize?'
date: '2023-09-26T12:25:46-03:00'
draft: false
category: concept
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

Rhize has only one strong opinion: all data exchanged must be modeled on the ISA-95 standard.
This standards-based schema is how Rhize connects every data event across an entire operation.
If you aren't an ISA-95 fan, we're happy to convert you, but adoption is a requirement to use the platform.

And if do adopt ISA-95, you open your organization to Rhize's far-reaching transformations.

## Use cases

Rhize's flexible, data-centric architecture can serve many functions.
It has components that can completely replace your MES, historian, andon, and real-time monitoring solutions.
Besides better performance and flexibility, Rhize has far tighter integration of plant and system data.

Some uses of Rhize include:

- **Manufacturing knowledge graph**.

  All data that Rhize collects, whether from sensors or from an ERP, is contextual and interconnected. Rather than a relational database, Rhize uses a graph structure, where any node can be traversed from any other.
  
  The graph database unlocks new possibilities for manufacturing analysis and data science, especially when used as a source to train deep-learning models.

- **Real-time monitoring and alerts**.

  The fundamental design of Rhize is low-latency and event-driven.
  Rhize can collect and monitor data from protocols like MQTT and OPC-UA.
  
  Rhize also has components to monitor and react to this data stream, ensuring that you can stop problems early&mdash;and program corrective measures to execute automatically.
  
- **MES or MOM**

  Rhize serves as a drop-in replacement for a traditional MES or MOM.
  Through the data bus, it can calculate OEE, schedule, track, and execute dynamic workflows.

  All execution also runs through the same GraphQL endpoint.

## Modern IT for manufacturing 

Rhize is innovative, practical, and built on modern tools and practices:

- **All data is accessible through a single endpoint.**
While the data collected and processed may span multiple segments, events, units, areas, and even plants, all data is stored in a graph database and exposed through a GraphQL interface.

- **Automated and containerized deployment.**
Rhize brings innovations from DevOps to manufacturing.
In practice, this means that Rhize is interoperable with whatever system the manufacturer uses,
deployment is version-controlled, and your system can use rolling upgrades with zero downtime.

- **Built on open standards.**
Rhize is based on open standards, like ISA-95, and open protocols, like MQTT.
Open industry standards and protocols ensure that the application and your manufacturing processes speak a common language.
Rhize heavily uses open-source software, which brings interoperability and robust tooling ecosystems.

  
## A tool that fits to your processes

The development of Rhize is the culmination of decades of experience from real practitioners.
We know that manufacturing is messy, and each process has thousands of particulars.
Even within the same company and segment, processes frequently differ from site to site.

Our design philosophy empowers manufacturing operators to shape their tool for their work demands.
Some examples of the flexibility include:

- **A headless MES**. While Rhize has a graphical interface, all data is reachable through a single API endpoint. This means your teams can rapidly build custom frontends―and do it with the most comfortable API for frontend development, GraphQL.
- **No code interface**. Model your schema and execute processes using BPMN, a visual programming language. The visual interface makes Rhize and your manufacturing automation accessible to the widest possible audience.
- **Generic data collection**. Rhize receives data from all levels of the manufacturing process. The NATS broker publishes and subscribes to low-level data from MQTT and OPC-UA, but the database can also receive ERP inventories and documents sent over HTTP.
