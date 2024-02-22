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

Be mindful of the overall size of your variables, especially when outputting to new variables.
For example, imagine an initial JSON payload, `data`, that is 600MB.
If a JSONata task slightly modifies and outputs it to a new variable, `data2`, the process variable context will exceed 1MB and the BPMN process will exit.

To work around this constraint, you can save memory by mutating variables.
That is, instead of outputting a new variable, you can output the transformed payload to the original variable name.

## Avoid parallel joins

Running processes in [parallel]({{< relref "/how-to/bpmn/bpmn-elements#parallel-gateway" >}}) can increase the workflow's complexity.
Parallel joins in particular can also increase memory usage of the NATS service.

Where possible, prefer exclusive branching and sequential execution.
When a task requires concurrency, keep the amount of data processed and the complexity of the tasks to the minimum necessary.

## Observe JSON size

Each element in a BPMN workflow passes, evaluates, or transforms a JSON body.
Any unnecessary fields occupy unneccessary space in the {{< abbr "process variable context" >}}.
However, its hard for a human to reason about the size of the inflight payload without a tool to provide measurements and context.

It's easier to find places to reduce the in-flight payload size if you can visualize its memory footprint. 
We recommend the [JSON site analyzer](https://www.debugbear.com/json-size-analyzer), which presents a flame graph of the memory used by the objects in a JSON data structure.


{{< figure
src="/how-to/bpmn/screenshot-rhize-flamegraph-json.png"
alt="A simplified diagram of Rhize's architecture"
width="70%"
caption="<em><small>The material lot object is dominating the size of this JSON payload. This a good place to start looking for optimizations.</small></em>"
>}}

## Use the JSONata book extension

A BPMN process performs better when the JSONata transformations are precise.
A strategy to debug and minimize necessary computation is to break transformations into smaller steps.

If you use Visual Studio Code, consider the [`jsonata-language`](https://marketplace.visualstudio.com/items?itemName=bigbug.vscode-language-jsonata) extension.
Similar to a Jupyter notebook, the extension provides an interactive environment to write JSONata expressions and pass the output from one expression into the input of another.
Besides its benefit for monitoring performance, we have used it to incrementally build complex JSONata in a way that we can document and share (in the style of literate programming).

