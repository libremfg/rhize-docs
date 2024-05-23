---
title: Handle errors and debug
date: '2024-04-24T19:35:09+03:00'
categories: ["how-to"]
description: Strategies to handle errors in your BPMN workflows, and ways to debug workflows when things don't work as expected.
weight: 350
menu:
  main:
    parent: howto-bpmn
    identifier:
---

Errors come in two categories: expected and unexpected.
The Rhize BPMN engine has ways to handle both.

A robust workflow is going to have built-in logic to anticipate errors.
For unexpected issues, every node in a workflow is _instrumented_, meaning it emits metrics and traces about its performance.
You can also use debug flags and variables to trace variable context as it transforms across the workflow.

## Strategies to handle errors

All error handling likely uses some conditional logic.
The workflow author anticipates the error and then writes some logic to conditionally handle it.
However, you have many ways to handle conditions. When deciding how to direct flows, consider both the context of the error and overall readability of your diagram.
This section describes some key strategies.

### Gateways

Use [exclusive gateways]({{< relref "/how-to/bpmn/bpmn-elements#gateways" >}}) for any type of error handling.
For example, you could evaluate that `bodyTemp` is within a normal range to complete the workflow
and otherwise stop execution with an end event.

### JSON schema validation

Validation can greatly limit the scope of possible errors.
To validate your JSON payloads, use the [JSON schema task]({{< relref "/how-to/bpmn/bpmn-elements#json-schema" >}}).

The JSON schema task outputs a boolean value that indicates whether the input conforms to the schema that you set.
You can then set a condition based on whether this `valid` variable is true, and create logic to handle errors accordingly.
For example, this schema requires that the input variables include a property `arr` whose
value  is an array of numbers.


```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Generated schema for Root",
  "type": "object",
  "properties": { "arr": { "type": "array", "items": { "type": "number" } } },
  "required": ["arr"]
}
```

In a production workflow, you might use this exact schema to validate the input for a function that calculates statistics (perhaps choosing a different variable name).


{{< bigFigure
src="/images/bpmn/screenshot-rhize-bpmn-json-schema.png"
alt="Screenshot of a conditional that branches when the JSON schema task receives invalid input."
caption="A conditional that branches when the JSON schema task receives invalid input. [Download the template](https://github.com/libremfg/bpmn-templates/tree/main/call-activity-calculate-stats)"
width="35%"
>}}




### JSONata conditions

Besides the logical gateway, it may make sense to use JSONata ternary expressions in one of the many parameters that accepts JSONata expressions.
For example, this expression creates one message body if `valid` is `true` and another if not:

```jsonata
=
{
  "message": $.valid ? "Schema is valid" : "Invalid schema" 
}
```

### Check JSONata output

If a field has no value, JSONata outputs nothing.
For example, the following expression outputs only `{"name": "Rhize"}`,
because no `$err` field exists.

{{< tabs >}}
{{% tab  "Expression" %}}
```json
=( 
  $name := "Rhize";


  { 
  "name": $name,
  "error": $err
  }
)
```
{{% /tab %}}
{{% tab  "Output" %}}
```
{
  "name": "Rhize"
}
```
{{% /tab %}}
{{% /tabs %}}

You can use this behavior to direct flows.
For example, an exclusive gateway may have a condition such as `$exists(err)` that flows into an error-handling condition.

### Define error boundary

The error boundary is an intermediate event that evaluates whether a task had an error.
To use an error boundary:
1. Attach an intermediate event to a task.
1. Select the wrench icon and choose the error boundary.
1. Attach an arrow to the event that directs flows if the node returns an error.

For example, this error boundary directs the control flow when a REST task returns an unexpected result.

{{< bigFigure
src="/images/bpmn/screenshot-rhize-bpmn-error-boundary.png"
alt="Screenshot of an error boundary that happens when a REST task returns a non-200 response."
caption="An error boundary that happens when a REST task returns a non-200 response."
width="35%"
>}}

### Create event logging

To persist error handling, you can set gateways that flow to mutation tasks that use the `addEvent` operation. 
The added event may be a successful operation, an error, or both,
creating a record of events emitted in the workflow that are stored in your manufacturing knowledge graph.
This strategy increases the observability of errors and facilitates future analysis.
It may also be useful when combined with the debugging strategies described in the next section.

## Strategies to debug

For detailed debugging,
you can use an embedded instance of [Grafana Tempo](https://github.com/grafana/tempo) to inspect each step of the workflow, node by node.
To debug on the fly, you may also find it useful to use `customResponse` and intermediate message throws to print variables and output at different checkpoints. 

### Debug from the API calls

When you first test or run a workflow, consider starting the testing and debugging process from an API trigger.
All API triggers return information about the workflow state (for example `COMPLETED` or `ABORTED`).
With the `createAndRunBpmnSync` operation, you can also use the `customResponse` to provide information from the workflow's variable context.
For details of how this works, read the guide to [triggering workflows]({{< relref "trigger-workflows" >}}).

For example, consider a workflow that has two nodes, a Message throw event and a REST task.
1. When the message completes, the user writes `Message sent` into `customResponse` as an output variable.
1. When the REST task completes, the response is saved into `customResponse`. 

So the `jobState` property reports on the overall workflow status, and `customResponse` serves as a checkpoint to report the state of each node execution.
Now imagine that the user has started the workflow from the API and receives this response:

```
{
  "data": {
    "createAndRunBpmnSync": {
      "jobState": "ABORTED",
      "customResponse": "message sent",
      "traceID": "993ee32af9522f5b35b4ec80f4ff58a8"
    }
  }
}
```


Note how `ABORTED` indicates the workflow failed somewhere.
Yet, the value of `customResponse` must have been set after the message event executed.
So the problem is likely with the REST node.

You could also use a similar strategy with intermediate message events.
However, while undoubtedly useful, these methods are also limited&mdash; the BPMN equivalents of `printf()` debugging.
For a full-featured debugging, use the `traceID` to explore the workflow through Tempo.


### Debug in Tempo

{{< notice "note" >}}
The instructions here provide the minimum about using Tempo as a tool.
To discover the many ways you can filter your BPMN traces for debugging and analysis,
refer to the [official documentation](https://grafana.com/docs/tempo/latest/).
{{< /notice >}}

Rhize creates a unique ID for each workflow that runs.
This ID is reported as the `traceID` in the `createAndRunBPMN` mutation operation.
Use this ID to debug the workflow in Tempo.

To inspect a workflow in Tempo:
1. Go to your Grafana instance.
2. Select **Explore** and then Tempo.
3. From the **TraceQL** tab, enter the `traceID` and query.
Alternatively, use the **Search** tab with the `bpmn-engine` to find traces for all workflows.

{{< bigFigure
src="/images/bpmn/screenshot-rhize-bpmn-spans-in-tempo-compact.png"
alt="Screenshot of a compact view of spans for a BPMN process in Tempo"
caption="Screenshot of a compact view of spans for a BPMN process in Tempo"
width="55%"
>}}


Each workflow instance displays _spans_ that trace the state of each node at its start, execution, and end states.
When debugging, you are likely interested in the spans that result in `ABORTED`. 
To inspect the errors:
1. Select the nodes with errors.
1. Use the `events` property to inspect for exceptions.

For example, this REST task failed because the URL was invalid.

{{< bigFigure
src="/images/bpmn/screenshot-rhize-bpmn-spans-in-tempo-compact.png"
alt="Screenshot of a detailed view of an error for a BPMN process in Tempo"
caption="A detailed view of an error for a BPMN process in Tempo"
width="55%"
>}}

Also note the names of the spans in the previous two screenshots.
Names that convey semantic information it easier to find specific nodes and easier to understand and follow the overall workflow.
Well-named nodes make debugging easier.
This is one of the reasons we recommend always following a set of [naming conventions]({{< relref "naming-conventions" >}}) when you author BPMN workflows.

### Adding the debug flag

For granular debugging, it also helps to trace the variable context as it passes from node to node.
To facilitate this, Rhize provides a debugging option that you can pass in multiple ways:
- From an API call with the `debug:true` [argument]({{< relref "/how-to/gql/call-the-graphql-api/#request-body" >}}).
- In the process variable context, by setting `__traceDebug: true`
- In the [BPMN service configuration]({{< relref "/reference/service-config/bpmn-configuration/" >}}) by setting `OpenTelemetry.defaultDebug` to `true`

When the debugging variable is set, Tempo reports the entire variable context in the **Span Attributes** at the end of each node.

{{< bigFigure
src="/images/bpmn/screenshot-rhize-variable-spans.png"
alt="Screenshot showing the process variable context at the end of a node in a BPMN workflow."
caption="The process variable context at the end of a node in a BPMN workflow."
width="55%"
>}}
