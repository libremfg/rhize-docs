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

This guide shows you the procedure to back up Grafana on your Rhize Kubernetes deployment.
For general instructions, refer to the official [Back up Grafana](https://grafana.com/docs/grafana/latest/administration/back-up-grafana/) documentation.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/grafana`.
- Access to the [Rhize Kubernetes Environment](/deploy/install/setup-kubernetes)
{{% param pre_reqs %}}

Also, before you start, confirm you are in the right context and namespace.

{{% param k8s_cluster_ns %}}

## Steps

To back up the Grafana, follow these steps:

1. Check the logs for the Grafana pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the Grafana pods:

     ```bash
     kubectl exec --stdin --tty <GRAFANA_POD_NAME> -- /bin/bash
     ```

    For details, read the Kubernetes topic [Get Shell to a Running Container](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/).

1. Use `tar` to backup the Grafana data and `conf` directories:

     ```bash
     ## Data Directory Backup Command
     tar -v -c -f /home/grafana/grafana-data-$(date +"%Y-%m-%dT%H.%M.%S").tar.gz /var/lib/grafana
     ## Conf Directory Backup Command
     tar -v -c -f /home/grafana/grafana-conf-$(date +"%Y-%m-%dT%H.%M.%S").tar.gz /usr/share/grafana/conf
     ```

1. Change to the backup directory. For example:

    ```bash
    cd /home/grafana/
    ```

1. Check for the latest `.gz` files (for example, with `ls -lt`).
   There should be new backup `data` and `conf` files whose names include timestamps from when you ran the preceding `tar` commands.

1. Create a checksum file for the latest backups:

   ```bash
   sha256sum <LATEST_DATA_FILE>.tar.gz <LATEST_CONF_FILE>.tar.gz > backup.sums
   ```


1. Exit the container shell, and then copy files out of the container to your backup location:

    ```bash
    ## exit shell
    exit
    ## copy container files to backup
    kubectl cp <GRAFANA_POD>:/home/grafana/<NEW_DATA_BACKUP_FILENAME> \
    ./<NEW_DATA_BACKUP_FILENAME> -c grafana

    kubectl cp <GRAFANA_POD>:/home/grafana/<NEW_CONF_BACKUP_FILENAME> \
    ./<NEW_CONF_BACKUP_FILENAME> -c grafana
    kubectl cp <GRAFANA_POD>:/home/grafana/backup.sums \
    ./backup.sums -c grafana
    ```

## Confirm success


To confirm the backup, check their sha256 sums and their content.

To check the sums:

1. Change to the directory where you sent the backups:

     ```bash
     cd <BACKUP>/<ON_YOUR_DEVICE>/
     ```
1. Compare the checksums:

     ```bash
     sha256sum -c backup.sums \
     <LATEST_DATA_FILE>.tar.gz <LATEST_CONF_FILE>.tar.gz
     ```

To check that the content is correct, unzip the files and inspect the data.

## Next steps

- Test the [Restore Grafana]({{< relref "../restore" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup [the Graph Database]({{< relref "graphdb" >}}).
