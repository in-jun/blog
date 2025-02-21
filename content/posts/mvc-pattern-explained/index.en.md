---
title: "What is the MVC Pattern?"
date: 2024-06-05T15:22:37+09:00
tags: ["mvc", "design pattern"]
draft: false
---

The MVC pattern (Model-View-Controller) is a software design pattern that divides software into three parts and develops it. By dividing the software into three parts of the Model, View, and Controller, the MVC pattern improves the maintainability and scalability of the software, and helps developers to understand and develop the software more easily.

### Model

The Model is the part of the software that contains the data and handles the data structure and the logic for handling the data.

### View

The View is the part of the software that is responsible for the user interface and displays data to the user.

### Controller

The Controller is the part of the software that contains the business logic and controls the Model and View by receiving input from the user.

The MVC pattern improves the maintainability and scalability of the software and helps developers to understand and develop the software more easily by dividing the software into three parts. The MVC pattern is also widely used in web development and is based on the MVC pattern in major web frameworks such as Spring, Django, and Ruby on Rails.

## How to use the MVC pattern in Spring Boot

#### Model

In Spring Boot, the Model is the part that handles the data, and handles the structure of the data and the logic for handling the data. It is defined as a Java class and consists of fields containing data and methods for handling the data. You can use components such as DTOs, Entities, and Repositories to define and handle data.

#### View

In Spring Boot, the View is the part that handles the user interface and displays data to the user. It is defined as an HTML file and uses template engines such as Thymeleaf, Freemarker, and JSP to display data. You can create HTML files using the Thymeleaf template engine and pass data from the Model in the Controller to the View to display it to the user. You can return data in JSON format when implementing REST APIs using the `@RestController` annotation.

#### Controller

In Spring Boot, the Controller is the part that handles the business logic and controls the Model and View by receiving input from the user. It is defined as a Java class and processes the Model and displays the View upon receiving a user request. You can define controller classes using the `@Controller` annotation and process user requests using the `@GetMapping` and `@PostMapping` annotations.
