---
title: "Exploring the Dispatcher Servlet"
date: 2024-06-05T08:14:35+09:00
tags: ["spring", "dispatcher servlet", "java"]
description: "A comprehensive guide to DispatcherServlet, the core component of Spring MVC, covering its history, the Front Controller pattern, detailed request processing flow, key components like HandlerMapping/HandlerAdapter/ViewResolver, initialization process, Spring Boot auto-configuration, differences between @Controller and @RestController, and practical tips including Interceptor vs Filter differences and async request handling."
draft: false
---

## What is the Dispatcher Servlet?

The Dispatcher Servlet is the core component of Spring MVC that implements the Front Controller pattern. It receives all HTTP requests from clients at a single entry point, delegates them to the appropriate controllers, and renders the results returned by controllers into views for responses. Only one Dispatcher Servlet exists in a web application. It handles all requests centrally, enabling efficient management of common logic and allowing developers to focus on business logic.

## History and Evolution of DispatcherServlet

Spring MVC emerged in 2004 with Spring Framework 1.0, establishing itself as a web framework with DispatcherServlet implementing the Front Controller pattern as an alternative to the complex servlet development approach of J2EE at that time. Initially, servlets were registered and mapped through XML-based configuration. Since Servlet 3.0 and above, Java configuration became possible through `WebApplicationInitializer`. With the advent of Spring Boot, auto-configuration was introduced, allowing developers to use it immediately without separate configuration.

## Front Controller Pattern

The Front Controller pattern is a design pattern frequently used in enterprise application design that processes all client requests at a single entry point, centralizing common logic (authentication, logging, exception handling) and delegating each request to the appropriate handler. In the traditional servlet approach, individual servlets had to be created for each URL and mapped in web.xml, which caused code duplication and management complexity. Using the Front Controller pattern, one servlet receives and processes all requests, eliminating code duplication and improving maintainability.

## Detailed Request Processing Flow of DispatcherServlet

DispatcherServlet goes through the following seven-stage processing flow from receiving a client request to generating a response.

### Stage 1: Receiving HTTP Request

When a client sends an HTTP request, the servlet container (Tomcat, Jetty, etc.) receives it and calls the `doService()` method of DispatcherServlet. At this point, request information (URL, HTTP method, headers, parameters) is passed in the `HttpServletRequest` object. DispatcherServlet performs preparation work to process this request.

### Stage 2: Finding Handler via HandlerMapping

DispatcherServlet iterates through registered HandlerMapping implementations to find the handler (controller method) mapped to the request URL and HTTP method. The most commonly used `RequestMappingHandlerMapping` finds mapping information based on annotations like `@RequestMapping`, `@GetMapping`, and `@PostMapping`. When a mapping is found, it returns a `HandlerExecutionChain` object containing the handler and interceptor chain.

### Stage 3: Executing Handler via HandlerAdapter

A HandlerAdapter matching the type of the found handler is selected to invoke the actual handler method. `RequestMappingHandlerAdapter` processes methods in classes annotated with `@Controller`, performing tasks like method parameter binding, validation, and type conversion. During this process, `HttpMessageConverter` plays the role of converting (deserializing) the request body into Java objects.

### Stage 4: Returning ModelAndView

When the handler completes execution, it returns a `ModelAndView` object containing the processing result. This object includes the view name (logical view name) and model data (data to be passed to the view). When using `@RestController` or `@ResponseBody`, it bypasses ViewResolver and serializes data directly into the response body.

### Stage 5: Finding View via ViewResolver

ViewResolver converts the logical view name returned by the controller into an actual view object. Various ViewResolver implementations exist: `InternalResourceViewResolver` converts to JSP file paths, `ThymeleafViewResolver` converts to Thymeleaf templates, and others. The configured prefix and suffix are combined to generate the path of the actual view file.

### Stage 6: Rendering View

The `render()` method of the View object found by ViewResolver is called to generate responses like HTML, JSON, or XML based on model data. For JSP, the servlet engine compiles and executes the JSP file to generate the final HTML. Thymeleaf's template engine processes template files to generate dynamic content.

### Stage 7: Returning HTTP Response

The rendered result is written to the `HttpServletResponse` object and delivered to the client. This includes response status code, headers, and body. The servlet container converts this response to match the HTTP protocol and transmits it to the client through the network.

## Detailed Description of Key Components

### HandlerMapping

HandlerMapping is a strategy interface that maps HTTP requests to appropriate handlers. Various implementations exist: `RequestMappingHandlerMapping` maps based on `@RequestMapping` family annotations, `BeanNameUrlHandlerMapping` maps bean names to URLs, and `SimpleUrlHandlerMapping` directly maps URL patterns to handlers. When multiple HandlerMappings are registered, they are searched sequentially according to priority (Order), and the first matching handler is used.

### HandlerAdapter

HandlerAdapter is an interface implementing the adapter pattern to invoke various types of handlers in a consistent manner. `RequestMappingHandlerAdapter` processes methods using `@Controller` and `@RequestMapping`, `HttpRequestHandlerAdapter` processes `HttpRequestHandler` interface implementations, and `SimpleControllerHandlerAdapter` processes the traditional `Controller` interface. Through this, Spring MVC can flexibly support various handler types.

### ViewResolver

ViewResolver converts logical view names into actual view objects. `InternalResourceViewResolver` handles internal resources like JSP and configures prefix and suffix to add paths and extensions to view names. `ThymeleafViewResolver` and `FreeMarkerViewResolver` are ViewResolvers for Thymeleaf and FreeMarker template engines respectively, supporting server-side rendering. Multiple ViewResolvers operate in chain form, searching for views sequentially.

### HandlerExceptionResolver

HandlerExceptionResolver is a strategy interface that handles exceptions occurring during handler execution. `ExceptionHandlerExceptionResolver` processes `@ExceptionHandler` annotations, `ResponseStatusExceptionResolver` processes `@ResponseStatus` annotations, and `DefaultHandlerExceptionResolver` converts Spring MVC's standard exceptions to HTTP status codes. Through this, consistent exception handling and custom error pages can be provided.

### MultipartResolver

MultipartResolver is a component that handles file upload requests (multipart/form-data). `CommonsMultipartResolver` uses the Apache Commons FileUpload library, and `StandardServletMultipartResolver` uses Servlet 3.0's standard multipart API. Spring Boot automatically configures StandardServletMultipartResolver by default. Maximum file size and request size can be limited through `spring.servlet.multipart.*` properties.

### LocaleResolver

LocaleResolver is a strategy interface that determines the client's locale (language and region information). `AcceptHeaderLocaleResolver` determines locale based on the HTTP Accept-Language header, `SessionLocaleResolver` uses locale stored in the session, and `CookieLocaleResolver` uses locale stored in cookies. Through this, internationalization (i18n) is supported to provide content in various languages.

### ThemeResolver

ThemeResolver provides functionality to dynamically switch web application themes (visual elements like CSS and images). `FixedThemeResolver` uses a fixed theme, `SessionThemeResolver` stores theme information in the session, and `CookieThemeResolver` stores theme information in cookies. Flexible UI customization is possible, such as users selecting preferred themes or administrators changing the entire theme.

## Differences in Operation with @RestController

`@Controller` follows the traditional MVC pattern by returning ModelAndView and rendering HTML pages through ViewResolver. However, `@RestController` is an annotation combining `@Controller` and `@ResponseBody`, where the return value of methods is delivered directly to the HTTP response body rather than being a view name. At this time, `HttpMessageConverter` serializes Java objects into formats like JSON or XML. The most commonly used `MappingJackson2HttpMessageConverter` uses the Jackson library to convert objects to JSON, and `GsonHttpMessageConverter` uses the Gson library. The appropriate converter is automatically selected based on `Accept` and `Content-Type` headers, operating in a way optimized for RESTful API development.

## DispatcherServlet Initialization Process

When DispatcherServlet is initialized, it first creates or references an existing `WebApplicationContext`. This context is a container managing Spring beans, including components like controllers, services, and repositories. The bean initialization order is as follows: `ContextLoaderListener` first creates the Root WebApplicationContext and registers common beans (data sources, transaction managers, etc.), then DispatcherServlet creates the Servlet WebApplicationContext to register web layer beans (controllers, ViewResolvers, etc.). The Servlet WebApplicationContext references the Root WebApplicationContext as its parent, forming a hierarchical structure. This dual context structure allows multiple DispatcherServlets to share common beans while each servlet has independent web layer configuration.

## Auto-Configuration in Spring Boot

Spring Boot automatically configures and registers DispatcherServlet through `DispatcherServletAutoConfiguration`, allowing developers to immediately run web applications without separate web.xml or Java configuration. Various settings can be customized through `spring.mvc.*` properties. ViewResolver is configured with `spring.mvc.view.prefix` and `spring.mvc.view.suffix`, static resource paths are specified with `spring.mvc.static-path-pattern`, and exception throwing when handlers are not found is controlled with `spring.mvc.throw-exception-if-no-handler-found`. For more detailed customization, the `WebMvcConfigurer` interface can be implemented to programmatically add or modify interceptors, formatters, message converters, CORS settings, etc. Using `@EnableWebMvc` completely disables auto-configuration and switches to manual configuration.

## Practical Tips

### Interceptor vs Filter Differences

Filter is part of the servlet specification and operates at the servlet container level, intercepting requests and responses before and after DispatcherServlet execution. Interceptor is part of Spring MVC and operates inside DispatcherServlet after HandlerMapping and before/after Handler execution, with access to Spring beans and the ability to modify ModelAndView. Filter is suitable for low-level processing like security, encoding, and logging. Interceptor is suitable for business logic-related processing like authentication, authorization checks, and logging. Interceptor implements the `HandlerInterceptor` interface's `preHandle()`, `postHandle()`, and `afterCompletion()` methods to intervene at each stage of request processing.

### Asynchronous Request Processing

Spring MVC supports Servlet 3.0's asynchronous request processing. When controller methods return `Callable` or `DeferredResult`, the request processing thread is immediately returned, and work is performed in a separate thread before responding with the result. This efficiently uses threads for tasks requiring long processing times (external API calls, large-scale data processing), improving concurrent processing performance. Using Spring WebFlux allows completely non-blocking request processing through a reactive programming model.

### Performance Optimization Methods

Several strategies can be used to optimize DispatcherServlet performance. Static resources should be configured to be handled directly by the servlet container or web server (Nginx, Apache) without going through DispatcherServlet. ViewResolver chains should be minimized to reduce unnecessary view searches. When using `@ResponseBody` or `@RestController`, appropriate HttpMessageConverters should be selected to improve serialization performance. Only essential interceptors and filters should be registered to minimize overhead. Caching strategies (HTTP cache headers, Spring Cache) should be applied to reduce processing time for duplicate requests.

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

## Conclusion

DispatcherServlet is a core component of Spring MVC that implements the Front Controller pattern to centrally handle all HTTP requests, providing a flexible and extensible architecture through strategy interfaces like HandlerMapping, HandlerAdapter, and ViewResolver. Since its emergence in 2004, it has continuously evolved through Servlet 3.0 support, Java configuration, and Spring Boot's auto-configuration. It supports both traditional MVC and RESTful API development through @Controller and @RestController, provides functionality like interceptors, exception handling, file uploads, and internationalization through various components and configuration options, and abstracts the complexity of the web layer to enable powerful web application development while allowing developers to focus on business logic.
