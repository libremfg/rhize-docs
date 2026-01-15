---
title: Recommended Kubernetes cluster sizing
description: The recommended number of nodes and compute per pod in your Rhize Kubernetes cluster
---

Rhize runs on Kubernetes.

This document provides compute recommendations for the nodes, pods services of your [Rhize Install]({{< relref "install" >}}).
Some services also have recommended replication factors to increase reliability.

## Node recommendations

The following tables are the minimum recommended sizes to provision your cluster for Rhize {{% param v %}}.

### Rhize nodes

For high availability,  Rhize recommends a **minimum of three nodes** with the following specifications.

| Property              | Value             |
|-----------------------|-------------------|
| Number of nodes       | 3                 |
| CPU Speed (GHz)       | 3.3               |
| vCPU per Node         | 16                |
| Memory per node (GiB) | 32 (64 is better) |
| Persisted Volumes     | 16                |
| Persisted Volume IOPS | 5000              |
| PV Throughput (MBps)  | 500               |
| Total Disk Space (TB) | 3                 |
| Disk IOPS             | 5000              |
| Disk MBps             | 500               |

### Rhize agent

The Rhize agent typically runs on the edge, outside of the cluster entirely.
For the Rhize Agent, the minimum recommended specifications are as follows:

| Property              | Value |
|-----------------------|-------|
| CPU Speed (GHz)       | 2.8   |
| vCPU per Node         | 2     |
| Memory per node (GiB) | 1     |
| Persisted Volumes     | 1     |

## Service-level recommendations

The following table lists the **minimum** recommended specifications for the main services.
Services with stateful PV have a persistent volume per pod.

>![Warn]
> Avoid NFS or SMB filesystems. These are known to lead to file corruption in BaaS and do not work at all with various other services.

| Service                | Pods for HA (replica count) | vCPU per Pod | Memory Per Pod | Stateful PV | DiskSize (GiB) | Comments                                                             |
|------------------------|-----------------------------|--------------|----------------|-------------|----------------|----------------------------------------------------------------------|
| `baas-alpha`           | 3                           | 8            | 16 (at least)  | Yes         | 750            | High throughput and IOPS                                             |
| `baas-zero`            | 3                           | 2            | 2              | Yes         | 300            | High throughput and IOPS                                             |
| `workflow`             | 3                           | 1            | 2              | No          | N/A            | HA requires 2 pods, but 3 is to avoid hotkey issues and balance load |
| `isa95`                | 1*                          | 1            | 1              | No          | N/A            | *ISA-95 does not support HA                                          |
| `keycloak-postgres`    | 2                           | 1            | 2              | No          | 200            | Runs in pod with `keycloak`                                          |
| `keycloak`             | 2                           | 1            | 2              | No          | N/A            |                                                                      |
| `libre-ui`             | 3                           | 0.25         | 0.25           | No          | N/A            |                                                                      |
| `quest-db`             | 1                           | 4            | 8              | Yes         | 250            | High Throughput and IPOS                                             |
| `redpanda`             | 3                           |              |                | Yes         | 100            | High IOPS                                                            |
| `restate`              | 3                           |              |                | Yes         | 50             | High Throughput and IPOS                                             |
| `appsmith`             | 3                           | 4            |                | Yes         | 50             | High Throughput and IPOS                                             |

### Monitoring stack

The following table provides minimal compute recommendations for the monitoring stack.

The default recommendation is to run your Rhize observability stack in the nodes that also run the Rhize application.
However, some deployments prefer to separate monitoring to its own cluster.

| Service                 | Pods for HA (replica count) | vCPU cores per pod | Memory per pod | DiskSize (GiB) |
|-------------------------|-----------------------------|--------------------|----------------|----------------|
| `grafana`               | 3                           | 0.5                | 2              | 50GB           |
| `prometheus-node`       | 4                           | 0.25               | 0.05           | N/A            |
| `prometheus-server`     | 1 per pod                   | 1                  | 2              | 1              |
| `promtail`              | 4                           | 0.25               | 0.2            | N/A            |
| `loki`                  | 1                           | 1                  | 1              | 1              |
| `loki-logs`             | 1 per pod                   | 0.25               | 0.1            | N/A            |
| `loki-canary`           | 4                           | 0.25               | 0.1            | N/A            |
| `loki-gateway`          | 1                           | 0.25               | 0.05           | 0.25           |
| `loki-grafana-operator` | 1                           | 0.25               | 0.1            | 0.25           |
| `tempo-compactor`       | 1                           | 0.25               | 2              | 0.25           |
| `tempo-ingester`        | 3                           | 0.5                | 0.75           | 1.5            |
| `tempo-querier`         | 1                           | 0.25               | 0.5            | 0.25           |
| `tempo-distributor`     | 1                           | 0.25               | 0.5            | 0.25           |
| `tempo-query-frontend`  | 1                           | 0.25               | 0.5            | 0.25           |
| `temp-memcache`         | 1                           | 0.25               | 0.1            | 0.25           |

## Back up

You can [back up Rhize to S3](/deploy/backup/binary/) .
Consider including an S3 bucket as part of your deployment.

