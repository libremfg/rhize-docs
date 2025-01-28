---
title: 'Use the KPI service'
categories: "how-to"
description: How to configure KPI Service to record key ISO22400 OEE Metrics.
weight: 500
cascade: 
  experimental: true
---

{{< experimental-kpi >}}

The KPI service records {{< abbr "equipment" >}}-centric metrics related to the manufacturing operation.
To use it, you must:
1. Record machine state data using the [rule pipeline]({{< relref "/how-to/publish-subscribe/create-equipment-class-rule/" >}}).
1. Persist this data to a time-series database.

