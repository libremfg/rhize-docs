---
title: 'Gateways'
date: '2023-09-26T11:10:37-03:00'
draft: draft
category: reference
description: >-
  BPMN tasks in the Rhize engine.
weight: 200
menu:
  main:
    parent: bpmn-reference
---


_Gateways_ control how sequence flows interact as they converge and diverge within a process.
They represent mechanisms that either allow or disallow a passage.

BPMN notation represents gateways as diamonds with single thin lines, as is common in many diagrams with decision flows.
Besides decisions, however, Rhize's BPMN notation also includes parellel gateways.

As with [Events]({{< ref "events" >}}) and [Activities]({{< ref "activities" >}}), gateway types are marked by their icons.

{{< figure
alt="Gateway with two branches"
caption="<small><em>Drawn as diamonds, gateways represent branches in a sequence flow.</em></small>"
src="/images/bpmn/bpmn-gateway-overview.svg"
>}}

### Exclusive gateway

![exclusive gateways are marked by an "x" icon](/images/bpmn/bpmn-gateway-exclusive.svg)

Marked by an "X" icon, an exclusive gateway represents a point in a process where only one path is followed.
In some conversations, exclusive gateways are also called "XORs".

If a gateway has multiple sequence flows, all flows except one must have a conditional expression that the engine can evaluate.
To designate a default, leave one flow without an expression.

### Parallel gateway

![Parallel gateways are marked by a "+" icon](/images/bpmn/bpmn-gateway-parallel.svg)

Marked by a "+" icon, parallel flows indicate a point where parallel tasks are run.

<!---
### Inclusive gateway
### Event-based gateway
### Complex gateway
 -->
