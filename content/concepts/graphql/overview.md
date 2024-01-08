+++
title = "Overview"
weight = 5
[menu.main]
  identifier = "graphql-overview"
  parent = "garphql"
+++

## Introduction

GraphQL is a powerful query language for APIs that enables clients to request only the data they need. It provides a flexible and efficient alternative to traditional REST APIs, allowing clients to define the structure of the response and receive exactly the data they require. In Rhize, GraphQL plays a central role in unifying the communication between microservices within the manufacturing execution system.

## Microservices

Rhize adopts a microservices architecture to enhance scalability, maintainability, and flexibility. Most microservices in the Rhize ecosystem exposes a GraphQL API, which serves as a standardized interface for interacting with specific functionalities. This approach ensures that different components of Rhize can operate independently while seamlessly communicating through a common data query language.

## Subgraph

A subgraph in Rhize refers to an individual GraphQL API provided by a microservice. These subgraphs represent distinct functionalities or domains within the manufacturing execution system. An example is `BPMN`. Subgraphs encapsulate specific data models, business logic, and operations related to their respective microservices.

## Supergraph Composition with Apollo Router

The API in Rhize is a supergraph that is a composition of multiple subgraphs orchestrated using the Apollo Router. The Apollo Router serves as a middleware that combines individual microservice GraphQL APIs into a unified and cohesive supergraph. This composition enables clients to interact with the entire Rhize system seamlessly, as if it were a single, integrated GraphQL schema.

### Benefits of Supergraph Composition

1. *Unified API* The supergraph presents a single, comprehensive API that abstracts the complexity of the underlying microservices. Clients can query and mutate data across multiple domains without needing to manage separate endpoints.
1. *Efficient Communication* Supergraph composition optimizes data fetching by reducing over-fetching and under-fetching. Clients receive precisely the data they request, enhancing performance and minimizing network overhead.
1. *Flexibility and Agility* Rhize can evolve and scale its microservices independently without disrupting client applications. The supergraph adapts to changes in the underlying microservices, providing a flexible and future-proof architecture.

## Getting Started with Rhize GraphQL

To start leveraging Rhize's GraphQL capabilities, developers can refer to (Call the GraphQL API)[/how-to/gql/call-the-graphql-api/] for information on available queries, mutations, and subscriptions. The documentation outlines the structure of the supergraph, including the various subgraphs and their corresponding functionalities.
