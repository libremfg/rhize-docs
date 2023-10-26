---
title: 'Set up Kubernetes'
date: '2023-09-22T14:49:53-03:00'
draft: true
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

This procedure aims to be as generic and vendor-neutral as possible.
Some configuration depends on where and how you run your IT infrastructure&mdash;what cloud provider you use, preferred auxiliary tools, and so on---so your team must adapt the process for its particular use cases.

You can also use this procedure as the model for an automation workflow in your CI.

  
## Prerequisites


Before starting, ensure that you have the following technical requirements:

- Access to our Helm charts
- Administrative privileges for running Kubernetes cluster.
- Internet access
- A way to programmatically make HTTP requests (this guide uses Curl)
- [Helm](https://helm.sh) installed
{{% param pre_reqs %}}

## Steps to set up Kubernetes

First, record your site and environment.
Then, follow these steps.

1. Create a namespace called {{< param application_name >}}.

    ```bash
    kubectl create ns {{< param application_name >}}
    ```

    Confirm it works with `kubectl get ns`.

    The output should how an active {{< param application_name >}} namespace.

1. Set this namespace as a default with

    ```bash
    kubectl config set-context --current --namespace={{< param application_name >}}
    ```

    Alternatively, you can modify the config file. For frequent switching, consider kubens.
    
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
     --docker-server=<DOCKER_SERVER> \
     --docker-username= <USERNAME> \
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

1. Pull the build template repo.

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
