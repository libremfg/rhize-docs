---
title: About KPI Service and overrides
description: >-
  An explanation of how the Rhize KPI service works
weight: 200
---

{{< experimental-kpi >}}

Key Performance Indicators (KPIs) in manufacturing are metrics to help monitor, assess, and optimize the performance of various aspects of your production process.

Rhize has an optional `KPI` service that queries process values persisted to a time-series database and then calculates various KPIs.
Rhize's implementation of work calendars is inspired by ISO/TR [22400-10](https://www.iso.org/obp/ui/?_escaped_fragment_=iso:std:71283:en), a standard on KPIs in operations management.

## What the service does

```mermaid
sequenceDiagram
    actor U as User
    participant K as KPI Service
    participant TSDB as Time Series Database

    U->>K: Query KPI in certain interval
    K->>TSDB: Query State Records
    TSDB->>K: Response: State records
    K->>TSDB: Query Quantity Records
    TSDB->>K: Response: Quantity records
    K->>TSDB: Query JobResponse Records
    TSDB->>K: Response: JobResponse records
    K-->>TSDB: (Optional:) Query Planned Downtime Records
    TSDB-->>K: Response: Downtime Records
    K-->>TSDB: (Optional:) Query Shift Records
    TSDB-->>K: Response: Downtime Records
    K->>K: Calculate KPIs
    K->U: Response: KPI Result
```

The KPI service provides an interface in the graph database for the user to query a list of pre-defined KPIs on a piece of equipment in the `equipmentHierarchy` within a certain time interval.
The service then queries the time-series database for all state changes, produced quantities, and job response data.
With the returned data, the service calculates the KPI value and returns it to the user.

## Supported KPIs

The service supports all KPIs described by the ISO/TR 22400-10,
along with some other useful KPIs:

- `ActualProductionTime`
- `ActualUnitSetupTime`
- `ActualSetupTime`
- `ActualUnitDelayTime`
- `ActualUnitDownTime`
- `TimeToRepair`
- `ActualUnitProcessingTime`
- `PlannedShutdownTime`
- `PlannedDownTime`
- `PlannedBusyTime`
- `Availability`
- `GoodQuantity`
- `ScrapQuantity`
- `ReworkQuantity`
- `ProducedQuantityMachineOrigin`
- `ProducedQuantity`
- `Effectiveness`
- `EffectivenessMachineOrigin`
- `QualityRatio`
- `OverallEquipmentEffectiveness`
- `ActualCycleTime`
- `ActualCycleTimeMachineOrigin`

