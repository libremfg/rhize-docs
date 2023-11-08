---
title: "NATS stream backups"
weight: 600
description: >-
  To help recover from pod failures, Rhize creates manual backups of the NATS message stores for some critical services.
categories: ["how-to"]
menu:
  main:
    parent: backup
---

To help recover from pod failures, Rhize creates manual backups of the [NATS message stores](https://docs.nats.io/nats-concepts/jetstream/streams) for some critical services.

## BPMN activity node backups

If a BPMN pod engine dies, NATS automatically replays any [BPMN activity]({{< relref "/reference/bpmn/activities" >}}) node that has lasted for ten minutes or fewer.
If a node process takes longer than 10 minutes, NATS ages it out of the queue.
The process continues, but if the pod dies or is interrupted, that node is permanently dropped.

This ten-minute limit was chose to provide ample time for any reasonable node process. Processes that take longer, such as cooling or fermentation periods, should be implemented as [BPMN event triggers]({{< relref "/reference/bpmn/events" >}}) or as polls that periodically check data sources between intervals of sleep.

## Read more

To learn about NATS recovery strategies, read the [Disaster Recovery](https://docs.nats.io/running-a-nats-service/nats_admin/jetstream_admin/disaster_recovery) topic from the official NATS documentation.
