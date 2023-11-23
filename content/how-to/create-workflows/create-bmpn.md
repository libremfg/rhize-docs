---
title: 'Create BPMN workflows'
date: '2023-09-22T14:50:39-03:00'
draft: false
categories: "how-to"
description: Create BPMN workflows to handle inputs, react to events, process data, and throw triggers.
weight: 300
menu:
  main:
    parent: howto-bpmn
    identifier:
---

This topic shows you how to use the BPMN UI to create event-driven workflows.

## Prerequisites

To create a workflow, you'll need:
- [An installed environment](/deploy/install)
- [Topics to publish and subscribe to]({{< relref "../publish-subscribe" >}})
- The ability to [call the GraphQL API]({{< relref "query" >}}) and understand JSON.



## General procedures

The following sections cover some particulars to use each element.
To view the full list of elements and everything you can configure, refer to the [BPMN elements]({{< relref "bpmn-elements" >}}).

1. Create a start event:
    1. Select a single thin circle (`Start`) and drag it your process space.
    1. If the process is subscribing to a topic, in the **Message > Name** field, add the topic you want to subscribe to. For example, `/orders/*/sap`.


1. Use tasks to process and filter data:

    | If you want to...                | Use this BPMN activity |
    |----------------------------------|------------------------|
    | Filter the contents of a message | [JSONata transform]({{< relref "bpmn-elements/#jsonata-transform" >}}").    |
    | Call the GraphQL API             | GraphQL [query]({{< relref "bpmn-elements/#graphql-query" >}}") or [mutation]({{< relref "bpmn-elements/#graphql-mutation" >}}")    |
    | Call another BPMN workflow       | [Call activity]({{< relref "bpmn-elements/#call-activity)" >}})      |

1. Create conditions with gateways:
    1. Draw flows from this gateway to the elements that represents conditional results.
    1. Create a JSONata expression in the flow to define the evaluation criteria.
    
    | If you want to...                | Use this Gateway |
    |----------------------------------|------------------------|
    | Add a conditional flow | [Exclusive gateway]({{< relref "bpmn-elements/#exclusive-gateway" >}}").    |
    | Run processes in parallel | [Parallel gateway]({{< relref "bpmn-elements/#parallel-gateway" >}}").    |



1. To run the workflow, toggle the **Enabled** switch.

## Examples

These workflows demonstrate the minimum work needed to create some useful process.

### Build an Alert

This workflow sends an alert if the oven temperature is greater than 400 degrees.
    <img
    src="/images/bpmn/screenshot-rhize-temp-alert-bpmn-example.png"
    alt="Full BPMN diagram for a temperature alert"
    width="60%"
    />


1. Create a message start event that subscribes to the correct topic (for example, `oven1/sensors/thermometer`).
1. Connect the start event to a task. For **Template**, choose `JSONata transform`.
1. In **JSONata transform expression**, write an expression to evaluate whether the temp exceeds 400 (for example: `readings.temp > 100`).
   Name the output variable `highTemp`.
1. Connect the JSONata task to an exclusive gateway.
1. Connect the gateway to an intermediate message event.
1. In the flow that connects the gateway and the intermediate message event, add this condition: `= $.highTemp`.

    <img
    src="/images/bpmn/screenshot-rhize-condition-jsonata-expression.png"
    alt="Screenshot of the JSONata condition syntax in a flow"
    width="20%"
    />


1. In the intermediate message event, add the topic to publish the alert to.

    In the **Inputs** field, add the message body. Use `BODY` for the local variable name and something like this for the **Variable assignment value**:

    ```json
    {"message":"Temperature exceeded 100 degrees"}
    ```

1. Add **End** events to the gateway and to the message event.



### Write quantities to the database

This workflow receives information from the ERP system about a new employee, extracts the values, then creates a new person in the database.
For simplicity, assume the order has only these properties:

<img
src="/images/bpmn/screenshot-rhize-bpmn-graphql.png"
alt="Full BPMN diagram for a GraphQL service task"
width="60%"
/>

```json
{
  "Name": "Jane Smith",
  "id": "206460711234-C27",
  "Personnel class": "Bakers",
}
```

1. Create a start event that subscribes to the correct topic, for example `orders`.
1. Connect the start event to a JSONATA task saves the input as a variable, $newEmployee.
1. Connect the JSONata task to a GraphQL service task.
1. Sends `$.NewEmployee` as the variables for GraphQL mutation, `AddPerson`.
1. Connect the GrapqhQL task to a gateway. Connect this gateway to an `Error` end event and a normal end event.
1. In the flow to the `Error`, add an evaluation for whether `$.Response.status` is 201.


### Invoke other BPMN workflows

For modularity, you can call workflows that you already defined.

1. First, from the BPMN menu, note the workflow you want to call.
1. Create a Call activity.
1. In **Called element**, enter the Process ID.

    <img
    alt="Screenshot of a BPMN process invoking a process called CallTask"
    src="/images/bpmn/screenshot-rhize-bpmn-called-task-.png"
    width="20%"
    />
