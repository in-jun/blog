---
title: "What is the MVC Pattern?"
date: 2024-06-05T15:22:37+09:00
tags: ["mvc", "design pattern", "spring", "architecture"]
description: "A comprehensive guide to the MVC pattern from its 1979 origins to Spring MVC architecture, pros and cons, and comparisons with MVP/MVVM"
draft: false
---

## The Birth of the MVC Pattern

The MVC pattern was first conceived in 1979 by Norwegian computer scientist Trygve Reenskaug while working on the Smalltalk project at Xerox PARC (Palo Alto Research Center). It emerged from his efforts to design graphical user interface (GUI) software that would enable users to effectively control and visualize complex data.

Initially known by various names, the pattern was formalized as Model-View-Controller on December 10, 1979, following extensive discussions with Adele Goldberg. For over 40 years since then, it has established itself as a foundational pattern in software architecture.

## Core Concepts of the MVC Pattern

The MVC pattern is an architectural pattern that separates an application into three distinct roles: Model, View, and Controller. Each component maintains independent responsibilities. By separating the user interface from business logic, it increases code reusability and facilitates maintenance. This separation allows multiple developers to work on different layers independently, maximizing collaboration efficiency.

### Model

The Model is the layer responsible for core data and business logic in the application.

The main roles are as follows:

- Interacts with the database and manages data state
- Validates data integrity
- Contains data transformation and calculation logic
- Operates independently without dependencies on View or Controller, maximizing reusability

In Spring Boot, it consists of components such as Entity, DTO, Repository, and Service. These are mapped to database tables through JPA and implement transaction processing and business rules.

### View

The View is the presentation layer that visually represents data to users.

It can be implemented in various forms:

- Web pages using HTML, CSS, and JavaScript
- Dynamic page generation through template engines (Thymeleaf, JSP, Freemarker, etc.)
- API responses in JSON/XML format

The View only displays Model data to users and should not contain business logic. It receives user input and passes it to the Controller. Multiple Views can represent the same Model data in different ways, making it easy to support various clients such as web, mobile, and API.

### Controller

The Controller acts as a mediator that receives user requests and controls the flow between Model and View.

The main responsibilities are as follows:

- Validates user input
- Invokes appropriate business logic
- Updates Model state
- Selects the appropriate View to display results and generates responses

In Spring Boot, Controllers are defined using `@Controller` or `@RestController` annotations. They map HTTP requests to methods using annotations like `@GetMapping` and `@PostMapping`. They bind parameters using `@RequestParam`, `@PathVariable`, and `@RequestBody`.

## How Spring MVC Works

Spring MVC is designed based on the Front Controller Pattern. A centralized controller called DispatcherServlet receives all HTTP requests and delegates them to appropriate handlers. This allows common concerns such as authentication, logging, and exception handling to be processed in one place. Developers can focus solely on business logic.

### Request Processing Flow

1. A client's HTTP request arrives at the DispatcherServlet
2. HandlerMapping finds the Controller mapped to the request URL
3. HandlerAdapter executes the Controller's method
4. The Controller performs business logic and returns Model data and a View name
5. ViewResolver finds the actual View object and renders it
6. The final HTTP response is delivered to the client

During this process, Interceptors can intervene before and after requests to perform common processing such as logging, authentication, and authorization checks. When exceptions occur, ExceptionHandlers process them to generate appropriate error responses.

## Advantages and Disadvantages of the MVC Pattern

### Advantages

- **Separation of Concerns**: Domain logic and UI logic can be developed and modified independently. This greatly improves code readability and maintainability. It increases stability by preventing changes in one part from affecting other parts.

- **High Reusability**: The same Model can be reused across multiple Views, making it easy to support various clients such as web, mobile, and API simultaneously. Since View changes do not affect the Model, UI can be freely improved or replaced.

- **Testability**: Each layer can be tested independently, making unit testing easy. Controller and Service logic can be tested in isolation using Mock objects. Even in integration testing, the clear responsibility of each component enables quick identification of error sources.

### Disadvantages

- **Massive Controller Problem**: In complex applications, Controllers can become excessively bloated. A single Controller handling multiple Models and Views can contain hundreds of lines of code. This makes code analysis and testing difficult and causes dependency issues when adding new features.

- **Model-View Dependency**: It is difficult to completely eliminate dependencies between Model and View. Particularly in traditional MVC implementations, Views often directly reference Models, increasing coupling between the two layers. This means changes in View or Model can affect each other, complicating maintenance.

- **Lifecycle Sharing Problem**: Controllers and Views often share lifecycles, making complete separation difficult. Especially on platforms like Android, Activities or Fragments simultaneously serve as both Controller and View, making testing and reuse challenging.

## MVC vs MVP vs MVVM

MVP (Model-View-Presenter) and MVVM (Model-View-ViewModel) patterns emerged to overcome the limitations of MVC. Each pattern handles the dependency between View and Model differently.

### MVP (Model-View-Presenter)

The MVP pattern replaces MVC's Controller with a Presenter to completely eliminate dependencies between View and Model.

The main characteristics are as follows:

- The View communicates with Model only through the Presenter and has no direct references
- The Presenter controls the View through a View interface, reducing coupling between them
- The View can be easily replaced with a Mock for independent Presenter testing

However, a 1:1 relationship forms between View and Presenter, causing the Presenter to be tightly coupled to a specific View. As applications become more complex, Presenters also become bloated.

### MVVM (Model-View-ViewModel)

The MVVM pattern automates synchronization between View and ViewModel using Data Binding.

The main characteristics are as follows:

- Changes in the View are automatically reflected in the ViewModel and vice versa
- The ViewModel contains only pure data and logic without dependencies on specific Views
- High reusability and testability

MVVM has been widely adopted in modern frontend frameworks such as Angular, React, and Vue.js. Two-way data binding makes it easy to keep UI and state in sync. It supports a declarative programming style that improves code readability.

### Pattern Selection Guide

The application targets for each pattern are as follows:

- **MVC**: Suitable for traditional server-side web applications (Spring, Django, Ruby on Rails). It is optimized for structures that render HTML on the server and return it. Implementation is intuitive with a low learning curve, enabling rapid prototype development.

- **MVP**: Useful for Android development or projects where testability is important. It is chosen when complete separation of View and Model is needed. View logic can be isolated through the Presenter, making unit testing easy.

- **MVVM**: Widely used in frontend-centric SPA applications (React, Vue.js, Angular). It efficiently handles complex UI state management through data binding and reactive programming. High component reusability makes it suitable for large-scale frontend application development.

## Conclusion

The MVC pattern has been evolving as the foundation of software architecture for over 40 years since its birth in 1979. It became the basis for major web frameworks such as Spring, Django, and Ruby on Rails, providing core values of separation of concerns and improved code reusability.

Although limitations exist such as Controller bloat and Model-View dependency issues, it is still effectively utilized in modern web application development when combined with Spring MVC's advanced features like DispatcherServlet, Interceptors, and AOP, as well as REST API architecture and microservice patterns.

Selecting the appropriate pattern among MVC, MVP, and MVVM based on project requirements, team technology stack, and application complexity, and mixing multiple patterns as needed is the best approach. It is important to understand and apply the essence of separation of concerns and improved maintainability that each pattern pursues, rather than the patterns themselves.
