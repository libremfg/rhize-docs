---
title: 'Work masters reference'
date: '2023-11-15T16:29:21-03:00'
draft: false
categories: ["reference"]
description:
weight: 100
menu:
  main:
    parent: how-to
    identifier:
rule:  A boolean expression that, if it evaluates to `true`, triggers or creates an instance of a workflow.

---

To make a production object visible to the Rhize data hub, you must define it as a data model.
For a no-code interface to define an object, use the Work masters UI.

These sections document all the objects that you can add through the UI, and the fields and properties that you can associate with them.
All these models are based on the ISA-95 standard, and most are explictely defined in Part two, which describes the Role-based equipment hierarchy.

Often, one object references another: for example, a piece of equipment may belong to an equipment class, have a unit of measure as a property, and be associated with process segment.
These associations form nodes and edges in your knowledge graph, so the more information relationships that you accurately create, the better.

{{< notice "note" >}}

The Work masters UI works best for objects you infrequently update.
For batch uploads, consider using the GraphQL API or a BPMN process.

{{< /notice >}}


## Global object fields

All objects that you define must have a unique name.
Additionally, most objects have the following fields

| Global field | Description                                                                           |
|--------------|---------------------------------------------------------------------------------------|
| Version      | The version of the object                                                             |
| Description  | Freeform text to describe what the object does and help colleagues understand its role |

### Version states

Each version state can have the following states:
- `Draft`
- `Active`
- `For review`
- `Deprecated`

## Equipment

A piece of _equipment_ is a tool with a defined role in a [process segment](#process-segment).
In a baking process, an example of equipment might be a specific brownie oven.

Along with the preceding fields, you can also connect an equipment item to a [data source](#data-source), add additional properties, and toggle it to be active or inactive.

{{% introTable.inline "equipment" %}}
{{ $term := (.Get 0) }}
{{ $vowels := slice "a" "e" "i" "o" "u" }}
Along with the [global object fields](#global-object-fields),
{{cond (in $vowels (index (split (lower $term) "") 0 )) "an" "a" }}
{{ $term }} object has the following fields:
{{% /introTable.inline %}}


| General equipment fields  | Description                                                                                                                                                                                                                                                        |
|-----------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Equipment class | The [class of equipment](#equipment-class) that it belongs to.                                                                                                                                                                                                     |
| Equipment level | Associated level for the equipment. One of:  `Enterprise`, `Site`, `Area`, `ProcessCell`, `Unit`, `ProductionLine`, `WorkCell`, `ProductionUnit`, `Warehouse`, `StorageZone`, `StorageUnit`, `WorkCenter`, `WorkUnit`, `EquipmentModule`, `ControlModule`, `Other` |



## Equipment class

An _equipment class_ is a grouping of [equipment](#equipment) for a definite purpose.
For example, in a baking process, an equipment class might be the category of all ovens, with properties such as `maximum temperature` and `number of shelves`.

<!---
Equipment has **Rules**, which... -->

Along with the [Global properties](#global-object-fields), an equipment class can include an indefinite number of properties with the following fields.

| Properties      | Description                              |
|-----------------|------------------------------------------|
|
| Name            | Name of the property                     |
| Description     | A freeform text to describe the property |
| Unit of measure | The properties (unit of measure)[#uom]   |
<!--
| Expression      |                                          | -->

## Data Sources

A _Data source_ is a source of real-time data that is collected by the Rhize agent.

| General fields           | Description                                                                         |
|--------------------------|-------------------------------------------------------------------------------------|
| Connection string        | A string to specify information about the data source and the way to connect to it  |
| The Data source protocol | Either `MQTT` or `OPCUA`                                                            |
| username                 | If needed, username for [Agent authentication]({{< ref "agent-configuration" >}})    |
| password                 | If needed, password for [Agent authentication]({{< ref "agent-configuration" >}})    |
| certificate              | If needed, certificate for [Agent authentication]({{< ref "agent-configuration" >}}) |

Each data source has topics with the following fields:

| Topics fields     | Description |
|-------------------|-------------|
| Data type         |             |
| Deduplication key |             |
| Label             |             |
| Description       |             |

Some data sources, such as OPC UA, have methods for RPC calls.

## Material definition

_Materials_ are everything required to produce a finished good.
They include raw materials, intermediate materials, and collections of parts.

{{% introTable.inline "material" /%}}

| General        |                                                                                  |
|----------------|----------------------------------------------------------------------------------|
| Material class | One or more [material classes](#material-class) that it inherits propreties from |


Materials may have an indefinite number of properties with parameters for the following fields:
- Value
- [Unit of measure](#uom)

## Material Class

A _material class_ is {{< dfn "material class" >}}.

{{% introTable.inline "material class" /%}}

| General fields         | Description                                                                                                                                                                                                             |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Assembly type          | Can be one of: <ol type="a"><li>Logical: the components of the material are not necessarily physically connected</li><li>Physical: the components of the material are physically connected or in the same location</li><ol> |
| Relationship           | Can be one of: <ol type="a"><li>`Permanent`, if a material that can't be split from the production process</li><li> `Transient`, for temporary material in assembly, such as a pallet</li></ol>
| Hierarchy scope        | the [hierarchy scope](#hierarchy-scope) that it belongs to                                                                                                                                                              |
| Includes properties of | One or more material class to inherit properties from                                                                                                                                                                            |
| Is assembled from      | Material classes that make this material                                                                                                                                                                                |

Material classes may have an indefinite number of properties with parameters for the following fields:
- Value
- [Unit of measure](#uom)

## Person

A _person_ is a unique member of [personnel class](#personnel-class).

{{% introTable.inline "person" /%}}

| General fields            | Description                                                |
|---------------------------|------------------------------------------------------------|
| Name                      | The name of the person                                                            |
| Hierarchy scope           | The [hierarchy scope](#hierarchy-scope) that the person belongs to                                                            |
| Inherit personnel classes | One ore more personnel classes to inherit properties from  |
| Operational location      | The associated [Operational location](#operation-location) |

## Personnel Class

A _personnel class_ is {{< dfn "personnel class" >}}.
In a baking process, an example of a personnel class may be `oven_operators`.

{{% introTable.inline "personnel class" /%}}

| General fields  | Description                                                                                   |
|-----------------|------------------------------------------------------------------------------------|
| Hierarchy scope | The [hierarchy scope](#hierarchy-scope) within which this personnel exchanges data |

## Operational Location

An _operational location_ is where resources are expected to be located in a plant.
For example, in a baking process, an operational location class may be `northwing_kitchen_A`

{{% introTable.inline "operational location" /%}}

| General fields               | Description                                                                       |
|------------------------------|-----------------------------------------------------------------------------------|
| Hierarchy scope              | The [hierarchy scope](#hierarchy-scope) within which this location exchanges data |
| Operational location classes | Zero or more [operational location classes](#operational-location-class) to inherit properties from                         |
| Map view                     | Where the location is on the map                                                  |

## Physical Asset

A _physical asset_ is portable or swappable equipment.
In a baking process, a physical asset might be the laser jet printer which adds labels to the boxes (and could be used in many segments across the plant).

In many cases, you only need to model [equipment](#equipment).



## Physical asset class

A _physical asset class_ is a class of [physical assets](#physical asset).

The physical asset class has properties for:
- ClassType
- Value
- Unit of measure


## Operational Location Class

An operational location class is a grouping of operational locations for a defined purpose.
For example, in a baking process, an operational location class may be `Kitchens`

{{% introTable.inline "operational location class" /%}}

| General fields                     | Description                                                                                  |
|------------------------------------|-----------------------------------------------------------------------------------|
| Hierarchy scope                    | The [hierarchy scope](#hierarchy-scope) within which this location exchanges data |
| Inherit Operational location class | The Operational location classes to inherit properties from                       |


## Operations Definition

An _operations definition_ is {{< dfn "operations definition" >}}.
For example, in a baking process, an operations definition might be `Brownie_Master_Recipe`.

{{% introTable.inline "operations definition" /%}}

| General fields  | Description                                                                                     |
|-----------------|-------------------------------------------------------------------------------------------------|
| Operation type  | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality`                           |
| Hierarchy scope | The [hierarchy scope](#hierarchy-scope) within which data is exchanged for this operations definition |


## Hierarchy Scope

The _hierarchy scope_ represents the scope within which data information is exchanged. For example, in a baking process, two plants may have different personnel and equipment, even if they both produce the identical final products.
The hierarchy scope defines a scope where all granular data within is relevant to it.

While hierarchy scope is often connected to an [operational location](#operational-location), the determining is about _information exchange_.

## Units of Measure {#uom}

A _Unit of measure_ is {{< dfn "unit of measure" >}}.

You can create units of measure in the UI and give them the following parameters:
- Name
- Data type

## Process segment

A _process segment is a {{< dfn "process segment" >}}.

You can associate specifications for:
- Equipment, Material, Personnel, and Physical Assets

{{% introTable.inline "Process segment" /%}}

| General fields           | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| Operations type          | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality`         |
| Definition type          | One of: Instance, Pattern                                                     |
| Duration                 | The expected duration                                                         |
| Duration unit of measure | The time [unit of measure](#uom)                                              |
| Hierarchy scope          | The [hierarchy scope](#hierarchy-scope) within which data is exchanged for this process segment |

You can add additional parameters for:
- Name
- Value
- Unit of measure

## Work Master

A _work master_ is {{< dfn "work master" >}}.

{{% introTable.inline "work master" /%}}

| General fields           | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| Workflow type            | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality` |
| Workflow specification   | An associated BPMN workflow                                           |
