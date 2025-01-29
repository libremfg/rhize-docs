---
icon: inbox-in
title: >-
  Data collection (eBR example)
description: An example of how Rhize ingests data from various sources to create Electronic Batch Records for pharmaceutical manufacturing
categories: ["howto", "use-cases"]
weight: 0100
images:
  - /images/og/graphic-rhize-data-collection-ebr.png
---

{{% notice note %}}

Looking to implement Rhize for your Pharma operation?
[Talk to an engineer](https://rhize.com/contact-us/)

{{% /notice %}}

This document provides examples of how you can use Rhize to automatically ingest data from various sources and store it in a standardized ISA-95 schema.
The examples here are to produce an Electronic Batch Record, an important use case in pharmaceutical manufacturing.
However, the process described here is very similar to what data collection would like when integrating with any third-party system (such as an MRP, CMMS, and so on), no matter the type of manufacturing process.

The procedure has the following steps:

1. Identify the sources of data.
1. Map the fields for these data sources to Rhize's ISA-95 schema.
1. Write {{< abbr "BPMN" >}} processes that listen for relevant eBR events and transform the incoming data to the ISA-95 schema.
1. After the batch finishes, query the database with the fields for your {{< abbr "ebr" >}}.

The following sections describe this process in a bit more detail.

## Prerequisites

This procedure involves multiple data sources and different operations to transform the incoming data and store it in the graph database.
Before you start, ensure that you have the following:
- Awareness of the different sources of eBR data
- If real-time data comes from equipment, [Connected data sources]({{< relref "how-to/publish-subscribe/connect-datasource" >}})
- Sufficient knowledge of the ISA-95 standard to model the input data as ISA-95 schema
- In the BPMN process, the ability to filter JSON and [call the GraphQL API]({{< relref "how-to/gql" >}})

In larger operations, different teams may help with different parts of the eBR-creation process.
For example, your integrators may help appropriately model the data, and the frontend team may render the outputted JSON into a final document.

## Steps to automate eBR creation

The following steps describe the broad procedure to automatically update the database for incoming batch data, then automatically create an eBR after the batch run.

### Identify the sources of data

The first step is to identify the sources of data for your eBR.

{{< figure
alt="Diagram showing some examples of eBR data sources"
src="/images/ebr/diagram-rhize-example-ebr-sources.png"
width="75%"
>}}

Common data sources for an eBR include:

- **{{< abbr "ERP" >}} documents:** high-level operations documents. This might include information about planning and scheduling.
- **{{< abbr "MES" >}} data:** granular process data, tracking objects such as the weight of individual material and the responses for different jobs.
- **{{< abbr "LIMS" >}} documents:** information about the laboratory environment and testing samples
- **Real-time event data:** for example, data sent from OPC UA or MQTT servers
- **Exceptions:** Errors and alerts raised from the operator screen or automation system

### Model the fields as ISA-95 schema

After you've identified the source data, the next step is to map this data into ISA-95 models.

{{< figure
alt="diagram showing some examples of ISA-95 modeling"
src="/images/ebr/diagram-rhize-map-ebr-isa95.png"
width="80%"
>}}

Some common objects to map include raw and final material, equipment, personnel, operations schedule, segments, job responses, exceptions, and the ERP batch number.
Once ingested, all data is linked through common associations in the graph database and is thus accessible through a single query.

### Write a BPMN workflow to ingest the data in real-time

{{< bigFigure
alt="Example of a BPMN workflow"
src="/images/ebr/diagram-rhize-bpmn-ebr.png"
width="60%"
caption="A simplified BPMN workflow. For an example of a real workflow with nodes for each logic step, refer to the next image."
>}}

With the sources of data and their corresponding models, the next step
is to write a [{{< abbr "BPMN" >}}]({{< relref "/how-to/bpmn" >}}) workflow to automatically transform the data and update the database.

{{< notice "note" >}}
You may want to break these steps into multiple parts.
Or, for increased modularity, you can call another BPMN workflow with a [Call activity]({{< relref "how-to/bpmn/bpmn-elements">}}#call-activities).
{{< /notice >}}

The procedure is as follows:

1. Create a BPMN that is [triggered]({{< relref "how-to/bpmn/trigger-workflows" >}}) by a relevant eBR event. For example, the workflow might subscribe to a  `/lims/lab1`, or be triggered by a call to the Rhize API. If the data comes from certain equipment, you first need to [Connect a data source]({{< relref "how-to/publish-subscribe/connect-datasource" >}}).

1. Transform with JSONata

   Rhize has a built-in [JSONata]({{< relref "how-to/bpmn/use-jsonata" >}}) interpreter, which can filter and transform JSON.
   Use a [JSONata service task]({{< relref "how-to/bpmn/bpmn-elements">}}#jsonata-transform) to map the data sources into the corresponding ISA-95 fields that you defined on the previous step.
  
   Use the output as a variable for the next step.
   

1. POST data with a graph mutation.

   Use the variable returned by the JSONata step to send a mutation to update the Graph database with the new fields.
   To learn more, read the [Guide to GraphQL with Rhize]({{< relref "how-to/gql" >}}).

In real BPMN workflows, you can dynamically create and assign fields as they enter the system.
For example, this workflow creates a new material definition and material-definition version based on whether this object already exists.

{{< bigFigure
alt="Screenshot of a BPMN workflow that adds material only if it exists"
src="/images/bpmn/screenshot-rhize-bpmn-add-material-definition.png"
>}}

This step can involve multiple BPMN processes subscribing to different topics.
As long as the incoming event data has a common association, for example, through the `id` of the batch data and associated `JobResponse`, you can return all eBR fields in one GraphQL query&mdash;no recursive SQL joins needed.

{{< figure
alt="Multiple BPMN processes can be united in one batch"
src="/images/ebr/diagram-rhize-inputs-for-ebr.png"
width="75%"
>}}

### Query the DB with the eBR fields

After the batch finishes, use a [GraphQL query]({{< relref "how-to/gql/query" >}}) to receive all relevant batch data.
You only need one precise request to return exactly the data you specify.

{{< figure
alt="Diagram showing how a query makes an ebr"
src="/images/ebr/diagram-rhize-make-ebr-query.png"
width="55%"
>}}
   
Here is a small, generic snippet of how it looks:
Note how the query specifies exactly the fields to return: no further response filtering is required.
For an idea of how a more complete query looks, refer to the [Electronic Batch Records]({{< relref "ebr" >}}) guide.

{{< expandable title="Snippet of a makeEbr query" >}}
```graphql
query makeEbr ($filter: JobOrderFilter) {
  queryJobResponse(filter: $filter) {
    EXAMPLE_id: id
    description
    matActualProduced: materialActual(filter:{materialUse: { eq:Produced }}){
      id
      material: materialDefinitionVersion{
        id
      }
      quantity
      quantityUoM {
        id
      }
    }
  ## More eBR fields
  }
}
```
{{< /expandable >}}

The only extra step is to use the returned JSON object as the input for however you create your eBR documents.

## Next steps

Fast eBR automation is just one of many use cases of Rhize in the pharmaceutical industry.
With the same event data that you automatically ingest and filter in this workflow, you can also:
- Program reactive logic using BPMN for {{< abbr "event orchestration" >}}. For example, you might send an alert after detecting a threshold condition.
- Analyze multiple batch runs for deviations. For example, you can query every instance of a failure mode across all laboratories.
- Compare batches against some variable. For example, you can compare all runs for two versions of equipment.

