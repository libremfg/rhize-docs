---
title: 'Query, mutate, and subcribe'
categories: ["concepts"]
description: Examples of how to use the different GraphQL operations in Rhize
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


{{< tabs >}}
{{% tab "query" %}}
```graphql
query allEquipment($filter: EquipmentFilter) {
g
  queryEquipment(filter: $filter) {
    id
  }
  }
}
```
{{% /tab %}}
{{% tab "variables" %}}

```json
{
  "EquipmentFilter": {
    "id": {
      "regexp": "/KITCHEN_.*|/i"
    }
  },
}
```
{{% /tab %}}
{{< /tabs >}}

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
}
```
{{% /tab %}}
{{% tab "variables" %}}

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

```graphql
query countItems($filter: EquipmentFilter) {
  aggregateEquipment(filter: $filter) {
    count
  }
}
```

## Mutations

Rhize supports the following ways to change the API.

### `Add`

Mutations that start with `Add` create a resource on the server.

For example, this mutation adds one more items of equipment.
To add multiple, send the variable as an array of objects, rather than a single object.
The `numUids` property reports how many new objects were created.

{{% tabs %}}
{{< tab "mutation" >}}

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
{{% tab "Create one object" %}}

```json
{

  "input": {
    "id": "Kitchen_mixer_a_20",
    "label": "Kitchen mixer A11"
  }
}
```
{{% /tab %}}
{{% tab "Create many" %}}

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
For example, this operation updates the description for a specific version of an equipment item.


```graphql
mutation updateMixerVersion( $updateEquipmentVersionInput2: UpdateEquipmentVersionInput!){
  updateEquipmentVersion(input: $updateEquipmentVersionInput2) {
    equipmentVersion {
      description
      id
    }
  }
}

# variables
{
  "updateEquipmentVersionInput2": {
    "filter": {"iid":"0xcc701"},
    "set": {
      "description": "Second generation of the mixer 9000"
    }
  }
}
```

### `Delete`

{{< notice "caution" >}}
Be careful! Without a [Database backup]({{< relref "/deploy/backup/graphdb" >}}), deleted items cannot be recovered.
{{< /notice >}}

Mutations that start with `delete` remove a resource from the database.

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
{{% /tab %}}

{{% tab "variables" %}}
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

Note that you should be sure to minimize the payload for subscription operations.
Additionally, you only need to subscribe for changes that persist to the knowledge graph.
For general event handling, it's often better to use a [BPMN workflow]({{< relref "../bpmn" >}}) that subscribes to a NATS, MQTT, or OPC UA topic.

## More examples


### Query equipment class

```graphql
query  Example2 {
  queryEquipmentClass{
    id
    activeVersion {
      # EquipmentClassVersion
      iid
      id
      version
      # EquimpentClassProperty
      properties {
        id
        label
        description
        propertyType
        value
        valueUnitOfMeasure {
         id
         dataType
        }
        bindingType
        triggersRules {
          iid
        }
      }
    }
  }
}
```


### Add unit of measure

{{< tabs >}}
{{% tab "mutation" %}}
```graphql
mutation Example6($input: [AddUnitOfMeasureInput!]!) {
  addUnitOfMeasure(input: $input) {
    unitOfMeasure {
      iid
      id
    }
    numUids
  }
}
```
{{% /tab %}}
{{% tab "variables" %}}

```json
{
  "input": [
    {
      "id": "example unit of measure",
      "dataType": "INT64",
      "effectiveStart": "2023-08-01T08:00:00Z"
    }
  ]
}
```
{{% /tab %}}
{{< /tabs >}}

