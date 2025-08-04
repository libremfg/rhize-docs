---
title: 'Restore Audit backup'
date: '2024-03-26T11:20:56-03:00'
categories: ["how-to"]
description: How to restore the backup of the Audit PostgreSQL on your Rhize deployment
weight: 300
---

This guide shows you the procedure to restore your Audit PostgreSQL database in your Rhize Kubernetes deployment.

## Prerequisites

Before you start, ensure you have the following:

- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- An [Audit PostgreSQL backup]({{< relref "../backup/audit" >}})

Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

To restore Audit PostgreSQL, follow these steps:

## Steps

1. Confirm the cluster and namespace are correct:

    {{% param "k8s_cluster_ns" %}}

1. Retrieve the Audit user password using the following command:

    ```bash
    kubectl get secret <SECRET-NAME> -o jsonpath="{.data.<SECRET-KEY>}" | base64 --decode
    ```

1. Extract your backup file:

    ```bash
    gzip -d audit-postgres-backup-YYYYMMDDTHHMMAA.sql
    ```

1. Restore the backup:
     
     ```bash
     cat audit-postgres-backup-YYYYMMDDTHHMMAA.sql | kubectl exec -i audit-postgres-0 -- psql postgresql://postgres:<DB_PASSWORD>@localhost:5432 -U <DB_USER_NAME>
     ```


## Next Steps

- Test the [Backup Audit]({{< relref "../backup/audit" >}}) procedure 
- Plan and execute a [Maintenance Strategy]({{< relref "../maintain/audit" >}}) to handle your audit data.
