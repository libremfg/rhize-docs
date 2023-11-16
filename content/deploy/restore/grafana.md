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

- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- A [Grafana backup]({{< relref "../backup/grafana" >}})

## Steps

1. Confirm the cluster and namespace are correct:

    {{% param "k8s_cluster_ns" %}}

1. If a checksum file does not exist for the latest backups, create one:

    ```bash
    sha256sum <LATEST_DATA_FILE>.tar.gz <LATEST_CONF_FILE>.tar.gz > backup.sums
    ```
1. Copy the checksum file into the new Grafana Pod within the `/home/grafana` directory:

     ```bash
     kubectl cp ./backup.sums \
     <GRAFANA_POD_NAME>:/home/grafana
     ```

1. Copy the Grafana data tar file into the new Grafana Pod within the `/home/grafana` directory:

     ```bash
     kubectl cp ./<LATEST_DATA_FILE>.tar.gz \
     <GRAFANA_POD_NAME>:/home/grafana
     ```

1. Copy the Grafana configuration tar file into the new Grafana Pod within the `/home/grafana` directory:

     
     ```bash
     kubectl cp ./<LATEST_CONF_FILE>.tar.gz \
     <GRAFANA_POD_NAME>:/home/grafana
     ```

1. Confirm that the checksums match:

     ```bash
     kubectl exec -it <GRAFANA_POD_NAME> -- /bin/bash 

     <GRFANA_POD_NAME>:~$ cd /home/grafana
     <GRFANA_POD_NAME>:~$ sha256sum -c backup.sums
     ./<LATEST_DATA_FILE>.tar.gz: OK
     ./<LATEST_CONF_FILE>.tar.gz: OK

     ```

1. Untar the data file:

     ```bash
     tar -xvf <LATEST_DATA_FILE>.tar.gz --directory /
     ```

1. Untar the configuration file:

     ```bash
     tar -xvf <LATEST_CONF_FILE>.tar.gz --directory /home/grafana/
     ```

1. Move over the top of current configuration. 

     | Typically some files are configured as a kubernetes [`ConfigMap`](https://kubernetes.io/docs/concepts/configuration/configmap/) and may need to be configured as part of installation. The following command will prompt when it is going to overwrite a file, and if it has the permissions to do so.

     ```bash
     mv /home/grafana/usr/share/grafana/conf/* /usr/share/grafana/conf/
     ```

1. Remove restore files and directory

     ```bash
     rm /home/grafana/<LATEST_DATA_FILE>.tar.gz
     rm /home/grafana/<LATEST_CONF_FILE>.tar.gz
     rm /home/grafana/backup.sums
     rm -r /home/grafana/usr
     ```

1. Restart the Grafana Deployment.

     ```bash
     kubectl rollout restart deployment grafana -n libre
     ```
