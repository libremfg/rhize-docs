---
title: Material models in ISA-95
description: A guide to material entities and relationships in ISA-95
icon: beaker
---

In ISA-95, _material_ can be a finished good or anything that goes into this good.
Examples of material include:
- A final product, such as packaged watch
- A part, such as a gear in this watch 
- An intermediate substance, such as a produced reactant to be used in combination with another chemical
- Raw materials, like the flour and water that make dough


Like [equipment]({{< relref "equipment" >}}), material can have classes and properties.
However, to account for detailed tracking of unique material units,
the material model has more entities than equipment.

{{< details title="Full diagram of abstract relationships" closed="true" >}}

```mermaid
classDiagram
`material sublot` o--> `material lot` :assembled from
`material lot` o--> `material lot` :assembled from
`material definition` o--> `material definition` :assembled from
`material class` o--> `material class` :assembled from
`material class` o--> `material class` :assembled from
`material lot` -->`material definition` :defined by
`material definition` -->`material class` :defined by
`material lot` *--> `material lot properties` :has values of
`material sublot` *--> `material lot properties` :has values of
`material definition` *-->`material definition properties` :has properties of
`material class` -->`material class properties` :has properties of
`material lot properties` ..> `material definition properties` :maps to
`material definition properties` ..> `material class properties` :maps to
`material lot properties` *--> `material lot properties` :contains
`material definition properties` *--> `material definition properties` :contains
`material class properties` *--> `material class properties` :contains
```

{{< /details >}}

## Defined by

The `defined by` relationship associates material with common categories and definitions. 

```mermaid
classDiagram
`material lot` -->`material definition` :defined by
`material definition` -->`material class` :defined by
`Cosmic Blue Juice,\npallet 1` -->`Cosmic Blue Juice,\ndefinition` :defined by
`Cosmic Blue Juice,\ndefinition` -->`Juices class` :defined by
```

### Material lots are `defined by` material definitions

_Material definitions_ provide a way to ensure units of the same substance 
have a consistent name and set of properties.
_Material lots_ provide a way to uniquely identify each specific instance of that definition.

For example, the Springfield plant might produce 100 pallets of its flagship product, `Cosmic Blue Juice`.
Obviously, these pallets are not literally the same: otherwise they would just be one pallet.
Rather, each pallet is a separate _lots_, and all these lots share the same material definition.


### Definitions are defined by classes

If you need another level of abstraction, you can also categorize your material definitions by _material class_.
Material classes provide a way to categorize material by function or shared [properties](#material-properties).
For example, `The Juice Factory` has five juice definitions, all part of the class `Juices`.

```mermaid
classDiagram
namespace juices {
class `Nuclear Green Juice`
class `Tropical Orange Juice`
class `Cosmic blue juice`
class `Royal Purple Juice`
class `Berry Red Juice`
}

```
Note that material classes can contain material classes. For example, the `raw_materials` class might contain all raw ingredients.

```mermaid
---
subtitle: Material classes can contain material classes
---
classDiagram
namespace raw_materials{
  class sweeteners
  class flavors
  class colors
}
namespace sweeteners{
  class sugar
  class aspertame
}
namespace flavors{
  class `blue flavoring`
  class `orange flavoring`
}
namespace colors{
  class `blue`
  class `orange`
}



```

## Is assembled from

Material lots also might be _assembled from_ material _sublots_.


```mermaid
classDiagram
`material lot` o--> `material sublot` :is assembled from
```

Sublots are uniquely identifiable components of a material lot.
For example,
the pallet `PBJ.1000.1` might be assembled from a set of packed juice cases.
Each case might be modelled as a sublot with a unique ID, such as `PBJ.1000.1.1`.


## Has material properties

Material can have _properties_, or characteristics that describe some aspect of its implementation. 
You can set material definitions at the level of the class, definition, or lot.

If a material class or definition has members, then all members _inherit_ the properties associated with its defining entity.
If using class or definition properties, you can also set a default value to be inherited by its members.

For example, the `juices` class has the property `sugarContent`.
The material definition `Cosmic Blue Juice` is a member of this class, and thus it inherits the `sugarContent` property.
The `Cosmic Blue Juice` product has a defined standard value for its `sugarContent`, `100 grams`.
The material lot `CBJ.Pallet1` is a pallet of Cosmic Blue Juice.
This lot inherits the `sugarContent` property from the definition that it belongs to, and its value might deviate from the default value of its definition.

```mermaid
classDiagram
class materialClass{
  id: juices
}
class materialDefinition{
  id: Cosmic blue juice
}

class materialLot{
  id: Cosmic blue juice, pallet 1
}


class materialLotProperty{
   id: cbj.1.sugarContent,
   UnitOfMeasure: g,
   value: 99.5
}
class materialDefinitionProperty{
   id: cbj.sugarContent,
   value: 100
   UnitOfMeasure: g,
}
class materialClassProperty{
   id: sugarContent,
   UnitOfMeasure: g,
}

materialClass *--> materialClassProperty :has property of
materialDefinition *--> materialDefinitionProperty :has property of
materialLot *--> materialLotProperty :has value of
materialLot *--> materialDefinition :defined by
materialDefinition *--> materialClass :defined by
materialLotProperty *--> materialDefinitionProperty :maps to
materialDefinitionProperty *--> materialClassProperty :maps to


```


### Properties contain properties

```mermaid
classDiagram
flavor_profile *--> sweetness
flavor_profile *--> umami
flavor_profile *--> aciditiy

```

As with equipment properties, all properties can contain properties.
For example, the property `flavor_profile` might contain properties for `sweetness`, `acidity` and `umami`.
