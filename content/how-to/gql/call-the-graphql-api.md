---
title: >-
  Overview: the Rhize API
date: '2023-11-22T09:43:30-03:00'
categories: ["how-to"]
description: How to query your manufacturing knowledge graph
weight: 100
---

In a manufacturing operation, all event data is interrelated.
To make these relations explorable, Rhize stores data in a special-purpose graph database designed to represent all levels of the manufacturing process.
This database is enforced by our ISA-95 schema, the most comprehensive data representation of ISA-95 in the world.

Rhize exposes this database through a [GraphQL API](https://graphql.org/).
Unlike REST, GraphQL requires only one endpoint, and you can define exactly the data that you return for each operation.


If you are a customer, the best way to learn both GraphQL and ISA-95 modelling is to use the [Apollo Explorer](https://www.apollographql.com/) for our schema.
However, for newcomers to GraphQL, the flexibility may look overwhelming.
These topics introduce the basics of how to use GraphQL with Rhize's custom database.

Once you learn how to explore the API, you'll find that the interface is more comfortable and discoverable than a comparable OpenAPI (Swagger) document&mdash;and that's before considering the improvements GraphQL brings to precision, performance, and developer experience.

## Operation types {#operations}

In GraphQL, an _operation_ is a request to the server.
Rhize supports three types of operations:

- **[Queries]({{< relref "query" >}})** return data and subsets of data.
- **[Mutations]({{< relref "mutate" >}})** change the data on the server side.
- **[Subscriptions]({{< relref "subscribe" >}})** notify about data changes in real time.

For details and examples, refer to their specific documentation pages.

## Call syntax

The following sections show you the essential features to make a query.

### Authenticate

To authenticate your requests, pass a bearer token as an `Authorization` header.
Be sure to preface the value with the word `Bearer `:


{{< figure
alt="Example of how it looks in Apollo explorer"
src="/images/screenshot-rhize-apollo-auth-headers.png"
width="50%"
>}}

For an overview of how Rhize handles token exchange, read [About OpenID connect]({{< relref "/deploy/about-openidconnect" >}}).

### Request body

By default, all GraphQL operations have the following structure:
1. Define the operation type (one of, `query`, `mutation`, or `subscription`).
1. Name the query anything you want. This example builds a `query` called `myCustomName`:
    ```graphql
    query myCustomName {
        #operations will go here
      }

    ```
1. In curly brackets, define the _operation_ you want to query.
1. In parenthesis next to the operation, add the _arguments_ to pass. This example uses the `getEquipment` operation, and its arguments specify which item of equipment to get.

    ```graphql
    query myCustomName {
      getEquipment(id: "Kitchen_mixer_b_01") {
        #Fields go here
        }
      }
    ```

1. Within the operation, define the fields you want to return. This example queries for the equipment ID and the person who created the entity.

    ```graphql
    query myCustomName {
      getEquipment(id: "Kitchen_mixer_b_01") {
        id
        _createdBy
      }
    }
    ```

   As you might expect, the request returns only these fields for the equipment named `Kitchen_mixer_b_01`.

   ```json
   {
      "data": {
        "getEquipment": {
          "id": "Kitchen_mixer_b_01",
          "_createdBy": "john_snow"
        }
      }
    }
    ```

### Request exactly the data you want

A major benefit of GraphQL is that you can modify queries to return only the fields you want.
 You can join data entities in a single query and query for entity relationships  in the same way that you would for entity attributes.
  
Unlike calls to a REST API, where the server-side code defines what a response looks like, GraphQL calls instruct the server to return only what is specified.
Furthermore, you can query diverse sets of data in one call, so you can get exactly the entities you want without calling multiple endpoints, as you would in REST, or composing queries with complex recursive joins, as you would in SQL.
Besides precision, this also brings performance benefits to minimize network calls and their payloads.

For example, this expands the fields requested from the previous example.
Besides `id` and `_createdBy`, it now returns the `description`, unique ID, and version information about the requested equipment item:

{{< tabs >}}
{{% tab "request" %}}
```graphql

query ExampleQuery {
  queryEquipment(filter: { id: { eq: "Kitchen_mixer_b_0 1" } }) {
    id
    _createdBy
    versions {
      iid
      description
    }
    activeVersion {
      iid
      description

    }
  }
}
```
{{% /tab %}}
{{% tab "response" %}}
```json
{
  "data": {
    "queryEquipment": [
      {
        "id": "Kitchen_mixer_b_01",
        "_createdBy": "john_snow",
        "versions": [
          {
            "iid": "0xcc701",
            "description": "First generation of the mixer 9000"
          },
          {
            "iid": "0xcc71a",
            "description": "Second generation (in testing)"
          }
        ],
        "activeVersion": {
          "iid": "0xcc701",
          "description": "First generation of the mixer 9000"
        }
      }
    ]
  }
}
```
{{% /tab %}}
{{< /tabs >}}

You can also add multiple operations to one call.
For example, this query requests all data sources and all persons:


{{< tabs >}}
{{% tab "request" %}}
```graphql
query peopleAndDataSources {
  queryPerson {
    id
    label
  }
  queryDataSource {
    id
  }
}
```
{{% /tab %}}
{{% tab "response" %}}
```json
{
  "data": {
    "queryPerson": [
      {
        "id": "235",
        "label": "John Ramirez"
      },
      {
        "id": "234",
        "label": "Jan Smith"
      }
    ],
    "queryDataSource": [
      {
        "id": "x44_mqtt"
      },
      {
        "id": "x45_opcUA"
      }

    ]
  }
}
```
{{% /tab %}}
{{< /tabs >}}

## Shortcuts for more expressive requests

The following sections provide some common ways to reduce boilerplate and shorten the necessary coding for a call.

### Make input dynamic with variables {#variables}

The preceding examples place the query input as _inline_ arguments.
Often, calls to production systems separate these arguments out as JSON _variables_.

Variables add dynamism to your requests, which serves to make them more reusable.
For example:
- If you build a low-code reporting application, you could use variables to change the arguments based on user input.
- In a BPMN event orchestration, you could use variables to make a GraphQL call based on a previous JSONata filter. Refer to the example, [Write ERP material definition to DB]({{< relref "../bpmn/create-workflow/#write-erp-material-definition-to-database" >}}).


For example, this query places the ID of the resource that it requests as an inline variable:

```graphql
query myCustomName {
  getEquipment(id: "Kitchen_mixer_b_01") {
    _createdBy
  }
}
```

Instead, you can pass this argument as a variable.
This requires the following changes:

1. In the argument for your query, name the variable and state its type.
This instructs the query to receive data from outside of its context:

    ```graphql
    ## Name variable and type
    query myCustomName ($getEquipmentId: String) {
      ## operations go here.
    }
    ```
1. In the operation, pass the variable as a value in the argument.
In this example, add the variable as a value to the `id` key like this:

    ```graphql
    query GetEquipment($getEquipmentId: String) {
    
      ## pass variable to one or more operations
      getEquipment(id: $getEquipmentId) {
        ## fields go here
      }
    }
    ```
    
1. In a separate `variables` section of the query, define the JSON object that is your variable:

   ```json
   {
    "getEquipmentId": "Kitchen_mixer_b_01"
   }
   ```


{{< tabs >}}
{{% tab "Query" %}}
    
```graphql
query GetEquipment($getEquipmentId: String) {
  getEquipment(id: $getEquipmentId) {
    _createdBy
  }
}
```
**Variables**:
```json
{
 "getEquipmentId": "Kitchen_mixer_b_01"
}
```
{{% /tab %}}
{{% /tab %}}

The preceding example is minimal, but the use of variables to _parameterize_ arguments also applies to complex object creation and filtering.
For example, this _mutation_ uses variables to create an array of Persons:

{{< tabs >}}
  {{% tab "Mutation" %}}
```graphql
mutation AddPerson($input: [AddPersonInput!]!) {
  addPerson(input: $input) {
    person {
      id
    }
  }
}
```
**Variables**:
```json
{
  "input": [
 {"id": "234", "label":"Jan Smith"},
 {"id": "235", "label": "John Ramirez"}
  ]
}
```
{{% /tab %}}
{{< /tabs >}}

To learn more, read the official GraphQL documentation on [Variables](https://graphql.org/learn/queries/#variables).

### Template requested fields with fragments

Along with [variables](#variables), you can use _fragments_ to reduce repetitive writing.

Fragments are common fields that you use when querying an object.
For example, imagine you wanted to make queries to different equipment objects for their `id`, `label`, `_createdBy`, and `versions[]` properties.
Instead of writing these fields in each operation, you could define them in a fragment, and then refer to that fragment in each specific operation or query.

To use a fragment:
1. Define them with the `fragment` keyword, declaring its name and object.
    ```graphql
             ## name         ## object
   fragment CommonFields on Equipment
   ```
1. Include the fragment in the fields for your operation by prefacing its name with three dots:
    ```
    ...CommonFields
    ```
    
For example:

{{< tabs >}}
{{% tab "query" %}}
```graphql
## Define common fields
fragment CommonFields on Equipment{
  id
  label
  _createdBy
  versions {
    id
  }
}

## Use them in your query.
query kitchenEquipment {
  getEquipment(id: "Kitchen_mixer_b_01") {
    ...CommonFields
  }
}
```
**Variables:**
```json
{
  "data": {
    "getEquipment": {
      "id": "Kitchen_mixer_b_02",
      "label": "Kitchen mixer B02",
      "_createdBy": "admin@rhize.com",
      "versions": []
    }
  }
}
```
{{% /tab %}}
{{% /tabs %}}

