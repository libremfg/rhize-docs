---
title: >-
  Calculate OEE
description: The Rhize guide to modelling and querying OEE
categories: ["howto", "use-cases"]
weight: 0100
menu:
  main:
    parent: use-cases
    identifier: calculate-oee
---

This guide provides a high-level overview of how to use Rhize to calculate various key performance indicators (KPIS), including Overall equipment effectiveness.
As an example the implementation section walks through a full end-to-end solution.

## Outline

OEE is a key performance indicator that measures how effectively a manufacturing process uses its equipment.
As defined in [{{< abbr "ISO 22400" >}}](https://www.iso.org/standard/56847.html), OEE measures the ratio of actual output to the maximum potential output.
To calculate this, the metric evaluates three primary factors:
- Availability
- Performance
- Quality

This measure is a common method in manufacturing to assess and improve production efficiency in industrial operations.

## Background: ISA95 architecture for OEE

The following diagram shows the ISA-95 entities that are involved with OEE calculations.

{{< bigFigure
src="/images/oee/data-architecture.svg"
alt="A diagram showing the overall isa95 architecture required for OEE calculations. It shows the relationship between the relationship between the Work Schedule, Operations Performance, Role Based Equipment and work calendar models."
caption="A diagram showing the overall ISA95 architecture involved in making OEE calculations."
width="90%"
>}}

## Implement OEE in Rhize

### Pre Requisties

Before you start, ensure you have the following:
- Rhize installed and configured, including timeseries tools

This implementation guide also involves doing the following actions in Rhize:

- [Use the rules engine to persist process values]({{< relref "how-to/publish-subscribe/create-equipment-class-rule" >}})
- [Use messages to trigger BPMN workflows]({{< relref "how-to/bpmn/create-workflow" >}})
- [Use user-triggered workflows]({{< relref "how-to/bpmn/create-workflow" >}})

### Overall system architecture

```mermaid
sequenceDiagram
Actor U as user
participant M as Machine
participant A as libre-agent
participant C as libre-core
participant B as bpmn-engine
participant G as graph database
participant T as timeseries database
loop each process value message received
M->>A:Process Values Published to broker
A->>A:Values deduplicated
A->>C:Values ingested
C->>C:Bound to equipment properties
C->>C:Rules evaluated
C->>B:BPMN triggered
B->>G:Data persisted
B->>T:Data persisted
end
loop each user involvement
U->>B:BPMN Triggered by operator's frontend
B->>B:Process runs, transforming data
B->>G:Data Persisted
B->>T:Data persisted
end
```

## Handle real-time values

For detailed information see: [How To: Create equipment class rule]({{< relref "how-to/publish-subscribe/create-equipment-class-rule" >}})

The Rhize agent ingests values from an external broker using protocols such as OPCUA, MQTT, Kafka.
The OEE calculation is particularly interested in machine state changes and produced quantities.

Data Flow Diagram:

```mermaid
sequenceDiagram
participant M as Machine
participant A as libre-agent
participant C as libre-core
participant B as bpmn-engine
participant T as timeseries database
M->>A:{<br/>"state":"Running",<br/>"timestamp":"2024-09-04T09:00:00Z"<br/>}
A->>C:{<br/>"dataSource.id":"MQTT",<br/>"payload":<br/>{<br/>"state":"Running",<br/>},<br/>"timestamp":"2024-09-04T09:00:00Z"<br/>}
C->>C:["Machine A.state":{"previous":"Held","current":"Running"},<br/>"timestamp":"2024-09-04T09:00:00Z"]
C->>B:{"EquipmentId":"Machine A",<br/>"State":"Running",<br/>"timestamp":"2024-09-04T09:00:00Z"}
B->>T:{"Table":"EquipmentState",<br/>"EquipmentId":"Machine A",<br/>"State":"APT",<br/>"timestamp":"2024-09-04T09:00:00Z"}
```

Rhize Architecture:

In the preceding diagram, a machine publishes telemetry values to an MQTT server in the following form:

```json
{
  "state": "Running|Held|Stopped",
  "quantityCounter": 10 
}
```

The Rhize rules engine processes these values to run actions when conditions are met.
Including:

- Trigger a BPMN workflow when the machine state changes to persist the value to timeseries

    ```pseudocode
    Trigger Property: State
    Trigger Expression: State.current.value != State.previous.value
    BPMN Variables:
      State: State.Current.value
      Timestamp: SourceTimestamp
      EquipmentId: EquipmentId
    Workflow: RULE_Handle_StateChange
    ```

    The `RULE_Handle_StateChange`workflow is as follows:

    ```mermaid
    flowchart LR
    start((start))-->transform(Transform state
    to ISO22400)
    transform-->map(Map into correct
     JSON Structure)
    map-->throw(throw to NATS to be 
    picked up by time series ingester service
     and persisted to time series)
    throw-->e((end))
    ```

- Trigger a BPMN workflow when the produced quantity value changes to perist the value to timeseries

    ```pseudocode
    TriggerProperty: QuantityCounter
    TriggerExpression QuantityCounter.current.Value != QuantityCounter.previous.Value
    BPMN Variables:
      QuantityDelta: State.current.value - State.previous.value
      Timestamp: SourceTimestamp
      EquipmentId: EquipmentId
    Workflow: RULE_Handle_QuantityChange
    ```

    The `RULE_Handle_QuantityChange` workflow is as follows:

    ```mermaid
    flowchart LR
    start((start))-->map(Map into correct
     JSON Structure)
    map-->throw(throw to NATS to be 
    picked up by time series ingester service
     and persisted to time series)
    throw-->e((end))
    ```

### Import orders

In this scenario, a production order is published to the MQTT server. The Rhize agent bridges the message to the NATS broker.

The production order contains information such as operations, materials produced, and consumed and any particular equipment requirements.
It includes the planned rate of production for each operation, added as a job order parameter.
The import workflow listens for the order to be published to NATS, then maps the data into ISA95 entities, and perists to the graph database.

Workflow NATS_ImportOrder:

```mermaid
flowchart LR
start((start))-->map(Map into correct
 ISA95 Structure)
map-->mutate(Persist to graph database)
mutate-->e((end))
```

### User orchestrated workflow

An operator has the responsibility to start and stop operations as well as record the quantities of good and scrap material.
These values must be persisted to the time-series database (see TODO:Link and TODO:Link).
These workflows will be triggered by an API call from the operations' front end.

Workflows:

API_StartOperation

```mermaid
flowchart LR
start((start))-->query(Query: Lookup job order)
query-->map1(Map: Map job response input)
map1-->mutate(Mutate: add job response to graphql database)
mutate-->map2(Map: jobOrderState payload)
map2-->mutate2(Persist: Add record to time series database)
mutate2-->e((end))
```

API_EndOperation

```mermaid
flowchart LR
start((start))-->query(Query: Lookup currently running job response)
query-->map1(Map: Map job response input)
map1-->mutate(Mutate: update job response with end data time)
mutate-->map2(Map: jobOrderState payload)
map2-->mutate2(Persist: Add record to time series database)
mutate2-->e((end))
```

API_RecordProducedQuantities

```mermaid
flowchart LR
start((start))-->query(Query: Lookup currently running job response)
query-->map1(Map: Map MaterialActual payload with good/scrap/rework quantities)
map1-->mutate(Mutate: add MaterialActuals linked to job response)
mutate-->map2(Map: QuantityLog payload)
map2-->mutate2(Persist: Add records to time series database)
mutate2-->e((end))
```

#### Dashboarding KPI Queries

Using the KPI Queries, we can create Grafana dashboards which may look as follows:

{{< bigFigure
src="/images/oee/oee-dashboard.png"
alt="A diagram showing the an example of an OEE dashboard in Grafana. It includes key metrics such as Availability, Performance, Quality, Quantites produced and an overall OEE figure"
caption="A diagram showing an example KPI dashboard in Grafana."
width="90%"
>}}
