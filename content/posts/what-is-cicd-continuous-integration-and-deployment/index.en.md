---
title: "What is CI/CD?"
date: 2024-06-10T17:14:26+09:00
tags: ["CI", "CD", "Continuous Integration", "Continuous Delivery"]
draft: false
---

## CI (Continuous Integration)

CI (Continuous Integration) means continuous integration. It is a process of automatically building and testing code whenever it is written and changed. Simply put, it is a process of automatically integrating code written by multiple developers.

### How CI Works

1. A developer modifies code
2. The code is pushed to a repository (e.g., GitHub)
3. A CI tool automatically fetches the code and builds it
4. It runs tests
5. It notifies the developer with the results

### Benefits of CI

-   Code issues can be found quickly
-   The time for manually building and testing can be reduced
-   High-quality code can be maintained

## CD (Continuous Deployment)

CD (Continuous Deployment) means continuous deployment. It is a process of automatically reflecting the code that has passed through the CI process into a service. In other words, it is a process of making developed content available to users right away.

### How CD Works

1. It receives the code that has passed through the CI process
2. It automatically starts the deployment process
3. It applies the new code to the service
4. It checks the deployment results

### Benefits of CD

-   There is no need for manual deployment processes
-   Deployment errors can be reduced
-   New features can be provided quickly

## Representative CI/CD Tools

-   Jenkins: The most widely used tool
-   GitHub Actions: A tool that works well with GitHub
-   GitLab CI: A tool provided by GitLab
-   AWS CodePipeline: A tool provided by AWS

## Summary

CI/CD automates the process from development to deployment. CI automates the process of integrating and testing code, and CD automates the process of reflecting this into the actual service. This allows developers to focus more on writing code, and users can use new features more quickly.
