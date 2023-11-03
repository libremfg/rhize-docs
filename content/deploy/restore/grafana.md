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
1. Copy the Grafana data tar file into the new Grafana Pod within the `/var/lib/grafana` directory:

     ```bash
     kubectl cp ./grafana-data-2023-11-01T16.05.53.tar.gz \
     <GRAFANA_POD_NAME>:/var/lib/grafana/
     ```

     A that the checksums match:

     ```bash
     kubectl exec -it <GRAFANA_POD_NAME> -- \
     'sha256sum ./<LATEST_DATA_FILE>.tar.gz  <LATEST_CONF_FILE>.tar.gz \
     > ./<PATH_TO_BACKUP>/backup.sums'
     ```

1. Untar the file:

     ```bash
     tar -xvf grafana-data-2023-11-01T16.05.53.tar.gz --directory /
     ```

1. Copy the Grafana configuration file into the new Grafana Pod in the `/usr/share/grafana/conf` directory:

     ```bash
     kubectl cp ./grafana-conf-2023-11-01T16.05.53.tar.gz \
     <GRAFANA_POD_NAME>:/usr/share/grafana/conf
     ```

1. Untar the file:

     ```bash
     tar -xvf grafana-conf-2023-11-01T16.05.53.tar.gz --directory /
     ```

1. Restart the Grafana Deployment.
