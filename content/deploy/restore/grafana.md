---
title: 'Restore Grafana'
date: '2023-10-19T13:52:23-03:00'
categories: ["how-to"]
description: How to restore a Grafana backup on Rhize
weight: 300
menu:
  main:
    parent: restore
    identifier:
---


This guide shows you how to restore Grafana in your Rhize environment.

## Prerequisites

Before you start, ensure you have the following:

{{% param pre_reqs %}}
- A [Grafana backup]({{< relref "../backup/grafana" >}})

## Steps

<!-- if procedure is very long, consider using h3s -->

1. Confirm the cluster and namespace are correct.

    {{% param k8s_cluster_ns %}}

1.  Copy the tar file into the new Grafana Pod within the `/var/lib/grafana/` directory.

    ```bash
    kubectl cp ./local-dest-of-backup <grafana-pod>:/var/lib/grafana/
    ```
1. Untar the file.

   ```bash
   tar -xvf <backup>.tar.gz
   ```

1. Move the de-compressed files to `/var/lib/grafana`

1. Restart the Grafana deployment.

To confirm sucess, log in and verify the backup contents are where they should be.
