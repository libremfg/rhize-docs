---
title: 'Restore the GraphDB'
date: '2023-10-19T13:52:23-03:00'
ategories: ["how-to"]
description: How to restore a backup of the Rhize Graph DB.
weight: 200
---

This guide shows you how to restore the Graph database in your Rhize environment.

## Prerequisites

Before you start, ensure you have the following:

- The GraphDB Helm chart
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- A [Database backup]({{< relref "../backup/graphdb" >}})

## Steps

<!-- if procedure is very long, consider using h3s -->

1. Confirm the cluster and namespace are correct.

    {{% param k8s_cluster_ns %}}

1. Change to the {{< param application_name >}}-baas helm chart overrides, `baas.yaml`.
   Set `alpha.initContainers.init.enable` to `true`.

1. Upgrade or install the Helm chart.

    ```bash
    helm upgrade --install -f baas.yaml {{< param application_name >}}-baas {{< param application_name >}}/baas -n {{< param application_name >}}
    ```

1. In the Alpha 0 initialization container, create the backup directory.

    <!-- vale off -->

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha-init -- \
    mkdir -p /dgraph/backups
    ```
    <!-- vale on -->

1. If the backup directory does not have a checksums file, create one.

    ```bash
    sha256sum ./<PATH_TO_BACKUP>/*.gz > ./<PATH_TO_BACKUP>/backup.sums
    ```

1. Copy the backup into the initialization container.

    ```bash
    kubectl cp --retries=10 ./<PATH_TO_BACKUP> \
    {{< param application_name >}}-baas-alpha-0:/dgraph/backups/<PATH_TO_BACKUP> \
    -c {{< param application_name >}}-baas-alpha-init
    ```

    After the process finishes, confirm that the checksums match:

    ```bash
    kubectl exec -it {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha-init -- \
    'sha256sum -c /dgraph/backups/<PATH_TO_BACKUP>/backup.sums /dgraph/backups/<PATH_TO_BACKUP>/*.gz'
    ```

1. Restore the backup to the restore directory.
  Replace the `<PATH_TO_BACKUP>` and `<NAMESPACE>` in the arguments for the following command:


    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha-init --  \
    dgraph bulk -f /dgraph/backups/<PATH_TO_BACKUP>/g01.json.gz \
    -g /dgraph/backups/<PATH_TO_BACKUP>/g01.gql_schema.gz \
    -s /dgraph/backups/<PATH_TO_BACKUP>/g01.schema.gz \
    --zero={{< param application_name >}}-baas-zero-0.{{< param application_name >}}-baas-zero-headless.<NAMESPACE>.svc.cluster.local:5080 \
    --out /dgraph/restore --replace_out
    ```
1. Copy the backup to the correct directory:

    <!-- vale off -->

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha-init -- \
    mv /dgraph/restore/0/p /dgraph/p
    ```
    <!-- vale on -->

1. Complete the initialization container for alpha 0.

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha-init -- touch /dgraph/doneinit
    ```

1. Wait for `{{< param application_name >}}-baas-alpha-0` to start serving the GraphQL API.

1. Make a database mutation to force a snapshot to be taken.
For example, create a `UnitOfMeasure` then delete it:

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha -- \
    curl --location --request POST 'http://localhost:8080/graphql' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation RestoringDatabase($input:[AddUnitOfMeasureInput!]!){\r\n addUnitOfMeasure(input:$input){\r\n unitOfMeasure{\r\n id\r\n dataType\r\n code\r\n }\r\n}\r\n}","variables":{"input":[{"code":"Restoring","isActive":true,"dataType":"BOOL"}]}}'
    ```
    Wait until you see {{< param application_name >}}-baas creating a snapshot in the logs. For example:

    ```bash
    $ kubectl logs {{< param application_name >}}-baas-alpha-0
    ++ hostname -f
    ++ awk '{gsub(/\.$/,""); print $0}'
    ...
    I0314 20:32:21.282271 19 draft.go:805] Creating snapshot at Index: 16, ReadTs: 9
    ```

    Revert any database mutations:

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-0 -c {{< param application_name >}}-baas-alpha -- \
    curl --location --request POST 'http://localhost:8080/graphql' \
    --header 'Content-Type: application/json' \
    --data-raw '{"query":"mutation {\r\n deleteUnitOfMeasure(filter:{code:{eq:\"Restoring\"}}){\r\n unitOfMeasure{\r\n id\r\n }\r\n }\r\n}","variables":{"input":[{"code":"Restoring","isActive":true,"dataType":"BOOL"}]}}'
    ```

1. Complete the initialization container for alpha 1:

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-1 -c {{< param application_name >}}-baas-alpha-init -- \
    touch /dgraph/doneinit
    ```

    And alpha 2:

    ```bash
    kubectl exec -t {{< param application_name >}}-baas-alpha-2 -c {{< param application_name >}}-baas-alpha-init -- \
    touch /dgraph/doneinit
    ```
