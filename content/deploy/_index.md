---
title: Deploy
description: >-
  A collection of pages to administrate Rhize: install, upgrade, back up, and more.
weight: 100
identifier: deploy
cascade:
  domain_name: libremfg.ai
  brand_name: Libre
  application_name: libre
  db: libreBaas
  pre_reqs: |-
    - Optional: [kubectx](https://github.com/ahmetb/kubectx) utilities
        - `kubectx` to manage multiple clusters
        - `kubens` to switch between and configure namespaces easily
    - Optional: the [k8 Lens IDE](https://k8slens.dev), if you prefer to use Kubernetes graphically
  k8s_cluster_ns: |-
    ```bash
    ## context
    kubectl config current-context
    ## namespace
    kubectl get namespace
    ```

    To change the namespace for all subsequent `kubectl` commands to `libre`, run this command:

    ```bash
    kubectl config set-context --current --namespace=libre
    ```

    For a reference of useful `kubectl` commands, refer to the official [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/).

---

A collection of pages to administrate Rhize: install, upgrade, back up, and more.
