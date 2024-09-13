---
title: 'Use the KPI service'
date: '2024-09-03T00:00:00Z'
draft: true
categories: "how-to"
description: How to configure KPI Service to record key ISO22400 OEE Metrics.
weight: 500
menu:
  main:
    parent: how-to
    identifier: howto-kpi-service
---

The KPI service allows users to record {{< abbr "equipment" >}}-centric metrics related the their operation. It requires recording machine state data using the [rule pipeline]({{< relref "/how-to/publish-subscribe/create-equipment-class-rule/" >}}) and persisting to a time series database.
