+++
date = "2024-01-04"
title = "GraphQL"
description = "GraphQL"
[menu.main]
identifier = "graphql"
parent = "concepts"
weight = 4
+++


<div class="landing">
  <div class="hero">
    <p>
      GraphQL query exactly what you want with first class joins.
    </p>
    <img class="hero-deco" src="/images/hero-deco_403x160.png" />
  </div>
  <div class="item">
    <div class="icon"><i class="lni lni-play" aria-hidden="true"></i></div>
    <a  href="{{< relref "overview.md">}}">
      <h2>Introduction</h2>
      <p>
        GraphQL is a powerful query language for APIs that enables clients to request only the data they need. It provides a flexible and efficient alternative to traditional REST APIs, allowing clients to define the structure of the response and receive exactly the data they require. In Rhize, GraphQL plays a central role in unifying the communication between microservices within the manufacturing execution system.
      </p>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="lni lni-play" aria-hidden="true"></i></div>
    <a  href="{{< relref "..">}}">
      <h2>Microservices</h2>
      <p>
        Rhize adopts a microservices architecture to enhance scalability, maintainability, and flexibility. Most microservices in the Rhize ecosystem exposes a GraphQL API, which serves as a standardized interface for interacting with specific functionalities. This approach ensures that different components of Rhize can operate independently while seamlessly communicating through a common data query language.
      </p>
    </a>
  </div>

  <div class="item">
    <div class="icon"><i class="lni lni-play" aria-hidden="true"></i></div>
    <a  href="{{< relref "..">}}">
      <h2>Subgraph</h2>
      <p>
        A subgraph in Rhize refers to an individual GraphQL API provided by a microservice. These subgraphs represent distinct functionalities or domains within the manufacturing execution system. An example is `BPMN`. Subgraphs encapsulate specific data models, business logic, and operations related to their respective microservices.
      </p>
    </a>
  </div>

  <div class="item">
    <div class="icon"><i class="lni lni-play" aria-hidden="true"></i></div>
    <a  href="{{< relref "..">}}">
      <h2>Supergraph Composition with Apollo Router</h2>
      <p>
        The API in Rhize is a supergraph that is a composition of multiple subgraphs orchestrated using the Apollo Router. The Apollo Router serves as a middleware that combines individual microservice GraphQL APIs into a unified and cohesive supergraph. This composition enables clients to interact with the entire Rhize system seamlessly, as if it were a single, integrated GraphQL schema.
      </p>
      <h2> Benefits of Supergraph Composition</h2>
      <ul>
        <li><strong>Unified API</strong>: The supergraph presents a single, comprehensive API that abstracts the complexity of the underlying microservices. Clients can query and mutate data across multiple domains without needing to manage separate endpoints.</li>
        <li><strong>Efficient Communication</strong>: Supergraph composition optimizes data fetching by reducing over-fetching and under-fetching. Clients receive precisely the data they request, enhancing performance and minimizing network overhead.</li>
        <li><strong>Flexibility and Agility</strong>: Rhize can evolve and scale its microservices independently without disrupting client applications. The supergraph adapts to changes in the underlying microservices, providing a flexible and future-proof architecture.</li>
      </ul>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="lni lni-play" aria-hidden="true"></i></div>
    <a  href="{{< relref "..">}}">
      <h2>Getting Started with Rhize GraphQL</h2>
      <p>To start leveraging Rhize's GraphQL capabilities, developers can refer to the official documentation for information on available queries, mutations, and subscriptions. The documentation outlines the structure of the supergraph, including the various subgraphs and their corresponding functionalities.</p>
    </a>
  </div>
</div>

<style>
  ul.contents {
    display: none;
  }
</style>
