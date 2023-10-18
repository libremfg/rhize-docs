---
title: 'Influxdb'
date: '2023-10-18T11:01:56-03:00'
draft: true
categories: ["how-to"]
description: How to backup InfluxDB on your Rhize deployment
weight: 200
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you the procedure to back up the InfluxDB database on your Rhize Kubernetes deployment.
For general instructions to back up Influx, refer to the official [Backup and restore](https://docs.influxdata.com/influxdb/v1/administration/backup_and_restore/) documentation.

## Prerequisites

Before you start, ensure you have the following:

- Access to the customer [Rhize Kubernetes Environment]({{< relref "../install/configure-kubernetes" >}})
- A token with backup priviliges on the Rhize (Libre) organization and bucket
- [kubectl](https://kubernetes.io/docs/tasks/tools/) and [kubectx](https://github.com/ahmetb/kubectx)
- Optional: the [k8 Lens IDE](https://k8lens.dev), if you prefer to manage Kubernetes graphically

## Procedure

First, confirm you are in the right context and namespace.

    ```bash
    ## context
    kubectl config current-context
    ## namespace
    kubectl get namespace
    ```

Record these outputs for record keeping.

Then, to back up the database, follow these steps:

1. Check the logs for the InfluxDB pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the Influx pods.

1. Run the Influx DB backup command


    ```bash
    
    influx backup --org {{< param brand_name >}} --bucket {{< param brand_name >}} --token <token-here> /backups/$(date +"%Y-%m-%dT%H.%M.%S")
    ```

1. Open the backup directory (the `destination` parameter in the preceding Curl command). Check the latest directory (for example with `ls -lh`) for the latest `.gz` files.
1. Copy files out of the container to your backup location:
   
   ```bash
   kubectl cp <name-space>/<influx-pod-name>:backups/<backup-directory-data> \
   ./<some-location>/<on-your-computer>
   ```

To check that the backup succeeded, unzip the files and inspect the data.

