---
title: 'Special variables'
categories: ["reference"]
description: Special variables used by Rhize BPMN workflows
weight:
menu:
  main:
    parent: howto-bpmn
    identifier:
---

Rhize designates some variable names for a special purpose in BPMN workflow.
This list these special variables is as follows:

| Variable         | Purpose                                                                                                                                                                                                                                                                                |
|------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `BODY`           | The name of the variable as **Input** in [Intermediate message throws]({{< relref "/how-to/bpmn/bpmn-elements.md#intermediate-message-events" >}}). The value of this variable is the payload sent to the Rhize message broker.                                                        |
| `customResponse` | A value to report at the end of a synchronous API call to trigger a workflow. On completion, the call reports whatever the value was in the `customResponse` field of the GraphQL response. For details, read [Trigger workflows]({{< relref "/how-to/bpmn/trigger-workflows.md" >}}). |
| `__traceDebug`   | If `true` at the start of the workflow, the BPMN workflow reports the variable context at each node as spans in Tempo.                                                                                                                                                                 |
