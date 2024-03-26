---
title: 'Maintain Audit PostgreSQL'
date: '2024-03-26T11:20:56-03:00'
categories: ["how-to"]
description: How to maintain Audit PostgreSQL on your Rhize deployment
weight: 300
menu:
  main:
    parent: maintain
    identifier:
---

This guide shows you the procedure to maintain your Audit Postgres database on your Rhize Kubernetes deployment.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/libre-audit`.
- Access to the [Rhize Kubernetes Environment](/deploy/install/setup-kubernetes)
{{% param pre_reqs %}}


Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

Maintaining Audit PostgreSQL involves two steps:

1. Detach target partitions from main table

```bash
kubectl exec -i audit-postgresql-0 -- psql -h localhost -d audit -U postgres -c 'alter table audit_log detach partition audit_log_p20240101;'
```

1. Backup partition table

```bash

pg_dump -U admin -h localhost -p5433 --file ./audit-p20240101.sql --table public.audit_log_p20240101 audit

```

1. Drop partition table to remove from database

```bash

drop table audit_log_p20240101;

```


On success, the backup creates a gzip file, `audit-p20240101.sql`.

To check that the backup succeeded, unzip the files and inspect the data.

## Next Steps

- Test the [Restore Audit]({{< relref "../restore/audit" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup:
  - [Keycloak]({{< relref "keycloak" >}}).
  - [Grafana]({{< relref "grafana" >}}).
  - [The Graph Database]({{< relref "graphdb" >}}).
