---
title: "Tutorial: create rule to trigger workflow"
date: "2024-04-29T11:39:29+03:00"
draft: false
categories: ["tutorial"]
description: Follow this tutorial to create a rule to run a workflow every time a data source changes.
weight:
menu:
  main:
    parent: how-to
    identifier:
---

An equipment class rule triggers a BPMN workflow whenever a data source publishes a value that meets a specified threshold.

Imagine a scenario when an oven must be preheated every time a new order number is published to NATS. A rule will listen to messages published to a specific topic and apply a boolean condition to them. If the condition evaluates to true, the rule will trigger a BPMN that will preheat the oven.

{{% notice note %}}

This article assumes the data source protocol is MQTT.

{{% /notice %}}

## Section 1: Prerequisites

Before setting a rule, configure the following via the admin UI:

- Data source
- Data source topic
- Unit of measure
- BPMN
- Equipment class with bound properties

Then, you’ll be able to create a rule and associate it with an actual equipment.

### Creating a Data Source

1. Navigate to Main Menu > Master Data > Data Sources.
2. Create a new data source using the sidebar. The label (id) must be identical to the one specified in the configuration file for the libre-agent microservice.
3. Add a draft data source version from the `General` tab.
4. Select a data source protocol.
5. Optionally, enter a connection string, such as `mqtt://nats:1883`, that is identical to the one specified in the configuration file for the libre-agent microservice.
6. Save the data source version to create it.

{{< bigFigure
width="100%"
alt="A new data source and version created in the UI."
src="/images/equipment-class-rules/Creating_a_Data_Source_and_Version.png"
caption="A new data source and version created in the UI."
>}}

### Creating a Data Source Topic

1. Navigate to the `Topics` tab.
2. Add a new property (i.e., topic)
3. Select `STRING` for the property’s data type (assuming an order number will be a string and look like `Order1` for example).
4. Select your preferred deduplication key. The default option, `Message Value`, is most appropriate for this scenario.
5. For label, enter the exact topic name as it appears in the data source. You can use a slash to refer to a nested topic. For this example, all new order numbers will be published to `Oven/OrderNumber`.
6. Confirm by clicking on the green tick icon.
7. Navigate to the `General` tab and change the version state to Active

{{< bigFigure
width="100%"
alt="A new data source topic created in the UI."
src="/images/equipment-class-rules/Creating_a_Data_Source_Topic.png"
caption="A new data source topic created in the UI."
>}}

### Creating a Unit of Measure

1. Navigate to Main Menu > Master Data > Units of Measure.
2. Add a new unit of measure.
3. Enter `Order Number` for the unit name.
4. Select `STRING` for the data type.

{{< bigFigure
width="100%"
alt="A new unit of measure created in the UI."
src="/images/equipment-class-rules/Creating_a_Unit_of_Measure.png"
caption="A new unit of measure created in the UI."
>}}

### Creating a BPMN

A rule cannot be set up without a BPMN. Ensure you have one ready before setting up a rule in the next section. For this example, this simple 3-node BPMN will be enough:

[rules_example_bpmn](../../static/BPMNs/rules_example_bpmn.bpmn)

1. Navigate to Main Menu > Workflows > Process List.
2. Import the BPMN
3. Save it.
4. Set the version as active.

{{< bigFigure
width="100%"
alt="A BPMN created in the UI."
src="/images/equipment-class-rules/Creating_a_BPMN.png"
caption="A BPMN created in the UI."
>}}

The BPMN has a `Libre Jsonata Transform` task that contains an expression `"Preheating oven for order number " & $.orderNumber”` . This means the rule engine must trigger this BPMN with a payload that includes the order number value like so:

```json
{
  "orderNumber": "Order1"
}
```

### Creating an Equipment Class with Bound Properties

#### Equipment Class and Version

1. Navigate to Main Menu > Master Data > Equipment Class.
2. Create a new equipment class via the sidebar. The label can be `Pizza Line` for example.
3. From the `General` tab, create a new Draft version.

{{< bigFigure
width="100%"
alt="A new equipment class and version created in the UI."
src="/images/equipment-class-rules/Creating_an_Equipment_Class_and_Version.png"
caption="A new equipment class and version created in the UI."
>}}

#### Equipment Class Property

1. From the properties tab, create a new property.
2. Select `BOUND` for type.
3. Enter `orderNumber` for name.
4. Select the unit of measure created earlier (`Order Number`) for UoM.

{{< bigFigure
width="100%"
alt="A new equipment class property created in the UI."
src="/images/equipment-class-rules/Creating_an_Equipment_Class_Property.png"
caption="A new equipment class property created in the UI."
>}}

## Section 2: Creating a Rule

### Adding a Rule to an Existing Equipment Class

1. From the Rules tab of an equipment class version, create a new rule.
2. Enter `Run BPMN on Order Number` for the name and confirm.
3. Select `rules_example_bpmn` for the workflow specification.
4. Add `orderNumber` as a trigger property.
5. Add a trigger expression that evaluates to true or false.

{{% notice note %}}

The rule will run the workflow above only if the expression evaluates to true. It’s common to compare the new value with the previous.

{{% /notice %}}

In this case, we can compare the new order number to the previous by adding `orderNumber.current.value != orderNumber.previous.value`. Note that the root of the object path must match the id of the equipment class property we set up earlier. If the property was called Order Number, you need to access it like this instead `"Order Number".current.value != "Order Number".previous.value`.

The entire information that becomes available to the rule engine looks like this:

```javascript
{
  orderNumber: {
    current: {
      bindingType: "BOUND",
      description: "bound prop",
      equipmentClassProperty: {
        id: "EQCLASS1.10.orderNumber",
        iid: "0x2a78",
        label: "orderNumber"
      },
      equipmentVersion: {
        equipment: {
          id: "EQ1",
          iid: "0x1b",
          label: "EQ1"
        },
        id: "EQ1",
        iid: "0x22",
        version: "2"
      },
      id: "EQCLASS1.10.orderNumber",
      label: "orderNumber",
      messageKey: "ns=3;i=1003.1695170450000000000",
      propertyType: "DefaultType",
      serverPicoseconds: 0,
      serverTimestamp: "2023-09-20T00:40:50.028Z",
      sourcePicoseconds: 0,
      sourceTimestamp: "2023-09-20T00:40:50Z",
      value: "Order2",
      valueUnitOfMeasure: {
        dataType: "FLOAT",
        id: "FLOAT",
        iid: "0x28"
      }
    },
    previous: {
      bindingType: "BOUND",
      description: "bound prop",
      equipmentClassProperty: {
        id: "EQCLASS1.10.orderNumber",
        iid: "0x2a78",
        label: "orderNumber"
      },
      equipmentVersion: {
        equipment: {
          id: "EQ1",
          iid: "0x1b",
          label: "EQ1"
        },
        id: "EQ1",
        iid: "0x22",
        version: "2"
      },
      id: "EQCLASS1.10.orderNumber",
      label: "orderNumber",
      messageKey: "ns=3;i=1003.1695170440000000000",
      propertyType: "DefaultType",
      serverPicoseconds: 0,
      serverTimestamp: "2023-09-20T00:40:40.003Z",
      sourcePicoseconds: 0,
      sourceTimestamp: "2023-09-20T00:40:40Z",
      value: "Order1",
      valueUnitOfMeasure: {
        dataType: "FLOAT",
        id: "FLOAT",
        iid: "0x28"
      }
    }
  }
}
```

6. Optionally, pass information to the BPMN by adding a payload message. The message will be an object with multiple keys.
7. Enter `orderNumber` for the field name.
8. Enter `orderNumber.current.value` for the JSON expression.
9. Create the rule.
10. From the `General` tab, change the equipment class version state to active.

{{< bigFigure
width="100%"
alt="Creating an equipment class rule in the UI."
src="/images/equipment-class-rules/Creating_a_Rule.png"
caption="Creating an equipment class rule in the UI."
>}}

### Associating an Equipment with a Bound Property

The final steps to setting up a rule are to:

1. Create a new equipment version.
2. Link it to a data source.
3. Set up bound properties.

#### Create an Equipment and Version

1. Navigate to Navigate to Main Menu > Master Data > Equipment.
2. Select a piece of equipment. If none, create one called `Line 1`.
3. From the `General` tab, add a draft version.
4. Link the version to the equipment class you created earlier (`Pizza Line`).
5. Save the version to create it.

{{< bigFigure
width="100%"
alt="A new equipment class and version created in the UI."
src="/images/equipment-class-rules/Creating_an_Equipment_and_Version.png"
caption="A new equipment class and version created in the UI."
>}}

#### Link a Data Source

1. From the `Data Sources` tab, link the equipment version to the data source you created at the beginning of Section 1.

{{< bigFigure
width="100%"
alt="An equipment linked to a data source in the UI."
src="/images/equipment-class-rules/Link_Equipment_to_Data_Source.png"
caption="An equipment linked to a data source in the UI."
>}}

#### Set Up the Bound Property

1. From the properties tab, find a property you want this equipment to inherit and click on the binding icon.
2. If you chose the property `orderNumber`, add the topic `Oven/OrderNumber` you added in Section 2.

{{< bigFigure
width="100%"
alt="An equipment property bound to a data source topic in the UI."
src="/images/equipment-class-rules/Binding_an_Equipment_Property_to_a_Topic.png"
caption="An equipment property bound to a data source topic in the UI."
>}}

### Testing the Binding and the Rule

To test the value of the property `orderNumber` of the equipment `Line 1` has been bound to the topic Oven/OrderNumber, you need to:

1. Open `MQTT Explorer` and connect to the broker.

The microservice Libre Agent (`libre-agent`) should immediately publish a message to indicate the data source topic `Oven/OrderNumber` has been set up successfully.

{{< bigFigure
width="65%"
alt="The Libre Agent has connected to the data source."
src="/images/equipment-class-rules/Libre_Agent_has_Connected_to_the_Data_Source.png"
caption="The Libre Agent has connected to the data source."
>}}

2. Publish the string `Order1` to the topic `Oven/OrderNumber`.

{{< bigFigure
width="65%"
alt="A new order number was published to the data source."
src="/images/equipment-class-rules/Publish_Order_Number_to_NATS.png"
caption="A new order number was published to the data source."
>}}

A new topic called `Oven` containing the subtopic `OrderNumber` will appear if the message has been received.

A topic called `MQTT/nats/ValueChanged` will also appear if there is an equipment property bound to this topic.

In addition, the published value should show in the column `Expression` of the equipment property `orderNumber`.

{{< bigFigure
width="100%"
alt="The bound property assumes the last value published to the data source."
src="/images/equipment-class-rules/New_orderNumber_in_the_Admin_UI.png"
caption="The bound property assumes the last value published to the data source."
>}}

{{% notice note %}}

If this is the very first message published to the topic, the rule will not be triggered because there is no previous value to compare to the latest one. However, if you publish another order number, a new topic called `Core` will show up containing a subtopic called `RuleTriggered` to indicate that the rule has indeed been triggered.

{{% /notice %}}

{{< bigFigure
width="65%"
alt="The rule engine has published a message to indicate that the equipment class rule has indeed been triggered."
src="/images/equipment-class-rules/Rule_Triggered_in_broker.png"
caption="The rule engine has published a message to indicate that the equipment class rule has indeed been triggered."
>}}

To confirm the intended BPMN was executed, navigate to Grafana (Tempo) and look for a trace containing the expected BPMN id.

{{< bigFigure
width="100%"
alt="Grafana shows a recent trace with the id of the target BPMN."
src="/images/equipment-class-rules/Executed_BPMNs_in_Grafana.png"
caption="Grafana shows a recent trace with the id of the target BPMN."
>}}
