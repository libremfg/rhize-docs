---
title: 'Graphdb'
date: '2023-10-18T11:01:46-03:00'
draft: true
categories: ["how-to"]
description: How to back up the Rhize graph database
weight: 100
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you the procedure to back up the Rhize Graph database.

## Prerequisites

Before you start, ensure you have the following:

- Access to the [Rhize Kubernetes Environment]({{< relref "../install/configure-kubernetes" >}})
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
    
1. Check the logs for the alpha and zero pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the alpha pods.

1. Use curl to create a backup of the node.

    ```bash
    curl --location --request POST 'http://localhost:8080/admin' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation {\r\n export(input: {format: \"json\", destination: \"/dgraph/backups/'"$(date +"%Y-%m-%dT%H.%M.%SZ")"'\"}) {\r\n response {\r\n message\r\n code\r\n }\r\n}\r\n}","variables":{}}'
    ```

1. Open the backup directory (the `destination` parameter in the preceding Curl command). Check the latest directory (for example with `ls -lh`) for the latest .gz files.
1. Copy files out of the containter to your backup location:
   
   ```bash
   kubectl cp <name-space>/<pod-name>:backups/<folder- name-of-backup> \
   ./<some-location>/<on-your-computer>
   ```

To check that the backup succeeded, unzip the files and inspect the data.

