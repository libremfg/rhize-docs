---
title: 'Turn values into events'
date: '2024-03-05T19:10:43-03:00'
draft: true
categories: ["how-to"]
description: Use the Rhize rules engine to turn a value from a data source into an event for orchestration
weight: 200
menu:
  main:
    parent: howto-pubsub
    identifier:
---

A {{< abbr "data source" >}}  can emit a high volume of data,
but not all this data is useful.
To filter for significant events, use the _rules engine_ to write rules to that trigger workflows when conditions are met.

The rules engine evaluates incoming values from a data source and converts significant changes into _events_ to be processed by a {{< abbr "bpmn" >}} workflow.
Each rule exists on the level of the {{< abbr "equipment class" ->}}.
Each rule evaluates changes that happen to a set of specified properties for a data source.
If the condition evaluates to `true`, the engine throws a trigger to start a workflow.
You can also use the message payload to create variables for the workflow to use.


```mermaid
---
title: Rules trigger workflows from data-source changes
---
flowchart LR
    A(Property\nchanged?) -->|yes| B{"rule evaluates\nto true?"}
    B -->|no| C(do nothing)
    B -->|"yes\n(optional: pass variables)"| D(Run BPMN workflow)
```

## Prerequisites

To create a rule, you must first create the models and workflows that you want to associate with this rule.
The procedure is as follows:
1. [Create a data source]({{< ref "connect-datasource" >}}).
1. [Write a BPMN workflow]({{< relref "/how-to/bpmn/create-workflow/" >}}) that the rule triggers. You can edit or change this workflow later.
1. [Create models]({{< relref "../model" >}}) for the following associated objects:
    - A [{{< abbr "data source" >}}]({{< ref "master-definitions#data-source" >}})
    - An [{{< abbr "equipment" >}}]({{< ref "master-definitions#equipment" >}}) item bound to this data source
    - An [{{< abbr "equipment class" >}}]({{< ref "master-definitions#equipment-class" >}}) that this equipment belongs to

Once you you've created these objects, you can create a rule for the equipment class, as documented in the following section.

## Create a rule in the UI

In the Rhize UI, select the equipment class that you want to create a rule for.
Then follow these steps:

1. In the Equipment class, select the **Rules** tab.
1. In **Workflow specification**, select the BPMN workflow that will orchestrate processes based on the event.
1. In **Trigger properties**, add the data-source properties you want to build the rule on. If any of these properties change, the rule will evaluate them.
1. In **JSONata expression**, enter the JSONata expression that the rule evaluates. For help building expressions, select the **#** button to open the JSONata editor.
1. If needed, use the **Message payload** group to pass values from the message payload into the BPMN {{< abbr "process variable context" >}}. Enter the **Field name**, then write a JSONata expression to filter and transform it.
1. Enable the rule with the toggle.

Here is an example of how a rule might look:

{{< figure
alt="A screenshot of a configured rule, as described in subsequent paragraph"
src="../screenshot-rhize-rules-engine.png"
width="45%"
>}}

This rule, `High Speed`, triggers the workflow `PizzaLineNewOrder`.
Whenever the `speed` property of the message has a `current.value` that exceeds `100`,
Rhize starts the workflow, passing the value of `speed.current.value` into the BPMN's {{< abbr "process variable context" >}}.
