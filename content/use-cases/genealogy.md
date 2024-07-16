---
title: >-
  Genealogy
description: The Rhize guide to modelling and querying the forward and backward genealogy of a material lot
categories: ["howto", "use-cases"]
weight: 0100
hidden: true
menu:
  main:
    parent: use-cases
    identifier:
---


This document provides a high-level overview of how to use Rhize for use cases in material genealogy.

In manufacturing, a _genealogy_ is the record of what a material contains or what it is now a part of.
As its name implies, genealogy represents the family tree of the material.

Rhize provides a standards-based schema to represent material in at all levels of granularity.
The ISA-95 schema of its DB automatically creates associations between material lots and other information about planned and performed work.
This database has a GraphQL API, which can pull full genealogies from terse queries.
As such, Rhize makes an **ideal backend to use for genealogical use cases**.


```echart width="80%" heigh="1000px"
const option = {
  title: {
    subtext: "Click solid squares to expand.\nHover on ingredients for quantities",
    fontSize: 13
  },
  tooltip: [
    {
      z: 60,
      show: true,
      showContent: true,
      alwaysShowContent: true,
    },
  ],
  initialTreeDepth: 3,
  series: [
    {
      type: "tree",
      left: "25%",
      right: "20%",
      top: "10%",
      bottom: "20%",
      symbol: "emptySquares",
      orient: "LR",
      expandAndCollapse: true,
      lineStyle:{
        color: "#006838",
        },
      label: {
        position: "bottom",
        rotate: 0,
        verticalAlign: "middle",
        align: "right",
        fontSize: 11,
      },
      itemStyle:{
          color: "#006838",
          },
      leaves: {
        label: {
          position: "bottom",
          backgroundColor: "#FFFFFF",
          rotate: 10,
          verticalAlign: "middle",
          align: "left",
          fontSize: 13,
        },
      },

      animationDurationUpdate: 650,
      data: [],
    },
  ],
};

(option.series[0].data[0] = 
{
  "name": "lt-fc-cookie-box-2f",
  "value": 1,
  "children": [
    {
      "name": "lt-fc-cookie-unit-dh",
      "value": 1000,
      "children": [
        {
          "name": "lt-fc-cookie-frosting-9Q",
          "value": 3500,
          "children": [
            {
              "name": "lt-fc-butter-67",
              "value": 1125
            },
            {
              "name": "lt-fc-confectioner-sugar-yN",
              "value": 250
            },
            {
              "name": "lt-fc-peanut-butter-Cq",
              "value": 2250
            }
          ]
        },
        {
          "name": "lt-fc-cookie-dough-Vr",
          "value": 15000,
          "children": [
            {
              "name": "lt-fc-egg-gY",
              "value": 50
            },
            {
              "name": "lt-fc-flour-kO",
              "value": 7500
            },
            {
              "name": "lt-fc-salt-Z3",
              "value": 150
            },
            {
              "name": "lt-fc-sugar-32",
              "value": 2500
            },
            {
              "name": "lt-fc-vanilla-extract-px",
              "value": 10
            }
          ]
        }
      ]
    },
    {
      "name": "lt-fc-cookie-wrapper-NR",
      "value": 150
    }
  ]
}

),
  (option.title.text = `Example frontend:\nreverse genealogy of ${option.series[0].data[0].name}`);
 ```


## Steps to use Rhize for genealogy

In the terms of ISA-95, the lineage of each material is expressed through the following entities:
- **Material lots.** Unique amounts of identifiable material. For example, this might be a piece of cut steel, or an camshaft in an engine.
- **Material Sublots.** Uniquely identifiable parts of a material lot. For example a if a box of consumer-packaged goods represents a material lot, the individual serial numbers of the packages within might be the material sublot. Each sublot is unique, but multiple sublots may share properties from their parent material lot (for example, the expiry date).

Finally, the relationships are expressed through the following properties:
- `isAssembledFrom` expresses the material lots or sublots that went into another material.
- `isComponentOf` represents the material lot or sublot that this material went into.


{{< notice "note" >}}

The disintiction between sub-lots and lots varies with process. The rest of this document simplifies the process by using only the word "lots".

{{< /notice >}}

{{< bigFigure
src="/images/diagram-genealogy-of-a-batch.png"
width="80%"
>}}



### Identify lots to collect

To use Rhize for genealogy, first identify the material lots that you want to identify.
How you identify these depends on the reality of your process.
But these guidelines generally are true:
- The lot must be uniquely identifiable
- The ID provides useful information about the material composition
- The level of granularity of the lots is realistic for your current processes


### Model these lots into your knowledge graph

After you have identified the material lots, you can plan how the data fits with the other components of your knowledge graph.
At minimum, your material lots must have a _material definition_ and an active version.

Beyond these requirements, the graph structure of the ISA-95 database provides many ways to create links to other manufacturing entities, including:
- A work request or job response
- The associated {{< abbr "resource actuals" >}}
- As components of larger groups such as material Classes, or the material specifications in a work masters.

### Implement how to store your lots in the RhizeDB

After you have planned the process and defined your models, you can begin adding

Your manufacturing process determines where lot IDs are created.
The broad patterns are as follows:
- Assign lots at the time of creating the work request or schedule (while the job response might create a material actual that maps to the requested lot ID).
- Generate lot IDs beforehand, then use a GraphQL call to create the records in the Rhize DB when events like button pressing or automated signals indicate the lots have been created
- Assign lot IDs at the exact time of work performance. For example, you can write a [BPMN workflow]({{< relref "/how-to/bpmn/" >}}) to subscribe to a topic that receives information about lots, and then automatically forward the IDs to your knowledge graph


### Query the data

After you start collecting data, the next step is to query it.

#### Forward genealogy

A forward genealogy examines the history of how one lot becomes a component of another.
For example, if a supplier informs a manufacturing about an issue with a specific raw material,
the manufacturer can run a forward genealogy that looks at the downstream material that consumed these bad lots.

In Rhize, you can query the forward genealogy through the `isComponentOfMaterialLot` property,
using nesting to indicate the number of levels of forward generations.
For example, this returns the full chain of material that contains (or contains material that contains)
the material sublot `lt-fc-peanut-butter-Cq:

```gql
query GetMaterialLot($getMaterialLotId: String) {
  getMaterialLot(id: "lt-fc-peanut-butter-Cq") {
    id
    isComponentOfMaterialLot {
      id
      isComponentOfMaterialLot {
        id
        isComponentOfMaterialLot {
          id
        }
      }
    }
  }
}

```

This query returns data in the following structure:

```json
{
  "data": {
    "getMaterialLot": {
      "id": "lt-fc-peanut-butter-Cq",
      "isComponentOfMaterialLot": {
        "id": "lt-fc-cookie-frosting-9Q",
        "isComponentOfMaterialLot": {
          "id": "lt-fc-cookie-unit-dh",
          "isComponentOfMaterialLot": {
            "id": "lt-fc-cookie-box-2f"
          }
        }
      }
    }
  }
}
```

#### Backward genealogy

A backward genealogy examines all material lots that go into an item of material.

In Rhize, you can query this relationship through the `isAssembledFromMaterialLot` property,
using nesting to indicate the level of material ancestry to return.
For example, this returns four levels of backward genealogy for the material lot
`lt-fc-cookie-box-2f`.

```gql
query GetMaterialLot($getMaterialLotId: String) {
  getMaterialLot(id: $getMaterialLotId) {
    id
    quantity
    isAssembledFromMaterialLot {
      id
      quantity
      isAssembledFromMaterialLot {
        id
        quantity
        isAssembledFromMaterialLot {
          id
          quantity
        }
      }
    }
  }
}
```

This query looks back four levels.
The returned genealogy looks something like the following:

{{% expandable title="example-lot-genealogy.json" %}}

```json
{
  "data": {
    "getMaterialLot": {
      "id": "lt-fc-cookie-box-2f",
      "quantity": 1,
      "isAssembledFromMaterialLot": [
        {
          "id": "lt-fc-cookie-unit-dh",
          "quantity": 1000,
          "quantityUnitOfMeasure": {
            "id": "cookie unit"
          },
          "isAssembledFromMaterialLot": [
            {
              "id": "lt-fc-cookie-frosting-9Q",
              "quantity": 3500,
              "isAssembledFromMaterialLot": [
                {
                  "id": "lt-fc-butter-67",
                  "quantity": 1125
                },
                {
                  "id": "lt-fc-confectioner-sugar-yN",
                  "quantity": 250
                },
                {
                  "id": "lt-fc-peanut-butter-Cq",
                  "quantity": 2250
                }
              ]
            },
            {
              "id": "lt-fc-cookie-dough-Vr",
              "quantity": 15000,
              "isAssembledFromMaterialLot": [
                {
                  "id": "lt-fc-egg-gY",
                  "quantity": 50
                },
                {
                  "id": "lt-fc-flour-kO",
                  "quantity": 7500
                },
                {
                  "id": "lt-fc-salt-Z3",
                  "quantity": 150
                },
                {
                  "id": "lt-fc-sugar-32",
                  "quantity": 2500
                },
                {
                  "id": "lt-fc-vanilla-extract-px",
                  "quantity": 10
                }
              ]
            }
          ]
        },
        {
          "id": "lt-fc-cookie-wrapper-NR",
          "quantity": 150,
          "quantityUnitOfMeasure": {
            "id": "wrapper"
          },
          "isAssembledFromMaterialLot": []
        }
      ]
    }
  }
}
```

{{% /expandable %}}



## Next steps: display and analyze

The preceding steps are all you need to create a data foundation to use Rhize for Genealogy.
After you've started collecting data, you can use the data hub genealogy queries to build frontends and isolate entities for more detailed tracing and performance analysis.

### Build frontends

All the data that you store in the Rhize DB is exposed through the GraphQL API.
This provides a flexible way to create custom frontends to organize your genealogical analysis in the presentation that makes sense for your use case.
For example, you might represent the genealogy lots in any of the following ways:
- In a summary report, providing a brief list of the material and all impacted upstream or downstream lots.
- As an interactive list, which you can expand to view a lot's associated quantities, job order, personnel and so on.
- As the input for a secondary query
- In a graphical presentation
- In any combination of the preceding

For a visual example, the preceding graphic takes the data from the preceding reverse-genealogy query,
transforms it with a [JSONata expression]({{< relref "/how-to/bpmn/use-jsonata" >}}) and then visualizes the relationship using 
[Apache echarts](https://echarts.apache.org/).

The JSONata expression takes an array of material lots,
thenrecursively renames all IDs and `isAssembledFrom` properties to `name` and `children`.
This is the data structure expected by the Echarts Tree chart.

```golang
(
$makeParent := function($data){
    $data.{
        "name": id,
        "value": quantity,
        "children": $makeParent(isAssembledFromMaterialLot)
    }
};

$makeParent($.data.getMaterialLot)

)
```

Alternatively, if the query data is the input for only the Apache Echarts dataset,
you could use GraphQL aliases to rename the object keys.

```gql

query reverseGenealogy {
  queryMaterialLot(filter: {id{regexp: "/batch-a-/"}}) {
    name: id
    quantity
    children: isAssembledFromMaterialLot {
       ...
       }
    }
  }
```

### Combine with granular tracing and performance analysis

While a genealogy is an effective tool on its own, usefulness of the Rhize data hub compounds with each use case.
So genealogy implementations are most effective if you can combine them with the other data stored in your manufacturing knowledge graph.

For example, the genealogical record may provide the input for more granular _track and trace_ investigation, in which you use the Lot IDs to determine information such as who worked on the material, with what equipment, and performing what kind of work.

You could also combine genealogy with performance analysis, using the genealogical record as the starting point to analyze and predict failures and deviations.
