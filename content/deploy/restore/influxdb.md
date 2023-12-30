---
title: 'Restore InfluxDB'
date: '2023-10-19T13:52:23-03:00'
categories: ["how-to"]
description: How to restore an InfluxDB backup on Rhize
draft: true
weight: 400
menu:
  main:
    parent: restore
    identifier: restore-influx
---


This guide shows you how to restore InfluxDB in your Rhize environment.

## Prerequisites

Before you start, ensure you have the following:

- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- An [InfluxDB backup]({{< relref "../backup/" >}})

## Steps

1. Confirm the cluster and namespace are correct.

    {{% param k8s_cluster_ns %}}

1.  Create a `PersistentVolumeClaim` for the InfluxDB backup file
(adjust size as needed):

    ```yaml
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
    name: influxdb-backup
    spec:
      accessModes:
        - ReadWriteOnce
    resources
    requests:
      storage: 1Gi
    ```

1. Modify the Influx deployment:

    ```yaml
    apiVersion: extensions/v1beta1
    kind: Deployment
    metadata:
    name: influxdb
    labels:
    name: influxdb
    ...
    volumes:
      - name: influx
       persistentVolumeClaim:
         claimName: influxdb
      - name: influx-backup
       persistentVolumeClaim:
         claimName: influxdb-backup
     containers:
       - name: influxdb
       image: "influxdb:alpine"
       volumeMounts:
       - mountPath: /var/lib/influxdb
         name: influx
       - mountPath: /tmp/backup
       name: influx-backup
     ```


1. Copy the backup file in the Kubernetes backup destination created in the preceding step:

     ```bash
     kubectl cp <local_path> <namespace>/<pod_name>:/tmp/backup/
     ```

1. Delete the InfluxDB deployment, as it needs to be stopped for the backup import.
1. Create a job that uses the same container image and volume. Modify the command:

    ```yaml
    kind: Job
    metadata:
        name: influx-restore
    spec:
        template:
            metadata:
                name: influx-restore
                labels:
                    task: influx-restore
            spec:
                volumes:
                    - name: influx
                        persistentVolumeClaim:
                            claimName: influxdb
                   - name: backup
                    persistentVolumeClaim:
                        claimName: influx-backup
                    containers:
                        - name: influx
                        image: "influxdb:alpine"
                        command: ["/bin/sh"]
                        args: ["-c", "influxd restore - metadir /var/lib/influxdb/meta -database <your_db_here> -datadir /var/lib/influxdb/data /tmp/backup/"]
                        volumeMounts:
                          - mountPath: /var/lib/influxdb
                          name: influx
                          - mountPath: /tmp/backup
                          name: backup
            restartPolicy: Never
    ```

1. Apply the job config. Check that it ran successfully

1. Re-create your InfluxDB deployment. Use the CLI or HTTP to test that it's available.
1. Remove the backup persistent claim and remove its use from the deployment config.
