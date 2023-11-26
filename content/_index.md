+++
date = "2017-03-20T19:35:35+11:00"
title = "The Rhize Manufacturing Data Hub"
description = "User guides, deploy docs, references, and deep dives about the Rhize manufacturing data hub."
[menu.main]
name = "Home"
identifier = "home"
weight = 0
+++

Rhize is a real-time, event-driven manufacturing data hub.

In one hub, Rhize unites all manufacturing event data, relates the events through a standardized data model, and makes all this data accessible through a single endpoint.
The tight integration of all levels of manufacturing data, from real-time sensor data to operations orders, serves a wide variety of business needs, including:

- **A manufacturing knowledge graph**, helping humans and algorithms analyze plant processes and discover places to optimize.
- **An {{< abbr "MES" >}} to handle manufacturing events in real time**, sliding the time when you detect and recover from errors to much earlier in the production line.
- **A backend to build lowcode manufacturing applications**, giving your people the power to create interfaces that solve problems close to their work domains.


<div class="landing">

  <div class="item">
    <div class="icon"><i class="fa fa-info-circle" aria-hidden="true"></i></div>
    <a href="{{< relref "/get-started/introduction">}}">
      <h2>Introduction</h2>
      <p>
      What is Rhize? How does it work?
      </p>
    </a>
  </div>

  <div class="item">
    <div class="icon"><i class="fa fa-building" aria-hidden="true"></i></div>
    <a href="{{< relref "/deploy">}}">
      <h2>Deploy</h2>
      <p>
      Install, backup, upgrade, and restore.
      </p>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="fa fa-object-group" aria-hidden="true"></i></div>
    <a href="{{< relref "/how-to/bpmn">}}">
      <h2>Model</h2>
      <p>
      Define your production in a common data model.
      </p>
    </a>
  </div>
  <div class="item">
    {{< gql-icon >}}
    <a href="{{< relref "/how-to/gql">}}">
      <h2>Query</h2>
      <p>
      Use the manufacturing knowledge graph for analysis and custom frontends
      </p>
    </a>
  </div>
  <div class="item">
    <a  href="{{< relref "/reference">}}">
    <div class="icon"><i class="fa fa-wrench" aria-hidden="true"></i></div>
      <h2>Handle events</h2>
      <p>
      Write custom frontends to monitor process and build pubsub MES.
      </p>
    </a>
  </div>
  <div class="item">
    <div class="icon"><i class="fa fa-level-up" aria-hidden="true"></i></div>
    <a href="{{< relref "/releases">}}">
      <h2>Releases</h2>
      <p>
        What's new in Rhize.
      </p>
    </a>
  </div>

</div>

