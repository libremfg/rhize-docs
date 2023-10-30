---
title: 'Grafana'
date: '2023-10-18T11:01:56-03:00'
draft: true
categories: ["how-to"]
description: How to backup Grafana on your Rhize deployment
weight: 300
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you the procedure to back up the Grafana on your Rhize Kubernetes deployment.
For general instructions, refer to the official [Backup Grafana](https://grafana.com/docs/grafana/latest/administration/back-up-grafana/) documentation.

## Prerequisites

Before you start, ensure you have the following:

- Access to the [Rhize Kubernetes Environment]({{< relref "../install/setup-kubernetes" >}})
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

Then, to back up the Grafana, follow these steps:

1. Check the logs for the Grafana pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the Grafana pods.

1. Use `tar` to backup the Grafana data and `conf` directories:

    ```bash
    ## Data Directory Backup Command
    tar -v -c -f /home/grafana/grafana-data-$(date +"%Y-%m-%dT%H.%M.%S").tar.gz /var/lib/grafana
    ## Conf Directory Backup Command
    tar -v -c -f /home/grafana/grafana-conf-$(date +"%Y-%m-%dT%H.%M.%S").tar.gz /usr/share/grafana/conf
    ```

1. Open the backup directory. Check the latest directory (for example with `ls -lh`) for the latest `.gz` files.

1. Copy files out of the container to your backup location:
   
   ```bash
   kubectl cp <grafana-pod>:/home/grafana/<new-data-backup-filename> \
   ./<new-data-backup-filename> -c grafana
   
   kubectl cp <grafana-pod>:/home/grafana/<new-conf-backup-filename> \
   ./<new-conf-backup-filename> -c grafana
   ```

To check that the backup succeeded, unzip the files and inspect the data.

