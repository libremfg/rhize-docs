---
title: 'Mutate'
categories: ["how-to"]
description: A guide to adding, creating, and deleting data in the Rhize DB
weight: 250
menu:
  main:
    parent: how-to-query
    identifier:
---

_Mutations_ change the database in someway by creating, updating, or deleting a resource.
You might use a mutation to update a personnel class, or in to a [{{< abbr "BPMN" >}}]({{< relref "/how-to/bpmn" >}}) workflow that automatically creates records of incoming material lots.

Rhize supports the following ways to change the API.

## `add` {#add}

{{< notice "note" >}}
The `add` operation corresponds to the `Process` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.
{{< /notice >}}

Mutations that start with `add` create a resource on the server.

For example, this mutation adds one more items of equipment.
To add multiple, send the variable as an array of objects, rather than a single object.
The `numUids` property reports how many new objects were created.

{{% tabs %}}
{{% tab "mutation" %}}

```graphql
mutation AddEquipment($input: [AddEquipmentInput!]!) {
  addEquipment(input: $input) {
    equipment {
      id
      label
    }
    numUids
  }
}
```

{{% /tab %}}
{{% tab "Vars: create one object" %}}

```json
{

  "input": {
    "id": "Kitchen_mixer_a_20",
    "label": "Kitchen mixer A11"
  }
}
```
{{% /tab %}}
{{% tab "Vars: Create many" %}}

```json
{

  "input": [{
    "id": "Kitchen_mixer_b_01",
    "label": "Kitchen mixer A11"
  },{
    "id": "Kitchen_mixer_b_02",
    "label": "Kitchen mixer A12"
  },
  ]
}
```
{{% /tab %}}{{< /tabs >}}

### Upsert

Many `add` operations support _upserting_, which _update_ or _insert_ (create).
That is, if the object already exists, the operation will update it with the additional fields.

Besides general UX convenience, upsert is useful when data comes from multiple sources and in no guaranteed order, or when data comes from the message broker.

To enable upsert, set the `upsert:` argument to true:

```graphql
addEquipment(input: $input, upsert: true)
```

## `update` {#update}

Mutations that start with `update` change something in an object that already exists.
The `update` operations can use [filters]({{< relref "/how-to/gql/filter" >}}).

{{< notice "note" >}}
The `update` operation corresponds to the `Change` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.
{{< /notice >}}

For example, this operation updates the description for a specific version of an equipment item.

{{< tabs >}}
{{% tab "query" %}}

```graphql
mutation updateMixerVersion( $updateEquipmentVersionInput2: UpdateEquipmentVersionInput!){
  updateEquipmentVersion(input: $updateEquipmentVersionInput2) {
    equipmentVersion {
      description
      id
    }
  }
}
```

**Variables**:
```json
{
  "updateEquipmentVersionInput2": {
    "filter": {"iid":"0xcc701"},
    "set": {
      "description": "Second generation of the mixer 9000"
    }
  }
}
```
{{% /tab %}}
{{% /tabs %}}

## `delete` {#delete}

{{< notice "warning" >}}
Be careful! Without a [Database backup]({{< relref "/deploy/backup/graphdb" >}}), deleted items cannot be recovered.
{{< /notice >}}


Mutations that start with `delete` remove a resource from the database.
The `delete` operations can use [filters]({{< relref "/how-to/gql/filter" >}}).


{{< notice "note" >}}
The `delete` operation corresponds to the `Cancel` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.
{{< /notice >}}

For example, this operation deletes a unit of measure:

{{< tabs >}}
{{% tab "mutation" %}}

```graphql
mutation deleteUoM($filter: UnitOfMeasureFilter!){
  deleteUnitOfMeasure(filter: $filter) {
    numUids
  }
}
```

**Variables:**
```json
{
  "filter": {
    "id": {
      "eq": "example unit of measure"
    }
  }
}

```
{{% /tab %}}
{{% /tabs %}}

## Deep mutations

You can perform deep mutations at multiple levels.
Deep mutations don't alter linked objects but can add nested new objects or link to existing objects.

For example, this mutation creates a new version of equipment, and associates a new item of equipment with it. Both the `equipmentVersion` and the `equipment` did not exist in the database.

```graphql
  mutation AddEquipmentVersion($addEquipmentVersionInput2: [AddEquipmentVersionInput!]!) {
  addEquipmentVersion(input: $addEquipmentVersionInput2) {
    equipmentVersion {
      id
      equipment {
        id
      }
    }
  }
}
```

**Variables:**

```json
  "addEquipmentVersionInput2": {
    "id": "widget_machine_version_1",
    "version": "1",
    "versionStatus": "DRAFT",
    "equipment": {
      "id": "widget_maker_1",
      "label": "Widget maker 1"

    }
  }
}
```

You can confirm the record and its nested property exists with a `get` query.
If the preceding operation succeeded, this query returns both the new `Widget Maker` and
its corresponding version:

{{< tabs >}}
{{% tab "query" %}}
```graphql
query{
  getEquipment(id: "widget_maker_1") {
    id
    versions{
      id
      version
    }
  }
}
```
{{% /tab %}}


{{% tab "result" %}}

```json
{
  "addEquipmentVersionInput2": {
    "id": "widget_machine_version_1",
    "version": "1",
    "versionStatus": "DRAFT",
    "equipment": {
      "id": "widget_maker_1",
      "label": "Widget maker 1"

    }
  }
}
```

{{% /tab %}}

{{< /tabs >}}

To update an existing nested object, use the update mutation for its type.
