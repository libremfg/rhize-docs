---
title: 'Connect data source'
date: '2023-09-22T14:50:39-03:00'
draft: false
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

To add a data source, you'll need:
- Access to an MQTT or OPC UA device
- Credentials for this device, if necessary
- The URL of your Rhize environment

## Steps to connect

The process has two sides:
- Sending topics from your MQTT or OPCUA device to Rhize.
- [Modeling the data source]({{< relref "../model" >}}) and its associated objects.
  You can create entities in the Rhize UI, or through its [GraphQL API]({{< relref "../gql" >}}).

### Send your process data to Rhize

1. Enter the explorer or OPC UA server for the device.
1. Add the Rhize URL.
1. Add the topics that you want to send.

### Model the data source on Rhize

1. Enter the Rhize UI and go to **Master Data > Data sources**.
1. Add the connection string, topics, and other necessary parameters. For details of what these fields mean, review the [Data source object reference]({{< relref "../model/master-definitions/#data-source" >}}).
1. **Create** and then change version state to `Active`.

Now add the data source to its equipment (or, if it doesn't exist [model new equipment]({{< relref "../model/master-definitions#equipment" >}})):
1. Select the equipment, then **Data sources**.
1. If the equipment has properties bound to this data source, create the properties, then configure them as `BOUND` to the data source.

## Next steps

Now that you have the data source sending time series data, you can [Create a workflow]({{< relref "bpmn" >}}) to handle the events that it publishes.
