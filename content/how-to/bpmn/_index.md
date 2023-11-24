---
title: 'Handle events'
date: '2023-09-22T14:50:39-03:00'
draft: false
categories: "how-to"
description: Create BPMN workflows to handle inputs and listen for events, and throw triggers.
weight: 300
menu:
  main:
    parent: how-to
    identifier: howto-bpmn
---

The heart of a manufacturing process is not data, but the _event_.

For its event handling, Rhize uses a custom {{< abbr "BPMN" >}} engine:
- The low-code, graphical notation makes workflow programming accessible to more people in your operation
- Its event-based workflows can listen for events published to the message broker, and send messages back
- The service task interface can make GraphQL queries, thus operate directly on the data in your data hub.

In the following topics, learn how to use Rhize's BPMN engine.
