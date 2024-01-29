---
title: 'Use query filters'
categories: ["how-to"]
description: How to filter a GraphQL query to a subset of manufacturing items.
weight: 210
menu:
  main:
    parent: how-to-query
    identifier:
---

When a query returns many items, it's often helpful to filter the response to some subset.
Rhize has many filters to make your queries more precise, bringing more meaningful results with less need for secondary processing.

This page provides a detailed guide of how to use the filters with examples of how to use them.
For a bare reference, refer to the [Filter reference]({{< relref "/reference/gql-filters" >}}).

{{< notice "note" >}}
These filters are based on Rhize's implementation of the Dgraph [`@search` directives](https://dgraph.io/docs/graphql/schema/directives/search/).
{{< /notice >}}
  
## Filter by property

These filters return only the resources that have some specified property or property range. They typically work on `string` and `dateTime` objects.

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
This query returns equipment that both have been modified and have next versions:

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

## Combine filters with `and`, `or`, `not`

To filter by multiple properties, use the `and`, `or` and `not`, operators.
GraphQL syntax uses [infix notation](https://en.wikipedia.org/wiki/Infix_notation), so: "a and b" is `a, and: { b }`, “a or b or c” is `a, or: { b, or: c }`, and “not” is a prefix (`not:`).

### this `and` that property

The `and` operator filters for objects that include all specified properties.

For example, this query returns equipment objects that match two properties:
- `effectiveStart` must be the 1st and the 10th of January, 2024
- It must have a non-null `nextVersion`

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

This is shorter filter syntax is equivalent to `and: {has: nextVersion}`.

{{< /notice >}}

### One `or`  more properties

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


### `not` this properties

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

### A list of filters

The `and` and `or` accept lists of filters.
For example, this query filters for equipment objects whose `id` is matches `A`, `B`, or `C`:

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

The `@cascade`  directive filters certain nodes within a query.
Use it to filter requested resources by a nested sub-property, similar to a `WHERE` clause in SQL.

{{< notice "caution" >}}

`@cascade` is not as performant as flatter queries.
Consider using it only after you've exhausted other query structures to return the data you want.

{{< /notice >}}

For example, this query [filters]({{< relref "call-the-graphql-api#filter" >}}) for job responses with an ID of `12341`, and then filters that set for only the items that have a `data.properyLabel` field with a value of `INSTANCE ID`.

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

### Include

The `@include` directive returns a field only if its variable is `true`.
It is the converse of [`@skip`](#skip), which returns a field if its variable is `false`.

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


