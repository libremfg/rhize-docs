---
title: "BPMN execution recovery"
weight: 600
description: >-
  Rhize has a number of built-in methods to ensure that a BPMN workflow executes reliably.
categories: ["concepts"]
menu:
  main:
    parent: restore
---

[BPMN processes]({{< ref "bpmn" >}}) are one area where availability is critical, since the processes often have longer execution durations and many steps.

Through clustering and replication, BPMN execution continues in the event that a BPMN node suddenly fails (for example through a panic or loss of power). 
As long as the remaining BPMN nodes are not at already full processing capacity,
the Rhize system recovers and finishes execution.
This recovery is automatic, though users may experience an execution gap of up to 30s during the execution process.

## BPMN failure and recovery modes 

The details about how Rhize recovers from a halted process depend on the point of failure.

### BPMN node fails

If a BPMN container suddenly dies, the currently executing process times out after 30s.
As long as the node had not been running for [longer than 10 minutes](#bpmn-age-out),
NATS resends the message to another BPMN node

### NATS node unavailable

If the NATS node dies, recovery depends on your replication and backup strategy.

- If the stream has R3 replication or greater, a new NATS node picks up the process. No noticeable performance issues should occur.

- If the stream has no replication, everything is lost in the node. However, if you took a snapshot of a stream with `nats stream backup` before the node became unavailable, and the `WorkflowSpecifications` KV is the same at backup and restore sites, then you can use the `nats stream restore` command to replay the stream from when the backup was made.

To learn more, read the NATS topic on [Disaster recovery](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/disaster_recovery)

## All BPMN elements age out after ten minutes {#bpmn-age-out}

If an element in a BPMN workflow takes longer than 10 minutes, NATS ages the workflow out of the queue. The process continues, but if the pod executing the element dies or is interrupted, that workflow is permanently dropped.

This ten-minute execution limit should be sufficient for any element in a BPMN process.
Processes that take longer, such as cooling or fermentation periods, should be implemented as [BPMN event triggers]({{< relref "/reference/bpmn/events" >}}) or as polls that periodically check data sources between intervals of sleep.
