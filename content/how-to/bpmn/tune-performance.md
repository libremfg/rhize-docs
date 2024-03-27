---
title: 'Tune BPMN performance'
date: '2024-02-09T09:47:47-03:00'
categories: ["how-to"]
description: Tips to debug and improve the performance of your BPMN process
weight: 300
menu:
  main:
    parent: howto-bpmn
    identifier:
    name: Tune performance
---

This page documents some tips to debug [BPMN workflows]({{< relref "/how-to/bpmn/create-workflow" >}}) and improve their performance.

Manufacturing events can generate a vast amount of data.
And a BPMN workflow can have any number of logical flows and data transformations.
So an inefficient BPMN process can introduce performance degradations.

## Manage the process context size

{{< notice "note" >}}
The max size of the process variable context comes from the default max payload size of NATS Jetstreams.
To increase this size, change your NATS configuration.
{{< /notice >}}

By default, the size of the {{< abbr "process variable context" >}} is 1MB.
If the sum size of all variables exceeds this limit, the BPMN process fails to execute.

### Be mindful of variable output

Pay attention the overall size of your variables, especially when outputting to new variables.
For example, imagine an initial JSON payload, `data`, that is 600KB.
If a JSONata task slightly modifies and outputs it to a new variable, `data2`, the process variable context will exceed 1MB and the BPMN process will exit.

To work around this constraint, you can save memory by mutating variables.
That is, instead of outputting a new variable, you can output the transformed payload to the original variable name.

### Discard unneeded data from API responses

Additionally, in service tasks that call APIs, use the **Response Transform Expression** to minimize the returned data to only the necessary fields.
Rhize stores only the output of the expression, and discards the other part of the response. This is especially useful in service tasks that [Call a REST API](https://docs.rhize.com/how-to/bpmn/bpmn-elements/#call-rest-api), since you cannot precisely specify the fields in the response (as you can with a GraphQL query).

If you still struggle to find what objects create memory bottlenecks, use a tool to observe their footprint, as documented in the next section.

### Observe payload size

Each element in a BPMN workflow passes, evaluates, or transforms a JSON body.
Any unnecessary fields occupy unnecessary space in the {{< abbr "process variable context" >}}.
However, it's hard for a human to reason about the size of the inflight payload without a tool to provide measurements and context.

It's easier to find places to reduce the in-flight payload size if you can visualize its memory footprint. 
We recommend the [JSON site analyzer](https://www.debugbear.com/json-size-analyzer), which presents a flame graph of the memory used by the objects in a JSON data structure.


{{< figure
src="/how-to/bpmn/screenshot-rhize-flamegraph-json.png"
alt="A simplified diagram of Rhize's architecture"
width="70%"
caption="<em><small>The material lot object is dominating the size of this JSON payload. This a good place to start looking for optimizations.</small></em>"
>}}


## Look for inefficient execution logic

When you first write a workflow, you may use some logical flows slow down execution time.
If a process seems slow, look for these places to refactor performance.

### Avoid parallel joins

Running processes in [parallel]({{< relref "/how-to/bpmn/bpmn-elements#parallel-gateway" >}}) can increase the workflow's complexity.
Parallel joins in particular can also increase memory usage of the NATS service.

Where possible, prefer exclusive branching and sequential execution.
When a task requires concurrency, keep the amount of data processed and the complexity of the tasks to the minimum necessary.

### Check Wildcards in Message Start events

BPMN message start tasks can start on any topic or datasource, however the performance of these events can vary depending on their configuration.
If you have numerous message start tasks you may find that subscribing to an exact topic or limiting the subscription to a single wildcard will
dramatically reduce the performance impact.

### Avoid loops

A BPMN process can loop back to a previous task node to repeat execution.
This process can also increase execution time.
If a process with a loop is taking too long to execute, consider refactoring the loop to process the variables as a batch in JSONata tasks.

## Use the JSONata book extension

A BPMN process performs better when the JSONata transformations are precise.
A strategy to debug and minimize necessary computation is to break transformations into smaller steps.

If you use Visual Studio Code, consider the [`jsonata-language`](https://marketplace.visualstudio.com/items?itemName=bigbug.vscode-language-jsonata) extension.
Similar to a Jupyter notebook, the extension provides an interactive environment to write JSONata expressions and pass the output from one expression into the input of another.
Besides its benefit for monitoring performance, we have used it to incrementally build complex JSONata in a way that we can document and share (in the style of literate programming).

