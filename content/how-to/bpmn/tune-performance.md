---
title: 'Tune BPMN performance'
date: '2024-02-09T09:47:47-03:00'
categories: ["how-to"]
description: Tips debug and improve the performance of your BPMN process
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

## Avoid parallel gateways

Running processes in [parallel]({{< relref "/how-to/bpmn/bpmn-elements#parallel-gateway" >}}) can increase the workflow's complexity by an order of magnitude.
Parallel joins, in particular, can also increase memory usage of the NATS service.

Where possible, prefer exclusive branching and sequential execution.
When a task requires concurrency, keep the amount of data processed and the complexity of the tasks to the minimum necessary.

## Observe JSON size

Each element in a BPMN workflow is passing, evaluating, or transforming a JSON body.
If that body contains unnecessary fields, the workflow has inefficiencies.
However, its hard for a human to reason about the size of a JSON object without a tool to provide measurements and context.

Once you can visualize the memory footprint of a JSON body, it's easier to find places to optimize.
For this reason, it may help to reduce in-flight payload size by putting it in an analyzer.
For this purpose, we recommend the [JSON site analyzer](https://www.debugbear.com/json-size-analyzer), which presents a flame graph of the memory used by the objects in a JSON data structure.


{{< figure
src="/how-to/bpmn/screenshot-rhize-flamegraph-json.png"
alt="A simplified diagram of Rhize's architecture"
width="70%"
caption="<em><small>The material lot object is dominating the size of this JSON payload. This a good place to start looking for optimizations.</small></em>"
>}}

## Use the JSONata extension

JSONata transformations perform better when they are precise.
A strategy to debug and minimize necessary computation is to break transformations down into smaller steps.

If you use Visual Studio Code, consider the [`jsonata-language`](https://marketplace.visualstudio.com/items?itemName=bigbug.vscode-language-jsonata) extension.
Similar to a Jupyter notebook, the extension provides an interactive environment to write JSONata expressions and to pass the outputs from one expression into the input of another.
Besides its benefit for monitoring performance, we have used it to incrementally build complex JSONata in a way that we can  document and share (in the style of literate programming).

## Manage the process context size

{{< notice "note" >}}
The max size of the process variable context comes from the default max payload size of NATS Jetstreams.
To increase this size, change your NATS configuration.
{{< /notice >}}

By default, the size of the {{< abbr "process variable context" >}} is 1MB.
If the sum size of all variables exceeds this limit, the BPMN process exits.

Be mindful of the overall size of your variables, especially when outputting to new variables.
For example, imagine an initial JSON payload, `data`, that is 600MB.
If a JSONata task slightly modifies and outputs it to a new variable, `data2`, the process variable context will exceed 1000MB and the BPMN process will exit.

To work around this constraint, you can save memory by mutating variables.
That is, instead of outputting a new variable, you can output the transformed payload to the original variable name.
