---
title: "Overview: orchestrate processes"
categories: "how-to"
description: >
   An overview of how to use Rhize's custom BPMN engine and UI to orchestrate workflows.
weight: 10
aliases:
  - "/how-to/bpmn/orchestration-overview"
menu:
  main:
    parent: howto-bpmn
---

This guide provides a quick overview of the major features of the Rhize {{< abbr "BPMN">}} engine and interface, with links to detailed guides for specific topics.
For a reference of all BPMN elements and their parameters, refer to [BPMN elements]({{< relref "/how-to/bpmn/bpmn-elements" >}}).

The Rhize BPMN UI provides a graphical interface to transform and standardize data flows across systems.
Such _process orchestration_ has many uses for manufacturing.
For example, you can write a BPMN workflow to do any of the following:
- Automatically ingest data from ERP and SCADA systems, then transform and store the payloads in the standardized ISA-95 representation
- Coordinate tasks across various systems, creating a layer for different data and protocols to pass through
- Calculate derived values from the data that is exchanged to perform functions such as waste calculation and process control.


{{< bigFigure
src="/images/bpmn/rhize-bpmn-coordination-between-multiple-systems.png.webp"
alt="An example of a workflow that transforms, calculates, stores, and sends to external systems"
width="70%"
>}}


{{< notice "note" >}}
Rhize BPMN workflows conform to the visual grammar described in the OMG standard for [Business Process Model and Notation](https://www.omg.org/spec/BPMN/2.0/).
Each process is made of _events_ (circles), _activities_ (rectangles), _gateways_ (diamonds), and _flows_ (arrows).
Some elements are extended for Rhize-specific features, such as service tasks that call the GraphQL API.
Some elements from the standard are unused and thus do not appear in the UI.
{{< /notice  >}}

## Request and send data

Workflows often exchange data between Rhize and one or more external systems.
The BPMN activity _task templates_ provide multiple ways to communicate with internal and external systems,
and pass data over different protocols.
Additionally, _message_ events provide templates to publish and subscribe to the Rhize broker.

Each template has a set of parameters to configure it.
**To use a template**:
1. Select the _activity_ (rectangle) element.
1. Select **Template** and then choose the template you want.
1. Configure the template according to its [Task parameters]({{< relref "/how-to/bpmn/bpmn-elements#jsonata-transform" >}}).

### Interact with the Rhize API

Use GraphQL tasks to query and change data in your manufacturing knowledge graph.
For example:
- A scheduling workflow could use the [Query task]({{< relref "/how-to/bpmn/bpmn-elements/#graphql-query" >}})  to find all `JobResponses` whose state is `COMPLETED`.
- An ingestion workflow might use a [Mutation task]({{< relref "/how-to/bpmn/bpmn-elements/#graphql-mutation" >}}) to update new `jobResponse` data that was published from a SCADA system. 

You can also use [JSONata]({{< relref "/how-to/bpmn/bpmn-elements#jsonata-transform" >}}) in your GraphQL payloads to dynamically add values at runtime.
For details about how to use the Rhize API, read the [Guide to GraphQL]({{< relref "/how-to/gql" >}}).

### Interact with external systems

To make HTTP requests to external systems, use the [REST task]({{< relref "/how-to/bpmn/bpmn-elements#call-rest-api" >}}).
For example, you might send a `POST` with performance values to an ERP system, or use a `GET` operation to query test results.

{{< notice "note" >}}
Besides REST, you can use this template to interact with any HTTP API.
{{< /notice >}}

### Publish and subscribe

Besides HTTP, workflows can also publish and subscribe messages over MQTT, NATS, and OPC UA.

{{< bigFigure
alt="A workflow that listens to a message and throws a message"
src="/images/bpmn/rhize-bpmn-message-start-throw-conditional.png"
caption="A workflow that evaluates a message and throws a if the payload meets a certain condition message"
width="60%"
>}}

**To publish and subscribe to the Rhize broker:**
1. Select a start (thin circle) or intermediate (double-line) circle.
1. Select the wrench icon.
1. Select the message event (circle with an envelope).
1. Configure the message topic and body according to the [Event parameters]({{< relref "/how-to/bpmn/bpmn-elements/#events" >}}).
1. If using an [Intermediate throw event]({{< relref "/how-to/bpmn/bpmn-elements#service-tasks" >}}), name the variable `BODY`.

**To listen and publish to an edge device:**
1. [Create a data source]({{< relref "how-to/publish-subscribe/connect-datasource/" >}}).
1. In your workflow, select the task. And choose the **Data source** template.
1. Configure the [Data Source task parameters]({{< relref "/how-to/bpmn/bpmn-elements#service-tasks" >}}).

The strategy you choose to send and receive message data depends on your architectural setup. 
Generally, data-source messages come from level-1 and level-2 devices on the edge,
and messages published to the Rhize broker come from any NATS, MQTT, or OPC UA client.
The following diagram shows some common ways to interact with messages through BPMN.

{{< bigFigure
src="/images/bpmn/diagram-rhize-bpmn-control-message-flow.svg"
alt="Diagram providing decision of control flows"
width="50%"
>}}

## Transform and calculate

As the data in a workflow passes from start node to end node, it often undergoes some secondary processing.
Mew properties might be added, some data might be filtered, or a node might create a set of derived values from the original input.
For example, you might use calculate statistics, or transform a message payload into a format to be received by the Rhize API or an external system.


{{< bigFigure
src="/images/bpmn/screenshot-rhize-jsonata-map.png"
alt="Annotated and truncated version of an example transformation to the operationEvent definition"
caption="Annotated and truncated version of mapping an external event to the `operationEvent` definition"
width=" 70%"
>}}

To calculate and transform data, BPMN nodes can interpret the JSONata expression language.
For details, read the complete [Rhize guide to JSONata](/how-to/bpmn/use-jsonata).

## Trigger workflows

You have multiple ways to trigger a start condition.

{{% reusable/bpmn-triggers %}}

To learn more, read [Trigger workflows]({{< relref "how-to/bpmn/trigger-workflows" >}}).

## Reuse workflows

BPMN workflows are _composable_, where each element can be reused by others.
For example, you might create a workflow that calculates common statistics, or one that makes a specified call to an external system.
Using _call activities_ other workflows can reuse the workflow.


{{< bigFigure
alt="A call activity"
src="/images/bpmn/diagram-rhize-bpmn-call-activity.png"
width="55%"
caption="An example of a main workflow calling a function"
>}}

To reuse a workflow:
1. Drag the task element (rectangle) into the workflow.
1. Select the wrench icon.
1. Select **Call Activity**.
1. Configure it according to the [call activity parameters]({{< relref "/how-to/bpmn/bpmn-elements#call-activities" >}}).

## Examples
 
Rhize has a repository of templates that you can import and use in your system.
Use these to explore how the key functionality works.
[Rhize BPMN templates](https://github.com/libremfg/bpmn-templates)
 

