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

{{% param "k8s_cluster_ns" %}}

## Steps

To back up the database, follow these steps:

1. Check the logs for the alpha and zero pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

    ```bash
    kubectl logs {{< param application_name >}}-baas-baas-alpha-0 --tail=80
    ```

1. Open a pod shell for one of the alpha pods.

    ```bash
    kubectl exec --stdin --tty \
    {{< param application_name >}}-baas-baas-alpha-0 -- /bin/bash
    ```

    For details, read the Kubernetes topic [Get Shell to a Running Container](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/).

1. Make a POST request to get the your Keycloak `/token` endpoint to get an `access_token` value.
For example, with `curl` and `jq`:

    ```bash
    ## replace USERNAME and PASSWORD with your credentials
    USERNAME=backups@libremfg.com \
    && PASSWORD=password \
    && curl --location \
      --request POST "${BAAS_OIDC_URL}/realms/libre/protocol/openid-connect/token" \
      --header 'Content-Type\ application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=password' \
      --data-urlencode "username=${USERNAME}" \
      --data-urlencode "password=${PASSWORD}"  \
      --data-urlencode "client_id=${BAAS_OIDC_CLIENT_ID}" \
      --data-urlencode "client_secret=${OIDC_SECRET}" | jq .access_token
    ```

1. Using the token from the previous step, send a POST to `localhost:8080/admin` to create a backup of the node.
For example, with `curl`:

    ```bash
    curl --location --request POST 'http://localhost:8080/admin' \
    --header 'Authorization: Bearer <TOKEN>' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation {\r\n export(input: {format: \"json\", destination: \"/dgraph/backups/'"$(date +"%Y-%m-%dT%H.%M.%SZ")"'\"}) {\r\n response {\r\n message\r\n code\r\n }\r\n}\r\n}","variables":{}}'
    ```

1. Change to the backup directory (the `destination` parameter in the preceding `curl` command). For example:

    ```bash
    cd /dgraph/backups
    ```

1. Check for the latest directory. Its name should be the timestamp of when you sent the preceding `curl` request. For example:

    ```bash
    ls -lt
    ```

   With these flags, the first listed directory should be the latest backup, named something like `2023-10-31T16.55.56Z`


1. Exit the container shell, then copy files out of the container to your backup location:

    ```bash
    ## exit shell
    exit
    ## copy container files to backup
    kubectl cp --retries=5 <name-space>/<pod-name>:backups/<CONTAINER_BACKUP \
    ./<BACKUP>/<ON_YOUR_DEVICE>
    ```

## Confirm success

On success, the backup creates three zipped files:
- The GraphQL schema
- The DB schema
- A JSON file with the real database data.

To check that the backup succeeded, unzip the files and inspect the data.

## Next Steps

- Test the [Restore Graph Database]({{< relref "../restore/graphdb" >}}) procedure to ensure you can recover data in case of an emergency.
- To back up other Rhize services, read how to backup [Grafana]({{< relref "grafana" >}}).
