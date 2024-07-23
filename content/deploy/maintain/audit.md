---
title: 'Archive the PostgreSQL Audit trail'
date: '2024-03-26T11:20:56-03:00'
categories: ["how-to"]
description: How to archive a partition of the Audit trail on your Rhize deployment
weight: 100
menu:
  main:
    parent: maintain
    identifier:
---

The [audit trial]({{< relref "/how-to/audit" >}}) can generate a high volume of data, so it is a good practice to periodically _archive_ portions of it.
An archive separates a portion of the data from the database and keeps it for long-term storage. This process involves the use of PostgreSQL [Table Partitions](https://www.postgresql.org/docs/current/ddl-partitioning.html).

Archiving a partition improves query speed for current data, while providing a cost-effective way to store older.


## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-archives/libre-audit`.
- Access to the [Rhize Kubernetes Environment](/deploy/install/setup-kubernetes) {{% param pre_reqs %}}

Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

To archive the PostgreSQL Audit trail, follow these steps:

1. Record the `<PARTITION_NAME>` of the partition you wish to detach and archive.
   This is based on the retention-period query for the names of the existing partitions:

   ```bash
   kubectl exec -i audit-postgres-0 -- psql -h localhost \ 
     -d audit -U <DB_USER> \
     -c "select * from partman.show_partitions('public.audit_log')"
   ```

1. Detach the target partitions from the main table:

    ```bash

    kubectl exec -i audit-postgres-0 -- psql -h localhost \
      -d audit -U <DB_USER> \
      -c 'alter table audit_log detach partition <PARTITION_NAME>;'

    ```

1. Backup the partition table:

    ```bash
    pg_dump -U <DB_USER> -h audit-postgres-0 -p5433 \
      --file ./audit-p20240101.sql --table public.audit_log_p20240101 audit
    ```

   On success, the backup creates a GZIP file, `<PARITION_NAME>.sql`.
   To check that the backup succeeded, unzip the files and inspect the data.

1. Drop the partition table to remove it from the database:

    ```bash
    kubectl exec -i audit-postgres-0 -- psql -h localhost -d audit \
      -U <DB_USER> -c 'drop table <PARTITION_NAME>;'
    ```

## Next Steps

- For full backups or Rhize services, read how to back up:
  - [Keycloak]({{< relref "/deploy/backup/keycloak" >}})
  - [The Audit trail]({{< relref "/deploy/backup/audit" >}})
  - [Grafana]({{< relref "/deploy/backup/grafana" >}})
  - [The Graph Database]({{< relref "/deploy/backup/graphdb" >}})
