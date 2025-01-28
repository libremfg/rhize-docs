---
title: User guides
description: Topics about how to use Rhize to query data, build and run workflows, and build frontends.
weight: 200
identifier: how-to
icon: clipboard-list
cascade:
  domain_name: libremfg.ai
  brand_name: Libre
  application_name: libre
  pre_reqs: |-
    - Permissions to access the [Rhize Kubernetes Environment](/how-to/install/configure-kubernetes")
    - [kubectl](https://kubernetes.io/docs/tasks/tools/)
    - Optional: [kubectx](https://github.com/ahmetb/kubectx) utilities
        - `kubectx` to manage multiple clusters
        - `kubens` to switch between and configure namespaces easily
    - Optional: the [k8 Lens IDE](https://k8lens.dev), if you prefer to manage Kubernetes graphically
  k8s_cluster_ns: |-
    ```bash
    ## context
    kubectl config current-context
    ## namespace
    kubectl get namespace
    ```
---

Topics about how to use Rhize to query data, build and run workflows, and build frontends.
