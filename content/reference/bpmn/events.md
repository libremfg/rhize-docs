---
title: 'Events'
date: '2023-09-26T11:10:37-03:00'
draft: false
category: reference
description: >-
  Descriptions and notations for start, intermediary, and end events.
weight: 100
menu:
  main:
    parent: bpmn-reference
    identifier: bpmn-events
---

_Events_ are something that happen in the course of a process.
In BPMN, events are drawn with circles.

In event-driven models, events can happen in one of three _dimensions_:

- **Start.**
  All processes begin with some trigger that starts an event. Start events are drawn with a single thin circle.

- **Intermediate.** 
  Possible events between the start and end. Intermediate events might start from some trigger, or create some result. They are drawn with a double thin line.

- **End.**
  All processes end with some result. End events are drawn with a single thick line.

![A simplified model of events with no activities](/images/bpmn/rhize-bpmn-events.png)

Besides these dimensions, BPMN also classifies events by whether they _catch_ a trigger or _throw_ a result.
All start events are catch events; that is, they react to some trigger.
All end events are throw events; that is, they terminate with some output&mdash;even an error.
Intermediate events may throw or catch.

Rhize supports various event types to categorize an event, as described in the following sections.
Throwing events are represented with icons that are filled in.

### Message

![A message event](/images/bpmn/bpmn-message-event.svg)

- Purpose: To denote a message being caught or thrown.
- Icon: An envelope
- Examples: A MQTT device publishes a message about a new sensor reading (starting a process). The ERP system sends a confirmation document (ending a process).
- Dimension: Start, intermediate, end


### Timer

![A timer event](/images/bpmn/bpmn-timer-event.svg)
- Purpose: An event after a certain amount of elapsed time or on a certain data
- Icon: A clock
- Examples: An hourly timer starts a process to check quality. An intermediate event starts after a twenty-minute fermentation process.
- Dimension: Start, intermediate

### Error

![An error event](/images/bpmn/bpmn-error-event.svg)

- Purpose: An error occurred in the system
- Icon: A flash
- Example: A REST server returns a 500 error.
- Dimension: End



<!---
### Signal
![An signal event](/images/bpmn/bpmn-signal-event.svg)
- Purpose: An event that catches or throws a signal
- Dimension: Start, intermediate, end
- Example: 
### Conditional
![An conditional event](/images/bpmn/bpmn-conditional-event.svg)
- Purpose: An trigger event caught when some condition is true.
- Icon: 
- Example: A sensor reading exceeds 100 degrees celsius (starting a process).
- Dimension: Start, intermediate
### Compensation
![An compensation event](/images/bpmn/bpmn-compensation-event.svg)
- Purpose: Undo events that already happened
- Dimension: intermediate, End
- Example: A failed quality check halts a batch process.
### Escalation
![Escalation events](/images/bpmn/bpmn-escalation-event.svg)
- Purpose: An escalation event caught or thrown
- Dimension: Start, intermediate, end
- Example: 
 -->

