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
To view the full list of elements and their parameters, refer to [BPMN elements]({{< relref "bpmn-elements" >}}).

## Prerequisites

To create a workflow, you'll need:
- [An installed environment](/deploy/install)
- [Topics to publish and subscribe to]({{< relref "../publish-subscribe" >}})
- The ability to [call the GraphQL API]({{< relref "../gql" >}}) and understand JSON.


## General procedures

Every workflow is different, but the overall procedure usually works like this:

1. Create a start event:
    1. Select a single thin circle (`Start`) and drag it your process space.
    1. If the process is subscribing to a topic, in the **Message > Name** field, add the topic you want to subscribe to. For example, `/orders/*/sap`.


1. Use tasks to process and filter data:

    | If you want to...                | Use this BPMN activity |
    |----------------------------------|------------------------|
    | Filter the contents of a message | [JSONata transform]({{< relref "bpmn-elements/#jsonata-transform" >}}").    |
    | Call the GraphQL API             | GraphQL [query]({{< relref "bpmn-elements/#graphql-query" >}}") or [mutation]({{< relref "bpmn-elements/#graphql-mutation" >}}")    |
    | Call another BPMN workflow       | [Call activity]({{< relref "bpmn-elements/#call-activity)" >}})      |

1. Create [conditional flows]({{< relref "bpmn-elements/#exclusive-gateway" >}}) and [parallel processes]({{< relref "bpmn-elements/#parallel-gateway" >}}) with gateways. To establish a condition, write a JSONata expression in the arrow that leads to the conditional result.
1. To run the workflow, toggle the **Enabled** switch.

## Examples

These workflows demonstrate the minimum work needed to create some useful process.

### Build an Alert

This workflow publishes an alert if a reading from an oven sensor exceeds 100 degrees.
    <img
    src="/images/bpmn/screenshot-rhize-temp-alert-bpmn-example.png"
    alt="Full BPMN diagram for a temperature alert"
    width="60%"
    />


1. Create a message start event that subscribes to the correct topic (for example, `oven1/sensors/thermometer`).
1. Connect the start event to a task. For **Template**, choose `JSONata transform`.
1. In **JSONata transform expression**, write an expression to evaluate whether the temp exceeds 100 (for example: `readings.temp > 100`).
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



### Write ERP material definition to database

This workflow receives information from the ERP system about a new [material definition]({{< relref "../model/master-definitions#material-definition" >}}), extracts the values, then creates a new record in the database.

<img
src="/images/bpmn/screenshot-rhize-bpmn-graphql.png"
alt="Full BPMN diagram for a GraphQL service task"
width="60%"
/>

For simplicity, assume the order has only these properties:

```json
{
  "MaterialDefinition": [
    {
      "Definition_ID": "RM-8001276",
      "Description": ["Sugar small bags 20kg"]
    }
  ]
}
```

1. Create a start event that subscribes to the correct topic, for example `orders`.
1. Connect the start event to a JSONATA task.
1. In the **JSONata transform expression**, filter for only the fields you need, and map them to the field names accepted by the API:


    ```js
    $map($.MaterialDefinition, function($v) {
        {
            "id": $v.Definition_ID,
            "description": $v.Description
        }
    })
    ```

    Name the output variable `newMaterial`.

1. Connect the JSONata task to a GraphQL service task.
1. Send `$.newMaterial` as the variable for the GraphQL mutation `addMaterialDefinition`.
  In **Mutation body**, define the operation and fields to return.
  In **Variables,** add the values for the payload.

{{% tabs %}}
{{< tab "Mutation" >}}
```js
mutation newMaterial($input: [AddMaterialDefinitionInput!]!) {
  addMaterialDefinition(input: $input) {
    materialDefinition {
      iid
      id
      _createdOn
    }
  }
}
```
{{< /tab >}}
{{< tab "Variables" >}}
```json
{
  "input": $.newMaterial
}
```
{{< /tab >}}

{{% /tabs %}}

<br/>

Finish the workflow with some error handling based on the response:

1. Connect the GraphQL task to a gateway. Connect this gateway to two end events, one for error and one for success.
1. In the flow to the `Error`, add an evaluation for whether `$.Response.status` is 200.


### Invoke other BPMN workflows

For modularity, you can call workflows that you already defined.

1. First, from the BPMN menu, note the ID of the workflow that you want to call.
1. In your new workflow, create a Call activity.
1. In the **Called element** field, enter the Process ID. This example calls a process with an ID `tempAlert`:

    <img
    alt="Screenshot of a BPMN process invoking a process called CallTask"
    src="/images/bpmn/screenshot-rhize-bpmn-called-task-.png"
    width="20%"
    />
