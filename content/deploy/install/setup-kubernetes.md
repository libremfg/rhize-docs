---
title: 'Set up Kubernetes'
date: '2023-09-22T14:49:53-03:00'
categories: ["how-to"]
description:
  How to install Rhize services on your Kubernetes cluster.
weight: 050
menu:
  main:
    parent: install
    identifier:
---

This guide shows you how to install Rhize services on your Kubernetes cluster.
You can also use this procedure as the model for an automation workflow in your CI.


## Prerequisites {#prereqs}

Before starting, ensure that you have the following technical requirements.

**Software requirements**:
- [kubectl](https://kubernetes.io/docs/tasks/tools/)
- [Helm](https://helm.sh)
- Curl, or some similar program to make HTTP requests from the command line

**Access requirements**:
- Administrative privileges for a running Kubernetes cluster in your environment.
  Your organization must set this up.
- Access to Rhize Helm charts and its build repo.
  Rhize provides these to all customers.

**Optional utilities.**
For manual installs, the following auxiliary tools might make
the experience a little more human friendly:
{{% param pre_reqs %}}

  Again, these are helpers, not requirements.
  You can install everything with only the `kubectl` and `helm` commands.


## Steps to set up Kubernetes

First, record your site and environment.
Then, follow these steps.

1. Create a namespace called {{< param application_name >}}.

    ```bash
    kubectl create ns {{< param application_name >}}
    ```

    Confirm it works with `kubectl get ns`.

    On success, the output shows an active `{{< param application_name >}}` namespace.

1. Set this namespace as a default with

    ```bash
    kubectl config set-context --current --namespace={{< param application_name >}}
    ```

    Alternatively, you can modify the kube `config` file or use the `kubens` tool.

1. Add the Helm repo:

    ```bash
    helm repo add \
         --username <EMAIL_ADDRESS> \
         --password <ACCESS_TOKEN> \
         {{< param application_name >}} \
   <REPO>
    ```


1. Create the container image pull secret:

    ```bash
    kubectl create secret docker-registry {{< param application_name >}}-registry-credential \
     --docker-server=<DOCKER_SERVER> \ ## the repo
     --docker-password= <ACCESS_TOKEN> \
     --docker-email= <EMAIL_ADDRESS>
    ```

    Confirm the secrets with this command:

    ```bash
    kubectl get secrets
    ```


1. Add the Bitnami Helm repo:

     ```bash
     helm repo add bitnami https://charts.bitnami.com/bitnami
     ```

1. Pull the build template repo (we will supply this).

1. Update overrides to `keycloak.yaml`. Then install with this command:

     ```bash
     helm install keycloak -f ./keycloak.yaml bitnami/keycloak -n libre
     ```

1. Set up port forwarding from Keycloak. For example, this forwards traffic to port `5101` on `localhost`

     ```bash
     kubectl port-forward  svc/keycloak 5101:80
     ```

## Next steps

1. [Configure Keycloak]({{< relref "keycloak.md" >}})
1. [Install services]({{< relref "services.md" >}}).
