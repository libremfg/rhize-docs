---
title: 'Install'
date: '2023-09-22T13:54:26-03:00'
draft: false
category: how-to
description:
weight: 100
menu:
  main:
    parent: deploy
    identifier: install
cascade:
  domain_name: libremfg.ai
  brand_name: Libre
  application_name: libre
---

Follow these steps to create new Rhize installations and secure them in a Kubernetes environment.

## Broad overview

The essential procedure is as follows:

1. **Set up the Kubernetes environment.**
    1. Within a Kubernetes cluster, create a new namespace.
    1. In this namespace, add the Rhize container images and Helm repos.
    1. In the cluster, create secrets for passwords.
    1. Use Helm to install Keycloak.
1. **Configure Keycloak.**
    1. In Keycloak, create a realm and clients for each service.
    1. In the cluster, create client secrets from Keycloak.
    1. Use Helm to install {{< param db >}} .
    1. In Keycloak, give {{< param db >}} admin permissions.
1. **Install services.** For each service, installation involves the following:
    1. Ensuring dependencies are installed.
    1. Editing their YAML files to override defaults as needed.
    1. Installing through Helm.
  
