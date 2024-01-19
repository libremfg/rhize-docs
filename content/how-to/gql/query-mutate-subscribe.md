---
title: 'Query, mutate, and subscribe'
categories: ["concepts"]
description: A guide to the three GraphQL operations in Rhize
weight: 200
menu:
  main:
    parent: how-to-query
    identifier:
---

This document provides examples for how to use the Rhize GraphQL API to query, update, and subscribe to objects in the Manufacturing data hub.

In GraphQL, an _operation_ is a type of request to the server.
Rhize supports three types of operations:

- **Queries** return data and subsets of data.
- **Mutations** change the data on the server side.
- **Subscriptions** notify about data changes in real time.


## Queries

Most queries start with these three verbs, each of which indicates the resources to return.
- `get` for a single resource
- `query` for multiple resources
- `aggregate` for calculations on arrays

{{< notice "note" >}}

These operations correspond to the `Get` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

{{< /notice >}}

### `get` single resource

Queries that start with `get` return one object.
Common use cases of gets are to explore all data related to a particular object.
For example, in a custom dashboard, you may use `getDataSource` to make a custom page that reports a specified data source.


Typically, the argument specifies the resource by either its human-readable ID (`id`), or its unique address in the database (`iid`).


For example, this query gets the `iid`, `_createdBy`, and `versions` for the equipment item `Kitchen_mixer_b_01`:

```graphql
query mixerCheck {
  getEquipment(id: "Kitchen_mixer_b_01") {
      iid
      _createdBy
      versions{
        id
      }
  }
}
```

### `Query` multiple resources

Queries that start with `query` return an array of objects.
For example, a custom dashboard may use `queryEquipmentVersion` to create a page that displays all active versions of equipment that are running in a certain {{< abbr "hierarchy scope" >}}.

For example, this query returns the ID of all pieces of equipment.

```graphql
query allEquipment{
  queryEquipment {
    id
  }
}
```

Often, it's convenient to [filter]({{< relref "call-the-graphql-api#filter" >}}) the items returned by a query.
This query uses a regular expression in its variables to filter for items that begin with either `Kitchen_` or `Cooling_` (case insensitive):

{{< tabs >}}
{{% tab "query" %}}
```graphql
query getEquipment($filter: EquipmentFilter) {
  aggregateEquipment(filter: $filter) {
    count
  }
  queryEquipment(filter: $filter) {
    id
  }
}
```
**Variables**

```json
{
  "EquipmentFilter": {
    "id": {
      "regexp": "/|Kitchen_.*|Cooling_.*/i"
    }
  },
}
```
{{% /tab %}}
{{< /tabs >}}


### `Aggregate` data from multiple resources

Like `query`, operations that start with `aggregate` return sets of arrays.

However, rather than return items, the purpose of aggregate operations is to returns secondary data computed from the properties of these items.
For example, you might use an `aggregate` query to create a report about operational performance for a set of process segments within a certain time frame.

This request returns the count of all Equipment items that match a certain filter:

{{< tabs >}}
{{% tab "query" %}}
```graphql
query countItems($filter: EquipmentFilter) {
  aggregateEquipment(filter: $filter) {
    count
  }
}
```
{{% /tab %}}
{{< /tabs >}}

## Mutations

Rhize supports the following ways to change the API.

### `Add`

Mutations that start with `Add` create a resource on the server.
The `Add` operation corresponds to the `Process` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

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

### `Update`

Mutations that start with `Update` change something in an object that already exists.
The `Update` operation corresponds to the `Change` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

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

### `Delete`

{{< notice "caution" >}}
Be careful! Without a [Database backup]({{< relref "/deploy/backup/graphdb" >}}), deleted items cannot be recovered.
{{< /notice >}}

Mutations that start with `delete` remove a resource from the database.
The operation corresponds to the `Cancel` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

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


## Subscriptions

{{< notice "note" >}}

These operations correspond to the `SyncGet` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

{{< /notice >}}

The operations for a `subscription` are similar to the operations for a [`query`](#queries).
But rather than providing information about the entire item, the purpose of subscriptions is to notify about real-time changes to a manufacturing resource.


This example query subscribes to changes in a specified set of `workResponses`, reporting only their `id` and effective end time.

```graphql

subscription GetWorkResponse($getWorkResponseId: String) {
    getWorkResponse(id: $getWorkResponseId){
      jobResponses {
      effectiveEnd
    }
  }
}
```

Try to minimize the payload for subscription operations.
Additionally, you need to subscribe only to changes that persist to the knowledge graph.
For general event handling, it's often better to use a [BPMN workflow]({{< relref "../bpmn" >}}) that subscribes to a NATS, MQTT, or OPC UA topic.
