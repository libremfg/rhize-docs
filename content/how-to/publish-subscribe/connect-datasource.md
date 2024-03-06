---
title: 'Connect data source'
date: '2023-09-22T14:50:39-03:00'
categories: "how-to"
description: Configure a data source to publish topics for the Rhize platform.
weight: 10
menu:
  main:
    parent: howto-pubsub
    identifier: connect-data-source
---

For Rhize to listen to and [handle]({{< relref "../BPMN" >}}) manufacturing events,
you need to connect a {{< abbr "data source" >}}.

## Prerequisites

To add a data source, you need the following:
- Access to an MQTT or OPC UA server
- Credentials for this server, if necessary
- The URL and connection string for this server (Rhize will  point to this)

## Steps to connect

The process has two sides:
- Sending topics from your MQTT, OPCUA, or NATS server to Rhize.
- In Rhize, [defining the data source]({{< relref "../model/create-objects-ui" >}}) and its associated objects.

  To do this, you can create entities in the Rhize UI, or through its [GraphQL API]({{< relref "../gql" >}}).

### Model the data source in the Rhize UI

1. Enter the Rhize UI and go to **Master Data > Data sources**.
1. Add the connection string, topics, and other necessary parameters. For details of what these fields mean, review the [Data source object reference]({{< relref "../model/master-definitions/#data-sources" >}}).
1. **Create** and then change version state to `Active`.

Now add the data source to its equipment (or, if it doesn't exist [model new equipment]({{< relref "../model/master-definitions#equipment" >}})):
1. Select the equipment, then **Data sources**.
1. If the equipment has properties bound to this data source, create the properties, then configure them as `BOUND` to the data source.


Once active, Rhize reaches out to this data source and synchronizes the equipment properties to the bound topics.

## Next steps

Now that you have the data source sending time-series data, you can [Create a workflow]({{< relref "bpmn" >}}) to handle the events that it publishes.
