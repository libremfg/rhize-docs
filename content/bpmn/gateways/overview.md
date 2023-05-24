+++
title = "Gateway Overview"
description = "This is my description"
weight = 1
[menu.main]
parent = "gateways"
+++

BPMN gateways are used to depict decision points and control flow within a process in business process modelling. Gateways enable the modelling of complex routing and branching logic, allowing for conditional paths and synchronisation of process flows. They help define how the process should behave based on certain conditions or events. The 5 gateway types, Parallel, Inclusive, Exclusive, Complex and Event Based, each represent different condition logic, such as AND, XOR, OR and +.

## Exclusive Gateway
An exclusive gateway is a type of gateway used to model decision points within a business process where only one path can be taken. It represents a point in the process where a single alternative must be chosen among multiple mutually exclusive options based on specified conditions or rules. 
## Inclusive Gateway
An inclusive gateway allows multiple outgoing sequence flows to be chosen simultaneously. It represents a decision point where multiple paths can be followed concurrently based on their conditions. All sequence flows whose conditions evaluate to true will be taken.
## Parallel Gateway
A parallel gateway represents a synchronization point where multiple incoming sequence flows are merged into a single outgoing flow or vice versa. It is used to split the process flow into parallel paths or to join parallel paths back together. All incoming sequence flows must complete before the gateway allows the process to continue.
## Event-Based Gateway

## Complex Gateway
Complex gateways are a type of BPMN gateway that combines multiple conditions and routing rules to determine the flow of a process. They are used to model more intricate decision-making scenarios that cannot be adequately represented using the basic gateways (exclusive, inclusive, parallel, and event-based). They provide a way to express complex business logic by evaluating multiple conditions simultaneously and determining the appropriate path based on the combination of these conditions.

