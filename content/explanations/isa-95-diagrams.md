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

These diagrams provide some highly simplified visual explanations gleaned from parts of the thorough [ISA-95 standard](https://www.isa.org/store?query=isa95).
To read about how the standard fits within the data architecture of Rhize, read our blog post [Rethinking perspectives on ISA-95](https://rhize.com/blog/reframing-perspective-on-isa95/).

## Definition, demand, result

At a high-level, manufacturing consists of:
- Goods being demanded
- Goods being produced

Between these two points, the manufacturing operations performs this work according to its definitions
of work and the resources that it has available.
This diagram shows how ISA-95 defines these fundamental relationships from the perspective of the business (ERP) and manufacturing operation (MOM).


{{< bigFigure
src="/images/s95/diagram-rhize-definition-demand-result-l3-l4.png"
alt="Models to define, demand, and produce work"
caption="**Click to expand**"
width="85%"
>}}


## Information exchange between models and levels

This diagram shows how information exchanges between resource models and systems.
It is a highly simplified view of some flows described in parts 2 and 4 of the standard.
Each entity in the diagram carries information in multiple dimensions, including:
- The entity's position in the resource model (as shown by vertical orientation and color)
- Its relationship to other entities
- Its role in the integration between level-3 and level-4 systems.

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
These entities and their relationships also represent some foundational objects in the Rhize data model (exposed through the Rhize [GraphQL Interface](/how-to/gql/)).

{{< bigFigure
src="/images/s95/diagram-rhize-isa95-big-overview.svg"
alt="A large overview of the ISA-95 object model"
caption="**Click to expand**"
width="85%"
>}}


