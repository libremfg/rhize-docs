---
title: 'Restore the GraphDB from AWS'
date: '2023-10-19T13:52:23-03:00'
ategories: ["how-to"]
description: How to restore a backup of the Rhize Graph DB from Amazon S3.
weight: 200
menu:
  main:
    parent: restore
    identifier:
---

This guide shows you how to restore the Graph database from Amazon S3 to your Rhize environment.

## Prerequisites

Before you start, ensure you have the following:

- The GraphDB Helm chart
- [`kubectl`](https://kubernetes.io/docs/tasks/tools/)
- A [Database backup]({{< relref "../backup/binary" >}})

## Steps

<!-- if procedure is very long, consider using h3s -->

1. Set the follow environmental variables:
   - `AWS_ACCESS_KEY_ID` your AWS access key with permissions to write to the destination bucket
   - `AWS_SECRET_ACCESS_KEY` your AWS access key with permissions to write to the destination bucket
   - `AWS_SESSION_TOKEN` your AWS session token (if required)

1. Confirm the cluster and namespace are correct.

    {{% param k8s_cluster_ns %}}

1. Upgrade or install the Helm chart.

    ```bash
    helm upgrade --install -f baas.yaml {{< param application_name >}}-baas {{< param application_name >}}/baas -n {{< param application_name >}}
    ```

1. Wait for `{{< param application_name >}}-baas-alpha-0` to start serving the GraphQL API.

1.  Make a POST request to your Keycloak `/token` endpoint to get an `access_token` value.
    For example, with `curl` and `jq`:

    ```bash
    ## replace USERNAME and PASSWORD with your credentials
    USERNAME=backups@libremfg.com \
    && PASSWORD=password \
    && curl --location \
      --request POST "${BAAS_OIDC_URL}/realms/libre/protocol/openid-connect/token" \
      --header 'Content-Type\ application/x-www-form-urlencoded' \
      --data-urlencode 'grant_type=password' \
      --data-urlencode "username=<USERNAME>" \
      --data-urlencode "password=<PASSWORD>"  \
      --data-urlencode "client_id=<BASS_CLIENT_ID>" \
      --data-urlencode "client_secret=<BASS_CLIENT_SECRET>" | jq .access_token
    ```

1. Using the token from the previous step, send a POST to `<alpha pod>:8080/admin` to start the restore from the s3 bucket to the alpha node.
   For example, with `curl`:

    ```bash
   curl --location 'http://alpha-0:8080/admin' \
   --header 'Content-Type: application/json' \
   --header 'Authorization: Bearer <TOKEN>' \
   --data '{"query":"mutation{\n  restore(input:{\n    location: \"s3://s3.<AWS-REGION>.amazonaws.com/<AWS-BUCKET-NAME>\",\n    backupId: \"cocky_boyd5\"\n  }){\n    message\n    code\n  }\n}","variables":{}}'
   ```
