---
title: 'Activities'
date: '2023-09-26T11:10:37-03:00'
draft: false
category: reference
description: >-
  A reference of BPMN tasks available from the Rhize UI.
weight: 200
menu:
  main:
    parent: bpmn-reference
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


In BPMN, an _activity_ is work performed within a business process.

On the Rhize platform, most activities are _tasks_, work that cannot be broken down into smaller levels of detail.
Tasks are drawn with rectangles with rounded corners.
Besides tasks, you can also use _call activities_, processes which call and invoke other processes.

As with [Gateways]({{< ref "gateways" >}}) and [events]({{< ref "events" >}}), service and call activities types are marked by their icons.

## Service task templates

{{< figure
caption="<small><em>Service tasks have a gear icon marker</em></small>"
alt="An empty service task"
src="/images/bpmn/bpmn-service-task.svg"
width="100"
>}}

A service task uses some service.
In Rhize workflows, service tasks include HTTP calls (GraphQL and REST), database operations, and JSON manipulation.
These service tasks come with templates.

To add a service task, select the change icon ("wrench"), then select **Service Task**.
Use **Templates** to structure the service task call and response.

The service task templates are as follows:

### JSONata transform

Transform JSON data with a [JSONata expression](https://docs.jsonata.org/overview.html).


| Call parameters  | Description                           |
|------------------|---------------------------------------|
| Input            | Input data for the transform          |
| Transform        | Variables for the GraphQL query       |
| Max Payload size | {{< param boilerplate.max_payload >}} |


### GraphQL Query

Run a [GraphQL query](https://graphql.com/learn/the-query/)

| Call parameters    | Description                                  |
|--------------------|----------------------------------------------|
| Query body         | GraphQL query expression                     |
| Variables          | {{< param boilerplate.graph_vars >}}         |
| Connection Timeout | {{< param boilerplate.connection_timeout >}} |
| Max Payload size   | {{< param boilerplate.max_payload >}}        |

{{% param boilerplate.jsonata_response %}}

### GraphQL Mutation

Run a [GraphQL mutation](https://graphql.com/learn/mutations/)

| Call parameters    | description                                  |
|--------------------|----------------------------------------------|
| Mutation body      | GraphQL Mutation expression                  |
| Variables          | {{< param boilerplate.graph_vars >}}         |
| Connection Timeout | {{< param boilerplate.connection_timeout >}} |
| Max Payload size   | {{< param boilerplate.max_payload >}}        |

### Call REST API

HTTP call to a REST API service.

Description:

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


<!---
### JSON schema
  - `Query body`
  - `Variables`
  - `Connection Timeout`
  - `Max Payload size`
 -->

## Call activities

![Call activities have a task with an icon to expand](/images/bpmn/bpmn-call-activity.svg)

A _call activity_ invokes another process defined in your BPMN interface.
In this flow, the process that contains the call is the _parent_, and the process that is called is the _child_.

Besides the input and output variables, call activities have the following parameters:

| Parameters         | Description                                                           |
|--------------------|-----------------------------------------------------------------------|
| Called element     | The ID of the called process                                          |
| Output propagation | Whether to propagate the child output variables to the parent process |

