---
title: 'Back up Keycloak'
date: '2024-01-08T14:30:15-05:00'
categories: ["how-to"]
description: How to backup Keycloak on your Rhize deployment
weight: 300
---

This guide shows you how to back up Keycloak on your Rhize Kubernetes deployment.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/keycloak`.
- Access to the [Rhize Kubernetes Environment](/deploy/install/setup-kubernetes)
{{% param pre_reqs %}}

Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

To back up Keycloak, follow these steps:

1. Check the logs for the Keycloak pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Retrieve the Keycloak user password using the following command, replacing <namespace> with your namespace:


    ```bash
    kubectl get secret keycloak-<namespace>-postgresql -o jsonpath="{.data.postgres-password}" | base64 --decode
    ```

1. Execute a command on the Keycloak Postgres pod to perform a full backup, replacing <NAMESPACE> with your namespace:

    ```bash
    kubectl exec -i keycloak-<NAMESPACE>-postgresql-0 -- pg_dumpall -U postgres | gzip > keycloak-postgres-backup-$(date +"%Y%m%dT%I%M%p").sql.gz
    ```


1. When prompted, use the password from the previous step. Expect the prompt multiple times for each database.

1. Check the logs for the Keycloak Postgres pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors relating to the backup.

## Confirm success

On success, the backup creates a gzip file, `keycloak-postgres-backup-YYYYMMDDTHHMMSS.sql.gz`.

To check that the backup succeeded, unzip the files and inspect the data.

## Next Steps

- Test the [Restore Keycloak]({{< relref "../restore/keycloak" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup:
  - [Grafana]({{< relref "grafana" >}}).
  - [The Graph Database]({{< relref "graphdb" >}}).
