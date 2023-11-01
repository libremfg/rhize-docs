---
title: 'Back up the Graph DB'
date: '2023-10-18T11:01:46-03:00'
categories: ["how-to"]
description: How to back up the Rhize graph database
weight: 100
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you how to back up the Rhize Graph database.
You can also use it to model an automation workflow.

## Prerequisites

Before you start, ensure you have the following:

- A designated backup location, for example `~/rhize-backups/database`.
- Access to your [Rhize Kubernetes Environment]({{< relref "install" >}})
{{% param pre_reqs %}}.

Also, before you start, confirm you are in the right context and namespace.

```bash
## context
kubectl config current-context
## namespace
kubectl get namespace
```
## Steps

To back up the database, follow these steps:

1. Check the logs for the alpha and zero pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Open a pod shell for one of the alpha pods.

    ```bash
    kubectl exec --stdin --tty \
    {{< param application_name >}}-baas-baas-alpha-0 -- /bin/bash
    ```

    For details, read the Kubernetes topic [Get Shell to a Running Container](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/).

1. Use `curl` or something similar to create a backup of the node:

    ```bash
    curl --location --request POST 'http://localhost:8080/admin' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation {\r\n export(input: {format: \"json\", destination: \"/dgraph/backups/'" $(date +"%Y-%m-%dT%H.%M.%SZ")"'\"}) {\r\n response {\r\n message\r\n code\r\n }\r\n}\r\n}","variables":{}}'
    ```

1. Change to the backup directory (the `destination` parameter in the preceding `curl` command).

1. Check for the latest directory. Its name should be the timestamp of when you sent the preceding `curl` request. For example:

   ```bash
   ls -lt
   ```

   With these flags, the first listed directory should be the latest backup, named something like `2023-10-31T16.55.56Z`


1. Copy files out of the container to your backup location:

   ```bash
   kubectl cp <name-space>/<pod-name>:backups/<folder- name-of-backup> \
   ./<some-location>/<on-your-computer>
   ```

## Confirm success

To check that the backup succeeded, unzip the files and inspect the data.
There are likely three zipped files:
- The GraphQL schema
- The DB schema
- A JSON file with the real database data.

## Next Steps

- Test the [Restore Graph Database]({{< relref "../restore/influxdb" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup [Grafana]({{< relref "grafana" >}}).
