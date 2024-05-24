---
title: 'About process variable context'
date: '2023-09-26T11:10:37-03:00'
draft: false
categories: [concepts]
description: >-
  The nodes in a BPMN workflow can read and write from a set of variables.
  These variables are process variable context.
weight: 800
menu:
  main:
    parent: howto-bpmn
---

As data passes through the nodes of a workflow, the nodes share access to a variable space.
Nodes can access these variables, create new variables, and mutate existing ones.
This overall variable object is called _process variable context_.

## Access process variable context through `$`

The most common place to access variables in a JSONata express&mdash;either the JSONata task, or a parameter that accepts JSONata.
In keeping with the conventions of JSONata, you can access the root variable context through `$.`.
For details and examples, read the Rhize guide to [Use JSONata]({{< relref "how-to/bpmn/use-jsonata" >}}).

Objects within variable context are accesed with dot notation.
For example, the following is a reference to the first item in the `orders` object in the variable context:

```
$.orders[]
```

{{< notice "note" >}}
When accessing variables outside of designated transform tasks, don't forget to prefix the field with the `=`
{{< /notice >}}

## You can write output to variables

Many output fields offer a way to create a variable.
For example, the JSON schema field has two variables that you can name,
one that outputs a boolean based on whether the schema is valid, and another that outputs
the string if the variable is invalid.
You can access these variables in later nodes (unless you mutate them).

## Variables are mutable

That is, you can change the variable from one value to another.
This can be an effective strategy to manage the over all process variable context size.

## Default size

By default, the process variable context has a maximum size of 1MB.
When an activity outputs data, the output is added to the process variable context.
When variable size gets large, you have multiple strategies to reduce its size (besides mutating variables).
For ideas, refer to [Tune BPMN performance]({{< relref "/how-to/bpmn/tune-performance" >}}).

## Call activities

A special case for variable context happens when a workflow uses a 
[call activity]({{< relref "/how-to/bpmn/create-workflow/#reuse-workflows" >}}) to call another workflow.
In this case, the call activity node specifies what variables pass to the child node and what output variables from the child are passed back into the parent.

{{< bigFigure
alt="A call activity"
src="/images/bpmn/diagram-rhize-bpmn-call-activity.png"
width="55%"
caption="An example of a main workflow calling a function. [Template](https://github.com/libremfg/bpmn-templates/tree/main/call-activity-calculate-stats)"
>}}

## Trace variable context

Variable context can be accessed in a few ways:
- through `dataJSON` in a `createAndRunBpmnSync` operation.
- In Tempo. Refer to the [Debug guide]({{< relref "how-to/bpmn/debug-workflows" >}})
