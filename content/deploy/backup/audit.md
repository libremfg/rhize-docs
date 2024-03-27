---
title: 'Back up Audit PostgreSQL'
date: '2024-03-26T11:20:56-03:00'
categories: ["how-to"]
description: How to backup Audit PostgreSQL on your Rhize deployment
weight: 300
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you the procedure to backup your Audit PostgreSQL database on your Rhize Kubernetes deployment.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/libre-audit`.
- Access to the [Rhize Kubernetes Environment](/deploy/install/setup-kubernetes)
{{% param pre_reqs %}}


Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

To back up Audit PostgreSQL, follow these steps:

1. Check the logs for the Audit pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Retrieve the Audit user password using the following command, replacing <namespace> with your namespace:


    ```bash
    kubectl get secret <SECRET-NAME> -o jsonpath="{.data.<SECRET-KEY>}" | base64 --decode
    ```

1. Execute a command on the Audit Postgres pod to perform a full backup, replacing <NAMESPACE> with your namespace:

    ```bash
    kubectl exec -i audit-postgres-0 -- pg_dumpall -U <DB_USER> | gzip > audit-postgres-backup-$(date +"%Y%m%dT%I%M%p").sql.gz
    ```


On success, the backup creates a gzip file, `audit-postgres-backup-YYYYMMDDTHHMMSS.sql.gz`.

To check that the backup succeeded, unzip the files and inspect the data.

## Next Steps

- Test the [Restore Audit]({{< relref "../restore/audit" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup:
  - [Keycloak]({{< relref "keycloak" >}}).
  - [Grafana]({{< relref "grafana" >}}).
  - [The Graph Database]({{< relref "graphdb" >}}).
