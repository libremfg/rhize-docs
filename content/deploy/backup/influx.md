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
    kubectl exec --stdin --tty <INFLUX_POD_NAME> -- /bin/bash
    ```

    For details, read the Kubernetes topic [Get Shell to a Running Container](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/).

1. Use the `influx backup` command to backup the data.

    ```bash
    influx backup --org {{< param brand_name >}} --bucket {{< param brand_name >}}  --token <token-here> /backups/$(date +"%Y-%m-%dT%H.%M.%S")
    ```

| Default audit bucket is `libre`

1. Open the backup directory. Check the latest directory (for example with `ls -lt`) for the latest `.gz` files. Its name should be a timestamp from when you ran the preceding backup command.

1. Create a file that holds the sha256 checksums of the latest backup files. Replace `<backup-folder-date>` below  You'll use this file to confirm the copy is identical.

    ```bash
    cd /backups/
    sha256sum ./<backup-folder-date>/* > ./backup.sums
    ```

1. Leave the container shell. Copy files out of the container to your backup location:

   ```bash
   kubectl cp --retries=10 <namespace>/<INFLUX-POD>:backups/<backup-folder-date> ./<backup-folder-date>
   kubectl cp --retries=10 <namespace>/<INFLUX-POD>:backups/backup.sums ./backup.sums
   ```

1. Use the checksum to confirm that the pod files and the local files are the same.
If you are using Windows, you can run an equivalent check with the [`CertUtil`](https://learn.microsoft.com/en-us/windows-server/administration/windows-commands/certutil) utility:

   {{< tabs >}}
   {{% tab "bash" %}}
   ```bash
   ## Change to the directory
   cd ./<BACKUP>/<ON_YOUR_DEVICE>/
   ## Check sums
   sha256sum -c backup.sums
   ```
   {{% /tab %}}
   {{% tab "cmd" %}}
   ```cmd
   CertUtil -hashfile C:\<BACKUP>\<ON_YOUR_DEVICE>\backup.sums sha256
   ```
   {{% /tab %}}
   {{< /tabs >}}

## Next steps

- Test the [Restore Influxdb]({{< relref "../restore/influxdb" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup [the Graph Database]({{< relref "graphdb" >}}) and [Grafana]({{< relref "grafana" >}}).
