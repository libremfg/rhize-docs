---
title: 'Back up Grafana'
date: '2023-10-18T11:01:56-03:00'
categories: ["how-to"]
description: How to backup Grafana on your Rhize deployment
weight: 300
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you the procedure to back up the Grafana on your Rhize Kubernetes deployment.
For general instructions, refer to the official [Backup Influx](https://docs.influxdata.com/influxdb/v1/administration/backup_and_restore/) documentation.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/grafana`.
- Access to the [Rhize Kubernetes Environment](/deploy/install/setup-kubernetes)
{{% param pre_reqs %}}

Also, before you start, confirm you are in the right context and namespace.

```bash
## context
kubectl config current-context
## namespace
kubectl get namespace
```

## Steps

Then, to back up the Grafana, follow these steps:

1. Check the logs for the Grafana pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the Grafana pods:

    ```bash
    kubectl exec <GRAFANA_POD_NAME> -- /bin/bash
    ```

    For details, read the Kubernetes topic [Get Shell to a Running Container](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/).

1. Use `tar` to backup the Grafana data and `conf` directories:

    ```bash
    ## Data Directory Backup Command
    tar -v -c -f /home/grafana/grafana-data-$(date +"%Y-%m-%dT%H.%M.%S").tar.gz /var/lib/grafana
    ## Conf Directory Backup Command
    tar -v -c -f /home/grafana/grafana-conf-$(date +"%Y-%m-%dT%H.%M.%S").tar.gz /usr/share/grafana/conf
    ```

1. Open the backup directory. Check the latest directory (for example with `ls -lt`) for the latest `.gz` files. Its name should be a timestamp from when you ran the preceding `tar` command.

1. Copy files out of the container to your backup location:

   ```bash
   kubectl cp <grafana-pod>:/home/grafana/<new-data-backup-filename> \
   ./<new-data-backup-filename> -c grafana

   kubectl cp <grafana-pod>:/home/grafana/<new-conf-backup-filename> \
   ./<new-conf-backup-filename> -c grafana
   ```

To check that the backup succeeded, unzip the files and inspect the data.

## Next steps

- Test the [Restore Grafana]({{< relref "../restore" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup [the Graph Database]({{< relref "graphdb" >}}) and [InfluxDB](/deploy/backup/influx).
