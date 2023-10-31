---
title: 'Restore the GraphDB'
date: '2023-10-19T13:52:23-03:00'
ategories: ["how-to"]
description: How to restore a backup of the Rhize Graph DB.
weight: 200
menu:
  main:
    parent: restore
    identifier:
---

This guide shows you how to restore the Graph database in your Rhize environment.

## Prerequisites

Before you start, ensure you have the following:

{{% param pre_reqs %}}
- The GraphDB helm chart
- A [Database backup]({{< relref "../backup/graphdb" >}})

## Steps

<!-- if procedure is very long, consider using h3s -->

1. Confirm the cluster and namespace are correct.

    {{% param k8s_cluster_ns %}}

1.  Copy the tar file into the new Grafana Pod within the `/var/lib/grafana/` directory.

    ```bash
    kubectl cp ./local-dest-of-backup <grafana-pod>:/var/lib/grafana/
    ```
1. Uninstall the Helm chart:

   ```bash
   helm uninstall dgraph -n <namespace>
   ```

1. Change to the `dgraph` helm chart directory, and open `values.yaml`.
   Set `alpha.initContainers.init.enable` to `true`.

1. Deploy the Helm chart.

    ```bash
    helm install dgraph . -n <namespace>
    ```

1. In the Alpha 0 initialization container, create the backup directory.

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-0 -c dgraph-dgraph-alpha-init -- mkdir -p /dgraph/backups
    ```

1. Copy the backup into the initialization container.

    ```bash
    kubectl cp ./<path-to-backup> dgraph-dgraph-alpha-0:/dgraph/backups/<path-to-backup> \
    -c dgraph-dgraph-alpha-init
    ```

1. Restore the backup to the restore directory.
  Replace <path-to-backup> and `<namespace`> in the arguments for the following command.


    ```bash
    kubectl exec -t dgraph-dgraph-alpha-0 -c dgraph-dgraph-alpha-init --  \
    dgraph bulk -f /dgraph/backups/<path-to-backup>/g01.json.gz \
    -g /dgraph/backups/<path-to-backup>/g01.gql_schema.gz \
    -s /dgraph/backups/<path-to-backup>/g01.schema.gz - \
    -zero=dgraph-dgraph-zero-0.dgraph-dgraph-zero-headless.<namespace>.svc.cluster.local:5080 \
    --out /dgraph/restore --replace_out
    ```
1. Copy the backup to the correct directory:

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-0 -c dgraph-dgraph-alpha-init -- \
    mv /dgraph/restore/0/p/dgraph/p
    ```

1. Complete the initialization container for alpha 0.

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-0 -c dgraph-
    dgraph-alpha-init -- touch /dgraph/doneinit
    ```

1. Wait for `dgraph-dgraph-alpha-0` to start serving the GraphQL API.

1. Make a database mutation to force a snapshot to be taken.
For example, create a `UnitOfMeasure` then delete it:

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-0 -c dgraph-dgraph-alpha -- \
    curl --location --request POST 'http://localhost:8080/graphql' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation RestoringDatabase($input:[AddUnitOfMeasureInput!]!){\r\n addUnitOfMeasure(input:$input){\r\n unitOfMeasure{\r\n id\r\n dataType\r\n code\r\n }\r\n}\r\n}","variables":{"input":[{"code":"Restoring","isActive":true,"dataType":"BOOL"}]}}'
    ```
    Wait until you see a snapshot in the logs. For example:

    ```bash
    I0314 20:32:21.282271 19 draft.go:805] Creating snapshot at Index: 16, ReadTs: 9
    ```

    Revert any database mutations:

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-0 -c dgraph-dgraph-alpha -- \
    curl --location --request POST 'http://localhost:8080/graphql' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation {\r\n deleteUnitOfMeasure(filter:{code:{eq:\"Restoring\"}}){\r\n unitOfMeasure{\r\n id\r\n }\r\n }\r\n}","variables":{"input":[{"code":"Restoring","isActive":true,"dataType":"BOOL"}]}}'
    ```

1. Complete the initialization container for alpha 1:

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-1 -c dgraph-dgraph-alpha-init -- \
    touch /dgraph/doneinit
    ```

    And alpha 2:

    ```bash
    kubectl exec -t dgraph-dgraph-alpha-2 -c dgraph-dgraph-alpha-init -- \
    touch /dgraph/doneinit
    ```
