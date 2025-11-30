---
title: Equipment models in ISA-95
description: A guide to equipment entities and relationships in ISA-95
icon: wrench
images: 
  - "/images/s95/diagram-rhize-isa-equipment-relationships-packing.png"

---

{{% reusable/isa-95-course %}}

Equipment is an object that has a defined role in the production process. 
Equipment can have _properties_, which define some temporary or permanent value,
and can belong to _classes_, which provide templates to define and categorize related objects.

{{< figure
alt="A packaging class, instance and sub units"
src="/images/s95/diagram-rhize-isa-equipment-relationships-packing.png"
>}}

All the equipment entities are connected through relationships.
This page describes what these relationships are and when to use them.


{{< details title="Abstract diagram of equipment entity-relationships" >}}

```mermaid
classDiagram
equipment --> `equipment class` : defined by
`equipment class` o--> `equipment class` :made up of
`equipment class` --> `equipment class` :includes properties of
equipment *--> `equipment property` :has values of
`equipment class` *--> `equipment class property` :has properties of
`equipment class property` <.. `equipment property` :maps to 
equipment o--> equipment : made up of
`equipment property` o--> `equipment property` : contains
`equipment class property` o--> `equipment class property` : contains
```

{{< /details >}}


## The role-based hierarchy


The word _role_ is key to understanding the ISA-95 equipment models.
All equipment has a particular function in the wider operation.
The scope of a role varies widely, from the execution of an enterprise-level schedule to the production of a single unit of material.

Equipment with broader scopes occupy higher _levels_,
and they may be composed of lower-level equipment objects that perform more specialized roles.
This composition of equipment is called
the _role-based equipment hierarchy_.

{{< figure
alt="Role-based equipment hierarchy"
src="/images/s95/diagram-rhize-isa95-equipment-hierarchy.svg"
width="65%"
>}}

Your model can be explicit about the equipment's position in the hierarchy through the `equipmentLevel` attribute.

```mermaid
classDiagram
class equipment {
id: "JF.SF.PA.PackL4.Capper"
description: "Capper line 4"
equipmentLevel: "workUnit"
}

```

Note that the lowest two levels distinguish equipment that has a storage role from equipment that has a production role.

When equipment has a production role, that role typically is scoped to the execution of an order or collection of orders.
For example, in our fictional juice factory, equipment roles include:
- The Springfield plant. A site-level equipment that organizes the production of all brands of juice.
- The sugar storage zone. Where the Springfield site stores raw sugar in silos.
- The mixing unit. a work unit that receives raw coloring, flavoring, and sugar as input and produces a bulk volume of `Cosmic Blue juice` material as output.


The role of work units, equipment on the lowest level, is typically to execute one order at a time. 
For that reason, PLCs and other controls-level equipment is typically below the scope of the ISA-95 equipment model
&mdash;though **the model may provide an interface for PLC to level-3 interaction.**



## Equipment is made up of equipment
 
Equipment is made up of other equipment.
High-level equipment items are composed of equipment items with more granular functions.
For example, the juice factory has a work center, `packaging line 1`, that is composed of 4 lower level units that perform specific packaging functions.

```mermaid
classDiagram
   equipment o--> equipment : made up of
```

### Reasons to use `isMadeOf`

The `isMadeOf` relationship provides a way to organize equipment in its hierarchical structure.
This structure often mimics the spatial hierarchy of the plant or the social hierarchy of the organization.

Besides this, the `isMadeOf` relationship provides a way to do the following:
- **Set required assemblies for sub items**. For example, a process specifies a `Sweeteners storage center` it also logically specifies the equipment that that storage center contains (e.g. `silos`)
- **Query and compare work by zone of interest.** For example, you could compare performance across all packing lines by querying the parent center. 
- **Provide a view of the manufacturing operation that is intelligible from the business perspective.**
The equipment model focuses on the production of new material, not individual controls.  

### Query example: full composition of The Juice Factory


In the RhizeDB, the equipment `isMadeUpOf` relationship can be queried as follows.
This response shows the entire equipment hierarchy for The Juice Factory enterprise.

{{< details title="Query and response" closed="true" >}}
{{% tabs items="Query,Response" %}}
{{% tab %}}

```gql
query enterprise{   
  enterprise: getEquipment(id:"JF.SF") {
    ...active
     isMadeUpOf {
      ...active    
      isMadeUpOf {
        ...active
        isMadeUpOf {
          ...active
          isMadeUpOf {
            ...active
            isMadeUpOf {
              ...active
            }
          }
        } 
      }
    }    
  }
}

fragment active on Equipment{
   activeVersion {
      id
      description
      equipmentLevel
   }
}
```

{{% /tab %}}
{{% tab %}}
```json
{{% reusable/jf %}}
```

{{% /tab %}}
{{% /tabs %}}

{{< /details >}}


## Equipment can have properties

Properties are _key value_ pairs that report some permanent or temporary condition of an object.
Equipment can have 0 or many properties.

```mermaid
classDiagram
equipment *--> `equipment property` :has values of
```

For example, the `Packaging line` work center has the properties:
- `State`, which reports whether the center is active or not.
- `infeed`, the number of empty containers at the beginning of the line
- `outfeed`, the number of filled containers at the end of the line

The value of these properties can used to calculate metrics or trigger workflows.

### Equipment properties can contain properties

A property itself can have a composition of properties.
For example, a unit might have the `dimension` property that contains subproperties of `width` and `height`.

```mermaid
classDiagram
rectangularThing *--> `dimension (property)`  : "has values of"
`dimension (property)` *-->  length : "contains"
`dimension (property)` *-->  width : "contains"

`dimension (property)` *-->  height : "contains"
```


This `contains` relationship creates a container to group granular properties by some commonality. 
It also saves configuration time, since any equipment that has the parent property can logically have its child properties as well.


## Equipment classes define equipment

Similar equipment might be _defined_ by its equipment class.
Classes minimize repetitive modelling of equal equipment and properties.

```mermaid
classDiagram
equipment --> `equipment class` : defined by
```

For example, the `packing line` work center always has a `filler` work unit as part of its composition.
So, when there are 4 `packing lines`, there logically must be 4 fillers.
To avoid individually tracking each filler and its configuration, you can create a `fillers` class that defines each member.

```mermaid
classDiagram
namespace Fillers {
  class `filler line 1`
  class `filler line 2`
  class `filler line 3`
  class `filler line 4`
}
```

### Query example: all members of `Packaging` class


This example queries the Rhize DB for all members of the `Packaging` equipment class.

{{< details title="Example: query class for members" >}}
{{< tabs items="Query,Result" >}}
{{< tab >}}

```gql
query equipmentClass{
  getEquipmentClass(id:"Packaging") {
    id
    equipmentVersions {
      id
      description
    }
  }
}

```
{{< /tab >}}
{{< tab >}}
```json
{
  "data": {
    "getEquipmentClass": {
      "id": "Packaging",
      "equipmentVersions": [
        {
          "id": "JF.SF.PA.PackL1",
          "description": "Packaging line 1"
        },
        {
          "id": "JF.SF.PA.PackL2",
          "description": "Packaging line 2"
        },
        {
          "id": "JF.SF.PA.PackL3",
          "description": "Packaging line 3"
        },
        {
          "id": "JF.SF.PA.PackL4",
          "description": "Packaging line 4"
        }
      ]
    }
  }
}

```
{{< /tab >}}
{{< /tabs >}}


{{< /details >}}

### Equipment properties map to class properties


As equipment can have equipment properties, an equipment class can have equipment class properties.
However, an equipment class property is only a key, not a value.
When an equipment belongs to an equipment class, that equipment receives its properties.
So, equipment properties _map to_ the class properties.

```mermaid
classDiagram

equipment *--> `equipment  property` :has values of
equipment *--> `equipment  class` :defined by
`equipment  class` *--> `equipment  class  property` :has properties of
`equipment class  property` <.. `equipment property` :maps to 
```


Classes are abstract, and so class properties are abstract keys.
An Equipment is tangible, and thus has a property key and an actual value.



### Equipment classes can be made of other classes

As equipment can be _made of_ equipment, so equipment classes can be made of equipment classes.

```mermaid
classDiagram
`packaging (class)` *-- fillers
`packaging (class)` *-- cappers
`packaging (class)` *-- packers
`packaging (class)` *-- palletizers

`packaging line 1` *-- filler 1
`packaging line 1` *-- capper 1
`packaging line 1` *-- packer 1
`packaging line 1` *-- palletizer 1

```

