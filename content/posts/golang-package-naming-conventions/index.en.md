---
title: "Golang Package Conventions"
date: 2025-02-15T21:40:48+09:00
tags: ['golang', 'package', 'convention', 'architecture', 'best-practices']
description: "Learn about the package structure recommended by the creators of the Go language, common pitfalls, and proven solutions from real-world projects."
draft: false
---

> This article was written in reference to the Go blog "Package Names" and several Go package convention resources.

## Key Tenets of Package Conventions

Go's package convention does not prescribe strict rules for directory structure or architecture instead, it presents the following key principles:

## 1. Organize Packages by Responsibility

Avoid putting all types in a single package such as interfaces or models. Instead, organize packages based on the responsibility of their domain, following the "Organize by responsibility" principle. For example:

-   user package: responsible for user management
-   order package: responsible for order management

## 2. Leverage Package Paths

Go leverages the package path itself as an expressive tool.  We can see this demonstrated in several of the official Go packages:

-   crypto/: Namespace for packages related to cryptography
-   encoding/: Namespace for packages related to encoding

This approach provides clear separation of concerns for packages with the same name like runtime/pprof and net/http/pprof.

## 3. Avoid Duplication

Avoid repeating information in the package name that the package path already provides. This helps to keep code concise and readable.

## Conclusion

These conventions are not hard rules but rather guidelines intended to promote clarity and maintainability in your code.  It's important to apply them appropriately to the context of your project.

> Reference: https://go.dev/blog/package-names
