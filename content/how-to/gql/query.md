---
title: 'Query'
categories: ["how-to"]
description: A guide to the three GraphQL operations in Rhize
weight: 200
---

A _query_ returns one or more resources from the database.
Whether you want to investigate manufacturing processes or build a custom report,
a good query is likely the foundation of your workflow.

Most queries start with these three verbs, each of which indicates the resources to return.

- `get` for a single resource
- `query` for multiple resources
- `aggregate` for calculations on arrays


{{< notice "note" >}}

These operations correspond to the `Get` verb defined in [Part 5](https://www.isa.org/products/ansi-isa-95-00-05-2018-enterprise-control-system-i) of the ISA-95 standard.

{{< /notice >}}

## `query` multiple resources {#query}

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

If you don't have the precise `iid`, you can use one of the string [filters]({{< relref "filter" >}}).


## `get` single resource {#get}

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

## `Aggregate` data from multiple resources {#aggregate}

Operations that start with `aggregate` provide aggregated statistics for a specified set of items.

The syntax and filtering for an `aggregate` operation is the same as for a `query` operation.
However, rather than returning items, the aggregate operation returns one or more computed statistics about these items.
For example, you might use an `aggregate` query to create a summary report about a set of process segments within a certain time frame.

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

## Sort and paginate

A query can take arguments to order and paginate your results.

{{< notice "note" >}}
Without an `order` parameter, a query returns items without any default or guaranteed order.
{{< /notice >}}

### Order

{{< notice "caution" >}}

Ordered queries **return only the first 1000 records of the ordered field.**
This behavior might exclude records that you expect, especially if you [combine `order` with a `@cascade`]({{< relref "filter#avoid-using-cascade-with-the-orderhahahugoshortcode50s8hbhb-argument" >}}) filter in a nested field.

{{< /notice >}}

The `order` argument works with any property whose type is `Int`, `Float`, `String`, or `DateTime`.
For example, this query sorts Person objects by ID in ascending alphabetical order:

```graphql
query{
  queryPerson(order:{ asc: id}) {
    id
  }
}
```

And this orders by the Person's `effectiveStart` date in descending chronological order.

```
query{
  queryPerson(order:{ desc: effectiveStart}) {
    id
    effectiveStart
  }
}
```

### Paginate with `offset`

The `offset` argument specifies what item to start displaying results from, and the `first` argument specifies how many items to show.

For example, this skips the five most recent Person items (as measured by `effectiveStart`), and then displays the next 10:

```graphql
query{
  queryPerson(order:{
    desc: effectiveStart
    },
    offset: 5,
    first: 10
    ) {
    id
    effectiveStart
  }
}
```

## Filter queries

Rhize also has many queries to filter or return subsets of items.
To learn how to filter, read [Use query filters]({{< relref "/how-to/gql/filter" >}}).
