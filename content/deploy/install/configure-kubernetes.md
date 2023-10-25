---
title: 'Install Rhize on Kubernetes'
date: '2023-09-22T14:49:53-03:00'
draft: true
categories: how-to
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

## Broad overview

The essential procedure is as follows:

1. Within a Kubernetes cluster, create a new namespace.
1. In this name space, add the Rhize container images and Helm repos.
1. Install Keycloak, to manage authentication for users and services
1. Install services. For each service, installation involves:
    1. Ensuring dependencies are installed.
    1. Overriding any defaults.
    1. Installing through Helm.


