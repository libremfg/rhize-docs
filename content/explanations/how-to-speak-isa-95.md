---
title: How to speak ISA-95
description: More than a standard, ISA-95 is a specialized vocabulary that describes all elements of manufacturing operation.
og_image: /images/og/graphic-rhize-how-to-speak-isa95.png
menu:
    main:
        parent: "explanations"
---

[ISA-95](https://www.isa.org/store?query=isa95) provides a common language to discuss manufacturing.
When you speak with other manufacturing stakeholders, you can use the standard's precise vocabulary to ensure that everyone is speaking about the same thing.

The standard also describes how different manufacturing entities relate to each other.
[With the right application architecture](https://rhize.com/blog/reframing-perspective-on-isa95/),
these relationships can form a complete and coherent data model of a full manufacturing operation.
Thus learning how to speak the language of ISA-95 can help standardize communication between both humans and machines.

However, while ISA-95 is not as complex as a natural human language, it is lengthy. This document provides a brief introduction to some essential terminology.

## Foundational concepts

The following concepts frame all conversation that involves ISA-95.
If you are a manufacturing veteran, they might be familiar to you.
But a high-level review never hurt anyone.

### The levels of a manufacturing operation


{{< bigFigure
alt="Levels of a manufacturing operation"
src="/images/s95/diagram-rhize-isa95-levels.svg"
width="80%"
>}}

Discussions that involve ISA-95 frequently reference the _levels_ of a system.
You may hear phrases like "this workflow integrates level-4 data with level-3 activities,"
or "the batch is a level-3 construct".
In this context, _level_ corresponds the degree of granularity necessary to discuss and exchange data for different purposes in the manufacturing operation.



| Level | Operational Perspective             | Example system                                           |
|-------|-------------------------------------|----------------------------------------------------------|
| 4     | Business planning                   | {{< abbr "ERP" >}}                                       |
| 3     | Manufacturing operations management | {{< abbr "MES" >}}, {{< abbr "CMMS" >}}, Quality control |
| 2     | Monitoring and acquisition          | SCADA                                                    |
| 1     | Sensors                             | PLCs                                                     |

While **ISA-95 focuses on level 3 and the interaction between levels 3 and 4**, your models can incorporate data from level 2.

### Role based equipment hierarchy: the view from up top {#rbeh}

The _equipment hierarchy_ represents how equipment can contain other equipment, as a production line might contain a conveyor belt and a pneumatic actuator.

ISA-95 defines equipment across multiple scales.
The scale may be as broad as the building where a plant makes items or as a granular as an individual unit that performs one small action within a complex process.

{{< bigFigure
alt="Role-based equipment hierarchy"
src="/images/s95/diagram-rhize-isa95-equipment-hierarchy.svg"
width="65%"
>}}

These equipment hierarchies often provide a naming convention to prefix addresses for plant data.
For example, an MQTT topic might be named `site1/bakery2/kitchenA/ovens/a_temp_sensor`.
In Rhize, the [Equipment UI]({{< relref "/how-to/model/master-definitions" >}}) provides an interface to model your plant according to this compositional hierarchy.

### Relationships

Most diagrams about models in ISA-95 show a collection of objects that are connected by lines and arrows.
These lines and arrows represent _relationships_.

Understanding how entities relate is fundamental to understanding how to the manufacturing process works as a complete system.
Nothing in a manufacturing operation happens in a vacuum,
and ISA-95 describes these connections with a precise vocabulary of relation.

Some important relations include:
- **Defined by**. As a member may be defined by a class.
- **References** As an operations definition references a bill of material
- **Assembled from**. As a final material lot may be assembled from various intermediate lots.
- **Made up of**. As work schedules are made up of work requests, and work centers are made up of work units.

For the full list of relationships, refer to ISA-95 Part 2.
To explore the relationships in an interactive way,
you can use the Rhize [GraphQL]({{< relref "/how-to/gql">}}) API explorer.

## The activities of an MES

Much of the ISA-95 standard discusses operations at the view of level 3, that is the MES or _Manufacturing Operations Management (MOM)_ system. But what activities are part of a MOM system? This is the subject of ISA-95 part 3.

{{< bigFigure
src="/images/s95/diagram-rhize-isa95-activity-model.svg"
alt="The activities of a level-3 system"
caption="Different activities of a level-3 system and their interactions with other levels. Broadly, activities can be categorized as reference, pre-execution, execution, and post-execution."
width="75%"
>}}

The 8 major activities of a MOM are as follows:

* **Product definition:** What goes into a product, and what resources does it require?
* **Resource management:** What resources are available to produce goods?
* **Detailed production scheduling:** When and what does the business want to produce? After a business determines its demand, it can build a schedule using its available resources.
* **Production dispatching:** How will the plant assign the available resources to produce the schedule? Once the schedule is received, the level-3 system can assign resources to orders by referencing the definitions and capabilities.
* **Production execution management:** How does the plant execute the order?
* **Production data collection:** What data is emitted and stored during execution?
* **Production tracking:** What components and actions went into production? For example, [EBR](https://docs.rhize.com/use-cases/ebr/), [Genealogy](https://docs.rhize.com/use-cases/genealogy/), and Track and Trace are all use-cases of production tracking.
* **Production performance analysis:** How well did the actual production run go, as compared to its ideal? For example, measures of OEE, deviation analysis, and golden batches are all use-cases of performance analysis.

To make sense of these activities, you also need to have a concept of the relationship between planned and performed work.

### Definition, demand, result

Almost all manufacturing processes share a common flow, from _definition_ to _production_ to _analysis_:

1. A business defines how a good is to be produced.
2. The business then creates a schedule that demands that a number of these goods are produced according to its definition.
3. The plant uses its available resources and references the existing definitions to execute the orders from the schedule.


{{< bigFigure
src="/images/s95/diagram-rhize-isa-definition-demand-result-l3-l4.svg"
alt="Models to define, demand, and produce work"
caption="**The relationships between requests, responses, segments, and resources across level 4 and level 3 systems.**"
width="85%"
>}}


As long as a business continues to make things, its processes always include a definition of work, a demand for work, and the result of production.
These categories inform not only the activities of manufacturing but also the models of production that make each of these activities sensible.

## Frequently used models

ISA-95 describes how production _entities_ relate to one another within and across the manufacturing activities.
Entities are physical or abstract objects that make up the composition of a manufacturing process in its past, present, future, and ideal state.
Here are some of the most common entities.

### Resources

All aspects of manufacturing involve resources. Without resources nothing can be done or made. ISA-95 Parts 1 and 2 provide a rich and extensive vocabulary for discussing resources. Generally the resource models have the following patterns:

* _Classes_ provide groupings and associations
* The members of a class are objects that exist in the real world. These _instances_ are represented with versions.
* As the work executes, the _actuals_ define what resource was really used for a specific job.
* These resources are part of specifications and requirements for definitions of work:

All of these resource models can be extended with _properties_.

#### Equipment


{{< watch
text="Creating an equipment model in Rhize"
src="https://www.youtube.com/watch?v=Wh6sYCuNYJI&list=PLeYowHxqJrUi5ojKBvYg3CnfYdvOqVMi5&index=1"
>}}

_Equipment_ is a tool used in the production process.
Important equipment models include the following:

- **Equipment classes.** Equipment that shares some purpose, such as `rotating widget makers`.
- **Equipment (Instance).** An instance of an equipment class, such as `compressor-5, version 2`.
- **Actual.** The equipment that really performed a job. For example, the actual could be the ID of the compressor involved in some specific production.
- **Equipment Properties.** Attributes of an equipment or equipment class. For example, a property of an compressor might be `rotation_speed`.

Relationships between equipment are organized according to the role-based equipment hierarchy and, optionally, the hierarchy scope.

#### Material

{{< watch
text="Five ways to view material through ISA-95"
src="https://www.youtube.com/watch?v=Xd5kj1TUQkY"
>}}

_Material_ is all the input matter required to produce a finished good.
Import material models include the following:

{{< bigFigure
alt="Material class, definition, lot, and sublot"
src="/images/s95/diagram-rhize-material-class-definition-lot.png"
width="50%"
>}}

- **Material classes.** Material classes represent a broad group of associated materials. An example might be `raw_sugar`.

- **Material definitions.** A standardized definition of some material, ensuring consistency in the operation.
- **Material lots.** Material lots and sublots are the identifiable units that go into a larger assembly.
For example, a material lot might be a pallet of sugar from a supplier, and the sublot might be the individual sugar bags.

   Lots can have parent/child relationships to express material compositions.
   The composition could be reversible, as in a machine assembled from interchangeable parts, or permanent, as in the case of a processes that involve one-way chemical transformations.

- **Material Actual.** A material actual is the quantity of material in a job that is used, consumed, marked as scrap, and so on.
- **Material properties.** Properties of material that are relevant to the production process, for example, `meltingPoint` or `containsLactose`.

This relationship expresses how material is composed of other material.

#### Personnel

_Personnel_ are the people who execute a job.
Important personnel models include:

- **Personnel class.** A group of people with an associated function, for example `coil_operators`.
- **Person.** The "instance" of a personnel class, where the "version" may track properties like certifications and years of experience.
- **Personnel actual.** The people who really perform a certain job.
- **Personnel properties.** Attributes such as `trained to operate heavy machinery`. Properties could also communicate a person's location or current assignment.

### Hierarchy scope: multiple views of equipment hierarchies

The hierarchy scope is a special grouping of equipment that does not necessarily follow the conventional role-based hierarchy.
For example, Rhize uses hierarchy scope to [ define calendar rules and calculate metrics ](https://docs.rhize.com/how-to/work-calendars/about-calendars-and-overrides/#)for a set of machines whose shift rules don't necessarily correspond to the hierarchy. You might also set a hierarchy scope to calculate metrics or track production across an arbitrary grouping of equipment.

{{< bigFigure
src="/images/work-calendars/diagram-rhize-work-calendar-relationships.png"
caption="The calendar service uses the relationships between equipment, hierarchy scope, and work calendars."
alt="Diagram of relationship between three configurations"
width="50%"
>}}

### Segments: process steps to execute

The process segment defines the unit of work as it is visible from the business.
For example, a baking operation may have the segments `mixing`, `baking`, `cooling`, `testing`, and `storing`.

A segment indicates that a unit of work is meaningful for the business to follow.
While `mixing` might be example of a valid segment, an individual turn of the mixing motor would be a very unlikely segment, as the action is too granular to provide any useful context to the business.

A segment may specify its necessary work definitions and resources.
Process segments also serve as information containers to analyze and track the production of a good at some stage in its lifecycle.

## Work done and requested

{{< bigFigure
alt="Schedules and requests"
src="/images/s95/diagram-rhize-isa95-schedule-requests.svg"
caption="An operations schedule is associated with a work requests, which has associated job orders"
width="60%"
>}}

Besides resources, manufacturers also need to track and describe how work is demanded and performed.

ISA-95 offers vocabulary to describe the views of this work from both the level-4 (business) perspective and the level 3 (execution) perspective.
If you're wondering whether a model refers to level three or four, keep this trick in mind:

**Models that start with "operation" refer to level 4; models that start with "work" refer to level 3.**


### The operational view of work

In all conventional manufacturing, demand originates from the "top," that is, from the business or level-4 system. And production results are compared against this original demand. Thus, all conventional models of manufacturing include a model of demand, definitions, and results from the level-4 perspective.

This operational view of work is defined in ISA-95 part 2.
Here is a quick primer on the major models:

* **Operations definitions** define the resources required to perform a schedule.
* **Operations schedules** include the _requests_ to produce goods.
These requests typically demand that production occur at certain times or by certain deadlines.
* **Operations performance** is the collection of _responses_ to a request. Performance models provide information about the _state_ of a request, such as `WAITING`, `READY`, `RUNNING`, and `COMPLETED`.
* **Operations capability** provides information about the resources for past and future operations. These capability models provide a way to determine a plant's theoretical maximum capacity and a way to analyze how well past production operations performed against this capacity.

### The level-3 view of work

{{< bigFigure
alt="Requests and responses being passed"
src="/images/s95/diagram-rhize-isa-95-requests-responses.webp"
caption="The flow of requests and performance from level 4 to level 3"
width="50%"
>}}

ISA-95 part 4 defines the level-3 models of work. These models are more granular and detailed than their corresponding operational models.

Typically, one operations request corresponds to one work request, and they differ the degree of detail reported in the work request. For example, the operations request may ask for 1000 intermediate widgets, and the work request produces these intermediate widgets.

However, a work request may also fulfill multiple or even fractional operations requests―for example, a work request may produce 1500 intermediate widgets, allocating 1000 to fulfill the operational request and sending the spare 500 to storage.

#### Defined work

The _Work Master_ provides a set of resource specifications to do some work. It may be associated with segment.
When it is planned in a real job order, the work master is "cloned" as a _Work Directive._

#### Planned work
Planned work broadly follows the following hierarchy

* **Work Schedule.** A schedule to perform some batch, which contains one or more work requests
* **Work Request.** A collection of job orders to make something
* **Job Order.** An order to execute a specific part in a work request

#### Performed work

{{< watch
text="Query a job response and its linked data"
src="https://www.youtube.com/watch?v=EkAbNbx6LQw&t=2s"
>}}

The performance of a production run is queried through the _job response_. This response exists in the following hierarchy:

* **Work Performance.** A collection of work responses that detail the performance of the work done for some work schedule
* **Work response.** A collection of job responses that map to a work request
* **Job response.** The data about the real performance of a job order, including its start and end times and resource actuals.

## Now you're talking

In this document, you've learned the basic vocabulary to discuss manufacturing according to a standardized model.
However, this is still an extremely brief entry into ISA-95, whose full standard has 9 parts and thousands of words.

Nevertheless, the best way to acquire a language is to practice it.
Can you think of how all the preceding terms apply to your manufacturing operation? Try to apply the terms with some colleagues!
