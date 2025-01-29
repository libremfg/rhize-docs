---
title: 'Subscribe'
categories: ["how-to"]
description: A guide to using GraphQL to subscribe to changes in the database.
weight: 280
---

The operations for a `subscription` are similar to the operations for a [`query`]({{< relref "/how-to/gql/query" >}}).
But rather than providing information about the entire item, the purpose of subscriptions is to notify about real-time changes to a manufacturing resource.


{{< callout type="info" >}}

These operations correspond to the `SyncGet` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

{{< /callout >}}


This example query subscribes to changes in a specified set of `workResponses`, reporting only their `id` and effective end time.

```graphql

subscription GetWorkResponse($getWorkResponseId: String) {
    getWorkResponse(id: $getWorkResponseId){
      jobResponses {
      effectiveEnd
    }
  }
}
```

Try to minimize the payload for subscription operations.
Additionally, you need to subscribe only to changes that persist to the knowledge graph.
For general event handling, it's often better to use a [BPMN workflow]({{< relref "../bpmn" >}}) that subscribes to a NATS, MQTT, or OPC UA topic.
