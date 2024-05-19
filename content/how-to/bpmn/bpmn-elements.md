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
    Optional [JSONata](https://docs.jsonata.org/1.7.0/overview) expression to map to the [process variable context](#process-variable-context)
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
  headers: >-
    Additional headers to send in the request
---

This document describes the parameters available to each BPMN element in the Rhize UI.
These parameters control how users set conditions, transform data, access variables, call services, and so on.




## Common parameters


Every BPMN workflow and every element that the workflow contains have the following parameters:

| Parameter            | Description                                                                                                               |
|----------------------|---------------------------------------------------------------------------------------------------------------------------|
| ID                   | Mandatory unique ID. For guidance, follow the [BPMN naming conventions]({{< relref "/how-to/bpmn/naming-conventions" >}}). |
| Name                 | Optional human readable name. If empty, takes ID value.                                                                              |
| Documentation        | Optional freeform text for additional information                                                                                  |
| Extension properties | Optional metadata to add to workflow or node                                                                              |


## Events

_Events_ are something that happen in the course of a process.
In BPMN, events are drawn with circles.
Events have a _type_ and a _dimension_.
  
{{< tabs >}}
{{% tab "Events" %}}
![A simplified model of events with no activities](/images/bpmn/rhize-bpmn-events.png)
{{% /tab %}}
{{% tab "Message type" %}}
Message events subscribe or publish to the Rhize broker. <br/>
![A message event](/images/bpmn/bpmn-message-event.svg)
{{% /tab %}}

{{% tab "Timer type" %}}
Timer events start according to some interval or date, or wait for some duration. <br/>
![Timer event](/images/bpmn/bpmn-timer-event.svg  )
{{% /tab %}}
{{< /tabs >}}

In event-driven models, events can happen in one of three _dimensions_:

- **Start.**
  All processes begin with some trigger that starts an event. Start events are drawn with a single thin circle.

- **Intermediate.**
  Possible events between the start and end. Intermediate events might start from some trigger, or create some result. They are drawn with a double thin line.

- **End.**
  All processes end with some result. End events are drawn with a single thick line.




Besides these dimensions, BPMN also classifies events by whether they _catch_ a trigger or _throw_ a result.
All start events are catch events; that is, they react to some trigger.
All end events are throw events; that is, they terminate with some output&mdash;even an error.
Intermediate events may throw or catch.

Rhize supports various event types to categorize an event, as described in the following sections.
As with [Gateways](#gateways) and [Activities](#activities), event types are marked by their icons.
Throwing events are represented with icons that are filled in.



### Start events


Start events are triggered by the `CreateAndRunBPMN` and `CreateAndRunBPMNSync` {{< abbr "mutation" >}} operations.
The parameters for a start event are as follows:

| Parameter | Description                                                                                                            |
|-----------|------------------------------------------------------------------------------------------------------------------------|
| Outputs   | Optional variables to add to the {{< abbr "process variable context" >}}. JSON or JSONata. |


### Message start events

Message events are triggered from a message published to the Rhize broker.
The parameters for a message event are as follows:

| Parameter | Description                                                                                       |
|-----------|---------------------------------------------------------------------------------------------------|
| Message   | The topic the message subscribes to on the Rhize Broker. The topic structure follows MQTT syntax. |
| Outputs   |  Optional variables to add to the {{< abbr "process variable context" >}}.  JSON or JSONata.      |

### Timer start events

Timer start events are triggered either at a specific date or recurring intervals.
The parameters for a timer start event are as follows:

| Parameter | Description                                                                                                                                                                                                                                                                                     |
|-----------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Timer     | One of <ul><li>`Cycle`, to begin at recurring intervals. For example,`R5/2024-05-09T08:12:55/PT10S` starts on `2024-05-09` and executes every 10 seconds for 5 repetitions. If `<START_DATE>` is not set, Rhize uses `2023-01-01T00:00:00Z`.</li> <li> `Date`, to happen at a certain time, for example, `2024-05-09T08:12:55`</li></ul> Enter values in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format. |
| Outputs   | Optional variables to add to the {{< abbr "process variable context" >}}. JSON or JSONata.                                                                                                                                                                                                      |

### Intermediate message events

Intermediate message events throw a message to the Rhize NATS broker.
This may provide info for a subscribing third-party client, or initiate another BPMN workflow.

The parameters for an intermediate message event are as follows:

| Parameter | Description                                                                                                            |
|-----------|------------------------------------------------------------------------------------------------------------------------|
| Message   | The topic the message publishes to on the Rhize Broker. The topic structure follows MQTT syntax                        |
| Inputs    | Variables to name and filter. For example, they may come from a preceding JSONata element.                             |
| Headers   | {{< param boilerplate.headers >}} |
| Outputs | JSON or JSONata. Optional variables to add to the {{< abbr "process variable context" >}}.                                                                                                   |

### Intermediate timer events

An intermediate message pauses for some duration.
The parameters for an intermediate timer event are as follows:

| Parameter | Description                                                                                                            |
|-----------|------------------------------------------------------------------------------------------------------------------------|
| Timer| A duration to pause. Enter values in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.|
| Outputs   | Optional variables to add to the {{< abbr "process variable context" >}}. The assignment value can be JSON or JSONata. |


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
| Transform        | The transform expression  |
| Max Payload size | {{< param boilerplate.max_payload >}}                                         |


Besides the call parameters, the JSONata task has following additional fields:

| Parameter      | Description                                                                                                                                                                       |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Input response | The name of the variable to add to the {{< abbr "process variable context" >}}|


### GraphQL Query

Run a [GraphQL query]({{< relref "../gql/query" >}})

| Call parameters    | Description                                  |
|--------------------|----------------------------------------------|
| Query body         | GraphQL query expression                     |
| Variables          | {{< param boilerplate.graph_vars >}}         |
| Connection Timeout | {{< param boilerplate.connection_timeout >}} |
| Max Payload size   | {{< param boilerplate.max_payload >}}        |

Besides the call parameters, the Query task has following additional fields:

| Parameter      | Description                                                                                                                                                                       |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Input response | {{% param boilerplate.jsonata_response %}}. For GraphQL operations, use this only to map values. Rely on [GQL filters]({{< relref "/how-to/gql/filter" >}}) to limit the payload. |
| Headers        | {{< param boilerplate.headers >}}                                                                                                                                                 |

### GraphQL Mutation

Run a [GraphQL mutation]({{< relref "../gql/mutate" >}})

| Call parameters    | description                                  |
|--------------------|----------------------------------------------|
| Mutation body      | GraphQL Mutation expression                  |
| Variables          | {{< param boilerplate.graph_vars >}}         |
| Connection Timeout | {{< param boilerplate.connection_timeout >}} |
| Max Payload size   | {{< param boilerplate.max_payload >}}        |

Besides the call parameters, the mutation task has following additional fields:

| Parameter      | Description                                                                                                                                                                       |
|----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Input response | {{% param boilerplate.jsonata_response %}}. For mutations, use this only to map values. Use the mutation call to limit the payload. |
| Headers   | {{% param boilerplate.headers %}} |

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

Besides the call parameters, the REST task has following additional fields:

| Parameter      | Description                                |
|----------------|--------------------------------------------|
| Input response | {{% param boilerplate.jsonata_response %}} |
| Headers        | {{% param boilerplate.headers %}}                                           |

### Read Datasource

Read values from topics of a datasource (for example, an OPC-UA server)

| Call parameters  | Description                               |
|------------------|-------------------------------------------|
| Data source      | {{< param boilerplate.data_id >}}         |
| Data             | {{< param boilerplate.data_expression >}} |
| Max Payload size | {{< param boilerplate.max_payload >}}     |

Besides the call parameters, the data source task has following additional fields:

| Parameter      | Description                                                                    |
|----------------|--------------------------------------------------------------------------------|
| Input response | The variable name to store the response in {{< abbr "process variable context" >}} |
| Headers        | {{< param boilerplate.headers >}}                                              |

### Write Datasource

Write values to topics of a datasource.

| Call parameters  | Description                               |
|------------------|-------------------------------------------|
| Data source      | {{< param boilerplate.data_id >}}         |
| Data             | {{< param boilerplate.data_expression >}} |
| Max Payload size | {{< param boilerplate.max_payload >}}     |


Besides the call parameters, the data source task has following additional fields:

| Parameter      | Description                                                                    |
|----------------|--------------------------------------------------------------------------------|
| Input response | The variable name to store the response in {{< abbr "process variable context" >}} |
| Headers        | {{< param boilerplate.headers >}}                                              |


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

For each workflow, access the variable context through the `$` prefix.
Objects within the variable context are accessed through dot notation.
For example, the following is a reference to the `orders` object in the variable context:

```
$.orders
```

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

You can use a JSONata expression as any **Input JSON** field. 
However, you must prefix the JSON object with a `=`.
For example, consider these variables sent in a GraphQL mutation task.
With the `=`, the `quantity` and `id` properties are replaced by what is returned by their JSONata expression.
Without it, this just creates invalid JSON.

```json
={
  "input": [
    {
      "id": "new_stuff_" & $.id,
      "quantity": $.quantity,
      "quantityUoM": {
        "id": "grams"
      }
    }
  ]
}
```


