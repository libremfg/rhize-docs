---
title: 'Upgrade'
date: '2023-10-18T15:02:24-03:00'
draft: true
categories: ["how-to"]
description: How to upgrade Rhize
weight: 900
menu:
  main:
    parent: deploy
    identifier:
---

<!-- Title must be a verb -->

<!-- Small intro explaining what task is, and why someone might do this task
Link to relevant explanations and reference topics, if needed -->

## Prerequisites

Before you start, ensure you have the following:

- Access to the [Rhize Kubernetes Environment]({{< relref ".." >}})
- [kubectl](https://kubernetes.io/docs/tasks/tools/) and [kubectx](https://github.com/ahmetb/kubectx)
- Optional: the [k8 Lens IDE](https://k8lens.dev), if you prefer to manage Kubernetes graphically
- [helm](https://helm.sh/docs/helm/helm_install/)

Be sure that you notify relevant parties of the coming upgrade.

## Procedure

First, record the old and new versions, their context, and namespaces.

1. Check the logs for the {{< param application_name >}} pods, either in Lens or with [`kubectl logs`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#logs).
    Ensure there are no errors.

1. Pull the [] directory:
1. Change to the `kubernetes/charts/libre` directory.
1. Check your Kubernetes context and namespace.
1. Use the `helm list` command to check for {{< param application_name >}} services.
1. Scale down `{{< param application_name >}}-pubsub`.
1. Delete the `schema` job.

In your editor edit the config file to match the influx token of the environment.

1. Upgrade with the following command:


    ```bash
    helm upgrade libre -f namespace.yaml -n namespace
    ```
    
1. Restart the deployment.

## Verify success

Verify success in Kubernetes by checking that the version upgraded properly and that the logs are correct.

Inform your team that the upgrade was successful.

<!--Define what success looks like -->

<!-- 
### Error recovery
Optional. Define common failure modes and how to recover
-->

<!--
## Next steps
Optional. Summarize what was done. Give an example of what success looks like.

Where applicable, provide links to next steps or to read more.
-->
