---
title: 'Filter'
categories: ["how-to"]
description: How to filter a GraphQL call to a subset of manufacturing items.
weight: 210
---


_Filters_  limit an operation to a subset of resources.
You can use filters to make operations more precise, remove unneeded items from a payload, and reduce the need for secondary processing.

To use a filter, specify it in the operation's argument.
Most fields in an object can serve as a filter.
{{< notice "note" >}}
This page provides a detailed guide of how to use the filters, with examples.
For a bare reference of filters and data types, refer to the [GraphQL type reference]({{< relref "/reference/gql-types" >}}).
{{< /notice >}}

  
## Filter by property

The following sections show some common [scalar filters]({{< relref "/reference/gql-types#scalar-filters" >}}), filters that work on `string`, `dateTime`, and numeric values.
These filters return only the resources that have some specified property or property range.

### `between` dates

The `between` property returns items within time ranges for a specific property.
This query returns job responses that started between January 01, 2023 and January 05, 2023.

```graphql
query {
  queryJobResponse(
    filter: {
      effectiveStart: { between: { min: "2023-01-01", max: "2023-01-05" } }
    }
  ) {
    id
    effectiveStart
  }
}
```

### `has` property

The `has` keyword returns results only if an item has the specified field.
For example, this query returns only equipment items that have been modified at least once.

{{< tabs >}}
{{% tab "query" %}}
```graphql
query QueryEquipment {
  queryEquipment(filter: {has: _modifiedOn}) {
    id
    _createdOn
    _modifiedOn
  }
}
```
{{% /tab %}}
{{% tab "Response" %}}
```json
{
  "data": {
    "queryEquipment": [
      {
        "id": "AN-19670-Equipment-1",
        "_createdOn": "2023-12-24T16:50:45Z",
        "_modifiedOn": "2024-01-23T20:06:30Z"
      },
      {
        "id": "AN-19670-Equipment-2",
        "_createdOn": "2023-12-24T18:16:35Z",
        "_modifiedOn": "2024-01-23T20:06:35Z"
      },
      // more items
      ]
    }
 }
```
{{% /tab %}}
{{< /tabs >}}

To filter for items that have multiple properties, include the fields in an array.
This query returns equipment objects that both have been modified and have next versions:

```graphql
query QueryEquipment {
  queryEquipment(filter: {has: [_modifiedOn, nextVersion]}) {
    nextVersion
    _modifiedOn
  }
}
```

### `in` this subset

The `in` keyword filters for objects that have properties with specified values.
For example, this query returns material lots that have material definitions that are either `dough` or `cookie_unit`.

```graphQL
query{
  queryMaterialLot @cascade {
    id
    materialDefinition(filter: {id: {in: ["dough", "cookie_unit"]}}) {
      id
    }
    }
  }
}
```

### `regexp`

The `regexp` keyword searches for matches using the [RE2](https://github.com/google/re2) regular expression engine.

For example,
this query uses a regular expression in its variables to filter for items that begin with either `Kitchen_` or `Cooling_` (case insensitive):

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

{{< notice "caution" >}}

The `regexp` filters can have performance costs.
After you refine a query filter to return exactly what you need, consider ways to simplify the regular expression
or, if possible, use a different filter.

{{< /notice >}}

## Combine filters with `and`, `or`, `not`

To filter by multiple properties, use the `and`, `or`, and `not`, operators.
GraphQL syntax uses [infix notation](https://en.wikipedia.org/wiki/Infix_notation), so: "a and b" is `a, and: { b }`, “a or b or c” is `a, or: { b, or: c }`, and “not” is a prefix (`not:`).

### this `and` that property

The `and` operator filters for objects that include all specified properties.

For example, this query returns equipment objects that match two properties:
- The `effectiveStart` must be the 1st and the 10th of January, 2024.
- It must have a non-null `nextVersion`.

The `and` function is implicit unless you are searching on the same field.
So this filter has an implied `and`:

```
query{
  queryEquipment(filter: {
      effectiveStart: {
        between: {min: "2024-01-01", max: "2024-01-10"}
        
      }
      has: nextVersion
    
    }
  )
  {
    effectiveStart
    id
    nextVersion
  }
}
```

{{< notice "note" >}}

This preceding filter syntax is a shorter equivalent to `and: {has: nextVersion}`.

{{< /notice >}}

### One `or` more properties

The `or` operator filters for objects that have at least one of the specified properties.
For example, you can take the preceding query and modify it so that it returns objects that have an effective start between the specified range or a `nextVersion` property (inclusive).

```graphql
queryEquipment(filter: {
      effectiveStart: {
        between: {min: "2024-01-01", max: "2024-01-10"}
        
      }
      or: {has: nextVersion}
    
    }
  )
```


### `not` these properties

The `not` operator filters for objects that do not contain the specified property.
For example, you can take the preceding query and modify it so that it returns objects that have an effective start between the specified range and _do not_ have a `nextVersion` property:

```
queryEquipment(filter: {
      effectiveStart: {
        between: {min: "2024-01-01", max: "2024-01-10"}
        
      }
      not: {has: nextVersion}
    
    }
  )
```

To modify this to include both objects within the range and objects that do not have a `nextVersion`, use `or` with `not`:

```graphql
or: { not: {has: nextVersion} }
```

### This list of filters

The `and` and `or` operators accept lists of filters.
For example, this query filters for equipment objects whose `id` matches `A`, `B`, or `C`:

```graphql
queryEquipment (filter: {
    or: [
    { id: { eq: "A" } }, 
    { id: { eq: "B" } },
    { id: { eq: "C" } }, 
  ]
  })
```

## Use directives

Rhize offers [_query directives_](https://the-guild.dev/graphql/tools/docs/schema-directives#what-about-query-directives), special instructions about how to look up and return values in a query.
These directives can extend your filtering to look at nested properties or to conditionally display a field.

All directives begin with the `@` sign.

### Cascade

The `@cascade`  directive filters for certain nodes within a query.
Use it to filter requested resources by a nested sub-property, similar to a `WHERE` clause in SQL.

{{< notice "caution" >}}

`@cascade` is not as performant as flatter queries.
Consider using it only after you've exhausted other query structures to return the data you want.

{{< /notice >}}

For example, this query filters for job responses with an ID of `12341`, and then filters that set for only the items that have a `data.properyLabel` field with a value of `INSTANCE ID`.

{{< tabs >}}

{{% tab "Query" %}}

```graphql
query QueryJobResponse($filter: JobResponseFilter, $propertyLabel: String) {
  queryJobResponse(filter: $filter)  @cascade(fields:["data"]){
    id
    iid
    data(filter: { label: { anyoftext: $propertyLabel } }) {
      id
      iid
      label
      value
    }
  }
}
```
**Variables**:
```json
{
    "filter": {
        "id": {
            "alloftext": "12341"
        }
    },
    "propertyLabel": "INSTANCE ID"
}

```
{{% /tab %}}
{{< /tabs >}}

#### Avoid using @cascade with the [`order`]({{< relref "query#order" >}}) argument

The `order` argument returns only the first 1000 records of the query.
If a record matches the `@cascade` filter but comes after these first 1000 records, the API does not return it.

For example, this query logic works as follows:
1. Return the first 1000 records of equipment as ordered by `effectiveStart`.
1. From these 1000 records, return only the equipment items that are part of `parentEquipment1`.

```graphql
query($filter: EquipmentFilter){
  queryEquipment (filter: { order: {desc:effectiveStart}) @cascade{
    id
    isPartOf (filter: {id:{eq:"parentEquipment1"}}) {
      id
    }
  }
}
```

This behavior can be surprising and undesirable, so avoid `@cascade` with the `order` argument.

### Include

The `@include` directive returns a field only if its variable is `true`.

For example, when `includeIf` is `true`, this query omits specified values for `versions`.


{{< tabs >}}

{{% tab "query" %}}

```graphql
query($includeIf: Boolean!) {
  queryEquipment {
    id
    versions @include(if: $includeIf) {
      id
    }
  }
}
```

{{% /tab %}}

{{% tab "variables" %}}

Change to `true` to include `versions` fields.

```json
{
  "includeIf": false
}
```

{{% /tab %}}

{{< /tabs >}}


