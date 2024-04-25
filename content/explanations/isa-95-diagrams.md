---
title: ISA-95 diagrams
description: >-
    Helpful diagrams to present a high-level overview of the ISA-95 models
    for entities and information flows.
weight: 200
draft: false
menu:
  main:
    parent: explanations
---

The ISA-95 standard is long and thorough.
These diagrams provide some simplified visual explanations to help explain the varied categories of flows and relationships in the standard.
To read about how the standard fits within the data architecture of Rhize, read our blog post [Rethinking perspectives on ISA-95](https://rhize.com/blog/reframing-perspective-on-isa95/).

## Information exchange between models and levels

This diagram shows how information exchanges between resource models and systems.
It is a highly simplified view of some flows described in parts 2 and 4 of the standard.
Each entity in the diagram carries information in multiple dimensions, including:
- The entity's position in the resource model (as show by vertical orientation and color)
- Its relationship to other entities
- Its role in the integration of systems across level 3 and level 4 of the standard.

{{< notice "note" >}}

:movie_camera: Watch two manufacturing experts explain this diagram on [episode 1 of the Rhize podcast](https://www.youtube.com/watch?v=qfUnX-_J-to).

{{< /notice >}}

{{< bigFigure
src="/images/s95/rhize-s95-p2-p4-high-level-overview-ISA95_P2_P4.svg"
alt="A large overview of the ISA-95 object model"
caption="**Click to expand**"
width="85%"
>}}

## Overview of relations, levels, and stages

This diagram shows the top-level relations of manufacturing entities in level-3 and level-4 systems across different stages of production. 
These entities and their built-in inter-relations also are also some of the foundational objects for the Rhize data model (exposed through the Rhize [GraphQL Interface](/how-to/gql/)).

Outside the main diagram are relationships for certain entities.

{{< bigFigure
src="/images/s95/diagram-rhize-isa95-big-overview.svg"
alt="A large overview of the ISA-95 object model"
caption="**Click to expand**"
width="85%"
>}}


