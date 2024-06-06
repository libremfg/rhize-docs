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
| Version      | The version of the object (and each version has a [state](#version-states))            |
| Description  | Freeform text to describe what the object does and help colleagues understand its role |

### Version states

Each version of an object can have the following states:
- `Draft`
- `Active`
- `For review`
- `Deprecated`


{{< notice "note" >}}
When recording actual execution, what matters is version of the object, not its general definition.
Thus, **to add a class to an object, you must give that object a version first.**
{{< /notice >}}


## Common models

_Common models_ are data objects that can apply to different resources in your manufacturing process

### Units of Measure {#uom}

A _Unit of measure_ is a defined unit to consistently compare values, duration or quantities.

You can create units of measure in the UI and give them the following parameters:
- Name
- Data type

### Data Sources

A _data source_ is a source of real-time data that is collected by the Rhize agent.
For example, in a baking process, a data source might be an OPC UA server that sends readings from an oven thermometer.

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

### Hierarchy Scope

The _hierarchy scope_ represents the scope within which data information is exchanged.
It provides a flexible way to group entities and data outside of the scope defined by the role-based equipment hierarchy.

## Resource models

_Resource models_ are data objects that have a specific role in your role-based equipment hierarchy.

### Equipment class

An _equipment class_ is a grouping of [equipment](#equipment) for a definite purpose.
For example, in a baking process, an equipment class might be the category of all ovens, with properties such as `maximum temperature` and `number of shelves`.

<!---
Equipment has **Rules**, which... -->

Along with the [Global properties](#global-object-fields), an equipment class can include an indefinite number of properties with the following fields:

| Properties      | Description                              |
|-----------------|------------------------------------------|
| Name            | Name of the property                     |
| Description     | A freeform text to describe the property |
| Unit of measure | The properties (unit of measure)[#uom]   |
<!--
| Expression      |                                          | -->

### Equipment

A piece of _equipment_ is a tool with a defined role in a [process segment](#process-segment).
For example, in a baking process, equipment might be a specific brownie oven.

Equipment also might be part of hierarchy of levels, starting with Enterprise and ending with granular levels such as `WorkUnit`.

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

### Material Class

A _material class_ is a group of material with a shared purpose in the manufacturing process.

{{% introTable.inline "material-class" /%}}

| General fields         | Description                                                                                                                                                                                                             |
|------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Assembly type          | Can be one of: <ol type="a"><li>`Logical`: the components of the material are not necessarily physically connected</li><li>`Physical`: the components of the material are physically connected or in the same location</li><ol> |
| Relationship           | Can be one of: <ol type="a"><li>`Permanent`, if a material that can't be split from the production process</li><li> `Transient`, for temporary material in assembly, such as a pallet</li></ol>
| Hierarchy scope        | The [hierarchy scope](#hierarchy-scope) that material class belongs to                                                                                                                                                              |
| Includes properties of | One or more material classes that a version inherits properties from                                                                                                                                                                            |
| Is assembled from      | Material classes that make this material                                                                                                                                                                                |

Material classes may have an indefinite number of properties with parameters for the following fields:
- Value
- [Unit of measure](#uom)

### Material definition

_Materials_ are everything required to produce a finished good.
They include raw materials, intermediate materials, and collections of parts.

{{% introTable.inline "material" /%}}

| General        | Description                                                                                  |
|----------------|----------------------------------------------------------------------------------|
| Material class | One or more [material classes](#material-class) that a version inherits properties from |


Materials may have an indefinite number of properties with parameters for the following fields:
- Value
- [Unit of measure](#uom)

### Personnel Class

A _personnel class_ is a grouping of persons whose work shares a definite purpose in the manufacturing process.
In a baking process, an example of a personnel class may be `oven_operators`.

{{% introTable.inline "personnel-class" /%}}

| General fields  | Description                                                                                   |
|-----------------|------------------------------------------------------------------------------------|
| Hierarchy scope | The [hierarchy scope](#hierarchy-scope) within which this personnel exchanges data |

### Person

A _person_ is a unique member of [personnel class](#personnel-class).

{{% introTable.inline "person" /%}}

| General fields            | Description                                                |
|---------------------------|------------------------------------------------------------|
| Name                      | The name of the person                                                            |
| Hierarchy scope           | The [hierarchy scope](#hierarchy-scope) that the person belongs to                                                            |
| Inherit personnel classes | One or more personnel classes that a version inherits properties from  |
| Operational location      | The associated [Operational location](#operational-location) |

### Physical asset class

A _physical asset class_ is a class of [physical assets](#physical-assets).

The physical asset class has properties for:
- ClassType
- Value
- Unit of measure

### Physical Asset

A _physical asset_ is portable or swappable equipment.
In a baking process, a physical asset might be the laser jet printer which adds labels to the boxes (and could be used in many segments across the plant).

In many cases, your process may need to model only [equipment](#equipment), not physical assets.


### Operational Location Class

An _operational location_ class is a grouping of [operational locations](#operational-location) for a defined purpose.
For example, in a baking process, an operational location class may be `Kitchens`

{{% introTable.inline "operational-location-class" /%}}

| General fields                     | Description                                                                                  |
|------------------------------------|-----------------------------------------------------------------------------------|
| Hierarchy scope                    | The [hierarchy scope](#hierarchy-scope) within which this location exchanges data |
| Inherit Operational location class | One or more Operational location classes that a version inherits properties from                       |

### Operational Location

An _operational location_ is where resources are expected to be located in a plant.
For example, in a baking process, an operational location class may be `northwing_kitchen_A`

{{% introTable.inline "operational-location" /%}}

| General fields               | Description                                                                       |
|------------------------------|-----------------------------------------------------------------------------------|
| Hierarchy scope              | The [hierarchy scope](#hierarchy-scope) within which this location exchanges data |
| Operational location classes | Zero or more [operational location classes](#operational-location-class) that a version inherits properties from                         |
| Map view                     | Where the location is on the map                                                  |

## Operation models

_Operation models_ are data objects that describe manufacturing processes from the perspective of the level-4 (ERP) systems.

### Process segment

A _process segment_ is a step in a manufacturing activity that is visible to a business process, grouping the necessary personnel, material, equipment, and physical assets.
In a baking process, an example segment might be `mixing`.

You can associate specifications for:
- Equipment, Material, Personnel, and Physical Assets

{{% introTable.inline "process-segment" /%}}

| General fields           | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| Operations type          | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality`         |
| Definition type          | One of: `Instance`, `Pattern`                                                     |
| Duration                 | The expected duration                                                         |
| Duration unit of measure | The time [unit of measure](#uom)                                              |
| Hierarchy scope          | The [hierarchy scope](#hierarchy-scope) within which data is exchanged for this process segment |

You can add additional parameters for:
- Name
- Value
- Unit of measure
  
### Operations Definition

_Operations Definitions_ describe how resources come together to manufacture product from the perspective of 
the level-4 (ERP) systems.

The operation model carries enough detail to plan the work at resolutions of hours and days. For more granularity, refer to [work models](#work-models).

{{% introTable.inline "operations-definition" /%}}

| General fields  | Description                                                                                           |
|-----------------|-------------------------------------------------------------------------------------------------------|
| Operation type  | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality`                                 |
| Hierarchy scope | The [hierarchy scope](#hierarchy-scope) within which data is exchanged for this operations definition |

### Operations event class

An _operations event class_ defines a class of operations events within some hierarchy.

The class has the following properties:
- **Version**
- **Operations event classes,** defining one or more operations event classes that a version inherits properties from

### Operations event definition

An _operations event definition_ defines the properties that pertain to an _event_ from the perspective of the level-4 (ERP) systems.
Along with the event itself, it may have associated resources, such as material lots or physical assets received.

{{% introTable.inline "operations-event-definition" /%}}


| Field                    | Description                                                                                                                                                                                                                                                                      |
|--------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Category                 | A string that can be used to group the event                                                                                                                                                                                                                                                               |
| Source                   |    The activity, function, task or phase that generated the event.       |
| Event type               | One of: <ol type="a"><li>`Alert`, an potentially significant event, such as a workflow trigger, that does not require notification</li><li> `Alarm`, an event that requires notification</li> <li>`Event`, any other event that is not at the level of alarm or alert</li></ol> |
| Operations event classes | One or more [operations event classes](#operations-event-class) that a version definition inherits properties from.                                                                                                                                  |

## Work models

_Work models_ describe how the resources come together to manufacture product from the perspective of level-3 (MES) systems.
As with [Operations models](#operations-models), 
the steps in the process are called _segments_.

The work model carries enough detail to plan the work at resolutions of hours and minutes. For less granularity, refer to [operations definitions](#operations-definitions).

### Work Master

A _work master_ is a template for a job order from the perspective of the level-3 (MES/MOM) systems.
In a baking process, an example work master might be `Brownie Recipe`.

{{% introTable.inline "work-master" /%}}

| General fields           | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| Workflow type            | One of: ` Inventory`, `maintenance`, `mixed`, `production`, `quality` |
| Workflow specification   | An associated BPMN workflow                                           |


### Work calendar

_Work calendars_ describe a set of rules for specific calendar entries, including duration, start and end dates, and times.

The general fields for a calendar duration are as follows:

| General fields  | Description                             |
|-----------------|-----------------------------------------|
| Description     | A description of the work calendar      |
| Hierarchy scope | The [hierarchy scope](#hierarchy-scope) that defines scope of data exchanged for the calendar entries |

The work calendar can have properties with a `description`, `value`, and [`unit of measure`](#uom).

The work calendar object can have one or more _entries_, which define the start, end, duration, and recurrence of a rule.
The duration and recurrence attributes for a time-based rule are represented by the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) standard.
The attributes for an entry are as follows:

| Entry fields             | Description                                                                                                                                              |
|--------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------|
| Description              | Freeform text that describes the entry                                                                                                                  |
| Type                     | One of: `PlannedBusyTime`, `PlannedDownTime`, and `PlannedShutdown`                                                                                      |
| Start date and time      | When the entry starts                                                                                                                                    |
| End date and time        | When the entry finishes                                                                                                                                  |
| Recurrence time interval | How often the entry repeats according to the [repeating interval representation](https://en.wikipedia.org/wiki/ISO_8601#Repeating_intervals) of IS0 8601 |
| Duration rule            | How long the work calendar lasts, according to the [Duration representation](https://en.wikipedia.org/wiki/ISO_8601) of IS0 8601.                        |

