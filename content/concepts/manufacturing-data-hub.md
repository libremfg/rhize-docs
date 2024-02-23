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

This article explains what a Manufacturing Data Hub is and why it must have these particular components to meet the needs of large, modern manufacturing environments.

In another phrasing, this article explains why Rhize made the choices it did to become the world's first manufacturing data hub.
However, the scope of this article is the design considerations that define an MDH in general.
For an introductory explanations about Rhize in particular, read [What is Rhize]({{< relref "/get-started/introduction" >}}) and [How Rhize works]({{< relref "/get-started/how-rhize-works" >}}). 

## What is an MDH?

A Manufacturing Data Hub is a system that collects all manufacturing events, stores them in a standard model, and has a programmable engine that can run user logic to receive, transform, and send messages across different devices in a manufacturing operation.

Thus, a manufacturing data hub is not only a storage or message system;
it is a coherent system of interelated parts and interfaces.
The components that make an MDH are:
- The schema-on-write graph database
- A data model that uses a manufacturing standard
- The agent that listens for messages
- The message broker that handles messages from publishers and to subscribers
- The rules engine that executes user workflows
- The API that exposes the database
- The IT infrastructure that this all runs on, which at certain scale must be clustered.

Rhize chose these parts deliberately, after careful consideration and years of experience running into constraints.
The following sections describe how this design arose out of the manufacturing IT landscape.


## Point-to-point reaches scaling issues

In early efforts to digitize manufacturing, information often flows from _point to point_.
In point-to-point networks, each node communicates directly with another.
For example, in point-to-point topology, a sensor communicates with a PLC, the PLC communicates with the MES, and the MES with the level-4 systems. 
Additionally, even within a specific level, devices and applications might be responsible for coordinating communication between each other.

![Diagram simplifying flows depicted in part 1 of ISA-95](/images/arch/diagram-rhize-l3-l4-information-flows.png)

While this form of communication is initially simple to implement, it also tightly couples services.
As the system scales, the complexity of point-to-point communication increases at a  non-linear rate. With each node, the system that becomes increasingly fragile and unobservable.
To maintain two connected services, an operator must control one channel of communication; for three services, three channels; for four services, six channels; soon complexity explodes.

## Pub/sub architecture decouples

After a point-to-point system becomes too difficult to maintain, the next evolution is to adopt a hub and spoke model.
In this topology, a central hub coordinates communication between nodes.
Some systems achieve this by polling. That is, each device sends a request to the hub at some interval to see if anything changed.

Considering the number of devices and volume of exchange in manufacturing, polling can become a very inefficient use of network bandwidth.
For this reason, the publish-subscribe pattern has become a popular way for manufacturers to decouple communication.
Event producers _publish_ topics to a message broker, and the message broker sends the event to consumers that _subscribe_ to the particular topic.

![Diagram showing event producers and subscribers in decoupled pub-sub communication](/images/arch/diagram-rhize-pubsub-hubspoke.png)


But simply setting up a message broker with publishers and subscribers is not enough.
The data must be stored, and data on its own provides no value.
What matters is the _event_ that drives the data and the surrounding context of the event that makes it meaningful.

Furthermore, even if data is surrounded by context, every integrated application will have its own structure and format. Without a system to standardize this incoming data, the database becomes a giant blob, not something that can be explored as a cohesive whole.

## ISA-95 and graph structures for cohesive contextualization

For a coherent data model and contextualization, all event data must be stored in a standardized schema.
Fortunately many bright minds in manufacturing have already collaborated to create a generic data model: ISA-95.


![Diagram showing ISA-95 data model](/images/arch/diagram-rhize-isa95-schema.png)


The ISA-95 standard provides a perfect source to create a data model.
And as it happens, its system of attributes and relations is inherently graph-like.
Thus a database that uses the ISA-95 schema brings built-in standardization for all events, and the graph structure provides the context.


Combined with pub-sub messaging, the hub now decouples devices and provides a standardized data model that makes the data from these devices visible as parts of a contextual whole.

However, this system still has major limitations:
- It lacks a programming engine to evaluate the data and add logical transformations
- The system needs to structure raw message data in its ISA-95 representation 

For to resolve both of these limitations, a Manufacturing Data Hub must also include a rules engine.

## The rules engine creates responsiveness

To bring true "ubiquitous automation" to manufacturing processes, a data model and database provide only half the solution.
Manufacturers need responsiveness, so that the system can handle events in real time.
Thus the hub needs to be programmable, so that users can write intermediary logic to handle events and conditionally publish messages back to subscribers.

![Diagram showing ISA-95 data model](/images/arch/diagram-rhize-bpmn-eda.png)

The data hub also must be agnostic about the information it receives, so the event handler must have a way to transform incoming events and represent them in the database schema.
Without such transformation, the hub shifts the burden of work onto the event producer.
This is both inconvenient for the user and more fragile architecturally:
a second place where transformation can happen is also a second point of failure.
As long as the producer and consumer can accept and receive the same encoding (for example, JSON), the data hub should hold the responsibility for enforcing standardization.

While the rules engine completes the data transformation part of the puzzle,
the MDH still misses an important component: its users.
The best MDH should be as accessible as possible to all stakeholders, not only programming experts. 

## Sensible interfaces make it accessible

For most operators in manufacturing, IT is part of a job, not a job in itself.
So, a well-designed manufacturing data hub should provide high-quality abstractions,
with interfaces that minimize the need for thinking about IT systems instead of manufacturing systems.

GraphQL, with its single endpoint and precise controls, makes an ideal API interface for the MDH graph database. 
Queries resemble the structure of the data itself, requiring no recursive joins or intermediary object-relation models.
GraphQL also pairs perfectly with a data model based on ISA-95, whose object model has a graph structure, itself a model on the interconnected reality of real manufacturing artifacts.

While GraphQL provides the API to query and transform the data, it cannot execute logic.
So the rules engine should also provide a graphical interface to make event handling as accessible as possible.

With a rules engine and API, manufacturers can now use the datahub as a backend to create any type of MES or MOM system.
However, MES and MOM applications are often mission-critical.
To protect the operation, the MDH must also support distributed execution.

## Distributed execution provides robustness

The final factor is that the components of an MDH must run on distributed systems.
Large manufacturing operations can generate enormous volumes of data.
At some point, scaling vertically, with better hardware on single devices, is impossible.
Besides size constraints, single devices also creates single points of failure

So the system must scale horizontally, where different nodes share computation responsibilities,
and extra volumes add data replication.

## Read more

Our blog has some articles that define what a data hub is:

- [What is a Manufacturing Data Hub?](https://rhize.com/blog/what-is-a-manufacturing-data-hub/)
- [Data hub vs. Data lake: the difference for manufacturers](https://rhize.com/blog/manufacturing-data-hub-vs-data-lake/)

