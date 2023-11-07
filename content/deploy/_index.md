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
  db: libreBaaS
  pre_reqs: |-
    - Optional: [kubectx](https://github.com/ahmetb/kubectx) utilities
        - `kubectx` to manage multiple clusters
        - `kubens` to switch between and configure namespaces easily
    - Optional: the [k8 Lens IDE](https://k8lens.dev), if you prefer to use Kubernetes graphically
  k8s_cluster_ns: |-
    ```bash
    ## context
    kubectl config current-context
    ## namespace
    kubectl get namespace
    ```
    
---

A collection of pages to administrate Rhize: install, upgrade, back up, and more.
