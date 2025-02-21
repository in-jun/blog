---
title: "Exploring the Dispatcher Servlet"
date: 2024-06-05T08:14:35+09:00
tags: ["spring", "dispatcher servlet", "java"]
draft: false
---

## What is the Dispatcher Servlet?

The Dispatcher Servlet is at the heart of Spring MVC. It is responsible for receiving client requests, delegating them to the appropriate controller, and then passing the result returned by the controller to the view. There is only one Dispatcher Servlet in a web application, and it handles all client requests.

### How the Dispatcher Servlet Works

1. Receives a request from the client.
2. Finds the controller that will handle the client's request through Handler Mapping.
3. Executes the controller through Handler Adapter.
4. Transforms the result returned by the controller into a View through View Resolver.
5. Forwards the view to the client.

> When using `RestController`, View Resolver is not used. Instead, the object is converted to JSON format and sent to the client.

### Advantages of the Dispatcher Servlet

4. No need to configure servlet mappings in web.xml.
1. Developers can focus only on the controller because the Dispatcher Servlet delegates client requests to the appropriate controller.
1. Developers don't have to worry about handling the View because the Dispatcher Servlet passes the result returned by the controller to the View.
1. Developers don't have to use the Servlet API because request and response handling is handled by the Dispatcher Servlet.

### Additional Features of the Dispatcher Servlet

In addition to basic request handling, the Dispatcher Servlet provides various additional features.

#### Interceptor Support

The Dispatcher Servlet supports the use of interceptors to perform specific logic before and after handling requests. This allows common functionality (e.g., authentication, logging) to be handled centrally.

#### Exception Handling Capabilities

The Dispatcher Servlet has built-in exception handling capabilities, allowing for consistent exception handling throughout the application. You can define handling logic for specific exceptions using `@ControllerAdvice` and `@ExceptionHandler`.

#### Custom Handler Mappings

In addition to the default handler mappings, you can implement custom handler mappings to apply complex request mapping logic. This allows for more flexible request handling.

### Configuring the Dispatcher Servlet

When using Spring Boot, the Dispatcher Servlet is automatically configured by default. However, you can also manually configure it if necessary. You can configure the Dispatcher Servlet by registering it as a bean in a `@Configuration` class.

```java
@Configuration
public class WebConfig {
    @Bean
    public DispatcherServlet dispatcherServlet() {
        DispatcherServlet dispatcherServlet = new DispatcherServlet();
        dispatcherServlet.setThrowExceptionIfNoHandlerFound(true);
        return dispatcherServlet;
    }
}
```

By configuring it this way, you can set it to throw an exception when no handler is found.

### Conclusion

The Dispatcher Servlet is a core component of Spring MVC, responsible for handling client requests and delegating them to the appropriate controller. Its various additional features and configurability make it possible to develop flexible and powerful web applications.
