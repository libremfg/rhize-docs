---
title: 'Trigger workflows'
date: '2024-04-24T19:35:09+03:00'
categories: ["how-to"]
description: How to Trigger Workflow
weight: 150
menu:
  main:
    parent: howto-bpmn
    identifier:
---


You also have multiple ways to start, or _trigger_, a BPMN workflow.
The best choice of trigger depends on the context of the event and the system that initiates the workflow.

{{% reusable/bpmn-triggers %}}

## Start a workflow from an API

When a workflow has the default start event, trigger it through an API call.
For example, an API trigger may originate from a custom frontend application or a developer's local machine.

Each call must specify the workflow ID as an [argument in the request body]({{< relref "/how-to/gql/call-the-graphql-api/#request-body" >}}).

### Synchronous and asynchronous API triggers

To start BPMN workflows, Rhize has two API operations:
- `createAndRunBPMNSync` starts a workflow and waits for the process to complete or abort (synchronous).
- `createAndRunBpmn` starts a workflow and does not wait for the response (asynchronous).

Use the synchronous operation if you want to receive information about the result of the workflow in the call response.
On the other hand, the asynchronous operation frees up the call system to do more work, no matter whether the workflow runs correctly.

Both operations have  similar call syntax.
For example, compare the syntax for these calls:

{{% tabs %}}
{{% tab "Synchronous" %}}
```gql
mutation sychronousCall{
  createAndRunBpmnSync(id: "API_demo_custom_response") {
    id
    jobState
    customResponse
  }
}

```
{{% /tab %}}

{{% tab "Async" %}}
```gql
mutation asyncCall{
  createAndRunBpmn(id: "API_demo_custom_response") {
    id
    jobState
    customResponse
  }
}
```
{{% /tab %}}
{{% /tabs %}}

The responses for these calls have two differences:
- For synchronous calls, the returned `JobState` should be a finished value (such as `COMPLETED` or `ABORTED`). Asynchronous calls likely return an in-progress status, such as `RUNNING`.
- Only the synchronous call receives data in the `customResponse`. For details, refer to the next section.

### `CustomResponse`

The `customResponse` is a special variable to return data in the response to clients that run `createAndRunBPMNSync` operations.

You can set the `customResponse` in any [element]({{< relref "/how-to/bpmn/bpmn-elements" >}}) that has an `Output` or `Input response` parameter.
It can use any data from the {{< abbr "process variable context" >}}, including variables added on the fly.

Functionally, only the last value of the `customResponse` is returned to the client that sent the response.
However, you can use conditional branches and different end nodes to add error handling.

For example, this workflow returns `Workflow ran correctly` if the call variables include the message `CORRECT` and an error message in all other cases.

<!-- vale off -->
{{< bigFigure
src="/images/bpmn/screenshot-rhize-bpmn-error-handling-custom-response.png"
alt="A BPMN workflow with customResponse in the output of the end node"
caption="Download this workflow from [BPMN templates](https://github.com/libremfg/bpmn-templates/)"
width="80%"
>}}
<!-- vale on -->

### Additional properties for workflow calls {#variables-versions}

API operations can also include parameters to add variables to the {{< abbr "process variable context" >}} and to specify a workflow version.

To add variables, use the `variables` input argument.
Note that the variables are accessible from their root object.
For example, a workflow would access the following string value at `$.input.message`:

```gql{
"variables": "{\"input\":{\"message\":\"CORRECT\"}}"
}
```

To specify a version, use the `version` property. For example, this input instructs Rhize to run version `3` of the `API_demoCallToRemoteAPI` workflow:

```json
{
  "createAndRunBpmnSyncId": "API_demoCallToRemoteAPI",
  "version": "3"
}
```


If the `version` property is empty, Rhize runs the active version of the workflow (if an active version exists). 
## Start from a message

The [message start event]({{< relref "/how-to/bpmn/bpmn-elements#message-start-event" >}}) subscribes to a topic on the Rhize broker.
Whenever a message is published to this topic, the workflow is triggered.
The Rhize broker can receive messages published over MQTT, NATS, and OPC UA.

For example, this workflow subscribes to the topic `material/stuff`.
Whenever a message is published to the topic, it evaluates whether the quantity is in the correct threshold.
If the quantity is correct, it uses the [mutation service task]({{< relref "/how-to/bpmn/bpmn-elements#graphql-mutation/" >}}) to add a material lot.
If incorrect, it sends an alert back to the broker.

<!-- vale off -->
{{% bigFigure 
alt="BPMN message start with conditional evaluation"
src="/images/bpmn/rhize-bpmn-message-start-throw-conditional.png"
width="65%"
caption="Download this workflow as a [BPMN template](https://github.com/libremfg/bpmn-templates/tree/main/msg-start-and-throw)."
 %}}
<!-- vale on -->

Note that, for a workflow to run from a message start event, the workflow **must be enabled.**

## Rule-based triggers

Rule-based triggers subscribe to tag changes from a data source and trigger when the rule change condition is met.
Typically, users choose this workflow trigger when they want to orchestrate processes originating from level-1 and level-2 systems.

To add a data source and create a rule based trigger, refer to [Turn values into events]({{< relref "how-to/publish-subscribe/turn-value-into-event" >}}).

## Timer triggers

Timer triggers run according to a configured time or interval.
For example, a timer trigger may start a workflow each day, or once at a certain time.

To use timer triggers, use the [timer start event]({{< relref "/how-to/bpmn/bpmn-elements#timer-start-event" >}}). As with message start events, the workflow **must be enabled** for it to run.

