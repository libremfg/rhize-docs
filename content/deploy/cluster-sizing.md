---
title: Cluster sizing
description: The recommended compute per pod
---

The [Rhize Install]({{< relref "install" >}}) includes many services that run in their own pod.
These services have different resource requirments.

When you install Rhize, follow these provisioning guidelines as the minimum compute needed for each service per pod.
 
| Service                         | Recommended number of pods | CPU cores per pod | Memory per pod | Disk per pod |
|---------------------------------|----------------------------|-------------------|----------------|--------------|
| `baas-zero`                     | 3                          | 2                 | 2              | 250GB        |
| `libre-core`                    | 3                          | 1                 | 2              | N/A          |
| `baas-alpha`                    | 3                          | 8                 | 16             | 500GB        |
| `libre-bpmn`                    | 3                          | 1                 | 2              | N/A          |
| `libre-ui`                      | 3                          | 0.25              | 0.25           | N/A          |
| `nats`                          | 3                          | 1                 | 2              | 200GB        |
| `router`                        | 3                          | 0.25              | 2              | N/A          |
| `keycloak`                      | 2                          | 1                 | 2              | N/A          |
| `keycloak-db`                   | 2                          | 1                 | 2              | 200GB        |
| `grafana`                       | 3                          | 0.5               | 2              | 50GB         |
| `agent`                         | 2                          | 1                 | 0.75           | N/A          |
| `prometheus-server`             | 1                          | 1                 | 2              | 1            |
| `prometheus-alertmanager`       | 1                          | 0.25              | 0.05           | 0.25         |
| `prometheus-kube-state-metrics` | 1                          | 0.25              | 0.05           | 0.25         |
| `prometheus-node`               | 4                          | 0.25              | 0.05           | NODE         |
| `loki`                          | 1                          | 1                 | 1              | 1            |
| `loki-logs`                     | 4                          | 0.25              | 0.1            | NODE         |
| `loki-canary`                   | 4                          | 0.25              | 0.1            | NODE         |
| `loki-gateway`                  | 1                          | 0.25              | 0.05           | 0.25         |
| `loki-grafana-operator`         | 1                          | 0.25              | 0.1            | 0.25         |
| `promtail`                      | 4                          | 0.25              | 0.2            | NODE         |
| `tempo-compactor`               | 1                          | 0.25              | 2              | 0.25         |
| `tempo-ingester`                | 3                          | 0.5               | 0.75           | 1.5          |
| `tempo-querier`                 | 1                          | 0.25              | 0.5            | 0.25         |
| `tempo-distributor`             | 1                          | 0.25              | 0.5            | 0.25         |
| `tempo-query-frontend`          | 1                          | 0.25              | 0.5            | 0.25         |
| `temp-memcache`                 | 1                          | 0.25              | 0.1            | 0.25         |
