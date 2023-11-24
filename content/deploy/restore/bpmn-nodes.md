---
title: "BPMN execution recovery"
weight: 600
description: >-
  If a BPMN node suddenly fails, Rhize has a number of recovery methods to ensure that the workflow finishes executing.
categories: ["concepts"]
menu:
  main:
    parent: restore
---

[BPMN processes]("../how-to/create-workflows") often have longer execution durations and many steps.
If a BPMN node suddenly fails (for example through a panic or loss of power),
Rhize needs to ensure that the workflow completes.

To achieve high availability and resiliency, Rhize services run in [Kubernetes nodes](https://kubernetes.io/docs/concepts/architecture/nodes/), and the NATS message broker typically has [data replication](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/replication).
As long as the remaining BPMN nodes are not already at full processing capacity,
if a BPMN node fails while executing a process,
the Rhize system recovers and finishes the workflow.

This recovery is automatic, though users may experience an execution gap of up to 30 seconds.

## BPMN failure and recovery modes 

How Rhize recovers from a halted process depends on where the system failed.

### BPMN node failure

If a BPMN container suddenly fails, the process that was currently executing times out after 30 seconds.
As long as the node had not been running for [longer than 10 minutes](#bpmn-age-out),
NATS resends the message to another BPMN node and the process finishes.

### NATS node unavailable

If the NATS node fails, recovery depends on your replication and backup strategy.

- If the stream has R3 replication or greater, a new NATS node picks up the process. No noticeable performance issues should occur.

- If the stream has no replication, everything in the node is lost. However, if you took a snapshot of a stream with `nats stream backup` before the node became unavailable, and the `WorkflowSpecifications` KV is the same at backup and restore sites, then you can use the `nats stream restore` command to replay the stream from when the backup was made.

To learn more, read the NATS topic on [Disaster recovery](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/disaster_recovery).

## All BPMN elements age out after ten minutes {#bpmn-age-out}

If an element in a BPMN workflow takes longer than 10 minutes, NATS ages the workflow out of the queue. The process continues, but if the pod executing the element dies or is interrupted, that workflow is permanently dropped.

This ten-minute execution limit should be sufficient for any element in a BPMN process.
Processes that take longer, such as cooling or fermentation periods, should be implemented as [BPMN event triggers]({{< relref "/how-to/bpmn/bpmn-elements" >}}) or as polls that periodically check data sources between intervals of sleep.
