---
title: Material models in ISA-95
description: A guide to material entities and relationships in ISA-95
icon: beaker
---

_Material_ can be a finished good or anything that goes into this good.
Examples of material include:
- A final product, such as packaged watch
- A part, such as a gear in this watch 
- An intermediate substance, such as a produced reactant that will be used in combination with another chemical
- Raw materials, like the flour and water that make dough

All manufacturing involves material transformation.
Some material goes in; new material goes out; and this process repeats until the final good is produced.

Like [equipment]({{< relref "equipment" >}}), material can have classes and properties.
However, ISA-95 also can model the existence and production of every unique material component, or lot.
So, the material model has more entities than equipment.


{{< details title="Full diagram of abstract relationships" closed="true" >}}

```mermaid
---
config:
  layout: elk
---
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

_Material definitions_ provide a way to ensure that one material name consistently refers to the same substance.
_Material lots_ provide a way to uniquely identify each specific instance of that definition.

For example, the Springfield plant might produce 100 pallets of its flagship product, `Cosmic Blue Juice`.
Obviously, these pallets are not literally the same: otherwise they would just be one pallet.
Rather, they are separate _lots_ that share the same material definition.


With this model, the Juice Factory can both:
- Create definitions to ensure consistent use and production of material
- Track unique material as it flow across production.

### Definitions are defined by classes

If you need another level of abstraction, you can also categorize your material definitions by _material class_.
For example, `The Juice Factory` has five juice definitions, all part of the class `Juices`.

```mermaid
classDiagram
namespace juices{
class `Nuclear Green Juice`
class `Tropical Orange Juice`
class `Cosmic blue juice`
class `Royal Purple Juice`
class `Berry Red Juice`
}

```

Material classes provide a way to categorize material by function or shared [properties]({#material-properties}).
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

## Has values and properties {#material-properties}

Material lots and sublots can have values.
These values are stored in _material lot properties_.

```mermaid
---
title: Lot properties map to definition properties
---

classDiagram
class lot {
  sugarContent=10g
}
class `juice definition` {
 sugarContent
 }

lot ..> `juice definition` :maps to
```
  
This property may map to a property set for its material definition. And material definition properties may themselves map to class properties.

Note that class and definition properties do not have values since they are abstract. The lot, on the other hand, is real, so it has a value.
So the `Sweeteners` class, the `Cosmic blue juice` definition, and the `PBJ.1000.1` lot all might have a `sugarContent` property, but only the lot can have an actual value, such as `100`.


## Properties contain properties

```mermaid
classDiagram
flavor_profile *--> sweetness
flavor_profile *--> umami
flavor_profile *--> aciditiy

```

As with equipment properties, all properties can contain properties.
For example, the property `flavor_profile` might contain properties for `sweetness`, `acidity` and `umami`.
