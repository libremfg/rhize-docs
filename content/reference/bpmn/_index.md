---
title: 'BMPN elements'
date: '2023-09-26T11:10:37-03:00'
draft: false
categories: [reference]
description: >-
  A reference of all BPMN elements used in the Rhize BPMN engine.
weight: 600
menu:
  main:
    parent: reference
    identifier: bpmn-reference
---

These pages describe the elements to make a Rhize {{< abbr "bpmn" >}} workflow, and their parameters to set conditions, use variables, and call services. 

Rhize BPMN elements are based on the Business Process Model and Notation [OMG Standard](https://www.omg.org/spec/BPMN/2.0/).
While the visual grammar is functionally same, we extend some elements for specific Rhize features, like service tasks that call the GraphQL gateway.

Each BPMN workflow is a _process_ with an ID.
Each process is made up _events_ (circles), _activities_ (rectangles), _gateways_, and _flows_ (arrows).


