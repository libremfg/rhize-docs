---
title: 'NATS configuration'
date: '2023-10-04T10:22:15-03:00'
draft: true
category: reference
description: Values and parameters to configure NATS in your Rhize operation
weight: 300
menu:
  main:
    parent: reference
    identifier: nats-reference
---

Rhize uses the [NATS message broker](https://nats.io/) for its publish-subscribe messaging.
Through NATS, Rhize can decouple services, exchange messages in real-time,
and receive event data from all levels of the operation.

These sections describe NATS parameters that are particularly relevant to Rhize's configuration.
For general use, refer to the [NATS official documentation](https://docs.nats.io/nats-concepts/overview).

## Built-in topics

Generally, operators have complete control over what events a service publishes or subscribes to.
However, a few critical topics are built-in to some services.

- `Topic_name`
  - Purpose:
  - Expected structure:
  - Publishers: serviceOne, serviceTwo
  - Subcribers: serviceX, serviceY

_Editor's note:
Maybe it makes more sense to make list by service, rather than by topic._

## Message queue parameters

You can configure message queues in two ways:
- By size (for example `2GB`)
- By TTL limits (for example, `7 days`)

_Editor's note: Make a list or table of parameters.
Whatever would help people look up values while they implement._

