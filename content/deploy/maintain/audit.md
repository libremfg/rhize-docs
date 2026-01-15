---
title: 'Archive the Audit trail'
date: '2024-03-26T11:20:56-03:00'
categories: ["how-to"]
description: How to archive a partition of the Audit trail on your Rhize deployment
weight: 100
---

The [audit trail]({{< relref "../../how-to/audit" >}}) can generate a high volume of data, so it is a good practice to periodically _archive_ portions of it.
An archive separates a portion of the data from the database and keeps it for long-term storage. This process involves the use of detaching [QuestDB Partitions](https://questdb.com/docs/concepts/partitions/). Detached partitions can be added back in at a later date.

Archiving a partition improves query speed for current data, while providing a cost-effective way to store older data.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-archives/libre-audit`.
- Access to the [Rhize Kubernetes Environment]({{< relref "../install/setup-kubernetes" >}})

{{% param pre_reqs %}}

Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

To archive the Rhize Audit trail, follow these steps:

1. Access QuestDB admin console by port forwarding 9000 on the QuestDB service. Start by Identifying QuestDB Service using 
  
   ```bash
   $ kubectl get svc -n <namespace> | grep quest
   ```
  
1. Forward the QuestDB console service port locally using 
  
   ```bash
   $ kubectl port-forward service/<quest-service-name> 9000 -n <namespace>
   ```

1. Using the browser open http://localhost:9000 to the QuestDB console

1. Record the `<PARTITION_NAME>` of the partition you wish to detach and archive.
   This is based on the retention-period query for the names of the existing partitions. Execute the following query in the QuestDB console.

   ```sql
   SHOW PARTITIONS FROM audit_log;
   ```

    ![QuestDB Console Query - `SHOW PARITIONS FROM audit_log;`](./show-audit-log-partitions.png)

1. Detach the target partitions from the main table:

    ```sql
    ALTER TABLE audit_log
    DETACH PARTITION WHERE time < '<TIMESTAMP i.e. 2025-12-31T23:59:59.99999Z>';
    ```

    ![QuestDB Console Query -`ALTER TABLE audit_log DETACH PARITION WHERE time < '2025-12-31T23:59:59.99999Z'](./detach-parition.png)

    On success, the command renames the partitions in `/root/.questdb/db/audit_log*/<partition_name>` to `/root/.questdb/db/audit_log*/<partition_name>.detached`.
  
1. Move partitions out of QuestDB into cold storage:

    Identify the name of the partitions detached in the audit_log directory:

    ```bash
    $ kubectl exec -it questdb bash -c "ls /root/.questdb/db/audit_log*/*.detached -d -w 1"
    ```

    Example:
    ```bash
    $ kubectl exec -it questdb bash -c "ls /root/.questdb/db/audit_log*/*.detached -d -w 1"
    /root/.questdb/db/audit_log~9/2025-12-15.detached
    /root/.questdb/db/audit_log~9/2025-12-16.detached
    ...
    /root/.questdb/db/audit_log~9/2025-12-31.detached
    ```

1. For each partition copy it out of the pod:

    ```bash
    kubectl cp questdb:/root/.questdb/db/<audit log directory>/<detached partition>.detached
    ```

    Example:

    ```bash
    kubectl cp questdb:/root/.questdb/db/audit_log~9/2025-12-15.detached 2025-12-15.detached
    Successfully copied 78.8kB to .\2025-12-15.detached
    ```

1. Then the partition can be removed from QuestDB

    ```bash
    kubectl exec -it questdb rm -rf /root/.questdb/db/<audit log directory>/<detached partition>.detached
    ```

    Example:

    ```bash
    $ kubectl exec -it questdb bash -c "rm -rf /root/.questdb/db/audit_log~9/2025-12-15.detached"
    ```

    Repeat for any additional partitions.

## Next Steps

- For full backups or Rhize services, read how to back up:
  - [Keycloak]({{< relref "../backup/keycloak" >}})
  - [The Audit trail]({{< relref "../backup/audit" >}})
  - [Grafana]({{< relref "../backup/grafana" >}})
  - [The Graph Database]({{< relref "../backup/graphdb" >}})
