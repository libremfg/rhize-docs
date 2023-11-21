---
title: 'Master definitions and fields'
date: '2023-11-15T16:29:21-03:00'
draft: false
categories: ["reference"]
description: >-
  A reference of all manufacturing data objects and properties that you can create in the Rhize UI
weight: 100
menu:
  main:
    parent: how-to-define
    identifier: master-definitions

---

To make a production object visible to the Rhize data hub, you must define it as a data model.

These sections document all the objects that you can add through the UI, and the fields and properties that you can associate with them.
All these models are based on the ISA-95 standard, mostly from [Part 2](https://www.isa.org/products/ansi-isa-95-00-02-2018-enterprise-control-system-i), which describes the role-based equipment hierarchy.



## Global object fields

All objects that you define must have a unique name.
Additionally, most objects have the following fields:

| Global field | Description                                                                            |
|--------------|----------------------------------------------------------------------------------------|
| Version      | The version of the object (and each version has a [state](#version-states))              |
| Description  | Freeform text to describe what the object does and help colleagues understand its role |

### Version states

Each version of an object can have the following states:
- `Draft`
- `Active`
- `For review`
- `Deprecated`

## Equipment


A piece of _equipment_ is a tool with a defined role in a [process segment](#process-segment).
For example, in a baking process, equipment might be a specific brownie oven.

Along with the following fields, you can also connect an equipment item to a [data source](#data-source), add additional properties, and toggle it to be active or inactive.

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

Along with the [Global properties](#global-object-fields), an equipment class can include an indefinite number of properties with the following fields:

| Properties      | Description                              |
|-----------------|------------------------------------------|
|
| Name            | Name of the property                     |
| Description     | A freeform text to describe the property |
| Unit of measure | The properties (unit of measure)[#uom]   |
<!--
| Expression      |                                          | -->

## Data Sources

A _data source_ is a source of real-time data that is collected by the Rhize agent.
The general fields for a data source are as follows:

| General fields           | Description                                                                         |
|--------------------------|-------------------------------------------------------------------------------------|
| Connection string        | A string to specify information about the data source and the way to connect to it  |
| The Data source protocol | Either `MQTT` or `OPCUA`                                                            |
| username                 | If needed, username for [Agent authentication]({{< ref "agent-configuration" >}})    |
| password                 | If needed, password for [Agent authentication]({{< ref "agent-configuration" >}})    |
| certificate              | If needed, certificate for [Agent authentication]({{< ref "agent-configuration" >}}) |

Additionally, each data source can have _topics_ that Rhize should be able to subscribe to.
Each topic has the following fields:

| Topic field       | Description                                                                   |
|-------------------|-------------------------------------------------------------------------------|
| Data type         | The data type Rhize expects to find when it receives data from that topic     |
| Deduplication key | The field that NATS uses to de-duplicate messages from multiple data sources. |
| Label             | The name of the topic on the side of the data source                          |
| Description       | A freeform text field to add context                                          |

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

A _material class_ is a group of material with a shared purpose in the manufacturing process.

{{% introTable.inline "material class" /%}}

| General fields         | Description                                                                                                                                                                                                             |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Assembly type          | Can be one of: <ol type="a"><li>Logical: the components of the material are not necessarily physically connected</li><li>Physical: the components of the material are physically connected or in the same location</li><ol> |
| Relationship           | Can be one of: <ol type="a"><li>`Permanent`, if a material that can't be split from the production process</li><li> `Transient`, for temporary material in assembly, such as a pallet</li></ol>
| Hierarchy scope        | The [hierarchy scope](#hierarchy-scope) that material class belongs to                                                                                                                                                              |
| Includes properties of | One or more material classes to inherit properties from                                                                                                                                                                            |
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

A _personnel class_ is a grouping of persons whose work shares a definite purpose in the manufacturing process.
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

## Operational Location Class

An _operational location_ class is a grouping of [operational locations](#operational-locations) for a defined purpose.
For example, in a baking process, an operational location class may be `Kitchens`

{{% introTable.inline "operational location class" /%}}

| General fields                     | Description                                                                                  |
|------------------------------------|-----------------------------------------------------------------------------------|
| Hierarchy scope                    | The [hierarchy scope](#hierarchy-scope) within which this location exchanges data |
| Inherit Operational location class | The Operational location classes to inherit properties from                       |



## Physical Asset

A _physical asset_ is portable or swappable equipment.
In a baking process, a physical asset might be the laser jet printer which adds labels to the boxes (and could be used in many segments across the plant).

In many cases, your process may need to model only [equipment](#equipment), not physical assts.



## Physical asset class

A _physical asset class_ is a class of [physical assets](#physical-assets).

The physical asset class has properties for:
- ClassType
- Value
- Unit of measure


## Operations Definition

An _operations definition_ defines the resources required to perform an operation, including for production, quality, maintenance, and inventory, from the perspective of the level-4 enterprise control systems.

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

A _Unit of measure_ is a defined unit to consistely compare values, duratation or quantities.

You can create units of measure in the UI and give them the following parameters:
- Name
- Data type

## Process segment

A _process segment_ is a step in a manufacturing activity that is visible to a business process, grouping the necessary personnel, material, equipment, and physical assets.
In a baking process, an example segment might be `mixing`.

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

A _work master_ is a template for a job order from the perspective of the level-3 (MES/MOM) systems.
In a baking process, an example work master might be `Brownie Recipe`.

{{% introTable.inline "work master" /%}}

| General fields           | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| Workflow type            | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality` |
| Workflow specification   | An associated BPMN workflow                                           |
