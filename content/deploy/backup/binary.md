---
title: 'Back up the Graph DB to AWS'
date: '2024-11-04T11:01:46-03:00'
categories: ["how-to"]
description: How to back up the Rhize graph database to Amazon S3 storage.
weight: 100
menu:
  main:
    parent: backup
    identifier:
---

This guide shows you how to back up the Rhize Graph database to Amazon S3 storage.

## Prerequisites

Before you start, ensure you have the following:


- A designated S3 backup location, for example `s3://s3.<AWS-REGION>.amazonaws.com/<AWS-BUCKET-NAME>`.
- Access to your [Rhize Kubernetes Environment]({{< relref "install" >}})
{{% param pre_reqs %}}.


Before you start, confirm you are in the right context and namespace:

{{% param "k8s_cluster_ns" %}}

## Steps

To back up the database, follow these steps:

1. Check the logs for the alpha and zero pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

    ```bash
    kubectl logs {{< param application_name >}}-baas-baas-alpha-0 --tail=80
    ```
1. Set the following environmental variables:
   - `AWS_ACCESS_KEY_ID`. Your AWS access key with permissions to write to the destination bucket 
   - `AWS_SECRET_ACCESS_KEY`. Your AWS access key with permissions to write to the destination bucket
   - `AWS_SESSION_TOKEN`. Your AWS session token (if required)

1. Make a POST request to your Keycloak `/token` endpoint to get an `access_token` value.
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

1. Using the token from the previous step, send a POST to `<alpha service>:8080/admin` to create a backup of the node to your S3 bucket.
For example, with `curl`:

    ```bash
   curl --location 'http://alpha:8080/admin' \
   --header 'Content-Type: application/json' \
   --header 'Authorization: Bearer <TOKEN>' \
   --data '{"query":"mutation {\n  backup(input: {destination: \"s3://s3.<AWS-REGION>.amazonaws.com/<AWS-BUCKET-NAME>\"}) {\n    response {\n      message\n      code\n    }\n    taskId\n  }\n}","variables":{}}'
   ```

1. List available backups to confirm your backup succeeded:

    ```bash
    curl --location 'http://alpha:8080/admin' \
   --header 'Content-Type: application/json' \
   --header 'Authorization: Bearer <TOKEN>' \
   --data '{"query":"query backup() {\n\tlistBackups(input: {location: \"s3://s3.<AWS-REGION>>.amazonaws.com/<AWS-BUCKET-NAME>\"}) {\n\t\tbackupId\n\t\tbackupNum\n\t\tpath\n\t\tsince\n\t\ttype\n\t}\n}","variables":{}}'
    ```

## Next Steps

- Test the [Restore Graph Database From S3]({{< relref "../restore/binary" >}}) procedure to ensure you can recover data from Amazon S3 in case of an emergency.
- To back up other Rhize services, read how to backup [Grafana]({{< relref "grafana" >}}).
