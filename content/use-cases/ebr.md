---
title: >-
  Electronic batch records
description: An example of how to use Rhize to create an Electronic Batch Records for pharmaceuticals
draft: false
categories: ["howto", "use-cases"]
weight: 001
menu:
  main:
    parent: use-cases
    identifier:
---

In pharmaceutical manufacturing, an _Electronic Batch Record (eBR)_ is a detailed report about a specific batch.
It includes information about items such as the process segments, material, personnel, and equipment.

As Rhize can ingest data from all levels of the manufacturing process, and do so in real-time, it is an ideal single source of truth to create eBRs.
The process can be highly automated and highly efficient.
Our experience in production systems shows that Rhize can typically generate an eBR in less than 500 milliseconds. 

The procedure has the following steps:

1. Identify the sources of data
1. Map the fields for these data sources to Rhize's ISA-95 schema
1. Write a BPMN process that listens for a data source, transforms the incoming data to the schema, and then sends a {{< abbr "mutation" >}} to update the Rhize database.
1. After the batch finishes, query the database with the fields for your {{< abbr "ebr" >}}.

The following sections describe this process in a bit more detail.

## Prerequisites

This procedure involves multiple data sources and different operations to transform the incoming data and store it in the graph database.
Before you start, ensure that you have the following:
- Awareness of the different sources of EBR data
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


Common data sources for an eBR might include:

- **{{< abbr "ERP" >}} documents:** high-level operations documents
- **{{< abbr "MES" >}} data:** granular process data, tracking objects such as the weight of individual material and the responses for different jobs.
- **{{< abbr "LIMS" >}} documents:** information about the laboratory environment
- **Real-time event data:** for example, data sent from OPC UA or MQTT servers

### Model the fields as ISA-95 schema

After you've identified the source data, the next step is to map this data into ISA-95 models.


{{< figure
alt="diagram showing some examples of ISA-95 modeling"
src="/images/ebr/diagram-rhize-map-ebr-isa95.png"
width="80%"
>}}

Some common objects to map include raw and final material, equipment, personnel, operations schedule, segments, job responses, and the ERP batch number.

Once ingested, all of this data is linked through common associations in the graph database, and are thus accessible through a single query.

### Write a BPMN workflow to ingest the data in real-time

{{< figure
alt="Example of a BPMN workflow"
src="/images/ebr/diagram-rhize-bpmn-ebr.png"
width="60%"
caption="<small><em>A simplified BPMN workflow. For an example of a real workflow with nodes for each logic step, refer to the next image.</em></small>"
>}}

With the sources of data and their corresponding models, the next step
is to write a [{{< abbr "BPMN" >}}]({{< relref "/how-to/bpmn" >}}) workflow to automatically transform the data and update the database.

The procedure is as follows:

1. Subscribe to the topic for the appropriate data (for example `/lims/lab1`). If the data comes from certain equipment, you first need to [Connect a data source]({{< relref "how-to/publish-subscribe/connect-datasource" >}}).

1. Transform with JSONata

   Rhize has a built-in JSONata interpreter, which can filter and transform JSON.
   Use a [JSONata service task]({{< relref "how-to/bpmn/bpmn-elements">}}#jsonata-transform) to map the data sources into the corresponding ISA-95 fields that you defined on the previous step.
  
   Use the output as a variable for the next step.
   
   {{< notice "note" >}}
   You may want to break these steps into multiple parts.
   Or, for increased modularity, you can call another BPMN workflow with a [Call activity]({{< relref "how-to/bpmn/bpmn-elements">}}#call-activities).
   {{< /notice >}}

1. POST data with a graph mutation.

   Use the Variable returned by the JSONata step to send a mutation to update the Graph database with the new fields.
   To learn more, read the [Guide to GraphQL with Rhize]({{< relref "how-to/gql" >}}).

In real BPMN workflows, you can dynamically create and assign fields as they enter the system.
For example, this workflow creates a new material definition and material-definition version based on whether this object already exists.

<a href="/images/bpmn/screenshot-rhize-bpmn-add-material-definition.png" target="_blank">
{{< figure
alt="Screenshot of a BPMN workflow that adds material only if it exists"
src="/images/bpmn/screenshot-rhize-bpmn-add-material-definition.png"
>}}
</a>

This step can involve multiple BPMN processes subscribing to different topics.
As long as the incoming event data has a common association, for example through the `id` of the batch data and associated `JobResponse`, you can return all necessary data in one GraphQL query&mdash;no recursive SQL joins necessary.

{{< figure
alt="Multiple BPMN processes can be united in one batch"
src="/images/ebr/diagram-rhize-inputs-for-ebr.png"
width="75%"
>}}

### Query the DB with the eBR fields

After the batch finishes, use a [GraphQL query]({{< relref "how-to/gql/query-mutate-subscribe" >}}) to receive all relevant batch data.
You only need to write one request, and it will return exactly the data you need.

{{< figure
alt="Diagram showing how a query makes an ebr"
src="/images/ebr/diagram-rhize-make-ebr-query.png"
width="55%"
>}}

Our experience has shown us that the query is about 300 lines. Here's a
small, generic snippet of how it looks:

{{< expandable title="Snippet of a makeEbr query" >}}
```graphql
query makeEbr ($filter: JobOrderFilter) {
  queryJobOrder(filter: $filter) {
    EXAMPLE_id: id
    label
    matReqProduced: materialRequirements(filter: {materialUse:{eq: Produced}}){
      id
      material {
    }
    materialDefinitionVersion {
      id
      version
      versionStatus
    materialClasses {
      id
      label
    }
  ## More EBR fields
  }
```
{{< /expandable >}}

Note how the query specifies exactly the fields to return: no further filtering of the response is required.
The only further step to use the returned JSON object as the input for however you create your eBR documents.

## Next steps

Fast eBR automation is just one of many use cases of Rhize in the Pharmaceutical industry.
With the same event data that you automatically ingest and filter in this workflow, you can also:
- Program reactive logic using BPMN for {{< abbr "event orchestration" >}}. For example, you might send an alert after detecting a threshold condition.
- Analyze multiple batch runs for deviations. For example, you can query every instance of a failure mode across all laboratories.
- Compare batches against some variable. For example, you can compare all runs for two versions of equipment.
