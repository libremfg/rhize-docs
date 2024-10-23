---
title: >-
  Track and trace
description: The Rhize guide to querying all the information that happened in a manufacturing job.
categories: ["howto", "use-cases"]
weight: 0100
menu:
  main:
    parent: use-cases
    identifier:
---

This document details how to use Rhize to implement a _track and trace_
to answer all the questions about what happened during a certain process or series of processes.

After you decide how to model and ingest your data for a track and trace use case,
you can use a single Rhize query to identify answers to questions such as:
- What material was involved in this job?
- What equipment used to perform this job?
- Who were the operators who performed the work?
- What are the results of quality testing for this work?
- When and where did the work happen? 
- What order was this job a response to?

In pharmaceutical manufacturing, an [_Electronic batch record_]({{< relref "/use-cases/ebr" >}}) is a special kind of track and trace to keep a record of all inputs of a pharmaceutical batch.
Another related use case is the [Genealogy]({{< relref "/use-cases/genealogy" >}}), which keeps a record of a how a material flows through the manufacturing process.


## Background: ISA-95 entities in a track-and-trace query

{{< notice >}}
:memo: For a more complete introduction to ISA-95 and its terminology,
read [How to speak ISA-95]({{< relref "/explanations/how-to-speak-isa-95" >}}).
{{< /notice >}}

The Rhize DB uses ISA-95 as an ontology to represent all components of planned and performed work.
Once you have mapped the entities you want to track to a standard model, the Rhize DB provides a highly flexible backend to build track and trace reports.

The following lists detail the ISA-95 entities that you might need when querying the Rhize database for a track and trace.
Note that the exact data involved in a track and trace returns depends on your manufacturing needs and data-collection capabilities.
It is likely that some of the following entities are irrelevant for your particular use case.

### Performance information

A _job response_ represents a unit of performed work in a manufacturing operation.
As a job response has relations to {{< abbr "resource actuals" >}}, times, measurements, and orders,
the job response typically forms the core of your query.



{{< bigFigure
src="/images/s95/diagram-rhize-s95-job-response-with-children.svg"
caption="An example of a job response with child job responses. The parent job has a material actual representing the final produced good. The child job responses also have their own properties that may be important to model. This is just one variation of many. **ISA-95 is flexible and the best model always depends on your use case**."
>}}


The following table lists the properties and associations of a job response that may be important for a track and trace:

- **Start and End times.** To track when work happened. The difference between start and ends is also how Rhize calculates job duration                          |
- **Material Actuals.** To track quantities and uses of material that is consumed, produced, tested, scrapped, and so on. Material actuals may also have associated lots for unique identification.
- **Equipment Actual.** To track the real equipment used in a job
- **Personnel actual.** To track the people involved in a job.
- **Process values**. To store associated data.
- **Comments and Signatures.** Additional input from operators.

### Scheduling information

Every job response corresponds to an order, and a track and trace report might also include information
about the work that was demanded. The top-level object for this demand is likely the _job order_.

When adding order information, consider whether you need the following properties:
* **Scheduled start and end times.** These might be compared to the real start and ends.
* **Material requirements**. The material that corresponds to the material actuals in the performance. Requirements may include:
   - Material to be produced, along with their scheduled quantities and units of measure
   * Material to be consumed, along with their scheduled quantities and units of measure
   * Any by products
* **Planned equipment**. This can be compared to the real equipment used.
* **WorkDirective**. The dispatched version of the planned work. The directive may include:
   - Specifications or a BoM (if the requirements are not in the order itself).
   - Any relevant work master configuration (routing, process parameters like temp, times, etc)


### Quality information

Your track and trace also may record test results.
These results provide context about the quality of the work produced in the job response.

Each {{< abbr "resource actual" >}} can have a corresponding test result.
For example:
- The material actual and lot may record the sample
- The equipment actual may record test location
- Physical asset actuals may record instruments used for the test
- Personnel actual may record who performed the test.

## Example query

The following snippet is an example of how to pull a full track and trace from a single [GraphQL query]({{< relref "/how-to/gql/query" >}}).
To make the payload more explicit, each top-level object has an [alias](https://graphql.org/learn/queries/#aliases).
This alias serves as the key for the object in the JSON payload.

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


{{< expandable title="Full query" >}}

```gql

query trackAndTrace {
  performance: getJobResponse(id: "ds1d-batch-119-jr-fc-make-frosting") {
    startDateTime
    endDateTime
    duration
    materialActual {
      id
      materialUse
      quantity
      quantityUoM {
        id
      }
      materialLot {
        id
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
 planning: getJobOrder(id: "ds1d-batch-jo-119") {
     scheduledStartDateTime
    scheduledEndDateTime
    materialRequirements {
      id
      quantity
      materialUse
      quantityUoM {
        id
      }
      
    }
    equipmentRequirements {
      id
    }
    workDirective {
      id
      
      workMaster {
        id
        parameterSpecifications {
          id
          description
        }
      }
    }

 }
 testing: getTestResult(id: "ds1d-batch-tr-119") {
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

```

{{< /expandable >}}


The `performance`section of this query may return data that looks something like this.
Note that every object does not every requested field.
In this example, only some of the material actual have values for additional properties.


{{< expandable title="Response: performance track and trace" >}}

```json
{
  "data": {
    "performance": {
      "startDateTime": "2024-09-23T23:22:25Z",
      "endDateTime": "2024-09-23T23:38:04.783Z",
      "duration": 939.783,
      "materialActual": [
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
              "id": "fat-percent"
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
              "id": "viscosity"
            },
            {
              "id": "temperature"
            }
          ]
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
          "equipment": {
            "id": "kitchen.line_1.mixer_1"
          },
          "description": null,
          "children": [],
          "properties": []
        },
        {
          "id": "ds1d-batch-kitchen-actual-119",
          "equipment": {
            "id": "kitchen"
          },
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

{{< /expandable >}}
