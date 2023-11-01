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


1. Confirm the cluster and namespace are correct.

    {{% param k8s_cluster_ns %}

1. Copy the grafana data tar file into the new Grafana Pod within the /var/lib/grafana directory.

    ```bash
    kubectl cp ./grafana-data-2023-11-01T16.05.53.tar.gz grafana-64cd6db6f4-8txc2:/var/lib/grafana/
    ```

1. Untar the file

     ```bash
     tar -xvf grafana-data-2023-11-01T16.05.53.tar.gz --directory /
     ```

1. Copy the Grafana configuration file into the new Grafana Pod within /usr/share/grafana/conf directory.

     ```bash
     kubectl cp ./grafana-conf-2023-11-01T16.05.53.tar.gz grafana-64cd6db6f4-8txc2:/usr/share/grafana/conf
     ```

1. Untar the file

    ```bash
    tar -xvf grafana-conf-2023-11-01T16.05.53.tar.gz --directory /
    ```

1. Restart the Grafana Deployment.
