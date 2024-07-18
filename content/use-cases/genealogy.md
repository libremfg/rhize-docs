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
The reasons to enable a genealogy include to:
- Prevent product recalls by isolating deviations early in the material flow
- Decrease recall time by having a complete record of where material starts and ends
- For reporting and performance analysis of material deviations
- Compliance and documentation about tracking material

Rhize provides a standards-based schema to represent material in at all levels of granularity.
The graph structure of its DB has built-in properties to associate material lots with other information about planned and performed work.
This database has a GraphQL API, which can pull full genealogies from terse queries.
As such, Rhize makes an **ideal backend to use for genealogical use cases**.


```echart width="80%" heigh="600px"
const option = {
  title: {
    subtext: "Click solid squares to expand.\nHover on ingredients for quantities in grams",
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
      left: "15%",
      right: "30%",
      top: "10%",
      bottom: "2%",
      symbol: "emptySquares",
      orient: "RL",
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

_Data from a Rhize query in an Apache Echart. Read the [Build frontend](#frontend) section for details._

## Background: material entities in Rhize

In ISA-95 terminology, the lineage of each material is expressed through the following entities:
- **Material lots.** Unique amounts of identifiable material. For example, a material lot might be a camshaft in an engine or a package of sugar from a supplier.
- **Material Sublots.** Uniquely identifiable parts of a material lot. For example, if a box of consumer-packaged goods represents a material lot, the individual serial numbers of the packages within might be the material sublots. Each sublot is unique, but multiple sublots may share properties from their parent material lot (for example, the expiry date).

The relationship between lots are expressed through the following properties :
- `isAssembledFromMaterial[Sub]lot` and `isComponentOf[Sub]lot`. Define the material lots or sublots that went into another material.
- `parentMaterialLot` and `childSubLot`. Define the relationships between a material lot and its sublots.

Note that these properties are symmetrical. If lot `final-1` has the property `{isAssembledFromMaterialLot: "intermediate-1"`},
then lot `intermediate-1` has the property `{isComponentOfMaterialLot: "final-1" }`.
The graph structure of the RhizeDB builds these automatically.
  

{{< notice "note" >}}

The distinction between sub-lots and lots varies with process. The rest of this document simplifies the process by using only the word "lots".

{{< /notice >}}

{{< bigFigure
src="/images/genealogy/diagram-rhize-genealogy-of-a-batch.png"
width="30%"
alt="A simplified view of how a pallet of packaged goods is assembled from lots and sublots."
caption="A simplified view of how a pallet of packaged goods is assembled from lots and sublots."
>}}

## Steps to use Rhize for genealogy

The following sections describe how to use Rhize to build a Genealogy use case.
In short:
1. Identify the unique lots in your material flows.
2. Add these lots to your model.
3. Implement how to collect these lots.
4. Query the database

### Identify lots to collect

To use Rhize for genealogy, first identify the material lots that you want to identify.
How you identify these depends on your processes and material flows.
But the following guidelines generally are true:
- The lot must be uniquely identifiable.
- The ID provides useful information about the material composition.
- The level of granularity of the lots is realistic for your current processes.

For example, in small baking operation, lots might come from the following areas:
- The serial numbers of ingredients from suppliers
- The batches of baked pastries
- The wrappers consumed by the packing process
- The pallets of packed goods (with individual packages being material sublots).

{{< notice "note" >}}
For some best practices of how to model, read our blog [How much do I need to model?](https://rhize.com/blog/how-much-do-i-need-to-model-when-applying-the-isa-95-standard/)
{{< /notice >}}


### Model these lots into your knowledge graph

After you have identified the material lots, you can model how the data fits with the other components of your manufacturing knowledge graph.
At minimum, your material lots must have a {{< abbr "material definition" >}} with an active version.

Beyond these requirements, the graph structure of the ISA-95 database provides many ways to create links between lots and other manufacturing entities, including:
- A work request or job response
- The associated {{< abbr "resource actual" >}}
- In aggregations such as part of a material class, or part of the material specifications in a {{< abbr "work master" >}}.

In the aforementioned baking process, the lots may have:
- Material classes (raw, intermediate, and final)
- Associated equipment, such as mixers, ovens, and trays.
- Have associated segments (such as "mixing" or "cooling"
- Associated measurements and properties

### Implement how to store your lots in the RhizeDB

After you have planned the process and defined your models, the next step is to implement how to add material lot IDs to Rhize in the course of your real manufacturing operation.

Your manufacturing process determines where lot IDs are created.
The broad patterns are as follows:
- **Scheduled.** Assign lots at the time of creating the work request or schedule (while the job response might create a material actual that maps to the requested lot ID).
- **Schedule and event-driven.** Generate lot IDs beforehand, then, use a GraphQL call to create records in the Rhize DB after some event. Example events might be a button press or an automated signal that indicates the lot has been physically created.
- **Event-driven.** Assign lot IDs at the exact time of work performance. For example, you can write a [BPMN workflow]({{< relref "/how-to/bpmn/" >}}) to subscribe to a topic that receives information about lots, and then automatically forward the IDs to your knowledge graph.

In the example baking process, lots maybe collected in the following ways:
- Scanned from supplier bar code
- Generated after the quality inspector indicates that a tray is finished
- Planned in terms of final packaging and expiration date

### Query the data

After you start collecting data, the next step is to query it.
The following examples show how to query for forward and backward genealogies using the [`get`](https://docs.rhize.com/how-to/gql/query/#get) operation to query material lots.


{{< notice "note" >}}
You could also query for multiple genealogies&mdash;either through material lots or through aggregations such as material definitions and specifications&mdash; then apply [filters](https://docs.rhize.com/how-to/gql/filter/).
{{< /notice >}}

#### Backward genealogy

A backward genealogy examines all material lots that are part of the assembly of some later material lot.

In Rhize, you can query this relationship through the `isAssembledFromMaterialLot` property,
using nesting to indicate the level of material ancestry to return.
For example, this returns four levels of backward genealogy for the material lot
`lt-fc-cookie-box-2f`.

```gql
query reverseGenealogy($getMaterialLotId: String) {
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

The returned genealogy looks something like the following:

{{% expandable title="example-backward-genealogy.json" %}}

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

#### Forward genealogy

A forward genealogy examines the history of how one lot becomes a component of another.
For example, if a supplier informs a manufacturer about an issue with a specific raw material,
the manufacturer can run a forward genealogy that looks at the downstream material that consumed these bad lots.

In Rhize, you can query the forward genealogy through the `isComponentOfMaterialLot` property,
using nesting to indicate the number of levels of forward generations.
For example, this query returns the full chain of material that contains (or contains material that contains)
the material sublot `lt-fc-peanut-butter-Cq`:

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

## Next steps: display and analyze

The preceding steps are all you need to create a data foundation to use Rhize for genealogy.
After you've started collecting data, you can use the data hub genealogy queries to build frontends and isolate entities for more detailed tracing and performance analysis.

### Build frontends {#frontend}

All the data that you store in the Rhize DB is exposed through the GraphQL API.
This provides a flexible way to create custom frontends to organize your genealogical analysis in the presentation that makes sense for your use case.
For example, you might represent the genealogy lots in any of the following ways:
- In a summary report, providing a brief list of the material and all impacted upstream or downstream lots.
- As an interactive list, which you can expand to view a lot's associated quantities, job order, personnel and so on.
- As the input for a secondary query
- In a display using some data visualization library

For a visual example, the interactive chart in the introduction takes the data from the preceding reverse-genealogy query,
transforms it with a [JSONata expression]({{< relref "/how-to/bpmn/use-jsonata" >}}), and visualizes the relationship using 
[Apache echarts](https://echarts.apache.org/).

The JSONata expression accepts an array of material lots,
then recursively renames all IDs and `isAssembledFrom` properties to `name` and `children`.
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

Alternatively, you could use GraphQL aliases to rename the object keys:

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

The intro of this document provides an interactive example of an Echarts tree.
We've also embedded Echarts in Grafana workspaces to make interactive dashboards for forward and reverse genealogies:

{{< bigFigure
src="/images/genealogy/screenshot-rhize-genealogy-grafana.png"
alt="An interactive genealogy dashboard. Filter by material definition, then select specific material lots."
caption="An interactive genealogy dashboard. Filter by material definition, then select specific material lots."
width="90%"
>}}



### Combine with granular tracing and performance analysis

While a genealogy is an effective tool on its own, usefulness of the Rhize data hub compounds with each use case.
So genealogy implementations are most effective if you can combine them with the other data stored in your manufacturing knowledge graph.

For example, the genealogical record may provide the input for more granular _track and trace_ investigation, in which you use the Lot IDs to determine information such as who worked on the material, with what equipment, and performing what kind of work.

You could also combine genealogy with performance analysis, using the genealogical record as the starting point to analyze and predict failures and deviations.
