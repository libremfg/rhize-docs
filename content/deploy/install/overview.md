---
title: 'Overview'
categories: ["how-to"]
description: >-
  A high-level overview of the Rhize install process.
weight: 010
menu:
  main:
    parent: install
    identifier: install-overview
---

This guide walks you through how to Install Rhize and its services in a Kubernetes environment.
You can also use these docs to model automation workflows in your CI.

> This procedure aims to be as generic and vendor-neutral as possible.
> Some configuration depends on where and how you run your IT infrastructure&mdash;what cloud provider you use, preferred auxiliary tools, and so on---so your team must adapt the process for its particular use cases.

## Condensed instructions

This guide has three steps, each of which has its own page.
The essential procedure is as follows:

1. **[Set up the Kubernetes environment](/deploy/install/setup-kubernetes)**.

    1. Within a Kubernetes cluster, create a new namespace.
    1. In this namespace, add the Rhize container images and Helm repos.
    1. In the cluster, create passwords.
    1. Use Helm to install Keycloak.

1. **[Configure Keycloak]({{< relref "keycloak" >}})**.

    1. In Keycloak, create a realm and clients for each service.
    1. In the cluster, create secrets for the KeyCloak clients.

1. **[Install services]({{< relref "services" >}})**.

    
    1. Use Helm to install {{< param db >}} .
    1. In Keycloak, give {{< param db >}} admin permissions.
    1. Use these admin permissions to POST the database schema.
    1. Return to Keycloak and add the newly created permissions to the {{< param db >}} group.
    1. Use Helm to install all other services in this sequence:
         1. Install the service dependencies.
         1. Edit its YAML files to override defaults as needed.
         1. Install through Helm.


  

