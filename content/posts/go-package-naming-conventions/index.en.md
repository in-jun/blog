---
title: "Go Package Naming Conventions"
date: 2025-02-15T21:40:48+09:00
tags: ["Go", "Programming"]
description: "Package naming rules and best practices in Go."
draft: false
---

> This article references the official Go blog's "Package Names," Go code review comments, and standard library design cases.

## Go Package Design Philosophy

Go's package system reflects the language's emphasis on simplicity and clarity. Instead of adopting deep package hierarchies like Java or C++ namespace systems, Go separates package paths from package names so code can stay concise without losing meaning.

Go's package conventions do not enforce strict rules for directory structure or architectural patterns. That is a deliberate design choice. The language's creators, including Rob Pike and Ken Thompson, favored an approach that gives programmers flexibility while still offering clear guidance. You can see this throughout the standard library. In practice, Go's package conventions center on the following principles.

## 1. Organize by Responsibility

Go discourages type-centric structures where all interfaces are gathered in an `interfaces` package or all data structures are concentrated in a `models` package. This is a common anti-pattern from traditional Java package structures. Instead, Go recommends organizing packages based on the "Organize by responsibility" principle, where each package is responsible for a specific domain. This aligns with fundamental software design principles of high cohesion and low coupling.

### Anti-pattern: Type-based Package Organization

Many Go beginners make the mistake of creating structures like the following based on their experience with other languages.

```
myapp/
├── interfaces/
│   ├── user.go
│   └── order.go
├── models/
│   ├── user.go
│   └── order.go
└── services/
    ├── user.go
    └── order.go
```

This structure makes maintenance difficult because modifying a specific feature requires changing multiple packages simultaneously. It is prone to circular dependency issues, and low cohesion makes related logic hard to find.

### Recommended Pattern: Responsibility-based Package Organization

Organizing packages around domain responsibilities brings related types and logic together in one package, increasing cohesion.

```
myapp/
├── user/
│   ├── user.go        // User type and related methods
│   ├── repository.go  // Repository interface and implementation
│   └── service.go     // Business logic
└── order/
    ├── order.go       // Order type and related methods
    ├── repository.go
    └── service.go
```

In this structure, all user-related code resides in the `user` package, and all order-related code resides in the `order` package. When modifying or understanding a feature, you only need to check one package. The Go standard library's `net/http` package follows this principle, providing everything HTTP-related (server, client, handlers, request/response types) in a single package.

## 2. Leveraging Package Paths for Namespaces

Go uses package paths as both namespaces and a way to communicate intent. This is one of the language's distinctive traits. Package paths are not just file system locations; they also tell readers what a package is for and where it fits. The standard library applies this idea consistently.

### Hierarchical Namespaces in the Standard Library

The Go standard library groups related packages under top-level directories to provide clear namespaces.

-   `crypto/`: Namespace for cryptography-related packages, including `crypto/aes`, `crypto/rsa`, `crypto/sha256`, providing all cryptographic algorithms and functions under a consistent path.
-   `encoding/`: Namespace for data encoding-related packages, including `encoding/json`, `encoding/xml`, `encoding/base64`, supporting various encoding formats.
-   `net/`: Namespace for network-related packages, including `net/http`, `net/url`, `net/rpc`, providing all network programming functionality.

### Clear Distinction of Packages with Identical Names

Package paths also make it easy to distinguish packages that share the same name. A representative example is `pprof`.

-   `runtime/pprof`: A low-level package that generates and saves runtime profiling data. Use this when you need to save profiling data to a file or control it directly.
-   `net/http/pprof`: A high-level package that provides profiling data through an HTTP server. It registers HTTP handlers so profiling information can be viewed in a web browser.

Both packages are named `pprof`, but their paths show the difference: `runtime/pprof` is for runtime profiling, while `net/http/pprof` exposes profiling through an HTTP server. In many cases, the import path alone tells you which one you need.

### Project Namespace Organization

Applying standard library patterns to projects clarifies code structure. For example, an e-commerce system can be organized as follows.

```
myapp/
├── payment/
│   ├── stripe/      // Stripe payment implementation
│   ├── paypal/      // PayPal payment implementation
│   └── payment.go   // Common interface
└── storage/
    ├── postgres/    // PostgreSQL implementation
    ├── mongodb/     // MongoDB implementation
    └── storage.go   // Common interface
```

In this structure, the `payment` directory groups all payment-related implementations, and the `storage` directory groups all storage-related implementations, making related packages easy to find.

## 3. Avoid Stuttering

In Go, package names combine with exported types and function names in usage. It is important not to repeat information already provided by the package path in package or type names. This is called avoiding "stuttering," and it significantly improves code conciseness and readability.

### Anti-pattern: Stuttering

Here are common examples of stuttering patterns.

```go
// Bad: Duplication between package name and type name
package user
type UserService struct {}    // user.UserService (redundant!)
type UserRepository struct {} // user.UserRepository (redundant!)

// Bad: Incorrectly imitating encoding/json package
package json
type JSONEncoder struct {}    // json.JSONEncoder (redundant!)
```

When used, this code becomes unnecessarily verbose: `user.UserService` and `json.JSONEncoder` repeat the same context in both the package and type name.

### Recommended Pattern: Concise Naming

Since package names already provide context, type and function names should be concise.

```go
// Good: Concise and clear names
package user
type Service struct {}    // user.Service (clear and concise)
type Repository struct {} // user.Repository (clear and concise)

// Standard library examples
package bytes
type Buffer struct {} // bytes.Buffer (perfect)

package http
type Request struct {}  // http.Request (perfect)
type Response struct {} // http.Response (perfect)
```

When used, this code reads naturally and easily as `user.Service`, `bytes.Buffer`, `http.Request`. The combination of package name and type name conveys the clearest meaning.

### Eliminating Redundancy in Function Naming

Apply the same principle to function names. Do not repeat context already provided by the package name.

```go
// Bad
package log
func LogMessage(msg string) {} // log.LogMessage (redundant!)

// Good
package log
func Print(msg string) {}      // log.Print (concise and clear)
func Printf(format string, args ...interface{}) {} // log.Printf
```

The standard library's `log` package uses concise names like `Print`, `Printf`, `Println` instead of `LogMessage`. When used, it reads naturally as `log.Print()`.

## 4. Package Naming Principles

Package names follow Go's philosophy: they should be concise, clear, and lowercase.

### Prefer Lowercase and Single Words

Go package names use only lowercase and do not include underscores (`_`) or uppercase letters. Use a single word when possible. When multiple words are necessary, concatenate them without separators.

```go
// Good
package httputil  // HTTP utility
package strconv   // String Conversion
package filepath  // File Path

// Bad
package http_util  // Uses underscore (discouraged)
package HttpUtil   // Uses uppercase (not allowed)
package stringconversion // Name too long
```

### Clear and Descriptive Names

Package names should clearly communicate what the package does. Avoid names that are too generic or vague.

```go
// Good
package user      // User management
package payment   // Payment processing
package auth      // Authentication

// Bad
package util      // Too generic
package common    // Too vague
package helpers   // Purpose unclear
```

Names like `util`, `common`, `helpers` do not clearly communicate the package's purpose and easily become "junk drawer" packages where unrelated code accumulates over time.

### Abbreviation Usage Principles

Go allows using well-known abbreviations. This pattern is visible in the standard library.

```go
package fmt       // format
package strconv   // string conversion
package syscall   // system call
package regexp    // regular expression
```

However, abbreviations should be commonly used in the relevant domain. Avoid arbitrarily created abbreviations.

## Putting the Principles into Practice

### Examples from the Standard Library

The Go standard library perfectly applies these principles. Let's examine a few examples.

**`encoding/json` package:**
- Package path: `encoding/json` (clearly expresses JSON encoding)
- Key functions: `json.Marshal()`, `json.Unmarshal()` (concise and clear)
- Types: `json.Encoder`, `json.Decoder` (no stuttering)

**`net/http` package:**
- Package path: `net/http` (HTTP protocol in networking)
- Key types: `http.Client`, `http.Server`, `http.Request` (concise)
- Key functions: `http.Get()`, `http.Post()` (clear without stuttering)

These patterns have been validated through nearly 20 years of use. New Go projects are recommended to follow the same principles.

## Conclusion

Go's package conventions are not just rules. They are guidelines that help keep code clear, maintainable, and consistent across the Go community. Organizing packages by responsibility improves cohesion and reduces coupling. Using package paths as namespaces makes code easier to navigate. Avoiding redundancy keeps APIs concise and readable.

Apply these principles based on the size and needs of your project. Small projects can start with a simple structure and grow over time. Larger codebases benefit from defining package boundaries and responsibilities early. The Go standard library and well-maintained open source projects are strong references for writing idiomatic Go code.

> Reference: https://go.dev/blog/package-names
