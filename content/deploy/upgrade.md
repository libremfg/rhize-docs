---
title: 'Upgrade'
date: '2023-10-18T15:02:24-03:00'
categories: ["how-to"]
description: How to upgrade Rhize
weight: 900
menu:
  main:
    parent: deploy
    identifier:
---

This guide shows you how to upgrade Rhize.

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
1. Use the `helm list` command to check for {{< param application_name >}} services.
1. Scale down `{{< param application_name >}}-pubsub`.
1. Delete the `schema` job.

In your editor, edit the config file to match the Influx token of the environment.

1. Upgrade with the following command:


    ```bash
    helm upgrade {{< param application_name >}} -f <NAMESPACE>.yaml -n namespace
    ```

1. Restart the deployment.

## Verify success

Verify success in Kubernetes by checking that the version upgraded properly and that the logs are correct.

Inform your team that the upgrade was successful.

