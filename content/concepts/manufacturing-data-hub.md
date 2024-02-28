---
title: Manufacturing Data Hub
description: >-
  What is a Manufacturing Data Hub? Why is it necessary?
  How the design of Rhize meets the needs of modern manufacturing.
weight: 100
menu:
  main:
    parent: concepts
---

This article explains what the components of a _Manufacturing Data Hub_ (MDH) are and why the system must have these particular components to meet the needs of large, modern manufacturing environments.

In another phrasing, this article explains why Rhize made the choices it did to become the world's first manufacturing data hub.
However, the scope of this article is the design considerations that define an MDH in general.
For introductory explanations about Rhize in particular, read [What is Rhize]({{< relref "/get-started/introduction" >}}) and [How Rhize works]({{< relref "/get-started/how-rhize-works" >}}). 



## What is an MDH?

A manufacturing data hub is a system that collects all manufacturing events, stores them in a standard model, and has a programmable engine that can run user logic to receive, transform, and send messages across different devices in a manufacturing operation.
As it comes with all the necessary backend components&mdash;message handling, logic, and storage&mdash;an MDH also serves as a backend for manufacturers to build custom MES and MOM applications.


{{< figure
width="75%"
alt="simplified mdh"
src="/images/arch/diagram-rhize-simplified-mdh.png"
>}}

Thus, an MDH is not only a storage or message system.
It is a coherent system of interrelated parts and interfaces whose components include the following:

- A high-performance graph database with a standardized schema
- A data model based on manufacturing standards
- An API to interact with the data
- An agent that listens for tag changes coming from devices
- A rules engine that monitors tag changes and triggers user workflows when conditions are met
- A message broker that communicates events to and from various systems
- A workflow engine that processes, transforms, and contextualizes tag and event data
- The IT infrastructure that this all runs on, which at a certain scale must be clustered.

Rhize chose these parts deliberately, after careful consideration and years of real-world experience.
The following sections describe how these parts work together and how this design arose from the manufacturing IT landscape.

## Point-to-point reaches scaling issues

In early efforts to digitize manufacturing, information often flows from _point to point_.
In point-to-point networks, each node communicates directly with another.
For example, a sensor communicates with a PLC, the PLC communicates with the MES, and the MES communicates with the level-4 systems. 
Additionally, even within a specific level, devices and applications might communicate directly with each other:

{{< figure
width="65%"
alt="Diagram simplifying flows depicted in part 1 of ISA-95"
src="/images/arch/diagram-rhize-l3-l4-information-flows.png"
caption="<small>A simplified view of how information might exchange between level 3 and 4 systems in a point-to-point topology.</small>"
>}}

While this form of communication is initially simple to implement, it also tightly couples services.
As the system scales, the complexity of point-to-point communication increases non-linearly. With each node, the system becomes increasingly fragile and unobservable.


## Pub/sub messaging decouples devices

After a point-to-point system becomes too difficult to maintain, the next evolution is to adopt a _hub-and-spoke_ model.
In this topology, a central hub coordinates communication between nodes.
Some systems achieve this by polling. That is, each device sends a request to the hub at some interval to see if anything changed.

Considering the number of devices and volume of exchange in manufacturing, polling can become a very inefficient use of network bandwidth.
For this reason, the publish-subscribe pattern has become a popular way for manufacturers to decouple communication.
Event producers _publish_ topics to a message broker, and the message broker sends the event to consumers that _subscribe_ to the particular topic.

{{< figure
width="65%"
alt="Diagram showing event producers and subscribers in decoupled pub-sub communication"
src="/images/arch/diagram-rhize-pubsub-hubspoke.png"
>}}


But while a publish-subscribe pattern resolves issues of device communication and data accessibility,
it does not address how to make the data useful for analysis or how to build automation workflows using the message stream.
The data on its own provides no value.
What matters is the _event_ that drives the data and the surrounding context of the event that makes it meaningful.

## ISA-95 and graph structures for cohesive contextualization

For a coherent data model and contextualization, all event data must be stored in a standardized schema.
Fortunately, many bright minds in manufacturing have already collaborated to create a generic data model: ISA-95.


{{< figure
width="65%"
alt="Diagram showing ISA-95 data model"
src="/images/arch/diagram-rhize-isa95-schema.png"
>}}


The ISA-95 standard provides a comprehensive data model for manufacturing.
And as it happens, its object-oriented system of attributes and relations has an inherent graph structure.
Thus a database that uses the ISA-95 schema brings built-in standardization for all events, and the graph structure provides the context.


Where publish-subscribe messaging decouples communication, the graph database and schema provide a means to store the events that these messages describe within an interrelated whole.
However, this system still lacks a bridge between the message stream and the long-term, standardized storage.
This gap reveals missing components:
- The system needs to structure raw message data in its ISA-95 representation 
- Users need a way to access the database and message flow to program their own applications

{{< figure
width="65%"
alt="Diagram showing how an MDH is incomplete without a bridge between messages and storage"
src="/images/arch/diagram-rhize-incomplete-mdh.png"
>}}


## The rules engine creates events

After the hub receives a message, it needs to evaluate whether the data is significant enough to constitute an event.
This is the value of the _rules engine_: it assesses message values for changes and then evaluates whether these values should be classified as significant _events_.

{{< figure
width="65%"
alt="Diagram showing how the rules engine turns topics into events."
src="/images/arch/diagram-rhize-rule-engine.png"
caption="<small>A simplified view of how information might be exchanged between level 3 and 4 systems in a point-to-point topology.</small>"
>}}

## A workflow engine makes the system responsive

For true "ubiquitous automation" of manufacturing processes, an MDH must provide a way for users to write their own logic to handle events as they happen. 
Thus, the hub needs a workflow engine that can send messages, process data, and interact with the database in real-time.

{{< figure
width="70%"
alt="Diagram showing ISA-95 data model"
src="/images/arch/diagram-rhize-bpmn-eda.png"
>}}

The data hub also must be agnostic about the information it receives, so the event handler must have a way to transform incoming events and represent them in the database schema.
Without such transformation, the burden of ISA-95 standardization falls on the event producer.
This is both inconvenient for the user and more fragile architecturally:
a second place where transformation can happen is also a second point of failure.
As long as the producer and consumer can accept and receive the same encoding (for example, JSON), the data hub should be responsible for enforcing standardization.

With components for data ingestion, processing, and standardized storage, the MDH has all the necessary functionality to serve as a knowledge graph, MES backend, and integrator of legacy systems.

## Sensible interfaces make it accessible

For many who work in industrial automation, IT is part of a job, not a job in itself.
So, a well-designed manufacturing data hub should provide high-quality abstractions,
with interfaces that minimize the need for thinking about IT systems instead of manufacturing ones.

GraphQL, with its single endpoint and precise controls, makes an ideal API interface for the MDH graph database. 
Queries resemble the structure of the data itself, requiring no recursive joins or intermediary object-relation models.
GraphQL also pairs perfectly with a data model based on ISA-95, whose object model has a graph structure, itself a model of the interconnected reality of real manufacturing.

While GraphQL provides the API to query and transform the data, it cannot execute logic.
So, the rules engine should also provide a graphical interface to make event handling as accessible as possible.

However, one final piece is missing: the system must be robust enough for the data-intensive world of manufacturing IT.


## Distributed execution provides robustness

The final factor is that the components of an MDH must run on distributed systems.
Large manufacturing operations can generate enormous volumes of data.
At some point, scaling vertically (with better hardware on single devices) is impossible.
Besides size constraints, single devices also create single points of failure.

So, an MDH must scale horizontally, where different nodes share computation responsibilities,
and extra volumes add data replication.

## Read more

Our blog has some articles that define what a data hub is:

- [What is a Manufacturing Data Hub?](https://rhize.com/blog/what-is-a-manufacturing-data-hub/)
- [Data hub vs. Data lake: the difference for manufacturers](https://rhize.com/blog/manufacturing-data-hub-vs-data-lake/)

