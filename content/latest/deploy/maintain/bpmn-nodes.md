---
title: "BPMN execution recovery"
weight: 200
description: >-
  If a Workflow node suddenly fails, Rhize has a number of recovery methods to ensure that the workflow finishes executing.
categories: ["concepts"]
---

[{{< abbr "BPMN" >}} processes]({{< relref "../../how-to/bpmn" >}}) often have longer execution durations and many steps.
If a Workflow node suddenly fails (for example through a panic or loss of power),
Rhize needs to ensure that the workflow completes.

To achieve high availability and resiliency, Rhize services run in [Kubernetes nodes](https://kubernetes.io/docs/concepts/architecture/nodes/), and [Restate in high availability](https://docs.restate.dev/foundations/key-concepts#infrastructure-failures-e-g-server-crashes-vm-restarts).

As long as the remaining Workflow nodes are not already at full processing capacity,
if a Workflow node fails while executing a process,
the Rhize system recovers and finishes the BPMN execution.

This recovery is automatic, though users may experience an execution gap of up to a few seconds.

## BPMN failure and recovery modes 

How Rhize recovers from a halted process depends on where the system failed.

### Workflow node failure

If a Workflow container suddenly fails, the process that was currently executing times out after a few seconds.

Restate re-sends the message to another BPMN node and the process finishes.

### Restate node unavailable

The Restate Server can be deployed as a high-availability cluster, so if a node fails, others can take over without losing any execution state. If Restate is deployed as a single node, it can still recover from crashes by recovering from persistent disk.

If the Restate server crashes or restates any on-going executions are retried on new instances.

If a handler calls an API that times out, Restate will retry the run action with exponential backoff.

An idempotency key is added to Workflow Execution to ensure that, Restate will automatically ensure requests are deduplicated. Deduplicated requests will return the same result as the original request.

To learn more refer to [Restate documentation](https://docs.restate.dev/foundations/key-concepts#what-it-covers) for further details.
