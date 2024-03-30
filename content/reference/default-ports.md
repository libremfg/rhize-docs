---
title: 'Default URLs and local ports'
date: '2023-11-02T16:49:42-03:00'
draft: false
categories: ["reference"]
description: "A list of the default ports for the various Rhize services"
weight: 900
menu:
  main:
    parent: reference
    identifier:
---

After you [install Rhize services](/deploy/install/services), they are accessible, by default, on the following ports:

| Service                   | Default Port                       |
|---------------------------|------------------------------------|
| Admin UI                  | [`localhost:3030`](http://localhost:3030) |
| Grafana                   | [`localhost:3001`](http://localhost:3001) |
| Router                    | [`localhost:4000`](http://localhost:4000) |
| Keycloak                  | [`localhost:8090`](http://localhost:8090) |
| `baas-alpha` command line | [`localhost:8080`](http://localhost:8080) |

## URLs

When you create DNS records, Rhize recommends the following URLs:

{{< reusable/default-urls >}}
