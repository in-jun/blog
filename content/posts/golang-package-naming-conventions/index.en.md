---
title: "Go Package Naming Conventions"
date: 2025-02-15T21:40:48+09:00
tags: ["Go", "Programming"]
description: "Package naming rules and best practices in Go."
draft: false
---

> This article references the official Go blog's "Package Names," Go code review comments, and standard library design cases.

## Go Package Design Philosophy

Go's package system has a unique philosophy compared to other languages, reflecting Go's core design principles of simplicity and clarity. Go did not adopt complex package hierarchies like Java or C++'s namespace system. Instead, it separates package paths and package names to enable concise yet expressive code.

Go's package conventions do not enforce strict rules for directory structure or architectural patterns. This is a deliberate design choice by the Go team. Go language creators, including Rob Pike and Ken Thompson, preferred an approach that provides flexibility to programmers while offering clear guidelines. This philosophy can be observed in the package structure of the standard library. Go's package conventions are built around the following key principles.

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

Go uses package paths themselves as expressive tools and namespaces. This is one of Go's unique characteristics. Package paths are not merely file system locations but semantic tools that express the purpose and category of packages. The Go standard library is a representative case of consistently applying this principle.

### Hierarchical Namespaces in the Standard Library

The Go standard library groups related packages under top-level directories to provide clear namespaces.

-   `crypto/`: Namespace for cryptography-related packages, including `crypto/aes`, `crypto/rsa`, `crypto/sha256`, providing all cryptographic algorithms and functions under a consistent path.
-   `encoding/`: Namespace for data encoding-related packages, including `encoding/json`, `encoding/xml`, `encoding/base64`, supporting various encoding formats.
-   `net/`: Namespace for network-related packages, including `net/http`, `net/url`, `net/rpc`, providing all network programming functionality.

### Clear Distinction of Packages with Identical Names

Using package paths allows clear distinction between packages with identical names based on purpose and usage. A representative example is the `pprof` package.

-   `runtime/pprof`: A low-level package that generates and saves runtime profiling data. Use this when you need to save profiling data to a file or control it directly.
-   `net/http/pprof`: A high-level package that provides profiling data through an HTTP server. It registers HTTP handlers so profiling information can be viewed in a web browser.

Both packages use the name `pprof`, but the paths clearly indicate that `runtime/pprof` provides runtime-related functionality and `net/http/pprof` provides HTTP server-related functionality. Users can determine which package to use just by looking at the import path.

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

When used, such code becomes unnecessarily verbose with `user.UserService` or `json.JSONEncoder`, where `user` and `json` information is repeated twice.

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

Package names themselves follow Go philosophy, being concise, clear, and lowercase-only.

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

## Practical Application Cases

### Standard Library Analysis

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

Go's package conventions are not mere rules but guidelines for code clarity, maintainability, and consistency across the Go community. These principles reflect decades of programming experience and philosophy from Go's language creators. Responsibility-based package organization achieves high cohesion and low coupling. Namespace utilization through package paths provides clear structure. Eliminating redundancy creates concise and readable code.

It is important to appropriately apply these principles according to each project's context and scale. Small projects can start with simple structures and expand gradually as needed. Large projects should consider clear package boundaries and responsibility separation from the beginning. Referencing the Go standard library and popular open-source projects can teach real-world application cases, greatly helping in writing idiomatic Go code.

> Reference: https://go.dev/blog/package-names
