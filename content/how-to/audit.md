---
title: 'Audit'
date: '2023-12-20T12:47:09-03:00'
categories: ["how-to"]
description: How to use the Audit log to inspect all events in the Rhize system
weight: 600
menu:
  main:
    parent: how-to
    identifier:
---

The _Audit Log_ provides a tamper-proof and immutable audit trail of all events that occur in the Rhize system.

Users with appropriate permissions can access the audit log either through the UI menu or the GraphQL API

## Prerequisites

To use the audit log, ensure you have the following:

- Access to your Rhize UI environment
- If accessing through GraphQL, you also need:
    - The ability to [Use the Rhize GraphQL API]({{< relref "gql" >}})
    - A token configured so that `audience` includes `audit`, and the scopes contain `audit:query`

## Audit through the UI

To inspect the audit log through the Rhize UI, follow these steps:

1. From the UI menu, select **Audit**.
1. Select the users that you want to include in the audit.
1. Use the time filters to select the pre-defined or custom range that you want to return.

On success, a log of events appears for the users and time ranges specified.
For a description of the fields returned, refer to the [Audit fields](#audit-fields) section.


### Audit fields

In the audit UI, each record in the audit has the following fields:

| Field              | Description                                                                                                             |
|--------------------|-------------------------------------------------------------------------------------------------------------------------|
| Timestamp          | The time when the event occurred                                                                                        |
| User               | The user who performed the operation                                                                                    |
| Operation          | The [GraphQL operation]({{< relref "gql/query-mutate-subscribe" >}}) involved                                           |
| Entity Internal ID | The ID of the resource that was changed                                                                                 |
| Attribute          | What changed in the resource. This corresponds to the object properties as defined by the API and its underlying schema |
| Value              | The new value of the updated attribute                                                                                  |


## Audit through GraphQL

The audit log is also exposed through the GraphQL API.
To access it, use the `queryAuditLog` operation, and add [filters]({{< relref "gql/call-the-graphql-api#filters" >}}) for the time range and users.

Here's an example query:

```gql
query {
  queryAuditLog(filter: {start: "2023-01-01T00:00:00Z", end:"2023-12-31T00:00:00Z", tagFilter:[{id:"user", in: ["admin@libremfg.com"]},{id:"operation", in: ["set"]}]}, order: {}) {
    operationType
    meta {
      time
      user
    }
    event {
      operation
      uid
      attribute
      value
    }
  }
}
```

