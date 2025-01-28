---
title: 'Define production models'
description: Create models for equipment, data sources, operations definitions, work definitions, and so on. 
date: '2023-09-22T14:50:39-03:00'
draft: false
weight: 300
---

You have multiple ways to update your production models:

- Use the UI to define it for an individual unit or class
- POST a batch over the GraphQL API
- Use BPMN as a filter receive an incoming ERP document and map into the system

The trade offs are usually upfront configuration time, number of items to add, and level of automation.
Adding an item over the UI requires no programming skill, but you can only add only one unit at a time.
Creating a BPMN process to listen for an event and automatically map new units brings the highest automation, but it requires upfront investment to write and test the BPMN workflow.


{{< card-list >}}
