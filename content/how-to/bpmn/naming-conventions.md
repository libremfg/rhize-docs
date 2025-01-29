---
title: 'Naming conventions'
categories: ["reference"]
description: Recommended naming conventions for BPMN processes and their nodes
weight: 950
---

{{< callout type="info" >}}
These are recommendations. Your organization may adapt the conventions to its needs.
{{< /callout >}}

Each BPMN workflow has an ID, as does each node in the workflow.
Rhize recommends adopting a set of conventions about how you name these elements.
Standardizing BPMN names across an environment has multiple benefits:
- Consistent workflow naming conventions help you filter and find workflows in the process list.
- Well-named nodes make the workflow behavior easier to understand at a glance.
- These names provide discovery and context when debugging and tracing a workflow. 

The following list describes our default naming conventions.


## BPMN processes

Name BPMN Processes according to the following convention:

`<INVOCATION_TYPE>_<CONTRACT_ID>_<PURPOSE>`

Where:
- `<INVOCATION_TYPE>` describes how the BPMN is expected to be triggered

- `<CONTRACT_ID>` Links to the ID supplied in the sequence diagram (if applicable)
- `<PURPOSE>` describes what the workflow does

| InvocationTypes | Description                                                                                    |
|-----------------|------------------------------------------------------------------------------------------------|
| `NATS`          | Invoked when a message is received in the Rhize NATS broker                                    |
| `API`           | Expects to be called from the API using `createAndRunBPMNSync` or `createAndRunBPMN` mutations |
| `RULE`          | Invocation is expected from the [rule engine]({{< relref "create-equipment-class-rule" >}})          |
| `FUNC`          | Internal functions to be invoked as helpers                                                    |

Examples:
- `NATS_ProcessOrderV1TransformAndPersist`
- `NATS_PLMMaterialMasterV2TransformPersistAndPublish`
- `RULE_ChangeOEEStatusOfCNCEquipment`
- `API_WST04_GetNextLibreBatchNumber`
- `API_WAT01_CloseOpenJobOrders`

## BPMN Nodes 

Name nodes in a workflow according to the following convention:
- `<TYPE>_<SUB_TYPE>_<DETAIL>`

Where:
- `<TYPE>` 
 is the type of node
- `<SUB_TYPE>` further categorizes the node
- `<DETAIL>` describes the node behavior.

### Start Events

For [start events]({{< relref "/how-to/bpmn/bpmn-elements">}}),
use the name to describe each trigger according to the following convention:

`START_<SUB_TYPE>_<DESCRIPTION>`

For message starts, include the topics.
For timers, indicate the frequency.

| SubType | Description |
| --- | --- |
| `API` | Manual start via API |
| `MSG` | Message Start |
| `TIMER` | Timer start |

Examples:
- `START_MSG_InboundOrders`
- `START_API`
- `START_TIMER_EveryTenMinutes`

### Query task

Runs a GraphQL [{{< abbr "query" >}}]({{< relref "/how-to/gql/query/" >}}).

Prefix: `Q`.

| SubTypes | Description                                                                             |
|----------|-----------------------------------------------------------------------------------------|
| `GET`    | [Get query]({{< relref "/how-to/gql/query/#get" >}}). Expected to return one item       |
| `QUERY`  | [Query operation]({{< relref "/how-to/gql/query/#query" >}}). May return multiple items |
| `AGG`    | [Aggregate query]({{< relref "/how-to/gql/query/#aggregate" >}})                        |

Examples:

- `Q_GET_OperationsScheduleByOperationId`
- `Q_QUERY_JobOrdersByOperationsRequestId`

### Mutation task

Runs a GraphQL [{{< abbr "mutation" >}}]({{< relref "/how-to/gql/mutate/" >}}).


Prefix: `M`

| SubTypes | Description                                                                              |
|----------|------------------------------------------------------------------------------------------|
| `ADD`    | [Adds]({{< relref "/how-to/gql/mutate/#add" >}}) a new record                            |
| `UPDATE` | [Updates]({{< relref "/how-to/gql/mutate/#update" >}}) existing                          |
| `UPSERT` | Updates existing [or adds new]({{< relref "/how-to/gql/mutate/#upsert" >}}) if not found |
| `DELETE` | [Deletes]({{< relref "/how-to/gql/mutate/#delete" >}}) a record                          |
|          |                                                                                          |

Examples:

- `M_UPSERT_ProcessOrder`
- `M_ADD_UnitOfMeasure`

### JSONata transform task

Prefix: `J`

| SubType     | Description                                 |
|-------------|---------------------------------------------|
| `INIT`      | Initialising some new variables             |
| `INDEX`     | Updating an index variable                  |
| `MAP`       | Mapping one entity to another               |
| `TRANSFORM` | Updates existing or adds new if not found   |
| `DIFF`      | Calculating the difference between entities |
| `CLEANUP`   | Deletes the record                          |
| `CALC`      | Performing some calculation                 |

Examples:

- `J_INDEX_CreateLoop1`
- `J_TRANSFORM_PO_to_JO`
- `J_INIT_ProcessingLimits`

### REST task


REST nodes should also indicate the target system and endpoints,
according to the following naming convention:

`REST_<SYSTEM>_<SUB_TYPE>_<ENDPOINT>_<DETAIL>`

Where:

- `SYSTEM` abbreviates the system being called, for example `SAP`.


| SubType  | Description                                 |
|----------|---------------------------------------------|
| `GET`    | Initialising some new variables             |
| `POST`   | Updating an index variable                  |
| `PUT`    | Mapping one entity to another               |
| `PATCH`  | Updates existing or adds new if not found   |
| `DELETE` | Calculating the difference between entities |

Examples:

- `REST_SAP_POST_bill-material-bom`
- `REST_EWM_GET_serial-number-by-object-v1_RingSerialNumbers`

### Gateway

Prefix = `GW`

| SubType   | Description             |
|-----------|-------------------------|
| `X_SPLIT` | Exclusive gateway split |
| `X_JOIN`  | Parallel gateway join   |
| `P_SPLIT` | Parallel gateway split  |
| `P_JOIN`  | Parallel gateway join   |

Examples:

- `GW_X_SPLIT_DifferenceLoop01`
- `GW_P_JOIN_DifferenceLoop01`

### Sequence Flows

Only name sequence flows that have conditions.
If a sequence flow carries a condition, indicate the condition in the naming as follows:

`F_<CONDITION_DESCRIPTION>`

Examples:

- `F_NoNewEquipment`
- `F_AbandonFlagTrue`

### End Events

 If a workflow has multiple end events, indicate their number according to this convention:
- `END_<NUMBER>`

Examples:

- `END_01`
- `END_02`

## Response Field Naming

When nodes generate a response, give the response field the same name as its node.

