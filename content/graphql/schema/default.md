+++
title = "@default Directive"
description = "The @default directive specifies which GraphQL APIs are generated for a given type. Without it, all queries & mutations are generated except subscription."
weight = 6
[menu.main]
    parent = "schema"
    identifier = "schema-generate"
+++

The `@default` directive provides default values to be stored when not supplied in a mutation (`add`/`update`). 

The directive can be used with the current DateTime (via `$now') to allow timestamping of mutation events.


## Example Usage

```graphql
type Type {
  field: FieldType @default(
    add: {value: "value"}
    update: { value: "value"}
  )
}
```
Where a value is not provided as input for a mutation, the `add` value will be used if the node is being created, and the `update` value will be used if the node exists and is being updated. 

## Timestamp support

The directive supports timestamping the mutation event
```graphql
type Type {
    createdAt: DateTime! @default(
        add: { value: "$now" }
    )
    updatedAt: DateTime! @default(
        add: { value: "$now" }
        update: { value: "$now" }
    )
}
```
The string `$now` is replaced by the current DateTime string on the server.

The u

## Schema Validation
### Field Type Conversion
Values are provided as strings, parsed into the correct field type by Dgraph.

Schema validation will check that:
- `Int` field values can be `parsedstrconv.ParseInt`
- `Float` field values can be parsed by `strconv.ParseFloat`
- `Boolean` field values are `true` or `false`
- `$now` can only be used with fields of type `DateTime`

###Enum support
Schema validation does **not** currently ensure that `@default` values for 
enums are a valid member of the enum, so this is allowed:
```graphql
enum State {
  HOT  NOT
}

type Type {
  state: State @default(add: { value: "FOO"})
}
```
### Restrictions

Schema validation  prevents use of `@default` on:
- Types with `@remote `directive
- Fields of type `ID`
- Fields that are not scalar types (`Int`, `Float`, `String`, `Boolean`, `DateTime`) or an `enum`
- Fields that are list types (i.e. `[String]`)
- Fields with` @id`, `@custom`, `@lambda`

## Output schema changes:
Fields with `@default(add)` values become optional in `AddTypeInput`