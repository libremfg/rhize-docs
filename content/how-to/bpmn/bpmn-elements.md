---
title: 'BMPN elements'
date: '2023-09-26T11:10:37-03:00'
draft: false
categories: [reference]
description: >-
  A reference of all BPMN elements used in the Rhize BPMN engine.
weight: 1000
menu:
  main:
    parent: howto-bpmn
boilerplate:
  jsonata_response: >-
    You can optionally add a [JSONata](https://docs.jsonata.org/1.7.0/overview) expression to filter results
  max_payload: >-
    Number. If the response length exceeds this number of characters, Rhize throws an error.
  connection_timeout: >-
    Number. Time in milliseconds to establish a connection.
  graph_vars: >-
    JSON. Variables for the GraphQL query.
  data_id: >-
    The ID of the datasource
  data_expression: >-
    JSON or JSONata expression. Topics and values to write to
---

These pages describe the elements to make a Rhize {{< abbr "bpmn" >}} workflow, and their parameters to set conditions, use variables, and call services.

Rhize BPMN elements are based on the Business Process Model and Notation [OMG Standard](https://www.omg.org/spec/BPMN/2.0/).
While the visual grammar is functionally the same, we extend some elements for specific Rhize features, like service tasks that call the GraphQL API.

Each BPMN workflow is a _process_ with an ID.
Each process is made up _events_ (circles), _activities_ (rectangles), _gateways_ (diamonds), and _flows_ (arrows).


## Events

_Events_ are something that happen in the course of a process.
In BPMN, events are drawn with circles.

In event-driven models, events can happen in one of three _dimensions_:

- **Start.**
  All processes begin with some trigger that starts an event. Start events are drawn with a single thin circle.

- **Intermediate.**
  Possible events between the start and end. Intermediate events might start from some trigger, or create some result. They are drawn with a double thin line.

- **End.**
  All processes end with some result. End events are drawn with a single thick line.

![A simplified model of events with no activities](/images/bpmn/rhize-bpmn-events.png)

Besides these dimensions, BPMN also classifies events by whether they _catch_ a trigger or _throw_ a result.
All start events are catch events; that is, they react to some trigger.
All end events are throw events; that is, they terminate with some output&mdash;even an error.
Intermediate events may throw or catch.

Rhize supports various event types to categorize an event, as described in the following sections.
As with [Gateways](#gateways) and [Activities](#activities), event types are marked by their icons.
Throwing events are represented with icons that are filled in.

### Message

![A message event](/images/bpmn/bpmn-message-event.svg)

{{< notice "note" >}}
Message events follow MQTT topic syntax.
{{< /notice >}}

- Purpose: To denote a message being caught or thrown.
- Icon: An envelope
- Examples: A MQTT device publishes a message about a new sensor reading (starting a process). The ERP system sends a confirmation document (ending a process).
- Dimension: Start, intermediate, end


### Timer

![A timer event](/images/bpmn/bpmn-timer-event.svg)
- Purpose: An event after a certain amount of elapsed time or on a certain data
- Icon: A clock
- Examples: An hourly timer starts a process to check quality. An intermediate event starts after a twenty-minute fermentation process.
- Dimension: Start, intermediate

In Rhize, start timer events can be one of `Cycle`, to begin at recurring intervals, and `Date`, to happen at a certain time. An intermediate time event is always of `Duration`. 
All timer events are configured in the **Timer** parameter and in an [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.

### Error

![An error event](/images/bpmn/bpmn-error-event.svg)

- Purpose: An error occurred in the system
- Icon: A flash
- Example: A REST server returns a 500 error.
- Dimension: End




## Service tasks

In BPMN, an _activity_ is work performed within a business process.

On the Rhize platform, most activities are _tasks_, work that cannot be broken down into smaller levels of detail.
Tasks are drawn with rectangles with rounded corners.

{{< notice "note" >}}
Besides tasks, you can also use [_call activities_](#call-activities), processes which call and invoke other processes.
{{< /notice >}}

A service task uses some service.
In Rhize workflows, service tasks include [Calls to the GraphQL API]({{< relref "../gql/call-the-graphql-api" >}}) (and REST APIs), data source reads and writes, and JSON manipulation.
These service tasks come with templates.

As with [Gateways](#gateways) and [events](#events), service task are marked by their icons.


{{< figure
caption="<small><em>Service tasks have a gear icon marker</em></small>"
alt="An empty service task"
src="/images/bpmn/bpmn-service-task.svg"
width="100"
>}}


To add a service task, select the change icon ("wrench"), then select **Service Task**.
Use **Templates** to structure the service task call and response.

The service task templates are as follows

### JSONata transform

Transform JSON data with a [JSONata expression](https://docs.jsonata.org/overview.html).


| Call parameters  | Description                                                                   |
|------------------|-------------------------------------------------------------------------------|
| Input            | Input data for the transform                                                  |
| Transform        | [Variables for the GraphQL query]({{< relref "../gql/call-the-graphql-api#variables" >}}) |
| Max Payload size | {{< param boilerplate.max_payload >}}                                         |




### GraphQL Query

Run a [GraphQL query]({{< relref "../gql/query" >}})

| Call parameters    | Description                                  |
|--------------------|----------------------------------------------|
| Query body         | GraphQL query expression                     |
| Variables          | {{< param boilerplate.graph_vars >}}         |
| Connection Timeout | {{< param boilerplate.connection_timeout >}} |
| Max Payload size   | {{< param boilerplate.max_payload >}}        |

{{% param boilerplate.jsonata_response %}}

### GraphQL Mutation

Run a [GraphQL mutation]({{< relref "../gql/mutate" >}})

| Call parameters    | description                                  |
|--------------------|----------------------------------------------|
| Mutation body      | GraphQL Mutation expression                  |
| Variables          | {{< param boilerplate.graph_vars >}}         |
| Connection Timeout | {{< param boilerplate.connection_timeout >}} |
| Max Payload size   | {{< param boilerplate.max_payload >}}        |

### Call REST API

HTTP call to a REST API service.

| Call parameters    | Description                                                                        |
|--------------------|------------------------------------------------------------------------------------|
| Method Type        | One of `GET`, `POST`, `PATCH`, `PUT`, `DELETE`                                     |
| Verification       | Boolean. Whether verify the Certificate Authority provided in the TLS certificate. |
| URL                | The target URL                                                                     |
| URL Parameters     | JSON. The key-value pairs to be used as query parameters in the URL                |
| HTTP Headers       | JSON. The key-value pairs to be used as request headers                            |
| Connection Timeout | {{% param boilerplate.connection_timeout %}}                                       |
| Max Payload size   | {{< param boilerplate.max_payload >}}                                              |

{{% param boilerplate.jsonata_response %}}

### Read Datasource

Read values from topics of a datasource (for example, an OPC-UA server)

| Call parameters  | Description                               |
|------------------|-------------------------------------------|
| Data source      | {{< param boilerplate.data_id >}}         |
| Data             | {{< param boilerplate.data_expression >}} |
| Max Payload size | {{< param boilerplate.max_payload >}}     |

### Write Datasource

Write values to topics of a datasource.

| Call parameters  | Description                               |
|------------------|-------------------------------------------|
| Data source      | {{< param boilerplate.data_id >}}         |
| Data             | {{< param boilerplate.data_expression >}} |
| Max Payload size | {{< param boilerplate.max_payload >}}     |

## Call activities

![Call activities have a task with an icon to expand](/images/bpmn/bpmn-call-activity.svg)

A _call activity_ invokes another workflow.
In this flow, the process that contains the call is the _parent_, and the process that is called is the _child_.

Besides the input and output variables, call activities have the following parameters:

| Parameters         | Description                                                           |
|--------------------|-----------------------------------------------------------------------|
| Called element     | The ID of the called process                                          |
| Output propagation | Whether to propagate the child output variables to the parent process |

## Gateways

_Gateways_ control how sequence flows interact as they converge and diverge within a process.
They represent mechanisms that either allow or disallow a passage.

BPMN notation represents gateways as diamonds with single thin lines, as is common in many diagrams with decision flows.
Besides decisions, however, Rhize's BPMN notation also includes parallel gateways.

As with [Events](#events) and [Activities](#activities), gateway types are marked by their icons.

{{< figure
alt="Gateway with two branches"
caption="<small><em>Drawn as diamonds, gateways represent branches in a sequence flow.</em></small>"
src="/images/bpmn/bpmn-gateway-overview.svg"
>}}

### Exclusive gateway

![exclusive gateways are marked by an "x" icon](/images/bpmn/bpmn-gateway-exclusive.svg)

Marked by an "X" icon, an _exclusive gateway_ represents a point in a process where only one path is followed.
In some conversations, an exclusive gateway is also called an _XOR_.

If a gateway has multiple sequence flows, all flows except one must have a conditional [JSONata expression](https://docs.jsonata.org/1.7.0/overview) that the engine can evaluate.
To designate a default, leave one flow without an expression.

{{< figure
alt="An exclusive gateway that has a condition and a default"
src="/images/bpmn/rhize-bpmn-exclusive-gateway.png"
width="50%"
caption="<em>An exclusive gateway with a condition and default. Configure conditions as JSONata expressions</em>"
>}}

Exclusive gateways can only branch. That is, they cannot join multiple flows.

### Parallel gateway

![Parallel gateways are marked by a "+" icon](/images/bpmn/bpmn-gateway-parallel.svg)

Marked by a "+" icon, _parallel gateways_ indicate a point where parallel tasks are run.

{{< figure
alt="A parallel gateway that branches and rejoins"
src="/images/bpmn/screenshot-rhize-bpmn-parallel-gateway.png"
width="50%"
caption="<em>Parallel gateways run jobs in parallel.</em>"
>}}

{{% expandable title="Parallel joins" %}}

You can join parallel tasks with another parallel gateway.
This joins the variables from both branches to [process variable context](#process-variable-context).
Note that parallel joins have performance costs, so be mindful of using them, especially in large tasks.
To learn more, read [Tune BPMN performance]({{< relref "tune-performance" >}}).

{{< figure
alt="A parallel gateway that branches and rejoins"
src="/images/bpmn/screenshot-rhize-bpmn-parallel-join.png"
width="50%"
caption="<em>Parallel joins join variable context, but have performance costs.</em>"
>}}

{{% /expandable %}}

## Variables and expressions

As data passes and transforms from one element to another, variables remain in the _process variable context_.
You can access these variables through JSONata expressions.

### Process variable context

_Process variable context_ refers to the set of the variables that exist within the context of an overall BPMN process.
Each node can access this process variable context through a JSONata expression, using the syntax documented in the following section.
By default, the process variable context has a maximum size of 1MB.
When an activity outputs data, the output is added to the process variable context.

When variable size gets large, you have multiple strategies to reduce its size.
For ideas, refer to [Tune BPMN performance]({{< relref "/how-to/bpmn/tune-performance" >}}).

### JSONata expression syntax

Besides service tasks, many of the preceding elements can have JSONata expressions.
For example, an exclusive gateway requires a JSONata expression for all but the default flow.

The expression has the following syntax:
- It must begin with an `=`
- If you reference a variable, you must prefix it with `$.`

    ```json
    = $.varName > 100
    ```
