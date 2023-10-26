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


This guide has three steps, each of which has its own page.
You can also use these docs to model automation workflows in your CI.

The essential procedure is as follows

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
  

