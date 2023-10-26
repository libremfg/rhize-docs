---
title: 'Overview'
categories: ["how-to"]
description: >-
  How to install Rhize services on your Kubernetes cluster.
weight: 010
menu:
  main:
    parent: install
    identifier: install-overview
---

This guide shows you how to install Rhize services on your Kubernetes cluster.

This procedure aims to be as generic and vendor-neutral as possible.
Some configuration depends on where and how you run your IT infrastructure&mdash;what cloud provider you use, preferred auxiliary tools, and so on---so your team must adapt the process for its particular use cases.

## Steps

You can also use this procedure as the model for an automation workflow in your CI.

1. **[Set up the Kubernetes environment.]({{< relref "configure-kubernetes" >}})**

    1. Within a Kubernetes cluster, create a new namespace.
    1. In this namespace, add the Rhize container images and Helm repos.
    1. In the cluster, create secrets for passwords.
    1. Use Helm to install Keycloak.

1. **[Configure Keycloak.]({{< relref "keycloak" >}})**

    1. In Keycloak, create a realm and clients for each service.
    1. In the cluster, create client secrets from Keycloak.
    1. Use Helm to install {{< param db >}} .
    1. In Keycloak, give {{< param db >}} admin permissions.

1. **[Install services.]({{< relref "services" >}})**

    For each service, installation involves the following:
    1. Ensuring dependencies are installed.
    1. Editing their YAML files to override defaults as needed.
    1. Installing through Helm.
  

