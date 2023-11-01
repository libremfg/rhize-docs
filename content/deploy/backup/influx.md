---
title: 'Back up Influx'
date: '2023-10-18T11:01:56-03:00'
categories: ["how-to"]
description: How to backup InfluxDB on your Rhize deployment
draft: true
weight: 300
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you the procedure to back up the InfluxDB on your Rhize Kubernetes deployment.
For general instructions, refer to the official [Backup Grafana](https://grafana.com/docs/grafana/latest/administration/back-up-grafana/) documentation.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/influx`.
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

Then, to back up the Influx, follow these steps:

1. Check the logs for the Influx pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the Influx pods:

    ```bash
    kubectl exec <INFLUX_POD_NAME> -- /bin/bash
    ```

    For details, read the Kubernetes topic [Get Shell to a Running Container](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/).

1. Use the `influx backup` command to backup the data.

    ```bash
    influx backup --org {{< param brand_name >}} --bucket {{< param brand_name >}}  --token <token-here> /backups/$(date +"%Y-%m-%dT%H.%M.%S")
    ```

1. Open the backup directory. Check the latest directory (for example with `ls -lt`) for the latest `.gz` files. Its name should be a timestamp from when you ran the preceding backup command.

1. Leave the container shell. Copy files out of the container to your backup location:

   ```bash
   kubectl cp <namespace>/<INFLUX-POD>:backups/<backup-folder-date> \
   ./<backup-folder-date>
   ```

To check that the backup succeeded, unzip the files and inspect the data.

## Next steps

- Test the [Restore Influxdb]({{< relref "../restore/influxdb" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup [the Graph Database]({{< relref "graphdb" >}}) and [Grafana]({{< relref "grafana" >}}).
