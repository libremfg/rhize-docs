---
title: GraphQL filters
description: A list of the filters you can use to query and update manufacturing models.
categories: ["reference"]
weight: 930
menu:
  main:
    identifier: gql-filters
    parent: reference
---

This page provides a bare reference of filter queries accepted by the Rhize database.
For an extended guide, with examples, read [Use query filters]({{< relref "/how-to/gql/query-filters" >}}).

## String filters

String properties have the following filters:

| Filter                         | Description                                               | Example argument                                 |
|--------------------------------|-----------------------------------------------------------|--------------------------------------------------|
| `eq`                           | Equals (exact match)                                      | `(filter: {id: {eq: "match"}})`                  |
| `in`                           | From this match of arrays                                 | `(filter: {id: {in: ["dough", "cookie_unit"]}})` |
| `lt`,`gt`,`le`, `ge` `between` | Less than, greater than, or between a lexicographic range | `(filter: {id: {lt: "M"}`                        |
| `regexp`                       | A regular expression match in `RE2` syntax                | `(filter: {id: {regexp: "/hello/i"}})`           |
| `anyoftext`                    | A match for any entered strings, separated by spaces      | `(filter: {id: {anyoftext: "100 MD"}})`          |
| `alloftext`                    | A match for all entered strings                           | `(filter: {id {alloftext: "MD"}})`               |

## Integers, floats, DateTimes

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


## Enum filters

Properties of the type `Enum` can be filtered by the following:
 - `lt`
 - `le`
 - `eq`
 - `in`
 - `between`
 - `ge`
 - `gt`

 Each keyword has the same behavior as described in [string filters](#string-filters).

## Boolean filters

Boolean filters can be either `true` or `false`.

## Geolocation filters

Geolocation filters filter by geographic coordinates.
They return matches within the specified [GeoJSON polygon](https://datatracker.ietf.org/doc/html/rfc7946#section-3.1.6).

| Filter     | Description                                     |
|------------|-------------------------------------------------|
| near       | Within the specified `distance` from the polyon |
| within     | In the polygon coordinates                      |
| Intersects | In the intersection of two polygons                                                |
