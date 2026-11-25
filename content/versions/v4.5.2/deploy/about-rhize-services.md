---
title: >-
  About Rhize services
description: An overview of the Rhize services and the function each one plays
draft: false
categories: ["concepts"]
weight: 1
params:
  images:
    - "/images/arch/rhize-service-architecture.png"
---

This document covers the major components of Rhize's architecture and services.

{{< bigFigure
width="75%"
alt="rhize services and interaction"
src="/images/arch/rhize-service-architecture.png"
>}}

## Core backend infrastructure

The following services are the key components of the Rhize backend.

-  **RhizeDB (BaaS).**
    An ACID-compliant graph database, exposed to users through a GraphQL API.

-  **ISA-95.**
    The logic and schema for the ISA-95 data model.

    The ISA-95 service also contains helper functions to process ISA-95 entities. These include version control, property inheritance, event processing, and historization of equipment property data.

- **Workflow.**
    The workflow service processes the logic configured through the nodes and connections of a user-defined BPMN workflow.

- **Agent.**
    The Rhize agent bridges your plant telemetry and events with the Rhize data hub. It collects data emitted from the plant and publishes it to the message broker.

- **Restate.**
    Restate is the engine for stateful, durable execution. It serves multiple functions in the Rhize application stack:
    
    - **Durable execution.** Restate journals each step of an executing service. Even in the case of massive failure, such as a power outage, execution resumes from the last completed step.
    - **State management.** Restate stores state for services like ISA-95 and workflow, enabling stateful functions with durable execution.
    - **Concurrency control.** Restate ensures data integrity and idempotency for parallel processing.
    - **Decoupling.** Rhize services communicate through Restate's durable execution engine rather than directly with each other. This reduces complexity and ensures redelivery if a service is unavailable.
    - **Extensibility.** Users can write Restate handlers to deploy custom services.
    
    
- **Kubernetes.**
    Rhize deploys on Kubernetes. Manufacturing is data-intensive, and outages can have severe consequences.
    Kubernetes is the core infrastructure for high availability and scalability.
    As a de facto standard, Kubernetes has a diverse ecosystem, providing many tools and resources to extend and learn about the system.

    Rhize is agnostic about whether you deploy on-premises or in the cloud.

    For local testing, we also offer customers a Docker Compose environment.

## Rhize frontends

Apart from your custom frontends, the Rhize deployment has the following default services.

- **Admin UI.**
    The core Rhize interface to model entities, write BPMN workflows, explore queries, administer users, and so on.

- **Portal.**
   The Rhize portal provides a frontend to aggregate built-in and custom Rhize applications.

## Optional services

These third-party services are often found as defaults in Rhize deployments.

- **Audit.**
  A record of all changes to the database, stored in object store.

- **Grafana.**
   Observability dashboards and tracing.

- **QuestDB.**
   Rhize's default time-series database.
