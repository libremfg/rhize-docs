+++
title = "Event Driven Architecture"
weight = 4
[menu.main]
  identifier = "eda"
  parent = "arch"
+++

_Event-driven architecture (EDA)_ is a software design pattern that focuses on the flow of events, notifications, and messages within a system to facilitate communication and interaction between different components or services. In EDA, systems are built to respond to events rather than following a strict procedural flow.

At the heart of  is the concept of events. Events are discrete occurrences or notifications that represent changes or actions within a system. These events can include user actions, changes in data, external triggers, or any other meaningful incident. Event-driven systems typically have three main components:

1. **Event Producers:** These are entities that generate or trigger events. They can be user interactions, sensors, external systems, or even other components within the same system.

2. **Event Bus (or Broker):** The event bus is responsible for receiving, storing, and distributing events to the appropriate event consumers. It acts as a communication channel that decouples event producers from event consumers, allowing for a more flexible and modular architecture.

3. **Event Consumers:** These are components, services, or modules that react to specific events they're interested in. Consumers subscribe to events on the event bus and perform actions or tasks in response to those events.

The benefits of an Event-Driven Architecture include:

- **Scalability:** EDA can easily scale since new components can be added to the system by simply subscribing to relevant events on the event bus.

- **Decoupling:** By decoupling event producers and consumers through the event bus, components become more independent, making the system more flexible and adaptable to changes.

- **Modularity:** Different parts of the system can be developed and updated independently as long as they adhere to the events they produce and consume.

- **Real-time Responsiveness:** EDA enables real-time processing and reaction to events, which is crucial for systems requiring quick responses to changing conditions.

- **Flexibility:** It allows for easier integration of new functionalities, third-party services, and external systems without disrupting the existing architecture.

EDA is commonly used in various domains, including microservice architectures, internet of things (IoT) systems, financial trading platforms, and real-time analytics applications. It's particularly useful in scenarios where asynchronous communication, flexibility, and responsiveness are critical.

## The 4 Patterns of EDA

1. **Event Notification:** Systems publish events when interesting things happen. Other systems can subscribe to those event notifications to determine if they need to take subsequent action.
   - positives: Greater Decoupling, Reduced Load on Source
   - negatives: Replicated Data, Eventual Consistency
2. **Event-carried State Transfer:** The published events contain all the pertinent context about the event from the perspective of the publisher limiting the need for the subscriber to request additional information
   - positives: Greater Decoupling, Reduced Load on Source
   - negatives: Replicated Data, Eventual Consistency
3. **Event Sourcing:** An append-only log of events is created that allows the application state to be build from the logs. Event sourcing is version control for data in your application. Accounting ledgers are an example of an event-sourced system
   - positives: 
     - Greater Decoupling, 
     - Reduced Load on Source
     - Audit
     - Historic State
     - Alternative State / Branching / Historical State Change
     - Memory Image
   - negatives:
     - Unfamiliar
     - Integration with External systems is more complex
     - Event Schema changes and application code changes can invalidate the application state
     - Identifiers / Data Integrity / Referential Integrity is more complex to achieve
     - Asynchronous processing is often more complex
     - Versioning along with the ability to replay old events with newer logic is quite complex
     
4. **CQRS:** Command Query Responsibility Segregation. Separate components are used for querying data as for changing data
    - positives: Greater Decoupling, Reduced Load on Source
    - negatives: Replicated Data, Eventual Consistency
