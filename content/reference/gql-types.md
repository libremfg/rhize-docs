---
title: GraphQL types and filters

description: >-
  A reference of the data types in the Rhize API and of the filters available for each type.
categories: ["reference"]
weight: 930
menu:
  main:
    name: GQL types and filters
    identifier: gql-filters
    parent: reference
---

This page provides a reference of the data types enforced by the Rhize database schema,
and of the filters that can apply to these types when you query, update, or delete a set of resources.
For an extended guide, with examples, read [Use query filters]({{< relref "/how-to/gql/filter" >}}).

{{< notice "note" >}}
These filters are based on Rhize's implementation of the Dgraph [`@search` directives](https://dgraph.io/docs/graphql/schema/directives/search/).
{{< /notice >}}

## Data types

Every object in the Rhize schema has fields that are of one of the basic data types.
From the other perspective, these data types define fields that compose manufacturing objects,
objects defined precisely by ISA-95 and enforced by Rhize's database schema.

### Basic types

Every manufacturing object in the Rhize database is made of fields that are of one the following basic types.
In official GraphQL terminology, these types are called [_scalar types_](https://graphql.org/learn/schema/#scalar-types).

- `String`
- `Int`
- `Float`
- `Enum`
- `Boolean`
- `id`: A string representing a unique object within a defined [object type](#object-type).
- `iid`: The object's unique address in the database. For example, `0xf9b49`.
- `DateTime`: A timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.
- `Geo`: Geometry types for geo-spatial coordinates

### Object type

The preceding basic types form the building blocks for Rhize's manufacturing object schema, with data models corresponding to ISA-95.

Each object is made of manufacturing-specific fields of one of the basic types.
For example, the `materialActual`  object has basic fields, including:
- `description`, a `String`.
- `effectiveEnd`, a `DateTime`

The `materialActual` also has complex fields describing associated manufacturing objects, for example,
an array of associated `MaterialLot` objects, the `MaterialDefinition` object, and so on.
All objects in the database have relationships to other objects.

## Scalar filters

Every field that has a basic type can be used as a filter.
The filters that are available depend on the data type, but the behavior of the `String` filters corresponds closely to `DateTime` and `Int` filters.

### String filters

String properties have the following filters:

| Filter                         | Description                                               | Example argument                                 |
|--------------------------------|-----------------------------------------------------------|--------------------------------------------------|
| `eq`                           | Equals (exact match)                                      | `(filter: {id: {eq: "match"}})`                  |
| `in`                           | From this match of arrays                                 | `(filter: {id: {in: ["dough", "cookie_unit"]}})` |
| `lt`,`gt`,`le`, `ge` `between` | Less than, greater than, or between a lexicographic range | `(filter: {id: {lt: "M"}`                        |
| `regexp`                       | A regular expression match using [`RE2` syntax](https://github.com/google/re2/wiki/Syntax/)                | `(filter: {id: {regexp: "/hello/i"}})`           |
| `anyoftext`                    | A match for any entered strings, separated by spaces      | `(filter: {id: {anyoftext: "100 MD"}})`          |
| `alloftext`                    | A match for all entered strings                           | `(filter: {id {alloftext: "MD"}})`               |

### Integers, floats, DateTimes

Properties that have a type of `Int`, `Float`, or `DateTime` can be filtered by the following keywords.
Note that all date times are in the [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format.

 - `lt`
 - `le`
 - `eq`
 - `in`
 - `between`
 - `ge`
 - `gt`

Each keyword has the same behavior as described in [string filters](#string-filters), only they operate on numerical rather than lexicographic values.

### Enum filters

Properties of the type `Enum` can be filtered by the following:
 - `lt`
 - `le`
 - `eq`
 - `in`
 - `between`
 - `ge`
 - `gt`

 Each keyword has the same behavior as described in [string filters](#string-filters).

### Boolean filters

Boolean filters can be either `true` or `false`.

### Geolocation filters

Geolocation filters return objects within specified geographic coordinates.
They return matches within the specified [GeoJSON polygon](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.6).

| Filter     | Description                                      |
|------------|--------------------------------------------------|
| near       | Within the specified `distance` from the polygon |
| within     | In the polygon coordinates                       |
| Intersects | In the intersection of two polygons              |

## Read more

- [Rhize guide to GraphQL](/how-to/gql)
- [Dgraph `@search` directive](https://dgraph.io/docs/graphql/schema/directives/search/).
