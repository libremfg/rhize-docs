---
title: 'Query'
categories: ["how-to"]
description: A guide to the three GraphQL operations in Rhize
weight: 200
menu:
  main:
    parent: how-to-query
    identifier:
---

A _query_ returns one or more resources from the database.
Whether you want to investigate manufacturing processes or build a custom report,
the work starts with a query to the Rhize knowledge graph.

Most queries start with these three verbs, each of which indicates the resources to return.

- `get` for a single resource
- `query` for multiple resources
- `aggregate` for calculations on arrays


{{< notice "note" >}}

These operations correspond to the `Get` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

{{< /notice >}}

## `get` single resource

Queries that start with `get` return one object.
A common use of `get` is to explore all data related to a particular object.
For example, in a custom dashboard, you may use `getDataSource` to make a custom page that reports a specified data source.

Typically, the argument specifies the resource by either its human-readable ID (`id`) or its unique address in the database (`iid`).

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

## `query` multiple resources

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

### Query specified IDs

To filter your query to a specific set of items, use the `filter` argument with the requested IDs.

The least verbose way to filter is to specify the requested items' `iid` (their unique database addresses) in an array:
For example, this query returns only equipment with an `iid` of `0xf9b49` or `0x102aa5`.

```graphql
query ExampleQuery {
  queryEquipment(filter: { iid: ["0xf9b49", "0x102aa5"] }) {
    iid
    id
  }
}
```

If you don't have the precise `iid`, you can use one of the string [filters]({{< relref "query-filters" >}}).

