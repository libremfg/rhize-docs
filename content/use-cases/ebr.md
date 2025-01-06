---
title: >-
  Electronic Batch Records
description: The Rhize guide to querying all the information that happened in a manufacturing job.
categories: ["howto", "use-cases"]
weight: 0100
og_image:
aliases:
  - "/use-cases/track-and-trace/"
menu:
  main:
    parent: use-cases
    identifier:
---

This document shows you how to use ISA-95 and Rhize to create a generic, reusable model for any use case that involves _Electronic batch records_.
As long as you properly [map and ingest]({{< relref "data-collection-ebr" >}}) the source data,
the provided queries here should work for any operation, though you'll need to tweak them to fit the particular structure of your job response and reporting requirements.

An Electronic Batch Record (eBR) is a detailed report about a specific batch.
Generating eBRs is an important component of pharmaceutical manufacturing, whose high standards of compliance and complexity of inputs demand a great deal of detail in each report.

Rhize can model events and resources at a high degree of granularity, and its ISA-95 schema creates built-in relationships between these entities.
So it makes an ideal backend to generate eBRs with great detail and context.
In a single query, 
you can use Rhize to identify answers to questions such as:
- What material, equipment, and personnel were involved in this job? And what was their function in performance?
- When and where did this job happen? How long did it run for?
- Why was this work performed? That is, what is the order that initiated the work?
- What are the results of quality testing for this work?


{{< notice >}}
:memo:
The focus here is modeling and querying.
For a high-level overview of how eBR data may enter the Rhize data hub, read the guide to [Data collection]({{< relref "/use-cases/data-collection-ebr" >}}).
{{< /notice >}}


## Quick query

If you just want to build out a [GraphQL query]({{< relref "/how-to/gql/query" >}}) for your reporting, use these templates to get started.


If you know the IDs for the relevant job response, job order, and test results, you can structure each group as a top-level object.
If you want to input only one ID, you can also use nested fields on a response, order, or test specification to pull all necessary information.
The Rhize DB stores relationships, so the values are identical&mdash;only the structure of the response changes.


{{< tabs >}}
{{< tab "flat" >}}

```gql

query trackAndTrace {
  performance: getJobResponse(id: "<JOB_ID>") {
   # duration, actuals, and so on
  }
  planning: getJobOrder(id: "<ORDER_ID>") {
  # requirements, work master, and so on
  }
  testing: getTestResult(id: "<TEST_ID>") {
   # evaluation properties and tested objects
  }
}
```
{{< /tab >}}
{{< tab "nested" >}}

```gql
query nestedTrackAndTrace {
  jobResponse: getJobResponse(id: "ds1d-batch-119-jr-fc-make-frosting") {
    id
    ## more fields about performance
    materialActual { ## repeat for other resources as needed
      id
      quantity
      testResults { ## test results for material
        id
      }
      ## More material fields
    }
    associated_order: jobOrder {
      id
      ## more planning fields
    }
  }
}

```
{{< /tab >}} 
{{</ tabs >}}

For more detail, refer to the
[complete example query](#example-query).


## Background: ISA-95 entities in a track-and-trace query

{{< notice >}}
:memo: For an introduction to ISA-95 and its terminology,
read [How to speak ISA-95]({{< relref "/explanations/how-to-speak-isa-95" >}}).
{{< /notice >}}

The following lists detail the ISA-95 entities that you might need when querying the Rhize database for a track and trace.
As always, your manufacturing needs and data-collection capabilities determine the exact data that is necessary.
It is likely that some of the following fields are irrelevant to your particular use case.

### Performance information

A _job response_ represents a unit of performed work in a manufacturing operation.
The job response typically forms the core of a track-and-trace query,
as you can query it to obtain duration and all {{< abbr "resource actual" >}}s involved in the job.
A job response may also contain child job responses, as displayed in the following diagram:



{{< bigFigure
src="/images/s95/diagram-rhize-s95-job-response-with-children.svg"
caption="An example of a job response with child job responses. The parent job has a material actual representing the final produced good. The child job responses also have their own properties that may be important to model. This is just one variation of many. **ISA-95 is flexible and the best model always depends on your use case**."
>}}


For a track and trace, some important job response properties and associations include the following:

- **Start and End times.** When work started and how long it lasted.
- **Material Actuals.** The quantities of material involved and how they are used: consumed, produced, tested, scrapped, and so on. Material actuals may also have associated lots for unique identification. Test results may be derived from samples of the material actual. 
- **Equipment Actuals.** The real equipment used in a job, along with associated equipment properties and testing results.
- **Personnel actuals.** The people involved in a job or test.
- **Process values**. Associated process data and calculations.
- **Comments and Signatures.** Additional input from operators.

### Scheduling information

A track and trace report might also include information
about the work that was demanded.
The simplest relationship between performance and demand is the link between a job response and a _job order_.
So your track and trace might include information about the order that initiated the response.
Through this order, you could also include higher-level scheduling information.

When adding order information, consider whether you need the following properties:
* **Scheduled start and end times.** These might be compared to the real start and end.
* **Material requirements**. The material that corresponds to the material actuals in the performance. Requirements may include:
   - Material to be produced, along with their scheduled quantities and units of measure
   * Material to be consumed, along with their scheduled quantities and units of measure
   * Any by-product material and scrap
* **Planned equipment**. This can be compared to the real equipment used.
* **Work Directive**. The dispatched version of the planned work. The directive may include:
   - Specifications or a BoM (if the requirements are not in the order itself)
   - Any relevant work master configuration (routing, process parameters like temperature, durations, and so on)


### Quality information

Your track and trace also may record test results.
These results provide context about the quality of the work produced in the job response.

Each {{< abbr "resource actual" >}} can have a corresponding test result.
For example:
- The material actual and lot may record the sample.
- The equipment actual may record test locations.
- Physical asset actuals may record instruments used for the test.
- Personnel actuals may record who performed the test.

## Example query

The following snippet is an example of how to pull a full track and trace from a single [GraphQL query]({{< relref "/how-to/gql/query" >}}).
Each top-level object has an [alias](https://graphql.org/learn/queries/#aliases), which serves as the key for the object in the JSON payload.

```gql
query trackAndTrace {
  performance: getJobResponse(id: "ds1d-119-as") {
   # duration, actuals, and so on
  }
 planning: getJobOrder(id: "ds1d-119-jo-119-3") {
  # requirements, work directive, and so on
 }
 testing: getTestResult(id: "ds1d-119-tr-3") {
   # evaluation properties and tested objects
}
```

{{< tabs >}}
{{% tab "Full query" %}}

**Variables**
```json
{
  "getJobResponseId": "ds1d-batch-119-jr-fc-make-frosting",
  "getJobOrderId": "ds1d-batch-jo-119",
  "getTestResultId": "ds1d-batch-tr-119"
}
```

**Query**

```gql

query trackAndTrace ($getJobResponseId: String $getJobOrderId: String $getTestResultId: String) {
  performance: getJobResponse(id:$getJobResponseId) {
    jobResponseId: id
    startDateTime
    endDateTime
    duration
    jobState
    workDirective {
      id
    }
    materialActual {
      id
      materialUse
      quantity
      quantityUoM {
        id
      }
      materialDefinition {
        id
      }
      materialLot {
        id
        materialDefinition {
          id
        }
      }
      materialSubLot {
        id
      }
      properties {
        id
      }
    }
    equipmentActual {
      id
      equipment {
        id
      }
      description
      children {
        id
      }
      properties {
        id
        value
        valueUnitOfMeasure {
          id
        }
      }
    }
    personnelActual {
      id
      
    }
  }
  
  planning: getJobOrder(id: $getJobOrderId) {
    orderId: id
    scheduledStartDateTime
    scheduledEndDateTime 
    materialRequirements { 
      id
      quantity
      quantityUoM {
        id
      }
    }
    equipmentRequirements {
      id
      equipment {
        id
      }
      
    }
    workMaster{
      id
      parameterSpecifications {
        id
        description
      }
    }
   
    }
 
 testing: getTestResult(id: $getTestResultId) {
    resultsId: id
    id
    evaluationDate
    expiration
    evaluationCriterionResult
    equipmentActual {
    id
    }
    materialActual {
    id
    materialUse  
    }
    physicalAsset {
    id 
    }
    equipmentActual {
      id
    }
   }


 }
 
}

```
{{< /tab >}}
{{< tab "Response: performance track and trace" >}}

The `performance` section of this query may return data that looks something like this.
Note that every object does not necessarily have every requested field.
In this example, only some material actuals have additional properties.

```json
{
  "data": {
    "performance": {
      "id": "ds1d-batch-119-jr-fc-make-frosting",
      "startDateTime": "2024-09-23T23:22:25Z",
      "endDateTime": "2024-09-23T23:38:04.783Z",
      "duration": 939.783,
      "materialActual": [
        {
          "id": "ds1d-batch-fc-cookie-frosting-actual-119",
          "materialUse": "Produced",
          "quantity": 3499.46,
          "quantityUoM": {
            "id": "g"
          },
          "materialLot": [
            {
              "id": "ds1d-batch-fc-cookie-frosting-lot-119"
            }
          ],
          "materialSubLot": [],
          "properties": [
            {
              "id": "viscosity",
              "value": "0.1",
              "valueUnitOfMeasure": {
                "id": "mm2/s"
              }
            },
            {
              "id": "temperature",
              "value": "22",
              "valueUnitOfMeasure": {
                "id": "C"
              }
            }
          ]
        },
        {
          "id": "ds1d-batch-fc-butter-actual-119",
          "materialUse": "Consumed",
          "quantity": 1124.05,
          "quantityUoM": {
            "id": "g"
          },
          "materialLot": [
            {
              "id": "ds1d-batch-fc-butter-lot-119"
            }
          ],
          "materialSubLot": [],
          "properties": [
            {
              "id": "fat-percent",
              "value": "15",
              "valueUnitOfMeasure": null
            }
          ]
        },
        {
          "id": "ds1d-batch-fc-confectioner-sugar-actual-119",
          "materialUse": "Consumed",
          "quantity": 249.08,
          "quantityUoM": {
            "id": "g"
          },
          "materialLot": [
            {
              "id": "ds1d-batch-fc-confectioner-sugar-lot-119"
            }
          ],
          "materialSubLot": [],
          "properties": []
        },
        {
          "id": "ds1d-batch-fc-peanut-butter-actual-119",
          "materialUse": "Consumed",
          "quantity": 2249.63,
          "quantityUoM": {
            "id": "g"
          },
          "materialLot": [
            {
              "id": "ds1d-batch-fc-peanut-butter-lot-119"
            }
          ],
          "materialSubLot": [],
          "properties": []
        }
      ],
      "equipmentActual": [
        {
          "id": "ds1d-batch-kitchen-mixer-actual-119",
          "description": null,
          "children": [],
          "properties": []
        },
        {
          "id": "ds1d-batch-kitchen-actual-119",
          "description": null,
          "children": [],
          "properties": []
        }
      ],
      "personnelActual": [
        {
          "id": "ds1d-batch-fc-supervisor-actual-119"
        },
        {
          "id": "ds1d-batch-fc-handler-actual-119"
        }
      ]
    }
  }
}
```

{{< /tab >}}
{{< /tabs >}}

## Build a reporting frontend

As a final step, you can also transform the JSON payload into a more human-readable presentation.
As always, you have a few options. Here are a few, from least to most interactive:
- Create a  PDF report, perhaps using specialized software such as InfoBatch
- Create a static web report, using basic HTML and CSS
- Build an interactive report explorer, which may include links to other reports and dynamic visualizations of alerts and performance

## Next steps: combine with other use cases

You can reuse and combine the queries here for other use cases that involve tracking and performance analysis.
For example, if you want a detailed report for the movement of material, you can combine the queries here with a query for a [material lot genealogy]({{< relref "genealogy" >}}). This would provide a detailed report for every job that involved an ancestor or descendent of the queried material.

