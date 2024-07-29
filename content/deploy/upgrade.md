---
title: 'Upgrade'
date: '2023-10-18T15:02:24-03:00'
categories: ["how-to"]
description: How to upgrade Rhize
weight: 500
menu:
  main:
    parent: deploy
    identifier:
---

This guide shows you how to upgrade Rhize.

{{< reusable/backup >}}

## Prerequisites

Before you start, ensure you have the following:

- Access to the [Rhize Kubernetes Environment]({{< relref ".." >}})
- [helm](https://helm.sh/docs/helm/helm_install/)
{{% param pre_reqs %}}

Be sure that you notify relevant parties of the coming upgrade.

## Procedure

First, record the old and new versions, their context, and namespaces.

1. Check the logs for the {{< param application_name >}} pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Use Git to pull your Rhize customer build directory.
1. Change to the `kubernetes/charts/{{< param application_name >}}` directory.
1. Check your Kubernetes context and namespace.

    {{% param k8s_cluster_ns %}}

1. Use the `helm list` command to check for {{< param application_name >}} services.
1. Upgrade with the following command:


    ```bash
    helm upgrade {{< param application_name >}} -f <NAMESPACE>.yaml -n namespace
    ```

1. Get a token using your credentials.
   With `curl`, it looks like this:

    ```bash
    curl --location --request POST 'https://<AUTH_SUBDOMAIN>-<YOUR_DOMAIN>
    auth.{{< param application_name >}}/realms/{{< param application_name >}}/protocol/openid-connect/token' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'username=system@{{< param application_name >}}.com' \
    --data-urlencode 'password=<PASSWORD>' \
    --data-urlencode 'client_id={{< param application_name >}}Baas' \
    --data-urlencode 'client_secret=<CLIENT_SECRET>'
    ```



1. Redeploy the schema. To do so, you need to interact with the `alpha` service on port `8080`. You can do this in multiple ways. Either enter the alpha shell with a command such as `kubectl exec --stdin baas-alpha-0 -- sh`, or forward the port to your local instance using a command such as `kubectl port-forward baas-alpha-0 8080:8080`.

   For example, using port forwarding, a `curl` command to deploy the schema looks like this:

    ```bash
    curl --location -X POST 'http://localhost:<FORWARDED_PORT>/admin/schema' \
    -H "Authorization: Bearer $<TOKEN>" \
    -H "content-Type: application/octet-stream" \
    --data-binary <PATH/TO/SCHEMA>.sdl
    ```

    The schema file is likely called something like `schema.sdl`.

1. Restart the deployment.

## Verify success

Verify success in Kubernetes by checking that the version upgraded properly and that the logs are correct.

Inform your team that the upgrade was successful.
